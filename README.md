# odin-opengl-examples

examples of using opengl and glfw using [odin](http://odin-lang.org/), also one example for raylib and vulkan each <br>

examples work but arent necessarily well done / documented <br>
as i used this to get to know odin <br>

resources: [odin docs](https://odin-lang.org/docs/), [bg-thompson: OpenGL-Tutorials-In-Odin](https://github.com/bg-thompson/OpenGL-Tutorials-In-Odin), [learnopengl.com](https://learnopengl.com) <br>

external code: [ufbx](https://github.com/ufbx/ufbx), [odin-ufbx](https://github.com/cshenton/odin-ufbx)

assets: [my own texture](https://www.artstation.com/artwork/BX4Xq9), [stylized-brick-002 texture](https://3dtextures.me/2022/01/29/stylized-bricks-002/), [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono), cube / sphere / suzanne model made using [blender](https://www.blender.org/) <br>

! from __10__ onwards if you get linking errors, recompile 10_ufbx/external/ufbx/ufbx.c -> ufbx.lib / .a, see [odin-ufbx](https://github.com/cshenton/odin-ufbx)<br>
  then copy that library file to any other example using ufbx

|                                                                                                                     |                                                                                                                                                                                                                             |
| ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------                                                                                                       |
| __00_hello__: default odin hello world                                                                              | __01_import__: using the import statement and packages                                                                                                                                                                      |
| __02_raylib__: open default window in raylib                                                                        | __03_glfw__: blank window in glfw                                                                                                                                                                                           |
| <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/02_raylib.png" alt="logo" width="400"> | <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/03_glfw.png" alt="logo" width="400">                                                                                                           |
| __04_vulkan__: blank window using vulkan                                                                            | __05_triangle__: opengl & glfw triangle                                                                                                                                                                                     |
| <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/04_vulkan.png" alt="logo" width="400"> | <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/05_triangle.png" alt="logo" width="400">                                                                                                       |
| __06_quad__: opengl & glfw quad                                                                                     | __07_texture__: opengl & glfw textured quad                                                                                                                                                                                 |
| <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/06_quad.png" alt="logo" width="400">   | <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/07_texture.png" alt="logo" width="400">                                                                                                        |
| __08_cube__: opengl & glfw rotating cube                                                                            | __09_camera__: free-fly camera and opengl & glfw textured cube                                                                                                                                                              |
| <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/08_cube.png" alt="logo" width="400">   | <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/09_camera.png" alt="logo" width="400">                                                                                                         |
| __10_ufbx__: loading .fbx file, also [blinn-phong shading](https://learnopengl.com/Lighting/Basic-Lighting)         | __11_entities__: multiple moving 3d meshes in one scene                                                                                                                                                                     |
| <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/10_ufbx.png" alt="logo" width="400">   | <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/11_entities.png" alt="logo" width="400">                                                                                                       |
| __12_normal__: normal mapping                                                                                       | __13_cel__: cel shading and shader re-compilation                                                                                                                                                                           |
| <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/12_normal.png" alt="logo" width="400"> | <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/13_cel.png" alt="logo" width="400">                                                                                                            |
| __14_pbr__: pbr shading                                                                                             | __15_deferred__: deferred pbr shading                                                                                                                                                                                       |
| _not yet working_                                                                                                   | <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/15_deferred_02.png" alt="logo" width="400">                                                                                                    |
| __16_text__: unbatched text rendering using `vendor:stb/truetype`                                                   | __17_microui__:                                                                                                                                                                                                             |
| <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/16_text.png" alt="logo" width="400">   | not working                                                                                                                                                                                                                 |
| __18_nuklear__:                                                                                                     | __19_imgui__: using [L-4's bindings](https://gitlab.com/L-4/odin-imgui), see [tutorial](https://www.youtube.com/watch?v=7_xIc9aYdoo), use your own vcvarsall.bat file see 19_imgui/external/odin-imgui/IMPORTANT_README.txt |
| not working                                                                                                         | <img src="https://github.com/phil-stein/odin-opengl-examples/blob/main/files/19_imgui.png" alt="logo" width="400">                                                                                                          |

## todo
  - [ ] hot-reloading, [video_01](https://www.youtube.com/watch?v=HY6Dv0Fbu14), [video_02](https://www.youtube.com/watch?v=KvgNLeaGgWE&t=307s)
  - [ ] dump stack trace
    - [X] [build-in](https://pkg.odin-lang.org/core/debug/trace/)
    - [X] [dump stack trace](https://github.com/DaseinPhaos/pdb) `doesnt work` 
  - [ ] [tracking allocator](https://www.youtube.com/watch?v=dg6qogN8kIE)
  - [ ] temporary allocator `WIP`
  - [X] [reflection](https://pkg.odin-lang.org/core/reflect/)
    - [X] get all names of struct members
    - [X] set struct members
  - [ ] opengl debugging `WIP` 
    - [X] set callback
    - [ ] print location of error
    - [X] filter errors
  - [ ] text rendering
    - [X] unbatched
    - [ ] batched
    - [ ] 3d
    - [ ] sdf
  - [ ] pbr `WIP`
  - [X] deferred shading 
  - [ ] tonemapping
  - [ ] microui
  - [ ] nuklear
  - [ ] dear imgui
  - [ ] debug-renderer
  - fx
    - [ ] anti-aliasing, fxa prob.
    - [ ] [bloom](https://www.youtube.com/watch?v=ml-5OGZC7vE&t=319s&pp=ygUNb3BlbmdsIGVmZmVjdA%3D%3D)
    - [ ] cascaded shadows
  - [ ] particle system -> instanced rendering, batching, etc.
  - [ ] serialization
  - [ ] skeletal anim, [video_01](https://www.youtube.com/watch?v=ZzMnu3v_MOw), 
  - [ ] figure out why loading fbx files is so slow
  - [ ] asset manager
  - [ ] clean up code, add comments

## maybe
  - [ ] physics 
  - [ ] ray-tracing 
  - [ ] [intersection effect](https://www.youtube.com/watch?v=SiCNFMhDZ1o&list=WL&index=1&pp=gAQBiAQB) 
  - [ ] [shader art](https://www.youtube.com/watch?v=f4s1h2YETNY&t=196s) 
  - [ ] paletization?
  - [ ] [texture optimizations](https://www.youtube.com/watch?v=ElwclNhYW04&pp=ygUUcGFsbGV0aXphdGlvbiBvcGVuZ2w%3D)
  - [ ] [radiance cascades](https://www.youtube.com/watch?v=3so7xdZHKxw)

