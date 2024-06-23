package core 

import "core:fmt"
import "core:c"
import "vendor:glfw"
import gl "vendor:OpenGL"


WINDOW_TYPE :: enum { MINIMIZED, MAXIMIZED, FULLSCREEN };

window: glfw.WindowHandle;
window_width  : int
window_height : int

// intis glfw & glad, also creates the window
// returns: <stddef.h> return_code
window_create :: proc( width, height: int, title: cstring, type: WINDOW_TYPE, vsync: bool ) -> bool
{
	// enable error logging for glfw
  glfw.SetErrorCallback( cast(glfw.ErrorProc)error_callback );
  

  // Initialise GLFW
	if (glfw.Init() == glfw.FALSE)
	{
		fmt.printf( "Failed to initialize GLFW !!!\n" );
		return false;
	}
	glfw.WindowHint( glfw.CONTEXT_VERSION_MAJOR, 4 );
	glfw.WindowHint( glfw.CONTEXT_VERSION_MINOR, 6 );
	glfw.WindowHint( glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE );
	// glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, true); // @TODO: implement this, page 439 in learnopengl

// #ifdef __APPLE__
// 	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
// #endif

  monitor   := glfw.GetPrimaryMonitor();
  mode      := glfw.GetVideoMode( monitor );
  monitor_w := mode.width;
  monitor_h := mode.height;
 
  glfw.WindowHint_int( glfw.RED_BITS,     mode.red_bits );
  glfw.WindowHint_int( glfw.GREEN_BITS,   mode.green_bits );
  glfw.WindowHint_int( glfw.BLUE_BITS,    mode.blue_bits );
  glfw.WindowHint_int( glfw.REFRESH_RATE, mode.refresh_rate );

  // open a window and create its opengl context
	if ( type == WINDOW_TYPE.FULLSCREEN )
  {
    window = glfw.CreateWindow( mode.width, mode.height, title, monitor, nil );
    window_width  = int(mode.width)
    window_height = int(mode.height)
  }
  else
  {
    window = glfw.CreateWindow( cast(c.int)width, cast(c.int)height, title, nil, nil );
    window_width  = width
    window_height = height
  }

	if (window == nil)
	{
		fmt.printf( "Failed to open GLFW window.\n" );
		glfw.Terminate();
		return false;
	}

	// make the window's context current
	glfw.MakeContextCurrent( window );

  glfw.SwapInterval( vsync ? 1 : 0 );  // disable vsync

  // gl.load_up_to( 3, 3, glfw.gl_set_proc_address );
  gl.load_up_to( 4, 6, glfw.gl_set_proc_address );

	// tell opengl the size of our window
  w, h := glfw.GetFramebufferSize( window );
	gl.Viewport( 0, 0, w, h );

	// maximize window
	if ( type == WINDOW_TYPE.MAXIMIZED )
	{
		glfw.MaximizeWindow( window );
	}

	// set the resize callback
	glfw.SetFramebufferSizeCallback( window, cast(glfw.FramebufferSizeProc)resize_callback );
  // @NOTE: causes inability to restore maximized after fullscreen, also framebuffers crash when minimizing to system tray
  // glfwSetWindowMaximizeCallback(core_data->window,  (GLFWwindowmaximizefun)maximize_callback); 

	glfw.SetWindowAttrib( window, glfw.FOCUS_ON_SHOW, 1 );  // 1: true
	// glfwSetWindowAttrib(window, GLFW_AUTO_ICONIFY, true);
	glfw.RequestWindowAttention( window );
  
  camera_set_pers_mat( f32(window_width), f32(window_height) )

	return true; 
}

// glfw error callback func
@(private)
error_callback :: proc( error: c.int, description: cstring )
{
	fmt.printf( "GLFW-Error: %s\n", description );
}

// window resize callback
// resizes the "glViewport" according to the resized window
// window is type GLFWwindow*
@(private)
resize_callback :: proc( window: glfw.WindowHandle, width, height: c.int )
{
	gl.Viewport( 0, 0, width, height );
  camera_set_pers_mat( f32(width), f32(height) )
  window_width  = int(width)
  window_height = int(height)
}

window_should_close :: #force_inline proc() -> bool
{
  return glfw.WindowShouldClose( window ) == glfw.TRUE;
}

// void maximize_callback(void* window, int maximized)
// {
//   TRACE();
//
//   (void)window;
//   win_type = maximized ? WINDOW_MAX : WINDOW_MIN; // : win_type;
// }
