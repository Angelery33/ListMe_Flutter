import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ca'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get commonAdd;

  /// No description provided for @commonConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get commonLoading;

  /// No description provided for @commonSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get commonSearch;

  /// No description provided for @commonAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get commonAccept;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonYes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Hecho!'**
  String get commonSuccess;

  /// No description provided for @commonRequired.
  ///
  /// In es, this message translates to:
  /// **'Obligatorio'**
  String get commonRequired;

  /// No description provided for @commonOptional.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get commonOptional;

  /// No description provided for @commonUnknown.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get commonUnknown;

  /// No description provided for @commonAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get commonAll;

  /// No description provided for @commonNone.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get commonNone;

  /// No description provided for @commonUntitled.
  ///
  /// In es, this message translates to:
  /// **'Sin título'**
  String get commonUntitled;

  /// No description provided for @commonShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get commonShare;

  /// No description provided for @commonCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get commonCopy;

  /// No description provided for @commonRefresh.
  ///
  /// In es, this message translates to:
  /// **'Refrescar'**
  String get commonRefresh;

  /// No description provided for @commonCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get commonCreate;

  /// No description provided for @commonUpdate.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get commonUpdate;

  /// No description provided for @commonPrevious.
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get commonPrevious;

  /// No description provided for @commonNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get commonNext;

  /// No description provided for @commonFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get commonFinish;

  /// No description provided for @commonSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get commonSend;

  /// No description provided for @commonPublish.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get commonPublish;

  /// No description provided for @commonSync.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar'**
  String get commonSync;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema de la aplicación'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige el modo de color'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsThemeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsThemeSystem;

  /// No description provided for @settingsAccent.
  ///
  /// In es, this message translates to:
  /// **'Elije tu tema'**
  String get settingsAccent;

  /// No description provided for @settingsTextAndReading.
  ///
  /// In es, this message translates to:
  /// **'Texto y Lectura'**
  String get settingsTextAndReading;

  /// No description provided for @settingsFontSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de fuente'**
  String get settingsFontSize;

  /// No description provided for @settingsFontSizeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ajusta el tamaño del texto global'**
  String get settingsFontSizeSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la aplicación'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsRegional.
  ///
  /// In es, this message translates to:
  /// **'Regional'**
  String get settingsRegional;

  /// No description provided for @settingsCurrency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get settingsCurrency;

  /// No description provided for @settingsCurrencySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Para listas de gastos'**
  String get settingsCurrencySubtitle;

  /// No description provided for @settingsAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get settingsAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get settingsLogout;

  /// No description provided for @settingsVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get settingsVersion;

  /// No description provided for @settingsSectionLists.
  ///
  /// In es, this message translates to:
  /// **'Listas'**
  String get settingsSectionLists;

  /// No description provided for @settingsSharedListsLayout.
  ///
  /// In es, this message translates to:
  /// **'Vista de listas ajenas'**
  String get settingsSharedListsLayout;

  /// No description provided for @settingsSharedListsLayoutSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo se muestran las listas de otros usuarios'**
  String get settingsSharedListsLayoutSubtitle;

  /// No description provided for @settingsLayoutSection.
  ///
  /// In es, this message translates to:
  /// **'Sección'**
  String get settingsLayoutSection;

  /// No description provided for @settingsLayoutTab.
  ///
  /// In es, this message translates to:
  /// **'Pestaña'**
  String get settingsLayoutTab;

  /// No description provided for @settingsLayoutBottom.
  ///
  /// In es, this message translates to:
  /// **'Al final'**
  String get settingsLayoutBottom;

  /// No description provided for @listsSharedWithMe.
  ///
  /// In es, this message translates to:
  /// **'Compartidas conmigo'**
  String get listsSharedWithMe;

  /// No description provided for @listsMyLists.
  ///
  /// In es, this message translates to:
  /// **'Mis listas'**
  String get listsMyLists;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get profileTitle;

  /// No description provided for @profileUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get profileUser;

  /// No description provided for @profileEditProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get profileEditProfile;

  /// No description provided for @profileEditUsername.
  ///
  /// In es, this message translates to:
  /// **'Editar nombre de usuario'**
  String get profileEditUsername;

  /// No description provided for @profileUsernameUpdated.
  ///
  /// In es, this message translates to:
  /// **'Usuario actualizado'**
  String get profileUsernameUpdated;

  /// No description provided for @profileEditSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cambia tu nombre de usuario'**
  String get profileEditSubtitle;

  /// No description provided for @profileChangePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get profileChangePassword;

  /// No description provided for @profileChangePasswordSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Actualiza tu contraseña'**
  String get profileChangePasswordSubtitle;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get profileCurrentPassword;

  /// No description provided for @profileNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get profileNewPassword;

  /// No description provided for @profileConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get profileConfirmPassword;

  /// No description provided for @profilePasswordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get profilePasswordTooShort;

  /// No description provided for @profilePasswordChanged.
  ///
  /// In es, this message translates to:
  /// **'Contraseña cambiada'**
  String get profilePasswordChanged;

  /// No description provided for @profileChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get profileChange;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro? Esta acción es irreversible y se eliminarán todos tus datos.'**
  String get profileDeleteConfirm;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileSectionAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionStats.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get profileSectionStats;

  /// No description provided for @profileStatsLists.
  ///
  /// In es, this message translates to:
  /// **'Listas creadas'**
  String get profileStatsLists;

  /// No description provided for @profileStatsCompleted.
  ///
  /// In es, this message translates to:
  /// **'Elementos completados'**
  String get profileStatsCompleted;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileLogoutTitle;

  /// No description provided for @fontSizeVerySmall.
  ///
  /// In es, this message translates to:
  /// **'Muy Pequeño'**
  String get fontSizeVerySmall;

  /// No description provided for @fontSizeSmall.
  ///
  /// In es, this message translates to:
  /// **'Pequeño'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get fontSizeNormal;

  /// No description provided for @fontSizeMedium.
  ///
  /// In es, this message translates to:
  /// **'Mediano'**
  String get fontSizeMedium;

  /// No description provided for @fontSizeLarge.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeVeryLarge.
  ///
  /// In es, this message translates to:
  /// **'Muy Grande'**
  String get fontSizeVeryLarge;

  /// No description provided for @accentAmethyst.
  ///
  /// In es, this message translates to:
  /// **'Amatista'**
  String get accentAmethyst;

  /// No description provided for @accentSapphire.
  ///
  /// In es, this message translates to:
  /// **'Zafiro'**
  String get accentSapphire;

  /// No description provided for @accentRuby.
  ///
  /// In es, this message translates to:
  /// **'Rubí'**
  String get accentRuby;

  /// No description provided for @accentEmerald.
  ///
  /// In es, this message translates to:
  /// **'Esmeralda'**
  String get accentEmerald;

  /// No description provided for @accentCobalt.
  ///
  /// In es, this message translates to:
  /// **'Cobalto'**
  String get accentCobalt;

  /// No description provided for @accentCyan.
  ///
  /// In es, this message translates to:
  /// **'Turquesa'**
  String get accentCyan;

  /// No description provided for @accentMagenta.
  ///
  /// In es, this message translates to:
  /// **'Magenta'**
  String get accentMagenta;

  /// No description provided for @accentTitanium.
  ///
  /// In es, this message translates to:
  /// **'Titanio'**
  String get accentTitanium;

  /// No description provided for @authLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get authRegister;

  /// No description provided for @authUsername.
  ///
  /// In es, this message translates to:
  /// **'Nombre de Usuario'**
  String get authUsername;

  /// No description provided for @authEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authConfirmPassword;

  /// No description provided for @authEnter.
  ///
  /// In es, this message translates to:
  /// **'ENTRAR'**
  String get authEnter;

  /// No description provided for @authSignUp.
  ///
  /// In es, this message translates to:
  /// **'REGISTRARSE'**
  String get authSignUp;

  /// No description provided for @authNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Regístrate aquí'**
  String get authNoAccount;

  /// No description provided for @authHasAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? Inicia sesión'**
  String get authHasAccount;

  /// No description provided for @authFillAll.
  ///
  /// In es, this message translates to:
  /// **'Por favor, rellena todos los campos'**
  String get authFillAll;

  /// No description provided for @authLoginError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get authLoginError;

  /// No description provided for @authRegisterError.
  ///
  /// In es, this message translates to:
  /// **'Error al registrarse'**
  String get authRegisterError;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authPasswordsMismatch;

  /// No description provided for @authWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get authWelcome;

  /// No description provided for @authCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCreateAccount;

  /// No description provided for @authInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Introduce un email válido'**
  String get authInvalidEmail;

  /// No description provided for @authPasswordRequirements.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres, una mayúscula y un número'**
  String get authPasswordRequirements;

  /// No description provided for @navLists.
  ///
  /// In es, this message translates to:
  /// **'Listas'**
  String get navLists;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @navSocial.
  ///
  /// In es, this message translates to:
  /// **'Social'**
  String get navSocial;

  /// No description provided for @navInfo.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get navInfo;

  /// No description provided for @listsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Listas'**
  String get listsTitle;

  /// No description provided for @listsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes listas todavía'**
  String get listsEmpty;

  /// No description provided for @listsCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear lista'**
  String get listsCreate;

  /// No description provided for @listsNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva lista'**
  String get listsNew;

  /// No description provided for @listsSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar lista…'**
  String get listsSearch;

  /// No description provided for @listsDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Lista'**
  String get listsDeleteTitle;

  /// No description provided for @listsDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar esta lista y todo su contenido?'**
  String get listsDeleteMessage;

  /// No description provided for @listsSyncing.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando...'**
  String get listsSyncing;

  /// No description provided for @listsPublished.
  ///
  /// In es, this message translates to:
  /// **'¡Lista publicada con éxito!'**
  String get listsPublished;

  /// No description provided for @listsPublishError.
  ///
  /// In es, this message translates to:
  /// **'Error al publicar la lista'**
  String get listsPublishError;

  /// No description provided for @listsShareTitle.
  ///
  /// In es, this message translates to:
  /// **'Compartir lista'**
  String get listsShareTitle;

  /// No description provided for @listsShareMessage.
  ///
  /// In es, this message translates to:
  /// **'Comparte la lista con otros usuarios.'**
  String get listsShareMessage;

  /// No description provided for @listsShareEmail.
  ///
  /// In es, this message translates to:
  /// **'Email del usuario'**
  String get listsShareEmail;

  /// No description provided for @listsShareEmailHint.
  ///
  /// In es, this message translates to:
  /// **'usuario@ejemplo.com'**
  String get listsShareEmailHint;

  /// No description provided for @listsInviteSent.
  ///
  /// In es, this message translates to:
  /// **'Invitación enviada'**
  String get listsInviteSent;

  /// No description provided for @listsUploadCloud.
  ///
  /// In es, this message translates to:
  /// **'Subir a la nube'**
  String get listsUploadCloud;

  /// No description provided for @listConfigTitleCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear lista'**
  String get listConfigTitleCreate;

  /// No description provided for @listConfigTitleEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar lista'**
  String get listConfigTitleEdit;

  /// No description provided for @listConfigName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get listConfigName;

  /// No description provided for @listConfigNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get listConfigNameRequired;

  /// No description provided for @listConfigDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get listConfigDescription;

  /// No description provided for @listConfigType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get listConfigType;

  /// No description provided for @listConfigTypeSelect.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un tipo'**
  String get listConfigTypeSelect;

  /// No description provided for @listConfigDisplay.
  ///
  /// In es, this message translates to:
  /// **'Visualización'**
  String get listConfigDisplay;

  /// No description provided for @listConfigCompact.
  ///
  /// In es, this message translates to:
  /// **'Vista compacta'**
  String get listConfigCompact;

  /// No description provided for @listConfigCompactSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cuadrícula con tarjetas más pequeñas'**
  String get listConfigCompactSubtitle;

  /// No description provided for @listConfigCompletion.
  ///
  /// In es, this message translates to:
  /// **'Completitud'**
  String get listConfigCompletion;

  /// No description provided for @listConfigCompletionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Permite marcar elementos como completados'**
  String get listConfigCompletionSubtitle;

  /// No description provided for @listConfigGradeable.
  ///
  /// In es, this message translates to:
  /// **'Puntuable'**
  String get listConfigGradeable;

  /// No description provided for @listConfigGradeableSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Permite valorar elementos'**
  String get listConfigGradeableSubtitle;

  /// No description provided for @listConfigThematic.
  ///
  /// In es, this message translates to:
  /// **'Temático'**
  String get listConfigThematic;

  /// No description provided for @listConfigThematicSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Usa géneros temáticos'**
  String get listConfigThematicSubtitle;

  /// No description provided for @listConfigWishlist.
  ///
  /// In es, this message translates to:
  /// **'Lista de deseos'**
  String get listConfigWishlist;

  /// No description provided for @listConfigWishlistSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Marca elementos como deseados'**
  String get listConfigWishlistSubtitle;

  /// No description provided for @listConfigPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get listConfigPrice;

  /// No description provided for @listConfigPriceSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra el precio de los elementos'**
  String get listConfigPriceSubtitle;

  /// No description provided for @listConfigTracksDates.
  ///
  /// In es, this message translates to:
  /// **'Registra fechas'**
  String get listConfigTracksDates;

  /// No description provided for @listConfigTracksDatesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Adquisición, inicio y finalización'**
  String get listConfigTracksDatesSubtitle;

  /// No description provided for @listConfigProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get listConfigProgress;

  /// No description provided for @listConfigProgressSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lleva un seguimiento del progreso'**
  String get listConfigProgressSubtitle;

  /// No description provided for @listConfigProgressType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de progreso'**
  String get listConfigProgressType;

  /// No description provided for @listConfigIconAndColor.
  ///
  /// In es, this message translates to:
  /// **'Icono y color'**
  String get listConfigIconAndColor;

  /// No description provided for @listConfigGenres.
  ///
  /// In es, this message translates to:
  /// **'Géneros'**
  String get listConfigGenres;

  /// No description provided for @listConfigGenresAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir género'**
  String get listConfigGenresAdd;

  /// No description provided for @genreAddTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir Género/Temática'**
  String get genreAddTitle;

  /// No description provided for @genreName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del género'**
  String get genreName;

  /// No description provided for @attributeNewType.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Tipo de Atributo'**
  String get attributeNewType;

  /// No description provided for @listConfigRatingProgress.
  ///
  /// In es, this message translates to:
  /// **'Puntuación y Progreso'**
  String get listConfigRatingProgress;

  /// No description provided for @listConfigSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar lista'**
  String get listConfigSave;

  /// No description provided for @listConfigCreated.
  ///
  /// In es, this message translates to:
  /// **'Lista creada'**
  String get listConfigCreated;

  /// No description provided for @listConfigUpdated.
  ///
  /// In es, this message translates to:
  /// **'Lista actualizada'**
  String get listConfigUpdated;

  /// No description provided for @categoryBook.
  ///
  /// In es, this message translates to:
  /// **'Libros'**
  String get categoryBook;

  /// No description provided for @categoryManga.
  ///
  /// In es, this message translates to:
  /// **'Manga'**
  String get categoryManga;

  /// No description provided for @categoryComic.
  ///
  /// In es, this message translates to:
  /// **'Cómic'**
  String get categoryComic;

  /// No description provided for @categoryAnime.
  ///
  /// In es, this message translates to:
  /// **'Anime'**
  String get categoryAnime;

  /// No description provided for @categoryMovie.
  ///
  /// In es, this message translates to:
  /// **'Películas'**
  String get categoryMovie;

  /// No description provided for @categorySeries.
  ///
  /// In es, this message translates to:
  /// **'Series / TV'**
  String get categorySeries;

  /// No description provided for @categoryFigures.
  ///
  /// In es, this message translates to:
  /// **'Figuras'**
  String get categoryFigures;

  /// No description provided for @categoryFunko.
  ///
  /// In es, this message translates to:
  /// **'Funko Pop'**
  String get categoryFunko;

  /// No description provided for @categoryGeneric.
  ///
  /// In es, this message translates to:
  /// **'Genérico'**
  String get categoryGeneric;

  /// No description provided for @commonItem.
  ///
  /// In es, this message translates to:
  /// **'elemento'**
  String get commonItem;

  /// No description provided for @commonItems.
  ///
  /// In es, this message translates to:
  /// **'elementos'**
  String get commonItems;

  /// No description provided for @itemNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo elemento'**
  String get itemNew;

  /// No description provided for @itemEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar elemento'**
  String get itemEdit;

  /// No description provided for @itemName.
  ///
  /// In es, this message translates to:
  /// **'Nombre / Título'**
  String get itemName;

  /// No description provided for @itemNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get itemNameRequired;

  /// No description provided for @itemDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get itemDescription;

  /// No description provided for @itemSectionMain.
  ///
  /// In es, this message translates to:
  /// **'Información Principal'**
  String get itemSectionMain;

  /// No description provided for @itemSectionStatusProgress.
  ///
  /// In es, this message translates to:
  /// **'Estado y Progreso'**
  String get itemSectionStatusProgress;

  /// No description provided for @itemSectionProperties.
  ///
  /// In es, this message translates to:
  /// **'Propiedades'**
  String get itemSectionProperties;

  /// No description provided for @itemSectionDates.
  ///
  /// In es, this message translates to:
  /// **'Fechas'**
  String get itemSectionDates;

  /// No description provided for @itemSectionAttributes.
  ///
  /// In es, this message translates to:
  /// **'Atributos Personalizados'**
  String get itemSectionAttributes;

  /// No description provided for @itemSectionGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería de Imágenes'**
  String get itemSectionGallery;

  /// No description provided for @itemItemNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de elemento'**
  String get itemItemNumber;

  /// No description provided for @itemProductType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de Producto'**
  String get itemProductType;

  /// No description provided for @itemEdition.
  ///
  /// In es, this message translates to:
  /// **'Edición'**
  String get itemEdition;

  /// No description provided for @itemPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get itemPrice;

  /// No description provided for @itemGenre.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get itemGenre;

  /// No description provided for @itemScore.
  ///
  /// In es, this message translates to:
  /// **'Puntuación'**
  String get itemScore;

  /// No description provided for @itemImport.
  ///
  /// In es, this message translates to:
  /// **'Importar desde API'**
  String get itemImport;

  /// No description provided for @itemImportAdded.
  ///
  /// In es, this message translates to:
  /// **'Imagen importada añadida'**
  String get itemImportAdded;

  /// No description provided for @itemDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar elemento'**
  String get itemDeleteTitle;

  /// No description provided for @itemDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar este elemento?'**
  String get itemDeleteMessage;

  /// No description provided for @itemSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar'**
  String get itemSaveError;

  /// No description provided for @itemCreateError.
  ///
  /// In es, this message translates to:
  /// **'Error creando el artículo'**
  String get itemCreateError;

  /// No description provided for @itemUpdateError.
  ///
  /// In es, this message translates to:
  /// **'Error actualizando el artículo'**
  String get itemUpdateError;

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get statusPending;

  /// No description provided for @statusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En Progreso'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get statusCompleted;

  /// No description provided for @statusDropped.
  ///
  /// In es, this message translates to:
  /// **'Abandonado'**
  String get statusDropped;

  /// No description provided for @statusPaused.
  ///
  /// In es, this message translates to:
  /// **'En Pausa'**
  String get statusPaused;

  /// No description provided for @statusStatusCurrent.
  ///
  /// In es, this message translates to:
  /// **'Estado actual'**
  String get statusStatusCurrent;

  /// No description provided for @statusEnjoying.
  ///
  /// In es, this message translates to:
  /// **'Disfrutando ahora'**
  String get statusEnjoying;

  /// No description provided for @statusEnjoyingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mostrar en la sección destacada'**
  String get statusEnjoyingSubtitle;

  /// No description provided for @statusEnjoyingDisabled.
  ///
  /// In es, this message translates to:
  /// **'Solo disponible en \'En Progreso\''**
  String get statusEnjoyingDisabled;

  /// No description provided for @progressSeason.
  ///
  /// In es, this message translates to:
  /// **'Temporada'**
  String get progressSeason;

  /// No description provided for @progressEpisode.
  ///
  /// In es, this message translates to:
  /// **'Episodio'**
  String get progressEpisode;

  /// No description provided for @progressChapter.
  ///
  /// In es, this message translates to:
  /// **'Capítulo'**
  String get progressChapter;

  /// No description provided for @progressVolume.
  ///
  /// In es, this message translates to:
  /// **'Volumen'**
  String get progressVolume;

  /// No description provided for @progressPage.
  ///
  /// In es, this message translates to:
  /// **'Página'**
  String get progressPage;

  /// No description provided for @progressQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get progressQuantity;

  /// No description provided for @progressProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progressProgress;

  /// No description provided for @progressActual.
  ///
  /// In es, this message translates to:
  /// **'actual'**
  String get progressActual;

  /// No description provided for @progressTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get progressTotal;

  /// No description provided for @datesAcquisition.
  ///
  /// In es, this message translates to:
  /// **'Fecha de adquisición'**
  String get datesAcquisition;

  /// No description provided for @datesStart.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get datesStart;

  /// No description provided for @datesCompletion.
  ///
  /// In es, this message translates to:
  /// **'Fecha de finalización'**
  String get datesCompletion;

  /// No description provided for @datesNotSet.
  ///
  /// In es, this message translates to:
  /// **'No establecida'**
  String get datesNotSet;

  /// No description provided for @attributesEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay atributos añadidos.'**
  String get attributesEmpty;

  /// No description provided for @attributesAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir atributo'**
  String get attributesAdd;

  /// No description provided for @attributesCreateType.
  ///
  /// In es, this message translates to:
  /// **'Crear nuevo tipo'**
  String get attributesCreateType;

  /// No description provided for @attributesType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get attributesType;

  /// No description provided for @attributesValue.
  ///
  /// In es, this message translates to:
  /// **'Valor'**
  String get attributesValue;

  /// No description provided for @attributesNewTypeName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del tipo'**
  String get attributesNewTypeName;

  /// No description provided for @collectionTitle.
  ///
  /// In es, this message translates to:
  /// **'COLECCIÓN'**
  String get collectionTitle;

  /// No description provided for @collectionEmpty.
  ///
  /// In es, this message translates to:
  /// **'Esta colección está vacía.'**
  String get collectionEmpty;

  /// No description provided for @collectionViewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get collectionViewAll;

  /// No description provided for @collectionAddItem.
  ///
  /// In es, this message translates to:
  /// **'Añadir elemento'**
  String get collectionAddItem;

  /// No description provided for @collectionGenerate.
  ///
  /// In es, this message translates to:
  /// **'Generar tomos automáticamente'**
  String get collectionGenerate;

  /// No description provided for @collectionGenerateTitle.
  ///
  /// In es, this message translates to:
  /// **'Generar tomos'**
  String get collectionGenerateTitle;

  /// No description provided for @collectionGenerateConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Generar tomos automáticamente? Se crearán items hijos numerados.'**
  String get collectionGenerateConfirm;

  /// No description provided for @collectionGenerateResult.
  ///
  /// In es, this message translates to:
  /// **'Se crearon {n} tomos'**
  String collectionGenerateResult(int n);

  /// No description provided for @descriptionTitle.
  ///
  /// In es, this message translates to:
  /// **'DESCRIPCIÓN'**
  String get descriptionTitle;

  /// No description provided for @descriptionEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción. Pulsa el botón para añadir una.'**
  String get descriptionEmpty;

  /// No description provided for @descriptionEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar descripción'**
  String get descriptionEdit;

  /// No description provided for @descriptionAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir descripción'**
  String get descriptionAdd;

  /// No description provided for @descriptionPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Escribe una descripción…'**
  String get descriptionPlaceholder;

  /// No description provided for @descriptionReadMore.
  ///
  /// In es, this message translates to:
  /// **'Leer más'**
  String get descriptionReadMore;

  /// No description provided for @descriptionReadLess.
  ///
  /// In es, this message translates to:
  /// **'Leer menos'**
  String get descriptionReadLess;

  /// No description provided for @imageGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get imageGallery;

  /// No description provided for @imageCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get imageCamera;

  /// No description provided for @imageCameraError.
  ///
  /// In es, this message translates to:
  /// **'Error al abrir cámara. Asegúrate de tener permisos.'**
  String get imageCameraError;

  /// No description provided for @imageUploadError.
  ///
  /// In es, this message translates to:
  /// **'Error al subir imagen'**
  String get imageUploadError;

  /// No description provided for @imageFavorite.
  ///
  /// In es, this message translates to:
  /// **'Favorita'**
  String get imageFavorite;

  /// No description provided for @searchImportTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar e importar'**
  String get searchImportTitle;

  /// No description provided for @searchImportPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Buscar…'**
  String get searchImportPlaceholder;

  /// No description provided for @searchImportAuthorFilter.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por autor (opcional)'**
  String get searchImportAuthorFilter;

  /// No description provided for @searchImportNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron resultados'**
  String get searchImportNoResults;

  /// No description provided for @searchImportError.
  ///
  /// In es, this message translates to:
  /// **'Error al buscar'**
  String get searchImportError;

  /// No description provided for @infoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get infoTitle;

  /// No description provided for @socialTitle.
  ///
  /// In es, this message translates to:
  /// **'Social'**
  String get socialTitle;

  /// No description provided for @sortTitle.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get sortTitle;

  /// No description provided for @filterTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get filterTitle;

  /// No description provided for @sortName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get sortName;

  /// No description provided for @sortDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get sortDate;

  /// No description provided for @sortScore.
  ///
  /// In es, this message translates to:
  /// **'Puntuación'**
  String get sortScore;

  /// No description provided for @sortAsc.
  ///
  /// In es, this message translates to:
  /// **'Ascendente'**
  String get sortAsc;

  /// No description provided for @sortDesc.
  ///
  /// In es, this message translates to:
  /// **'Descendente'**
  String get sortDesc;

  /// No description provided for @homeListsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Listas'**
  String get homeListsTitle;

  /// No description provided for @homeListsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tus tareas y notas'**
  String get homeListsSubtitle;

  /// No description provided for @homeProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Configura tu cuenta de usuario'**
  String get homeProfileSubtitle;

  /// No description provided for @homeSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes App'**
  String get homeSettingsTitle;

  /// No description provided for @homeSettingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Temas, fuentes y notificaciones'**
  String get homeSettingsSubtitle;

  /// No description provided for @homeInfoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Información de la aplicación'**
  String get homeInfoSubtitle;

  /// No description provided for @imageCrop.
  ///
  /// In es, this message translates to:
  /// **'Recortar'**
  String get imageCrop;

  /// No description provided for @imageMarkFavorite.
  ///
  /// In es, this message translates to:
  /// **'Marcar como favorita'**
  String get imageMarkFavorite;

  /// No description provided for @imageViewOptions.
  ///
  /// In es, this message translates to:
  /// **'Ver opciones'**
  String get imageViewOptions;

  /// No description provided for @entryImportFromApi.
  ///
  /// In es, this message translates to:
  /// **'Importar desde API'**
  String get entryImportFromApi;

  /// No description provided for @entryItemName.
  ///
  /// In es, this message translates to:
  /// **'Nombre / Título'**
  String get entryItemName;

  /// No description provided for @entryDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get entryDescription;

  /// No description provided for @listConfigNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get listConfigNameLabel;

  /// No description provided for @listConfigDescriptionOptional.
  ///
  /// In es, this message translates to:
  /// **'Descripción (Opcional)'**
  String get listConfigDescriptionOptional;

  /// No description provided for @listConfigSelectIcon.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un icono:'**
  String get listConfigSelectIcon;

  /// No description provided for @listConfigSelectColor.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un color:'**
  String get listConfigSelectColor;

  /// No description provided for @listConfigGenresEdit.
  ///
  /// In es, this message translates to:
  /// **'Personalizar Géneros'**
  String get listConfigGenresEdit;

  /// No description provided for @ratingScale5.
  ///
  /// In es, this message translates to:
  /// **'Sobre 5 Estrellas (1-5)'**
  String get ratingScale5;

  /// No description provided for @ratingScale10.
  ///
  /// In es, this message translates to:
  /// **'Sobre 10 (Estándar)'**
  String get ratingScale10;

  /// No description provided for @ratingScale100.
  ///
  /// In es, this message translates to:
  /// **'Sobre 100 (Porcentaje)'**
  String get ratingScale100;

  /// No description provided for @progressTypeManual.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get progressTypeManual;

  /// No description provided for @progressTypeBook.
  ///
  /// In es, this message translates to:
  /// **'Libro'**
  String get progressTypeBook;

  /// No description provided for @progressTypeSeries.
  ///
  /// In es, this message translates to:
  /// **'Serie'**
  String get progressTypeSeries;

  /// No description provided for @progressTypeAnime.
  ///
  /// In es, this message translates to:
  /// **'Anime'**
  String get progressTypeAnime;

  /// No description provided for @progressTypeManga.
  ///
  /// In es, this message translates to:
  /// **'Manga'**
  String get progressTypeManga;

  /// No description provided for @categoryGenericMixed.
  ///
  /// In es, this message translates to:
  /// **'General / Otros'**
  String get categoryGenericMixed;

  /// No description provided for @searchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Buscar...'**
  String get searchPlaceholder;

  /// No description provided for @sortDateNewest.
  ///
  /// In es, this message translates to:
  /// **'Fecha (Más reciente)'**
  String get sortDateNewest;

  /// No description provided for @sortDateOldest.
  ///
  /// In es, this message translates to:
  /// **'Fecha (Más antiguo)'**
  String get sortDateOldest;

  /// No description provided for @sortNameAZ.
  ///
  /// In es, this message translates to:
  /// **'Nombre (A-Z)'**
  String get sortNameAZ;

  /// No description provided for @sortNameZA.
  ///
  /// In es, this message translates to:
  /// **'Nombre (Z-A)'**
  String get sortNameZA;

  /// No description provided for @sortScoreHighLow.
  ///
  /// In es, this message translates to:
  /// **'Puntuación (Alta-Baja)'**
  String get sortScoreHighLow;

  /// No description provided for @sortScoreLowHigh.
  ///
  /// In es, this message translates to:
  /// **'Puntuación (Baja-Alta)'**
  String get sortScoreLowHigh;

  /// No description provided for @infoWishlist.
  ///
  /// In es, this message translates to:
  /// **'En lista de deseos'**
  String get infoWishlist;

  /// No description provided for @infoAcquired.
  ///
  /// In es, this message translates to:
  /// **'Adquirido'**
  String get infoAcquired;

  /// No description provided for @infoPriceEstimated.
  ///
  /// In es, this message translates to:
  /// **'PRECIO ESTIMADO'**
  String get infoPriceEstimated;

  /// No description provided for @infoPriceCost.
  ///
  /// In es, this message translates to:
  /// **'COSTE'**
  String get infoPriceCost;

  /// No description provided for @expandCollapse.
  ///
  /// In es, this message translates to:
  /// **'Contraer'**
  String get expandCollapse;

  /// No description provided for @expandExpand.
  ///
  /// In es, this message translates to:
  /// **'Expandir'**
  String get expandExpand;

  /// No description provided for @listsEmptyHeading.
  ///
  /// In es, this message translates to:
  /// **'No tienes listas'**
  String get listsEmptyHeading;

  /// No description provided for @listsEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera lista pulsando el botón +'**
  String get listsEmptyMessage;

  /// No description provided for @listConfigRatingTitle.
  ///
  /// In es, this message translates to:
  /// **'Puntuación Personal'**
  String get listConfigRatingTitle;

  /// No description provided for @datesAcquisitionShort.
  ///
  /// In es, this message translates to:
  /// **'Fecha Adquisición'**
  String get datesAcquisitionShort;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get errorGeneric;

  /// No description provided for @errorPrefix.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @listEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Esta lista está vacía'**
  String get listEmptyTitle;

  /// No description provided for @listEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Pulsa \'+\' para añadir tu primer elemento'**
  String get listEmptyMessage;

  /// No description provided for @listEmptySearch.
  ///
  /// In es, this message translates to:
  /// **'No hay resultados para tu búsqueda'**
  String get listEmptySearch;

  /// No description provided for @groupPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get groupPending;

  /// No description provided for @groupInProgress.
  ///
  /// In es, this message translates to:
  /// **'En Progreso'**
  String get groupInProgress;

  /// No description provided for @groupPaused.
  ///
  /// In es, this message translates to:
  /// **'En Pausa'**
  String get groupPaused;

  /// No description provided for @groupDropped.
  ///
  /// In es, this message translates to:
  /// **'Abandonados'**
  String get groupDropped;

  /// No description provided for @groupCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completados'**
  String get groupCompleted;

  /// No description provided for @groupAcquired.
  ///
  /// In es, this message translates to:
  /// **'Adquiridos'**
  String get groupAcquired;

  /// No description provided for @groupWishlist.
  ///
  /// In es, this message translates to:
  /// **'Lista de Deseos'**
  String get groupWishlist;

  /// No description provided for @groupOthers.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get groupOthers;

  /// No description provided for @configStatusOrderTitle.
  ///
  /// In es, this message translates to:
  /// **'Secciones de estado'**
  String get configStatusOrderTitle;

  /// No description provided for @configStatusOrderDesc.
  ///
  /// In es, this message translates to:
  /// **'Activa y reordena las secciones visibles en la lista'**
  String get configStatusOrderDesc;

  /// No description provided for @socialFriendsTab.
  ///
  /// In es, this message translates to:
  /// **'Amigos'**
  String get socialFriendsTab;

  /// No description provided for @socialRequestsTab.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get socialRequestsTab;

  /// No description provided for @socialInvitationsTab.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones'**
  String get socialInvitationsTab;

  /// No description provided for @socialAddFriend.
  ///
  /// In es, this message translates to:
  /// **'Añadir amigo'**
  String get socialAddFriend;

  /// No description provided for @socialAddShort.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get socialAddShort;

  /// No description provided for @socialNoFriendsTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes amigos'**
  String get socialNoFriendsTitle;

  /// No description provided for @socialNoPendingRequests.
  ///
  /// In es, this message translates to:
  /// **'Sin solicitudes pendientes'**
  String get socialNoPendingRequests;

  /// No description provided for @socialNoPendingInvitations.
  ///
  /// In es, this message translates to:
  /// **'Sin invitaciones pendientes'**
  String get socialNoPendingInvitations;

  /// No description provided for @socialWantsToBeYourFriend.
  ///
  /// In es, this message translates to:
  /// **'Quiere ser tu amigo'**
  String get socialWantsToBeYourFriend;

  /// No description provided for @socialReject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get socialReject;

  /// No description provided for @socialInvitesYouToCollaborate.
  ///
  /// In es, this message translates to:
  /// **'Te invita a colaborar'**
  String get socialInvitesYouToCollaborate;

  /// No description provided for @socialRoleReader.
  ///
  /// In es, this message translates to:
  /// **'Lector'**
  String get socialRoleReader;

  /// No description provided for @socialRoleEditor.
  ///
  /// In es, this message translates to:
  /// **'Editor'**
  String get socialRoleEditor;

  /// No description provided for @socialInvitationAccepted.
  ///
  /// In es, this message translates to:
  /// **'Invitación aceptada'**
  String get socialInvitationAccepted;

  /// No description provided for @socialUsernameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario'**
  String get socialUsernameLabel;

  /// No description provided for @socialUsernameHint.
  ///
  /// In es, this message translates to:
  /// **'Username exacto'**
  String get socialUsernameHint;

  /// No description provided for @socialRequestSentTo.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada a {username}'**
  String socialRequestSentTo(String username);

  /// No description provided for @socialRequestError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar'**
  String get socialRequestError;

  /// No description provided for @socialRemoveFriendTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar amigo'**
  String get socialRemoveFriendTitle;

  /// No description provided for @socialRemoveFriendConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar a {username} de tu lista de amigos?'**
  String socialRemoveFriendConfirm(String username);

  /// No description provided for @shareInviteFriendTitle.
  ///
  /// In es, this message translates to:
  /// **'Invitar amigo'**
  String get shareInviteFriendTitle;

  /// No description provided for @shareNoFriendsHint.
  ///
  /// In es, this message translates to:
  /// **'Añade amigos desde la pestaña Social para invitarlos.'**
  String get shareNoFriendsHint;

  /// No description provided for @shareAllFriendsCollaborating.
  ///
  /// In es, this message translates to:
  /// **'Todos tus amigos ya colaboran en esta lista.'**
  String get shareAllFriendsCollaborating;

  /// No description provided for @shareSelectFriend.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un amigo'**
  String get shareSelectFriend;

  /// No description provided for @shareReadOnlyLabel.
  ///
  /// In es, this message translates to:
  /// **'Solo lectura'**
  String get shareReadOnlyLabel;

  /// No description provided for @shareInviteAction.
  ///
  /// In es, this message translates to:
  /// **'Invitar a {username}'**
  String shareInviteAction(String username);

  /// No description provided for @shareSelectOne.
  ///
  /// In es, this message translates to:
  /// **'Selecciona uno'**
  String get shareSelectOne;

  /// No description provided for @shareInviteSentTo.
  ///
  /// In es, this message translates to:
  /// **'Invitación enviada a {username}'**
  String shareInviteSentTo(String username);

  /// No description provided for @shareInviteError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar invitación'**
  String get shareInviteError;

  /// No description provided for @collaborationTitle.
  ///
  /// In es, this message translates to:
  /// **'COLABORACIÓN'**
  String get collaborationTitle;

  /// No description provided for @collaborationCurrentCollaborators.
  ///
  /// In es, this message translates to:
  /// **'Colaboradores actuales'**
  String get collaborationCurrentCollaborators;

  /// No description provided for @collaborationInviteFriend.
  ///
  /// In es, this message translates to:
  /// **'Invitar amigo'**
  String get collaborationInviteFriend;

  /// No description provided for @collaborationRemoveTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar colaborador'**
  String get collaborationRemoveTooltip;

  /// No description provided for @collaborationInfoNote.
  ///
  /// In es, this message translates to:
  /// **'El usuario recibirá una notificación para aceptar la colaboración.'**
  String get collaborationInfoNote;

  /// No description provided for @collaborationReadOnlyPermission.
  ///
  /// In es, this message translates to:
  /// **'Permiso de solo lectura'**
  String get collaborationReadOnlyPermission;

  /// No description provided for @collaborationNoFriendsHint.
  ///
  /// In es, this message translates to:
  /// **'Añade amigos desde la pestaña Social para poder invitarlos.'**
  String get collaborationNoFriendsHint;

  /// No description provided for @collaborationAllAdded.
  ///
  /// In es, this message translates to:
  /// **'Todos tus amigos ya colaboran en esta lista.'**
  String get collaborationAllAdded;

  /// No description provided for @collaborationRemoveSuccess.
  ///
  /// In es, this message translates to:
  /// **'\"{username}\" eliminado de la biblioteca'**
  String collaborationRemoveSuccess(String username);

  /// No description provided for @collaborationRemoveError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar colaborador'**
  String get collaborationRemoveError;

  /// No description provided for @collaborationRemoveTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar colaborador'**
  String get collaborationRemoveTitle;

  /// No description provided for @collaborationRemoveConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar a \"{username}\" de esta biblioteca?'**
  String collaborationRemoveConfirm(String username);

  /// No description provided for @collaborationRoleEditor.
  ///
  /// In es, this message translates to:
  /// **'Editor'**
  String get collaborationRoleEditor;

  /// No description provided for @collaborationRoleReadOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo lectura'**
  String get collaborationRoleReadOnly;

  /// No description provided for @collaborationSendErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar'**
  String get collaborationSendErrorGeneric;

  /// No description provided for @listLeaveTitle.
  ///
  /// In es, this message translates to:
  /// **'Abandonar lista'**
  String get listLeaveTitle;

  /// No description provided for @listLeaveConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres dejar de seguir \"{name}\"?\n\nDejarás de tener acceso a esta biblioteca.'**
  String listLeaveConfirm(String name);

  /// No description provided for @listLeaveAction.
  ///
  /// In es, this message translates to:
  /// **'ABANDONAR'**
  String get listLeaveAction;

  /// No description provided for @profileTotalItems.
  ///
  /// In es, this message translates to:
  /// **'Elementos totales'**
  String get profileTotalItems;

  /// No description provided for @profilePhotoSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar foto de perfil'**
  String get profilePhotoSaveError;

  /// No description provided for @profilePhotoUploadError.
  ///
  /// In es, this message translates to:
  /// **'Error al subir la imagen'**
  String get profilePhotoUploadError;

  /// No description provided for @profilePickerGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get profilePickerGallery;

  /// No description provided for @profilePickerCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get profilePickerCamera;

  /// No description provided for @genresSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Personalizar Géneros / Categorías'**
  String get genresSectionTitle;

  /// No description provided for @genresEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin géneros definidos.'**
  String get genresEmpty;

  /// No description provided for @progressSetTitle.
  ///
  /// In es, this message translates to:
  /// **'Establecer {label}'**
  String progressSetTitle(String label);

  /// No description provided for @socialFeedComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente\nfeed de amigos'**
  String get socialFeedComingSoon;

  /// No description provided for @listOwnerYou.
  ///
  /// In es, this message translates to:
  /// **'Tuya'**
  String get listOwnerYou;

  /// No description provided for @listOwnerCollaborator.
  ///
  /// In es, this message translates to:
  /// **'Colaborador'**
  String get listOwnerCollaborator;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ca',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
