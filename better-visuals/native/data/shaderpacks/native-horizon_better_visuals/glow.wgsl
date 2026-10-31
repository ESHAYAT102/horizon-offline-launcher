fn post(input: PostInput) -> vec4<f32> {
    // Eight samples, one pass. The sky cannot make the whole screen bloom.
    let pixel = 1.0 / frame.resolution;
    var halo = vec3<f32>(0.0);
    for (var i = 0u; i < 8u; i++) {
        let a = f32(i) * 0.7853982;
        let uv = input.uv + vec2<f32>(cos(a), sin(a)) * pixel * 6.0;
        let c = textureSampleLevel(previous, linear_sampler, uv, 0.0).rgb;
        let visible = select(1.0, 0.18, depth_at(uv) == 0.0);
        halo += c * smoothstep(0.72, 0.95, dot(c, vec3<f32>(0.2126, 0.7152, 0.0722))) * visible;
    }
    return vec4<f32>(min(input.color.rgb + halo * 0.11, vec3<f32>(1.0)), input.color.a);
}
