package main

import    "core:fmt"
import    "core:c"
import    "core:time"
import    "core:math"
import    "core:os"
import    "core:runtime"
import    "vendor:glfw"
import gl "vendor:OpenGL"

import "core"


global_vao    : u32; 
global_shader : u32;
watch         : time.Stopwatch;

main :: proc() 
{
  if ( !core.window_create( 1000, 750, "title", core.WINDOW_TYPE.MINIMIZED,true ) )
  {
    fmt.print( "failed to create window\n" )
    return;
  }
  
  make_triangle()
  make_shader()

  gl.UseProgram( global_shader )
  gl.BindVertexArray( global_vao )
  // defer gl.BindVertexArray(0)

  for ( !core.window_should_close() )
  {
    glfw.PollEvents();

    if ( cast(bool)glfw.GetKey( core.window, glfw.KEY_ESCAPE ) )
    { break; }

    gl.ClearColor( 0.0, 1.0, 1.0, 1.0 );
    gl.Clear( gl.COLOR_BUFFER_BIT );

    // -- draw triangle --
    gl.DrawArrays( gl.TRIANGLES,    // Draw triangles.
                   0,               // Begin drawing at index 0.
                   3 )              // Use 3 indices.

    glfw.SwapBuffers( core.window );
  }

  glfw.DestroyWindow( core.window );
  glfw.Terminate();
}

make_triangle :: proc()
{
  vertices : [15] f32 = {
      // Coordinates ; Colors
       0.0,  0.5,       1, 0, 0,
       0.5, -0.5,       0, 1, 0,
      -0.5, -0.5,       0, 0, 1,
  }

  // Set up vertex array / buffer objects.
  gl.GenVertexArrays( 1, &global_vao )
  gl.BindVertexArray( global_vao )

  vbo : u32 
  gl.GenBuffers( 1, &vbo )
  gl.BindBuffer( gl.ARRAY_BUFFER, vbo )

  // Describe GPU buffer.
  gl.BufferData( gl.ARRAY_BUFFER,     // target
                 size_of(vertices),   // size of the buffer object's data store
                 &vertices,           // data used for initialization
                 gl.STATIC_DRAW )     // usage

  // Position and color attributes. Don't forget to enable!
  gl.VertexAttribPointer( 0,                   // index
                          2,                   // size
                          gl.FLOAT,            // type
                          gl.FALSE,            // normalized
                          5 * size_of(f32),    // stride
                          0 )                  // offset
  
  gl.VertexAttribPointer( 1, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 2 * size_of(f32) )

  // Enable the vertex position and color attributes defined above.
  gl.EnableVertexAttribArray( 0 )
  gl.EnableVertexAttribArray( 1 )
}

make_shader :: proc()
{
  // Compile vertex shader and fragment shader.
  // Note how much easier this is in Odin than in C++!
  program_ok      : bool
  vertex_shader   := string( #load( "../assets/vertex.glsl"   ) )
  fragment_shader := string( #load( "../assets/fragment.glsl" ) )

  global_shader, program_ok = gl.load_shaders_source( vertex_shader, fragment_shader );

  if ( !program_ok )
  {
      fmt.println( "ERROR: Failed to load and compile shaders." ); os.exit( 1 )
  }
}
