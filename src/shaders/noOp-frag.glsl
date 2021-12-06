#version 300 es
precision highp float;

//uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;

uniform float u_Aperture;

in vec2 fs_Pos;

in vec2 fs_UV;

out vec4 out_Col;

uniform sampler2D u_Texture;


float normpdf(float x, float sigma)
{
	return 0.39894*exp(-0.5 * x * x / (sigma * sigma)) / sigma;
}


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
    // Output texture to screen
    vec4 unblurredColor = texture(u_Texture, fs_UV);

    float dofZ = unblurredColor.a;

    //out_Col = vec4(vec3(dofZ), 1.0);

    out_Col = vec4(unblurredColor.rgb, 1.0);


    
    //out_Col = vec4(texture(u_Texture, vec2(fract(fs_UV.x + 0.5), fract(fs_UV.y + 0.5))).rgb, 1.0);


    // ShaderFun Gaussian Blur

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
    




    /*
    // From https://www.shadertoy.com/view/XdfGDH
    const int mSize = 11;
    const int kSize = (mSize - 1) / 2;
    float kernel[mSize];
    vec3 final_color = vec3(0.0);

    //create the 1-D kernel
    float sigma = 100.0;
    float Z = 0.0;
    for (int j = 0; j <= kSize; ++j) 
    {
        kernel[kSize + j] = kernel[kSize - j] = normpdf(float(j), sigma);
    }

    //get the normalization factor (as the gaussian has been clamped)
    for (int j = 0; j < mSize; ++j) 
    {
        Z += kernel[j];
    }
    
    float horizontalStep = 1.f / u_Dimensions.y;
    float verticalStep = 1.f / u_Dimensions.x;

    //read out the texels
    for (int i = -kSize; i <= kSize; ++i) 
    {
        for (int j = -kSize; j <= kSize; ++j) 
        {
            float weight = kernel[kSize + j] * kernel[kSize + i];

            float xUV = fs_UV[0] + float(i) * horizontalStep;

            float yUV = fs_UV[1] + float(j) * verticalStep;

            vec3 colorAtCurrentPixel = vec3(texture(u_Texture, vec2(xUV, yUV)));

            final_color += weight * colorAtCurrentPixel;


        }
    }
    
    final_color /= Z * Z;
    */




    vec3 finalBlurred = outputColor;

    float t = getBias(dofZ, 0.75);

    vec3 dofColor = mix(unblurredColor.rgb, finalBlurred, t);


    // Bias the aperture slider to give more control near blurry side of spectrum
    float blurAmount = getBias((u_Aperture - 1.0) / 21.0, 0.25);

    vec3 interpolatedColor = mix(dofColor, unblurredColor.rgb, blurAmount);


    out_Col = vec4(interpolatedColor, 1.0);

    //out_Col = vec4(vec3(t), 1.0);
}

