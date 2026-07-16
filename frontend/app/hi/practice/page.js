import React from 'react';
import DailyPracticePage from '../../../src/views/DailyPracticePage';
import Layout from '../../../src/components/Layout';

export const metadata = {
  title: 'नित्य नियम व दैनिक साधना | Vrindopnishad',
  description: 'दैनिक साधना डैशबोर्ड। हनुमान चालीसा, आरती, और स्तोत्रों के पाठ पढ़ें और अपनी दैनिक पूजा नियम को ट्रैक करें।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi/practice',
  }
};

export default function HindiPracticeRoute() {
  return (
    <Layout>
      <DailyPracticePage />
    </Layout>
  );
}
