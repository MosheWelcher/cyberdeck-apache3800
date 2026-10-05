// Fit gauge for the base faceplate: four thin corner pieces with the plate's
// exact outline and bracket screw holes. Print (1.2 mm, a few minutes each),
// lay them on the installed Printables brackets, and check:
//   - every hole lines up with an insert (drop an M3 screw through)
//   - the edge clears the case wall all round, corners included
// Also echoes FIT OK / FIT WARNING checks against the bracket geometry.
include <../lib/common.scad>

gauge_t    = 1.2;
gauge_band = 22;          // width of the edge band
gauge_leg  = [150, 120];  // corner piece reach along X, Y

// Same hole filter as parts/base_faceplate.scad
kb_hole_keepout = [kb_offset[0], kb_offset[1],
                   kb_cutout[0] + m3_csk_d + 6, kb_cutout[1] + m3_csk_d + 6];
used_mount_holes = [for (p = base_mount_holes) if (!in_rect(p, kb_hole_keepout)) p];

// ---------- checks ----------
function edge_dist(p) = min(base_L / 2 - abs(p[0]), base_W / 2 - abs(p[1]));
module check(ok, msg) echo(str(ok ? "FIT OK      " : "FIT WARNING ", msg));

wall_gap_x = (bracket_outer[0] - base_L) / 2;
wall_gap_y = (bracket_outer[1] - base_W) / 2;
check(min(wall_gap_x, wall_gap_y) >= 0.5,
      str("plate edge to case wall: ", wall_gap_x, " mm (ends), ", wall_gap_y, " mm (front/back)"));
check(base_R <= bracket_outer[2],
      str("plate corner R", base_R, " inside bracket corner R", bracket_outer[2]));
lip_cover = min(base_L / 2 - bracket_lip[0] / 2, base_W / 2 - bracket_lip[1] / 2);
check(lip_cover >= 8, str("plate overlaps the bracket lip by ", lip_cover, " mm (lip is 12)"));
for (p = used_mount_holes) {
    d = edge_dist(p);
    check(d >= m3_csk_d / 2 + 1, str("hole ", p, ": countersink ", d - m3_csk_d / 2, " mm from plate edge"));
}
kb_gap_x = bracket_lip[0] / 2 - kb_size[0] / 2;
check(kb_gap_x >= 1, str("K400 edge to end-bracket lip: ", kb_gap_x, " mm per side (test-fit / sand if < 1)"));
kb_gap_front = (kb_front_y - kb_hanger_flange) - (-bracket_lip[1] / 2);
kb_gap_back  = bracket_lip[1] / 2 - (kb_back_y + kb_hanger_flange);
check(min(kb_gap_front, kb_gap_back) >= 0.5,
      str("hanger flange to bracket lip: front ", kb_gap_front, " mm, back ", kb_gap_back, " mm"));

// ---------- gauge pieces ----------
module gauge_2d() {
    difference() {
        rrect(base_L, base_W, base_R);
        rrect(base_L - 2 * gauge_band, base_W - 2 * gauge_band, 2);
        for (p = used_mount_holes) translate(p) circle(d = m3_clear_d);
    }
}

module corner_piece(sx, sy) {
    linear_extrude(gauge_t) intersection() {
        gauge_2d();
        translate([sx > 0 ? base_L / 2 - gauge_leg[0] : -base_L / 2,
                   sy > 0 ? base_W / 2 - gauge_leg[1] : -base_W / 2])
            square([gauge_leg[0], gauge_leg[1]]);
    }
}

piece = "all";   // "all" (spread out to view), or a corner: [-1|1, -1|1]

// Each corner fits the bed on its own (exported as stl/fit_test_<corner>.stl).
if (piece == "all")
    for (sx = [-1, 1], sy = [-1, 1]) translate([sx * 25, sy * 25, 0]) corner_piece(sx, sy);
else
    corner_piece(piece[0], piece[1]);
