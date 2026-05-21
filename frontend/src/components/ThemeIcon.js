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
  Sunrise,
  Sunset, 
  Leaf, 
  Waves,
  Droplets,
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
  Sunrise,
  Sunset,
  Leaf,
  Waves,
  Droplets
};

const ThemeIcon = ({ name, size = 16, className = "" }) => {
  const IconComponent = iconMap[name] || HelpCircle;
  return <IconComponent size={size} className={className} />;
};

export default ThemeIcon;
