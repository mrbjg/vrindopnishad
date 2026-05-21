import React from 'react';
import { 
  Moon, 
  Sun, 
  Sparkles, 
  Orbit, 
  Compass, 
  Snowflake, 
  CloudSnow, 
  CloudRain, 
  Mountain, 
  Sunset, 
  Leaf, 
  Waves,
  HelpCircle
} from 'lucide-react';

const iconMap = {
  Moon,
  Sun,
  Sparkles,
  Orbit,
  Compass,
  Snowflake,
  CloudSnow,
  CloudRain,
  Mountain,
  Sunset,
  Leaf,
  Waves
};

const ThemeIcon = ({ name, size = 16, className = "" }) => {
  const IconComponent = iconMap[name] || HelpCircle;
  return <IconComponent size={size} className={className} />;
};

export default ThemeIcon;
