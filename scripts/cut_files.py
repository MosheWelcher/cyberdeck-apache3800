#!/usr/bin/env python3
"""Turn OpenSCAD's 2D DXF into files cutting services accept.

  python scripts/cut_files.py raw.dxf out.dxf [out.step thickness_mm]

OpenSCAD's DXF claims to be R10 (AC1006) but contains LWPOLYLINE entities
(R14+) and no units, and strict quoting tools (e.g. SendCutSend) reject it.
This reads its closed outlines and writes:
  - out.dxf:  plain R12 DXF, closed POLYLINEs, millimetres
  - out.step: the outline extruded to thickness_mm (needs gmsh:
              pip install --user gmsh); skipped if gmsh is missing
Geometry is not changed — the outlines are copied point for point.
"""
import sys


def read_loops(path):
    """Closed outlines from OpenSCAD's DXF: one list of (x, y) per LWPOLYLINE."""
    lines = open(path, encoding="utf-8").read().splitlines()
    pairs = [(lines[i].strip(), lines[i + 1].strip()) for i in range(0, len(lines) - 1, 2)]
    loops, cur, x = [], None, None
    for code, value in pairs:
        if code == "0":
            if cur:
                loops.append(cur)
            cur = [] if value == "LWPOLYLINE" else None
        elif cur is not None and code == "10":
            x = float(value)
        elif cur is not None and code == "20":
            cur.append((x, float(value)))
    if cur:
        loops.append(cur)
    return loops


def area(loop):
    return 0.5 * sum(x0 * y1 - x1 * y0 for (x0, y0), (x1, y1) in zip(loop, loop[1:] + loop[:1]))


def write_dxf(loops, path):
    xs = [p[0] for l in loops for p in l]
    ys = [p[1] for l in loops for p in l]
    out = ["0", "SECTION", "2", "HEADER",
           "9", "$ACADVER", "1", "AC1009",
           "9", "$INSUNITS", "70", "4",          # 4 = millimetres
           "9", "$MEASUREMENT", "70", "1",       # metric
           "9", "$EXTMIN", "10", f"{min(xs):.4f}", "20", f"{min(ys):.4f}",
           "9", "$EXTMAX", "10", f"{max(xs):.4f}", "20", f"{max(ys):.4f}",
           "0", "ENDSEC",
           "0", "SECTION", "2", "ENTITIES"]
    for loop in loops:
        out += ["0", "POLYLINE", "8", "0", "66", "1", "70", "1"]   # closed
        for x, y in loop:
            out += ["0", "VERTEX", "8", "0", "10", f"{x:.4f}", "20", f"{y:.4f}"]
        out += ["0", "SEQEND", "8", "0"]
    out += ["0", "ENDSEC", "0", "EOF"]
    with open(path, "w", newline="\r\n") as f:
        f.write("\n".join(out) + "\n")


def write_step(loops, path, t):
    import gmsh
    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 0)
    occ = gmsh.model.occ
    curve_loops = []
    for loop in sorted(loops, key=lambda l: -abs(area(l))):   # outer outline first
        pts = [occ.addPoint(x, y, 0) for x, y in loop]
        segs = [occ.addLine(a, b) for a, b in zip(pts, pts[1:] + pts[:1])]
        curve_loops.append(occ.addCurveLoop(segs))
    face = occ.addPlaneSurface(curve_loops)                  # first loop = outer, rest = holes
    occ.extrude([(2, face)], 0, 0, t)
    occ.synchronize()
    gmsh.write(path)
    gmsh.finalize()


def main():
    if len(sys.argv) not in (3, 5):
        sys.exit(__doc__)
    loops = read_loops(sys.argv[1])
    if not loops:
        sys.exit("no LWPOLYLINE outlines found in " + sys.argv[1])
    write_dxf(loops, sys.argv[2])
    print(f"{sys.argv[2]}: {len(loops)} closed outlines")
    if len(sys.argv) == 5:
        try:
            write_step(loops, sys.argv[3], float(sys.argv[4]))
            print(f"{sys.argv[3]}: {sys.argv[4]} mm thick")
        except ImportError:
            print("gmsh not installed (pip install --user gmsh) - STEP skipped")


if __name__ == "__main__":
    main()
