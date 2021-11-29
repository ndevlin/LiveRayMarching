
// Original code by Adam Mally, additions by Nathan Devlin

import {vec3, vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// Utilizes dat.GUI
const controls = 
{
  //tesselations: 6,
  //'Load Scene': loadScene, // A function pointer, essentially
  LightPosTheta: -30,
  LightPosAzimuth: 60,
  FocalLength: 2.0,
  Aperture: 1.0,
  Exposure: 1.0,
  AO_Amount: 3.5,
  SSS_All: 0.0
};

// Controller that allows user color input for ocean
const colorObject = 
{
  // Grey
  RobotColor: [ 180, 180, 180 ], // RGB array
};

// Controller that allows user color input for light color
const lightColor = 
{
  // 5000 Kelvin in RGB; warm lighting
  LightColor: [ 255, 255, 255 ], // RGB array
};

let square: Square;

//let prevTesselations: number = 6;

// Used as a clock
let currTick: number = 0.0;

// Takes in spherical coordinates and returns a corresponding vec4 in cartesian coordinates
function convertSphericalToCartesian(thetaDeg: number, distance: number, azimuthDeg: number) : vec4
{
  let theta: number = thetaDeg * 0.01745329252;
  let azimuth: number = azimuthDeg * 0.01745329252;

  let z: number = distance * Math.sin(azimuth) * Math.cos(theta);
  let x: number = distance * Math.sin(azimuth) * Math.sin(theta);
  let y: number = distance * Math.cos(azimuth);

  return vec4.fromValues(x, y, z, 1.0);
}


function loadScene() 
{
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
}


function main() 
{
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  //gui.add(controls, 'tesselations', 0, 8).step(1);
  //gui.add(controls, 'Load Scene');
  gui.add(controls, 'LightPosTheta', -180, 180).step(1);
  gui.add(controls, 'LightPosAzimuth', 0, 90).step(0.1);
  gui.add(controls, 'FocalLength', 0.1, 10.0).step(0.01);
  gui.add(controls, 'Aperture', 1.0, 22.0).step(0.1);
  gui.add(controls, 'Exposure', 0.0, 22.0).step(0.2);
  gui.add(controls, 'AO_Amount', 0, 5).step(0.1);
  gui.add(controls, 'SSS_All', 0, 1).step(1);

  // Color control for ocean; RGB input
  gui.addColor(colorObject, 'RobotColor');

    // Color control for sun; RGB input
  gui.addColor(lightColor, 'LightColor');

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) 
  {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);

  renderer.setClearColor(164.0 / 255.0, 233.0 / 255.0, 1.0, 1);

  gl.enable(gl.DEPTH_TEST);

  const flat = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/flat-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/flat-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() 
  {
    // Increment the clock
    currTick += 1.0;

    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();

    // Convert Light Position Spherical Coordinates to CartesianCoordinates
    let lightPos: vec4 = convertSphericalToCartesian(controls.LightPosTheta, 
                                                     10, 
                                                     controls.LightPosAzimuth);

    // 1632869657277 = 09/29/2021 7PM
    // deci-seconds since the above time
    let currTime: number = (Date.now() - 1632869657277.0) / 10000.0;

    // Render with custom noise-based shader
    renderer.render(camera, 
    flat, 
    [square], 
    // Divide by 256 to convert from web RGB to shader 0-1 values
    vec4.fromValues(colorObject.RobotColor[0] / 256.0, 
                    colorObject.RobotColor[1] / 256.0, 
                    colorObject.RobotColor[2] / 256.0, 1),
    vec4.fromValues(lightColor.LightColor[0] / 256.0, 
                    lightColor.LightColor[1] / 256.0, 
                    lightColor.LightColor[2] / 256.0, 1),
    currTick,
    currTime,
    lightPos,
    controls.AO_Amount,
    controls.Aperture,
    controls.Exposure,
    controls.FocalLength,
    controls.SSS_All
    );
    
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() 
  {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
    flat.setDimensions(window.innerWidth, window.innerHeight);

  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();
  flat.setDimensions(window.innerWidth, window.innerHeight);


  // Start the render loop
  tick();
}

main();

