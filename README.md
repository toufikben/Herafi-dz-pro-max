# حرفي الجزائر | Herafi Algeria

منصة ربط الزبائن بالحرفيين في الجزائر.

## المشاريع

| المجلد | الوصف |
|--------|--------|
| `herafi-algeria-app/` | تطبيق الزبون + الحرفي (Android) |
| `herafi-algeria-admin/` | لوحة تحكم الأدمن (Android) |

## التشغيل المحلي

```bash
# المتطلبات: Flutter 3.24+ و Android SDK
cd herafi-algeria-app
flutter pub get
flutter run

# الأدمن
cd herafi-algeria-admin
flutter create . --org com.herafi.algeria --project-name herafi_algeria_admin --platforms=android
flutter pub get
flutter run
```

## بناء APK / AAB

```bash
cd herafi-algeria-app
flutter build apk --release
flutter build appbundle --release
```

الملفات:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

## البناء التلقائي عبر GitHub Actions

1. ارفع `herafi-algeria-app` إلى مستودع GitHub
2. عند كل push على `main` يُبنى APK و AAB تلقائياً
3. من تبويب **Actions** → اختر آخر workflow → **Artifacts** → حمّل APK/AAB

الملف: `.github/workflows/build.yml`

## Firebase (إلزامي للإنتاج)

راجع:
- `herafi-algeria-app/FIREBASE_SETUP.md`
- `SETUP_COMPLETE_GUIDE.md`
- `herafi-algeria-app/firebase/firestore.rules`

ضع `google-services.json` في:
`herafi-algeria-app/android/app/google-services.json`

## الوثائق

- `SETUP_COMPLETE_GUIDE.md` — دليل التجهيز الكامل
- `GITHUB_INSTRUCTIONS.md` — رفع وبناء
- `PROJECT_STATUS.md` — حالة المشروع

## الترخيص

خاص بالمشروع.
