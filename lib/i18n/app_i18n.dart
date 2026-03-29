import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class AppI18n {
  static const Map<String, String> _en = {
    'myOrders': 'My Orders',
    'signOut': 'Sign Out',
    'account': 'Account',
    'signIn': 'Sign In',
    'register': 'Register',
    'createAccount': 'Create Account',
    'continueWithGoogle': 'Continue with Google',
    'googleCancelled': 'Google sign-in was cancelled.',
    'googleFailed': 'Google sign-in failed',
    'googleUnsupported':
        'Google sign-in works only on Android/iOS run targets.',
    'checkout': 'Checkout',
    'bakongPayment': 'Bakong Payment',
    'signInRequired': 'Sign in required',
    'submitProof': 'Submit Proof',
    'paymentMethodBakong': 'Payment method: Bakong only',
    'samkiAccount': 'SAMKI Account',
    'authSubtitleSignIn': 'Sign in to continue checkout and manage your orders.',
    'authSubtitleRegister': 'Register to checkout and track your orders.',
    'fullName': 'Full Name',
    'email': 'Email',
    'password': 'Password',
    'required': 'Required',
    'invalidEmail': 'Invalid email',
    'min4': 'Minimum 4 characters',
    'alreadyHave': 'Already have an account? ',
    'noAccount': 'No account yet? ',
  };

  static const Map<String, String> _kh = {
    'myOrders': 'ការបញ្ជាទិញរបស់ខ្ញុំ',
    'signOut': 'ចាកចេញ',
    'account': 'គណនី',
    'signIn': 'ចូលគណនី',
    'register': 'ចុះឈ្មោះ',
    'createAccount': 'បង្កើតគណនី',
    'continueWithGoogle': 'បន្តដោយ Google',
    'googleCancelled': 'ការចូល Google ត្រូវបានបោះបង់',
    'googleFailed': 'ការចូល Google បរាជ័យ',
    'googleUnsupported':
        'ការចូល Google ដំណើរការបានតែលើ Android/iOS ប៉ុណ្ណោះ',
    'checkout': 'បង់ប្រាក់',
    'bakongPayment': 'ការទូទាត់ Bakong',
    'signInRequired': 'ត្រូវការចូលគណនី',
    'submitProof': 'ដាក់ស្នើភស្តុតាង',
    'paymentMethodBakong': 'វិធីទូទាត់៖ Bakong ប៉ុណ្ណោះ',
    'samkiAccount': 'គណនី SAMKI',
    'authSubtitleSignIn': 'ចូលគណនីដើម្បីបន្តបង់ប្រាក់ និងគ្រប់គ្រងការបញ្ជាទិញរបស់អ្នក។',
    'authSubtitleRegister': 'ចុះឈ្មោះដើម្បីបង់ប្រាក់ និងតាមដានការបញ្ជាទិញរបស់អ្នក។',
    'fullName': 'ឈ្មោះពេញ',
    'email': 'អ៊ីមែល',
    'password': 'ពាក្យសម្ងាត់',
    'required': 'តម្រូវឱ្យបំពេញ',
    'invalidEmail': 'អ៊ីមែលមិនត្រឹមត្រូវ',
    'min4': 'យ៉ាងហោចណាស់ ៤ តួអក្សរ',
    'alreadyHave': 'មានគណនីរួចហើយ? ',
    'noAccount': 'មិនទាន់មានគណនី? ',
  };

  static String text(AppLanguage language, String key) {
    final source = language == AppLanguage.kh ? _kh : _en;
    return source[key] ?? _en[key] ?? key;
  }
}

extension I18nRef on WidgetRef {
  String t(String key) {
    final language = watch(languageProvider);
    return AppI18n.text(language, key);
  }
}
