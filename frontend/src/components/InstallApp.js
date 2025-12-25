import React, { useState, useEffect } from 'react';
import { Download, Monitor, Smartphone, AppWindow } from 'lucide-react';

const InstallApp = () => {
    const [deferredPrompt, setDeferredPrompt] = useState(null);
    const [isInstalled, setIsInstalled] = useState(false);
    const [showPrompt, setShowPrompt] = useState(false);

    useEffect(() => {
        window.addEventListener('beforeinstallprompt', (e) => {
            // Prevent Chrome 67 and earlier from automatically showing the prompt
            e.preventDefault();
            // Stash the event so it can be triggered later.
            setDeferredPrompt(e);
            setShowPrompt(true);
        });

        window.addEventListener('appinstalled', (evt) => {
            setIsInstalled(true);
            setShowPrompt(false);
            console.log('App was installed');
        });

        // Check if already installed
        if (window.matchMedia('(display-mode: standalone)').matches) {
            setIsInstalled(true);
        }
    }, []);

    const handleInstallClick = async () => {
        if (!deferredPrompt) return;

        // Show the prompt
        deferredPrompt.prompt();

        // Wait for the user to respond to the prompt
        const { outcome } = await deferredPrompt.userChoice;
        console.log(`User response to the install prompt: ${outcome}`);

        // We've used the prompt, and can't use it again, throw it away
        setDeferredPrompt(null);
        setShowPrompt(false);
    };

    const apkDownloadUrl = `${process.env.PUBLIC_URL}/download/Sant-Vaani.apk`;

    return (
        <section className="container mt-5 mb-5">
            <div className="card install-card" style={{
                background: 'linear-gradient(135deg, #2c1810 0%, #4a2c1a 100%)',
                color: '#fff5e6',
                border: 'none',
                overflow: 'hidden',
                position: 'relative'
            }}>
                <div className="install-content" style={{ position: 'relative', zIndex: 2 }}>
                    <div className="row align-items-center">
                        <div className="col-md-7">
                            <h2 style={{ color: '#f59e0b', fontSize: '2rem', marginBottom: '1.5rem' }}>
                                Carry Wisdom in Your Pocket
                            </h2>
                            <p style={{ fontSize: '1.1rem', marginBottom: '2rem', color: '#d1cdc7', lineHeight: '1.7' }}>
                                Download the <strong style={{ color: '#fff' }}>Vrindopnishad App</strong> to access sacred content offline, receive daily inspirations, and experience a fully immersive spiritual journey.
                            </p>

                            <div className="install-actions" style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
                                {showPrompt && !isInstalled && (
                                    <button
                                        onClick={handleInstallClick}
                                        className="btn btn-primary"
                                        style={{ background: '#f59e0b', border: 'none', color: '#2c1810' }}
                                    >
                                        <AppWindow size={20} style={{ marginRight: '0.5rem' }} />
                                        Install Web App (PWA)
                                    </button>
                                )}

                                <a
                                    href={apkDownloadUrl}
                                    download
                                    className="btn btn-primary"
                                    style={{ background: '#fff', border: 'none', color: '#2c1810' }}
                                >
                                    <Smartphone size={20} style={{ marginRight: '0.5rem' }} />
                                    Download Android APK
                                </a>
                            </div>

                            <p style={{ marginTop: '1.5rem', fontSize: '0.85rem', color: '#999' }}>
                                * Web App works on all devices (iOS, Android, Windows, Mac).
                            </p>
                        </div>
                        <div className="col-md-5 d-none d-md-block text-center">
                            <div className="phone-mockup" style={{
                                width: '240px',
                                height: '480px',
                                background: '#1a1a1a',
                                borderRadius: '32px',
                                border: '8px solid #333',
                                margin: '0 auto',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                boxShadow: '0 20px 50px rgba(0,0,0,0.5)',
                                position: 'relative'
                            }}>
                                <div style={{
                                    width: '100%',
                                    height: '100%',
                                    padding: '10px',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    gap: '10px'
                                }}>
                                    <div style={{ height: '40%', background: '#2c1810', borderRadius: '15px' }}></div>
                                    <div style={{ height: '10%', background: '#444', borderRadius: '5px', width: '80%' }}></div>
                                    <div style={{ height: '10%', background: '#444', borderRadius: '5px', width: '60%' }}></div>
                                    <div style={{ flex: 1, background: '#333', borderRadius: '15px' }}></div>
                                </div>
                                <div className="om-symbol" style={{
                                    position: 'absolute',
                                    fontSize: '5rem',
                                    opacity: 0.1,
                                    top: '50%',
                                    left: '50%',
                                    transform: 'translate(-50%, -50%)',
                                    color: '#f59e0b'
                                }}>ॐ</div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Decorative Elements */}
                <div style={{
                    position: 'absolute',
                    top: '-50px',
                    right: '-50px',
                    width: '300px',
                    height: '300px',
                    background: 'radial-gradient(circle, rgba(245, 158, 11, 0.1) 0%, transparent 70%)',
                    borderRadius: '50%'
                }}></div>
            </div>
        </section>
    );
};

export default InstallApp;
