package core

import linalg "core:math/linalg/glsl"
import        "vendor:glfw"
import gl     "vendor:OpenGL"


WINDOW_TYPE :: enum { MINIMIZED, MAXIMIZED, FULLSCREEN };


entity_t :: struct
{
  pos, rot, scl    : linalg.vec3,
  
  mesh             : mesh_t,

  mat : struct
  {
    albedo           : u32,
    roughness        : u32,
    metallic         : u32,
    normal           : u32,
  },

  model, inv_model : linalg.mat4,

}

cubemap_t :: struct
{
  loaded : bool,
  // name   : string,

  environment : u32,
  irradiance  : u32,
  prefilter   : u32,
  intensity   : f32,
}


data_t :: struct
{
  delta_t_real      : f32,
  delta_t           : f32,
  total_t           : f32,
  cur_fps           : f32,
  time_scale        : f32,

  window: glfw.WindowHandle,
  window_width  : int,
  window_height : int,


  quad_vao : u32,
  quad_vbo : u32,

  global_shader         : u32,
  equirect_shader       : u32,
  irradiance_map_shader : u32,
  prefilter_shader      : u32,
  brdf_lut_shader       : u32,

  brdf_lut : u32,

  cubemap : cubemap_t,

  wireframe_mode_enabled : bool,
  
  mouse_x           : f32,
  mouse_y           : f32,  
  mouse_delta_x     : f32,
  mouse_delta_y     : f32, 

  mouse_sensitivity : f32,

  cam : struct
  {
    pos       : linalg.vec3,
    target    : linalg.vec3,
    pitch_rad : f32, 
    yaw_rad   : f32, 
    view_mat  : linalg.mat4,
    pers_mat  : linalg.mat4,
  },
  
  entity_arr : [dynamic]entity_t,

}
data : data_t =
{
  delta_t_real      = 0.0,
  delta_t           = 0.0,
  total_t           = 0.0,
  cur_fps           = 0.0,
  time_scale        = 1.0,
  
  wireframe_mode_enabled = false,
  
  mouse_x           = 0.0,
  mouse_y           = 0.0, 
  mouse_delta_x     = 0.0,
  mouse_delta_y     = 0.0, 

  mouse_sensitivity = 0.5,

  cam = 
  {
    pos       = { 0, 5, -6 },
    target    = {  0, 0, 0 },
    pitch_rad = -0.4,
    yaw_rad   = 14.2,
  }
}

data_init :: proc()
{
  // screen quad 
	quad_verts := [?]f32{ 
	  // pos       // uv 
	  -1.0,  1.0,  0.0, 1.0,
	  -1.0, -1.0,  0.0, 0.0,
	   1.0, -1.0,  1.0, 0.0,

	  -1.0,  1.0,  0.0, 1.0,
	   1.0, -1.0,  1.0, 0.0,
	   1.0,  1.0,  1.0, 1.0
	}

	// screen quad VAO
	gl.GenVertexArrays( 1, &data.quad_vao )
	gl.GenBuffers( 1, &data.quad_vbo )
	gl.BindVertexArray( data.quad_vao )
	gl.BindBuffer( gl.ARRAY_BUFFER, data.quad_vbo);
	gl.BufferData( gl.ARRAY_BUFFER, size_of(quad_verts), &quad_verts, gl.STATIC_DRAW); // quad_verts is 24 long
	gl.EnableVertexAttribArray(0);
	gl.VertexAttribPointer( 0, 2, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 0 )
	gl.EnableVertexAttribArray( 1 )
	gl.VertexAttribPointer( 1, 2, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 2 * size_of(f32) )

}

data_pre_updated :: proc()
{
  @(static) first_frame := true
  // ---- time ----
	data.delta_t_real = f32(glfw.GetTime()) - data.total_t
	data.total_t      = f32(glfw.GetTime())
  data.cur_fps      = 1 / data.delta_t_real
  if ( first_frame ) 
  { data.delta_t_real = 0.016; first_frame = false; } // otherwise dt first frame is like 5 seconds
  data.delta_t = data.delta_t_real * data.time_scale
}

data_post_update :: proc()
{
  data.mouse_delta_x = 0.0
  data.mouse_delta_y = 0.0
}

