#version 300 es
precision highp float;

//uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;

in vec2 fs_Pos;

in vec2 fs_UV;

out vec4 out_Col;

uniform sampler2D u_Texture;


float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5 * x * x / (sigma * sigma)) / sigma;
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
    vec4 color = texture(u_Texture, fs_UV);

    float dofZ = color.a;

    //out_Col = vec4(vec3(dofZ), 1.0);

    out_Col = vec4(color.rgb, 1.0);


    
    //out_Col = vec4(texture(u_Texture, vec2(fract(fs_UV.x + 0.5), fract(fs_UV.y + 0.5))).rgb, 1.0);








    // ShaderFun Gaussian Blur
    
    float horizontalStep = 1.f / u_Dimensions.y;
    float verticalStep = 1.f / u_Dimensions.x;



    vec3 outputColor = vec3(0.f, 0.f, 0.f);

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

    out_Col = vec4(outputColor * ambientIncrease, 1.0);
    

    //out_Col = vec4(u_Dimensions.x, 0.0, 0.0, 1.0);



    //out_Col = vec4(color, 1.0);
}

