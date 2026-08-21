// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'حرفي الجزائر';

  @override
  String get welcome => 'مرحباً بك في حرفي الجزائر';

  @override
  String get search => 'ابحث عن حرفي أو تخصص...';

  @override
  String get categories => 'التخصصات';

  @override
  String get featuredCraftsmen => 'حرفيون مميزون';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorLoadingCraftsmen =>
      'تعذر تحميل الحرفيين. تحقق من الاتصال بـ Firebase.';

  @override
  String get call => 'اتصال';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get home => 'الرئيسية';

  @override
  String get orders => 'طلباتي';

  @override
  String get myAccount => 'حسابي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get selectWilayaFirst => 'يرجى اختيار الولاية أولاً';

  @override
  String get selectSpecialtyAtLeastOne => 'يرجى اختيار تخصص واحد على الأقل';

  @override
  String get loginFirst => 'يرجى تسجيل الدخول أولاً';

  @override
  String get editProfileSaved => 'تم حفظ التعديلات بنجاح';

  @override
  String profileSaveFailed(String error) {
    return 'فشل حفظ الملف الشخصي: $error';
  }

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get completeProfile => 'إكمال الملف الشخصي';

  @override
  String get editProfileHint => 'يمكنك تعديل معلوماتك الشخصية هنا';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get wilaya => 'الولاية';

  @override
  String get commune => 'البلدية';

  @override
  String get specialties => 'التخصصات';

  @override
  String get bioOptional => 'نبذة شخصية (اختياري)';

  @override
  String get priceNoteOptional => 'ملاحظة حول السعر (اختياري)';

  @override
  String get priceNoteHint => 'مثال: السعر حسب العمل، أو يبدأ من 1000 دج';

  @override
  String get yearsOfExperience => 'سنوات الخبرة';

  @override
  String get saveEdits => 'حفظ التعديلات';

  @override
  String get saveAndContinue => 'حفظ ومتابعة';

  @override
  String get selectWilaya => 'اختر الولاية';

  @override
  String get selectAppointmentFirst => 'يرجى اختيار الموعد أولاً';

  @override
  String get mustLoginFirst => 'يجب تسجيل الدخول أولاً';

  @override
  String sendOrderFailed(String error) {
    return 'فشل إرسال الطلب: $error';
  }

  @override
  String get orderSentSuccessfully => 'تم إرسال الطلب بنجاح';

  @override
  String craftsmanWillBeNotified(String name) {
    return 'سيتم إشعار الحرفي $name بطلبك';
  }

  @override
  String get ok => 'حسناً';

  @override
  String get orderService => 'طلب خدمة';

  @override
  String get problemDescription => 'وصف المشكلة';

  @override
  String get problemDescriptionHint => 'اشرح ما الذي تحتاجه بالضبط...';

  @override
  String get descriptionTooShort => 'الوصف قصير جداً';

  @override
  String get location => 'الموقع';

  @override
  String get detailedAddressOptional => 'العنوان بالتفصيل (اختياري)';

  @override
  String get serviceTime => 'وقت الخدمة';

  @override
  String get immediate => 'فوري';

  @override
  String get laterAppointment => 'موعد لاحق';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get sendOrder => 'إرسال الطلب';
}
