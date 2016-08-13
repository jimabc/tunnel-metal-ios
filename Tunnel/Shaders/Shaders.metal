//
//  Shaders.metal
//  Tunnel
//
//  Created by James Matteson on 7/9/16.
//  Copyright © 2016 James Matteson. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

static float map(float value, float valueMin, float valueMax, float newMin, float newMax) {
    return ((newMax - newMin) * (value - valueMin) / (valueMax - valueMin)) + newMin;
}

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    texture2d<float, access::read> input [[texture(1)]],
                    constant float &timer [[buffer(0)]],
                    uint2 gid [[thread_position_in_grid]]) {
    
    int screen_width = output.get_width();
    int screen_height = output.get_height();
    
    int texture_width = input.get_width();
    int texture_height = input.get_height();
    
    float2 screen = float2(screen_width, screen_height);
    float2 p = (-1.0 + 2.0 * float2(gid.x, gid.y) / screen.xy); // -1 to 1
    float2 uv;
    
    float r = length(p);
    uv.x = .1 * timer + .1 / r;
    uv.x = map(fmod(uv.x, 1.0), 0.0, 1.0, 0.0, texture_height);
    
    float a = atan2(p.y, p.x);
    uv.y = 1. * a / 3.1416; // -1 to 1
    uv.y = map(uv.y, -1.0, 1.0, 0.0, texture_width);
    
    float4 color = input.read(uint2(uv));
    color *= smoothstep(0.0, .5, r);
    gid.y = screen_height - gid.y;
    output.write(color, gid);
}