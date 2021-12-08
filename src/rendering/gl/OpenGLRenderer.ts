
// Basic framework by Adam Mally, additions by Nathan Devlin

// Sets up OpenGL Rendering

import {mat4, vec4, vec3} from 'gl-matrix';
import Drawable from './Drawable';
import Camera from '../../Camera';
import {gl} from '../../globals';
import ShaderProgram from './ShaderProgram';

// In this file, `gl` is accessible because it is imported above
class OpenGLRenderer 
{
  constructor(public canvas: HTMLCanvasElement) 
  {}

  setClearColor(r: number, g: number, b: number, a: number) 
  {
    gl.clearColor(r, g, b, a);
  }

  setSize(width: number, height: number) 
  {
    this.canvas.width = width;
    this.canvas.height = height;
  }

  clear() 
  {
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  }

  render(camera: Camera, 
    prog: ShaderProgram, 
    drawables: Array<Drawable>, 
    robotColorIn: vec4, 
    lightColorIn: vec4, 
    currTick: number, 
    currTime: number,
    lightPos: vec4,
    aoIn: number,
    aperture: number,
    exposure: number,
    gamma: number,
    focusDistance: number,
    focalLength: number,
    SSS_All: number) 
  {
    let model = mat4.create();
    let viewProj = mat4.create();

    mat4.identity(model);
    mat4.multiply(viewProj, camera.projectionMatrix, camera.viewMatrix);
    
    prog.setEyeRefUp(camera.controls.eye, camera.controls.center, camera.controls.up);

    prog.setModelMatrix(model);
    
    prog.setViewProjMatrix(viewProj);
    
    prog.setGeometryColor(robotColorIn);

    prog.setLightColor(lightColorIn);

    prog.setCurrTick(currTick);

    prog.setCurrTime(currTime);

    let cp: vec3 = camera.getEye();
    prog.setCameraPos([cp[0], cp[1], cp[2], 1]);

    prog.setLightPos([lightPos[0], lightPos[1], lightPos[2], 1]);

    prog.setAO(aoIn);

    prog.setAperture(aperture);

    prog.setExposure(exposure);

    prog.setGamma(gamma);

    prog.setSSSall(SSS_All);

    prog.setTexLocation();

    prog.setFocusDistance(focusDistance);

    prog.setFocalLength(focalLength);

    for (let drawable of drawables) 
    {
      prog.draw(drawable);
    }
  }
};

export default OpenGLRenderer;

