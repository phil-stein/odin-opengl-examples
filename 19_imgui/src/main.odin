package main

import        "core:fmt"
import        "core:c"
import        "core:time"
import        "core:math"
import linalg "core:math/linalg/glsl"
import        "core:os"
import        "core:runtime"
import        "vendor:glfw"
import gl     "vendor:OpenGL"

import "core"


global_vao    : u32
global_shader : u32
watch         : time.Stopwatch

tab_pressed_last_frame : bool = false
wireframe_mode_enabled : bool = false

scl : linalg.vec2 = { 0.5, 0.5 } 

main :: proc() 
{
  if ( !core.window_create( 1500, 1150, "title", core.WINDOW_TYPE.MINIMIZED, true ) )
  {
    fmt.print( "failed to create window\n" )
    return;
  }
  ui_init()
  
  indices_len := make_cube()
  make_shader()

  gl.UseProgram( global_shader )
  gl.BindVertexArray( global_vao )
  // defer gl.BindVertexArray(0)

  model : linalg.mat4
  view  : linalg.mat4
  pers  : linalg.mat4
  turntable_view_mat :: proc( radius, speed: f32 ) -> ( view: linalg.mat4 )
  {
    cam_x := math.sin_f32( f32(glfw.GetTime()) * speed ) * radius  
  	cam_z := math.cos_f32( f32(glfw.GetTime()) * speed ) * radius  
  
  	pos    : linalg.vec3 = { cam_x, 0.0, cam_z }
  	center : linalg.vec3 = { 0.0, 0.0, 0.0 }
  	up     : linalg.vec3 = { 0.0, 1.0, 0.0 }
  	return linalg.mat4LookAt(pos, center, up)
  }
  get_front :: proc( pitch_rad, yaw_rad: f32 ) -> ( front: linalg.vec3 )
  {
    // f32 pitch_rad = core_data->cam.pitch_rad + core_data->cam.pitch_shake_rad;
    // f32 yaw_rad   = core_data->cam.yaw_rad   + core_data->cam.yaw_shake_rad;
  	front.x = math.cos_f32(yaw_rad) * math.cos_f32(pitch_rad)
  	front.y = math.sin_f32(pitch_rad)
  	front.z = math.sin_f32(yaw_rad) * math.cos_f32(pitch_rad);
    return
  }
  view_mat :: proc() -> ( view: linalg.mat4 )
  {
    // vec3_copy(VEC3_Y(1), up);
    // up : linalg.vec3 = { 0, 1, 0 }
    up : linalg.vec3 = { 0.4 , 0.88, -0.24 }
    // camera_get_front(front);
    front := get_front( -0.48, 12.02 )
    // fmt.println( "front: ", front )

    pos : linalg.vec3 = { -8, 5, 5 }

  	// vec3_add(core_data->cam.pos, front, center);
    center := pos + front
    // fmt.println( "center: ", center )

  	// mat4_lookat(core_data->cam.pos, center, up, view);
  	return linalg.mat4LookAt(pos, center, up)
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

    return
  }
  // view = turntable_view_mat( 10.0 ) 
  pers = linalg.mat4Perspective(45.0 * math.PI / 180.0, 1000.0 / 750.0, 0.1, 1000)
  // pers = linalg.mat4Perspective( 45.0 * math.PI / 180.0, 750.0 / 1000.0, 0.1, 1000 )
  model = make_model( { 0, 0, 0 }, { 0, 0, 0 }, { 1, 1, 1 } )
  // model = linalg.mat4Translate( { 0, 0, 0 } )

  fmt.println( "model[0]: ", model[0] )
  fmt.println( "model[1]: ", model[1] )
  fmt.println( "model[2]: ", model[2] )
  fmt.println( "model[3]: ", model[3] )

  // pers[0][0] = 1.36
  fmt.println( "pers[0]: ", pers[0] )
  fmt.println( "pers[1]: ", pers[1] )
  fmt.println( "pers[2]: ", pers[2] )
  fmt.println( "pers[3]: ", pers[3] )


  for ( !core.window_should_close() )
  {
    glfw.PollEvents();

    // if ( cast(bool)glfw.GetKey( core.window, glfw.KEY_ESCAPE ) )
    if ( bool(glfw.GetKey( core.window, glfw.KEY_ESCAPE )) )
    { break; }

    if ( !tab_pressed_last_frame && 
         bool(glfw.GetKey( core.window, glfw.KEY_TAB )) )
    { 
      wireframe_mode_enabled  = !wireframe_mode_enabled 
      tab_pressed_last_frame = true
    }
    else if ( !bool(glfw.GetKey( core.window, glfw.KEY_TAB )) )
    { tab_pressed_last_frame = false }

    // gl.ClearColor( 0.0, 1.0, 1.0, 1.0 )
    gl.ClearColor( 0.0, 0.0, 0.0, 1.0 )
    gl.Clear( gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT )
    gl.Disable( gl.DEPTH_TEST )

    // wireframe mode
    if ( wireframe_mode_enabled == true )
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE) }
	  else
	  { gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL) }

    // -- draw triangle --
    // gl.UseProgram( global_shader )
    // gl.BindVertexArray( global_vao )
  
    view = turntable_view_mat( 10.0, 1.0 ) 
    // view = view_mat() 
    // fmt.println( "view[0]: ", view[0] )
    // fmt.println( "view[1]: ", view[1] )
    // fmt.println( "view[2]: ", view[2] )
    // fmt.println( "view[3]: ", view[3] )

    gl.UniformMatrix4fv(gl.GetUniformLocation(global_shader, "model"), 1, gl.FALSE, &model[0][0])
    gl.UniformMatrix4fv(gl.GetUniformLocation(global_shader, "view"),  1, gl.FALSE, &view[0][0])
    gl.UniformMatrix4fv(gl.GetUniformLocation(global_shader, "proj"),  1, gl.FALSE, &pers[0][0])

    gl.DrawElements(gl.TRIANGLES,         // Draw triangles.
                    indices_len,          // Draw 36 vertices.
                    gl.UNSIGNED_INT,      // Data type of the indices.
                    rawptr(uintptr(0)))   // Pointer to indices. (Not needed.)

    ui_update()


    glfw.SwapBuffers( core.window )
  }

  ui_cleanup()
  glfw.DestroyWindow( core.window )
  glfw.Terminate()
}

make_cube :: proc() -> ( indices_len: i32 )
{
  vertices := [?]f32 { 
    // pos,       uvs 
    -1, -1, -1,   0, 0,
    +1, -1, -1,   0, 0,
    -1, +1, -1,   0, 0,
    +1, +1, -1,   0, 0,

    -1, -1, +1,   0, 0,
    +1, -1, +1,   0, 0,
    -1, +1, +1,   0, 0,
    +1, +1, +1,   0, 0,

    -1, -1, -1,   0, 0,
    -1, +1, -1,   0, 0,
    -1, -1, +1,   0, 0,
    -1, +1, +1,   0, 0,

    +1, -1, -1,   0, 0,
    +1, +1, -1,   0, 0,
    +1, -1, +1,   0, 0,
    +1, +1, +1,   0, 0,

    -1, -1, -1,   0, 0,
    +1, -1, -1,   0, 0,
    -1, -1, +1,   0, 0,
    +1, -1, +1,   0, 0,

    -1, +1, -1,   0, 0,
    +1, +1, -1,   0, 0,
    -1, +1, +1,   0, 0,
    +1, +1, +1,   0, 0,
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
