import React from 'react';
import DailyPracticePage from '../../src/views/DailyPracticePage';
import Layout from '../../src/components/Layout';

export const metadata = {
  title: 'Daily Spiritual Practice (Nitya Niyam) | Vrindopnishad',
  description: 'Your daily spiritual practice dashboard. Access Aarti, Hanuman Chalisa, Stutis, and track your daily check-offs and streaks.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/practice',
  }
};

export default function PracticeRoute() {
  return (
    <Layout>
      <DailyPracticePage />
    </Layout>
  );
}
