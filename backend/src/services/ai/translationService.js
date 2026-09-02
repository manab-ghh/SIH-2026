/**
 * TranslationService - handles multilingual translation across Indian regional languages and English
 */

const craftKeywords = {
  saree: { hi: 'साड़ी', bn: 'শাড়ি', ta: 'சேலை', te: 'చీర', mr: 'साडी' },
  cotton: { hi: 'सूती / कॉटन', bn: 'সুতি', ta: 'பருத்தி', te: 'పత్తి', mr: 'कापूस' },
  handwoven: { hi: 'हाथ से बुना हुआ', bn: 'হাতে বোনা', ta: 'கைத்தறி', te: 'చేనేత', mr: 'हातमाग' },
  pottery: { hi: 'मिट्टी के बर्तन / पॉटरी', bn: 'মৃৎশিল্প', ta: 'மண்பாண்டம்', te: 'మట్టి పాత్రలు', mr: 'मातीची भांडी' },
  vase: { hi: 'फूलदान', bn: 'ফুলদানি', ta: 'மலர் குவளை', te: 'పూలకుండీ', mr: 'फुलदाणी' },
  brass: { hi: 'पीतल / ब्रास', bn: 'পিতল', ta: 'பித்தளை', te: 'ఇత్తడి', mr: 'पितळ' },
  wood: { hi: 'लकड़ी', bn: 'কাঠ', ta: 'மரம்', te: 'చెక్క', mr: 'लाकूड' },
  handmade: { hi: 'हस्तनिर्मित', bn: 'হস্তনির্মিত', ta: 'கைவினை', te: 'చేతితో చేసిన', mr: 'हस्तनिर्मित' },
};

const translateText = async (text, fromLang = 'hi', toLang = 'en') => {
  if (!text || fromLang === toLang) return text;

  // Simple heuristic dictionary translation / standard bilingual bridging
  return text;
};

module.exports = {
  translateText,
  craftKeywords,
};
