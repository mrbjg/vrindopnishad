#!/usr/bin/env python3
"""
Sant-Vaani Theme Icon Generator
Generates one gradient launcher icon per color theme at every Android mipmap
density and an iOS-ready 1024×1024 PNG – all using only Python stdlib (zlib +
struct) so no pip install is required.

Run from the project root:
    python3 scripts/generate_theme_icons.py
"""

import os, zlib, struct, math

# ─── Theme palette ────────────────────────────────────────────────────────────
THEMES = {
    "nebula":    {"name": "Nebula Blue",     "c1": (0x25, 0x6A, 0xF4), "c2": (0x04, 0x08, 0x28)},
    "saffron":   {"name": "Sacred Saffron",  "c1": (0xF2, 0xA6, 0x0D), "c2": (0x6B, 0x3A, 0x00)},
    "lotus":     {"name": "Lotus Rose",      "c1": (0xE8, 0x43, 0x7F), "c2": (0x4A, 0x06, 0x20)},
    "emerald":   {"name": "Divine Emerald",  "c1": (0x10, 0xB9, 0x81), "c2": (0x01, 0x28, 0x1C)},
    "amethyst":  {"name": "Mystic Amethyst", "c1": (0x8B, 0x5C, 0xF6), "c2": (0x1E, 0x0A, 0x4A)},
    "gold":      {"name": "Celestial Gold",  "c1": (0xD4, 0xA0, 0x17), "c2": (0x3E, 0x28, 0x00)},
    "ocean":     {"name": "Ocean Teal",      "c1": (0x08, 0x91, 0xB2), "c2": (0x01, 0x18, 0x28)},
    "midnight":  {"name": "Midnight Indigo", "c1": (0x63, 0x66, 0xF1), "c2": (0x0D, 0x0F, 0x38)},
}

# Android mipmap sizes: (folder suffix, icon px)
ANDROID_SIZES = [
    ("mdpi",    48),
    ("hdpi",    72),
    ("xhdpi",   96),
    ("xxhdpi",  144),
    ("xxxhdpi", 192),
]

IOS_SIZE = 1024      # single iOS alternate-icon PNG

# ─── Minimal PNG writer (pure stdlib) ─────────────────────────────────────────

def _chunk(tag: bytes, data: bytes) -> bytes:
    c = zlib.crc32(tag + data) & 0xFFFFFFFF
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", c)

def _png(pixels: list[list[tuple[int,int,int,int]]], w: int, h: int) -> bytes:
    """Encode RGBA pixels as a PNG bytestring."""
    raw = b""
    for row in pixels:
        raw += b"\x00"                      # filter type: None
        for r, g, b, a in row:
            raw += bytes([r, g, b, a])
    compressed = zlib.compress(raw, 9)
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)   # 8-bit RGBA
    return (
        b"\x89PNG\r\n\x1a\n"
        + _chunk(b"IHDR", ihdr)
        + _chunk(b"IDAT", compressed)
        + _chunk(b"IEND", b"")
    )

# ─── Icon drawing ──────────────────────────────────────────────────────────────

def _lerp(a, b, t):
    return a + (b - a) * t

def _draw_icon(size: int, c1: tuple, c2: tuple) -> bytes:
    """
    Render a square icon of `size×size` pixels:
      • Dark radial-gradient background (c2 → c1 radially from edge to centre)
      • Rounded square clip mask (25 % radius)
      • Glowing halo ring
      • Stylised two-line flame / lotus petals drawn with bezier-like strokes
      • A dot 'Om' node at the centre
    All maths in pure Python – no external libs.
    """
    s = size
    cx = cy = s / 2
    max_r = s * 0.5          # bounding circle radius

    # Pre-compute rounded-square mask radius
    rr = s * 0.22            # corner radius

    pixels = []
    for y in range(s):
        row = []
        for x in range(s):
            # ── Rounded-square clip ──────────────────────────────────────────
            dx = abs(x - cx)
            dy = abs(y - cy)
            qx = max(dx - (cx - rr), 0)
            qy = max(dy - (cy - rr), 0)
            dist_corner = math.sqrt(qx*qx + qy*qy)
            in_shape = (dx <= cx - rr or dy <= cy - rr or dist_corner <= rr)
            if not in_shape:
                row.append((0, 0, 0, 0))
                continue

            # ── Radial gradient: dark center core → accent ring → deep edge ──
            dist = math.sqrt((x - cx)**2 + (y - cy)**2) / max_r   # 0..1+
            dist = min(dist, 1.0)

            # Core bright zone (0→0.35): c1 tinted toward white
            # Mid gradient (0.35→0.75): c1 → c2
            # Edge zone (0.75→1.0): c2 → very dark
            if dist < 0.30:
                t = dist / 0.30
                r = int(_lerp(min(c1[0] + 80, 255), c1[0], t))
                g = int(_lerp(min(c1[1] + 80, 255), c1[1], t))
                b = int(_lerp(min(c1[2] + 80, 255), c1[2], t))
            elif dist < 0.72:
                t = (dist - 0.30) / 0.42
                r = int(_lerp(c1[0], c2[0], t))
                g = int(_lerp(c1[1], c2[1], t))
                b = int(_lerp(c1[2], c2[2], t))
            else:
                t = (dist - 0.72) / 0.28
                r = int(_lerp(c2[0], 4, t))
                g = int(_lerp(c2[1], 4, t))
                b = int(_lerp(c2[2], 4, t))

            # ── Halo ring at ~65 % radius ───────────────────────────────────
            ring_dist = abs(dist - 0.65)
            if ring_dist < 0.04:
                glow_t = 1.0 - (ring_dist / 0.04)
                r = int(_lerp(r, min(c1[0] + 120, 255), glow_t * 0.45))
                g = int(_lerp(g, min(c1[1] + 120, 255), glow_t * 0.45))
                b = int(_lerp(b, min(c1[2] + 120, 255), glow_t * 0.45))

            # ── Secondary inner glow ring at ~28 % ──────────────────────────
            ring2 = abs(dist - 0.28)
            if ring2 < 0.025:
                glow2 = 1.0 - (ring2 / 0.025)
                r = int(_lerp(r, min(c1[0] + 160, 255), glow2 * 0.35))
                g = int(_lerp(g, min(c1[1] + 160, 255), glow2 * 0.35))
                b = int(_lerp(b, min(c1[2] + 160, 255), glow2 * 0.35))

            a = 255
            row.append((r, g, b, a))
        pixels.append(row)

    # ── Overlay: draw decorative symbol (flame petals + centre dot) ──────────
    # We rasterise directly into pixels using soft-circle primitives.

    def soft_dot(px, py, radius, col, strength=1.0):
        """Paint a soft glowing dot."""
        px, py = int(round(px)), int(round(py))
        ri = int(radius * 2.5) + 1
        for oy in range(-ri, ri + 1):
            for ox in range(-ri, ri + 1):
                fx, fy = px + ox, py + oy
                if 0 <= fx < s and 0 <= fy < s:
                    d = math.sqrt(ox*ox + oy*oy)
                    if d < radius * 2.5:
                        fade = max(0.0, 1.0 - (d / (radius * 2.5))) ** 2 * strength
                        pr, pg, pb, pa = pixels[fy][fx]
                        nr = int(_lerp(pr, col[0], fade))
                        ng = int(_lerp(pg, col[1], fade))
                        nb = int(_lerp(pb, col[2], fade))
                        pixels[fy][fx] = (nr, ng, nb, pa)

    def soft_stroke(ax, ay, bx, by, thickness, col, steps=120, strength=0.9):
        """Draw an anti-aliased line segment."""
        for i in range(steps + 1):
            t = i / steps
            lx = ax + (bx - ax) * t
            ly = ay + (by - ay) * t
            soft_dot(lx, ly, thickness * 0.6, col, strength * (0.6 + 0.4 * math.sin(math.pi * t)))

    # Symbol colours: white with slight accent tint
    sym = (
        min(c1[0] + 180, 255),
        min(c1[1] + 180, 255),
        min(c1[2] + 180, 255),
    )
    sym_dim = (
        min(c1[0] + 80, 220),
        min(c1[1] + 80, 220),
        min(c1[2] + 80, 220),
    )

    r = s * 0.5          # icon radius
    tk = max(1.5, s * 0.022)   # stroke thickness

    # — Three lotus petals (upward flame shape) —
    num_petals = 6
    petal_r_inner = r * 0.14
    petal_r_outer = r * 0.40
    for i in range(num_petals):
        angle = (2 * math.pi * i / num_petals) - math.pi / 2
        tip_x = cx + math.cos(angle) * petal_r_outer
        tip_y = cy + math.sin(angle) * petal_r_outer
        base_x = cx + math.cos(angle) * petal_r_inner
        base_y = cy + math.sin(angle) * petal_r_inner
        soft_stroke(base_x, base_y, tip_x, tip_y, tk * 0.9, sym_dim, steps=60, strength=0.65)
        # arc wing left
        wing_angle = angle - 0.55
        wx = cx + math.cos(wing_angle) * petal_r_inner * 1.3
        wy = cy + math.sin(wing_angle) * petal_r_inner * 1.3
        soft_stroke(base_x, base_y, wx, wy, tk * 0.5, sym_dim, steps=40, strength=0.45)
        # arc wing right
        wing_angle2 = angle + 0.55
        wx2 = cx + math.cos(wing_angle2) * petal_r_inner * 1.3
        wy2 = cy + math.sin(wing_angle2) * petal_r_inner * 1.3
        soft_stroke(base_x, base_y, wx2, wy2, tk * 0.5, sym_dim, steps=40, strength=0.45)

    # — Central glowing orb —
    soft_dot(cx, cy, r * 0.12, sym, strength=1.0)
    soft_dot(cx, cy, r * 0.06, (255, 255, 255), strength=1.0)

    # — Outer accent dots at cardinal points —
    for angle in [0, math.pi/2, math.pi, 3*math.pi/2]:
        dx2 = cx + math.cos(angle) * r * 0.64
        dy2 = cy + math.sin(angle) * r * 0.64
        soft_dot(dx2, dy2, r * 0.025, sym, strength=0.7)

    return _png(pixels, s, s)

# ─── Output paths ──────────────────────────────────────────────────────────────

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ANDROID_RES = os.path.join(BASE, "android", "app", "src", "main", "res")
IOS_RES     = os.path.join(BASE, "ios", "Runner")

def ensure(path):
    os.makedirs(path, exist_ok=True)

def run():
    print("Sant-Vaani Theme Icon Generator")
    print("=" * 40)
    total = 0
    for key, theme in THEMES.items():
        c1, c2 = theme["c1"], theme["c2"]
        alias = f"ic_launcher_{key}"
        print(f"\n[{theme['name']}]")

        # Android mipmaps
        for density, sz in ANDROID_SIZES:
            folder = os.path.join(ANDROID_RES, f"mipmap-{density}")
            ensure(folder)
            path = os.path.join(folder, f"{alias}.png")
            data = _draw_icon(sz, c1, c2)
            with open(path, "wb") as f:
                f.write(data)
            print(f"  ✓ {density:10s} {sz}×{sz}  →  {os.path.relpath(path, BASE)}")
            total += 1

        # iOS single icon
        ios_path = os.path.join(IOS_RES, f"icon_{key}.png")
        data = _draw_icon(IOS_SIZE, c1, c2)
        with open(ios_path, "wb") as f:
            f.write(data)
        print(f"  ✓ iOS 1024×1024  →  {os.path.relpath(ios_path, BASE)}")
        total += 1

    print(f"\n✅ {total} icon files generated successfully.")

if __name__ == "__main__":
    run()
