
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
	start_dist = 501,064;
	half_dist = 5397,69;
	half_height = 765,766;
	base_height = 3,88835;
	fog_r = 0,721569;
	fog_g = 0,803922;
	fog_b = 0,929412;
	fog_scale = 2,76409;
	sun_col_r = 1;
	sun_col_g = 1;
	sun_col_b = 1;
	sun_dir_x = 0,41452;
	sun_dir_y = 0,909807;
	sun_dir_z = 0,0206221;
	sun_start_ang = 0;
	sun_stop_ang = 104,831;
	time = 0;
	max_fog_opacity = 0,91391;
	setvolfog( start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale, sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, sun_stop_ang, time, max_fog_opacity );
	visionsetnaked( "mp_dockside", 0 );
}
