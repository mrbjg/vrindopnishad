'use client';

import React, { useState } from 'react';
import { Helmet } from 'react-helmet-async';
import { Mail, MapPin, Send, MessageSquare } from 'lucide-react';
import { generateArticleSchema, generateBreadcrumbSchema, SITE_URL } from '../../utils/seoSchemas';
import SEOFooter from '../../components/SEOFooter';

const ContactPage = () => {
  const pageUrl = `${SITE_URL}/contact`;
  const title = 'Contact Us — Get in touch with Vrindopnishad Team';
  const description = 'Reach out to the editors, Sanskrit scholars, and developers of Vrindopnishad. Submit feedback, correct scriptural text, or collaborate with us.';

  const [formData, setFormData] = useState({ name: '', email: '', message: '' });
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    // Simulate contact form submission
    console.log('Form submission:', formData);
    setSubmitted(true);
  };

  return (
    <div className="animate-fade-in max-w-4xl mx-auto">
      <Helmet>
        <title>{title}</title>
        <meta name="description" content={description} />
        <link rel="canonical" href={pageUrl} />
        <meta property="og:title" content={title} />
        <meta property="og:description" content={description} />
        <meta property="og:url" content={pageUrl} />
        <meta property="og:type" content="article" />
        <script type="application/ld+json">{JSON.stringify(generateArticleSchema(title, description, pageUrl))}</script>
        <script type="application/ld+json">{JSON.stringify(generateBreadcrumbSchema([{ name: 'Home', path: '/' }, { name: 'Contact', path: '/contact' }]))}</script>
      </Helmet>

      <article className="py-12">
        <header className="mb-12">
          <div className="badge border-purple-400/30 text-purple-400/80 bg-purple-400/5 mb-4">Connect</div>
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-white leading-tight">Contact Vrindopnishad Team</h1>
          <p className="text-lg text-white/60 leading-relaxed">Have scriptural corrections, translation suggestions, or want to collaborate? We would love to hear from you.</p>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
          {/* Left column: Contact Info details */}
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-white/95 mb-4">Ashram & Digital Office</h2>
            <p className="text-white/75 leading-relaxed">
              Our editorial and verification workflow is conducted directly from Vrindavan Dham. Scholars and practitioners meet regularly to verify manuscripts.
            </p>

            <div className="space-y-4">
              <div className="flex items-start gap-4">
                <div className="p-3 rounded-xl bg-white/[0.03] border border-white/5 text-amber-400 shrink-0">
                  <MapPin size={18} />
                </div>
                <div>
                  <h4 className="text-xs font-bold text-white/40 uppercase tracking-wide">Location</h4>
                  <p className="text-sm text-white/80 mt-0.5">Lohia Bazar Road, Near Radhavallabh Temple, Vrindavan, Uttar Pradesh, 281121, India</p>
                </div>
              </div>

              <div className="flex items-start gap-4">
                <div className="p-3 rounded-xl bg-white/[0.03] border border-white/5 text-purple-400 shrink-0">
                  <Mail size={18} />
                </div>
                <div>
                  <h4 className="text-xs font-bold text-white/40 uppercase tracking-wide">Email Coordinates</h4>
                  <p className="text-sm text-white/80 mt-0.5 hover:text-primary"><a href="mailto:info@vrindopnishad.in">info@vrindopnishad.in</a></p>
                </div>
              </div>

              <div className="flex items-start gap-4">
                <div className="p-3 rounded-xl bg-white/[0.03] border border-white/5 text-emerald-400 shrink-0">
                  <MessageSquare size={18} />
                </div>
                <div>
                  <h4 className="text-xs font-bold text-white/40 uppercase tracking-wide">Lineage Collaboration</h4>
                  <p className="text-sm text-white/80 mt-0.5">Open to all recognized Vaishnava traditions seeking to digitize and publish their archives.</p>
                </div>
              </div>
            </div>
          </div>

          {/* Right column: Interactive form */}
          <div className="p-6 rounded-3xl border border-white/10 bg-white/[0.02] backdrop-blur-xl">
            {submitted ? (
              <div className="h-full flex flex-col items-center justify-center text-center py-8">
                <div className="w-12 h-12 rounded-full bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 mb-4">
                  <Send size={18} />
                </div>
                <h3 className="text-lg font-bold text-white mb-2">Message Sent Successfully</h3>
                <p className="text-xs text-white/50 max-w-xs">Thank you for writing. Our editorial team will review your message and reply as soon as possible.</p>
                <button onClick={() => setSubmitted(false)} className="mt-6 px-4 py-2 rounded-xl bg-white/[0.05] hover:bg-white/[0.1] text-xs text-white border border-white/10 transition-colors">
                  Send Another Message
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4">
                <h3 className="text-lg font-bold text-white mb-4">Feedback & Support</h3>

                <div className="space-y-1">
                  <label htmlFor="name-input" className="text-[10px] text-white/50 font-bold uppercase tracking-wider block">Full Name</label>
                  <input
                    id="name-input"
                    type="text"
                    required
                    placeholder="Enter your name"
                    className="w-full bg-white/[0.03] border border-white/10 focus:border-primary/50 rounded-xl px-4 py-2.5 text-xs text-white placeholder:text-white/30 focus:outline-none transition-colors"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  />
                </div>

                <div className="space-y-1">
                  <label htmlFor="email-input" className="text-[10px] text-white/50 font-bold uppercase tracking-wider block">Email Address</label>
                  <input
                    id="email-input"
                    type="email"
                    required
                    placeholder="name@example.com"
                    className="w-full bg-white/[0.03] border border-white/10 focus:border-primary/50 rounded-xl px-4 py-2.5 text-xs text-white placeholder:text-white/30 focus:outline-none transition-colors"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  />
                </div>

                <div className="space-y-1">
                  <label htmlFor="message-input" className="text-[10px] text-white/50 font-bold uppercase tracking-wider block">Message Details</label>
                  <textarea
                    id="message-input"
                    rows={4}
                    required
                    placeholder="Type your feedback, scriptural corrections, or questions here..."
                    className="w-full bg-white/[0.03] border border-white/10 focus:border-primary/50 rounded-xl px-4 py-2.5 text-xs text-white placeholder:text-white/30 focus:outline-none transition-colors resize-none"
                    value={formData.message}
                    onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                  />
                </div>

                <button
                  type="submit"
                  className="w-full flex items-center justify-center gap-2 py-3 rounded-xl bg-primary text-black font-bold text-xs hover:bg-primary-hover shadow-lg hover:shadow-primary/10 transition-all duration-300"
                >
                  <Send size={12} />
                  <span>Send Message</span>
                </button>
              </form>
            )}
          </div>
        </div>
      </article>
      <SEOFooter />
    </div>
  );
};

export default ContactPage;
