import React, { createContext, useState, useEffect, useRef, useContext } from 'react';

const AudioContext = createContext();

export const useAudio = () => {
    const context = useContext(AudioContext);
    if (!context) {
        throw new Error('useAudio must be used within an AudioProvider');
    }
    return context;
};

export const AudioProvider = ({ children }) => {
    const [currentTrack, setCurrentTrack] = useState(null);
    const [isPlaying, setIsPlaying] = useState(false);
    const [progress, setProgress] = useState(0);
    const [duration, setDuration] = useState(0);
    const [volume, setVolume] = useState(() => {
        const savedVolume = localStorage.getItem('sv_audio_volume');
        return savedVolume ? parseFloat(savedVolume) : 0.8;
    });
    const [isMuted, setIsMuted] = useState(false);
    const [isLoading, setIsLoading] = useState(false);

    const audioRef = useRef(new Audio());

    useEffect(() => {
        const audio = audioRef.current;

        const updateProgress = () => {
            if (audio.duration) {
                setProgress((audio.currentTime / audio.duration) * 100);
            }
        };

        const onLoadedMetadata = () => {
            setDuration(audio.duration);
        };

        const onEnded = () => {
            setIsPlaying(false);
            setProgress(0);
        };

        const onWaiting = () => setIsLoading(true);
        const onPlaying = () => setIsLoading(false);
        const onError = (e) => {
            console.error('Audio playback error:', e);
            setIsLoading(false);
            setIsPlaying(false);
        };

        audio.addEventListener('timeupdate', updateProgress);
        audio.addEventListener('loadedmetadata', onLoadedMetadata);
        audio.addEventListener('ended', onEnded);
        audio.addEventListener('waiting', onWaiting);
        audio.addEventListener('playing', onPlaying);
        audio.addEventListener('error', onError);

        return () => {
            audio.removeEventListener('timeupdate', updateProgress);
            audio.removeEventListener('loadedmetadata', onLoadedMetadata);
            audio.removeEventListener('ended', onEnded);
            audio.removeEventListener('waiting', onWaiting);
            audio.removeEventListener('playing', onPlaying);
            audio.removeEventListener('error', onError);
        };
    }, []);

    useEffect(() => {
        audioRef.current.volume = isMuted ? 0 : volume;
        localStorage.setItem('sv_audio_volume', volume.toString());
    }, [volume, isMuted]);

    const play = (track) => {
        if (!track || !track.audio_url) return;

        if (currentTrack?.id === track.id) {
            if (!isPlaying) {
                audioRef.current.play().catch(console.error);
                setIsPlaying(true);
            }
            return;
        }

        setCurrentTrack(track);
        audioRef.current.src = track.audio_url;
        audioRef.current.load();
        audioRef.current.play()
            .then(() => setIsPlaying(true))
            .catch(err => {
                console.error('Playback failed:', err);
                setIsPlaying(false);
            });
    };

    const pause = () => {
        audioRef.current.pause();
        setIsPlaying(false);
    };

    const toggle = () => {
        if (isPlaying) {
            pause();
        } else if (currentTrack) {
            audioRef.current.play().catch(console.error);
            setIsPlaying(true);
        }
    };

    const seek = (percentage) => {
        if (audioRef.current.duration) {
            const newTime = (percentage / 100) * audioRef.current.duration;
            audioRef.current.currentTime = newTime;
            setProgress(percentage);
        }
    };

    const value = {
        currentTrack,
        isPlaying,
        progress,
        duration,
        volume,
        setVolume,
        isMuted,
        setIsMuted,
        isLoading,
        play,
        pause,
        toggle,
        seek
    };

    return (
        <AudioContext.Provider value={value}>
            {children}
        </AudioContext.Provider>
    );
};
