# Horizon Better Visuals

Created with T3Code for ESHAYAT102.

**What changes:** ore mineral pixels glow in darkness (not the stone), nearby
torches and soul lights add warm or blue colour, leaves fall in their tree's
colour, fireflies appear near warm-biome ground at dusk, and a small shader
adds a low-sun halo and glow to bright pixels. Most of these effects are absent
on a sunny title screen or far from their sources; this is not a full lighting
engine or a recreation of Shine. For a quick check, enter a world at night
beside exposed diamond ore and a torch, then set `/time set 12000` to see
the dusk effects. Choose **Better Visuals** under Shader Packs if another
pack was selected.

One original native mod bundle for Horizon 26.3: nearby warm and soul-blue
lighting, mineral-only full-bright pixels on 18 ore textures, a bounded set of
drifting leaves and dusk fireflies, water-entry splashes, and a lightweight
sunset-and-glow shader. No code or art from Shine,
Particular, or the resource packs is used. It is not a 1:1 recreation of the
user's Fabric stack. Biome Haze is not part of this bundle.

Native mods run with your user privileges. Review `native/better_visuals/`
before building. The bundle pins Horizon native visual hook API 9 at
`efc875c37e174ac27cebb712c2449c0fdc17a484` ([PR #4413](https://github.com/horizon-rust/horizon/pull/4413)).

Run `sh native/install.sh` with `HORIZON_HOME` set to your instance folder,
then use the launcher’s **Native mods → Build** after accepting the trust
warning. Installation does not build or run source code. The script includes
one shader pack and a small ore-mask resource pack within the same `.hnmod`.
It picks the shader only when no other shader is selected. Shader packs are
mutually exclusive in Horizon. Ore masks are derived from the player's prepared
Minecraft 26.3 textures, not copied from Emissive Glowing Ores. Uninstall with
`sh native/uninstall.sh`; this leaves the built game and worlds intact.
The single Mods On/Off toggle also pauses Better Visuals' bundled shader when
off; it does not change a different shader pack you selected yourself.

For local packaging: `python3 native/package.py` then set
`BETTER_VISUALS_BUNDLE` to the resulting file when running `native/install.sh`.
The shader pack has one
eight-tap glow pass, with a 1.5 ms GPU budget; ambient particle emission is
limited to one leaf every four ticks and one firefly per sampled site. Measure
the actual GPU time with F3 on your hardware.

The bloom is an approximation, not a clone of Shine's rendering pipeline.
Version 0.1.3 uses tree-matched leaf particles (pink only for cherry, orange
for orange poplar, and biome-tinted for oak), makes the existing glow and local
light easier to see without more shader taps or light sources, and gives this
settings-free mod one full-width On/Off toggle instead of an empty Settings page.
