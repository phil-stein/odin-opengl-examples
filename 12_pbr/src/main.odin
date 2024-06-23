package core

import        "core:fmt"
import        "core:c"
import        "core:time"
import        "core:math"
import linalg "core:math/linalg/glsl"
import        "core:os"
import        "core:runtime"
import        "core:slice"
import        "vendor:glfw"
import gl     "vendor:OpenGL"
import        "core:image"
import        "core:image/png"



main :: proc() 
{
  // @TODO: test this
  // log.log( "this is log" )
  // log.info( "this is info" )
  // log.debug( "this is debug" )
  // log.warn( "this is warn" )
  // log.error( "this is error" )

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
  
  // data.global_shader = make_shader( #load( "../assets/basic.vert", string ), 
  //                                   #load( "../assets/basic.frag", string ))
  data.global_shader = make_shader( #load( "../assets/basic.vert", string ), 
                                    #load( "../assets/pbr.frag",   string ), "global_shader")


  data.global_shader = make_shader( #load( "../assets/cubemap/brdf_lut.vert", string ), 
                                    #load( "../assets/cubemap/brdf_lut.frag", string ))
  data.brdf_lut = make_brdf_lut()

  // SPRINTF(ASSET_PATH_MAX + 64, vert_path, "%sshaders/cubemap/render_equirect.vert", core_data->asset_path);
  // SPRINTF(ASSET_PATH_MAX + 64, frag_path, "%sshaders/cubemap/render_equirect.frag", core_data->asset_path);
  // core_data->equirect_shader = shader_create_from_file(vert_path, frag_path, NULL, "equirect_render_shader");
  data.equirect_shader = make_shader( #load( "../assets/cubemap/render_equirect.vert", string ), 
                                      #load( "../assets/cubemap/render_equirect.frag", string ))
 
  // SPRINTF(ASSET_PATH_MAX + 64, frag_path, "%sshaders/cubemap/irradiance_map.frag", core_data->asset_path);
  // core_data->irradiance_map_shader = shader_create_from_file(vert_path, 
		// 			      frag_path, NULL, "irradiance_map_shader");
  data.irradiance_map_shader = make_shader( #load( "../assets/cubemap/render_equirect.vert", string ), 
                                            #load( "../assets/cubemap/irradiance_map.frag", string ))
 
  // SPRINTF(ASSET_PATH_MAX + 64, frag_path, "%sshaders/cubemap/prefilter_map.frag", core_data->asset_path);
  // core_data->prefilter_shader = shader_create_from_file(vert_path, 
		// 			      frag_path, NULL, "prefilter_shader");
  data.prefilter_shader = make_shader( #load( "../assets/cubemap/render_equirect.vert", string ), 
                                       #load( "../assets/cubemap/prefilter_map.frag", string ))
  
  // core_data->cube_map = cubemap_load("#cubemaps/gothic_manor_01_2k.hdr");
  // core_data->cube_map.intensity = 1.9f;
  cubemap_data := #load( "../assets/gothic_manor_01_2k.hdr" )
  data.cubemap = cubemap_load( &cubemap_data[0], len(cubemap_data) )
  data.cubemap.intensity = 1.9


  
  // -- add entities --
  char_idx := len(data.entity_arr)
  append( &data.entity_arr, entity_t{ pos = { 0, 0, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = mesh_load_fbx( "assets/female_char_01.fbx" ), 
                                      mat  = { 
                                               albedo    = make_texture( "assets/albedo.png" ), 
                                               roughness = make_texture( "assets/roughness.png" ), 
                                               metallic  = make_texture( "assets/metallic.png" ), 
                                               normal    = make_texture( "assets/normal.png" ) 
                                             },
                                    } )

  // cube_idx := len(data.entity_arr)
  // append( &data.entity_arr, entity_t{ pos = { -2.5, 2, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
  //                                     mesh = mesh_load_fbx( "assets/cube.fbx" ), 
  //                                     mat  = { 
  //                                              albedo    = make_texture( "assets/texture_01.png" ), 
  //                                              roughness = make_texture( "assets/roughness.png" ), 
  //                                              metallic  = make_texture( "assets/metallic.png" ), 
  //                                              normal    = make_texture( "assets/normal.png" ) 
  //                                            },
  //                                   } )

  // sphere_idx := len(data.entity_arr)
  // append( &data.entity_arr, entity_t{ pos = {  0.0, 2, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
  //                                     mesh = mesh_load_fbx( "assets/sphere.fbx" ), 
  //                                     mat  = { 
  //                                              albedo    = make_texture( "assets/blank.png" ), 
  //                                              roughness = make_texture( "assets/roughness.png" ), 
  //                                              metallic  = make_texture( "assets/metallic.png" ), 
  //                                              normal    = make_texture( "assets/normal.png" ) 
  //                                            },
  //                                   } )

  // suzanne_idx := len(data.entity_arr)
  // append( &data.entity_arr, entity_t{ pos = { 2.5, 2, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 }, 
  //                                     mesh = mesh_load_fbx( "assets/suzanne.fbx" ), 
  //                                     texture = make_texture( "assets/blank.png" ) } )
 
  
  // -- set opengl state --
	
  gl.BindFramebuffer( gl.FRAMEBUFFER, 0 )

  gl.Viewport( 0, 0, i32(data.window_width), i32(data.window_height) )

  gl.Enable( gl.DEPTH_TEST )

  gl.Disable( gl.BLEND ) // enable blending of transparent texture

  // @TODO: @BUGG: meshes only show correct if culling front faces, 
  //               reversing order in mesh_load_fbx() didnt work
  // gl.Disable( gl.CULL_FACE )
  gl.FrontFace( gl.CCW )
  gl.Enable( gl.CULL_FACE )
  // gl.CullFace( gl.BACK )
  gl.CullFace( gl.FRONT )

  gl.Enable( gl.TEXTURE_CUBE_MAP_SEAMLESS )
  

  gl.UseProgram( data.global_shader )

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

    // gl.ClearColor( 0.0, 1.0, 1.0, 1.0 )
    gl.ClearColor( 0.0, 0.0, 0.0, 1.0 )
    gl.ClearColor( 0.5, 0.5, 0.5, 1.0 )
    gl.Clear( gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT )

    // wireframe mode
    if ( data.wireframe_mode_enabled == true )
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE) }
	  else
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL) }

    // // move entities
    // data.entity_arr[cube_idx].pos.y    = math.sin_f32( data.total_t ) +2
    // data.entity_arr[sphere_idx].pos.y  = math.sin_f32( data.total_t ) +2
    // data.entity_arr[sphere_idx].pos.z  = math.sin_f32( data.total_t *2 )
    // data.entity_arr[suzanne_idx].pos.z = math.sin_f32( data.total_t )

    



    // -- draw meshes --
    for &e in data.entity_arr
    {
      // gl.UseProgram( global_shader )
      gl.BindVertexArray( e.mesh.vao )
  
      camera_set_view_mat() 
      e.model = make_model( e.pos, e.rot, e.scl )
      e.inv_model = linalg.inverse( e.model )

      gl.UniformMatrix4fv(gl.GetUniformLocation(data.global_shader, "model"),     1, gl.FALSE, &e.model[0][0])
      gl.UniformMatrix4fv(gl.GetUniformLocation(data.global_shader, "inv_model"), 1, gl.FALSE, &e.inv_model[0][0])
      
      // gl.Uniform3f(gl.GetUniformLocation(data.global_shader, "light_pos"), 0, 5, -2)

      gl.UniformMatrix4fv(gl.GetUniformLocation(data.global_shader, "view"),      1, gl.FALSE, &data.cam.view_mat[0][0])
      gl.UniformMatrix4fv(gl.GetUniformLocation(data.global_shader, "proj"),      1, gl.FALSE, &data.cam.pers_mat[0][0])
      
      gl.Uniform3f(gl.GetUniformLocation(data.global_shader, "view_pos"), data.cam.pos.x, data.cam.pos.y, data.cam.pos.z )

      gl.Uniform1f(gl.GetUniformLocation(data.global_shader, "cube_map_intensity"), data.cubemap.intensity )

      tex_idx := 0
      gl.ActiveTexture( u32(gl.TEXTURE0 + tex_idx) )
      gl.BindTexture( gl.TEXTURE_2D, data.cubemap.irradiance )
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "irradiance_map"), i32(tex_idx) )
      tex_idx += 1
      gl.ActiveTexture( u32(gl.TEXTURE0 + tex_idx) )
      gl.BindTexture( gl.TEXTURE_2D, data.cubemap.prefilter )
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "prefilter_map"), i32(tex_idx) )
      tex_idx += 1
      gl.ActiveTexture( u32(gl.TEXTURE0 + tex_idx) )
      gl.BindTexture( gl.TEXTURE_2D, data.brdf_lut )
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "brdf_lut"), i32(tex_idx) )

      // -- set lights --
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "dir_lights_len"), 0 )
      // ...
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "point_lights_len"), 0 )
      // ...
     
      gl.ActiveTexture( u32(gl.TEXTURE0 + tex_idx) )
      gl.BindTexture( gl.TEXTURE_2D, e.mat.albedo )
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "albedo"), i32(tex_idx) )
      tex_idx += 1
      gl.ActiveTexture( u32(gl.TEXTURE0 + tex_idx) )
      gl.BindTexture( gl.TEXTURE_2D, e.mat.roughness )
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "roughness"), i32(tex_idx) )
      tex_idx += 1
      gl.ActiveTexture( u32(gl.TEXTURE0 + tex_idx) )
      gl.BindTexture( gl.TEXTURE_2D, e.mat.metallic )
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "metallic"), i32(tex_idx) )
      tex_idx += 1
      gl.ActiveTexture( u32(gl.TEXTURE0 + tex_idx) )
      gl.BindTexture( gl.TEXTURE_2D, e.mat.normal )
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "normal"), i32(tex_idx) )

      gl.DrawElements( gl.TRIANGLES,             // Draw triangles.
                       i32(e.mesh.indices_len),  // indices length
                       gl.UNSIGNED_INT,          // Data type of the indices.
                       rawptr(uintptr(0)) )      // Pointer to indices. (Not needed.)
    }

    glfw.SwapBuffers( data.window )
    
    // fmt.println( len(data.entity_arr) )
    // fmt.println( cap(data.entity_arr) )
    // // clear( &data.entity_arr )
    // free( &data.entity_arr )
    // fmt.println( len(data.entity_arr) )
    // fmt.println( cap(data.entity_arr) )

    data_post_update()
    input_update()
  }

  glfw.DestroyWindow( data.window )
  glfw.Terminate()
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

make_shader :: proc( vertex_src, fragment_src: string, name := "unnamed") -> ( handle: u32 )
{
  // Compile vertex shader and fragment shader.
  // Note how much easier this is in Odin than in C++!
  program_ok      : bool
  // vertex_shader   := string( #load( "../assets/basic.vert" ) )
  // fragment_shader := string( #load( "../assets/basic.frag" ) )
  // handle, program_ok = gl.load_shaders_source( vertex_shader, fragment_shader )
  handle, program_ok = gl.load_shaders_source( vertex_src, fragment_src )

  if ( !program_ok )
  {
    fmt.println( "ERROR: Failed to load and compile shaders: ", name )
    os.exit( 1 )
  }

  return
}

make_texture :: proc( path: string ) -> ( handle: u32 )
{
  gl.GenTextures( 1, &handle )
  gl.BindTexture( gl.TEXTURE_2D, handle )

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
  options   :=  image.Options { .alpha_add_if_missing }

  //    image_ptr, err =  q.load_from_file(IMAGELOC, options)
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

  // Describe texture.
  gl.TexImage2D(
      gl.TEXTURE_2D,    // texture type
      0,                // level of detail number (default = 0)
      gl.RGBA,          // texture format
      image_w,          // width
      image_h,          // height
      0,                // border, must be 0
      gl.RGBA,          // pixel data format
      gl.UNSIGNED_BYTE, // data type of pixel data
      &pixels[0],  // image data
  )

  // Texture wrapping options.
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
  
  // Texture filtering options.
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

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

