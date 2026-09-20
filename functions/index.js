const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// إشعار حقيقي لما حالة الطلب تتغير
exports.onOrderStatusChange = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.status === after.status) return null;

    const clientId = after.clientId;
    const deliveryId = after.deliveryId;

    // جيب FCM token للعميل
    if (clientId) {
      const userDoc = await admin.firestore().collection('users').doc(clientId).get();
      const fcmToken = userDoc.data()?.fcmToken;
      if (fcmToken) {
        let title = 'مطعمي';
        let body = '';
        if (after.status === 'في الطريق') {
          title = '🔴 الدليفري في الطريق';
          body = `الدليفري ${after.deliveryId ? 'قرب منك' : ''} - تتبع لايف شغال - ${after.deliveryFee?.toFixed(2)}ج`;
        } else if (after.status === 'تم التوصيل') {
          title = '✅ تم التوصيل';
          body = `طلبك وصل - قيّم المطعم - ${after.total?.toFixed(2)}ج`;
        } else if (after.status === 'مزاد') {
          title = '🔥 مزاد جديد';
          body = `فيه ${after.bidsCount||0} مزايدة على طلبك - اختار أرخص واحد`;
        }

        await admin.messaging().send({
          token: fcmToken,
          notification: { title, body },
          data: { orderId: context.params.orderId, status: after.status }
        });
        console.log(`FCM sent to ${clientId}: ${title}`);
      }
    }

    // إشعار للدليفري لما يكسب مزاد
    if (after.status === 'في الطريق' && before.status === 'مزاد' && deliveryId) {
      const delDoc = await admin.firestore().collection('users').doc(deliveryId).get();
      const delToken = delDoc.data()?.fcmToken;
      if (delToken) {
        await admin.messaging().send({
          token: delToken,
          notification: {
            title: '🎉 كسبت المزاد!',
            body: `العميل اختارك - ${after.deliveryFee?.toFixed(2)}ج - روح استلم الأكل`
          }
        });
      }
    }
    return null;
  });

// إشعار لما حد يزايد في مزادك
exports.onNewBid = functions.firestore
  .document('orders/{orderId}/bids/{bidId}')
  .onCreate(async (snap, context) => {
    const bid = snap.data();
    const orderId = context.params.orderId;
    const orderDoc = await admin.firestore().collection('orders').doc(orderId).get();
    const order = orderDoc.data();
    if (!order) return null;

    const clientDoc = await admin.firestore().collection('users').doc(order.clientId).get();
    const clientToken = clientDoc.data()?.fcmToken;
    if (clientToken) {
      await admin.messaging().send({
        token: clientToken,
        notification: {
          title: `🔥 مزايدة جديدة: ${bid.bidFee?.toFixed(2)}ج`,
          body: `${bid.deliveryName} - ${bid.etaMinutes} دقيقة - ${bid.bidFee < (order.deliveryFee||100) ? 'أرخص!' : ''}`
        }
      });
    }
    return null;
  });
