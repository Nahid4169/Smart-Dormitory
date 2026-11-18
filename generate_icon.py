from PIL import Image, ImageDraw, ImageFilter
import os

def create_smart_dorm_icon():
    size = 1024
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background rounded rectangle
    margin = 48
    corner_radius = 220
    bbox = [margin, margin, size - margin, size - margin]

    # Draw background with gradient effect
    bg_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg_layer)

    for i in range(margin, size - margin):
        # Vertical gradient from #121A30 to #070A14
        ratio = (i - margin) / (size - 2 * margin)
        r = int(18 + ratio * (7 - 18))
        g = int(26 + ratio * (10 - 26))
        b = int(48 + ratio * (20 - 48))
        bg_draw.line([(margin, i), (size - margin, i)], fill=(r, g, b, 255))

    # Create rounded mask for background
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(bbox, radius=corner_radius, fill=255)

    bg_layer.putalpha(mask)
    img.paste(bg_layer, (0, 0), bg_layer)

    # 2. Outer border / glow ring
    border_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border_layer)
    border_draw.rounded_rectangle(bbox, radius=corner_radius, outline=(139, 124, 255, 100), width=6)
    img = Image.alpha_composite(img, border_layer)

    # 3. Central Glow behind building
    glow_size = 600
    glow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)
    glow_draw.ellipse(
        [size//2 - glow_size//2, size//2 - glow_size//2 + 30, size//2 + glow_size//2, size//2 + glow_size//2 + 30],
        fill=(139, 124, 255, 55)
    )
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(50))
    img = Image.alpha_composite(img, glow_layer)

    # 4. Draw Building (Smart Dormitory Building Silhouette)
    building_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(building_layer)

    # Building body (Centered, width 420, height 520, from y=240 to y=760)
    bx1, by1, bx2, by2 = 302, 240, 722, 780

    # Main building structure with slight gradient or solid sleek navy/purple
    b_draw.rounded_rectangle([bx1, by1, bx2, by2], radius=24, fill=(29, 41, 65, 255), outline=(85, 184, 255, 180), width=4)

    # Roof antenna / smart tower
    b_draw.rectangle([502, 170, 522, 240], fill=(139, 124, 255, 255))
    b_draw.ellipse([492, 150, 532, 190], fill=(69, 214, 160, 255)) # Smart sensor beacon

    # Windows grid (3 columns, 5 rows)
    cols = 3
    rows = 5
    start_x = bx1 + 55
    start_y = by1 + 60
    w_width = 75
    w_height = 80
    gap_x = 35
    gap_y = 25

    for r in range(rows):
        for c in range(cols):
            wx = start_x + c * (w_width + gap_x)
            wy = start_y + r * (w_height + gap_y)

            # Alternate active/inactive smart window colors (Purple, Blue, Green)
            if (r + c) % 3 == 0:
                w_color = (139, 124, 255, 230) # Purple
            elif (r + c) % 3 == 1:
                w_color = (85, 184, 255, 230)  # Blue
            else:
                w_color = (69, 214, 160, 230)  # Green

            b_draw.rounded_rectangle([wx, wy, wx + w_width, wy + w_height], radius=10, fill=w_color)

    # Entrance door at bottom center
    door_w = 90
    door_h = 130
    dx1 = size//2 - door_w//2
    dy1 = by2 - door_h
    b_draw.rounded_rectangle([dx1, dy1, dx1 + door_w, by2], radius=15, fill=(11, 16, 32, 255), outline=(139, 124, 255, 255), width=3)

    # Smart badge / door light
    b_draw.ellipse([dx1 + 15, dy1 + 45, dx1 + 35, dy1 + 65], fill=(69, 214, 160, 255))

    img = Image.alpha_composite(img, building_layer)

    # 5. Smart Wi-Fi / IoT Waves at top
    wave_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    w_draw = ImageDraw.Draw(wave_layer)

    # Draw arc signals above tower
    center = (512, 170)
    w_draw.arc([center[0]-70, center[1]-70, center[0]+70, center[1]+70], start=210, end=330, fill=(85, 184, 255, 220), width=8)
    w_draw.arc([center[0]-110, center[1]-110, center[0]+110, center[1]+110], start=210, end=330, fill=(139, 124, 255, 220), width=8)

    img = Image.alpha_composite(img, wave_layer)

    # Ensure directory exists
    os.makedirs("assets/icon", exist_ok=True)
    img.save("assets/icon/app_icon.png", "PNG")
    print("Successfully generated assets/icon/app_icon.png")

if __name__ == "__main__":
    create_smart_dorm_icon()
