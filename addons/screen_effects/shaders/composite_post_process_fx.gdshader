shader_type canvas_item;

//---------------------------------------------------------------

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D viewport_texture;
uniform float screen_blur_amount: hint_range(0.0, 1.0) = 0.0;
uniform float radial_blur_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec2 radial_blur_center_position = vec2(0.5, 0.5);
uniform vec2 motion_blur_velocity = vec2(0.0, 0.0);

//---------------------------------------------------------------

void fragment()
{
	int lBlurSamples = 8;
	
	//////////////////////////////////////
	// Get screen color and apply simple global blur
	float fScreenBlur = 10.0 * screen_blur_amount;
	vec3 vScreenCol = texture(SCREEN_TEXTURE, SCREEN_UV, fScreenBlur).rgb;
	
	////////////////////////
	// Radial Blur
	vec2 vRadialBlurDirection = SCREEN_UV - radial_blur_center_position;
	float fRadialBlurPower = 0.025;

	////////////////////////////
	// Precompute division value
	float invBlurSamples = 1.0 / float(lBlurSamples - 1);

	for (int i = 0; i < lBlurSamples; ++i)
	{
		vec2 vBlurOffset = motion_blur_velocity * (float(i) * invBlurSamples - 0.5) + 
							radial_blur_amount * fRadialBlurPower * vRadialBlurDirection * float(i);
		
		//////////////////////////////////
		// Sample the screen and apply UVs
		vScreenCol += texture(SCREEN_TEXTURE, SCREEN_UV - vBlurOffset, fScreenBlur).rgb;
	}

	vScreenCol /= float(lBlurSamples);
	
	//////////////////
	// Output
	COLOR.rgb = vScreenCol;
	COLOR.a = 1.0;
}

//---------------------------------------------------------------
