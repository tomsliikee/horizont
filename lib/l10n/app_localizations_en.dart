// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Horizont';

  @override
  String get settings => 'Settings';

  @override
  String get privacyReportLabel => 'Privacy report · 7 days';

  @override
  String get trackersBlocked => 'Trackers blocked';

  @override
  String moreThanLastWeek(int count) {
    return '$count more than last week';
  }

  @override
  String fewerThanLastWeek(int count) {
    return '$count fewer than last week';
  }

  @override
  String get sameAsLastWeek => 'As many as last week';

  @override
  String get countedOnDevice => 'Counted on this device.';

  @override
  String get favourites => 'Favourites';

  @override
  String get frequentlyVisited => 'Frequently visited';

  @override
  String get readingList => 'Reading list';

  @override
  String readMinutes(int count) {
    return '$count min.';
  }

  @override
  String get home => 'Home';

  @override
  String get back => 'Back';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get colourwayWallpaper => 'Wallpaper';

  @override
  String get colourwayBlue => 'Blue';

  @override
  String get colourwayViolet => 'Violet';

  @override
  String get colourwayGreen => 'Green';

  @override
  String get colourwayOrange => 'Orange';

  @override
  String get colourwayPink => 'Pink';

  @override
  String get forward => 'Forward';

  @override
  String get reload => 'Reload';

  @override
  String get menu => 'Menu';

  @override
  String get searchOrEnterAddress => 'Search or address';

  @override
  String get searchOrEnterAddressLong => 'Search or enter address';

  @override
  String get privateSearchOrAddress => 'Private · Search or address';

  @override
  String get cancel => 'Cancel';

  @override
  String get linkNeedsOtherApp =>
      'This link needs another app and was not opened.';

  @override
  String get tabs => 'Tabs';

  @override
  String tabsOpen(int count) {
    return '$count open';
  }

  @override
  String tabsOpenInGroup(int count, String group) {
    return '$count open · Group “$group”';
  }

  @override
  String get newTab => 'New tab';

  @override
  String get done => 'Done';

  @override
  String get closeTab => 'Close tab';

  @override
  String get privateMode => 'Private';

  @override
  String tabsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabs',
      one: '1 tab',
    );
    return '$_temp0';
  }

  @override
  String privateTabsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count private tabs',
      one: '1 private tab',
      zero: 'No private tabs',
    );
    return '$_temp0';
  }

  @override
  String get startPage => 'Start page';

  @override
  String get closeAllTabs => 'Close all';

  @override
  String get closeAllTabsTitle => 'Close all tabs?';

  @override
  String get tabClosed => 'Tab closed';

  @override
  String get undo => 'Undo';

  @override
  String get topHit => 'Top hit';

  @override
  String suggestionsFrom(String engine) {
    return 'Search suggestions · $engine';
  }

  @override
  String get fromYourLibrary => 'From your library';

  @override
  String get quickSearch => 'Quick search';

  @override
  String get quickImages => 'Images';

  @override
  String get quickMaps => 'Maps';

  @override
  String get quickNews => 'News';

  @override
  String get quickWeather => 'Weather';

  @override
  String get weatherWord => 'weather';

  @override
  String get clearInput => 'Clear input';

  @override
  String get suggestionSearch => 'Search';

  @override
  String suggestionHistory(String when) {
    return 'History · $when';
  }

  @override
  String suggestionBookmark(String folder) {
    return 'Bookmark · $folder';
  }

  @override
  String suggestionReading(String host) {
    return '$host · in your reading list';
  }

  @override
  String suggestionVisited(String host, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$host · visited $_temp0';
  }

  @override
  String get switchToTab => 'Switch to tab';

  @override
  String openAddress(String address) {
    return 'Open $address';
  }

  @override
  String get insertSuggestion => 'Take into the field';

  @override
  String get closeMenu => 'Close menu';

  @override
  String get close => 'Close';

  @override
  String get connectionSecure => 'Connection secure';

  @override
  String get connectionInsecure => 'Not secure';

  @override
  String get share => 'Share';

  @override
  String get saveBookmark => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get addToReadingList => 'Reading list';

  @override
  String get findInPage => 'Find';

  @override
  String get readerView => 'Reader view';

  @override
  String get textSize => 'Text size';

  @override
  String get smaller => 'Smaller';

  @override
  String get bigger => 'Bigger';

  @override
  String get desktopSite => 'Request desktop site';

  @override
  String get mobileSite => 'Request mobile site';

  @override
  String get addToHomeScreen => 'Add to home screen';

  @override
  String tabsWithCount(int count) {
    return 'Tabs ($count)';
  }

  @override
  String get library => 'Library';

  @override
  String get downloads => 'Downloads';

  @override
  String get privateTab => 'Private tab';

  @override
  String bookmarkAdded(String folder) {
    return 'Saved to $folder';
  }

  @override
  String get bookmarkRemoved => 'Bookmark removed';

  @override
  String get readingAdded => 'Added to the reading list';

  @override
  String get readingAddedOffline =>
      'Added to the reading list, available offline';

  @override
  String get noArticle => 'No reader view for this page';

  @override
  String get pinUnsupported => 'The home screen does not take shortcuts';

  @override
  String get chooseFolder => 'Save in folder';

  @override
  String get newFolder => 'New folder';

  @override
  String get folderName => 'Name';

  @override
  String get create => 'Create';

  @override
  String get rename => 'Rename';

  @override
  String get deleteFolder => 'Delete folder';

  @override
  String deleteFolderTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get deleteFolderBody => 'The folder and its bookmarks are deleted.';

  @override
  String get findPlaceholder => 'Find on page';

  @override
  String findCount(int active, int count) {
    return '$active of $count';
  }

  @override
  String get noMatches => 'No matches';

  @override
  String get previousMatch => 'Previous match';

  @override
  String get nextMatch => 'Next match';

  @override
  String get closeFind => 'Close find';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get history => 'History';

  @override
  String get searchHistory => 'Search history';

  @override
  String get searchBookmarks => 'Search bookmarks';

  @override
  String get searchReadingList => 'Search reading list';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get clearHistory => 'Clear history …';

  @override
  String get clearHistoryTitle => 'Clear history?';

  @override
  String get clearHistoryBody =>
      'Every visited page on this device is deleted. Bookmarks and the reading list stay.';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String bookmarkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookmarks',
      one: '1 bookmark',
    );
    return '$_temp0';
  }

  @override
  String get readingUnread => 'Unread';

  @override
  String get readingStarted => 'Started';

  @override
  String get readingHalf => 'Half read';

  @override
  String get readingAlmost => 'Almost done';

  @override
  String get readingOffline => 'Available offline';

  @override
  String get emptyHistory => 'No history yet';

  @override
  String get emptyHistoryHint =>
      'Pages you visit show up here, grouped by day.';

  @override
  String get emptyFolder => 'No bookmarks in this folder';

  @override
  String get emptyFolderHint => 'Tap “Save” in the menu of a page.';

  @override
  String get emptyReading => 'Your reading list is empty';

  @override
  String get emptyReadingHint =>
      'Tap “Reading list” in the menu to keep a page for later, offline too.';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get removed => 'Removed';

  @override
  String get savedInDownload => 'Saved in “Download”';

  @override
  String timeRemaining(String time) {
    return 'About $time left';
  }

  @override
  String filesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files today',
      one: '1 file today',
      zero: 'No files today',
    );
    return '$_temp0';
  }

  @override
  String get includingRunning => 'Including the running download.';

  @override
  String get nothingRunning => 'Nothing running';

  @override
  String get allDone => 'All done';

  @override
  String get pauseDownload => 'Pause download';

  @override
  String get resumeDownload => 'Resume download';

  @override
  String get cancelDownload => 'Cancel download';

  @override
  String get openFile => 'Open';

  @override
  String get clearList => 'Clear list';

  @override
  String get noDownloads => 'No downloads yet';

  @override
  String get noDownloadsHint =>
      'Files you download land in the “Download” folder.';

  @override
  String sizeOf(String done, String total) {
    return '$done of $total';
  }

  @override
  String get downloadFailed => 'Failed';

  @override
  String get downloadCanceled => 'Canceled';

  @override
  String get downloadPaused => 'Paused';

  @override
  String get downloadWaiting => 'Waiting …';

  @override
  String get downloadStarted => 'Download started';

  @override
  String get downloadAsk => 'Download this file?';

  @override
  String get download => 'Download';

  @override
  String get privateDownloadWarning =>
      'The file stays in “Download” after the private session.';

  @override
  String get openFailed => 'No app can open this file';

  @override
  String get unknownSize => 'Size unknown';

  @override
  String get showAll => 'Show all';

  @override
  String get privateTitle => 'Browse privately';

  @override
  String get privateBody =>
      'Horizont does not keep visited pages, searches or form data. Close the last private tab and everything is gone.';

  @override
  String get lockedWithFingerprint => 'Locked with fingerprint';

  @override
  String get whenLeavingApp => 'When you leave the app';

  @override
  String get lockOff => 'Not locked';

  @override
  String get lockOffSub => 'Switch on in Privacy';

  @override
  String get strictTracking => 'Tracker blocking';

  @override
  String get strictTrackingSub =>
      'Known trackers are blocked, nothing is counted';

  @override
  String get leavePrivate => 'Leave private mode';

  @override
  String get privateUnavailable =>
      'Private tabs need a newer Android System WebView.';

  @override
  String get unlock => 'Unlock';

  @override
  String get unlockReason => 'Unlock private tabs';

  @override
  String get privateLocked => 'Private tabs are locked';

  @override
  String get notStored => 'Not stored';

  @override
  String get designAndColour => 'Design & colour';

  @override
  String designSummary(String theme, String colourway, String layout) {
    return '$theme · $colourway · $layout';
  }

  @override
  String get designHint => '6 bar layouts, 6 colourways';

  @override
  String get general => 'General';

  @override
  String get searchEngine => 'Search engine';

  @override
  String get startPageSections => 'Favourites, frequent, reading list';

  @override
  String get startPageNothing => 'Only the search';

  @override
  String get groupTabs => 'Group tabs';

  @override
  String get groupTabsSub => 'Tabs opened from a tab stay with it';

  @override
  String get homeAfterAway => 'Start page after time away';

  @override
  String get homeAfterAwaySub =>
      'Come back after longer than this and a new tab with the start page opens. The old tab stays open.';

  @override
  String get homeAfterHalfHour => 'After 30 minutes';

  @override
  String get homeAfterHour => 'After 1 hour';

  @override
  String get homeAfterFourHours => 'After 4 hours';

  @override
  String get autoCloseTabs => 'Close tabs automatically';

  @override
  String get autoCloseNever => 'Never';

  @override
  String get autoCloseDay => 'After 1 day';

  @override
  String get autoCloseWeek => 'After 1 week';

  @override
  String get autoCloseMonth => 'After 1 month';

  @override
  String get autoCloseSub =>
      'Tabs you have not looked at for that long close when Horizont starts.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacySecurity => 'Privacy & security';

  @override
  String get trackingOn => 'Tracking protection on';

  @override
  String get trackingOff => 'Tracking protection off';

  @override
  String get httpsOnlyShort => 'HTTPS only';

  @override
  String get passwords => 'Passwords & passkeys';

  @override
  String get passwordsSub => 'Google Password Manager';

  @override
  String get siteSettings => 'Site settings';

  @override
  String get siteSettingsSub => 'Camera, microphone, location';

  @override
  String get advanced => 'Advanced';

  @override
  String get askBeforeDownload => 'Ask before saving';

  @override
  String get saveWithoutAsking => 'Save without asking';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get accessibilitySub => 'Text size, force zoom';

  @override
  String get about => 'About Horizont';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get defaultBrowser => 'Default browser';

  @override
  String get defaultBrowserSub => 'Open links from other apps in Horizont';

  @override
  String get changesApplyNow => 'Changes apply at once';

  @override
  String get mode => 'Mode';

  @override
  String get colourway => 'Colourway';

  @override
  String get barLayout => 'Bar layout';

  @override
  String get bar => 'Bar';

  @override
  String get tintFromPage => 'Take the site colour';

  @override
  String get tintFromPageSub =>
      'Tint the status bar in the colour of the page header';

  @override
  String get statusBarBlur => 'Status bar blur';

  @override
  String get statusBarBlurSub =>
      'How softly the colour fades out below the status bar';

  @override
  String get blurOff => 'Off';

  @override
  String get blurSoft => 'Soft';

  @override
  String get blurStrong => 'Strong';

  @override
  String get shrinkOnScroll => 'Shrink while scrolling';

  @override
  String get shrinkOnScrollSub => 'Shows only the domain';

  @override
  String get translucentBars => 'Translucent';

  @override
  String get translucentBarsSub =>
      'Lets what lies beneath show through; blurred within the app';

  @override
  String get hideAtEnd => 'Hide at the end of the page';

  @override
  String get hideAtEndSub => 'The bar goes away when you reach the bottom';

  @override
  String get layoutKompakt => 'Compact';

  @override
  String get layoutZweireihig => 'Two rows';

  @override
  String get layoutExpressiv => 'Expressive';

  @override
  String get layoutOben => 'Top';

  @override
  String get layoutKarte => 'Card';

  @override
  String get layoutMinimal => 'Minimal';

  @override
  String get engineSub => 'For the address bar and quick search';

  @override
  String get engineGoogleSub => 'Default';

  @override
  String get engineEcosiaSub => 'Plants trees with ad revenue';

  @override
  String get engineDdgSub => 'Without personalisation';

  @override
  String get engineStartpageSub => 'Google results, anonymised';

  @override
  String get engineBingSub => 'Microsoft';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get searchSuggestions => 'Search suggestions';

  @override
  String searchSuggestionsSub(String engine) {
    return 'What you type is sent to $engine';
  }

  @override
  String thisWeekSites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sites',
      one: '1 site',
    );
    return 'This week · $_temp0';
  }

  @override
  String get protection => 'Protection';

  @override
  String get blockTracking => 'Prevent cross-site tracking';

  @override
  String get blockTrackingSub =>
      'Ad networks do not follow you from site to site';

  @override
  String get httpsOnly => 'HTTPS only';

  @override
  String get httpsOnlySub => 'Insecure connections are reported first';

  @override
  String get fraudWarning => 'Warn about fraudulent sites';

  @override
  String get fraudWarningSub => 'Checks addresses against known phishing lists';

  @override
  String get lockPrivateTabs => 'Lock private tabs';

  @override
  String get lockPrivateTabsSub => 'Unlock with fingerprint';

  @override
  String get clearData => 'Clear history and site data';

  @override
  String get clearDataTitle => 'Clear history and site data?';

  @override
  String get clearDataBody =>
      'Visited pages, cookies, logins on sites, the cache and site permissions are deleted. Bookmarks, the reading list and downloads stay.';

  @override
  String get cleared => 'Deleted';

  @override
  String get showOnStartPage => 'Show on the start page';

  @override
  String get camera => 'Camera';

  @override
  String get microphone => 'Microphone';

  @override
  String get location => 'Location';

  @override
  String get allowed => 'Allowed';

  @override
  String get blocked => 'Blocked';

  @override
  String get noSitePermissions => 'No site has asked yet';

  @override
  String get noSitePermissionsHint =>
      'When a site asks for camera, microphone or location, your answer is kept here.';

  @override
  String get resetAll => 'Reset all';

  @override
  String get forceZoom => 'Force zoom';

  @override
  String get forceZoomSub => 'Zoom pages that forbid it';

  @override
  String get textSizePerSite => 'Text size per site';

  @override
  String get textSizePerSiteHint =>
      'Set in the menu of a page; kept for its site.';

  @override
  String get aboutBody =>
      'A browser for Android in Toms Expressive Design. Pages are shown by Android System WebView.';

  @override
  String get licences => 'Licences';

  @override
  String get licencesSub =>
      'Readability, EasyPrivacy, Google Sans Flex and the packages';

  @override
  String get bundledData => 'Bundled data';

  @override
  String get offlineTitle => 'No connection';

  @override
  String offlineBody(String host) {
    return '$host cannot be reached right now. Check the connection and try again.';
  }

  @override
  String get certificateTitle => 'Connection not secure';

  @override
  String certificateBody(String host) {
    return 'The certificate of $host is not valid, so Horizont did not load the page.';
  }

  @override
  String get insecureTitle => 'No HTTPS';

  @override
  String insecureBody(String host) {
    return '$host offers no secure connection. What you send could be read on the way.';
  }

  @override
  String get continueInsecure => 'Open over HTTP anyway';

  @override
  String get failedTitle => 'Page not loaded';

  @override
  String failedBody(String host) {
    return '$host could not be shown.';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get pageCrashed => 'The page stopped and was loaded again.';

  @override
  String pageSays(String host) {
    return '$host says';
  }

  @override
  String get ok => 'OK';

  @override
  String signInTo(String host) {
    return 'Sign in to $host';
  }

  @override
  String get username => 'User name';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String permissionAsk(String host, String what) {
    return '$host wants to use $what';
  }

  @override
  String get and => 'and';

  @override
  String get allow => 'Allow';

  @override
  String get dontAllow => 'Don’t allow';

  @override
  String get openInOtherApp => 'Open in another app?';

  @override
  String openInOtherAppBody(String target) {
    return 'The page wants to open $target.';
  }

  @override
  String get open => 'Open';

  @override
  String get noAppForLink => 'No app can open this link';

  @override
  String get chooseFiles => 'Choose files';

  @override
  String get search => 'Search';

  @override
  String get startNav => 'Start';

  @override
  String secureSubtitle(String title) {
    return '$title · secure';
  }

  @override
  String insecureSubtitle(String title) {
    return '$title · not secure';
  }

  @override
  String get voiceSearch => 'Voice search';

  @override
  String get showBar => 'Show the bar';

  @override
  String get swipeForTabs => 'Swipe for the next tab';

  @override
  String get scrollToTop => 'Status bar, tap to scroll to the top';

  @override
  String tabPosition(String title, int index, int count) {
    return '$title, tab $index of $count';
  }

  @override
  String get activeTab => 'in front';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';
}
