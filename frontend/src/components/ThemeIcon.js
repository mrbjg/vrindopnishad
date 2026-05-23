import React from 'react';
import { 
  Moon, 
  Sun, 
  Sparkle,
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
  HelpCircle,
  Flower2
} from 'lucide-react';

const iconMap = {
  Moon,
  Sun,
  Sparkle,
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
  Flower2
};

const ThemeIcon = ({ name, size = 16, className = "" }) => {
  const IconComponent = iconMap[name] || HelpCircle;
  return <IconComponent size={size} className={className} />;
};

export default ThemeIcon;
