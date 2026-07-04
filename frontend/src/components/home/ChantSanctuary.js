import React, { useState, useEffect } from 'react';
import { Volume2, VolumeX } from 'lucide-react';

const ChantSanctuary = ({
  isHi,
  japaCount,
  handleUpdateJapaCount,
  dailyGoal,
  percentComplete,
  rounds,
}) => {

  const [isTanpuraPlaying, setIsTanpuraPlaying] = useState(false);
  const [audioCtx, setAudioCtx] = useState(null);
  const [tanpuraTimer, setTanpuraTimer] = useState(null);

  const pluckString = (ctx, frequency, pluckTime) => {
    const fundamental = frequency;
    const harmonics = [1, 2, 3, 4, 5, 6, 7];
    const amplitudes = [1.0, 0.5, 0.35, 0.25, 0.15, 0.1, 0.05];

    const masterGain = ctx.createGain();
    masterGain.gain.setValueAtTime(0, pluckTime);
    masterGain.gain.linearRampToValueAtTime(0.18, pluckTime + 0.03);
    masterGain.gain.exponentialRampToValueAtTime(0.001, pluckTime + 4.2);
    masterGain.connect(ctx.destination);

    harmonics.forEach((h, idx) => {
      const osc = ctx.createOscillator();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(fundamental * h, pluckTime);

      const filter = ctx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(fundamental * h * 1.5, pluckTime);
      filter.frequency.exponentialRampToValueAtTime(fundamental * h * 0.5 + 80, pluckTime + 2.8);

      const gain = ctx.createGain();
      gain.gain.setValueAtTime(amplitudes[idx] * 0.1, pluckTime);

      osc.connect(filter);
      filter.connect(gain);
      gain.connect(masterGain);

      osc.start(pluckTime);
      osc.stop(pluckTime + 4.5);
    });
  };

  const toggleTanpura = () => {
    if (isTanpuraPlaying) {
      if (tanpuraTimer) clearInterval(tanpuraTimer);
      if (audioCtx) {
        try {
          audioCtx.close();
        } catch (e) {
          console.warn(e);
        }
      }
      setIsTanpuraPlaying(false);
      setAudioCtx(null);
      setTanpuraTimer(null);
    } else {
      const AudioCtxClass = window.AudioContext || window.webkitAudioContext;
      const ctx = new AudioCtxClass();
      setAudioCtx(ctx);
      setIsTanpuraPlaying(true);

      const baseFreq = 130.81;
      const freqs = [
        baseFreq * 1.5,
        baseFreq * 2.0,
        baseFreq * 2.0,
        baseFreq
      ];

      let pluckIdx = 0;
      pluckString(ctx, freqs[pluckIdx], ctx.currentTime);
      pluckIdx = (pluckIdx + 1) % 4;

      const timer = setInterval(() => {
        pluckString(ctx, freqs[pluckIdx], ctx.currentTime + 0.05);
        pluckIdx = (pluckIdx + 1) % 4;
      }, 1200);

      setTanpuraTimer(timer);
    }
  };


  useEffect(() => {
    return () => {
      if (tanpuraTimer) clearInterval(tanpuraTimer);
      if (audioCtx) {
        try {
          audioCtx.close();
        } catch (e) {
          console.warn(e);
        }
      }
    };
  }, [tanpuraTimer, audioCtx]);

  return (
    <div className="glass-card p-5 rounded-3xl border border-primary/10 flex flex-col justify-between h-full select-none text-left">
      <div>
        <div className="flex items-center justify-between mb-4 pb-2 border-b border-white/5">
          <div className="flex items-center gap-2">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
            </span>
            <span className="text-[10px] uppercase tracking-[0.2em] text-white/60 font-bold">
              {isHi ? "जाप साधना" : "Chant Sanctuary"}
            </span>
          </div>
          <span className="text-[9px] font-bold text-white/40 uppercase">
            Goal: {dailyGoal / 108} {dailyGoal === 108 ? 'Mala' : 'Malas'}
          </span>
        </div>

        <div className="space-y-4">
          <div>
            <span className="text-[9px] uppercase tracking-wider text-white/35 block">
              {isHi ? "कुल जाप / Total Chants" : "Total Chants"}
            </span>
            <div className="flex items-baseline justify-between">
              <span className="text-xl font-extrabold text-minimal-gold block mt-0.5 font-mono">{japaCount}</span>
              <button
                onClick={toggleTanpura}
                className={`p-1.5 rounded-full border transition-all touch-manipulation min-w-[28px] min-h-[28px] flex items-center justify-center relative group ${isTanpuraPlaying
                    ? 'bg-sky-500/10 border-sky-500/40 text-sky-400 animate-pulse'
                    : 'bg-white/5 border-white/10 text-white/40 hover:text-white'
                  }`}
                title={isTanpuraPlaying ? (isHi ? "तंबूरा बंद करें" : "Stop Tanpura Drone") : (isHi ? "तंबूरा शुरू करें" : "Start Tanpura Drone")}
                aria-label={isTanpuraPlaying ? "Stop Tanpura Drone" : "Start Tanpura Drone"}
              >
                {isTanpuraPlaying ? <Volume2 size={12} aria-hidden="true" /> : <VolumeX size={12} aria-hidden="true" />}
                <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
                  {isTanpuraPlaying ? (isHi ? "तंबूरा बंद" : "Stop Tanpura") : (isHi ? "तंबूरा चालू" : "Start Tanpura")}
                </span>
              </button>
            </div>
          </div>
          <div>
            <span className="text-[9px] uppercase tracking-wider text-white/35 block">
              {isHi ? "माला पूर्ण / Completed Mala" : "Completed Mala"}
            </span>
            <span className="text-xs font-bold text-white/80 block mt-0.5">
              {rounds} {isHi ? "माला" : "Rounds"}{' '}
              <span className="text-white/40 font-normal font-mono">({japaCount % 108}/108)</span>
            </span>
          </div>
        </div>


        <div className="grid grid-cols-3 gap-2 mt-4 pt-3 border-t border-white/5">
          <button
            onClick={() => handleUpdateJapaCount(japaCount + 1)}
            className="bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl py-2.5 text-center text-xs font-bold text-white/80 transition-colors touch-manipulation min-h-[38px] relative group"
            title={isHi ? "१ जाप जोड़ें" : "Add 1 Chant"}
            aria-label={isHi ? "१ जाप जोड़ें" : "Add 1 Chant"}
          >
            +1
            <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
              {isHi ? "१ जाप जोड़ें" : "Add 1 Chant"}
            </span>
          </button>
          <button
            onClick={() => handleUpdateJapaCount(japaCount + 108)}
            className="bg-primary/10 hover:bg-primary/20 border border-primary/25 rounded-xl py-2.5 text-center text-xs font-bold text-primary transition-colors touch-manipulation min-h-[38px] relative group"
            title={isHi ? "१ माला जोड़ें" : "Add 1 Mala (108)"}
            aria-label={isHi ? "१ माला जोड़ें" : "Add 1 Mala (108)"}
          >
            +108
            <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
              {isHi ? "१ माला (१०८)" : "Add 1 Mala (+108)"}
            </span>
          </button>
          <button
            onClick={() => {
              if (window.confirm(isHi ? "क्या आप जाप संख्या रीसेट करना चाहते हैं?" : "Reset chant count?")) {
                handleUpdateJapaCount(0);
              }
            }}
            className="bg-red-500/5 hover:bg-red-500/10 border border-red-500/10 hover:border-red-500/20 rounded-xl py-2.5 text-center text-xs font-bold text-red-400 transition-colors touch-manipulation min-h-[38px] relative group"
            title={isHi ? "जाप संख्या रीसेट करें" : "Reset Chant Count"}
            aria-label={isHi ? "जाप संख्या रीसेट करें" : "Reset Chant Count"}
          >
            Reset
            <span className="absolute -top-8 left-1/2 -translate-x-1/2 scale-0 group-hover:scale-100 bg-black text-[10px] text-white/90 px-2 py-1 rounded border border-white/10 transition-all duration-200 pointer-events-none whitespace-nowrap z-50">
              {isHi ? "जाप रीसेट" : "Reset Count"}
            </span>
          </button>
        </div>
      </div>

      <div className="space-y-2 mt-4 pt-3 border-t border-white/5">
        <div className="flex justify-between items-center text-[9px] font-bold uppercase tracking-wider">
          <span className="text-white/50">{isHi ? "दैनिक लक्ष्य" : "Daily Goal"}</span>
          <span className="text-primary">{percentComplete}%</span>
        </div>
        <div className="h-1.5 w-full bg-white/5 rounded-full overflow-hidden border border-white/5">
          <div
            className="h-full bg-primary rounded-full transition-all duration-500 ease-out"
            style={{ width: `${percentComplete}%` }}
          />
        </div>
      </div>
    </div>
  );
};

export default React.memo(ChantSanctuary);
