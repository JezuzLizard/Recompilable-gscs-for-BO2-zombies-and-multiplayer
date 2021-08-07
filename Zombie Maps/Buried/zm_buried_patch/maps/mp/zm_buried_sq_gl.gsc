#include maps/mp/zm_buried_sq;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	flag_init( "sq_gl_lantern_aquired" );
	declare_sidequest_stage( "sq", "gl", ::init_stage, ::stage_logic, ::exit_stage );
	level thread sq_gl_setup_buildable_trig();
}

sq_gl_setup_buildable_trig()
{
	while ( !isDefined( level.sq_lamp_generator_unitrig ) )
	{
		wait 1;
	}
	level.sq_lamp_generator_unitrig.realorigin = level.sq_lamp_generator_unitrig.origin;
	level.sq_lamp_generator_unitrig.origin += vectorScale( ( 0, 0, 1 ), 10000 );
}

init_stage()
{
	s_start = getstruct( "sq_ghost_lamp_start", "script_noteworthy" );
	gl_lantern_spawn( s_start );
	if ( flag( "sq_is_max_tower_built" ) )
	{
		level thread stage_vo_max();
	}
	else
	{
		level thread stage_vo_ric();
	}
	level._cur_stage_name = "gl";
	clientnotify( "gl" );
}

stage_logic()
{
/#
	iprintlnbold( "GL Started" );
#/
	s_start = getstruct( "sq_ghost_lamp_start", "script_noteworthy" );
	gl_lantern_move( s_start );
	flag_wait( "sq_gl_lantern_aquired" );
	wait_network_frame();
	stage_completed( "sq", level._cur_stage_name );
}

exit_stage( success )
{
}

stage_vo_max()
{
	level waittill( "lantern_crashing" );
	maxissay( "vox_maxi_sidequest_gl_2", level.vh_lantern );
}

stage_vo_ric()
{
	richtofensay( "vox_zmba_sidequest_gl_0", 8 );
	level waittill( "lantern_crashing" );
	richtofensay( "vox_zmba_sidequest_gl_1", 6 );
}

gl_lantern_spawn( s_start )
{
	level.vh_lantern = spawnvehicle( "tag_origin", "ghost_lantern_ai", "heli_quadrotor2_zm", s_start.origin, ( 0, 0, 1 ) );
	level.vh_lantern makevehicleunusable();
	level.vh_lantern setneargoalnotifydist( 128 );
	level.vh_lantern.m_lantern = spawn( "script_model", level.vh_lantern.origin );
	level.vh_lantern.m_lantern setmodel( "p6_zm_bu_lantern_silver_on" );
	level.vh_lantern.m_lantern linkto( level.vh_lantern, "tag_origin" );
	playfxontag( level._effect[ "sq_glow" ], level.vh_lantern.m_lantern, "tag_origin" );
	level.vh_lantern.m_lantern playsound( "zmb_sq_glantern_impact" );
	level.vh_lantern.m_lantern playloopsound( "zmb_sq_glantern_full_loop_3d" );
	level.vh_lantern thread gl_lantern_damage_watcher();
	wait_network_frame();
}

gl_lantern_delete()
{
	if ( isDefined( level.vh_lantern ) )
	{
		if ( isDefined( level.vh_lantern.m_lantern ) )
		{
			level.vh_lantern.m_lantern delete();
		}
		if ( isDefined( level.vh_lantern.t_pickup ) )
		{
			level.vh_lantern.t_pickup delete();
		}
		level.vh_lantern cancelaimove();
		level.vh_lantern clearvehgoalpos();
		if ( isDefined( level.vh_lantern.m_link ) )
		{
			level.vh_lantern.m_link delete();
		}
		level.vh_lantern delete();
	}
}

gl_lantern_move( s_current )
{
	level endon( "lantern_crashing" );
	while ( 1 )
	{
		s_current = gl_lantern_get_next_struct( s_current );
		if ( flag( "sq_is_max_tower_built" ) )
		{
			if ( randomint( 100 ) < 50 )
			{
				s_current = level.vh_lantern gl_lantern_teleport();
			}
		}
		level.vh_lantern gl_lantern_move_to_struct( s_current );
	}
}

gl_lantern_get_next_struct( s_current )
{
	a_struct_links = [];
	a_target_structs = getstructarray( s_current.target, "targetname" );
	while ( isDefined( s_current.script_string ) )
	{
		a_names = strtok( s_current.script_string, " " );
		_a171 = a_names;
		_k171 = getFirstArrayKey( _a171 );
		while ( isDefined( _k171 ) )
		{
			str_name = _a171[ _k171 ];
			a_new_structs = getstructarray( str_name, "targetname" );
			a_target_structs = arraycombine( a_target_structs, a_new_structs, 0, 0 );
			_k171 = getNextArrayKey( _a171, _k171 );
		}
	}
	return array_randomize( a_target_structs )[ 0 ];
}

gl_lantern_move_to_struct( s_goto )
{
	self endon( "death" );
	self endon( "delete" );
	self setvehgoalpos( s_goto.origin, 1 );
	self pathvariableoffset( vectorScale( ( 0, 0, 1 ), 128 ), 1 );
	self waittill_either( "goal", "near_goal" );
}

gl_lantern_teleport()
{
	self notify( "lantern_teleporting" );
	playfx( level._effect[ "fx_wisp_lg_m" ], self.origin );
	playsoundatposition( "zmb_sq_glantern_impact", self.origin );
	gl_lantern_delete();
	a_path_spots = getstructarray( "sq_ghost_lamp_path", "script_noteworthy" );
	s_teleport_spot = array_randomize( a_path_spots )[ 0 ];
	gl_lantern_spawn( s_teleport_spot );
	return s_teleport_spot;
}

gl_lantern_damage_watcher()
{
	self.m_lantern endon( "delete" );
	self.m_lantern setcandamage( 1 );
	while ( 1 )
	{
		self.m_lantern waittill( "damage", amount, attacker, dir, point, dmg_type );
		if ( dmg_type == "MOD_GRENADE" || dmg_type == "MOD_GRENADE_SPLASH" )
		{
			break;
		}
		else
		{
		}
	}
	self.m_lantern playsound( "zmb_sq_glantern_impact" );
	self gl_lantern_crash_movement();
	self thread gl_lantern_pickup_watch();
	self thread gl_lantern_stop_spin_on_land();
	level thread gl_lantern_respawn_wait();
	level waittill( "gl_lantern_respawn" );
	if ( isDefined( self.m_lantern ) )
	{
		s_start_spot = gl_lantern_teleport();
		gl_lantern_move( s_start_spot );
	}
}

gl_lantern_stop_spin_on_land()
{
	self endon( "delete" );
	while ( isDefined( self ) && length( self.velocity ) > 3 )
	{
		wait 0,1;
	}
	if ( isDefined( self ) )
	{
		self.m_link = spawn( "script_model", self.origin );
		self.m_link setmodel( "tag_origin" );
		self linkto( self.m_link );
	}
}

gl_lantern_respawn_wait()
{
	wait 30;
	level notify( "gl_lantern_respawn" );
}

gl_lantern_pickup_watch()
{
	self endon( "lantern_teleporting" );
	self.t_pickup = spawn( "trigger_radius_use", self.origin, 0, 48, 32 );
	self.t_pickup setcursorhint( "HINT_NOICON" );
	self.t_pickup sethintstring( &"ZM_BURIED_SQ_LANTERN_G" );
	self.t_pickup triggerignoreteam();
	self.t_pickup enablelinkto();
	self.t_pickup linkto( self );
	self.t_pickup waittill( "trigger", player );
	player player_take_piece( level.zombie_buildables[ "buried_sq_oillamp" ].buildablepieces[ 0 ] );
	piece = player player_get_buildable_piece( 2 );
	if ( isDefined( piece ) )
	{
		piece.sq_is_ghost_lamp = 1;
		piece.start_origin = vectorScale( ( 0, 0, 1 ), 512 );
		piece.start_angles = ( 0, 0, 1 );
	}
	self.t_pickup delete();
	self.m_lantern delete();
	self delete();
	flag_set( "sq_gl_lantern_aquired" );
}

gl_lantern_crash_movement()
{
	level notify( "lantern_crashing" );
	self cancelaimove();
	self clearvehgoalpos();
	self setphysacceleration( vectorScale( ( 0, 0, 1 ), 800 ) );
	hitdir = ( 0, 0, 1 );
	side_dir = vectorcross( hitdir, ( 0, 0, 1 ) );
	side_dir_mag = randomfloatrange( -100, 100 );
	side_dir_mag += sign( side_dir_mag ) * 80;
	side_dir *= side_dir_mag;
	self setvehvelocity( self.velocity + vectorScale( ( 0, 0, 1 ), 100 ) + vectornormalize( side_dir ) );
	ang_vel = self getangularvelocity();
	ang_vel = ( ang_vel[ 0 ] * 0,3, ang_vel[ 1 ], ang_vel[ 2 ] * 0,3 );
	yaw_vel = randomfloatrange( 0, 210 ) * sign( ang_vel[ 1 ] );
	yaw_vel += sign( yaw_vel ) * 180;
	ang_vel += ( randomfloatrange( -1, 1 ), yaw_vel, randomfloatrange( -1, 1 ) );
	self setangularvelocity( ang_vel );
	self.crash_accel = randomfloatrange( 75, 110 );
}
