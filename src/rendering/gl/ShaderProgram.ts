
// Original code by Adam Mally, additions by Nathan Devlin

import {vec2, vec3, vec4, mat4} from 'gl-matrix';
import Drawable from './Drawable';
import {gl} from '../../globals';

let activeProgram: WebGLProgram = null;

export class Shader 
{
  shader: WebGLShader;

  constructor(type: number, source: string) 
  {
    this.shader = gl.createShader(type);
    gl.shaderSource(this.shader, source);
    gl.compileShader(this.shader);

    if (!gl.getShaderParameter(this.shader, gl.COMPILE_STATUS)) 
    {
      throw gl.getShaderInfoLog(this.shader);
    }
  }
};

class ShaderProgram 
{
  prog: WebGLProgram;

  attrPos: number;
  attrNor: number;
  attrCol: number;

  attrUV: number;


  unifRef: WebGLUniformLocation;
  unifEye: WebGLUniformLocation;
  unifUp: WebGLUniformLocation;
  unifDimensions: WebGLUniformLocation;


  unifModel: WebGLUniformLocation;
  
  unifModelInvTr: WebGLUniformLocation;
  
  unifViewProj: WebGLUniformLocation;

  unifRobotColor: WebGLUniformLocation;

  unifLightColor: WebGLUniformLocation;
  
  unifCameraPos: WebGLUniformLocation;

  unifLightPos: WebGLUniformLocation;

  unifAO: WebGLUniformLocation;

  unifAperture: WebGLUniformLocation;

  unifExposure: WebGLUniformLocation;

  unifSSSall: WebGLUniformLocation;

  unifCurrTick: WebGLUniformLocation;

  unifCurrTime: WebGLUniformLocation;

  unifTexLocation: WebGLUniformLocation;

  unifFocusDistance: WebGLUniformLocation;

  unifFocalLength: WebGLUniformLocation;


  constructor(shaders: Array<Shader>) 
  {
    this.prog = gl.createProgram();

    for (let shader of shaders) 
    {
      gl.attachShader(this.prog, shader.shader);
    }
    gl.linkProgram(this.prog);
    if (!gl.getProgramParameter(this.prog, gl.LINK_STATUS)) 
    {
      throw gl.getProgramInfoLog(this.prog);
    }

    this.attrPos          = gl.getAttribLocation(this.prog, "vs_Pos");
    
    this.unifEye          = gl.getUniformLocation(this.prog, "u_Eye");
    this.unifRef          = gl.getUniformLocation(this.prog, "u_Ref");
    this.unifUp           = gl.getUniformLocation(this.prog, "u_Up");
    this.unifDimensions   = gl.getUniformLocation(this.prog, "u_Dimensions");

    this.attrNor          = gl.getAttribLocation(this.prog, "vs_Nor");
    
    this.attrCol          = gl.getAttribLocation(this.prog, "vs_Col");

    this.attrUV           = gl.getAttribLocation(this.prog, "vs_UV");
    
    this.unifModel        = gl.getUniformLocation(this.prog, "u_Model");
    
    this.unifModelInvTr   = gl.getUniformLocation(this.prog, "u_ModelInvTr");
    
    this.unifViewProj     = gl.getUniformLocation(this.prog, "u_ViewProj");

    this.unifRobotColor   = gl.getUniformLocation(this.prog, "u_RobotColor");

    this.unifLightColor   = gl.getUniformLocation(this.prog, "u_LightColor");

    this.unifCameraPos    = gl.getUniformLocation(this.prog, "u_CameraPos");

    this.unifLightPos     = gl.getUniformLocation(this.prog, "u_LightPos");

    this.unifAO           = gl.getUniformLocation(this.prog, "u_AO");

    this.unifAperture     = gl.getUniformLocation(this.prog, "u_Aperture");

    this.unifExposure     = gl.getUniformLocation(this.prog, "u_Exposure");

    this.unifSSSall       = gl.getUniformLocation(this.prog, "u_SSSall");
    
    this.unifCurrTick     = gl.getUniformLocation(this.prog, "u_CurrTick");

    this.unifCurrTime     = gl.getUniformLocation(this.prog, "u_Time");

    this.unifTexLocation  = gl.getUniformLocation(this.prog, "u_Texture");

    this.unifFocusDistance  = gl.getUniformLocation(this.prog, "u_FocusDistance");

    this.unifFocalLength  = gl.getUniformLocation(this.prog, "u_FocalLength");


  }

  use() 
  {
    if (activeProgram !== this.prog) 
    {
      gl.useProgram(this.prog);
      activeProgram = this.prog;
    }
  }


  setEyeRefUp(eye: vec3, ref: vec3, up: vec3) 
  {
    this.use();
    if(this.unifEye !== -1) 
    {
      gl.uniform3f(this.unifEye, eye[0], eye[1], eye[2]);
    }
    if(this.unifRef !== -1) 
    {
      gl.uniform3f(this.unifRef, ref[0], ref[1], ref[2]);
    }
    if(this.unifUp !== -1) 
    {
      gl.uniform3f(this.unifUp, up[0], up[1], up[2]);
    }
  }

  setDimensions(width: number, height: number) 
  {
    this.use();
    if(this.unifDimensions !== -1) 
    {
      gl.uniform2f(this.unifDimensions, width, height);
    }
  }


  setModelMatrix(model: mat4) 
  {
    this.use();
    if (this.unifModel !== -1) 
    {
      gl.uniformMatrix4fv(this.unifModel, false, model);
    }

    if (this.unifModelInvTr !== -1) 
    {
      let modelinvtr: mat4 = mat4.create();
      mat4.transpose(modelinvtr, model);
      mat4.invert(modelinvtr, modelinvtr);
      gl.uniformMatrix4fv(this.unifModelInvTr, false, modelinvtr);
    }
  }

  setViewProjMatrix(vp: mat4) 
  {
    this.use();
    if (this.unifViewProj !== -1) 
    {
      gl.uniformMatrix4fv(this.unifViewProj, false, vp);
    }
  }

  setGeometryColor(color: vec4) 
  {
    this.use();
    if (this.unifRobotColor !== -1) 
    {
      gl.uniform4fv(this.unifRobotColor, color);
    }
  }

  setLightColor(color: vec4)
  {
    this.use();
    if (this.unifLightColor !== -1) 
    {
      gl.uniform4fv(this.unifLightColor, color);
    }
  }

  setCameraPos(cameraPos: vec4) 
  {
    this.use();
    if (this.unifCameraPos !== -1) 
    {
      gl.uniform4fv(this.unifCameraPos, cameraPos);
    }
  }

  setLightPos(lightPos: vec4)
   {
    this.use();
    if (this.unifLightPos !== -1)
    {
      gl.uniform4fv(this.unifLightPos, lightPos);
    }
  }

  setAO(ao: number)
  {
    this.use();
    if(this.unifAO !== -1)
    {
      gl.uniform1f(this.unifAO, ao);
    }
  }

  setAperture(aperture: number)
  {
    this.use();
    if(this.unifAperture !== -1)
    {
      gl.uniform1f(this.unifAperture, aperture);
    }
  }

  setExposure(exposure: number)
  {
    this.use();
    if(this.unifExposure !== -1)
    {
      gl.uniform1f(this.unifExposure, exposure);
    }
  }

  setSSSall(sssAll: number)
  {
    this.use();
    if(this.unifSSSall !== -1)
    {
      gl.uniform1f(this.unifSSSall, sssAll);
    }
  }

  setCurrTick(currTick: number)
  {
    this.use();
    if(this.unifCurrTick !== -1)
    {
      gl.uniform1f(this.unifCurrTick, currTick);
    }
  }

  setCurrTime(currTime: number)
  {
    this.use();
    if(this.unifCurrTime !== -1)
    {
      gl.uniform1f(this.unifCurrTime, currTime);
    }
  }

  setTexLocation()
  {
    this.use();
    if(this.unifTexLocation !== -1)
    {
      // Use Texture slot 0
      gl.uniform1i(this.unifTexLocation, 0);
    }
  }


  setFocusDistance(focusDistance: number)
  {
    this.use();
    if(this.unifFocusDistance !== -1)
    {
      gl.uniform1f(this.unifFocusDistance, focusDistance);
    }
  }


  setFocalLength(focalLength: number)
  {
    this.use();
    if(this.unifFocalLength !== -1)
    {
      gl.uniform1f(this.unifFocalLength, focalLength);
    }
  }


  draw(d: Drawable) 
  {
    this.use();

    if (this.attrPos != -1 && d.bindPos()) 
    {
      gl.enableVertexAttribArray(this.attrPos);
      gl.vertexAttribPointer(this.attrPos, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrNor != -1 && d.bindNor()) 
    {
      gl.enableVertexAttribArray(this.attrNor);
      gl.vertexAttribPointer(this.attrNor, 4, gl.FLOAT, false, 0, 0);
    }


    if (this.attrUV != -1 && d.bindUV()) 
    {
      gl.enableVertexAttribArray(this.attrUV);
      gl.vertexAttribPointer(this.attrUV, 2, gl.FLOAT, false, 0, 0);
      gl.vertexAttribDivisor(this.attrUV, 0);
    }


    d.bindIdx();
    gl.drawElements(d.drawMode(), d.elemCount(), gl.UNSIGNED_INT, 0);

    if (this.attrPos != -1) gl.disableVertexAttribArray(this.attrPos);
    if (this.attrNor != -1) gl.disableVertexAttribArray(this.attrNor);
  }
};

export default ShaderProgram;

