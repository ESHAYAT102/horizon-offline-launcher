fn sky(input: SkyInput) -> vec4<f32> {
    if frame.dimension != 0 {
        return input.color;
    }
    let low = 1.0 - smoothstep(0.0, 0.30, abs(frame.sun_direction.y));
    let toward = max(dot(input.direction, frame.sun_direction), 0.0);
    let halo = pow(toward, 8.0) * low * (1.0 - frame.rain) * 0.70;
    return vec4<f32>(input.color.rgb + vec3<f32>(1.0, 0.43, 0.12) * halo, input.color.a);
}
