package core

import    "core:fmt"
import    "core:c"
import    "vendor:glfw"
import nk "../external/odin-nuklear"


//
// nk_glfw_device_t :: struct 
// {
//   cmds          : nk.Buffer,
//   null          : nk.Draw_Null_Texture,
//   vbo, vao, ebo : uint,
//   prog          : uint,
//   vert_shdr     : uint, 
//   frag_shdr     : uint, 
//   attrib_pos    : int, 
//   attrib_uv     : int,
//   attrib_col    : int, 
//   uniform_tex   : int,
//   uniform_proj  : int, 
//   font_tex      : uint,
// };
//
// // #ifndef NK_GLFW_TEXT_MAX
// // #define NK_GLFW_TEXT_MAX 256
// // #endif
// NK_GLFW_TEXT_MAX :: 256
// nk_glfw_data_t  :: struct
// {
//   win : glfw.WindowHandle,
//   width, height : c.int,
//   display_width, display_height : c.int,
//   ogl : nk_glfw_device_t,
//   ctx : nk.Context,
//   atlas: nk.Font,  // nk_font_atlas
//   fb_scale              : nk.Vec2,
//   text                  : [NK_GLFW_TEXT_MAX]uint,
//   text_len              : int,
//   scroll                : nk.Vec2,
//   last_button_click     : f64,
//   is_double_click_down  : c.int,
//   double_click_pos      : nk.Vec2,
// }
//
// ui_glfw_data : nk_glfw_data_t

MAX_VERTEX_BUFFER  :: 512 * 1024
MAX_ELEMENT_BUFFER :: 128 * 1024

glfw_data : nk.glfw_data_t
width  : int = 0
height : int = 0
ctx : ^nk.Context
bg  : nk.ColorF

// cant have these two because the windoews cant be resized otherwise NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE
window_flags       : nk.Panel_Flag = nk.Panel_Flag.Border | nk.Panel_Flag.Title
window_min_flags   : nk.Panel_Flag = nk.Panel_Flag.Border | nk.Panel_Flag.Title | nk.Panel_Flag.Minimizable
window_float_flags : nk.Panel_Flag = nk.Panel_Flag.Border | nk.Panel_Flag.Title | nk.Panel_Flag.Movable | nk.Panel_Flag.Scalable| nk.Panel_Flag.Minimizable
top_bar_flags      : nk.Panel_Flag = nk.Panel_Flag.Border

ui_init :: proc( )
{
  fmt.println( "ui_init start" )
  // ---- nuklear ----
  ctx = nk.glfw3_init( &glfw_data, data.window, nk.Glfw_Init_State.NK_GLFW3_INSTALL_CALLBACKS )
  /* Load Fonts: if none of these are loaded a default font will be used  */
  /* Load Cursor: if you uncomment cursor loading please hide the cursor */
  fmt.println( "glfw3_init" )

  {
    atlas : ^nk.font_atlas_t
    nk.glfw3_font_stash_begin( &glfw_data, &atlas )

    /* struct nk_font * */ droid := nk.font_atlas_add_from_file(atlas, "assets/fonts/DroidSans.ttf", 20/*18*//*16*//*14*/, nil  )

    nk.glfw3_font_stash_end( &glfw_data )
    /*nk_style_load_all_cursors(ctx, atlas->cursors);*/

    nk.style_set_font( ctx, &droid.handle )
  }
}

ui_update :: proc()
{
  // get window size
  w := data.window_width
  h := data.window_height
  nk.glfw3_new_frame( &glfw_data )


  // less height because the window bar on top and below
  w_ratio : f32 = 400.0  / 1920.0
  h_ratio : f32 = 1000.0 / 1020.0
  x_ratio : f32 = 0.0    / 1920.0
  y_ratio : f32 = 10.0   / 1020.0

  win_rect := nk.rect( x_ratio * f32(w), y_ratio * f32(h), w_ratio * f32(w), h_ratio * f32(h) )

  if nk.begin( ctx, "core_data", win_rect, { window_float_flags } ) 
  {
    collapse_states := nk.Collapse_States.Minimized
    nk.layout_row_dynamic( ctx, 20, 1 )
    // if nk.tree_state_push( ctx, nk.Tree_Type.Tab /* NK_TREE_TAB */, "time", &collapse_states /* nk.Window_Flags.Minimized */ /* NK_MINIMIZED */ )
    if nk.tree_state_push( ctx, /* nk.Tree_Type.Tab */ "cock", "time", &collapse_states )
    {
      nk.label_args( ctx, {nk.Text_Align.Left} /* NK_TEXT_LEFT */, "t_last_frame: %f", data.total_t )   
      nk.label_args( ctx, {nk.Text_Align.Left} /* NK_TEXT_LEFT */, "delta_t: %f",      data.delta_t )   
      nk.label_args( ctx, {nk.Text_Align.Left} /* NK_TEXT_LEFT */, "cur_fps: %f",      data.cur_fps )
      nk.tree_pop( ctx )
    }
  }
  nk.end( ctx )


  nk.glfw3_render( &glfw_data, nk.Anti_Aliasing.On , MAX_VERTEX_BUFFER, MAX_ELEMENT_BUFFER ) 
}

ui_cleanup :: proc()
{
  nk.clear( ctx )
}
