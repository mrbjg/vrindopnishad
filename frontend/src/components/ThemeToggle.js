import React from 'react';
import { useTheme } from '../contexts/ThemeContext';
import { Moon, Sun, Monitor } from 'lucide-react';

const ThemeToggle = ({ className = '', showLabel = false }) => {
    const { theme, isDark, setTheme, toggleTheme } = useTheme();

    // Simple toggle button (just switches between light/dark)
    if (!showLabel) {
        return (
            <button
                onClick={toggleTheme}
                className={`p-2.5 rounded-xl transition-all duration-300 hover:scale-105 active:scale-95
          ${isDark
                        ? 'bg-amber-500/20 text-amber-400 hover:bg-amber-500/30'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                    } ${className}`}
                aria-label={`Switch to ${isDark ? 'light' : 'dark'} mode`}
            >
                {isDark ? <Sun size={20} /> : <Moon size={20} />}
            </button>
        );
    }

    // Full theme selector with system option
    return (
        <div className={`flex items-center gap-1 p-1 rounded-xl bg-muted ${className}`}>
            <ThemeButton
                active={theme === 'light'}
                onClick={() => setTheme('light')}
                icon={<Sun size={16} />}
                label="Light"
            />
            <ThemeButton
                active={theme === 'dark'}
                onClick={() => setTheme('dark')}
                icon={<Moon size={16} />}
                label="Dark"
            />
            <ThemeButton
                active={theme === 'system'}
                onClick={() => setTheme('system')}
                icon={<Monitor size={16} />}
                label="System"
            />
        </div>
    );
};

const ThemeButton = ({ active, onClick, icon, label }) => (
    <button
        onClick={onClick}
        className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-all duration-200
      ${active
                ? 'bg-background text-foreground shadow-sm'
                : 'text-muted-foreground hover:text-foreground'
            }`}
    >
        {icon}
        <span className="hidden sm:inline">{label}</span>
    </button>
);

export default ThemeToggle;
