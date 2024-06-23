package core

import "vendor:glfw"

delta_t_real  : f32 = 0.0
delta_t       : f32 = 0.0
total_t       : f32 = 0.0
cur_fps       : f32 = 0.0
time_scale    : f32 = 1.0

mouse_x       : f32 = 0.0 
mouse_y       : f32 = 0.0  
mouse_delta_x : f32 = 0.0 
mouse_delta_y : f32 = 0.0 

mouse_sensitivity : f32 = 0.5

data_pre_updated :: proc()
{
  @(static) first_frame := true
  // ---- time ----
	delta_t_real = f32(glfw.GetTime()) - total_t
	total_t      = f32(glfw.GetTime())
  cur_fps      = 1 / delta_t_real
  if ( first_frame ) 
  { delta_t_real = 0.016; first_frame = false; } // otherwise dt first frame is like 5 seconds
  delta_t = delta_t_real * time_scale
}

data_post_update :: proc()
{
  mouse_delta_x = 0.0
  mouse_delta_y = 0.0
}

