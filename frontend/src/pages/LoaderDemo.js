import React, { useState } from 'react';
import Loader from '../components/Loader';
import { useLoading } from '../contexts/LoadingContext';
import Navigation from '../components/Navigation';

/**
 * LoaderDemo Component - Demonstrates all loader variations
 * This is a test/demo page to showcase the loader component
 * Can be accessed at /loader-demo route
 */
const LoaderDemo = () => {
    const [showInlineLoader, setShowInlineLoader] = useState(false);
    const { showLoading, hideLoading } = useLoading();

    const simulateAsyncOperation = () => {
        showLoading('Simulating async operation...');
        setTimeout(() => {
            hideLoading();
            alert('Operation complete!');
        }, 3000);
    };

    const simulateWithCustomText = () => {
        showLoading('Custom loading message...');
        setTimeout(() => {
            hideLoading();
        }, 2500);
    };

    const toggleInlineLoader = () => {
        setShowInlineLoader(!showInlineLoader);
    };

    return (
        <div>
            <Navigation />
            <div className="container mt-4" style={{ maxWidth: '900px' }}>
                <div className="text-center mb-4">
                    <h1 className="hero-title" style={{ fontSize: 'clamp(1.75rem, 5vw, 3rem)', marginBottom: '1rem' }}>
                        Loader Component Demo
                    </h1>
                    <p className="hero-subtitle" style={{ fontSize: 'clamp(1rem, 3vw, 1.2rem)' }}>
                        Test different loader variations
                    </p>
                </div>

                {/* Demo 1: Global Fullscreen Loader */}
                <div className="card mb-4">
                    <h3 style={{ marginBottom: '1rem' }}>1. Global Fullscreen Loader</h3>
                    <p style={{ marginBottom: '1rem', color: '#666' }}>
                        Uses the global LoadingContext to show a fullscreen overlay loader.
                        Perfect for API calls, form submissions, and app-wide operations.
                    </p>
                    <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
                        <button
                            className="btn btn-primary"
                            onClick={simulateAsyncOperation}
                        >
                            Trigger 3s Operation
                        </button>
                        <button
                            className="btn btn-secondary"
                            onClick={simulateWithCustomText}
                        >
                            Custom Text (2.5s)
                        </button>
                    </div>
                    <div style={{
                        marginTop: '1rem',
                        padding: '1rem',
                        background: 'rgba(255, 107, 53, 0.05)',
                        borderRadius: '8px',
                        fontSize: '0.9rem',
                        fontFamily: 'monospace'
                    }}>
                        <strong>Code:</strong><br />
                        const &#123; showLoading, hideLoading &#125; = useLoading();<br />
                        showLoading('Custom message...');<br />
                        {/* ... async work ... */}<br />
                        hideLoading();
                    </div>
                </div>

                {/* Demo 2: Inline Loader */}
                <div className="card mb-4">
                    <h3 style={{ marginBottom: '1rem' }}>2. Inline Loader</h3>
                    <p style={{ marginBottom: '1rem', color: '#666' }}>
                        Shows loader within a component section, not fullscreen.
                        Great for partial page loading or specific sections.
                    </p>
                    <button
                        className="btn btn-outline"
                        onClick={toggleInlineLoader}
                    >
                        {showInlineLoader ? 'Hide' : 'Show'} Inline Loader
                    </button>

                    <div style={{
                        marginTop: '1.5rem',
                        padding: '2rem',
                        background: '#f5f5f5',
                        borderRadius: '12px',
                        minHeight: '150px',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center'
                    }}>
                        {showInlineLoader ? (
                            <Loader text="Loading section data..." />
                        ) : (
                            <div style={{ textAlign: 'center', color: '#999' }}>
                                Click the button above to show the loader here
                            </div>
                        )}
                    </div>

                    <div style={{
                        marginTop: '1rem',
                        padding: '1rem',
                        background: 'rgba(255, 107, 53, 0.05)',
                        borderRadius: '8px',
                        fontSize: '0.9rem',
                        fontFamily: 'monospace'
                    }}>
                        <strong>Code:</strong><br />
                        &#123;loading ? (<br />
                        &nbsp;&nbsp;&lt;Loader text="Loading..." /&gt;<br />
                        ) : (<br />
                        &nbsp;&nbsp;&lt;div&gt;Your content&lt;/div&gt;<br />
                        )&#125;
                    </div>
                </div>

                {/* Demo 3: Loader with Different Texts */}
                <div className="card mb-4">
                    <h3 style={{ marginBottom: '1rem' }}>3. Loader Text Variations</h3>
                    <p style={{ marginBottom: '1rem', color: '#666' }}>
                        The loader supports custom text for different contexts.
                    </p>

                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem' }}>
                        <div style={{ padding: '1.5rem', background: '#f5f5f5', borderRadius: '8px', textAlign: 'center' }}>
                            <Loader text="Loading..." show={true} />
                        </div>
                        <div style={{ padding: '1.5rem', background: '#f5f5f5', borderRadius: '8px', textAlign: 'center' }}>
                            <Loader text="Fetching data..." show={true} />
                        </div>
                        <div style={{ padding: '1.5rem', background: '#f5f5f5', borderRadius: '8px', textAlign: 'center' }}>
                            <Loader text="Please wait..." show={true} />
                        </div>
                    </div>
                </div>

                {/* Demo 4: Loader Without Text */}
                <div className="card mb-4">
                    <h3 style={{ marginBottom: '1rem' }}>4. Loader Without Text</h3>
                    <p style={{ marginBottom: '1rem', color: '#666' }}>
                        Sometimes you don't need text, just the animation.
                    </p>

                    <div style={{ padding: '2rem', background: '#f5f5f5', borderRadius: '8px', textAlign: 'center' }}>
                        <Loader show={true} />
                    </div>

                    <div style={{
                        marginTop: '1rem',
                        padding: '1rem',
                        background: 'rgba(255, 107, 53, 0.05)',
                        borderRadius: '8px',
                        fontSize: '0.9rem',
                        fontFamily: 'monospace'
                    }}>
                        <strong>Code:</strong><br />
                        &lt;Loader /&gt;
                    </div>
                </div>

                {/* Animation Details */}
                <div className="card" style={{ background: 'linear-gradient(135deg, rgba(255, 107, 53, 0.05) 0%, rgba(255, 215, 0, 0.05) 100%)' }}>
                    <h3 style={{ marginBottom: '1rem' }}>✨ Animation Details</h3>
                    <div style={{ lineHeight: '1.8', color: '#5d3a1a' }}>
                        <p><strong>Style:</strong> Load #9 - Bouncing Bubbles</p>
                        <p><strong>Duration:</strong> 2 seconds per rotation</p>
                        <p><strong>Colors:</strong></p>
                        <ul style={{ marginLeft: '1.5rem' }}>
                            <li>Bubble 1: Orange gradient (#ff6b35 → #d84315)</li>
                            <li>Bubble 2: Gold gradient (#ffd700 → #ff8c00)</li>
                        </ul>
                        <p><strong>Effects:</strong></p>
                        <ul style={{ marginLeft: '1.5rem' }}>
                            <li>360° rotation animation</li>
                            <li>Scale bounce (0 → 1 → 0)</li>
                            <li>Smooth easing curves</li>
                            <li>Box shadows for depth</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default LoaderDemo;
