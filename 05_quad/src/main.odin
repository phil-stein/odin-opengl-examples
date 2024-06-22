package main

import    "core:fmt"
import    "core:c"
import    "core:time"
import    "core:math"
import m  "core:math/linalg/glsl"
import    "core:os"
import    "core:runtime"
import    "vendor:glfw"
import gl "vendor:OpenGL"

import "core"


global_vao    : u32
global_shader : u32
watch         : time.Stopwatch

tab_pressed_last_frame : bool = false
wireframe_mode_enabled : bool = false

scl : m.vec2 = { 0.5, 0.5 } 

main :: proc() 
{
  if ( !core.window_create( 1000, 750, "title", core.WINDOW_TYPE.MINIMIZED, true ) )
  {
    fmt.print( "failed to create window\n" )
    return;
  }
  
  make_quad()
  make_shader()

  gl.UseProgram( global_shader )
  gl.BindVertexArray( global_vao )
  // defer gl.BindVertexArray(0)

  for ( !core.window_should_close() )
  {
    glfw.PollEvents();

    // if ( cast(bool)glfw.GetKey( core.window, glfw.KEY_ESCAPE ) )
    if ( bool(glfw.GetKey( core.window, glfw.KEY_ESCAPE )) )
    { break; }

    if ( !tab_pressed_last_frame && 
         bool(glfw.GetKey( core.window, glfw.KEY_TAB )) )
    { 
      wireframe_mode_enabled  = !wireframe_mode_enabled 
      tab_pressed_last_frame = true
    }
    else if ( !bool(glfw.GetKey( core.window, glfw.KEY_TAB )) )
    { tab_pressed_last_frame = false }

    gl.ClearColor( 0.0, 1.0, 1.0, 1.0 )
    gl.Clear( gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT )
    gl.Disable( gl.DEPTH_TEST )

    // wireframe mode
    if ( wireframe_mode_enabled == true )
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE) }
	  else
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL) }

    // -- draw triangle --
    // gl.UseProgram( global_shader )
    // gl.BindVertexArray( global_vao )
    gl.Uniform2f( gl.GetUniformLocation(global_shader, "scl"), scl.x, scl.y )

    gl.DrawArrays( gl.TRIANGLES,    // Draw triangles.
                   0,               // Begin drawing at index 0.
                   6 )              // Use 3 indices.

    glfw.SwapBuffers( core.window )
  }

  glfw.DestroyWindow( core.window )
  glfw.Terminate()
}

make_quad :: proc()
{
  quad_verts := [?]f32 { 
	  // pos        uvs
	  -1.0,  1.0,   0.0, 1.0,
	  -1.0, -1.0,   0.0, 0.0,
	   1.0, -1.0,   1.0, 0.0,

	  -1.0,  1.0,   0.0, 1.0,
	   1.0, -1.0,   1.0, 0.0,
	   1.0,  1.0,   1.0, 1.0
	} 

  fmt.printfln("24 * size_of(f32): %d", 24 * size_of(f32))
  fmt.printfln( "sizeof(verts): %d", size_of(quad_verts) )
  // fmt.println( size_of(f32) )

  vbo : u32 
	gl.GenVertexArrays( 1, &global_vao )
	gl.GenBuffers( 1, &vbo )

  gl.BindVertexArray( global_vao )
  gl.BindBuffer( gl.ARRAY_BUFFER, vbo )

	gl.BufferData( gl.ARRAY_BUFFER, size_of(quad_verts), &quad_verts, gl.STATIC_DRAW ) // quad_verts is 24 long

	gl.EnableVertexAttribArray( 0 )
	gl.VertexAttribPointer( 0, 2, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 0 )
	gl.EnableVertexAttribArray( 1 )
	gl.VertexAttribPointer( 1, 2, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 2 * size_of(f32) )
}

make_shader :: proc()
{
  // Compile vertex shader and fragment shader.
  // Note how much easier this is in Odin than in C++!
  program_ok      : bool
  vertex_shader   := string( #load( "../assets/vertex.glsl"   ) )
  fragment_shader := string( #load( "../assets/fragment.glsl" ) )

  global_shader, program_ok = gl.load_shaders_source( vertex_shader, fragment_shader )

  if ( !program_ok )
  {
    fmt.println( "ERROR: Failed to load and compile shaders." )
    os.exit( 1 )
  }
}
