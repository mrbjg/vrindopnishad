import React, { useState, useEffect } from 'react';
import { Clock, Edit2 } from 'lucide-react';

const BrajCalendar = ({ isHi, calendarData, onSaveCalendar }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [form, setForm] = useState({ ...calendarData });

  
  useEffect(() => {
    setForm({ ...calendarData });
  }, [calendarData]);

  const handleSave = () => {
    onSaveCalendar(form);
    setIsEditing(false);
  };

  const handleCancel = () => {
    setForm({ ...calendarData });
    setIsEditing(false);
  };

  return (
    <div className="glass-card p-5 rounded-3xl border border-primary/10 flex flex-col justify-between h-full select-none text-left">
      <div>
        <div className="flex items-center justify-between mb-4 pb-2 border-b border-white/5">
          <div className="flex items-center gap-2">
            <Clock size={16} className="text-primary" />
            <span className="text-[10px] uppercase tracking-[0.2em] text-white/60 font-bold">
              {isHi ? "ब्रज पंचांग" : "Braj Calendar"}
            </span>
          </div>
          {!isEditing && (
            <button
              onClick={() => setIsEditing(true)}
              className="text-zinc-600 hover:text-white transition-colors"
              title="Edit Calendar"
            >
              <Edit2 size={12} />
            </button>
          )}
        </div>

        {isEditing ? (
          <div className="space-y-2.5 my-2">
            <div>
              <span className="text-[8px] uppercase tracking-wider text-white/40 block mb-0.5">Tithi (EN / HI)</span>
              <div className="grid grid-cols-2 gap-1">
                <input
                  type="text"
                  className="bg-white/5 border border-white/10 rounded px-2 py-0.5 text-xs text-white focus:outline-none focus:border-primary/50 font-light"
                  value={form.tithiEn}
                  onChange={e => setForm(prev => ({ ...prev, tithiEn: e.target.value }))}
                  placeholder="Tithi EN"
                />
                <input
                  type="text"
                  className="bg-white/5 border border-white/10 rounded px-2 py-0.5 text-xs text-white focus:outline-none focus:border-primary/50 font-light"
                  value={form.tithiHi}
                  onChange={e => setForm(prev => ({ ...prev, tithiHi: e.target.value }))}
                  placeholder="तिथि हिन्दी"
                />
              </div>
            </div>
            <div>
              <span className="text-[8px] uppercase tracking-wider text-white/40 block mb-0.5">Season (EN / HI)</span>
              <div className="grid grid-cols-2 gap-1">
                <input
                  type="text"
                  className="bg-white/5 border border-white/10 rounded px-2 py-0.5 text-xs text-white focus:outline-none focus:border-primary/50 font-light"
                  value={form.seasonEn}
                  onChange={e => setForm(prev => ({ ...prev, seasonEn: e.target.value }))}
                  placeholder="Season EN"
                />
                <input
                  type="text"
                  className="bg-white/5 border border-white/10 rounded px-2 py-0.5 text-xs text-white focus:outline-none focus:border-primary/50 font-light"
                  value={form.seasonHi}
                  onChange={e => setForm(prev => ({ ...prev, seasonHi: e.target.value }))}
                  placeholder="ऋतु हिन्दी"
                />
              </div>
            </div>
            <div>
              <span className="text-[8px] uppercase tracking-wider text-white/40 block mb-0.5">Astayama Lila (EN / HI)</span>
              <div className="grid grid-cols-2 gap-1">
                <input
                  type="text"
                  className="bg-white/5 border border-white/10 rounded px-2 py-0.5 text-xs text-white focus:outline-none focus:border-primary/50 font-light"
                  value={form.lilaEn}
                  onChange={e => setForm(prev => ({ ...prev, lilaEn: e.target.value }))}
                  placeholder="Lila EN"
                />
                <input
                  type="text"
                  className="bg-white/5 border border-white/10 rounded px-2 py-0.5 text-xs text-white focus:outline-none focus:border-primary/50 font-light"
                  value={form.lilaHi}
                  onChange={e => setForm(prev => ({ ...prev, lilaHi: e.target.value }))}
                  placeholder="लीला हिन्दी"
                />
              </div>
            </div>
            <div>
              <span className="text-[8px] uppercase tracking-wider text-white/40 block mb-0.5">Next Festival (EN / HI)</span>
              <div className="grid grid-cols-2 gap-1">
                <input
                  type="text"
                  className="bg-white/5 border border-white/10 rounded px-2 py-0.5 text-xs text-white focus:outline-none focus:border-primary/50 font-light"
                  value={form.festivalEn}
                  onChange={e => setForm(prev => ({ ...prev, festivalEn: e.target.value }))}
                  placeholder="Festival EN"
                />
                <input
                  type="text"
                  className="bg-white/5 border border-white/10 rounded px-2 py-0.5 text-xs text-white focus:outline-none focus:border-primary/50 font-light"
                  value={form.festivalHi}
                  onChange={e => setForm(prev => ({ ...prev, festivalHi: e.target.value }))}
                  placeholder="उत्सव हिन्दी"
                />
              </div>
            </div>
            <div className="flex gap-2 justify-end pt-1">
              <button
                onClick={handleCancel}
                className="px-2 py-0.5 text-[9px] rounded border border-white/10 hover:bg-white/5 text-zinc-400 hover:text-white transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleSave}
                className="px-2 py-0.5 text-[9px] rounded bg-white text-zinc-950 hover:bg-zinc-200 font-semibold transition-colors"
              >
                Save
              </button>
            </div>
          </div>
        ) : (
          <>
            <div className="space-y-4">
              <div>
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">
                  {isHi ? "तिथि / Lunar Day" : "Lunar Tithi"}
                </span>
                <span className="text-xs font-bold text-white/80 block mt-0.5">
                  {isHi ? calendarData.tithiHi : calendarData.tithiEn}
                </span>
              </div>
              <div>
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">
                  {isHi ? "ऋतु / Season" : "Current Season"}
                </span>
                <span className="text-xs font-bold text-white/80 block mt-0.5">
                  {isHi ? calendarData.seasonHi : calendarData.seasonEn}
                </span>
              </div>
              <div>
                <span className="text-[9px] uppercase tracking-wider text-white/35 block">
                  {isHi ? "अष्टयाम लीला / Pastime" : "Aṣṭayāma Līlā"}
                </span>
                <span className="text-xs font-bold text-white/80 block mt-0.5 truncate">
                  {isHi ? calendarData.lilaHi : calendarData.lilaEn}
                </span>
              </div>
            </div>

            <div className="mt-4 pt-3 border-t border-white/5">
              <span className="text-[9px] uppercase tracking-wider text-primary font-bold block mb-1">
                🎉 {isHi ? "आगामी उत्सव" : "Next Festival"}
              </span>
              <span className="text-[11px] font-semibold text-minimal-gold block">
                {isHi ? calendarData.festivalHi : calendarData.festivalEn}
              </span>
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default React.memo(BrajCalendar);
