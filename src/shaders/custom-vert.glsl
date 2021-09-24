#version 300 es

// Written by Nathan Devlin, based on reference by Adam Mally

// Vertex Shader to create an organic undulating effect

uniform mat4 u_Model;       // Model matrix

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.

uniform float u_Time;

uniform vec4 u_CameraPos;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. 
out vec4 fs_Col;            // The color of each vertex. 

out vec4 fs_Pos;

out vec4 fs_UnalteredPos;

uniform vec4 u_LightPos;// = vec4(5, 5, 3, 1); //The position of our virtual light


// Takes in spherical coordinates and returns a corresponding vec4 in cartesian coordinates
vec4 convertSphericalToCartesian(vec4 sphericalVecIn)
{
  float r = sphericalVecIn[0];
  float theta = sphericalVecIn[1];
  float phi = sphericalVecIn[2];

  float z = r * sin(phi) * cos(theta);
  float x = r * sin(phi) * sin(theta);
  float y = r * cos(phi);

  return vec4(x, y, z, 0.0);
}

// Takes in cartesian coordinates and returns a correpsonding vector in spherical coordinates
vec4 convertCartesianToSpherical(vec4 cartesianVecIn)
{
    float x = cartesianVecIn[0];
    float y = cartesianVecIn[1];
    float z = cartesianVecIn[2];

    float r = sqrt(x * x + y * y + z * z);

    float theta = atan(x, z);

    float phi = acos(y / sqrt(x * x + y * y + z * z));

    return vec4(r, theta, phi, 0.0f);
}


// Takes in a position vec3, returns a vec3, to be used below as a color
vec3 noise3D( vec3 p ) 
{
    float val1 = fract(sin((dot(p, vec3(127.1, 311.7, 191.999)))) * 43758.5453);

    float val2 = fract(sin((dot(p, vec3(191.999, 127.1, 311.7)))) * 3758.5453);

    float val3 = fract(sin((dot(p, vec3(311.7, 191.999, 127.1)))) * 758.5453);

    return vec3(val1, val2, val3);
}


// Interpolate in 3 dimensions
vec3 interpNoise3D(float x, float y, float z) 
{
    int intX = int(floor(x));
    float fractX = fract(x);
    int intY = int(floor(y));
    float fractY = fract(y);
    int intZ = int(floor(z));
    float fractZ = fract(z);

    vec3 v1 = noise3D(vec3(intX, intY, intZ));
    vec3 v2 = noise3D(vec3(intX + 1, intY, intZ));
    vec3 v3 = noise3D(vec3(intX, intY + 1, intZ));
    vec3 v4 = noise3D(vec3(intX + 1, intY + 1, intZ));

    vec3 v5 = noise3D(vec3(intX, intY, intZ + 1));
    vec3 v6 = noise3D(vec3(intX + 1, intY, intZ + 1));
    vec3 v7 = noise3D(vec3(intX, intY + 1, intZ + 1));
    vec3 v8 = noise3D(vec3(intX + 1, intY + 1, intZ + 1));

    vec3 i1 = mix(v1, v2, fractX);
    vec3 i2 = mix(v3, v4, fractX);

    vec3 i3 = mix(i1, i2, fractY);

    vec3 i4 = mix(v5, v6, fractX);
    vec3 i5 = mix(v7, v8, fractX);

    vec3 i6 = mix(i4, i5, fractY);

    vec3 i7 = mix(i3, i6, fractZ);

    return i7;
}


// 3D Fractal Brownian Motion
vec3 fbm(float x, float y, float z) 
{
    vec3 total = vec3(0.f, 0.f, 0.f);

    float persistence = 0.5f;
    int octaves = 8;

    for(int i = 1; i <= octaves; i++) 
    {
        float freq = pow(2.f, float(i));
        float amp = pow(persistence, float(i));

        total += interpNoise3D(x * freq, y * freq, z * freq) * amp;
    }
    
    return total;
}


float calculateNoiseOffset(vec4 worldPos)
{
// Add fbm noise
    vec3 fbmVal = fbm(worldPos[0], worldPos[1], worldPos[2]);

    vec4 originalNormal = worldPos;
    originalNormal[3] = 0.0f;

    float multiplier = 0.0f;

    float height = fbmVal[0] * 1.25f;

    height *= (1.0f + abs(vs_Pos[1]) / 3.0f);

    height = (1.0f + height) * height - 1.0f;

    if(height > 0.001f)
    {
        height /= 50.0f;
        multiplier = (1.0f + height) * (1.0f + height) * (1.0f + height) * (1.0f + height) - 1.0f;
    }
    else
    {
        multiplier = -0.001f;
    }

    return 3.0f * multiplier;
}



void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. 

    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = u_LightPos - modelposition;  // Compute the direction in which the light source lies

    vec4 worldPos = modelposition;

    vec4 originalNormal = worldPos;
    originalNormal[3] = 0.0f;


    float multiplier = calculateNoiseOffset(worldPos) * 1.0f;



    // Creates vacillating effect from Original
    /*
    float toAdd = float(u_Time) / 20.0;

    preFinal += sin(preFinal + toAdd) / 20.0;

    fs_Pos = preFinal;
    */

    


    vec4 alteredPos = worldPos + originalNormal * multiplier;
    

    gl_Position = u_ViewProj * alteredPos; // Final positions of the geometry's vertices

    fs_Pos = alteredPos;

    fs_UnalteredPos = worldPos;



    /*
    // Faster attempt to calculate new normals
    float delta = 0.4f;


    vec4 normalSpherical = convertCartesianToSpherical(vs_Pos);

    vec4 normalJitterSpherical1 = normalSpherical + vec4(0, delta, 0, 1);
    vec4 normalJitterSpherical2 = normalSpherical + vec4(0, -delta, 0, 1);

    vec4 normalJitterSpherical3 = normalSpherical + vec4(0, 0, delta, 1);
    vec4 normalJitterSpherical4 = normalSpherical + vec4(0, 0, -delta, 1);

    vec4 normalJitteredCartesian1 = convertSphericalToCartesian(normalJitterSpherical1);
    vec4 normalJitteredCartesian2 = convertSphericalToCartesian(normalJitterSpherical2);
    
    vec4 normalJitteredCartesian3 = convertSphericalToCartesian(normalJitterSpherical3);
    vec4 normalJitteredCartesian4 = convertSphericalToCartesian(normalJitterSpherical4);


    vec4 faceTangent1 = normalize(normalJitteredCartesian1 - normalJitteredCartesian2);

    vec3 faceBitangent1 = normalize(cross(vec3(faceTangent1), vec3(normalJitteredCartesian1)));

    vec3 newNormal1 = -normalize(cross(vec3(faceTangent1), faceBitangent1));


    vec4 faceTangent2 = normalize(normalJitteredCartesian3 - normalJitteredCartesian4);

    vec3 faceBitangent2 = normalize(cross(vec3(faceTangent2), vec3(normalJitteredCartesian3)));

    vec3 newNormal2 = -normalize(cross(vec3(faceTangent2), faceBitangent2));

    fs_Nor = normalize((vec4(newNormal1, 0) + vec4(newNormal2, 0)));
    */


    /*
    vec4 sampleVec1 = normalize(fs_Pos + vec4(delta, 0, 0, 1));
    vec4 sampleVec2 = normalize(fs_Pos + vec4(-delta, 0, 0, 1));

    float sampleHeight1 = calculateNoiseOffset(sampleVec1);
    float sampleHeight2 = calculateNoiseOffset(sampleVec2);

    sampleVec1 *= sampleHeight1;
    sampleVec2 *= sampleHeight2;


    vec4 faceTangent1 = normalize(sampleVec2 - sampleVec1);

    vec3 faceBitangent1 = normalize(cross(vec3(faceTangent1), vec3(sampleVec2)));

    vec3 newNormal1 = normalize(cross(vec3(faceTangent1), faceBitangent1));

    
    vec4 sampleVec3 = normalize(fs_Pos + vec4(0, delta, 0, 1));
    vec4 sampleVec4 = normalize(fs_Pos + vec4(0, -delta, 0, 1));

    float sampleHeight3 = calculateNoiseOffset(sampleVec3);
    float sampleHeight4 = calculateNoiseOffset(sampleVec4);

    sampleVec3 *= sampleHeight3;
    sampleVec4 *= sampleHeight4;

    vec4 faceTangent2 = normalize(sampleVec3 - sampleVec4);

    vec3 faceBitangent2 = normalize(cross(vec3(faceTangent2), vec3(sampleVec3)));

    vec3 newNormal2 = normalize(cross(vec3(faceTangent2), faceBitangent2));

    
    vec4 sampleVec5 = normalize(fs_Pos + vec4(0, 0, delta, 1));
    vec4 sampleVec6 = normalize(fs_Pos + vec4(0, 0, -delta, 1));

    float sampleHeight5 = calculateNoiseOffset(sampleVec5);
    float sampleHeight6 = calculateNoiseOffset(sampleVec5);

    sampleVec5 *= sampleHeight5;
    sampleVec6 *= sampleHeight6;

    vec4 faceTangent3 = normalize(sampleVec5 - sampleVec6);

    vec3 faceBitangent3 = normalize(cross(vec3(faceTangent3), vec3(sampleVec5)));

    vec3 newNormal3 = normalize(cross(vec3(faceTangent3), faceBitangent3));
    */


    //fs_Nor = normalize((vec4(newNormal1, 0) + vec4(newNormal2, 0) + vec4(newNormal3, 0) + vs_Nor) / 4.0f);
    //fs_Nor = normalize((vec4(newNormal1, 0) + vs_Nor) / 2.0f);


    
    // Calculate new normals

    
    float delta = 0.005f;

    vec4 normalSpherical = convertCartesianToSpherical(vs_Nor);

    vec4 normalJitterSpherical1 = normalSpherical + vec4(0, delta, 0, 0);
    vec4 normalJitterSpherical2 = normalSpherical + vec4(0, -delta, 0, 0);

    vec4 normalJitterSpherical3 = normalSpherical + vec4(0, 0, delta, 0);
    vec4 normalJitterSpherical4 = normalSpherical + vec4(0, 0, -delta, 0);

    vec4 normalJitteredCartesian1 = convertSphericalToCartesian(normalJitterSpherical1);
    vec4 normalJitteredCartesian2 = convertSphericalToCartesian(normalJitterSpherical2);
    
    vec4 normalJitteredCartesian3 = convertSphericalToCartesian(normalJitterSpherical3);
    vec4 normalJitteredCartesian4 = convertSphericalToCartesian(normalJitterSpherical4);


    float xDiff = calculateNoiseOffset(normalJitteredCartesian1) - calculateNoiseOffset(normalJitteredCartesian2);
    //xDiff /= 2.0f;
    
    float yDiff = calculateNoiseOffset(normalJitteredCartesian3) - calculateNoiseOffset(normalJitteredCartesian4);
    //zDiff /= 2.0f;

    xDiff *= 2.0f;
    yDiff *= 2.0f;

    float z = sqrt(1.0 - xDiff * xDiff - yDiff * yDiff);
    
    vec4 localNormal = normalize(vec4(xDiff, yDiff, z, 0));

    // Create tangent space to normal space matrix
    vec3 tangent = -cross(vec3(0, 1, 0), vec3(localNormal));
    vec3 bitangent = cross(vec3(fs_Nor), tangent);

    
    mat4 tangentToWorld = mat4(tangent.x, bitangent.x, fs_Nor.x, 0,
                             tangent.y, bitangent.y, fs_Nor.y, 0,
                             tangent.z, bitangent.z, fs_Nor.z, 0,
                             0,         0,           0,        1);
    

    vec4 transformedNormal = tangentToWorld * localNormal;

    transformedNormal[0] = vs_Nor[0];


    fs_Nor = transformedNormal;
    


    vec4 testVal = fs_Nor;
    testVal = vec4(vec3(testVal) - vec3(normalize(vs_Nor)), 1.0f);
    testVal[0] = (testVal[0] + 1.0f) / 2.0f;
    fs_Col = testVal * 1.0f;
    




    //gl_Position = u_ViewProj * alteredPos; // Final positions of the geometry's vertices

}

