// LID screen panel: bezel window + screen retainer bosses + mounting holes.
// Front face (viewing side) is z = panel_t, back face is z = 0.
// Bosses grow from the back (-z); the screen glass sits against the back.
include <../lib/common.scad>

piece = "all";   // "all" (exploded tiles), "whole", or [i, j]

S       = preset(screen, screen_presets);
mod_w   = S[0]; mod_h = S[1]; mod_t = S[2];
act_w   = S[3]; act_h = S[4];
act_off = [S[5], S[6]];

lid_L = case_in_l - 2 * (panel_gap + lid_draft_inset);
lid_W = case_in_w - 2 * (panel_gap + lid_draft_inset);
lid_R = max(case_corner_r - panel_gap - lid_draft_inset, 1);

lid_n  = auto_split(lid_L, lid_W);
lid_xs = resolve_seams(lid_split_x, lid_L, lid_n[0]);
lid_ys = resolve_seams(lid_split_y, lid_W, lid_n[1]);

boss_h     = mod_t + screen_shim;
boss_reach = boss_d / 2 + 0.5;   // boss centre -> screen module edge

function lin(n, len) = [for (k = [0 : n - 1]) -len/2 + len * (k + 0.5) / n];

// [x, y, angle] — angle points from boss toward the screen (for clips)
function boss_positions() = concat(
    [for (x = lin(bosses_long_side, mod_w))  [x,  mod_h/2 + boss_reach, -90]],
    [for (x = lin(bosses_long_side, mod_w))  [x, -mod_h/2 - boss_reach,  90]],
    [for (y = lin(bosses_short_side, mod_h)) [ mod_w/2 + boss_reach, y, 180]],
    [for (y = lin(bosses_short_side, mod_h)) [-mod_w/2 - boss_reach, y,   0]]
);

// Seam screws stay out of the window (+ bevel + head) and away from mounts/bosses.
win_c = screen_offset + act_off;
lid_keepouts = concat(
    [[win_c[0], win_c[1],
      act_w + 2 * (window_margin + window_chamfer) + m3_csk_d + 2,
      act_h + 2 * (window_margin + window_chamfer) + m3_csk_d + 2]],
    point_keepouts(lid_mount_holes),
    point_keepouts([for (b = boss_positions()) [b[0] + screen_offset[0], b[1] + screen_offset[1]]], boss_d + 8)
);

module viewing_window() {
    ww = act_w + 2 * window_margin;
    wh = act_h + 2 * window_margin;
    c  = window_chamfer;
    hull() {
        translate([0, 0, -1]) linear_extrude(1 + panel_t - c) rrect(ww, wh, 1);
        translate([0, 0, panel_t + 1]) linear_extrude(0.01) rrect(ww + 2 * (c + 1), wh + 2 * (c + 1), 2 + c);
    }
}

module lid_panel_whole() {
    insert_depth = min(m3_insert_depth, boss_h + panel_t - 1.2);
    difference() {
        union() {
            plate(lid_L, lid_W, lid_R, panel_t);
            translate(screen_offset)
                for (b = boss_positions())
                    translate([b[0], b[1], -boss_h]) cylinder(d = boss_d, h = boss_h + 0.01);
        }
        translate(screen_offset + act_off) viewing_window();
        translate(screen_offset)
            for (b = boss_positions())
                translate([b[0], b[1], -boss_h - 0.01]) cylinder(d = m3_insert_d, h = insert_depth);
        for (p = lid_mount_holes) translate(p) m3_csk(panel_t);
        for (p = seam_holes(lid_xs, lid_ys, lid_L, lid_W, lid_keepouts)) translate(p) seam_screw(panel_t);
    }
}

// Screen module stand-in for the assembly preview.
module screen_dummy() {
    translate(concat(screen_offset, [-screen_shim - mod_t]))
        linear_extrude(mod_t) rrect(mod_w, mod_h, 1);
}

tiled(piece, lid_xs, lid_ys, panel_t) lid_panel_whole();
