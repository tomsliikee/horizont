// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Horizont';

  @override
  String get settings => 'Einstellungen';

  @override
  String get privacyReportLabel => 'Datenschutzbericht · 7 Tage';

  @override
  String get trackersBlocked => 'Tracker blockiert';

  @override
  String moreThanLastWeek(int count) {
    return '$count mehr als letzte Woche';
  }

  @override
  String fewerThanLastWeek(int count) {
    return '$count weniger als letzte Woche';
  }

  @override
  String get sameAsLastWeek => 'So viele wie letzte Woche';

  @override
  String get countedOnDevice => 'Gezählt auf diesem Gerät.';

  @override
  String get favourites => 'Favoriten';

  @override
  String get frequentlyVisited => 'Häufig besucht';

  @override
  String get readingList => 'Leseliste';

  @override
  String readMinutes(int count) {
    return '$count Min.';
  }

  @override
  String get home => 'Startseite';

  @override
  String get back => 'Zurück';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get colourwayWallpaper => 'Hintergrund';

  @override
  String get colourwayBlue => 'Blau';

  @override
  String get colourwayViolet => 'Violett';

  @override
  String get colourwayGreen => 'Grün';

  @override
  String get colourwayOrange => 'Orange';

  @override
  String get colourwayPink => 'Pink';

  @override
  String get forward => 'Vorwärts';

  @override
  String get reload => 'Neu laden';

  @override
  String get menu => 'Menü';

  @override
  String get searchOrEnterAddress => 'Suchen oder Adresse';

  @override
  String get searchOrEnterAddressLong => 'Suchen oder Adresse eingeben';

  @override
  String get privateSearchOrAddress => 'Privat · Suchen oder Adresse';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get linkNeedsOtherApp =>
      'Dieser Link braucht eine andere App und wurde nicht geöffnet.';

  @override
  String get tabs => 'Tabs';

  @override
  String tabsOpen(int count) {
    return '$count offen';
  }

  @override
  String tabsOpenInGroup(int count, String group) {
    return '$count offen · Gruppe „$group“';
  }

  @override
  String get newTab => 'Neuer Tab';

  @override
  String get done => 'Fertig';

  @override
  String get closeTab => 'Tab schließen';

  @override
  String get privateMode => 'Privat';

  @override
  String tabsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tabs',
      one: '1 Tab',
    );
    return '$_temp0';
  }

  @override
  String privateTabsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count private Tabs',
      one: '1 privater Tab',
      zero: 'Keine privaten Tabs',
    );
    return '$_temp0';
  }

  @override
  String get startPage => 'Startseite';

  @override
  String get closeAllTabs => 'Alle schließen';

  @override
  String get closeAllTabsTitle => 'Alle Tabs schließen?';

  @override
  String get tabClosed => 'Tab geschlossen';

  @override
  String get undo => 'Rückgängig';

  @override
  String get topHit => 'Top-Treffer';

  @override
  String suggestionsFrom(String engine) {
    return 'Suchvorschläge · $engine';
  }

  @override
  String get fromYourLibrary => 'Aus deiner Mediathek';

  @override
  String get quickSearch => 'Schnellsuche';

  @override
  String get quickImages => 'Bilder';

  @override
  String get quickMaps => 'Karten';

  @override
  String get quickNews => 'News';

  @override
  String get quickWeather => 'Wetter';

  @override
  String get weatherWord => 'Wetter';

  @override
  String get clearInput => 'Eingabe löschen';

  @override
  String get suggestionSearch => 'Suche';

  @override
  String suggestionHistory(String when) {
    return 'Verlauf · $when';
  }

  @override
  String suggestionBookmark(String folder) {
    return 'Lesezeichen · $folder';
  }

  @override
  String suggestionReading(String host) {
    return '$host · in deiner Leseliste';
  }

  @override
  String suggestionVisited(String host, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal',
      one: 'einmal',
    );
    return '$host · $_temp0 besucht';
  }

  @override
  String get switchToTab => 'Zu Tab wechseln';

  @override
  String openAddress(String address) {
    return '$address öffnen';
  }

  @override
  String get insertSuggestion => 'Ins Feld übernehmen';

  @override
  String get closeMenu => 'Menü schließen';

  @override
  String get close => 'Schließen';

  @override
  String get connectionSecure => 'Verbindung sicher';

  @override
  String get connectionInsecure => 'Nicht sicher';

  @override
  String get share => 'Teilen';

  @override
  String get saveBookmark => 'Merken';

  @override
  String get saved => 'Gemerkt';

  @override
  String get addToReadingList => 'Leseliste';

  @override
  String get findInPage => 'Suchen';

  @override
  String get readerView => 'Reader-Ansicht';

  @override
  String get textSize => 'Textgröße';

  @override
  String get smaller => 'Kleiner';

  @override
  String get bigger => 'Größer';

  @override
  String get desktopSite => 'Desktop-Website anfordern';

  @override
  String get mobileSite => 'Mobile Website anfordern';

  @override
  String get addToHomeScreen => 'Zum Startbildschirm';

  @override
  String tabsWithCount(int count) {
    return 'Tabs ($count)';
  }

  @override
  String get library => 'Mediathek';

  @override
  String get downloads => 'Downloads';

  @override
  String get privateTab => 'Privater Tab';

  @override
  String bookmarkAdded(String folder) {
    return 'In „$folder“ gemerkt';
  }

  @override
  String get bookmarkRemoved => 'Lesezeichen entfernt';

  @override
  String get readingAdded => 'Zur Leseliste hinzugefügt';

  @override
  String get readingAddedOffline =>
      'Zur Leseliste hinzugefügt, offline verfügbar';

  @override
  String get noArticle => 'Keine Reader-Ansicht für diese Seite';

  @override
  String get pinUnsupported =>
      'Der Startbildschirm nimmt keine Verknüpfungen an';

  @override
  String get chooseFolder => 'In Ordner merken';

  @override
  String get newFolder => 'Neuer Ordner';

  @override
  String get folderName => 'Name';

  @override
  String get create => 'Anlegen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get deleteFolder => 'Ordner löschen';

  @override
  String deleteFolderTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get deleteFolderBody =>
      'Der Ordner und seine Lesezeichen werden gelöscht.';

  @override
  String get findPlaceholder => 'Auf der Seite suchen';

  @override
  String findCount(int active, int count) {
    return '$active von $count';
  }

  @override
  String get noMatches => 'Keine Treffer';

  @override
  String get previousMatch => 'Vorheriger Treffer';

  @override
  String get nextMatch => 'Nächster Treffer';

  @override
  String get closeFind => 'Suche schließen';

  @override
  String get bookmarks => 'Lesezeichen';

  @override
  String get history => 'Verlauf';

  @override
  String get searchHistory => 'Verlauf durchsuchen';

  @override
  String get searchBookmarks => 'Lesezeichen durchsuchen';

  @override
  String get searchReadingList => 'Leseliste durchsuchen';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get clearHistory => 'Verlauf löschen …';

  @override
  String get clearHistoryTitle => 'Verlauf löschen?';

  @override
  String get clearHistoryBody =>
      'Alle besuchten Seiten auf diesem Gerät werden gelöscht. Lesezeichen und Leseliste bleiben.';

  @override
  String get delete => 'Löschen';

  @override
  String get remove => 'Entfernen';

  @override
  String bookmarkCount(int count) {
    return '$count Lesezeichen';
  }

  @override
  String get readingUnread => 'Ungelesen';

  @override
  String get readingStarted => 'Angefangen';

  @override
  String get readingHalf => 'Zur Hälfte gelesen';

  @override
  String get readingAlmost => 'Fast fertig';

  @override
  String get readingOffline => 'Offline verfügbar';

  @override
  String get emptyHistory => 'Noch kein Verlauf';

  @override
  String get emptyHistoryHint =>
      'Besuchte Seiten erscheinen hier, nach Tagen geordnet.';

  @override
  String get emptyFolder => 'Keine Lesezeichen in diesem Ordner';

  @override
  String get emptyFolderHint => 'Im Menü einer Seite auf „Merken“ tippen.';

  @override
  String get emptyReading => 'Die Leseliste ist leer';

  @override
  String get emptyReadingHint =>
      'Im Menü auf „Leseliste“ tippen, um eine Seite für später zu behalten, auch offline.';

  @override
  String get nothingFound => 'Nichts gefunden';

  @override
  String get removed => 'Entfernt';

  @override
  String get savedInDownload => 'Gespeichert in „Download“';

  @override
  String timeRemaining(String time) {
    return 'Noch etwa $time';
  }

  @override
  String filesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien heute',
      one: '1 Datei heute',
      zero: 'Heute keine Dateien',
    );
    return '$_temp0';
  }

  @override
  String get includingRunning => 'Inklusive laufendem Download.';

  @override
  String get nothingRunning => 'Gerade läuft nichts';

  @override
  String get allDone => 'Alles fertig';

  @override
  String get pauseDownload => 'Download pausieren';

  @override
  String get resumeDownload => 'Download fortsetzen';

  @override
  String get cancelDownload => 'Download abbrechen';

  @override
  String get openFile => 'Öffnen';

  @override
  String get clearList => 'Liste leeren';

  @override
  String get noDownloads => 'Noch keine Downloads';

  @override
  String get noDownloadsHint =>
      'Heruntergeladene Dateien landen im Ordner „Download“.';

  @override
  String sizeOf(String done, String total) {
    return '$done von $total';
  }

  @override
  String get downloadFailed => 'Fehlgeschlagen';

  @override
  String get downloadCanceled => 'Abgebrochen';

  @override
  String get downloadPaused => 'Pausiert';

  @override
  String get downloadWaiting => 'Wartet …';

  @override
  String get downloadStarted => 'Download gestartet';

  @override
  String get downloadAsk => 'Datei herunterladen?';

  @override
  String get download => 'Herunterladen';

  @override
  String get privateDownloadWarning =>
      'Die Datei bleibt nach der privaten Sitzung im Ordner „Download“.';

  @override
  String get openFailed => 'Keine App kann diese Datei öffnen';

  @override
  String get unknownSize => 'Größe unbekannt';

  @override
  String get showAll => 'Alle zeigen';

  @override
  String get privateTitle => 'Privat surfen';

  @override
  String get privateBody =>
      'Horizont merkt sich keine besuchten Seiten, Suchen oder Formulardaten. Schließt du den letzten privaten Tab, ist alles weg.';

  @override
  String get lockedWithFingerprint => 'Mit Fingerabdruck gesperrt';

  @override
  String get whenLeavingApp => 'Wenn du die App verlässt';

  @override
  String get lockOff => 'Nicht gesperrt';

  @override
  String get lockOffSub => 'In Datenschutz einschaltbar';

  @override
  String get strictTracking => 'Trackingschutz';

  @override
  String get strictTrackingSub =>
      'Bekannte Tracker werden blockiert, nichts wird gezählt';

  @override
  String get leavePrivate => 'Privaten Modus verlassen';

  @override
  String get privateUnavailable =>
      'Private Tabs brauchen eine neuere Android System WebView.';

  @override
  String get unlock => 'Entsperren';

  @override
  String get unlockReason => 'Private Tabs entsperren';

  @override
  String get privateLocked => 'Private Tabs sind gesperrt';

  @override
  String get notStored => 'Wird nicht gespeichert';

  @override
  String get designAndColour => 'Design & Farbe';

  @override
  String designSummary(String theme, String colourway, String layout) {
    return '$theme · $colourway · $layout';
  }

  @override
  String get designHint => '6 Leistenlayouts, 6 Farbwelten';

  @override
  String get general => 'Allgemein';

  @override
  String get searchEngine => 'Suchmaschine';

  @override
  String get startPageSections => 'Favoriten, Häufig besucht, Leseliste';

  @override
  String get startPageNothing => 'Nur die Suche';

  @override
  String get groupTabs => 'Tabs gruppieren';

  @override
  String get groupTabsSub => 'Aus einem Tab geöffnete Tabs bleiben bei ihm';

  @override
  String get homeAfterAway => 'Startseite nach Abwesenheit';

  @override
  String get homeAfterAwaySub =>
      'Wer länger weg war, als hier eingestellt, kommt auf einen neuen Tab mit der Startseite zurück. Der alte Tab bleibt offen.';

  @override
  String get homeAfterHalfHour => 'Nach 30 Minuten';

  @override
  String get homeAfterHour => 'Nach 1 Stunde';

  @override
  String get homeAfterFourHours => 'Nach 4 Stunden';

  @override
  String get autoCloseTabs => 'Tabs automatisch schließen';

  @override
  String get autoCloseNever => 'Nie';

  @override
  String get autoCloseDay => 'Nach 1 Tag';

  @override
  String get autoCloseWeek => 'Nach 1 Woche';

  @override
  String get autoCloseMonth => 'Nach 1 Monat';

  @override
  String get autoCloseSub =>
      'Tabs, die so lange nicht angesehen wurden, schließen beim Start von Horizont.';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get privacySecurity => 'Datenschutz & Sicherheit';

  @override
  String get trackingOn => 'Tracking-Schutz an';

  @override
  String get trackingOff => 'Tracking-Schutz aus';

  @override
  String get httpsOnlyShort => 'Nur HTTPS';

  @override
  String get passwords => 'Passwörter & Passkeys';

  @override
  String get passwordsSub => 'Google Passwortmanager';

  @override
  String get siteSettings => 'Website-Einstellungen';

  @override
  String get siteSettingsSub => 'Kamera, Mikrofon, Standort';

  @override
  String get advanced => 'Erweitert';

  @override
  String get askBeforeDownload => 'Vor dem Speichern fragen';

  @override
  String get saveWithoutAsking => 'Ohne Nachfrage speichern';

  @override
  String get accessibility => 'Bedienungshilfen';

  @override
  String get accessibilitySub => 'Textgröße, Zoom erzwingen';

  @override
  String get about => 'Über Horizont';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get defaultBrowser => 'Standardbrowser';

  @override
  String get defaultBrowserSub => 'Links aus anderen Apps in Horizont öffnen';

  @override
  String get changesApplyNow => 'Änderungen gelten sofort';

  @override
  String get mode => 'Modus';

  @override
  String get colourway => 'Farbwelt';

  @override
  String get barLayout => 'Leistenlayout';

  @override
  String get bar => 'Leiste';

  @override
  String get tintFromPage => 'Websitefarbe übernehmen';

  @override
  String get tintFromPageSub =>
      'Statusleiste in der Farbe des Seitenkopfs tönen';

  @override
  String get shrinkOnScroll => 'Beim Scrollen verkleinern';

  @override
  String get shrinkOnScrollSub => 'Zeigt nur noch die Domain';

  @override
  String get translucentBars => 'Durchscheinend';

  @override
  String get translucentBarsSub =>
      'Lässt durchscheinen, was darunter liegt; in der App weichgezeichnet';

  @override
  String get hideAtEnd => 'Am Seitenende ausblenden';

  @override
  String get hideAtEndSub => 'Die Leiste verschwindet, wenn du unten ankommst';

  @override
  String get layoutKompakt => 'Kompakt';

  @override
  String get layoutZweireihig => 'Zweireihig';

  @override
  String get layoutExpressiv => 'Expressiv';

  @override
  String get layoutOben => 'Oben';

  @override
  String get layoutKarte => 'Karte';

  @override
  String get layoutMinimal => 'Minimal';

  @override
  String get engineSub => 'Für die Adressleiste und Schnellsuche';

  @override
  String get engineGoogleSub => 'Standard';

  @override
  String get engineEcosiaSub => 'Pflanzt Bäume mit Werbeeinnahmen';

  @override
  String get engineDdgSub => 'Ohne Personalisierung';

  @override
  String get engineStartpageSub => 'Google-Ergebnisse, anonymisiert';

  @override
  String get engineBingSub => 'Microsoft';

  @override
  String get suggestions => 'Vorschläge';

  @override
  String get searchSuggestions => 'Suchvorschläge';

  @override
  String searchSuggestionsSub(String engine) {
    return 'Eingaben werden an $engine gesendet';
  }

  @override
  String thisWeekSites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Websites',
      one: '1 Website',
    );
    return 'Diese Woche · $_temp0';
  }

  @override
  String get protection => 'Schutz';

  @override
  String get blockTracking => 'Websiteübergreifendes Tracking verhindern';

  @override
  String get blockTrackingSub =>
      'Werbenetzwerke folgen dir nicht von Seite zu Seite';

  @override
  String get httpsOnly => 'Nur HTTPS';

  @override
  String get httpsOnlySub => 'Unsichere Verbindungen werden vorher gemeldet';

  @override
  String get fraudWarning => 'Warnung bei Betrugsseiten';

  @override
  String get fraudWarningSub => 'Prüft Adressen gegen bekannte Phishing-Listen';

  @override
  String get lockPrivateTabs => 'Private Tabs sperren';

  @override
  String get lockPrivateTabsSub => 'Entsperren mit Fingerabdruck';

  @override
  String get clearData => 'Verlauf und Websitedaten löschen';

  @override
  String get clearDataTitle => 'Verlauf und Websitedaten löschen?';

  @override
  String get clearDataBody =>
      'Besuchte Seiten, Cookies, Anmeldungen auf Websites, der Cache und Website-Berechtigungen werden gelöscht. Lesezeichen, Leseliste und Downloads bleiben.';

  @override
  String get cleared => 'Gelöscht';

  @override
  String get showOnStartPage => 'Auf der Startseite zeigen';

  @override
  String get camera => 'Kamera';

  @override
  String get microphone => 'Mikrofon';

  @override
  String get location => 'Standort';

  @override
  String get allowed => 'Erlaubt';

  @override
  String get blocked => 'Blockiert';

  @override
  String get noSitePermissions => 'Noch keine Website hat gefragt';

  @override
  String get noSitePermissionsHint =>
      'Fragt eine Website nach Kamera, Mikrofon oder Standort, steht deine Antwort hier.';

  @override
  String get resetAll => 'Alle zurücksetzen';

  @override
  String get forceZoom => 'Zoom erzwingen';

  @override
  String get forceZoomSub => 'Auch Seiten vergrößern, die es verbieten';

  @override
  String get textSizePerSite => 'Textgröße pro Website';

  @override
  String get textSizePerSiteHint =>
      'Im Menü einer Seite einstellen; gilt dann für die ganze Website.';

  @override
  String get aboutBody =>
      'Ein Browser für Android in Toms Expressive Design. Seiten zeigt Android System WebView.';

  @override
  String get licences => 'Lizenzen';

  @override
  String get licencesSub =>
      'Readability, EasyPrivacy, Google Sans Flex und die Pakete';

  @override
  String get bundledData => 'Mitgelieferte Daten';

  @override
  String get offlineTitle => 'Keine Verbindung';

  @override
  String offlineBody(String host) {
    return '$host ist gerade nicht erreichbar. Prüfe die Verbindung und versuche es noch einmal.';
  }

  @override
  String get certificateTitle => 'Verbindung nicht sicher';

  @override
  String certificateBody(String host) {
    return 'Das Zertifikat von $host ist nicht gültig, deshalb hat Horizont die Seite nicht geladen.';
  }

  @override
  String get insecureTitle => 'Kein HTTPS';

  @override
  String insecureBody(String host) {
    return '$host bietet keine sichere Verbindung an. Was du sendest, wäre unterwegs lesbar.';
  }

  @override
  String get continueInsecure => 'Trotzdem über HTTP öffnen';

  @override
  String get failedTitle => 'Seite nicht geladen';

  @override
  String failedBody(String host) {
    return '$host konnte nicht angezeigt werden.';
  }

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get pageCrashed => 'Die Seite ist abgestürzt und wurde neu geladen.';

  @override
  String pageSays(String host) {
    return '$host meldet';
  }

  @override
  String get ok => 'OK';

  @override
  String signInTo(String host) {
    return 'Anmelden bei $host';
  }

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get signIn => 'Anmelden';

  @override
  String permissionAsk(String host, String what) {
    return '$host möchte $what verwenden';
  }

  @override
  String get and => 'und';

  @override
  String get allow => 'Erlauben';

  @override
  String get dontAllow => 'Nicht erlauben';

  @override
  String get openInOtherApp => 'In anderer App öffnen?';

  @override
  String openInOtherAppBody(String target) {
    return 'Die Seite möchte $target öffnen.';
  }

  @override
  String get open => 'Öffnen';

  @override
  String get noAppForLink => 'Keine App kann diesen Link öffnen';

  @override
  String get chooseFiles => 'Dateien wählen';

  @override
  String get search => 'Suchen';

  @override
  String get startNav => 'Start';

  @override
  String secureSubtitle(String title) {
    return '$title · sicher';
  }

  @override
  String insecureSubtitle(String title) {
    return '$title · nicht sicher';
  }

  @override
  String get voiceSearch => 'Sprachsuche';

  @override
  String get showBar => 'Leiste zeigen';

  @override
  String get swipeForTabs => 'Wischen für den nächsten Tab';

  @override
  String get scrollToTop => 'Statusleiste, tippen, um nach oben zu scrollen';

  @override
  String tabPosition(String title, int index, int count) {
    return '$title, Tab $index von $count';
  }

  @override
  String get activeTab => 'im Vordergrund';

  @override
  String get greetingMorning => 'Guten Morgen';

  @override
  String get greetingAfternoon => 'Guten Tag';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get greetingNight => 'Gute Nacht';
}
