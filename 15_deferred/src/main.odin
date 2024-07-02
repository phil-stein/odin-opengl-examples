package core

import        "core:fmt"
import        "core:math"
import linalg "core:math/linalg/glsl"
import        "core:os"
import        "vendor:glfw"
import gl     "vendor:OpenGL"
import        "core:image"
import        "core:image/png"

exposure  :: 1.25

main :: proc() 
{
  // ---- init ----

  if ( !window_create( 1000, 750, "title", WINDOW_TYPE.MINIMIZED, true ) )
  {
    fmt.print( "failed to create window\n" )
    return;
  }
  input_init()
  // hide cursor
  input_center_cursor()
  input_set_cursor_visibile( false )

  // ---- setup ----

  data_init()


  // blank_tex_srgb  := make_texture( "assets/blank.png", true )
  blank_tex       := make_texture( "assets/blank.png", false )
  // black_blank_tex := make_texture( "assets/blank_black.png", false )
  
  // -- add entities --

  sphere_idx := len(data.entity_arr)
  append( &data.entity_arr, entity_t{ pos = {  2, 2, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = mesh_load_fbx( "assets/sphere.fbx" ), 
                                      mat  = { 
                                               albedo    = make_texture( "assets/brick/albedo.png",    true ), 
                                               roughness = make_texture( "assets/brick/roughness.png", false ), 
                                               metallic  = blank_tex, 
                                               normal    = make_texture( "assets/brick/normal.png",    false ), 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 1.0,
                                               metallic_f  = 0.0,
                                             },
                                    } )

  append( &data.entity_arr, entity_t{ pos = {  -2, 2, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = data.entity_arr[sphere_idx].mesh, 
                                      mat  = { 
                                               albedo    = blank_tex, 
                                               roughness = blank_tex, 
                                               metallic  = blank_tex, 
                                               normal    = blank_tex, 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 0.1,
                                               metallic_f  = 1.0,
                                             },
                                    } )
  append( &data.entity_arr, entity_t{ pos = {  -2, 4, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = data.entity_arr[sphere_idx].mesh, 
                                      mat  = { 
                                               albedo    = blank_tex, 
                                               roughness = blank_tex, 
                                               metallic  = blank_tex, 
                                               normal    = blank_tex, 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 0.25,
                                               metallic_f  = 1.0,
                                             },
                                    } )
  append( &data.entity_arr, entity_t{ pos = {  -2, 6, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = data.entity_arr[sphere_idx].mesh, 
                                      mat  = { 
                                               albedo    = blank_tex, 
                                               roughness = blank_tex, 
                                               metallic  = blank_tex, 
                                               normal    = blank_tex, 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 0.5,
                                               metallic_f  = 1.0,
                                             },
                                    } )
  append( &data.entity_arr, entity_t{ pos = {  -2, 8, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = data.entity_arr[sphere_idx].mesh, 
                                      mat  = { 
                                               albedo    = blank_tex, 
                                               roughness = blank_tex, 
                                               metallic  = blank_tex, 
                                               normal    = blank_tex, 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 0.75,
                                               metallic_f  = 1.0,
                                             },
                                    } )

  append( &data.entity_arr, entity_t{ pos = {   0, 2, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = data.entity_arr[sphere_idx].mesh, 
                                      mat  = { 
                                               albedo    = blank_tex, 
                                               roughness = blank_tex, 
                                               metallic  = blank_tex, 
                                               normal    = blank_tex, 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 0.1,
                                               metallic_f  = 0.0,
                                             },
                                    } )
  append( &data.entity_arr, entity_t{ pos = {   0, 4, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = data.entity_arr[sphere_idx].mesh, 
                                      mat  = { 
                                               albedo    = blank_tex, 
                                               roughness = blank_tex, 
                                               metallic  = blank_tex, 
                                               normal    = blank_tex, 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 0.25,
                                               metallic_f  = 0.0,
                                             },
                                    } )
  append( &data.entity_arr, entity_t{ pos = {   0, 6, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = data.entity_arr[sphere_idx].mesh, 
                                      mat  = { 
                                               albedo    = blank_tex, 
                                               roughness = blank_tex, 
                                               metallic  = blank_tex, 
                                               normal    = blank_tex, 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 0.5,
                                               metallic_f  = 0.0,
                                             },
                                    } )
  append( &data.entity_arr, entity_t{ pos = {   0, 8, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = data.entity_arr[sphere_idx].mesh, 
                                      mat  = { 
                                               albedo    = blank_tex, 
                                               roughness = blank_tex, 
                                               metallic  = blank_tex, 
                                               normal    = blank_tex, 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 0.75,
                                               metallic_f  = 0.0,
                                             },
                                    } )

  append( &data.entity_arr, entity_t{ pos = { -2, 4, 0 }, rot = { 0, 180, 0 }, scl = { 1, 1, 1 },
                                      mesh = mesh_load_fbx( "assets/suzanne_02.fbx" ), 
                                      mat  = { 
                                               albedo    = blank_tex, 
                                               roughness = blank_tex, 
                                               metallic  = blank_tex, 
                                               normal    = blank_tex, 

                                               tint        = linalg.vec3{ 1.0, 1.0, 1.0 },
                                               roughness_f = 0.25,
                                               metallic_f  = 1.0,
                                             },
                                    } )
 
  
  // -- set opengl state --
	
  gl.BindFramebuffer( gl.FRAMEBUFFER, 0 )
  gl.Viewport( 0, 0, i32(data.window_width), i32(data.window_height) )
  gl.Enable( gl.DEPTH_TEST )
  gl.Disable( gl.BLEND ) // enable blending of transparent texture
  gl.FrontFace( gl.CCW )
  gl.Enable( gl.CULL_FACE )
  gl.CullFace( gl.FRONT )

  gl.Enable( gl.TEXTURE_CUBE_MAP_SEAMLESS )
  

  gl.ClearColor( 0.0, 0.0, 0.0, 1.0 )

  // ---- main loop ----
  for ( !window_should_close() )
  {
    glfw.PollEvents();
      
    data_pre_updated()
      
    camera_rotate_by_mouse()
    camera_move_by_keys()

    if ( keystates[KEY.ESCAPE].pressed )
    { break }

    if ( keystates[KEY.TAB].pressed )
    { data.wireframe_mode_enabled  = !data.wireframe_mode_enabled }

    // wireframe mode
    if ( data.wireframe_mode_enabled == true )
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE) }
	  else
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL) }
    
    // -- draw meshes --
    camera_set_view_mat() 

    { // deferred
      framebuffer_bind( &data.fb_deferred )
      gl.Clear( gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT )
      gl.Enable( gl.DEPTH_TEST )
      gl.Enable( gl.TEXTURE_CUBE_MAP_SEAMLESS )
      gl.Disable( gl.BLEND ) // enable blending of transparent texture

      gl.Enable( gl.CULL_FACE )
      gl.CullFace( gl.BACK )

      shader_use( data.deferred_shader )
      for &e in data.entity_arr
      {
        gl.BindVertexArray( e.mesh.vao )
  
        e.model = make_model( e.pos, e.rot, e.scl )
        // @TODO:
        // e.inv_model = linalg.inverse( e.model )
        shader_act_set_mat4( "model", &e.model[0][0] )
        shader_act_set_mat4( "view",  &data.cam.view_mat[0][0] )
        shader_act_set_mat4( "proj",  &data.cam.pers_mat[0][0] )
        
       
        shader_act_bind_texture( "albedo", e.mat.albedo )
        shader_act_bind_texture( "roughness", e.mat.roughness )
        shader_act_bind_texture( "metallic", e.mat.metallic )
        shader_act_bind_texture( "norm", e.mat.normal )
        // shader_act_bind_texture( "emissive", e.mat.emissive )
        shader_act_set_vec3( "tint",        e.mat.tint )
        shader_act_set_f32(  "roughness_f", e.mat.roughness_f )
        shader_act_set_f32(  "metallic_f",  e.mat.metallic_f )
        // shader_act_set_f32(  "emissive_f",  e.mat.emissive_f )
        
        shader_act_set_vec2_f( "uv_tile", 1.0, 1.0 )


        gl.DrawElements( gl.TRIANGLES,             // Draw triangles.
                         i32(e.mesh.indices_len),  // indices length
                         gl.UNSIGNED_INT,          // Data type of the indices.
                         rawptr(uintptr(0)) )      // Pointer to indices. (Not needed.)

      }
      // skybox -----------------------------------------------------------------
      gl.DepthFunc(gl.LEQUAL);  // change depth function so depth test passes when values are equal to depth buffer's content

      shader_use( data.skybox_shader )
      view_no_pos := data.cam.view_mat
      view_no_pos[3][0] = 0.0 
      view_no_pos[3][1] = 0.0 
      view_no_pos[3][2] = 0.0 
      shader_act_set_mat4( "view", &view_no_pos[0][0] )
      shader_act_set_mat4( "proj", &data.cam.pers_mat[0][0] )

      // skybox cube
      gl.BindVertexArray(data.skybox_vao);
      shader_act_bind_cube_map( "cube_map", data.cubemap.environment )
      gl.DrawArrays(gl.TRIANGLES, 0, 36);
      gl.BindVertexArray(0);
      gl.DepthFunc(gl.LESS); // set depth function back to default
      framebuffer_unbind()
    }

    { // lighting pass
      
      framebuffer_bind( &data.fb_lighting )
      gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
      gl.Disable(gl.DEPTH_TEST);
    
      shader_use( data.lighting_shader )

      shader_act_set_vec3( "view_pos", data.cam.pos )
      shader_act_set_f32( "cube_map_intensity", data.cubemap.intensity )

      shader_act_bind_cube_map("irradiance_map", data.cubemap.irradiance )
      shader_act_bind_cube_map("prefilter_map", data.cubemap.prefilter )
      shader_act_bind_texture("brdf_lut", data.brdf_lut )

      shader_act_bind_texture("color", data.fb_deferred.buffer01 )
      shader_act_bind_texture("material", data.fb_deferred.buffer02 )
      shader_act_bind_texture("normal", data.fb_deferred.buffer03 )
      shader_act_bind_texture("position", data.fb_deferred.buffer04 )
      // @TODO: shadow

      // -- set lights --
      shader_act_set_i32( "dir_lights_len", 1 )
      shader_act_set_vec3_f( "dir_lights[0].direction", 1.0, 1.0, 0.0 )
      shader_act_set_vec3_f( "dir_lights[0].color",     1.0,  1.0, 1.0 )

      shader_act_set_i32( "point_lights_len", 0 )
      // ...
      
      gl.BindVertexArray(data.quad_vao);
      gl.DrawArrays(gl.TRIANGLES, 0, 6);
      gl.Enable(gl.DEPTH_TEST);
      gl.Enable( gl.CULL_FACE )
      framebuffer_unbind()
    }

    { // post fx
      shader_use( data.post_fx_shader )

      gl.Clear(gl.COLOR_BUFFER_BIT);
      gl.Disable(gl.DEPTH_TEST);
      gl.Disable( gl.CULL_FACE )

      shader_act_set_f32( "exposure", exposure )
      
      shader_act_bind_texture( "tex", data.fb_lighting.buffer01 )
      

      gl.BindVertexArray(data.quad_vao);
      gl.DrawArrays(gl.TRIANGLES, 0, 6);
      gl.Enable(gl.DEPTH_TEST);
      gl.Enable( gl.CULL_FACE )
    }


    // draw the gbuffer and lighting buffer onto screen as quads
    quad_size :: linalg.vec2{ 0.25, -0.25 }
    draw_quad( linalg.vec2{ -0.75,  0.75 }, quad_size, data.fb_deferred.buffer01 )
    draw_quad( linalg.vec2{ -0.75,  0.25 }, quad_size, data.fb_deferred.buffer02 )
    draw_quad( linalg.vec2{ -0.75, -0.25 }, quad_size, data.fb_deferred.buffer03 )
    draw_quad( linalg.vec2{ -0.75, -0.75 }, quad_size, data.fb_deferred.buffer04 )
    draw_quad( linalg.vec2{ -0.25,  0.75 }, quad_size, data.fb_lighting.buffer01 )

    glfw.SwapBuffers( data.window )
    
    data_post_update()
    input_update()
  }

  glfw.DestroyWindow( data.window )
  glfw.Terminate()
}

draw_quad :: proc( pos, scl: linalg.vec2, texture_handle: u32 )
{
  gl.Disable( gl.CULL_FACE )
  gl.Disable( gl.DEPTH_TEST)

  // -- draw triangle --
  // gl.UseProgram( data.quad_shader )
  shader_use( data.quad_shader )
  gl.BindVertexArray( data.quad_vao )
  // gl.Uniform2f( gl.GetUniformLocation(data.quad_shader, "pos"), pos.x, pos.y )
  // gl.Uniform2f( gl.GetUniformLocation(data.quad_shader, "scl"), scl.x, scl.y )
  shader_act_set_vec2( "pos", pos )
  shader_act_set_vec2( "scl", scl )
  
  gl.ActiveTexture( gl.TEXTURE0 )
  gl.BindTexture( gl.TEXTURE_2D, texture_handle )
  // gl.Uniform1i( gl.GetUniformLocation(data.quad_shader, "tex"), 0 )
  shader_act_set_i32( "tex", 0 )

  gl.DrawArrays( gl.TRIANGLES,    // Draw triangles.
                 0,               // Begin drawing at index 0.
                 6 )              // Use 3 indices.

  gl.Enable( gl.CULL_FACE )
  gl.Enable( gl.DEPTH_TEST)
}

make_model :: proc( pos, rot, scale: linalg.vec3 ) -> ( model: linalg.mat4 )
{
	// mat4_make_identity(model);
	// float x = rot[0];  m_deg_to_rad(&x);
	// float y = rot[1];  m_deg_to_rad(&y);
	// float z = rot[2];  m_deg_to_rad(&z);
  model = linalg.identity( linalg.mat4 )
  x := math.to_radians( rot.x )
  y := math.to_radians( rot.y )
  z := math.to_radians( rot.z )
	
	// mat4_rotate_at(model, pos, x, VEC3_X(1));
	// mat4_rotate_at(model, pos, y, VEC3_Y(1));
	// mat4_rotate_at(model, pos, z, VEC3_Z(1));
  model *= linalg.mat4Rotate( { 1.0, 0.0, 0.0 }, x )
  model *= linalg.mat4Rotate( { 0.0, 1.0, 0.0 }, y )
  model *= linalg.mat4Rotate( { 0.0, 0.0, 1.0 }, z )
	
	// mat4_translate(model, pos);
  model *= linalg.mat4Translate( pos )

	// mat4_scale(model, scale, model);
  model *= linalg.mat4Scale( scale )

  // fmt.println( "model[0]: ", model[0] )
  // fmt.println( "model[1]: ", model[1] )
  // fmt.println( "model[2]: ", model[2] )
  // fmt.println( "model[3]: ", model[3] )

  return
}

gl_format_str :: proc( format: i32 ) -> string
{
  return format == gl.R8         ? "R8"         :
         format == gl.SRGB8      ? "SRGB8"      :
         format == gl.RED        ? "RED"        :
         format == gl.RGB        ? "RGB"        :
         format == gl.SRGB       ? "SRGB"       :
         format == gl.RGBA       ? "RGBA"       :
         format == gl.SRGB_ALPHA ? "SRGB_ALPHA" :
         "unknown" 
}
make_texture :: proc( path: string, srgb: bool ) -> ( handle: u32 )
{
  // Load image at compile time
  // image_file_bytes := #load( "../assets/texture_01.png" )
  image_file_bytes, ok := os.read_entire_file( path, context.allocator )
  if( !ok ) 
  {
    // Print error to stderr and exit with errorcode
    fmt.eprintln("could not read texture file: ", path)
    os.exit(1)
  }
  defer delete( image_file_bytes, context.allocator )

  // Load image  Odin's core:image library.
  image_ptr :  ^image.Image
  err       :   image.Error
  // options   :=  image.Options { .alpha_add_if_missing }
  options   :=  image.Options { }

  image_ptr, err =  png.load_from_bytes( image_file_bytes, options )
  defer png.destroy( image_ptr )
  image_w := i32( image_ptr.width )
  image_h := i32( image_ptr.height )

  if ( err != nil )
  {
      fmt.println("ERROR: Image failed to load.")
  }

  // Copy bytes from icon buffer into slice.
  pixels := make( []u8, len(image_ptr.pixels.buf) )
  for b, i in image_ptr.pixels.buf 
  {
      pixels[i] = b
  }
  gl.GenTextures( 1, &handle )
  gl.BindTexture( gl.TEXTURE_2D, handle )

  // Texture wrapping options.
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
  
  // Texture filtering options.
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)


  gl_internal_format : i32 = srgb ? gl.SRGB_ALPHA : gl.RGBA
  gl_format          : u32 = gl.RGBA
  switch image_ptr.channels
  {
    case 1:
      gl_internal_format = srgb ? gl.SRGB8 : gl.R8
      gl_format = gl.RED
      break;
    // case 2:
    //   gl_internal_format = gl.RG8
    //   gl_format = gl.RG
    //   // P_INFO("gl.RGB");
    //   break;
    case 3:
      gl_internal_format = srgb ? gl.SRGB : gl.RGB
      gl_format = gl.RGB
      break;
    case 4:
      gl_internal_format = srgb ? gl.SRGB_ALPHA : gl.RGBA
      gl_format = gl.RGBA
      break;
    case:
      fmt.eprintln( "texture has incorrect channel amount: ", image_ptr.channels )
      os.exit( 1 )
  }
  assert( image_ptr.channels >= 1 && image_ptr.channels <= 4, "texture has incorrect channel amount" )

  // Describe texture.
  gl.TexImage2D(
      gl.TEXTURE_2D,      // texture type
      0,                  // level of detail number (default = 0)
      gl_internal_format, // gl.RGBA, // texture format
      image_w,            // width
      image_h,            // height
      0,                  // border, must be 0
      gl_format,          // gl.RGBA, // pixel data format
      gl.UNSIGNED_BYTE,   // data type of pixel data
      &pixels[0],         // image data
  )

  // must be called after glTexImage2D
  gl.GenerateMipmap(gl.TEXTURE_2D);

  return handle
}

texture_free_handle :: proc( _handle: u32 )
{
  handle := _handle
  if handle == 0 { return }
	gl.DeleteTextures( 1, &handle )
  handle = 0;
}

make_brdf_lut :: proc () -> ( handle: u32 )
{
  width  :: 512
  height :: 512

  // gen framebuffer ---------------------------------------------------------------------

  capture_fbo, capture_rbo : u32
  gl.GenFramebuffers( 1, &capture_fbo )
  gl.GenRenderbuffers( 1, &capture_rbo )

  gl.BindFramebuffer( gl.FRAMEBUFFER, capture_fbo )
  gl.BindRenderbuffer( gl.RENDERBUFFER, capture_rbo )
  gl.RenderbufferStorage( gl.RENDERBUFFER, gl.DEPTH_COMPONENT24, width, height )
  gl.FramebufferRenderbuffer( gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, capture_fbo )

  // gen brdf lut ------------------------------------------------------------------------
  
  brdf_lut : u32 
  gl.GenTextures( 1, &brdf_lut )

  gl.BindTexture( gl.TEXTURE_2D, brdf_lut )
  gl.TexImage2D( gl.TEXTURE_2D, 0, gl.RG16F, width, height, 0, gl.RG, gl.FLOAT, nil )
  gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
  gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

  gl.BindFramebuffer( gl.FRAMEBUFFER, capture_fbo )
  gl.BindRenderbuffer( gl.RENDERBUFFER, capture_rbo )
  gl.RenderbufferStorage( gl.RENDERBUFFER, gl.DEPTH_COMPONENT24, width, height )
  gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, brdf_lut, 0 )

  gl.Viewport( 0, 0, width, height )
  gl.UseProgram( data.brdf_lut_shader )
  gl.Clear( gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT )
  
	gl.BindVertexArray( data.quad_vao )
	gl.DrawArrays( gl.TRIANGLES, 0, 6 )
  gl.BindFramebuffer( gl.FRAMEBUFFER, 0 )

  gl.DeleteFramebuffers( 1, &capture_fbo )
  gl.DeleteRenderbuffers( 1, &capture_rbo )

  // @TODO: need to save this as float instead of 8bit

  // const int channel_nr = 2;
  // u32 pixels_len = 0;
  // texture_t t;
  // t.handle     = brdf_lut;
  // t.width      = width;
  // t.height     = height;
  // t.channel_nr = channel_nr;
  // #ifdef EDITOR
  // int t_path_len = (int)strlen(path);
  // char* tex_name = (char*)&path[t_path_len - 1];
  // for (int i = t_path_len - 1; i >= 0; --i)
  // {
  //   if (path[i] == '\\' || path[i] == '/') { break; }
  //   tex_name = (char*)&path[i];
  // }
  // ASSERT(strlen(tex_name) < TEXTURE_T_NAME_MAX);
  // STRCPY(t.name, tex_name);
  // #endif // EDITOR
  // asset_io_texture_write_pixels_to_file(&t,  GL_RG, path);

  // pixels_len++; // so gcc doesnt complain about unused variable

    
  return brdf_lut
}

