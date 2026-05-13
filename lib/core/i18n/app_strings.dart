import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/settings/settings_provider.dart';

/// Sistema de internacionalización ligero basado en mapas por idioma.
/// Uso: `context.tr('settings.title')` o `AppStrings.t(context, 'key')`.
class AppStrings {
  static const String defaultLocale = 'es';

  static const List<Locale> supportedLocales = [
    Locale('es'),
    Locale('ca'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('de'),
    Locale('pt'),
  ];

  /// Etiquetas legibles para mostrar al usuario.
  static const Map<String, String> languageLabels = {
    'es': 'Español',
    'ca': 'Català / Valencià',
    'en': 'English',
    'fr': 'Français',
    'it': 'Italiano',
    'de': 'Deutsch',
    'pt': 'Português',
  };

  static const Map<String, Map<String, String>> _strings = {
    // ---- Español ----
    'es': {
      'common.save': 'Guardar',
      'common.cancel': 'Cancelar',
      'common.delete': 'Eliminar',
      'common.edit': 'Editar',
      'common.add': 'Añadir',
      'common.confirm': 'Confirmar',
      'common.back': 'Atrás',
      'common.loading': 'Cargando…',
      'common.search': 'Buscar',

      'settings.title': 'Ajustes',
      'settings.appearance': 'Apariencia',
      'settings.theme': 'Tema de la aplicación',
      'settings.theme.subtitle': 'Elige el modo de color',
      'settings.theme.light': 'Claro',
      'settings.theme.dark': 'Oscuro',
      'settings.theme.system': 'Sistema',
      'settings.accent': 'Elije tu tema',
      'settings.textAndReading': 'Texto y Lectura',
      'settings.fontSize': 'Tamaño de fuente',
      'settings.fontSize.subtitle': 'Ajusta el tamaño del texto global',
      'settings.language': 'Idioma',
      'settings.language.subtitle': 'Idioma de la aplicación',
      'settings.regional': 'Regional',
      'settings.currency': 'Moneda',
      'settings.currency.subtitle': 'Para listas de gastos',
      'settings.account': 'Cuenta',
      'settings.logout': 'Cerrar Sesión',
      'settings.version': 'Versión',

      'profile.title': 'Mi Perfil',
      'profile.user': 'Usuario',
      'profile.editProfile': 'Editar perfil',
      'profile.changePassword': 'Cambiar contraseña',

      'fontSize.verySmall': 'Muy Pequeño',
      'fontSize.small': 'Pequeño',
      'fontSize.normal': 'Normal',
      'fontSize.medium': 'Mediano',
      'fontSize.large': 'Grande',
      'fontSize.veryLarge': 'Muy Grande',

      'accent.amethyst': 'Amatista',
      'accent.sapphire': 'Zafiro',
      'accent.ruby': 'Rubí',
      'accent.emerald': 'Esmeralda',
      'accent.cobalt': 'Cobalto',
      'accent.cyan': 'Turquesa',
      'accent.magenta': 'Magenta',
      'accent.titanium': 'Titanio',
    },

    // ---- Català / Valencià ----
    'ca': {
      'common.save': 'Guardar',
      'common.cancel': 'Cancel·lar',
      'common.delete': 'Eliminar',
      'common.edit': 'Editar',
      'common.add': 'Afegir',
      'common.confirm': 'Confirmar',
      'common.back': 'Enrere',
      'common.loading': 'Carregant…',
      'common.search': 'Cercar',

      'settings.title': 'Ajustos',
      'settings.appearance': 'Aparença',
      'settings.theme': "Tema de l'aplicació",
      'settings.theme.subtitle': 'Tria el mode de color',
      'settings.theme.light': 'Clar',
      'settings.theme.dark': 'Fosc',
      'settings.theme.system': 'Sistema',
      'settings.accent': 'Tria el teu tema',
      'settings.textAndReading': 'Text i Lectura',
      'settings.fontSize': 'Mida de la lletra',
      'settings.fontSize.subtitle': 'Ajusta la mida del text global',
      'settings.language': 'Idioma',
      'settings.language.subtitle': "Idioma de l'aplicació",
      'settings.regional': 'Regional',
      'settings.currency': 'Moneda',
      'settings.currency.subtitle': 'Per a llistes de despeses',
      'settings.account': 'Compte',
      'settings.logout': 'Tancar sessió',
      'settings.version': 'Versió',

      'profile.title': 'El meu perfil',
      'profile.user': 'Usuari',
      'profile.editProfile': 'Editar perfil',
      'profile.changePassword': 'Canviar contrasenya',

      'fontSize.verySmall': 'Molt petit',
      'fontSize.small': 'Petit',
      'fontSize.normal': 'Normal',
      'fontSize.medium': 'Mitjà',
      'fontSize.large': 'Gran',
      'fontSize.veryLarge': 'Molt gran',

      'accent.amethyst': 'Ametista',
      'accent.sapphire': 'Safir',
      'accent.ruby': 'Robí',
      'accent.emerald': 'Maragda',
      'accent.cobalt': 'Cobalt',
      'accent.cyan': 'Cian',
      'accent.magenta': 'Magenta',
      'accent.titanium': 'Titani',
    },

    // ---- English ----
    'en': {
      'common.save': 'Save',
      'common.cancel': 'Cancel',
      'common.delete': 'Delete',
      'common.edit': 'Edit',
      'common.add': 'Add',
      'common.confirm': 'Confirm',
      'common.back': 'Back',
      'common.loading': 'Loading…',
      'common.search': 'Search',

      'settings.title': 'Settings',
      'settings.appearance': 'Appearance',
      'settings.theme': 'App theme',
      'settings.theme.subtitle': 'Choose color mode',
      'settings.theme.light': 'Light',
      'settings.theme.dark': 'Dark',
      'settings.theme.system': 'System',
      'settings.accent': 'Choose accent',
      'settings.textAndReading': 'Text & Reading',
      'settings.fontSize': 'Font size',
      'settings.fontSize.subtitle': 'Adjust global text size',
      'settings.language': 'Language',
      'settings.language.subtitle': 'Application language',
      'settings.regional': 'Regional',
      'settings.currency': 'Currency',
      'settings.currency.subtitle': 'For expense lists',
      'settings.account': 'Account',
      'settings.logout': 'Log out',
      'settings.version': 'Version',

      'profile.title': 'My Profile',
      'profile.user': 'User',
      'profile.editProfile': 'Edit profile',
      'profile.changePassword': 'Change password',

      'fontSize.verySmall': 'Very Small',
      'fontSize.small': 'Small',
      'fontSize.normal': 'Normal',
      'fontSize.medium': 'Medium',
      'fontSize.large': 'Large',
      'fontSize.veryLarge': 'Very Large',

      'accent.amethyst': 'Amethyst',
      'accent.sapphire': 'Sapphire',
      'accent.ruby': 'Ruby',
      'accent.emerald': 'Emerald',
      'accent.cobalt': 'Cobalt',
      'accent.cyan': 'Cyan',
      'accent.magenta': 'Magenta',
      'accent.titanium': 'Titanium',
    },

    // ---- Français ----
    'fr': {
      'common.save': 'Enregistrer',
      'common.cancel': 'Annuler',
      'common.delete': 'Supprimer',
      'common.edit': 'Modifier',
      'common.add': 'Ajouter',
      'common.confirm': 'Confirmer',
      'common.back': 'Retour',
      'common.loading': 'Chargement…',
      'common.search': 'Rechercher',

      'settings.title': 'Paramètres',
      'settings.appearance': 'Apparence',
      'settings.theme': "Thème de l'application",
      'settings.theme.subtitle': 'Choisissez le mode couleur',
      'settings.theme.light': 'Clair',
      'settings.theme.dark': 'Sombre',
      'settings.theme.system': 'Système',
      'settings.accent': 'Choisissez votre thème',
      'settings.textAndReading': 'Texte et Lecture',
      'settings.fontSize': 'Taille de la police',
      'settings.fontSize.subtitle': 'Ajustez la taille du texte global',
      'settings.language': 'Langue',
      'settings.language.subtitle': "Langue de l'application",
      'settings.regional': 'Régional',
      'settings.currency': 'Devise',
      'settings.currency.subtitle': 'Pour les listes de dépenses',
      'settings.account': 'Compte',
      'settings.logout': 'Se déconnecter',
      'settings.version': 'Version',

      'profile.title': 'Mon Profil',
      'profile.user': 'Utilisateur',
      'profile.editProfile': 'Modifier le profil',
      'profile.changePassword': 'Changer le mot de passe',

      'fontSize.verySmall': 'Très petit',
      'fontSize.small': 'Petit',
      'fontSize.normal': 'Normal',
      'fontSize.medium': 'Moyen',
      'fontSize.large': 'Grand',
      'fontSize.veryLarge': 'Très grand',

      'accent.amethyst': 'Améthyste',
      'accent.sapphire': 'Saphir',
      'accent.ruby': 'Rubis',
      'accent.emerald': 'Émeraude',
      'accent.cobalt': 'Cobalt',
      'accent.cyan': 'Cyan',
      'accent.magenta': 'Magenta',
      'accent.titanium': 'Titane',
    },

    // ---- Italiano ----
    'it': {
      'common.save': 'Salva',
      'common.cancel': 'Annulla',
      'common.delete': 'Elimina',
      'common.edit': 'Modifica',
      'common.add': 'Aggiungi',
      'common.confirm': 'Conferma',
      'common.back': 'Indietro',
      'common.loading': 'Caricamento…',
      'common.search': 'Cerca',

      'settings.title': 'Impostazioni',
      'settings.appearance': 'Aspetto',
      'settings.theme': "Tema dell'app",
      'settings.theme.subtitle': 'Scegli la modalità colore',
      'settings.theme.light': 'Chiaro',
      'settings.theme.dark': 'Scuro',
      'settings.theme.system': 'Sistema',
      'settings.accent': 'Scegli il tema',
      'settings.textAndReading': 'Testo e Lettura',
      'settings.fontSize': 'Dimensione del testo',
      'settings.fontSize.subtitle': 'Regola la dimensione globale del testo',
      'settings.language': 'Lingua',
      'settings.language.subtitle': "Lingua dell'applicazione",
      'settings.regional': 'Regionale',
      'settings.currency': 'Valuta',
      'settings.currency.subtitle': 'Per le liste delle spese',
      'settings.account': 'Account',
      'settings.logout': 'Esci',
      'settings.version': 'Versione',

      'profile.title': 'Il mio profilo',
      'profile.user': 'Utente',
      'profile.editProfile': 'Modifica profilo',
      'profile.changePassword': 'Cambia password',

      'fontSize.verySmall': 'Molto piccolo',
      'fontSize.small': 'Piccolo',
      'fontSize.normal': 'Normale',
      'fontSize.medium': 'Medio',
      'fontSize.large': 'Grande',
      'fontSize.veryLarge': 'Molto grande',

      'accent.amethyst': 'Ametista',
      'accent.sapphire': 'Zaffiro',
      'accent.ruby': 'Rubino',
      'accent.emerald': 'Smeraldo',
      'accent.cobalt': 'Cobalto',
      'accent.cyan': 'Ciano',
      'accent.magenta': 'Magenta',
      'accent.titanium': 'Titanio',
    },

    // ---- Deutsch ----
    'de': {
      'common.save': 'Speichern',
      'common.cancel': 'Abbrechen',
      'common.delete': 'Löschen',
      'common.edit': 'Bearbeiten',
      'common.add': 'Hinzufügen',
      'common.confirm': 'Bestätigen',
      'common.back': 'Zurück',
      'common.loading': 'Laden…',
      'common.search': 'Suchen',

      'settings.title': 'Einstellungen',
      'settings.appearance': 'Erscheinungsbild',
      'settings.theme': 'App-Design',
      'settings.theme.subtitle': 'Farbmodus wählen',
      'settings.theme.light': 'Hell',
      'settings.theme.dark': 'Dunkel',
      'settings.theme.system': 'System',
      'settings.accent': 'Wähle dein Theme',
      'settings.textAndReading': 'Text und Lesen',
      'settings.fontSize': 'Schriftgröße',
      'settings.fontSize.subtitle': 'Globale Textgröße anpassen',
      'settings.language': 'Sprache',
      'settings.language.subtitle': 'Anwendungssprache',
      'settings.regional': 'Regional',
      'settings.currency': 'Währung',
      'settings.currency.subtitle': 'Für Ausgabenlisten',
      'settings.account': 'Konto',
      'settings.logout': 'Abmelden',
      'settings.version': 'Version',

      'profile.title': 'Mein Profil',
      'profile.user': 'Benutzer',
      'profile.editProfile': 'Profil bearbeiten',
      'profile.changePassword': 'Passwort ändern',

      'fontSize.verySmall': 'Sehr klein',
      'fontSize.small': 'Klein',
      'fontSize.normal': 'Normal',
      'fontSize.medium': 'Mittel',
      'fontSize.large': 'Groß',
      'fontSize.veryLarge': 'Sehr groß',

      'accent.amethyst': 'Amethyst',
      'accent.sapphire': 'Saphir',
      'accent.ruby': 'Rubin',
      'accent.emerald': 'Smaragd',
      'accent.cobalt': 'Kobalt',
      'accent.cyan': 'Cyan',
      'accent.magenta': 'Magenta',
      'accent.titanium': 'Titan',
    },

    // ---- Português ----
    'pt': {
      'common.save': 'Guardar',
      'common.cancel': 'Cancelar',
      'common.delete': 'Eliminar',
      'common.edit': 'Editar',
      'common.add': 'Adicionar',
      'common.confirm': 'Confirmar',
      'common.back': 'Voltar',
      'common.loading': 'A carregar…',
      'common.search': 'Pesquisar',

      'settings.title': 'Definições',
      'settings.appearance': 'Aparência',
      'settings.theme': 'Tema da aplicação',
      'settings.theme.subtitle': 'Escolha o modo de cor',
      'settings.theme.light': 'Claro',
      'settings.theme.dark': 'Escuro',
      'settings.theme.system': 'Sistema',
      'settings.accent': 'Escolha o tema',
      'settings.textAndReading': 'Texto e Leitura',
      'settings.fontSize': 'Tamanho do texto',
      'settings.fontSize.subtitle': 'Ajustar tamanho global do texto',
      'settings.language': 'Idioma',
      'settings.language.subtitle': 'Idioma da aplicação',
      'settings.regional': 'Regional',
      'settings.currency': 'Moeda',
      'settings.currency.subtitle': 'Para listas de despesas',
      'settings.account': 'Conta',
      'settings.logout': 'Terminar sessão',
      'settings.version': 'Versão',

      'profile.title': 'Meu Perfil',
      'profile.user': 'Utilizador',
      'profile.editProfile': 'Editar perfil',
      'profile.changePassword': 'Alterar palavra-passe',

      'fontSize.verySmall': 'Muito pequeno',
      'fontSize.small': 'Pequeno',
      'fontSize.normal': 'Normal',
      'fontSize.medium': 'Médio',
      'fontSize.large': 'Grande',
      'fontSize.veryLarge': 'Muito grande',

      'accent.amethyst': 'Ametista',
      'accent.sapphire': 'Safira',
      'accent.ruby': 'Rubi',
      'accent.emerald': 'Esmeralda',
      'accent.cobalt': 'Cobalto',
      'accent.cyan': 'Ciano',
      'accent.magenta': 'Magenta',
      'accent.titanium': 'Titânio',
    },
  };

  /// Resuelve un string en el idioma actual del SettingsProvider.
  static String t(BuildContext context, String key) {
    final locale = context.read<SettingsProvider>().locale;
    return _resolve(locale, key);
  }

  static String _resolve(String locale, String key) {
    final map = _strings[locale] ?? _strings[defaultLocale]!;
    return map[key] ?? _strings[defaultLocale]?[key] ?? key;
  }
}

extension AppStringsContext on BuildContext {
  /// Lee del SettingsProvider (re-build si cambia el idioma).
  String tr(String key) {
    final locale = watch<SettingsProvider>().locale;
    return AppStrings._resolve(locale, key);
  }
}
