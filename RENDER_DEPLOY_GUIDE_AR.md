# دليل نشر خادم FCM الوسيط على منصة Render

**المشروع:** حرفي الجزائر — `Herafi-dz-pro-max`
**المستودع المستهدف:** [toufikben/herafi-fcm-relay](https://github.com/toufikben/herafi-fcm-relay)
**التاريخ:** 20 أغسطس 2026

---

## نظرة عامة

خادم FCM الوسيط (`server.py`) هو حلقة الوصل بين تطبيق Flutter ومشروع Firebase، لأنه يتولى إرسال الإشعارات باستخدام مفتاح Admin SDK دون كشفه في التطبيق. هذا الحل ضروري لأن خطة Firebase المجانية (Spark) لا تتيح Cloud Functions، لذلك نُشغّل الخادم الوسيط على منصة Render المجانية.

يعمل الخادم كخدمة FastAPI (Python) على المنفذ 8000، ويقرأ ثلاث متغيرات بيئية عند التشغيل:

| المتغير البيئي | القيمة المطلوبة | الأهمية |
|---|---|---|
| `FCM_PROJECT_ID` | `herafi-algeria` | معرف مشروع Firebase |
| `RELAY_SECRET` | كلمة سر تختارها أنت (مثل `Herafi2026Sec!`) | سر المصادقة بين التطبيق والخادم |
| `GOOGLE_SERVICE_ACCOUNT_JSON` | محتوى ملف `service-account.json` كاملًا (سطر واحد) | مفتاح Firebase Admin SDK لإرسال الإشعارات |

## المرحلة الأولى: تجهيز مفتاح الخدمة (ملف service-account.json)

مفتاح Admin SDK **غير مرفوع على GitHub عمدًا** لأسباب أمنية (مستثنى عبر `.gitignore`)، وهو موجود فقط في نسختك المحلية في:

```
herafi-algeria-app/fcm-relay/service-account.json
```

هذا الملف ضروري للنشر، وسنحوّل محتواه إلى سطر واحد لاستخدامه في Render.

## المرحلة الثانية: تحويل service-account.json إلى سطر واحد

في Terminal على جهازك، نفّذ الأمر التالي (بعد التأكد من أن المسار صحيح):

```bash
cd herafi-algeria-app/fcm-relay
python3 -c "import json; f=open('service-account.json'); print(json.dumps(json.load(f)).replace(' ',''))" > service_account_oneline.txt
cat service_account_oneline.txt
```

ينسخ هذا الأمر محتوى الملف كاملًا في سطر واحد دون مسافات — وهذا هو النص الذي ستلصقه في Render.

## المرحلة الثالثة: إنشاء الخدمة على Render

1. ادخل إلى [render.com](https://render.com) وسجّل الدخول بحساب GitHub (www.toufik155@gmail.com).
2. من لوحة التحكم اضغط **New +** ثم اختر **Web Service**.
3. اختر **Build and deploy from a Git repository** ثم **Next**.
4. اختر مستودع `toufikben/herafi-fcm-relay`. إن لم يظهر، مرّر لأسفل واضغط **Configure account** لربط حسابك ثم **Refresh**.

## المرحلة الرابعة: إعدادات الخدمة

| الحقل | القيمة |
|---|---|
| Name | `herafi-fcm-relay` |
| Region | أقرب منطقة إليك (مثل Frankfurt) |
| Branch | `master` |
| Root Directory | (اتركه فارغًا) |
| Runtime | **Python 3** |
| Build Command | `pip install -r requirements.txt` |
| Start Command | `uvicorn server:app --host 0.0.0.0 --port 8000` |
| Instance Type | Free |

## المرحلة الخامسة: إضافة المتغيرات البيئية

في نفس صفحة الإعداد، انتقل إلى قسم **Environment Variables** وأضف الثلاثة التالية:

| Key | Value |
|---|---|
| `FCM_PROJECT_ID` | `herafi-algeria` |
| `RELAY_SECRET` | كلمة السر التي اخترتها (مثل `Herafi2026Sec!`) — **احفظها، ستحتاجها في التطبيق** |
| `GOOGLE_SERVICE_ACCOUNT_JSON` | محتوى ملف `service_account_oneline.txt` كاملاً (لصقه كما هو في سطر واحد) |

**ملاحظة مهمة:** قيمة `GOOGLE_SERVICE_ACCOUNT_JSON` طويلة (أسطر JSON مضغوطة في سطر واحد). الصقها كاملة دون اقتطاع.

اضغط **Create Web Service** وانتظر حتى يكتمل البناء (عادة 2–4 دقائق). عند النجاح سترى رابطًا بصيغة:

```
https://herafi-fcm-relay.onrender.com
```

## المرحلة السادسة: اختبار الخادم

افتح الرابط التالي في المتصفح (إن كان سكربت الصحة `/health` مفعّلًا) أو نفّذ:

```bash
curl https://herafi-fcm-relay.onrender.com/health
```

إن ردّ `{"status":"ok"}` (أو ما يماثله حسب السكربت) فالخادم يعمل.

## المرحلة السابعة: ربط الخادم بتطبيق Flutter

فتح `notification_service.dart` (السطور 129–141) يعرّف متغيرين يُمرّران عند التشغيل عبر `--dart-define`:

| Dart environment | المقابل في Render |
|---|---|
| `FCM_RELAY_BASE_URL` | رابط الخدمة، مثال: `https://herafi-fcm-relay.onrender.com` |
| `FCM_RELAY_SECRET` | نفس قيمة `RELAY_SECRET` في Render |

### للتشغيل المحلي والتطوير:

```bash
flutter run --dart-define=FCM_RELAY_BASE_URL=https://herafi-fcm-relay.onrender.com --dart-define=FCM_RELAY_SECRET=Herafi2026Sec!
```

### لبناء APK النهائي:

```bash
flutter build apk --dart-define=FCM_RELAY_BASE_URL=https://herafi-fcm-relay.onrender.com --dart-define=FCM_RELAY_SECRET=Herafi2026Sec!
```

### لتطبيق الأدمن (`herafi-algeria-admin`) إن كان يحتوي واجهة إشعارات:

نفّذ نفس الأوامر في مجلد تطبيق الأدمن.

## تنبيهات مهمة

1. **تعليق الخدمة المجانية:** خطة Render المجانية تُعلّق الخدمة بعد 15 دقيقة من عدم النشاط، وأول طلب بعدها يستغرق نحو 30 ثانية (Cold Start). هذا مقبول للاختبار؛ للنشر التجاري يُفضّل الترقية لخطة مدفوعة (~7$ شهريًا) مع تفعيل **Prevent Sleep**.
2. **السرية:** لا تشارك `service-account.json` أو `RELAY_SECRET` مع أحد. المفتاح موجود محليًا فقط (غير مرفوع على GitHub)، وإذا انكشف يومًا يمكن إلغاؤه من [Firebase Console → Service Accounts](https://console.firebase.google.com/project/herafi-algeria/settings/serviceaccounts/adminsdk) وإصدار جديد.
3. **التحديثات:** بعد أي تعديل على `server.py` ورفعه إلى GitHub، يعيد Render البناء تلقائيًا خلال دقائق.
4. **أول إشعار:** الإشعارات تُرسل عبر `fcmToken` المحفوظ في Firestore عند تسجيل الدخول؛ تأكد أن المصادقة بالعمل عبر OTP تسجّل التوكن (الكود يفعل ذلك تلقائيًا عند كل تسجيل دخول).

## إذا طلب منك Render ربط الحساب من جديد

في بعض الحالات يطلب Render التفويض مجددًا عبر **Configure account** — مرّرها بنفس خطوات الربط، وستجد المستودع بعدها في قائمة Build and deploy.

---

*أُعد هذا الدليل بواسطة Manus AI لمشروع حرفي الجزائر.*
