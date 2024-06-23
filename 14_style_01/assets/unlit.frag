#version 460 core

out vec4 FragColor;

//passed from vertex-shader
in VS_OUT
{
  vec2 uv_coords;
  vec3 frag_pos;
  vec3 normal;
  mat3 TBN;
} _in;

// uniform vec3 tint;
uniform sampler2D tex;

void main()
{
  // vec3 normal;
  // normal = texture(norm, _in.uv_coords).rgb;
  // normal = normalize(normal * 2.0 - 1.0);
  // normal = normalize(_in.TBN * normal);
  // // vec4 normal = vec4(_normal, 1.0);

  vec3 obj_color   = texture(tex, _in.uv_coords.xy).rgb; // * vec4(tint.rgb, 1.0);
  // vec3 obj_color   = vec3( 1.0 ); 
  FragColor      = vec4( obj_color, 1.0 );

  // FragColor      = vec4( diffuse, 1.0 );
  // FragColor      = vec4( cell, 1.0 );


  // FragColor = texture(tex, _in.uv_coords.xy); // * vec4(tint.rgb, 1.0);
  // FragColor = vec4( _in.uv_coords.xy, 0.0, 1.0 );
  // FragColor = vec4( 1.0 );
  // FragColor = vec4( normalize(_in.normal), 1.0 );
}
