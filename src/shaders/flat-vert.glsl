#version 300 es

// Written by Nathan Devlin

// Vertex Shader for SDF shader
// Simply pass info to fragment shader

precision highp float;

// Attributes
in vec4 vs_Pos;
out vec2 fs_Pos;

void main() 
{
  fs_Pos = vs_Pos.xy;
  gl_Position = vs_Pos;
}
