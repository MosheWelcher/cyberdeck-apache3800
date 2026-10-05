#!/usr/bin/env bash
# Render every printable part to stl/ (and preview PNGs to img/).
# Usage: scripts/export.sh            (from the repo root, Git Bash)
#        OPENSCAD=/path/to/openscad scripts/export.sh
#
# Uses an OpenSCAD development build (2024+) with the Manifold engine when
# available — seconds instead of ~35 minutes on the stock 2021.01 release.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -z "${OPENSCAD:-}" ]; then
  nightly=$(ls -d "$LOCALAPPDATA"/Programs/OpenSCAD-Nightly/OpenSCAD-*/openscad.com 2>/dev/null | sort | tail -1 || true)
  for c in "$nightly" "/c/Program Files/OpenSCAD (Nightly)/openscad.com" "/c/Program Files/OpenSCAD/openscad.com"; do
    [ -n "$c" ] && [ -x "$c" ] && { OPENSCAD="$c"; break; }
  done
  [ -z "${OPENSCAD:-}" ] && OPENSCAD=openscad
fi
# Only newer builds have --backend (Manifold); probe so 2021.01 still works.
BACKEND=()
"$OPENSCAD" --help 2>&1 | grep -q -- "--backend" && BACKEND=(--backend=manifold)
echo "Using: $("$OPENSCAD" --version 2>&1) ${BACKEND[*]}"

scad() { "$OPENSCAD" -q "${BACKEND[@]}" "$@"; }
mkdir -p stl img

# Panels: one STL per tile.
for part in lid_panel base_faceplate; do
  "$OPENSCAD" "${BACKEND[@]}" -o "stl/.$part.echo" "parts/$part.scad"
  tiles=$(sed -n 's/.*"TILES \([0-9]*\) \([0-9]*\)".*/\1 \2/p' "stl/.$part.echo" | head -1)
  rm -f "stl/.$part.echo"
  read -r nx ny <<<"$tiles"
  for ((i = 0; i < nx; i++)); do
    for ((j = 0; j < ny; j++)); do
      out="stl/${part}_tile_${i}_${j}.stl"
      echo "-> $out"
      scad -D "piece=[$i,$j]" -o "$out" "parts/$part.scad"
    done
  done
done

# Small parts: one plate each.
for part in lid_bracket screen_retainer; do
  echo "-> stl/$part.stl"
  scad -o "stl/$part.stl" "parts/$part.scad"
done

# Previews
scad --imgsize=1600,1200 --viewall --autocenter --camera=0,0,0,55,0,25,0 -o img/assembly.png assembly.scad
scad --imgsize=1200,900 --camera=0,0,0,35,0,15,900 -o img/lid_panel_tiles.png parts/lid_panel.scad
scad --imgsize=1200,900 --camera=0,0,0,35,0,15,900 -o img/base_faceplate_tiles.png parts/base_faceplate.scad
echo "Done."
