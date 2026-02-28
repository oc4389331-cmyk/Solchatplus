const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Trigger que se activa al crear un nuevo mensaje en un chat.
 * Envía una notificación push al destinatario.
 */
exports.onMessageCreated = functions.firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const messageData = snapshot.data();
        const chatId = context.params.chatId;

        console.log(`[onMessageCreated] Iniciando para Chat: ${chatId}, Mensaje: ${context.params.messageId}`);

        // 1. Obtener información del chat
        const chatDoc = await admin.firestore().collection('chats').doc(chatId).get();
        if (!chatDoc.exists) return null;

        const chatData = chatDoc.data();
        const participants = chatData.participants;
        const senderId = messageData.senderId;
        const type = messageData.type || 'text';
        const isGroup = chatData.isGroup || false;
        const groupName = chatData.name || 'Grupo';

        if (!participants || !Array.isArray(participants)) return null;

        // Identificar destinatarios
        const recipientAddresses = participants.filter(addr => addr !== senderId);
        if (recipientAddresses.length === 0) return null;

        // 2. Obtener tokens y verificar presencia
        const tokens = [];
        const userPromises = recipientAddresses.map(addr => admin.firestore().collection('users').doc(addr).get());
        const userDocs = await Promise.all(userPromises);

        userDocs.forEach((userDoc, index) => {
            const addr = recipientAddresses[index];
            if (userDoc.exists) {
                const userData = userDoc.data();
                const recipientActiveChat = userData.activeChatId ? String(userData.activeChatId).trim().toLowerCase() : null;
                const currentChat = String(chatId).trim().toLowerCase();
                const isOnline = userData.isOnline === true;

                // LÓGICA DE PRESENCIA RESILIENTE
                const lastSeen = userData.lastSeen ? userData.lastSeen.toDate() : new Date(0);
                const now = new Date();
                const secondsSinceLastSeen = (now - lastSeen) / 1000;

                // Si el usuario está en el chat y está online (con margen de 15s), saltamos el push
                const effectivelyOffline = !isOnline || secondsSinceLastSeen > 15;

                if (!effectivelyOffline && recipientActiveChat === currentChat) {
                    console.log(`[onMessageCreated] SKIP: User ${addr} is actively viewing this chat.`);
                    return;
                }

                if (userData.fcmToken) {
                    tokens.push(userData.fcmToken);
                }
            }
        });

        if (tokens.length === 0) return null;

        // 3. Obtener nombre del remitente
        const senderDoc = await admin.firestore().collection('users').doc(senderId).get();
        const senderName = (senderDoc.exists && senderDoc.data().nickname) ? senderDoc.data().nickname : 'Alguien';

        // 4. CUERPO DE NOTIFICACIÓN (Individual)
        let finalBody = '';
        if (type === 'image') finalBody = '📷 Imagen';
        else if (type === 'payment') finalBody = '💸 Pago';
        else finalBody = messageData.text || 'Nuevo mensaje';

        const notificationTitle = isGroup ? `${groupName}` : senderName;

        // 5. Configurar mensaje
        const message = {
            notification: {
                title: notificationTitle,
                body: finalBody,
            },
            android: {
                priority: 'high',
                notification: {
                    channelId: 'high_importance_channel',
                    sound: 'default',
                    // Eliminamos clickAction explícito para que use el comportamiento por defecto (abrir app)
                },
            },
            apns: {
                payload: {
                    aps: {
                        threadId: chatId, // threadId es correcto para agrupación en iOS
                        sound: 'default',
                        badge: 1,
                        contentAvailable: true,
                        mutableContent: true,
                    },
                },
            },
            data: {
                chatId: chatId,
                type: type,
                senderId: senderId,
                isGroup: String(isGroup),
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                // Pasamos el groupKey en data para control local
                groupKey: chatId,
            },
            tokens: tokens,
        };

        try {
            const response = await admin.messaging().sendEachForMulticast(message);
            console.log(`[onMessageCreated] Enviado: ${response.successCount}, Fallidos: ${response.failureCount}`);
            return response;
        } catch (error) {
            console.error('[onMessageCreated] Error crítico:', error);
            return null;
        }
    });

const solanaWeb3 = require('@solana/web3.js');

/**
 * Trigger que se activa al crear un nuevo chat/grupo.
 * Verifica el pago de la comisión on-chain.
 */
exports.onGroupCreated = functions.firestore
    .document('chats/{chatId}')
    .onCreate(async (snapshot, context) => {
        const chatData = snapshot.data();
        if (!chatData.isGroup) return null;

        const signature = chatData.paymentSignature;
        const token = chatData.paymentToken || 'SOL';
        const projectFeeWallet = '575z43vmBjh4dKjG42TQXJBKRCHTkEWMbhLXseDCuQKh';
        const expectedSolAmount = 0.01;
        const expectedSkrAmount = 31.0;

        if (!signature) {
            await snapshot.ref.delete();
            return null;
        }

        try {
            const connection = new solanaWeb3.Connection(solanaWeb3.clusterApiUrl('mainnet-beta'), 'confirmed');
            const tx = await connection.getParsedTransaction(signature, {
                maxSupportedTransactionVersion: 0,
            });

            if (!tx) {
                await snapshot.ref.delete();
                return null;
            }

            let isValid = false;
            const instructions = tx.transaction.message.instructions;

            if (token === 'SOL') {
                for (const inst of instructions) {
                    if (inst.program === 'system' && inst.parsed.type === 'transfer') {
                        const info = inst.parsed.info;
                        const amountSol = info.lamports / 1e9;
                        if (info.destination === projectFeeWallet && amountSol >= expectedSolAmount) {
                            isValid = true;
                            break;
                        }
                    }
                }
            } else if (token === 'SKR') {
                for (const inst of instructions) {
                    if (inst.program === 'spl-token' && inst.parsed.type === 'transfer') {
                        const info = inst.parsed.info;
                        if (info.destination && info.amount) {
                            const amountSkr = parseFloat(info.amount) / 1e6;
                            if (amountSkr >= expectedSkrAmount) {
                                isValid = true;
                                break;
                            }
                        }
                    }
                }
            }

            if (!isValid) {
                await snapshot.ref.delete();
            }
            return null;

        } catch (error) {
            console.error('Error onGroupCreated:', error);
            return null;
        }
    });
