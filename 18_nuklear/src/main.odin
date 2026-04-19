package core

import        "core:fmt"
import        "core:c"
import        "core:time"
import        "core:math"
import linalg "core:math/linalg/glsl"
import        "core:os"
import        "base:runtime"
import        "core:slice"
import        "vendor:glfw"
import gl     "vendor:OpenGL"
import        "core:image"
import        "core:image/png"



main :: proc() 
{
  // ---- init ----

  if ( !window_create( 1000, 750, "title", WINDOW_TYPE.MINIMIZED, true ) )
  {
    fmt.print( "failed to create window\n" )
    return;
  }
  input_init()

  // ---- setup ----

  input_center_cursor()
  input_set_cursor_visibile( false )
  
  make_shader()


  ui_init()

  
  // -- add entities --

  cube_idx := len(data.entity_arr)
  append( &data.entity_arr, entity_t{ pos = { -2.5, 2, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = mesh_load_fbx( "assets/cube.fbx" ), 
                                      texture = make_texture( "assets/texture_01.png" ) } )

  sphere_idx := len(data.entity_arr)
  append( &data.entity_arr, entity_t{ pos = {  0.0, 2, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 },
                                      mesh = mesh_load_fbx( "assets/sphere.fbx" ), 
                                      texture = make_texture( "assets/blank.png" ) } )

  suzanne_idx := len(data.entity_arr)
  append( &data.entity_arr, entity_t{ pos = { 2.5, 2, 0 }, rot = { 0, 0, 0 }, scl = { 1, 1, 1 }, 
                                      mesh = mesh_load_fbx( "assets/suzanne.fbx" ), 
                                      texture = make_texture( "assets/blank.png" ) } )
    
  gl.UseProgram( data.global_shader )
  // defer gl.BindVertexArray(0)
  gl.Enable( gl.DEPTH_TEST )

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

    // move entities
    data.entity_arr[cube_idx].pos.y    = math.sin_f32( data.total_t ) +2
    data.entity_arr[sphere_idx].pos.y  = math.sin_f32( data.total_t ) +2
    data.entity_arr[sphere_idx].pos.z  = math.sin_f32( data.total_t *2 )
    data.entity_arr[suzanne_idx].pos.z = math.sin_f32( data.total_t )

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
      gl.UniformMatrix4fv(gl.GetUniformLocation(data.global_shader, "view"),      1, gl.FALSE, &data.cam.view_mat[0][0])
      gl.UniformMatrix4fv(gl.GetUniformLocation(data.global_shader, "proj"),      1, gl.FALSE, &data.cam.pers_mat[0][0])
      
      gl.Uniform3f(gl.GetUniformLocation(data.global_shader, "light_pos"), 0, 5, -2)
      
      gl.ActiveTexture( gl.TEXTURE0 )
      gl.BindTexture( gl.TEXTURE_2D, e.texture )
      gl.Uniform1i( gl.GetUniformLocation(data.global_shader, "tex"), 0 )

      gl.DrawElements(gl.TRIANGLES,             // Draw triangles.
                      i32(e.mesh.indices_len),  // Draw 36 vertices.
                      gl.UNSIGNED_INT,          // Data type of the indices.
                      rawptr(uintptr(0)))       // Pointer to indices. (Not needed.)
    }

    ui_update()

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

  ui_cleanup()

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

make_shader :: proc()
{
  // Compile vertex shader and fragment shader.
  // Note how much easier this is in Odin than in C++!
  program_ok      : bool
  vertex_shader   := string( #load( "../assets/basic.vert"   ) )
  fragment_shader := string( #load( "../assets/basic.frag" ) )

  data.global_shader, program_ok = gl.load_shaders_source( vertex_shader, fragment_shader )

  if ( !program_ok )
  {
    fmt.println( "ERROR: Failed to load and compile shaders." )
    os.exit( 1 )
  }
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

