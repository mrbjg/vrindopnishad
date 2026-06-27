export const metadata = {
  metadataBase: new URL('https://path.vrindopnishad.in'),
  title: 'वृंदोपनिषद् | श्री वृन्दावन धाम सन्त वाणी',
  description: 'सन्त, ग्रन्थ, वाणी, और वृन्दावन धाम की रसिक शिक्षाओं के लिए एक पूर्ण सर्वर-रेंडर किया गया सर्च-इंजन अनुकूलित मंच।',
  alternates: {
    canonical: '/hi',
    languages: {
      'en': '/',
      'hi': '/hi',
    },
  },
  keywords: [
    'वृंदोपनिषद्', 'राधावल्लभ संप्रदाय', 'ब्रज साहित्य', 
    'रसिक संत', 'ग्रन्थ', 'पदावली', 'वृन्दावन भक्ति', 
    'वैष्णव इतिहास', 'भक्ति काव्य', 'श्लोक अर्थ'
  ],
  openGraph: {
    title: 'वृंदोपनिषद् | श्री वृन्दावन धाम सन्त वाणी',
    description: 'सन्त, ग्रन्थ, वाणी, और वृन्दावन धाम की रसिक शिक्षाओं के लिए एक पूर्ण सर्वर-रेंडर किया गया सर्च-इंजन अनुकूलित मंच।',
    url: 'https://path.vrindopnishad.in/hi',
    siteName: 'वृंदोपनिषद्',
    locale: 'hi_IN',
    type: 'website',
    images: [
      {
        url: '/official-logo-dark.svg',
        width: 1200,
        height: 630,
        alt: 'वृंदोपनिषद् लोगो',
      }
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'वृंदोपनिषद् | श्री वृन्दावन धाम सन्त वाणी',
    description: 'सन्त, ग्रन्थ, वाणी, और वृन्दावन धाम की रसिक शिक्षाओं के लिए एक पूर्ण सर्वर-रेंडर किया गया सर्च-इंजन अनुकूलित मंच।',
    images: ['/official-logo-dark.svg'],
  },
};

export default function HindiLayout({ children }) {
  return (
    <div lang="hi">
      {children}
    </div>
  );
}
