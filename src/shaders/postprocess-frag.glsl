#version 300 es

// Written by Nathan Devlin

// Post-processing pass; takes in computed color, adds blurring etc.

precision highp float;

// Uniforms

uniform vec2 u_Dimensions;

uniform float u_Aperture;

uniform sampler2D u_Texture;

// Attributes

in vec2 fs_Pos;

in vec2 fs_UV;

out vec4 out_Col;


// Utility Functions

float getBias(float t, float biasAmount)
{
  return (t / ((((1.0 / biasAmount) - 2.0) * (1.0 - t)) + 1.0));
}


float getGain(float t, float gainAmount)
{
  if(t < 0.5)
  {
    return getBias(t * 2.0, gainAmount) / 2.0;
  }
  else
  {
    return getBias(t * 2.0 - 1.0, 1.0 - gainAmount) / 2.0 + 0.5;
  }
}

// Pre-computed kernal for Gaussian blur
const float kernal[121] = float[121]
(0.006849, 0.007239, 0.007559, 0.007795, 0.007941, 0.00799,  0.007941, 0.007795, 0.007559, 0.007239, 0.006849,
 0.007239, 0.007653, 0.00799,  0.00824,  0.008394, 0.008446, 0.008394, 0.00824,  0.00799,  0.007653, 0.007239,
 0.007559, 0.00799,  0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604, 0.008342, 0.00799,  0.007559,
 0.007795, 0.00824,  0.008604, 0.008873, 0.009039, 0.009095, 0.009039, 0.008873, 0.008604, 0.00824,  0.007795,
 0.007941, 0.008394, 0.008764, 0.009039, 0.009208, 0.009265, 0.009208, 0.009039, 0.008764, 0.008394, 0.007941,
 0.00799,  0.008446, 0.008819, 0.009095, 0.009265, 0.009322, 0.009265, 0.009095, 0.008819, 0.008446, 0.00799,
 0.007941, 0.008394, 0.008764, 0.009039, 0.009208, 0.009265, 0.009208, 0.009039, 0.008764, 0.008394, 0.007941,
 0.007795, 0.00824,  0.008604, 0.008873, 0.009039, 0.009095, 0.009039, 0.008873, 0.008604, 0.00824,  0.007795,
 0.007559, 0.00799,  0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604, 0.008342, 0.00799,  0.007559,
 0.007239, 0.007653, 0.00799,  0.00824,  0.008394, 0.008446, 0.008394, 0.00824,  0.00799,  0.007653, 0.007239,
 0.006849, 0.007239, 0.007559, 0.007795, 0.007941, 0.00799,  0.007941, 0.007795, 0.007559, 0.007239, 0.006849);

void main()
{
    // Unaltered Texture
    vec4 unblurredColor = texture(u_Texture, fs_UV);

    float dofZ = unblurredColor.a;

    // Gaussian Blur

    vec3 outputColor = vec3(0.f, 0.f, 0.f);
    
    float horizontalStep = 1.f / u_Dimensions.y;
    float verticalStep = 1.f / u_Dimensions.x;

    for(int r = -5; r < 5; r++)
    {
        for(int c = -5; c < 5; c++)
        {
            float weight = kernal[(r + 5) * 11 + (c + 5)];

            float xUV = fs_UV[0] + float(c) * horizontalStep;

            float yUV = fs_UV[1] + float(r) * verticalStep;

            vec3 colorAtCurrentPixel = vec3(texture(u_Texture, vec2(xUV, yUV)));

            outputColor += weight * colorAtCurrentPixel;
        }
    }

    float ambientIncrease = 1.2f; // To make the image brighter

    outputColor *= ambientIncrease;

    vec3 finalBlurred = outputColor;

    float t = getBias(dofZ, 0.75);

    vec3 dofColor = mix(unblurredColor.rgb, finalBlurred, t);

    // Bias the aperture slider to give more control near blurry side of spectrum
    float blurAmount = getBias((u_Aperture - 1.0) / 21.0, 0.25);

    vec3 interpolatedColor = mix(dofColor, unblurredColor.rgb, blurAmount);

    out_Col = vec4(interpolatedColor, 1.0);
}

