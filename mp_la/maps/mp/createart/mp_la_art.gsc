
main()
{
	level.tweakfile = 1;
	setdvar( "scr_fog_exp_halfplane", "3759.28" );
	setdvar( "scr_fog_exp_halfheight", "243.735" );
	setdvar( "scr_fog_nearplane", "601.593" );
	setdvar( "scr_fog_red", "0.806694" );
	setdvar( "scr_fog_green", "0.962521" );
	setdvar( "scr_fog_blue", "0.9624" );
	setdvar( "scr_fog_baseheight", "-475.268" );
	setdvar( "visionstore_glowTweakEnable", "0" );
	setdvar( "visionstore_glowTweakRadius0", "5" );
	setdvar( "visionstore_glowTweakRadius1", "" );
	setdvar( "visionstore_glowTweakBloomCutoff", "0.5" );
	setdvar( "visionstore_glowTweakBloomDesaturation", "0" );
	setdvar( "visionstore_glowTweakBloomIntensity0", "1" );
	setdvar( "visionstore_glowTweakBloomIntensity1", "" );
	setdvar( "visionstore_glowTweakSkyBleedIntensity0", "" );
	setdvar( "visionstore_glowTweakSkyBleedIntensity1", "" );
	start_dist = 740,262;
	half_dist = 4113,21;
	half_height = 1651,45;
	base_height = -80,5565;
	fog_r = 0,372549;
	fog_g = 0,454902;
	fog_b = 0,447059;
	fog_scale = 7,39106;
	sun_col_r = 1;
	sun_col_g = 0,686275;
	sun_col_b = 0,337255;
	sun_dir_x = -0,196011;
	sun_dir_y = 0,785122;
	sun_dir_z = 0,587506;
	sun_start_ang = 0;
	sun_stop_ang = 61,3208;
	time = 0;
	max_fog_opacity = 1;
	setvolfog( start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale, sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, sun_stop_ang, time, max_fog_opacity );
	visionsetnaked( "mp_la", 0 );
}
