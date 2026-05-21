import os
import subprocess
import re
from PIL import Image

def generate_favicons():
    svg_path = '/Users/sakhi/Code/Company/Projects/VrindaVaani/frontend/public/favicon.svg'
    public_dir = '/Users/sakhi/Code/Company/Projects/VrindaVaani/frontend/public'
    
    # Read original SVG
    with open(svg_path, 'r') as f:
        svg_content = f.read()

    # Define light and dark styles to insert
    light_style = """    <style>
        .bg {
            fill: #ffffff;
        }
        .main-path {
            fill: #000000;
        }
        .raj-path {
            fill: rgb(128,128,128);
        }
        .shyam-shri-ellipse {
            fill: none;
            stroke: #000000;
            stroke-width: 0.15px;
        }
    </style>"""

    dark_style = """    <style>
        .bg {
            fill: #000000;
        }
        .main-path {
            fill: #ffffff;
        }
        .raj-path {
            fill: rgb(255,222,0);
        }
        .shyam-shri-ellipse {
            fill: #ffffff;
            stroke: none;
        }
    </style>"""

    # Replace original style block
    style_regex = re.compile(r'<style>.*?</style>', re.DOTALL)
    
    svg_light = style_regex.sub(light_style, svg_content)
    svg_dark = style_regex.sub(dark_style, svg_content)

    temp_light_svg = '/tmp/temp_light.svg'
    temp_dark_svg = '/tmp/temp_dark.svg'

    with open(temp_light_svg, 'w') as f:
        f.write(svg_light)
    with open(temp_dark_svg, 'w') as f:
        f.write(svg_dark)

    print("Generating light-theme and dark-theme base PNGs using qlmanage...")
    # Render SVGs to 512x512 PNGs using qlmanage
    subprocess.run(['qlmanage', '-t', '-s', '512', '-o', '/tmp', temp_light_svg], check=True)
    subprocess.run(['qlmanage', '-t', '-s', '512', '-o', '/tmp', temp_dark_svg], check=True)

    png_light_base = '/tmp/temp_light.svg.png'
    png_dark_base = '/tmp/temp_dark.svg.png'

    # Verify files were created
    if not os.path.exists(png_light_base) or not os.path.exists(png_dark_base):
        raise FileNotFoundError("qlmanage failed to generate PNGs.")

    print("Base PNGs generated. Opening with Pillow...")
    img_light = Image.open(png_light_base)
    img_dark = Image.open(png_dark_base)

    # Let's clean up/crop the thumbnail (qlmanage adds a subtle border or padding sometimes, but usually -t -s 512 is tight. Let's make sure it's correct)
    print(f"Light image format: {img_light.format}, size: {img_light.size}, mode: {img_light.mode}")
    print(f"Dark image format: {img_dark.format}, size: {img_dark.size}, mode: {img_dark.mode}")

    # Generate assets for Light/Default Theme
    targets_light = {
        'favicon-16x16.png': (16, 16),
        'favicon-32x32.png': (32, 32),
        'apple-touch-icon.png': (180, 180),
        'android-chrome-192x192.png': (192, 192),
        'android-chrome-512x512.png': (512, 512),
        # Light theme specific naming (for prefers-color-scheme links)
        'favicon-16x16-light-theme.png': (16, 16),
        'favicon-32x32-light-theme.png': (32, 32),
        'apple-touch-icon-light-theme.png': (180, 180),
        'android-chrome-192x192-light-theme.png': (192, 192),
        'android-chrome-512x512-light-theme.png': (512, 512),
    }

    targets_dark = {
        'favicon-16x16-dark-theme.png': (16, 16),
        'favicon-32x32-dark-theme.png': (32, 32),
        'apple-touch-icon-dark-theme.png': (180, 180),
        'android-chrome-192x192-dark-theme.png': (192, 192),
        'android-chrome-512x512-dark-theme.png': (512, 512),
    }

    # Helper function to save resized PNGs
    def save_resized(img, filename, size):
        resized = img.resize(size, Image.Resampling.LANCZOS)
        out_path = os.path.join(public_dir, filename)
        resized.save(out_path, 'PNG')
        print(f"Saved: {out_path}")

    for filename, size in targets_light.items():
        save_resized(img_light, filename, size)

    for filename, size in targets_dark.items():
        save_resized(img_dark, filename, size)

    # Generate multi-resolution .ico files
    # favicon.ico and favicon-light-theme.ico should contain 16x16 and 32x32 sizes of light theme
    ico_sizes = [(16, 16), (32, 32)]
    ico_imgs_light = [img_light.resize(sz, Image.Resampling.LANCZOS) for sz in ico_sizes]
    ico_imgs_dark = [img_dark.resize(sz, Image.Resampling.LANCZOS) for sz in ico_sizes]

    favicon_ico_path = os.path.join(public_dir, 'favicon.ico')
    favicon_light_ico_path = os.path.join(public_dir, 'favicon-light-theme.ico')
    favicon_dark_ico_path = os.path.join(public_dir, 'favicon-dark-theme.ico')

    # Save ICOs
    ico_imgs_light[0].save(favicon_ico_path, format='ICO', sizes=ico_sizes, append_images=ico_imgs_light[1:])
    print(f"Saved: {favicon_ico_path}")
    
    ico_imgs_light[0].save(favicon_light_ico_path, format='ICO', sizes=ico_sizes, append_images=ico_imgs_light[1:])
    print(f"Saved: {favicon_light_ico_path}")

    ico_imgs_dark[0].save(favicon_dark_ico_path, format='ICO', sizes=ico_sizes, append_images=ico_imgs_dark[1:])
    print(f"Saved: {favicon_dark_ico_path}")

    # Clean up temp files
    for path in [temp_light_svg, temp_dark_svg, png_light_base, png_dark_base]:
        if os.path.exists(path):
            os.remove(path)
            
    print("All favicon assets generated successfully!")

if __name__ == '__main__':
    generate_favicons()
