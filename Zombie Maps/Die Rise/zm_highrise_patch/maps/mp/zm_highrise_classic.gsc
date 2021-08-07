#include maps/mp/zm_highrise_utility;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_ai_leaper;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zm_highrise_elevators;
#include maps/mp/zm_highrise_classic;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zm_highrise_buildables;
#include maps/mp/zombies/_zm_chugabud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#using_animtree( "zombie_escape_elevator" );

precache()
{
	precacheshader( "overlay_low_health_splat" );
	precacheshellshock( "elevator_crash" );
	maps/mp/zombies/_zm_chugabud::chugabug_precache();
	maps/mp/zm_highrise_buildables::include_buildables();
	maps/mp/zm_highrise_buildables::init_buildables();
	maps/mp/zm_highrise_sq::init();
	maps/mp/zombies/_zm_equip_springpad::init( &"ZM_HIGHRISE_EQUIP_SPRINGPAD_PICKUP_HINT_STRING", &"ZM_HIGHRISE_EQUIP_SPRINGPAD_HOWTO" );
	level._zombiemode_post_respawn_callback = ::highrise_post_respawn_callback;
	onplayerconnect_callback( ::highrise_player_connect_callback );
}

main()
{
	level.buildables_built[ "pap" ] = 1;
	level.custom_pap_move_in = ::highrise_pap_move_in;
	level.custom_pap_move_out = ::highrise_pap_move_out;
	flag_init( "perks_ready" );
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "rooftop" );
	maps/mp/zombies/_zm_game_module::set_current_game_module( level.game_module_standard_index );
	level thread maps/mp/zombies/_zm_buildables::think_buildables();
	level.calc_closest_player_using_paths = 1;
	level.validate_enemy_path_length = ::highrise_validate_enemy_path_length;
	level thread maps/mp/zm_highrise_classic::init_escape_pod();
	level thread maps/mp/zm_highrise_elevators::init_elevators();
	temp_clips = getentarray( "elevator_delete", "targetname" );
	if ( isDefined( temp_clips ) && temp_clips.size > 0 )
	{
		array_thread( temp_clips, ::self_delete );
	}
	level thread maps/mp/zm_highrise_elevators::init_elevator( "1b" );
	level thread maps/mp/zm_highrise_elevators::init_elevator( "1c", 1 );
	level thread maps/mp/zm_highrise_elevators::init_elevator( "1d" );
	if ( randomint( 100 ) > 50 )
	{
		level thread maps/mp/zm_highrise_elevators::init_elevator( "3", 1, -1264 );
		level thread maps/mp/zm_highrise_elevators::init_elevator( "3b", 2 );
	}
	else
	{
		level thread maps/mp/zm_highrise_elevators::init_elevator( "3", 2 );
		level thread maps/mp/zm_highrise_elevators::init_elevator( "3b", 1, -1264 );
	}
	level thread maps/mp/zm_highrise_elevators::init_elevator( "3c", 3 );
	level thread maps/mp/zm_highrise_elevators::init_elevator( "3d", 1 );
	flag_wait( "initial_blackscreen_passed" );
	level thread escape_pod();
	level._chugabug_reject_corpse_override_func = ::highrise_chugabud_reject_corpse_func;
	level._chugabud_reject_node_override_func = ::highrise_chugabud_reject_node_func;
	level._chugabud_post_respawn_override_func = ::highrise_chugabud_post_respawn_func;
	level.insta_kill_triggers = getentarray( "instant_death", "targetname" );
	array_thread( level.insta_kill_triggers, ::squashed_death_init, 0 );
	e_trigger = getent( "instant_death_escape_pod_shaft", "targetname" );
	if ( isDefined( e_trigger ) )
	{
		e_trigger thread squashed_death_init( 1 );
		e_trigger thread escape_pod_death_trigger_think();
		level.insta_kill_triggers[ level.insta_kill_triggers.size ] = e_trigger;
	}
	exploder( 9 );
	exploder( 10 );
	flag_wait( "start_zombie_round_logic" );
	level thread maps/mp/zm_highrise_elevators::random_elevator_perks();
	level thread maps/mp/zm_highrise_elevators::faller_location_logic();
	level.custom_faller_entrance_logic = ::maps/mp/zm_highrise_elevators::watch_for_elevator_during_faller_spawn;
	setdvar( "zombiemode_path_minz_bias", 13 );
	level.check_valid_poi = ::check_valid_poi;
	level thread maps/mp/zm_highrise_elevators::shouldsuppressgibs();
}

highrise_validate_enemy_path_length( player )
{
	max_dist = 1296;
	d = distancesquared( self.origin, player.origin );
	if ( d <= max_dist )
	{
		return 1;
	}
	return 0;
}

highrise_player_connect_callback()
{
	self setperk( "specialty_fastmantle" );
	self thread end_game_turn_off_whoswho();
}

end_game_turn_off_whoswho()
{
	self endon( "disconnect" );
	level waittill( "end_game" );
	self thread turn_off_whoswho();
}

highrise_post_respawn_callback()
{
	self setperk( "specialty_fastmantle" );
	self thread turn_off_whoswho();
}

turn_off_whoswho()
{
	self endon( "disconnect" );
	self setclientfieldtoplayer( "clientfield_whos_who_filter", 1 );
	wait_network_frame();
	wait_network_frame();
	self setclientfieldtoplayer( "clientfield_whos_who_filter", 0 );
}

highrise_pap_move_in( trigger, origin_offset, angles_offset )
{
	level endon( "Pack_A_Punch_off" );
	trigger endon( "pap_player_disconnected" );
	pap_machine = trigger.perk_machine;
	worldgun = trigger.worldgun;
	worldgundw = trigger.worldgun.worldgundw;
	offset = origin_offset[ 2 ];
	trigger.worldgun rotateto( self.angles + angles_offset + vectorScale( ( 0, 0, 1 ), 90 ), 0,35, 0, 0 );
	offsetdw = vectorScale( ( 0, 0, 1 ), 3 );
	if ( isDefined( trigger.worldgun.worldgundw ) )
	{
		worldgundw rotateto( self.angles + angles_offset + vectorScale( ( 0, 0, 1 ), 90 ), 0,35, 0, 0 );
	}
	wait 0,5;
	move_vec = ( ( ( self.origin + origin_offset ) - worldgun.origin ) * 0,05 ) / 0,5;
	elapsed_time_counter = 0;
	while ( isDefined( worldgun ) && elapsed_time_counter < 0,5 )
	{
		worldgun.origin = ( worldgun.origin[ 0 ] + move_vec[ 0 ], worldgun.origin[ 1 ] + move_vec[ 1 ], pap_machine.origin[ 2 ] + offset );
		if ( isDefined( worldgundw ) )
		{
			worldgundw.origin = ( worldgundw.origin[ 0 ] + move_vec[ 0 ], worldgundw.origin[ 1 ] + move_vec[ 1 ], pap_machine.origin[ 2 ] + offset + offsetdw[ 2 ] );
		}
		elapsed_time_counter += 0,05;
		wait 0,05;
	}
}

highrise_pap_move_out( trigger, origin_offset, interact_offset )
{
	level endon( "Pack_A_Punch_off" );
	trigger endon( "pap_player_disconnected" );
	pap_machine = trigger.perk_machine;
	worldgun = trigger.worldgun;
	worldgundw = trigger.worldgun.worldgundw;
	offset = origin_offset[ 2 ];
	offsetdw = vectorScale( ( 0, 0, 1 ), 3 );
	move_vec = ( ( interact_offset - origin_offset ) * 0,05 ) / 0,5;
	elapsed_time_counter = 0;
	while ( isDefined( worldgun ) && elapsed_time_counter < 0,5 )
	{
		worldgun.origin = ( worldgun.origin[ 0 ] + move_vec[ 0 ], worldgun.origin[ 1 ] + move_vec[ 1 ], pap_machine.origin[ 2 ] + offset );
		if ( isDefined( worldgundw ) )
		{
			worldgundw.origin = ( worldgundw.origin[ 0 ] + move_vec[ 0 ], worldgundw.origin[ 1 ] + move_vec[ 1 ], pap_machine.origin[ 2 ] + offset + offsetdw[ 2 ] );
		}
		elapsed_time_counter += 0,05;
		wait 0,05;
	}
	move_vec = ( ( origin_offset - interact_offset ) * 0,05 ) / level.packapunch_timeout;
	elapsed_time_counter = 0;
	while ( isDefined( worldgun ) && elapsed_time_counter < level.packapunch_timeout )
	{
		worldgun.origin = ( worldgun.origin[ 0 ] + move_vec[ 0 ], worldgun.origin[ 1 ] + move_vec[ 1 ], pap_machine.origin[ 2 ] + offset );
		if ( isDefined( worldgundw ) )
		{
			worldgundw.origin = ( worldgundw.origin[ 0 ] + move_vec[ 0 ], worldgundw.origin[ 1 ] + move_vec[ 1 ], pap_machine.origin[ 2 ] + offset + offsetdw[ 2 ] );
		}
		elapsed_time_counter += 0,05;
		wait 0,05;
	}
}

escape_pod_death_trigger_think()
{
	self endon( "death" );
	while ( 1 )
	{
		level waittill( "escape_pod_falling_begin" );
		self trigger_off();
		level waittill( "escape_pod_falling_complete" );
		self trigger_on();
		level waittill( "escape_pod_moving_back_to_start_position" );
		self trigger_off();
		level waittill( "escape_pod_returns_to_start_location" );
		self trigger_on();
	}
}

zm_treasure_chest_init()
{
	chest1 = getstruct( "start_chest", "script_noteworthy" );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
}

squashed_death_init( kill_if_falling )
{
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( isDefined( who.insta_killed ) && !who.insta_killed )
		{
			if ( isplayer( who ) )
			{
				who thread elevator_black_screen_squash_check();
				who thread insta_kill_player( 1, kill_if_falling );
				break;
			}
			else if ( isai( who ) )
			{
				while ( is_true( who.in_the_ceiling ) )
				{
					continue;
				}
				who dodamage( who.health + 100, who.origin );
				who.insta_killed = 1;
				if ( isDefined( who.has_been_damaged_by_player ) && !who.has_been_damaged_by_player )
				{
					if ( isDefined( who.is_leaper ) && who.is_leaper )
					{
						who thread maps/mp/zombies/_zm_ai_leaper::leaper_cleanup();
						break;
					}
					else
					{
						level.zombie_total++;
					}
				}
			}
		}
	}
}

elevator_black_screen_squash_check()
{
	if ( !self hasperk( "specialty_finalstand" ) )
	{
		return;
	}
	while ( isDefined( level.elevators ) )
	{
		_a385 = level.elevators;
		_k385 = getFirstArrayKey( _a385 );
		while ( isDefined( _k385 ) )
		{
			elevator = _a385[ _k385 ];
			if ( isDefined( elevator.body.trig ) )
			{
				if ( self istouching( elevator.body.trig ) )
				{
					if ( isDefined( self.fade_to_black_time ) )
					{
						time = getTime();
						dt = ( time - self.fade_to_black_time ) / 1000;
						if ( abs( dt ) < 10 )
						{
							return;
						}
					}
					start_wait = 0;
					black_screen_wait = 3,8;
					fade_in_time = 0,2;
					fade_out_time = 0,01;
					self thread fadetoblackforxsec( start_wait, black_screen_wait, fade_in_time, fade_out_time );
					self.fade_to_black_time = getTime();
					return 1;
				}
			}
			_k385 = getNextArrayKey( _a385, _k385 );
		}
	}
}

insta_kill_player( perks_can_respawn_player, kill_if_falling )
{
	self endon( "disconnect" );
	if ( isDefined( perks_can_respawn_player ) && perks_can_respawn_player == 0 )
	{
		if ( self hasperk( "specialty_quickrevive" ) )
		{
			self unsetperk( "specialty_quickrevive" );
		}
		if ( self hasperk( "specialty_finalstand" ) )
		{
			self unsetperk( "specialty_finalstand" );
		}
	}
	self maps/mp/zombies/_zm_buildables::player_return_piece_to_original_spawn();
	if ( isDefined( self.insta_killed ) && self.insta_killed )
	{
		return;
	}
	if ( isDefined( self.ignore_insta_kill ) )
	{
		self.disable_chugabud_corpse = 1;
		return;
	}
	if ( self hasperk( "specialty_finalstand" ) )
	{
		self.ignore_insta_kill = 1;
		self.disable_chugabud_corpse = 1;
		self dodamage( self.health + 1000, ( 0, 0, 1 ) );
		return;
	}
	if ( !isDefined( kill_if_falling ) || kill_if_falling == 0 )
	{
		if ( !self isonground() )
		{
			return;
		}
	}
	if ( is_player_killable( self ) )
	{
		self.insta_killed = 1;
		in_last_stand = 0;
		self notify( "chugabud_effects_cleanup" );
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			in_last_stand = 1;
		}
		self thread blood_splat();
		if ( getnumconnectedplayers() == 1 )
		{
			if ( isDefined( self.lives ) && self.lives > 0 )
			{
				self.waiting_to_revive = 1;
				points = getstruct( "zone_green_start", "script_noteworthy" );
				spawn_points = getstructarray( points.target, "targetname" );
				point = spawn_points[ 0 ];
				if ( in_last_stand == 0 )
				{
					self dodamage( self.health + 1000, ( 0, 0, 1 ) );
				}
				wait 0,5;
				self freezecontrols( 1 );
				wait 0,25;
				self setorigin( point.origin + vectorScale( ( 0, 0, 1 ), 20 ) );
				self.angles = point.angles;
				if ( in_last_stand )
				{
					flag_set( "instant_revive" );
					self.stopflashingbadlytime = getTime() + 1000;
					wait_network_frame();
					flag_clear( "instant_revive" );
				}
				else
				{
					self thread maps/mp/zombies/_zm_laststand::auto_revive( self );
					self.waiting_to_revive = 0;
					self.solo_respawn = 0;
					self.lives = 0;
				}
				self freezecontrols( 0 );
				self.insta_killed = 0;
			}
			else
			{
				self dodamage( self.health + 1000, ( 0, 0, 1 ) );
			}
		}
		else
		{
			self dodamage( self.health + 1000, ( 0, 0, 1 ) );
			wait_network_frame();
			self.bleedout_time = 0;
		}
		self.insta_killed = 0;
	}
}

highrise_chugabud_reject_corpse_func( v_corpse_position )
{
	reject = 0;
	if ( isDefined( level.elevator_volumes ) )
	{
		scr_org = spawn( "script_origin", v_corpse_position );
		_a563 = level.elevator_volumes;
		_k563 = getFirstArrayKey( _a563 );
		while ( isDefined( _k563 ) )
		{
			volume = _a563[ _k563 ];
			if ( scr_org istouching( volume ) )
			{
				reject = 1;
				break;
			}
			else
			{
				_k563 = getNextArrayKey( _a563, _k563 );
			}
		}
		scr_org delete();
	}
	return reject;
}

highrise_chugabud_reject_node_func( v_corpse_pos, nd_node )
{
	reject = 0;
	skip_elevator_volume_check = 0;
	scr_org = spawn( "script_origin", nd_node.origin );
	player_zone = maps/mp/zombies/_zm_zonemgr::get_player_zone();
	if ( isDefined( player_zone ) )
	{
		if ( player_zone == "zone_orange_elevator_shaft_middle_1" || player_zone == "zone_orange_elevator_shaft_middle_2" )
		{
			skip_elevator_volume_check = 1;
		}
	}
	if ( !isDefined( level.chugabud_info_volume1 ) )
	{
		level.chugabud_info_volume1 = getent( "zone_orange_level1_whos_who_info_volume", "targetname" );
	}
	scr_org.origin = v_corpse_pos;
	if ( scr_org istouching( level.chugabud_info_volume1 ) )
	{
		scr_org.origin = nd_node.origin;
		if ( !scr_org istouching( level.chugabud_info_volume1 ) )
		{
			reject = 1;
		}
	}
	if ( !reject )
	{
		if ( !isDefined( level.chugabud_info_volume2 ) )
		{
			level.chugabud_info_volume2 = getent( "whos_who_slide_info_volume", "targetname" );
		}
		scr_org.origin = v_corpse_pos;
		if ( scr_org istouching( level.chugabud_info_volume2 ) )
		{
			n_node_corpse = getnode( "whos_who_slide_corpse_respawn_position", "targetname" );
			maps/mp/zombies/_zm_chugabud::force_corpse_respawn_position( n_node_corpse.origin );
		}
	}
	while ( !reject )
	{
		while ( !skip_elevator_volume_check )
		{
			scr_org.origin = nd_node.origin;
			while ( isDefined( level.elevator_volumes ) )
			{
				_a665 = level.elevator_volumes;
				_k665 = getFirstArrayKey( _a665 );
				while ( isDefined( _k665 ) )
				{
					volume = _a665[ _k665 ];
					if ( scr_org istouching( volume ) )
					{
						reject = 1;
						break;
					}
					else
					{
						_k665 = getNextArrayKey( _a665, _k665 );
					}
				}
			}
		}
	}
	scr_org delete();
	return reject;
}

highrise_chugabud_post_respawn_func( v_new_player_position )
{
	scr_org = spawn( "script_origin", v_new_player_position );
	e_corpse = self.e_chugabud_corpse;
	if ( isDefined( e_corpse ) )
	{
		corpse_zone = maps/mp/zombies/_zm_zonemgr::get_zone_from_position( e_corpse.origin );
		if ( isDefined( corpse_zone ) || corpse_zone == "zone_orange_elevator_shaft_middle_2" && corpse_zone == "zone_orange_elevator_shaft_middle_1" )
		{
			if ( !isDefined( level.elevator_shaft_middle_2_respawn_nodes ) )
			{
				level.elevator_shaft_middle_2_respawn_nodes = getnodearray( "orange_elevator_middle_2_player_respawn_loc", "targetname" );
				level.elevator_shaft_middle_2_respawn_nodes_index = 0;
			}
			nd_node = level.elevator_shaft_middle_2_respawn_nodes[ level.elevator_shaft_middle_2_respawn_nodes_index ];
			level.elevator_shaft_middle_2_respawn_nodes_index++;
			if ( level.elevator_shaft_middle_2_respawn_nodes_index >= level.elevator_shaft_middle_2_respawn_nodes.size )
			{
				level.elevator_shaft_middle_2_respawn_nodes_index = 0;
			}
			maps/mp/zombies/_zm_chugabud::force_player_respawn_position( nd_node.origin );
		}
	}
	e_corpse = self.e_chugabud_corpse;
	if ( isDefined( e_corpse ) )
	{
		a_escape_pod_ents = [];
		a_escape_pod_ents[ a_escape_pod_ents.size ] = getent( "escape_pod_trigger", "targetname" );
		a_escape_pod_ents[ a_escape_pod_ents.size ] = getent( "zone_green_escape_pod", "targetname" );
		scr_org.origin = e_corpse.origin;
		touching = 0;
		i = 0;
		while ( i < a_escape_pod_ents.size )
		{
			e_ent = a_escape_pod_ents[ i ];
			if ( scr_org istouching( e_ent ) )
			{
				touching = 1;
				break;
			}
			else
			{
				i++;
			}
		}
		if ( touching )
		{
			scr_org.origin = v_new_player_position;
			touching = 0;
			i = 0;
			while ( i < a_escape_pod_ents.size )
			{
				e_ent = a_escape_pod_ents[ i ];
				if ( scr_org istouching( e_ent ) )
				{
					touching = 1;
					break;
				}
				else
				{
					i++;
				}
			}
			if ( !touching )
			{
				if ( v_new_player_position[ 2 ] > 3300 )
				{
					if ( !isDefined( level.escape_pod_corpse_respawn_nodes ) )
					{
						level.escape_pod_corpse_respawn_nodes = getnodearray( "escape_pod_corpse_respawn_loc", "targetname" );
						level.escape_pod_corpse_respawn_node_index = 0;
					}
					nd_node = level.escape_pod_corpse_respawn_nodes[ level.escape_pod_corpse_respawn_node_index ];
					level.escape_pod_corpse_respawn_node_index++;
					if ( level.escape_pod_corpse_respawn_node_index >= level.escape_pod_corpse_respawn_nodes.size )
					{
						level.escape_pod_corpse_respawn_node_index = 0;
					}
					maps/mp/zombies/_zm_chugabud::force_corpse_respawn_position( nd_node.origin );
					if ( isDefined( self.riding_escape_pod ) )
					{
						self.riding_escape_pod = undefined;
					}
				}
			}
		}
	}
	scr_org delete();
}

blood_splat()
{
	earthquake( 0,3, 3, self.origin, 128 );
	if ( isDefined( self.blood_splats_overlay ) )
	{
		return;
	}
	self.blood_splats_overlay = newclienthudelem( self );
	self.blood_splats_overlay setshader( "overlay_low_health_splat", 640, 480 );
	self.blood_splats_overlay.x = 0;
	self.blood_splats_overlay.y = 0;
	self.blood_splats_overlay.splatter = 1;
	self.blood_splats_overlay.alignx = "left";
	self.blood_splats_overlay.aligny = "top";
	self.blood_splats_overlay.sort = 1;
	self.blood_splats_overlay.foreground = 0;
	self.blood_splats_overlay.horzalign = "fullscreen";
	self.blood_splats_overlay.vertalign = "fullscreen";
	self.blood_splats_overlay.alpha = 1;
	wait 3;
	self.blood_splats_overlay fadeovertime( 1 );
	self.blood_splats_overlay.alpha = 0;
	wait 1;
	self.blood_splats_overlay destroy();
}

is_player_killable( player, checkignoremeflag )
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( player.sessionstate == "spectator" )
	{
		return 0;
	}
	if ( player.sessionstate == "intermission" )
	{
		return 0;
	}
	if ( isDefined( self.intermission ) && self.intermission )
	{
		return 0;
	}
	if ( isDefined( checkignoremeflag ) && player.ignoreme )
	{
		return 0;
	}
	return 1;
}

init_escape_elevators_animtree()
{
	scriptmodelsuseanimtree( -1 );
}

escapeelevatoruseanimtree()
{
	self useanimtree( -1 );
}

init_escape_pod()
{
	flag_init( "escape_pod_needs_reset" );
	level thread init_escape_elevators_anims();
/#
	adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Escape Pod:2/Reset To Top:1" "set zombie_devgui_hrescapepodreset 1" \n" );
	level thread watch_escapepod_devgui();
#/
}

init_escape_elevators_anims()
{
	level.escape_elevator_1_state = %v_zombie_elevator_escape_player1_loop;
	level.escape_elevator_2_state = %v_zombie_elevator_escape_player2_loop;
	level.escape_elevator_3_state = %v_zombie_elevator_escape_player3_loop;
	level.escape_elevator_4_state = %v_zombie_elevator_escape_player4_loop;
	level.escape_elevator_5_state = %v_zombie_elevator_escape_player4_cablebreak;
	level.escape_elevator_prestine_idle_state = %fxanim_zm_highrise_elevator_prestine_idle_anim;
	level.escape_elevator_prestine_drop_state = %fxanim_zm_highrise_elevator_prestine_drop_anim;
	level.escape_elevator_prestine_impact_state = %fxanim_zm_highrise_elevator_prestine_impact_anim;
	level.escape_elevator_damage_idle_state = %fxanim_zm_highrise_elevator_damage_idle_anim;
	level.escape_elevator_damage_drop_state = %fxanim_zm_highrise_elevator_damage_drop_anim;
	level.escape_elevator_damage_impact_state = %fxanim_zm_highrise_elevator_damage_impact_anim;
	level.escape_elevator_idle = level.escape_elevator_prestine_idle_state;
	level.escape_elevator_drop = level.escape_elevator_prestine_drop_state;
	level.escape_elevator_impact = level.escape_elevator_prestine_impact_state;
}

escape_pod()
{
	escape_pod = getent( "elevator_bldg1a_body", "targetname" );
	escape_pod setmovingplatformenabled( 1 );
	escape_pod escapeelevatoruseanimtree();
	escape_pod_trigger = getent( "escape_pod_trigger", "targetname" );
	escape_pod.is_elevator = 1;
	escape_pod._post_host_migration_thread = ::maps/mp/zm_highrise_elevators::escape_pod_host_migration_respawn_check;
	if ( !isDefined( escape_pod_trigger ) )
	{
		return;
	}
	escape_pod.home_origin = escape_pod.origin;
	escape_pod.link_start = [];
	escape_pod.link_end = [];
	escape_pod_blocker_door = getent( "elevator_bldg1a_body_door_clip", "targetname" );
	number_of_times_used = 0;
	used_at_least_once = 0;
	escape_pod setanim( level.escape_elevator_1_state );
	escape_pod setclientfield( "clientfield_escape_pod_light_fx", 1 );
	escape_pod_trigger thread escape_pod_walk_on_off( escape_pod );
	while ( 1 )
	{
		escape_pod setanim( level.escape_elevator_idle );
		flag_clear( "escape_pod_needs_reset" );
		if ( isDefined( escape_pod_blocker_door ) )
		{
			escape_pod escape_pod_linknodes( "escape_pod_door_l_node" );
			escape_pod escape_pod_linknodes( "escape_pod_door_r_node" );
			escape_pod_blocker_door unlink();
			escape_pod_blocker_door thread trigger_off();
		}
		if ( is_true( used_at_least_once ) )
		{
			wait 3;
		}
		escape_pod thread escape_pod_state_run();
		while ( 1 )
		{
			players_in_escape_pod = escape_pod_trigger escape_pod_get_all_alive_players_inside();
			while ( players_in_escape_pod == 0 )
			{
				escape_pod.escape_pod_state = 1;
				wait 0,05;
			}
			all_players_touching = escape_pod_trigger escape_pod_are_all_alive_players_ready();
			players_total = escape_pod_trigger escape_pod_get_all_alive_players();
			players_in_escape_pod = escape_pod_trigger escape_pod_get_all_alive_players_inside();
			if ( players_in_escape_pod > 0 )
			{
				escape_pod.escape_pod_state = 2;
			}
			if ( all_players_touching )
			{
				escape_pod thread escape_pod_tell_fx();
				wait 3;
				all_players_still_touching = escape_pod_trigger escape_pod_are_all_alive_players_ready();
				if ( all_players_still_touching )
				{
					break;
				}
			}
			else
			{
				wait 0,05;
			}
		}
		level notify( "escape_pod_falling_begin" );
		players = get_players();
		_a1053 = players;
		_k1053 = getFirstArrayKey( _a1053 );
		while ( isDefined( _k1053 ) )
		{
			player = _a1053[ _k1053 ];
			player.riding_escape_pod = 1;
			player allowjump( 0 );
			_k1053 = getNextArrayKey( _a1053, _k1053 );
		}
		if ( isDefined( escape_pod_blocker_door ) )
		{
			escape_pod_blocker_door trigger_on();
			escape_pod_blocker_door linkto( escape_pod );
			escape_pod escape_pod_unlinknodes( "escape_pod_door_l_node" );
			escape_pod escape_pod_unlinknodes( "escape_pod_door_r_node" );
		}
		escape_pod.escape_pod_state = 5;
		escape_pod thread escape_pod_shake();
		wait ( getanimlength( level.escape_elevator_5_state ) - 0,05 );
		escape_pod setanim( level.escape_elevator_drop );
		escape_pod setclientfield( "clientfield_escape_pod_light_fx", 0 );
		escape_pod setclientfield( "clientfield_escape_pod_sparks_fx", 1 );
		escape_pod thread escape_pod_move();
		escape_pod thread escape_pod_rotate();
		escape_pod waittill( "reached_destination" );
		number_of_times_used++;
		escape_pod thread impact_animate();
		if ( number_of_times_used == 1 )
		{
			level.escape_elevator_idle = level.escape_elevator_damage_idle_state;
			level.escape_elevator_drop = level.escape_elevator_damage_drop_state;
			level.escape_elevator_impact = level.escape_elevator_damage_impact_state;
		}
		level notify( "escape_pod_falling_complete" );
		if ( isDefined( escape_pod_blocker_door ) )
		{
			escape_pod_blocker_door unlink();
			escape_pod_blocker_door trigger_off();
			escape_pod escape_pod_linknodes( "escape_pod_door_l_node" );
			escape_pod escape_pod_linknodes( "escape_pod_door_r_node" );
		}
		escape_pod setclientfield( "clientfield_escape_pod_sparks_fx", 0 );
		escape_pod setclientfield( "clientfield_escape_pod_impact_fx", 1 );
		escape_pod setclientfield( "clientfield_escape_pod_light_fx", 1 );
		flag_set( "escape_pod_needs_reset" );
		level waittill( "reset_escape_pod" );
		flag_clear( "escape_pod_needs_reset" );
		escape_pod setclientfield( "clientfield_escape_pod_impact_fx", 0 );
		escape_pod thread escape_pod_breaking_rotate();
		wait 6;
		escape_pod playsound( "zmb_elevator_run_start" );
		escape_pod playloopsound( "zmb_elevator_run", 1 );
		level notify( "escape_pod_moving_back_to_start_position" );
		if ( isDefined( escape_pod_blocker_door ) )
		{
			escape_pod_blocker_door trigger_on();
			escape_pod_blocker_door linkto( escape_pod );
			escape_pod escape_pod_unlinknodes( "escape_pod_door_l_node" );
			escape_pod escape_pod_unlinknodes( "escape_pod_door_r_node" );
		}
		escape_pod moveto( escape_pod.home_origin, 3, 0,1, 0,1 );
		escape_pod waittill( "movedone" );
		escape_pod stoploopsound( 1 );
		escape_pod playsound( "zmb_esc_pod_crash" );
		escape_pod playsound( "zmb_elevator_run_stop" );
		escape_pod playsound( "zmb_elevator_ding" );
		escape_pod thread reset_impact_animate();
		used_at_least_once = 1;
	}
}

escape_pod_walk_on_off( escape_pod )
{
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( isplayer( who ) )
		{
			if ( !is_true( who.in_escape_pod_trigger ) )
			{
				self thread escape_pod_walk_on_off_watch( who, escape_pod );
			}
		}
	}
}

escape_pod_walk_on_off_watch( who, escape_pod )
{
	who endon( "disconnect" );
	who.in_escape_pod_trigger = 1;
	playsoundatposition( "zmb_esc_pod_bump", escape_pod.origin + vectorScale( ( 0, 0, 1 ), 15 ) );
	while ( who istouching( self ) )
	{
		wait 1;
	}
	playsoundatposition( "zmb_esc_pod_bump", escape_pod.origin + vectorScale( ( 0, 0, 1 ), 15 ) );
	who.in_escape_pod_trigger = 0;
}

reset_impact_animate()
{
	self setanim( level.escape_elevator_prestine_impact_state );
	wait getanimlength( level.escape_elevator_prestine_impact_state );
	level notify( "escape_pod_returns_to_start_location" );
}

impact_animate()
{
	self setanim( level.escape_elevator_impact );
	wait getanimlength( level.escape_elevator_impact );
	self setanim( level.escape_elevator_idle );
}

escape_pod_state( set, wait_for_current_end )
{
	if ( isDefined( self.state ) && self.state == set )
	{
		return;
	}
	if ( is_true( wait_for_current_end ) )
	{
		self waittill( "done" );
	}
	self.state = set;
	switch( set )
	{
		case 1:
			self.state_anim = level.escape_elevator_1_state;
			break;
		case 2:
			self.state_anim = level.escape_elevator_2_state;
			break;
		case 3:
			self.state_anim = level.escape_elevator_3_state;
			break;
		case 4:
			self.state_anim = level.escape_elevator_4_state;
			break;
		case 5:
			self.state_anim = level.escape_elevator_5_state;
			break;
	}
	self setanim( self.state_anim );
}

escape_pod_state_run()
{
	while ( 1 )
	{
		while ( !isDefined( self.escape_pod_state ) )
		{
			wait 0,05;
		}
		while ( isDefined( self.state ) && self.state == 1 && self.state == self.escape_pod_state )
		{
			wait 0,05;
		}
		self.state = self.escape_pod_state;
		shouldwait = 1;
		switch( self.state )
		{
			case 1:
				self.state_anim = level.escape_elevator_1_state;
				shouldwait = 0;
				break;
			case 2:
				self.state_anim = level.escape_elevator_2_state;
				break;
			case 3:
				self.state_anim = level.escape_elevator_3_state;
				break;
			case 4:
				self.state_anim = level.escape_elevator_4_state;
				break;
			case 5:
				self.state_anim = level.escape_elevator_5_state;
				break;
		}
		self setanim( self.state_anim );
		if ( shouldwait )
		{
			wait ( getanimlength( self.state_anim ) - 0,05 );
			continue;
		}
		else
		{
			wait 0,05;
		}
	}
}

escape_pod_tell_fx()
{
	self setclientfield( "clientfield_escape_pod_tell_fx", 1 );
	wait 3;
	self setclientfield( "clientfield_escape_pod_tell_fx", 0 );
}

escape_pod_get_all_alive_players()
{
	players = get_players();
	players_alive = 0;
	_a1318 = players;
	_k1318 = getFirstArrayKey( _a1318 );
	while ( isDefined( _k1318 ) )
	{
		player = _a1318[ _k1318 ];
		if ( player.sessionstate != "spectator" )
		{
			players_alive++;
		}
		_k1318 = getNextArrayKey( _a1318, _k1318 );
	}
	return players_alive;
}

escape_pod_get_all_alive_players_inside()
{
	players = get_players();
	players_in_escape_pod = 0;
	_a1335 = players;
	_k1335 = getFirstArrayKey( _a1335 );
	while ( isDefined( _k1335 ) )
	{
		player = _a1335[ _k1335 ];
		if ( player.sessionstate != "spectator" )
		{
			if ( player istouching( self ) )
			{
				players_in_escape_pod++;
			}
		}
		_k1335 = getNextArrayKey( _a1335, _k1335 );
	}
	return players_in_escape_pod;
}

escape_pod_breaking_rotate()
{
	rolls = array( -3, 6, -6, 3 );
	time = 0,74;
	accel = 0,1;
	deccel = 0,1;
	_a1358 = rolls;
	_k1358 = getFirstArrayKey( _a1358 );
	while ( isDefined( _k1358 ) )
	{
		roll = _a1358[ _k1358 ];
		self rotateroll( roll, time, accel, deccel );
		self playsound( "zmb_esc_pod_bump" );
		self waittill( "rotatedone" );
		_k1358 = getNextArrayKey( _a1358, _k1358 );
	}
}

escape_pod_rotate()
{
	rolls = array( -3, 11, -8, 9, -13, 15, -13, 5, -9, 10, -4 );
	time = 0,21;
	accel = 0,1;
	deccel = 0,1;
	_a1375 = rolls;
	_k1375 = getFirstArrayKey( _a1375 );
	while ( isDefined( _k1375 ) )
	{
		roll = _a1375[ _k1375 ];
		self rotateroll( roll, time, accel, deccel );
		self waittill( "rotatedone" );
		_k1375 = getNextArrayKey( _a1375, _k1375 );
	}
}

escape_pod_move()
{
	shock_radius = 117,6;
	destination_struct = getstruct( self.target, "targetname" );
	level notify( "free_fall" );
	self playsound( "zmb_esc_pod_break" );
	self moveto( destination_struct.origin, 3, 0,1, 0,1 );
	self waittill( "movedone" );
	self playsound( "zmb_esc_pod_crash" );
	earthquake( 0,3, 1,5, self.origin, 256 );
	self notify( "reached_destination" );
	players = get_players();
	_a1398 = players;
	_k1398 = getFirstArrayKey( _a1398 );
	while ( isDefined( _k1398 ) )
	{
		player = _a1398[ _k1398 ];
		if ( !is_true( player.riding_escape_pod ) )
		{
		}
		else
		{
			player.riding_escape_pod = 0;
			player allowstand( 0 );
			player allowcrouch( 0 );
			player setstance( "prone" );
			player shellshock( "elevator_crash", 4,5 );
			player allowjump( 1 );
			player allowstand( 1 );
			player allowcrouch( 1 );
		}
		_k1398 = getNextArrayKey( _a1398, _k1398 );
	}
}

escape_pod_shake()
{
	self endon( "reached_destination" );
	duration = randomfloatrange( 0,5, 1,5 );
	wait_time = randomfloatrange( 1,5, 2,5 );
	while ( 1 )
	{
		wait wait_time;
		earthquake( 0,2, duration, self.origin, 1024 );
	}
}

escape_pod_linknodes( node_name )
{
	start_node = getnode( node_name, "targetname" );
	while ( isDefined( start_node ) )
	{
		start_node.links = [];
		near_nodes = getnodesinradiussorted( start_node.origin, 128, 0, 64, "pathnodes" );
		links = 0;
		_a1445 = near_nodes;
		_k1445 = getFirstArrayKey( _a1445 );
		while ( isDefined( _k1445 ) )
		{
			node = _a1445[ _k1445 ];
			if ( !isDefined( node.target ) )
			{
				self.link_start[ self.link_start.size ] = start_node;
				self.link_end[ self.link_end.size ] = node;
				maps/mp/zm_highrise_utility::highrise_link_nodes( start_node, node );
				maps/mp/zm_highrise_utility::highrise_link_nodes( node, start_node );
				start_node.links[ start_node.links.size ] = node;
				links++;
				if ( links == 2 )
				{
					return;
				}
			}
			else
			{
				_k1445 = getNextArrayKey( _a1445, _k1445 );
			}
		}
	}
}

escape_pod_unlinknodes( node_name )
{
	start_node = getnode( node_name, "targetname" );
	while ( isDefined( start_node ) && isDefined( start_node.links ) )
	{
		linked_nodes = start_node.links;
		_a1476 = linked_nodes;
		_k1476 = getFirstArrayKey( _a1476 );
		while ( isDefined( _k1476 ) )
		{
			node = _a1476[ _k1476 ];
			if ( !isDefined( node.target ) )
			{
				maps/mp/zm_highrise_utility::highrise_unlink_nodes( start_node, node );
				maps/mp/zm_highrise_utility::highrise_unlink_nodes( node, start_node );
			}
			_k1476 = getNextArrayKey( _a1476, _k1476 );
		}
	}
}

escape_pod_are_all_alive_players_ready()
{
	players = get_players();
	players_in_escape_pod = 0;
	players_alive = 0;
	_a1506 = players;
	_k1506 = getFirstArrayKey( _a1506 );
	while ( isDefined( _k1506 ) )
	{
		player = _a1506[ _k1506 ];
		if ( player.sessionstate != "spectator" )
		{
			players_alive++;
			if ( player istouching( self ) )
			{
				players_in_escape_pod++;
			}
		}
		_k1506 = getNextArrayKey( _a1506, _k1506 );
	}
	return players_alive == players_in_escape_pod;
}

watch_escapepod_devgui()
{
/#
	while ( 1 )
	{
		resetcmd = getDvar( "zombie_devgui_hrescapepodreset" );
		if ( isDefined( resetcmd ) && resetcmd != "" )
		{
			level notify( "reset_escape_pod" );
			setdvar( "zombie_devgui_hrescapepodreset", "" );
		}
		wait 1;
#/
	}
}

check_valid_poi( valid )
{
	_a1545 = level.elevator_volumes;
	_k1545 = getFirstArrayKey( _a1545 );
	while ( isDefined( _k1545 ) )
	{
		volume = _a1545[ _k1545 ];
		if ( self istouching( volume ) )
		{
			return 0;
		}
		_k1545 = getNextArrayKey( _a1545, _k1545 );
	}
	return valid;
}
