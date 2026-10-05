// Fit-check preview: case opened flat (lid behind the hinge, +Y),
// both panels in place. Open in OpenSCAD and press F5. Not for printing.
include <lib/common.scad>
use <parts/lid_panel.scad>
use <parts/lid_bracket.scad>
use <parts/base_faceplate.scad>
use <parts/kb_hanger.scad>

hinge_gap = 40;   // visual spacing between base and opened lid

module cavity(depth) {
    color(c_case) difference() {
        translate([0, 0, -depth]) plate(case_in_l + 8, case_in_w + 8, case_corner_r + 4, depth);
        translate([0, 0, -depth + 3]) plate(case_in_l, case_in_w, case_corner_r, depth);
    }
}

// K400 Plus stand-in: body to the flat underside, battery hump along the back.
module k400_dummy() {
    top = -kb_top_drop;
    color([0.12, 0.12, 0.12]) {
        translate([kb_offset[0], kb_offset[1], top - kb_floor_depth])
            linear_extrude(kb_floor_depth) rrect(kb_size[0], kb_size[1], 3);
        translate([kb_offset[0], kb_offset[1] + kb_size[1] / 2 - 15, top - kb_hump_depth])
            linear_extrude(kb_hump_depth - kb_floor_depth + 0.01) rrect(337, 26, 3);
    }
    color([0.3, 0.3, 0.3]) translate([kb_offset[0], kb_offset[1], top])   // keys
        linear_extrude(2) translate([-50, 0]) rrect(240, 110, 2);
}

// Hangers in place (profile rotated so the foot points into the opening).
module hangers_in_place() {
    color("orange") for (x = kb_hanger_x) {
        translate([kb_offset[0] + x - kb_hanger_w / 2, kb_front_y, -panel_t])
            rotate([90, 0, 90]) mirror([1, 0, 0]) linear_extrude(kb_hanger_w) kb_hanger_profile(kb_ledge_z[0], kb_hanger_foot[0]);
        translate([kb_offset[0] + x - kb_hanger_w / 2, kb_back_y, -panel_t])
            rotate([90, 0, 90]) linear_extrude(kb_hanger_w) kb_hanger_profile(kb_ledge_z[1], kb_hanger_foot[1]);
    }
}

// Base half
cavity(base_depth);
translate([0, 0, -base_panel_drop]) {
    color(c_panel) translate([0, 0, -panel_t]) base_faceplate_whole();
    // Printables bracket ring under the plate (fit checks: parts/fit_test.scad)
    color([0.2, 0.7, 0.3]) translate([0, 0, -panel_t]) bracket_ring(base_mount_holes);
    k400_dummy();
    hangers_in_place();
}

// Lid, opened 180 degrees about the hinge: interior faces up
translate([0, case_in_w + hinge_gap, 0]) {
    cavity(lid_depth);
    translate([0, 0, -lid_panel_drop - panel_t]) {
        color(c_panel)  lid_panel_whole();
        color(c_screen) screen_dummy();
    }
    bh = lid_depth - lid_panel_drop - panel_t;
    // brackets at the hole positions, long axis along the nearest wall
    color("gray") for (p = lid_mount_holes)
        translate([p[0], p[1], -lid_depth])
            rotate(abs(p[0]) / case_in_l > abs(p[1]) / case_in_w ? 90 : 0)
                translate([-lid_bracket_size[0] / 2, -lid_bracket_size[1] / 2, 0])
                    cube([lid_bracket_size[0], lid_bracket_size[1], bh]);
}
