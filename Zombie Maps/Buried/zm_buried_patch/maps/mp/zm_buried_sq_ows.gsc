#include maps/mp/zm_buried_sq;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	flag_init( "sq_ows_start" );
	flag_init( "sq_ows_target_missed" );
	flag_init( "sq_ows_success" );
	declare_sidequest_stage( "sq", "ows", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
	if ( flag( "sq_is_max_tower_built" ) )
	{
		level thread stage_vo_max();
	}
	else
	{
		level thread stage_vo_ric();
	}
	level._cur_stage_name = "ows";
	clientnotify( "ows" );
}

stage_vo_max()
{
	m_lightboard = getent( "sq_bp_board", "targetname" );
	maxissay( "vox_maxi_sidequest_ip_4", m_lightboard );
}

stage_vo_ric()
{
	richtofensay( "vox_zmba_sidequest_ip_5", 8 );
	richtofensay( "vox_zmba_sidequest_ip_6", 8 );
	richtofensay( "vox_zmba_sidequest_ip_7", 11 );
}

stage_logic()
{
/#
	iprintlnbold( "OWS Started" );
#/
	while ( !flag( "sq_ows_success" ) )
	{
		level thread ows_fountain_wait();
		flag_wait( "sq_ows_start" );
		ows_targets_start();
		flag_clear( "sq_ows_start" );
	}
	stage_completed( "sq", level._cur_stage_name );
}

exit_stage( success )
{
}

ows_fountain_wait()
{
	level endon( "sq_ows_start" );
	s_fountain_spot = getstruct( "sq_ows_fountain", "targetname" );
	t_fountain = spawn( "trigger_radius_use", s_fountain_spot.origin, 0, 55, 64 );
	t_fountain setcursorhint( "HINT_NOICON" );
	t_fountain sethintstring( &"ZM_BURIED_SQ_FOUNT_U" );
	t_fountain triggerignoreteam();
	t_fountain usetriggerrequirelookat();
	t_fountain waittill( "trigger" );
	t_fountain playsound( "zmb_sq_coin_toss" );
	t_fountain delete();
	flag_set( "sq_ows_start" );
}

ows_targets_start()
{
	n_cur_second = 0;
	flag_clear( "sq_ows_target_missed" );
	level thread sndsidequestowsmusic();
	a_sign_spots = getstructarray( "otw_target_spot", "script_noteworthy" );
	while ( n_cur_second < 40 )
	{
		a_spawn_spots = ows_targets_get_cur_spots( n_cur_second );
		if ( isDefined( a_spawn_spots ) && a_spawn_spots.size > 0 )
		{
			ows_targets_spawn( a_spawn_spots );
		}
		wait 1;
		n_cur_second++;
	}
	if ( !flag( "sq_ows_target_missed" ) )
	{
		flag_set( "sq_ows_success" );
		playsoundatposition( "zmb_sq_target_success", ( 0, 0, 0 ) );
	}
	else
	{
		playsoundatposition( "zmb_sq_target_fail", ( 0, 0, 0 ) );
	}
	level notify( "sndEndOWSMusic" );
}

ows_targets_get_cur_spots( n_time )
{
	a_target_spots = getstructarray( "otw_target_spot", "script_noteworthy" );
	a_to_spawn = [];
	str_time = "" + n_time;
	_a133 = a_target_spots;
	_k133 = getFirstArrayKey( _a133 );
	while ( isDefined( _k133 ) )
	{
		s_spot = _a133[ _k133 ];
		if ( isDefined( s_spot.script_string ) )
		{
			a_spawn_times = strtok( s_spot.script_string, " " );
			if ( isinarray( a_spawn_times, str_time ) )
			{
				a_to_spawn[ a_to_spawn.size ] = s_spot;
			}
		}
		_k133 = getNextArrayKey( _a133, _k133 );
	}
	return a_to_spawn;
}

ows_targets_spawn( a_spawn_spots )
{
	_a151 = a_spawn_spots;
	_k151 = getFirstArrayKey( _a151 );
	while ( isDefined( _k151 ) )
	{
		s_spot = _a151[ _k151 ];
		m_target = spawn( "script_model", s_spot.origin );
		m_target.angles = s_spot.angles;
		m_target setmodel( "p6_zm_bu_target" );
		m_target ghost();
		wait_network_frame();
		m_target show();
		playfxontag( level._effect[ "sq_spawn" ], m_target, "tag_origin" );
		m_target playsound( "zmb_sq_target_spawn" );
		if ( isDefined( s_spot.target ) )
		{
			m_target thread ows_target_move( s_spot.target );
		}
		m_target thread ows_target_think();
		m_target thread sndhit();
		m_target thread sndtime();
		_k151 = getNextArrayKey( _a151, _k151 );
	}
}

ows_target_think()
{
	self setcandamage( 1 );
	self thread ows_target_delete_timer();
	self waittill_either( "ows_target_timeout", "damage" );
	if ( isDefined( self.m_linker ) )
	{
		self unlink();
		self.m_linker delete();
	}
	self rotatepitch( -90, 0,15, 0,05, 0,05 );
	self waittill( "rotatedone" );
	self delete();
}

ows_target_move( str_target )
{
	s_target = getstruct( str_target, "targetname" );
	self.m_linker = spawn( "script_model", self.origin );
	self.m_linker.angles = self.angles;
	self linkto( self.m_linker );
	self.m_linker moveto( s_target.origin, 4, 0,05, 0,05 );
}

ows_target_delete_timer()
{
	self endon( "death" );
	wait 4;
	self notify( "ows_target_timeout" );
	flag_set( "sq_ows_target_missed" );
/#
	iprintlnbold( "missed target! step failed. target @ " + self.origin );
#/
}

sndsidequestowsmusic()
{
	while ( is_true( level.music_override ) )
	{
		wait 0,1;
	}
	level.music_override = 1;
	level setclientfield( "mus_zmb_egg_snapshot_loop", 1 );
	ent = spawn( "script_origin", ( 0, 0, 0 ) );
	ent playloopsound( "mus_sidequest_ows" );
	level waittill( "sndEndOWSMusic" );
	level setclientfield( "mus_zmb_egg_snapshot_loop", 0 );
	level.music_override = 0;
	ent stoploopsound( 4 );
	if ( !flag( "sq_ows_success" ) )
	{
		wait 0,5;
		ent playsound( "mus_sidequest_0" );
	}
	wait 3,5;
	ent delete();
}

sndhit()
{
	self endon( "ows_target_timeout" );
	self waittill( "damage" );
	self playsound( "zmb_sq_target_hit" );
}

sndtime()
{
	self endon( "zmb_sq_target_hit" );
	self waittill( "ows_target_timeout" );
	self playsound( "zmb_sq_target_flip" );
}
