import React from 'react';
import LoginPage from '../../../src/views/LoginPage';
import Layout from '../../../src/components/Layout';

export const metadata = {
  title: 'साइन इन | Vrindopnishad',
  description: 'साइन इन करें और अपने दैनिक जाप और सुरक्षित पदों को ट्रैक करें।',
  alternates: {
    canonical: 'https://path.vrindopnishad.in/hi/login',
  }
};

export default function HiLoginRoute() {
  return (
    <Layout>
      <LoginPage />
    </Layout>
  );
}
