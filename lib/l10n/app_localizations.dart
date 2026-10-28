import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Horizont'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @privacyReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy report · 7 days'**
  String get privacyReportLabel;

  /// No description provided for @trackersBlocked.
  ///
  /// In en, this message translates to:
  /// **'Trackers blocked'**
  String get trackersBlocked;

  /// No description provided for @moreThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} more than last week'**
  String moreThanLastWeek(int count);

  /// No description provided for @fewerThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} fewer than last week'**
  String fewerThanLastWeek(int count);

  /// No description provided for @sameAsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'As many as last week'**
  String get sameAsLastWeek;

  /// No description provided for @countedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Counted on this device.'**
  String get countedOnDevice;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @frequentlyVisited.
  ///
  /// In en, this message translates to:
  /// **'Frequently visited'**
  String get frequentlyVisited;

  /// No description provided for @readingList.
  ///
  /// In en, this message translates to:
  /// **'Reading list'**
  String get readingList;

  /// No description provided for @readMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min.'**
  String readMinutes(int count);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @colourwayWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get colourwayWallpaper;

  /// No description provided for @colourwayBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colourwayBlue;

  /// No description provided for @colourwayViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get colourwayViolet;

  /// No description provided for @colourwayGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colourwayGreen;

  /// No description provided for @colourwayOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colourwayOrange;

  /// No description provided for @colourwayPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colourwayPink;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @searchOrEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Search or address'**
  String get searchOrEnterAddress;

  /// No description provided for @searchOrEnterAddressLong.
  ///
  /// In en, this message translates to:
  /// **'Search or enter address'**
  String get searchOrEnterAddressLong;

  /// No description provided for @privateSearchOrAddress.
  ///
  /// In en, this message translates to:
  /// **'Private · Search or address'**
  String get privateSearchOrAddress;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @linkNeedsOtherApp.
  ///
  /// In en, this message translates to:
  /// **'This link needs another app and was not opened.'**
  String get linkNeedsOtherApp;

  /// No description provided for @tabs.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get tabs;

  /// No description provided for @tabsOpen.
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String tabsOpen(int count);

  /// No description provided for @tabsOpenInGroup.
  ///
  /// In en, this message translates to:
  /// **'{count} open · Group “{group}”'**
  String tabsOpenInGroup(int count, String group);

  /// No description provided for @newTab.
  ///
  /// In en, this message translates to:
  /// **'New tab'**
  String get newTab;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @closeTab.
  ///
  /// In en, this message translates to:
  /// **'Close tab'**
  String get closeTab;

  /// No description provided for @privateMode.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateMode;

  /// No description provided for @tabsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tab} other{{count} tabs}}'**
  String tabsCount(int count);

  /// No description provided for @privateTabsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No private tabs} =1{1 private tab} other{{count} private tabs}}'**
  String privateTabsCount(int count);

  /// No description provided for @startPage.
  ///
  /// In en, this message translates to:
  /// **'Start page'**
  String get startPage;

  /// No description provided for @closeAllTabs.
  ///
  /// In en, this message translates to:
  /// **'Close all'**
  String get closeAllTabs;

  /// No description provided for @closeAllTabsTitle.
  ///
  /// In en, this message translates to:
  /// **'Close all tabs?'**
  String get closeAllTabsTitle;

  /// No description provided for @tabClosed.
  ///
  /// In en, this message translates to:
  /// **'Tab closed'**
  String get tabClosed;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @topHit.
  ///
  /// In en, this message translates to:
  /// **'Top hit'**
  String get topHit;

  /// No description provided for @suggestionsFrom.
  ///
  /// In en, this message translates to:
  /// **'Search suggestions · {engine}'**
  String suggestionsFrom(String engine);

  /// No description provided for @fromYourLibrary.
  ///
  /// In en, this message translates to:
  /// **'From your library'**
  String get fromYourLibrary;

  /// No description provided for @quickSearch.
  ///
  /// In en, this message translates to:
  /// **'Quick search'**
  String get quickSearch;

  /// No description provided for @quickImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get quickImages;

  /// No description provided for @quickMaps.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get quickMaps;

  /// No description provided for @quickNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get quickNews;

  /// No description provided for @quickWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get quickWeather;

  /// No description provided for @weatherWord.
  ///
  /// In en, this message translates to:
  /// **'weather'**
  String get weatherWord;

  /// No description provided for @clearInput.
  ///
  /// In en, this message translates to:
  /// **'Clear input'**
  String get clearInput;

  /// No description provided for @suggestionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get suggestionSearch;

  /// No description provided for @suggestionHistory.
  ///
  /// In en, this message translates to:
  /// **'History · {when}'**
  String suggestionHistory(String when);

  /// No description provided for @suggestionBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark · {folder}'**
  String suggestionBookmark(String folder);

  /// No description provided for @suggestionReading.
  ///
  /// In en, this message translates to:
  /// **'{host} · in your reading list'**
  String suggestionReading(String host);

  /// No description provided for @suggestionVisited.
  ///
  /// In en, this message translates to:
  /// **'{host} · visited {count, plural, =1{once} other{{count} times}}'**
  String suggestionVisited(String host, int count);

  /// No description provided for @switchToTab.
  ///
  /// In en, this message translates to:
  /// **'Switch to tab'**
  String get switchToTab;

  /// No description provided for @openAddress.
  ///
  /// In en, this message translates to:
  /// **'Open {address}'**
  String openAddress(String address);

  /// No description provided for @insertSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Take into the field'**
  String get insertSuggestion;

  /// No description provided for @closeMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get closeMenu;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @connectionSecure.
  ///
  /// In en, this message translates to:
  /// **'Connection secure'**
  String get connectionSecure;

  /// No description provided for @connectionInsecure.
  ///
  /// In en, this message translates to:
  /// **'Not secure'**
  String get connectionInsecure;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBookmark;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @addToReadingList.
  ///
  /// In en, this message translates to:
  /// **'Reading list'**
  String get addToReadingList;

  /// No description provided for @findInPage.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get findInPage;

  /// No description provided for @readerView.
  ///
  /// In en, this message translates to:
  /// **'Reader view'**
  String get readerView;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @smaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller'**
  String get smaller;

  /// No description provided for @bigger.
  ///
  /// In en, this message translates to:
  /// **'Bigger'**
  String get bigger;

  /// No description provided for @desktopSite.
  ///
  /// In en, this message translates to:
  /// **'Request desktop site'**
  String get desktopSite;

  /// No description provided for @mobileSite.
  ///
  /// In en, this message translates to:
  /// **'Request mobile site'**
  String get mobileSite;

  /// No description provided for @addToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add to home screen'**
  String get addToHomeScreen;

  /// No description provided for @tabsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Tabs ({count})'**
  String tabsWithCount(int count);

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @privateTab.
  ///
  /// In en, this message translates to:
  /// **'Private tab'**
  String get privateTab;

  /// No description provided for @bookmarkAdded.
  ///
  /// In en, this message translates to:
  /// **'Saved to {folder}'**
  String bookmarkAdded(String folder);

  /// No description provided for @bookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get bookmarkRemoved;

  /// No description provided for @readingAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to the reading list'**
  String get readingAdded;

  /// No description provided for @readingAddedOffline.
  ///
  /// In en, this message translates to:
  /// **'Added to the reading list, available offline'**
  String get readingAddedOffline;

  /// No description provided for @noArticle.
  ///
  /// In en, this message translates to:
  /// **'No reader view for this page'**
  String get noArticle;

  /// No description provided for @pinUnsupported.
  ///
  /// In en, this message translates to:
  /// **'The home screen does not take shortcuts'**
  String get pinUnsupported;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Save in folder'**
  String get chooseFolder;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get folderName;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get deleteFolder;

  /// No description provided for @deleteFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteFolderTitle(String name);

  /// No description provided for @deleteFolderBody.
  ///
  /// In en, this message translates to:
  /// **'The folder and its bookmarks are deleted.'**
  String get deleteFolderBody;

  /// No description provided for @findPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Find on page'**
  String get findPlaceholder;

  /// No description provided for @findCount.
  ///
  /// In en, this message translates to:
  /// **'{active} of {count}'**
  String findCount(int active, int count);

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @previousMatch.
  ///
  /// In en, this message translates to:
  /// **'Previous match'**
  String get previousMatch;

  /// No description provided for @nextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get nextMatch;

  /// No description provided for @closeFind.
  ///
  /// In en, this message translates to:
  /// **'Close find'**
  String get closeFind;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get searchHistory;

  /// No description provided for @searchBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Search bookmarks'**
  String get searchBookmarks;

  /// No description provided for @searchReadingList.
  ///
  /// In en, this message translates to:
  /// **'Search reading list'**
  String get searchReadingList;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history …'**
  String get clearHistory;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Every visited page on this device is deleted. Bookmarks and the reading list stay.'**
  String get clearHistoryBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @bookmarkCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bookmark} other{{count} bookmarks}}'**
  String bookmarkCount(int count);

  /// No description provided for @readingUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get readingUnread;

  /// No description provided for @readingStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get readingStarted;

  /// No description provided for @readingHalf.
  ///
  /// In en, this message translates to:
  /// **'Half read'**
  String get readingHalf;

  /// No description provided for @readingAlmost.
  ///
  /// In en, this message translates to:
  /// **'Almost done'**
  String get readingAlmost;

  /// No description provided for @readingOffline.
  ///
  /// In en, this message translates to:
  /// **'Available offline'**
  String get readingOffline;

  /// No description provided for @emptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get emptyHistory;

  /// No description provided for @emptyHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Pages you visit show up here, grouped by day.'**
  String get emptyHistoryHint;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks in this folder'**
  String get emptyFolder;

  /// No description provided for @emptyFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Tap “Save” in the menu of a page.'**
  String get emptyFolderHint;

  /// No description provided for @emptyReading.
  ///
  /// In en, this message translates to:
  /// **'Your reading list is empty'**
  String get emptyReading;

  /// No description provided for @emptyReadingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap “Reading list” in the menu to keep a page for later, offline too.'**
  String get emptyReadingHint;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// No description provided for @savedInDownload.
  ///
  /// In en, this message translates to:
  /// **'Saved in “Download”'**
  String get savedInDownload;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'About {time} left'**
  String timeRemaining(String time);

  /// No description provided for @filesToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No files today} =1{1 file today} other{{count} files today}}'**
  String filesToday(int count);

  /// No description provided for @includingRunning.
  ///
  /// In en, this message translates to:
  /// **'Including the running download.'**
  String get includingRunning;

  /// No description provided for @nothingRunning.
  ///
  /// In en, this message translates to:
  /// **'Nothing running'**
  String get nothingRunning;

  /// No description provided for @allDone.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get allDone;

  /// No description provided for @pauseDownload.
  ///
  /// In en, this message translates to:
  /// **'Pause download'**
  String get pauseDownload;

  /// No description provided for @resumeDownload.
  ///
  /// In en, this message translates to:
  /// **'Resume download'**
  String get resumeDownload;

  /// No description provided for @cancelDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get cancelDownload;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openFile;

  /// No description provided for @clearList.
  ///
  /// In en, this message translates to:
  /// **'Clear list'**
  String get clearList;

  /// No description provided for @noDownloads.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloads;

  /// No description provided for @noDownloadsHint.
  ///
  /// In en, this message translates to:
  /// **'Files you download land in the “Download” folder.'**
  String get noDownloadsHint;

  /// No description provided for @sizeOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String sizeOf(String done, String total);

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get downloadFailed;

  /// No description provided for @downloadCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get downloadCanceled;

  /// No description provided for @downloadPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get downloadPaused;

  /// No description provided for @downloadWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting …'**
  String get downloadWaiting;

  /// No description provided for @downloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Download started'**
  String get downloadStarted;

  /// No description provided for @downloadAsk.
  ///
  /// In en, this message translates to:
  /// **'Download this file?'**
  String get downloadAsk;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @privateDownloadWarning.
  ///
  /// In en, this message translates to:
  /// **'The file stays in “Download” after the private session.'**
  String get privateDownloadWarning;

  /// No description provided for @openFailed.
  ///
  /// In en, this message translates to:
  /// **'No app can open this file'**
  String get openFailed;

  /// No description provided for @unknownSize.
  ///
  /// In en, this message translates to:
  /// **'Size unknown'**
  String get unknownSize;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @privateTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse privately'**
  String get privateTitle;

  /// No description provided for @privateBody.
  ///
  /// In en, this message translates to:
  /// **'Horizont does not keep visited pages, searches or form data. Close the last private tab and everything is gone.'**
  String get privateBody;

  /// No description provided for @lockedWithFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Locked with fingerprint'**
  String get lockedWithFingerprint;

  /// No description provided for @whenLeavingApp.
  ///
  /// In en, this message translates to:
  /// **'When you leave the app'**
  String get whenLeavingApp;

  /// No description provided for @lockOff.
  ///
  /// In en, this message translates to:
  /// **'Not locked'**
  String get lockOff;

  /// No description provided for @lockOffSub.
  ///
  /// In en, this message translates to:
  /// **'Switch on in Privacy'**
  String get lockOffSub;

  /// No description provided for @strictTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracker blocking'**
  String get strictTracking;

  /// No description provided for @strictTrackingSub.
  ///
  /// In en, this message translates to:
  /// **'Known trackers are blocked, nothing is counted'**
  String get strictTrackingSub;

  /// No description provided for @leavePrivate.
  ///
  /// In en, this message translates to:
  /// **'Leave private mode'**
  String get leavePrivate;

  /// No description provided for @privateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Private tabs need a newer Android System WebView.'**
  String get privateUnavailable;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock private tabs'**
  String get unlockReason;

  /// No description provided for @privateLocked.
  ///
  /// In en, this message translates to:
  /// **'Private tabs are locked'**
  String get privateLocked;

  /// No description provided for @notStored.
  ///
  /// In en, this message translates to:
  /// **'Not stored'**
  String get notStored;

  /// No description provided for @designAndColour.
  ///
  /// In en, this message translates to:
  /// **'Design & colour'**
  String get designAndColour;

  /// No description provided for @designSummary.
  ///
  /// In en, this message translates to:
  /// **'{theme} · {colourway} · {layout}'**
  String designSummary(String theme, String colourway, String layout);

  /// No description provided for @designHint.
  ///
  /// In en, this message translates to:
  /// **'6 bar layouts, 6 colourways'**
  String get designHint;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @searchEngine.
  ///
  /// In en, this message translates to:
  /// **'Search engine'**
  String get searchEngine;

  /// No description provided for @startPageSections.
  ///
  /// In en, this message translates to:
  /// **'Favourites, frequent, reading list'**
  String get startPageSections;

  /// No description provided for @startPageNothing.
  ///
  /// In en, this message translates to:
  /// **'Only the search'**
  String get startPageNothing;

  /// No description provided for @groupTabs.
  ///
  /// In en, this message translates to:
  /// **'Group tabs'**
  String get groupTabs;

  /// No description provided for @groupTabsSub.
  ///
  /// In en, this message translates to:
  /// **'Tabs opened from a tab stay with it'**
  String get groupTabsSub;

  /// No description provided for @homeAfterAway.
  ///
  /// In en, this message translates to:
  /// **'Start page after time away'**
  String get homeAfterAway;

  /// No description provided for @homeAfterAwaySub.
  ///
  /// In en, this message translates to:
  /// **'Come back after longer than this and a new tab with the start page opens. The old tab stays open.'**
  String get homeAfterAwaySub;

  /// No description provided for @homeAfterHalfHour.
  ///
  /// In en, this message translates to:
  /// **'After 30 minutes'**
  String get homeAfterHalfHour;

  /// No description provided for @homeAfterHour.
  ///
  /// In en, this message translates to:
  /// **'After 1 hour'**
  String get homeAfterHour;

  /// No description provided for @homeAfterFourHours.
  ///
  /// In en, this message translates to:
  /// **'After 4 hours'**
  String get homeAfterFourHours;

  /// No description provided for @autoCloseTabs.
  ///
  /// In en, this message translates to:
  /// **'Close tabs automatically'**
  String get autoCloseTabs;

  /// No description provided for @autoCloseNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get autoCloseNever;

  /// No description provided for @autoCloseDay.
  ///
  /// In en, this message translates to:
  /// **'After 1 day'**
  String get autoCloseDay;

  /// No description provided for @autoCloseWeek.
  ///
  /// In en, this message translates to:
  /// **'After 1 week'**
  String get autoCloseWeek;

  /// No description provided for @autoCloseMonth.
  ///
  /// In en, this message translates to:
  /// **'After 1 month'**
  String get autoCloseMonth;

  /// No description provided for @autoCloseSub.
  ///
  /// In en, this message translates to:
  /// **'Tabs you have not looked at for that long close when Horizont starts.'**
  String get autoCloseSub;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get privacySecurity;

  /// No description provided for @trackingOn.
  ///
  /// In en, this message translates to:
  /// **'Tracking protection on'**
  String get trackingOn;

  /// No description provided for @trackingOff.
  ///
  /// In en, this message translates to:
  /// **'Tracking protection off'**
  String get trackingOff;

  /// No description provided for @httpsOnlyShort.
  ///
  /// In en, this message translates to:
  /// **'HTTPS only'**
  String get httpsOnlyShort;

  /// No description provided for @passwords.
  ///
  /// In en, this message translates to:
  /// **'Passwords & passkeys'**
  String get passwords;

  /// No description provided for @passwordsSub.
  ///
  /// In en, this message translates to:
  /// **'Google Password Manager'**
  String get passwordsSub;

  /// No description provided for @siteSettings.
  ///
  /// In en, this message translates to:
  /// **'Site settings'**
  String get siteSettings;

  /// No description provided for @siteSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Camera, microphone, location'**
  String get siteSettingsSub;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @askBeforeDownload.
  ///
  /// In en, this message translates to:
  /// **'Ask before saving'**
  String get askBeforeDownload;

  /// No description provided for @saveWithoutAsking.
  ///
  /// In en, this message translates to:
  /// **'Save without asking'**
  String get saveWithoutAsking;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @accessibilitySub.
  ///
  /// In en, this message translates to:
  /// **'Text size, force zoom'**
  String get accessibilitySub;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About Horizont'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @defaultBrowser.
  ///
  /// In en, this message translates to:
  /// **'Default browser'**
  String get defaultBrowser;

  /// No description provided for @defaultBrowserSub.
  ///
  /// In en, this message translates to:
  /// **'Open links from other apps in Horizont'**
  String get defaultBrowserSub;

  /// No description provided for @changesApplyNow.
  ///
  /// In en, this message translates to:
  /// **'Changes apply at once'**
  String get changesApplyNow;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @colourway.
  ///
  /// In en, this message translates to:
  /// **'Colourway'**
  String get colourway;

  /// No description provided for @barLayout.
  ///
  /// In en, this message translates to:
  /// **'Bar layout'**
  String get barLayout;

  /// No description provided for @bar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get bar;

  /// No description provided for @tintFromPage.
  ///
  /// In en, this message translates to:
  /// **'Take the site colour'**
  String get tintFromPage;

  /// No description provided for @tintFromPageSub.
  ///
  /// In en, this message translates to:
  /// **'Tint the status bar in the colour of the page header'**
  String get tintFromPageSub;

  /// No description provided for @statusBarBlur.
  ///
  /// In en, this message translates to:
  /// **'Status bar blur'**
  String get statusBarBlur;

  /// No description provided for @statusBarBlurSub.
  ///
  /// In en, this message translates to:
  /// **'How softly the colour fades out below the status bar'**
  String get statusBarBlurSub;

  /// No description provided for @blurOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get blurOff;

  /// No description provided for @blurSoft.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get blurSoft;

  /// No description provided for @blurStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get blurStrong;

  /// No description provided for @shrinkOnScroll.
  ///
  /// In en, this message translates to:
  /// **'Shrink while scrolling'**
  String get shrinkOnScroll;

  /// No description provided for @shrinkOnScrollSub.
  ///
  /// In en, this message translates to:
  /// **'Shows only the domain'**
  String get shrinkOnScrollSub;

  /// No description provided for @translucentBars.
  ///
  /// In en, this message translates to:
  /// **'Translucent'**
  String get translucentBars;

  /// No description provided for @translucentBarsSub.
  ///
  /// In en, this message translates to:
  /// **'Lets what lies beneath show through; blurred within the app'**
  String get translucentBarsSub;

  /// No description provided for @hideAtEnd.
  ///
  /// In en, this message translates to:
  /// **'Hide at the end of the page'**
  String get hideAtEnd;

  /// No description provided for @hideAtEndSub.
  ///
  /// In en, this message translates to:
  /// **'The bar goes away when you reach the bottom'**
  String get hideAtEndSub;

  /// No description provided for @layoutKompakt.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get layoutKompakt;

  /// No description provided for @layoutZweireihig.
  ///
  /// In en, this message translates to:
  /// **'Two rows'**
  String get layoutZweireihig;

  /// No description provided for @layoutExpressiv.
  ///
  /// In en, this message translates to:
  /// **'Expressive'**
  String get layoutExpressiv;

  /// No description provided for @layoutOben.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get layoutOben;

  /// No description provided for @layoutKarte.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get layoutKarte;

  /// No description provided for @layoutMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get layoutMinimal;

  /// No description provided for @engineSub.
  ///
  /// In en, this message translates to:
  /// **'For the address bar and quick search'**
  String get engineSub;

  /// No description provided for @engineGoogleSub.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get engineGoogleSub;

  /// No description provided for @engineEcosiaSub.
  ///
  /// In en, this message translates to:
  /// **'Plants trees with ad revenue'**
  String get engineEcosiaSub;

  /// No description provided for @engineDdgSub.
  ///
  /// In en, this message translates to:
  /// **'Without personalisation'**
  String get engineDdgSub;

  /// No description provided for @engineStartpageSub.
  ///
  /// In en, this message translates to:
  /// **'Google results, anonymised'**
  String get engineStartpageSub;

  /// No description provided for @engineBingSub.
  ///
  /// In en, this message translates to:
  /// **'Microsoft'**
  String get engineBingSub;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @searchSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Search suggestions'**
  String get searchSuggestions;

  /// No description provided for @searchSuggestionsSub.
  ///
  /// In en, this message translates to:
  /// **'What you type is sent to {engine}'**
  String searchSuggestionsSub(String engine);

  /// No description provided for @thisWeekSites.
  ///
  /// In en, this message translates to:
  /// **'This week · {count, plural, =1{1 site} other{{count} sites}}'**
  String thisWeekSites(int count);

  /// No description provided for @protection.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get protection;

  /// No description provided for @blockTracking.
  ///
  /// In en, this message translates to:
  /// **'Prevent cross-site tracking'**
  String get blockTracking;

  /// No description provided for @blockTrackingSub.
  ///
  /// In en, this message translates to:
  /// **'Ad networks do not follow you from site to site'**
  String get blockTrackingSub;

  /// No description provided for @httpsOnly.
  ///
  /// In en, this message translates to:
  /// **'HTTPS only'**
  String get httpsOnly;

  /// No description provided for @httpsOnlySub.
  ///
  /// In en, this message translates to:
  /// **'Insecure connections are reported first'**
  String get httpsOnlySub;

  /// No description provided for @fraudWarning.
  ///
  /// In en, this message translates to:
  /// **'Warn about fraudulent sites'**
  String get fraudWarning;

  /// No description provided for @fraudWarningSub.
  ///
  /// In en, this message translates to:
  /// **'Checks addresses against known phishing lists'**
  String get fraudWarningSub;

  /// No description provided for @lockPrivateTabs.
  ///
  /// In en, this message translates to:
  /// **'Lock private tabs'**
  String get lockPrivateTabs;

  /// No description provided for @lockPrivateTabsSub.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint'**
  String get lockPrivateTabsSub;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear history and site data'**
  String get clearData;

  /// No description provided for @clearDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history and site data?'**
  String get clearDataTitle;

  /// No description provided for @clearDataBody.
  ///
  /// In en, this message translates to:
  /// **'Visited pages, cookies, logins on sites, the cache and site permissions are deleted. Bookmarks, the reading list and downloads stay.'**
  String get clearDataBody;

  /// No description provided for @cleared.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get cleared;

  /// No description provided for @showOnStartPage.
  ///
  /// In en, this message translates to:
  /// **'Show on the start page'**
  String get showOnStartPage;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get allowed;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @noSitePermissions.
  ///
  /// In en, this message translates to:
  /// **'No site has asked yet'**
  String get noSitePermissions;

  /// No description provided for @noSitePermissionsHint.
  ///
  /// In en, this message translates to:
  /// **'When a site asks for camera, microphone or location, your answer is kept here.'**
  String get noSitePermissionsHint;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get resetAll;

  /// No description provided for @forceZoom.
  ///
  /// In en, this message translates to:
  /// **'Force zoom'**
  String get forceZoom;

  /// No description provided for @forceZoomSub.
  ///
  /// In en, this message translates to:
  /// **'Zoom pages that forbid it'**
  String get forceZoomSub;

  /// No description provided for @textSizePerSite.
  ///
  /// In en, this message translates to:
  /// **'Text size per site'**
  String get textSizePerSite;

  /// No description provided for @textSizePerSiteHint.
  ///
  /// In en, this message translates to:
  /// **'Set in the menu of a page; kept for its site.'**
  String get textSizePerSiteHint;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'A browser for Android in Toms Expressive Design. Pages are shown by Android System WebView.'**
  String get aboutBody;

  /// No description provided for @licences.
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get licences;

  /// No description provided for @licencesSub.
  ///
  /// In en, this message translates to:
  /// **'Readability, EasyPrivacy, Google Sans Flex and the packages'**
  String get licencesSub;

  /// No description provided for @bundledData.
  ///
  /// In en, this message translates to:
  /// **'Bundled data'**
  String get bundledData;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'{host} cannot be reached right now. Check the connection and try again.'**
  String offlineBody(String host);

  /// No description provided for @certificateTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection not secure'**
  String get certificateTitle;

  /// No description provided for @certificateBody.
  ///
  /// In en, this message translates to:
  /// **'The certificate of {host} is not valid, so Horizont did not load the page.'**
  String certificateBody(String host);

  /// No description provided for @insecureTitle.
  ///
  /// In en, this message translates to:
  /// **'No HTTPS'**
  String get insecureTitle;

  /// No description provided for @insecureBody.
  ///
  /// In en, this message translates to:
  /// **'{host} offers no secure connection. What you send could be read on the way.'**
  String insecureBody(String host);

  /// No description provided for @continueInsecure.
  ///
  /// In en, this message translates to:
  /// **'Open over HTTP anyway'**
  String get continueInsecure;

  /// No description provided for @failedTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not loaded'**
  String get failedTitle;

  /// No description provided for @failedBody.
  ///
  /// In en, this message translates to:
  /// **'{host} could not be shown.'**
  String failedBody(String host);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @pageCrashed.
  ///
  /// In en, this message translates to:
  /// **'The page stopped and was loaded again.'**
  String get pageCrashed;

  /// No description provided for @pageSays.
  ///
  /// In en, this message translates to:
  /// **'{host} says'**
  String pageSays(String host);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @signInTo.
  ///
  /// In en, this message translates to:
  /// **'Sign in to {host}'**
  String signInTo(String host);

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @permissionAsk.
  ///
  /// In en, this message translates to:
  /// **'{host} wants to use {what}'**
  String permissionAsk(String host, String what);

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @dontAllow.
  ///
  /// In en, this message translates to:
  /// **'Don’t allow'**
  String get dontAllow;

  /// No description provided for @openInOtherApp.
  ///
  /// In en, this message translates to:
  /// **'Open in another app?'**
  String get openInOtherApp;

  /// No description provided for @openInOtherAppBody.
  ///
  /// In en, this message translates to:
  /// **'The page wants to open {target}.'**
  String openInOtherAppBody(String target);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @noAppForLink.
  ///
  /// In en, this message translates to:
  /// **'No app can open this link'**
  String get noAppForLink;

  /// No description provided for @chooseFiles.
  ///
  /// In en, this message translates to:
  /// **'Choose files'**
  String get chooseFiles;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @startNav.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startNav;

  /// No description provided for @secureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{title} · secure'**
  String secureSubtitle(String title);

  /// No description provided for @insecureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{title} · not secure'**
  String insecureSubtitle(String title);

  /// No description provided for @voiceSearch.
  ///
  /// In en, this message translates to:
  /// **'Voice search'**
  String get voiceSearch;

  /// No description provided for @showBar.
  ///
  /// In en, this message translates to:
  /// **'Show the bar'**
  String get showBar;

  /// No description provided for @swipeForTabs.
  ///
  /// In en, this message translates to:
  /// **'Swipe for the next tab'**
  String get swipeForTabs;

  /// No description provided for @scrollToTop.
  ///
  /// In en, this message translates to:
  /// **'Status bar, tap to scroll to the top'**
  String get scrollToTop;

  /// No description provided for @tabPosition.
  ///
  /// In en, this message translates to:
  /// **'{title}, tab {index} of {count}'**
  String tabPosition(String title, int index, int count);

  /// No description provided for @activeTab.
  ///
  /// In en, this message translates to:
  /// **'in front'**
  String get activeTab;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @hapticsSub.
  ///
  /// In en, this message translates to:
  /// **'How clearly Horizont vibrates when you tap and swipe. The system\'s vibration setting still applies.'**
  String get hapticsSub;

  /// No description provided for @hapticsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get hapticsOff;

  /// No description provided for @hapticsNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get hapticsNormal;

  /// No description provided for @hapticsStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get hapticsStrong;

  /// No description provided for @liftOverPageBars.
  ///
  /// In en, this message translates to:
  /// **'Move above page bars'**
  String get liftOverPageBars;

  /// No description provided for @liftOverPageBarsSub.
  ///
  /// In en, this message translates to:
  /// **'When a page has its own bar at the bottom (Instagram, X), the bar moves above it'**
  String get liftOverPageBarsSub;

  /// No description provided for @barRaise.
  ///
  /// In en, this message translates to:
  /// **'Bar height'**
  String get barRaise;

  /// No description provided for @barRaiseSub.
  ///
  /// In en, this message translates to:
  /// **'How far the bottom bar sits above its usual place'**
  String get barRaiseSub;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
