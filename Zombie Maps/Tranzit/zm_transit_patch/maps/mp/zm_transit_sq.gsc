#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( level.createfx_enabled )
	{
		return;
	}
	if ( isDefined( level.gamedifficulty ) && level.gamedifficulty == 0 )
	{
		level thread sq_easy_cleanup();
		return;
	}
	level.sq_volume = getent( "sq_common_area", "targetname" );
	level.sq_clip = getent( "sq_common_clip", "targetname" );
	register_map_navcard( "navcard_held_zm_transit", "navcard_held_zm_buried" );
	if ( isDefined( level.sq_clip ) )
	{
		level.sq_clip connectpaths();
		level.sq_clip trigger_off();
	}
	maps/mp/zombies/_zm_spawner::register_zombie_death_event_callback( ::sq_zombie_death_event_response );
	declare_sidequest( "sq", ::init_sidequest, ::sidequest_logic, ::complete_sidequest, ::generic_stage_start, ::generic_stage_complete );
	init_sidequest_vo();
	precache_sidequest_assets();
	level thread survivor_vox();
	level thread avogadro_is_near_tower();
	level thread avogadro_far_from_tower();
	level thread avogadro_stab_watch();
	level thread init_navcard();
	level thread init_navcomputer();
	level.buildable_built_custom_func = ::builable_built_custom_func;
	level thread richtofen_sidequest_power_state();
}

sq_easy_cleanup()
{
	computer_buildable_trig = getent( "sq_common_buildable_trigger", "targetname" );
	computer_buildable_trig delete();
	sq_buildables = getentarray( "buildable_sq_common", "targetname" );
	_a64 = sq_buildables;
	_k64 = getFirstArrayKey( _a64 );
	while ( isDefined( _k64 ) )
	{
		item = _a64[ _k64 ];
		item delete();
		_k64 = getNextArrayKey( _a64, _k64 );
	}
}

init_player_sidequest_stats()
{
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_started", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_maxis_reset", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_rich_reset", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_rich_stage_1", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_rich_stage_2", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_rich_stage_3", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_rich_complete", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_maxis_stage_1", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_maxis_stage_2", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_maxis_stage_3", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_maxis_complete", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "sq_transit_last_completed", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "navcard_held_zm_transit", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "navcard_held_zm_highrise", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "navcard_held_zm_buried", 0 );
	self maps/mp/gametypes_zm/_globallogic_score::initpersstat( "navcard_applied_zm_transit", 0 );
}

init_sidequest_vo()
{
	level.power_station_zones = [];
	level.power_station_zones[ level.power_station_zones.size ] = "zone_trans_6";
	level.power_station_zones[ level.power_station_zones.size ] = "zone_amb_cornfield";
	level.power_station_zones[ level.power_station_zones.size ] = "zone_trans_7";
	level.power_station_zones[ level.power_station_zones.size ] = "zone_pow_ext1";
	level.power_station_zones[ level.power_station_zones.size ] = "zone_prr";
	level.power_station_zones[ level.power_station_zones.size ] = "zone_pcr";
	level.power_station_zones[ level.power_station_zones.size ] = "zone_pow_warehouse";
}

init_sidequest()
{
	players = get_players();
}

start_transit_sidequest()
{
	if ( level.gamedifficulty == 0 )
	{
		return;
	}
	sidequest_start( "sq" );
}

sidequest_logic()
{
	level thread sidequest_main();
	wait_for_buildable( "sq_common" );
	if ( isDefined( level.navcomputer_spawned ) && !level.navcomputer_spawned )
	{
		update_sidequest_stats( "sq_transit_started" );
	}
	level thread navcomputer_waitfor_navcard();
	if ( flag( "power_on" ) )
	{
		level thread richtofensay( "vox_zmba_sidequest_jet_terminal_0" );
	}
	hint_said = 0;
	while ( !hint_said )
	{
		level waittill( "maxi_terminal_vox" );
		if ( flag( "power_on" ) )
		{
			hint_said = 1;
		}
		wait 0,05;
	}
	maxissay( "vox_maxi_turbine_terminal_0", ( 11360, 8489, -576 ) );
}

complete_sidequest()
{
}

sidequest_main()
{
	sidequest_init_tracker();
	flag_wait( "start_zombie_round_logic" );
	level.maxcompleted = 0;
	level.richcompleted = 0;
	players = get_players();
	_a180 = players;
	_k180 = getFirstArrayKey( _a180 );
	while ( isDefined( _k180 ) )
	{
		player = _a180[ _k180 ];
		player.transit_sq_started = 1;
		lastcompleted = player maps/mp/zombies/_zm_stats::get_global_stat( "sq_transit_last_completed" );
		if ( lastcompleted == 1 )
		{
			level.richcompleted = 1;
		}
		else
		{
			if ( lastcompleted == 2 )
			{
				level.maxcompleted = 1;
			}
		}
		_k180 = getNextArrayKey( _a180, _k180 );
	}
	if ( level.richcompleted )
	{
		clientnotify( "sqrc" );
		wait 1;
	}
	if ( level.maxcompleted )
	{
		clientnotify( "sqmc" );
		wait 1;
	}
	if ( level.richcompleted && level.maxcompleted )
	{
		clientnotify( "sqkl" );
		return;
	}
	while ( 1 )
	{
		level thread maxis_sidequest();
		flag_wait( "power_on" );
		if ( isDefined( level.maxcompleted ) && !level.maxcompleted )
		{
			update_sidequest_stats( "sq_transit_maxis_reset" );
		}
		if ( isDefined( level.maxis_sq_intro_said ) && !level.maxis_sq_intro_said && isDefined( level.maxcompleted ) && !level.maxcompleted )
		{
			wait 2;
			level.maxis_sq_intro_said = 1;
			level thread maxissay( "vox_maxi_power_on_0", ( 12072, 8496, -704 ), undefined, undefined, 1 );
		}
		level thread richtofen_sidequest();
		flag_waitopen( "power_on" );
		if ( isDefined( level.richcompleted ) && !level.richcompleted )
		{
			update_sidequest_stats( "sq_transit_rich_reset" );
		}
	}
}

sidequest_init_tracker()
{
	level.sq_progress = [];
	level.sq_progress = [];
	level.sq_progress[ "maxis" ] = [];
	level.sq_progress[ "maxis" ][ "A_turbine_1" ] = 0;
	level.sq_progress[ "maxis" ][ "A_turbine_2" ] = 0;
	level.sq_progress[ "maxis" ][ "A_complete" ] = 0;
	level.sq_progress[ "maxis" ][ "B_complete" ] = 0;
	level.sq_progress[ "maxis" ][ "C_turbine_1" ] = 0;
	level.sq_progress[ "maxis" ][ "C_screecher_1" ] = 0;
	level.sq_progress[ "maxis" ][ "C_turbine_2" ] = 0;
	level.sq_progress[ "maxis" ][ "C_screecher_2" ] = 0;
	level.sq_progress[ "maxis" ][ "C_complete" ] = 0;
	level.sq_progress[ "maxis" ][ "FINISHED" ] = 0;
	level.sq_progress[ "rich" ] = [];
	level.sq_progress[ "rich" ][ "A_jetgun_built" ] = 0;
	level.sq_progress[ "rich" ][ "A_jetgun_tower" ] = 0;
	level.sq_progress[ "rich" ][ "A_complete" ] = 0;
	level.sq_progress[ "rich" ][ "B_zombies_tower" ] = 0;
	level.sq_progress[ "rich" ][ "B_complete" ] = 0;
	level.sq_progress[ "rich" ][ "C_screecher_light" ] = 0;
	level.sq_progress[ "rich" ][ "C_complete" ] = 0;
	level.sq_progress[ "rich" ][ "FINISHED" ] = 0;
/#
	if ( getDvarInt( #"113D490F" ) > 0 )
	{
		level thread sidequest_debug_tracker();
#/
	}
}

sidequest_debug_tracker()
{
/#
	arraymainkeys = getarraykeys( level.sq_progress );
	index = 0;
	x = 0;
	while ( x < arraymainkeys.size )
	{
		arraysubkeys = getarraykeys( level.sq_progress[ arraymainkeys[ x ] ] );
		_a289 = arraysubkeys;
		_k289 = getFirstArrayKey( _a289 );
		while ( isDefined( _k289 ) )
		{
			key = _a289[ _k289 ];
			hudelem = newhudelem();
			hudelem.alignx = "left";
			hudelem.location = 0;
			hudelem.foreground = 1;
			hudelem.fontscale = 1,1;
			hudelem.sort = 20 - index;
			hudelem.alpha = 1;
			hudelem.x = 0;
			hudelem.y = 60 + ( index * 15 );
			hudelem thread sidequest_debug_tracker_update( arraymainkeys[ x ], key );
			index++;
			_k289 = getNextArrayKey( _a289, _k289 );
		}
		x++;
#/
	}
}

sidequest_debug_tracker_update( mainkey, subkey )
{
/#
	while ( 1 )
	{
		value = level.sq_progress[ mainkey ][ subkey ];
		str = ( mainkey + " -- " ) + subkey + ": ";
		if ( isDefined( value ) && !isint( value ) && isDefined( value.classname ) )
		{
			self settext( str + "[X]" );
		}
		else
		{
			if ( isDefined( value ) )
			{
				if ( !isint( value ) && !isDefined( value.classname ) && isDefined( value.targetname ) && value.targetname == "screecher_escape" )
				{
					self settext( str + "[X]" );
				}
				else
				{
					self settext( str + value );
				}
				break;
			}
			else
			{
				self settext( str + "0" );
			}
		}
		wait 1;
#/
	}
}

generic_stage_start()
{
	level._stage_active = 1;
}

generic_stage_complete()
{
	level._stage_active = 0;
}

maxis_sidequest()
{
	level endon( "power_on" );
	if ( flag( "power_on" ) || isDefined( level.maxcompleted ) && level.maxcompleted )
	{
		return;
	}
	update_sidequest_stats( "sq_transit_maxis_stage_1" );
	level thread maxis_sidequest_a();
	level thread maxis_sidequest_b();
	level thread maxis_sidequest_c();
	level thread avogadro_stunned_vo();
}

turbine_power_watcher( player )
{
	level endon( "end_avogadro_turbines" );
	self endon( "death" );
	self.powered = undefined;
	turbine_failed_vo = undefined;
	while ( isDefined( self ) )
	{
		wait 2;
		if ( is_true( player.turbine_power_is_on ) && !is_true( player.turbine_emped ) )
		{
			self.powered = 1;
			continue;
		}
		else
		{
			if ( is_true( player.turbine_emped ) || !is_true( player.turbine_power_is_on ) )
			{
				wait 2;
				self.powered = 0;
				if ( !isDefined( turbine_failed_vo ) )
				{
					level thread maxissay( "vox_maxi_turbines_out_0", self.origin );
					turbine_failed_vo = 1;
				}
			}
		}
	}
}

maxis_sidequest_a()
{
	level endon( "power_on" );
	if ( isDefined( level.sq_progress[ "maxis" ][ "B_complete" ] ) && !level.sq_progress[ "maxis" ][ "B_complete" ] )
	{
		level.sq_progress[ "maxis" ][ "A_complete" ] = 0;
	}
	while ( 1 )
	{
		players = get_players();
		_a423 = players;
		_k423 = getFirstArrayKey( _a423 );
		while ( isDefined( _k423 ) )
		{
			player = _a423[ _k423 ];
			if ( isDefined( player.buildableturbine ) && player.buildableturbine istouching( level.sq_volume ) )
			{
				level notify( "maxi_terminal_vox" );
				player.buildableturbine thread turbine_watch_cleanup();
				if ( !isDefined( level.sq_progress[ "maxis" ][ "A_turbine_1" ] ) )
				{
					level.sq_progress[ "maxis" ][ "A_turbine_1" ] = player.buildableturbine;
					level.sq_progress[ "maxis" ][ "A_turbine_1" ] thread turbine_power_watcher( player );
					break;
				}
				else
				{
					if ( !isDefined( level.sq_progress[ "maxis" ][ "A_turbine_2" ] ) )
					{
						level.sq_progress[ "maxis" ][ "A_turbine_2" ] = player.buildableturbine;
						level.sq_progress[ "maxis" ][ "A_turbine_2" ] thread turbine_power_watcher( player );
					}
				}
			}
			_k423 = getNextArrayKey( _a423, _k423 );
		}
		if ( get_how_many_progressed_from( "maxis", "A_turbine_1", "A_turbine_2" ) == 1 )
		{
			level thread maxissay( "vox_maxi_turbine_1tower_0", ( 7737, -416, -142 ) );
		}
		if ( get_how_many_progressed_from( "maxis", "A_turbine_1", "A_turbine_2" ) == 2 )
		{
			if ( avogadro_at_tower() )
			{
				level thread maxissay( "vox_maxi_turbine_2tower_avo_0", ( 7737, -416, -142 ) );
			}
			else
			{
				level thread maxissay( "vox_maxi_turbine_2tower_0", ( 7737, -416, -142 ) );
			}
			update_sidequest_stats( "sq_transit_maxis_stage_2" );
			level thread maxis_sidequest_complete_check( "A_complete" );
		}
		level waittill_either( "turbine_deployed", "equip_turbine_zm_cleaned_up" );
		if ( !level.sq_progress[ "maxis" ][ "B_complete" ] )
		{
			level.sq_progress[ "maxis" ][ "A_complete" ] = 0;
			continue;
		}
		else
		{
		}
	}
}

maxis_sidequest_b()
{
	level endon( "power_on" );
	while ( 1 )
	{
		level waittill( "stun_avogadro", avogadro );
		if ( isDefined( level.sq_progress[ "maxis" ][ "A_turbine_1" ] ) && is_true( level.sq_progress[ "maxis" ][ "A_turbine_1" ].powered ) && isDefined( level.sq_progress[ "maxis" ][ "A_turbine_2" ] ) && is_true( level.sq_progress[ "maxis" ][ "A_turbine_2" ].powered ) )
		{
			if ( isDefined( avogadro ) && avogadro istouching( level.sq_volume ) )
			{
				level notify( "end_avogadro_turbines" );
				break;
			}
		}
		else
		{
		}
	}
	level notify( "maxis_stage_b" );
	level thread maxissay( "vox_maxi_avogadro_emp_0", ( 7737, -416, -142 ) );
	update_sidequest_stats( "sq_transit_maxis_stage_3" );
	player = get_players();
	player[ 0 ] setclientfield( "sq_tower_sparks", 1 );
	player[ 0 ] setclientfield( "screecher_maxis_lights", 1 );
	level thread maxis_sidequest_complete_check( "B_complete" );
}

maxis_sidequest_c()
{
	flag_wait( "power_on" );
	flag_waitopen( "power_on" );
	level endon( "power_on" );
	level.sq_progress[ "maxis" ][ "C_complete" ] = 0;
	turbine_1_talked = 0;
	turbine_2_talked = 0;
	screech_zones = getstructarray( "screecher_escape", "targetname" );
	while ( 1 )
	{
		if ( !isDefined( level.sq_progress[ "maxis" ][ "C_turbine_1" ] ) )
		{
		}
		if ( !isDefined( level.sq_progress[ "maxis" ][ "C_turbine_2" ] ) )
		{
		}
		players = get_players();
		_a548 = players;
		_k548 = getFirstArrayKey( _a548 );
		while ( isDefined( _k548 ) )
		{
			player = _a548[ _k548 ];
			while ( isDefined( player.buildableturbine ) )
			{
				x = 0;
				while ( x < screech_zones.size )
				{
					zone = screech_zones[ x ];
					if ( distancesquared( player.buildableturbine.origin, zone.origin ) < ( zone.radius * zone.radius ) )
					{
						player.buildableturbine thread turbine_watch_cleanup();
						if ( !isDefined( level.sq_progress[ "maxis" ][ "C_turbine_1" ] ) )
						{
							if ( !isDefined( level.sq_progress[ "maxis" ][ "C_screecher_2" ] ) || zone != level.sq_progress[ "maxis" ][ "C_screecher_2" ] )
							{
								level.sq_progress[ "maxis" ][ "C_turbine_1" ] = player.buildableturbine;
								level.sq_progress[ "maxis" ][ "C_screecher_1" ] = zone;
							}
							x++;
							continue;
						}
						else
						{
							if ( !isDefined( level.sq_progress[ "maxis" ][ "C_turbine_2" ] ) )
							{
								if ( !isDefined( level.sq_progress[ "maxis" ][ "C_screecher_1" ] ) || zone != level.sq_progress[ "maxis" ][ "C_screecher_1" ] )
								{
									level.sq_progress[ "maxis" ][ "C_turbine_2" ] = player.buildableturbine;
									level.sq_progress[ "maxis" ][ "C_screecher_2" ] = zone;
								}
							}
						}
					}
					x++;
				}
			}
			_k548 = getNextArrayKey( _a548, _k548 );
		}
		if ( get_how_many_progressed_from( "maxis", "C_turbine_1", "C_turbine_2" ) == 1 )
		{
			zone = undefined;
			if ( isDefined( level.sq_progress[ "maxis" ][ "C_turbine_1" ] ) )
			{
				zone = level.sq_progress[ "maxis" ][ "C_screecher_1" ];
			}
			else
			{
				zone = level.sq_progress[ "maxis" ][ "C_screecher_2" ];
			}
			if ( isDefined( zone ) && !turbine_1_talked )
			{
				turbine_1_talked = 1;
				level thread maxissay( "vox_maxi_turbine_1light_0", zone.origin );
			}
		}
		if ( get_how_many_progressed_from( "maxis", "C_turbine_1", "C_turbine_2" ) == 2 )
		{
			zone = undefined;
			if ( isDefined( level.sq_progress[ "maxis" ][ "C_turbine_1" ] ) )
			{
				zone = level.sq_progress[ "maxis" ][ "C_screecher_1" ];
			}
			else
			{
				zone = level.sq_progress[ "maxis" ][ "C_screecher_2" ];
			}
			if ( isDefined( zone ) )
			{
				if ( level.sq_progress[ "maxis" ][ "B_complete" ] && level.sq_progress[ "maxis" ][ "A_complete" ] )
				{
					if ( !turbine_2_talked )
					{
						level thread maxissay( "vox_maxi_turbine_2light_on_0", zone.origin );
						turbine_2_talked = 1;
					}
					player = get_players();
					player[ 0 ] setclientfield( "screecher_maxis_lights", 0 );
					level maxis_sidequest_complete_check( "C_complete" );
					return;
					break;
				}
				else
				{
					level thread maxissay( "vox_maxi_turbine_2light_off_0", zone.origin );
				}
			}
		}
		level waittill_either( "turbine_deployed", "equip_turbine_zm_cleaned_up" );
		level.sq_progress[ "maxis" ][ "C_complete" ] = 0;
	}
}

maxis_sidequest_complete_check( nowcomplete )
{
	level.sq_progress[ "maxis" ][ nowcomplete ] = 1;
	if ( level.sq_progress[ "maxis" ][ "A_complete" ] && level.sq_progress[ "maxis" ][ "B_complete" ] && level.sq_progress[ "maxis" ][ "C_complete" ] )
	{
		level maxis_sidequest_complete();
	}
}

maxis_sidequest_complete()
{
	turbinescriptnoteworthy1 = undefined;
	turbinescriptnoteworthy2 = undefined;
	if ( isDefined( level.sq_progress[ "maxis" ][ "C_screecher_1" ] ) && isDefined( level.sq_progress[ "maxis" ][ "C_screecher_1" ].script_noteworthy ) )
	{
		turbinescriptnoteworthy1 = level.sq_progress[ "maxis" ][ "C_screecher_1" ].script_noteworthy;
	}
	if ( isDefined( level.sq_progress[ "maxis" ][ "C_screecher_2" ] ) && isDefined( level.sq_progress[ "maxis" ][ "C_screecher_2" ].script_noteworthy ) )
	{
		turbinescriptnoteworthy2 = level.sq_progress[ "maxis" ][ "C_screecher_2" ].script_noteworthy;
	}
	update_sidequest_stats( "sq_transit_maxis_complete" );
	level sidequest_complete( "maxis" );
	level.sq_progress[ "maxis" ][ "FINISHED" ] = 1;
	level.maxcompleted = 1;
	clientnotify( "sq_kfx" );
	if ( isDefined( level.richcompleted ) && level.richcompleted )
	{
		level clientnotify( "sq_krt" );
	}
	wait 1;
	clientnotify( "sqm" );
	wait 1;
	level set_screecher_zone_origin( turbinescriptnoteworthy1 );
	wait 1;
	clientnotify( "sq_max" );
	wait 1;
	level set_screecher_zone_origin( turbinescriptnoteworthy2 );
	wait 1;
	clientnotify( "sq_max" );
	level thread droppowerup( "maxis" );
}

richtofen_sidequest()
{
	level endon( "power_turned_off" );
	if ( !flag( "power_on" ) || isDefined( level.richcompleted ) && level.richcompleted )
	{
		return;
	}
	if ( isDefined( level.richtofen_sq_intro_said ) && !level.richtofen_sq_intro_said )
	{
		level thread wait_for_richtoffen_intro();
	}
	update_sidequest_stats( "sq_transit_rich_stage_1" );
	level thread richtofen_sidequest_a();
	level thread richtofen_sidequest_b();
	level thread richtofen_sidequest_c();
}

richtofen_sidequest_power_state()
{
	flag_wait( "power_on" );
	while ( 1 )
	{
		flag_waitopen( "power_on" );
		level notify( "power_turned_off" );
		level notify( "power_off" );
		level thread maxissay( "vox_maxi_power_off_0", ( 12072, 8496, -704 ), undefined, undefined, 1 );
		wait 7;
		level thread richtofensay( "vox_zmba_sidequest_power_off_0", undefined, 1, 15 );
		flag_wait( "power_on" );
		level thread richtofensay( "vox_zmba_sidequest_emp_off_0", undefined, 1, 15 );
		wait 7;
		level thread maxissay( "vox_maxi_emp_off_0", ( 12072, 8496, -704 ), undefined, undefined, 1 );
	}
}

richtofen_sidequest_a()
{
	level endon( "power_off" );
	level.sq_progress[ "rich" ][ "A_jetgun_built" ] = 0;
	level.sq_progress[ "rich" ][ "A_jetgun_tower" ] = 0;
	level.sq_progress[ "rich" ][ "A_complete" ] = 0;
	ric_fail_out = undefined;
	ric_fail_heat = undefined;
	if ( isDefined( level.buildables_built[ "jetgun_zm" ] ) && !level.buildables_built[ "jetgun_zm" ] )
	{
		wait_for_buildable( "jetgun_zm" );
	}
	level.sq_progress[ "rich" ][ "A_jetgun_built" ] = 1;
	while ( 1 )
	{
		level.sq_volume waittill( "trigger", who );
		if ( isplayer( who ) && isalive( who ) && who getcurrentweapon() == "jetgun_zm" || !isDefined( who.jetgun_heatval ) && who.jetgun_heatval < 1 )
		{
			who thread left_sq_area_watcher( level.sq_volume );
			notifystring = who waittill_any_return( "disconnect", "weapon_change", "death", "player_downed", "jetgun_overheated", "left_sg_area" );
			if ( notifystring == "jetgun_overheated" && isDefined( who ) && who istouching( level.sq_volume ) )
			{
				self.checking_jetgun_fire = 0;
				break;
			}
			else if ( !isDefined( ric_fail_out ) )
			{
				ric_fail_out = 1;
				level thread richtofensay( "vox_zmba_sidequest_jet_low_0", undefined, 0, 10 );
			}
			self.checking_jetgun_fire = 0;
			continue;
		}
		else
		{
			if ( isplayer( who ) && isalive( who ) && who getcurrentweapon() == "jetgun_zm" && isDefined( who.jetgun_heatval ) && who.jetgun_heatval > 1 )
			{
				if ( !isDefined( ric_fail_heat ) )
				{
					ric_fail_heat = 1;
					level thread richtofensay( "vox_zmba_sidequest_jet_low_0", undefined, 0, 10 );
				}
			}
		}
	}
	level thread richtofensay( "vox_zmba_sidequest_jet_empty_0", undefined, 0, 16 );
	player = get_players();
	player[ 0 ] setclientfield( "screecher_sq_lights", 1 );
	update_sidequest_stats( "sq_transit_rich_stage_2" );
	level thread richtofen_sidequest_complete_check( "A_complete" );
	level.sq_progress[ "rich" ][ "A_jetgun_tower" ] = 1;
}

left_sq_area_watcher( volume )
{
	while ( self istouching( volume ) )
	{
		wait 0,5;
	}
	self notify( "left_sg_area" );
}

richtofen_sidequest_b()
{
	level endon( "power_off" );
	level.sq_progress[ "rich" ][ "B_zombies_tower" ] = 25;
	level thread lure_zombies_to_tower_hint();
	while ( level.sq_progress[ "rich" ][ "B_zombies_tower" ] > 0 )
	{
		level waittill( "zombie_died_in_sq_volume" );
		while ( !level.sq_progress[ "rich" ][ "A_complete" ] )
		{
			level thread richtofensay( "vox_zmba_sidequest_blow_mag_0" );
		}
		level.sq_progress[ "rich" ][ "B_zombies_tower" ]--;

		if ( level.sq_progress[ "rich" ][ "B_zombies_tower" ] > 0 )
		{
		}
	}
	level thread richtofensay( "vox_zmba_sidequest_blow_nomag_0" );
	update_sidequest_stats( "sq_transit_rich_stage_3" );
	level notify( "sq_stage_3complete" );
	level thread richtofen_sidequest_complete_check( "B_complete" );
}

lure_zombies_to_tower_hint()
{
	level endon( "power_on" );
	level endon( "sq_stage_3complete" );
	zombie_train = 0;
	lure_distance = 722500;
	while ( !zombie_train )
	{
		zombies = getaiarray();
		counter = 0;
		_a881 = zombies;
		_k881 = getFirstArrayKey( _a881 );
		while ( isDefined( _k881 ) )
		{
			zombie = _a881[ _k881 ];
			if ( distancesquared( zombie.origin, level.sq_volume.origin ) < lure_distance )
			{
				counter++;
			}
			_k881 = getNextArrayKey( _a881, _k881 );
		}
		if ( counter >= 5 )
		{
			zombie_train = 1;
		}
		wait 3;
	}
	level thread richtofensay( "vox_zmba_sidequest_zom_lure_0" );
}

richtofen_sidequest_c()
{
	level endon( "power_off" );
	level endon( "richtofen_sq_complete" );
	screech_zones = getstructarray( "screecher_escape", "targetname" );
	level thread screecher_light_hint();
	level thread screecher_light_on_sq();
	level.sq_richtofen_c_screecher_lights = [];
	while ( 1 )
	{
		level waittill( "safety_light_power_off", screecher_zone );
		while ( !level.sq_progress[ "rich" ][ "A_complete" ] || !level.sq_progress[ "rich" ][ "B_complete" ] )
		{
			level thread richtofensay( "vox_zmba_sidequest_emp_nomag_0" );
		}
		level.sq_richtofen_c_screecher_lights[ level.sq_richtofen_c_screecher_lights.size ] = screecher_zone;
		level.sq_progress[ "rich" ][ "C_screecher_light" ]++;
		if ( level.sq_progress[ "rich" ][ "C_screecher_light" ] >= 4 )
		{
			break;
		}
		else
		{
			if ( isDefined( level.checking_for_richtofen_c_failure ) && !level.checking_for_richtofen_c_failure )
			{
				level thread check_for_richtofen_c_failure();
			}
		}
	}
	level thread richtofensay( "vox_zmba_sidequest_4emp_mag_0" );
	level notify( "richtofen_c_complete" );
	player = get_players();
	player[ 0 ] setclientfield( "screecher_sq_lights", 0 );
	level thread richtofen_sidequest_complete_check( "C_complete" );
}

check_for_richtofen_c_failure()
{
	if ( isDefined( level.checking_for_richtofen_c_failure ) && !level.checking_for_richtofen_c_failure )
	{
		level.checking_for_richtofen_c_failure = 1;
		wait 5;
		if ( level.sq_progress[ "rich" ][ "C_screecher_light" ] < 4 )
		{
			level thread richtofensay( "vox_zmba_sidequest_3emp_mag_0" );
			level.sq_progress[ "rich" ][ "C_screecher_light" ] = 0;
		}
		level.checking_for_richtofen_c_failure = 0;
	}
}

screecher_light_on_sq()
{
	while ( 1 )
	{
		level waittill( "safety_light_power_on", screecher_zone );
		arrayremovevalue( level.sq_richtofen_c_screecher_lights, screecher_zone );
		if ( level.sq_progress[ "rich" ][ "C_screecher_light" ] > 0 )
		{
			level.sq_progress[ "rich" ][ "C_screecher_light" ]--;

		}
	}
}

richtofen_sidequest_complete_check( nowcomplete )
{
	level.sq_progress[ "rich" ][ nowcomplete ] = 1;
	if ( level.sq_progress[ "rich" ][ "A_complete" ] && level.sq_progress[ "rich" ][ "B_complete" ] && level.sq_progress[ "rich" ][ "C_complete" ] )
	{
		level thread richtofen_sidequest_complete();
	}
}

richtofen_sidequest_complete()
{
	update_sidequest_stats( "sq_transit_rich_complete" );
	level thread sidequest_complete( "richtofen" );
	level.sq_progress[ "rich" ][ "FINISHED" ] = 1;
	level.richcompleted = 1;
	clientnotify( "sq_kfx" );
	if ( isDefined( level.maxcompleted ) && level.maxcompleted )
	{
		level clientnotify( "sq_kmt" );
	}
	wait 1;
	clientnotify( "sqr" );
	_a1007 = level.sq_richtofen_c_screecher_lights;
	_k1007 = getFirstArrayKey( _a1007 );
	while ( isDefined( _k1007 ) )
	{
		zone = _a1007[ _k1007 ];
		level set_screecher_zone_origin( zone.target.script_noteworthy );
		wait 1;
		clientnotify( "sq_rich" );
		wait 1;
		_k1007 = getNextArrayKey( _a1007, _k1007 );
	}
	level thread droppowerup( "richtofen" );
}

set_screecher_zone_origin( script_noteworthy )
{
	if ( !isDefined( script_noteworthy ) )
	{
		return;
	}
	switch( script_noteworthy )
	{
		case "cornfield":
			clientnotify( "zsc" );
			break;
		case "diner":
			clientnotify( "zsd" );
			break;
		case "forest":
			clientnotify( "zsf" );
			break;
		case "busdepot":
			clientnotify( "zsb" );
			break;
		case "bridgedepot":
			clientnotify( "zsbd" );
			break;
		case "townbridge":
			clientnotify( "zsbt" );
			break;
		case "huntershack":
			clientnotify( "zsh" );
			break;
		case "powerstation":
			clientnotify( "zsp" );
			break;
	}
}

turbine_watch_cleanup()
{
	if ( isDefined( self.turbine_watch_cleanup ) && self.turbine_watch_cleanup )
	{
		return;
	}
	self.turbine_watch_cleanup = 1;
	self waittill( "death" );
	level notify( "equip_turbine_zm_cleaned_up" );
}

get_how_many_progressed_from( story, a, b )
{
	if ( isDefined( level.sq_progress[ story ][ a ] ) || !isDefined( level.sq_progress[ story ][ b ] ) && !isDefined( level.sq_progress[ story ][ a ] ) && isDefined( level.sq_progress[ story ][ b ] ) )
	{
		return 1;
	}
	else
	{
		if ( isDefined( level.sq_progress[ story ][ a ] ) && isDefined( level.sq_progress[ story ][ b ] ) )
		{
			return 2;
		}
	}
	return 0;
}

sq_zombie_death_event_response()
{
	if ( distancesquared( self.origin, level.sq_volume.origin ) < 176400 && isDefined( self.damagemod ) )
	{
		mod = self.damagemod;
		if ( mod != "MOD_GRENADE" && mod != "MOD_GRENADE_SPLASH" && mod != "MOD_EXPLOSIVE" && mod != "MOD_EXPLOSIVE_SPLASH" || mod == "MOD_PROJECTILE" && mod == "MOD_PROJECTILE_SPLASH" )
		{
			level notify( "zombie_died_in_sq_volume" );
		}
	}
}

update_sidequest_stats( stat_name )
{
	maxis_complete = 0;
	rich_complete = 0;
	started = 0;
	if ( stat_name == "sq_transit_maxis_complete" )
	{
		maxis_complete = 1;
	}
	else
	{
		if ( stat_name == "sq_transit_rich_complete" )
		{
			rich_complete = 1;
		}
	}
	players = get_players();
	_a1124 = players;
	_k1124 = getFirstArrayKey( _a1124 );
	while ( isDefined( _k1124 ) )
	{
		player = _a1124[ _k1124 ];
		if ( stat_name == "sq_transit_started" )
		{
			player.transit_sq_started = 1;
		}
		else if ( stat_name == "navcard_applied_zm_transit" )
		{
			player maps/mp/zombies/_zm_stats::set_global_stat( level.navcard_needed, 0 );
			thread sq_refresh_player_navcard_hud();
		}
		else
		{
			if ( isDefined( player.transit_sq_started ) && !player.transit_sq_started )
			{
			}
		}
		else
		{
			if ( rich_complete )
			{
				player maps/mp/zombies/_zm_stats::set_global_stat( "sq_transit_last_completed", 1 );
				incrementcounter( "global_zm_total_rich_sq_complete_transit", 1 );
			}
			else
			{
				if ( maxis_complete )
				{
					player maps/mp/zombies/_zm_stats::set_global_stat( "sq_transit_last_completed", 2 );
					incrementcounter( "global_zm_total_max_sq_complete_transit", 1 );
				}
			}
			player maps/mp/zombies/_zm_stats::increment_client_stat( stat_name, 0 );
		}
		_k1124 = getNextArrayKey( _a1124, _k1124 );
	}
	if ( rich_complete || maxis_complete )
	{
		level notify( "transit_sidequest_achieved" );
	}
}

richtofensay( vox_line, intro, ignore_power_state, time )
{
	level endon( "end_game" );
	level endon( "intermission" );
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return;
	}
	if ( isDefined( level.richcompleted ) && level.richcompleted )
	{
		return;
	}
	level endon( "richtofen_c_complete" );
	if ( !isDefined( time ) )
	{
		time = 45;
	}
	while ( isDefined( level.richtofen_talking_to_samuel ) || level.richtofen_talking_to_samuel && isDefined( level.richtofen_sq_intro_said ) && !level.richtofen_sq_intro_said )
	{
		wait 1;
	}
	if ( isDefined( level.rich_sq_player ) && is_player_valid( level.rich_sq_player ) )
	{
/#
		iprintlnbold( "Richtoffen Says: " + vox_line );
#/
		if ( flag( "power_on" ) && !flag( "switches_on" ) && isDefined( ignore_power_state ) && !ignore_power_state )
		{
			return;
		}
		level.rich_sq_player playsoundtoplayer( vox_line, level.rich_sq_player );
		if ( isDefined( level.richtofen_talking_to_samuel ) && !level.richtofen_talking_to_samuel )
		{
			level thread richtofen_talking( time );
		}
	}
}

richtofen_talking( time )
{
	level.rich_sq_player.dontspeak = 1;
	level.richtofen_talking_to_samuel = 1;
	wait time;
	level.richtofen_talking_to_samuel = 0;
	if ( isDefined( level.rich_sq_player ) )
	{
		level.rich_sq_player.dontspeak = 0;
	}
}

maxissay( line, org, playonent, playonenttag, ignore_power_state )
{
	level endon( "end_game" );
	level endon( "intermission" );
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return;
	}
	if ( isDefined( level.maxcompleted ) && level.maxcompleted )
	{
		return;
	}
	if ( !flag( "power_on" ) && flag( "switches_on" ) && isDefined( ignore_power_state ) && !ignore_power_state )
	{
		return;
	}
	while ( isDefined( level.maxis_talking ) && level.maxis_talking )
	{
		wait 0,05;
	}
	level.maxis_talking = 1;
/#
	iprintlnbold( "Maxis Says: " + line );
#/
	if ( isDefined( playonent ) )
	{
		playonent playsoundontag( line, playonenttag );
	}
	else
	{
		playsoundatposition( line, org );
	}
	wait 10;
	level.maxis_talking = 0;
}

wait_for_richtoffen_intro()
{
	level endon( "intermission" );
	power_occupied = 1;
	while ( power_occupied )
	{
		inzone = 0;
		_a1274 = level.power_station_zones;
		_k1274 = getFirstArrayKey( _a1274 );
		while ( isDefined( _k1274 ) )
		{
			zone = _a1274[ _k1274 ];
			if ( isDefined( maps/mp/zombies/_zm_zonemgr::player_in_zone( zone ) ) && maps/mp/zombies/_zm_zonemgr::player_in_zone( zone ) )
			{
				inzone = 1;
			}
			_k1274 = getNextArrayKey( _a1274, _k1274 );
		}
		if ( !inzone )
		{
			power_occupied = 0;
		}
		wait 0,1;
	}
	wait 5;
	if ( !isDefined( level.rich_sq_player ) || !flag( "power_on" ) && !flag( "switches_on" ) )
	{
		return;
	}
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return;
	}
	level.rich_sq_player playsoundtoplayer( "vox_zmba_sidequest_power_on_0", level.rich_sq_player );
	richtofen_talking( 45 );
	level.richtofen_sq_intro_said = 1;
}

survivor_vox()
{
	initiated = 0;
	while ( !initiated )
	{
		players = get_players();
		_a1314 = players;
		_k1314 = getFirstArrayKey( _a1314 );
		while ( isDefined( _k1314 ) )
		{
			player = _a1314[ _k1314 ];
			if ( distance2dsquared( player.origin, ( 8000, -6656, 160 ) ) < 1225 )
			{
				if ( player usebuttonpressed() )
				{
					playsoundatposition( "zmb_zombie_arc", ( 8000, -6656, 160 ) );
					start_time = getTime();
					end_time = start_time + 5000;
					while ( player usebuttonpressed() && distance2dsquared( player.origin, ( 8000, -6656, 160 ) ) < 1225 && is_player_valid( player ) )
					{
						if ( getTime() > end_time )
						{
							initiated = 1;
						}
						wait 0,05;
					}
					playsoundatposition( "zmb_buildable_piece_add", ( 8000, -6656, 160 ) );
				}
			}
			_k1314 = getNextArrayKey( _a1314, _k1314 );
		}
		wait 1;
	}
	playsoundatposition( "zmb_weap_wall", ( 8000, -6656, 160 ) );
	i = -1;
	while ( 1 )
	{
		players = get_players();
		_a1343 = players;
		_k1343 = getFirstArrayKey( _a1343 );
		while ( isDefined( _k1343 ) )
		{
			player = _a1343[ _k1343 ];
			if ( distance2dsquared( player.origin, ( 8000, -6656, 160 ) ) < 1225 )
			{
				if ( player usebuttonpressed() && is_player_valid( player ) )
				{
					if ( flag( "power_on" ) )
					{
						if ( i == -1 || i > 4 )
						{
							playsoundatposition( "vox_maxi_tv_distress_0", ( 8000, -6656, 160 ) );
							i++;
							continue;
						}
						else
						{
							if ( i < 4 )
							{
								playsoundatposition( level.survivor_vox[ i ], ( 8000, -6656, 160 ) );
							}
						}
						i++;
					}
					wait 60;
				}
			}
			_k1343 = getNextArrayKey( _a1343, _k1343 );
		}
		wait 1;
	}
}

builable_built_custom_func( buildable )
{
	if ( buildable.buildable_name == "jetgun_zm" )
	{
		if ( flag( "power_on" ) || flag( "switches_on" ) )
		{
			level thread richtofensay( "vox_zmba_sidequest_jet_complete_0" );
			level.sq_jetgun_built = 1;
		}
	}
}

screecher_light_hint()
{
	level endon( "power_off" );
	level endon( "richtofen_c_complete" );
	while ( !level.sq_progress[ "rich" ][ "A_jetgun_tower" ] )
	{
		wait 1;
	}
	screech_zones = getstructarray( "screecher_escape", "targetname" );
	dist = 122500;
	while ( 1 )
	{
		count = 0;
		players = get_players();
		_a1399 = players;
		_k1399 = getFirstArrayKey( _a1399 );
		while ( isDefined( _k1399 ) )
		{
			player = _a1399[ _k1399 ];
			_a1401 = screech_zones;
			_k1401 = getFirstArrayKey( _a1401 );
			while ( isDefined( _k1401 ) )
			{
				zone = _a1401[ _k1401 ];
				if ( distancesquared( player.origin, zone.origin ) < dist )
				{
					if ( player maps/mp/zombies/_zm_weapons::has_weapon_or_upgrade( "emp_grenade_zm" ) )
					{
						count++;
					}
				}
				_k1401 = getNextArrayKey( _a1401, _k1401 );
			}
			_k1399 = getNextArrayKey( _a1399, _k1399 );
		}
		if ( count >= players.size )
		{
			richtofensay( "vox_zmba_sidequest_near_light_0" );
			return;
		}
		wait 2;
	}
}

maxi_near_corn_hint()
{
	level endon( "power_on" );
	say_hint = 0;
	while ( !say_hint )
	{
		players = get_players();
		_a1430 = players;
		_k1430 = getFirstArrayKey( _a1430 );
		while ( isDefined( _k1430 ) )
		{
			player = _a1430[ _k1430 ];
			if ( !player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_amb_cornfield" ) )
			{
			}
			else if ( isDefined( player.buildableturbine ) && isDefined( player.buildableturbine.equipment_can_move ) && player.buildableturbine.equipment_can_move && isDefined( player.isonbus ) && player.isonbus )
			{
				say_hint = 1;
			}
			else
			{
				if ( isDefined( player.buildableturbine ) && isDefined( player.isonbus ) && player.isonbus )
				{
					say_hint = 1;
				}
			}
			_k1430 = getNextArrayKey( _a1430, _k1430 );
		}
		wait 2;
	}
	level thread maxissay( "vox_maxi_near_corn_0", undefined, level.automaton, "J_neck" );
}

avogadro_far_from_tower()
{
	if ( isDefined( level.maxcompleted ) && level.maxcompleted )
	{
		return;
	}
	level waittill( "power_on" );
	level endon( "power_on" );
	say_hint = 0;
	while ( !say_hint )
	{
		players = get_players();
		_a1466 = players;
		_k1466 = getFirstArrayKey( _a1466 );
		while ( isDefined( _k1466 ) )
		{
			player = _a1466[ _k1466 ];
			if ( isDefined( player.isonbus ) && !player.isonbus )
			{
			}
			else
			{
				if ( !avogadro_near_tower() && player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_amb_cornfield" ) )
				{
					say_hint = 1;
				}
			}
			_k1466 = getNextArrayKey( _a1466, _k1466 );
		}
		wait 1;
	}
	level thread maxissay( "vox_maxi_avogadro_far_0", undefined, level.automaton, "J_neck" );
}

avogadro_near_tower()
{
	if ( isDefined( level.avogadro ) && level.avogadro maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_amb_cornfield" ) )
	{
		return 1;
	}
	return 0;
}

avogadro_stab_watch()
{
	if ( isDefined( level.maxcompleted ) && level.maxcompleted )
	{
		return;
	}
	level waittill( "avogadro_stabbed", avogadro );
	if ( !flag( "power_on" ) )
	{
		level thread maxissay( "vox_maxi_avogadro_stab_0", avogadro.origin );
	}
}

avogadro_is_near_tower()
{
	if ( isDefined( level.maxcompleted ) && level.maxcompleted )
	{
		return;
	}
	level waittill( "power_on" );
	level endon( "power_on" );
	say_hint = 0;
	while ( !say_hint )
	{
		if ( avogadro_near_tower() )
		{
			say_hint = 1;
		}
		wait 1;
	}
	level thread maxissay( "vox_maxi_avogadro_near_0", ( 7737, -416, -142 ) );
}

avogadro_at_tower()
{
	if ( isDefined( level.avogadro ) && level.avogadro istouching( level.sq_volume ) )
	{
		return 1;
	}
	return 0;
}

droppowerup( story )
{
	center_struct = getstruct( "sq_common_tower_fx", "targetname" );
	trace = bullettrace( center_struct.origin, center_struct.origin - vectorScale( ( 0, 0, 0 ), 999999 ), 0, undefined );
	poweruporigin = trace[ "position" ] + vectorScale( ( 0, 0, 0 ), 25 );
	mintime = 240;
	maxtime = 720;
	while ( 1 )
	{
		trail = spawn( "script_model", center_struct.origin );
		trail setmodel( "tag_origin" );
		wait 0,5;
		playfxontag( level._effect[ story + "_sparks" ], trail, "tag_origin" );
		trail moveto( poweruporigin, 10 );
		trail waittill( "movedone" );
		level thread droppoweruptemptation( story, poweruporigin );
		wait 1;
		trail delete();
		wait randomintrange( mintime, maxtime );
	}
}

droppoweruptemptation( story, origin )
{
	powerup = spawn( "script_model", origin );
	powerup endon( "powerup_grabbed" );
	powerup endon( "powerup_timedout" );
	temptation_array = array( "insta_kill", "nuke", "double_points", "carpenter" );
	temptation_index = 0;
	first_time = 1;
	rotation = 0;
	temptation_array = array_randomize( temptation_array );
	while ( isDefined( powerup ) )
	{
		powerup maps/mp/zombies/_zm_powerups::powerup_setup( temptation_array[ temptation_index ] );
		if ( first_time )
		{
			powerup thread maps/mp/zombies/_zm_powerups::powerup_timeout();
			powerup thread maps/mp/zombies/_zm_powerups::powerup_wobble();
			powerup thread maps/mp/zombies/_zm_powerups::powerup_grab();
			first_time = 0;
		}
		if ( rotation == 0 )
		{
			wait 15;
			rotation++;
			temptation_index++;
			continue;
		}
		else if ( rotation == 1 )
		{
			wait 7,5;
			rotation++;
			temptation_index++;
			continue;
		}
		else if ( rotation == 2 )
		{
			wait 2,5;
			rotation++;
			temptation_index++;
			continue;
		}
		else
		{
			wait 1,5;
			rotation++;
		}
		temptation_index++;
		if ( temptation_index >= temptation_array.size )
		{
			temptation_index = 0;
		}
	}
}

init_navcard()
{
	flag_wait( "start_zombie_round_logic" );
	spawn_card = 1;
	players = get_players();
	_a1634 = players;
	_k1634 = getFirstArrayKey( _a1634 );
	while ( isDefined( _k1634 ) )
	{
		player = _a1634[ _k1634 ];
		has_card = does_player_have_map_navcard( player );
		if ( has_card )
		{
			player.navcard_grabbed = level.map_navcard;
			spawn_card = 0;
		}
		_k1634 = getNextArrayKey( _a1634, _k1634 );
	}
	thread sq_refresh_player_navcard_hud();
	if ( !spawn_card )
	{
		return;
	}
	model = "p6_zm_keycard";
	org = ( -6245, 5479,5, -55,35 );
	angles = ( 0, 0, 0 );
	maps/mp/zombies/_zm_utility::place_navcard( model, level.map_navcard, org, angles );
}

init_navcomputer()
{
	flag_wait( "start_zombie_round_logic" );
	spawn_navcomputer = 1;
	players = get_players();
	_a1664 = players;
	_k1664 = getFirstArrayKey( _a1664 );
	while ( isDefined( _k1664 ) )
	{
		player = _a1664[ _k1664 ];
		built_comptuer = player maps/mp/zombies/_zm_stats::get_global_stat( "sq_transit_started" );
		if ( !built_comptuer )
		{
			spawn_navcomputer = 0;
			break;
		}
		else
		{
			_k1664 = getNextArrayKey( _a1664, _k1664 );
		}
	}
	if ( !spawn_navcomputer )
	{
		return;
	}
	level.navcomputer_spawned = 1;
	get_players()[ 0 ] maps/mp/zombies/_zm_buildables::player_finish_buildable( level.sq_buildable.buildablezone );
	while ( isDefined( level.sq_buildable ) && isDefined( level.sq_buildable.model ) )
	{
		buildable = level.sq_buildable.buildablezone;
		i = 0;
		while ( i < buildable.pieces.size )
		{
			if ( isDefined( buildable.pieces[ i ].model ) )
			{
				buildable.pieces[ i ].model delete();
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( buildable.pieces[ i ].unitrigger );
			}
			if ( isDefined( buildable.pieces[ i ].part_name ) )
			{
				buildable.stub.model notsolid();
				buildable.stub.model show();
				buildable.stub.model showpart( buildable.pieces[ i ].part_name );
			}
			i++;
		}
	}
	level thread navcomputer_waitfor_navcard();
}

navcomputer_waitfor_navcard()
{
	computer_buildable_trig = getent( "sq_common_buildable_trigger", "targetname" );
	trig_pos = getstruct( "sq_common_key", "targetname" );
	navcomputer_use_trig = spawn( "trigger_radius_use", trig_pos.origin, 0, 48, 48 );
	navcomputer_use_trig setcursorhint( "HINT_NOICON" );
	navcomputer_use_trig sethintstring( &"ZOMBIE_NAVCARD_USE" );
	navcomputer_use_trig triggerignoreteam();
	while ( 1 )
	{
		navcomputer_use_trig waittill( "trigger", who );
		if ( isplayer( who ) && is_player_valid( who ) )
		{
			if ( does_player_have_correct_navcard( who ) )
			{
				navcomputer_use_trig sethintstring( &"ZOMBIE_NAVCARD_SUCCESS" );
				who playsound( "zmb_sq_navcard_success" );
				update_sidequest_stats( "navcard_applied_zm_transit" );
				return;
				break;
			}
			else
			{
				navcomputer_use_trig sethintstring( &"ZOMBIE_NAVCARD_FAIL" );
				wait 1;
				navcomputer_use_trig sethintstring( &"ZOMBIE_NAVCARD_USE" );
			}
		}
	}
}

avogadro_stunned_vo()
{
	level endon( "maxis_stage_b" );
	while ( 1 )
	{
		level waittill( "stun_avogadro", avogadro );
		if ( avogadro maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_prr" ) )
		{
			level thread maxissay( "vox_maxi_avogadro_stab_0", ( 12072, 8496, -704 ) );
			return;
		}
	}
}

sq_refresh_player_navcard_hud()
{
	if ( !isDefined( level.navcards ) )
	{
		return;
	}
	players = get_players();
	_a1759 = players;
	_k1759 = getFirstArrayKey( _a1759 );
	while ( isDefined( _k1759 ) )
	{
		player = _a1759[ _k1759 ];
		navcard_bits = 0;
		i = 0;
		while ( i < level.navcards.size )
		{
			hasit = player maps/mp/zombies/_zm_stats::get_global_stat( level.navcards[ i ] );
			if ( isDefined( player.navcard_grabbed ) && player.navcard_grabbed == level.navcards[ i ] )
			{
				hasit = 1;
			}
			if ( hasit )
			{
				navcard_bits += 1 << i;
			}
			i++;
		}
		wait_network_frame();
		player setclientfield( "navcard_held", 0 );
		if ( navcard_bits > 0 )
		{
			wait_network_frame();
			player setclientfield( "navcard_held", navcard_bits );
		}
		_k1759 = getNextArrayKey( _a1759, _k1759 );
	}
}
