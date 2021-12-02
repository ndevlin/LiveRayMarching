#version 300 es
precision highp float;

//uniform vec3 u_Eye, u_Ref, u_Up;
//uniform vec2 u_Dimensions;

//in vec2 fs_Pos;

in vec2 fs_UV;

out vec4 out_Col;

uniform sampler2D u_Texture;

void main()
{
    // Output texture to screen
    vec3 color = texture(u_Texture, fs_UV).rgb;


    if(fract(fs_UV.y * 10.0) > 0.5)
    {
        color = vec3(1.0, 1.0, 1.0) + -color;
    } 


    out_Col = vec4(color, 1.0);
}

