'use client';

import React, { useState, useEffect, useContext, useRef, useCallback } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { ApiContext } from '../contexts/ClientProviders';
import { Helmet } from 'react-helmet-async';
import './PromoLanding.css';

// ─── Scene Data ───────────────────────────────────────────────
const SCENES = [
  {
    id: 'swadhyaya',
    title: 'Daily Swadhyaya',
    subtitle: 'Sacred verses, delivered at dawn',
    poem: 'Each morning a verse arrives — a mirror held up to the soul. Read, reflect, absorb. The words of the saints are not instructions; they are invitations to stillness.',
    poemSignature: '— from the tradition of Pushti Marg',
    poemTitle: 'Stillness,\nas a practice.',
    meta: {
      type: 'Scripture',
      author: 'Mahaprabhu Vallabhacharya',
      work: 'Swadhyaya Collection',
      date: 'Daily · Dawn',
      origin: 'Pushti Marg Tradition',
      movement: 'Vaishnava · Bhakti'
    },
    image: 'https://images.unsplash.com/photo-1532375810709-75b1da00537c?auto=format&fit=crop&w=1280&q=80',
    hotspots: [
      { x: '30%', y: '35%', label: 'Verse Display', desc: 'Sanskrit verses rendered in traditional Devanagari with word-by-word translation and audio recitation by learned acharyas.' },
      { x: '70%', y: '55%', label: 'Audio Recitation', desc: 'Listen to authentic pronunciations of each verse, with adjustable speed and repeat functionality for memorization.' },
      { x: '50%', y: '80%', label: 'Daily Archive', desc: 'Never miss a day — every past swadhyaya is stored in your personal spiritual journal for reflection.' }
    ]
  },
  {
    id: 'chant',
    title: 'Chant Sanctuary',
    subtitle: 'A digital Japa Mala for the modern devotee',
    poem: 'The mala turns, bead by bead. Each name uttered is a step closer to the divine. In silence, in motion, in the rhythm of breath — the sanctuary is always open.',
    poemSignature: '— the practice of Naam Jap',
    poemTitle: 'Breath,\nas a prayer.',
    meta: {
      type: 'Meditation',
      author: 'Bhakti Yoga Tradition',
      work: 'Japa Mala · 108 Beads',
      date: 'Timeless',
      origin: 'Naam Jap Parampara',
      movement: 'Bhakti · Dhyana'
    },
    image: 'https://images.unsplash.com/photo-1600618528240-fb9fc964b853?auto=format&fit=crop&w=1280&q=80',
    hotspots: [
      { x: '50%', y: '40%', label: 'Virtual Mala', desc: 'A beautifully animated 108-bead japa mala with haptic feedback. Track your rounds and set daily chanting goals.' },
      { x: '25%', y: '65%', label: 'Mantra Library', desc: 'Choose from dozens of sacred mantras — each with meaning, pronunciation guide, and traditional melody.' },
      { x: '75%', y: '30%', label: 'Meditation Timer', desc: 'Set duration-based or round-based sessions. Gentle bells mark transitions without breaking concentration.' }
    ]
  },
  {
    id: 'calendar',
    title: 'Braj Calendar',
    subtitle: 'Live the divine Lilas as they unfold',
    poem: 'Time in Braj is not linear — it spirals. Each season, each tithi, each festival carries the fragrance of Shri Krishna\'s eternal play. The calendar is a portal.',
    poemSignature: '— the cycle of Braj',
    poemTitle: 'Time,\nas a spiral.',
    meta: {
      type: 'Calendar',
      author: 'Braj Mandal Traditions',
      work: 'Vikram Samvat Panchang',
      date: 'Vikram Samvat Era',
      origin: 'Braj · Vrindavan',
      movement: 'Lila · Utsav'
    },
    image: 'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?auto=format&fit=crop&w=1280&q=80',
    hotspots: [
      { x: '45%', y: '30%', label: 'Today\'s Lila', desc: 'Every day features the specific divine pastime associated with that tithi — narrated with context and devotional significance.' },
      { x: '65%', y: '70%', label: 'Festival Guide', desc: 'Complete guide to upcoming festivals with rituals, significance, and regional variations across Braj.' },
      { x: '20%', y: '55%', label: 'Tithi Tracker', desc: 'Precise Vikram Samvat dates, Ekadashi alerts, and personalized reminders for your observances.' }
    ]
  }
];

const BRAND_NAME = 'SANT VAANI';
const BRAND_TAGLINE = 'Where Silence Speaks';

const FAQ_ITEMS = [
  {
    q: "What is the core purpose of VrindaVaani?",
    a: "VrindaVaani is a digital sanctuary created to preserve and share the sacred literature, traditional Ragas, and calendar of Braj, with a special focus on the teachings of Vaishnava saints."
  },
  {
    q: "How does the Japa Mala / Chant Sanctuary function?",
    a: "It features an interactive 108-bead Japa Mala with haptic feedback, custom meditation timers, and a library of traditional mantras with audio and pronunciation guides."
  },
  {
    q: "Where does the scriptural content come from?",
    a: "Every verse, Sanskrit shloka, and translation is sourced directly from canonical Vaishnava texts and validated with traditional commentary for absolute authenticity."
  },
  {
    q: "Is VrindaVaani free to use?",
    a: "Yes. VrindaVaani is entirely non-commercial and run as a devotional service. There are no advertisements, subscriptions, or hidden charges."
  },
  {
    q: "How can I participate or contribute?",
    a: "You can contribute by translating verses, reporting corrections, or recording audio recitations. Please reach out via the feedback portal in the main application."
  }
];

// ─── Component ────────────────────────────────────────────────
export default function PromoLanding() {
  const { apiService } = useContext(ApiContext);
  const location = useLocation();
  const isHindiRoute = location.pathname.startsWith('/hi');

  // Loader
  const [loaderLineOn, setLoaderLineOn] = useState(false);
  const [lettersOn, setLettersOn] = useState([]);
  const [taglineOn, setTaglineOn] = useState(false);
  const [loaderDone, setLoaderDone] = useState(false);
  const [loaderGone, setLoaderGone] = useState(false);

  // Scenes
  const [currentScene, setCurrentScene] = useState(0); // 0=threshold, 1-3=works, 4=faq, 5=connect, 6=exit
  const [sceneDirection, setSceneDirection] = useState('next');
  const [isTransitioning, setIsTransitioning] = useState(false);
  const totalScenes = SCENES.length + 4; // threshold + works + faq + connect + exit

  // Cursor
  const [mousePos, setMousePos] = useState({ x: -100, y: -100 });
  const [auraPos, setAuraPos] = useState({ x: -100, y: -100 });
  const [cursorHover, setCursorHover] = useState(false);
  const [jsReady, setJsReady] = useState(false);
  const auraRef = useRef(null);
  const auraAnimRef = useRef(null);

  // Panel
  const [panelOpen, setPanelOpen] = useState(false);
  const [panelData, setPanelData] = useState(null);

  // FAQ Accordion State
  const [openFaq, setOpenFaq] = useState(null);

  const toggleFaq = (idx) => {
    setOpenFaq(prev => prev === idx ? null : idx);
  };

  // Stats
  const [stats, setStats] = useState({ verses: 120, sants: 12, books: 6, ragas: 8 });

  // Lang
  const [lang, setLang] = useState(isHindiRoute ? 'hi' : 'en');

  // Torch
  const canvasRefs = useRef([]);

  // ─── Loader Sequence ────────────────────────────────────────
  useEffect(() => {
    const letters = BRAND_NAME.split('');
    const timers = [];

    // Start line
    timers.push(setTimeout(() => setLoaderLineOn(true), 200));

    // Letters stagger
    letters.forEach((_, i) => {
      timers.push(setTimeout(() => {
        setLettersOn(prev => [...prev, i]);
      }, 600 + i * 120));
    });

    // Tagline
    timers.push(setTimeout(() => setTaglineOn(true), 600 + letters.length * 120 + 400));

    // Done
    timers.push(setTimeout(() => setLoaderDone(true), 600 + letters.length * 120 + 1800));

    // Remove from DOM
    timers.push(setTimeout(() => {
      setLoaderGone(true);
      setJsReady(true);
    }, 600 + letters.length * 120 + 3200));

    return () => timers.forEach(clearTimeout);
  }, []);

  // ─── Stats from API ────────────────────────────────────────
  useEffect(() => {
    const fetchCounts = async () => {
      try {
        const cached = sessionStorage.getItem('pm_stats');
        if (cached) {
          setStats(JSON.parse(cached));
          return;
        }
        const items = await apiService.getAllContent(null, 25000);
        let counts = { shloka: 0, strotra: 0, poem: 0, raga: 0, sant: 0, book: 0 };
        items.forEach(item => {
          const cat = item.category?.toLowerCase();
          if (cat === 'raga') counts.raga++;
          else if (cat === 'saint' || cat === 'sant') counts.sant++;
          else if (cat === 'book') counts.book++;
          else if (counts[cat] !== undefined) counts[cat]++;
        });
        const result = {
          verses: (counts.shloka + counts.strotra + counts.poem) || 120,
          sants: counts.sant || 12,
          books: counts.book || 6,
          ragas: counts.raga || 8
        };
        setStats(result);
        sessionStorage.setItem('pm_stats', JSON.stringify(result));
      } catch (e) {
        console.warn('Stats fetch failed, using fallbacks:', e);
      }
    };
    fetchCounts();
  }, [apiService]);

  // ─── Custom Cursor ──────────────────────────────────────────
  useEffect(() => {
    const isTouchDevice = window.matchMedia('(hover: none)').matches;
    if (isTouchDevice) return;

    const handleMouseMove = (e) => {
      setMousePos({ x: e.clientX, y: e.clientY });
    };

    window.addEventListener('mousemove', handleMouseMove, { passive: true });
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  // Smooth aura follow
  useEffect(() => {
    const isTouchDevice = window.matchMedia('(hover: none)').matches;
    if (isTouchDevice) return;

    let ax = mousePos.x, ay = mousePos.y;

    const animate = () => {
      ax += (mousePos.x - ax) * 0.08;
      ay += (mousePos.y - ay) * 0.08;
      setAuraPos({ x: ax, y: ay });
      auraAnimRef.current = requestAnimationFrame(animate);
    };

    auraAnimRef.current = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(auraAnimRef.current);
  }, [mousePos]);

  // ─── Scene Navigation ──────────────────────────────────────
  const goToScene = useCallback((target, dir) => {
    if (isTransitioning) return;
    if (target < 0 || target >= totalScenes) return;

    setIsTransitioning(true);
    setSceneDirection(dir);
    setPanelOpen(false);
    setOpenFaq(null); // Reset FAQ state on scene change
    setCurrentScene(target);

    setTimeout(() => setIsTransitioning(false), 1400);
  }, [isTransitioning, totalScenes]);

  // ─── Keyboard Navigation ───────────────────────────────────
  useEffect(() => {
    const handleKey = (e) => {
      if (panelOpen) {
        if (e.key === 'Escape') setPanelOpen(false);
        return;
      }
      if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
        e.preventDefault();
        goToScene(currentScene + 1, 'next');
      } else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
        e.preventDefault();
        goToScene(currentScene - 1, 'prev');
      }
    };

    window.addEventListener('keydown', handleKey);
    return () => window.removeEventListener('keydown', handleKey);
  }, [currentScene, panelOpen, goToScene]);

  // ─── Torch & 3D Parallax Tilt Effect ──────────────────────
  const handleCanvasMouseMove = useCallback((e, idx) => {
    const canvas = canvasRefs.current[idx];
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    const mx = ((e.clientX - rect.left) / rect.width * 100).toFixed(1) + '%';
    const my = ((e.clientY - rect.top) / rect.height * 100).toFixed(1) + '%';
    canvas.style.setProperty('--mx', mx);
    canvas.style.setProperty('--my', my);

    // Subtle 3D Tilt calculations
    const px = (e.clientX - rect.left) / rect.width - 0.5; // -0.5 to 0.5
    const py = (e.clientY - rect.top) / rect.height - 0.5; // -0.5 to 0.5
    canvas.style.setProperty('--rx', `${py * -10}deg`);
    canvas.style.setProperty('--ry', `${px * 10}deg`);
  }, []);

  const handleCanvasEnter = useCallback((idx) => {
    const canvas = canvasRefs.current[idx];
    if (canvas) canvas.classList.add('torch-active');
  }, []);

  const handleCanvasLeave = useCallback((idx) => {
    const canvas = canvasRefs.current[idx];
    if (canvas) {
      canvas.classList.remove('torch-active');
      canvas.style.setProperty('--rx', '0deg');
      canvas.style.setProperty('--ry', '0deg');
    }
  }, []);

  // Card Mouse Move spotlight tracking
  const handleCardMouseMove = useCallback((e) => {
    const card = e.currentTarget;
    const rect = card.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    card.style.setProperty('--c-mx', `${x}px`);
    card.style.setProperty('--c-my', `${y}px`);
  }, []);

  // ─── Hotspot Click ─────────────────────────────────────────
  const openHotspot = (sceneData, hotspot) => {
    setPanelData({
      eyebrow: sceneData.title,
      title: hotspot.label,
      description: hotspot.desc,
      feature: sceneData.id
    });
    setPanelOpen(true);
  };

  // ─── Scene Class Helper ────────────────────────────────────
  const getSceneClass = (index) => {
    if (index === currentScene) return 'pm-scene is-active';
    if (sceneDirection === 'next') {
      if (index === currentScene - 1) return 'pm-scene is-leaving-left';
      if (index === currentScene + 1) return 'pm-scene will-enter-next';
    } else {
      if (index === currentScene + 1) return 'pm-scene is-leaving-right';
      if (index === currentScene - 1) return 'pm-scene will-enter-prev';
    }
    return 'pm-scene';
  };

  // ─── Enter Museum ──────────────────────────────────────────
  const enterMuseum = () => goToScene(1, 'next');

  return (
    <>
      <Helmet>
        <title>Sant Vaani — Where Silence Speaks</title>
        <meta name="description" content="A cinematic digital sanctuary of sacred verses, chants, and the living calendar of Braj. Experience the wisdom of Pushti Marg saints." />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;1,300;1,400&family=Inter:wght@200;300;400;500&display=swap" rel="stylesheet" />
      </Helmet>

      <div className={`promo-museum${jsReady ? ' js-ready' : ''}`}>

        {/* ═══ LOADER ═══ */}
        {!loaderGone && (
          <div className={`pm-loader${loaderDone ? ' is-done' : ''}`}>
            <div className={`pm-loader-line${loaderLineOn ? ' is-on' : ''}`} />
            <div className="pm-loader-brand">
              <div className="pm-loader-logo">
                {BRAND_NAME.split('').map((char, i) => (
                  <span
                    key={i}
                    className={`ltr${lettersOn.includes(i) ? ' is-on' : ''}`}
                  >
                    {char === ' ' ? '\u00A0' : char}
                  </span>
                ))}
              </div>
              <div className={`pm-loader-tagline${taglineOn ? ' is-on' : ''}`}>
                {BRAND_TAGLINE}
              </div>
            </div>
            <div className={`pm-loader-line${loaderLineOn ? ' is-on' : ''}`} />
          </div>
        )}

        {/* ═══ CUSTOM CURSOR ═══ */}
        <div
          className={`pm-cursor${cursorHover ? ' is-hovering' : ''}`}
          style={{ transform: `translate(${mousePos.x}px, ${mousePos.y}px)` }}
        />
        <div
          className="pm-aura"
          ref={auraRef}
          style={{ transform: `translate(${auraPos.x}px, ${auraPos.y}px)` }}
        />

        {/* ═══ CHROME TOP ═══ */}
        <div className="pm-chrome pm-chrome-top">
          <div className="pm-brand"
            onMouseEnter={() => setCursorHover(true)}
            onMouseLeave={() => setCursorHover(false)}
          >
            SANT VAANI
            <small>VrindaVaani</small>
          </div>
          <div className="pm-top-tools">
            <div className="pm-lang-toggle">
              <button
                className={lang === 'en' ? 'is-active' : ''}
                onClick={() => setLang('en')}
                onMouseEnter={() => setCursorHover(true)}
                onMouseLeave={() => setCursorHover(false)}
              >EN</button>
              <span className="sep">|</span>
              <button
                className={lang === 'hi' ? 'is-active' : ''}
                onClick={() => setLang('hi')}
                onMouseEnter={() => setCursorHover(true)}
                onMouseLeave={() => setCursorHover(false)}
              >हिं</button>
            </div>
            <Link
              to={lang === 'hi' ? "/hi" : "/"}
              className="pm-sound-toggle"
              data-hover="true"
              onMouseEnter={() => setCursorHover(true)}
              onMouseLeave={() => setCursorHover(false)}
            >
              Enter App
              <span className="dot" style={{ background: 'var(--or)' }} />
            </Link>
          </div>
        </div>

        {/* ═══ CHROME BOTTOM ═══ */}
        <div className="pm-chrome pm-chrome-bottom">
          <div className="pm-progress">
            {Array.from({ length: totalScenes }).map((_, i) => (
              <button
                key={i}
                className={`pm-progress-dot${i === currentScene ? ' is-active' : ''}`}
                onClick={() => goToScene(i, i > currentScene ? 'next' : 'prev')}
                onMouseEnter={() => setCursorHover(true)}
                onMouseLeave={() => setCursorHover(false)}
                aria-label={`Go to scene ${i + 1}`}
              />
            ))}
          </div>
          <div className={`pm-hint${currentScene > 0 ? ' is-hidden' : ''}`}>
            <span className="key">←</span>
            <span className="key">→</span>
            Navigate
          </div>
        </div>

        {/* ═══ SCROLL INDICATOR (Hubtown-inspired) ═══ */}
        <div className={`pm-scroll-indicator${currentScene > 0 ? ' is-hidden' : ''}`}>
          Scroll
        </div>

        {/* ═══ STAGE ═══ */}
        <div className="pm-stage">

          {/* ── Scene 0: Threshold ── */}
          <div className={`${getSceneClass(0)} pm-scene-threshold`} data-scene="0">
            <div className="pm-threshold-bg-wrap">
              <div
                className="pm-threshold-bg"
                style={{
                  backgroundImage: `url('https://images.unsplash.com/photo-1548013146-72479768bada?auto=format&fit=crop&w=1920&q=80')`
                }}
              />
              <div className="pm-threshold-beam" />
              <div className="pm-threshold-fog" />
              <div className="pm-threshold-vignette" />
              <div className="pm-threshold-spot" />
            </div>

            <div className="pm-threshold-inner">
              <div className="pm-threshold-mark">
                {lang === 'en' ? 'A Digital Sanctuary' : 'एक डिजिटल मंदिर'}
              </div>

              <h1 className="pm-threshold-title">
                {lang === 'en' ? (
                  <><span className="title-line title-line-where">Where</span><span className="title-line title-line-silence"><em>Silence</em></span><span className="title-line title-line-speaks">Speaks</span></>
                ) : (
                  <><span className="title-line title-line-where">जहाँ</span><span className="title-line title-line-silence"><em>मौन</em></span><span className="title-line title-line-speaks">बोलता है</span></>
                )}
              </h1>

              <p className="pm-threshold-sub">
                {lang === 'en'
                  ? 'Sacred verses, chants, and the living calendar of Braj — curated from the timeless wisdom of Pushti Marg saints.'
                  : 'पवित्र श्लोक, भजन, और ब्रज का जीवंत पंचांग — पुष्टि मार्ग के संतों की शाश्वत वाणी से संकलित।'
                }
              </p>

              <div className="pm-threshold-list">
                {lang === 'en' ? (
                  <>
                    Swadhyaya <span>·</span> Chanting <span>·</span> Calendar <span>·</span> Saints
                  </>
                ) : (
                  <>
                    स्वाध्याय <span>·</span> जप <span>·</span> पंचांग <span>·</span> संत
                  </>
                )}
              </div>

              <div className="pm-stats-row">
                <div className="pm-stat-item">
                  <span className="pm-stat-num">{stats.verses}+</span>
                  <span className="pm-stat-label">{lang === 'en' ? 'Sacred Verses' : 'पवित्र श्लोक'}</span>
                </div>
                <div className="pm-stat-item">
                  <span className="pm-stat-num">{stats.sants}+</span>
                  <span className="pm-stat-label">{lang === 'en' ? 'Saints' : 'संत'}</span>
                </div>
                <div className="pm-stat-item">
                  <span className="pm-stat-num">{stats.books}+</span>
                  <span className="pm-stat-label">{lang === 'en' ? 'Sacred Texts' : 'ग्रंथ'}</span>
                </div>
                <div className="pm-stat-item">
                  <span className="pm-stat-num">{stats.ragas}+</span>
                  <span className="pm-stat-label">{lang === 'en' ? 'Ragas' : 'राग'}</span>
                </div>
              </div>

              <button
                className="pm-enter"
                onClick={enterMuseum}
                onMouseEnter={() => setCursorHover(true)}
                onMouseLeave={() => setCursorHover(false)}
              >
                {lang === 'en' ? 'Begin the Journey' : 'यात्रा आरम्भ करें'}
              </button>
            </div>
          </div>

          {/* ── Scenes 1-3: Works ── */}
          {SCENES.map((scene, idx) => {
            const sceneIdx = idx + 1;
            return (
              <div
                key={scene.id}
                className={getSceneClass(sceneIdx)}
                data-scene={sceneIdx}
              >
                <div className="pm-work-num">{String(sceneIdx).padStart(2, '0')}</div>

                {/* Vertical scene label (Hubtown-inspired) */}
                <div className="pm-scene-label">{scene.title}</div>

                {/* Scene counter (Hubtown-inspired) */}
                <div className="pm-scene-counter">
                  <span className="current">{String(sceneIdx).padStart(2, '0')}</span>
                  <span className="sep">/</span>
                  <span>{String(SCENES.length).padStart(2, '0')}</span>
                </div>

                <div className="pm-scene-work">
                  {/* Left: Meta — lunchlab.fr structured labels */}
                  <div className="pm-work-meta">
                    <span className="type-tag">{scene.meta.type}</span>
                    <div className="pm-meta-field">
                      <span className="meta-label">Author</span>
                      <span className="meta-value">{scene.meta.author}</span>
                    </div>
                    <div className="pm-meta-field">
                      <span className="meta-label">Work</span>
                      <span className="meta-value">{scene.meta.work}</span>
                    </div>
                    <div className="pm-meta-field">
                      <span className="meta-label">Date</span>
                      <span className="meta-value">{scene.meta.date}</span>
                    </div>
                    <div className="pm-meta-field">
                      <span className="meta-label">Origin</span>
                      <span className="meta-value">{scene.meta.origin}</span>
                    </div>
                    <div className="pm-meta-field">
                      <span className="meta-label">Movement</span>
                      <span className="meta-value">{scene.meta.movement}</span>
                    </div>
                  </div>

                  {/* Center: Artwork */}
                  <div className="pm-work-frame">
                    <div
                      className="pm-work-canvas"
                      ref={el => canvasRefs.current[idx] = el}
                      onMouseMove={(e) => handleCanvasMouseMove(e, idx)}
                      onMouseEnter={() => handleCanvasEnter(idx)}
                      onMouseLeave={() => handleCanvasLeave(idx)}
                    >
                      <img
                        className="pm-work-img"
                        src={scene.image}
                        alt={scene.title}
                        loading={idx === 0 ? 'eager' : 'lazy'}
                      />
                      <div className="pm-work-shade" />
                      <div className="pm-work-glow" />
                      <div className="pm-work-grain" />

                      {/* Hotspots */}
                      {scene.hotspots.map((hs, hi) => (
                        <button
                          key={hi}
                          className="pm-hotspot"
                          style={{ '--hx': hs.x, '--hy': hs.y }}
                          onClick={(e) => {
                            e.stopPropagation();
                            openHotspot(scene, hs);
                          }}
                          onMouseEnter={() => setCursorHover(true)}
                          onMouseLeave={() => setCursorHover(false)}
                          aria-label={hs.label}
                        />
                      ))}

                      {/* lunchlab.fr-style canvas tools: / WORK + REVEAL */}
                      <div className="pm-canvas-tools">
                        <button
                          className="pm-canvas-btn"
                          onClick={(e) => {
                            e.stopPropagation();
                            openHotspot(scene, {
                              label: scene.title,
                              desc: scene.poem
                            });
                          }}
                          onMouseEnter={() => setCursorHover(true)}
                          onMouseLeave={() => setCursorHover(false)}
                        >
                          / Work
                        </button>
                        <button
                          className="pm-canvas-btn"
                          onClick={(e) => {
                            e.stopPropagation();
                            openHotspot(scene, {
                              label: 'Explore ' + scene.title,
                              desc: scene.subtitle + '. ' + scene.poem
                            });
                          }}
                          onMouseEnter={() => setCursorHover(true)}
                          onMouseLeave={() => setCursorHover(false)}
                        >
                          Reveal
                        </button>
                      </div>
                    </div>

                    <div className="pm-work-cartouche">
                      {scene.subtitle}
                    </div>
                  </div>

                  {/* Right: Poem — lunchlab.fr style */}
                  <div className="pm-work-poem">
                    <h2 className="poem-title-lunchlab">{scene.poemTitle.split('\n').map((line, i) => (
                      <span key={i}>{line}<br /></span>
                    ))}</h2>
                    <p>{scene.poem}</p>
                    <span className="signature">{scene.poemSignature}</span>
                  </div>
                </div>
              </div>
            );
          })}

          {/* ── Scene 4: FAQ (Got Questions?) ── */}
          <div className={`${getSceneClass(totalScenes - 2)} pm-scene-faq`} data-scene={totalScenes - 2}>
            <div className="pm-faq-inner">
              <div className="pm-faq-header">
                <div className="pm-faq-eyebrow">
                  STAGE 04 - FAQ
                </div>
                <div className="pm-faq-status">
                  <span className="status-dot">◆</span> Query resolved.
                </div>
              </div>

              <div className="pm-faq-layout">
                {/* Left side: Monospace pixelated style layout */}
                <div className="pm-faq-left">
                  <h2 className="pm-faq-title">
                    GOT<br />QUESTIONS?
                  </h2>
                  <p className="pm-faq-quote">
                    "Checking the codex..."
                  </p>
                </div>

                {/* Right side: Accordion list */}
                <div className="pm-faq-right">
                  <div className="pm-faq-list">
                    {FAQ_ITEMS.map((item, idx) => (
                      <div 
                        key={idx} 
                        className={`pm-faq-item${openFaq === idx ? ' is-open' : ''}`}
                      >
                        <button
                          className="pm-faq-trigger"
                          onClick={() => toggleFaq(idx)}
                          onMouseEnter={() => setCursorHover(true)}
                          onMouseLeave={() => setCursorHover(false)}
                          aria-expanded={openFaq === idx}
                          aria-controls={`faq-answer-${idx}`}
                        >
                          <span className="faq-num">{String(idx + 1).padStart(2, '0')}</span>
                          <span className="faq-q">{item.q}</span>
                          <span className="faq-icon">◆</span>
                        </button>
                        <div 
                          id={`faq-answer-${idx}`}
                          className={`faq-answer-wrap${openFaq === idx ? ' is-open' : ''}`}
                        >
                          <div className="faq-answer-inner">
                            <p className="faq-a">{item.a}</p>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              
              <div className="pm-faq-footer">
                MORE QUESTIONS? REACH OUT DIRECTLY <span className="footer-dots">◆ ◆ ◆</span>
              </div>
            </div>
          </div>

          {/* ── Scene 5: Connect (Shakanksh-inspired CTA) ── */}
          <div className={`${getSceneClass(totalScenes - 2)} pm-scene-connect`} data-scene={totalScenes - 2}>
            <div className="pm-connect-inner">
              <div className="pm-connect-left">
                <div className="pm-connect-available">
                  <span className="avail-dot" /> Available for devotees
                </div>
                <h2 className="pm-connect-title">
                  {lang === 'en' ? (<>LET'S BEGIN<br/>TOGETHER.</>) : (<>आइए साथ<br/>आरम्भ करें।</>)}
                </h2>
                <p className="pm-connect-sub">
                  {lang === 'en'
                    ? 'Choose how you\'d like to connect. Pick the channel that fits you best.'
                    : 'कैसे जुड़ना चाहते हैं चुनें। अपनी सुविधानुसार माध्यम चुनें।'
                  }
                </p>
              </div>
              <div className="pm-connect-right">
                {/* Channel 01 — LIVE */}
                <div 
                  className="pm-channel-card"
                  onMouseMove={handleCardMouseMove}
                >
                  <div className="channel-tags">
                    <span className="channel-tag tag-live">Live</span>
                    <span className="channel-num">Channel 01</span>
                  </div>
                  <h3 className="channel-title">{lang === 'en' ? 'Enter the App' : 'ऐप में प्रवेश करें'}</h3>
                  <p className="channel-desc">
                    {lang === 'en'
                      ? 'Explore the full sanctuary. Browse sacred verses, chant with the Japa Mala, and follow the living Braj Calendar.'
                      : 'पूर्ण मंदिर का अन्वेषण करें। पवित्र श्लोक पढ़ें, जपमाला से जप करें, और ब्रज पंचांग देखें।'
                    }
                  </p>
                  <Link
                    to={lang === 'hi' ? "/hi" : "/"}
                    className="channel-btn"
                    onMouseEnter={() => setCursorHover(true)}
                    onMouseLeave={() => setCursorHover(false)}
                  >
                    {lang === 'en' ? 'Enter Sanctuary' : 'मंदिर में प्रवेश करें'}
                  </Link>
                </div>
                {/* Channel 02 — ASYNC */}
                <div 
                  className="pm-channel-card"
                  onMouseMove={handleCardMouseMove}
                >
                  <div className="channel-tags">
                    <span className="channel-tag tag-async">Async</span>
                    <span className="channel-num">Channel 02</span>
                  </div>
                  <h3 className="channel-title">{lang === 'en' ? 'Daily Swadhyaya' : 'दैनिक स्वाध्याय'}</h3>
                  <p className="channel-desc">
                    {lang === 'en'
                      ? 'Receive a sacred verse every morning. No apps, no scheduling. Pure devotion delivered to your notification.'
                      : 'हर सुबह एक पवित्र श्लोक प्राप्त करें। बिना ऐप, बिना अनुसूची। शुद्ध भक्ति सीधे आपके पास।'
                    }
                  </p>
                  <Link
                    to={lang === 'hi' ? "/hi" : "/"}
                    className="channel-btn"
                    onMouseEnter={() => setCursorHover(true)}
                    onMouseLeave={() => setCursorHover(false)}
                  >
                    {lang === 'en' ? 'Start Now' : 'अभी आरम्भ करें'}
                  </Link>
                </div>
              </div>
            </div>
          </div>

          {/* ── Scene 6: Exit ── */}
          <div className={`${getSceneClass(totalScenes - 1)} pm-scene-exit`} data-scene={totalScenes - 1}>
            <div className="pm-exit-inner">
              <div className="pm-exit-line">
                {lang === 'en' ? (
                  <>The journey inward<br/>has no <em>destination</em></>
                ) : (
                  <>अंतर्यात्रा का<br/>कोई <em>गंतव्य</em> नहीं</>
                )}
              </div>
              <div className="pm-exit-sub">
                {lang === 'en'
                  ? 'Begin your practice with Sant Vaani'
                  : 'संत वाणी के साथ अपनी साधना आरम्भ करें'
                }
              </div>
              <button
                className="pm-exit-restart"
                onClick={() => goToScene(0, 'prev')}
                onMouseEnter={() => setCursorHover(true)}
                onMouseLeave={() => setCursorHover(false)}
              >
                {lang === 'en' ? 'Revisit the Journey' : 'यात्रा पुनः देखें'}
              </button>
            </div>
          </div>
        </div>

        {/* ═══ MOBILE NAV ARROWS ═══ */}
        <button
          className={`pm-nav-arrow pm-nav-prev${currentScene <= 0 ? ' is-hidden' : ''}`}
          onClick={() => goToScene(currentScene - 1, 'prev')}
          aria-label="Previous scene"
        >
          ‹
        </button>
        <button
          className={`pm-nav-arrow pm-nav-next${currentScene >= totalScenes - 1 ? ' is-hidden' : ''}`}
          onClick={() => goToScene(currentScene + 1, 'next')}
          aria-label="Next scene"
        >
          ›
        </button>

        {/* ═══ SIDE PANEL ═══ */}
        <div
          className={`pm-panel-backdrop${panelOpen ? ' is-open' : ''}`}
          onClick={() => setPanelOpen(false)}
        />
        <div className={`pm-panel${panelOpen ? ' is-open' : ''}`}>
          <button
            className="pm-panel-close"
            onClick={() => setPanelOpen(false)}
            onMouseEnter={() => setCursorHover(true)}
            onMouseLeave={() => setCursorHover(false)}
          >
            ×
          </button>
          {panelData && (
            <>
              <div className="pm-panel-eyebrow">
                {panelData.eyebrow}
              </div>
              <div className="pm-panel-title">{panelData.title}</div>
              <div className="pm-panel-section">
                <h4>Description</h4>
                <p>{panelData.description}</p>
              </div>
              <div className="pm-panel-section is-quote">
                <p>
                  {lang === 'en'
                    ? '"Every feature in Sant Vaani is designed to deepen your connection with the divine — not to distract from it."'
                    : '"संत वाणी की प्रत्येक विशेषता आपको परमात्मा से और गहरे जोड़ने के लिए बनाई गई है — विचलित करने के लिए नहीं।"'
                  }
                </p>
              </div>

              {/* Hubtown-style numbered navigation */}
              <div className="pm-panel-nav-list">
                {SCENES.map((s, i) => (
                  <button
                    key={s.id}
                    className="pm-panel-nav-item"
                    onClick={() => {
                      setPanelOpen(false);
                      goToScene(i + 1, i + 1 > currentScene ? 'next' : 'prev');
                    }}
                    onMouseEnter={() => setCursorHover(true)}
                    onMouseLeave={() => setCursorHover(false)}
                  >
                    {s.title}
                    <span className="nav-num">{String(i + 1).padStart(2, '0')}</span>
                  </button>
                ))}
              </div>
            </>
          )}
        </div>
      </div>
    </>
  );
}
