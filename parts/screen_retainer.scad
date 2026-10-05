// Flat clips that screw onto the lid-panel bosses and clamp the screen.
// Prints flat; one clip per boss.
include <../lib/common.scad>

S      = preset(screen, screen_presets);
n_clips = 2 * bosses_long_side + 2 * bosses_short_side;

reach  = boss_d / 2 + 0.5;            // boss centre -> screen edge
clip_l = boss_d / 2 + reach + clip_overlap;

module clip() {
    difference() {
        // hole centre at origin, clip extends +x over the screen
        translate([-boss_d / 2, -clip_w / 2, 0])
            linear_extrude(clip_t) offset(r = 1.5) offset(delta = -1.5) square([clip_l, clip_w]);
        translate([0, 0, -1]) cylinder(d = m3_clear_d, h = clip_t + 2);
    }
}

for (k = [0 : n_clips - 1]) translate([0, k * (clip_w + 4), 0]) clip();
