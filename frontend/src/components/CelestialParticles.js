import React, { useEffect, useRef } from 'react';
import { useSettings, isLightTheme } from '../contexts/SettingsContext';

const CelestialParticles = () => {
  const { settings } = useSettings();
  const canvasRef = useRef(null);

  const settingsTheme = settings.theme || 'light';
  const isAuthPage = window.location.pathname.includes('/login');
  const theme = isAuthPage ? 'space' : settingsTheme;

  const isMobile = window.innerWidth < 1024 || 
                   ('ontouchstart' in window) || 
                   (navigator.maxTouchPoints > 0);

  useEffect(() => {
    if (settings.enableAnimations === false || isMobile) return;

    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animationFrameId;
    let particles = [];
    let shootingStars = [];
    let birds = [];
    
    
    let lastTime = 0;
    const fpsInterval = isMobile ? 1000 / 30 : 1000 / 60;

    
    const backdropCanvas = document.createElement('canvas');
    const bCtx = backdropCanvas.getContext('2d');

    
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
    
    
    let particleCount = isMobile ? 10 : 35;
    if (theme === 'snow' || theme === 'winter') {
      particleCount = isMobile ? 20 : 60;
    } else if (theme === 'rainy') {
      particleCount = isMobile ? 25 : 80;
    } else if (theme === 'forest') {
      particleCount = isMobile ? 12 : 35;
    } else if (theme === 'ocean') {
      particleCount = isMobile ? 12 : 40;
    } else if (theme === 'void') {
      particleCount = isMobile ? 8 : 25;
    } else if (theme === 'waterfall') {
      particleCount = isMobile ? 15 : 60;
    } else if (theme === 'cherryblossom' || theme === 'cherryblossom_light') {
      particleCount = isMobile ? 15 : 45;
    } else if (theme === 'aurora') {
      particleCount = isMobile ? 15 : 45;
    } else if (theme === 'mountain_morning') {
      particleCount = isMobile ? 15 : 45;
    } else if (theme === 'night') {
      particleCount = isMobile ? 25 : 70;
    } else if (theme === 'space') {
      particleCount = isMobile ? 30 : 80;
    }

    
    const createParticle = (initY = false) => {
      const w = canvas.width;
      const h = canvas.height;
      const randX = Math.random() * w;
      const randY = initY ? Math.random() * h : h + 10;

      
      let p = {
        x: randX,
        y: randY,
        radius: Math.random() * (isMobile ? 0.45 : 0.65) + 0.15,
        vx: (Math.random() - 0.5) * 0.03,
        vy: -(Math.random() * 0.03 + 0.005),
        color: 'rgba(255, 255, 255, 0.8)',
        alpha: Math.random() * 0.5 + 0.4,
        twinkleSpeed: Math.random() * 0.035 + 0.015,
        twinklePhase: Math.random() * Math.PI * 2,
        extra: {}
      };

      
      if (theme === 'snow' || theme === 'winter') {
        p.radius = Math.random() * (isMobile ? 1.5 : 2.5) + 0.6;
        p.vy = Math.random() * 0.7 + 0.3;
        p.vx = (Math.random() - 0.3) * 0.25;
        p.color = 'rgba(255, 255, 255, 0.75)';
        p.alpha = Math.random() * 0.4 + 0.4;
        p.extra = {
          swaySpeed: Math.random() * 0.012 + 0.004,
          swayAmplitude: Math.random() * 1.2 + 0.4,
          swayPhase: Math.random() * Math.PI * 2
        };
      } else if (theme === 'rainy') {
        p.radius = Math.random() * 0.8 + 0.4;
        p.vy = Math.random() * 5 + 9;
        p.vx = -1.2 - Math.random() * 0.8;
        p.color = 'rgba(174, 207, 238, 0.45)';
        p.alpha = Math.random() * 0.3 + 0.2;
        p.extra = {
          length: Math.random() * 12 + 12
        };
      } else if (theme === 'forest') {
        p.radius = Math.random() * (isMobile ? 2.5 : 4.5) + 1.5;
        p.vy = Math.random() * 0.4 + 0.2;
        p.vx = (Math.random() - 0.5) * 0.3;
        const leafColors = [
          'rgba(34, 197, 94, 0.35)',
          'rgba(234, 179, 8, 0.35)',
          'rgba(249, 115, 22, 0.35)',
          'rgba(16, 185, 129, 0.35)'
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
        p.vy = -(Math.random() * 0.4 + 0.15);
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
            p.extra.type = 'droplet';
            p.x = Math.random() * (waterfallWidth * 0.8) + (waterfallWidth * 0.1);
            p.y = initY ? Math.random() * h : h * 0.15;
            p.radius = Math.random() * 0.55 + 0.3;
            p.vy = Math.random() * 6.0 + 5.5;
            p.vx = (Math.random() * 0.25) - 0.125;
            p.color = 'rgba(165, 243, 252, 0.85)';
          } else if (rand < 0.65) {
            p.extra.type = 'mist';
            p.x = Math.random() * (waterfallWidth * 1.25);
            p.y = initY ? (h - Math.random() * 140) : h + 10;
            p.radius = Math.random() * 12.0 + 6.0;
            p.vy = -(Math.random() * 0.55 + 0.25);
            p.vx = (Math.random() - 0.5) * 0.4;
            p.color = 'rgba(207, 250, 254, 0.4)';
            p.alpha = Math.random() * 0.18 + 0.08;
          } else {
            p.extra.type = 'star';
            p.x = (waterfallWidth * 1.25) + Math.random() * (w - waterfallWidth * 1.25);
            p.y = Math.random() * (h * 0.7);
            p.radius = Math.random() * (isMobile ? 0.45 : 0.65) + 0.15;
            p.vx = (Math.random() - 0.5) * 0.015;
            p.vy = -(Math.random() * 0.015 + 0.003);
            p.color = 'rgba(254, 243, 199, 0.8)';
          }
        }
      } else if (theme === 'cherryblossom' || theme === 'cherryblossom_light') {
        p.radius = Math.random() * (isMobile ? 2.2 : 3.8) + 1.6;
        p.vy = Math.random() * 0.75 + 0.35;
        p.vx = (Math.random() - 0.25) * 0.28;
        p.color = ['rgba(244, 114, 182, 0.45)', 'rgba(251, 207, 232, 0.5)', 'rgba(244, 63, 94, 0.4)'][Math.floor(Math.random() * 3)];
        p.alpha = Math.random() * 0.4 + 0.3;
        p.extra = {
          angle: Math.random() * Math.PI * 2,
          rotationSpeed: (Math.random() - 0.5) * 0.022,
          swaySpeed: Math.random() * 0.012 + 0.005,
          swayPhase: Math.random() * Math.PI * 2,
          swayAmplitude: Math.random() * 0.8 + 0.4
        };
      } else if (theme === 'aurora') {
        p.radius = Math.random() * 1.5 + 0.4;
        p.vy = -(Math.random() * 0.35 + 0.1);
        p.vx = (Math.random() - 0.5) * 0.15;
        p.color = ['rgba(16, 185, 129, 0.7)', 'rgba(34, 211, 238, 0.65)', 'rgba(255, 255, 255, 0.75)'][Math.floor(Math.random() * 3)];
        p.alpha = Math.random() * 0.5 + 0.3;
      }

      return p;
    };

    let lastWidth = window.innerWidth;
    let lastHeight = window.innerHeight;
    let resizeTimeout;

    const resizeCanvas = () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(() => {
        const width = window.innerWidth;
        const height = window.innerHeight;

        const widthChanged = Math.abs(width - lastWidth) > 8;
        const heightChanged = Math.abs(height - lastHeight) > 120;

        if (widthChanged || heightChanged) {
          canvas.width = width + 8;
          canvas.height = height + 8;
          lastWidth = width;
          lastHeight = height;

          
          backdropCanvas.width = canvas.width;
          backdropCanvas.height = canvas.height;
          renderStaticBackdrop();

          particles.length = 0;
          for (let i = 0; i < particleCount; i++) {
            particles.push(createParticle(true));
          }
        }
      }, 150);
    };

    
    canvas.width = window.innerWidth + 8;
    canvas.height = window.innerHeight + 8;
    
    
    backdropCanvas.width = canvas.width;
    backdropCanvas.height = canvas.height;

    window.addEventListener('resize', resizeCanvas);

    
    for (let i = 0; i < particleCount; i++) {
      particles.push(createParticle(true));
    }

    
    const drawMoon = (pCtx, cWidth, cHeight) => {
      if (!moonCanvas) return;
      if (cWidth < 1024) return;
      pCtx.save();
      const moonX = cWidth - 120;
      const moonY = 180;
      const radius = 35;

      pCtx.beginPath();
      const glowGrad = pCtx.createRadialGradient(moonX, moonY, 0, moonX, moonY, radius * 2.5);
      glowGrad.addColorStop(0, 'rgba(254, 243, 199, 0.18)');
      glowGrad.addColorStop(0.5, 'rgba(254, 243, 199, 0.06)');
      glowGrad.addColorStop(1, 'rgba(254, 243, 199, 0)');
      pCtx.fillStyle = glowGrad;
      pCtx.arc(moonX, moonY, radius * 2.5, 0, Math.PI * 2);
      pCtx.fill();

      pCtx.drawImage(moonCanvas, moonX - 50, moonY - 50);
      pCtx.restore();
    };

    const drawSpacePlanet = (pCtx, cWidth, cHeight) => {
      if (cWidth < 1024) return;
      pCtx.save();
      const pX = 140;
      const pY = 180;
      const radius = isMobile ? 22 : 30;

      pCtx.beginPath();
      const glowGrad = pCtx.createRadialGradient(pX, pY, 0, pX, pY, radius * 2.2);
      glowGrad.addColorStop(0, 'rgba(167, 139, 250, 0.20)');
      glowGrad.addColorStop(0.5, 'rgba(192, 132, 252, 0.05)');
      glowGrad.addColorStop(1, 'rgba(167, 139, 250, 0)');
      pCtx.fillStyle = glowGrad;
      pCtx.arc(pX, pY, radius * 2.2, 0, Math.PI * 2);
      pCtx.fill();

      const ringAngle = -Math.PI / 6;

      pCtx.beginPath();
      pCtx.ellipse(pX, pY, radius * 1.8, radius * 0.4, ringAngle, Math.PI, 0, false);
      pCtx.strokeStyle = 'rgba(192, 132, 252, 0.50)';
      pCtx.lineWidth = isMobile ? 3 : 5;
      pCtx.stroke();

      pCtx.beginPath();
      const planetGrad = pCtx.createLinearGradient(pX - radius, pY - radius, pX + radius, pY + radius);
      planetGrad.addColorStop(0, '#a78bfa');
      planetGrad.addColorStop(0.5, '#7c3aed');
      planetGrad.addColorStop(1, '#4c1d95');
      pCtx.fillStyle = planetGrad;
      pCtx.arc(pX, pY, radius, 0, Math.PI * 2);
      pCtx.fill();

      pCtx.beginPath();
      pCtx.ellipse(pX, pY, radius * 1.8, radius * 0.4, ringAngle, 0, Math.PI, false);
      pCtx.strokeStyle = 'rgba(192, 132, 252, 0.85)';
      pCtx.lineWidth = isMobile ? 3 : 5;
      pCtx.stroke();

      pCtx.restore();
    };

    const drawSunsetSun = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      const sunX = cWidth * 0.5;
      const sunY = cHeight * 0.9;
      const radius = isMobile ? 50 : 80;

      pCtx.beginPath();
      const glowGrad = pCtx.createRadialGradient(sunX, sunY, 0, sunX, sunY, radius * 3.5);
      glowGrad.addColorStop(0, 'rgba(251, 146, 60, 0.22)');
      glowGrad.addColorStop(0.3, 'rgba(239, 68, 68, 0.15)');
      glowGrad.addColorStop(1, 'rgba(251, 146, 60, 0)');
      pCtx.fillStyle = glowGrad;
      pCtx.arc(sunX, sunY, radius * 3.5, 0, Math.PI * 2);
      pCtx.fill();

      pCtx.beginPath();
      const sunGrad = pCtx.createLinearGradient(sunX, sunY - radius, sunX, sunY + radius);
      sunGrad.addColorStop(0, 'rgba(253, 224, 71, 0.85)');
      sunGrad.addColorStop(1, 'rgba(249, 115, 22, 0.35)');
      pCtx.fillStyle = sunGrad;
      pCtx.arc(sunX, sunY, radius, 0, Math.PI * 2);
      pCtx.fill();

      pCtx.restore();
    };

    const drawMountains = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      
      const sunX = cWidth * 0.25;
      const sunY = cHeight * 0.7;
      pCtx.beginPath();
      const sunGrad = pCtx.createRadialGradient(sunX, sunY, 0, sunX, sunY, 110);
      sunGrad.addColorStop(0, 'rgba(252, 211, 77, 0.35)');
      sunGrad.addColorStop(0.4, 'rgba(251, 191, 36, 0.1)');
      sunGrad.addColorStop(1, 'rgba(251, 191, 36, 0)');
      pCtx.fillStyle = sunGrad;
      pCtx.arc(sunX, sunY, 110, 0, Math.PI * 2);
      pCtx.fill();

      pCtx.beginPath();
      pCtx.moveTo(0, cHeight);
      pCtx.lineTo(0, cHeight * 0.76);
      pCtx.lineTo(cWidth * 0.25, cHeight * 0.52);
      pCtx.lineTo(cWidth * 0.45, cHeight * 0.68);
      pCtx.lineTo(cWidth * 0.7, cHeight * 0.42);
      pCtx.lineTo(cWidth * 0.85, cHeight * 0.60);
      pCtx.lineTo(cWidth, cHeight * 0.35);
      pCtx.lineTo(cWidth, cHeight);
      pCtx.closePath();

      const mtGrad1 = pCtx.createLinearGradient(0, cHeight * 0.35, 0, cHeight);
      mtGrad1.addColorStop(0, 'rgba(34, 197, 94, 0.18)');
      mtGrad1.addColorStop(1, 'rgba(21, 128, 61, 0.38)');
      pCtx.fillStyle = mtGrad1;
      pCtx.fill();

      pCtx.beginPath();
      pCtx.moveTo(0, cHeight);
      pCtx.lineTo(0, cHeight * 0.86);
      pCtx.lineTo(cWidth * 0.15, cHeight * 0.68);
      pCtx.lineTo(cWidth * 0.38, cHeight * 0.78);
      pCtx.lineTo(cWidth * 0.55, cHeight * 0.54);
      pCtx.lineTo(cWidth * 0.75, cHeight * 0.74);
      pCtx.lineTo(cWidth * 0.9, cHeight * 0.64);
      pCtx.lineTo(cWidth, cHeight * 0.82);
      pCtx.lineTo(cWidth, cHeight);
      pCtx.closePath();

      const mtGrad2 = pCtx.createLinearGradient(0, cHeight * 0.50, 0, cHeight);
      mtGrad2.addColorStop(0, 'rgba(21, 128, 61, 0.32)');
      mtGrad2.addColorStop(1, 'rgba(20, 83, 45, 0.58)');
      pCtx.fillStyle = mtGrad2;
      pCtx.fill();

      pCtx.restore();
    };

    const drawMountainMorning = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      
      const sunX = cWidth * 0.35;
      const sunY = cHeight * 0.65;
      const sunRadius = isMobile ? 45 : 70;

      pCtx.beginPath();
      const glowGrad = pCtx.createRadialGradient(sunX, sunY, 0, sunX, sunY, sunRadius * 4);
      glowGrad.addColorStop(0, 'rgba(253, 186, 116, 0.35)');
      glowGrad.addColorStop(0.3, 'rgba(244, 63, 94, 0.18)');
      glowGrad.addColorStop(0.6, 'rgba(254, 243, 199, 0.08)');
      glowGrad.addColorStop(1, 'rgba(254, 243, 199, 0)');
      pCtx.fillStyle = glowGrad;
      pCtx.arc(sunX, sunY, sunRadius * 4, 0, Math.PI * 2);
      pCtx.fill();

      const rayCount = 8;
      for (let i = 0; i < rayCount; i++) {
        const angle = (i * Math.PI * 2) / rayCount;
        const startX = sunX;
        const startY = sunY;
        const endX = sunX + Math.cos(angle) * (sunRadius * 4.5);
        const endY = sunY + Math.sin(angle) * (sunRadius * 4.5);

        pCtx.beginPath();
        const rayGrad = pCtx.createLinearGradient(startX, startY, endX, endY);
        rayGrad.addColorStop(0, 'rgba(253, 186, 116, 0.12)');
        rayGrad.addColorStop(0.5, 'rgba(244, 63, 94, 0.04)');
        rayGrad.addColorStop(1, 'rgba(254, 243, 199, 0)');
        pCtx.strokeStyle = rayGrad;
        pCtx.lineWidth = isMobile ? 12 : 24;
        pCtx.moveTo(startX, startY);
        pCtx.lineTo(endX, endY);
        pCtx.stroke();
      }

      pCtx.beginPath();
      const sunGrad = pCtx.createLinearGradient(sunX, sunY - sunRadius, sunX, sunY + sunRadius);
      sunGrad.addColorStop(0, 'rgba(255, 253, 245, 0.95)');
      sunGrad.addColorStop(0.4, 'rgba(253, 224, 71, 0.85)');
      sunGrad.addColorStop(1, 'rgba(249, 115, 22, 0.4)');
      pCtx.fillStyle = sunGrad;
      pCtx.arc(sunX, sunY, sunRadius, 0, Math.PI * 2);
      pCtx.fill();

      pCtx.beginPath();
      pCtx.moveTo(0, cHeight);
      pCtx.lineTo(0, cHeight * 0.72);
      pCtx.quadraticCurveTo(cWidth * 0.25, cHeight * 0.58, cWidth * 0.50, cHeight * 0.78);
      pCtx.quadraticCurveTo(cWidth * 0.72, cHeight * 0.54, cWidth * 0.90, cHeight * 0.80);
      pCtx.lineTo(cWidth, cHeight * 0.72);
      pCtx.lineTo(cWidth, cHeight);
      pCtx.closePath();

      const bgMtGrad = pCtx.createLinearGradient(0, cHeight * 0.55, 0, cHeight);
      bgMtGrad.addColorStop(0, 'rgba(224, 150, 140, 0.12)');
      bgMtGrad.addColorStop(1, 'rgba(190, 120, 115, 0.25)');
      pCtx.fillStyle = bgMtGrad;
      pCtx.fill();

      pCtx.beginPath();
      pCtx.moveTo(0, cHeight);
      pCtx.lineTo(0, cHeight * 0.82);
      pCtx.quadraticCurveTo(cWidth * 0.30, cHeight * 0.72, cWidth * 0.58, cHeight * 0.86);
      pCtx.quadraticCurveTo(cWidth * 0.82, cHeight * 0.66, cWidth, cHeight * 0.80);
      pCtx.lineTo(cWidth, cHeight);
      pCtx.closePath();

      const fgMtGrad = pCtx.createLinearGradient(0, cHeight * 0.66, 0, cHeight);
      fgMtGrad.addColorStop(0, 'rgba(87, 74, 70, 0.20)');
      fgMtGrad.addColorStop(1, 'rgba(68, 60, 58, 0.40)');
      pCtx.fillStyle = fgMtGrad;
      pCtx.fill();

      pCtx.restore();
    };

    const renderStaticWaterfall = (pCtx, cWidth, cHeight) => {
      if (cWidth < 1024) return;
      pCtx.save();
      
      const waterfallWidth = Math.min(220, cWidth * 0.22);
      
      const skyGrad = pCtx.createLinearGradient(waterfallWidth, 0, cWidth, cHeight);
      skyGrad.addColorStop(0, 'rgba(6, 18, 23, 0.2)');
      skyGrad.addColorStop(1, 'rgba(2, 6, 8, 0.45)');
      pCtx.fillStyle = skyGrad;
      pCtx.fillRect(waterfallWidth, 0, cWidth - waterfallWidth, cHeight);

      pCtx.beginPath();
      pCtx.moveTo(0, 0);
      pCtx.lineTo(waterfallWidth * 1.1, 0);
      pCtx.lineTo(waterfallWidth, cHeight * 0.15);
      pCtx.lineTo(waterfallWidth * 0.85, cHeight * 0.15);
      pCtx.bezierCurveTo(
        waterfallWidth * 0.75, cHeight * 0.4,
        waterfallWidth * 0.5, cHeight * 0.7,
        waterfallWidth * 0.65, cHeight
      );
      pCtx.lineTo(0, cHeight);
      pCtx.closePath();

      const cliffGrad = pCtx.createLinearGradient(0, 0, waterfallWidth, cHeight);
      cliffGrad.addColorStop(0, 'rgba(10, 29, 38, 0.45)');
      cliffGrad.addColorStop(0.5, 'rgba(7, 21, 28, 0.55)');
      cliffGrad.addColorStop(1, 'rgba(3, 10, 13, 0.65)');
      pCtx.fillStyle = cliffGrad;
      pCtx.fill();

      pCtx.beginPath();
      pCtx.strokeStyle = 'rgba(22, 78, 99, 0.18)';
      pCtx.lineWidth = 1.6;
      pCtx.moveTo(waterfallWidth * 0.85, cHeight * 0.15);
      pCtx.bezierCurveTo(
        waterfallWidth * 0.75, cHeight * 0.4,
        waterfallWidth * 0.4, cHeight * 0.7,
        waterfallWidth * 0.55, cHeight
      );
      pCtx.stroke();

      pCtx.restore();
    };

    const drawWaterfallDynamic = (pCtx, cWidth, cHeight) => {
      if (cWidth < 1024) return;
      pCtx.save();
      
      const waterfallWidth = Math.min(220, cWidth * 0.22);
      const time = Date.now() * 0.0035;

      const wStart = waterfallWidth * 0.16;
      const wEnd = waterfallWidth * 0.80;
      const wBodyGrad = pCtx.createLinearGradient(wStart, 0, wEnd, 0);
      wBodyGrad.addColorStop(0, 'rgba(6, 182, 212, 0.05)');
      wBodyGrad.addColorStop(0.25, 'rgba(165, 243, 252, 0.16)');
      wBodyGrad.addColorStop(0.5, 'rgba(255, 255, 255, 0.28)');
      wBodyGrad.addColorStop(0.75, 'rgba(165, 243, 252, 0.16)');
      wBodyGrad.addColorStop(1, 'rgba(6, 182, 212, 0.04)');
      
      pCtx.fillStyle = wBodyGrad;
      pCtx.beginPath();
      pCtx.moveTo(wStart, cHeight * 0.15);
      for (let y = cHeight * 0.15; y <= cHeight; y += 30) {
        const leftSway = Math.sin(y * 0.045 - time * 7.5) * 1.8;
        pCtx.lineTo(wStart + leftSway, y);
      }
      for (let y = cHeight; y >= cHeight * 0.15; y -= 30) {
        const rightSway = Math.sin(y * 0.035 - time * 8.5 + 2.0) * 1.8;
        pCtx.lineTo(wEnd + rightSway, y);
      }
      pCtx.closePath();
      pCtx.fill();

      const streamCount = 14;
      for (let i = 0; i < streamCount; i++) {
        const startPct = 0.18 + (i / (streamCount - 1)) * 0.60;
        const startX = waterfallWidth * startPct;
        
        pCtx.beginPath();
        if (i % 4 === 0) {
          pCtx.strokeStyle = 'rgba(255, 255, 255, 0.42)';
          pCtx.lineWidth = Math.random() * 2.2 + 1.2;
        } else if (i % 3 === 0) {
          pCtx.strokeStyle = 'rgba(165, 243, 252, 0.32)';
          pCtx.lineWidth = Math.random() * 2.8 + 1.0;
        } else if (i % 2 === 0) {
          pCtx.strokeStyle = 'rgba(34, 211, 238, 0.22)';
          pCtx.lineWidth = Math.random() * 2.0 + 0.8;
        } else {
          pCtx.strokeStyle = 'rgba(255, 255, 255, 0.18)';
          pCtx.lineWidth = Math.random() * 1.2 + 0.5;
        }
        
        pCtx.moveTo(startX, cHeight * 0.15);
        
        const freq = 0.06 + (i % 3) * 0.025;
        const speed = 16.0 + (i % 4) * 2.5;
        const amp = 0.6 + Math.random() * 0.8;
        
        for (let y = cHeight * 0.15; y <= cHeight; y += 40) {
          const sway = Math.sin(y * freq + time * speed + i) * amp;
          pCtx.lineTo(startX + sway, y);
        }
        pCtx.stroke();
      }

      const crestAlpha = 0.5 + Math.sin(time * 4.5) * 0.12;
      const ledgeGrad = pCtx.createLinearGradient(waterfallWidth * 0.15, 0, waterfallWidth * 0.85, 0);
      ledgeGrad.addColorStop(0, 'rgba(165, 243, 252, 0)');
      ledgeGrad.addColorStop(0.3, `rgba(255, 255, 255, ${crestAlpha * 0.75})`);
      ledgeGrad.addColorStop(0.5, `rgba(207, 250, 254, ${crestAlpha * 0.95})`);
      ledgeGrad.addColorStop(0.7, `rgba(255, 255, 255, ${crestAlpha * 0.75})`);
      ledgeGrad.addColorStop(1, 'rgba(165, 243, 252, 0)');
      
      pCtx.fillStyle = ledgeGrad;
      pCtx.beginPath();
      pCtx.ellipse(
        waterfallWidth * 0.48,
        cHeight * 0.15,
        waterfallWidth * 0.34,
        4.0 + Math.sin(time * 3.5) * 1.0,
        0,
        0,
        Math.PI * 2
      );
      pCtx.fill();

      const waveLayers = [
        { fill: 'rgba(207, 250, 254, 0.22)', amp: 4.0, freq: 0.045, speed: 6.0, offset: 0, height: 26 },
        { fill: 'rgba(165, 243, 252, 0.30)', amp: 2.8, freq: 0.065, speed: -7.5, offset: Math.PI / 2, height: 18 },
        { fill: 'rgba(255, 255, 255, 0.40)', amp: 1.8, freq: 0.085, speed: 10.0, offset: Math.PI, height: 12 }
      ];
      
      waveLayers.forEach((wave) => {
        pCtx.fillStyle = wave.fill;
        pCtx.beginPath();
        pCtx.moveTo(0, cHeight);
        for (let x = 0; x <= waterfallWidth * 1.15; x += 12) {
          const waveSway = Math.sin(x * wave.freq + time * wave.speed + wave.offset) * wave.amp
                         + Math.cos(x * (wave.freq * 0.35) - time * (wave.speed * 0.25)) * (wave.amp * 0.4);
          pCtx.lineTo(x, cHeight - wave.height + waveSway);
        }
        pCtx.lineTo(waterfallWidth * 1.15, cHeight);
        pCtx.closePath();
        pCtx.fill();
      });

      const mistOverlayGrad = pCtx.createLinearGradient(0, cHeight - 140, waterfallWidth * 1.25, cHeight);
      mistOverlayGrad.addColorStop(0, 'rgba(6, 182, 212, 0)');
      mistOverlayGrad.addColorStop(0.5, 'rgba(165, 243, 252, 0.06)');
      mistOverlayGrad.addColorStop(1, 'rgba(255, 255, 255, 0.16)');
      pCtx.fillStyle = mistOverlayGrad;
      pCtx.fillRect(0, cHeight - 140, waterfallWidth * 1.25, 140);

      pCtx.restore();
    };

    const drawCherryBlossomBackdrop = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      const mX = cWidth * 0.82;
      const mY = cHeight * 0.22;
      const radius = Math.min(65, cWidth * 0.08);
      
      pCtx.beginPath();
      const moonGlow = pCtx.createRadialGradient(mX, mY, 0, mX, mY, radius * 2.5);
      moonGlow.addColorStop(0, 'rgba(255, 241, 242, 0.22)');
      moonGlow.addColorStop(0.3, 'rgba(244, 114, 182, 0.08)');
      moonGlow.addColorStop(1, 'rgba(20, 10, 21, 0)');
      pCtx.fillStyle = moonGlow;
      pCtx.arc(mX, mY, radius * 2.5, 0, Math.PI * 2);
      pCtx.fill();
      
      pCtx.beginPath();
      pCtx.fillStyle = 'rgba(255, 241, 242, 0.88)';
      pCtx.shadowColor = 'rgba(244, 114, 182, 0.4)';
      pCtx.shadowBlur = 25;
      pCtx.arc(mX, mY, radius, 0, Math.PI * 2);
      pCtx.fill();
      
      pCtx.restore();
    };

    const drawCherryBlossomLightBackdrop = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      const mX = cWidth * 0.82;
      const mY = cHeight * 0.22;
      const radius = Math.min(65, cWidth * 0.08);
      
      pCtx.beginPath();
      const sunGlow = pCtx.createRadialGradient(mX, mY, 0, mX, mY, radius * 3.5);
      sunGlow.addColorStop(0, 'rgba(255, 255, 255, 0.45)');
      sunGlow.addColorStop(0.3, 'rgba(253, 224, 71, 0.15)');
      sunGlow.addColorStop(0.6, 'rgba(251, 207, 232, 0.08)');
      sunGlow.addColorStop(1, 'rgba(255, 240, 243, 0)');
      pCtx.fillStyle = sunGlow;
      pCtx.arc(mX, mY, radius * 3.5, 0, Math.PI * 2);
      pCtx.fill();
      
      pCtx.beginPath();
      pCtx.fillStyle = 'rgba(255, 255, 255, 0.95)';
      pCtx.shadowColor = 'rgba(251, 207, 232, 0.5)';
      pCtx.shadowBlur = 30;
      pCtx.arc(mX, mY, radius, 0, Math.PI * 2);
      pCtx.fill();
      
      pCtx.restore();
    };

    const drawAuroraBackdrop = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      const time = Date.now() * 0.0006;
      
      const curtains = [
        { color: 'rgba(16, 185, 129, 0.09)', offset: 0, speed: 1.0, heightPct: 0.65 },
        { color: 'rgba(6, 182, 212, 0.07)', offset: Math.PI / 2, speed: 0.8, heightPct: 0.55 },
        { color: 'rgba(52, 211, 153, 0.05)', offset: Math.PI, speed: 1.2, heightPct: 0.75 }
      ];
      
      curtains.forEach((c) => {
        pCtx.beginPath();
        const grad = pCtx.createLinearGradient(0, 0, 0, cHeight * c.heightPct);
        grad.addColorStop(0, c.color);
        grad.addColorStop(0.5, c.color.replace('0.0', '0.04'));
        grad.addColorStop(1, 'rgba(0, 0, 0, 0)');
        
        pCtx.fillStyle = grad;
        
        pCtx.moveTo(0, cHeight * c.heightPct);
        pCtx.lineTo(0, cHeight * 0.15);
        
        for (let x = 0; x <= cWidth; x += 40) {
          const waveY = cHeight * 0.25 
            + Math.sin(x * 0.004 + time * c.speed + c.offset) * 45 
            + Math.cos(x * 0.002 - time * c.speed * 0.6) * 20;
          pCtx.lineTo(x, waveY);
        }
        
        pCtx.lineTo(cWidth, cHeight * c.heightPct);
        pCtx.closePath();
        pCtx.fill();
      });
      
      pCtx.restore();
    };

    const drawRainyBackdrop = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      const cloudGrad = pCtx.createLinearGradient(0, 0, 0, cHeight * 0.35);
      cloudGrad.addColorStop(0, 'rgba(71, 85, 105, 0.28)');
      cloudGrad.addColorStop(0.5, 'rgba(100, 116, 139, 0.12)');
      cloudGrad.addColorStop(1, 'rgba(100, 116, 139, 0)');
      pCtx.fillStyle = cloudGrad;
      
      pCtx.beginPath();
      pCtx.arc(cWidth * 0.1, 0, cWidth * 0.22, 0, Math.PI * 2);
      pCtx.arc(cWidth * 0.35, 0, cWidth * 0.28, 0, Math.PI * 2);
      pCtx.arc(cWidth * 0.65, 0, cWidth * 0.32, 0, Math.PI * 2);
      pCtx.arc(cWidth * 0.9, 0, cWidth * 0.25, 0, Math.PI * 2);
      pCtx.closePath();
      pCtx.fill();

      const cloudGrad2 = pCtx.createLinearGradient(0, 0, 0, cHeight * 0.25);
      cloudGrad2.addColorStop(0, 'rgba(148, 163, 184, 0.2)');
      cloudGrad2.addColorStop(1, 'rgba(148, 163, 184, 0)');
      pCtx.fillStyle = cloudGrad2;
      pCtx.beginPath();
      pCtx.arc(cWidth * 0.2, 0, cWidth * 0.18, 0, Math.PI * 2);
      pCtx.arc(cWidth * 0.5, 0, cWidth * 0.24, 0, Math.PI * 2);
      pCtx.arc(cWidth * 0.8, 0, cWidth * 0.2, 0, Math.PI * 2);
      pCtx.closePath();
      pCtx.fill();
      
      pCtx.restore();
    };

    const drawForestBackdrop = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      pCtx.fillStyle = isLightTheme(theme) ? 'rgba(16, 185, 129, 0.08)' : 'rgba(16, 185, 129, 0.04)';
      const bgTreeCount = isMobile ? 8 : 16;
      const bgStep = cWidth / bgTreeCount;
      for (let i = 0; i <= bgTreeCount; i++) {
        const x = i * bgStep + (Math.sin(i) * 10);
        const treeHeight = (isMobile ? 120 : 200) + (Math.cos(i * 1.5) * 40);
        const y = cHeight - treeHeight;
        const width = isMobile ? 35 : 60;
        
        pCtx.beginPath();
        pCtx.moveTo(x, y);
        pCtx.lineTo(x - width * 0.5, y + treeHeight * 0.4);
        pCtx.lineTo(x - width * 0.3, y + treeHeight * 0.4);
        pCtx.lineTo(x - width * 0.7, y + treeHeight * 0.7);
        pCtx.lineTo(x - width * 0.4, y + treeHeight * 0.7);
        pCtx.lineTo(x - width * 0.9, cHeight);
        pCtx.lineTo(x + width * 0.9, cHeight);
        pCtx.lineTo(x + width * 0.4, y + treeHeight * 0.7);
        pCtx.lineTo(x + width * 0.7, y + treeHeight * 0.7);
        pCtx.lineTo(x + width * 0.3, y + treeHeight * 0.4);
        pCtx.lineTo(x + width * 0.5, y + treeHeight * 0.4);
        pCtx.closePath();
        pCtx.fill();
      }

      pCtx.fillStyle = isLightTheme(theme) ? 'rgba(21, 128, 61, 0.16)' : 'rgba(21, 128, 61, 0.09)';
      const fgTreeCount = isMobile ? 10 : 20;
      const fgStep = cWidth / fgTreeCount;
      for (let i = 0; i <= fgTreeCount; i++) {
        const x = i * fgStep + (Math.sin(i * 2) * 8);
        const treeHeight = (isMobile ? 80 : 140) + (Math.sin(i * 2.3) * 25);
        const y = cHeight - treeHeight;
        const width = isMobile ? 25 : 45;
        
        pCtx.beginPath();
        pCtx.moveTo(x, y);
        pCtx.lineTo(x - width * 0.5, y + treeHeight * 0.4);
        pCtx.lineTo(x - width * 0.3, y + treeHeight * 0.4);
        pCtx.lineTo(x - width * 0.7, y + treeHeight * 0.7);
        pCtx.lineTo(x - width * 0.4, y + treeHeight * 0.7);
        pCtx.lineTo(x - width * 0.9, cHeight);
        pCtx.lineTo(x + width * 0.9, cHeight);
        pCtx.lineTo(x + width * 0.4, y + treeHeight * 0.7);
        pCtx.lineTo(x + width * 0.7, y + treeHeight * 0.7);
        pCtx.lineTo(x + width * 0.3, y + treeHeight * 0.4);
        pCtx.lineTo(x + width * 0.5, y + treeHeight * 0.4);
        pCtx.closePath();
        pCtx.fill();
      }
      
      pCtx.restore();
    };

    const drawOceanBackdrop = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      const time = Date.now() * 0.0006;
      
      pCtx.fillStyle = isLightTheme(theme) ? 'rgba(14, 165, 233, 0.08)' : 'rgba(14, 165, 233, 0.04)';
      pCtx.beginPath();
      pCtx.moveTo(0, cHeight);
      for (let x = 0; x <= cWidth; x += 15) {
        const y = cHeight - (isMobile ? 60 : 100) + Math.sin(x * 0.003 + time) * 15;
        pCtx.lineTo(x, y);
      }
      pCtx.lineTo(cWidth, cHeight);
      pCtx.closePath();
      pCtx.fill();

      pCtx.fillStyle = isLightTheme(theme) ? 'rgba(2, 132, 199, 0.12)' : 'rgba(2, 132, 199, 0.07)';
      pCtx.beginPath();
      pCtx.moveTo(0, cHeight);
      for (let x = 0; x <= cWidth; x += 15) {
        const y = cHeight - (isMobile ? 45 : 75) + Math.cos(x * 0.004 - time * 0.8) * 12;
        pCtx.lineTo(x, y);
      }
      pCtx.lineTo(cWidth, cHeight);
      pCtx.closePath();
      pCtx.fill();

      pCtx.fillStyle = isLightTheme(theme) ? 'rgba(3, 105, 161, 0.16)' : 'rgba(3, 105, 161, 0.10)';
      pCtx.beginPath();
      pCtx.moveTo(0, cHeight);
      for (let x = 0; x <= cWidth; x += 15) {
        const y = cHeight - (isMobile ? 30 : 50) + Math.sin(x * 0.005 + time * 1.2) * 8;
        pCtx.lineTo(x, y);
      }
      pCtx.lineTo(cWidth, cHeight);
      pCtx.closePath();
      pCtx.fill();
      
      pCtx.restore();
    };

    const drawVoidBackdrop = (pCtx, cWidth, cHeight) => {
      pCtx.save();
      const cX = cWidth * 0.5;
      const cY = cHeight * 0.45;
      const radius = isMobile ? 90 : 150;
      
      pCtx.beginPath();
      const glowGrad = pCtx.createRadialGradient(cX, cY, radius * 0.8, cX, cY, radius * 2.2);
      glowGrad.addColorStop(0, 'rgba(255, 255, 255, 0.03)');
      glowGrad.addColorStop(0.5, 'rgba(255, 255, 255, 0.01)');
      glowGrad.addColorStop(1, 'rgba(255, 255, 255, 0)');
      pCtx.fillStyle = glowGrad;
      pCtx.arc(cX, cY, radius * 2.2, 0, Math.PI * 2);
      pCtx.fill();

      pCtx.beginPath();
      pCtx.strokeStyle = 'rgba(255, 255, 255, 0.04)';
      pCtx.lineWidth = 1;
      pCtx.arc(cX, cY, radius, 0, Math.PI * 2);
      pCtx.stroke();

      pCtx.beginPath();
      pCtx.strokeStyle = 'rgba(255, 255, 255, 0.02)';
      pCtx.lineWidth = 0.8;
      pCtx.ellipse(cX, cY, radius * 1.5, radius * 0.15, -Math.PI / 12, 0, Math.PI * 2);
      pCtx.stroke();
      
      pCtx.restore();
    };

    const renderStaticBackdrop = () => {
      const cWidth = canvas.width;
      const cHeight = canvas.height;
      
      bCtx.clearRect(0, 0, cWidth, cHeight);
      
      if (theme === 'night') {
        drawMoon(bCtx, cWidth, cHeight);
      } else if (theme === 'space') {
        drawSpacePlanet(bCtx, cWidth, cHeight);
      } else if (theme === 'sunset') {
        drawSunsetSun(bCtx, cWidth, cHeight);
      } else if (theme === 'mountains' || theme === 'mountains morning') {
        drawMountains(bCtx, cWidth, cHeight);
      } else if (theme === 'mountain_morning') {
        drawMountainMorning(bCtx, cWidth, cHeight);
      } else if (theme === 'waterfall') {
        renderStaticWaterfall(bCtx, cWidth, cHeight);
      } else if (theme === 'rainy') {
        drawRainyBackdrop(bCtx, cWidth, cHeight);
      } else if (theme === 'forest') {
        drawForestBackdrop(bCtx, cWidth, cHeight);
      } else if (theme === 'void') {
        drawVoidBackdrop(bCtx, cWidth, cHeight);
      } else if (theme === 'cherryblossom') {
        drawCherryBlossomBackdrop(bCtx, cWidth, cHeight);
      } else if (theme === 'cherryblossom_light') {
        drawCherryBlossomLightBackdrop(bCtx, cWidth, cHeight);
      }
    };

    
    renderStaticBackdrop();

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

    const animate = (timestamp) => {
      animationFrameId = requestAnimationFrame(animate);

      const now = timestamp || performance.now();
      const elapsed = now - lastTime;
      if (elapsed < fpsInterval) return;
      lastTime = now - (elapsed % fpsInterval);

      ctx.clearRect(0, 0, canvas.width, canvas.height);
      const time = now * 0.0035;

      
      ctx.drawImage(backdropCanvas, 0, 0);

      
      if (theme === 'aurora') {
        drawAuroraBackdrop(ctx, canvas.width, canvas.height);
      } else if (theme === 'ocean') {
        drawOceanBackdrop(ctx, canvas.width, canvas.height);
      } else if (theme === 'waterfall') {
        drawWaterfallDynamic(ctx, canvas.width, canvas.height);
      }

      
      particles.forEach((p, index) => {
        
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
            p.x += p.vx + Math.sin(p.y * 0.025 + time) * 0.22;
            p.y += p.vy;
            p.alpha = Math.max(0, p.alpha - 0.0025);
          } else {
            p.x += p.vx;
            p.y += p.vy;
          }
        } else if (theme === 'cherryblossom' || theme === 'cherryblossom_light') {
          p.extra.swayPhase += p.extra.swaySpeed;
          p.extra.angle += p.extra.rotationSpeed;
          p.x += p.vx + Math.sin(p.extra.swayPhase) * p.extra.swayAmplitude * 0.3;
          p.y += p.vy;
        } else if (theme === 'aurora') {
          p.x += p.vx;
          p.y += p.vy;
        } else {
          p.x += p.vx;
          p.y += p.vy;
        }

        
        p.twinklePhase += p.twinkleSpeed;
        const currentAlpha = Math.max(0.05, p.alpha + Math.sin(p.twinklePhase) * 0.18);

        
        if (theme === 'rainy') {
          ctx.beginPath();
          ctx.strokeStyle = `rgba(174, 207, 238, ${currentAlpha})`;
          ctx.lineWidth = p.radius;
          ctx.moveTo(p.x, p.y);
          ctx.lineTo(p.x + p.vx * 0.8, p.y + p.extra.length);
          ctx.stroke();
        } else if (theme === 'forest') {
          drawLeaf(ctx, p.x, p.y, p.radius, p.extra.angle, p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`);
        } else if (theme === 'ocean') {
          ctx.beginPath();
          ctx.strokeStyle = p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`;
          ctx.lineWidth = 1;
          ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
          ctx.stroke();
          
          ctx.beginPath();
          ctx.fillStyle = `rgba(255, 255, 255, ${currentAlpha * 0.4})`;
          ctx.arc(p.x - p.radius * 0.3, p.y - p.radius * 0.3, p.radius * 0.2, 0, Math.PI * 2);
          ctx.fill();
        } else if (theme === 'waterfall') {
          if (p.extra.type === 'droplet') {
            ctx.beginPath();
            ctx.strokeStyle = Math.random() < 0.5 
              ? `rgba(255, 255, 255, ${currentAlpha * 0.8})` 
              : `rgba(165, 243, 252, ${currentAlpha * 0.75})`;
            ctx.lineWidth = p.radius;
            ctx.moveTo(p.x, p.y);
            ctx.lineTo(p.x + p.vx * 0.6, p.y + p.vy * 1.6);
            ctx.stroke();
          } else if (p.extra.type === 'mist') {
            ctx.beginPath();
            const mistGrad = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.radius);
            mistGrad.addColorStop(0, `rgba(207, 250, 254, ${currentAlpha * 0.35})`);
            mistGrad.addColorStop(1, 'rgba(207, 250, 254, 0)');
            ctx.fillStyle = mistGrad;
            ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
            ctx.fill();
          } else {
            ctx.beginPath();
            ctx.fillStyle = p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`;
            ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
            ctx.fill();
          }
        } else if (theme === 'cherryblossom' || theme === 'cherryblossom_light') {
          drawLeaf(ctx, p.x, p.y, p.radius, p.extra.angle, p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`);
        } else if (theme === 'aurora') {
          ctx.beginPath();
          ctx.fillStyle = p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`;
          ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
          ctx.fill();
        } else {
          ctx.beginPath();
          ctx.fillStyle = p.color.substring(0, p.color.lastIndexOf(',')) + `, ${currentAlpha})`;
          ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
          ctx.fill();
        }

        
        let isOffScreen = false;
        if (theme === 'snow' || theme === 'winter' || theme === 'rainy' || theme === 'forest' || theme === 'cherryblossom' || theme === 'cherryblossom_light') {
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
          if (theme === 'snow' || theme === 'winter' || theme === 'rainy' || theme === 'forest' || theme === 'cherryblossom' || theme === 'cherryblossom_light') {
            particles[index].y = -10;
          } else if (theme === 'waterfall' && particles[index].extra.type === 'droplet') {
            particles[index].y = canvas.height * 0.15;
          }
        }
      });

      
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
    };

    animate();

    return () => {
      window.removeEventListener('resize', resizeCanvas);
      clearTimeout(resizeTimeout);
      cancelAnimationFrame(animationFrameId);
    };
  }, [theme, settings.enableAnimations, isMobile]);

  if (settings.enableAnimations === false || isMobile) return null;
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
