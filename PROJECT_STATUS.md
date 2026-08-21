# حالة مشروع حرفي الجزائر — ملخص نهائي قبل الرفع على GitHub

**التاريخ:** أغسطس 2026

---

## المجلدات

```
artifacts/
├── herafi-algeria-app/       # تطبيق الزبون + الحرفي (Flutter)
├── herafi-algeria-admin/     # تطبيق لوحة التحكم (Flutter)
├── GITHUB_INSTRUCTIONS.md    # تعليمات الرفع والبناء
└── PROJECT_STATUS.md         # هذا الملف
```

---

## ما تم إنجازه بالكامل

### تطبيق الزبون + الحرفي
- [x] Splash + التحقق من الجلسة
- [x] تسجيل برقم الهاتف (OTP) مربوط بـ Firebase Auth
- [x] اختيار نوع الحساب (زبون / حرفي شخصي / مؤسسة / مجموعة)
- [x] إكمال الملف الشخصي + حفظ في Firestore
- [x] الرئيسية + التخصصات
- [x] بحث متقدم (تخصص، ولاية، بلدية، تقييم، موثّق) مربوط بـ Firestore
- [x] تفاصيل الحرفي + اتصال / واتساب / طلب خدمة
- [x] إنشاء طلب مربوط بـ Firestore
- [x] قائمة الطلبات (Stream) + تقييم بالنجوم
- [x] الملف الشخصي
- [x] الإعدادات (ثيم ليلي/فاتح، 3 لغات، خروج، حذف حساب)
- [x] 58 ولاية مع بلدياتها
- [x] خدمة الإشعارات Push (FCM)
- [x] أيقونة تطبيق تكيفية (Teal + رمز أدوات)
- [x] ملفات Android للبناء (Manifest, Gradle, ProGuard)

### تطبيق الأدمن
- [x] شاشة دخول
- [x] إحصائيات (جاهزة للربط بـ AdminStatsService)
- [x] إدارة المستخدمين (تبويبات + إجراءات)
- [x] إدارة الطلبات + تفاصيل
- [x] إدارة التخصصات
- [x] إعدادات + خروج
- [x] خدمة AdminStatsService لجلب الإحصائيات من Firestore

### وثائق
- [x] README لكل مشروع
- [x] FIREBASE_SETUP.md
- [x] GITHUB_INSTRUCTIONS.md

---

## قبل الرفع على GitHub — قائمة سريعة

1. أنشئ مشروع Firebase وضع `google-services.json`
2. شغّل `flutterfire configure` أو عدّل `firebase_options.dart`
3. اختبر على جهاز حقيقي (OTP)
4. (اختياري) استبدل أيقونة XML بأيقونة PNG احترافية عبر [appicon.co](https://www.appicon.co)
5. ارفع المستودعين حسب `GITHUB_INSTRUCTIONS.md`
6. ابنِ APK/AAB:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

---

## ملاحظات تقنية

- التطبيق يعمل في **وضع تجريبي** إذا لم يكن Firebase مهيأً (بيانات وهمية).
- بعد الربط، كل المسارات الحقيقية تعمل عبر الخدمات في `lib/services/`.
- للأدمن: يُفضّل لاحقاً Email/Password Auth منفصل عن Phone Auth للزبائن.
- فهارس Firestore قد تُطلب تلقائياً من الروابط في رسائل الخطأ عند أول استعلام مركّب.

---

## الترخيص

خاص بالمشروع — جميع الحقوق محفوظة.
