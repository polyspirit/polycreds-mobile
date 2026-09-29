// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get clear => 'Clear';

  @override
  String get back => 'Back';

  @override
  String backTo(Object label) {
    return 'Back: $label';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get erase => 'Delete';

  @override
  String digitsEntered(int count) {
    return 'Digits entered: $count';
  }

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get change => 'Change';

  @override
  String get copy => 'Copy';

  @override
  String get next => 'Next';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get noGroup => 'No group';

  @override
  String get search => 'Search';

  @override
  String get errTimeout =>
      'The server is not responding. Check your connection.';

  @override
  String get errCertificate => 'Invalid server certificate.';

  @override
  String get errNoConnection => 'No connection to the server.';

  @override
  String get err401 => 'Session expired. Sign in again.';

  @override
  String get err403 => 'Not enough permissions.';

  @override
  String get err404 => 'Not found.';

  @override
  String get err429 => 'Too many attempts. Please wait a bit.';

  @override
  String errServer(Object code) {
    return 'Server error ($code).';
  }

  @override
  String get errNotPolyCreds => 'No PolyCreds server found at this address.';

  @override
  String get errLoginExpired => 'Sign-in session expired. Sign in again.';

  @override
  String durationSeconds(int n) {
    return '$n s';
  }

  @override
  String durationMinutes(int n) {
    return '$n min';
  }

  @override
  String afterDuration(Object duration) {
    return 'After $duration';
  }

  @override
  String get immediately => 'Immediately';

  @override
  String get never => 'Never';

  @override
  String clipboardWillClear(Object duration) {
    return 'Clipboard will be cleared in $duration';
  }

  @override
  String get copiedPassword => 'Password copied';

  @override
  String get copiedLogin => 'Login copied';

  @override
  String get copiedHost => 'Host copied';

  @override
  String get copiedCommand => 'Command copied';

  @override
  String get copiedText => 'Text copied';

  @override
  String credentialsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credentials',
      one: '$count credential',
    );
    return '$_temp0';
  }

  @override
  String notesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '$count note',
    );
    return '$_temp0';
  }

  @override
  String get activeNow => 'Active now';

  @override
  String get neverUsed => 'Not used yet';

  @override
  String activeMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Active $n minutes ago',
      one: 'Active $n minute ago',
    );
    return '$_temp0';
  }

  @override
  String activeHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Active $n hours ago',
      one: 'Active $n hour ago',
    );
    return '$_temp0';
  }

  @override
  String activeDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Active $n days ago',
      one: 'Active $n day ago',
    );
    return '$_temp0';
  }

  @override
  String activeWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Active $n weeks ago',
      one: 'Active $n week ago',
    );
    return '$_temp0';
  }

  @override
  String activeOn(Object date) {
    return 'Active $date';
  }

  @override
  String get setDigits => 'Digits';

  @override
  String get setLower => 'Lowercase letters';

  @override
  String get setUpper => 'Uppercase letters';

  @override
  String get setSymbols => 'Symbols';

  @override
  String get setExtended => 'Extended symbols';

  @override
  String get strengthWeak => 'Weak';

  @override
  String get strengthFair => 'Fair';

  @override
  String get strengthGood => 'Good';

  @override
  String get strengthStrong => 'Strong';

  @override
  String get strengthVeryStrong => 'Very strong';

  @override
  String strengthBits(Object label, int bits) {
    return '$label · ~$bits bits';
  }

  @override
  String get appTagline =>
      'Your passwords, server credentials and notes. Everything is encrypted on the server you choose.';

  @override
  String get serverSection => 'Server';

  @override
  String get cloudDefault => 'PolyCreds cloud · default';

  @override
  String get ownServer => 'Own server';

  @override
  String get selfHosted => 'Self-hosted PolyCreds';

  @override
  String get serverAddress => 'Server address';

  @override
  String get enterServer => 'Enter the server address';

  @override
  String get continueAction => 'Continue';

  @override
  String get serverChangeLater =>
      'You can change the address later in settings';

  @override
  String get enterEmail => 'Enter your e-mail';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get loginFooter =>
      'Sign-up and password reset are in the PolyCreds web version';

  @override
  String get enter6Digits => 'Enter the 6 digits from the e-mail';

  @override
  String get codeResent => 'Code sent again';

  @override
  String get codeTitle => 'Code from e-mail';

  @override
  String get codeSentPrefix => 'We sent a 6-digit code to ';

  @override
  String get codeSentSuffix => '. Enter it to confirm sign-in.';

  @override
  String get resendIn => 'Resend in ';

  @override
  String get resendCode => 'Resend code';

  @override
  String get confirm => 'Confirm';

  @override
  String get codeFooter =>
      'No e-mail? Check the Spam folder. You can resend up to 3 times a minute.';

  @override
  String get pinMismatch => 'PINs do not match. Try again';

  @override
  String stepOf(int step) {
    return 'Step $step of 2';
  }

  @override
  String get createPin => 'Create a PIN';

  @override
  String get repeatPin => 'Repeat the PIN';

  @override
  String get pinCreateHint =>
      'It unlocks the app on this device. You won\'t need your account password.';

  @override
  String get pinRepeatHint => 'Enter the same PIN again.';

  @override
  String get pinDigitsHint => '4 to 6 digits';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String wrongPin(int n) {
    return 'Wrong PIN. Attempts left: $n';
  }

  @override
  String get signInWithPassword => 'Sign in with password';

  @override
  String get signOut => 'Sign out';

  @override
  String get tabVault => 'Vault';

  @override
  String get tabNotes => 'Notes';

  @override
  String get tabGenerator => 'Generator';

  @override
  String get tabProfile => 'Profile';

  @override
  String get searchVaultHint => 'Search credentials and notes';

  @override
  String allCount(int n) {
    return 'All · $n';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String get sites => 'Websites';

  @override
  String get servers => 'Servers';

  @override
  String get newGroup => 'New group';

  @override
  String get newCredential => 'New credential';

  @override
  String get groups => 'Groups';

  @override
  String get favoritesHint => 'Star credentials to keep them at hand';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get emptyText =>
      'Add your first credential: a login and password for a website or server. Groups help keep things tidy.';

  @override
  String get addCredential => 'Add credential';

  @override
  String get createGroup => 'Create group';

  @override
  String get copyPassword => 'Copy password';

  @override
  String get copyLogin => 'Copy login';

  @override
  String get copyHost => 'Copy host';

  @override
  String get editGroup => 'Edit group';

  @override
  String get newCredentialInGroup => 'New credential in group';

  @override
  String get byName => 'By name';

  @override
  String get byDate => 'By date';

  @override
  String get groupNoCredentials => 'No credentials in this group yet';

  @override
  String deleteItemTitle(Object name) {
    return 'Delete “$name”?';
  }

  @override
  String get deleteCredentialText =>
      'The login, password and note will be deleted permanently.';

  @override
  String get connectionCommand => 'Connection command';

  @override
  String get note => 'Note';

  @override
  String modifiedOn(Object date) {
    return 'Modified $date';
  }

  @override
  String get deleteCredential => 'Delete credential';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get login => 'Login';

  @override
  String get link => 'Link';

  @override
  String get openLink => 'Open link';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get protocol => 'Protocol';

  @override
  String get cantOpenLink => 'Could not open the link';

  @override
  String get enterName => 'Enter a name';

  @override
  String get enterLogin => 'Enter a login';

  @override
  String get enterHost => 'Enter a host';

  @override
  String get portRange => 'Port from 1 to 65535';

  @override
  String get group => 'Group';

  @override
  String get editCredential => 'Edit credential';

  @override
  String get siteTab => 'Website';

  @override
  String get serverTab => 'Server · SSH/FTP';

  @override
  String get name => 'Name';

  @override
  String get generatePassword => 'Generate password';

  @override
  String get credentialNoteHint => 'Backup codes, hints, anything else';

  @override
  String deleteGroupTitle(Object name) {
    return 'Delete group “$name”?';
  }

  @override
  String get deleteEmptyGroupText =>
      'The group is empty. This cannot be undone.';

  @override
  String deleteGroupText(Object items) {
    return '$items will be deleted with the group. They cannot be restored.';
  }

  @override
  String get deleteGroup => 'Delete group';

  @override
  String get groupTitle => 'Group';

  @override
  String get whatStored => 'What the group holds';

  @override
  String get credentials => 'Credentials';

  @override
  String get credentialsDesc => 'Logins and passwords for websites and servers';

  @override
  String get notes => 'Notes';

  @override
  String get notesDesc => 'Formatted text';

  @override
  String groupContains(Object items) {
    return 'The group has $items. ';
  }

  @override
  String get groupTypeHint =>
      'The group type decides where it is shown: on the “Vault” or “Notes” tab.';

  @override
  String credentialsN(int n) {
    return 'Credentials · $n';
  }

  @override
  String notesN(int n) {
    return 'Notes · $n';
  }

  @override
  String groupsN(int n) {
    return 'Groups · $n';
  }

  @override
  String get searchHint => 'Search by credential, note and group names';

  @override
  String get generatedPassword => 'Generated password';

  @override
  String get refresh => 'Refresh';

  @override
  String get use => 'Use';

  @override
  String get length => 'Length';

  @override
  String get newNote => 'New note';

  @override
  String get newNoteGroup => 'New note group';

  @override
  String get noNotes => 'No notes yet';

  @override
  String get searchNotesHint => 'Search notes';

  @override
  String get more => 'More';

  @override
  String get copyText => 'Copy text';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get deleteNoteText => 'The note will be deleted permanently.';

  @override
  String noteModifiedOn(Object date) {
    return 'modified $date';
  }

  @override
  String get emptyNote => 'Empty note';

  @override
  String get enterNoteTitle => 'Enter a note title';

  @override
  String get noteBodyHint => 'Note text';

  @override
  String get removeLink => 'Remove';

  @override
  String get fmtBold => 'Bold';

  @override
  String get fmtItalic => 'Italic';

  @override
  String get fmtUnderline => 'Underline';

  @override
  String get fmtHeading => 'Heading';

  @override
  String get fmtBulletList => 'Bulleted list';

  @override
  String get fmtNumberedList => 'Numbered list';

  @override
  String get fmtCode => 'Code';

  @override
  String get logoutTitle => 'Sign out?';

  @override
  String get logoutText =>
      'The PIN on this device will be reset. To sign in you will need your password and a code from e-mail.';

  @override
  String get logout => 'Sign out';

  @override
  String get personalData => 'Personal data';

  @override
  String get devices => 'Devices';

  @override
  String get securitySettings => 'Security and settings';

  @override
  String get version => 'Version';

  @override
  String get openWeb => 'Open web version';

  @override
  String get min2Chars => 'At least 2 characters';

  @override
  String get min6Chars => 'At least 6 characters';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get dataSaved => 'Changes saved';

  @override
  String get userName => 'Name';

  @override
  String get emailHelper => 'Sign-in codes are sent to this address';

  @override
  String get changePassword => 'Change password';

  @override
  String get newPassword => 'New password';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get currentPasswordHelper => 'Required to change e-mail or password';

  @override
  String get changeServerTitle => 'Change server?';

  @override
  String get changeServerText =>
      'The current session on this device will end. Then choose a server and sign in again.';

  @override
  String get changeServer => 'Change server';

  @override
  String get settings => 'Settings';

  @override
  String get security => 'Security';

  @override
  String get changePin => 'Change PIN';

  @override
  String get autoLock => 'Auto-lock';

  @override
  String get clipboardClear => 'Clear clipboard';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get serverChangeNote =>
      'Changing the server ends the current session on this device.';

  @override
  String get languageSystem => 'Same as system';

  @override
  String languageNow(Object language) {
    return 'Now: $language';
  }

  @override
  String get languageRussianInline => 'Russian';

  @override
  String get languageEnglishInline => 'English';

  @override
  String get languageRussianOther => 'Russian';

  @override
  String get languageEnglishOther => 'Английский';

  @override
  String get languageNote =>
      'The language changes right away, no restart needed. Vault entries are not translated.';

  @override
  String get languageGroup => 'Interface language';

  @override
  String get auto => 'AUTO';

  @override
  String get terminateOthersTitle => 'End other sessions?';

  @override
  String get terminateOthersText =>
      'Ended devices will need to sign in again with a code from e-mail.';

  @override
  String get terminate => 'End';

  @override
  String terminatedN(int n) {
    return 'Sessions ended: $n';
  }

  @override
  String get thisDevice => 'This device';

  @override
  String otherSessions(int n) {
    return 'Other sessions · $n';
  }

  @override
  String get noOtherSessions => 'No other active sessions';

  @override
  String get terminateAll => 'End all other sessions';

  @override
  String signedInOn(Object date) {
    return 'Signed in $date';
  }

  @override
  String createdModified(Object created, Object modified) {
    return 'Created $created · modified $modified';
  }
}
