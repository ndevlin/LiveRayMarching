#version 300 es

// Written by Nathan Devlin

// Post-processing vertex shader
// Simply passes info to fragment shader

precision highp float;

// Attributes

in vec4 vs_Pos;

in vec2 vs_UV;

out vec2 fs_Pos;
out vec2 fs_UV;

void main() 
{
  fs_Pos = vs_Pos.xy;
  fs_UV = vs_UV;
  gl_Position = vs_Pos;
}

