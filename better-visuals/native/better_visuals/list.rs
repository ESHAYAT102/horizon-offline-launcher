fn better_visuals_list(mods: &mut Vec<crate::game::native_hooks::NativeMod>) {
    mods.push(crate::game::native_hooks::NativeMod {
        id: crate::game::better_visuals_native::ID.into(),
        title: "Horizon Better Visuals 0.1.3".into(),
        description: "Light, subtle bloom, ore highlights and ambient particles".into(),
        keys: Vec::new(),
    });
}
