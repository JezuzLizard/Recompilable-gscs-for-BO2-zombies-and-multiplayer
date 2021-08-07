#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/gametypes_zm/_globallogic_ui;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/gametypes_zm/_globallogic_defaults;
#include maps/mp/gametypes_zm/_gameobjects;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_callbacksetup;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;

main()
{
	maps/mp/gametypes_zm/_globallogic::init();
	maps/mp/gametypes_zm/_callbacksetup::setupcallbacks();
	globallogic_setupdefault_zombiecallbacks();
	menu_init();
	registerroundlimit( 1, 1 );
	registertimelimit( 0, 0 );
	registerscorelimit( 0, 0 );
	registerroundwinlimit( 0, 0 );
	registernumlives( 1, 1 );
	maps/mp/gametypes_zm/_weapons::registergrenadelauncherduddvar( level.gametype, 10, 0, 1440 );
	maps/mp/gametypes_zm/_weapons::registerthrowngrenadeduddvar( level.gametype, 0, 0, 1440 );
	maps/mp/gametypes_zm/_weapons::registerkillstreakdelay( level.gametype, 0, 0, 1440 );
	maps/mp/gametypes_zm/_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
	level.takelivesondeath = 1;
	level.teambased = 1;
	level.disableprematchmessages = 1;
	level.disablemomentum = 1;
	level.overrideteamscore = 0;
	level.overrideplayerscore = 0;
	level.displayhalftimetext = 0;
	level.displayroundendtext = 0;
	level.allowannouncer = 0;
	level.endgameonscorelimit = 0;
	level.endgameontimelimit = 0;
	level.resetplayerscoreeveryround = 1;
	level.doprematch = 0;
	level.nopersistence = 1;
	level.scoreroundbased = 0;
	level.forceautoassign = 1;
	level.dontshowendreason = 1;
	level.forceallallies = 0;
	level.allow_teamchange = 0;
	setdvar( "scr_disable_team_selection", 1 );
	makedvarserverinfo( "scr_disable_team_selection", 1 );
	setmatchflag( "hud_zombie", 1 );
	setdvar( "scr_disable_weapondrop", 1 );
	setdvar( "scr_xpscale", 0 );
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::blank;
	level.onspawnplayerunified = ::onspawnplayerunified;
	level.onroundendgame = ::onroundendgame;
	level.mayspawn = ::mayspawn;
	set_game_var( "ZM_roundLimit", 1 );
	set_game_var( "ZM_scoreLimit", 1 );
	set_game_var( "_team1_num", 0 );
	set_game_var( "_team2_num", 0 );
	map_name = level.script;
	mode = getDvar( "ui_gametype" );
	if ( isDefined( mode ) && mode == "" && isDefined( level.default_game_mode ) )
	{
		mode = level.default_game_mode;
	}
	set_gamemode_var_once( "mode", mode );
	set_game_var_once( "side_selection", 1 );
	location = getDvar( "ui_zm_mapstartlocation" );
	if ( location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	set_gamemode_var_once( "location", location );
	set_gamemode_var_once( "randomize_mode", getDvarInt( #"5D1D04D4" ) );
	set_gamemode_var_once( "randomize_location", getDvarInt( #"D446AE4D" ) );
	set_gamemode_var_once( "team_1_score", 0 );
	set_gamemode_var_once( "team_2_score", 0 );
	set_gamemode_var_once( "current_round", 0 );
	set_gamemode_var_once( "rules_read", 0 );
	set_game_var_once( "switchedsides", 0 );
	gametype = getDvar( "ui_gametype" );
	game[ "dialog" ][ "gametype" ] = gametype + "_start";
	game[ "dialog" ][ "gametype_hardcore" ] = gametype + "_start";
	game[ "dialog" ][ "offense_obj" ] = "generic_boost";
	game[ "dialog" ][ "defense_obj" ] = "generic_boost";
	set_gamemode_var( "pre_init_zombie_spawn_func", undefined );
	set_gamemode_var( "post_init_zombie_spawn_func", undefined );
	set_gamemode_var( "match_end_notify", undefined );
	set_gamemode_var( "match_end_func", undefined );
	setscoreboardcolumns( "score", "kills", "downs", "revives", "headshots" );
	onplayerconnect_callback( ::onplayerconnect_check_for_hotjoin );
}

game_objects_allowed( mode, location )
{
	allowed[ 0 ] = mode;
	entities = getentarray();
	_a153 = entities;
	_k153 = getFirstArrayKey( _a153 );
	while ( isDefined( _k153 ) )
	{
		entity = _a153[ _k153 ];
		if ( isDefined( entity.script_gameobjectname ) )
		{
			isallowed = maps/mp/gametypes_zm/_gameobjects::entity_is_allowed( entity, allowed );
			if ( isDefined( entity.script_noteworthy ) )
			{
				isvalidlocation = entity.script_noteworthy == location;
			}
			if ( !isallowed || !isvalidlocation && !is_classic() )
			{
				if ( isDefined( entity.spawnflags ) && entity.spawnflags == 1 )
				{
					if ( isDefined( entity.classname ) && entity.classname != "trigger_multiple" )
					{
						entity connectpaths();
					}
				}
				entity delete();
				break;
			}
			else
			{
				if ( isDefined( entity.script_vector ) )
				{
					entity moveto( entity.origin + entity.script_vector, 0,05 );
					entity waittill( "movedone" );
					if ( isDefined( entity.spawnflags ) && entity.spawnflags == 1 )
					{
						entity disconnectpaths();
					}
					break;
				}
				else
				{
					if ( isDefined( entity.spawnflags ) && entity.spawnflags == 1 )
					{
						if ( isDefined( entity.classname ) && entity.classname != "trigger_multiple" )
						{
							entity connectpaths();
						}
					}
				}
			}
		}
		_k153 = getNextArrayKey( _a153, _k153 );
	}
}

post_init_gametype()
{
	if ( isDefined( level.gamemode_map_postinit ) )
	{
		if ( isDefined( level.gamemode_map_postinit[ level.scr_zm_ui_gametype ] ) )
		{
			[[ level.gamemode_map_postinit[ level.scr_zm_ui_gametype ] ]]();
		}
	}
}

post_gametype_main( mode )
{
	set_game_var( "ZM_roundWinLimit", get_game_var( "ZM_roundLimit" ) * 0,5 );
	level.roundlimit = get_game_var( "ZM_roundLimit" );
	if ( isDefined( level.gamemode_map_preinit ) )
	{
		if ( isDefined( level.gamemode_map_preinit[ mode ] ) )
		{
			[[ level.gamemode_map_preinit[ mode ] ]]();
		}
	}
}

globallogic_setupdefault_zombiecallbacks()
{
	level.spawnplayer = ::maps/mp/gametypes_zm/_globallogic_spawn::spawnplayer;
	level.spawnplayerprediction = ::maps/mp/gametypes_zm/_globallogic_spawn::spawnplayerprediction;
	level.spawnclient = ::maps/mp/gametypes_zm/_globallogic_spawn::spawnclient;
	level.spawnspectator = ::maps/mp/gametypes_zm/_globallogic_spawn::spawnspectator;
	level.spawnintermission = ::maps/mp/gametypes_zm/_globallogic_spawn::spawnintermission;
	level.onplayerscore = ::blank;
	level.onteamscore = ::blank;
	level.wavespawntimer = ::wavespawntimer;
	level.onspawnplayer = ::blank;
	level.onspawnplayerunified = ::blank;
	level.onspawnspectator = ::onspawnspectator;
	level.onspawnintermission = ::onspawnintermission;
	level.onrespawndelay = ::blank;
	level.onforfeit = ::blank;
	level.ontimelimit = ::blank;
	level.onscorelimit = ::blank;
	level.ondeadevent = ::ondeadevent;
	level.ononeleftevent = ::blank;
	level.giveteamscore = ::blank;
	level.giveplayerscore = ::blank;
	level.gettimelimit = ::maps/mp/gametypes_zm/_globallogic_defaults::default_gettimelimit;
	level.getteamkillpenalty = ::blank;
	level.getteamkillscore = ::blank;
	level.iskillboosting = ::blank;
	level._setteamscore = ::maps/mp/gametypes_zm/_globallogic_score::_setteamscore;
	level._setplayerscore = ::blank;
	level._getteamscore = ::blank;
	level._getplayerscore = ::blank;
	level.onprecachegametype = ::blank;
	level.onstartgametype = ::blank;
	level.onplayerconnect = ::blank;
	level.onplayerdisconnect = ::onplayerdisconnect;
	level.onplayerdamage = ::blank;
	level.onplayerkilled = ::blank;
	level.onplayerkilledextraunthreadedcbs = [];
	level.onteamoutcomenotify = ::maps/mp/gametypes_zm/_hud_message::teamoutcomenotifyzombie;
	level.onoutcomenotify = ::blank;
	level.onteamwageroutcomenotify = ::blank;
	level.onwageroutcomenotify = ::blank;
	level.onendgame = ::onendgame;
	level.onroundendgame = ::blank;
	level.onmedalawarded = ::blank;
	level.autoassign = ::maps/mp/gametypes_zm/_globallogic_ui::menuautoassign;
	level.spectator = ::maps/mp/gametypes_zm/_globallogic_ui::menuspectator;
	level.class = ::maps/mp/gametypes_zm/_globallogic_ui::menuclass;
	level.allies = ::menuallieszombies;
	level.teammenu = ::maps/mp/gametypes_zm/_globallogic_ui::menuteam;
	level.callbackactorkilled = ::blank;
	level.callbackvehicledamage = ::blank;
}

setup_standard_objects( location )
{
	structs = getstructarray( "game_mode_object" );
	_a290 = structs;
	_k290 = getFirstArrayKey( _a290 );
	while ( isDefined( _k290 ) )
	{
		struct = _a290[ _k290 ];
		if ( isDefined( struct.script_noteworthy ) && struct.script_noteworthy != location )
		{
		}
		else
		{
			if ( isDefined( struct.script_string ) )
			{
				keep = 0;
				tokens = strtok( struct.script_string, " " );
				_a300 = tokens;
				_k300 = getFirstArrayKey( _a300 );
				while ( isDefined( _k300 ) )
				{
					token = _a300[ _k300 ];
					if ( token == level.scr_zm_ui_gametype && token != "zstandard" )
					{
						keep = 1;
					}
					else
					{
						if ( token == "zstandard" )
						{
							keep = 1;
						}
					}
					_k300 = getNextArrayKey( _a300, _k300 );
				}
				if ( !keep )
				{
					break;
				}
			}
			else
			{
				barricade = spawn( "script_model", struct.origin );
				barricade.angles = struct.angles;
				barricade setmodel( struct.script_parameters );
			}
		}
		_k290 = getNextArrayKey( _a290, _k290 );
	}
	objects = getentarray();
	_a322 = objects;
	_k322 = getFirstArrayKey( _a322 );
	while ( isDefined( _k322 ) )
	{
		object = _a322[ _k322 ];
		if ( !object is_survival_object() )
		{
		}
		else
		{
			if ( isDefined( object.spawnflags ) && object.spawnflags == 1 && object.classname != "trigger_multiple" )
			{
				object connectpaths();
			}
			object delete();
		}
		_k322 = getNextArrayKey( _a322, _k322 );
	}
	if ( isDefined( level._classic_setup_func ) )
	{
		[[ level._classic_setup_func ]]();
	}
}

is_survival_object()
{
	if ( !isDefined( self.script_parameters ) )
	{
		return 0;
	}
	tokens = strtok( self.script_parameters, " " );
	remove = 0;
	_a352 = tokens;
	_k352 = getFirstArrayKey( _a352 );
	while ( isDefined( _k352 ) )
	{
		token = _a352[ _k352 ];
		if ( token == "survival_remove" )
		{
			remove = 1;
		}
		_k352 = getNextArrayKey( _a352, _k352 );
	}
	return remove;
}

game_module_player_damage_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	self.last_damage_from_zombie_or_player = 0;
	if ( isDefined( eattacker ) )
	{
		if ( isplayer( eattacker ) && eattacker == self )
		{
			return;
		}
		if ( isDefined( eattacker.is_zombie ) || eattacker.is_zombie && isplayer( eattacker ) )
		{
			self.last_damage_from_zombie_or_player = 1;
		}
	}
	if ( isDefined( self._being_shellshocked ) || self._being_shellshocked && self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return;
	}
	if ( isplayer( eattacker ) && isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team )
	{
		if ( isDefined( self.hasriotshield ) && self.hasriotshield && isDefined( vdir ) )
		{
			if ( isDefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped )
			{
				if ( self maps/mp/zombies/_zm::player_shield_facing_attacker( vdir, 0,2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					return;
				}
			}
			else
			{
				if ( !isDefined( self.riotshieldentity ) )
				{
					if ( !self maps/mp/zombies/_zm::player_shield_facing_attacker( vdir, -0,2 ) && isDefined( self.player_shield_apply_damage ) )
					{
						return;
					}
				}
			}
		}
		if ( isDefined( level._game_module_player_damage_grief_callback ) )
		{
			self [[ level._game_module_player_damage_grief_callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
		}
		if ( isDefined( level._effect[ "butterflies" ] ) )
		{
			if ( isDefined( sweapon ) && weapontype( sweapon ) == "grenade" )
			{
				playfx( level._effect[ "butterflies" ], self.origin + vectorScale( ( 1, 1, 1 ), 40 ) );
			}
			else
			{
				playfx( level._effect[ "butterflies" ], vpoint, vdir );
			}
		}
		self thread do_game_mode_shellshock();
		self playsound( "zmb_player_hit_ding" );
	}
}

do_game_mode_shellshock()
{
	self endon( "disconnect" );
	self._being_shellshocked = 1;
	self shellshock( "grief_stab_zm", 0,75 );
	wait 0,75;
	self._being_shellshocked = 0;
}

add_map_gamemode( mode, preinit_func, precache_func, main_func )
{
	if ( !isDefined( level.gamemode_map_location_init ) )
	{
		level.gamemode_map_location_init = [];
	}
	if ( !isDefined( level.gamemode_map_location_main ) )
	{
		level.gamemode_map_location_main = [];
	}
	if ( !isDefined( level.gamemode_map_preinit ) )
	{
		level.gamemode_map_preinit = [];
	}
	if ( !isDefined( level.gamemode_map_postinit ) )
	{
		level.gamemode_map_postinit = [];
	}
	if ( !isDefined( level.gamemode_map_precache ) )
	{
		level.gamemode_map_precache = [];
	}
	if ( !isDefined( level.gamemode_map_main ) )
	{
		level.gamemode_map_main = [];
	}
	level.gamemode_map_preinit[ mode ] = preinit_func;
	level.gamemode_map_main[ mode ] = main_func;
	level.gamemode_map_precache[ mode ] = precache_func;
	level.gamemode_map_location_precache[ mode ] = [];
	level.gamemode_map_location_main[ mode ] = [];
}

add_map_location_gamemode( mode, location, precache_func, main_func )
{
	if ( !isDefined( level.gamemode_map_location_precache[ mode ] ) )
	{
/#
		println( "*** ERROR : " + mode + " has not been added to the map using add_map_gamemode." );
#/
		return;
	}
	level.gamemode_map_location_precache[ mode ][ location ] = precache_func;
	level.gamemode_map_location_main[ mode ][ location ] = main_func;
}

rungametypeprecache( gamemode )
{
	if ( !isDefined( level.gamemode_map_location_main ) || !isDefined( level.gamemode_map_location_main[ gamemode ] ) )
	{
		return;
	}
	if ( isDefined( level.gamemode_map_precache ) )
	{
		if ( isDefined( level.gamemode_map_precache[ gamemode ] ) )
		{
			[[ level.gamemode_map_precache[ gamemode ] ]]();
		}
	}
	if ( isDefined( level.gamemode_map_location_precache ) )
	{
		if ( isDefined( level.gamemode_map_location_precache[ gamemode ] ) )
		{
			loc = getDvar( "ui_zm_mapstartlocation" );
			if ( loc == "" && isDefined( level.default_start_location ) )
			{
				loc = level.default_start_location;
			}
			if ( isDefined( level.gamemode_map_location_precache[ gamemode ][ loc ] ) )
			{
				[[ level.gamemode_map_location_precache[ gamemode ][ loc ] ]]();
			}
		}
	}
	if ( isDefined( level.precachecustomcharacters ) )
	{
		self [[ level.precachecustomcharacters ]]();
	}
}

rungametypemain( gamemode, mode_main_func, use_round_logic )
{
	if ( !isDefined( level.gamemode_map_location_main ) || !isDefined( level.gamemode_map_location_main[ gamemode ] ) )
	{
		return;
	}
	level thread game_objects_allowed( get_gamemode_var( "mode" ), get_gamemode_var( "location" ) );
	if ( isDefined( level.gamemode_map_main ) )
	{
		if ( isDefined( level.gamemode_map_main[ gamemode ] ) )
		{
			level thread [[ level.gamemode_map_main[ gamemode ] ]]();
		}
	}
	if ( isDefined( level.gamemode_map_location_main ) )
	{
		if ( isDefined( level.gamemode_map_location_main[ gamemode ] ) )
		{
			loc = getDvar( "ui_zm_mapstartlocation" );
			if ( loc == "" && isDefined( level.default_start_location ) )
			{
				loc = level.default_start_location;
			}
			if ( isDefined( level.gamemode_map_location_main[ gamemode ][ loc ] ) )
			{
				level thread [[ level.gamemode_map_location_main[ gamemode ][ loc ] ]]();
			}
		}
	}
	if ( isDefined( mode_main_func ) )
	{
		if ( isDefined( use_round_logic ) && use_round_logic )
		{
			level thread round_logic( mode_main_func );
		}
		else
		{
			level thread non_round_logic( mode_main_func );
		}
	}
	level thread game_end_func();
}

round_logic( mode_logic_func )
{
	level.skit_vox_override = 1;
	if ( isDefined( level.flag[ "start_zombie_round_logic" ] ) )
	{
		flag_wait( "start_zombie_round_logic" );
	}
	flag_wait( "start_encounters_match_logic" );
	if ( !isDefined( game[ "gamemode_match" ][ "rounds" ] ) )
	{
		game[ "gamemode_match" ][ "rounds" ] = [];
	}
	set_gamemode_var_once( "current_round", 0 );
	set_gamemode_var_once( "team_1_score", 0 );
	set_gamemode_var_once( "team_2_score", 0 );
	if ( isDefined( is_encounter() ) && is_encounter() )
	{
		[[ level._setteamscore ]]( "allies", get_gamemode_var( "team_2_score" ) );
		[[ level._setteamscore ]]( "axis", get_gamemode_var( "team_1_score" ) );
	}
	flag_set( "pregame" );
	waittillframeend;
	level.gameended = 0;
	cur_round = get_gamemode_var( "current_round" );
	set_gamemode_var( "current_round", cur_round + 1 );
	game[ "gamemode_match" ][ "rounds" ][ cur_round ] = spawnstruct();
	game[ "gamemode_match" ][ "rounds" ][ cur_round ].mode = getDvar( "ui_gametype" );
	level thread [[ mode_logic_func ]]();
	flag_wait( "start_encounters_match_logic" );
	level.gamestarttime = getTime();
	level.gamelengthtime = undefined;
	level thread createtimer();
	level notify( "clear_hud_elems" );
	level waittill( "game_module_ended", winner );
	game[ "gamemode_match" ][ "rounds" ][ cur_round ].winner = winner;
	level thread kill_all_zombies();
	level.gameendtime = getTime();
	level.gamelengthtime = level.gameendtime - level.gamestarttime;
	level.gameended = 1;
	if ( winner == "A" )
	{
		score = get_gamemode_var( "team_1_score" );
		set_gamemode_var( "team_1_score", score + 1 );
	}
	else
	{
		score = get_gamemode_var( "team_2_score" );
		set_gamemode_var( "team_2_score", score + 1 );
	}
	if ( isDefined( is_encounter() ) && is_encounter() )
	{
		[[ level._setteamscore ]]( "allies", get_gamemode_var( "team_2_score" ) );
		[[ level._setteamscore ]]( "axis", get_gamemode_var( "team_1_score" ) );
		if ( get_gamemode_var( "team_1_score" ) == get_gamemode_var( "team_2_score" ) )
		{
			level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "win" );
			level thread maps/mp/zombies/_zm_audio_announcer::announceroundwinner( "tied" );
		}
		else
		{
			level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "win", winner, "lose" );
			level thread maps/mp/zombies/_zm_audio_announcer::announceroundwinner( winner );
		}
	}
	level thread delete_corpses();
	level delay_thread( 5, ::revive_laststand_players );
	level notify( "clear_hud_elems" );
	while ( startnextzmround( winner ) )
	{
		level clientnotify( "gme" );
		while ( 1 )
		{
			wait 1;
		}
	}
	level.match_is_ending = 1;
	if ( isDefined( is_encounter() ) && is_encounter() )
	{
		matchwonteam = "";
		if ( get_gamemode_var( "team_1_score" ) > get_gamemode_var( "team_2_score" ) )
		{
			matchwonteam = "A";
		}
		else
		{
			matchwonteam = "B";
		}
		level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "win", matchwonteam, "lose" );
		level thread maps/mp/zombies/_zm_audio_announcer::announcematchwinner( matchwonteam );
		level create_final_score();
		track_encounters_win_stats( matchwonteam );
	}
	maps/mp/zombies/_zm::intermission();
	level.can_revive_game_module = undefined;
	level notify( "end_game" );
}

end_rounds_early( winner )
{
	level.forcedend = 1;
	cur_round = get_gamemode_var( "current_round" );
	set_gamemode_var( "ZM_roundLimit", cur_round );
	if ( isDefined( winner ) )
	{
		level notify( "game_module_ended" );
	}
	else
	{
		level notify( "end_game" );
	}
}

checkzmroundswitch()
{
	if ( !isDefined( level.zm_roundswitch ) || !level.zm_roundswitch )
	{
		return 0;
	}
/#
	assert( get_gamemode_var( "current_round" ) > 0 );
#/
	return 1;
	return 0;
}

create_hud_scoreboard()
{
	level endon( "end_game" );
	level thread module_hud_full_screen_overlay();
	level thread module_hud_team_1_score();
	level thread module_hud_team_2_score();
	level thread module_hud_round_num();
	respawn_spectators_and_freeze_players();
	waittill_any_or_timeout( 6, "clear_hud_elems" );
	wait 2,1;
}

respawn_spectators_and_freeze_players()
{
	players = get_players();
	_a785 = players;
	_k785 = getFirstArrayKey( _a785 );
	while ( isDefined( _k785 ) )
	{
		player = _a785[ _k785 ];
		if ( player.sessionstate == "spectator" )
		{
			if ( isDefined( player.spectate_hud ) )
			{
				player.spectate_hud destroy();
			}
			player [[ level.spawnplayer ]]();
		}
		player freeze_player_controls( 1 );
		_k785 = getNextArrayKey( _a785, _k785 );
	}
}

module_hud_team_1_score()
{
	level._encounters_score_1 = newhudelem();
	level._encounters_score_1.x = 0;
	level._encounters_score_1.y = 260;
	level._encounters_score_1.alignx = "center";
	level._encounters_score_1.horzalign = "center";
	level._encounters_score_1.vertalign = "top";
	level._encounters_score_1.font = "default";
	level._encounters_score_1.fontscale = 2,3;
	level._encounters_score_1.color = ( 1, 1, 1 );
	level._encounters_score_1.foreground = 1;
	level._encounters_score_1 settext( "Team CIA:  " + get_gamemode_var( "team_1_score" ) );
	level._encounters_score_1.alpha = 0;
	level._encounters_score_1.sort = 11;
	level._encounters_score_1 fadeovertime( 2 );
	level._encounters_score_1.alpha = 1;
	level waittill_any_or_timeout( 6, "clear_hud_elems" );
	level._encounters_score_1 fadeovertime( 2 );
	level._encounters_score_1.alpha = 0;
	wait 2,1;
	level._encounters_score_1 destroy();
}

module_hud_team_2_score()
{
	level._encounters_score_2 = newhudelem();
	level._encounters_score_2.x = 0;
	level._encounters_score_2.y = 290;
	level._encounters_score_2.alignx = "center";
	level._encounters_score_2.horzalign = "center";
	level._encounters_score_2.vertalign = "top";
	level._encounters_score_2.font = "default";
	level._encounters_score_2.fontscale = 2,3;
	level._encounters_score_2.color = ( 1, 1, 1 );
	level._encounters_score_2.foreground = 1;
	level._encounters_score_2 settext( "Team CDC:  " + get_gamemode_var( "team_2_score" ) );
	level._encounters_score_2.alpha = 0;
	level._encounters_score_2.sort = 12;
	level._encounters_score_2 fadeovertime( 2 );
	level._encounters_score_2.alpha = 1;
	level waittill_any_or_timeout( 6, "clear_hud_elems" );
	level._encounters_score_2 fadeovertime( 2 );
	level._encounters_score_2.alpha = 0;
	wait 2,1;
	level._encounters_score_2 destroy();
}

module_hud_round_num()
{
	level._encounters_round_num = newhudelem();
	level._encounters_round_num.x = 0;
	level._encounters_round_num.y = 60;
	level._encounters_round_num.alignx = "center";
	level._encounters_round_num.horzalign = "center";
	level._encounters_round_num.vertalign = "top";
	level._encounters_round_num.font = "default";
	level._encounters_round_num.fontscale = 2,3;
	level._encounters_round_num.color = ( 1, 1, 1 );
	level._encounters_round_num.foreground = 1;
	level._encounters_round_num settext( "Round:  ^5" + get_gamemode_var( "current_round" ) + " / " + get_game_var( "ZM_roundLimit" ) );
	level._encounters_round_num.alpha = 0;
	level._encounters_round_num.sort = 13;
	level._encounters_round_num fadeovertime( 2 );
	level._encounters_round_num.alpha = 1;
	level waittill_any_or_timeout( 6, "clear_hud_elems" );
	level._encounters_round_num fadeovertime( 2 );
	level._encounters_round_num.alpha = 0;
	wait 2,1;
	level._encounters_round_num destroy();
}

createtimer()
{
	flag_waitopen( "pregame" );
	elem = newhudelem();
	elem.hidewheninmenu = 1;
	elem.horzalign = "center";
	elem.vertalign = "top";
	elem.alignx = "center";
	elem.aligny = "middle";
	elem.x = 0;
	elem.y = 0;
	elem.foreground = 1;
	elem.font = "default";
	elem.fontscale = 1,5;
	elem.color = ( 1, 1, 1 );
	elem.alpha = 2;
	elem thread maps/mp/gametypes_zm/_hud::fontpulseinit();
	if ( isDefined( level.timercountdown ) && level.timercountdown )
	{
		elem settenthstimer( level.timelimit * 60 );
	}
	else
	{
		elem settenthstimerup( 0,1 );
	}
	level.game_module_timer = elem;
	level waittill( "game_module_ended" );
	elem destroy();
}

revive_laststand_players()
{
	if ( isDefined( level.match_is_ending ) && level.match_is_ending )
	{
		return;
	}
	players = get_players();
	_a917 = players;
	_k917 = getFirstArrayKey( _a917 );
	while ( isDefined( _k917 ) )
	{
		player = _a917[ _k917 ];
		if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			player thread maps/mp/zombies/_zm_laststand::auto_revive( player );
		}
		_k917 = getNextArrayKey( _a917, _k917 );
	}
}

team_icon_winner( elem )
{
	og_x = elem.x;
	og_y = elem.y;
	elem.sort = 1;
	elem scaleovertime( 0,75, 150, 150 );
	elem moveovertime( 0,75 );
	elem.horzalign = "center";
	elem.vertalign = "middle";
	elem.x = 0;
	elem.y = 0;
	elem.alpha = 0,7;
	wait 0,75;
}

delete_corpses()
{
	corpses = getcorpsearray();
	x = 0;
	while ( x < corpses.size )
	{
		corpses[ x ] delete();
		x++;
	}
}

track_encounters_win_stats( matchwonteam )
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ]._encounters_team == matchwonteam )
		{
			players[ i ] maps/mp/zombies/_zm_stats::increment_client_stat( "wins" );
			players[ i ] maps/mp/zombies/_zm_stats::add_client_stat( "losses", -1 );
			players[ i ] adddstat( "skill_rating", 1 );
			players[ i ] setdstat( "skill_variance", 1 );
			players[ i ] maps/mp/zombies/_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "wins", 1 );
			players[ i ] maps/mp/zombies/_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "losses", -1 );
		}
		else
		{
			players[ i ] setdstat( "skill_rating", 0 );
			players[ i ] setdstat( "skill_variance", 1 );
		}
		players[ i ] updatestatratio( "wlratio", "wins", "losses" );
		i++;
	}
}

module_hud_full_screen_overlay()
{
	fadetoblack = newhudelem();
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	if ( is_encounter() || getDvar( "ui_gametype" ) == "zcleansed" )
	{
		level waittill_any_or_timeout( 25, "start_fullscreen_fade_out" );
	}
	else
	{
		level waittill_any_or_timeout( 25, "start_zombie_round_logic" );
	}
	fadetoblack fadeovertime( 2 );
	fadetoblack.alpha = 0;
	wait 2,1;
	fadetoblack destroy();
}

create_final_score()
{
	level endon( "end_game" );
	level thread module_hud_team_winer_score();
	wait 2;
	level thread module_hud_full_screen_overlay();
	wait 8;
}

module_hud_team_winer_score()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] thread create_module_hud_team_winer_score();
		if ( isDefined( players[ i ]._team_hud ) && isDefined( players[ i ]._team_hud[ "team" ] ) )
		{
			players[ i ] thread team_icon_winner( players[ i ]._team_hud[ "team" ] );
		}
		if ( isDefined( level.lock_player_on_team_score ) && level.lock_player_on_team_score )
		{
			players[ i ] freezecontrols( 1 );
			players[ i ] takeallweapons();
			players[ i ] setclientuivisibilityflag( "hud_visible", 0 );
			players[ i ].sessionstate = "spectator";
			players[ i ].spectatorclient = -1;
			players[ i ].maxhealth = players[ i ].health;
			players[ i ].shellshocked = 0;
			players[ i ].inwater = 0;
			players[ i ].friendlydamage = undefined;
			players[ i ].hasspawned = 1;
			players[ i ].spawntime = getTime();
			players[ i ].afk = 0;
			players[ i ] detachall();
		}
		i++;
	}
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "match_over" );
}

create_module_hud_team_winer_score()
{
	self._team_winer_score = newclienthudelem( self );
	self._team_winer_score.x = 0;
	self._team_winer_score.y = 70;
	self._team_winer_score.alignx = "center";
	self._team_winer_score.horzalign = "center";
	self._team_winer_score.vertalign = "middle";
	self._team_winer_score.font = "default";
	self._team_winer_score.fontscale = 15;
	self._team_winer_score.color = ( 1, 1, 1 );
	self._team_winer_score.foreground = 1;
	if ( self._encounters_team == "B" && get_gamemode_var( "team_2_score" ) > get_gamemode_var( "team_1_score" ) )
	{
		self._team_winer_score settext( &"ZOMBIE_MATCH_WON" );
	}
	else
	{
		if ( self._encounters_team == "B" && get_gamemode_var( "team_2_score" ) < get_gamemode_var( "team_1_score" ) )
		{
			self._team_winer_score.color = ( 1, 1, 1 );
			self._team_winer_score settext( &"ZOMBIE_MATCH_LOST" );
		}
	}
	if ( self._encounters_team == "A" && get_gamemode_var( "team_1_score" ) > get_gamemode_var( "team_2_score" ) )
	{
		self._team_winer_score settext( &"ZOMBIE_MATCH_WON" );
	}
	else
	{
		if ( self._encounters_team == "A" && get_gamemode_var( "team_1_score" ) < get_gamemode_var( "team_2_score" ) )
		{
			self._team_winer_score.color = ( 1, 1, 1 );
			self._team_winer_score settext( &"ZOMBIE_MATCH_LOST" );
		}
	}
	self._team_winer_score.alpha = 0;
	self._team_winer_score.sort = 12;
	self._team_winer_score fadeovertime( 2 );
	self._team_winer_score.alpha = 1;
	wait 10;
	self._team_winer_score fadeovertime( 2 );
	self._team_winer_score.alpha = 0;
	wait 2,1;
	self._team_winer_score destroy();
}

non_round_logic( mode_logic_func )
{
	level thread [[ mode_logic_func ]]();
}

game_end_func()
{
	if ( !isDefined( get_gamemode_var( "match_end_notify" ) ) && !isDefined( get_gamemode_var( "match_end_func" ) ) )
	{
		return;
	}
	level waittill( get_gamemode_var( "match_end_notify" ), winning_team );
	level thread [[ get_gamemode_var( "match_end_func" ) ]]( winning_team );
}

setup_classic_gametype()
{
	ents = getentarray();
	_a1111 = ents;
	_k1111 = getFirstArrayKey( _a1111 );
	while ( isDefined( _k1111 ) )
	{
		ent = _a1111[ _k1111 ];
		if ( isDefined( ent.script_parameters ) )
		{
			parameters = strtok( ent.script_parameters, " " );
			should_remove = 0;
			_a1117 = parameters;
			_k1117 = getFirstArrayKey( _a1117 );
			while ( isDefined( _k1117 ) )
			{
				parm = _a1117[ _k1117 ];
				if ( parm == "survival_remove" )
				{
					should_remove = 1;
				}
				_k1117 = getNextArrayKey( _a1117, _k1117 );
			}
			if ( should_remove )
			{
				ent delete();
			}
		}
		_k1111 = getNextArrayKey( _a1111, _k1111 );
	}
	structs = getstructarray( "game_mode_object" );
	_a1147 = structs;
	_k1147 = getFirstArrayKey( _a1147 );
	while ( isDefined( _k1147 ) )
	{
		struct = _a1147[ _k1147 ];
		if ( !isDefined( struct.script_string ) )
		{
		}
		else tokens = strtok( struct.script_string, " " );
		spawn_object = 0;
		_a1155 = tokens;
		_k1155 = getFirstArrayKey( _a1155 );
		while ( isDefined( _k1155 ) )
		{
			parm = _a1155[ _k1155 ];
			if ( parm == "survival" )
			{
				spawn_object = 1;
			}
			_k1155 = getNextArrayKey( _a1155, _k1155 );
		}
		if ( !spawn_object )
		{
		}
		else
		{
			barricade = spawn( "script_model", struct.origin );
			barricade.angles = struct.angles;
			barricade setmodel( struct.script_parameters );
		}
		_k1147 = getNextArrayKey( _a1147, _k1147 );
	}
	unlink_meat_traversal_nodes();
}

zclassic_main()
{
	level thread setup_classic_gametype();
	level thread maps/mp/zombies/_zm::round_start();
}

unlink_meat_traversal_nodes()
{
	meat_town_nodes = getnodearray( "meat_town_barrier_traversals", "targetname" );
	meat_tunnel_nodes = getnodearray( "meat_tunnel_barrier_traversals", "targetname" );
	meat_farm_nodes = getnodearray( "meat_farm_barrier_traversals", "targetname" );
	nodes = arraycombine( meat_town_nodes, meat_tunnel_nodes, 1, 0 );
	traversal_nodes = arraycombine( nodes, meat_farm_nodes, 1, 0 );
	_a1193 = traversal_nodes;
	_k1193 = getFirstArrayKey( _a1193 );
	while ( isDefined( _k1193 ) )
	{
		node = _a1193[ _k1193 ];
		end_node = getnode( node.target, "targetname" );
		unlink_nodes( node, end_node );
		_k1193 = getNextArrayKey( _a1193, _k1193 );
	}
}

canplayersuicide()
{
	return self hasperk( "specialty_scavenger" );
}

onplayerdisconnect()
{
	if ( isDefined( level.game_mode_custom_onplayerdisconnect ) )
	{
		level [[ level.game_mode_custom_onplayerdisconnect ]]( self );
	}
	level thread maps/mp/zombies/_zm::check_quickrevive_for_hotjoin( 1 );
	self maps/mp/zombies/_zm_laststand::add_weighted_down();
	level maps/mp/zombies/_zm::checkforalldead( self );
}

ondeadevent( team )
{
	thread maps/mp/gametypes_zm/_globallogic::endgame( level.zombie_team, "" );
}

onspawnintermission()
{
	spawnpointname = "info_intermission";
	spawnpoints = getentarray( spawnpointname, "classname" );
	if ( spawnpoints.size < 1 )
	{
/#
		println( "NO " + spawnpointname + " SPAWNPOINTS IN MAP" );
#/
		return;
	}
	spawnpoint = spawnpoints[ randomint( spawnpoints.size ) ];
	if ( isDefined( spawnpoint ) )
	{
		self spawn( spawnpoint.origin, spawnpoint.angles );
	}
}

onspawnspectator( origin, angles )
{
}

mayspawn()
{
	if ( isDefined( level.custommayspawnlogic ) )
	{
		return self [[ level.custommayspawnlogic ]]();
	}
	if ( self.pers[ "lives" ] == 0 )
	{
		level notify( "player_eliminated" );
		self notify( "player_eliminated" );
		return 0;
	}
	return 1;
}

onstartgametype()
{
	setclientnamemode( "auto_change" );
	level.displayroundendtext = 0;
	maps/mp/gametypes_zm/_spawning::create_map_placed_influencers();
	if ( !isoneround() )
	{
		level.displayroundendtext = 1;
		if ( isscoreroundbased() )
		{
			maps/mp/gametypes_zm/_globallogic_score::resetteamscores();
		}
	}
}

displayroundend( round_winner )
{
	players = get_players();
	_a1318 = players;
	_k1318 = getFirstArrayKey( _a1318 );
	while ( isDefined( _k1318 ) )
	{
		player = _a1318[ _k1318 ];
		player thread module_hud_round_end( round_winner );
		if ( isDefined( player._team_hud ) && isDefined( player._team_hud[ "team" ] ) )
		{
			player thread team_icon_winner( player._team_hud[ "team" ] );
		}
		player delay_thread( 5, ::freeze_player_controls, 1 );
		_k1318 = getNextArrayKey( _a1318, _k1318 );
	}
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
	level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "clap" );
	level thread play_sound_2d( "zmb_air_horn" );
	wait 5;
}

module_hud_round_end( round_winner )
{
	self endon( "disconnect" );
	self._team_winner_round = newclienthudelem( self );
	self._team_winner_round.x = 0;
	self._team_winner_round.y = 50;
	self._team_winner_round.alignx = "center";
	self._team_winner_round.horzalign = "center";
	self._team_winner_round.vertalign = "middle";
	self._team_winner_round.font = "default";
	self._team_winner_round.fontscale = 15;
	self._team_winner_round.color = ( 1, 1, 1 );
	self._team_winner_round.foreground = 1;
	if ( self._encounters_team == round_winner )
	{
		self._team_winner_round.color = ( 1, 1, 1 );
		self._team_winner_round settext( "YOU WIN" );
	}
	else
	{
		self._team_winner_round.color = ( 1, 1, 1 );
		self._team_winner_round settext( "YOU LOSE" );
	}
	self._team_winner_round.alpha = 0;
	self._team_winner_round.sort = 12;
	self._team_winner_round fadeovertime( 1 );
	self._team_winner_round.alpha = 1;
	wait 4;
	self._team_winner_round fadeovertime( 1 );
	self._team_winner_round.alpha = 0;
	wait 1,1;
	self._team_winner_round destroy();
}

displayroundswitch()
{
	level._round_changing_sides = newhudelem();
	level._round_changing_sides.x = 0;
	level._round_changing_sides.y = 60;
	level._round_changing_sides.alignx = "center";
	level._round_changing_sides.horzalign = "center";
	level._round_changing_sides.vertalign = "middle";
	level._round_changing_sides.font = "default";
	level._round_changing_sides.fontscale = 2,3;
	level._round_changing_sides.color = ( 1, 1, 1 );
	level._round_changing_sides.foreground = 1;
	level._round_changing_sides.sort = 12;
	fadetoblack = newhudelem();
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "side_switch" );
	level._round_changing_sides settext( "CHANGING SIDES" );
	level._round_changing_sides fadeovertime( 1 );
	level._round_changing_sides.alpha = 1;
	wait 2;
	fadetoblack fadeovertime( 1 );
	level._round_changing_sides fadeovertime( 1 );
	level._round_changing_sides.alpha = 0;
	fadetoblack.alpha = 0;
	wait 1,1;
	level._round_changing_sides destroy();
	fadetoblack destroy();
}

module_hud_create_team_name()
{
	if ( !is_encounter() )
	{
		return;
	}
	if ( !isDefined( self._team_hud ) )
	{
		self._team_hud = [];
	}
	if ( isDefined( self._team_hud[ "team" ] ) )
	{
		self._team_hud[ "team" ] destroy();
	}
	elem = newclienthudelem( self );
	elem.hidewheninmenu = 1;
	elem.alignx = "center";
	elem.aligny = "middle";
	elem.horzalign = "center";
	elem.vertalign = "middle";
	elem.x = 0;
	elem.y = 0;
	if ( isDefined( level.game_module_team_name_override_og_x ) )
	{
		elem.og_x = level.game_module_team_name_override_og_x;
	}
	else
	{
		elem.og_x = 85;
	}
	elem.og_y = -40;
	elem.foreground = 1;
	elem.font = "default";
	elem.color = ( 1, 1, 1 );
	elem.sort = 1;
	elem.alpha = 0,7;
	elem setshader( game[ "icons" ][ self.team ], 150, 150 );
	self._team_hud[ "team" ] = elem;
}

startnextzmround( winner )
{
	if ( !isonezmround() )
	{
		if ( !waslastzmround() )
		{
			displayroundend( winner );
			create_hud_scoreboard();
			if ( checkzmroundswitch() )
			{
				displayroundswitch();
			}
			setmatchtalkflag( "DeadChatWithDead", level.voip.deadchatwithdead );
			setmatchtalkflag( "DeadChatWithTeam", level.voip.deadchatwithteam );
			setmatchtalkflag( "DeadHearTeamLiving", level.voip.deadhearteamliving );
			setmatchtalkflag( "DeadHearAllLiving", level.voip.deadhearallliving );
			setmatchtalkflag( "EveryoneHearsEveryone", level.voip.everyonehearseveryone );
			setmatchtalkflag( "DeadHearKiller", level.voip.deadhearkiller );
			setmatchtalkflag( "KillersHearVictim", level.voip.killershearvictim );
			game[ "state" ] = "playing";
			level.allowbattlechatter = getgametypesetting( "allowBattleChatter" );
			if ( isDefined( level.zm_switchsides_on_roundswitch ) && level.zm_switchsides_on_roundswitch )
			{
				set_game_var( "switchedsides", !get_game_var( "switchedsides" ) );
			}
			map_restart( 1 );
			return 1;
		}
	}
	return 0;
}

start_round()
{
	flag_clear( "start_encounters_match_logic" );
	if ( !isDefined( level._module_round_hud ) )
	{
		level._module_round_hud = newhudelem();
		level._module_round_hud.x = 0;
		level._module_round_hud.y = 70;
		level._module_round_hud.alignx = "center";
		level._module_round_hud.horzalign = "center";
		level._module_round_hud.vertalign = "middle";
		level._module_round_hud.font = "default";
		level._module_round_hud.fontscale = 2,3;
		level._module_round_hud.color = ( 1, 1, 1 );
		level._module_round_hud.foreground = 1;
		level._module_round_hud.sort = 0;
	}
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] freeze_player_controls( 1 );
		i++;
	}
	level._module_round_hud.alpha = 1;
	label = &"Next Round Starting In  ^2";
	level._module_round_hud.label = label;
	level._module_round_hud settimer( 3 );
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "countdown" );
	level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "clap" );
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	level notify( "start_fullscreen_fade_out" );
	wait 2;
	level._module_round_hud fadeovertime( 1 );
	level._module_round_hud.alpha = 0;
	wait 1;
	level thread play_sound_2d( "zmb_air_horn" );
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] freeze_player_controls( 0 );
		players[ i ] sprintuprequired();
		i++;
	}
	flag_set( "start_encounters_match_logic" );
	flag_clear( "pregame" );
	level._module_round_hud destroy();
}

isonezmround()
{
	if ( get_game_var( "ZM_roundLimit" ) == 1 )
	{
		return 1;
	}
	return 0;
}

waslastzmround()
{
	if ( isDefined( level.forcedend ) && level.forcedend )
	{
		return 1;
	}
	if ( !hitzmroundlimit() || hitzmscorelimit() && hitzmroundwinlimit() )
	{
		return 1;
	}
	return 0;
}

hitzmroundlimit()
{
	if ( get_game_var( "ZM_roundLimit" ) <= 0 )
	{
		return 0;
	}
	return getzmroundsplayed() >= get_game_var( "ZM_roundLimit" );
}

hitzmroundwinlimit()
{
	if ( !isDefined( get_game_var( "ZM_roundWinLimit" ) ) || get_game_var( "ZM_roundWinLimit" ) <= 0 )
	{
		return 0;
	}
	if ( get_gamemode_var( "team_1_score" ) >= get_game_var( "ZM_roundWinLimit" ) || get_gamemode_var( "team_2_score" ) >= get_game_var( "ZM_roundWinLimit" ) )
	{
		return 1;
	}
	if ( get_gamemode_var( "team_1_score" ) >= get_game_var( "ZM_roundWinLimit" ) || get_gamemode_var( "team_2_score" ) >= get_game_var( "ZM_roundWinLimit" ) )
	{
		if ( get_gamemode_var( "team_1_score" ) != get_gamemode_var( "team_2_score" ) )
		{
			return 1;
		}
	}
	return 0;
}

hitzmscorelimit()
{
	if ( get_game_var( "ZM_scoreLimit" ) <= 0 )
	{
		return 0;
	}
	if ( is_encounter() )
	{
		if ( get_gamemode_var( "team_1_score" ) >= get_game_var( "ZM_scoreLimit" ) || get_gamemode_var( "team_2_score" ) >= get_game_var( "ZM_scoreLimit" ) )
		{
			return 1;
		}
	}
	return 0;
}

getzmroundsplayed()
{
	return get_gamemode_var( "current_round" );
}

onspawnplayerunified()
{
	onspawnplayer( 0 );
}

onspawnplayer( predictedspawn )
{
	if ( !isDefined( predictedspawn ) )
	{
		predictedspawn = 0;
	}
	pixbeginevent( "ZSURVIVAL:onSpawnPlayer" );
	self.usingobj = undefined;
	self.is_zombie = 0;
	if ( isDefined( level.custom_spawnplayer ) && isDefined( self.player_initialized ) && self.player_initialized )
	{
		self [[ level.custom_spawnplayer ]]();
		return;
	}
	if ( isDefined( level.customspawnlogic ) )
	{
/#
		println( "ZM >> USE CUSTOM SPAWNING" );
#/
		self [[ level.customspawnlogic ]]( predictedspawn );
		if ( predictedspawn )
		{
			return;
		}
	}
	else /#
	println( "ZM >> USE STANDARD SPAWNING" );
#/
	if ( flag( "begin_spawning" ) )
	{
		spawnpoint = maps/mp/zombies/_zm::check_for_valid_spawn_near_team( self, 1 );
/#
		if ( !isDefined( spawnpoint ) )
		{
			println( "ZM >> WARNING UNABLE TO FIND RESPAWN POINT NEAR TEAM - USING INITIAL SPAWN POINTS" );
#/
		}
	}
	if ( !isDefined( spawnpoint ) )
	{
		match_string = "";
		location = level.scr_zm_map_start_location;
		if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
		{
			location = level.default_start_location;
		}
		match_string = ( level.scr_zm_ui_gametype + "_" ) + location;
		spawnpoints = [];
		structs = getstructarray( "initial_spawn", "script_noteworthy" );
		while ( isDefined( structs ) )
		{
			_a1722 = structs;
			_k1722 = getFirstArrayKey( _a1722 );
			while ( isDefined( _k1722 ) )
			{
				struct = _a1722[ _k1722 ];
				while ( isDefined( struct.script_string ) )
				{
					tokens = strtok( struct.script_string, " " );
					_a1728 = tokens;
					_k1728 = getFirstArrayKey( _a1728 );
					while ( isDefined( _k1728 ) )
					{
						token = _a1728[ _k1728 ];
						if ( token == match_string )
						{
							spawnpoints[ spawnpoints.size ] = struct;
						}
						_k1728 = getNextArrayKey( _a1728, _k1728 );
					}
				}
				_k1722 = getNextArrayKey( _a1722, _k1722 );
			}
		}
		if ( !isDefined( spawnpoints ) || spawnpoints.size == 0 )
		{
			spawnpoints = getstructarray( "initial_spawn_points", "targetname" );
		}
/#
		assert( isDefined( spawnpoints ), "Could not find initial spawn points!" );
#/
		spawnpoint = maps/mp/zombies/_zm::getfreespawnpoint( spawnpoints, self );
	}
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
		return;
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "zsurvival" );
	}
	self.entity_num = self getentitynumber();
	self thread maps/mp/zombies/_zm::onplayerspawned();
	self thread maps/mp/zombies/_zm::player_revive_monitor();
	self freezecontrols( 1 );
	self.spectator_respawn = spawnpoint;
	self.score = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "score" );
	self.pers[ "participation" ] = 0;
/#
	if ( getDvarInt( "zombie_cheat" ) >= 1 )
	{
		self.score = 100000;
#/
	}
	self.score_total = self.score;
	self.old_score = self.score;
	self.player_initialized = 0;
	self.zombification_time = 0;
	self.enabletext = 1;
	self thread maps/mp/zombies/_zm_blockers::rebuild_barrier_reward_reset();
	if ( isDefined( level.host_ended_game ) && !level.host_ended_game )
	{
		self freeze_player_controls( 0 );
		self enableweapons();
	}
	if ( isDefined( level.game_mode_spawn_player_logic ) )
	{
		spawn_in_spectate = [[ level.game_mode_spawn_player_logic ]]();
		if ( spawn_in_spectate )
		{
			self delay_thread( 0,05, ::maps/mp/zombies/_zm::spawnspectator );
		}
	}
	pixendevent();
}

get_player_spawns_for_gametype()
{
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = ( level.scr_zm_ui_gametype + "_" ) + location;
	player_spawns = [];
	structs = getstructarray( "player_respawn_point", "targetname" );
	_a1834 = structs;
	_k1834 = getFirstArrayKey( _a1834 );
	while ( isDefined( _k1834 ) )
	{
		struct = _a1834[ _k1834 ];
		if ( isDefined( struct.script_string ) )
		{
			tokens = strtok( struct.script_string, " " );
			_a1839 = tokens;
			_k1839 = getFirstArrayKey( _a1839 );
			while ( isDefined( _k1839 ) )
			{
				token = _a1839[ _k1839 ];
				if ( token == match_string )
				{
					player_spawns[ player_spawns.size ] = struct;
				}
				_k1839 = getNextArrayKey( _a1839, _k1839 );
			}
		}
		else player_spawns[ player_spawns.size ] = struct;
		_k1834 = getNextArrayKey( _a1834, _k1834 );
	}
	return player_spawns;
}

onendgame( winningteam )
{
}

onroundendgame( roundwinner )
{
	if ( game[ "roundswon" ][ "allies" ] == game[ "roundswon" ][ "axis" ] )
	{
		winner = "tie";
	}
	else if ( game[ "roundswon" ][ "axis" ] > game[ "roundswon" ][ "allies" ] )
	{
		winner = "axis";
	}
	else
	{
		winner = "allies";
	}
	return winner;
}

menu_init()
{
	game[ "menu_team" ] = "team_marinesopfor";
	game[ "menu_changeclass_allies" ] = "changeclass";
	game[ "menu_initteam_allies" ] = "initteam_marines";
	game[ "menu_changeclass_axis" ] = "changeclass";
	game[ "menu_initteam_axis" ] = "initteam_opfor";
	game[ "menu_class" ] = "class";
	game[ "menu_changeclass" ] = "changeclass";
	game[ "menu_changeclass_offline" ] = "changeclass";
	game[ "menu_wager_side_bet" ] = "sidebet";
	game[ "menu_wager_side_bet_player" ] = "sidebet_player";
	game[ "menu_changeclass_wager" ] = "changeclass_wager";
	game[ "menu_changeclass_custom" ] = "changeclass_custom";
	game[ "menu_changeclass_barebones" ] = "changeclass_barebones";
	game[ "menu_controls" ] = "ingame_controls";
	game[ "menu_options" ] = "ingame_options";
	game[ "menu_leavegame" ] = "popup_leavegame";
	game[ "menu_restartgamepopup" ] = "restartgamepopup";
	precachemenu( game[ "menu_controls" ] );
	precachemenu( game[ "menu_options" ] );
	precachemenu( game[ "menu_leavegame" ] );
	precachemenu( game[ "menu_restartgamepopup" ] );
	precachemenu( "scoreboard" );
	precachemenu( game[ "menu_team" ] );
	precachemenu( game[ "menu_changeclass_allies" ] );
	precachemenu( game[ "menu_initteam_allies" ] );
	precachemenu( game[ "menu_changeclass_axis" ] );
	precachemenu( game[ "menu_class" ] );
	precachemenu( game[ "menu_changeclass" ] );
	precachemenu( game[ "menu_initteam_axis" ] );
	precachemenu( game[ "menu_changeclass_offline" ] );
	precachemenu( game[ "menu_changeclass_wager" ] );
	precachemenu( game[ "menu_changeclass_custom" ] );
	precachemenu( game[ "menu_changeclass_barebones" ] );
	precachemenu( game[ "menu_wager_side_bet" ] );
	precachemenu( game[ "menu_wager_side_bet_player" ] );
	precachestring( &"MP_HOST_ENDED_GAME" );
	precachestring( &"MP_HOST_ENDGAME_RESPONSE" );
	level thread menu_onplayerconnect();
}

menu_onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread menu_onmenuresponse();
	}
}

menu_onmenuresponse()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "menuresponse", menu, response );
		if ( response == "back" )
		{
			self closemenu();
			self closeingamemenu();
			if ( level.console )
			{
				if ( game[ "menu_changeclass" ] != menu && game[ "menu_changeclass_offline" ] != menu || menu == game[ "menu_team" ] && menu == game[ "menu_controls" ] )
				{
					if ( self.pers[ "team" ] == "allies" )
					{
						self openmenu( game[ "menu_class" ] );
					}
					if ( self.pers[ "team" ] == "axis" )
					{
						self openmenu( game[ "menu_class" ] );
					}
				}
			}
			continue;
		}
		else if ( response == "changeteam" && level.allow_teamchange == "1" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_team" ] );
		}
		if ( response == "changeclass_marines" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_allies" ] );
			continue;
		}
		else if ( response == "changeclass_opfor" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_axis" ] );
			continue;
		}
		else if ( response == "changeclass_wager" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_wager" ] );
			continue;
		}
		else if ( response == "changeclass_custom" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_custom" ] );
			continue;
		}
		else if ( response == "changeclass_barebones" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_barebones" ] );
			continue;
		}
		else if ( response == "changeclass_marines_splitscreen" )
		{
			self openmenu( "changeclass_marines_splitscreen" );
		}
		if ( response == "changeclass_opfor_splitscreen" )
		{
			self openmenu( "changeclass_opfor_splitscreen" );
		}
		if ( response == "endgame" )
		{
			if ( self issplitscreen() )
			{
				level.skipvote = 1;
				if ( isDefined( level.gameended ) && !level.gameended )
				{
					self maps/mp/zombies/_zm_laststand::add_weighted_down();
					self maps/mp/zombies/_zm_stats::increment_client_stat( "deaths" );
					self maps/mp/zombies/_zm_stats::increment_player_stat( "deaths" );
					self maps/mp/zombies/_zm_pers_upgrades::pers_upgrade_jugg_player_death_stat();
					level.host_ended_game = 1;
					maps/mp/zombies/_zm_game_module::freeze_players( 1 );
					level notify( "end_game" );
				}
			}
			continue;
		}
		else if ( response == "restart_level_zm" )
		{
			self maps/mp/zombies/_zm_laststand::add_weighted_down();
			self maps/mp/zombies/_zm_stats::increment_client_stat( "deaths" );
			self maps/mp/zombies/_zm_stats::increment_player_stat( "deaths" );
			self maps/mp/zombies/_zm_pers_upgrades::pers_upgrade_jugg_player_death_stat();
			missionfailed();
		}
		if ( response == "killserverpc" )
		{
			level thread maps/mp/gametypes_zm/_globallogic::killserverpc();
			continue;
		}
		else if ( response == "endround" )
		{
			if ( isDefined( level.gameended ) && !level.gameended )
			{
				self maps/mp/gametypes_zm/_globallogic::gamehistoryplayerquit();
				self maps/mp/zombies/_zm_laststand::add_weighted_down();
				self closemenu();
				self closeingamemenu();
				level.host_ended_game = 1;
				maps/mp/zombies/_zm_game_module::freeze_players( 1 );
				level notify( "end_game" );
			}
			else
			{
				self closemenu();
				self closeingamemenu();
				self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
			}
			continue;
		}
		else if ( menu == game[ "menu_team" ] && level.allow_teamchange == "1" )
		{
			switch( response )
			{
				case "allies":
					self [[ level.allies ]]();
					break;
				case "axis":
					self [[ level.teammenu ]]( response );
					break;
				case "autoassign":
					self [[ level.autoassign ]]( 1 );
					break;
				case "spectator":
					self [[ level.spectator ]]();
					break;
			}
			continue;
		}
		else
		{
			if ( game[ "menu_changeclass" ] != menu && game[ "menu_changeclass_offline" ] != menu && game[ "menu_changeclass_wager" ] != menu || menu == game[ "menu_changeclass_custom" ] && menu == game[ "menu_changeclass_barebones" ] )
			{
				self closemenu();
				self closeingamemenu();
				if ( level.rankedmatch && issubstr( response, "custom" ) )
				{
				}
				self.selectedclass = 1;
				self [[ level.class ]]( response );
			}
		}
	}
}

menuallieszombies()
{
	self maps/mp/gametypes_zm/_globallogic_ui::closemenus();
	if ( !level.console && level.allow_teamchange == "0" && isDefined( self.hasdonecombat ) && self.hasdonecombat )
	{
		return;
	}
	if ( self.pers[ "team" ] != "allies" )
	{
		if ( level.ingraceperiod || !isDefined( self.hasdonecombat ) && !self.hasdonecombat )
		{
			self.hasspawned = 0;
		}
		if ( self.sessionstate == "playing" )
		{
			self.switching_teams = 1;
			self.joining_team = "allies";
			self.leaving_team = self.pers[ "team" ];
			self suicide();
		}
		self.pers[ "team" ] = "allies";
		self.team = "allies";
		self.class = undefined;
		self updateobjectivetext();
		if ( level.teambased )
		{
			self.sessionteam = "allies";
		}
		else
		{
			self.sessionteam = "none";
			self.ffateam = "allies";
		}
		self setclientscriptmainmenu( game[ "menu_class" ] );
		self notify( "joined_team" );
		level notify( "joined_team" );
		self notify( "end_respawn" );
	}
}

custom_spawn_init_func()
{
	array_thread( level.zombie_spawners, ::add_spawn_function, ::maps/mp/zombies/_zm_spawner::zombie_spawn_init );
	array_thread( level.zombie_spawners, ::add_spawn_function, level._zombies_round_spawn_failsafe );
}

kill_all_zombies()
{
	ai = getaiarray( level.zombie_team );
	_a2190 = ai;
	_k2190 = getFirstArrayKey( _a2190 );
	while ( isDefined( _k2190 ) )
	{
		zombie = _a2190[ _k2190 ];
		if ( isDefined( zombie ) )
		{
			zombie dodamage( zombie.maxhealth * 2, zombie.origin, zombie, zombie, "none", "MOD_SUICIDE" );
			wait 0,05;
		}
		_k2190 = getNextArrayKey( _a2190, _k2190 );
	}
}

init()
{
	flag_init( "pregame" );
	flag_set( "pregame" );
	level thread onplayerconnect();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread onplayerspawned();
		if ( isDefined( level.game_module_onplayerconnect ) )
		{
			player [[ level.game_module_onplayerconnect ]]();
		}
	}
}

onplayerspawned()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill_either( "spawned_player", "fake_spawned_player" );
		if ( isDefined( level.match_is_ending ) && level.match_is_ending )
		{
			return;
		}
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			self thread maps/mp/zombies/_zm_laststand::auto_revive( self );
		}
		if ( isDefined( level.custom_player_fake_death_cleanup ) )
		{
			self [[ level.custom_player_fake_death_cleanup ]]();
		}
		self setstance( "stand" );
		self.zmbdialogqueue = [];
		self.zmbdialogactive = 0;
		self.zmbdialoggroups = [];
		self.zmbdialoggroup = "";
		if ( is_encounter() )
		{
			if ( self.team == "axis" )
			{
				self.characterindex = 0;
				self._encounters_team = "A";
				self._team_name = &"ZOMBIE_RACE_TEAM_1";
				break;
			}
			else
			{
				self.characterindex = 1;
				self._encounters_team = "B";
				self._team_name = &"ZOMBIE_RACE_TEAM_2";
			}
		}
		self takeallweapons();
		if ( isDefined( level.givecustomcharacters ) )
		{
			self [[ level.givecustomcharacters ]]();
		}
		self giveweapon( "knife_zm" );
		if ( isDefined( level.onplayerspawned_restore_previous_weapons ) && isDefined( level.isresetting_grief ) && level.isresetting_grief )
		{
			weapons_restored = self [[ level.onplayerspawned_restore_previous_weapons ]]();
		}
		if ( isDefined( weapons_restored ) && !weapons_restored )
		{
			self give_start_weapon( 1 );
		}
		weapons_restored = 0;
		if ( isDefined( level._team_loadout ) )
		{
			self giveweapon( level._team_loadout );
			self switchtoweapon( level._team_loadout );
		}
		if ( isDefined( level.gamemode_post_spawn_logic ) )
		{
			self [[ level.gamemode_post_spawn_logic ]]();
		}
	}
}

wait_for_players()
{
	level endon( "end_race" );
	if ( getDvarInt( "party_playerCount" ) == 1 )
	{
		flag_wait( "start_zombie_round_logic" );
		return;
	}
	while ( !flag_exists( "start_zombie_round_logic" ) )
	{
		wait 0,05;
	}
	while ( !flag( "start_zombie_round_logic" ) && isDefined( level._module_connect_hud ) )
	{
		level._module_connect_hud.alpha = 0;
		level._module_connect_hud.sort = 12;
		level._module_connect_hud fadeovertime( 1 );
		level._module_connect_hud.alpha = 1;
		wait 1,5;
		level._module_connect_hud fadeovertime( 1 );
		level._module_connect_hud.alpha = 0;
		wait 1,5;
	}
	if ( isDefined( level._module_connect_hud ) )
	{
		level._module_connect_hud destroy();
	}
}

onplayerconnect_check_for_hotjoin()
{
/#
	if ( getDvarInt( #"EA6D219A" ) > 0 )
	{
		return;
#/
	}
	map_logic_exists = level flag_exists( "start_zombie_round_logic" );
	map_logic_started = flag( "start_zombie_round_logic" );
	if ( map_logic_exists && map_logic_started )
	{
		self thread hide_gump_loading_for_hotjoiners();
	}
}

hide_gump_loading_for_hotjoiners()
{
	self endon( "disconnect" );
	self.rebuild_barrier_reward = 1;
	self.is_hotjoining = 1;
	num = self getsnapshotackindex();
	while ( num == self getsnapshotackindex() )
	{
		wait 0,25;
	}
	wait 0,5;
	self maps/mp/zombies/_zm::spawnspectator();
	self.is_hotjoining = 0;
	self.is_hotjoin = 1;
	if ( is_true( level.intermission ) || is_true( level.host_ended_game ) )
	{
		setclientsysstate( "levelNotify", "zi", self );
		self setclientthirdperson( 0 );
		self resetfov();
		self.health = 100;
		self thread [[ level.custom_intermission ]]();
	}
}
