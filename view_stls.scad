// Viewer for the exported STLs in stl/ (run scripts/export.sh first).
// Open in OpenSCAD and press F5. Tiles import at their real positions,
// so they reassemble into whole panels; set explode > 0 to pull them apart.

explode   = 0;        // mm gap between tiles (try 15)
lid_tiles  = [2, 2];  // [nx, ny] — match the stl/lid_panel_tile_*.stl files
base_tiles = [2, 2];  // [nx, ny] — match the stl/base_faceplate_tile_*.stl files
show_lid      = true;
show_base     = true;
show_brackets = true;
show_clips    = true;
show_hangers  = true;

module tiles(part, n) {
    for (i = [0 : n[0] - 1], j = [0 : n[1] - 1])
        translate([(i - (n[0] - 1) / 2) * explode, (j - (n[1] - 1) / 2) * explode, 0])
            color(((i + j) % 2 == 0) ? [0.25, 0.25, 0.3] : [0.35, 0.35, 0.42])
                import(str("stl/", part, "_tile_", i, "_", j, ".stl"));
}

// Base faceplate in front, lid screen panel behind it (as if the case lay open)
if (show_base) tiles("base_faceplate", base_tiles);
if (show_lid)  translate([0, 300, 0]) tiles("lid_panel", lid_tiles);

// Small parts off to the right
if (show_brackets) color("orange")    translate([230, -60, 0])  import("stl/lid_bracket.stl");
if (show_clips)    color("lightblue") translate([230, 120, 0])  import("stl/screen_retainer.stl");
if (show_hangers)  color("tomato")    translate([230, -200, 0]) import("stl/kb_hanger.stl");
