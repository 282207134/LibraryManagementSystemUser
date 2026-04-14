import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AppLanguage { zh, en, ja }

class AppLocalization {
  static const _boxName = 'app_config';
  static const _languageKey = 'app_language';
  static final ValueNotifier<AppLanguage> notifier =
      ValueNotifier<AppLanguage>(AppLanguage.zh);

  static Future<void> init() async {
    final box = Hive.box<String>(_boxName);
    final raw = box.get(_languageKey);
    notifier.value = _fromRaw(raw);
  }

  static Future<void> setLanguage(AppLanguage language) async {
    notifier.value = language;
    final box = Hive.box<String>(_boxName);
    await box.put(_languageKey, language.name);
  }

  static AppLanguage _fromRaw(String? raw) {
    switch (raw) {
      case 'en':
        return AppLanguage.en;
      case 'ja':
        return AppLanguage.ja;
      case 'zh':
      default:
        return AppLanguage.zh;
    }
  }

  static String languageLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.zh:
        return '中文';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.ja:
        return '日本語';
    }
  }

  static String tr(String key) {
    final lang = notifier.value;
    final map = _strings[key];
    if (map == null) return key;
    return map[lang] ?? map[AppLanguage.zh] ?? key;
  }

  static final Map<String, Map<AppLanguage, String>> _strings = {
    'app_title': {
      AppLanguage.zh: '图书管理系统',
      AppLanguage.en: 'Library Management',
      AppLanguage.ja: '図書管理システム',
    },
    'login': {
      AppLanguage.zh: '登录',
      AppLanguage.en: 'Login',
      AppLanguage.ja: 'ログイン',
    },
    'register': {
      AppLanguage.zh: '注册',
      AppLanguage.en: 'Register',
      AppLanguage.ja: '登録',
    },
    'email': {
      AppLanguage.zh: '邮箱',
      AppLanguage.en: 'Email',
      AppLanguage.ja: 'メール',
    },
    'password': {
      AppLanguage.zh: '密码',
      AppLanguage.en: 'Password',
      AppLanguage.ja: 'パスワード',
    },
    'confirm_password': {
      AppLanguage.zh: '确认密码',
      AppLanguage.en: 'Confirm Password',
      AppLanguage.ja: 'パスワード確認',
    },
    'username': {
      AppLanguage.zh: '用户名',
      AppLanguage.en: 'Username',
      AppLanguage.ja: 'ユーザー名',
    },
    'welcome_library': {
      AppLanguage.zh: '欢迎来到图书馆',
      AppLanguage.en: 'Welcome to the Library',
      AppLanguage.ja: '図書館へようこそ',
    },
    'login_continue': {
      AppLanguage.zh: '请登录以继续',
      AppLanguage.en: 'Please login to continue',
      AppLanguage.ja: '続行するにはログインしてください',
    },
    'forgot_password': {
      AppLanguage.zh: '忘记密码？',
      AppLanguage.en: 'Forgot password?',
      AppLanguage.ja: 'パスワードを忘れた？',
    },
    'enter_email': {
      AppLanguage.zh: '请输入邮箱',
      AppLanguage.en: 'Enter email',
      AppLanguage.ja: 'メールを入力してください',
    },
    'invalid_email': {
      AppLanguage.zh: '请输入有效邮箱',
      AppLanguage.en: 'Please enter a valid email',
      AppLanguage.ja: '有効なメールを入力してください',
    },
    'send_reset_link': {
      AppLanguage.zh: '发送重置邮件',
      AppLanguage.en: 'Send reset email',
      AppLanguage.ja: 'リセットメール送信',
    },
    'reset_email_sent': {
      AppLanguage.zh: '重置邮件已发送，请检查邮箱',
      AppLanguage.en: 'Reset email sent. Please check your inbox.',
      AppLanguage.ja: 'リセットメールを送信しました。メールをご確認ください。',
    },
    'go_register': {
      AppLanguage.zh: '去注册',
      AppLanguage.en: 'Sign up',
      AppLanguage.ja: '新規登録',
    },
    'go_login': {
      AppLanguage.zh: '去登录',
      AppLanguage.en: 'Go Login',
      AppLanguage.ja: 'ログインへ',
    },
    'no_account': {
      AppLanguage.zh: '还没有账号？',
      AppLanguage.en: "Don't have an account?",
      AppLanguage.ja: 'アカウントがありませんか？',
    },
    'home': {
      AppLanguage.zh: '首页',
      AppLanguage.en: 'Home',
      AppLanguage.ja: 'ホーム',
    },
    'books': {
      AppLanguage.zh: '图书浏览',
      AppLanguage.en: 'Books',
      AppLanguage.ja: '図書一覧',
    },
    'borrows': {
      AppLanguage.zh: '我的借阅',
      AppLanguage.en: 'My Borrows',
      AppLanguage.ja: '借覧',
    },
    'favorites': {
      AppLanguage.zh: '我的收藏',
      AppLanguage.en: 'Favorites',
      AppLanguage.ja: 'お気に入り',
    },
    'profile': {
      AppLanguage.zh: '个人中心',
      AppLanguage.en: 'Profile',
      AppLanguage.ja: 'プロフィール',
    },
    'admin': {
      AppLanguage.zh: '管理界面',
      AppLanguage.en: 'Admin',
      AppLanguage.ja: '管理',
    },
    'nav_home': {
      AppLanguage.zh: '首页',
      AppLanguage.en: 'Home',
      AppLanguage.ja: 'ホーム',
    },
    'nav_books': {
      AppLanguage.zh: '图书',
      AppLanguage.en: 'Books',
      AppLanguage.ja: '図書',
    },
    'nav_borrows': {
      AppLanguage.zh: '借阅',
      AppLanguage.en: 'Borrows',
      AppLanguage.ja: '借覧',
    },
    'nav_favorites': {
      AppLanguage.zh: '收藏',
      AppLanguage.en: 'Favs',
      AppLanguage.ja: 'お気に',
    },
    'nav_admin': {
      AppLanguage.zh: '管理',
      AppLanguage.en: 'Admin',
      AppLanguage.ja: '管理',
    },
    'nav_profile': {
      AppLanguage.zh: '我的',
      AppLanguage.en: 'Me',
      AppLanguage.ja: 'マイ',
    },
    'library': {
      AppLanguage.zh: '图书馆',
      AppLanguage.en: 'Library',
      AppLanguage.ja: '図書館',
    },
    'search_book_author': {
      AppLanguage.zh: '搜索书名或作者...',
      AppLanguage.en: 'Search by title or author...',
      AppLanguage.ja: '書名または著者で検索...',
    },
    'featured': {
      AppLanguage.zh: '⭐ 精选推荐',
      AppLanguage.en: '⭐ Featured',
      AppLanguage.ja: '⭐ おすすめ',
    },
    'popular_rank': {
      AppLanguage.zh: '人气排行榜 🔥',
      AppLanguage.en: 'Popular Ranking 🔥',
      AppLanguage.ja: '人気ランキング 🔥',
    },
    'new_arrivals': {
      AppLanguage.zh: '新上架',
      AppLanguage.en: 'New Arrivals',
      AppLanguage.ja: '新着',
    },
    'category_browse': {
      AppLanguage.zh: '📖 分类浏览',
      AppLanguage.en: '📖 Categories',
      AppLanguage.ja: '📖 カテゴリ',
    },
    'theme_mode': {
      AppLanguage.zh: '主题模式',
      AppLanguage.en: 'Theme Mode',
      AppLanguage.ja: 'テーマ',
    },
    'theme_system': {
      AppLanguage.zh: '跟随系统',
      AppLanguage.en: 'System',
      AppLanguage.ja: 'システム',
    },
    'theme_light': {
      AppLanguage.zh: '浅色',
      AppLanguage.en: 'Light',
      AppLanguage.ja: 'ライト',
    },
    'theme_dark': {
      AppLanguage.zh: '深色',
      AppLanguage.en: 'Dark',
      AppLanguage.ja: 'ダーク',
    },
    'language': {
      AppLanguage.zh: '语言',
      AppLanguage.en: 'Language',
      AppLanguage.ja: '言語',
    },
    'edit_profile': {
      AppLanguage.zh: '编辑资料',
      AppLanguage.en: 'Edit Profile',
      AppLanguage.ja: 'プロフィール編集',
    },
    'change_password': {
      AppLanguage.zh: '修改密码',
      AppLanguage.en: 'Change Password',
      AppLanguage.ja: 'パスワード変更',
    },
    'borrow_history': {
      AppLanguage.zh: '借阅历史',
      AppLanguage.en: 'Borrow History',
      AppLanguage.ja: '借覧履歴',
    },
    'current_borrow': {
      AppLanguage.zh: '当前借阅',
      AppLanguage.en: 'Current',
      AppLanguage.ja: '現在',
    },
    'history_record': {
      AppLanguage.zh: '历史记录',
      AppLanguage.en: 'History',
      AppLanguage.ja: '履歴',
    },
    'return_book': {
      AppLanguage.zh: '归还',
      AppLanguage.en: 'Return',
      AppLanguage.ja: '返却',
    },
    'logout': {
      AppLanguage.zh: '退出登录',
      AppLanguage.en: 'Logout',
      AppLanguage.ja: 'ログアウト',
    },
    'cancel': {
      AppLanguage.zh: '取消',
      AppLanguage.en: 'Cancel',
      AppLanguage.ja: 'キャンセル',
    },
    'save': {
      AppLanguage.zh: '保存',
      AppLanguage.en: 'Save',
      AppLanguage.ja: '保存',
    },
    'loading': {
      AppLanguage.zh: '加载中...',
      AppLanguage.en: 'Loading...',
      AppLanguage.ja: '読み込み中...',
    },
    'splash_title': {
      AppLanguage.zh: '图书管理系统',
      AppLanguage.en: 'Library Management',
      AppLanguage.ja: '図書管理システム',
    },
    'create_account': {
      AppLanguage.zh: '创建账号',
      AppLanguage.en: 'Create account',
      AppLanguage.ja: 'アカウント作成',
    },
    'register_start': {
      AppLanguage.zh: '注册即可开始使用',
      AppLanguage.en: 'Register to start',
      AppLanguage.ja: '登録して利用開始',
    },
    'account_info': {
      AppLanguage.zh: '账户信息',
      AppLanguage.en: 'Account Info',
      AppLanguage.ja: 'アカウント情報',
    },
    'personal_info': {
      AppLanguage.zh: '个人信息',
      AppLanguage.en: 'Personal Info',
      AppLanguage.ja: '個人情報',
    },
    'name': {
      AppLanguage.zh: '姓名',
      AppLanguage.en: 'Name',
      AppLanguage.ja: '氏名',
    },
    'phone': {
      AppLanguage.zh: '电话',
      AppLanguage.en: 'Phone',
      AppLanguage.ja: '電話',
    },
    'address': {
      AppLanguage.zh: '地址',
      AppLanguage.en: 'Address',
      AppLanguage.ja: '住所',
    },
    'unknown': {
      AppLanguage.zh: '未知',
      AppLanguage.en: 'Unknown',
      AppLanguage.ja: '不明',
    },
    'not_set': {
      AppLanguage.zh: '未设置',
      AppLanguage.en: 'Not set',
      AppLanguage.ja: '未設定',
    },
    'total_borrows': {
      AppLanguage.zh: '总借阅',
      AppLanguage.en: 'Total',
      AppLanguage.ja: '合計',
    },
    'current_borrows': {
      AppLanguage.zh: '当前借阅',
      AppLanguage.en: 'Current',
      AppLanguage.ja: '現在',
    },
    'history_borrows': {
      AppLanguage.zh: '历史借阅',
      AppLanguage.en: 'History',
      AppLanguage.ja: '履歴',
    },
    'email_address': {
      AppLanguage.zh: '邮箱地址',
      AppLanguage.en: 'Email',
      AppLanguage.ja: 'メールアドレス',
    },
    'user_role': {
      AppLanguage.zh: '用户角色',
      AppLanguage.en: 'Role',
      AppLanguage.ja: 'ユーザー権限',
    },
    'admin_role': {
      AppLanguage.zh: '管理员',
      AppLanguage.en: 'Admin',
      AppLanguage.ja: '管理者',
    },
    'normal_user': {
      AppLanguage.zh: '普通用户',
      AppLanguage.en: 'User',
      AppLanguage.ja: '一般ユーザー',
    },
    'registered_at': {
      AppLanguage.zh: '注册时间',
      AppLanguage.en: 'Registered At',
      AppLanguage.ja: '登録日時',
    },
    'borrow_limit': {
      AppLanguage.zh: '借阅上限',
      AppLanguage.en: 'Borrow Limit',
      AppLanguage.ja: '借覧上限',
    },
    'book_unit': {
      AppLanguage.zh: '本',
      AppLanguage.en: 'books',
      AppLanguage.ja: '冊',
    },
    'confirm': {
      AppLanguage.zh: '确认',
      AppLanguage.en: 'Confirm',
      AppLanguage.ja: '確認',
    },
    'update': {
      AppLanguage.zh: '更新',
      AppLanguage.en: 'Update',
      AppLanguage.ja: '更新',
    },
    'available': {
      AppLanguage.zh: '可借',
      AppLanguage.en: 'Available',
      AppLanguage.ja: '貸出可',
    },
    'unavailable': {
      AppLanguage.zh: '已借完',
      AppLanguage.en: 'Unavailable',
      AppLanguage.ja: '貸出不可',
    },
    'edit_book': {
      AppLanguage.zh: '编辑图书',
      AppLanguage.en: 'Edit Book',
      AppLanguage.ja: '図書編集',
    },
    'add_book': {
      AppLanguage.zh: '添加图书',
      AppLanguage.en: 'Add Book',
      AppLanguage.ja: '図書追加',
    },
    'author': {
      AppLanguage.zh: '作者',
      AppLanguage.en: 'Author',
      AppLanguage.ja: '著者',
    },
    'publisher': {
      AppLanguage.zh: '出版社',
      AppLanguage.en: 'Publisher',
      AppLanguage.ja: '出版社',
    },
    'publication_year': {
      AppLanguage.zh: '出版年份',
      AppLanguage.en: 'Publication Year',
      AppLanguage.ja: '出版年',
    },
    'category': {
      AppLanguage.zh: '分类',
      AppLanguage.en: 'Category',
      AppLanguage.ja: 'カテゴリ',
    },
    'description': {
      AppLanguage.zh: '简介',
      AppLanguage.en: 'Description',
      AppLanguage.ja: '概要',
    },
    'quantity': {
      AppLanguage.zh: '库存数量',
      AppLanguage.en: 'Quantity',
      AppLanguage.ja: '在庫数',
    },
    'available_quantity': {
      AppLanguage.zh: '可借数量',
      AppLanguage.en: 'Available Quantity',
      AppLanguage.ja: '貸出可能数',
    },
    'camera_upload': {
      AppLanguage.zh: '拍照上传',
      AppLanguage.en: 'Camera',
      AppLanguage.ja: 'カメラ',
    },
    'gallery_upload': {
      AppLanguage.zh: '相册上传',
      AppLanguage.en: 'Gallery',
      AppLanguage.ja: '写真',
    },
    'delete': {
      AppLanguage.zh: '删除',
      AppLanguage.en: 'Delete',
      AppLanguage.ja: '削除',
    },
    'edit': {
      AppLanguage.zh: '编辑',
      AppLanguage.en: 'Edit',
      AppLanguage.ja: '編集',
    },
    'operation_failed': {
      AppLanguage.zh: '操作失败',
      AppLanguage.en: 'Operation failed',
      AppLanguage.ja: '操作に失敗しました',
    },
    'password_length_error': {
      AppLanguage.zh: '新密码长度至少为6位',
      AppLanguage.en: 'New password must be at least 6 characters',
      AppLanguage.ja: '新しいパスワードは6文字以上必要です',
    },
    'new_password_mismatch': {
      AppLanguage.zh: '两次输入的新密码不一致',
      AppLanguage.en: 'New passwords do not match',
      AppLanguage.ja: '新しいパスワードが一致しません',
    },
    'password_changed_relogin': {
      AppLanguage.zh: '密码修改成功，请重新登录',
      AppLanguage.en: 'Password changed. Please log in again.',
      AppLanguage.ja: 'パスワードを変更しました。再ログインしてください。',
    },
    'check_borrows_hint': {
      AppLanguage.zh: '请在“我的借阅”页面查看借阅历史',
      AppLanguage.en: 'Please check borrow history in My Borrows',
      AppLanguage.ja: '借覧履歴は「借覧」ページで確認してください',
    },
    'upload_failed': {
      AppLanguage.zh: '上传失败',
      AppLanguage.en: 'Upload failed',
      AppLanguage.ja: 'アップロードに失敗しました',
    },
  };
}
