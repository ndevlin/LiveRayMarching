
// Original code by Adam Mally, additions by Nathan Devlin

import {vec3, vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Cube from './geometry/Cube';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 4,
  'Load Scene': loadScene, // A function pointer, essentially
};

// Controller that allows user color input
const colorObject = 
{
  actualColor: [ 255, 0, 0 ], // RGB array
};

let icosphere: Icosphere;

let square: Square;

let cube: Cube;

let prevTesselations: number = 5;

// Used as a clock
let currTick: number = 0.0;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();

  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();

  // Cube constructor takes in object origin
  cube = new Cube(vec3.fromValues(1, 1, 1));
  cube.create();
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
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');

  // Color control; RGB input
  gui.addColor(colorObject, 'actualColor');


  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);

  renderer.setClearColor(0.2, 0.2, 0.2, 1);

  gl.enable(gl.DEPTH_TEST);

  // Standard lambert shader
  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  // Noise-based vertex and fragment shaders
  const custom = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/custom-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/custom-frag.glsl')),
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
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }

    // Render with lambert shader
    /*
    renderer.render(camera, lambert, [
      icosphere,
      cube,
    ],
    // Divide by 256 to convert from web RGB to shader 0-1 values
    vec4.fromValues(colorObject.actualColor[0] / 256.0, colorObject.actualColor[1] / 256.0, colorObject.actualColor[2] / 256.0, 1),
    currTick
    );
    */

    // Render with custom noise-based shader
    renderer.render(camera, custom, [icosphere, cube],
    // Divide by 256 to convert from web RGB to shader 0-1 values
    vec4.fromValues(colorObject.actualColor[0] / 256.0, colorObject.actualColor[1] / 256.0, colorObject.actualColor[2] / 256.0, 1),
    currTick
    );
    
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();

