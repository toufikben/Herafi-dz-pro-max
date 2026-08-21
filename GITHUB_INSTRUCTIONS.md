# تعليمات رفع المشروع على GitHub وبناء APK / AAB

## 1. رفع المشروع على GitHub

### إنشاء مستودعين منفصلين (موصى به)

```bash
# تطبيق الزبون + الحرفي
cd herafi-algeria-app
git init
git add .
git commit -m "Initial commit - Herafi Algeria App"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/herafi-algeria-app.git
git push -u origin main

# تطبيق الأدمن
cd ../herafi-algeria-admin
git init
git add .
git commit -m "Initial commit - Herafi Algeria Admin"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/herafi-algeria-admin.git
git push -u origin main
```

أو يمكنك رفعهما في مستودع واحد بمجلدين.

---

## 2. تجهيز البيئة على جهازك

1. ثبّت [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. ثبّت Android Studio وافتح SDK Manager لتثبيت:
   - Android SDK
   - Android SDK Command-line Tools
   - Android Emulator (اختياري)
3. شغّل:
```bash
flutter doctor
```
تأكد أن كل شيء يظهر بعلامة ✓

---

## 3. تشغيل التطبيق

```bash
cd herafi-algeria-app
flutter pub get
flutter run
```

---

## 4. بناء APK (للتوزيع المباشر)

```bash
cd herafi-algeria-app
flutter build apk --release
```

الملف الناتج:
```
build/app/outputs/flutter-apk/app-release.apk
```

### بناء APK مقسّم حسب المعمارية (أصغر حجماً):
```bash
flutter build apk --split-per-abi --release
```

---

## 5. بناء AAB (لـ Google Play Store)

```bash
flutter build appbundle --release
```

الملف الناتج:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 6. توقيع التطبيق (Signing) قبل النشر

1. أنشئ مفتاح توقيع:
```bash
keytool -genkey -v -keystore herafi-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias herafi
```

2. أنشئ ملف `android/key.properties`:
```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=herafi
storeFile=../herafi-release-key.jks
```

3. عدّل `android/app/build.gradle` لإضافة signingConfig (راجع وثائق Flutter).

---

## 7. ربط Firebase (مهم)

1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. أنشئ مشروع جديد
3. أضف تطبيق Android بـ package name: `com.herafi.algeria`
4. نزّل `google-services.json` وضعه في:
   ```
   herafi-algeria-app/android/app/google-services.json
   ```
5. فعّل:
   - Authentication → Phone
   - Cloud Firestore
   - Cloud Messaging
6. ألغِ التعليق عن سطر `google-services` في `build.gradle` و `settings.gradle`

---

## 8. ملاحظات مهمة

- حالياً التطبيق يستخدم بيانات وهمية (Mock) للعرض.
- بعد ربط Firebase ستعمل المصادقة والطلبات الحقيقية.
- تأكد من تغيير `applicationId` إذا أردت نشراً خاصاً بك.
- الأيقونة الحالية افتراضية — استبدلها لاحقاً بأيقونة احترافية.

---

## هيكل المجلدين النهائي

```
artifacts/
├── herafi-algeria-app/          ← تطبيق الزبون + الحرفي
│   ├── android/
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
├── herafi-algeria-admin/        ← تطبيق الأدمن
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
└── GITHUB_INSTRUCTIONS.md       ← هذا الملف
```
