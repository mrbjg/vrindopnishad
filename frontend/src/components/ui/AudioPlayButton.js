import React from 'react';
import { Play, Pause, Loader2 } from 'lucide-react';
import { useAudio } from '../../contexts/AudioContext';

const AudioPlayButton = ({ track, className = "", size = 20 }) => {
    const { currentTrack, isPlaying, play, pause, isLoading } = useAudio();
    
    const isThisTrack = currentTrack?.id === track.id;
    const isThisTrackPlaying = isThisTrack && isPlaying;
    const isThisTrackLoading = isThisTrack && isLoading;

    const handleToggle = (e) => {
        e.preventDefault();
        e.stopPropagation();
        
        if (isThisTrackPlaying) {
            pause();
        } else {
            play(track);
        }
    };

    if (!track.audio_url) return null;

    return (
        <button
            onClick={handleToggle}
            className={`flex items-center justify-center rounded-full transition-all duration-300 hover:scale-110 active:scale-95 ${className}`}
            disabled={isThisTrackLoading}
        >
            {isThisTrackLoading ? (
                <Loader2 size={size} className="animate-spin" />
            ) : isThisTrackPlaying ? (
                <Pause size={size} fill="currentColor" />
            ) : (
                <Play size={size} fill="currentColor" />
            )}
        </button>
    );
};

export default AudioPlayButton;
