// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Herafi Algérie';

  @override
  String get welcome => 'Bienvenue sur Herafi Algérie';

  @override
  String get search => 'Rechercher un artisan ou une spécialité...';

  @override
  String get categories => 'Spécialités';

  @override
  String get featuredCraftsmen => 'Artisans en vedette';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get retry => 'Réessayer';

  @override
  String get errorLoadingCraftsmen =>
      'Impossible de charger les artisans. Vérifiez la connexion Firebase.';

  @override
  String get call => 'Appeler';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get home => 'Accueil';

  @override
  String get orders => 'Mes commandes';

  @override
  String get myAccount => 'Mon compte';

  @override
  String get settings => 'Paramètres';

  @override
  String get selectWilayaFirst => 'Veuillez d\'abord sélectionner une wilaya';

  @override
  String get selectSpecialtyAtLeastOne =>
      'Veuillez sélectionner au moins une spécialité';

  @override
  String get loginFirst => 'Veuillez vous connecter d\'abord';

  @override
  String get editProfileSaved => 'Profil mis à jour avec succès';

  @override
  String profileSaveFailed(String error) {
    return 'Échec de l\'enregistrement du profil: $error';
  }

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get completeProfile => 'Compléter le profil';

  @override
  String get editProfileHint =>
      'Vous pouvez modifier vos informations personnelles ici';

  @override
  String get fullName => 'Nom complet';

  @override
  String get nameRequired => 'Le nom est requis';

  @override
  String get wilaya => 'Wilaya';

  @override
  String get commune => 'Commune';

  @override
  String get specialties => 'Spécialités';

  @override
  String get bioOptional => 'Bio (Optionnel)';

  @override
  String get priceNoteOptional => 'Note sur le prix (Optionnel)';

  @override
  String get priceNoteHint =>
      'ex: Le prix dépend du travail, ou commence à partir de 1000 DZD';

  @override
  String get yearsOfExperience => 'Années d\'expérience';

  @override
  String get saveEdits => 'Enregistrer les modifications';

  @override
  String get saveAndContinue => 'Enregistrer et continuer';

  @override
  String get selectWilaya => 'Sélectionner la wilaya';

  @override
  String get selectAppointmentFirst =>
      'Veuillez d\'abord sélectionner un rendez-vous';

  @override
  String get mustLoginFirst => 'Vous devez d\'abord vous connecter';

  @override
  String sendOrderFailed(String error) {
    return 'Échec de l\'envoi de la commande: $error';
  }

  @override
  String get orderSentSuccessfully => 'Commande envoyée avec succès';

  @override
  String craftsmanWillBeNotified(String name) {
    return 'L\'artisan $name sera informé de votre demande';
  }

  @override
  String get ok => 'OK';

  @override
  String get orderService => 'Demander un service';

  @override
  String get problemDescription => 'Description du problème';

  @override
  String get problemDescriptionHint =>
      'Expliquez exactement ce dont vous avez besoin...';

  @override
  String get descriptionTooShort => 'La description est trop courte';

  @override
  String get location => 'Localisation';

  @override
  String get detailedAddressOptional => 'Adresse détaillée (Optionnel)';

  @override
  String get serviceTime => 'Temps de service';

  @override
  String get immediate => 'Immédiat';

  @override
  String get laterAppointment => 'Rendez-vous ultérieur';

  @override
  String get selectDate => 'Choisir la date';

  @override
  String get selectTime => 'Choisir l\'heure';

  @override
  String get sendOrder => 'Envoyer la commande';
}
