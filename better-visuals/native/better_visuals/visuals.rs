fn better_visuals(
    game: &crate::game::Game<'_>,
    rims: &mut Vec<crate::game::native_hooks::NativeBlockRim>,
    lights: &mut Vec<crate::game::native_hooks::NativeColoredLight>,
) {
    crate::game::better_visuals_native::visuals(game, rims, lights);
}
