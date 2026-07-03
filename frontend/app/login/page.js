import React from 'react';
import LoginPage from '../../src/views/LoginPage';
import Layout from '../../src/components/Layout';

export const metadata = {
  title: 'Sign In | Vrindopnishad',
  description: 'Sign in to Vrindopnishad to track your daily chanting, bookmarks, and read sacred verses.',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/login',
  }
};

export default function LoginRoute() {
  return (
    <Layout>
      <LoginPage />
    </Layout>
  );
}
