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
    vec4 color = texture(u_Texture, fs_UV);

    float dofZ = color.a;

    out_Col = vec4(vec3(dofZ), 1.0);








    //out_Col = vec4(color, 1.0);
}

