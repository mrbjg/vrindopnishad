export const metadata = {
  title: 'वृंदोपनिषद् | श्री वृन्दावन धाम सन्त वाणी',
  description: 'सन्त, ग्रन्थ, वाणी, और वृन्दावन धाम की रसिक शिक्षाओं के लिए एक पूर्ण सर्वर-रेंडर किया गया सर्च-इंजन अनुकूलित मंच।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi',
  },
};

export default function HindiLayout({ children }) {
  return (
    <div lang="hi">
      {children}
    </div>
  );
}
