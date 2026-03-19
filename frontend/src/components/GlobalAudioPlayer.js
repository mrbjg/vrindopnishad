import React, { useState, useEffect } from 'react';
import { useAudio } from '../contexts/AudioContext';
import { Play, Pause, SkipForward, SkipBack, Volume2, VolumeX, Maximize2, Minimize2, X, Music } from 'lucide-react';

const GlobalAudioPlayer = () => {
    const { 
        currentTrack, 
        isPlaying, 
        progress, 
        duration, 
        volume, 
        setVolume, 
        isMuted, 
        setIsMuted, 
        toggle, 
        seek,
        pause
    } = useAudio();

    const [isExpanded, setIsExpanded] = useState(false);
    const [isVisible, setIsVisible] = useState(false);

    useEffect(() => {
        if (currentTrack) {
            setIsVisible(true);
        }
    }, [currentTrack]);

    if (!isVisible || !currentTrack) return null;

    const formatTime = (time) => {
        if (!time) return '0:00';
        const minutes = Math.floor(time / 60);
        const seconds = Math.floor(time % 60);
        return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    };

    return (
        <div className={`fixed bottom-24 md:bottom-8 left-6 right-6 z-[1100] transition-all duration-500 transform ${isVisible ? 'translate-y-0 opacity-100' : 'translate-y-20 opacity-0'}`}>
            <div className={`glass-card overflow-hidden border border-white/10 shadow-2xl transition-all duration-500 ${isExpanded ? 'h-auto p-8' : 'h-20 p-4'}`}>
                
                {/* Progress Bar (Always on top of the card) */}
                <div 
                    className="absolute top-0 left-0 h-1 bg-primary/30 w-full cursor-pointer group"
                    onClick={(e) => {
                        const rect = e.currentTarget.getBoundingClientRect();
                        const x = e.clientX - rect.left;
                        const percentage = (x / rect.width) * 100;
                        seek(percentage);
                    }}
                >
                    <div 
                        className="h-full bg-primary relative transition-all duration-100"
                        style={{ width: `${progress}%` }}
                    >
                        <div className="absolute right-0 top-1/2 -translate-y-1/2 w-3 h-3 bg-white rounded-full shadow-lg opacity-0 group-hover:opacity-100 transition-opacity"></div>
                    </div>
                </div>

                {/* Mini Player View */}
                {!isExpanded && (
                    <div className="flex items-center justify-between h-full gap-4">
                        <div className="flex items-center gap-4 flex-1 min-w-0">
                            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-purple-600 flex items-center justify-center shadow-lg flex-shrink-0 animate-pulse-slow">
                                <Music size={24} className="text-white" />
                            </div>
                            <div className="min-w-0">
                                <h4 className="font-bold text-sm truncate">{currentTrack.title}</h4>
                                <p className="text-white/40 text-xs truncate">{currentTrack.author || 'VrindaVaani'}</p>
                            </div>
                        </div>

                        <div className="flex items-center gap-3">
                            <button 
                                onClick={toggle}
                                className="w-10 h-10 rounded-full bg-white text-black flex items-center justify-center hover:scale-110 active:scale-95 transition-all"
                            >
                                {isPlaying ? <Pause size={20} fill="black" /> : <Play size={20} fill="black" className="ml-0.5" />}
                            </button>
                            
                            <button 
                                onClick={() => setIsExpanded(true)}
                                className="p-2 text-white/40 hover:text-white transition-colors"
                            >
                                <Maximize2 size={18} />
                            </button>
                            
                            <button 
                                onClick={() => {
                                    pause();
                                    setIsVisible(false);
                                }}
                                className="p-2 text-white/40 hover:text-red-400 transition-colors"
                            >
                                <X size={18} />
                            </button>
                        </div>
                    </div>
                )}

                {/* Expanded View */}
                {isExpanded && (
                    <div className="animate-fade-in">
                        <div className="flex justify-between items-start mb-8">
                            <button 
                                onClick={() => setIsExpanded(false)}
                                className="p-2 bg-white/5 rounded-full text-white/40 hover:text-white transition-colors"
                            >
                                <Minimize2 size={24} />
                            </button>
                            <div className="text-center">
                                <span className="text-[10px] uppercase tracking-[0.3em] text-primary/60 font-bold mb-1 block">Playing Now</span>
                                <div className="h-1 w-8 bg-primary/20 mx-auto rounded-full"></div>
                            </div>
                            <button 
                                onClick={() => {
                                    pause();
                                    setIsVisible(false);
                                    setIsExpanded(false);
                                }}
                                className="p-2 bg-white/5 rounded-full text-white/40 hover:text-red-400 transition-colors"
                            >
                                <X size={24} />
                            </button>
                        </div>

                        <div className="flex flex-col md:flex-row gap-12 items-center">
                            <div className="w-full md:w-64 aspect-square rounded-3xl bg-gradient-to-br from-primary/30 to-purple-600/30 border border-white/10 flex items-center justify-center relative group overflow-hidden shadow-2xl">
                                <div className="absolute inset-0 bg-primary/10 animate-pulse"></div>
                                <Music size={80} className="text-white relative z-10 drop-shadow-2xl" />
                                {isPlaying && (
                                    <div className="absolute bottom-4 left-0 right-0 flex justify-center gap-1 h-8 items-end">
                                        {[1,2,3,4,5].map(i => (
                                            <div key={i} className="w-1 bg-primary/60 animate-audio-bar" style={{ animationDelay: `${i * 0.1}s` }}></div>
                                        ))}
                                    </div>
                                )}
                            </div>

                            <div className="flex-1 w-full text-center md:text-left">
                                <h3 className="text-3xl md:text-5xl font-bold mb-4 tracking-tight">{currentTrack.title}</h3>
                                <p className="text-xl text-primary/80 mb-8 font-medium">{currentTrack.author || 'Sant Vaani'}</p>
                                
                                <div className="space-y-6">
                                    <div className="flex justify-between text-xs font-medium text-white/40 uppercase tracking-widest">
                                        <span>{formatTime((progress / 100) * duration)}</span>
                                        <span>{formatTime(duration)}</span>
                                    </div>
                                    
                                    <div className="group relative pt-4 pb-2">
                                        <input 
                                            type="range" 
                                            min="0" 
                                            max="100" 
                                            value={progress} 
                                            onChange={(e) => seek(parseFloat(e.target.value))}
                                            className="w-full accent-primary h-1.5 rounded-full bg-white/10 cursor-pointer appearance-none outline-none"
                                        />
                                    </div>

                                    <div className="flex items-center justify-center md:justify-start gap-10 pt-4">
                                        <button className="text-white/30 hover:text-white transition-colors"><SkipBack size={32} /></button>
                                        <button 
                                            onClick={toggle}
                                            className="w-20 h-20 rounded-full bg-primary text-white flex items-center justify-center hover:scale-110 active:scale-95 transition-all shadow-xl shadow-primary/40"
                                        >
                                            {isPlaying ? <Pause size={36} fill="white" /> : <Play size={36} fill="white" className="ml-1" />}
                                        </button>
                                        <button className="text-white/30 hover:text-white transition-colors"><SkipForward size={32} /></button>
                                    </div>

                                    <div className="flex items-center gap-4 pt-8 md:pt-4 max-w-xs mx-auto md:mx-0">
                                        <button onClick={() => setIsMuted(!isMuted)} className="text-white/40 hover:text-white">
                                            {isMuted ? <VolumeX size={20} /> : <Volume2 size={20} />}
                                        </button>
                                        <input 
                                            type="range" 
                                            min="0" 
                                            max="1" 
                                            step="0.01" 
                                            value={isMuted ? 0 : volume} 
                                            onChange={(e) => {
                                                setVolume(parseFloat(e.target.value));
                                                if (isMuted) setIsMuted(false);
                                            }}
                                            className="flex-1 h-1 accent-primary rounded-full bg-white/10 cursor-pointer"
                                        />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
};

export default GlobalAudioPlayer;
