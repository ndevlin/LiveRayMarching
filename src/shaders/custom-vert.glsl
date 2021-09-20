#version 300 es

// Written by Nathan Devlin, based on reference by Adam Mally

// Vertex Shader to create an organic undulating effect

uniform mat4 u_Model;       // Model matrix

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.

uniform float u_Time;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. 
out vec4 fs_Col;            // The color of each vertex. 

out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. 

    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies


    gl_Position = u_ViewProj * modelposition;   // Final positions of the geometry's vertices

    fs_Pos = vs_Pos;

    gl_Position = u_ViewProj * modelposition;

    float toAdd = float(u_Time) / 20.0;

    gl_Position += sin(gl_Position + toAdd) / 20.0;
}

