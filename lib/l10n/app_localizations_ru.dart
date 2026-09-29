// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class L10nRu extends L10n {
  L10nRu([String locale = 'ru']) : super(locale);

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get clear => 'Очистить';

  @override
  String get back => 'Назад';

  @override
  String backTo(Object label) {
    return 'Назад: $label';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get done => 'Готово';

  @override
  String get retry => 'Повторить';

  @override
  String get erase => 'Стереть';

  @override
  String digitsEntered(int count) {
    return 'Введено цифр: $count';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get change => 'Сменить';

  @override
  String get copy => 'Копировать';

  @override
  String get next => 'Далее';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get noGroup => 'Без группы';

  @override
  String get search => 'Поиск';

  @override
  String get errTimeout => 'Сервер не отвечает. Проверьте подключение.';

  @override
  String get errCertificate => 'Недействительный сертификат сервера.';

  @override
  String get errNoConnection => 'Нет соединения с сервером.';

  @override
  String get err401 => 'Сеанс истёк. Войдите снова.';

  @override
  String get err403 => 'Недостаточно прав.';

  @override
  String get err404 => 'Не найдено.';

  @override
  String get err429 => 'Слишком много попыток. Подождите немного.';

  @override
  String errServer(Object code) {
    return 'Ошибка сервера ($code).';
  }

  @override
  String get errNotPolyCreds => 'По этому адресу не найден сервер PolyCreds.';

  @override
  String get errLoginExpired => 'Сеанс входа истёк. Войдите снова.';

  @override
  String durationSeconds(int n) {
    return '$n с';
  }

  @override
  String durationMinutes(int n) {
    return '$n мин';
  }

  @override
  String afterDuration(Object duration) {
    return 'Через $duration';
  }

  @override
  String get immediately => 'Сразу';

  @override
  String get never => 'Никогда';

  @override
  String clipboardWillClear(Object duration) {
    return 'Буфер обмена очистится через $duration';
  }

  @override
  String get copiedPassword => 'Пароль скопирован';

  @override
  String get copiedLogin => 'Логин скопирован';

  @override
  String get copiedHost => 'Хост скопирован';

  @override
  String get copiedCommand => 'Команда скопирована';

  @override
  String get copiedText => 'Текст скопирован';

  @override
  String credentialsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count доступа',
      many: '$count доступов',
      few: '$count доступа',
      one: '$count доступ',
    );
    return '$_temp0';
  }

  @override
  String notesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заметки',
      many: '$count заметок',
      few: '$count заметки',
      one: '$count заметка',
    );
    return '$_temp0';
  }

  @override
  String get activeNow => 'Активен сейчас';

  @override
  String get neverUsed => 'Не использовался';

  @override
  String activeMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Был активен $n минуты назад',
      many: 'Был активен $n минут назад',
      few: 'Был активен $n минуты назад',
      one: 'Был активен $n минуту назад',
    );
    return '$_temp0';
  }

  @override
  String activeHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Был активен $n часа назад',
      many: 'Был активен $n часов назад',
      few: 'Был активен $n часа назад',
      one: 'Был активен $n час назад',
    );
    return '$_temp0';
  }

  @override
  String activeDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Был активен $n дня назад',
      many: 'Был активен $n дней назад',
      few: 'Был активен $n дня назад',
      one: 'Был активен $n день назад',
    );
    return '$_temp0';
  }

  @override
  String activeWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Был активен $n недели назад',
      many: 'Был активен $n недель назад',
      few: 'Был активен $n недели назад',
      one: 'Был активен $n неделю назад',
    );
    return '$_temp0';
  }

  @override
  String activeOn(Object date) {
    return 'Был активен $date';
  }

  @override
  String get setDigits => 'Цифры';

  @override
  String get setLower => 'Строчные буквы';

  @override
  String get setUpper => 'Заглавные буквы';

  @override
  String get setSymbols => 'Символы';

  @override
  String get setExtended => 'Расширенные символы';

  @override
  String get strengthWeak => 'Слабый';

  @override
  String get strengthFair => 'Средний';

  @override
  String get strengthGood => 'Хороший';

  @override
  String get strengthStrong => 'Надёжный';

  @override
  String get strengthVeryStrong => 'Очень надёжный';

  @override
  String strengthBits(Object label, int bits) {
    return '$label · ~$bits бит';
  }

  @override
  String get appTagline =>
      'Ваши пароли, доступы к серверам и заметки. Всё зашифровано на сервере, который вы выбираете.';

  @override
  String get serverSection => 'Сервер';

  @override
  String get cloudDefault => 'Облако PolyCreds · по умолчанию';

  @override
  String get ownServer => 'Свой сервер';

  @override
  String get selfHosted => 'Self-hosted PolyCreds';

  @override
  String get serverAddress => 'Адрес сервера';

  @override
  String get enterServer => 'Введите адрес сервера';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get serverChangeLater => 'Адрес можно сменить позже в настройках';

  @override
  String get enterEmail => 'Введите e-mail';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get loginTitle => 'Вход';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get loginFooter =>
      'Регистрация и сброс пароля — в веб-версии PolyCreds';

  @override
  String get enter6Digits => 'Введите 6 цифр из письма';

  @override
  String get codeResent => 'Код отправлен повторно';

  @override
  String get codeTitle => 'Код из письма';

  @override
  String get codeSentPrefix => 'Отправили 6-значный код на ';

  @override
  String get codeSentSuffix => '. Введите его, чтобы подтвердить вход.';

  @override
  String get resendIn => 'Отправить повторно через ';

  @override
  String get resendCode => 'Отправить код повторно';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get codeFooter =>
      'Не пришло письмо? Проверьте «Спам». Повторная отправка — до 3 раз в минуту.';

  @override
  String get pinMismatch => 'PIN-коды не совпадают. Попробуйте ещё раз';

  @override
  String stepOf(int step) {
    return 'Шаг $step из 2';
  }

  @override
  String get createPin => 'Придумайте PIN-код';

  @override
  String get repeatPin => 'Повторите PIN-код';

  @override
  String get pinCreateHint =>
      'Он разблокирует приложение на этом устройстве. Пароль от аккаунта вводить не придётся.';

  @override
  String get pinRepeatHint => 'Введите тот же PIN-код ещё раз.';

  @override
  String get pinDigitsHint => 'От 4 до 6 цифр';

  @override
  String get enterPin => 'Введите PIN';

  @override
  String wrongPin(int n) {
    return 'Неверный PIN. Осталось попыток: $n';
  }

  @override
  String get signInWithPassword => 'Войти по паролю';

  @override
  String get signOut => 'Выйти из аккаунта';

  @override
  String get tabVault => 'Хранилище';

  @override
  String get tabNotes => 'Заметки';

  @override
  String get tabGenerator => 'Генератор';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get searchVaultHint => 'Поиск по доступам и заметкам';

  @override
  String allCount(int n) {
    return 'Все · $n';
  }

  @override
  String get favorites => 'Избранное';

  @override
  String get sites => 'Сайты';

  @override
  String get servers => 'Серверы';

  @override
  String get newGroup => 'Новая группа';

  @override
  String get newCredential => 'Новый доступ';

  @override
  String get groups => 'Группы';

  @override
  String get favoritesHint =>
      'Отметьте доступы звёздочкой, чтобы они были под рукой';

  @override
  String get emptyTitle => 'Здесь пока пусто';

  @override
  String get emptyText =>
      'Добавьте первый доступ: логин и пароль от сайта или сервера. Группы помогут навести порядок.';

  @override
  String get addCredential => 'Добавить доступ';

  @override
  String get createGroup => 'Создать группу';

  @override
  String get copyPassword => 'Скопировать пароль';

  @override
  String get copyLogin => 'Скопировать логин';

  @override
  String get copyHost => 'Скопировать хост';

  @override
  String get editGroup => 'Изменить группу';

  @override
  String get newCredentialInGroup => 'Новый доступ в группе';

  @override
  String get byName => 'По имени';

  @override
  String get byDate => 'По дате';

  @override
  String get groupNoCredentials => 'В группе пока нет доступов';

  @override
  String deleteItemTitle(Object name) {
    return 'Удалить «$name»?';
  }

  @override
  String get deleteCredentialText =>
      'Логин, пароль и заметка будут удалены без возможности восстановления.';

  @override
  String get connectionCommand => 'Команда подключения';

  @override
  String get note => 'Заметка';

  @override
  String modifiedOn(Object date) {
    return 'Изменён $date';
  }

  @override
  String get deleteCredential => 'Удалить доступ';

  @override
  String get removeFavorite => 'Убрать из избранного';

  @override
  String get addFavorite => 'В избранное';

  @override
  String get login => 'Логин';

  @override
  String get link => 'Ссылка';

  @override
  String get openLink => 'Открыть ссылку';

  @override
  String get host => 'Хост';

  @override
  String get port => 'Порт';

  @override
  String get protocol => 'Протокол';

  @override
  String get cantOpenLink => 'Не удалось открыть ссылку';

  @override
  String get enterName => 'Введите название';

  @override
  String get enterLogin => 'Введите логин';

  @override
  String get enterHost => 'Введите хост';

  @override
  String get portRange => 'Порт от 1 до 65535';

  @override
  String get group => 'Группа';

  @override
  String get editCredential => 'Изменить доступ';

  @override
  String get siteTab => 'Сайт';

  @override
  String get serverTab => 'Сервер · SSH/FTP';

  @override
  String get name => 'Название';

  @override
  String get generatePassword => 'Сгенерировать пароль';

  @override
  String get credentialNoteHint => 'Резервные коды, подсказки, всё остальное';

  @override
  String deleteGroupTitle(Object name) {
    return 'Удалить группу «$name»?';
  }

  @override
  String get deleteEmptyGroupText => 'Группа пустая. Удаление нельзя отменить.';

  @override
  String deleteGroupText(Object items) {
    return 'Вместе с группой будут удалены $items. Восстановить их будет нельзя.';
  }

  @override
  String get deleteGroup => 'Удалить группу';

  @override
  String get groupTitle => 'Группа';

  @override
  String get whatStored => 'Что хранится в группе';

  @override
  String get credentials => 'Доступы';

  @override
  String get credentialsDesc => 'Логины и пароли к сайтам и серверам';

  @override
  String get notes => 'Заметки';

  @override
  String get notesDesc => 'Текст с форматированием';

  @override
  String groupContains(Object items) {
    return 'В группе $items. ';
  }

  @override
  String get groupTypeHint =>
      'Тип группы влияет на то, где она показывается: во вкладке «Хранилище» или «Заметки».';

  @override
  String credentialsN(int n) {
    return 'Доступы · $n';
  }

  @override
  String notesN(int n) {
    return 'Заметки · $n';
  }

  @override
  String groupsN(int n) {
    return 'Группы · $n';
  }

  @override
  String get searchHint => 'Ищите по названиям доступов, заметок и групп';

  @override
  String get generatedPassword => 'Сгенерированный пароль';

  @override
  String get refresh => 'Обновить';

  @override
  String get use => 'Использовать';

  @override
  String get length => 'Длина';

  @override
  String get newNote => 'Новая заметка';

  @override
  String get newNoteGroup => 'Новая группа заметок';

  @override
  String get noNotes => 'Заметок пока нет';

  @override
  String get searchNotesHint => 'Поиск по заметкам';

  @override
  String get more => 'Ещё';

  @override
  String get copyText => 'Скопировать текст';

  @override
  String get deleteNote => 'Удалить заметку';

  @override
  String get deleteNoteText =>
      'Заметка будет удалена без возможности восстановления.';

  @override
  String noteModifiedOn(Object date) {
    return 'изменена $date';
  }

  @override
  String get emptyNote => 'Пустая заметка';

  @override
  String get enterNoteTitle => 'Введите название заметки';

  @override
  String get noteBodyHint => 'Текст заметки';

  @override
  String get removeLink => 'Убрать';

  @override
  String get fmtBold => 'Жирный';

  @override
  String get fmtItalic => 'Курсив';

  @override
  String get fmtUnderline => 'Подчёркнутый';

  @override
  String get fmtHeading => 'Заголовок';

  @override
  String get fmtBulletList => 'Маркированный список';

  @override
  String get fmtNumberedList => 'Нумерованный список';

  @override
  String get fmtCode => 'Код';

  @override
  String get logoutTitle => 'Выйти из аккаунта?';

  @override
  String get logoutText =>
      'PIN-код на этом устройстве будет сброшен. Для входа понадобятся пароль и код из письма.';

  @override
  String get logout => 'Выйти';

  @override
  String get personalData => 'Личные данные';

  @override
  String get devices => 'Устройства';

  @override
  String get securitySettings => 'Безопасность и настройки';

  @override
  String get version => 'Версия';

  @override
  String get openWeb => 'Открыть веб-версию';

  @override
  String get min2Chars => 'Минимум 2 символа';

  @override
  String get min6Chars => 'Минимум 6 символов';

  @override
  String get passwordsMismatch => 'Пароли не совпадают';

  @override
  String get enterCurrentPassword => 'Введите текущий пароль';

  @override
  String get dataSaved => 'Данные сохранены';

  @override
  String get userName => 'Имя';

  @override
  String get emailHelper => 'На этот адрес приходят коды входа';

  @override
  String get changePassword => 'Смена пароля';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get repeatPassword => 'Повторите пароль';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get currentPasswordHelper => 'Нужен для смены e-mail или пароля';

  @override
  String get changeServerTitle => 'Сменить сервер?';

  @override
  String get changeServerText =>
      'Текущий сеанс на этом устройстве будет завершён. Затем выберите сервер и войдите заново.';

  @override
  String get changeServer => 'Сменить сервер';

  @override
  String get settings => 'Настройки';

  @override
  String get security => 'Безопасность';

  @override
  String get changePin => 'Сменить PIN-код';

  @override
  String get autoLock => 'Автоблокировка';

  @override
  String get clipboardClear => 'Очистка буфера обмена';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get serverChangeNote =>
      'Смена сервера завершит текущий сеанс на этом устройстве.';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String languageNow(Object language) {
    return 'Сейчас: $language';
  }

  @override
  String get languageRussianInline => 'русский';

  @override
  String get languageEnglishInline => 'английский';

  @override
  String get languageRussianOther => 'Russian';

  @override
  String get languageEnglishOther => 'Английский';

  @override
  String get languageNote =>
      'Язык меняется сразу, перезапуск не нужен. Записи в хранилище не переводятся.';

  @override
  String get languageGroup => 'Язык интерфейса';

  @override
  String get auto => 'АВТО';

  @override
  String get terminateOthersTitle => 'Завершить другие сеансы?';

  @override
  String get terminateOthersText =>
      'На завершённых устройствах понадобится снова войти с кодом из письма.';

  @override
  String get terminate => 'Завершить';

  @override
  String terminatedN(int n) {
    return 'Завершено сеансов: $n';
  }

  @override
  String get thisDevice => 'Это устройство';

  @override
  String otherSessions(int n) {
    return 'Другие сеансы · $n';
  }

  @override
  String get noOtherSessions => 'Других активных сеансов нет';

  @override
  String get terminateAll => 'Завершить все другие сеансы';

  @override
  String signedInOn(Object date) {
    return 'Вход $date';
  }

  @override
  String createdModified(Object created, Object modified) {
    return 'Создан $created · изменён $modified';
  }
}
