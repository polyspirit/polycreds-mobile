import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
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
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

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
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backTo.
  ///
  /// In en, this message translates to:
  /// **'Back: {label}'**
  String backTo(Object label);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @erase.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get erase;

  /// No description provided for @digitsEntered.
  ///
  /// In en, this message translates to:
  /// **'Digits entered: {count}'**
  String digitsEntered(int count);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @noGroup.
  ///
  /// In en, this message translates to:
  /// **'No group'**
  String get noGroup;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @errTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server is not responding. Check your connection.'**
  String get errTimeout;

  /// No description provided for @errCertificate.
  ///
  /// In en, this message translates to:
  /// **'Invalid server certificate.'**
  String get errCertificate;

  /// No description provided for @errNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server.'**
  String get errNoConnection;

  /// No description provided for @err401.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Sign in again.'**
  String get err401;

  /// No description provided for @err403.
  ///
  /// In en, this message translates to:
  /// **'Not enough permissions.'**
  String get err403;

  /// No description provided for @err404.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get err404;

  /// No description provided for @err429.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a bit.'**
  String get err429;

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'Server error ({code}).'**
  String errServer(Object code);

  /// No description provided for @errNotPolyCreds.
  ///
  /// In en, this message translates to:
  /// **'No PolyCreds server found at this address.'**
  String get errNotPolyCreds;

  /// No description provided for @errLoginExpired.
  ///
  /// In en, this message translates to:
  /// **'Sign-in session expired. Sign in again.'**
  String get errLoginExpired;

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{n} s'**
  String durationSeconds(int n);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String durationMinutes(int n);

  /// No description provided for @afterDuration.
  ///
  /// In en, this message translates to:
  /// **'After {duration}'**
  String afterDuration(Object duration);

  /// No description provided for @immediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediately;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @clipboardWillClear.
  ///
  /// In en, this message translates to:
  /// **'Clipboard will be cleared in {duration}'**
  String clipboardWillClear(Object duration);

  /// No description provided for @copiedPassword.
  ///
  /// In en, this message translates to:
  /// **'Password copied'**
  String get copiedPassword;

  /// No description provided for @copiedLogin.
  ///
  /// In en, this message translates to:
  /// **'Login copied'**
  String get copiedLogin;

  /// No description provided for @copiedHost.
  ///
  /// In en, this message translates to:
  /// **'Host copied'**
  String get copiedHost;

  /// No description provided for @copiedCommand.
  ///
  /// In en, this message translates to:
  /// **'Command copied'**
  String get copiedCommand;

  /// No description provided for @copiedText.
  ///
  /// In en, this message translates to:
  /// **'Text copied'**
  String get copiedText;

  /// No description provided for @credentialsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} credential} other{{count} credentials}}'**
  String credentialsCount(int count);

  /// No description provided for @notesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} note} other{{count} notes}}'**
  String notesCount(int count);

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get activeNow;

  /// No description provided for @neverUsed.
  ///
  /// In en, this message translates to:
  /// **'Not used yet'**
  String get neverUsed;

  /// No description provided for @activeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Active {n} minute ago} other{Active {n} minutes ago}}'**
  String activeMinutesAgo(int n);

  /// No description provided for @activeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Active {n} hour ago} other{Active {n} hours ago}}'**
  String activeHoursAgo(int n);

  /// No description provided for @activeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Active {n} day ago} other{Active {n} days ago}}'**
  String activeDaysAgo(int n);

  /// No description provided for @activeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Active {n} week ago} other{Active {n} weeks ago}}'**
  String activeWeeksAgo(int n);

  /// No description provided for @activeOn.
  ///
  /// In en, this message translates to:
  /// **'Active {date}'**
  String activeOn(Object date);

  /// No description provided for @setDigits.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get setDigits;

  /// No description provided for @setLower.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters'**
  String get setLower;

  /// No description provided for @setUpper.
  ///
  /// In en, this message translates to:
  /// **'Uppercase letters'**
  String get setUpper;

  /// No description provided for @setSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get setSymbols;

  /// No description provided for @setExtended.
  ///
  /// In en, this message translates to:
  /// **'Extended symbols'**
  String get setExtended;

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get strengthFair;

  /// No description provided for @strengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get strengthGood;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthStrong;

  /// No description provided for @strengthVeryStrong.
  ///
  /// In en, this message translates to:
  /// **'Very strong'**
  String get strengthVeryStrong;

  /// No description provided for @strengthBits.
  ///
  /// In en, this message translates to:
  /// **'{label} · ~{bits} bits'**
  String strengthBits(Object label, int bits);

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your passwords, server credentials and notes. Everything is encrypted on the server you choose.'**
  String get appTagline;

  /// No description provided for @serverSection.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverSection;

  /// No description provided for @cloudDefault.
  ///
  /// In en, this message translates to:
  /// **'PolyCreds cloud · default'**
  String get cloudDefault;

  /// No description provided for @ownServer.
  ///
  /// In en, this message translates to:
  /// **'Own server'**
  String get ownServer;

  /// No description provided for @selfHosted.
  ///
  /// In en, this message translates to:
  /// **'Self-hosted PolyCreds'**
  String get selfHosted;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverAddress;

  /// No description provided for @enterServer.
  ///
  /// In en, this message translates to:
  /// **'Enter the server address'**
  String get enterServer;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @serverChangeLater.
  ///
  /// In en, this message translates to:
  /// **'You can change the address later in settings'**
  String get serverChangeLater;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your e-mail'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

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

  /// No description provided for @loginFooter.
  ///
  /// In en, this message translates to:
  /// **'Sign-up and password reset are in the PolyCreds web version'**
  String get loginFooter;

  /// No description provided for @enter6Digits.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digits from the e-mail'**
  String get enter6Digits;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'Code sent again'**
  String get codeResent;

  /// No description provided for @codeTitle.
  ///
  /// In en, this message translates to:
  /// **'Code from e-mail'**
  String get codeTitle;

  /// No description provided for @codeSentPrefix.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to '**
  String get codeSentPrefix;

  /// No description provided for @codeSentSuffix.
  ///
  /// In en, this message translates to:
  /// **'. Enter it to confirm sign-in.'**
  String get codeSentSuffix;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in '**
  String get resendIn;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @codeFooter.
  ///
  /// In en, this message translates to:
  /// **'No e-mail? Check the Spam folder. You can resend up to 3 times a minute.'**
  String get codeFooter;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again'**
  String get pinMismatch;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 2'**
  String stepOf(int step);

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN'**
  String get createPin;

  /// No description provided for @repeatPin.
  ///
  /// In en, this message translates to:
  /// **'Repeat the PIN'**
  String get repeatPin;

  /// No description provided for @pinCreateHint.
  ///
  /// In en, this message translates to:
  /// **'It unlocks the app on this device. You won\'t need your account password.'**
  String get pinCreateHint;

  /// No description provided for @pinRepeatHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the same PIN again.'**
  String get pinRepeatHint;

  /// No description provided for @pinDigitsHint.
  ///
  /// In en, this message translates to:
  /// **'4 to 6 digits'**
  String get pinDigitsHint;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Attempts left: {n}'**
  String wrongPin(int n);

  /// No description provided for @signInWithPassword.
  ///
  /// In en, this message translates to:
  /// **'Sign in with password'**
  String get signInWithPassword;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @tabVault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get tabVault;

  /// No description provided for @tabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tabNotes;

  /// No description provided for @tabGenerator.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get tabGenerator;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @searchVaultHint.
  ///
  /// In en, this message translates to:
  /// **'Search credentials and notes'**
  String get searchVaultHint;

  /// No description provided for @allCount.
  ///
  /// In en, this message translates to:
  /// **'All · {n}'**
  String allCount(int n);

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @sites.
  ///
  /// In en, this message translates to:
  /// **'Websites'**
  String get sites;

  /// No description provided for @servers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get servers;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @newCredential.
  ///
  /// In en, this message translates to:
  /// **'New credential'**
  String get newCredential;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @favoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Star credentials to keep them at hand'**
  String get favoritesHint;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyTitle;

  /// No description provided for @emptyText.
  ///
  /// In en, this message translates to:
  /// **'Add your first credential: a login and password for a website or server. Groups help keep things tidy.'**
  String get emptyText;

  /// No description provided for @addCredential.
  ///
  /// In en, this message translates to:
  /// **'Add credential'**
  String get addCredential;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @copyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get copyPassword;

  /// No description provided for @copyLogin.
  ///
  /// In en, this message translates to:
  /// **'Copy login'**
  String get copyLogin;

  /// No description provided for @copyHost.
  ///
  /// In en, this message translates to:
  /// **'Copy host'**
  String get copyHost;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// No description provided for @newCredentialInGroup.
  ///
  /// In en, this message translates to:
  /// **'New credential in group'**
  String get newCredentialInGroup;

  /// No description provided for @byName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get byName;

  /// No description provided for @byDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get byDate;

  /// No description provided for @groupNoCredentials.
  ///
  /// In en, this message translates to:
  /// **'No credentials in this group yet'**
  String get groupNoCredentials;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteItemTitle(Object name);

  /// No description provided for @deleteCredentialText.
  ///
  /// In en, this message translates to:
  /// **'The login, password and note will be deleted permanently.'**
  String get deleteCredentialText;

  /// No description provided for @connectionCommand.
  ///
  /// In en, this message translates to:
  /// **'Connection command'**
  String get connectionCommand;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @modifiedOn.
  ///
  /// In en, this message translates to:
  /// **'Modified {date}'**
  String modifiedOn(Object date);

  /// No description provided for @deleteCredential.
  ///
  /// In en, this message translates to:
  /// **'Delete credential'**
  String get deleteCredential;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLink;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocol;

  /// No description provided for @cantOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get cantOpenLink;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// No description provided for @enterLogin.
  ///
  /// In en, this message translates to:
  /// **'Enter a login'**
  String get enterLogin;

  /// No description provided for @enterHost.
  ///
  /// In en, this message translates to:
  /// **'Enter a host'**
  String get enterHost;

  /// No description provided for @portRange.
  ///
  /// In en, this message translates to:
  /// **'Port from 1 to 65535'**
  String get portRange;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @editCredential.
  ///
  /// In en, this message translates to:
  /// **'Edit credential'**
  String get editCredential;

  /// No description provided for @siteTab.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get siteTab;

  /// No description provided for @serverTab.
  ///
  /// In en, this message translates to:
  /// **'Server · SSH/FTP'**
  String get serverTab;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @generatePassword.
  ///
  /// In en, this message translates to:
  /// **'Generate password'**
  String get generatePassword;

  /// No description provided for @credentialNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Backup codes, hints, anything else'**
  String get credentialNoteHint;

  /// No description provided for @deleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete group “{name}”?'**
  String deleteGroupTitle(Object name);

  /// No description provided for @deleteEmptyGroupText.
  ///
  /// In en, this message translates to:
  /// **'The group is empty. This cannot be undone.'**
  String get deleteEmptyGroupText;

  /// No description provided for @deleteGroupText.
  ///
  /// In en, this message translates to:
  /// **'{items} will be deleted with the group. They cannot be restored.'**
  String deleteGroupText(Object items);

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get deleteGroup;

  /// No description provided for @groupTitle.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupTitle;

  /// No description provided for @whatStored.
  ///
  /// In en, this message translates to:
  /// **'What the group holds'**
  String get whatStored;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// No description provided for @credentialsDesc.
  ///
  /// In en, this message translates to:
  /// **'Logins and passwords for websites and servers'**
  String get credentialsDesc;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesDesc.
  ///
  /// In en, this message translates to:
  /// **'Formatted text'**
  String get notesDesc;

  /// No description provided for @groupContains.
  ///
  /// In en, this message translates to:
  /// **'The group has {items}. '**
  String groupContains(Object items);

  /// No description provided for @groupTypeHint.
  ///
  /// In en, this message translates to:
  /// **'The group type decides where it is shown: on the “Vault” or “Notes” tab.'**
  String get groupTypeHint;

  /// No description provided for @credentialsN.
  ///
  /// In en, this message translates to:
  /// **'Credentials · {n}'**
  String credentialsN(int n);

  /// No description provided for @notesN.
  ///
  /// In en, this message translates to:
  /// **'Notes · {n}'**
  String notesN(int n);

  /// No description provided for @groupsN.
  ///
  /// In en, this message translates to:
  /// **'Groups · {n}'**
  String groupsN(int n);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by credential, note and group names'**
  String get searchHint;

  /// No description provided for @generatedPassword.
  ///
  /// In en, this message translates to:
  /// **'Generated password'**
  String get generatedPassword;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @newNoteGroup.
  ///
  /// In en, this message translates to:
  /// **'New note group'**
  String get newNoteGroup;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotes;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchNotesHint;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get copyText;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNote;

  /// No description provided for @deleteNoteText.
  ///
  /// In en, this message translates to:
  /// **'The note will be deleted permanently.'**
  String get deleteNoteText;

  /// No description provided for @noteModifiedOn.
  ///
  /// In en, this message translates to:
  /// **'modified {date}'**
  String noteModifiedOn(Object date);

  /// No description provided for @emptyNote.
  ///
  /// In en, this message translates to:
  /// **'Empty note'**
  String get emptyNote;

  /// No description provided for @enterNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a note title'**
  String get enterNoteTitle;

  /// No description provided for @noteBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Note text'**
  String get noteBodyHint;

  /// No description provided for @removeLink.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLink;

  /// No description provided for @fmtBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get fmtBold;

  /// No description provided for @fmtItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get fmtItalic;

  /// No description provided for @fmtUnderline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get fmtUnderline;

  /// No description provided for @fmtHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get fmtHeading;

  /// No description provided for @fmtBulletList.
  ///
  /// In en, this message translates to:
  /// **'Bulleted list'**
  String get fmtBulletList;

  /// No description provided for @fmtNumberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered list'**
  String get fmtNumberedList;

  /// No description provided for @fmtCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get fmtCode;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutTitle;

  /// No description provided for @logoutText.
  ///
  /// In en, this message translates to:
  /// **'The PIN on this device will be reset. To sign in you will need your password and a code from e-mail.'**
  String get logoutText;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get personalData;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security and settings'**
  String get securitySettings;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @openWeb.
  ///
  /// In en, this message translates to:
  /// **'Open web version'**
  String get openWeb;

  /// No description provided for @min2Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 2 characters'**
  String get min2Chars;

  /// No description provided for @min6Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get min6Chars;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @dataSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get dataSaved;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get userName;

  /// No description provided for @emailHelper.
  ///
  /// In en, this message translates to:
  /// **'Sign-in codes are sent to this address'**
  String get emailHelper;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @currentPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'Required to change e-mail or password'**
  String get currentPasswordHelper;

  /// No description provided for @changeServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Change server?'**
  String get changeServerTitle;

  /// No description provided for @changeServerText.
  ///
  /// In en, this message translates to:
  /// **'The current session on this device will end. Then choose a server and sign in again.'**
  String get changeServerText;

  /// No description provided for @changeServer.
  ///
  /// In en, this message translates to:
  /// **'Change server'**
  String get changeServer;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @autoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get autoLock;

  /// No description provided for @clipboardClear.
  ///
  /// In en, this message translates to:
  /// **'Clear clipboard'**
  String get clipboardClear;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @serverChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Changing the server ends the current session on this device.'**
  String get serverChangeNote;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Same as system'**
  String get languageSystem;

  /// No description provided for @languageNow.
  ///
  /// In en, this message translates to:
  /// **'Now: {language}'**
  String languageNow(Object language);

  /// No description provided for @languageRussianInline.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussianInline;

  /// No description provided for @languageEnglishInline.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishInline;

  /// No description provided for @languageRussianOther.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussianOther;

  /// No description provided for @languageEnglishOther.
  ///
  /// In en, this message translates to:
  /// **'Английский'**
  String get languageEnglishOther;

  /// No description provided for @languageNote.
  ///
  /// In en, this message translates to:
  /// **'The language changes right away, no restart needed. Vault entries are not translated.'**
  String get languageNote;

  /// No description provided for @languageGroup.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get languageGroup;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'AUTO'**
  String get auto;

  /// No description provided for @terminateOthersTitle.
  ///
  /// In en, this message translates to:
  /// **'End other sessions?'**
  String get terminateOthersTitle;

  /// No description provided for @terminateOthersText.
  ///
  /// In en, this message translates to:
  /// **'Ended devices will need to sign in again with a code from e-mail.'**
  String get terminateOthersText;

  /// No description provided for @terminate.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get terminate;

  /// No description provided for @terminatedN.
  ///
  /// In en, this message translates to:
  /// **'Sessions ended: {n}'**
  String terminatedN(int n);

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @otherSessions.
  ///
  /// In en, this message translates to:
  /// **'Other sessions · {n}'**
  String otherSessions(int n);

  /// No description provided for @noOtherSessions.
  ///
  /// In en, this message translates to:
  /// **'No other active sessions'**
  String get noOtherSessions;

  /// No description provided for @terminateAll.
  ///
  /// In en, this message translates to:
  /// **'End all other sessions'**
  String get terminateAll;

  /// No description provided for @signedInOn.
  ///
  /// In en, this message translates to:
  /// **'Signed in {date}'**
  String signedInOn(Object date);

  /// No description provided for @createdModified.
  ///
  /// In en, this message translates to:
  /// **'Created {created} · modified {modified}'**
  String createdModified(Object created, Object modified);
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'ru':
      return L10nRu();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
