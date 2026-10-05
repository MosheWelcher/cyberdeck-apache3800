#!/usr/bin/env python3
"""Dump measurable geometry from a STEP file with no CAD libraries.

How the bracket hole pattern (ref/printables-bracket.md) and the K400 Plus
profile (ref/k400-plus.md) were measured. Reads the STEP text directly:

  python scripts/step_info.py part.step            # products, solids, holes
  python scripts/step_info.py part.step --planes   # + every planar face extent
  python scripts/step_info.py part.step --levels   # + distinct vertex X/Y/Z values

Notes
- Coordinates are each body's own frame. Check the printed assembly transforms
  (ITEM_DEFINED_TRANSFORMATION): identity means bodies are already placed.
- Bounding boxes use VERTEX_POINTs only; plain CARTESIAN_POINTs include
  construction/control points and give misleading extents.
- Cylinder r=2.0 -> Ø4 hole (M3 heat-set insert). Axis tells hole direction.
- STEP plane normals are not guaranteed outward; judge "up" from features
  (e.g. which face the insert holes open onto), not from normals.
"""
import re
import sys


def load(path):
    src = open(path, encoding="utf-8", errors="ignore").read()
    data = src.split("DATA;", 1)[1]
    ents = {}
    for m in re.finditer(r"#(\d+)\s*=\s*(.*?);\s*(?=#\d+\s*=|ENDSEC)", data, re.S):
        ents[int(m.group(1))] = " ".join(m.group(2).split())
    return ents


def refs(s):
    return [int(x) for x in re.findall(r"#(\d+)", s)]


def nums(s):
    return [float(x) for x in re.findall(r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?", s)]


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    ents = load(sys.argv[1])
    flags = set(sys.argv[2:])

    def pt(i):
        s = ents[i]
        inner = s[s.index("(", s.index("(") + 1) + 1:]
        return nums(inner.split(")")[0])

    def reach(start):
        seen, st = set(), [start]
        while st:
            n = st.pop()
            if n in seen or n not in ents:
                continue
            seen.add(n)
            st.extend(refs(ents[n]))
        return seen

    def axis(i):
        r = refs(ents[i])
        return pt(r[0]), (pt(r[1]) if len(r) > 1 else [0, 0, 1])

    def r1(v):
        return [round(c, 2) for c in v]

    unit = [v for v in ents.values() if "LENGTH_UNIT" in v]
    print("units:", unit[0] if unit else "?")
    for k, v in ents.items():
        if v.startswith(("PRODUCT(", "NEXT_ASSEMBLY_USAGE_OCCURRENCE")):
            print(f"#{k} {v[:110]}")
    for k, v in ents.items():
        if v.startswith("ITEM_DEFINED_TRANSFORMATION"):
            a, b = refs(v)[-2:]
            print(f"transform #{k}: {r1(axis(a)[0])},{r1(axis(a)[1])} -> {r1(axis(b)[0])},{r1(axis(b)[1])}")

    for sid, v in ents.items():
        if not v.startswith("MANIFOLD_SOLID_BREP"):
            continue
        R = reach(sid)
        V = [pt(refs(ents[i])[0]) for i in R if ents[i].startswith("VERTEX_POINT")]
        lo = [min(p[a] for p in V) for a in range(3)]
        hi = [max(p[a] for p in V) for a in range(3)]
        print(f"\n== solid #{sid} {v[:40]}  bbox {r1(lo)} .. {r1(hi)}  size {r1([h - l for l, h in zip(lo, hi)])}")
        cyl = set()
        for i in R:
            if ents[i].startswith("CYLINDRICAL_SURFACE"):
                o, z = axis(refs(ents[i])[0])
                cyl.add((round(nums(ents[i].split(",")[-1])[0], 2), tuple(r1(z)), tuple(round(c, 1) for c in o)))
        for c in sorted(cyl):
            print("   cylinder r=%s axis=%s at %s" % c)
        if "--planes" in flags:
            for f in sorted(i for i in R if ents[i].startswith("ADVANCED_FACE")):
                surf = refs(ents[f])[-1]
                if not ents[surf].startswith("PLANE"):
                    continue
                n = axis(refs(ents[surf])[0])[1]
                FV = [pt(refs(ents[i])[0]) for i in reach(f) if ents[i].startswith("VERTEX_POINT")]
                if FV:
                    rng = " ".join(f"{'xyz'[k]} {min(p[k] for p in FV):.1f}..{max(p[k] for p in FV):.1f}" for k in range(3))
                    print(f"   plane n={r1(n)}  {rng}")
        if "--levels" in flags:
            for k in range(3):
                print(f"   {'xyz'[k]} levels:", sorted(set(round(p[k], 1) for p in V)))


if __name__ == "__main__":
    main()
