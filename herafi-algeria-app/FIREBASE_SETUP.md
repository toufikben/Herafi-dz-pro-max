# دليل ربط Firebase لمشروع حرفي الجزائر

## الخطوة 1: إنشاء مشروع Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. اضغط **Add project** → اختر اسماً (مثلاً `herafi-algeria`)
3. عطّل Google Analytics إن أردت (اختياري)
4. انتظر حتى يُنشأ المشروع

---

## الخطوة 2: إضافة تطبيق Android

1. من لوحة المشروع → **Add app** → Android
2. **Android package name**: `com.herafi.algeria`
3. App nickname: `Herafi Algeria`
4. نزّل ملف **`google-services.json`**
5. ضعه في المسار التالي:
   ```
   herafi-algeria-app/android/app/google-services.json
   ```

---

## الخطوة 3: تفعيل الخدمات

### Authentication
1. من القائمة الجانبية → **Build** → **Authentication**
2. اضغط **Get started**
3. اختر **Phone** → Enable
4. أضف أرقام اختبار إن أردت (للتطوير بدون SMS حقيقي)

### Cloud Firestore
1. **Build** → **Firestore Database**
2. **Create database**
3. اختر **Start in test mode** أولاً (للتجربة)
4. اختر أقرب موقع (مثل `europe-west`)

### Cloud Messaging (للإشعارات لاحقاً)
1. **Build** → **Cloud Messaging**
2. لا يحتاج إعداداً إضافياً في البداية

---

## الخطوة 4: قواعد الأمان (Firestore Rules)

بعد التجربة، غيّر القواعد إلى شيء مثل:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /orders/{orderId} {
      allow read, write: if request.auth != null &&
        (resource == null ||
         request.auth.uid == resource.data.customerId ||
         request.auth.uid == resource.data.craftsmanId);
    }
  }
}
```

---

## الخطوة 5: تفعيل Google Services في المشروع

### في `android/settings.gradle`
أزل التعليق عن السطر:
```gradle
id "com.google.gms.google-services" version "4.4.2" apply false
```

### في `android/app/build.gradle`
أزل التعليق عن:
```gradle
id "com.google.gms.google-services"
```

وفي dependencies:
```gradle
implementation platform('com.google.firebase:firebase-bom:33.5.1')
```

---

## الخطوة 6: تحديث firebase_options.dart

### الطريقة المفضلة (FlutterFire CLI):
```bash
# تثبيت الأداة
dart pub global activate flutterfire_cli

# من مجلد المشروع
flutterfire configure
```

ستُنشئ الملف تلقائياً بالقيم الصحيحة.

### أو يدوياً:
افتح `lib/core/config/firebase_options.dart` واستبدل:
- `YOUR_ANDROID_API_KEY`
- `YOUR_ANDROID_APP_ID`
- `YOUR_SENDER_ID`
- `YOUR_PROJECT_ID`

يمكنك إيجاد هذه القيم في:
Firebase Console → Project Settings → Your apps → SDK setup

---

## الخطوة 7: الفهارس (Indexes) في Firestore

بعض الاستعلامات تحتاج فهارس مركبة. عند ظهور خطأ في التطبيق، Firebase يعطيك رابطاً لإنشاء الفهرس تلقائياً.

الاستعلامات المتوقعة:
- `role` + `wilaya` + `isActive`
- `role` + `rating` (ترتيب)
- `customerId` + `createdAt`
- `craftsmanId` + `createdAt`

---

## الخطوة 8: اختبار Phone Auth

1. في Authentication → Phone → Phone numbers for testing
2. أضف رقماً مثل: `+213555000000` مع رمز `123456`
3. استخدم هذا الرقم في التطبيق أثناء التطوير (بدون تكلفة SMS)

---

## ملاحظات مهمة

- **لا ترفع** `google-services.json` إلى مستودع عام إن كان يحتوي مفاتيح حساسة (يفضل إضافته في `.gitignore` في بعض الحالات، لكن Google توصي بإدراجه).
- تأكد أن `minSdk` ≥ 21 (موجود حالياً).
- على محاكي Android: استخدم أرقام الاختبار فقط، لأن SMS الحقيقي لا يصل للمحاكي بسهولة.
- بعد الربط، احذف المنطق الوهمي من شاشات Auth تدريجياً واستخدم `AuthService` الحقيقي.

---

## هيكل المجموعات في Firestore

```
users/{uid}
  - phone, fullName, role, craftsmanType
  - wilaya, commune, address
  - specialties[], yearsOfExperience, bio, priceNote
  - workPhotos[], rating, ratingCount
  - isVerified, isActive, isBlocked
  - createdAt, updatedAt

orders/{orderId}
  - customerId, craftsmanId, categoryId
  - description, wilaya, commune, address
  - preferredTime, status
  - customerRating, craftsmanRating
  - createdAt, updatedAt, completedAt
```
