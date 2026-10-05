#!/usr/bin/env bash
# Render every printable part to stl/ (and preview PNGs to img/).
# Usage: scripts/export.sh            (from the repo root, Git Bash)
#        OPENSCAD=/path/to/openscad scripts/export.sh
set -euo pipefail
cd "$(dirname "$0")/.."

OPENSCAD="${OPENSCAD:-/c/Program Files/OpenSCAD/openscad.com}"
command -v openscad >/dev/null 2>&1 && [ ! -x "$OPENSCAD" ] && OPENSCAD=openscad
mkdir -p stl img

# Panels: one STL per tile.
for part in lid_panel base_faceplate; do
  "$OPENSCAD" -o "stl/.$part.echo" "parts/$part.scad"
  tiles=$(sed -n 's/.*"TILES \([0-9]*\) \([0-9]*\)".*/\1 \2/p' "stl/.$part.echo" | head -1)
  rm -f "stl/.$part.echo"
  read -r nx ny <<<"$tiles"
  for ((i = 0; i < nx; i++)); do
    for ((j = 0; j < ny; j++)); do
      out="stl/${part}_tile_${i}_${j}.stl"
      echo "-> $out"
      "$OPENSCAD" -q -D "piece=[$i,$j]" -o "$out" "parts/$part.scad"
    done
  done
done

# Small parts: one plate each.
for part in lid_bracket screen_retainer; do
  echo "-> stl/$part.stl"
  "$OPENSCAD" -q -o "stl/$part.stl" "parts/$part.scad"
done

# Previews
"$OPENSCAD" -q --imgsize=1600,1200 --viewall --autocenter --camera=0,0,0,55,0,25,0 -o img/assembly.png assembly.scad
"$OPENSCAD" -q --imgsize=1200,900 --camera=0,0,0,35,0,15,900 -o img/lid_panel_tiles.png parts/lid_panel.scad
"$OPENSCAD" -q --imgsize=1200,900 --camera=0,0,0,35,0,15,900 -o img/base_faceplate_tiles.png parts/base_faceplate.scad
echo "Done."
