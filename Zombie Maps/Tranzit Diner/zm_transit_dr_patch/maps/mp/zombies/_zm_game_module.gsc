#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

register_game_module( index, module_name, pre_init_func, post_init_func, pre_init_zombie_spawn_func, post_init_zombie_spawn_func, hub_start_func )
{
	if ( !isDefined( level._game_modules ) )
	{
		level._game_modules = [];
		level._num_registered_game_modules = 0;
	}
	i = 0;
	while ( i < level._num_registered_game_modules )
	{
		if ( !isDefined( level._game_modules[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( level._game_modules[ i ].index ) && level._game_modules[ i ].index == index )
			{
/#
				assert( level._game_modules[ i ].index != index, "A Game module is already registered for index (" + index + ")" );
#/
			}
		}
		i++;
	}
	level._game_modules[ level._num_registered_game_modules ] = spawnstruct();
	level._game_modules[ level._num_registered_game_modules ].index = index;
	level._game_modules[ level._num_registered_game_modules ].module_name = module_name;
	level._game_modules[ level._num_registered_game_modules ].pre_init_func = pre_init_func;
	level._game_modules[ level._num_registered_game_modules ].post_init_func = post_init_func;
	level._game_modules[ level._num_registered_game_modules ].pre_init_zombie_spawn_func = pre_init_zombie_spawn_func;
	level._game_modules[ level._num_registered_game_modules ].post_init_zombie_spawn_func = post_init_zombie_spawn_func;
	level._game_modules[ level._num_registered_game_modules ].hub_start_func = hub_start_func;
	level._num_registered_game_modules++;
}

set_current_game_module( game_module_index )
{
	if ( !isDefined( game_module_index ) )
	{
		level.current_game_module = level.game_module_classic_index;
		level.scr_zm_game_module = level.game_module_classic_index;
		return;
	}
	game_module = get_game_module( game_module_index );
	if ( !isDefined( game_module ) )
	{
/#
		assert( isDefined( game_module ), "unknown game module (" + game_module_index + ")" );
#/
		return;
	}
	level.current_game_module = game_module_index;
}

get_current_game_module()
{
	return get_game_module( level.current_game_module );
}

get_game_module( game_module_index )
{
	if ( !isDefined( game_module_index ) )
	{
		return undefined;
	}
	i = 0;
	while ( i < level._game_modules.size )
	{
		if ( level._game_modules[ i ].index == game_module_index )
		{
			return level._game_modules[ i ];
		}
		i++;
	}
	return undefined;
}

game_module_pre_zombie_spawn_init()
{
	current_module = get_current_game_module();
	if ( !isDefined( current_module ) || !isDefined( current_module.pre_init_zombie_spawn_func ) )
	{
		return;
	}
	self [[ current_module.pre_init_zombie_spawn_func ]]();
}

game_module_post_zombie_spawn_init()
{
	current_module = get_current_game_module();
	if ( !isDefined( current_module ) || !isDefined( current_module.post_init_zombie_spawn_func ) )
	{
		return;
	}
	self [[ current_module.post_init_zombie_spawn_func ]]();
}

kill_all_zombies()
{
	ai = get_round_enemy_array();
	_a115 = ai;
	_k115 = getFirstArrayKey( _a115 );
	while ( isDefined( _k115 ) )
	{
		zombie = _a115[ _k115 ];
		if ( isDefined( zombie ) )
		{
			zombie dodamage( zombie.maxhealth * 2, zombie.origin, zombie, zombie, "none", "MOD_SUICIDE" );
			wait 0,05;
		}
		_k115 = getNextArrayKey( _a115, _k115 );
	}
}

freeze_players( freeze )
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] freeze_player_controls( freeze );
		i++;
	}
}

turn_power_on_and_open_doors()
{
	level.local_doors_stay_open = 1;
	level.power_local_doors_globally = 1;
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
	zombie_doors = getentarray( "zombie_door", "targetname" );
	_a144 = zombie_doors;
	_k144 = getFirstArrayKey( _a144 );
	while ( isDefined( _k144 ) )
	{
		door = _a144[ _k144 ];
		if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "electric_door" )
		{
			door notify( "power_on" );
		}
		else
		{
			if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "local_electric_door" )
			{
				door notify( "local_power_on" );
			}
		}
		_k144 = getNextArrayKey( _a144, _k144 );
	}
}

respawn_spectators_and_freeze_players()
{
	players = get_players();
	_a161 = players;
	_k161 = getFirstArrayKey( _a161 );
	while ( isDefined( _k161 ) )
	{
		player = _a161[ _k161 ];
		if ( player.sessionstate == "spectator" )
		{
			if ( isDefined( player.spectate_hud ) )
			{
				player.spectate_hud destroy();
			}
			player [[ level.spawnplayer ]]();
		}
		player freeze_player_controls( 1 );
		_k161 = getNextArrayKey( _a161, _k161 );
	}
}

damage_callback_no_pvp_damage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker == self )
	{
		return idamage;
	}
	if ( isDefined( eattacker ) && !isplayer( eattacker ) )
	{
		return idamage;
	}
	if ( !isDefined( eattacker ) )
	{
		return idamage;
	}
	return 0;
}

respawn_players()
{
	players = get_players();
	_a196 = players;
	_k196 = getFirstArrayKey( _a196 );
	while ( isDefined( _k196 ) )
	{
		player = _a196[ _k196 ];
		player [[ level.spawnplayer ]]();
		player freeze_player_controls( 1 );
		_k196 = getNextArrayKey( _a196, _k196 );
	}
}

zombie_goto_round( target_round )
{
	level notify( "restart_round" );
	if ( target_round < 1 )
	{
		target_round = 1;
	}
	level.zombie_total = 0;
	maps/mp/zombies/_zm::ai_calculate_health( target_round );
	zombies = get_round_enemy_array();
	while ( isDefined( zombies ) )
	{
		i = 0;
		while ( i < zombies.size )
		{
			zombies[ i ] dodamage( zombies[ i ].health + 666, zombies[ i ].origin );
			i++;
		}
	}
	respawn_players();
	wait 1;
}

wait_for_team_death_and_round_end()
{
	level endon( "game_module_ended" );
	level endon( "end_game" );
	checking_for_round_end = 0;
	level.isresetting_grief = 0;
	while ( 1 )
	{
		cdc_alive = 0;
		cia_alive = 0;
		players = get_players();
		_a244 = players;
		_k244 = getFirstArrayKey( _a244 );
		while ( isDefined( _k244 ) )
		{
			player = _a244[ _k244 ];
			if ( !isDefined( player._encounters_team ) )
			{
			}
			else if ( player._encounters_team == "A" )
			{
				if ( is_player_valid( player ) )
				{
					cia_alive++;
				}
			}
			else
			{
				if ( is_player_valid( player ) )
				{
					cdc_alive++;
				}
			}
			_k244 = getNextArrayKey( _a244, _k244 );
		}
		if ( cia_alive == 0 && cdc_alive == 0 && !level.isresetting_grief && isDefined( level.host_ended_game ) && !level.host_ended_game )
		{
			wait 0,5;
			if ( isDefined( level._grief_reset_message ) )
			{
				level thread [[ level._grief_reset_message ]]();
			}
			level.isresetting_grief = 1;
			level notify( "end_round_think" );
			level.zombie_vars[ "spectators_respawn" ] = 1;
			level notify( "keep_griefing" );
			checking_for_round_end = 0;
			zombie_goto_round( level.round_number );
			level thread reset_grief();
			level thread maps/mp/zombies/_zm::round_think( 1 );
		}
		else
		{
			if ( !checking_for_round_end )
			{
				if ( cia_alive == 0 )
				{
					level thread check_for_round_end( "B" );
					checking_for_round_end = 1;
					break;
				}
				else
				{
					if ( cdc_alive == 0 )
					{
						level thread check_for_round_end( "A" );
						checking_for_round_end = 1;
					}
				}
			}
		}
		if ( cia_alive > 0 && cdc_alive > 0 )
		{
			level notify( "stop_round_end_check" );
			checking_for_round_end = 0;
		}
		wait 0,05;
	}
}

reset_grief()
{
	wait 1;
	level.isresetting_grief = 0;
}

check_for_round_end( winner )
{
	level endon( "keep_griefing" );
	level endon( "stop_round_end_check" );
	level waittill( "end_of_round" );
	level.gamemodulewinningteam = winner;
	level.zombie_vars[ "spectators_respawn" ] = 0;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] freezecontrols( 1 );
		if ( players[ i ]._encounters_team == winner )
		{
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
			i++;
			continue;
		}
		else
		{
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
		}
		i++;
	}
	level notify( "game_module_ended" );
	level._game_module_game_end_check = undefined;
	maps/mp/gametypes_zm/_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
	level notify( "end_game" );
}

wait_for_team_death()
{
	wait 15;
	winner = undefined;
	while ( !isDefined( winner ) )
	{
		cdc_alive = 0;
		cia_alive = 0;
		players = get_players();
		_a418 = players;
		_k418 = getFirstArrayKey( _a418 );
		while ( isDefined( _k418 ) )
		{
			player = _a418[ _k418 ];
			if ( player._encounters_team == "A" )
			{
				if ( is_player_valid( player ) || isDefined( level.force_solo_quick_revive ) && level.force_solo_quick_revive && isDefined( player.lives ) && player.lives > 0 )
				{
					cia_alive++;
				}
			}
			else
			{
				if ( is_player_valid( player ) || isDefined( level.force_solo_quick_revive ) && level.force_solo_quick_revive && isDefined( player.lives ) && player.lives > 0 )
				{
					cdc_alive++;
				}
			}
			_k418 = getNextArrayKey( _a418, _k418 );
		}
		if ( cia_alive == 0 )
		{
			winner = "B";
		}
		else
		{
			if ( cdc_alive == 0 )
			{
				winner = "A";
			}
		}
		wait 0,05;
	}
	level notify( "game_module_ended" );
}

make_supersprinter()
{
	self set_zombie_run_cycle( "super_sprint" );
}

game_module_custom_intermission( intermission_struct )
{
	self closemenu();
	self closeingamemenu();
	level endon( "stop_intermission" );
	self endon( "disconnect" );
	self endon( "death" );
	self notify( "_zombie_game_over" );
	self.score = self.score_total;
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	s_point = getstruct( intermission_struct, "targetname" );
	if ( !isDefined( level.intermission_cam_model ) )
	{
		level.intermission_cam_model = spawn( "script_model", s_point.origin );
		level.intermission_cam_model.angles = s_point.angles;
		level.intermission_cam_model setmodel( "tag_origin" );
	}
	self.game_over_bg = newclienthudelem( self );
	self.game_over_bg.horzalign = "fullscreen";
	self.game_over_bg.vertalign = "fullscreen";
	self.game_over_bg setshader( "black", 640, 480 );
	self.game_over_bg.alpha = 1;
	self spawn( level.intermission_cam_model.origin, level.intermission_cam_model.angles );
	self camerasetposition( level.intermission_cam_model );
	self camerasetlookat();
	self cameraactivate( 1 );
	self linkto( level.intermission_cam_model );
	level.intermission_cam_model moveto( getstruct( s_point.target, "targetname" ).origin, 12 );
	if ( isDefined( level.intermission_cam_model.angles ) )
	{
		level.intermission_cam_model rotateto( getstruct( s_point.target, "targetname" ).angles, 12 );
	}
	self.game_over_bg fadeovertime( 2 );
	self.game_over_bg.alpha = 0;
	wait 2;
	self.game_over_bg thread maps/mp/zombies/_zm::fade_up_over_time( 1 );
}

create_fireworks( launch_spots, min_wait, max_wait, randomize )
{
	level endon( "stop_fireworks" );
	while ( 1 )
	{
		if ( isDefined( randomize ) && randomize )
		{
			launch_spots = array_randomize( launch_spots );
		}
		_a516 = launch_spots;
		_k516 = getFirstArrayKey( _a516 );
		while ( isDefined( _k516 ) )
		{
			spot = _a516[ _k516 ];
			level thread fireworks_launch( spot );
			wait randomfloatrange( min_wait, max_wait );
			_k516 = getNextArrayKey( _a516, _k516 );
		}
		wait randomfloatrange( min_wait, max_wait );
	}
}

fireworks_launch( launch_spot )
{
	firework = spawn( "script_model", launch_spot.origin + ( randomintrange( -60, 60 ), randomintrange( -60, 60 ), 0 ) );
	firework setmodel( "tag_origin" );
	wait_network_frame();
	playfxontag( level._effect[ "fw_trail_cheap" ], firework, "tag_origin" );
	firework playloopsound( "zmb_souls_loop", 0,75 );
	dest = launch_spot;
	while ( isDefined( dest ) && isDefined( dest.target ) )
	{
		random_offset = ( randomintrange( -60, 60 ), randomintrange( -60, 60 ), 0 );
		new_dests = getstructarray( dest.target, "targetname" );
		new_dest = random( new_dests );
		dest = new_dest;
		dist = distance( new_dest.origin + random_offset, firework.origin );
		time = dist / 700;
		firework moveto( new_dest.origin + random_offset, time );
		firework waittill( "movedone" );
	}
	firework playsound( "zmb_souls_end" );
	playfx( level._effect[ "fw_pre_burst" ], firework.origin );
	firework delete();
}
