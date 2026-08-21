// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Herafi Algeria';

  @override
  String get welcome => 'Welcome to Herafi Algeria';

  @override
  String get search => 'Search for a craftsman or specialty...';

  @override
  String get categories => 'Specialties';

  @override
  String get featuredCraftsmen => 'Featured Craftsmen';

  @override
  String get viewAll => 'View All';

  @override
  String get retry => 'Retry';

  @override
  String get errorLoadingCraftsmen =>
      'Could not load craftsmen. Check Firebase connection.';

  @override
  String get call => 'Call';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get home => 'Home';

  @override
  String get orders => 'My Orders';

  @override
  String get myAccount => 'My Account';

  @override
  String get settings => 'Settings';

  @override
  String get selectWilayaFirst => 'Please select a wilaya first';

  @override
  String get selectSpecialtyAtLeastOne =>
      'Please select at least one specialty';

  @override
  String get loginFirst => 'Please login first';

  @override
  String get editProfileSaved => 'Profile updated successfully';

  @override
  String profileSaveFailed(String error) {
    return 'Profile save failed: $error';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get editProfileHint => 'You can edit your personal information here';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get wilaya => 'Wilaya';

  @override
  String get commune => 'Commune';

  @override
  String get specialties => 'Specialties';

  @override
  String get bioOptional => 'Bio (Optional)';

  @override
  String get priceNoteOptional => 'Price Note (Optional)';

  @override
  String get priceNoteHint =>
      'e.g., Price depends on work, or starts from 1000 DZD';

  @override
  String get yearsOfExperience => 'Years of Experience';

  @override
  String get saveEdits => 'Save Edits';

  @override
  String get saveAndContinue => 'Save and Continue';

  @override
  String get selectWilaya => 'Select Wilaya';

  @override
  String get selectAppointmentFirst => 'Please select an appointment first';

  @override
  String get mustLoginFirst => 'Must login first';

  @override
  String sendOrderFailed(String error) {
    return 'Failed to send order: $error';
  }

  @override
  String get orderSentSuccessfully => 'Order sent successfully';

  @override
  String craftsmanWillBeNotified(String name) {
    return 'Craftsman $name will be notified of your request';
  }

  @override
  String get ok => 'OK';

  @override
  String get orderService => 'Request Service';

  @override
  String get problemDescription => 'Problem Description';

  @override
  String get problemDescriptionHint => 'Explain exactly what you need...';

  @override
  String get descriptionTooShort => 'Description is too short';

  @override
  String get location => 'Location';

  @override
  String get detailedAddressOptional => 'Detailed Address (Optional)';

  @override
  String get serviceTime => 'Service Time';

  @override
  String get immediate => 'Immediate';

  @override
  String get laterAppointment => 'Later Appointment';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get sendOrder => 'Send Order';
}
