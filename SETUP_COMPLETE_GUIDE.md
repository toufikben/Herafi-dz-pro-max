# دليل التجهيز الكامل — حرفي الجزائر
# كل ما يجب إعداده قبل التشغيل والنشر

---

## أ) ما هو جاهز في الكود (تم بناؤه)

### تطبيق الزبون + الحرفي (`herafi-algeria-app`)
| الجزء | الحالة |
|-------|--------|
| واجهات: Splash, تسجيل, OTP, اختيار دور, إكمال ملف | ✅ جاهز |
| رئيسية + تخصصات + بحث + فلاتر | ✅ جاهز |
| تفاصيل حرفي + طلب خدمة + طلباتي + تقييم | ✅ جاهز |
| ملف شخصي + إعدادات (ثيم/لغات/خروج/حذف) | ✅ جاهز |
| نماذج User + Order | ✅ جاهز |
| خدمات: Auth, User, Order, Notifications, AdminStats | ✅ جاهز (كود) |
| 58 ولاية + بلديات | ✅ جاهز |
| ملفات Android (Manifest, Gradle, ProGuard, أيقونة) | ✅ جاهز |
| ربط Firebase في الكود | ✅ جاهز (يحتاج إعداداتك) |

### تطبيق الأدمن (`herafi-algeria-admin`)
| الجزء | الحالة |
|-------|--------|
| واجهة دخول + إحصائيات + مستخدمون + طلبات + تخصصات + إعدادات | ✅ واجهات جاهزة |
| بيانات حقيقية من Firestore | ⚠️ الكود موجود في AdminStatsService — الواجهة ما زالت تعرض أرقاماً تجريبية جزئياً |
| ملفات Android كاملة للأدمن | ⚠️ يحتاج `flutter create` ثم نسخ lib |

---

## ب) ما يجب أن تجهّزه أنت (خارج الكود)

### 1. حسابات وأدوات
- [ ] حساب Google
- [ ] تثبيت Flutter SDK على جهازك
- [ ] تثبيت Android Studio + SDK
- [ ] تشغيل `flutter doctor` حتى تظهر كل العلامات ✓
- [ ] حساب GitHub (للرفع)

### 2. مشروع Firebase (إلزامي)
- [ ] إنشاء مشروع على https://console.firebase.google.com
- [ ] اسم مقترح: `herafi-algeria`
- [ ] إضافة تطبيق Android:
  - Package name: **`com.herafi.algeria`**
  - تنزيل **`google-services.json`**
  - وضعه في: `herafi-algeria-app/android/app/google-services.json`
- [ ] (اختياري للأدمن) تطبيق Android ثانٍ بـ package مختلف مثل `com.herafi.algeria.admin`

### 3. تفعيل خدمات Firebase
- [ ] **Authentication** → Sign-in method → **Phone** → Enable
- [ ] **Authentication** → أضف أرقام اختبار (للتطوير بدون SMS):
  - مثال: `+213555000000` / رمز `123456`
- [ ] **Firestore Database** → Create → ابدأ بـ Test mode ثم غيّر القواعد
- [ ] **Cloud Messaging** → مفعّل افتراضياً (للإشعارات)
- [ ] **Storage** (لاحقاً لصور الأعمال) — اختياري الآن

### 4. ملف إعدادات FlutterFire
من مجلد التطبيق:
```bash
dart pub global activate flutterfire_cli
cd herafi-algeria-app
flutterfire configure
```
أو عدّل يدوياً: `lib/core/config/firebase_options.dart`  
(استبدل YOUR_ANDROID_API_KEY, YOUR_APP_ID, YOUR_PROJECT_ID, YOUR_SENDER_ID)

### 5. قواعد قاعدة البيانات Firestore (انسخها)

في Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // المستخدمون
    match /users/{userId} {
      allow read: if true;  // البحث العام عن الحرفيين
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
      // ملاحظة: للأدمن لاحقاً أضف شرط custom claims
    }

    // الطلبات
    match /orders/{orderId} {
      allow read: if request.auth != null && (
        resource.data.customerId == request.auth.uid ||
        resource.data.craftsmanId == request.auth.uid
      );
      allow create: if request.auth != null
        && request.resource.data.customerId == request.auth.uid;
      allow update: if request.auth != null && (
        resource.data.customerId == request.auth.uid ||
        resource.data.craftsmanId == request.auth.uid
      );
    }
  }
}
```

### 6. فهارس Firestore المتوقعة
عند أول بحث/قائمة طلبات قد يظهر رابط "Create index" — اضغطه.
الفهارس الشائعة:
- `users`: role + isActive + isBlocked
- `users`: role + wilaya
- `users`: role + rating (Descending)
- `orders`: customerId + createdAt (Descending)
- `orders`: craftsmanId + createdAt (Descending)

### 7. هيكل المجموعات (Collections) — لا تنشئها يدوياً
التطبيق ينشئها تلقائياً عند أول استخدام:
```
users/{uid}
  phone, fullName, role, craftsmanType
  wilaya, commune, address
  specialties[], yearsOfExperience, bio, priceNote
  workPhotos[], rating, ratingCount
  isVerified, isActive, isBlocked
  createdAt, updatedAt

orders/{orderId}
  customerId, craftsmanId, categoryId
  description, wilaya, commune, address
  preferredTime, status
  customerRating, craftsmanRating
  createdAt, updatedAt, completedAt
```

### 8. ملفات يجب أن تكون عندك قبل البناء
| الملف | أين يوضع | من أين |
|-------|----------|--------|
| `google-services.json` | `android/app/` | Firebase Console |
| `firebase_options.dart` | `lib/core/config/` | flutterfire configure |
| (لاحقاً) `key.properties` + `.jks` | `android/` | keytool لتوقيع النشر |

### 9. أوامر التشغيل على جهازك
```bash
# التطبيق الرئيسي
cd herafi-algeria-app
flutter pub get
flutter run

# بناء APK
flutter build apk --release

# بناء AAB لمتجر Play
flutter build appbundle --release
```

### 10. تطبيق الأدمن — تجهيز إضافي
```bash
# إن لم يكن مجلد android موجوداً بالكامل:
cd herafi-algeria-admin
flutter create . --org com.herafi.algeria --project-name herafi_algeria_admin
# ثم أعد وضع lib/ و pubspec.yaml إن لزم
flutter pub get
flutter run
```
- أنشئ مستخدم أدمن في Firebase Authentication (Email/Password) يدوياً
- لاحقاً اربط الدخول بـ `signInWithEmailAndPassword`

### 11. الإشعارات (FCM)
- [ ] بعد وضع google-services.json تعمل التهيئة تلقائياً من الكود
- [ ] لإرسال إشعار من السيرفر: استخدم Firebase Console → Messaging أو Cloud Functions
- [ ] احفظ `fcmToken` في مستند المستخدم عند تسجيل الدخول (TODO صغير متبقٍ)

### 12. رفع GitHub
```bash
cd herafi-algeria-app
git init && git add . && git commit -m "Initial: Herafi Algeria app"
git remote add origin https://github.com/USER/herafi-algeria-app.git
git push -u origin main

cd ../herafi-algeria-admin
# نفس الخطوات
```
راجع أيضاً: `GITHUB_INSTRUCTIONS.md`

### 13. ما لا يوجد (عن قصد أو لاحقاً)
- لا يوجد خادم خاص (Backend Node) — الاعتماد على **Firebase فقط**
- لا يوجد دفع إلكتروني (حسب طلبك)
- لا يوجد شات داخلي (هاتف/واتساب فقط)
- لا تتبع حي على الخريطة
- صور الأعمال: الحقل موجود، رفع Storage لم يُربط بالكامل بعد
- دخول الأدمن ما زال تجريبياً (أي بريد/كلمة مرور تمرر للوحة)

---

## ج) Prompt جاهز للنسخ (Checklist سريع)

انسخ هذا واتبعه سطراً بسطر:

```
[ ] 1. تثبيت Flutter + Android Studio + flutter doctor
[ ] 2. إنشاء مشروع Firebase باسم herafi-algeria
[ ] 3. إضافة Android app: package com.herafi.algeria
[ ] 4. تنزيل google-services.json → android/app/
[ ] 5. تفعيل Phone Authentication + أرقام اختبار
[ ] 6. إنشاء Firestore (test mode ثم قواعد الأمان أعلاه)
[ ] 7. تشغيل: flutterfire configure
[ ] 8. flutter pub get && flutter run
[ ] 9. اختبار: تسجيل برقم اختبار → OTP → إكمال ملف → بحث → طلب
[ ] 10. إنشاء فهارس Firestore من الروابط إن ظهرت
[ ] 11. تفعيل قواعد الأمان النهائية
[ ] 12. تطبيق الأدمن: flutter create + تشغيل
[ ] 13. رفع GitHub حسب GITHUB_INSTRUCTIONS.md
[ ] 14. بناء APK/AAB عند الجاهزية للنشر
[ ] 15. (اختياري) أيقونة PNG احترافية + توقيع keystore
```

---

## د) خلاصة صادقة

**نعم — تم بناء:**
- واجهات التطبيقين (زبون/حرفي + أدمن)
- منطق الأعمال الأساسي
- نماذج قاعدة البيانات
- خدمات الربط مع Firebase
- قواعد مقترحة + هيكل Collections
- ولايات، إشعارات، أيقونة، ملفات بناء

**أنت مسؤول عن:**
- إنشاء مشروع Firebase وملفاته
- وضع المفاتيح والقواعد على السحابة
- تشغيل البناء على جهازك
- اختبار OTP الحقيقي
- الرفع على GitHub والنشر

بدون خطوات Firebase أعلاه، التطبيق يعمل بـ **وضع تجريبي** فقط (بيانات وهمية).
