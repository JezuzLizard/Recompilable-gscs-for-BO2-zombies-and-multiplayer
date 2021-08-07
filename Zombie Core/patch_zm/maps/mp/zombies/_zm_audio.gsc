#include maps/mp/zombies/_zm_spawner;
#include maps/mp/_music;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	registerclientfield( "allplayers", "charindex", 1, 3, "int" );
	registerclientfield( "toplayer", "isspeaking", 1, 1, "int" );
	level.audio_get_mod_type = ::get_mod_type;
	level zmbvox();
	level init_music_states();
	level maps/mp/zombies/_zm_audio_announcer::init();
	onplayerconnect_callback( ::init_audio_functions );
}

setexertvoice( exert_id ) //checked matches cerberus output
{
	self.player_exert_id = exert_id;
	self setclientfield( "charindex", self.player_exert_id );
}

playerexert( exert ) //checked changed to match cerberus output
{
	if ( is_true( self.isspeaking ) || is_true( self.isexerting ) )
	{
		return;
	}
	id = level.exert_sounds[ 0 ][ exert ];
	if ( isDefined( self.player_exert_id ) )
	{
		if ( isarray( level.exert_sounds[ self.player_exert_id ][ exert ] ) )
		{
			id = random( level.exert_sounds[ self.player_exert_id ][ exert ] );
		}
		else
		{
			id = level.exert_sounds[ self.player_exert_id ][ exert ];
		}
	}
	self.isexerting = 1;
	self thread exert_timer();
	self playsound( id );
}

exert_timer() //checked matches cerberus output
{
	self endon( "disconnect" );
	wait randomfloatrange( 1.5, 3 );
	self.isexerting = 0;
}

zmbvox() //checked matches cerberus output
{
	level.votimer = [];
	level.vox = zmbvoxcreate();
	init_standard_response_chances();
	level.vox zmbvoxadd( "player", "general", "crawl_spawn", "crawler_start", "resp_crawler_start" );
	level.vox zmbvoxadd( "player", "general", "hr_resp_crawler_start", "hr_resp_crawler_start", undefined );
	level.vox zmbvoxadd( "player", "general", "riv_resp_crawler_start", "riv_resp_crawler_start", undefined );
	level.vox zmbvoxadd( "player", "general", "ammo_low", "ammo_low", undefined );
	level.vox zmbvoxadd( "player", "general", "ammo_out", "ammo_out", undefined );
	level.vox zmbvoxadd( "player", "general", "door_deny", "nomoney_generic", undefined );
	level.vox zmbvoxadd( "player", "general", "perk_deny", "nomoney_perk", undefined );
	level.vox zmbvoxadd( "player", "general", "shoot_arm", "kill_limb", undefined );
	level.vox zmbvoxadd( "player", "general", "box_move", "box_move", undefined );
	level.vox zmbvoxadd( "player", "general", "no_money", "nomoney", undefined );
	level.vox zmbvoxadd( "player", "general", "oh_shit", "oh_shit", "resp_surrounded" );
	level.vox zmbvoxadd( "player", "general", "hr_resp_surrounded", "hr_resp_surrounded", undefined );
	level.vox zmbvoxadd( "player", "general", "riv_resp_surrounded", "riv_resp_surrounded", undefined );
	level.vox zmbvoxadd( "player", "general", "revive_down", "revive_down", undefined );
	level.vox zmbvoxadd( "player", "general", "revive_up", "revive_up", undefined );
	level.vox zmbvoxadd( "player", "general", "crawl_hit", "crawler_attack", undefined );
	level.vox zmbvoxadd( "player", "general", "sigh", "sigh", undefined );
	level.vox zmbvoxadd( "player", "general", "round_5", "round_5", undefined );
	level.vox zmbvoxadd( "player", "general", "round_20", "round_20", undefined );
	level.vox zmbvoxadd( "player", "general", "round_10", "round_10", undefined );
	level.vox zmbvoxadd( "player", "general", "round_35", "round_35", undefined );
	level.vox zmbvoxadd( "player", "general", "round_50", "round_50", undefined );
	level.vox zmbvoxadd( "player", "perk", "specialty_armorvest", "perk_jugga", undefined );
	level.vox zmbvoxadd( "player", "perk", "specialty_quickrevive", "perk_revive", undefined );
	level.vox zmbvoxadd( "player", "perk", "specialty_fastreload", "perk_speed", undefined );
	level.vox zmbvoxadd( "player", "perk", "specialty_rof", "perk_doubletap", undefined );
	level.vox zmbvoxadd( "player", "perk", "specialty_longersprint", "perk_stamine", undefined );
	level.vox zmbvoxadd( "player", "perk", "specialty_flakjacket", "perk_phdflopper", undefined );
	level.vox zmbvoxadd( "player", "perk", "specialty_deadshot", "perk_deadshot", undefined );
	level.vox zmbvoxadd( "player", "perk", "specialty_finalstand", "perk_who", undefined );
	level.vox zmbvoxadd( "player", "perk", "specialty_additionalprimaryweapon", "perk_mulekick", undefined );
	level.vox zmbvoxadd( "player", "powerup", "nuke", "powerup_nuke", undefined );
	level.vox zmbvoxadd( "player", "powerup", "insta_kill", "powerup_insta", undefined );
	level.vox zmbvoxadd( "player", "powerup", "full_ammo", "powerup_ammo", undefined );
	level.vox zmbvoxadd( "player", "powerup", "double_points", "powerup_double", undefined );
	level.vox zmbvoxadd( "player", "powerup", "carpenter", "powerup_carp", undefined );
	level.vox zmbvoxadd( "player", "powerup", "firesale", "powerup_firesale", undefined );
	level.vox zmbvoxadd( "player", "powerup", "minigun", "powerup_minigun", undefined );
	level.vox zmbvoxadd( "player", "kill", "melee", "kill_melee", undefined );
	level.vox zmbvoxadd( "player", "kill", "melee_instakill", "kill_insta", undefined );
	level.vox zmbvoxadd( "player", "kill", "weapon_instakill", "kill_insta", undefined );
	level.vox zmbvoxadd( "player", "kill", "closekill", "kill_close", undefined );
	level.vox zmbvoxadd( "player", "kill", "damage", "kill_damaged", undefined );
	level.vox zmbvoxadd( "player", "kill", "streak", "kill_streak", undefined );
	level.vox zmbvoxadd( "player", "kill", "headshot", "kill_headshot", "resp_kill_headshot" );
	level.vox zmbvoxadd( "player", "kill", "hr_resp_kill_headshot", "hr_resp_kill_headshot", undefined );
	level.vox zmbvoxadd( "player", "kill", "riv_resp_kill_headshot", "riv_resp_kill_headshot", undefined );
	level.vox zmbvoxadd( "player", "kill", "explosive", "kill_explo", undefined );
	level.vox zmbvoxadd( "player", "kill", "flame", "kill_flame", undefined );
	level.vox zmbvoxadd( "player", "kill", "raygun", "kill_ray", undefined );
	level.vox zmbvoxadd( "player", "kill", "bullet", "kill_streak", undefined );
	level.vox zmbvoxadd( "player", "kill", "tesla", "kill_tesla", undefined );
	level.vox zmbvoxadd( "player", "kill", "monkey", "kill_monkey", undefined );
	level.vox zmbvoxadd( "player", "kill", "thundergun", "kill_thunder", undefined );
	level.vox zmbvoxadd( "player", "kill", "freeze", "kill_freeze", undefined );
	level.vox zmbvoxadd( "player", "kill", "crawler", "crawler_kill", undefined );
	level.vox zmbvoxadd( "player", "kill", "hellhound", "kill_hellhound", undefined );
	level.vox zmbvoxadd( "player", "kill", "quad", "kill_quad", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "pistol", "wpck_crappy", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "smg", "wpck_smg", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "dualwield", "wpck_dual", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "shotgun", "wpck_shotgun", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "rifle", "wpck_sniper", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "burstrifle", "wpck_mg", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "assault", "wpck_mg", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "sniper", "wpck_sniper", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "mg", "wpck_mg", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "launcher", "wpck_launcher", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "grenade", "wpck_grenade", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "bowie", "wpck_bowie", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "raygun", "wpck_raygun", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "monkey", "wpck_monkey", "resp_wpck_monkey" );
	level.vox zmbvoxadd( "player", "weapon_pickup", "hr_resp_wpck_monkey", "hr_resp_wpck_monkey", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "riv_resp_wpck_monkey", "riv_resp_wpck_monkey", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "crossbow", "wpck_launcher", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "upgrade", "wpck_upgrade", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "favorite", "wpck_favorite", undefined );
	level.vox zmbvoxadd( "player", "weapon_pickup", "favorite_upgrade", "wpck_favorite_upgrade", undefined );
	level.vox zmbvoxadd( "player", "player_death", "player_death", "evt_player_final_hit", undefined );
	level.zmb_vox = [];
	level.zmb_vox[ "prefix" ] = "zmb_vocals_";
	level.zmb_vox[ "zombie" ] = [];
	level.zmb_vox[ "zombie" ][ "ambient" ] = "zombie_ambience";
	level.zmb_vox[ "zombie" ][ "sprint" ] = "zombie_sprint";
	level.zmb_vox[ "zombie" ][ "attack" ] = "zombie_attack";
	level.zmb_vox[ "zombie" ][ "teardown" ] = "zombie_teardown";
	level.zmb_vox[ "zombie" ][ "taunt" ] = "zombie_taunt";
	level.zmb_vox[ "zombie" ][ "behind" ] = "zombie_behind";
	level.zmb_vox[ "zombie" ][ "death" ] = "zombie_death";
	level.zmb_vox[ "zombie" ][ "crawler" ] = "zombie_crawler";
	level.zmb_vox[ "zombie" ][ "electrocute" ] = "zombie_electrocute";
	level.zmb_vox[ "quad_zombie" ] = [];
	level.zmb_vox[ "quad_zombie" ][ "ambient" ] = "quad_ambience";
	level.zmb_vox[ "quad_zombie" ][ "sprint" ] = "quad_sprint";
	level.zmb_vox[ "quad_zombie" ][ "attack" ] = "quad_attack";
	level.zmb_vox[ "quad_zombie" ][ "behind" ] = "quad_behind";
	level.zmb_vox[ "quad_zombie" ][ "death" ] = "quad_death";
	level.zmb_vox[ "thief_zombie" ] = [];
	level.zmb_vox[ "thief_zombie" ][ "ambient" ] = "thief_ambience";
	level.zmb_vox[ "thief_zombie" ][ "sprint" ] = "thief_sprint";
	level.zmb_vox[ "thief_zombie" ][ "steal" ] = "thief_steal";
	level.zmb_vox[ "thief_zombie" ][ "death" ] = "thief_death";
	level.zmb_vox[ "thief_zombie" ][ "anger" ] = "thief_anger";
	level.zmb_vox[ "boss_zombie" ] = [];
	level.zmb_vox[ "boss_zombie" ][ "ambient" ] = "boss_ambience";
	level.zmb_vox[ "boss_zombie" ][ "sprint" ] = "boss_sprint";
	level.zmb_vox[ "boss_zombie" ][ "attack" ] = "boss_attack";
	level.zmb_vox[ "boss_zombie" ][ "behind" ] = "boss_behind";
	level.zmb_vox[ "boss_zombie" ][ "death" ] = "boss_death";
	level.zmb_vox[ "leaper_zombie" ] = [];
	level.zmb_vox[ "leaper_zombie" ][ "ambient" ] = "leaper_ambience";
	level.zmb_vox[ "leaper_zombie" ][ "sprint" ] = "leaper_ambience";
	level.zmb_vox[ "leaper_zombie" ][ "attack" ] = "leaper_attack";
	level.zmb_vox[ "leaper_zombie" ][ "behind" ] = "leaper_close";
	level.zmb_vox[ "leaper_zombie" ][ "death" ] = "leaper_death";
	level.zmb_vox[ "monkey_zombie" ] = [];
	level.zmb_vox[ "monkey_zombie" ][ "ambient" ] = "monkey_ambience";
	level.zmb_vox[ "monkey_zombie" ][ "sprint" ] = "monkey_sprint";
	level.zmb_vox[ "monkey_zombie" ][ "attack" ] = "monkey_attack";
	level.zmb_vox[ "monkey_zombie" ][ "behind" ] = "monkey_behind";
	level.zmb_vox[ "monkey_zombie" ][ "death" ] = "monkey_death";
	level.zmb_vox[ "capzomb" ] = [];
	level.zmb_vox[ "capzomb" ][ "ambient" ] = "capzomb_ambience";
	level.zmb_vox[ "capzomb" ][ "sprint" ] = "capzomb_sprint";
	level.zmb_vox[ "capzomb" ][ "attack" ] = "capzomb_attack";
	level.zmb_vox[ "capzomb" ][ "teardown" ] = "capzomb_ambience";
	level.zmb_vox[ "capzomb" ][ "taunt" ] = "capzomb_ambience";
	level.zmb_vox[ "capzomb" ][ "behind" ] = "capzomb_behind";
	level.zmb_vox[ "capzomb" ][ "death" ] = "capzomb_death";
	level.zmb_vox[ "capzomb" ][ "crawler" ] = "capzomb_crawler";
	level.zmb_vox[ "capzomb" ][ "electrocute" ] = "zombie_electrocute";
	if ( isDefined( level._zmbvoxlevelspecific ) )
	{
		level thread [[ level._zmbvoxlevelspecific ]]();
	}
	if ( isDefined( level._zmbvoxgametypespecific ) )
	{
		level thread [[ level._zmbvoxgametypespecific ]]();
	}
	announcer_ent = spawn( "script_origin", ( 0, 0, 0 ) );
	level.vox zmbvoxinitspeaker( "announcer", "vox_zmba_", announcer_ent );
	level.exert_sounds[ 0 ][ "burp" ] = "evt_belch";
	level.exert_sounds[ 0 ][ "hitmed" ] = "null";
	level.exert_sounds[ 0 ][ "hitlrg" ] = "null";
	if ( isDefined( level.setupcustomcharacterexerts ) )
	{
		[[ level.setupcustomcharacterexerts ]]();
	}
}

init_standard_response_chances() //checked matches cerberus output
{
	level.response_chances = [];
	add_vox_response_chance( "sickle", 40 );
	add_vox_response_chance( "melee", 40 );
	add_vox_response_chance( "melee_instakill", 99 );
	add_vox_response_chance( "weapon_instakill", 10 );
	add_vox_response_chance( "explosive", 60 );
	add_vox_response_chance( "monkey", 60 );
	add_vox_response_chance( "flame", 60 );
	add_vox_response_chance( "raygun", 75 );
	add_vox_response_chance( "headshot", 15 );
	add_vox_response_chance( "crawler", 30 );
	add_vox_response_chance( "quad", 30 );
	add_vox_response_chance( "astro", 99 );
	add_vox_response_chance( "closekill", 15 );
	add_vox_response_chance( "bullet", 1 );
	add_vox_response_chance( "claymore", 99 );
	add_vox_response_chance( "dolls", 99 );
	add_vox_response_chance( "default", 1 );
}

init_audio_functions() //checked matches cerberus output
{
	self thread zombie_behind_vox();
	self thread player_killstreak_timer();
	if ( isDefined( level._custom_zombie_oh_shit_vox_func ) )
	{
		self thread [[ level._custom_zombie_oh_shit_vox_func ]]();
	}
	else
	{
		self thread oh_shit_vox();
	}
}

zombie_behind_vox() //checked changed to match cerberus output one change made at one discretion
{
	self endon( "death_or_disconnect" );
	if ( !isDefined( level._zbv_vox_last_update_time ) )
	{
		level._zbv_vox_last_update_time = 0;
		level._audio_zbv_shared_ent_list = get_round_enemy_array();
	}
	while ( 1 )
	{
		wait 1;
		t = getTime();
		if ( t > ( level._zbv_vox_last_update_time + 1000 ) )
		{
			level._zbv_vox_last_update_time = t;
			level._audio_zbv_shared_ent_list = get_round_enemy_array();
		}
		zombs = level._audio_zbv_shared_ent_list;
		played_sound = 0;
		for ( i = 0; i < zombs.size; i++ )
		{
			if ( !isdefined( zombs[ i ] ) )
			{
				continue;
			}
			if ( zombs[ i ].isdog )
			{
				continue;
			}
			dist = 200;
			z_dist = 50;
			alias = level.vox_behind_zombie;
			if ( isdefined( zombs[ i ].zombie_move_speed ) )
			{
				switch ( zombs[ i ].zombie_move_speed )
				{
					case "walk":
						dist = 200;
						break;
					case "run":
						dist = 250;
						break;
					case "sprint":
						dist = 275;
						break;
				}
			}
			if ( distancesquared( zombs[ i ].origin, self.origin ) < dist * dist )
			{
				yaw = self maps/mp/zombies/_zm_utility::getyawtospot( zombs[ i ].origin );
				z_diff = self.origin[ 2 ] - zombs[ i ].origin[ 2 ];
				//if ( yaw < -95 || yaw > 95 && Abs( z_diff ) < 50 ) //original
				if ( ( yaw < -95 || yaw > 95 ) && Abs( z_diff ) < 50 ) 
				{
					zombs[ i ] thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "behind", zombs[ i ].animname );
					played_sound = 1;
					break;
				}
			}
		}
		if ( played_sound )
		{
			wait 5;
		}
	}
}

attack_vox_network_choke() //checked matches cerberus output
{
	while ( 1 )
	{
		level._num_attack_vox = 0;
		wait_network_frame();
	}
}

do_zombies_playvocals( alias_type, zombie_type ) //checked changed to match cerberus output
{
	self endon( "death" );
	if ( !isDefined( zombie_type ) )
	{
		zombie_type = "zombie";
	}
	if ( is_true( self.shrinked ) )
	{
		return;
	}
	if ( is_true( self.is_inert ) )
	{
		return;
	}
	if ( !isDefined( self.talking ) )
	{
		self.talking = 0;
	}
	if ( isDefined( level.script ) && level.script == "zm_tomb" )
	{
		if ( isDefined( self.script_int ) && self.script_int >= 2 )
		{
			zombie_type = "capzomb";
			self.zmb_vocals_attack = "zmb_vocals_capzomb_attack";
		}
		else if ( isDefined( self.sndname ) )
		{
			zombie_type = self.sndname;
		}
	}
	if ( !isDefined( level.zmb_vox[ zombie_type ] ) )
	{
		return;
	}
	if ( !isDefined( level.zmb_vox[ zombie_type ][ alias_type ] ) )
	{
		return;
	}
	switch( alias_type )
	{
		case "ambient":
		case "attack":
		case "behind":
		case "crawler":
		case "death":
		case "electrocute":
		case "sprint":
		case "teardown":
			if ( !sndisnetworksafe() )
			{
				return;
			}
			break;
	}
	alias = level.zmb_vox[ "prefix" ] + level.zmb_vox[ zombie_type ][ alias_type ];
	if ( alias_type != "attack" && alias_type != "behind" && alias_type != "death" && alias_type != "anger" && alias_type != "steal" || alias_type == "taunt" && alias_type == "teardown" )
	{
		if ( isDefined( level._custom_zombie_audio_func ) )
		{
			self [[ level._custom_zombie_audio_func ]]( alias, alias_type );
		}
		else
		{
			self playsound( alias );
		}
	}
	else if ( !self.talking )
	{
		self.talking = 1;
		if ( self is_last_zombie() )
		{
			alias += "_loud";
		}
		self playsoundwithnotify( alias, "sounddone" );
		self waittill( "sounddone" );
		self.talking = 0;
	}
}

sndisnetworksafe() //checked matches cerberus output
{
	if ( !isDefined( level._num_attack_vox ) )
	{
		level thread attack_vox_network_choke();
	}
	if ( level._num_attack_vox > 4 )
	{
		return 0;
	}
	level._num_attack_vox++;
	return 1;
}

is_last_zombie() //checked matches cerberus output
{
	if ( get_current_zombie_count() <= 1 )
	{
		return 1;
	}
	return 0;
}

oh_shit_vox() //checked changed to match cerberus output
{
	self endon( "death_or_disconnect" );
	while ( 1 )
	{
		wait 1;
		players = get_players();
		zombs = get_round_enemy_array();
		if ( players.size > 1 )
		{
			close_zombs = 0;
			for ( i = 0; i < zombs.size; i++ )
			{
				if ( isDefined( zombs[ i ].favoriteenemy ) || zombs[ i ].favoriteenemy == self && !isDefined( zombs[ i ].favoriteenemy ) )
				{
					if ( distancesquared( zombs[ i ].origin, self.origin ) < 62500 )
					{
						close_zombs++;
					}
				}
			}
			if ( close_zombs > 4 )
			{
				if ( randomint( 100 ) > 75 && !is_true( self.isonbus ) )
				{
					self create_and_play_dialog( "general", "oh_shit" );
					wait 4;
				}
			}
		}
	}
}

create_and_play_dialog( category, type, response, force_variant, override ) //checked changed to match cerberus output
{
	waittime = 0.25;
	if ( !isDefined( self.zmbvoxid ) )
	{
		return;
	}
	if ( is_true( self.dontspeak ) )
	{
		return;
	}
	isresponse = 0;
	alias_suffix = undefined;
	index = undefined;
	prefix = undefined;
	if ( !isDefined( level.vox.speaker[ self.zmbvoxid ].alias[ category ][ type ] ) )
	{
		return;
	}
	prefix = level.vox.speaker[ self.zmbvoxid ].prefix;
	alias_suffix = level.vox.speaker[ self.zmbvoxid ].alias[ category ][ type ];
	if ( self is_player() )
	{
		if ( self.sessionstate != "playing" )
		{
			return;
		}
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() && type != "revive_down" || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() && type != "revive_up" )
		{
			return;
		}
		index = maps/mp/zombies/_zm_weapons::get_player_index( self );
		prefix = prefix + index + "_";
	}
	if ( isDefined( response ) )
	{
		if ( isDefined( level.vox.speaker[ self.zmbvoxid ].response[ category ][ type ] ) )
		{
			alias_suffix = response + level.vox.speaker[ self.zmbvoxid ].response[ category ][ type ];
		}
		isresponse = 1;
	}
	sound_to_play = self zmbvoxgetlinevariant( prefix, alias_suffix, force_variant, override );
	if ( isDefined( sound_to_play ) )
	{
		if ( isDefined( level._audio_custom_player_playvox ) )
		{
			self thread [[ level._audio_custom_player_playvox ]]( prefix, index, sound_to_play, waittime, category, type, override );
		}
		else
		{
			self thread do_player_or_npc_playvox( prefix, index, sound_to_play, waittime, category, type, override, isresponse );
		}
	}
}

do_player_or_npc_playvox( prefix, index, sound_to_play, waittime, category, type, override, isresponse ) //checked partially changed to match cerberus output
{
	self endon( "death_or_disconnect" );
	if ( is_true( level.skit_vox_override ) && !is_true( override ) )
	{
		return;
	}
	if ( !isDefined( self.isspeaking ) )
	{
		self.isspeaking = 0;
	}
	if ( is_true( self.isspeaking ) )
	{
		return;
	}
	if ( !self arenearbyspeakersactive() || is_true( self.ignorenearbyspkrs ) )
	{
		self.speakingline = sound_to_play;
		self.isspeaking = 1;
		if ( isplayer( self ) )
		{
			self setclientfieldtoplayer( "isspeaking", 1 );
		}
		self notify( "speaking" );
		playbacktime = soundgetplaybacktime( prefix + sound_to_play );
		if ( !isDefined( playbacktime ) )
		{
			return;
		}
		if ( playbacktime >= 0 )
		{
			playbacktime *= 0.001;
		}
		else
		{
			playbacktime = 1;
		}
		self playsoundontag( prefix + sound_to_play, "J_Head" );
		wait playbacktime;
		if ( isplayer( self ) && !is_true( isresponse ) && isDefined( self.last_vo_played_time ) )
		{
			if ( getTime() < ( self.last_vo_played_time + 5000 ) )
			{
				waittime = 15;
			}
		}
		wait waittime;
		self notify( "done_speaking" );
		self.isspeaking = 0;
		if ( isplayer( self ) )
		{
			self setclientfieldtoplayer( "isspeaking", 0 );
		}
		if ( isplayer( self ) )
		{
			self.last_vo_played_time = getTime();
		}
		if ( is_true( isresponse ) )
		{
			return;
		}
		if ( isDefined( level.vox.speaker[ self.zmbvoxid ].response ) && isDefined( level.vox.speaker[ self.zmbvoxid ].response[ category ] ) && isDefined( level.vox.speaker[ self.zmbvoxid ].response[ category ][ type ] ) )
		{
			if ( isDefined( self.isnpc ) && self.isnpc || !flag( "solo_game" ) )
			{
				if ( isDefined( level._audio_custom_response_line ) )
				{
					level thread [[ level._audio_custom_response_line ]]( self, index, category, type );
				}
				else
				{
					level thread setup_response_line( self, index, category, type );
				}
			}
		}
	}
	else
	{
	}
}

setup_response_line( player, index, category, type ) //checked matches cerberus output
{
	dempsey = 0;
	nikolai = 1;
	takeo = 2;
	richtofen = 3;
	switch( player.entity_num )
	{
		case 0:
			level setup_hero_rival( player, nikolai, richtofen, category, type );
			break;
		case 1:
			level setup_hero_rival( player, richtofen, takeo, category, type );
			break;
		case 2:
			level setup_hero_rival( player, dempsey, nikolai, category, type );
			break;
		case 3:
			level setup_hero_rival( player, takeo, dempsey, category, type );
			break;
	}
	return;
}

setup_hero_rival( player, hero, rival, category, type ) //checked changed to match cerberus output
{
	players = get_players();
	hero_player = undefined;
	rival_player = undefined;
	foreach ( ent in players )
	{
		if ( ent.characterindex == hero )
		{
			hero_player = ent;
			continue;
		}
		if ( ent.characterindex == rival )
		{
			rival_player = ent;
		}
	}
	if ( isDefined( hero_player ) && isDefined( rival_player ) )
	{
		if ( randomint( 100 ) > 50 )
		{
			hero_player = undefined;
		}
		else
		{
			rival_player = undefined;
		}
	}
	if ( isDefined( hero_player ) && distancesquared( player.origin, hero_player.origin ) < 250000 )
	{
		hero_player create_and_play_dialog( category, type, "hr_" );
	}
	else if ( isDefined( rival_player ) && distancesquared( player.origin, rival_player.origin ) < 250000 )
	{
		rival_player create_and_play_dialog( category, type, "riv_" );
	}
}

do_announcer_playvox( category, type, team ) //checked matches cerberus output
{
	if ( !isDefined( level.vox.speaker[ "announcer" ].alias[ category ] ) || !isDefined( level.vox.speaker[ "announcer" ].alias[ category ][ type ] ) )
	{
		return;
	}
	if ( !isDefined( level.devil_is_speaking ) )
	{
		level.devil_is_speaking = 0;
	}
	prefix = level.vox.speaker[ "announcer" ].prefix;
	suffix = level.vox.speaker[ "announcer" ].ent zmbvoxgetlinevariant( prefix, level.vox.speaker[ "announcer" ].alias[ category ][ type ] );
	if ( !isDefined( suffix ) )
	{
		return;
	}
	alias = prefix + suffix;
	if ( level.devil_is_speaking == 0 )
	{
		level.devil_is_speaking = 1;
		if ( !isDefined( team ) )
		{
			level.vox.speaker[ "announcer" ].ent playsoundwithnotify( alias, "sounddone" );
		}
		else
		{
			level thread zmbvoxannouncertoteam( category, type, team );
		}
		level.vox.speaker[ "announcer" ].ent waittill( "sounddone" );
		level.devil_is_speaking = 0;
	}
}

zmbvoxannouncertoteam( category, type, team ) //checked changed to match cerberus output
{
	prefix = level.vox.speaker[ "announcer" ].prefix;
	alias_to_team = prefix + level.vox.speaker[ "announcer" ].ent zmbvoxgetlinevariant( prefix, level.vox.speaker[ "announcer" ].alias[ category ][ type ] );
	if ( isDefined( level.vox.speaker[ "announcer" ].response[ category ][ type ] ) )
	{
		alias_to_rival = prefix + level.vox.speaker[ "announcer" ].ent zmbvoxgetlinevariant( prefix, level.vox.speaker[ "announcer" ].response[ category ][ type ] );
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( !isdefined( players[ i ]._encounters_team ) )
		{
			continue;
		}
		if ( players[ i ]._encounters_team == team )
		{
			level.vox.speaker[ "announcer" ].ent playsoundtoplayer( alias_to_team, players[ i ] );
			continue;
		}
		if(isdefined(alias_to_rival))
		{
			level.vox.speaker[ "announcer" ].ent playsoundtoplayer( alias_to_rival, players[ i ] );
		}
	}
	wait 3;
	level.vox.speaker[ "announcer" ].ent notify( "sounddone" );
}

player_killstreak_timer() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "death" );
	if ( getDvar( "zombie_kills" ) == "" )
	{
		setdvar( "zombie_kills", "7" );
	}
	if ( getDvar( "zombie_kill_timer" ) == "" )
	{
		setdvar( "zombie_kill_timer", "5" );
	}
	kills = getDvarInt( "zombie_kills" );
	time = getDvarInt( "zombie_kill_timer" );
	if ( !isDefined( self.timerisrunning ) )
	{
		self.timerisrunning = 0;
		self.killcounter = 0;
	}
	while ( 1 )
	{
		self waittill( "zom_kill", zomb );
		if ( isDefined( zomb._black_hole_bomb_collapse_death ) && zomb._black_hole_bomb_collapse_death == 1 )
		{
			continue;
		}
		if ( is_true( zomb.microwavegun_death ) )
		{
			continue;
		}
		self.killcounter++;
		if ( self.timerisrunning != 1 )
		{
			self.timerisrunning = 1;
			self thread timer_actual( kills, time );
		}
	}
}

player_zombie_kill_vox( hit_location, player, mod, zombie ) //checked does not match cerberus output did not change
{
	weapon = player getcurrentweapon();
	dist = distancesquared( player.origin, zombie.origin );
	if ( !isDefined( level.zombie_vars[ player.team ][ "zombie_insta_kill" ] ) )
	{
		level.zombie_vars[ player.team ][ "zombie_insta_kill" ] = 0;
	}
	instakill = level.zombie_vars[ player.team ][ "zombie_insta_kill" ];
	death = [[ level.audio_get_mod_type ]]( hit_location, mod, weapon, zombie, instakill, dist, player );
	chance = get_response_chance( death );
	if ( chance > randomintrange( 1, 100 ) && !is_true( player.force_wait_on_kill_line ) )
	{
		player.force_wait_on_kill_line = 1;
		player create_and_play_dialog( "kill", death );
		wait 2;
		if ( isDefined( player ) )
		{
			player.force_wait_on_kill_line = 0;
		}
	}
}

get_response_chance( event ) //checked matches cerberus output
{
	if ( !isDefined( level.response_chances[ event ] ) )
	{
		return 0;
	}
	return level.response_chances[ event ];
}

get_mod_type( impact, mod, weapon, zombie, instakill, dist, player ) //checked does not match cerberus output did not change
{
	close_dist = 4096;
	med_dist = 15376;
	far_dist = 160000;
	if ( isDefined( zombie._black_hole_bomb_collapse_death ) && zombie._black_hole_bomb_collapse_death == 1 )
	{
		return "default";
	}
	if ( zombie.animname == "screecher_zombie" && mod == "MOD_MELEE" )
	{
		return "killed_screecher";
	}
	if ( is_placeable_mine( weapon ) )
	{
		if ( !instakill )
		{
			return "claymore";
		}
		else
		{
			return "weapon_instakill";
		}
	}
	if ( weapon == "jetgun_zm" || weapon == "jetgun_upgraded_zm" )
	{
		if ( instakill )
		{
			return "weapon_instakill";
		}
		else
		{
			return "jetgun_kill";
		}
	}
	if ( weapon == "slipgun_zm" || weapon == "slipgun_upgraded_zm" )
	{
		if ( instakill )
		{
			return "weapon_instakill";
		}
		else
		{
			return "slipgun_kill";
		}
	}
	if ( isDefined( zombie.damageweapon ) && zombie.damageweapon == "cymbal_monkey_zm" )
	{
		if ( instakill )
		{
			return "weapon_instakill";
		}
		else
		{
			return "monkey";
		}
	}
	if ( is_headshot( weapon, impact, mod ) && dist >= far_dist )
	{
		return "headshot";
	}
	if ( mod != "MOD_MELEE" && mod != "MOD_BAYONET" && mod == "MOD_UNKNOWN" && dist < close_dist )
	{
		if ( !instakill )
		{
			if ( player hasweapon( "sickle_knife_zm" ) )
			{
				return "sickle";
			}
			else
			{
				return "melee";
			}
		}
		else
		{
			return "melee_instakill";
		}
	}
	if ( isDefined( zombie.damageweapon ) && zombie.damageweapon == "zombie_nesting_doll_single" )
	{
		if ( !instakill )
		{
			return "dolls";
		}
		else
		{
			return "weapon_instakill";
		}
	}
	if ( is_explosive_damage( mod ) && weapon != "ray_gun_zm" && !is_true( zombie.is_on_fire ) )
	{
		if ( !instakill )
		{
			return "explosive";
		}
		else
		{
			return "weapon_instakill";
		}
	}
	if ( !issubstr( weapon, "flame" ) && !issubstr( weapon, "molotov_" ) && issubstr( weapon, "napalmblob_" ) && mod != "MOD_BURNED" || mod == "MOD_GRENADE" && mod == "MOD_GRENADE_SPLASH" )
	{
		if ( !instakill )
		{
			return "flame";
		}
		else
		{
			return "weapon_instakill";
		}
	}
	if ( weapon == "ray_gun_zm" && dist > far_dist )
	{
		if ( !instakill )
		{
			return "raygun";
		}
		else
		{
			return "weapon_instakill";
		}
	}
	if ( !isDefined( impact ) )
	{
		impact = "";
	}
	if ( mod == "MOD_RIFLE_BULLET" || mod == "MOD_PISTOL_BULLET" )
	{
		if ( !instakill )
		{
			return "bullet";
		}
		else
		{
			return "weapon_instakill";
		}
	}
	if ( instakill )
	{
		return "default";
	}
	if ( mod != "MOD_MELEE" && zombie.animname == "quad_zombie" )
	{
		return "quad";
	}
	if ( mod != "MOD_MELEE" && zombie.animname == "astro_zombie" )
	{
		return "astro";
	}
	if ( mod != "MOD_MELEE" && !zombie.has_legs )
	{
		return "crawler";
	}
	if ( mod != "MOD_BURNED" && dist < close_dist )
	{
		return "closekill";
	}
	return "default";
}

timer_actual( kills, time ) //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "death" );
	timer = getTime() + ( time * 1000 );
	while ( getTime() < timer )
	{
		if ( self.killcounter > kills )
		{
			self create_and_play_dialog( "kill", "streak" );
			wait 1;
			self.killcounter = 0;
			timer = -1;
		}
		wait 0.1;
	}
	wait 10;
	self.killcounter = 0;
	self.timerisrunning = 0;
}

perks_a_cola_jingle_timer() //checked matches cerberus output
{
	if ( isDefined( level.sndperksacolaloopoverride ) )
	{
		self thread [[ level.sndperksacolaloopoverride ]]();
		return;
	}
	self endon( "death" );
	self thread play_random_broken_sounds();
	while ( 1 )
	{
		wait randomfloatrange( 31, 45 );
		if ( randomint( 100 ) < 15 )
		{
			self thread play_jingle_or_stinger( self.script_sound );
		}
	}
}

play_jingle_or_stinger( perksacola ) //checked matches cerberus output
{
	if ( isDefined( level.sndperksacolajingleoverride ) )
	{
		self thread [[ level.sndperksacolajingleoverride ]]();
		return;
	}
	playsoundatposition( "evt_electrical_surge", self.origin );
	if ( !isDefined( self.jingle_is_playing ) )
	{
		self.jingle_is_playing = 0;
	}
	if ( isDefined( perksacola ) )
	{
		if ( self.jingle_is_playing == 0 && level.music_override == 0 )
		{
			self.jingle_is_playing = 1;
			self playsoundontag( perksacola, "tag_origin", "sound_done" );
			if ( issubstr( perksacola, "sting" ) )
			{
				wait 10;
			}
			else if ( isDefined( self.longjinglewait ) )
			{
				wait 60;
			}
			else
			{
				wait 30;
			}
			self.jingle_is_playing = 0;
		}
	}
}

play_random_broken_sounds() //checked matches cerberus output
{
	self endon( "death" );
	level endon( "jingle_playing" );
	if ( !isDefined( self.script_sound ) )
	{
		self.script_sound = "null";
	}
	if ( self.script_sound == "mus_perks_revive_jingle" )
	{
		while ( 1 )
		{
			wait randomfloatrange( 7, 18 );
			playsoundatposition( "zmb_perks_broken_jingle", self.origin );
			playsoundatposition( "evt_electrical_surge", self.origin );
		}
	}
	else while ( 1 )
	{
		wait randomfloatrange( 7, 18 );
		playsoundatposition( "evt_electrical_surge", self.origin );
	}
}

perk_vox( perk ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( !isDefined( level.vox.speaker[ "player" ].alias[ "perk" ][ perk ] ) )
	{
		return;
	}
	self create_and_play_dialog( "perk", perk );
}

dialog_debugger( category, type ) //checked dev call deleted
{
}

init_music_states() //checked matches cerberus output
{
	level.music_override = 0;
	level.music_round_override = 0;
	level.old_music_state = undefined;
	level.zmb_music_states = [];
	level thread setupmusicstate( "round_start", "mus_zombie_round_start", 1, 1, 1, "WAVE" );
	level thread setupmusicstate( "round_end", "mus_zombie_round_over", 1, 1, 1, "SILENCE" );
	level thread setupmusicstate( "wave_loop", "WAVE", 0, 1, undefined, undefined );
	level thread setupmusicstate( "game_over", "mus_zombie_game_over", 1, 0, undefined, "SILENCE" );
	level thread setupmusicstate( "dog_start", "mus_zombie_dog_start", 1, 1, undefined, undefined );
	level thread setupmusicstate( "dog_end", "mus_zombie_dog_end", 1, 1, undefined, undefined );
	level thread setupmusicstate( "egg", "EGG", 0, 0, undefined, undefined );
	level thread setupmusicstate( "egg_safe", "EGG_SAFE", 0, 0, undefined, undefined );
	level thread setupmusicstate( "egg_a7x", "EGG_A7X", 0, 0, undefined, undefined );
	level thread setupmusicstate( "sam_reveal", "SAM", 0, 0, undefined, undefined );
	level thread setupmusicstate( "brutus_round_start", "mus_event_brutus_round_start", 1, 1, 0, "WAVE" );
	level thread setupmusicstate( "last_life", "LAST_LIFE", 0, 1, undefined, undefined );
}

setupmusicstate( state, alias, is_alias, override, round_override, musicstate ) //checked matches cerberus output
{
	if ( !isDefined( level.zmb_music_states[ state ] ) )
	{
		level.zmb_music_states[ state ] = spawnstruct();
	}
	level.zmb_music_states[ state ].music = alias;
	level.zmb_music_states[ state ].is_alias = is_alias;
	level.zmb_music_states[ state ].override = override;
	level.zmb_music_states[ state ].round_override = round_override;
	level.zmb_music_states[ state ].musicstate = musicstate;
}

change_zombie_music( state ) //checked changed to match cerberus output
{
	wait 0.05;
	m = level.zmb_music_states[ state ];
	if ( !isDefined( m ) )
	{
		return;
	}
	do_logic = 1;
	if ( !isDefined( level.old_music_state ) )
	{
		do_logic = 0;
	}
	if ( do_logic )
	{
		if ( level.old_music_state == m )
		{
			return;
		}
		else if ( level.old_music_state.music == "mus_zombie_game_over" )
		{
			return;
		}
	}
	if ( !isDefined( m.round_override ) )
	{
		m.round_override = 0;
	}
	if ( m.override == 1 && level.music_override == 1 )
	{
		return;
	}
	if ( m.round_override == 1 && level.music_round_override == 1 )
	{
		return;
	}
	if ( m.is_alias )
	{
		if ( isDefined( m.musicstate ) )
		{
			maps/mp/_music::setmusicstate( m.musicstate );
		}
		play_sound_2d( m.music );
	}
	else
	{
		maps/mp/_music::setmusicstate( m.music );
	}
	level.old_music_state = m;
}

weapon_toggle_vox( alias, weapon ) //checked changed to match cerberus output
{
	self notify( "audio_activated_trigger" );
	self endon( "audio_activated_trigger" );
	prefix = "vox_pa_switcher_";
	sound_to_play = prefix + alias;
	type = undefined;
	if ( isDefined( weapon ) )
	{
		type = get_weapon_num( weapon );
		if ( !isDefined( type ) )
		{
			return;
		}
	}
	self stopsounds();
	wait 0.05;
	if ( isDefined( type ) )
	{
		self playsoundwithnotify( prefix + "weapon_" + type, "sounddone" );
		self waittill( "sounddone" );
	}
	self playsound( sound_to_play + "_0" );
}

get_weapon_num( weapon ) //checked matches cerberus output
{
	weapon_num = undefined;
	switch( weapon )
	{
		case "humangun_zm":
			weapon_num = 0;
			break;
		case "sniper_explosive_zm":
			weapon_num = 1;
			break;
		case "tesla_gun_zm":
			weapon_num = 2;
			break;
	}
	return weapon_num;
}

addasspeakernpc( ignorenearbyspeakers ) //checked matches cerberus output
{
	if ( !isDefined( level.npcs ) )
	{
		level.npcs = [];
	}
	if ( is_true( ignorenearbyspeakers ) )
	{
		self.ignorenearbyspkrs = 1;
	}
	else
	{
		self.ignorenearbyspkrs = 0;
	}
	self.isnpc = 1;
	level.npcs[ level.npcs.size ] = self;
}

arenearbyspeakersactive() //checked partially changed to match cerberus output
{
	radius = 1000;
	nearbyspeakeractive = 0;
	speakers = get_players();
	if ( isDefined( level.npcs ) )
	{
		speakers = arraycombine( speakers, level.npcs, 1, 0 );
	}
	foreach ( person in speakers )
	{
		if ( self == person )
		{
			continue;
		}
		if ( person is_player() )
		{
			if ( person.sessionstate != "playing" )
			{
				continue;
			}
			if ( person maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
			{
				continue;
			}
		}
		if ( is_true( person.isspeaking ) && !is_true( person.ignorenearbyspkrs ) )
		{
			if ( distancesquared( self.origin, person.origin ) < radius * radius )
			{
				nearbyspeakeractive = 1;
			}
		}
	}
	return nearbyspeakeractive;
}

zmbvoxcreate() //checked matches cerberus output
{
	vox = spawnstruct();
	vox.speaker = [];
	return vox;
}

zmbvoxinitspeaker( speaker, prefix, ent ) //checked matches cerberus output
{
	ent.zmbvoxid = speaker;
	if ( !isDefined( self.speaker[ speaker ] ) )
	{
		self.speaker[ speaker ] = spawnstruct();
		self.speaker[ speaker ].alias = [];
	}
	self.speaker[ speaker ].prefix = prefix;
	self.speaker[ speaker ].ent = ent;
}

zmbvoxadd( speaker, category, type, alias, response ) //checked matches cerberus output
{
	if ( !isDefined( self.speaker[ speaker ] ) )
	{
		self.speaker[ speaker ] = spawnstruct();
		self.speaker[ speaker ].alias = [];
	}
	if ( !isDefined( self.speaker[ speaker ].alias[ category ] ) )
	{
		self.speaker[ speaker ].alias[ category ] = [];
	}
	self.speaker[ speaker ].alias[ category ][ type ] = alias;
	if ( isDefined( response ) )
	{
		if ( !isDefined( self.speaker[ speaker ].response ) )
		{
			self.speaker[ speaker ].response = [];
		}
		if ( !isDefined( self.speaker[ speaker ].response[ category ] ) )
		{
			self.speaker[ speaker ].response[ category ] = [];
		}
		self.speaker[ speaker ].response[ category ][ type ] = response;
	}
	create_vox_timer( type );
}

zmbvoxgetlinevariant( prefix, alias_suffix, force_variant, override ) //checked changed to match cerberus output
{
	if ( !isDefined( self.sound_dialog ) )
	{
		self.sound_dialog = [];
		self.sound_dialog_available = [];
	}
	if ( !isDefined( self.sound_dialog[ alias_suffix ] ) )
	{
		num_variants = maps/mp/zombies/_zm_spawner::get_number_variants( prefix + alias_suffix );
		if ( num_variants <= 0 )
		{
			return undefined;
		}
		for ( i = 0; i < num_variants; i++ )
		{
			self.sound_dialog[ alias_suffix ][ i ] = i;
		}
		self.sound_dialog_available[ alias_suffix ] = [];
	}
	while ( self.sound_dialog_available[ alias_suffix ].size <= 0 )
	{
		for ( i = 0; i < self.sound_dialog[ alias_suffix ].size; i++ )
		{
			self.sound_dialog_available[ alias_suffix ][ i ] = self.sound_dialog[ alias_suffix ][ i ];
		}
	}
	variation = random( self.sound_dialog_available[ alias_suffix ] );
	arrayremovevalue( self.sound_dialog_available[ alias_suffix ], variation );
	if ( isDefined( force_variant ) )
	{
		variation = force_variant;
	}
	if ( !isDefined( override ) )
	{
		override = 0;
	}
	return ( alias_suffix + "_" ) + variation;
}

zmbvoxcrowdonteam( alias, team, other_alias ) //checked changed to match cerberus output
{
	alias = "vox_crowd_" + alias;
	if ( !isDefined( team ) )
	{
		level play_sound_2d( alias );
		return;
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( !isdefined( players[ i ]._encounters_team ) )
		{
			continue;
		}
		if ( players[ i ]._encounters_team == team )
		{
			players[ i ] playsoundtoplayer( alias, players[ i ] );
			continue;
		}
		if ( isdefined( other_alias ) )
		{
			players[ i ] playsoundtoplayer( other_alias, players[ i ] );
		}
	}
}

playvoxtoplayer( category, type, force_variant ) //checked matches cerberus output
{
	if ( self.sessionstate != "playing" )
	{
		return;
	}
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return;
	}
	prefix = level.vox.speaker[ self.zmbvoxid ].prefix;
	alias_suffix = level.vox.speaker[ self.zmbvoxid ].alias[ category ][ type ];
	prefix = prefix + self.characterindex + "_";
	if ( !isDefined( alias_suffix ) )
	{
		return;
	}
	sound_to_play = self zmbvoxgetlinevariant( prefix, alias_suffix, force_variant );
	if ( isDefined( sound_to_play ) )
	{
		sound = prefix + sound_to_play;
		self playsoundtoplayer( sound, self );
	}
}

sndmusicstingerevent( type, player ) //checked matches cerberus output
{
	if ( isDefined( level.sndmusicstingerevent ) )
	{
		[[ level.sndmusicstingerevent ]]( type, player );
	}
}

custom_kill_damaged_vo( player ) //checked matches cerberus output
{
	self notify( "sound_damage_player_updated" );
	self endon( "death" );
	self endon( "sound_damage_player_updated" );
	self.sound_damage_player = player;
	wait 5;
	self.sound_damage_player = undefined;
}


