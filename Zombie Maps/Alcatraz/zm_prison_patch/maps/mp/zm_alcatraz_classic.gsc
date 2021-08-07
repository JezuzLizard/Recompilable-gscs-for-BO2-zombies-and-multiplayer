//checked includes changed to match cerberus output
#include maps/mp/zm_prison_sq_wth;
#include maps/mp/zm_prison_sq_fc;
#include maps/mp/zm_prison_sq_final;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zm_alcatraz_travel;
#include maps/mp/zm_alcatraz_traps;
#include maps/mp/zm_prison;
#include maps/mp/zm_alcatraz_sq;
#include maps/mp/zm_prison_sq_bg;
#include maps/mp/zm_prison_spoon;
#include maps/mp/zm_prison_achievement;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_afterlife;
#include maps/mp/zombies/_zm_ai_brutus;
#include maps/mp/zm_alcatraz_craftables;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zm_alcatraz_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

precache() //checked matches cerberus output
{
	if ( isDefined( level.createfx_enabled ) && level.createfx_enabled )
	{
		return;
	}
	maps/mp/zombies/_zm_craftables::init();
	maps/mp/zm_alcatraz_craftables::include_craftables();
	maps/mp/zm_alcatraz_craftables::init_craftables();
	maps/mp/zombies/_zm_ai_brutus::precache();
	maps/mp/zombies/_zm_afterlife::init();
	precacheshader( "waypoint_kill_red" );
	level._effect[ "powerup_on" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_powerup" );
}

main() //checked changed to match cerberus output
{
	level thread sq_main_controller();
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "zclassic" );
	maps/mp/zombies/_zm_game_module::set_current_game_module( level.game_module_standard_index );
	maps/mp/zombies/_zm_ai_brutus::init();
	level thread maps/mp/zombies/_zm_craftables::think_craftables();
	maps/mp/zm_prison_achievement::init();
	level thread maps/mp/zm_prison_spoon::init();
	level thread maps/mp/zm_prison_sq_bg::init();
	a_grief_clips = getentarray( "grief_clips", "targetname" );
	foreach ( clip in a_grief_clips )
	{
		clip connectpaths();
		clip delete();
	}
	level thread give_afterlife();
	level thread maps/mp/zm_alcatraz_sq::start_alcatraz_sidequest();
	onplayerconnect_callback( ::player_quest_vfx );
	flag_wait( "initial_blackscreen_passed" );
	level notify( "Pack_A_Punch_on" );
	flag_wait( "start_zombie_round_logic" );
	level thread maps/mp/zm_prison::delete_perk_machine_clip();
	level thread maps/mp/zm_alcatraz_traps::init_fan_trap_trigs();
	level thread maps/mp/zm_alcatraz_traps::init_acid_trap_trigs();
	level thread maps/mp/zm_alcatraz_traps::init_tower_trap_trigs();
	level thread maps/mp/zm_alcatraz_travel::init_alcatraz_zipline();
	level thread power_on_perk_machines();
	level thread afterlife_powerups();
	level thread afterlife_intro_door();
	level thread afterlife_cell_door_1();
	level thread afterlife_cell_door_2();
	level thread blundergat_upgrade_station();
}

zm_treasure_chest_init() //checked matches cerberus output
{
	chest1 = getstruct( "start_chest", "script_noteworthy" );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
}

give_afterlife() //checked changed to match cerberus output
{
	onplayerconnect_callback( maps/mp/zombies/_zm_afterlife::init_player );
	flag_wait( "initial_players_connected" );
	wait 0.5;
	n_start_pos = 1;
	a_players = getplayers();
	foreach ( player in a_players )
	{
		if ( isDefined( player.afterlife ) && !player.afterlife )
		{
			player thread fake_kill_player( n_start_pos );
			n_start_pos++;
		}
	}
}

fake_kill_player( n_start_pos ) //checked changed to match cerberus output
{
	self afterlife_remove();
	self.afterlife = 1;
	self thread afterlife_laststand();
	self waittill( "player_fake_corpse_created" );
	self thread afterlife_tutorial();
	e_corpse_location = getstruct( "corpse_starting_point_" + n_start_pos, "targetname" );
	trace_start = e_corpse_location.origin;
	trace_end = e_corpse_location.origin + vectorScale( ( 0, 0, -1 ), 100 );
	corpse_trace = physicstrace( trace_start, trace_end, vectorScale( ( -1, -1, 0 ), 10 ), vectorScale( ( 1, 1, 0 ), 10 ), self.e_afterlife_corpse );
	self.e_afterlife_corpse.origin = corpse_trace[ "position" ];
	vec_to_target = self.e_afterlife_corpse.origin - self.origin;
	vec_to_target = vectorToAngles( vec_to_target );
	vec_to_target = ( 0, vec_to_target[ 1 ], 0 );
	self setplayerangles( vec_to_target );
	self notify( "al_all_setup" );
}

afterlife_tutorial() //checked matches cerberus output
{
	self endon( "disconnect" );
	level endon( "end_game" );
	flag_wait( "start_zombie_round_logic" );
	wait 3;
	self create_tutorial_message( &"ZM_PRISON_AFTERLIFE_HOWTO" );
	self thread afterlife_tutorial_attack_watch();
	waittill_notify_or_timeout( "stop_tutorial", 5 );
	self thread destroy_tutorial_message();
	wait 1;
	if ( isDefined( self.afterlife ) && self.afterlife )
	{
		self create_tutorial_message( &"ZM_PRISON_AFTERLIFE_HOWTO_2" );
		self thread afterlife_tutorial_jump_watch();
		waittill_notify_or_timeout( "stop_tutorial", 5 );
		self thread destroy_tutorial_message();
	}
}

afterlife_tutorial_attack_watch() //checked matches cerberus output
{
	self endon( "stop_tutorial" );
	self endon( "disconnect" );
	while ( isDefined( self.afterlife ) && self.afterlife && !self isfiring() )
	{
		wait 0.05;
	}
	wait 0.2;
	self notify( "stop_tutorial" );
}

afterlife_tutorial_jump_watch() //checked matches cerberus output
{
	self endon( "stop_tutorial" );
	self endon( "disconnect" );
	while ( isDefined( self.afterlife ) && self.afterlife && !self is_jumping() )
	{
		wait 0.05;
	}
	wait 0.2;
	self notify( "stop_tutorial" );
}

afterlife_powerups() //checked matches cerberus output
{
	level._powerup_grab_check = ::cell_grab_check;
	s_powerup_loc = getstruct( "powerup_start", "targetname" );
	spawn_infinite_powerup_drop( s_powerup_loc.origin, "double_points" );
	s_powerup_loc = getstruct( "powerup_cell_1", "targetname" );
	if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "double_points" );
	}
	else
	{
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "insta_kill" );
	}
	s_powerup_loc = getstruct( "powerup_cell_2", "targetname" );
	if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "double_points" );
	}
	else
	{
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "full_ammo" );
	}
}

cell_grab_check( player ) //checked matches cerberus output
{
	cell_powerup = getstruct( "powerup_start", "targetname" );
	if ( self.origin == ( cell_powerup.origin + vectorScale( ( 0, 0, 1 ), 40 ) ) )
	{
		m_door = getent( "powerup_door", "targetname" );
		if ( !isDefined( m_door.opened ) )
		{
			return 0;
		}
	}
	cell_powerup = getstruct( "powerup_cell_1", "targetname" );
	if ( self.origin == ( cell_powerup.origin + vectorScale( ( 0, 0, 1 ), 40 ) ) )
	{
		m_door = getent( "powerup_cell_door_1", "targetname" );
		if ( !isDefined( m_door.opened ) )
		{
			return 0;
		}
	}
	cell_powerup = getstruct( "powerup_cell_2", "targetname" );
	if ( self.origin == ( cell_powerup.origin + vectorScale( ( 0, 0, 1 ), 40 ) ) )
	{
		m_door = getent( "powerup_cell_door_2", "targetname" );
		if ( !isDefined( m_door.opened ) )
		{
			return 0;
		}
	}
	return 1;
}

afterlife_intro_door() //checked matches cerberus output
{
	m_door = getent( "powerup_door", "targetname" );
	level waittill( "intro_powerup_activate" );
	wait 1;
	array_delete( getentarray( "wires_cell_dblock", "script_noteworthy" ) );
	m_door.opened = 1;
	m_door movex( 34, 2, 1 );
	m_door playsound( "zmb_jail_door" );
	level waittill( "intro_powerup_restored" );
	s_powerup_loc = getstruct( "powerup_start", "targetname" );
	spawn_infinite_powerup_drop( s_powerup_loc.origin );
}

afterlife_cell_door_1() //checked matches cerberus output
{
	m_door = getent( "powerup_cell_door_1", "targetname" );
	level waittill( "cell_1_powerup_activate" );
	wait 1;
	array_delete( getentarray( "wires_cell_cafeteria", "script_noteworthy" ) );
	m_door.opened = 1;
	m_door movex( 36, 2, 1 );
	m_door playsound( "zmb_jail_door" );
}

afterlife_cell_door_2() //checked matches cerberus output
{
	m_door = getent( "powerup_cell_door_2", "targetname" );
	level waittill( "cell_2_powerup_activate" );
	wait 1;
	array_delete( getentarray( "wires_cell_michigan", "script_noteworthy" ) );
	m_door.opened = 1;
	m_door movex( -34, 2, 1 );
	m_door playsound( "zmb_jail_door" );
}

spawn_infinite_powerup_drop( v_origin, str_type ) //checked matches cerberus output
{
	level._powerup_timeout_override = ::powerup_infinite_time;
	if ( isDefined( str_type ) )
	{
		intro_powerup = maps/mp/zombies/_zm_powerups::specific_powerup_drop( str_type, v_origin );
	}
	else
	{
		intro_powerup = maps/mp/zombies/_zm_powerups::powerup_drop( v_origin );
	}
	level._powerup_timeout_override = undefined;
}

powerup_infinite_time() //checked matches cerberus output
{
}

power_on_perk_machines() //checked changed to match cerberus output
{
	level waittill_any( "unlock_all_perk_machines", "open_sesame" );
	a_shockboxes = getentarray( "perk_afterlife_trigger", "script_noteworthy" );
	foreach ( e_shockbox in a_shockboxes )
	{
		e_shockbox notify( "damage" );
		wait 1;
	}
}

sq_main_controller() //checked matches cerberus output
{
	precacheshader( "zm_al_wth_zombie" );
	onplayerconnect_callback( maps/mp/zm_prison_sq_final::onplayerconnect_sq_final );
	level thread maps/mp/zm_prison_sq_final::stage_one();
	onplayerconnect_callback( maps/mp/zm_prison_sq_fc::onplayerconnect_sq_fc );
	level thread maps/mp/zm_prison_sq_fc::watch_for_trigger_condition();
	onplayerconnect_callback( maps/mp/zm_prison_sq_wth::onplayerconnect_sq_wth );
}

player_quest_vfx() //checked matches cerberus output
{
	flag_wait( "initial_blackscreen_passed" );
	wait 1;
	if ( !flag( "generator_challenge_completed" ) )
	{
		exploder( 2000 );
	}
}

