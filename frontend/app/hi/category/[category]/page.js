import React from 'react';
import CategoryPage from '../../../../src/views/CategoryPage';
import Layout from '../../../../src/components/Layout';

export const revalidate = 604800; // 7 days Edge CDN cache

export async function generateMetadata({ params }) {
  const category = params.category;
  const categoryNames = {
    shloka: 'श्लोक',
    strotra: 'स्तोत्र',
    poem: 'कविता',
    katha: 'कथा',
    sankirtan: 'संकीर्तन',
    saint: 'संत',
    dham: 'धाम',
    literature: 'साहित्य'
  };
  const name = categoryNames[category] || category;
  return {
    title: `${name} संग्रह | Vrindopnishad`,
    description: `वृंदोपनिषद् पर पवित्र ${name} का संपूर्ण संग्रह पढ़ें।`,
    alternates: {
      canonical: `https://path.vrindopnishad.in/hi/category/${category}`,
    }
  };
}

export default function HindiCategoryRoute({ params }) {
  const decodedCategory = params ? decodeURIComponent(params.category || '') : '';
  return (
    <Layout>
      <CategoryPage key={decodedCategory} category={decodedCategory} />
    </Layout>
  );
}


