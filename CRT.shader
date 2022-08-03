shader_type canvas_item;

uniform vec2 screenSize = vec2(272.0, 160.0);

uniform bool useBlur = true;
uniform float blurBrightness = 1.0;
uniform float blurContrast = 1.0;
uniform float blurSaturation = 1.0;
uniform float blurAmount : hint_range(0.0, 10.0, 0.1) = float(0.0);
uniform float blurMix : hint_range(0.0, 1.0, 0.01) = float(0.5);

uniform bool useCurvature = true;
uniform float curvatureX : hint_range(3.0, 15.0, 0.01) = float(6.0); 
uniform float curvatureY : hint_range(3.0, 15.0, 0.01) = float(4.0);
uniform vec4 borderColor : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float borderMix :  hint_range(0.0, 1.0, 0.01) = float(0.25);
uniform float borderBlur : hint_range(0.0, 10.0, 0.1) = float(3.0);
//uniform float borderPow : hint_range(0.0, 2.0, 0.01) = float(0.5);
//uniform float borderMul : hint_range(0.0, 5.0, 0.1) = float(3.0);


uniform bool useVignette = true;
uniform float vignetteValue : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float scanForce : hint_range(0.0, 1.0, 0.01) = float(0.2);
uniform float grilleForce : hint_range(0.0, 1.0, 0.01) = float(0.2);
uniform float grilleYOddOffset : hint_range(0.0, 0.5, 0.1) = float(0.0);

uniform vec2 chromaticPixel  = vec2(0.0);

const float Tau = 6.28318530718;

vec3 blur(sampler2D  tex, vec2 uv) {
	vec3 col;
	col.r = textureLod(tex,vec2( uv.x + 1.0/screenSize.x * chromaticPixel.x,
            		uv.y - 1.0/screenSize.y * chromaticPixel.y),blurAmount ).r;
	col.g = textureLod(tex,vec2(uv.x,	uv.y ), blurAmount).g;
	col.b = textureLod(tex,vec2(uv.x - 1.0/screenSize.x * chromaticPixel.x,
		        	uv.y + 1.0/screenSize.y * chromaticPixel.y),blurAmount).b;
	if (useBlur)
	{
		//vec3 col = textureLod(tex, uv, blurAmount).rgb;
		col.rgb = mix(vec3(0.0), col.rgb, blurBrightness);
		col.rgb = mix(vec3(0.5), col.rgb, blurContrast);
		col.rgb = mix(vec3(dot(vec3(1.0), col.rgb) * 0.33333), col.rgb, blurSaturation);
		return col;
	}
	else{
		col = texture(tex, uv).rgb;
		return col;
	}
}

vec2 uv_curve(vec2 uv) {
	if (useCurvature) {
		uv = uv * 2.0 - 1.0;
		vec2 offset = abs(uv.yx) / vec2(curvatureX, curvatureY);
		uv = uv + uv * offset * offset;
		uv = uv * 0.5 + 0.5;
	}

	return uv;
}

vec3 hue2rgb(float hue) {
	if (hue == 0.0) return vec3(0.0);
	hue+=.75;
	hue = fract(hue); //only use fractional part of hue, making it loop
	float r = abs(hue * 6.0 - 3.0) - 1.0; //red
	float g = 2.0 - abs(hue * 6.0 - 2.0); //green
	float b = 2.0 - abs(hue * 6.0 - 4.0); //blue
	vec3 rgb = vec3(r,g,b); //combine components
	rgb = clamp(rgb,0.0,1.0); //clamp between 0 and 1
	return rgb;
}

void fragment() {
	
	vec2 uv = uv_curve(UV);
	vec2 screenUv = uv_curve(SCREEN_UV);
	
	vec3 blur = blur(SCREEN_TEXTURE, screenUv).rgb;
	vec3 color = texture(SCREEN_TEXTURE, screenUv).rgb;

color.r = texture(SCREEN_TEXTURE,vec2( screenUv.x + 1.0/screenSize.x * chromaticPixel.x,
            		screenUv.y - 1.0/screenSize.y * chromaticPixel.y) ).r;
color.g = texture(SCREEN_TEXTURE,vec2(screenUv.x,	screenUv.y )).g;
color.b = texture(SCREEN_TEXTURE,vec2(screenUv.x - 1.0/screenSize.x * chromaticPixel.x,
		        	screenUv.y + 1.0/screenSize.y * chromaticPixel.y)).b;

	
	vec3 result = mix(color, blur, blurMix);
	result = color + (blur * blurMix);

	float s2 = scanForce * scanForce * scanForce;
	float scansSin = clamp(s2 * sin(0.7853 + uv.y * screenSize.y * Tau), 0.0, 1.0);
	float scansCos = clamp(s2 * cos(0.7853 + uv.y * screenSize.y * Tau), 0.0, 1.0);
	float sSin = pow(scansSin,0.5);
	float sCos = pow(scansCos,0.5);
    result *= vec3(1.0-(sSin+sCos));

	float gf = grilleForce * grilleForce;
	float yOffset = (fract(uv.y * screenSize.y*0.5) < 0.5) ? 0.0 : grilleYOddOffset;
	float ramp = fract(yOffset+uv.x * screenSize.x);
	ramp *= 1.0 - step(ramp,0.125);
	result *= vec3(mix(hue2rgb(ramp), vec3(1.0), 1.0 - gf));
	
	if (useVignette) 
	{
		float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
		vignette = clamp(pow((screenSize.x / 4.0) * vignette, vignetteValue), 0.0, 1.0);
		result *= vignette;
	}

	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
	{
		vec3 borderB = textureLod(SCREEN_TEXTURE, screenUv, borderBlur).rgb;
		float r = (uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y)*-5.0);
		vec3 borderOut = vec3(clamp(pow((screenSize.x / 4.0) * r, 0.2), 0.0, 1.0));
		result = mix(borderB, borderColor.rgb, borderMix) * borderOut;
	}

	COLOR.rgb = result;
}