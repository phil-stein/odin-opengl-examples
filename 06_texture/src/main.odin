package main

import      "core:fmt"
import      "core:c"
import      "core:c/libc"
import      "core:time"
import      "core:math"
import m    "core:math/linalg/glsl"
import      "core:os"
import      "core:runtime"
import      "core:image"
import      "core:image/png"
import      "core:io"

import      "vendor:glfw"
import gl   "vendor:OpenGL"
import stbi "vendor:stb/image"

import "core"


global_vao     : u32
global_shader  : u32
texture_handle : u32

tab_pressed_last_frame : bool = false
wireframe_mode_enabled : bool = false

scl : m.vec2 = { 0.75, 0.75 } 

main :: proc() 
{
  if ( !core.window_create( 1250, 1250, "title", core.WINDOW_TYPE.MINIMIZED, true ) )
  {
    fmt.print( "failed to create window\n" )
    return;
  }
  
  make_quad()
  make_shader()
  // texture_handle := make_texture( "assets/texture_01.png", true, false )
  // texture_handle := make_texture()
  texture_handle := make_texture( "assets/texture_01.png" )

  gl.UseProgram( global_shader )
  gl.BindVertexArray( global_vao )
  // defer gl.BindVertexArray(0)

  for ( !core.window_should_close() )
  {
    glfw.PollEvents();

    // if ( cast(bool)glfw.GetKey( core.window, glfw.KEY_ESCAPE ) )
    if ( bool(glfw.GetKey( core.window, glfw.KEY_ESCAPE )) )
    { break }

    if ( !tab_pressed_last_frame && 
         bool(glfw.GetKey( core.window, glfw.KEY_TAB )) )
    { 
      wireframe_mode_enabled  = !wireframe_mode_enabled 
      tab_pressed_last_frame = true
    }
    else if ( !bool(glfw.GetKey( core.window, glfw.KEY_TAB )) )
    { tab_pressed_last_frame = false }

    gl.ClearColor( 0.0, 1.0, 1.0, 1.0 )
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
    gl.Uniform2f( gl.GetUniformLocation(global_shader, "scl"), scl.x, scl.y )
    gl.ActiveTexture( gl.TEXTURE0 )
    gl.BindTexture( gl.TEXTURE_2D, texture_handle )
    gl.Uniform1i( gl.GetUniformLocation(global_shader, "tex"), 0 )

    gl.DrawArrays( gl.TRIANGLES,    // Draw triangles.
                   0,               // Begin drawing at index 0.
                   6 )              // Use 3 indices.

    glfw.SwapBuffers( core.window )
  }

  glfw.DestroyWindow( core.window )
  glfw.Terminate()
}

make_quad :: proc()
{
  quad_verts := [?]f32 { 
	  // pos        uvs
	  -1.0,  1.0,   0.0, 1.0,
	  -1.0, -1.0,   0.0, 0.0,
	   1.0, -1.0,   1.0, 0.0,

	  -1.0,  1.0,   0.0, 1.0,
	   1.0, -1.0,   1.0, 0.0,
	   1.0,  1.0,   1.0, 1.0
	} 

  fmt.printfln("24 * size_of(f32): %d", 24 * size_of(f32))
  fmt.printfln( "sizeof(verts): %d", size_of(quad_verts) )
  // fmt.println( size_of(f32) )

  vbo : u32 
	gl.GenVertexArrays( 1, &global_vao )
	gl.GenBuffers( 1, &vbo )

  gl.BindVertexArray( global_vao )
  gl.BindBuffer( gl.ARRAY_BUFFER, vbo )

	gl.BufferData( gl.ARRAY_BUFFER, size_of(quad_verts), &quad_verts, gl.STATIC_DRAW ) // quad_verts is 24 long

	gl.EnableVertexAttribArray( 0 )
	gl.VertexAttribPointer( 0, 2, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 0 )
	gl.EnableVertexAttribArray( 1 )
	gl.VertexAttribPointer( 1, 2, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 2 * size_of(f32) )
}

make_shader :: proc()
{
  // Compile vertex shader and fragment shader.
  // Note how much easier this is in Odin than in C++!
  program_ok      : bool
  vertex_shader   := string( #load( "../assets/vertex.glsl"   ) )
  fragment_shader := string( #load( "../assets/fragment.glsl" ) )

  global_shader, program_ok = gl.load_shaders_source( vertex_shader, fragment_shader )

  if ( !program_ok )
  {
    fmt.println( "ERROR: Failed to load and compile shaders." )
    os.exit( 1 )
  }
}

// make_texture :: proc( path: cstring, flip_vertical: bool, srgb: bool ) -> ( handle: u32 )
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

// make_texture :: proc( path: cstring, flip_vertical: bool, srgb: bool ) -> ( handle: u32 )
// {
//   width, height, channel_num : c.int 
// 
//   // OpenGL has texture coordinates with (0, 0) on bottom
//   stbi.set_flip_vertically_on_load( c.int(flip_vertical) )
//   pixels : rawptr = stbi.load( path, &width, &height, &channel_num, 4 ) // , stbi.rgb_alpha)
//   defer stbi.image_free( pixels )
//   fmt.println( "path: ", path )
//   fmt.println( "width: ", width )
//   fmt.println( "height: ", height )
//   fmt.println( "channel_num: ", channel_num )
//   fmt.println( "pixels: ", pixels )
// 
//   assert( pixels != nil )
//  
//   // handle : u32 = 0
//   handle = 0 
// 
//   gl.GenTextures( 1, &handle )
//   gl.BindTexture( gl.TEXTURE_2D, handle )
// 
//   // no interpolation
//   // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//   gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST )
//   gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_WRAP_S,     gl.REPEAT )
//   gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_WRAP_T,     gl.REPEAT )
//  
//   gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR )
//   // glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, 0);
// 
//   assert( channel_num >= 1 )
//   assert( channel_num <= 4 )
//   gl_internal_format : i32 = 0;
//   gl_format          : u32 = 0;
//   switch ( channel_num )
//   {
//     case 1:
//       gl_internal_format = srgb ? gl.SRGB8 : gl.R8
//       gl_format = gl.RED
//       break
//     case 2:
//       gl_internal_format = gl.RG8
//       gl_format = gl.RG
//       break
//     case 3:
//       gl_internal_format = srgb ? gl.SRGB : gl.RGB
//       gl_format = gl.RGB
//       break
//     case 4:
//       gl_internal_format = srgb ? gl.SRGB_ALPHA : gl.RGBA
//       gl_format = gl.RGBA
//       break
//   }
//   assert( gl_format != 0 )
//   fmt.println( "gl_internal_format: ", gl_internal_format )
//   fmt.println( "gl_format: ", gl_format )
// 
//   // gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
// 
//   gl.TexImage2D( gl.TEXTURE_2D, 0, gl_internal_format, 
//                  width, height, 0, gl_format, gl.UNSIGNED_BYTE, pixels )
//   
//   // must be called after glTexImage2D
//   gl.GenerateMipmap( gl.TEXTURE_2D )
// 
//   return handle
// }


// -- old version of load texture --
// load_texture :: proc( path: cstring, flip_vertical: bool ) -> (width, height, channel_num: c.int, pixels: rawptr)
// {
//   // width, height, channel_num : c.int
//
//   // OpenGL has texture coordinates with (0, 0) on bottom
//   stbi.set_flip_vertically_on_load( c.int(flip_vertical) )
//   image := stbi.load( path, &width, &height, &channel_num, 4 ) // , stbi.rgb_alpha)
//   defer stbi.image_free( image )
//   fmt.println( "path: ", path )
//   fmt.println( "width: ", width )
//   fmt.println( "height: ", height )
//   fmt.println( "channel_num: ", channel_num )
//   fmt.println( "image: ", image )
//
//   assert( image != nil )
//
//   // // @TODO: use context.temp_allocator or some other odin allocator
//   // //        once i actually find documentation on that
//   // pixels : ^u8 = context.temp_allocator
//   // pixels : ^u8 = libc.malloc( cast(size_t)(width * height * 4) )
//   // assert( pixels != nil )
//   
//   pixels = libc.malloc( uint(width * height * 4) )
//   assert( pixels != nil )
//   libc.memcpy( pixels, image, uint(width * height * 4) )
//   assert( pixels != nil )
//
//   // stbi.image_free( image )
//
//   return
// }
//
// make_texture :: proc( path: cstring, flip_vertical: bool, srgb: bool ) -> ( handle: u32 )
// {
//   width, height, channel_num, pixels := load_texture( path, flip_vertical )
//   defer libc.free( pixels )
//  
//   // handle : u32 = 0
//   handle = 0 
//
//   gl.GenTextures( 1, &handle )
//   gl.BindTexture( gl.TEXTURE_2D, handle )
//
//   // no interpolation
//   // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//   gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST )
//   gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_WRAP_S,     gl.REPEAT )
//   gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_WRAP_T,     gl.REPEAT )
//  
//   gl.TexParameteri( gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR )
//   // glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, 0);
//
//   assert( channel_num >= 1 )
//   assert( channel_num <= 4 )
//   gl_internal_format : i32 = 0;
//   gl_format          : u32 = 0;
//   switch ( channel_num )
//   {
//     case 1:
//       gl_internal_format = srgb ? gl.SRGB8 : gl.R8
//       gl_format = gl.RED
//       break
//     case 2:
//       gl_internal_format = gl.RG8
//       gl_format = gl.RG
//       break
//     case 3:
//       gl_internal_format = srgb ? gl.SRGB : gl.RGB
//       gl_format = gl.RGB
//       break
//     case 4:
//       gl_internal_format = srgb ? gl.SRGB_ALPHA : gl.RGBA
//       gl_format = gl.RGBA
//       break
//   }
//   assert( gl_format != 0 )
//   fmt.println( "gl_internal_format: ", gl_internal_format )
//   fmt.println( "gl_format: ", gl_format )
//
//   // gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
//
//   gl.TexImage2D( gl.TEXTURE_2D, 0, gl_internal_format, 
//                  width, height, 0, gl_format, gl.UNSIGNED_BYTE, pixels )
//   
//   // must be called after glTexImage2D
//   // gl.GenerateMipmap( gl.TEXTURE_2D )
//
//   return handle
// }
