# حرفي الجزائر | Herafi Algeria

منصة ربط الزبائن بالحرفيين في الجزائر.

## المميزات الحالية

- تسجيل ودخول برقم الهاتف (OTP)
- اختيار نوع الحساب: زبون / حرفي شخصي / مؤسسة / مجموعة
- إكمال الملف الشخصي (ولاية + بلدية)
- الصفحة الرئيسية مع التخصصات والبحث
- قائمة الطلبات (جارية / مكتملة / ملغاة)
- الملف الشخصي
- الإعدادات الكاملة:
  - الوضع الليلي / الفاتح
  - تغيير اللغة (عربي / فرنسي / إنجليزي)
  - تعديل الملف
  - حذف الحساب
  - تسجيل الخروج
- دعم RTL كامل
- تصميم Material 3 عصري

## التقنيات

- Flutter 3.x
- Riverpod (State Management)
- Firebase (Auth + Firestore + Messaging) — قيد الربط
- Google Fonts (Cairo)

## كيفية التشغيل

1. تأكد من تثبيت Flutter SDK:
```bash
flutter doctor
```

2. انسخ المشروع وافتحه:
```bash
cd herafi-algeria-app
flutter pub get
```

3. أضف ملفات Firebase:
- أنشئ مشروع Firebase
- فعّل Authentication (Phone)
- فعّل Firestore
- نزّل `google-services.json` وضعه في `android/app/`
- نزّل `GoogleService-Info.plist` لـ iOS إن أردت

4. شغّل التطبيق:
```bash
flutter run
```

## بناء APK / AAB

```bash
# APK
flutter build apk --release

# App Bundle (لـ Google Play)
flutter build appbundle --release
```

الملفات الناتجة:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

## هيكل المشروع

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── home/
│   ├── orders/
│   ├── profile/
│   ├── search/
│   ├── settings/
│   └── craftsman/
├── models/
├── services/
└── main.dart
```

## ما تم إنجازه

- [x] المصادقة (هاتف + OTP)
- [x] اختيار نوع الحساب (زبون / حرفي / مؤسسة / مجموعة)
- [x] إكمال الملف الشخصي
- [x] الصفحة الرئيسية + التخصصات
- [x] البحث المتقدم مع فلاتر
- [x] صفحة تفاصيل الحرفي
- [x] إنشاء طلب خدمة
- [x] التقييم بالنجوم
- [x] الإعدادات (ثيم + لغات + حذف حساب)
- [x] بيانات ولايات وبلديات جزائرية
- [x] ملفات Android للبناء
- [x] تطبيق الأدمن (هيكل أولي)

## الخطوات القادمة

- [ ] ربط Firebase Auth + Firestore الحقيقي
- [ ] استكمال بيانات 69 ولاية
- [ ] الإشعارات Push
- [ ] إكمال تطبيق الأدمن
- [ ] أيقونة التطبيق الاحترافية
- [ ] اختبارات وإطلاق تجريبي

## الترخيص

خاص بالمشروع — جميع الحقوق محفوظة.
