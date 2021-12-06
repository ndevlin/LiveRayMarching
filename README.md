# Signed Distance Function Ray Marching

## View a live WebGL Demo here!: https://ndevlin.github.io/LiveRayMarching/


![](images/FinalControls.png)


## Results

I was successfully able to implement all of the features I set out to implement. These were:

- Depth Of Field
- Ambient Occlusion
- SubSurface Scattering

I also added a few additional bonus features to the project, including
- Reflections
- Exposure
- Modifiable Focal Length
- Interactive User Controls

I added interactive user controls to enable the user to modify:
- Key Light position
- Key Light Color
- Aperture: Controls the amount of DOF blur
- FocusDistance: How far from the camera the focal plane lies
- Focal Length: Zoom amount: Small Focal length = Wide-Angle, Large Focal length = TelePhoto
- Exposure: Percent above or below 100% default exposure level
- AO Amount: Amount of Ambient Occlusion: More corresponds with greater AO shadowing
- SSS All: By default, the robot's eyes use a Sub-Surface Scattering material, but this control makes everuthing use SSS to visibly show the effect
- Robot Color: Change the albedo color of the robot


### Demo Images:

### Depth of Field

![](images/FocusDemo.png)


### Ambient Occlusion:

![](images/AO_Example.png)


### SubSurface Scattering

![](images/SSS.png)


### Reflections:

![](images/Reflections.png)

### Modifiable Color:

![](images/ColorChange.png)



## Post Mortem

I feel that the project went well overall. I was able to implement all of the features I set out to, and a few additional ones as well. 

The Depth Of Field feature turned out to be a lot more challenging to implement than I had expected since I had to add a whole Post Processing framework to my project. In order to make it work, I added an additional render pass. The original ray-marched scene is first rendered and stored to a texture using a Frame Buffer. Depth information is stored to to the alpha channel since all elements in the scene are opaque. Since the first render pass renders everything on a single-pixel basis, each pixel doesn't have any information about it's neighboring pixels. The second pass allows access to the whole image. The second shader reads from the texture to sample neighboring pixels to accomplish a guassian blur. This is interpolated accoring to the depth information stored in the depth channel between a fully blurry image and an un-blurred image.

The other features were more straightforward to implement, but still had some interesting challenges of their own. The ambient occlusion, subsurface scattering, and reflection functionality each had some hurdles and some elements that needed to be tweaked in order to get them looking nice.

Finally, the user interface I felt was very important to give the user a feeling of interactivity, and to really show of the variety of effects implemented. There was a lot of wiring up to do to make all of that functionality work together interactively.

Overall, I was able to achieve all the tasks I had laid out in my Design Document, which I feel was a solid accomplishment.


## Previous Progress Log:

## Milestone #3:
- Implemented Reflections
- Implemented SubSurface Scattering
- Added ability to change Key Light Position
- Added ability to change color of Key Light
- Added ability to change Robot Albedo
- Added User-modifiable sliders. User can now change:
    - Light Position
    - Focal Length
    - Aperture
    - Exposure (Brightness)
    - Amount of Ambient Occlusion
    - Color of Robot
    - Color of Key Light

I am still having trouble with the Depth of Field because it requires creating a separate framebuffer and then processing again on a second pass, but I will plan to have that working by next week.

Currently, the only material in the scene that uses SSS is the Robot's eyes. I added a toggle to make all materials use SSS so that the viewer can more easily see the effect of this material.

![](images/Reflections.png)

![](images/SSS.png)

![](images/ColorChange.png)


## Milestone #2:

- Make progress on algorithms
- Setting up the project was notably more time consuming than expected and getting things working properly took a solid chunk of time. Additionally going through the algorithms to understand them properly I think also took more time than expected.
- With that being said, I believe I am now set up for success and will be able to move a lot quicker with later parts of the implementation.

- Here is an example of one of my features, the ambient occlusion. It takes up a small amount of framerate, and is quite tunable to look very good and to meet the user's desires.

![](images/AO_Example.png)


## Design Specification:

### Introduction
- I have been very interested in rendering ever since I started learning about computer graphics, but I haven't had the opportunity to learn as much about rendering as I would like! I really enjoyed our HW2 and HW3 assignments, and I would like to build on those to make a polished SDF scene. I will start with my HW3 project as a base. That will allow me to focus on adding new rendering techniques and not spend so much time creating shapes or simply getting something to show up on screen. I will be implementing this as a solo project.

### Goal
- I would like to learn more about rendering techniques while at the same time showing off my graphics, procedural, and rendering knowledge in a polished project. I am hoping to incorporate some more advanced techniques like depth of field, subsurface scattering, and ambient occlusion into the scene. If time and logistics allow, I will also add some additional features like reflections, shadows, and/or volumetrics.

### Inspiration/reference:
- My starting point will be my HW3 project, and as such, my starting reference will be the robot I created in Maya, seen here

![](images/RobotReference.jpg)

If time and logisics allows, I am considering creating a new SDF scene that would have more complexity and would give more opportunity to show off rendering techniques like subsurface scattering and ambient occlusion. For this, I am considering creating a classic still life scene that I think would have the advantage of having multiple objects close to each other to show off the ambient occlusion, could have objects that would naturally have subsurface scattering, and would enable me to add or remove objects in accordance with the needs of the complexity of my scene. Here is my still life reference, below:


### Specification:
1) Depth of field rendering
    - Implement a simulated depth of field effect
    - Allow the user to change the focal length and/or the aperture

2) Subsurface scattering
    - Impement simulated subsurface scattering
    - Possibly add different materials that have different materials and different amounts of SSS

3) Ambient Occlusion
    - Implement simulated ambient occlusion
    - Tweak amount of ambient occlusion to enhance the scene as best as possible

Possible additional features:

4) Reflections
    - Add simulated reflections to enhance the scene and give it more detail

5) Volumetrics
    - May try a simple smoke effect to test out algorithm, learn more about volumetrics

### Techniques:
- I will primarily be referencing materials from this class, specifically the slides and Adam's shader toys. 

### Design:
- I don't think my project lends itself to a free-body diagram, so i will describe the design verbally. Each feature will build upon the last feature. I will have to look into how fast the features can run together, since all of the features added together could make the program very slow. As a result, I may add user controls to turn features on and off, thereby allowing the user to see each feature, but still having a reasonable FPS. Additionally, I might have a feature that allows the user to freeze the camera and render, taking away some of the realtime functionality, but allowing the user to see all features layered together in the scene

### Timeline:

Milestones:

Week 1: Planning
  - Research topics
  - Look into algorithms/ methodologies
  - Write up Design Doc
  - Plan out work for next few weeks

Week 2: Bulk of implementation
  - Implement basic depth of field
  - Implement basic ambient occlusion
  - Implement basic SubSurface Scattering
  - Possibly implement additional features
  - Refine/ improve as time allows

Week 3: Improvement
  - Refine Depth of Field
  - Refine Ambient Occlusion
  - Refine SubSurface Scattering
  - Add parameters that the user can tune/change
  - Consider creating new SDF still life scene if feasible/ sensible
  - Implement/ add new features as time/logistics allows

Week 4: Polish
  - Make sure Depth of Field, Ambient Occlusion, and SubSurface Scattering are at their best
  - Improve user controls
  - Refine any additional features added
  - Refine/Improve SDF scene
  - Performance improvements
  - Create Documentation, a nice ReadMe, images, etc.



