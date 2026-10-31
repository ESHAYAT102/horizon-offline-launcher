use super::native_hooks::{NativeBlockRim, NativeColoredLight};
use super::Game;
use horizon_client::particles::{ParticleOptions, ParticleType};
use std::cell::Cell;

pub(super) const ID: &str = "horizon_better_visuals";

fn leaf_particle(name: &str) -> Option<ParticleType> {
    match name {
        "minecraft:cherry_leaves" => Some(ParticleType::CherryLeaves),
        "minecraft:pale_oak_leaves" => Some(ParticleType::PaleOakLeaves),
        "minecraft:red_poplar_leaves" => Some(ParticleType::RedPoplarLeaves),
        "minecraft:orange_poplar_leaves" => Some(ParticleType::OrangePoplarLeaves),
        "minecraft:yellow_poplar_leaves" => Some(ParticleType::YellowPoplarLeaves),
        name if name.starts_with("minecraft:") && name.ends_with("_leaves") => Some(ParticleType::TintedLeaves),
        _ => None,
    }
}

pub(super) fn emissive(game: &Game<'_>, layers: &mut Vec<(&'static str, &'static str)>) {
    if !game.native_on(ID) { return; }
    // Static names: no allocations or texture decoding in the frame loop.
    const PAIRS: &[(&str, &str)] = &[
        ("minecraft:block/coal_ore", "horizon_better_visuals:emissive/coal_ore"),
        ("minecraft:block/deepslate_coal_ore", "horizon_better_visuals:emissive/deepslate_coal_ore"),
        ("minecraft:block/iron_ore", "horizon_better_visuals:emissive/iron_ore"),
        ("minecraft:block/deepslate_iron_ore", "horizon_better_visuals:emissive/deepslate_iron_ore"),
        ("minecraft:block/copper_ore", "horizon_better_visuals:emissive/copper_ore"),
        ("minecraft:block/deepslate_copper_ore", "horizon_better_visuals:emissive/deepslate_copper_ore"),
        ("minecraft:block/gold_ore", "horizon_better_visuals:emissive/gold_ore"),
        ("minecraft:block/deepslate_gold_ore", "horizon_better_visuals:emissive/deepslate_gold_ore"),
        ("minecraft:block/redstone_ore", "horizon_better_visuals:emissive/redstone_ore"),
        ("minecraft:block/deepslate_redstone_ore", "horizon_better_visuals:emissive/deepslate_redstone_ore"),
        ("minecraft:block/emerald_ore", "horizon_better_visuals:emissive/emerald_ore"),
        ("minecraft:block/deepslate_emerald_ore", "horizon_better_visuals:emissive/deepslate_emerald_ore"),
        ("minecraft:block/lapis_ore", "horizon_better_visuals:emissive/lapis_ore"),
        ("minecraft:block/deepslate_lapis_ore", "horizon_better_visuals:emissive/deepslate_lapis_ore"),
        ("minecraft:block/diamond_ore", "horizon_better_visuals:emissive/diamond_ore"),
        ("minecraft:block/deepslate_diamond_ore", "horizon_better_visuals:emissive/deepslate_diamond_ore"),
        ("minecraft:block/nether_gold_ore", "horizon_better_visuals:emissive/nether_gold_ore"),
        ("minecraft:block/nether_quartz_ore", "horizon_better_visuals:emissive/nether_quartz_ore"),
    ];
    layers.extend_from_slice(PAIRS);
}

fn color(name: &str) -> Option<u32> {
    match name {
        "minecraft:torch" | "minecraft:wall_torch" | "minecraft:lantern"
        | "minecraft:campfire" | "minecraft:fire" | "minecraft:lava" => Some(0xffa34f),
        "minecraft:soul_torch" | "minecraft:soul_wall_torch" | "minecraft:soul_lantern"
        | "minecraft:soul_campfire" | "minecraft:soul_fire" => Some(0x66bdeb),
        _ => None,
    }
}

fn sources(game: &Game<'_>) -> Vec<([i32; 3], u32)> {
    let Some(p) = game.native_player() else { return Vec::new(); };
    let center = [p.x.floor() as i32, p.y.floor() as i32, p.z.floor() as i32];
    let mut found = Vec::new();
    for dy in -1..=2 {
        for dz in -2..=2 {
            for dx in -2..=2 {
                let at = [center[0] + dx, center[1] + dy, center[2] + dz];
                if let Some(rgb) = game.native_lit_block_name(at).and_then(color) {
                    found.push((at, rgb));
                }
            }
        }
    }
    found.sort_by_key(|(at, _)| {
        (at[0] - center[0]).pow(2) + (at[1] - center[1]).pow(2) + (at[2] - center[2]).pow(2)
    });
    found.truncate(8);
    found
}

pub(super) fn visuals(game: &Game<'_>, _rims: &mut Vec<NativeBlockRim>, lights: &mut Vec<NativeColoredLight>) {
    if !game.native_on(ID) { return; }
    for (pos, rgb) in sources(game) {
        lights.push(NativeColoredLight {
            at: pos.map(|v| f64::from(v) + 0.5), rgb, radius: 6.0, intensity: 0.62,
        });
    }
}

thread_local! { static TICKS: Cell<u64> = const { Cell::new(0) }; }

fn mix(mut x: u64) -> u64 {
    x ^= x >> 30;
    x = x.wrapping_mul(0xbf58_476d_1ce4_e5b9);
    x ^= x >> 27;
    x = x.wrapping_mul(0x94d0_49bb_1331_11eb);
    x ^ (x >> 31)
}

fn block_name<'a>(game: &'a Game<'_>, at: [i32; 3]) -> Option<&'a str> {
    let [x, y, z] = at;
    game.world.chunks.contains_key(&(x.div_euclid(16), z.div_euclid(16)))
        .then(|| game.res.facts().get(game.world.block(x, y, z)).name.as_ref())
}

fn ambient(game: &mut Game<'_>, tick: u64) {
    let Some(player) = game.native_player() else { return; };
    if player.dimension != "minecraft:overworld" { return; }
    let [px, py, pz] = [player.x.floor() as i32, player.y.floor() as i32, player.z.floor() as i32];
    // One overhead leaf probe every four ticks; at most one drifting leaf.
    if tick.is_multiple_of(4) {
        let seed = mix(tick ^ ((px as u32 as u64) << 32) ^ pz as u32 as u64);
        let x = px + (seed % 13) as i32 - 6;
        let z = pz + (mix(seed) % 13) as i32 - 6;
        for y in py + 2..=py + 6 {
            if let Some(ty) = block_name(game, [x, y, z]).and_then(leaf_particle)
                && block_name(game, [x, y - 1, z]) == Some("minecraft:air") {
                let mut options = ParticleOptions::simple(ty);
                if ty == ParticleType::TintedLeaves {
                    let Some(chunk) = game.world.chunks.get(&(x.div_euclid(16), z.div_euclid(16))) else { break; };
                    let foliage = game.res.biomes().get(chunk.biome(x, y, z)).foliage;
                    options.color = [
                        ((foliage >> 16) & 255) as f32 / 255.0,
                        ((foliage >> 8) & 255) as f32 / 255.0,
                        (foliage & 255) as f32 / 255.0,
                        1.0,
                    ];
                }
                game.particles.add(&options,
                    [f64::from(x) + 0.5, f64::from(y) - 0.1, f64::from(z) + 0.5], [0.0; 3]);
                break;
            }
        }
    }
    // A fixed world-grid site, sampled sparsely at dusk. No per-frame scan.
    if tick.is_multiple_of(12) && (11500..=23000).contains(&game.world.day_time.rem_euclid(24000)) {
        let cell = ((tick / 12) % 9) as i32;
        let cx = px.div_euclid(8) + cell % 3 - 1;
        let cz = pz.div_euclid(8) + cell / 3 - 1;
        let seed = mix(((cx as u32 as u64) << 32) | cz as u32 as u64);
        let x = cx * 8 + 1 + (seed % 6) as i32;
        let z = cz * 8 + 1 + (mix(seed) % 6) as i32;
        if (x - px).abs() <= 12 && (z - pz).abs() <= 12 {
            for y in (py - 6..=py + 2).rev() {
                let Some(ground) = block_name(game, [x, y, z]) else { break; };
                if ground == "minecraft:air" { continue; }
                let Some(chunk) = game.world.chunks.get(&(x.div_euclid(16), z.div_euclid(16))) else { break; };
                let biome = game.res.biomes().get(chunk.biome(x, y, z));
                if biome.temperature < 0.35 || biome.temperature > 1.1
                    || block_name(game, [x, y + 1, z]) != Some("minecraft:air")
                    || block_name(game, [x, y + 2, z]) != Some("minecraft:air") { break; }
                let mut options = ParticleOptions::simple(ParticleType::EndRod);
                options.color = [1.0, 0.85, 0.45, 0.7];
                game.particles.add(&options,
                    [f64::from(x) + 0.5, f64::from(y) + 1.6, f64::from(z) + 0.5], [0.0, 0.002, 0.0]);
                break;
            }
        }
    }
    // Water entry for nearby moving mobs; limited to four per tick.
    for mob in game.mobs.iter().filter(|m| !m.removed).take(32) {
        let p = mob.position;
        let q = mob.previous;
        if (p.x as f64 - player.x).abs() > 12.0 || (p.z as f64 - player.z).abs() > 12.0
            || q.y - p.y < 0.18 { continue; }
        let at = [p.x.floor() as i32, p.y.floor() as i32, p.z.floor() as i32];
        if !block_name(game, at).is_some_and(|n| n.contains("water")) { continue; }
        game.particles.add(&ParticleOptions::simple(ParticleType::Splash),
            [f64::from(p.x), f64::from(p.y) + 0.1, f64::from(p.z)], [0.0, 0.08, 0.0]);
        break;
    }
}

pub(super) fn tick(game: &mut Game<'_>) {
    if !game.native_window() || !game.native_on(ID) { return; }
    let now = TICKS.with(|t| { let n = t.get() + 1; t.set(n); n });
    ambient(game, now);
    if !now.is_multiple_of(8) { return; }
    for (pos, rgb) in sources(game) {
        let drift = ((now ^ pos[0] as u32 as u64) % 7) as f64 * 0.025 - 0.075;
        game.native_flame_particle([
            f64::from(pos[0]) + 0.5 + drift,
            f64::from(pos[1]) + 0.65,
            f64::from(pos[2]) + 0.5 - drift,
        ], rgb == 0x66bdeb);
    }
}

#[cfg(test)]
mod tests {
    use super::{color, leaf_particle};
    use horizon_client::particles::ParticleType;
    #[test]
    fn only_intended_sources() {
        assert_eq!(color("minecraft:lantern"), Some(0xffa34f));
        assert_eq!(color("minecraft:soul_lantern"), Some(0x66bdeb));
        assert_eq!(color("minecraft:stone"), None);
    }
    #[test]
    fn ordinary_leaves_are_not_cherry_pink() {
        assert_eq!(leaf_particle("minecraft:oak_leaves"), Some(ParticleType::TintedLeaves));
        assert_eq!(leaf_particle("minecraft:cherry_leaves"), Some(ParticleType::CherryLeaves));
        assert_eq!(leaf_particle("minecraft:pale_oak_leaves"), Some(ParticleType::PaleOakLeaves));
        assert_eq!(leaf_particle("minecraft:orange_poplar_leaves"), Some(ParticleType::OrangePoplarLeaves));
        assert_eq!(leaf_particle("minecraft:stone"), None);
    }
}
