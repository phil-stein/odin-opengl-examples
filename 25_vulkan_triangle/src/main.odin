package main

import        "core:fmt"
import        "core:c"
import        "core:time"
import        "core:math"
import        "core:os"
import        "base:runtime"
import win32  "core:sys/windows"
import        "vendor:glfw"
import vk     "vendor:vulkan"


when ODIN_DEBUG
{ enable_validation_layers := true 
} else {
  enable_validation_layers := false 
}
validation_layers: [dynamic]string

window_should_close : bool = false
window: glfw.WindowHandle
instance: vk.Instance 

vk_loader: win32.HMODULE

vk_get_instance_proc_addr: #type proc "system" (
    instance: vk.Instance, 
    pName: cstring,
) -> rawptr

set_proc_address :: proc(p: rawptr, name: cstring) 
{
  // Only load vkGetInstanceProcAddr the platform-specific way and then
  // load everything else with vkGetInstanceProcAddr or vkGetDeviceProcAddr
  if name == "vkGetInstanceProcAddr" {
    fptr := win32.GetProcAddress(vk_loader, name)
    (cast(^rawptr)p)^ = fptr
  } else {
    fptr := vk_get_instance_proc_addr(instance, name)
    (cast(^rawptr)p)^ = fptr
  }

  // An alternative way, less wordy - load everything the platform-specific way
  // fptr := win32.GetProcAddress(vk_loader, name)
  // (cast(^rawptr)p)^ = fptr
}

main :: proc() 
{
  fmt.println( "[VULKAN-TRIANGLE]" )

  append( &validation_layers, "VK_LAYER_KHRONOS_validation" ) 

  window_init( 800, 600 )
  fmt.println( "post window_init()" )

  vulkan_load()
  fmt.println( "post vulkan_load()" )

  vulkan_init()
  fmt.println( "post vulkan_init()" )

  for !glfw.WindowShouldClose( window ) 
  {
    glfw.PollEvents()
  }

  glfw.DestroyWindow( window );
  glfw.Terminate();
}

window_init :: proc( width, height: int )
{
  glfw.Init()

  if glfw.VulkanSupported() == false
  {
    fmt.eprintln( "[ERROR] glfw doesnt support vulkan" )
  }

  glfw.WindowHint( glfw.CLIENT_API, glfw.NO_API )
  glfw.WindowHint( glfw.RESIZABLE, glfw.FALSE )
  window = glfw.CreateWindow( i32(width), i32(height), "Vulkan", nil, nil )
}
vulkan_init :: proc()
{
  vulkan_create_instance()
}
vulkan_load :: proc()
{
  vk_loader = win32.LoadLibraryW(win32.utf8_to_wstring("vulkan-1.dll"))
  defer win32.FreeLibrary(vk_loader)

  assert(vk_loader != nil, "Couldn't find Vulkan loader")

  set_proc_address(&vk_get_instance_proc_addr, "vkGetInstanceProcAddr")
  vk.load_proc_addresses(set_proc_address)
}
vulkan_create_instance :: proc() 
{
  app_info : vk.ApplicationInfo
  app_info.sType = vk.StructureType.APPLICATION_INFO
  app_info.pApplicationName = "Hello Triangle";
  app_info.applicationVersion = vk.MAKE_VERSION(1, 0, 0);
  app_info.pEngineName = "No Engine";
  app_info.engineVersion = vk.MAKE_VERSION(1, 0, 0);
  app_info.apiVersion = vk.API_VERSION_1_0;

  create_info : vk.InstanceCreateInfo
  create_info.sType = vk.StructureType.INSTANCE_CREATE_INFO
  create_info.pApplicationInfo = &app_info;

  // glfw_extension_count := 0
  glfw_extensions := glfw.GetRequiredInstanceExtensions()

  fmt.println( "-> len(glfw_extensions):", len(glfw_extensions) )
  for e, i in glfw_extensions
  {
    fmt.printfln( "--> [%.2d]: %s", i, e )
  }

  create_info.enabledExtensionCount = u32(len(glfw_extensions))
  create_info.ppEnabledExtensionNames = raw_data(glfw_extensions);

  create_info.enabledLayerCount = 0;
 
  result := vk.CreateInstance( &create_info, nil, &instance )
  if result != vk.Result.SUCCESS
  {
    fmt.eprintln( "[ERROR] creating vulkan instance, error:", result )
    return
  }

  extension_count : u32 = 0
  vk.EnumerateInstanceExtensionProperties( nil, &extension_count, nil )
  extensions := make( []vk.ExtensionProperties, extension_count )
  defer delete( extensions )
  result = vk.EnumerateInstanceExtensionProperties(nil, &extension_count, raw_data(extensions) );
  if result != vk.Result.SUCCESS
  {
    fmt.eprintln( "[ERROR] getting vulkan extensions, error:", result )
    return
  }

  for &e, i in extensions
  {
    ptr := raw_data(&e.extensionName)
    fmt.printfln( "[VULKAN-EXTENSION] %s, version: %d", (cstring)(ptr), e.specVersion )
  }
}

bool checkValidationLayerSupport() {
    uint32_t layerCount;
    vkEnumerateInstanceLayerProperties(&layerCount, nullptr);

    std::vector<VkLayerProperties> availableLayers(layerCount);
    vkEnumerateInstanceLayerProperties(&layerCount, availableLayers.data());

    return false;
}


make_triangle :: proc()
{
  vertices : [15] f32 = {
      // Coordinates ; Colors
       0.0,  0.5,       1, 0, 0,
       0.5, -0.5,       0, 1, 0,
      -0.5, -0.5,       0, 0, 1,
  }

}

