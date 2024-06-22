package core

import        "core:fmt"
import        "core:c"
import        "core:time"
import        "core:math"
import linalg "core:math/linalg/glsl"
import        "core:os"
import        "core:runtime"
import        "vendor:glfw"
import gl     "vendor:OpenGL"
import        "core:image"
import        "core:image/png"



global_vao    : u32
global_shader : u32
watch         : time.Stopwatch

wireframe_mode_enabled : bool = false

// @TODO: how to best structure the project ???
//        src\
//             main.odin
//             core\
//                   input.odin
//                   window.odin
//                   data.odin
//        or ----------------------------------
//        src\
//             main.odin
//             engine\
//                     input\
//                             input.odin
//                     window\
//                             window.odin
//                     data\
//                             data.odin
//        or ----------------------------------
//        src\
//             main.odin
//             engine\
//                     io\
//                         input.odin
//                         window.odin
//                         data.odin
//        or ----------------------------------
//        src\
//             main.odin
//             input.odin
//             window.odin
//             data.odin


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
  
  indices_len := make_cube()
  make_shader()
  texture_handle := make_texture( "assets/texture_01.png" )

  gl.UseProgram( global_shader )
  gl.BindVertexArray( global_vao )
  defer gl.BindVertexArray(0)
  gl.Enable( gl.DEPTH_TEST )

  model : linalg.mat4
  model = make_model( { 0, 0, 0 }, { 0, 0, 0 }, { 1, 1, 1 } )
  camera_set_pers_mat( 1000, 750 )


  for ( !window_should_close() )
  {
    glfw.PollEvents();
      
    data_pre_updated()
      
    camera_rotate_by_mouse()
    camera_move_by_keys()

    if ( keystates[KEY.ESCAPE].pressed )
    { break }

    if ( keystates[KEY.TAB].pressed )
    { wireframe_mode_enabled  = !wireframe_mode_enabled }

    // gl.ClearColor( 0.0, 1.0, 1.0, 1.0 )
    gl.ClearColor( 0.0, 0.0, 0.0, 1.0 )
    gl.Clear( gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT )

    // wireframe mode
    if ( wireframe_mode_enabled == true )
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE) }
	  else
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL) }

    // -- draw triangle --
    // gl.UseProgram( global_shader )
    // gl.BindVertexArray( global_vao )
  
    // view = core.camera_turntable_view_mat( 10.0, 1.0 ) 
    camera_set_view_mat() 

    gl.UniformMatrix4fv(gl.GetUniformLocation(global_shader, "model"), 1, gl.FALSE, &model[0][0])
    gl.UniformMatrix4fv(gl.GetUniformLocation(global_shader, "view"),  1, gl.FALSE, &view_mat[0][0])
    gl.UniformMatrix4fv(gl.GetUniformLocation(global_shader, "proj"),  1, gl.FALSE, &pers_mat[0][0])
    
    gl.ActiveTexture( gl.TEXTURE0 )
    gl.BindTexture( gl.TEXTURE_2D, texture_handle )
    gl.Uniform1i( gl.GetUniformLocation(global_shader, "tex"), 0 )

    gl.DrawElements(gl.TRIANGLES,         // Draw triangles.
                    indices_len,          // Draw 36 vertices.
                    gl.UNSIGNED_INT,      // Data type of the indices.
                    rawptr(uintptr(0)))   // Pointer to indices. (Not needed.)

    glfw.SwapBuffers( window )

    data_post_update()
    input_update()
  }

  glfw.DestroyWindow( window )
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

make_cube :: proc() -> ( indices_len: i32 )
{
  vertices := [?]f32 { 
    // pos,       uvs 
    -1, -1, -1,   0, 0,
    +1, -1, -1,   1, 0,
    -1, +1, -1,   0, 1,
    +1, +1, -1,   1, 1,

    -1, -1, +1,   0, 0,
    +1, -1, +1,   1, 0,
    -1, +1, +1,   0, 1,
    +1, +1, +1,   1, 1,

    -1, -1, -1,   0, 0,
    -1, +1, -1,   1, 0,
    -1, -1, +1,   0, 1,
    -1, +1, +1,   1, 1,

    +1, -1, -1,   0, 0,
    +1, +1, -1,   1, 0,
    +1, -1, +1,   0, 1,
    +1, +1, +1,   1, 1,
                       
    -1, -1, -1,   0, 0,
    +1, -1, -1,   1, 0,
    -1, -1, +1,   0, 1,
    +1, -1, +1,   1, 1,
                       
    -1, +1, -1,   0, 0,
    +1, +1, -1,   1, 0,
    -1, +1, +1,   0, 1,
    +1, +1, +1,   1, 1,
  }
  // index_array : [3 * 2 * 6] u32
  // index_array = {
  index_array := [?]u32 {
    0,  1,   2,  1,  2,  3, // Face 1
    4,  5,   6,  5,  6,  7, // Face 2
    8,  9,  10,  9, 10, 11, // Face 3
    12, 13, 14, 13, 14, 15, // Face 4
    16, 17, 18, 17, 18, 19, // Face 5
    20, 21, 22, 21, 22, 23, // Face 6
  }
  // fmt.println( "sizeof: ", size_of(index_array) )
  // fmt.println( "len: ", len(index_array) )
  indices_len = len(index_array)


  // Set up vertex array / element array / buffer objects
  gl.GenVertexArrays(1, &global_vao)
  gl.BindVertexArray(global_vao)

  vbo : u32 
  gl.GenBuffers(1, &vbo)
  gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

  ebo : u32 
  gl.GenBuffers(1, &ebo)
  gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
  
  // Describe GPU buffer.
  gl.BufferData(gl.ARRAY_BUFFER,     // target
                size_of(vertices),   // size of the buffer object's data store
                &vertices,           // data used for initialization
                gl.STATIC_DRAW)      // usage

  gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(index_array), &index_array, gl.STATIC_DRAW)

  // Position and color attributes. Don't forget to enable!
  gl.VertexAttribPointer(0,                   // index
                         3,                   // size
                         gl.FLOAT,            // type
                         gl.FALSE,            // normalized
                         5 * size_of(f32),    // stride
                         0)                   // offset
  
  gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 3 * size_of(f32))

  // Enable the vertex position and color attributes defined above.
  gl.EnableVertexAttribArray(0)
  gl.EnableVertexAttribArray(1)

  return
}

make_shader :: proc()
{
  // Compile vertex shader and fragment shader.
  // Note how much easier this is in Odin than in C++!
  program_ok      : bool
  vertex_shader   := string( #load( "../assets/basic.vert"   ) )
  fragment_shader := string( #load( "../assets/basic.frag" ) )

  global_shader, program_ok = gl.load_shaders_source( vertex_shader, fragment_shader )

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

