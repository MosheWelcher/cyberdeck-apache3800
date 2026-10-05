// =====================================================================
//  Apache 3800 Cyberdeck — single source of truth for every dimension.
//  Edit values HERE, never inside parts/*.scad.
//  Values tagged MEASURE are best-known defaults: verify with calipers /
//  radius gauges against YOUR case and parts before printing.
//  Units: millimetres. Origin: centre of the case opening, at the rim.
// =====================================================================

$fn = 48;

// ---------------------------------------------------------------------
//  Case (Harbor Freight Apache 3800, item 63927)
// ---------------------------------------------------------------------
case_in_l     = 383;   // inside length at rim (spec 15.063")
case_in_w     = 271;   // inside width at rim  (spec 10.688")
lid_depth     = 44;    // inside lid depth     (spec 1.75")
base_depth    = 108;   // inside base depth    (spec 4.25")
case_corner_r = 17;    // inside corner radius (from Printables bracket STEP: R17)
panel_gap     = 1.0;   // clearance per side, panel edge -> case wall

// ---------------------------------------------------------------------
//  Printer — panels larger than this are split into lap-jointed tiles
// ---------------------------------------------------------------------
bed             = [256, 256]; // usable bed X, Y
bed_margin      = 12;         // keep-out per axis (includes lap overlap)
lap_w           = 20;         // width of the lap-joint band at each seam
seam_hole_pitch = 60;         // target spacing of M3 screws along each seam
seam_edge_inset = 11;         // outermost seam screw, from the panel edge

// ---------------------------------------------------------------------
//  Fasteners (M3 throughout)
// ---------------------------------------------------------------------
m3_clear_d      = 3.4;
m3_csk_d        = 6.6;   // 90-degree countersink head diameter
m3_insert_d     = 4.0;   // heat-set insert hole (M3 x 5.7 typical)
m3_insert_depth = 6;
m3_nut_af       = 5.5;   // hex nut across flats (seam joints)

// ---------------------------------------------------------------------
//  Panels (shared)
// ---------------------------------------------------------------------
panel_t = 6;   // faceplate thickness (lid + base); front/back halves (3 + 3) form the lap joint

// ---------------------------------------------------------------------
//  LID — screen panel
// ---------------------------------------------------------------------
lid_panel_drop  = 6;    // MEASURE front face of panel below lid rim (clear gasket lip)
lid_draft_inset = 0;    // extra shrink per side if walls taper at that depth
lid_split_x = "auto";   // "auto" or list of seam X positions, e.g. [0] or []
lid_split_y = "auto";   // "auto" or list of seam Y positions

// Screen choice: one of the preset names below.
screen = "travel15.6";
// [module_w, module_h, module_t, active_w, active_h, active_off_x, active_off_y]
// active_off = active-area centre relative to module centre, viewed from front.
// ALL PRESETS ARE APPROXIMATE — measure your panel; driver boards vary.
screen_presets = [
  ["7",      [164.9, 100.0, 5.7, 154.2,  85.9, 0, 0]],   // 1024x600 HDMI kit class
  ["10.1",   [235.0, 143.0, 4.5, 217.0, 135.6, 0, 0]],   // 1280x800 IPS class
  ["13.3",   [300.0, 187.0, 3.5, 293.8, 165.2, 0, 3]],   // 1920x1080 eDP class
  ["15.6",   [359.5, 223.8, 3.2, 344.2, 193.6, 0, 5]],   // NV156FHM class
  // Portable "travel" monitors (whole unit in its own shell, thicker bottom chin
  // pushes the active area up). Typical 15.6" / 14" USB-C units — MEASURE yours.
  ["travel15.6", [357.0, 223.0, 9.0, 344.2, 193.6, 0, 8]],
  ["travel14",   [318.0, 200.0, 9.0, 309.4, 173.9, 0, 7]],
  ["custom", [200.0, 120.0, 4.0, 190.0, 110.0, 0, 0]]
];
screen_offset     = [0, 0];  // module centre relative to panel centre
window_margin     = 0.5;     // window larger than active area, per side
window_chamfer    = 2.0;     // 45-degree bevel on the viewing side
screen_shim       = 0.5;     // foam/tape between glass and panel back
// Retainer bosses + clips that clamp the screen to the panel back
boss_d            = 8;
bosses_long_side  = 2;       // per top/bottom edge
bosses_short_side = 2;       // per left/right edge (2 keeps y=0 free for the seam)
clip_w            = 12;
clip_t            = 2.5;
clip_overlap      = 4;       // how far each clip reaches over the screen edge

// Lid brackets: stand on the lid floor, carry M3 inserts for the panel.
lid_bracket_size = [18, 14];   // footprint [along wall, away from wall]
// Panel screw positions relative to panel centre. Default: brackets pushed
// against the walls, hole at bracket centre.
// Kept off x=0 / y=0 (default seams) and clear of the screen bosses.
lid_mount_holes = [
  [-150,  case_in_w/2 - 7], [-50,  case_in_w/2 - 7], [50,  case_in_w/2 - 7], [150,  case_in_w/2 - 7],
  [-150, -case_in_w/2 + 7], [-50, -case_in_w/2 + 7], [50, -case_in_w/2 + 7], [150, -case_in_w/2 + 7],
  [ case_in_l/2 - 7, -90], [ case_in_l/2 - 7, 90],
  [-case_in_l/2 + 7, -90], [-case_in_l/2 + 7, 90]
];

// ---------------------------------------------------------------------
//  BASE — keyboard / ports faceplate on the Printables brackets
//  (printables.com/model/1478000 — M3 inserts in the bracket top edge)
// ---------------------------------------------------------------------
base_panel_drop  = 16;   // MEASURE faceplate top below base rim (keyboard on top stands 14 mm; lid panel is 6 mm below its rim -> ~8 mm clearance closed)
base_plate = [378, 268, 16];   // faceplate outline [x, y, corner_r]: ~1 mm to the wall at bracket height
base_split_x = "auto";
base_split_y = [44];     // behind the keyboard opening (auto would cut through it)
// M3 insert positions of the 4-piece Printables bracket ring, from the case
// centre. Derived from "Apache 3800 Panel Bracket" by JohnS - N0CTL, CC BY 4.0
// (ref/apache-3800-panel-bracket-v8.step). Bracket is 17 mm tall.
// Front = -Y (handle side), Back = +Y (hinge side).
base_mount_holes = [
  [-70, -128], [0, -128], [70, -128],                    // Front Bracket
  [-70,  128], [0,  128], [70,  128],                    // Back Bracket
  [ 140, -128], [ 140, 128], [ 183, -85], [ 183, 0], [ 183, 85],   // +X end bracket
  [-140, -128], [-140, 128], [-183, -85], [-183, 0], [-183, 85]    // -X end bracket
];

// Keyboard: Logitech K400 Plus, sitting flat ON TOP of the plate. Only its
// battery hump drops through a slot (which also locates the keyboard).
// Dims from Logitech spec (354.3 x 139.9 x 23.5) and the GrabCAD model
// "LOGITECH K400 PLUS" by Tomas Stroka (ref/k400-plus.md).
// -Y is the handle (front) side; the battery hump faces +Y (hinge).
kb_size        = [355, 140];   // outline at the widest shell edge
kb_offset      = [0, -40];     // keyboard centre on the plate
kb_floor_depth = 12;           // frame top -> flat underside (rests on the plate)
kb_hump_depth  = 20;           // frame top -> battery-hump underside (hangs 8 mm below the underside)
kb_hump_size   = [345, 33];    // hump footprint where it meets the underside: [width, depth from back edge]
kb_slot_clear  = 1.0;          // per side around the hump
kb_slot_r      = 2;            // slot corner radius
// Preview only: the real K400 model as STL (git-ignored, GrabCAD terms). Create it with
//   python scripts/step_to_stl.py <Downloads>/Logitech_K400_PLUS.stp ref/local/k400_plus.stl
// Path is relative to the repo root; "" = show a simple box stand-in instead.
kb_model_stl       = "ref/local/k400_plus.stl";
kb_model_underside = -2;       // model's own Y of the flat underside (model: X width, Y up, -Z = hump/back)

// Port cutout types: [name, [w, h, corner_r, screw_spacing, screw_d]]
//   h = 0 -> round hole of diameter w.  screw_spacing = 0 -> no screws.
// APPROXIMATE generic panel-mount extensions — measure yours.
port_types = [
  ["usb_a",   [15.5,  8.0, 1.0, 30, 3.2]],
  ["usb_c",   [10.0,  4.5, 1.5, 22, 2.8]],
  ["hdmi",    [16.5,  7.5, 1.0, 30, 3.2]],
  ["rj45",    [16.5, 14.5, 0.5,  0, 0  ]],
  ["round16", [16.2,  0,   0,    0, 0  ]],   // 16 mm switch / GX16
  ["round12", [12.2,  0,   0,    0, 0  ]]    // 12 mm switch / LED
];
// Ports placed on the faceplate: [type, x, y, rotation_deg]
ports = [
  ["usb_a",   -120, 106, 0],
  ["usb_a",    -80, 106, 0],
  ["usb_c",    -45, 106, 0],
  ["hdmi",     -10, 106, 0],
  ["rj45",      30, 106, 0],
  ["round12",  125, 106, 0],
  ["round16",  150, 106, 0]
];
// Vent grilles: [x, y, w, h] regions filled with slots
vents = [ [110, 76, 120, 26] ];   // between the seam lap band and the port row
vent_slot_w     = 2.5;
vent_slot_pitch = 6;

// ---------------------------------------------------------------------
//  Preview colours (assembly only)
// ---------------------------------------------------------------------
c_panel  = [0.18, 0.18, 0.2];
c_screen = [0.05, 0.1, 0.25];
c_case   = [0.9, 0.5, 0.1, 0.2];
