package main

import "base:runtime"
import "core:fmt"
import "core:debug/trace"
import "core:mem"
import "core:reflect"


// setup debug/trace
global_trace_ctx: trace.Context
debug_trace_assertion_failure_proc :: proc(prefix, message: string, loc := #caller_location) -> ! 
{
	runtime.print_caller_location( loc )
	runtime.print_string( " " )
	runtime.print_string( prefix )
	if len(message) > 0 
  {
		runtime.print_string( ": " )
		runtime.print_string( message )
	}
	runtime.print_byte( '\n' )

	// ctx := &trace_ctx
	ctx := &global_trace_ctx
	if !trace.in_resolve( ctx ) 
  {
		buf: [64]trace.Frame
		runtime.print_string( "Debug Trace:\n" )
		frames := trace.frames( ctx, 1, buf[:] )
		for f, i in frames 
    {
			fl := trace.resolve( ctx, f, context.temp_allocator )
			if fl.loc.file_path == "" && fl.loc.line == 0 
      {
				continue
			}
			runtime.print_caller_location( fl.loc )
			runtime.print_string( " - frame " )
			runtime.print_int( i )
			runtime.print_byte( '\n' )
		}
	}
	runtime.trap()
}


test_t :: struct
{
  i_00 : int,
  i_01 : int,
  i_02 : int,

  f_00 : f32,

  str_00 : string,
}
test := test_t{
  i_00 = 1,
  i_01 = 2,
  i_02 = 3,

  f_00 = 1.23456,

  str_00 = "cock",
}

struct_a_t :: struct
{
  i_00 : int,
  i_01 : int,
  i_02 : int,

  f_00 : f32,

  str_00 : string,
  
  arr : [3]int,

  var : u32,
  
  b : struct_b_t,
  
}
struct_b_t :: struct
{
  i_00 : int,
  f_00 : f32,
  arr  : [4]f32
}


main :: proc() 
{
  when ODIN_DEBUG 
  {
    // setup tracking allocator
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer 
    {
			if len(track.allocation_map) > 0 
      {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map 
        {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 
      {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array 
        {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}

    // init stack trace
	  trace.init(&global_trace_ctx)
	  defer trace.destroy(&global_trace_ctx)
	  context.assertion_failure_proc = debug_trace_assertion_failure_proc
	}

  print_struct_info( test_t, test ) 

  // set member value
  v := reflect.struct_field_value_by_name( test, "i_00" )
  (^int)(v.data)^ += 3
  fmt.println( "added 3 to i_00" )

  fmt.println( "" )
  print_struct_info( test_t, test ) 

  fmt.println( "" )
  for i in 0 ..< reflect.struct_field_count( test_t )
  {
    sf := reflect.struct_field_at( test_t, i )
    // fmt.println( sf )
    fmt.println( sf.name, ":", sf.type, ", offset:", sf.offset )
  }

  fmt.println( "----------------------------------------------" )

  _struct := struct_a_t{
    i_01 = 1,
    i_02 = 2,
    str_00 = "hello",
    arr = { 123, 3, 6 },
  }
  display_struct_members( _struct, "_struct" )

}
// simple
print_struct_info :: proc( T: typeid, value: any )
{
  // print <name> : <type> = <value>
  types_arr  := reflect.struct_field_types( T )
  names_arr  := reflect.struct_field_names( T )
  for t, i in types_arr
  {
    v := reflect.struct_field_value_by_name( value, names_arr[i] )
    fmt.println( names_arr[i], ":", t, "=", v , " | ", reflect.is_integer( t ) )
  }
}

// complex
display_struct_members :: proc( value: any, name: string, indent_idx := 1 )
{
  fmt.printfln( "%s : %s", name, value.id )

  types_arr  := reflect.struct_field_types( value.id )
  names_arr  := reflect.struct_field_names( value.id )
  for type, i in types_arr
  {
    v := reflect.struct_field_value_by_name( value, names_arr[i] )
    display_type_info( type, v, names_arr[i], indent_idx )
  }
}
display_any :: #force_inline proc( v: any, name: string, indent_idx := 0 )
{
  display_type_info( type_info_of( v.id ), v, name, indent_idx )
}
display_type_info :: proc( type: ^reflect.Type_Info, v: any, name: string, indent_idx := 0 )
{
  for i in 0 ..< indent_idx
  {
    fmt.print( "| " )
  }

  switch
  {
    case reflect.is_array( type ) || reflect.is_dynamic_array( type ):
    {
      for idx := 0; idx < reflect.length( v ); idx += 1
      { 
        val : any
        ok  : bool
        _idx := idx
        val, _idx, ok = reflect.iterate_array( v, &_idx )
        if !ok { break }
        fmt.print( "\r" ) // already printed the |, this overwrites it
        display_any( val, fmt.tprintf( "%s[%d]", name, idx ), indent_idx /* +1 */ )
      }
    }
    case reflect.is_struct( type ):
    {
      display_struct_members( v, name, indent_idx +1 )
    }
    case: 
    { fmt.printf( "%s : %s = %v, %d\n", name, type, v, indent_idx ) }
  }
}

