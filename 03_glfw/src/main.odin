package main

import "core:fmt"
import "core:c"
import "vendor:glfw"
import gl "vendor:OpenGL"

import "core"


main :: proc() 
{
  if ( !core.window_create( 1000, 750, "title", core.WINDOW_TYPE.MINIMIZED,true ) )
  {
    fmt.print( "failed to create window\n" );
    return;
  }

  for ( !core.window_should_close() )
  {
    glfw.PollEvents();

    if ( cast(bool)glfw.GetKey( core.window, glfw.KEY_ESCAPE ) )
    { break; }

    gl.ClearColor( 0.0, 1.0, 1.0, 1.0 );
    gl.Clear( gl.COLOR_BUFFER_BIT );

    glfw.SwapBuffers( core.window );
  }

  glfw.DestroyWindow( core.window );
  glfw.Terminate();
}
