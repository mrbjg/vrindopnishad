import React, { useEffect, useRef } from 'react';
import { useSettings, isLightTheme } from '../contexts/SettingsContext';

const CelestialParticles = () => {
  const canvasRef = useRef(null);
  const { settings } = useSettings();
  const settingsTheme = settings.theme || 'light';
  const isAuthPage = window.location.pathname.includes('/login');
  const theme = isAuthPage ? 'space' : settingsTheme;

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animationFrameId;
    let particles = [];
    let shootingStars = [];
    let birds = [];
    
    // Adjust caps for performance (mobile vs desktop)
    const isMobile = window.innerWidth < 768;

    // Pre-render moon crescent if night theme
    let moonCanvas = null;
    if (theme === 'night') {
      moonCanvas = document.createElement('canvas');
      moonCanvas.width = 100;
      moonCanvas.height = 100;
      const mCtx = moonCanvas.getContext('2d');
      if (mCtx) {
        const mX = 50;
        const mY = 50;
        const mRadius = 35;
        
        mCtx.beginPath();
        mCtx.arc(mX, mY, mRadius, 0, Math.PI * 2);
        mCtx.fillStyle = 'rgba(254, 243, 199, 0.85)';
        mCtx.fill();
        
        mCtx.globalCompositeOperation = 'destination-out';
        mCtx.beginPath();
        mCtx.arc(mX - 12, mY - 4, mRadius + 2, 0, Math.PI * 2);
        mCtx.fill();
      }
    }
    
    let particleCount = isMobile ? 25 : 60;
    if (theme === 'snow' || theme === 'winter') {
      particleCount = isMobile ? 60 : 140;
    } else if (theme === 'rainy') {
      particleCount = isMobile ? 80 : 180;
    } else if (theme === 'forest') {
      particleCount = isMobile ? 25 : 60;
    } else if (theme === 'ocean') {
      particleCount = isMobile ? 30 : 75;
    } else if (theme === 'void') {
      particleCount = isMobile ? 20 : 45;
    } else if (theme === 'waterfall') {
      particleCount = isMobile ? 90 : 190;
    } else if (theme === 'mountain_morning') {
      particleCount = isMobile ? 45 : 100;
    } else if (theme === 'night') {
      particleCount = isMobile ? 85 : 190;
    } else if (theme === 'space') {
      particleCount = isMobile ? 100 : 220;
    }



    // Particle constructor helper
    const createParticle = (initY = false) => {
      const w = canvas.width;
      const h = canvas.height;
      const randX = Math.random() * w;
      const randY = initY ? Math.random() * h : h + 10;

      // Base configuration - tiny shimmering dots like in sky
      let p = {
        x: randX,
        y: randY,
        radius: Math.random() * (isMobile ? 0.45 : 0.65) + 0.15, // Shimmering dot sizes
        vx: (Math.random() - 0.5) * 0.03, // Slower horizontal drift
        vy: -(Math.random() * 0.03 + 0.005), // Very slow float up to represent realistic stars
        color: 'rgba(255, 255, 255, 0.8)',
        alpha: Math.random() * 0.5 + 0.4,
        twinkleSpeed: Math.random() * 0.035 + 0.015,
        twinklePhase: Math.random() * Math.PI * 2,
        extra: {}
      };

      // Customizations per theme
      if (theme === 'snow' || theme === 'winter') {
        p.radius = Math.random() * (isMobile ? 1.5 : 2.5) + 0.6;
        p.vy = Math.random() * 0.7 + 0.3; // Fall down
        p.vx = (Math.random() - 0.3) * 0.25; // Sway direction
        p.color = 'rgba(255, 255, 255, 0.75)';
        p.alpha = Math.random() * 0.4 + 0.4;
        p.extra = {
          swaySpeed: Math.random() * 0.012 + 0.004,
          swayAmplitude: Math.random() * 1.2 + 0.4,
          swayPhase: Math.random() * Math.PI * 2
        };
      } else if (theme === 'rainy') {
        p.radius = Math.random() * 0.8 + 0.4;
        p.vy = Math.random() * 5 + 9; // Rapid drop
        p.vx = -1.2 - Math.random() * 0.8; // Slanted fall
        p.color = 'rgba(174, 207, 238, 0.45)';
        p.alpha = Math.random() * 0.3 + 0.2;
        p.extra = {
          length: Math.random() * 12 + 12
        };
      } else if (theme === 'forest') {
        p.radius = Math.random() * (isMobile ? 2.5 : 4.5) + 1.5;
        p.vy = Math.random() * 0.4 + 0.2; // Gentle drift down
        p.vx = (Math.random() - 0.5) * 0.3;
        const leafColors = [
          'rgba(34, 197, 94, 0.35)',  // green
          'rgba(234, 179, 8, 0.35)',   // gold
          'rgba(249, 115, 22, 0.35)',  // orange
          'rgba(16, 185, 129, 0.35)'   // emerald
        ];
        p.color = leafColors[Math.floor(Math.random() * leafColors.length)];
        p.alpha = Math.random() * 0.4 + 0.3;
        p.extra = {
          angle: Math.random() * Math.PI * 2,
          rotationSpeed: (Math.random() - 0.5) * 0.02,
          swaySpeed: Math.random() * 0.015 + 0.008,
          swayPhase: Math.random() * Math.PI * 2
        };
      } else if (theme === 'ocean') {
        p.radius = Math.random() * (isMobile ? 2 : 4) + 1.0;
        p.vy = -(Math.random() * 0.4 + 0.15); // Rise up
        p.vx = (Math.random() - 0.5) * 0.2;
        p.color = 'rgba(14, 165, 233, 0.22)';
        p.alpha = Math.random() * 0.3 + 0.15;
        p.extra = {
          wobbleSpeed: Math.random() * 0.025 + 0.008,
          wobblePhase: Math.random() * Math.PI * 2
        };
      } else if (theme === 'space') {
        p.color = ['rgba(167, 139, 250, 0.75)', 'rgba(192, 132, 252, 0.7)', 'rgba(255, 255, 255, 0.85)'][Math.floor(Math.random() * 3)];
        p.vx = (Math.random() - 0.5) * 0.02;
        p.vy = -(Math.random() * 0.02 + 0.005);
      } else if (theme === 'sunset') {
        p.color = ['rgba(249, 115, 22, 0.65)', 'rgba(239, 68, 68, 0.55)', 'rgba(253, 186, 116, 0.7)'][Math.floor(Math.random() * 3)];
        p.vx = (Math.random() - 0.5) * 0.05;
        p.vy = -(Math.random() * 0.06 + 0.01);
      } else if (theme === 'void') {
        p.color = 'rgba(255, 255, 255, 0.45)';
        p.vx = (Math.random() - 0.5) * 0.03;
        p.vy = -(Math.random() * 0.03 + 0.008);
      } else if (theme === 'night') {
        p.color = 'rgba(254, 243, 199, 0.85)';
        p.vx = (Math.random() - 0.5) * 0.015;
        p.vy = -(Math.random() * 0.015 + 0.003);
      } else if (theme === 'light') {
        p.color = ['rgba(2, 132, 199, 0.25)', 'rgba(245, 158, 11, 0.25)', 'rgba(16, 185, 129, 0.2)'][Math.floor(Math.random() * 3)];
        p.vy = -(Math.random() * 0.12 + 0.03);
      } else if (theme === 'mountains') {
        p.radius = Math.random() * (isMobile ? 0.85 : 1.25) + 0.35;
        p.color = ['rgba(34, 197, 94, 0.45)', 'rgba(217, 119, 6, 0.35)', 'rgba(120, 113, 108, 0.4)'][Math.floor(Math.random() * 3)];
        p.vy = -(Math.random() * 0.08 + 0.02);
      } else if (theme === 'mountain_morning') {
        p.color = ['rgba(253, 186, 116, 0.75)', 'rgba(251, 146, 60, 0.65)', 'rgba(254, 243, 199, 0.8)'][Math.floor(Math.random() * 3)];
        p.vy = -(Math.random() * 0.12 + 0.03);
      } else if (theme === 'waterfall') {
        const isMobileOrTablet = w < 1024;
        if (isMobileOrTablet) {
          // On mobile/tablet, show only sky stars to keep it clean and fast!
          p.extra.type = 'star';
          p.x = Math.random() * w;
          p.y = Math.random() * h;
          p.radius = Math.random() * (isMobile ? 0.45 : 0.65) + 0.15;
          p.vx = (Math.random() - 0.5) * 0.015;
          p.vy = -(Math.random() * 0.015 + 0.003);
          p.color = 'rgba(254, 243, 199, 0.8)';
        } else {
          const waterfallWidth = Math.min(220, w * 0.22);
          const rand = Math.random();
          if (rand < 0.42) {
            // Waterfall water droplet cascade (faster fall speed, slightly thicker droplets)
            p.extra.type = 'droplet';
            p.x = Math.random() * (waterfallWidth * 0.8) + (waterfallWidth * 0.1);
            p.y = initY ? Math.random() * h : h * 0.15; // Start from top ledge (15% height)
            p.radius = Math.random() * 0.55 + 0.3;
            p.vy = Math.random() * 6.0 + 5.5; // Rapid rush
            p.vx = (Math.random() * 0.25) - 0.125; // Splash outwards slightly
            p.color = 'rgba(165, 243, 252, 0.85)';
          } else if (rand < 0.65) {
            // Bottom rising mist/foam (much fluffier, larger radius, slow rise)
            p.extra.type = 'mist';
            p.x = Math.random() * (waterfallWidth * 1.25);
            p.y = initY ? (h - Math.random() * 140) : h + 10;
            p.radius = Math.random() * 12.0 + 6.0; // Larger puff size for premium mist volume
            p.vy = -(Math.random() * 0.55 + 0.25);
            p.vx = (Math.random() - 0.5) * 0.4;
            p.color = 'rgba(207, 250, 254, 0.4)';
            p.alpha = Math.random() * 0.18 + 0.08;
          } else {
            // Tiny background star dots in the right sky
            p.extra.type = 'star';
            p.x = (waterfallWidth * 1.25) + Math.random() * (w - waterfallWidth * 1.25);
            p.y = Math.random() * (h * 0.7);
            p.radius = Math.random() * (isMobile ? 0.45 : 0.65) + 0.15;
            p.vx = (Math.random() - 0.5) * 0.015;
            p.vy = -(Math.random() * 0.015 + 0.003);
            p.color = 'rgba(254, 243, 199, 0.8)';
          }
        }
      }

      return p;
    };

    let lastWidth = window.innerWidth;
    let lastHeight = window.innerHeight;

    const resizeCanvas = () => {
      const width = window.innerWidth;
      const height = window.innerHeight;

      const widthChanged = Math.abs(width - lastWidth) > 8;
      // Height changes <= 120px are typical of browser chrome (address bar) showing/hiding on mobile.
      const heightChanged = Math.abs(height - lastHeight) > 120;

      if (widthChanged || heightChanged) {
        canvas.width = width + 8;
        canvas.height = height + 8;
        lastWidth = width;
        lastHeight = height;

        particles.length = 0;
        for (let i = 0; i < particleCount; i++) {
          particles.push(createParticle(true));
        }
      }
    };

    // Initial canvas dimensions setup
    canvas.width = window.innerWidth + 8;
    canvas.height = window.innerHeight + 8;
    window.addEventListener('resize', resizeCanvas);

    // Initialize particles across the canvas
    for (let i = 0; i < particleCount; i++) {
      particles.push(createParticle(true));
    }

    // Static Backdrop drawing functions
    const drawMoon = (cWidth, cHeight) => {
      if (!moonCanvas) return;
      if (cWidth < 1024) return; // Hide moon on mobile/tablet to avoid container cut-off!
      ctx.save();
      const moonX = cWidth - 120;
      const moonY = 180; // Shifted down to render fully behind content cards
      const radius = 35;

      // Outer glow aura (drawn on main canvas, so it's smooth and has NO sharp edges!)
      ctx.beginPath();
      const glowGrad = ctx.createRadialGradient(moonX, moonY, 0, moonX, moonY, radius * 2.5);
      glowGrad.addColorStop(0, 'rgba(254, 243, 199, 0.18)');
      glowGrad.addColorStop(0.5, 'rgba(254, 243, 199, 0.06)');
      glowGrad.addColorStop(1, 'rgba(254, 243, 199, 0)');
      ctx.fillStyle = glowGrad;
      ctx.arc(moonX, moonY, radius * 2.5, 0, Math.PI * 2);
      ctx.fill();

      // Draw the pre-rendered crescent moon from the offscreen canvas
      ctx.drawImage(moonCanvas, moonX - 50, moonY - 50);

      ctx.restore();
    };

    const drawSpacePlanet = (cWidth, cHeight) => {
      if (cWidth < 1024) return; // Hide on mobile/tablet to avoid container cut-off!
      ctx.save();
      const pX = 140;
      const pY = 180; // Shifted down to render fully behind content cards
      const radius = isMobile ? 22 : 30;

      // Planet glow aura
      ctx.beginPath();
      const glowGrad = ctx.createRadialGradient(pX, pY, 0, pX, pY, radius * 2.2);
      glowGrad.addColorStop(0, 'rgba(167, 139, 250, 0.20)');
      glowGrad.addColorStop(0.5, 'rgba(192, 132, 252, 0.05)');
      glowGrad.addColorStop(1, 'rgba(167, 139, 250, 0)');
      ctx.fillStyle = glowGrad;
      ctx.arc(pX, pY, radius * 2.2, 0, Math.PI * 2);
      ctx.fill();

      // Ring angle (slanted)
      const ringAngle = -Math.PI / 6; // -30 degrees

      // 1. Draw back half of the ring
      ctx.beginPath();
      ctx.ellipse(pX, pY, radius * 1.8, radius * 0.4, ringAngle, Math.PI, 0, false);
      ctx.strokeStyle = 'rgba(192, 132, 252, 0.50)';
      ctx.lineWidth = isMobile ? 3 : 5;
      ctx.stroke();

      // 2. Draw planet sphere
      ctx.beginPath();
      const planetGrad = ctx.createLinearGradient(pX - radius, pY - radius, pX + radius, pY + radius);
      planetGrad.addColorStop(0, '#a78bfa'); // Violet/purple
      planetGrad.addColorStop(0.5, '#7c3aed');
      planetGrad.addColorStop(1, '#4c1d95'); // Deep dark purple
      ctx.fillStyle = planetGrad;
      ctx.arc(pX, pY, radius, 0, Math.PI * 2);
      ctx.fill();

      // 3. Draw front half of the ring
      ctx.beginPath();
      ctx.ellipse(pX, pY, radius * 1.8, radius * 0.4, ringAngle, 0, Math.PI, false);
      ctx.strokeStyle = 'rgba(192, 132, 252, 0.85)';
      ctx.lineWidth = isMobile ? 3 : 5;
      ctx.stroke();

      ctx.restore();
    };

    const drawSunsetSun = (cWidth, cHeight) => {
      ctx.save();
      const sunX = cWidth * 0.5;
      const sunY = cHeight * 0.9;
      const radius = isMobile ? 50 : 80;

      // Soft sun halo
      ctx.beginPath();
      const glowGrad = ctx.createRadialGradient(sunX, sunY, 0, sunX, sunY, radius * 3.5);
      glowGrad.addColorStop(0, 'rgba(251, 146, 60, 0.22)');
      glowGrad.addColorStop(0.3, 'rgba(239, 68, 68, 0.15)');
      glowGrad.addColorStop(1, 'rgba(251, 146, 60, 0)');
      ctx.fillStyle = glowGrad;
      ctx.arc(sunX, sunY, radius * 3.5, 0, Math.PI * 2);
      ctx.fill();

      // Sun disc
      ctx.beginPath();
      const sunGrad = ctx.createLinearGradient(sunX, sunY - radius, sunX, sunY + radius);
      sunGrad.addColorStop(0, 'rgba(253, 224, 71, 0.85)');
      sunGrad.addColorStop(1, 'rgba(249, 115, 22, 0.35)');
      ctx.fillStyle = sunGrad;
      ctx.arc(sunX, sunY, radius, 0, Math.PI * 2);
      ctx.fill();

      ctx.restore();
    };

    const drawMountains = (cWidth, cHeight) => {
      ctx.save();
      
      // Warm morning sun disc
      const sunX = cWidth * 0.25;
      const sunY = cHeight * 0.7;
      ctx.beginPath();
      const sunGrad = ctx.createRadialGradient(sunX, sunY, 0, sunX, sunY, 110);
      sunGrad.addColorStop(0, 'rgba(252, 211, 77, 0.35)');
      sunGrad.addColorStop(0.4, 'rgba(251, 191, 36, 0.1)');
      sunGrad.addColorStop(1, 'rgba(251, 191, 36, 0)');
      ctx.fillStyle = sunGrad;
      ctx.arc(sunX, sunY, 110, 0, Math.PI * 2);
      ctx.fill();

      // Background Mountains (Sharp Green Peaks)
      ctx.beginPath();
      ctx.moveTo(0, cHeight);
      ctx.lineTo(0, cHeight * 0.76);
      ctx.lineTo(cWidth * 0.25, cHeight * 0.52);
      ctx.lineTo(cWidth * 0.45, cHeight * 0.68);
      ctx.lineTo(cWidth * 0.7, cHeight * 0.42);
      ctx.lineTo(cWidth * 0.85, cHeight * 0.60);
      ctx.lineTo(cWidth, cHeight * 0.35);
      ctx.lineTo(cWidth, cHeight);
      ctx.closePath();

      const mtGrad1 = ctx.createLinearGradient(0, cHeight * 0.35, 0, cHeight);
      if (theme === 'mountains' || theme === 'mountains morning' || theme === 'mountain_morning') {
        mtGrad1.addColorStop(0, 'rgba(34, 197, 94, 0.18)');  // Richer emerald/sage green
        mtGrad1.addColorStop(1, 'rgba(21, 128, 61, 0.38)');   // Richer forest green
      } else {
        mtGrad1.addColorStop(0, 'rgba(255, 255, 255, 0.04)');
        mtGrad1.addColorStop(1, 'rgba(255, 255, 255, 0.12)');
      }
      ctx.fillStyle = mtGrad1;
      ctx.fill();

      // Foreground Peaks (Sharp Green Peaks)
      ctx.beginPath();
      ctx.moveTo(0, cHeight);
      ctx.lineTo(0, cHeight * 0.86);
      ctx.lineTo(cWidth * 0.15, cHeight * 0.68);
      ctx.lineTo(cWidth * 0.38, cHeight * 0.78);
      ctx.lineTo(cWidth * 0.55, cHeight * 0.54);
      ctx.lineTo(cWidth * 0.75, cHeight * 0.74);
      ctx.lineTo(cWidth * 0.9, cHeight * 0.64);
      ctx.lineTo(cWidth, cHeight * 0.82);
      ctx.lineTo(cWidth, cHeight);
      ctx.closePath();

      const mtGrad2 = ctx.createLinearGradient(0, cHeight * 0.50, 0, cHeight);
      if (theme === 'mountains' || theme === 'mountains morning' || theme === 'mountain_morning') {
        mtGrad2.addColorStop(0, 'rgba(21, 128, 61, 0.32)');   // More vibrant sage green
        mtGrad2.addColorStop(1, 'rgba(20, 83, 45, 0.58)');    // Richer dark forest green
      } else {
        mtGrad2.addColorStop(0, 'rgba(255, 255, 255, 0.07)');
        mtGrad2.addColorStop(1, 'rgba(255, 255, 255, 0.18)');
      }
      ctx.fillStyle = mtGrad2;
      ctx.fill();

      ctx.restore();
    };

    const drawMountainMorning = (cWidth, cHeight) => {
      ctx.save();
      
      // 1. Sunrise Sun Disc & Glow
      const sunX = cWidth * 0.35;
      const sunY = cHeight * 0.65;
      const sunRadius = isMobile ? 45 : 70;

      // Soft radial morning glow
      ctx.beginPath();
      const glowGrad = ctx.createRadialGradient(sunX, sunY, 0, sunX, sunY, sunRadius * 4);
      glowGrad.addColorStop(0, 'rgba(253, 186, 116, 0.35)'); // Amber-gold
      glowGrad.addColorStop(0.3, 'rgba(244, 63, 94, 0.18)');  // Rose pink
      glowGrad.addColorStop(0.6, 'rgba(254, 243, 199, 0.08)'); // Cream
      glowGrad.addColorStop(1, 'rgba(254, 243, 199, 0)');
      ctx.fillStyle = glowGrad;
      ctx.arc(sunX, sunY, sunRadius * 4, 0, Math.PI * 2);
      ctx.fill();

      // Soft sun rays radiating outwards
      const rayCount = 8;
      const time = Date.now() * 0.0003;
      for (let i = 0; i < rayCount; i++) {
        const angle = (i * Math.PI * 2) / rayCount + time;
        const startX = sunX;
        const startY = sunY;
        const endX = sunX + Math.cos(angle) * (sunRadius * 4.5);
        const endY = sunY + Math.sin(angle) * (sunRadius * 4.5);

        ctx.beginPath();
        const rayGrad = ctx.createLinearGradient(startX, startY, endX, endY);
        rayGrad.addColorStop(0, 'rgba(253, 186, 116, 0.12)');
        rayGrad.addColorStop(0.5, 'rgba(244, 63, 94, 0.04)');
        rayGrad.addColorStop(1, 'rgba(254, 243, 199, 0)');
        ctx.strokeStyle = rayGrad;
        ctx.lineWidth = isMobile ? 12 : 24;
        ctx.moveTo(startX, startY);
        ctx.lineTo(endX, endY);
        ctx.stroke();
      }

      // Sun core disc
      ctx.beginPath();
      const sunGrad = ctx.createLinearGradient(sunX, sunY - sunRadius, sunX, sunY + sunRadius);
      sunGrad.addColorStop(0, 'rgba(255, 253, 245, 0.95)');
      sunGrad.addColorStop(0.4, 'rgba(253, 224, 71, 0.85)');
      sunGrad.addColorStop(1, 'rgba(249, 115, 22, 0.4)');
      ctx.fillStyle = sunGrad;
      ctx.arc(sunX, sunY, sunRadius, 0, Math.PI * 2);
      ctx.fill();

      // 2. Background mountain range silhouette (distant, soft rose-gray)
      ctx.beginPath();
      ctx.moveTo(0, cHeight);
      ctx.lineTo(0, cHeight * 0.72);
      ctx.quadraticCurveTo(cWidth * 0.25, cHeight * 0.58, cWidth * 0.50, cHeight * 0.78);
      ctx.quadraticCurveTo(cWidth * 0.72, cHeight * 0.54, cWidth * 0.90, cHeight * 0.80);
      ctx.lineTo(cWidth, cHeight * 0.72);
      ctx.lineTo(cWidth, cHeight);
      ctx.closePath();

      const bgMtGrad = ctx.createLinearGradient(0, cHeight * 0.55, 0, cHeight);
      bgMtGrad.addColorStop(0, 'rgba(224, 150, 140, 0.12)');
      bgMtGrad.addColorStop(1, 'rgba(190, 120, 115, 0.25)');
      ctx.fillStyle = bgMtGrad;
      ctx.fill();

      // 3. Foreground mountain range silhouette (closer, darker stone-peach)
      ctx.beginPath();
      ctx.moveTo(0, cHeight);
      ctx.lineTo(0, cHeight * 0.82);
      ctx.quadraticCurveTo(cWidth * 0.30, cHeight * 0.72, cWidth * 0.58, cHeight * 0.86);
      ctx.quadraticCurveTo(cWidth * 0.82, cHeight * 0.66, cWidth, cHeight * 0.80);
      ctx.lineTo(cWidth, cHeight);
      ctx.closePath();

      const fgMtGrad = ctx.createLinearGradient(0, cHeight * 0.66, 0, cHeight);
      fgMtGrad.addColorStop(0, 'rgba(87, 74, 70, 0.20)');
      fgMtGrad.addColorStop(1, 'rgba(68, 60, 58, 0.40)');
      ctx.fillStyle = fgMtGrad;
      ctx.fill();

      ctx.restore();
    };

    const drawWaterfallBackdrop = (cWidth, cHeight) => {
      if (cWidth < 1024) return; // Hide on mobile/tablet to keep it clean and fast!
      ctx.save();
      
      const waterfallWidth = Math.min(220, cWidth * 0.22);
      const time = Date.now() * 0.0035;
      
      // Sky/ambience background gradient on the right side
      const skyGrad = ctx.createLinearGradient(waterfallWidth, 0, cWidth, cHeight);
      skyGrad.addColorStop(0, 'rgba(6, 18, 23, 0.2)');
      skyGrad.addColorStop(1, 'rgba(2, 6, 8, 0.45)');
      ctx.fillStyle = skyGrad;
      ctx.fillRect(waterfallWidth, 0, cWidth - waterfallWidth, cHeight);

      // 1. Rocky Cliff silhouette on the left (semi-transparent for celestial blending)
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(waterfallWidth * 1.1, 0);
      ctx.lineTo(waterfallWidth, cHeight * 0.15); // Waterfall starting ledge (15% height)
      ctx.lineTo(waterfallWidth * 0.85, cHeight * 0.15);
      
      // Left cliff face bezier curve
      ctx.bezierCurveTo(
        waterfallWidth * 0.75, cHeight * 0.4,
        waterfallWidth * 0.5, cHeight * 0.7,
        waterfallWidth * 0.65, cHeight
      );
      ctx.lineTo(0, cHeight);
      ctx.closePath();

      const cliffGrad = ctx.createLinearGradient(0, 0, waterfallWidth, cHeight);
      cliffGrad.addColorStop(0, 'rgba(10, 29, 38, 0.45)');
      cliffGrad.addColorStop(0.5, 'rgba(7, 21, 28, 0.55)');
      cliffGrad.addColorStop(1, 'rgba(3, 10, 13, 0.65)');
      ctx.fillStyle = cliffGrad;
      ctx.fill();

      // Rock ridge detail highlights
      ctx.beginPath();
      ctx.strokeStyle = 'rgba(22, 78, 99, 0.18)';
      ctx.lineWidth = 1.6;
      ctx.moveTo(waterfallWidth * 0.85, cHeight * 0.15);
      ctx.bezierCurveTo(
        waterfallWidth * 0.75, cHeight * 0.4,
        waterfallWidth * 0.4, cHeight * 0.7,
        waterfallWidth * 0.55, cHeight
      );
      ctx.stroke();

      // 2. Main flowing background body of the waterfall (cylindrical fluid mass)
      const wStart = waterfallWidth * 0.16;
      const wEnd = waterfallWidth * 0.80;
      const wBodyGrad = ctx.createLinearGradient(wStart, 0, wEnd, 0);
      wBodyGrad.addColorStop(0, 'rgba(6, 182, 212, 0.05)');
      wBodyGrad.addColorStop(0.25, 'rgba(165, 243, 252, 0.16)');
      wBodyGrad.addColorStop(0.5, 'rgba(255, 255, 255, 0.28)');
      wBodyGrad.addColorStop(0.75, 'rgba(165, 243, 252, 0.16)');
      wBodyGrad.addColorStop(1, 'rgba(6, 182, 212, 0.04)');
      
      ctx.fillStyle = wBodyGrad;
      ctx.beginPath();
      // Draw organic waving borders down to cHeight
      ctx.moveTo(wStart, cHeight * 0.15);
      for (let y = cHeight * 0.15; y <= cHeight; y += 30) {
        const leftSway = Math.sin(y * 0.045 - time * 7.5) * 1.8;
        ctx.lineTo(wStart + leftSway, y);
      }
      for (let y = cHeight; y >= cHeight * 0.15; y -= 30) {
        const rightSway = Math.sin(y * 0.035 - time * 8.5 + 2.0) * 1.8;
        ctx.lineTo(wEnd + rightSway, y);
      }
      ctx.closePath();
      ctx.fill();

      // 3. Layered Shimmer Streams (Veins of rushing water)
      const streamCount = 20;
      for (let i = 0; i < streamCount; i++) {
        // Distribute starting points evenly across the ledge width
        const startPct = 0.18 + (i / (streamCount - 1)) * 0.60;
        const startX = waterfallWidth * startPct;
        
        ctx.beginPath();
        // Vary colors and opacities for multi-layer depth
        if (i % 4 === 0) {
          ctx.strokeStyle = 'rgba(255, 255, 255, 0.42)'; // Bright foaming stream
          ctx.lineWidth = Math.random() * 2.2 + 1.2;
        } else if (i % 3 === 0) {
          ctx.strokeStyle = 'rgba(165, 243, 252, 0.32)'; // Cyan highlight
          ctx.lineWidth = Math.random() * 2.8 + 1.0;
        } else if (i % 2 === 0) {
          ctx.strokeStyle = 'rgba(34, 211, 238, 0.22)'; // Deep cyan stream
          ctx.lineWidth = Math.random() * 2.0 + 0.8;
        } else {
          ctx.strokeStyle = 'rgba(255, 255, 255, 0.18)'; // Translucent background strand
          ctx.lineWidth = Math.random() * 1.2 + 0.5;
        }
        
        ctx.moveTo(startX, cHeight * 0.15);
        
        const freq = 0.06 + (i % 3) * 0.025;
        const speed = 16.0 + (i % 4) * 2.5;
        const amp = 0.6 + Math.random() * 0.8;
        
        for (let y = cHeight * 0.15; y <= cHeight; y += 40) {
          const sway = Math.sin(y * freq + time * speed + i) * amp;
          ctx.lineTo(startX + sway, y);
        }
        ctx.stroke();
      }

      // 4. Ledge Overflow foam crest (glowing overflow)
      const crestAlpha = 0.5 + Math.sin(time * 4.5) * 0.12;
      const ledgeGrad = ctx.createLinearGradient(waterfallWidth * 0.15, 0, waterfallWidth * 0.85, 0);
      ledgeGrad.addColorStop(0, 'rgba(165, 243, 252, 0)');
      ledgeGrad.addColorStop(0.3, `rgba(255, 255, 255, ${crestAlpha * 0.75})`);
      ledgeGrad.addColorStop(0.5, `rgba(207, 250, 254, ${crestAlpha * 0.95})`);
      ledgeGrad.addColorStop(0.7, `rgba(255, 255, 255, ${crestAlpha * 0.75})`);
      ledgeGrad.addColorStop(1, 'rgba(165, 243, 252, 0)');
      
      ctx.fillStyle = ledgeGrad;
      ctx.beginPath();
      ctx.ellipse(
        waterfallWidth * 0.48,
        cHeight * 0.15,
        waterfallWidth * 0.34,
        4.0 + Math.sin(time * 3.5) * 1.0,
        0,
        0,
        Math.PI * 2
      );
      ctx.fill();

      // 5. Dynamic bottom waves churning foam layers
      const waveLayers = [
        { fill: 'rgba(207, 250, 254, 0.22)', amp: 4.0, freq: 0.045, speed: 6.0, offset: 0, height: 26 },
        { fill: 'rgba(165, 243, 252, 0.30)', amp: 2.8, freq: 0.065, speed: -7.5, offset: Math.PI / 2, height: 18 },
        { fill: 'rgba(255, 255, 255, 0.40)', amp: 1.8, freq: 0.085, speed: 10.0, offset: Math.PI, height: 12 }
      ];
      
      waveLayers.forEach((wave) => {
        ctx.fillStyle = wave.fill;
        ctx.beginPath();
        ctx.moveTo(0, cHeight);
        for (let x = 0; x <= waterfallWidth * 1.15; x += 12) {
          const waveSway = Math.sin(x * wave.freq + time * wave.speed + wave.offset) * wave.amp
                         + Math.cos(x * (wave.freq * 0.35) - time * (wave.speed * 0.25)) * (wave.amp * 0.4);
          ctx.lineTo(x, cHeight - wave.height + waveSway);
        }
        ctx.lineTo(waterfallWidth * 1.15, cHeight);
        ctx.closePath();
        ctx.fill();
      });

      // 6. Soft blending mist gradient overlay
      const mistOverlayGrad = ctx.createLinearGradient(0, cHeight - 140, waterfallWidth * 1.25, cHeight);
      mistOverlayGrad.addColorStop(0, 'rgba(6, 182, 212, 0)');
      mistOverlayGrad.addColorStop(0.5, 'rgba(165, 243, 252, 0.06)');
      mistOverlayGrad.addColorStop(1, 'rgba(255, 255, 255, 0.16)');
      ctx.fillStyle = mistOverlayGrad;
      ctx.fillRect(0, cHeight - 140, waterfallWidth * 1.25, 140);

      ctx.restore();
    };

    const drawRainyBackdrop = (cWidth, cHeight) => {
      ctx.save();
      const cloudGrad = ctx.createLinearGradient(0, 0, 0, cHeight * 0.35);
      cloudGrad.addColorStop(0, 'rgba(71, 85, 105, 0.28)');
      cloudGrad.addColorStop(0.5, 'rgba(100, 116, 139, 0.12)');
      cloudGrad.addColorStop(1, 'rgba(100, 116, 139, 0)');
      ctx.fillStyle = cloudGrad;
      
      ctx.beginPath();
      ctx.arc(cWidth * 0.1, 0, cWidth * 0.22, 0, Math.PI * 2);
      ctx.arc(cWidth * 0.35, 0, cWidth * 0.28, 0, Math.PI * 2);
      ctx.arc(cWidth * 0.65, 0, cWidth * 0.32, 0, Math.PI * 2);
      ctx.arc(cWidth * 0.9, 0, cWidth * 0.25, 0, Math.PI * 2);
      ctx.closePath();
      ctx.fill();

      const cloudGrad2 = ctx.createLinearGradient(0, 0, 0, cHeight * 0.25);
      cloudGrad2.addColorStop(0, 'rgba(148, 163, 184, 0.2)');
      cloudGrad2.addColorStop(1, 'rgba(148, 163, 184, 0)');
      ctx.fillStyle = cloudGrad2;
      ctx.beginPath();
      ctx.arc(cWidth * 0.2, 0, cWidth * 0.18, 0, Math.PI * 2);
      ctx.arc(cWidth * 0.5, 0, cWidth * 0.24, 0, Math.PI * 2);
      ctx.arc(cWidth * 0.8, 0, cWidth * 0.2, 0, Math.PI * 2);
      ctx.closePath();
      ctx.fill();
      
      ctx.restore();
    };

    const drawForestBackdrop = (cWidth, cHeight) => {
      ctx.save();
      ctx.fillStyle = isLightTheme(theme) ? 'rgba(16, 185, 129, 0.08)' : 'rgba(16, 185, 129, 0.04)';
      const bgTreeCount = isMobile ? 8 : 16;
      const bgStep = cWidth / bgTreeCount;
      for (let i = 0; i <= bgTreeCount; i++) {
        const x = i * bgStep + (Math.sin(i) * 10);
        const treeHeight = (isMobile ? 120 : 200) + (Math.cos(i * 1.5) * 40);
        const y = cHeight - treeHeight;
        const width = isMobile ? 35 : 60;
        
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x - width * 0.5, y + treeHeight * 0.4);
        ctx.lineTo(x - width * 0.3, y + treeHeight * 0.4);
        ctx.lineTo(x - width * 0.7, y + treeHeight * 0.7);
        ctx.lineTo(x - width * 0.4, y + treeHeight * 0.7);
        ctx.lineTo(x - width * 0.9, cHeight);
        ctx.lineTo(x + width * 0.9, cHeight);
        ctx.lineTo(x + width * 0.4, y + treeHeight * 0.7);
        ctx.lineTo(x + width * 0.7, y + treeHeight * 0.7);
        ctx.lineTo(x + width * 0.3, y + treeHeight * 0.4);
        ctx.lineTo(x + width * 0.5, y + treeHeight * 0.4);
        ctx.closePath();
        ctx.fill();
      }

      ctx.fillStyle = isLightTheme(theme) ? 'rgba(21, 128, 61, 0.16)' : 'rgba(21, 128, 61, 0.09)';
      const fgTreeCount = isMobile ? 10 : 20;
      const fgStep = cWidth / fgTreeCount;
      for (let i = 0; i <= fgTreeCount; i++) {
        const x = i * fgStep + (Math.sin(i * 2) * 8);
        const treeHeight = (isMobile ? 80 : 140) + (Math.sin(i * 2.3) * 25);
        const y = cHeight - treeHeight;
        const width = isMobile ? 25 : 45;
        
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x - width * 0.5, y + treeHeight * 0.4);
        ctx.lineTo(x - width * 0.3, y + treeHeight * 0.4);
        ctx.lineTo(x - width * 0.7, y + treeHeight * 0.7);
        ctx.lineTo(x - width * 0.4, y + treeHeight * 0.7);
        ctx.lineTo(x - width * 0.9, cHeight);
        ctx.lineTo(x + width * 0.9, cHeight);
        ctx.lineTo(x + width * 0.4, y + treeHeight * 0.7);
        ctx.lineTo(x + width * 0.7, y + treeHeight * 0.7);
        ctx.lineTo(x + width * 0.3, y + treeHeight * 0.4);
        ctx.lineTo(x + width * 0.5, y + treeHeight * 0.4);
        ctx.closePath();
        ctx.fill();
      }
      
      ctx.restore();
    };

    const drawOceanBackdrop = (cWidth, cHeight) => {
      ctx.save();
      const time = Date.now() * 0.0006;
      
      ctx.fillStyle = isLightTheme(theme) ? 'rgba(14, 165, 233, 0.08)' : 'rgba(14, 165, 233, 0.04)';
      ctx.beginPath();
      ctx.moveTo(0, cHeight);
      for (let x = 0; x <= cWidth; x += 15) {
        const y = cHeight - (isMobile ? 60 : 100) + Math.sin(x * 0.003 + time) * 15;
        ctx.lineTo(x, y);
      }
      ctx.lineTo(cWidth, cHeight);
      ctx.closePath();
      ctx.fill();

      ctx.fillStyle = isLightTheme(theme) ? 'rgba(2, 132, 199, 0.12)' : 'rgba(2, 132, 199, 0.07)';
      ctx.beginPath();
      ctx.moveTo(0, cHeight);
      for (let x = 0; x <= cWidth; x += 15) {
        const y = cHeight - (isMobile ? 45 : 75) + Math.cos(x * 0.004 - time * 0.8) * 12;
        ctx.lineTo(x, y);
      }
      ctx.lineTo(cWidth, cHeight);
      ctx.closePath();
      ctx.fill();

      ctx.fillStyle = isLightTheme(theme) ? 'rgba(3, 105, 161, 0.16)' : 'rgba(3, 105, 161, 0.10)';
      ctx.beginPath();
      ctx.moveTo(0, cHeight);
      for (let x = 0; x <= cWidth; x += 15) {
        const y = cHeight - (isMobile ? 30 : 50) + Math.sin(x * 0.005 + time * 1.2) * 8;
        ctx.lineTo(x, y);
      }
      ctx.lineTo(cWidth, cHeight);
      ctx.closePath();
      ctx.fill();
      
      ctx.restore();
    };

    const drawVoidBackdrop = (cWidth, cHeight) => {
      ctx.save();
      const cX = cWidth * 0.5;
      const cY = cHeight * 0.45;
      const radius = isMobile ? 90 : 150;
      
      ctx.beginPath();
      const glowGrad = ctx.createRadialGradient(cX, cY, radius * 0.8, cX, cY, radius * 2.2);
      glowGrad.addColorStop(0, 'rgba(255, 255, 255, 0.03)');
      glowGrad.addColorStop(0.5, 'rgba(255, 255, 255, 0.01)');
      glowGrad.addColorStop(1, 'rgba(255, 255, 255, 0)');
      ctx.fillStyle = glowGrad;
      ctx.arc(cX, cY, radius * 2.2, 0, Math.PI * 2);
      ctx.fill();

      ctx.beginPath();
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.04)';
      ctx.lineWidth = 1;
      ctx.arc(cX, cY, radius, 0, Math.PI * 2);
      ctx.stroke();

      ctx.beginPath();
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.02)';
      ctx.lineWidth = 0.8;
      ctx.ellipse(cX, cY, radius * 1.5, radius * 0.15, -Math.PI / 12, 0, Math.PI * 2);
      ctx.stroke();
      
      ctx.restore();
    };

    const drawLeaf = (pCtx, x, y, size, angle, color) => {
      pCtx.save();
      pCtx.translate(x, y);
      pCtx.rotate(angle);
      pCtx.fillStyle = color;
      pCtx.beginPath();
      pCtx.moveTo(0, -size);
      pCtx.quadraticCurveTo(size * 0.65, 0, 0, size);
      pCtx.quadraticCurveTo(-size * 0.65, 0, 0, -size);
      pCtx.closePath();
      pCtx.fill();
      pCtx.restore();
    };

    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      const time = Date.now() * 0.0035;

      // 1. Draw static backdrops based on active theme
      if (theme === 'night') {
        drawMoon(canvas.width, canvas.height);
      } else if (theme === 'space') {
        drawSpacePlanet(canvas.width, canvas.height);
      } else if (theme === 'sunset') {
        drawSunsetSun(canvas.width, canvas.height);
      } else if (theme === 'mountains' || theme === 'mountains morning') {
        drawMountains(canvas.width, canvas.height);
      } else if (theme === 'mountain_morning') {
        drawMountainMorning(canvas.width, canvas.height);
      } else if (theme === 'waterfall') {
        drawWaterfallBackdrop(canvas.width, canvas.height);
      } else if (theme === 'rainy') {
        drawRainyBackdrop(canvas.width, canvas.height);
      } else if (theme === 'forest') {
        drawForestBackdrop(canvas.width, canvas.height);
      } else if (theme === 'ocean') {
        drawOceanBackdrop(canvas.width, canvas.height);
      } else if (theme === 'void') {
        drawVoidBackdrop(canvas.width, canvas.height);
      }

      // 2. Render and update particles
      particles.forEach((p, index) => {
        // Core Physics
        if (theme === 'snow' || theme === 'winter') {
          p.extra.swayPhase += p.extra.swaySpeed;
          p.x += p.vx + Math.sin(p.extra.swayPhase) * p.extra.swayAmplitude * 0.25;
          p.y += p.vy;
        } else if (theme === 'rainy') {
          p.x += p.vx;
          p.y += p.vy;
        } else if (theme === 'forest') {
          p.extra.swayPhase += p.extra.swaySpeed;
          p.extra.angle += p.extra.rotationSpeed;
          p.x += p.vx + Math.sin(p.extra.swayPhase) * 0.3;
          p.y += p.vy;
        } else if (theme === 'ocean') {
          p.extra.wobblePhase += p.extra.wobbleSpeed;
          p.x += p.vx + Math.sin(p.extra.wobblePhase) * 0.4;
          p.y += p.vy;
        } else if (theme === 'waterfall') {
          if (p.extra.type === 'droplet') {
            p.x += p.vx;
            p.y += p.vy;
          } else if (p.extra.type === 'mist') {
            // Mist drifts and sways gently as it floats upward
            p.x += p.vx + Math.sin(p.y * 0.025 + time) * 0.22;
            p.y += p.vy;
            // Mist fades out faster as it climbs
            p.alpha = Math.max(0, p.alpha - 0.0025);
          } else {
            // Stars in the sky
            p.x += p.vx;
            p.y += p.vy;
          }
        } else {
          // Standard float upwards
          p.x += p.vx;
          p.y += p.vy;
        }

        // Twinkle/Shimmer cycle
        p.twinklePhase += p.twinkleSpeed;
        const currentAlpha = Math.max(0.05, p.alpha + Math.sin(p.twinklePhase) * 0.18);

        // Draw particle representation
        if (theme === 'rainy') {
          ctx.beginPath();
          ctx.strokeStyle = `rgba(174, 207, 238, ${currentAlpha})`;
          ctx.lineWidth = p.radius;
          ctx.moveTo(p.x, p.y);
          ctx.lineTo(p.x + p.vx * 0.8, p.y + p.extra.length);
          ctx.stroke();
        } else if (theme === 'forest') {
          // Leaf shape
          drawLeaf(ctx, p.x, p.y, p.radius, p.extra.angle, p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`);
        } else if (theme === 'ocean') {
          // Unfilled bubble circles
          ctx.beginPath();
          ctx.strokeStyle = p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`;
          ctx.lineWidth = 1;
          ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
          ctx.stroke();
          
          // Bubble inner highlight
          ctx.beginPath();
          ctx.fillStyle = `rgba(255, 255, 255, ${currentAlpha * 0.4})`;
          ctx.arc(p.x - p.radius * 0.3, p.y - p.radius * 0.3, p.radius * 0.2, 0, Math.PI * 2);
          ctx.fill();
        } else if (theme === 'waterfall') {
          if (p.extra.type === 'droplet') {
            // Falling water droplets drawn as rapid streaks (motion blur matching fall velocity)
            ctx.beginPath();
            ctx.strokeStyle = Math.random() < 0.5 
              ? `rgba(255, 255, 255, ${currentAlpha * 0.8})` 
              : `rgba(165, 243, 252, ${currentAlpha * 0.75})`;
            ctx.lineWidth = p.radius;
            ctx.moveTo(p.x, p.y);
            // Draw a streak from (p.x, p.y) down to look like high-speed falling water droplets
            ctx.lineTo(p.x + p.vx * 0.6, p.y + p.vy * 1.6);
            ctx.stroke();
          } else if (p.extra.type === 'mist') {
            // Rising water mist at pool bottom
            ctx.beginPath();
            const mistGrad = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.radius);
            mistGrad.addColorStop(0, `rgba(207, 250, 254, ${currentAlpha * 0.35})`);
            mistGrad.addColorStop(1, 'rgba(207, 250, 254, 0)');
            ctx.fillStyle = mistGrad;
            ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
            ctx.fill();
          } else {
            // Shimmering sky stars (sharp pinprick dots)
            ctx.beginPath();
            ctx.fillStyle = p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`;
            ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
            ctx.fill();
          }
        } else {
          // Shimmering sky stars (sharp pinprick dots)
          ctx.beginPath();
          ctx.fillStyle = p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`;
          ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
          ctx.fill();
        }

        // Bounds check & recycle particle
        let isOffScreen = false;
        if (theme === 'snow' || theme === 'winter' || theme === 'rainy' || theme === 'forest') {
          isOffScreen = p.y > canvas.height + 20 || p.x < -20 || p.x > canvas.width + 20;
        } else if (theme === 'waterfall') {
          const waterfallWidth = Math.min(220, canvas.width * 0.22);
          if (p.extra.type === 'droplet') {
            isOffScreen = p.y > canvas.height + 10 || p.x < -10 || p.x > waterfallWidth * 1.1;
          } else if (p.extra.type === 'mist') {
            isOffScreen = p.y < canvas.height * 0.4 || p.alpha <= 0.01;
          } else {
            isOffScreen = p.y < -10 || p.x < waterfallWidth * 1.2 || p.x > canvas.width + 10;
          }
        } else {
          isOffScreen = p.y < -20 || p.x < -20 || p.x > canvas.width + 20;
        }

        if (isOffScreen) {
          particles[index] = createParticle(false);
          // Set recycled falling particles/droplets at the top
          if (theme === 'snow' || theme === 'winter' || theme === 'rainy' || theme === 'forest') {
            particles[index].y = -10;
          } else if (theme === 'waterfall' && particles[index].extra.type === 'droplet') {
            particles[index].y = canvas.height * 0.15;
          }
        }
      });

      // 3. Space Theme Shooting Stars
      if (theme === 'space') {
        if (Math.random() < 0.006 && shootingStars.length < 2) {
          shootingStars.push({
            x: Math.random() * canvas.width * 0.6,
            y: Math.random() * canvas.height * 0.3,
            vx: Math.random() * 4 + 6,
            vy: Math.random() * 2.5 + 4,
            length: Math.random() * 70 + 40,
            alpha: 1
          });
        }

        shootingStars.forEach((ss, idx) => {
          ss.x += ss.vx;
          ss.y += ss.vy;
          ss.alpha -= 0.025;

          ctx.save();
          ctx.beginPath();
          ctx.strokeStyle = `rgba(255, 255, 255, ${ss.alpha})`;
          ctx.lineWidth = 1.8;
          ctx.moveTo(ss.x, ss.y);
          ctx.lineTo(ss.x - ss.vx * 2.5, ss.y - ss.vy * 2.5);
          ctx.stroke();
          ctx.restore();

          if (ss.alpha <= 0 || ss.x > canvas.width || ss.y > canvas.height) {
            shootingStars.splice(idx, 1);
          }
        });
      }

      // 4. Mountain Theme Flying Birds
      if (theme === 'mountains' || theme === 'mountains morning' || theme === 'mountain_morning') {
        if (Math.random() < 0.005 && birds.length < 4) {
          birds.push({
            x: -30,
            y: Math.random() * canvas.height * 0.35 + 40,
            speed: Math.random() * 0.6 + 0.35,
            wingSpeed: Math.random() * 0.12 + 0.06,
            phase: Math.random() * Math.PI,
            size: Math.random() * 3 + 2.5
          });
        }

        birds.forEach((b, idx) => {
          b.x += b.speed;
          b.phase += b.wingSpeed;

          const wingOffset = Math.sin(b.phase) * b.size;

          ctx.save();
          ctx.beginPath();
          ctx.strokeStyle = 'rgba(28, 25, 23, 0.35)';
          ctx.lineWidth = 1.2;
          ctx.moveTo(b.x - b.size, b.y - wingOffset);
          ctx.quadraticCurveTo(b.x - b.size * 0.5, b.y - wingOffset - 2, b.x, b.y);
          ctx.quadraticCurveTo(b.x + b.size * 0.5, b.y - wingOffset - 2, b.x + b.size, b.y - wingOffset);
          ctx.stroke();
          ctx.restore();

          if (b.x > canvas.width + 30) {
            birds.splice(idx, 1);
          }
        });
      }

      animationFrameId = requestAnimationFrame(animate);
    };

    animate();

    return () => {
      window.removeEventListener('resize', resizeCanvas);
      cancelAnimationFrame(animationFrameId);
    };
  }, [theme]);

  // Completely invisible in pure light base mode to respect minimalist clean look
  if (theme === 'light') return null;

  const isLight = isLightTheme(theme);

  return (
    <canvas
      ref={canvasRef}
      className="fixed pointer-events-none z-[-1]"
      style={{
        top: '-4px',
        left: '-4px',
        right: '-4px',
        bottom: '-4px',
        mixBlendMode: isLight ? 'normal' : 'screen',
        opacity: isLight ? 0.75 : 0.85,
        display: 'block',
      }}
    />
  );
};

export default CelestialParticles;
