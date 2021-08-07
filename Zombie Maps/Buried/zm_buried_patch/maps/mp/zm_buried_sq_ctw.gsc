#include maps/mp/zm_buried_sq;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	flag_init( "sq_wisp_failed" );
	flag_init( "sq_m_wisp_weak" );
	level.sq_ctw_m_tubes_lit = 0;
	declare_sidequest_stage( "sq", "ctw", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
	flag_clear( "sq_wisp_failed" );
	level._cur_stage_name = "ctw";
	clientnotify( "ctw" );
}

stage_logic()
{
/#
	iprintlnbold( "CTW Started" );
#/
	if ( flag( "sq_is_max_tower_built" ) )
	{
		level thread stage_vo_max();
		ctw_max_start_wisp();
	}
	else
	{
		level thread stage_vo_ric();
		ctw_ric_start_wisp();
	}
	flag_wait_any( "sq_wisp_success", "sq_wisp_failed" );
	wait_network_frame();
	stage_completed( "sq", level._cur_stage_name );
}

exit_stage( success )
{
}

stage_vo_max()
{
	level endon( "sq_wisp_failed" );
	while ( !isDefined( level.vh_wisp ) )
	{
		wait 1;
	}
	level.vh_wisp endon( "delete" );
	maxissay( "vox_maxi_sidequest_ctw_0", level.e_sq_sign_attacker );
	maxissay( "vox_maxi_sidequest_ctw_1", level.e_sq_sign_attacker );
	wait 15;
	maxissay( "vox_maxis_sidequest_ctw_4", level.e_sq_sign_attacker );
}

stage_vo_ric()
{
	level endon( "sq_wisp_failed" );
	richtofensay( "vox_zmba_sidequest_ctw_0", 12 );
	richtofensay( "vox_zmba_sidequest_ctw_1", 8 );
	level waittill( "sq_ctw_zombie_powered_up" );
	richtofensay( "vox_zmba_sidequest_ctw_3", 8 );
}

wisp_move_from_sign_to_start( s_start )
{
	self.origin = level.m_sq_start_sign.origin - vectorScale( ( 1, 0, 0 ), 20 );
	self moveto( s_start.origin, 2, 0,5, 0,5 );
	self waittill( "movedone" );
	wait 1;
}

ctw_ric_start_wisp()
{
	if ( !isDefined( level.m_sq_start_sign ) )
	{
		return;
	}
	s_start = getstruct( level.m_sq_start_sign.target, "targetname" );
	m_wisp = getent( "sq_wisp", "targetname" );
	m_wisp setclientfield( "vulture_wisp", 1 );
	m_wisp wisp_move_from_sign_to_start( s_start );
	m_wisp thread ctw_ric_move_wisp( s_start );
}

ctw_ric_move_wisp( s_current )
{
	self endon( "ctw_wisp_timeout" );
	self setclientfield( "vulture_wisp", 0 );
	self.origin = s_current.origin;
	wait_network_frame();
	self setclientfield( "vulture_wisp", 1 );
	self thread ctw_ric_watch_wisp_timeout();
	ctw_ric_watch_wisp_dist();
	s_current = ctw_ric_get_next_wisp_struct( s_current );
	self endon( "ctw_wisp_moved" );
	self ctw_ric_power_towers();
	flag_set( "sq_wisp_success" );
}

ctw_ric_get_next_wisp_struct( s_current )
{
	if ( !isDefined( s_current.target ) )
	{
		return undefined;
	}
	a_structs = getstructarray( s_current.target, "targetname" );
	return array_randomize( a_structs )[ 0 ];
}

ctw_ric_watch_wisp_timeout()
{
	self endon( "ctw_wisp_moved" );
	wait 12;
	flag_set( "sq_wisp_failed" );
	self setclientfield( "vulture_wisp", 0 );
	self notify( "ctw_wisp_timeout" );
}

ctw_ric_watch_wisp_dist( s_current )
{
	self endon( "ctw_wisp_timeout" );
	is_near_wisp = 0;
	while ( !is_near_wisp )
	{
		players = getplayers();
		_a185 = players;
		_k185 = getFirstArrayKey( _a185 );
		while ( isDefined( _k185 ) )
		{
			player = _a185[ _k185 ];
			if ( !player hasperk( "specialty_nomotionsensor" ) )
			{
			}
			else
			{
				if ( distancesquared( player.origin, self.origin ) < 4096 )
				{
					is_near_wisp = 1;
				}
			}
			_k185 = getNextArrayKey( _a185, _k185 );
		}
		wait 0,1;
	}
	self notify( "ctw_wisp_moved" );
}

ctw_ric_power_towers()
{
	m_tower = getent( "sq_guillotine", "targetname" );
	level setclientfield( "vulture_wisp_orb_count", 1 );
	wait_network_frame();
	level setclientfield( "vulture_wisp_orb_count", 0 );
	wait 2;
	v_guillotine_spot = self.origin;
	self.origin = m_tower gettagorigin( "j_crystal_01" );
	m_tower thread ctw_ric_guillotine_glow( v_guillotine_spot );
	i = 0;
	while ( i < 5 )
	{
		wait 3;
		e_powered_zombie = undefined;
		while ( !isDefined( e_powered_zombie ) )
		{
			wait 1;
			a_zombies = ctw_find_zombies_for_powerup( self.origin, 512, m_tower );
			e_powered_zombie = array_randomize( a_zombies )[ 0 ];
		}
		level notify( "stop_ctw_ric_guillotine_glow" );
		e_powered_zombie ctw_power_up_ric_zombie( m_tower.m_glow );
		e_powered_zombie waittill( "death" );
		level setclientfield( "vulture_wisp_orb_count", i + 1 );
		m_tower ctw_return_wisp_to_guillotine( v_guillotine_spot, e_powered_zombie.origin );
		i++;
	}
}

ctw_ric_guillotine_glow( v_spot )
{
	level endon( "stop_ctw_ric_guillotine_glow" );
	if ( !isDefined( self.m_glow ) )
	{
		self.m_glow = spawn( "script_model", v_spot );
		self.m_glow setmodel( "tag_origin" );
	}
	while ( 1 )
	{
		playfxontag( level._effect[ "vulture_fx_wisp" ], self.m_glow, "tag_origin" );
		wait 0,25;
		self.m_glow playloopsound( "zmb_sq_wisp_loop_guillotine" );
	}
}

ctw_power_up_ric_zombie( m_wisp )
{
	wait_network_frame();
	v_to_zombie = vectornormalize( self gettagorigin( "J_SpineLower" ) - m_wisp.origin );
	v_move_spot = m_wisp.origin + ( v_to_zombie * 32 );
	m_wisp.origin = v_move_spot;
	self ctw_power_up_zombie();
}

ctw_return_wisp_to_guillotine( v_spot, v_start )
{
	self.m_glow.origin = v_start;
	self thread ctw_ric_guillotine_glow( v_start );
	wait_network_frame();
	v_to_tower = vectornormalize( v_spot - self.m_glow.origin );
	v_move_spot = self.m_glow.origin + ( v_to_tower * 32 );
	self.m_glow.origin = v_move_spot;
	self.m_glow.origin = v_spot;
}

ctw_max_start_wisp()
{
	nd_start = getvehiclenode( level.m_sq_start_sign.target, "targetname" );
	vh_wisp = spawnvehicle( "tag_origin", "wisp_ai", "heli_quadrotor2_zm", nd_start.origin, nd_start.angles );
	vh_wisp makevehicleunusable();
	level.vh_wisp = vh_wisp;
	vh_wisp.n_sq_max_energy = 30;
	vh_wisp.n_sq_energy = vh_wisp.n_sq_max_energy;
	vh_wisp thread ctw_max_wisp_play_fx();
	vh_wisp_mover = spawn( "script_model", vh_wisp.origin );
	vh_wisp_mover setmodel( "tag_origin" );
	vh_wisp linkto( vh_wisp_mover );
	vh_wisp_mover wisp_move_from_sign_to_start( nd_start );
	vh_wisp unlink();
	vh_wisp_mover delete();
	vh_wisp attachpath( nd_start );
	vh_wisp startpath();
	vh_wisp thread ctw_max_success_watch();
	vh_wisp thread ctw_max_fail_watch();
	vh_wisp thread ctw_max_wisp_enery_watch();
	wait_network_frame();
	flag_wait_any( "sq_wisp_success", "sq_wisp_failed" );
	vh_wisp cancelaimove();
	vh_wisp clearvehgoalpos();
	vh_wisp delete();
	if ( isDefined( level.vh_wisp ) )
	{
		level.vh_wisp delete();
	}
}

ctw_max_wisp_play_fx()
{
	self playloopsound( "zmb_sq_wisp_loop" );
	while ( isDefined( self ) )
	{
		playfxontag( level._effect[ "fx_wisp_m" ], self, "tag_origin" );
		if ( !flag( "sq_m_wisp_weak" ) )
		{
			playfxontag( level._effect[ "fx_wisp_lg_m" ], self, "tag_origin" );
		}
		wait 0,3;
	}
}

ctw_max_success_watch()
{
	self endon( "death" );
	self waittill( "reached_end_node" );
/#
	iprintlnbold( "Wisp Success!" );
#/
	flag_set( "sq_wisp_success" );
	level thread ctw_light_tube();
}

ctw_light_tube()
{
	level.sq_ctw_m_tubes_lit++;
	level setclientfield( "sq_ctw_m_t_l", level.sq_ctw_m_tubes_lit );
}

ctw_max_fail_watch()
{
	self endon( "death" );
	wait 1;
	n_starter_dist = distancesquared( self.origin, level.e_sq_sign_attacker.origin );
	a_players = getplayers();
	_a382 = a_players;
	_k382 = getFirstArrayKey( _a382 );
	while ( isDefined( _k382 ) )
	{
		player = _a382[ _k382 ];
		if ( distancesquared( self.origin, player.origin ) < 16384 )
		{
/#
			iprintlnbold( "Too Close to Wisp" );
#/
		}
		_k382 = getNextArrayKey( _a382, _k382 );
	}
	a_zombies = ctw_find_zombies_for_powerup( self.origin, 256 );
	array_thread( a_zombies, ::ctw_power_up_zombie );
	if ( a_zombies.size )
	{
		self.n_sq_energy += 10;
		if ( self.n_sq_energy > 30 )
		{
			self.n_sq_energy = 30;
		}
	}
	else
	{
		self.n_sq_energy--;

	}
	if ( self.n_sq_energy <= 15 && !flag( "sq_m_wisp_weak" ) )
	{
		flag_set( "sq_m_wisp_weak" );
	}
	else
	{
		if ( self.n_sq_energy > 15 && flag( "sq_m_wisp_weak" ) )
		{
			flag_clear( "sq_m_wisp_weak" );
		}
	}
/#
	iprintlnbold( self.n_sq_energy );
#/
	level thread ctw_max_fail_vo();
	flag_set( "sq_wisp_failed" );
}

ctw_max_fail_vo()
{
	maxissay( "vox_maxi_sidequest_ctw_8", level.e_sq_sign_attacker );
}

ctw_max_wisp_enery_watch()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( self.n_sq_energy <= 0 )
		{
			flag_set( "sq_wisp_failed" );
		}
		wait 1;
	}
}

debug_origin()
{
/#
	self endon( "death" );
	while ( 1 )
	{
		debugstar( self.origin, 1, ( 1, 0, 0 ) );
		wait 0,05;
#/
	}
}

ctw_find_zombies_for_powerup( v_origin, n_radius, m_ignore )
{
	if ( !isDefined( m_ignore ) )
	{
		m_ignore = undefined;
	}
	a_zombies = getaispeciesarray( level.zombie_team, "zombie" );
	n_radius_sq = n_radius * n_radius;
	a_near_zombies = [];
	_a473 = a_zombies;
	_k473 = getFirstArrayKey( _a473 );
	while ( isDefined( _k473 ) )
	{
		e_zombie = _a473[ _k473 ];
		if ( distancesquared( e_zombie.origin, v_origin ) < n_radius_sq && !isDefined( e_zombie.sq_wisp_powered ) )
		{
			if ( sighttracepassed( v_origin, e_zombie gettagorigin( "J_SpineLower" ), 1, m_ignore ) )
			{
				a_near_zombies[ a_near_zombies.size ] = e_zombie;
			}
		}
		_k473 = getNextArrayKey( _a473, _k473 );
	}
	return a_near_zombies;
}

ctw_power_up_zombie()
{
	level notify( "sq_ctw_zombie_powered_up" );
	self.sq_wisp_powered = 1;
	n_oldhealth = self.maxhealth;
	self.maxhealth *= 2;
	if ( self.maxhealth < n_oldhealth )
	{
		self.maxhealth = n_oldhealth;
	}
	self.health = self.maxhealth;
	if ( self.zombie_move_speed != "sprint" )
	{
		self set_zombie_run_cycle( "sprint" );
		self.zombie_move_speed_original = self.zombie_move_speed;
	}
	if ( flag( "sq_is_max_tower_built" ) )
	{
		str_fx = "fx_wisp_m";
	}
	else
	{
		str_fx = "vulture_fx_wisp";
	}
	self thread ctw_power_up_zombie_m_fx( str_fx );
}

ctw_power_up_zombie_m_fx( str_fx )
{
	self endon( "delete" );
	self endon( "death" );
	while ( isDefined( self ) && isalive( self ) )
	{
		playfxontag( level._effect[ str_fx ], self, "J_Wrist_RI" );
		wait 0,25;
		playfxontag( level._effect[ str_fx ], self, "J_Wrist_LE" );
		wait 0,25;
		self playloopsound( "zmb_sq_wisp_possess" );
	}
}
