package core

import linalg "core:math/linalg/glsl"
import        "vendor:glfw"


entity_t :: struct
{
  pos, rot, scl    : linalg.vec3,
  
  mesh             : mesh_t,
  texture          : u32,

  model, inv_model : linalg.mat4,

}


data_t :: struct
{
  delta_t_real      : f32,
  delta_t           : f32,
  total_t           : f32,
  cur_fps           : f32,
  time_scale        : f32,

  global_shader     : u32,
  wireframe_mode_enabled : bool,
  bg_color          : linalg.vec3,
  
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
  // bg_color          = { 1.0, 1.0, 1.0 },
  // bg_color          = { 0.2, 0.035, 0.075 },
  bg_color          = { 0.0, 0.0, 0.0 },
  
  mouse_x           = 0.0,
  mouse_y           = 0.0, 
  mouse_delta_x     = 0.0,
  mouse_delta_y     = 0.0, 

  mouse_sensitivity = 0.5,

  cam = 
  {
    pos       = { 0, 0.5, -2.5 },
    target    = {  0, 0, 0 },
    pitch_rad = -0.1, // -0.4,
    yaw_rad   = 14.2,
  }
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

