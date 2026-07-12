#!/usr/bin/env python3
"""Generate placeholder pixel art assets for 芯麓谷物语."""
import os
from PIL import Image

BASE = '/Users/skat/projects/芯麓谷物语/assets/images'
P = {
    'skin': (255, 200, 150), 's_dark': (220, 160, 110),
    'h_brn': (139, 90, 43), 'h_blk': (50, 40, 35), 'h_org': (220, 130, 60),
    's_blue': (70, 130, 180), 's_red': (200, 70, 70), 's_grn': (100, 170, 80),
    's_wht': (240, 240, 240), 'p_blue': (60, 80, 140), 'p_brn': (120, 90, 60),
    'p_dark': (60, 50, 40), 'shoe': (80, 50, 30), 'hat': (180, 150, 100),
    'hat_r': (200, 100, 160), 'grass': (100, 180, 80), 'dirt': (180, 140, 80),
    'tilled': (140, 100, 50), 'water': (60, 130, 210), 'w_dark': (40, 90, 160),
    'stone': (160, 160, 160), 's_dark': (120, 120, 120), 'wood': (180, 150, 100),
    'w_dark': (140, 110, 60), 'path': (200, 180, 150), 'roof': (180, 80, 60),
    'wall': (220, 200, 160), 'blk': (0, 0, 0), 'tr': (0, 0, 0, 0),
}

def body(img, x, y, sh, pa, sk, hr, ht=None, rb=None):
    p = lambda dx, dy, c: img.putpixel((x+dx, y+dy), c)
    for dy in range(2, 6):
        for dx in range(6, 12): p(dx, dy, sk)
    for dy in range(1, 4):
        for dx in range(5, 13): p(dx, dy, hr)
    p(5, 4, hr); p(12, 4, hr)
    p(8, 4, P['blk']); p(10, 4, P['blk'])
    for dy in range(6, 10):
        for dx in range(6, 12): p(dx, dy, sh)
    for dy in range(6, 10): p(5, dy, sk); p(12, dy, sk)
    p(5, 9, sk); p(12, 9, sk)
    for dy in range(10, 13):
        for dx in range(7, 11): p(dx, dy, pa)
    for dy in range(10, 13): p(6, dy, pa); p(11, dy, pa)
    for dx in range(6, 12): p(dx, 13, P['shoe'])
    p(6, 14, P['shoe']); p(7, 14, P['shoe']); p(10, 14, P['shoe']); p(11, 14, P['shoe'])
    if ht:
        for dy in range(0, 3):
            for dx in range(5, 13): p(dx, dy, ht)
        if rb:
            for dx in range(5, 13): p(dx, 2, rb)

def d_d(img, x, y, *a):
    body(img, x, y, *a)
    p = lambda dx, dy, c: img.putpixel((x+dx, y+dy), c)
    p(7, 15, P['shoe']); p(8, 15, P['shoe']); p(9, 15, P['shoe']); p(10, 15, P['shoe'])

def d_u(img, x, y, sh, pa, sk, hr, ht=None, rb=None):
    body(img, x, y, sh, pa, sk, hr, ht, rb)
    p = lambda dx, dy, c: img.putpixel((x+dx, y+dy), c)
    for dy in range(2, 5):
        for dx in range(6, 12): p(dx, dy, hr)

def d_s(img, x, y, sh, pa, sk, hr, ht=None, rb=None):
    p = lambda dx, dy, c: img.putpixel((x+dx, y+dy), c)
    for dy in range(2, 6):
        for dx in range(7, 11): p(dx, dy, sk)
    for dy in range(1, 4):
        for dx in range(6, 12): p(dx, dy, hr)
    p(5, 4, hr); p(9, 4, P['blk'])
    for dy in range(6, 10):
        for dx in range(7, 11): p(dx, dy, sh)
    for dy in range(6, 10): p(11, dy, sk)
    p(11, 9, sk)
    p(6, 6, sk); p(6, 7, sk); p(5, 8, sk); p(5, 9, sk)
    for dy in range(10, 13):
        for dx in range(8, 11): p(dx, dy, pa)
    for dy in range(10, 13): p(7, dy, pa)
    for dx in range(7, 12): p(dx, 13, P['shoe'])
    p(8, 14, P['shoe']); p(9, 14, P['shoe']); p(11, 14, P['shoe'])

def char_sheets(sh, pa, sk, hr, ht=None, rb=None):
    w, h = 64, 24
    dirs = ['idle_down', 'idle_up', 'idle_left', 'idle_right',
            'run_down', 'run_up', 'run_left', 'run_right']
    out = {}
    for d in dirs:
        img = Image.new('RGBA', (w, h), P['tr'])
        if d == 'idle_down':
            for i in range(4): d_d(img, i*16, 0, sh, pa, sk, hr, ht, rb)
        elif d == 'idle_up':
            for i in range(4): d_u(img, i*16, 0, sh, pa, sk, hr, ht, rb)
        elif d == 'idle_left':
            for i in range(4): d_s(img, i*16, 0, sh, pa, sk, hr, ht, rb)
        elif d == 'idle_right':
            for i in range(4):
                tmp = Image.new('RGBA', (16, 24), P['tr'])
                d_s(tmp, 0, 0, sh, pa, sk, hr, ht, rb)
                img.paste(tmp.transpose(Image.FLIP_LEFT_RIGHT), (i*16, 0))
        elif d == 'run_down':
            for i, f in enumerate([d_d, d_d, d_d, d_d]):
                f(img, i*16, 0, sh, pa, sk, hr)
        elif d == 'run_up':
            for i, f in enumerate([d_u, d_u, d_u, d_u]):
                f(img, i*16, 0, sh, pa, sk, hr)
        elif d == 'run_left':
            for i, f in enumerate([d_s, d_s, d_s, d_s]):
                f(img, i*16, 0, sh, pa, sk, hr)
        elif d == 'run_right':
            for i, f in enumerate([d_s, d_s, d_s, d_s]):
                tmp = Image.new('RGBA', (16, 24), P['tr'])
                f(tmp, 0, 0, sh, pa, sk, hr)
                img.paste(tmp.transpose(Image.FLIP_LEFT_RIGHT), (i*16, 0))
        out[d] = img
    return out

def gen_tiles():
    p = f'{BASE}/tiles'
    # grass
    img = Image.new('RGBA', (16, 16), P['grass'])
    for i in range(3):
        for j in range(3):
            if (i+j) % 2 == 0: img.putpixel((i+4, j+4), (120, 200, 90))
    img.save(f'{p}/grass.png')
    # dirt
    img = Image.new('RGBA', (16, 16), P['dirt'])
    for i in range(5):
        img.putpixel((i+6, 5), (160, 120, 60)); img.putpixel((i+6, 10), (160, 120, 60))
    img.save(f'{p}/dirt.png')
    # tilled
    img = Image.new('RGBA', (16, 16), P['tilled'])
    for i in range(8):
        img.putpixel((i*2, 2), (120, 80, 30)); img.putpixel((i*2+1, 9), (120, 80, 30))
    img.save(f'{p}/tilled.png')
    # water
    img = Image.new('RGBA', (16, 16), P['water'])
    for i in range(4):
        img.putpixel((i+2, 4), P['w_dark']); img.putpixel((i+10, 10), P['w_dark'])
    img.save(f'{p}/water.png')
    # stone
    img = Image.new('RGBA', (16, 16), P['stone'])
    for i in range(4):
        for j in range(3):
            img.putpixel((i+3, j+3), P['s_dark']); img.putpixel((i+9, j+9), P['s_dark'])
    img.save(f'{p}/stone.png')
    # wood floor
    img = Image.new('RGBA', (16, 16), P['wood'])
    for i in range(3):
        for j in range(16):
            if i % 2 == 0: img.putpixel((i*5+2, j), P['w_dark'])
    img.save(f'{p}/wood_floor.png')
    # path
    img = Image.new('RGBA', (16, 16), P['path'])
    for i in range(3):
        img.putpixel((i+5, 3), P['dirt']); img.putpixel((i+5, 12), P['dirt'])
    img.save(f'{p}/path.png')
    # fence
    img = Image.new('RGBA', (16, 16), P['tr'])
    for dx in range(4, 13):
        img.putpixel((dx, 2), P['wood']); img.putpixel((dx, 13), P['wood'])
    for dy in range(2, 14):
        img.putpixel((4, dy), P['w_dark']); img.putpixel((12, dy), P['w_dark'])
    for dx in range(5, 12): img.putpixel((dx, 7), P['wood'])
    img.save(f'{p}/fence.png')
    # wall
    img = Image.new('RGBA', (16, 16), P['wall'])
    for j in range(4):
        for i in range(8):
            img.putpixel((i*2, j*4), (200, 180, 140))
            img.putpixel((i*2+1, j*4+2), (180, 160, 120))
    img.save(f'{p}/wall.png')
    # roof
    img = Image.new('RGBA', (16, 16), P['roof'])
    for i in range(16):
        img.putpixel((i, 2-i//2), (200, 100, 70))
    img.save(f'{p}/roof.png')
    print('Tiles done')

def gen_items():
    p = f'{BASE}/items'
    def icon(fn, c, shp='sq'):
        img = Image.new('RGBA', (16, 16), P['tr'])
        if shp == 'sq':
            for dx in range(3, 13):
                for dy in range(3, 13): img.putpixel((dx, dy), c)
            dc = tuple(max(0, x-40) for x in c)
            for dx in range(2, 14):
                img.putpixel((dx, 2), dc); img.putpixel((dx, 13), dc)
            for dy in range(2, 14):
                img.putpixel((2, dy), dc); img.putpixel((13, dy), dc)
        elif shp == 'ci':
            cx, cy, r = 7, 7, 5
            for dx in range(-r, r+1):
                for dy in range(-r, r+1):
                    if dx*dx + dy*dy <= r*r: img.putpixel((cx+dx, cy+dy), c)
        img.save(f'{p}/{fn}.png')

    # Tools (simple shapes)
    for fn, c, shp in [
        ('hoe', (160, 120, 70), 'sq'), ('watering_can', (80, 120, 200), 'sq'),
        ('pickaxe', (160, 140, 80), 'sq'), ('axe', (180, 120, 60), 'sq'),
        ('scythe', (120, 180, 200), 'sq'),
    ]: icon(fn, c, shp)

    # Seeds
    for fn, c in [('seed_turnip', (240, 240, 240)), ('seed_potato', (200, 170, 100)),
                   ('seed_cabbage', (140, 200, 100)), ('seed_rice', (240, 230, 150)),
                   ('seed_tomato', (230, 80, 80)), ('seed_corn', (240, 210, 80)),
                   ('seed_pepper', (220, 50, 50)), ('seed_melon', (100, 200, 100)),
                   ('seed_pumpkin', (230, 150, 50)), ('seed_carrot', (240, 140, 40)),
                   ('seed_grape', (160, 80, 180)), ('seed_wheat', (220, 200, 120))]:
        icon(fn, c, 'ci')

    # Crops
    for fn, c in [('turnip', (240, 240, 240)), ('potato', (200, 170, 100)),
                   ('cabbage', (140, 200, 100)), ('rice', (220, 210, 130)),
                   ('tomato', (230, 80, 80)), ('corn', (240, 210, 80)),
                   ('pepper', (220, 50, 50)), ('melon', (100, 200, 100)),
                   ('pumpkin', (230, 150, 50)), ('carrot', (240, 140, 40)),
                   ('grape', (160, 80, 180)), ('wheat', (220, 200, 120))]:
        icon(fn, c, 'sq')

    # Resources & other
    for fn, c in [('wood', (180, 150, 100)), ('stone', (160, 160, 160)),
                   ('coal', (60, 60, 60)), ('copper_ore', (200, 140, 80)),
                   ('iron_ore', (150, 150, 160)), ('gold_ore', (240, 210, 50)),
                   ('copper_bar', (220, 160, 80)), ('iron_bar', (180, 180, 190)),
                   ('gold_bar', (255, 220, 60)), ('wine', (150, 50, 120)),
                   ('juice', (240, 160, 60)), ('cheese', (240, 220, 100)),
                   ('bread', (220, 180, 120)), ('bouquet', (240, 100, 140)),
                   ('chocolate', (120, 70, 40)), ('furnace', (120, 120, 120)),
                   ('chest', (180, 150, 100)), ('scarecrow', (180, 160, 100)),
                   ('wild_herb', (100, 180, 80)), ('mushroom', (200, 160, 120)),
                   ('berry', (180, 60, 100)), ('flower', (240, 160, 200)),
                   ('fish_carp', (180, 180, 100)), ('fertilizer', (160, 200, 180))]:
        icon(fn, c, 'sq' if fn not in ('wine', 'juice', 'berry', 'flower', 'wild_herb', 'mushroom') else 'ci')
    print('Items done')

def gen_crop_stages():
    p = f'{BASE}/tiles'
    for crop in ['turnip', 'potato', 'cabbage', 'rice', 'tomato', 'corn',
                 'pepper', 'melon', 'pumpkin', 'carrot', 'grape', 'wheat']:
        for sn, (shp, c) in [('seed', ('dot', (100, 80, 40))),
                              ('sprout', ('sp', (80, 160, 60))),
                              ('growing', ('gr', (60, 180, 40))),
                              ('ready', ('rd', (40, 200, 30)))]:
            img = Image.new('RGBA', (16, 16), P['tr'])
            dc = tuple(max(0, x-30) for x in c)
            lc = tuple(min(255, x+50) for x in c)
            if shp == 'dot':
                for dx in range(6, 10):
                    for dy in range(12, 15): img.putpixel((dx, dy), c)
            elif shp == 'sp':
                for dy in range(9, 15): img.putpixel((7, dy), c); img.putpixel((8, dy), c)
                for dx in range(6, 10): img.putpixel((dx, 14), dc)
            elif shp == 'gr':
                for dx in range(3, 13):
                    for dy in range(8, 13):
                        if dx > 4 and dx < 11 or dy > 9: img.putpixel((dx, dy), c)
                for dx in range(5, 11): img.putpixel((dx, 7), c)
            elif shp == 'rd':
                for dx in range(2, 14):
                    for dy in range(5, 14):
                        if dx > 3 and dx < 12 or dy > 7: img.putpixel((dx, dy), c)
                for dx in range(5, 11): img.putpixel((dx, 4), c)
                for dx in range(6, 10):
                    for dy in range(6, 9): img.putpixel((dx, dy), lc)
            img.save(f'{p}/{crop}_{sn}.png')
    print('Crop stages done')

def gen_tmx():
    lines = ['<?xml version="1.0" encoding="UTF-8"?>',
             '<map version="1.10" tiledversion="1.11.0" orientation="orthogonal"',
             ' renderorder="right-down" width="40" height="30" tilewidth="16" tileheight="16"',
             ' infinite="0" nextlayerid="4" nextobjectid="1">',
             '<tileset firstgid="1" name="tiles" tilewidth="16" tileheight="16" tilecount="12" columns="4">',
             '<image source="../images/tiles/grass.png" width="16" height="16"/>',
             '</tileset>',
             '<layer id="1" name="ground" width="40" height="30"><data encoding="csv">']
    for y in range(30):
        row = []
        for x in range(40):
            if 2 <= x <= 5 and 24 <= y <= 27: row.append('4')
            elif 1 <= x <= 3 and 25 <= y <= 26: row.append('4')
            elif (8 <= x <= 18 and y == 5) or (x == 9 and 6 <= y <= 10): row.append('2')
            elif (8 <= x <= 18 and y == 15): row.append('2')
            elif (22 <= x <= 28 and y == 12): row.append('2')
            elif (x == 22 and 5 <= y <= 12): row.append('2')
            elif 10 <= x <= 21 and 6 <= y <= 14: row.append('3')
            elif 28 <= x <= 32 and 5 <= y <= 10: row.append('5')
            elif x == 34 and 5 <= y <= 10: row.append('5')
            else: row.append('1')
        lines.append(','.join(row))
    lines.append('</data></layer>')
    lines.append('<layer id="2" name="buildings" width="40" height="30"><data encoding="csv">')
    for y in range(30):
        row = []
        for x in range(40):
            if 28 <= x <= 33 and y in (3, 4): row.append('9')
            elif 28 <= x <= 33 and 5 <= y <= 10: row.append('8')
            elif x in (27, 34) and 5 <= y <= 10: row.append('8')
            elif 35 <= x <= 38 and 6 <= y <= 9: row.append('8')
            elif 35 <= x <= 38 and y in (4, 5): row.append('9')
            elif x == 9 and 5 <= y <= 15: row.append('10')
            elif x == 22 and 5 <= y <= 15: row.append('10')
            elif y == 5 and 9 <= x <= 22: row.append('10')
            elif y == 15 and 9 <= x <= 22: row.append('10')
            else: row.append('0')
        lines.append(','.join(row))
    lines.append('</data></layer>')
    lines.append('<layer id="3" name="collision" width="40" height="30"><data encoding="csv">')
    for y in range(30):
        row = []
        for x in range(40):
            if x in (0, 39) or y in (0, 29): row.append('1')
            elif 3 <= x <= 5 and 24 <= y <= 27: row.append('1')
            elif 28 <= x <= 34 and 3 <= y <= 10: row.append('1')
            elif 35 <= x <= 38 and 4 <= y <= 9: row.append('1')
            elif x == 9 and 5 <= y <= 15: row.append('1')
            elif x == 22 and 5 <= y <= 15: row.append('1')
            elif y == 5 and 9 <= x <= 22: row.append('1')
            elif y == 15 and 9 <= x <= 22: row.append('1')
            else: row.append('0')
        lines.append(','.join(row))
    lines.append('</data></layer>')
    lines.append('</map>')
    with open(f'{BASE}/../maps/farm.tmx', 'w') as f:
        f.write('\n'.join(lines))
    print('TMX map done')

# ═══ MAIN ═══
if __name__ == '__main__':
    for d in ['tiles', 'characters', 'items', 'ui']:
        os.makedirs(f'{BASE}/{d}', exist_ok=True)
    os.makedirs(f'{BASE}/../maps', exist_ok=True)

    gen_tiles()
    gen_items()
    gen_crop_stages()

    print('Player...')
    s = char_sheets(P['s_blue'], P['p_blue'], P['skin'], P['h_brn'], P['hat'])
    for d, img in s.items():
        img.save(f'{BASE}/characters/player_{d}.png')

    print('NPCs...')
    for name, args in [
        ('lin', (P['s_grn'], P['p_dark'], P['skin'], P['h_brn'])),
        ('mei', (P['s_red'], P['p_blue'], P['skin'], P['h_org'], P['hat'], P['hat_r'])),
        ('lao_wang', (P['s_wht'], P['p_brn'], P['s_dark'], P['h_blk'])),
    ]:
        s = char_sheets(*args)
        for d, img in s.items():
            img.save(f'{BASE}/characters/{name}_{d}.png')

    # Placeholder
    Image.new('RGBA', (1, 1), P['tr']).save(f'{BASE}/tiles/placeholder.png')
    Image.new('RGBA', (1, 1), P['tr']).save(f'{BASE}/characters/placeholder.png')

    gen_tmx()
    print('All assets generated!')
