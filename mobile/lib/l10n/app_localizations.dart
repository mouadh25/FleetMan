import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ar', 'DZ'),
    Locale('fr'),
    Locale('fr', 'DZ')
  ];

  /// The title of the application
  ///
  /// In fr, this message translates to:
  /// **'FleetMan'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur FleetMan'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginButton;

  /// No description provided for @signInButton.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get signInButton;

  /// No description provided for @createAccountLink.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccountLink;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get loginError;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullNameLabel;

  /// No description provided for @companyNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'entreprise'**
  String get companyNameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPasswordLabel;

  /// No description provided for @signUpButton.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUpButton;

  /// No description provided for @passwordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordMismatch;

  /// No description provided for @signOutButton.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get signOutButton;

  /// No description provided for @vehicleDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails du véhicule'**
  String get vehicleDetails;

  /// No description provided for @plateNumber.
  ///
  /// In fr, this message translates to:
  /// **'Matricule'**
  String get plateNumber;

  /// No description provided for @make.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get make;

  /// No description provided for @model.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get model;

  /// No description provided for @odometer.
  ///
  /// In fr, this message translates to:
  /// **'Kilométrage'**
  String get odometer;

  /// No description provided for @year.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get year;

  /// No description provided for @statusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get statusActive;

  /// No description provided for @statusInMaintenance.
  ///
  /// In fr, this message translates to:
  /// **'En maintenance'**
  String get statusInMaintenance;

  /// No description provided for @statusOutOfService.
  ///
  /// In fr, this message translates to:
  /// **'Hors service'**
  String get statusOutOfService;

  /// No description provided for @scanQrButton.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le QR Code'**
  String get scanQrButton;

  /// No description provided for @fuelType.
  ///
  /// In fr, this message translates to:
  /// **'Type de carburant'**
  String get fuelType;

  /// No description provided for @vin.
  ///
  /// In fr, this message translates to:
  /// **'Numéro VIN'**
  String get vin;

  /// No description provided for @legalDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Documents légaux'**
  String get legalDocuments;

  /// No description provided for @insuranceExpiry.
  ///
  /// In fr, this message translates to:
  /// **'Assurance'**
  String get insuranceExpiry;

  /// No description provided for @technicalInspection.
  ///
  /// In fr, this message translates to:
  /// **'Contrôle technique'**
  String get technicalInspection;

  /// No description provided for @circulationCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte grise'**
  String get circulationCard;

  /// No description provided for @expired.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get expired;

  /// No description provided for @noDriver.
  ///
  /// In fr, this message translates to:
  /// **'Non assigné'**
  String get noDriver;

  /// No description provided for @fuelDiesel.
  ///
  /// In fr, this message translates to:
  /// **'Gasoil'**
  String get fuelDiesel;

  /// No description provided for @fuelEssence.
  ///
  /// In fr, this message translates to:
  /// **'Essence (Sans Plomb)'**
  String get fuelEssence;

  /// No description provided for @fuelSirghaz.
  ///
  /// In fr, this message translates to:
  /// **'Sirghaz (GPL-C)'**
  String get fuelSirghaz;

  /// No description provided for @startInspection.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer l\'inspection'**
  String get startInspection;

  /// No description provided for @daysShort.
  ///
  /// In fr, this message translates to:
  /// **'j'**
  String get daysShort;

  /// No description provided for @scanQRCode.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le QR Code'**
  String get scanQRCode;

  /// No description provided for @toggleFlash.
  ///
  /// In fr, this message translates to:
  /// **'Activer le flash'**
  String get toggleFlash;

  /// No description provided for @vehicleNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule non trouvé'**
  String get vehicleNotFound;

  /// No description provided for @orEnterPlateManually.
  ///
  /// In fr, this message translates to:
  /// **'Ou saisir le matricule manuellement'**
  String get orEnterPlateManually;

  /// No description provided for @plateNumberHint.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de matricule'**
  String get plateNumberHint;

  /// No description provided for @lookingUpVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Recherche du véhicule...'**
  String get lookingUpVehicle;

  /// No description provided for @scanQRInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Pointez la caméra vers le code QR du véhicule'**
  String get scanQRInstructions;

  /// No description provided for @tryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get tryAgain;

  /// No description provided for @auditForm.
  ///
  /// In fr, this message translates to:
  /// **'Formulaire d\'Audit'**
  String get auditForm;

  /// No description provided for @auditChecklist.
  ///
  /// In fr, this message translates to:
  /// **'Liste de contrôle'**
  String get auditChecklist;

  /// No description provided for @tires.
  ///
  /// In fr, this message translates to:
  /// **'Pneus'**
  String get tires;

  /// No description provided for @lights.
  ///
  /// In fr, this message translates to:
  /// **'Feux'**
  String get lights;

  /// No description provided for @fluids.
  ///
  /// In fr, this message translates to:
  /// **'Fluides'**
  String get fluids;

  /// No description provided for @mirrors.
  ///
  /// In fr, this message translates to:
  /// **'Rétroviseurs'**
  String get mirrors;

  /// No description provided for @odometerReading.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du compteur'**
  String get odometerReading;

  /// No description provided for @pass.
  ///
  /// In fr, this message translates to:
  /// **'Réussi'**
  String get pass;

  /// No description provided for @fail.
  ///
  /// In fr, this message translates to:
  /// **'Échoué'**
  String get fail;

  /// No description provided for @damageNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes de dommages'**
  String get damageNotes;

  /// No description provided for @damageNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez les dommages découverts...'**
  String get damageNotesHint;

  /// No description provided for @addPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get addPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @submitAudit.
  ///
  /// In fr, this message translates to:
  /// **'Soumettre l\'audit'**
  String get submitAudit;

  /// No description provided for @auditComplete.
  ///
  /// In fr, this message translates to:
  /// **'Audit complet'**
  String get auditComplete;

  /// No description provided for @auditPassed.
  ///
  /// In fr, this message translates to:
  /// **'Audit passé avec succès'**
  String get auditPassed;

  /// No description provided for @auditFailed.
  ///
  /// In fr, this message translates to:
  /// **'Audit échoué - Problème créé'**
  String get auditFailed;

  /// No description provided for @issueCreated.
  ///
  /// In fr, this message translates to:
  /// **'Problème créé: '**
  String get issueCreated;

  /// No description provided for @confirmSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la soumission'**
  String get confirmSubmit;

  /// No description provided for @allItemsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Tous les éléments doivent être complétés'**
  String get allItemsRequired;

  /// No description provided for @photoRequired.
  ///
  /// In fr, this message translates to:
  /// **'Photo requise avant soumission'**
  String get photoRequired;

  /// No description provided for @inspectionDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails de l\'inspection'**
  String get inspectionDetails;

  /// No description provided for @km.
  ///
  /// In fr, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @offlineQueued.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion - sauvegardé localement pour synchronisation'**
  String get offlineQueued;

  /// No description provided for @savedOffline.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardé hors ligne'**
  String get savedOffline;

  /// No description provided for @syncing.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation...'**
  String get syncing;

  /// No description provided for @shiftActive.
  ///
  /// In fr, this message translates to:
  /// **'Poste actif'**
  String get shiftActive;

  /// No description provided for @shiftInactive.
  ///
  /// In fr, this message translates to:
  /// **'Poste inactif'**
  String get shiftInactive;

  /// No description provided for @startShift.
  ///
  /// In fr, this message translates to:
  /// **'Commencer le poste'**
  String get startShift;

  /// No description provided for @endShift.
  ///
  /// In fr, this message translates to:
  /// **'Terminer le poste'**
  String get endShift;

  /// No description provided for @assignedVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule assigné'**
  String get assignedVehicle;

  /// No description provided for @noVehicleAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Aucun véhicule assigné'**
  String get noVehicleAssigned;

  /// No description provided for @myTasks.
  ///
  /// In fr, this message translates to:
  /// **'Mes tâches'**
  String get myTasks;

  /// No description provided for @pendingRepairs.
  ///
  /// In fr, this message translates to:
  /// **'Réparations en attente'**
  String get pendingRepairs;

  /// No description provided for @completedToday.
  ///
  /// In fr, this message translates to:
  /// **'Terminées aujourd\'hui'**
  String get completedToday;

  /// No description provided for @viewAllVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Voir tous les véhicules'**
  String get viewAllVehicles;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @fleetOverview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de la flotte'**
  String get fleetOverview;

  /// No description provided for @totalVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Total véhicules'**
  String get totalVehicles;

  /// No description provided for @activeVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Véhicules actifs'**
  String get activeVehicles;

  /// No description provided for @maintenanceVehicles.
  ///
  /// In fr, this message translates to:
  /// **'En maintenance'**
  String get maintenanceVehicles;

  /// No description provided for @issuesReported.
  ///
  /// In fr, this message translates to:
  /// **'Problèmes signalés'**
  String get issuesReported;

  /// No description provided for @recentActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité récente'**
  String get recentActivity;

  /// No description provided for @quickActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get quickActions;

  /// No description provided for @vehicleAllocation.
  ///
  /// In fr, this message translates to:
  /// **'Allocation de véhicules'**
  String get vehicleAllocation;

  /// No description provided for @driverAssignment.
  ///
  /// In fr, this message translates to:
  /// **'Affectation des chauffeurs'**
  String get driverAssignment;

  /// No description provided for @maintenanceSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier maintenance'**
  String get maintenanceSchedule;

  /// No description provided for @workOrders.
  ///
  /// In fr, this message translates to:
  /// **'Ordres de travail'**
  String get workOrders;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'ar':
      {
        switch (locale.countryCode) {
          case 'DZ':
            return AppLocalizationsArDz();
        }
        break;
      }
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'DZ':
            return AppLocalizationsFrDz();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
