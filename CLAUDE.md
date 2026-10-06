# CLAUDE.md — agent guide for the Apache 3800 cyberdeck CAD

Read this first, then `docs/DESIGN.md` for the full design record (every
decision, measurement source, open question). Together they should be all you
need — do not make the owner re-explain the project.

## What this is

Parametric **OpenSCAD** models for 3D-printed panels that turn a Harbor Freight
**Apache 3800** hard case into a cyberdeck (portable computer):

- **Lid** — a screen panel framing a **15.6" portable "travel" monitor** (the
  owner's: VILVA V156F1, preset `vilva15.6`), held by
  printed clips; the panel screws onto printed posts glued/screwed in the lid.
- **Base** — a faceplate with a **Logitech K400 Plus** keyboard sitting flat on top
  (its battery hump drops through a slot), a port
  row and a vent; it screws onto the 4-piece **Printables "Apache 3800 Panel
  Bracket"** ring (third-party, CC BY 4.0) installed in the case.

Status (2026-10-05): design complete enough to print; nothing printed or
test-fitted yet. Open items are in `docs/DESIGN.md` → *Open questions*.

## The owner

- New to agent workflows — explain what you did in plain words, briefly; no
  jargon dumps. Steers actively and may change requirements mid-task.
- **Config over hardcoding** is a standing rule: every dimension lives in
  `config.scad`; parts never contain magic numbers. They may sell this later.
- Ask (with concrete options + a recommendation) before big or irreversible
  design choices. Make reasonable assumptions on small things and say so.
- Prints on a **Bambu X1C** (256 × 256 bed).
- Hardware dev machine: Windows 11, 8 GB RAM. Fine for OpenSCAD.
- Wants all work on **`main`** (repo is public:
  github.com/MosheWelcher/cyberdeck-apache3800).

## Repo map

| Path | Role |
|---|---|
| `config.scad` | **Single source of truth.** All dimensions, hardware choices, port list, presets. `MEASURE` tags = unverified defaults. |
| `lib/common.scad` | Helpers (`rrect`, `plate`, `m3_csk`), derived values (`base_L/W/R`, keyboard hump-slot position), panel tiling/lap-joint engine, seam-screw placement with keep-outs. Includes `config.scad`. |
| `parts/lid_panel.scad` | Lid screen bezel: window + 45° bevel, retainer bosses (back), countersunk mount holes. Tiled. |
| `parts/screen_retainer.scad` | Flat clips that screw onto the bosses and clamp the monitor. |
| `parts/lid_bracket.scad` | Lid posts (shape: `lid_post()` in lib/common.scad): hug a long wall, sit on the lid floor fillet, M3 inserts top + back face. One per `lid_mount_holes`. |
| `parts/base_faceplate.scad` | Base plate: K400 battery-hump slot, ports, vents, bracket holes. Tiled. |
| `assembly.scad` | Preview only: case opened flat, panels, monitor + K400 stand-ins. |
| `view_stls.scad` | Imports the exported STLs to look at them (`explode` to spread tiles). |
| `scripts/export.sh` | Renders every part → `stl/`, previews → `img/`. |
| `scripts/step_to_stl.py` | STEP → STL via gmsh (`pip install --user gmsh`, installed). Makes `ref/local/k400_plus.stl` for previews. |
| `scripts/step_info.py` | Reads holes/extents/planes out of STEP files without CAD libs (how all third-party dimensions were measured). |
| `ref/local/` | **Ignored by version control** — local-only models (e.g. `k400_plus.stl` made from the GrabCAD STEP). `k400_preview()` in lib/common.scad imports it; box stand-in when `kb_model_stl = ""`. |
| `ref/` | Third-party reference: bracket STEP (CC BY 4.0, redistributable) + notes; K400 notes (its STEP is NOT redistributable); `apache-3800-case.md` = lid measurements from a third-party case CAD (zip in Downloads, not committed; **low trust**). |
| `stl/`, `img/` | Generated. Committed so the owner can print without running anything. |
| `docs/DESIGN.md` | Design record: decisions + why, sources, clearances, open questions, history. |

## Conventions (follow exactly)

- **Units mm. Origin = centre of the case opening.** **−Y = front/handle side,
  +Y = hinge side**, +X = right when facing the deck. Panel models: back face
  z = 0, front/visible face z = `panel_t`.
- **Every part file** = `include <../lib/common.scad>`, then modules, then ONE
  top-level render call at the bottom. `assembly.scad`/others pull modules in
  with `use <parts/x.scad>` (which skips the top-level call). Keep that shape.
- Tiled parts take `piece = "all" | "whole" | [i, j]` and `echo("TILES nx ny")`
  (the export script parses that echo). New large parts: wrap in `tiled(...)`.
- New dimensions → add to `config.scad` with a comment (and `MEASURE` if
  unverified). Derived/shared math → `lib/common.scad`. Never duplicate a
  formula in two parts.
- Seam screws are auto-placed; anything a seam screw must avoid goes in the
  part's keep-out list (`*_keepouts`).
- Third-party geometry must cite its source in a comment and in `ref/`.

## Running things

OpenSCAD: use the **development build** at
`%LOCALAPPDATA%\Programs\OpenSCAD-Nightly\OpenSCAD-<date>-x86-64\openscad.com`
with `--backend=manifold` (full export ≈ 10 s). The stock 2021.01 in
`C:\Program Files\OpenSCAD` works but takes ~35 min — don't use it for exports.

```bash
bash scripts/export.sh                      # all STLs + preview PNGs (auto-finds the dev build)
openscad.com --backend=manifold -D 'piece=[0,1]' -o out.stl parts/lid_panel.scad
openscad.com --backend=manifold -o out.echo parts/base_faceplate.scad   # echoes only (quick check)
openscad.com --backend=manifold --imgsize=1600,1200 --camera=... -o x.png assembly.scad  # look at it
```

Tips: from bash, call `openscad.com` via its full path in one plain command (the
sandbox guard rejects computed command names). Write scratch files to the job
tmp dir, not the repo. Don't edit `scripts/export.sh` while it is running (bash
reads scripts incrementally).

## After any change — verify before you say done

1. `bash scripts/export.sh` → no `WARNING`/`ERROR`, "Done.".
2. Render `assembly.scad` (and a cross-section if you touched heights) to a PNG
   and **look at it**.
3. `git status` — STLs should change only where you meant to change geometry.
4. Update `docs/DESIGN.md` (decision log / numbers / open questions) and the
   README if user-facing behaviour changed.

## Git / publishing

- Default branch **`main`**, remote `origin` = github.com/MosheWelcher/cyberdeck-apache3800 (**public**).
- Repo-local identity is set: `MosheWelcher` /
  `230245226+MosheWelcher@users.noreply.github.com`. **Never commit with the
  owner's personal email** (public repo).
- Background/agent sessions may be forced to edit in a worktree: commit there,
  then from the main checkout `git merge --ff-only <branch>`, `git push origin
  main`, `git worktree remove …`, delete the branch. The owner explicitly wants
  results on `main`.
- Commit trailer: `Co-Authored-By: Claude <model> <noreply@anthropic.com>`.

## Licensing / attribution

- Printables bracket by **JohnS - N0CTL**, **CC BY 4.0** — keep the credit in
  README, `config.scad` and `ref/printables-bracket.md`. Its STEP is in `ref/`.
- K400 Plus model by **Tomáš Stroka** on GrabCAD — measurements only; **do not
  commit the STEP** (GrabCAD terms). The owner keeps a copy in Downloads.
- The repo is **MIT** (`LICENSE`, © MosheWelcher, chosen 2026-10-05). The
  bracket STEP in `ref/` is excluded (CC BY 4.0) — listed in `NOTICE`.
  Keep `LICENSE` as the exact MIT text (GitHub detection); new third-party files get an entry in `NOTICE`.

## Don'ts (learned the hard way)

- Source of truth for the case: the Printables bracket STEP in `ref/` (seen
  installed in real cases) > Harbor Freight spec > the downloaded case CAD.
  Use the CAD only for what the others don't cover, tagged `MEASURE`.

- Don't re-add the bracket "inner-lip" fit checks / fit gauges — the owner had
  them removed on purpose.
- The K400 sits ON TOP of the plate (owner's choice, 2026-10-05) — don't go back
  to a drop-in opening/hangers. Don't start aluminium-plate work (DXF etc.)
  until the owner asks; it's a possible future step only.
- Don't design a deck battery / power-bank bay without asking — it came up but
  was never specified.
- Don't kill OpenSCAD GUI windows (the owner often has one open); only kill
  render processes you started (`-o` in the command line).
- printables.com blocks plain HTTP fetches — use the browser tools. GrabCAD
  downloads need the owner's login — ask them to download into Downloads.
- Windows `curl` may fail TLS revocation checks — add `--ssl-no-revoke`.
- winget's `OpenSCAD.OpenSCAD.Nightly` manifest points at a deleted file (404);
  get dev builds from `https://files.openscad.org/snapshots/` (verify `.sha256`).
