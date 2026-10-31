fn better_visuals_emissive(
    game: &crate::game::Game<'_>,
    layers: &mut Vec<(&'static str, &'static str)>,
) {
    crate::game::better_visuals_native::emissive(game, layers);
}
