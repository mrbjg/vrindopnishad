/**
 * Dynamic share card generator for Vrindopnishad Paath
 * Uses native HTML5 Canvas to render a high-quality 1080x1080 spiritual card.
 */
export const shareVerseCard = async (content, isHindiRoute = false) => {
  const canvas = document.createElement('canvas');
  canvas.width = 1080;
  canvas.height = 1080;
  const ctx = canvas.getContext('2d');
  
  if (!ctx) return;

  // 1. Draw elegant spiritual background gradient
  const gradient = ctx.createLinearGradient(0, 0, 1080, 1080);
  gradient.addColorStop(0, '#100b08'); // Deep soot saffron
  gradient.addColorStop(0.3, '#2a160c'); // Saffron amber shadow
  gradient.addColorStop(0.7, '#1b0a15'); // Deep magenta plum
  gradient.addColorStop(1, '#08080c'); // Cosmic night void
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, 1080, 1080);

  // 2. Draw gold borders & corner designs
  const goldColor = '#d4af37';
  const creamColor = '#e3ded0';
  
  ctx.strokeStyle = goldColor;
  ctx.lineWidth = 4;
  // Outer frame
  ctx.strokeRect(50, 50, 980, 980);
  
  // Inner thin frame
  ctx.strokeStyle = 'rgba(212, 175, 55, 0.4)';
  ctx.lineWidth = 1.5;
  ctx.strokeRect(62, 62, 956, 956);

  // Corner motifs (Geometric Sacred Art)
  const drawCorner = (x, y, rotation) => {
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(rotation);
    ctx.strokeStyle = goldColor;
    ctx.lineWidth = 3;
    
    // Draw L shape decoration
    ctx.beginPath();
    ctx.moveTo(-20, 0);
    ctx.lineTo(0, 0);
    ctx.lineTo(0, -20);
    ctx.stroke();

    // Draw secondary outer lines
    ctx.beginPath();
    ctx.moveTo(-35, 10);
    ctx.lineTo(10, 10);
    ctx.lineTo(10, -35);
    ctx.stroke();

    // Draw tiny inner diamond
    ctx.fillStyle = goldColor;
    ctx.beginPath();
    ctx.moveTo(0, 5);
    ctx.lineTo(5, 0);
    ctx.lineTo(0, -5);
    ctx.lineTo(-5, 0);
    ctx.closePath();
    ctx.fill();

    ctx.restore();
  };

  drawCorner(75, 75, 0); // Top Left
  drawCorner(1005, 75, Math.PI / 2); // Top Right
  drawCorner(1005, 1005, Math.PI); // Bottom Right
  drawCorner(75, 1005, -Math.PI / 2); // Bottom Left

  // 3. Draw Top Header / Watermark symbol
  ctx.fillStyle = goldColor;
  ctx.font = "italic 32px 'Tiro Devanagari Sanskrit', 'Noto Serif Devanagari', 'Georgia', serif";
  ctx.textAlign = 'center';
  ctx.fillText('ॐ', 540, 130);

  // Draw category tag
  ctx.fillStyle = 'rgba(227, 222, 208, 0.6)';
  ctx.font = "bold tracking-widest 16px 'Inter', 'sans-serif'";
  ctx.fillText((content.category || 'VERSE').toUpperCase(), 540, 175);

  // 4. Wrap and Render the Verse Text
  // Get text lines (either sanskrit text, or fallback to hindi meaning)
  const rawText = content.sanskrit_text || content.hindi_text || content.english_translation || '';
  
  // Format lines
  const rawLines = rawText.split('\n').map(line => line.trim()).filter(Boolean);
  
  // Let's cap the lines to fit perfectly inside the card (max 6 lines)
  const maxLinesToShow = 6;
  const processedLines = rawLines.slice(0, maxLinesToShow);
  
  // Wrap lines helper
  const wrapText = (text, maxWidth) => {
    const words = text.split(' ');
    const lines = [];
    let currentLine = '';

    for (let word of words) {
      const testLine = currentLine ? currentLine + ' ' + word : word;
      const metrics = ctx.measureText(testLine);
      if (metrics.width > maxWidth) {
        lines.push(currentLine);
        currentLine = word;
      } else {
        currentLine = testLine;
      }
    }
    if (currentLine) lines.push(currentLine);
    return lines;
  };

  ctx.fillStyle = creamColor;
  // Use Tiro Devanagari or Noto Serif Devanagari or fallback to Georgia/serif
  ctx.font = "500 38px 'Noto Serif Devanagari', 'Tiro Devanagari Sanskrit', 'Georgia', serif";
  
  const textX = 540;
  let textY = 320;
  const maxWidth = 860;
  const lineHeight = 62;

  // Let's wrap all lines to be safe
  const allWrappedLines = [];
  for (let line of processedLines) {
    const wrapped = wrapText(line, maxWidth);
    allWrappedLines.push(...wrapped);
  }

  // Slice wrapped lines to ensure they fit within card limits (max 8 lines total wrapped)
  const finalLines = allWrappedLines.slice(0, 9);

  // If there are more lines left, add an ellipsis line
  if (allWrappedLines.length > 9) {
    finalLines.push('...');
  }

  // Calculate dynamic start Y to center the block vertically
  const textHeight = finalLines.length * lineHeight;
  textY = 540 - (textHeight / 2) + 20;

  finalLines.forEach(line => {
    ctx.fillText(line, textX, textY);
    textY += lineHeight;
  });

  // 5. Draw Attribution (Author & Source)
  const authorName = content.author || (isHindiRoute ? 'वैष्णव रसिक संत' : 'Vaishnava Rasik Saint');
  const sourceName = content.title || '';
  
  textY += 30; // Spacing after text block
  ctx.fillStyle = goldColor;
  ctx.font = "italic 500 30px 'Noto Serif Devanagari', 'Tiro Devanagari Sanskrit', 'Georgia', serif";
  ctx.fillText(`— ${authorName}`, textX, textY);

  if (sourceName) {
    textY += 40;
    ctx.fillStyle = 'rgba(212, 175, 55, 0.6)';
    ctx.font = "300 20px 'Inter', sans-serif";
    ctx.fillText(sourceName, textX, textY);
  }

  // 6. Draw Bottom Watermark Footer
  ctx.fillStyle = 'rgba(227, 222, 208, 0.35)';
  ctx.font = "500 18px 'Inter', sans-serif";
  ctx.fillText('path.vrindopnishad.in • वृंदोपनिषद् पाठ', 540, 960);

  // 7. Perform Share or Download Fallback
  try {
    canvas.toBlob(async (blob) => {
      if (!blob) throw new Error('Canvas blob generation failed');
      
      const file = new File([blob], `Vrindopnishad_Pad_${content.id || 'Verse'}.png`, { type: 'image/png' });
      
      // Check if browser supports Web Share API with files
      if (navigator.canShare && navigator.canShare({ files: [file] })) {
        try {
          await navigator.share({
            files: [file],
            title: content.title || 'Vrindopnishad Verse',
            text: isHindiRoute 
              ? `वृंदोपनिषद् पाठ से आज का दिव्य रस सुनें: ${content.title} (${authorName})` 
              : `Divine verse from Vrindopnishad Paath: ${content.title} by ${authorName}`
          });
          return; // Shared successfully!
        } catch (shareError) {
          // If share aborted by user, don't trigger download
          if (shareError.name === 'AbortError') return;
          console.warn('Share API failed, falling back to download:', shareError);
        }
      }
      
      // Fallback: Direct Download
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = `Vrindopnishad_Pad_${content.id || 'Verse'}.png`;
      link.click();
      URL.revokeObjectURL(link.href);
    }, 'image/png');
  } catch (err) {
    console.error('Failed to export/share canvas image:', err);
    // Ultimate fallback: canvas URL
    const url = canvas.toDataURL('image/png');
    const link = document.createElement('a');
    link.href = url;
    link.download = `Vrindopnishad_Pad_${content.id || 'Verse'}.png`;
    link.click();
  }
};
