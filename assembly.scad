// Fit-check preview: case opened flat (lid behind the hinge, +Y),
// both panels in place. Open in OpenSCAD and press F5. Not for printing.
include <lib/common.scad>
use <parts/lid_panel.scad>
use <parts/lid_bracket.scad>
use <parts/base_faceplate.scad>

hinge_gap = 40;   // visual spacing between base and opened lid

module cavity(depth) {
    color(c_case) difference() {
        translate([0, 0, -depth]) plate(case_in_l + 8, case_in_w + 8, case_corner_r + 4, depth);
        translate([0, 0, -depth + 3]) plate(case_in_l, case_in_w, case_corner_r, depth);
    }
}

// Base half
cavity(base_depth);
translate([0, 0, -base_panel_drop]) {
    color(c_panel) translate([0, 0, -panel_t]) base_faceplate_whole();
    k400_preview();   // real K400 model if ref/local/k400_plus.stl exists (see config.scad)
}

// Lid, opened 180 degrees about the hinge: interior faces up
translate([0, case_in_w + hinge_gap, 0]) {
    cavity(lid_depth);
    translate([0, 0, -lid_panel_drop - panel_t]) {
        color(c_panel)  lid_panel_whole();
        color(c_screen) screen_dummy();
    }
    // posts at the hole positions, back face to the nearest wall
    color("gray") for (p = lid_mount_holes)
        translate([p[0], p[1], -lid_depth]) rotate(lid_post_rot(p)) lid_post();
}
