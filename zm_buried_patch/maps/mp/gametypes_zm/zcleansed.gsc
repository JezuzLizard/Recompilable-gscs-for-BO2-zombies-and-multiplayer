#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_weap_cymbal_monkey;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/gametypes_zm/_globallogic_utils;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_turned;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/_utility;

main() //checked matches cerberus output
{
	level.using_zombie_powerups = 1;
	level._game_mode_powerup_zombie_grab = ::zcleansed_zombie_powerup_grab;
	level._zombiemode_powerup_grab = ::zcleansed_powerup_grab;
	level._powerup_timeout_custom_time = ::zcleansed_powerup_custom_time_logic;
	level._powerup_grab_check = ::powerup_can_player_grab;
	setdvar( "aim_target_player_enabled", 1 );
	maps/mp/gametypes_zm/_zm_gametype::main();
	setscoreboardcolumns( "none", "score", "kills", "downs", "headshots" );
	level.cymbal_monkey_dual_view = 1;
	level.onprecachegametype = ::onprecachegametype;
	level.onstartgametype = ::onstartgametype;
	level.custom_end_screen = ::custom_end_screen;
	level._game_module_custom_spawn_init_func = maps/mp/gametypes_zm/_zm_gametype::custom_spawn_init_func;
	level._game_module_state_update_func = maps/mp/zombies/_zm_stats::survival_classic_custom_stat_update;
	level._effect[ "human_disappears" ] = loadfx( "maps/zombie/fx_zmb_returned_spawn_puff" );
	level._effect[ "zombie_disappears" ] = loadfx( "maps/zombie/fx_zmb_returned_spawn_puff" );
	level.human_finish_bonus_points = 250;
	level.human_bonus_points = 10;
	level.zombie_penalty_points = 5;
	level.human_bonus_period = 1;
	level.zombie_penalty_period = 10;
	level.zombie_player_kill_points = 50;
	level.human_player_kill_points = 50;
	level.human_player_suicide_penalty = 0;
	level.score_rank_bonus = array( 1.5, 0.75, 0.5, 0.25 );
	if ( isDefined( level.should_use_cia ) && level.should_use_cia )
	{
		level.characterindex = 0;
	}
	else
	{
		level.characterindex = 1;
	}
	level.graceperiodfunc = ::waitforhumanselection;
	level.customalivecheck = ::cleansed_alive_check;
	level thread onplayerconnect();
	maps/mp/gametypes_zm/_zm_gametype::post_gametype_main( "zcleansed" );
	init_cleansed_powerup_fx();
}

onprecachegametype() //checked matches cerberus output
{
	level.playersuicideallowed = 1;
	level.canplayersuicide = ::canplayersuicide;
	level.suicide_weapon = "death_self_zm";
	precacheitem( "death_self_zm" );
	precachemodel( "zombie_pickup_perk_bottle" );
	precache_trophy();
	precacheshader( "faction_cdc" );
	precacheshader( "faction_cia" );
	init_default_zcleansed_powerups();
	maps/mp/zombies/_zm_turned::init();
	level thread maps/mp/gametypes_zm/_zm_gametype::init();
	maps/mp/gametypes_zm/_zm_gametype::rungametypeprecache( "zcleansed" );
	init_cleansed_powerups();
}

init_default_zcleansed_powerups() //checked matches cerberus output
{
	maps/mp/zombies/_zm_powerups::include_zombie_powerup( "the_cure" );
	maps/mp/zombies/_zm_powerups::include_zombie_powerup( "blue_monkey" );
	maps/mp/zombies/_zm_powerups::add_zombie_powerup( "the_cure", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_MAX_AMMO", maps/mp/zombies/_zm_powerups::func_should_never_drop, 0, 0, 1 );
	maps/mp/zombies/_zm_powerups::add_zombie_powerup( "blue_monkey", level.cymbal_monkey_model, &"ZOMBIE_POWERUP_MAX_AMMO", maps/mp/zombies/_zm_powerups::func_should_never_drop, 1, 0, 0 );
}

init_cleansed_powerup_fx() //checked matches cerberus output
{
	level._effect[ "powerup_on_caution" ] = loadfx( "misc/fx_zombie_powerup_on_blue" );
}

onstartgametype() //checked changed to match cerberus output
{
	maps/mp/gametypes_zm/_zm_gametype::setup_classic_gametype();
	level thread makefindfleshstructs();
	flag_init( "start_supersprint" );
	level.custom_player_fake_death = ::empty;
	level.custom_player_fake_death_cleanup = ::empty;
	level.overrideplayerdamage = ::cleanseddamagechecks;
	level.playerlaststand_func = ::cleansed_player_laststand;
	level.onendgame = ::cleansedonendgame;
	level.ontimelimit = ::cleansedontimelimit;
	level.powerup_player_valid = ::cleansed_alive_check;
	level.nml_zombie_spawners = level.zombie_spawners;
	level.dodge_score_highlight = 1;
	level.dodge_show_revive_icon = 1;
	level.custom_max_zombies = 6;
	level.custom_zombie_health = 200;
	level.nml_dogs_enabled = 0;
	level.timercountdown = 1;
	level.initial_spawn = 1;
	level.nml_reaction_interval = 2000;
	level.nml_min_reaction_dist_sq = 1024;
	level.nml_max_reaction_dist_sq = 5760000;
	level.min_humans = 1;
	level.no_end_game_check = 1;
	level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
	level._get_game_module_players = undefined;
	level.powerup_drop_count = 0;
	level.is_zombie_level = 1;
	level.player_becomes_zombie = ::onzombifyplayer;
	level.player_kills_player = ::player_kills_player;
	set_zombie_var( "zombify_player", 1 );
	set_zombie_var( "penalty_died", 1 );
	set_zombie_var( "penalty_downed", 1 );
	if ( isDefined( level._zcleansed_weapon_progression ) )
	{
		for ( i = 0; i < level._zcleansed_weapon_progression.size; i++ )
		{
			addguntoprogression( level._zcleansed_weapon_progression[ i ] );
		}
	}
	maps/mp/gametypes_zm/_zm_gametype::rungametypemain( "zcleansed", ::zcleansed_logic );
}

turnedlog( text ) //checked matches cerberus output
{
	/*
/#
	println( "TURNEDLOG: " + text + "\n" );
#/
	*/
}

cleansed_player_laststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration ) //checked matches cerberus output used is_true() instead
{
	self maps/mp/zombies/_zm_score::player_downed_penalty();
	if ( isDefined( attacker ) && isplayer( attacker ) && attacker != self )
	{
		if ( is_true( self.hide_owner ) )
		{
			attacker notify( "invisible_player_killed" );
		}
	}
	if ( is_true( self.is_zombie ) && deathanimduration == 0 )
	{
		self stopsounds();
	}
}

cleansed_alive_check( player ) //checked changed to match cerberus output used is_true() instead
{
	if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() || is_true( player.nuked ) || is_true( player.is_in_process_of_zombify ) || is_true( player.is_in_process_of_humanify ) )
	{
		return 0;
	}
	return 1;
}

cleanseddamagechecks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked partially changed to match cerberus output changed at own discretion used is_true() instead
{
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || is_true( self.is_in_process_of_zombify ) || is_true( self.is_in_process_of_humanify ) )
	{
		return 0;
	}
	if ( is_true( self.nuked ) && eattacker != self.nuker && eattacker != self )
	{
		return 0;
	}
	if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker != self )
	{
		if ( eattacker.team == self.team )
		{
			return 0;
		}
		if ( is_true( eattacker.is_zombie ) && is_true( self.is_zombie ) )
		{
			return 0;
		}
		if ( !cleansed_alive_check( eattacker ) )
		{
			return 0;
		}
		if ( is_true( self.nuked ) && isDefined( self.nuker ) && eattacker != self.nuker )
		{
			return 0;
		}
		if ( is_true( self.is_zombie ) && sweapon == "cymbal_monkey_zm" && smeansofdeath != "MOD_IMPACT" )
		{
			level notify( "killed_by_decoy", eattacker, self );
			idamage = self.health + 666;
		}
		else
		{
			self.last_player_attacker = eattacker;
		}
		eattacker thread maps/mp/gametypes_zm/_weapons::checkhit( sweapon );
		if ( !eattacker.is_zombie && eattacker maps/mp/zombies/_zm_powerups::is_insta_kill_active() )
		{
			idamage = self.health + 666;
		}
	}
	if ( is_true( eattacker.is_zombie ) )
	{
		self playsoundtoplayer( "evt_player_swiped", self );
	}
	return self maps/mp/zombies/_zm::player_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
}

custom_end_screen() //checked changed to match cerberus output used is_true() instead
{
	players = get_players();
	winner = players[ 0 ];
	foreach ( player in players )
	{
		if ( ( isDefined( winner ) && player.score ) > winner.score )
		{
			winner = player;
		}
	}
	if ( isDefined( level.last_human_standing ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ].bonus_msg_hud = newclienthudelem( players[ i ] );
			players[ i ].bonus_msg_hud.alignx = "center";
			players[ i ].bonus_msg_hud.aligny = "middle";
			players[ i ].bonus_msg_hud.horzalign = "center";
			players[ i ].bonus_msg_hud.vertalign = "middle";
			players[ i ].bonus_msg_hud.y -= 130;
			if ( players[ i ] issplitscreen() )
			{
				players[ i ].bonus_msg_hud.y += 70;
			}
			players[ i ].bonus_msg_hud.foreground = 1;
			players[ i ].bonus_msg_hud.fontscale = 5;
			players[ i ].bonus_msg_hud.alpha = 0;
			players[ i ].bonus_msg_hud.color = ( 0, 0, 0 );
			players[ i ].bonus_msg_hud.hidewheninmenu = 1;
			players[ i ].bonus_msg_hud.font = "default";
			players[ i ].bonus_msg_hud settext( &"ZOMBIE_CLEANSED_SURVIVING_HUMAN_BONUS", level.last_human_standing.name );
			players[ i ].bonus_msg_hud changefontscaleovertime( 0.25 );
			players[ i ].bonus_msg_hud fadeovertime( 0.25 );
			players[ i ].bonus_msg_hud.alpha = 1;
			players[ i ].bonus_msg_hud.fontscale = 2;
			i++;
		}
		wait 3.25;
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( isDefined( players[ i ].bonus_msg_hud ) )
		{
			players[ i ].bonus_msg_hud changefontscaleovertime( 0.5 );
			players[ i ].bonus_msg_hud fadeovertime( 0.5 );
			players[ i ].bonus_msg_hud.alpha = 0;
			players[ i ].bonus_msg_hud.fontscale = 5;
		}
	}
	wait 0.5;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( isDefined( players[ i ].bonus_msg_hud ) )
		{
			players[ i ].bonus_msg_hud destroy();
		}
		players[ i ].game_over_hud = newclienthudelem( players[ i ] );
		players[ i ].game_over_hud.alignx = "center";
		players[ i ].game_over_hud.aligny = "middle";
		players[ i ].game_over_hud.horzalign = "center";
		players[ i ].game_over_hud.vertalign = "middle";
		players[ i ].game_over_hud.y -= 130;
		players[ i ].game_over_hud.foreground = 1;
		players[ i ].game_over_hud.fontscale = 3;
		players[ i ].game_over_hud.alpha = 0;
		players[ i ].game_over_hud.color = ( 0, 0, 0 );
		players[ i ].game_over_hud.hidewheninmenu = 1;
		players[ i ].game_over_hud settext( &"ZOMBIE_GAME_OVER" );
		players[ i ].game_over_hud fadeovertime( 1 );
		players[ i ].game_over_hud.alpha = 1;
		if ( players[ i ] issplitscreen() )
		{
			players[ i ].game_over_hud.fontscale = 2;
			players[ i ].game_over_hud.y += 40;
		}
		players[ i ].survived_hud = newclienthudelem( players[ i ] );
		players[ i ].survived_hud.alignx = "center";
		players[ i ].survived_hud.aligny = "middle";
		players[ i ].survived_hud.horzalign = "center";
		players[ i ].survived_hud.vertalign = "middle";
		players[ i ].survived_hud.y -= 100;
		players[ i ].survived_hud.foreground = 1;
		players[ i ].survived_hud.fontscale = 2;
		players[ i ].survived_hud.alpha = 0;
		players[ i ].survived_hud.color = ( 0, 0, 0 );
		players[ i ].survived_hud.hidewheninmenu = 1;
		if ( players[ i ] issplitscreen() )
		{
			players[ i ].survived_hud.fontscale = 1.5;
			players[ i ].survived_hud.y += 40;
		}
		winner_text = &"ZOMBIE_CLEANSED_WIN";
		loser_text = &"ZOMBIE_CLEANSED_LOSE";
		if ( is_true( level.host_ended_game ) )
		{
			players[ i ].survived_hud settext( &"MP_HOST_ENDED_GAME" );
		}
		else if ( players[ i ] == winner )
		{
			players[ i ].survived_hud settext( winner_text );
			break;
		}
		else
		{
			players[ i ].survived_hud settext( loser_text );
		}
		players[ i ].survived_hud fadeovertime( 1 );
		players[ i ].survived_hud.alpha = 1;
	}
}

allow_player_movement( allowed ) //checked partially changed to match cerberus output used is_true() instead
{
	level.player_movement_suppressed = !allowed;
	foreach ( player in get_players() )
	{
		if ( !is_true( player.in_zombify_call ) )
		{
			player freezecontrolswrapper( level.player_movement_suppressed );
		}
	}
}

watch_game_start() //checked matches cerberus output
{
	level.start_audio_allowed = 1;
	level waittill( "cleansed_game_started" );
	level.start_audio_allowed = 0;
}

listen_to_the_doctor_pregame() //checked matches cerberus output
{
	thread watch_game_start();
	level maps/mp/zombies/_zm_audio_announcer::leaderdialog( "dr_start_single_0", undefined, undefined, 1, 4 );
	wait 4;
	if ( level.start_audio_allowed )
	{
		level maps/mp/zombies/_zm_audio_announcer::leaderdialog( "dr_start_2", undefined, undefined, 1, 8 );
		wait 8;
	}
	if ( level.start_audio_allowed )
	{
		level maps/mp/zombies/_zm_audio_announcer::leaderdialog( "dr_start_3", undefined, undefined, 1, 8 );
		wait 4;
	}
	if ( level.start_audio_allowed )
	{
		level waittill( "cleansed_game_started" );
	}
}

listen_to_the_doctor_started() //checked matches cerberus output
{
	level maps/mp/zombies/_zm_audio_announcer::leaderdialog( "dr_cure_found_line", undefined, undefined, 1, 8 );
	wait 8;
}

listen_to_the_doctor_monkeys() //checked changed to match cerberus output used is_true() instead
{
	level endon( "end_game" );
	while ( 1 )
	{
		level waittill( "killed_by_decoy", killer, killee );
		if ( !isplayer( killee ) )
		{
			continue;
		}
		if ( is_true( level.playing_turned_kill_vo ) )
		{
			continue;
		}
		if ( !is_true( killer.heard_dr_monkey_killer ) )
		{
			level.playing_turned_kill_vo = 1;
			killer.heard_dr_monkey_killer = 1;
			killer thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "dr_monkey_killer", undefined, undefined, 0 );
		}
		if ( !is_true( killee.heard_dr_monkey_killee ) )
		{
			level.playing_turned_kill_vo = 1;
			killee.heard_dr_monkey_killee = 1;
			wait 0.25;
			killee thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "dr_monkey_killee", undefined, undefined, 0 );
		}
		if ( is_true( level.playing_turned_kill_vo ) )
		{
			wait 8;
			level.playing_turned_kill_vo = 0;
		}
	}
}

listen_to_the_doctor_human_deaths() //checked matches cerberus output used is_true() instead
{
	level endon( "end_game" );
	while ( 1 )
	{
		level waittill( "killed_by_zombie", killer, killee );
		wait 0.05;
		if ( is_true( level.playing_turned_kill_vo ) )
		{
			continue;
		}
		if ( !isDefined( killee.vo_human_killed_chance ) )
		{
			killee.vo_human_killed_chance = 24;
		}
		if ( randomint( 100 ) < killee.vo_human_killed_chance )
		{
			level.playing_turned_kill_vo = 1;
			killee thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "dr_human_killed", undefined, undefined, 0 );
			killee.vo_human_killed_chance = int( killee.vo_human_killed_chance * 0,5 );
		}
		if ( is_true( level.playing_turned_kill_vo ) )
		{
			wait 4;
			level.playing_turned_kill_vo = 0;
		}
	}
}

listen_to_the_doctor_zombie_deaths() //checked matches cerberus output used is_true() instead
{
	level endon( "end_game" );
	while ( 1 )
	{
		level waittill( "killed_by_human", killer, killee );
		wait 0.05;
		if ( is_true( level.playing_turned_kill_vo ) )
		{
			continue;
		}
		if ( !isDefined( killer.vo_human_killer_chance ) )
		{
			killer.vo_human_killer_chance = 24;
		}
		if ( randomint( 100 ) < killer.vo_human_killer_chance )
		{
			killer.vo_human_killer_chance = int( killer.vo_human_killer_chance * 0.5 );
			level.playing_turned_kill_vo = 1;
			killer thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "dr_human_killer", undefined, undefined, 0 );
		}
		if ( is_true( level.playing_turned_kill_vo ) )
		{
			wait 4;
			level.playing_turned_kill_vo = 0;
		}
	}
}

listen_to_the_doctor_endgame() //checked does not match cerberus output did not change
{
	wait 5;
	while ( maps/mp/gametypes_zm/_globallogic_utils::gettimeremaining() > 12000 )
	{
		wait 1;
	}
	r = randomint( 3 );
	if ( r == 0 )
	{
		level maps/mp/zombies/_zm_audio_announcer::leaderdialog( "dr_countdown0", undefined, undefined, 1, 4 );
	}
	else if ( r == 1 )
	{
		level maps/mp/zombies/_zm_audio_announcer::leaderdialog( "dr_countdown1", undefined, undefined, 1, 4 );
	}
	else
	{
		level maps/mp/zombies/_zm_audio_announcer::leaderdialog( "dr_countdown2", undefined, undefined, 1, 4 );
	}
	while ( maps/mp/gametypes_zm/_globallogic_utils::gettimeremaining() > 500 )
	{
		wait 1;
	}
	level maps/mp/zombies/_zm_audio_announcer::leaderdialog( "dr_ending", undefined, undefined, 1, 4 );
}

anysplitscreen() //checked changed to match cerberus output
{
	foreach ( player in get_players() )
	{
		if ( player issplitscreen() )
		{
			return 1;
		}
	}
	return 0;
}

listen_to_the_doctor() //checked matches cerberus output
{
	listen_to_the_doctor_pregame();
	if ( !anysplitscreen() )
	{
		listen_to_the_doctor_started();
		thread listen_to_the_doctor_human_deaths();
		thread listen_to_the_doctor_zombie_deaths();
		thread listen_to_the_doctor_monkeys();
	}
	thread listen_to_the_doctor_endgame();
}

watch_survival_time() //checked matches cerberus output
{
	level endon( "end_game" );
	level notify( "new_human_suviving" );
	level endon( "new_human_suviving" );
	self endon( "zombify" );
	wait 10;
	if ( !isDefined( self.vo_human_survival_chance ) )
	{
		self.vo_human_survival_chance = 24;
	}
	while ( 1 )
	{
		if ( isDefined( level.playing_turned_kill_vo ) && !level.playing_turned_kill_vo )
		{
			if ( randomint( 100 ) < self.vo_human_survival_chance )
			{
				self.vo_human_survival_chance = int( self.vo_human_survival_chance * 0.25 );
				level.playing_turned_kill_vo = 1;
				self thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "dr_survival", undefined, undefined, 0 );
				wait 4;
				level.playing_turned_kill_vo = 0;
			}
		}
		wait 5;
	}
}

zcleansed_logic() //checked changed to match cerberus output
{
	setdvar( "player_lastStandBleedoutTime", "0.05" );
	setmatchtalkflag( "DeadChatWithDead", 1 );
	setmatchtalkflag( "DeadChatWithTeam", 1 );
	setmatchtalkflag( "DeadHearTeamLiving", 1 );
	setmatchtalkflag( "DeadHearAllLiving", 1 );
	setmatchtalkflag( "EveryoneHearsEveryone", 1 );
	level.zombie_include_powerups[ "carpenter" ] = 0;
	level.noroundnumber = 1;
	level._supress_survived_screen = 1;
	doors = getentarray( "zombie_door", "targetname" );
	foreach ( door in doors )
	{
		door setinvisibletoall();
	}
	level thread maps/mp/zombies/_zm_blockers::open_all_zbarriers();
	level thread delay_box_hide();
	flag_wait( "initial_players_connected" );
	level.gamestarttime = getTime();
	level.gamelengthtime = undefined;
	level.custom_spawnplayer = ::respawn_cleansed_player;
	allow_player_movement( 0 );
	setup_players();
	flag_wait( "initial_blackscreen_passed" );
	level thread listen_to_the_doctor();
	level thread playturnedmusic();
	level notify( "start_fullscreen_fade_out" );
	wait 1.5;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread create_match_start_message( &"ZOMBIE_FIND_THE_CURE", 3 );
	}
	allow_player_movement( 1 );
	spawn_initial_cure_powerup();
	waitforhumanselection();
	level notify( "cleansed_game_started" );
	level thread leaderwatch();
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread create_match_start_message( &"ZOMBIE_MOST_TIME_AS_HUMAN_TO_WIN", 3 );
	}
	wait 1.2;
	flag_clear( "pregame" );
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread destroystartmsghud();
	}
	registertimelimit( 0, 1440 );
	level.discardtime = getTime() - level.starttime;
	level thread watch_for_end_game();
	wait_for_round_end();
	allow_player_movement( 0 );
	wait_network_frame();
	award_round_end_bonus();
	level notify( "end_game" );
}

wait_for_round_end() //checked matches cerberus output
{
	level endon( "early_game_end" );
	level endon( "normal_game_end" );
	while ( maps/mp/gametypes_zm/_globallogic_utils::gettimeremaining() > 0 )
	{
		wait 1;
	}
}

end_game_early() //checked matches cerberus output
{
	/*
/#
	iprintlnbold( "SOLO GAME - RELEASE ONLY" );
	return;
#/
	*/
	level.forcedend = 1;
	level notify( "early_game_end" );
	level notify( "end_game" );
}

watch_for_end_game() //checked matches cerberus output
{
	level waittill( "end_game" );
	registertimelimit( 0, 0 );
	setgameendtime( 0 );
}

cleansedontimelimit() //checked matches cerberus output
{
	level notify( "normal_game_end" );
}

cleansedonendgame( winningteam ) //checked matches cerberus output
{
}

create_match_start_message( text, duration ) //checked changed to match cerberus output
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self notify( "kill_match_start_message" );
	self endon( "kill_match_start_message" );
	if ( !isDefined( self.match_start_msg_hud ) )
	{
		self.match_start_msg_hud = newclienthudelem( self );
		self.match_start_msg_hud.alignx = "center";
		self.match_start_msg_hud.aligny = "middle";
		self.match_start_msg_hud.horzalign = "center";
		self.match_start_msg_hud.vertalign = "middle";
		self.match_start_msg_hud.y -= 130;
		self.match_start_msg_hud.fontscale = 5;
		self.match_start_msg_hud.foreground = 1;
		if ( self issplitscreen() )
		{
			self.match_start_msg_hud.y += 70;
		}
		self.match_start_msg_hud.color = ( 1, 1, 1 );
		self.match_start_msg_hud.hidewheninmenu = 1;
		self.match_start_msg_hud.font = "default";
	}
	self.match_start_msg_hud settext( text );
	self.match_start_msg_hud changefontscaleovertime( 0.25 );
	self.match_start_msg_hud fadeovertime( 0.25 );
	self.match_start_msg_hud.alpha = 1;
	self.match_start_msg_hud.fontscale = 2;
	if ( self issplitscreen() )
	{
		self.match_start_msg_hud.fontscale = 1.5;
	}
	wait duration;
	if ( !isDefined( self.match_start_msg_hud ) )
	{
		return;
	}
	self.match_start_msg_hud changefontscaleovertime( 0.5 );
	self.match_start_msg_hud fadeovertime( 0.5 );
	self.match_start_msg_hud.alpha = 0;
}

destroystartmsghud() //checked matches cerberus output
{
	level endon( "end_game" );
	self endon( "disconnect" );
	if ( !isDefined( self.match_start_msg_hud ) )
	{
		return;
	}
	self.match_start_msg_hud destroy();
	self.match_start_msg_hud = undefined;
}

delay_box_hide() //checked matches cerberus output
{
	wait 2;
	start_chest = getstruct( "start_chest", "script_noteworthy" );
	if ( isDefined( start_chest ) )
	{
		start_chest maps/mp/zombies/_zm_magicbox::hide_chest();
	}
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread onplayerlaststand();
		player thread onplayerdisconnect();
		player thread setup_player();
		player thread rewardsthink();
	}
}

onplayerlaststand() //checked matches cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "player_downed" );
		self takeallweapons();
	}
}

onplayerdisconnect() //checked changed to match cerberus output used is_true() instead
{
	level endon( "end_game" );
	self waittill( "disconnect" );
	if ( get_players().size <= 1 )
	{
		end_game_early();
	}
	if ( !is_true( level.ingraceperiod ) )
	{
		thread checkzombiehumanratio();
		wait 2;
		players = get_players();
		foreach ( player in players )
		{
			player.nuked = undefined;
		}
	}
}

zombie_ramp_up() //checked matches cerberus output
{
	self notify( "zombie_ramp_up" );
	self endon( "zombie_ramp_up" );
	self endon( "death_or_disconnect" );
	self endon( "humanify" );
	if ( isDefined( level.cleansed_zombie_round ) )
	{
		self.maxhealth = maps/mp/zombies/_zm::ai_zombie_health( level.cleansed_zombie_round );
	}
	else
	{
		self.maxhealth = maps/mp/zombies/_zm::ai_zombie_health( 2 );
	}
	self.health = self.maxhealth;
}

precache_trophy() //checked matches cerberus output
{
}

create_trophy() //checked matches cerberus output
{
}

give_trophy() //checked matches cerberus output
{
	if ( !self.has_trophy )
	{
		self setclientfield( "player_eyes_special", 1 );
		self setclientfield( "player_has_eyes", 0 );
		wait_network_frame();
		if ( cleansed_alive_check( self ) )
		{
			self setclientfield( "player_has_eyes", self.is_zombie );
		}
		self.has_trophy = 1;
	}
}

remove_trophy() //checked matches cerberus output
{
	if ( self.has_trophy )
	{
		self setclientfield( "player_eyes_special", 0 );
		self setclientfield( "player_has_eyes", 0 );
		wait_network_frame();
		if ( cleansed_alive_check( self ) )
		{
			self setclientfield( "player_has_eyes", self.is_zombie );
		}
		self.has_trophy = 0;
	}
}

enthrone( player ) //checked changed to match cerberus output
{
	player endon( "dethrone" );
	player endon( "disconnect" );
	while ( 1 )
	{
		if ( cleansed_alive_check( player ) && player.is_zombie )
		{
			if ( !player.has_trophy )
			{
				player give_trophy();
			}
		}
		else if ( player.has_trophy )
		{
			player remove_trophy();
		}
		wait 0.1;
	}
}

dethrone( player ) //checked matches cerberus output
{
	player notify( "dethrone" );
	player remove_trophy();
}

cleansed_set_leader( leader ) //checked matches cerberus output
{
	if ( isDefined( leader ) && isDefined( level.cleansed_leader ) )
	{
		if ( level.cleansed_leader != leader )
		{
			dethrone( level.cleansed_leader );
			level.cleansed_leader = leader;
			level thread enthrone( level.cleansed_leader );
		}
		return;
	}
	if ( isDefined( leader ) && !isDefined( level.cleansed_leader ) )
	{
		level.cleansed_leader = leader;
		level thread enthrone( level.cleansed_leader );
		return;
	}
	if ( !isDefined( leader ) && isDefined( level.cleansed_leader ) )
	{
		if ( isDefined( level.cleansed_leader ) )
		{
			dethrone( level.cleansed_leader );
		}
		level.cleansed_leader = leader;
		return;
	}
}

leaderwatch() //checked changed to match cerberus output may be suspicous
{
	level endon( "early_game_end" );
	level endon( "normal_game_end" );
	create_trophy();
	cleansed_set_leader( undefined );
	while ( 1 )
	{
		hiscore = -1;
		leader = undefined;
		players = get_players();
		foreach ( player in players )
		{
			if ( player.score > hiscore )
			{
				hiscore = player.score;
			}
		}
		foreach ( player in players )
		{
			if ( player.score >= hiscore )
			{
				if ( isDefined( leader ) )
				{
					leader = undefined;
					break;
				}
				leader = player;
				//logic here doesn't make much sense leader will be defined but then undefined?!
			}
		}
		cleansed_set_leader( leader );
		wait 0.25;
	}
}

cover_transition() //checked matches cerberus output
{
	self thread fadetoblackforxsec( 0, 0.15, 0.05, 0.1 );
	wait 0.1;
}

disappear_in_flash( washuman ) //checked matches cerberus output
{
	playsoundatposition( "zmb_bolt", self.origin );
	if ( washuman )
	{
		playfx( level._effect[ "human_disappears" ], self.origin );
	}
	else
	{
		playfx( level._effect[ "zombie_disappears" ], self.origin );
	}
	self ghost();
}

humanifyplayer( for_killing ) //checked matches cerberus output
{
	self freezecontrolswrapper( 1 );
	self thread cover_transition();
	self disappear_in_flash( 1 );
	self.team = self.prevteam;
	self.pers[ "team" ] = self.prevteam;
	self.sessionteam = self.prevteam;
	self turnedhuman();
	for_killing waittill_notify_or_timeout( "respawned", 0.75 );
	wait_network_frame();
	checkzombiehumanratio( self );
	self.last_player_attacker = undefined;
	self freezecontrolswrapper( level.player_movement_suppressed );
	self thread watch_survival_time();
}

onzombifyplayer() //checked partially changed to match cerberus output used is_true() instead
{
	if ( is_true( self.in_zombify_call ) )
	{
		return;
	}
	self.in_zombify_call = 1;
	while ( is_true( level.in_zombify_call ) )
	{
		wait 0.1;
	}
	level.in_zombify_call = 1;
	self freezecontrolswrapper( 1 );
	if ( is_true( self.is_zombie ) )
	{
		self check_for_drops( 0 );
	}
	else if ( isDefined( self.last_player_attacker ) && isplayer( self.last_player_attacker ) && is_true( self.last_player_attacker.is_zombie ) )
	{
		self check_for_drops( 1 );
		self.team = level.zombie_team;
		self.pers[ "team" ] = level.zombie_team;
		self.sessionteam = level.zombie_team;
		self.last_player_attacker thread humanifyplayer( self );
		self.player_was_turned_by = self.last_player_attacker;
	}
	else
	{
		self check_for_drops( 1 );
		self player_suicide();
		checkzombiehumanratio( undefined, self );
	}
	self setclientfield( "player_has_eyes", 0 );
	self notify( "zombified" );
	self disappear_in_flash( 0 );
	self cover_transition();
	self notify( "clear_red_flashing_overlay" );
	self.zombification_time = getTime() / 1000;
	self.last_player_attacker = undefined;
	self maps/mp/zombies/_zm_laststand::laststand_enable_player_weapons();
	self.ignoreme = 1;
	if ( isDefined( self.revivetrigger ) )
	{
		self.revivetrigger delete();
	}
	self.revivetrigger = undefined;
	self reviveplayer();
	self maps/mp/zombies/_zm_turned::turn_to_zombie();
	self freezecontrolswrapper( level.player_movement_suppressed );
	self thread zombie_ramp_up();
	level.in_zombify_call = 0;
	self.in_zombify_call = 0;
}

playerfakedeath( vdir ) //checked changed to match cerberus output used is_true() instead
{
	if ( !is_true( self.is_zombie ) )
	{
		self endon( "disconnect" );
		level endon( "game_module_ended" );
		level notify( "fake_death" );
		self notify( "fake_death" );
		self enableinvulnerability();
		self takeallweapons();
		self freezecontrolswrapper( 1 );
		self.ignoreme = 1;
		origin = self.origin;
		xyspeed = ( 0, 0, 0 );
		angles = self getplayerangles();
		angles = ( angles[ 0 ], angles[ 1 ], angles[ 2 ] + randomfloatrange( -5, 5 ) );
		if ( isDefined( vdir ) && length( vdir ) > 0 )
		{
			xyspeedmag = 40 + randomint( 12 ) + randomint( 12 );
			xyspeed = xyspeedmag * vectornormalize( ( vdir[ 0 ], vdir[ 1 ], 0 ) );
		}
		linker = spawn( "script_origin", ( 0, 0, 0 ) );
		linker.origin = origin;
		linker.angles = angles;
		self._fall_down_anchor = linker;
		self playerlinkto( linker );
		self playsoundtoplayer( "zmb_player_death_fall", self );
		origin = playerphysicstrace( origin, origin + xyspeed );
		origin += vectorScale( ( 0, 0, -1 ), 52 );
		lerptime = 0.5;
		linker moveto( origin, lerptime, lerptime );
		linker rotateto( angles, lerptime, lerptime );
		self freezecontrolswrapper( 1 );
		linker waittill( "movedone" );
		self giveweapon( "death_throe_zm" );
		self switchtoweapon( "death_throe_zm" );
		bounce = randomint( 4 ) + 8;
		origin = ( origin + ( 0, 0, bounce ) ) - ( xyspeed * 0.1 );
		lerptime = bounce / 50;
		linker moveto( origin, lerptime, 0, lerptime );
		linker waittill( "movedone" );
		origin = ( origin + ( 0, 0, bounce * -1 ) ) + ( xyspeed * 0.1 );
		lerptime /= 2;
		linker moveto( origin, lerptime, lerptime );
		linker waittill( "movedone" );
		linker moveto( origin, 5, 0 );
		wait 5;
		linker delete();
		self.ignoreme = 0;
		self takeweapon( "death_throe_zm" );
		self disableinvulnerability();
		self freezecontrolswrapper( 0 );
	}
}

onspawnzombie() //checked matches cerberus output
{
}

makefindfleshstructs() //checked changed to match cerberus output
{
	structs = getstructarray( "spawn_location", "script_noteworthy" );
	foreach ( struct in structs )
	{
		struct.script_string = "find_flesh";
	}
}

setup_players() //dev call ignored
{
	/*
/#
	while ( getDvarInt( #"99BF96D1" ) != 0 )
	{
		_a1269 = level._turned_zombie_respawnpoints;
		_k1269 = getFirstArrayKey( _a1269 );
		while ( isDefined( _k1269 ) )
		{
			spawnpoint = _a1269[ _k1269 ];
			text = "";
			color = ( 0, 0, 0 );
			if ( !isDefined( spawnpoint.angles ) )
			{
				text = "No Angles Defined";
				color = ( 0, 0, 0 );
				spawnpoint.angles = ( 0, 0, 0 );
			}
			_k1269 = getNextArrayKey( _a1269, _k1269 );
#/
		}
	}
	*/
}

setup_player() //checked matches cerberus output
{
	hotjoined = flag( "initial_players_connected" );
	flag_wait( "initial_players_connected" );
	wait 0.05;
	self ghost();
	self freezecontrolswrapper( 1 );
	self.ignoreme = 0;
	self.score = 0;
	self.characterindex = level.characterindex;
	self takeallweapons();
	self giveweapon( "knife_zm" );
	self give_start_weapon( 1 );
	self.prevteam = self.team;
	self.no_revive_trigger = 1;
	self.human_score = 0;
	self thread player_score_update();
	self.is_zombie = 0;
	self.has_trophy = 0;
	self.home_team = self.team;
	if ( self.home_team == "axis" )
	{
		self.home_team = "team3";
	}
	self thread wait_turn_to_zombie( hotjoined );
}

wait_turn_to_zombie( hot ) //checked matches cerberus output
{
	if ( hot )
	{
		self thread fadetoblackforxsec( 0, 1.25, 0.05, 0.25 );
		wait 1;
	}
	self.is_zombie = 0;
	self turn_to_zombie();
	self freezecontrolswrapper( level.player_movement_suppressed );
}

addguntoprogression( gunname ) //checked matches cerberus output
{
	if ( !isDefined( level.gunprogression ) )
	{
		level.gunprogression = [];
	}
	level.gunprogression[ level.gunprogression.size ] = gunname;
}

check_spawn_cymbal_monkey( origin, weapon ) //checked matches cerberus output
{
	chance = -0.05;
	if ( !self hasweapon( "cymbal_monkey_zm" ) || self getweaponammoclip( "cymbal_monkey_zm" ) < 1 )
	{
		if ( weapon == "cymbal_monkey_zm" || randomfloat( 1 ) < chance )
		{
			self notify( "awarded_cymbal_monkey" );
			level.spawned_cymbal_monkey = spawn_cymbalmonkey( origin );
			level.spawned_cymbal_monkey thread delete_spawned_monkey_on_turned( self );
			return 1;
		}
	}
	return 0;
}

delete_spawned_monkey_on_turned( player ) //checked matches cerberus output used is_true() instead
{
	wait 1;
	while ( isDefined( self ) && !is_true( player.is_zombie ) )
	{
		wait_network_frame();
	}
	if ( isDefined( self ) )
	{
		self maps/mp/zombies/_zm_powerups::powerup_delete();
		self notify( "powerup_timedout" );
	}
}

rewardsthink() //checked matches cerberus output used is_true() instead
{
	self endon( "_zombie_game_over" );
	self endon( "disconnect" );
	while ( isDefined( self ) )
	{
		self waittill( "killed_a_zombie_player", einflictor, target, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
		if ( !is_true( self.is_zombie ) )
		{
			if ( self check_spawn_cymbal_monkey( target.origin, sweapon ) )
			{
				target.suppress_drops = 1;
			}
		}
	}
}

shotgunloadout() //checked matches cerberus output used is_true() instead
{
	self endon( "_zombie_game_over" );
	self endon( "disconnect" );
	self endon( "bled_out" );
	self endon( "zombify" );
	level.cymbal_monkey_clone_weapon = "rottweil72_zm";
	if ( !self hasweapon( "rottweil72_zm" ) )
	{
		self giveweapon( "rottweil72_zm" );
		self switchtoweapon( "rottweil72_zm" );
	}
	if ( !is_true( self.is_zombie ) && !self hasweapon( level.start_weapon ) )
	{
		if ( !self hasweapon( "knife_zm" ) )
		{
			self giveweapon( "knife_zm" );
		}
		self give_start_weapon( 0 );
	}
	if ( self hasweapon( "rottweil72_zm" ) )
	{
		self setweaponammoclip( "rottweil72_zm", 2 );
		self setweaponammostock( "rottweil72_zm", 0 );
	}
	if ( self hasweapon( level.start_weapon ) )
	{
		self givemaxammo( level.start_weapon );
	}
	if ( self hasweapon( self get_player_lethal_grenade() ) )
	{
		self getweaponammoclip( self get_player_lethal_grenade() );
	}
	else
	{
		self giveweapon( self get_player_lethal_grenade() );
	}
	self setweaponammoclip( self get_player_lethal_grenade(), 2 );
}

gunprogressionthink() //checked changed to match cerberus output
{
	self endon( "_zombie_game_over" );
	self endon( "disconnect" );
	self endon( "bled_out" );
	self endon( "zombify" );
	counter = 0;
	if ( isDefined( level.gunprogression ) && !isDefined( level.cymbal_monkey_clone_weapon ) )
	{
		level.cymbal_monkey_clone_weapon = level.gunprogression[ 0 ];
	}
	last = level.start_weapon;
	if ( !self hasweapon( self get_player_lethal_grenade() ) )
	{
		self giveweapon( self get_player_lethal_grenade() );
	}
	self setweaponammoclip( self get_player_lethal_grenade(), 2 );
	self disableweaponcycling();
	while ( !is_true( self.is_zombie ) )
	{
		if ( !isDefined( level.gunprogression[ counter ] ) )
		{
			break; //added from cerberus
		}
		self disableweaponcycling();
		self giveweapon( level.gunprogression[ counter ] );
		self switchtoweapon( level.gunprogression[ counter ] );
		self waittill_notify_or_timeout( "weapon_change_complete", 0.5 );
		if ( isDefined( last ) && self hasweapon( last ) )
		{
			self takeweapon( last );
		}
		last = level.gunprogression[ counter ];
		while ( 1 )
		{
			self waittill( "killed_a_zombie_player", einflictor, target, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
			if ( isDefined( sweapon ) && level.gunprogression[ counter ] == sweapon )
			{
				counter++;
				break;
			}
		}
		counter++;
	}
	self giveweapon( level.start_weapon );
	self switchtoweapon( level.start_weapon );
	self waittill( "weapon_change_complete" );
	if ( isDefined( last ) && self hasweapon( last ) )
	{
		self takeweapon( last );
	}
	while ( 1 )
	{
		self waittill( "killed_a_zombie_player", einflictor, target, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
		if ( isDefined( sweapon ) && level.start_weapon == sweapon )
		{
			self notify( "gun_game_achievement" );
			return;
		}
	}
}

waitforhumanselection() //checked matches cerberus output
{
	level waittill( "initial_human_selected" );
}

checkzombiehumanratio( playertomove, playertoignore ) //checked partially changed to match cerberus output see compiler_limitations.md No. 2 used is_true() instead
{
	zombiecount = 0;
	humancount = 0;
	zombieexist = 0;
	humanexist = 0;
	earliestzombie = undefined;
	earliestzombietime = 99999999;
	if ( get_players().size <= 1 )
	{
		end_game_early();
	}
	while ( is_true( level.checking_human_zombie_ratio ) )
	{
		wait 0.05;
	}
	level.checking_human_zombie_ratio = 1;
	if ( isDefined( playertomove ) )
	{
		someonebecominghuman = 0;
		players = get_players();
		foreach ( player in players )
		{
			if ( is_true( player.is_in_process_of_humanify ) )
			{
				someonebecominghuman = 1;
			}
		}
		if ( isDefined( someonebecominghuman ) && !someonebecominghuman )
		{
			playertomove turn_to_human();
		}
		level.checking_human_zombie_ratio = 0;
		return;
	}
	players = get_players();
	foreach ( player in players )
	{
		if ( isDefined( playertoignore ) && playertoignore == player )
		{
		}
		else
		{
			if ( !is_true( player.is_zombie ) && !is_true( player.is_in_process_of_zombify ) )
			{
				humancount++;
				humanexist = 1;
			}
			else
			{
				zombiecount++;
				zombieexist = 1;
				if ( is_true( player.zombification_time ) < earliestzombietime )
				{
					earliestzombie = player;
					earliestzombietime = player.zombification_time;
				}
			}
		}
	}
	if ( humancount > 1 )
	{
		players = get_players( "allies" );
		if ( isDefined( players ) && players.size > 0 )
		{
			player = random( players );
			player thread cover_transition();
			player disappear_in_flash( 1 );
			player turn_to_zombie();
			zombiecount++;
		}
	}
	if ( !humanexist )
	{
		players = get_players( level.zombie_team );
		if ( isDefined( players ) && players.size > 0 )
		{
			player = random( players );
			player thread cover_transition();
			player disappear_in_flash( 0 );
			player.random_human = 1;
			player turn_to_human();
			player.random_human = 0;
			zombiecount--;

		}
	}
	level.checking_human_zombie_ratio = 0;
}

get_player_rank() //checked partially changed to match cerberus output changed at own discretion
{
	level.player_score_sort = [];
	players = get_players();
	foreach ( player in players )
	{
		index = 0;
		while ( index < level.player_score_sort.size && ( player.score < level.player_score_sort[ index ].score ) )
		{
			index++;
		}
		arrayinsert( level.player_score_sort, player, index );
	}
	for ( index = 0; index < level.player_score_sort.size; index++ )
	{
		if ( self == level.player_score_sort[ index ] )
		{
			return index;
		}
	}
	/*
/#
	assertmsg( "This should not happen" );
#/
	*/
	return 0;
}

player_add_score( bonus ) //checked matches cerberus output used is_true() instead
{
	mult = 1;
	if ( is_true( self.is_zombie ) )
	{
		mult = level.zombie_vars[ level.zombie_team ][ "zombie_point_scalar" ];
	}
	else
	{
		mult = level.zombie_vars[ "allies" ][ "zombie_point_scalar" ];
	}
	self maps/mp/zombies/_zm_score::add_to_player_score( bonus * mult );
}

player_sub_score( penalty ) //checked matches cerberus output
{
	penalty = int( min( self.score, penalty ) );
	self maps/mp/zombies/_zm_score::add_to_player_score( penalty * -1 );
}

player_suicide() //checked matches cerberus output
{
	self player_sub_score( level.human_player_suicide_penalty );
	/*
/#
	if ( get_players().size < 2 )
	{
		self.intermission = 0;
		thread spawn_initial_cure_powerup();
#/
	}
	*/
}

player_kills_player( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) //checked changed to match cerberus output used is_true() instead
{
	score_multiplier = 1;
	if ( !is_true( eattacker.is_zombie ) && isDefined( level.zombie_player_kill_points ) )
	{
		level notify( "killed_by_human", eattacker, self );
		eattacker player_add_score( int( score_multiplier * level.zombie_player_kill_points ) );
		eattacker maps/mp/zombies/_zm_stats::add_global_stat( "PLAYER_KILLS", 1 );
		if ( smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" )
		{
			eattacker maps/mp/zombies/_zm_stats::increment_client_stat( "grenade_kills" );
			eattacker maps/mp/zombies/_zm_stats::increment_player_stat( "grenade_kills" );
		}
	}
	if ( is_true( eattacker.is_zombie ) && isDefined( level.human_player_kill_points ) )
	{
		level notify( "killed_by_zombie", eattacker, self );
		eattacker player_add_score( int( score_multiplier * level.human_player_kill_points ) );
		eattacker maps/mp/zombies/_zm_stats::add_global_stat( "PLAYER_RETURNS", 1 );
	}
}

award_round_end_bonus() //checked partially changed to match cerberus output see compiler_limitations.md No. 2 used is_true() instead
{
	level notify( "stop_player_scores" );
	wait 0.25;
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "dr_time_line", undefined, undefined, 1 );
	while ( maps/mp/zombies/_zm_laststand::player_any_player_in_laststand() || is_true( level.in_zombify_call ) )
	{
		wait 0.25;
	}
	hiscore = -1;
	foreach ( player in get_players() )
	{
		if ( !is_true( player.is_zombie ) )
		{
			player player_add_score( level.human_finish_bonus_points );
			level.last_human_standing = player;
		}
		if ( player.score > hiscore )
		{
			hiscore = player.score;
		}
	}
	foreach ( player in get_players() )
	{
		if ( player.score >= hiscore )
		{
			player.team = player.prevteam;
			player.pers[ "team" ] = player.prevteam;
			player.sessionteam = player.prevteam;
			player maps/mp/zombies/_zm_stats::increment_client_stat( "wins" );
			player maps/mp/zombies/_zm_stats::add_client_stat( "losses", -1 );
			player adddstat( "skill_rating", 1 );
			player setdstat( "skill_variance", 1 );
			if ( gamemodeismode( level.gamemode_public_match ) )
			{
				player maps/mp/zombies/_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "wins", 1 );
				player maps/mp/zombies/_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "losses", -1 );
			}
		}
		else
		{
			player.team = level.zombie_team;
			player.pers[ "team" ] = level.zombie_team;
			player.sessionteam = level.zombie_team;
			player setdstat( "skill_rating", 0 );
			player setdstat( "skill_variance", 1 );
		}
	}
}

player_score_update() //checked matches cerberus output used is_true() instead
{
	self endon( "_zombie_game_over" );
	self endon( "disconnect" );
	level endon( "stop_player_scores" );
	waittime = 0,05;
	while ( 1 )
	{
		self waittill_any_or_timeout( waittime, "zombify", "humanify" );
		if ( !is_true( self._can_score ) )
		{
			continue;
		}
		if ( is_true( level.hostmigrationtimer ) )
		{
			continue;
		}
		if ( !is_true( level.ingraceperiod ) )
		{
			if ( !cleansed_alive_check( self ) )
			{
				waittime = 0,05;
				break;
			}
			else if ( is_true( self.is_zombie ) )
			{
				waittime = level.zombie_penalty_period;
				self player_sub_score( level.zombie_penalty_points );
				break;
			}
			else
			{
				waittime = level.human_bonus_period;
				self player_add_score( level.human_bonus_points );
			}
		}
	}
}

respawn_cleansed_player() //checked matches cerberus output
{
	spawnpoint = self maps/mp/zombies/_zm_turned::getspawnpoint();
	self.sessionstate = "playing";
	self allowspectateteam( "freelook", 0 );
	self spawn( spawnpoint.origin, spawnpoint.angles );
	self notify( "stop_flame_damage" );
	self reviveplayer();
	self.nuked = 0;
	self.nuker = undefined;
	self.suppress_drops = 0;
	self.is_burning = 0;
	self.is_zombie = 0;
	self.ignoreme = 0;
	self freezecontrolswrapper( level.player_movement_suppressed );
	self notify( "respawned" );
}

zcleansed_zombie_powerup_grab( powerup, zombie_player ) //checked changed to match cerberus output
{
	if ( !cleansed_alive_check( zombie_player ) )
	{
		return 0;
	}
	switch( powerup.powerup_name )
	{
		case "the_cure":
			level notify( "initial_human_selected" );
			zombie_player freezecontrolswrapper( 1 );
			zombie_player disappear_in_flash( 0 );
			zombie_player turn_to_human();
			players = get_players();
			foreach ( player in players )
			{
				if ( player.is_zombie )
				{
					player thread zombie_ramp_up();
				}
			}
			break;
		default:
			if ( isDefined( level.cleansed_powerups[ powerup.powerup_name ] ) )
			{
				if ( isDefined( level.cleansed_powerups[ powerup.powerup_name ].callback ) )
				{
					powerup thread [[ level.cleansed_powerups[ powerup.powerup_name ].callback ]]( zombie_player );
				}
			}
			break;
		}
	}
}

zcleansed_powerup_grab( powerup, player )
{
	if ( !cleansed_alive_check( player ) )
	{
		return 0;
	}
	switch( powerup.powerup_name ) //checked matches cerberus output
	{
		case "blue_monkey":
			player maps/mp/zombies/_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
			player setweaponammoclip( "cymbal_monkey_zm", 1 );
			player notify( "powerup_blue_monkey" );
			break;
		default:
			if ( isDefined( level.cleansed_powerups[ powerup.powerup_name ] ) )
			{
				if ( isDefined( level.cleansed_powerups[ powerup.powerup_name ].callback ) )
				{
					powerup thread [[ level.cleansed_powerups[ powerup.powerup_name ].callback ]]( player );
				}
			}
			break;
	}
}

zcleansed_powerup_custom_time_logic( powerup ) //checked matches cerberus output
{
	if ( powerup.powerup_name == "the_cure" )
	{
		return 0;
	}
	return 15;
}

spawn_initial_cure_powerup() //checked matches cerberus output
{
	struct = random( level._turned_powerup_spawnpoints );
	maps/mp/zombies/_zm_powerups::specific_powerup_drop( "the_cure", struct.origin );
}

spawn_cymbalmonkey( origin ) //checked matches cerberus output
{
	monkey = maps/mp/zombies/_zm_powerups::specific_powerup_drop( "blue_monkey", origin );
	return monkey;
}

check_for_drops( washuman ) //checked matches cerberus output used is_true() instead
{
	if ( !isDefined( level.cleansed_kills_for_drops ) )
	{
		level.cleansed_kills_for_drops = 0;
	}
	if ( is_true( self.nuked ) || is_true( self.suppress_drops ) )
	{
		return;
	}
	level.cleansed_kills_for_drops++;
	chance = ( level.cleansed_kills_for_drops - 2 ) / level.cleansed_kills_for_drops;
	if ( chance > 0 )
	{
		r = randomfloatrange( 0, 1 );
		if ( r < chance )
		{
			self thread drop_powerup( washuman );
			level.cleansed_kills_for_drops = 0;
		}
	}
}

add_cleansed_powerup( name, powerupmodel, text, team, zombie_death_frequency, human_death_frequency, callback ) //checked matches cerberus output
{
	if ( !isDefined( level.cleansed_powerups ) )
	{
		level.cleansed_powerups = [];
	}
	precachemodel( powerupmodel );
	if ( !isDefined( level.zombie_powerups[ name ] ) )
	{
		maps/mp/zombies/_zm_powerups::include_zombie_powerup( name );
		maps/mp/zombies/_zm_powerups::add_zombie_powerup( name, powerupmodel, text, maps/mp/zombies/_zm_powerups::func_should_never_drop, 0, team == 2, team == 1 );
		if ( !isDefined( level.statless_powerups ) )
		{
			level.statless_powerups = [];
		}
		level.statless_powerups[ name ] = 1;
	}
	powerup = spawnstruct();
	powerup.name = name;
	powerup.model = powerupmodel;
	powerup.team = team;
	powerup.callback = callback;
	powerup.zfrequency = zombie_death_frequency;
	powerup.hfrequency = human_death_frequency;
	level.cleansed_powerups[ name ] = powerup;
}

init_cleansed_powerups() //checked changed to match cerberus output
{
	level._effect[ "powerup_on_solo" ] = loadfx( "misc/fx_zombie_powerup_on_blue" );
	add_cleansed_powerup( "green_nuke", "zombie_bomb", &"ZOMBIE_THIS_IS_A_BUG", 0, 0,4, 0, ::turned_powerup_green_nuke );
	add_cleansed_powerup( "green_double", "zombie_x2_icon", &"ZOMBIE_THIS_IS_A_BUG", 0, 1, 0, ::turned_powerup_green_double );
	add_cleansed_powerup( "green_insta", "zombie_skull", &"ZOMBIE_THIS_IS_A_BUG", 0, 0,1, 0, ::turned_powerup_green_insta );
	add_cleansed_powerup( "green_ammo", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", 0, 1, 0, ::turned_powerup_green_ammo );
	add_cleansed_powerup( "green_monkey", level.cymbal_monkey_model, &"ZOMBIE_THIS_IS_A_BUG", 0, 0,4, 0, ::turned_powerup_green_monkey );
	add_cleansed_powerup( "red_nuke", "zombie_bomb", &"ZOMBIE_THIS_IS_A_BUG", 1, 0, 0,4, ::turned_powerup_red_nuke );
	add_cleansed_powerup( "red_ammo", "zombie_ammocan", &"ZOMBIE_THIS_IS_A_BUG", 1, 0, 1, ::turned_powerup_red_ammo );
	add_cleansed_powerup( "red_double", "zombie_x2_icon", &"ZOMBIE_THIS_IS_A_BUG", 1, 0, 1, ::turned_powerup_red_double );
	add_cleansed_powerup( "yellow_double", "zombie_x2_icon", &"ZOMBIE_THIS_IS_A_BUG", 2, 0,1, 0,1, ::turned_powerup_yellow_double );
	add_cleansed_powerup( "yellow_nuke", "zombie_bomb", &"ZOMBIE_THIS_IS_A_BUG", 2, 0,01, 0,01, ::turned_powerup_yellow_nuke );
	level.cleansed_powerup_history_depth = [];
	level.cleansed_powerup_history_depth[ 0 ] = 2;
	level.cleansed_powerup_history_depth[ 1 ] = 1;
	level.cleansed_powerup_history = [];
	level.cleansed_powerup_history[ 0 ] = [];
	level.cleansed_powerup_history[ 1 ] = [];
	level.cleansed_powerup_history_last = [];
	level.cleansed_powerup_history_last[ 0 ] = 0;
	level.cleansed_powerup_history_last[ 1 ] = 0;
	for ( i = 0; i < level.cleansed_powerup_history_depth[0]; i++ )
	{
		level.cleansed_powerup_history[ 0 ][ i ] = "none";
		level.cleansed_powerup_history[ 1 ][ i ] = "none";
	}
}

pick_a_powerup( washuman ) //checked partially changed to match cerberus output see compiler_limitations.md No. 2
{
	total = 0;
	foreach ( powerup in level.cleansed_powerups )
	{
		powerup.recent = 0;
		for ( i = 0; i < level.cleansed_powerup_history_depth[washuman]; i++ )
		{
			if ( level.cleansed_powerup_history[ washuman ][ i ] == powerup.name )
			{
				powerup.recent = 1;
			}
		}
		if ( powerup.recent )
		{
		}
		else if ( washuman )
		{
			total += powerup.hfrequency;
		}
		else
		{
			total += powerup.zfrequency;
		}
	}
	if ( total == 0 )
	{
		return undefined;
	}
	r = randomfloat( total );
	foreach ( powerup in level.cleansed_powerups )
	{
		if ( powerup.recent )
		{
		}
		else
		{
			if ( washuman )
			{
				r -= powerup.hfrequency;
			}
			else
			{
				r -= powerup.zfrequency;
			}
			if ( r <= 0 )
			{
				level.cleansed_powerup_history[ washuman ][ level.cleansed_powerup_history_last[ washuman ] ] = powerup.name;
				level.cleansed_powerup_history_last[ washuman ]++;
				if ( level.cleansed_powerup_history_last[ washuman ] >= level.cleansed_powerup_history_depth[ washuman ] )
				{
					level.cleansed_powerup_history_last[ washuman ] = 0;
				}
				return powerup;
			}
		}
	}
	return undefined;
}

drop_powerup( washuman ) //checked matches cerberus output
{
	powerup = pick_a_powerup( washuman );
	if ( isDefined( powerup ) )
	{
		origin = self.origin;
		wait 0.25;
		maps/mp/zombies/_zm_powerups::specific_powerup_drop( powerup.name, origin );
	}
}

powerup_can_player_grab( player ) //checked changed to match cerberus output used is_true() instead
{
	if ( !cleansed_alive_check( player ) )
	{
		return 0;
	}
	if ( isDefined( level.cleansed_powerups[ self.powerup_name ] ) )
	{
		if ( level.cleansed_powerups[ self.powerup_name ].team == 0 && is_true( player.is_zombie ) )
		{
			return 0;
		}
		if ( level.cleansed_powerups[ self.powerup_name ].team == 1 && !is_true( player.is_zombie ) )
		{
			return 0;
		}
	}
	else if ( self.zombie_grabbable && !is_true( player.is_zombie ) )
	{
		return 0;
	}
	if ( !self.zombie_grabbable && is_true( player.is_zombie ) )
	{
		return 0;
	}
	return 1;
}

player_nuke_fx() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "respawned" );
	self endon( "stop_flame_damage" );
	if ( isDefined( level._effect ) && isDefined( level._effect[ "character_fire_death_torso" ] ) )
	{
		if ( !self.isdog )
		{
			playfxontag( level._effect[ "character_fire_death_torso" ], self, "J_SpineLower" );
		}
	}
	if ( isDefined( level._effect ) && isDefined( level._effect[ "character_fire_death_sm" ] ) )
	{
		wait 1;
		tagarray = [];
		tagarray[ 0 ] = "J_Elbow_LE";
		tagarray[ 1 ] = "J_Elbow_RI";
		tagarray[ 2 ] = "J_Knee_RI";
		tagarray[ 3 ] = "J_Knee_LE";
		tagarray = array_randomize( tagarray );
		playfxontag( level._effect[ "character_fire_death_sm" ], self, tagarray[ 0 ] );
		wait 1;
		tagarray[ 0 ] = "J_Wrist_RI";
		tagarray[ 1 ] = "J_Wrist_LE";
		if ( isDefined( self.a ) || !isDefined( self.a.gib_ref ) && self.a.gib_ref != "no_legs" )
		{
			tagarray[ 2 ] = "J_Ankle_RI";
			tagarray[ 3 ] = "J_Ankle_LE";
		}
		tagarray = array_randomize( tagarray );
		playfxontag( level._effect[ "character_fire_death_sm" ], self, tagarray[ 0 ] );
		playfxontag( level._effect[ "character_fire_death_sm" ], self, tagarray[ 1 ] );
	}
}

player_nuke( player ) //checked matches cerberus output
{
	nuke_time = 2;
	self.isdog = 0;
	self.nuked = 1;
	self.nuker = player;
	self freezecontrolswrapper( 1 );
	maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, nuke_time / 2, nuke_time );
	self thread player_nuke_fx();
	wait nuke_time;
	if ( isDefined( self ) )
	{
		if ( isDefined( player ) )
		{
			self dodamage( self.health + 666, player.origin, player, player, "none", "MOD_EXPLOSIVE", 0, "nuke_zm" );
			return;
		}
		else
		{
			self.nuked = undefined;
			self dodamage( self.health + 666, self.origin, self, self, "none", "MOD_EXPLOSIVE", 0, "nuke_zm" );
		}
	}
}

turned_powerup_green_nuke( player ) //checked does not match cerberus output did not change used is_true() instead
{
	location = self.origin;
	playfx( level.zombie_powerups[ "nuke" ].fx, location );
	level thread maps/mp/zombies/_zm_powerups::nuke_flash();
	players = get_players();
	foreach ( target in players )
	{
		if ( !cleansed_alive_check( target ) )
		{
		}
		else if ( is_true( target.is_zombie ) )
		{
			target thread player_nuke( player );
			break;
		}
	}
}

turned_powerup_green_double( player ) //checked matches cerberus output
{
	level thread maps/mp/zombies/_zm_powerups::double_points_powerup( self, player );
}

turned_powerup_green_insta( player ) //checked matches cerberus output
{
	level thread maps/mp/zombies/_zm_powerups::insta_kill_powerup( self, player );
}

turned_powerup_green_ammo( player ) //checked matches cerberus output
{
	level thread maps/mp/zombies/_zm_powerups::full_ammo_powerup( self, player );
	weapon = player getcurrentweapon();
	player givestartammo( weapon );
}

turned_powerup_green_monkey( player ) //checked matches cerberus output
{
	player maps/mp/zombies/_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
	player setweaponammoclip( "cymbal_monkey_zm", 1 );
	player notify( "powerup_green_monkey" );
}

turned_powerup_red_nuke( player ) //checked partially changed to match cerberus output see compiler_limitations.md No. 2 used is_true() instead
{
	location = self.origin;
	playfx( level.zombie_powerups[ "nuke" ].fx, location );
	level thread maps/mp/zombies/_zm_powerups::nuke_flash();
	players = get_players();
	foreach ( target in players )
	{
		if ( !cleansed_alive_check( target ) )
		{
		}
		else if ( is_true( target.is_zombie ) )
		{
		}
		else
		{
			target thread player_nuke( player );
		}
	}
}

turned_powerup_red_ammo( player ) //checked matches cerberus output
{
	level thread maps/mp/zombies/_zm_powerups::empty_clip_powerup( self );
}

turned_powerup_red_double( player ) //checked matches cerberus output
{
	level thread maps/mp/zombies/_zm_powerups::double_points_powerup( self, player );
}

turned_powerup_yellow_double( player ) //checked matches cerberus output
{
	level thread maps/mp/zombies/_zm_powerups::double_points_powerup( self, player );
}

turned_powerup_yellow_nuke( player ) //checked partially changed to match cerberus output see compiler_limitations.md 
{
	location = self.origin;
	playfx( level.zombie_powerups[ "nuke" ].fx, location );
	level thread maps/mp/zombies/_zm_powerups::nuke_flash();
	players = get_players();
	foreach ( target in players ) 
	{
		if ( !cleansed_alive_check( target ) )
		{
		}
		else
		{
			if ( isDefined( target.team != player.team ) && target.team != player.team )
			{
				target thread player_nuke( player );
			}
		}
	}
}

playturnedmusic() //checked matches cerberus output
{
	ent = spawn( "script_origin", ( 0, 0, 0 ) );
	ent thread stopturnedmusic();
	playsoundatposition( "mus_zmb_gamemode_start", ( 0, 0, 0 ) );
	wait 5;
	ent playloopsound( "mus_zmb_gamemode_loop", 5 );
}

stopturnedmusic() //checked matches cerberus output
{
	level waittill( "end_game" );
	self stoploopsound( 1.5 );
	wait 1;
	self delete();
}
