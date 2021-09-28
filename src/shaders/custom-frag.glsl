#version 300 es

// Written by Nathan Devlin, based on reference by Adam Mally

// 3D Fractal Brownian Motion Fragment Shader

precision highp float;

uniform vec4 u_OceanColor; // User input color for Ocean

uniform vec4 u_LightColor; // User input color for Light

uniform vec4 u_CameraPos;

// Interpolated values out of the rasterizer
in vec4 fs_Pos;

in vec4 fs_UnalteredPos;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; 


vec3 returnLatitudeAsColor(vec3 p)
{
    float red = 0.0f;
    red += abs(p.y) * 2.0f - 0.5f;

    float green = 2.0;

    float blue = 2.0f;

    return vec3(red, green, blue);
}


// Takes in a position vec3, returns a vec3, to be used below as a color
vec3 noise3D( vec3 p ) 
{
    float val1 = fract(sin((dot(p, vec3(127.1, 311.7, 191.999)))) * 4.5453);

    float val2 = fract(sin((dot(p, vec3(191.999, 127.1, 311.7)))) * 3.5453);

    float val3 = fract(sin((dot(p, vec3(311.7, 191.999, 127.1)))) * 7.5453);

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
vec3 fbm(float x, float y, float z, int octaves) 
{
    vec3 total = vec3(0.f, 0.f, 0.f);

    float persistence = 0.5f;

    for(int i = 1; i <= octaves; i++) 
    {
        float freq = pow(3.f, float(i));
        float amp = pow(persistence, float(i));

        total += interpNoise3D(x * freq, y * freq, z * freq) * amp;
    }
    
    return total;
}

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d)
{
    return a + b * cos( 6.28318 * (c * t + d));
}

void main()
{
        // Material base color (before shading)
        vec4 diffuseColor = u_OceanColor;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

        //diffuseTerm = clamp(diffuseTerm, 0.0f, 1.0f);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   

        vec3 latitudeCol = returnLatitudeAsColor(vec3(fs_Pos[0], fs_Pos[1], fs_Pos[2]));

        
        float surfaceDifference = length(fs_Pos) - length(fs_UnalteredPos);

        float normalizedSurfaceDifference = surfaceDifference * 20.0f;
    
        if(surfaceDifference > 0.001f)
        {
            /*
            diffuseColor = vec4(0.0f, 1.0f, 0.0f, 1.0f);

            if(surfaceDifference < 0.005f)
            {
                diffuseColor = vec4(0.8941, 0.8, 0.2706, 1.0);
            }
            else if(surfaceDifference > 0.04f)
            {
                diffuseColor = vec4(1.0, 2.0, 2.0, 1.0);
            }
            */

            vec3 a = vec3(0.378, 1.008, 0.468);
            vec3 b = vec3(-0.762, 0.228, 0.718);
            vec3 c = vec3(0.78, 0.608, 0.698);
            vec3 d = vec3(0.588, 0.228, 0.178);

            diffuseColor = vec4(vec3(palette(normalizedSurfaceDifference, a, b, c, d)), 1.0f);
        }


        


        if(fs_Pos[1] > 0.85 || fs_Pos[1] < -0.85)
        {
            diffuseColor = vec4(latitudeCol, 1.0f);        
        }

        
        // Lambert shading
        out_Col = vec4(diffuseColor.rgb * lightIntensity, 1.0f);

        // Dark Side of the Planet
        if(diffuseColor == vec4(0.0f, 1.0f, 0.0f, 1.0f) && lightIntensity <= 0.1f)
        {            
            vec3 val = fbm(fs_Pos[0], fs_Pos[1], fs_Pos[2], 8);

            float avg = (val[0] + val[1] + val[2]) / 2.0f;

            avg = avg * avg * avg * avg * avg * avg * avg * avg * avg * avg;

            if(avg > 0.2f)
            {
                avg *= 2.0f;
                out_Col = vec4(avg, avg, 0.0f, 1.0f);
            }
        }
        else
        {
            // Add light color
            diffuseColor *= u_LightColor;

            out_Col = vec4(diffuseColor.rgb * lightIntensity, 1.0f);
        }


        // Blinn Phong Shading only for ocean
        if(surfaceDifference <= 0.001f)
        {
            
            vec4 viewVec = u_CameraPos - fs_Pos;

            vec4 posToLight = fs_LightVec - fs_Pos;

            vec4 surfaceNorm = fs_Nor;

            vec4 H = (viewVec + posToLight) / (length(viewVec) + length(posToLight));

            float intensity =  50.0f; // Relative intensity of highlight

            float sharpness = 50.0f; // How sharp or spread out the highlight is

            float specularIntensity = intensity * max(pow(dot(H, surfaceNorm), sharpness), 0.0f);

            float finalIntensity = lightIntensity + specularIntensity;
            
            // Compute final shaded color
            out_Col = vec4(diffuseColor.rgb * finalIntensity, 1.0f);
        }

        //out_Col = fs_Col;

}

