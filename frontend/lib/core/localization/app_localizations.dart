import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('hi'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'ShilpSetu AI',
      'tagline': 'Your AI Business Manager',
      'taglineHindi': 'आपके हुनर का डिजिटल साथी',
      'splashSubtitle':
          'Empowering artisans. Connecting craftsmanship with markets.',
      'loginTitle': 'Welcome to ShilpSetu AI',
      'loginSubtitle': 'Login to manage your artisan business',
      'phoneNumber': 'Phone Number',
      'password': 'Password',
      'login': 'Login',
      'createAccount': 'Create Account',
      'continueAsDemoArtisan': 'Continue as Demo Artisan',
      'namasteArtisan': 'Namaste',
      'dashboardSubtitle': "Let's grow your craft today.",
      'addProduct': '+ Add Product',
      'quickActions': 'Quick AI Tools',
      'productStudio': '📸 Product Studio',
      'voiceCatalog': '🎙 Voice Catalog',
      'smartPricing': '💰 Smart Pricing',
      'visualSearch': '🔎 Visual Search',
      'statsProducts': 'Products',
      'statsPublished': 'Published',
      'statsOrders': 'Orders',
      'statsEarnings': 'Sales',
      'recentProducts': 'Recent Products',
      'viewAll': 'View All',
      'navHome': 'Home',
      'navProducts': 'Products',
      'navSearch': 'Search',
      'navOrders': 'Orders',
      'navProfile': 'Profile',
      'tabAll': 'All',
      'tabDrafts': 'Drafts',
      'tabPublished': 'Published',
      'tabOutOfStock': 'Out of Stock',
      'howToAdd': 'What would you like to do?',
      'takePhoto': '📸 Take Product Photo',
      'chooseGallery': '🖼 Choose From Gallery',
      'describeVoice': '🎙 Describe With Voice',
      'enterManually': '✍ Enter Manually',
      'imageStudioTitle': 'AI Image Studio',
      'beforeAfter': 'Before / After Preview',
      'removeBackground': 'Remove Background',
      'improveLighting': 'Improve Lighting',
      'enhanceColors': 'Enhance Colors',
      'ecommerceCrop': 'E-Commerce Crop (1:1)',
      'enhancingImage': 'AI is improving your product photo...',
      'voiceTitle': 'Tell us about your product',
      'voiceSubtitle': 'Speak in your own language',
      'pricingTitle': 'Smart Pricing Assistant 💰',
      'previewTitle': 'Product Preview',
      'readyToSell': 'Ready to Sell?',
      'publishMarketplaces': 'Publish to Marketplaces',
      'similarProducts': 'Similar Craft Products',
      'ordersTitle': 'Orders',
      'profileTitle': 'Artisan Profile',
      'saveProduct': 'Save Product',
      'delete': 'Delete',
      'edit': 'Edit',
      'cancel': 'Cancel',
      'noProductsYet': 'No products added yet',
      'noOrdersYet': 'No orders yet',
      'ordersWillAppear': 'New marketplace orders from buyers will appear here',
    },
    'hi': {
      'appTitle': 'शिल्पसेतु AI',
      'tagline': 'आपके हुनर का डिजिटल साथी',
      'taglineHindi': 'आपके हुनर का डिजिटल साथी',
      'splashSubtitle': 'कारीगरों का सशक्तिकरण। शिल्प को बाज़ार से जोड़ना।',
      'loginTitle': 'शिल्पसेतु AI में आपका स्वागत है',
      'loginSubtitle': 'अपने शिल्प व्यवसाय को प्रबंधित करने के लिए लॉगिन करें',
      'phoneNumber': 'फ़ोन नंबर',
      'password': 'पासवर्ड',
      'login': 'लॉगिन करें',
      'createAccount': 'नया खाता बनाएं',
      'continueAsDemoArtisan': 'डेमो कारीगर के रूप में जारी रखें',
      'namasteArtisan': 'नमस्ते',
      'dashboardSubtitle': 'आइए आज आपके शिल्प को आगे बढ़ाएं।',
      'addProduct': '+ उत्पाद जोड़ें',
      'quickActions': 'त्वरित AI टूल्स',
      'productStudio': '📸 उत्पाद स्टूडियो',
      'voiceCatalog': '🎙 वॉइस कैटलॉग',
      'smartPricing': '💰 स्मार्ट मूल्य',
      'visualSearch': '🔎 विज़ुअल खोज',
      'statsProducts': 'कुल उत्पाद',
      'statsPublished': 'प्रकाशित',
      'statsOrders': 'ऑर्डर',
      'statsEarnings': 'बिक्री',
      'recentProducts': 'हाल के उत्पाद',
      'viewAll': 'सभी देखें',
      'navHome': 'होम',
      'navProducts': 'उत्पाद',
      'navSearch': 'खोजें',
      'navOrders': 'ऑर्डर',
      'navProfile': 'प्रोफ़ाइल',
      'tabAll': 'सभी',
      'tabDrafts': 'ड्राफ़्ट',
      'tabPublished': 'प्रकाशित',
      'tabOutOfStock': 'स्टॉक समाप्त',
      'howToAdd': 'आप क्या करना चाहते हैं?',
      'takePhoto': '📸 उत्पाद का फोटो लें',
      'chooseGallery': '🖼 गैलरी से चुनें',
      'describeVoice': '🎙 बोलकर बताएं',
      'enterManually': '✍ खुद लिखें',
      'imageStudioTitle': 'AI फोटो स्टूडियो',
      'beforeAfter': 'पहले / बाद का पूर्वावलोकन',
      'removeBackground': 'बैकग्राउंड हटाएं',
      'improveLighting': 'रोशनी सुधारें',
      'enhanceColors': 'रंग निखारें',
      'ecommerceCrop': 'ई-कॉमर्स क्रॉप (1:1)',
      'enhancingImage': 'AI आपके फोटो को बेहतर बना रहा है...',
      'voiceTitle': 'अपने उत्पाद के बारे में बताएं',
      'voiceSubtitle': 'अपनी भाषा में बोलें',
      'pricingTitle': 'स्मार्ट मूल्य सहायक 💰',
      'previewTitle': 'उत्पाद पूर्वावलोकन',
      'readyToSell': 'बेचने के लिए तैयार हैं?',
      'publishMarketplaces': 'बाज़ारों में प्रकाशित करें',
      'similarProducts': 'समान शिल्प उत्पाद',
      'ordersTitle': 'ऑर्डर्स',
      'profileTitle': 'कारीगर प्रोफ़ाइल',
      'saveProduct': 'उत्पाद सहेजें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'cancel': 'रद्द करें',
      'noProductsYet': 'अभी कोई उत्पाद नहीं है',
      'noOrdersYet': 'अभी कोई ऑर्डर नहीं है',
    },
    'bn': {
      'appTitle': 'শিল্পসেতু AI',
      'tagline': 'আপনার হুনের ডিজিটাল সঙ্গী',
      'taglineHindi': 'আপনার হুনের ডিজিটাল সঙ্গী',
      'splashSubtitle': 'কারিগরদের ক্ষমতায়ন।',
      'loginTitle': 'শিল্পসেতু AI-তে স্বাগতম',
      'loginSubtitle': 'লগইন করুন',
      'phoneNumber': 'ফোন নম্বর',
      'password': 'পাসওয়ার্ড',
      'login': 'লগইন',
      'createAccount': 'নতুন অ্যাকাউন্ট তৈরি করুন',
      'continueAsDemoArtisan': 'ডেমো কারিগর হিসেবে চালিয়ে যান',
      'namasteArtisan': 'নমস্কার',
      'dashboardSubtitle': 'চলুন আপনার কারুশিল্পকে এগিয়ে নিয়ে যাই।',
      'addProduct': '+ পণ্য যোগ করুন',
      'quickActions': 'দ্রুত AI টুলস',
      'productStudio': '📸 পণ্য স্টুডিও',
      'voiceCatalog': '🎙 ভয়েস ক্যাটালগ',
      'smartPricing': '💰 স্মার্ট মূল্য',
      'visualSearch': '🔎 ভিজ্যুয়াল অনুসন্ধান',
      'statsProducts': 'মোট পণ্য',
      'statsPublished': 'প্রকাশিত',
      'statsOrders': 'অর্ডার',
      'statsEarnings': 'বিক্রয়',
      'recentProducts': 'সাম্প্রতিক পণ্য',
      'viewAll': 'সব দেখুন',
      'navHome': 'হোম',
      'navProducts': 'পণ্য',
      'navSearch': 'অনুসন্ধান',
      'navOrders': 'অর্ডার',
      'navProfile': 'প্রোফাইল',
      'tabAll': 'সব',
      'tabDrafts': 'খসড়া',
      'tabPublished': 'প্রকাশিত',
      'tabOutOfStock': 'স্টক নেই',
      'howToAdd': 'আপনি কি করতে চান?',
      'takePhoto': '📸 ছবির তুলুন',
      'chooseGallery': '🖼 গ্যালারি থেকে বেছে নিন',
      'describeVoice': '🎙 কথা বলে বর্ণনা দিন',
      'enterManually': '✍ নিজে লিখুন',
      'imageStudioTitle': 'AI ইমেজ স্টুডিও',
      'voiceTitle': 'পণ্যের বিবরণ দিন',
      'pricingTitle': 'স্মার্ট মূল্য সহায়ক 💰',
      'previewTitle': 'পণ্য প্রাকদর্শন',
      'readyToSell': 'বিক্রির জন্য প্রস্তুত?',
      'publishMarketplaces': 'মার্কেটপ্লেসে প্রকাশ করুন',
      'similarProducts': 'অনুরূপ হস্তশিল্প পণ্য',
      'ordersTitle': 'অর্ডারসমূহ',
      'profileTitle': 'কারিগর প্রোফাইল',
      'saveProduct': 'সংরক্ষণ করুন',
      'delete': 'মুছুন',
      'edit': 'সম্পাদনা',
      'cancel': 'বাতিল',
      'noProductsYet': 'কোন পণ্য নেই',
      'noOrdersYet': 'কোন অর্ডার নেই',
    },
    'ta': {
      'appTitle': 'சில்ப்சேது AI',
      'tagline': 'உங்கள் திறமையின் டிஜிட்டல் தோழன்',
      'taglineHindi': 'உங்கள் திறமையின் டிஜிட்டல் தோழன்',
      'splashSubtitle': 'கைவினைஞர்களுக்கு அதிகாரமளித்தல்.',
      'loginTitle': 'சில்ப்சேது AI-க்கு வரவேற்கிறோம்',
      'loginSubtitle': 'உள்நுழையவும்',
      'phoneNumber': 'தொலைபேசி எண்',
      'password': 'கடவுச்சொல்',
      'login': 'உள்நுழை',
      'createAccount': 'கணக்கு உருவாக்கவும்',
      'continueAsDemoArtisan': 'டெமோ கைவினைஞராக தொடரவும்',
      'namasteArtisan': 'வணக்கம்',
      'dashboardSubtitle': 'உங்கள் கைவினைத் தொழிலை வளர்ப்போம்.',
      'addProduct': '+ தயாரிப்பு சேர்க்க',
      'quickActions': 'விரைவு AI கருவிகள்',
      'productStudio': '📸 தயாரிப்பு ஸ்டுடியோ',
      'voiceCatalog': '🎙 குரல் அட்டவணை',
      'smartPricing': '💰 ஸ்மார்ட் விலை',
      'visualSearch': '🔎 காட்சி தேடல்',
      'statsProducts': 'தயாரிப்புகள்',
      'statsPublished': 'வெளியிடப்பட்டது',
      'statsOrders': 'ஆர்டர்கள்',
      'statsEarnings': 'விற்பனை',
      'recentProducts': 'சமீபத்திய தயாரிப்புகள்',
      'viewAll': 'அனைத்தையும் பார்க்க',
      'navHome': 'முகப்பு',
      'navProducts': 'தயாரிப்புகள்',
      'navSearch': 'தேடல்',
      'navOrders': 'ஆர்டர்கள்',
      'navProfile': 'சுயவிவரம்',
      'tabAll': 'அனைத்தும்',
      'tabDrafts': 'வரைவுகள்',
      'tabPublished': 'வெளியிடப்பட்டது',
      'tabOutOfStock': 'கையிருப்பில் இல்லை',
      'howToAdd': 'நீங்கள் என்ன செய்ய விரும்புகிறீர்கள்?',
      'takePhoto': '📸 புகைப்படம் எடுக்கவும்',
      'chooseGallery': '🖼 கேலரியில் இருந்து தேர்வு செய்யவும்',
      'describeVoice': '🎙 குரல் மூலம் விவரிக்கவும்',
      'enterManually': '✍ கைமுறையாக உள்ளிடவும்',
      'imageStudioTitle': 'AI பட ஸ்டுடியோ',
      'voiceTitle': 'தயாரிப்பு பற்றி சொல்லுங்கள்',
      'pricingTitle': 'ஸ்மார்ட் விலை உதவியாளர் 💰',
      'previewTitle': 'தயாரிப்பு முன்னோட்டம்',
      'readyToSell': 'விற்க தயாரா?',
      'publishMarketplaces': 'சந்தைகளில் வெளியிடவும்',
      'similarProducts': 'ஒத்த தயாரிப்புகள்',
      'ordersTitle': 'ஆர்டர்கள்',
      'profileTitle': 'கைவினைஞர் சுயவிவரம்',
      'saveProduct': 'சேமிக்கவும்',
      'delete': 'நீக்கு',
      'edit': 'திருத்து',
      'cancel': 'ரத்துசெய்',
      'noProductsYet': 'தயாரிப்புகள் இல்லை',
      'noOrdersYet': 'ஆர்டர்கள் இல்லை',
    },
    'te': {
      'appTitle': 'శిల్పసేతు AI',
      'tagline': 'మీ ప్రతిభకు డిజిటల్ తోడు',
      'taglineHindi': 'మీ ప్రతిభకు డిజిటల్ తోడు',
      'splashSubtitle': 'చేతివృత్తుల వారి సాధికారత.',
      'loginTitle': 'శిల్పసేతు AI కి స్వాగతం',
      'loginSubtitle': 'లాగిన్ అవ్వండి',
      'phoneNumber': 'ఫోన్ నంబర్',
      'password': 'పాస్‌వర్డ్',
      'login': 'లాగిన్',
      'createAccount': 'ఖాతా సృష్టించండి',
      'continueAsDemoArtisan': 'డెమో కళాకారుడిగా కొనసాగండి',
      'namasteArtisan': 'నమస్కారం',
      'dashboardSubtitle': 'మీ కళను ముందుకు తీసుకువెళదాం.',
      'addProduct': '+ ఉత్పత్తిని జోడించండి',
      'quickActions': 'త్వరిత AI సాధనాలు',
      'productStudio': '📸 ప్రొడక్ట్ స్టూడియో',
      'voiceCatalog': '🎙 వాయిస్ క్యాటలాగ్',
      'smartPricing': '💰 స్మార్ట్ ధర',
      'visualSearch': '🔎 విజువల్ శోధన',
      'statsProducts': 'ఉత్పత్తులు',
      'statsPublished': 'ప్రచురించబడింది',
      'statsOrders': 'ఆర్డర్లు',
      'statsEarnings': 'అమ్మకాలు',
      'recentProducts': 'ఇటీవలి ఉత్పత్తులు',
      'viewAll': 'అన్నీ చూడండి',
      'navHome': 'హోమ్',
      'navProducts': 'ఉత్పత్తులు',
      'navSearch': 'శోధన',
      'navOrders': 'ఆర్డర్లు',
      'navProfile': 'ప్రొఫైల్',
      'tabAll': 'అన్నీ',
      'tabDrafts': 'డ్రాఫ్ట్‌లు',
      'tabPublished': 'ప్రచురించబడింది',
      'tabOutOfStock': 'స్టాక్ ముగిసింది',
      'howToAdd': 'మీరు ఏమి చేయాలనుకుంటున్నారు?',
      'takePhoto': '📸 ఫోటో తీయండి',
      'chooseGallery': '🖼 గ్యాలరీ నుండి ఎంచుకోండి',
      'describeVoice': '🎙 మాట్లాడి వివరించండి',
      'enterManually': '✍ మీరే నమోదు చేయండి',
      'imageStudioTitle': 'AI ఇమేజ్ స్టూడియో',
      'voiceTitle': 'ఉత్పత్తి గురించి చెప్పండి',
      'pricingTitle': 'స్మార్ట్ ధర సహాయకుడు 💰',
      'previewTitle': 'ఉత్పత్తి ప్రివ్యూ',
      'readyToSell': 'అమ్మకానికి సిద్ధమా?',
      'publishMarketplaces': 'మార్కెట్‌ప్లేస్‌లలో ప్రచురించండి',
      'similarProducts': 'సారూప్య ఉత్పత్తులు',
      'ordersTitle': 'ఆర్డర్లు',
      'profileTitle': 'కళాకారుడి ప్రొఫైల్',
      'saveProduct': 'సేవ్ చేయండి',
      'delete': 'తొలగించు',
      'edit': 'సవరించు',
      'cancel': 'రద్దు చేయి',
      'noProductsYet': 'ఉత్పత్తులు లేవు',
      'noOrdersYet': 'ఆర్డర్లు లేవు',
    },
    'mr': {
      'appTitle': 'शिल्पसेतू AI',
      'tagline': 'तुमच्या कौशल्याचा डिजिटल साथीदार',
      'taglineHindi': 'तुमच्या कौशल्याचा डिजिटल साथीदार',
      'splashSubtitle': 'कारागिरांचे सबलीकरण.',
      'loginTitle': 'शिल्पसेतू AI मध्ये आपले स्वागत आहे',
      'loginSubtitle': 'लॉगिन करा',
      'phoneNumber': 'फोन नंबर',
      'password': 'पासवर्ड',
      'login': 'लॉगिन',
      'createAccount': 'नवीन खाते तयार करा',
      'continueAsDemoArtisan': 'डेमो कारागीर म्हणून सुरू ठेवा',
      'namasteArtisan': 'नमस्ते',
      'dashboardSubtitle': 'आपल्या व्यवसायाला पुढे नेऊया.',
      'addProduct': '+ उत्पादन जोडा',
      'quickActions': 'जलद AI साधने',
      'productStudio': '📸 उत्पादन स्टुडिओ',
      'voiceCatalog': '🎙 व्हॉइस कॅटलॉग',
      'smartPricing': '💰 स्मार्ट किंमत',
      'visualSearch': '🔎 व्हिज्युअल शोध',
      'statsProducts': 'एकूण उत्पादने',
      'statsPublished': 'प्रकाशित',
      'statsOrders': 'ऑर्डर्स',
      'statsEarnings': 'विक्री',
      'recentProducts': 'नुकतीच जोडलेली उत्पादने',
      'viewAll': 'सर्व पहा',
      'navHome': 'मुख्यपृष्ठ',
      'navProducts': 'उत्पादने',
      'navSearch': 'शोध',
      'navOrders': 'ऑर्डर्स',
      'navProfile': 'प्रोफाइल',
      'tabAll': 'सर्व',
      'tabDrafts': 'मसुदा',
      'tabPublished': 'प्रकाशित',
      'tabOutOfStock': 'स्टॉक संपला',
      'howToAdd': 'आपण काय करू इच्छिता?',
      'takePhoto': '📸 फोटो काढा',
      'chooseGallery': '🖼 गॅलरीतून निवडा',
      'describeVoice': '🎙 बोलून सांगा',
      'enterManually': '✍ स्वतः लिहा',
      'imageStudioTitle': 'AI फोटो स्टुडिओ',
      'voiceTitle': 'उत्पादनाबद्दल सांगा',
      'pricingTitle': 'स्मार्ट किंमत सहाय्यक 💰',
      'previewTitle': 'उत्पादन पूर्वावलोकन',
      'readyToSell': 'विक्रीसाठी तयार आहात?',
      'publishMarketplaces': 'बाजारपेठेत प्रकाशित करा',
      'similarProducts': 'समान उत्पादने',
      'ordersTitle': 'ऑर्डर्स',
      'profileTitle': 'कारागीर प्रोफाइल',
      'saveProduct': 'उत्पादन जतन करा',
      'delete': 'हटवा',
      'edit': 'संपादित करा',
      'cancel': 'रद्द करा',
      'noProductsYet': 'अद्याप उत्पादने नाहीत',
      'noOrdersYet': 'अद्याप ऑर्डर्स नाहीत',
    },
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get appTitle => translate('appTitle');
  String get tagline => translate('tagline');
  String get taglineHindi => translate('taglineHindi');
  String get splashSubtitle => translate('splashSubtitle');
  String get loginTitle => translate('loginTitle');
  String get loginSubtitle => translate('loginSubtitle');
  String get phoneNumber => translate('phoneNumber');
  String get password => translate('password');
  String get login => translate('login');
  String get createAccount => translate('createAccount');
  String get continueAsDemoArtisan => translate('continueAsDemoArtisan');
  String get namasteArtisan => translate('namasteArtisan');
  String get dashboardSubtitle => translate('dashboardSubtitle');
  String get addProduct => translate('addProduct');
  String get quickActions => translate('quickActions');
  String get productStudio => translate('productStudio');
  String get voiceCatalog => translate('voiceCatalog');
  String get smartPricing => translate('smartPricing');
  String get visualSearch => translate('visualSearch');
  String get statsProducts => translate('statsProducts');
  String get statsPublished => translate('statsPublished');
  String get statsOrders => translate('statsOrders');
  String get statsEarnings => translate('statsEarnings');
  String get recentProducts => translate('recentProducts');
  String get viewAll => translate('viewAll');
  String get navHome => translate('navHome');
  String get navProducts => translate('navProducts');
  String get navSearch => translate('navSearch');
  String get navOrders => translate('navOrders');
  String get navProfile => translate('navProfile');
  String get tabAll => translate('tabAll');
  String get tabDrafts => translate('tabDrafts');
  String get tabPublished => translate('tabPublished');
  String get tabOutOfStock => translate('tabOutOfStock');
  String get howToAdd => translate('howToAdd');
  String get takePhoto => translate('takePhoto');
  String get chooseGallery => translate('chooseGallery');
  String get describeVoice => translate('describeVoice');
  String get enterManually => translate('enterManually');
  String get imageStudioTitle => translate('imageStudioTitle');
  String get beforeAfter => translate('beforeAfter');
  String get removeBackground => translate('removeBackground');
  String get improveLighting => translate('improveLighting');
  String get enhanceColors => translate('enhanceColors');
  String get ecommerceCrop => translate('ecommerceCrop');
  String get enhancingImage => translate('enhancingImage');
  String get voiceTitle => translate('voiceTitle');
  String get voiceSubtitle => translate('voiceSubtitle');
  String get pricingTitle => translate('pricingTitle');
  String get previewTitle => translate('previewTitle');
  String get readyToSell => translate('readyToSell');
  String get publishMarketplaces => translate('publishMarketplaces');
  String get similarProducts => translate('similarProducts');
  String get ordersTitle => translate('ordersTitle');
  String get profileTitle => translate('profileTitle');
  String get saveProduct => translate('saveProduct');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get cancel => translate('cancel');
  String get noProductsYet => translate('noProductsYet');
  String get noOrdersYet => translate('noOrdersYet');
  String get ordersWillAppear => translate('ordersWillAppear');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'bn', 'ta', 'te', 'mr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
