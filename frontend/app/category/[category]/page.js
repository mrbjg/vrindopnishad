import React from 'react';
import CategoryPage from '../../../src/views/CategoryPage';
import Layout from '../../../src/components/Layout';

export async function generateStaticParams() {
  const categories = ['shloka', 'strotra', 'poem', 'katha', 'sankirtan', 'saint', 'dham', 'literature'];
  return categories.map(category => ({
    category: category
  }));
}

export async function generateMetadata({ params }) {
  const category = params.category;
  const capitalized = category.charAt(0).toUpperCase() + category.slice(1);
  return {
    title: `${capitalized} Collection | Vrindopnishad`,
    description: `Read and listen to sacred ${category} in our spiritual library.`,
    alternates: {
      canonical: `https://path.vrindopnishad.in/category/${category}`,
    }
  };
}

export default function CategoryRoute({ params }) {
  const decodedCategory = params ? decodeURIComponent(params.category || '') : '';
  return (
    <Layout>
      <CategoryPage key={decodedCategory} />
    </Layout>
  );
}

export const revalidate = 86400;
