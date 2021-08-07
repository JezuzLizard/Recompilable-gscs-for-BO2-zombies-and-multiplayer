#include maps/mp/gametypes_zm/_globallogic_utils;
#include maps/mp/zombies/_zm_devgui;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zm_transit_lava;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zm_transit_dr_ffotd;
#include maps/mp/_visionset_mgr;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/_utility;
#include common_scripts/utility;

gamemode_callback_setup()
{
	maps/mp/zm_transit_dr_gamemodes::init();
}

encounter_init()
{
	precacheshader( "sun_moon_zombie" );
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
}

zclassic_init()
{
	level._zcleansed_weapon_progression = array( "rpd_zm", "srm1216_zm", "judge_zm", "qcw05_zm", "kard_zm" );
	survival_init();
}

zclassic_preinit()
{
	zclassic_init();
}

zcleansed_preinit()
{
	level._zcleansed_weapon_progression = array( "judge_zm", "srm1216_zm", "hk416_zm", "qcw05_zm", "kard_zm" );
	level.cymbal_monkey_clone_weapon = "srm1216_zm";
	survival_init();
}

survival_init()
{
	level.force_team_characters = 1;
	level.should_use_cia = 0;
	if ( randomint( 100 ) > 50 )
	{
		level.should_use_cia = 1;
	}
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
	flag_wait( "start_zombie_round_logic" );
	level.custom_intermission = ::transit_standard_intermission;
}

transit_standard_intermission()
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
	maps/mp/_visionset_mgr::vsmgr_deactivate( "overlay", "zm_transit_burn", self );
	self stopshellshock();
	points = getstructarray( "intermission", "targetname" );
	point = undefined;
	if ( !isDefined( points ) || points.size == 0 )
	{
		points = getentarray( "info_intermission", "classname" );
		if ( points.size < 1 )
		{
/#
			println( "NO info_intermission POINTS IN MAP" );
#/
			return;
		}
	}
	self.game_over_bg = newclienthudelem( self );
	self.game_over_bg.x = 0;
	self.game_over_bg.y = 0;
	self.game_over_bg.horzalign = "fullscreen";
	self.game_over_bg.vertalign = "fullscreen";
	self.game_over_bg.foreground = 1;
	self.game_over_bg.sort = 1;
	self.game_over_bg setshader( "black", 640, 480 );
	self.game_over_bg.alpha = 1;
	org = undefined;
	while ( 1 )
	{
		_a156 = points;
		_k156 = getFirstArrayKey( _a156 );
		while ( isDefined( _k156 ) )
		{
			struct = _a156[ _k156 ];
			if ( isDefined( struct.script_string ) && struct.script_string == level.scr_zm_map_start_location )
			{
				point = struct;
			}
			_k156 = getNextArrayKey( _a156, _k156 );
		}
		if ( !isDefined( point ) )
		{
			point = points[ 0 ];
		}
		if ( !isDefined( org ) )
		{
			self spawn( point.origin, point.angles );
		}
		if ( isDefined( point.target ) )
		{
			if ( !isDefined( org ) )
			{
				org = spawn( "script_model", self.origin + vectorScale( ( 0, 0, -1 ), 60 ) );
				org setmodel( "tag_origin" );
			}
			org.origin = point.origin;
			org.angles = point.angles;
			j = 0;
			while ( j < get_players().size )
			{
				player = get_players()[ j ];
				player camerasetposition( org );
				player camerasetlookat();
				player cameraactivate( 1 );
				j++;
			}
			speed = 20;
			if ( isDefined( point.speed ) )
			{
				speed = point.speed;
			}
			target_point = getstruct( point.target, "targetname" );
			dist = distance( point.origin, target_point.origin );
			time = dist / speed;
			q_time = time * 0,25;
			if ( q_time > 1 )
			{
				q_time = 1;
			}
			self.game_over_bg fadeovertime( q_time );
			self.game_over_bg.alpha = 0;
			org moveto( target_point.origin, time, q_time, q_time );
			org rotateto( target_point.angles, time, q_time, q_time );
			wait ( time - q_time );
			self.game_over_bg fadeovertime( q_time );
			self.game_over_bg.alpha = 1;
			wait q_time;
			continue;
		}
		else
		{
			self.game_over_bg fadeovertime( 1 );
			self.game_over_bg.alpha = 0;
			wait 5;
			self.game_over_bg thread fade_up_over_time( 1 );
		}
	}
}

zturned_preinit()
{
	encounter_init();
}

createfx_callback()
{
	ents = getentarray();
	i = 0;
	while ( i < ents.size )
	{
		if ( ents[ i ].classname != "info_player_start" )
		{
			ents[ i ] delete();
		}
		i++;
	}
}

main()
{
	level thread maps/mp/zm_transit_dr_ffotd::main_start();
	level.level_createfx_callback_thread = ::createfx_callback;
	level.default_game_mode = "zcleansed";
	level.default_start_location = "diner";
	level._get_random_encounter_func = ::maps/mp/zm_transit_utility::get_random_encounter_match;
	setup_rex_starts();
	maps/mp/zm_transit_dr_fx::main();
	maps/mp/zombies/_zm::init_fx();
	maps/mp/animscripts/zm_death::precache_gib_fx();
	level.zombiemode = 1;
	level._no_water_risers = 1;
	if ( !isDefined( level.zombie_surfing_kills ) )
	{
		level.zombie_surfing_kills = 1;
		level.zombie_surfing_kill_count = 6;
	}
	maps/mp/_sticky_grenade::init();
	level.level_specific_stats_init = ::init_transit_dr_stats;
	maps/mp/zombies/_load::main();
	init_clientflags();
	registerclientfield( "allplayers", "playerinfog", 1, 1, "int" );
	level.custom_breadcrumb_store_func = ::transit_breadcrumb_store_func;
	if ( getDvar( "createfx" ) == "1" )
	{
		return;
	}
	precacheshellshock( "lava" );
	precacheshellshock( "lava_small" );
	precache_survival_barricade_assets();
	include_game_modules();
	maps/mp/gametypes_zm/_spawning::level_use_unified_spawning( 1 );
	level.givecustomloadout = ::givecustomloadout;
	initcharacterstartindex();
	level.initial_round_wait_func = ::initial_round_wait_func;
	level.zombie_init_done = ::zombie_init_done;
	level.zombiemode_using_pack_a_punch = 1;
	level.zombiemode_reusing_pack_a_punch = 1;
	level.pap_interaction_height = 47;
	level.zombiemode_using_doubletap_perk = 1;
	level.zombiemode_using_juggernaut_perk = 1;
	level.zombiemode_using_marathon_perk = 1;
	level.zombiemode_using_revive_perk = 1;
	level.zombiemode_using_sleightofhand_perk = 1;
	level.register_offhand_weapons_for_level_defaults_override = ::offhand_weapon_overrride;
	level._zombie_custom_add_weapons = ::custom_add_weapons;
	level._allow_melee_weapon_switching = 1;
	level.uses_gumps = 1;
	setdvar( "aim_target_fixed_actor_size", 1 );
	include_weapons();
	include_powerups();
	level thread maps/mp/zm_transit_lava::lava_damage_init();
	level.zm_transit_burn_max_duration = 2;
	setup_zombie_init();
	maps/mp/zombies/_zm::init();
	maps/mp/zombies/_zm_weap_cymbal_monkey::init();
	if ( !isDefined( level.vsmgr_prio_overlay_zm_transit_burn ) )
	{
		level.vsmgr_prio_overlay_zm_transit_burn = 20;
	}
	maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zm_transit_burn", 1, level.vsmgr_prio_overlay_zm_transit_burn, 15, 1, ::maps/mp/_visionset_mgr::vsmgr_duration_lerp_thread_per_player, 0 );
	level maps/mp/zm_transit_dr_achievement::init();
	precacheitem( "death_throe_zm" );
	level.zones = [];
	level.zone_manager_init_func = ::transit_zone_init;
	init_zones[ 0 ] = "zone_gas";
	level thread maps/mp/zombies/_zm_zonemgr::manage_zones( init_zones );
	level.zombie_ai_limit = 24;
	setdvar( "zombiemode_path_minz_bias", 13 );
	level thread maps/mp/zm_transit_dr_ffotd::main_end();
	flag_wait( "start_zombie_round_logic" );
	level notify( "players_done_connecting" );
/#
	execdevgui( "devgui_zombie_transit_dr" );
	level.custom_devgui = ::zombie_transit_dr_devgui;
#/
	level thread set_transit_wind();
	level.speed_change_round = 15;
	level.speed_change_max = 5;
}

setup_rex_starts()
{
	add_gametype( "zcleansed", ::dummy, "zcleansed", ::dummy );
	add_gameloc( "diner", ::dummy, "diner", ::dummy );
}

dummy()
{
}

init_clientflags()
{
}

set_player_in_fog( onoff )
{
	if ( onoff )
	{
		self setclientfield( "playerinfog", 1 );
	}
	else
	{
		self setclientfield( "playerinfog", 0 );
	}
}

transit_breadcrumb_store_func( store_crumb )
{
	if ( isDefined( self.isonbus ) && self.isonbus )
	{
		return 0;
	}
	return store_crumb;
}

post_first_init()
{
	while ( !isDefined( anim.notfirsttime ) )
	{
		wait 0,5;
	}
	anim.meleerange = 36;
	anim.meleerangesq = anim.meleerange * anim.meleerange;
}

set_transit_wind()
{
	setdvar( "enable_global_wind", 1 );
	setdvar( "wind_global_vector", "-120 -115 -120" );
	setdvar( "wind_global_low_altitude", 0 );
	setdvar( "wind_global_hi_altitude", 2000 );
	setdvar( "wind_global_low_strength_percent", 0,5 );
}

precache_team_characters()
{
	precachemodel( "c_zom_player_cdc_dlc1_fb" );
	precachemodel( "c_zom_hazmat_viewhands" );
	precachemodel( "c_zom_player_cia_dlc1_fb" );
	precachemodel( "c_zom_suit_viewhands" );
}

precache_survival_barricade_assets()
{
	survival_barricades = getstructarray( "game_mode_object" );
	i = 0;
	while ( i < survival_barricades.size )
	{
		if ( isDefined( survival_barricades[ i ].script_string ) && survival_barricades[ i ].script_string == "survival" )
		{
			if ( isDefined( survival_barricades[ i ].script_parameters ) )
			{
				precachemodel( survival_barricades[ i ].script_parameters );
			}
		}
		i++;
	}
}

initcharacterstartindex()
{
	level.characterstartindex = 0;
/#
	forcecharacter = getDvarInt( #"FEE4CB69" );
	if ( forcecharacter != 0 )
	{
		level.characterstartindex = forcecharacter - 1;
#/
	}
}

give_team_characters()
{
	self detachall();
	self set_player_is_female( 0 );
	if ( !isDefined( self.characterindex ) )
	{
		self.characterindex = 1;
	}
	self setmodel( "c_zom_player_cdc_dlc1_fb" );
	self.voice = "american";
	self.skeleton = "base";
	self setviewmodel( "c_zom_hazmat_viewhands" );
	self.characterindex = 1;
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
}

setup_personality_character_exerts()
{
	level.exert_sounds[ 1 ][ "burp" ][ 0 ] = "vox_plr_0_exert_burp_0";
	level.exert_sounds[ 1 ][ "burp" ][ 1 ] = "vox_plr_0_exert_burp_1";
	level.exert_sounds[ 1 ][ "burp" ][ 2 ] = "vox_plr_0_exert_burp_2";
	level.exert_sounds[ 1 ][ "burp" ][ 3 ] = "vox_plr_0_exert_burp_3";
	level.exert_sounds[ 1 ][ "burp" ][ 4 ] = "vox_plr_0_exert_burp_4";
	level.exert_sounds[ 1 ][ "burp" ][ 5 ] = "vox_plr_0_exert_burp_5";
	level.exert_sounds[ 1 ][ "burp" ][ 6 ] = "vox_plr_0_exert_burp_6";
	level.exert_sounds[ 2 ][ "burp" ][ 0 ] = "vox_plr_1_exert_burp_0";
	level.exert_sounds[ 2 ][ "burp" ][ 1 ] = "vox_plr_1_exert_burp_1";
	level.exert_sounds[ 2 ][ "burp" ][ 2 ] = "vox_plr_1_exert_burp_2";
	level.exert_sounds[ 2 ][ "burp" ][ 3 ] = "vox_plr_1_exert_burp_3";
	level.exert_sounds[ 3 ][ "burp" ][ 0 ] = "vox_plr_2_exert_burp_0";
	level.exert_sounds[ 3 ][ "burp" ][ 1 ] = "vox_plr_2_exert_burp_1";
	level.exert_sounds[ 3 ][ "burp" ][ 2 ] = "vox_plr_2_exert_burp_2";
	level.exert_sounds[ 3 ][ "burp" ][ 3 ] = "vox_plr_2_exert_burp_3";
	level.exert_sounds[ 3 ][ "burp" ][ 4 ] = "vox_plr_2_exert_burp_4";
	level.exert_sounds[ 3 ][ "burp" ][ 5 ] = "vox_plr_2_exert_burp_5";
	level.exert_sounds[ 3 ][ "burp" ][ 6 ] = "vox_plr_2_exert_burp_6";
	level.exert_sounds[ 4 ][ "burp" ][ 0 ] = "vox_plr_3_exert_burp_0";
	level.exert_sounds[ 4 ][ "burp" ][ 1 ] = "vox_plr_3_exert_burp_1";
	level.exert_sounds[ 4 ][ "burp" ][ 2 ] = "vox_plr_3_exert_burp_2";
	level.exert_sounds[ 4 ][ "burp" ][ 3 ] = "vox_plr_3_exert_burp_3";
	level.exert_sounds[ 4 ][ "burp" ][ 4 ] = "vox_plr_3_exert_burp_4";
	level.exert_sounds[ 4 ][ "burp" ][ 5 ] = "vox_plr_3_exert_burp_5";
	level.exert_sounds[ 4 ][ "burp" ][ 6 ] = "vox_plr_3_exert_burp_6";
	level.exert_sounds[ 1 ][ "hitmed" ][ 0 ] = "vox_plr_0_exert_pain_medium_0";
	level.exert_sounds[ 1 ][ "hitmed" ][ 1 ] = "vox_plr_0_exert_pain_medium_1";
	level.exert_sounds[ 1 ][ "hitmed" ][ 2 ] = "vox_plr_0_exert_pain_medium_2";
	level.exert_sounds[ 1 ][ "hitmed" ][ 3 ] = "vox_plr_0_exert_pain_medium_3";
	level.exert_sounds[ 2 ][ "hitmed" ][ 0 ] = "vox_plr_1_exert_pain_medium_0";
	level.exert_sounds[ 2 ][ "hitmed" ][ 1 ] = "vox_plr_1_exert_pain_medium_1";
	level.exert_sounds[ 2 ][ "hitmed" ][ 2 ] = "vox_plr_1_exert_pain_medium_2";
	level.exert_sounds[ 2 ][ "hitmed" ][ 3 ] = "vox_plr_1_exert_pain_medium_3";
	level.exert_sounds[ 3 ][ "hitmed" ][ 0 ] = "vox_plr_2_exert_pain_medium_0";
	level.exert_sounds[ 3 ][ "hitmed" ][ 1 ] = "vox_plr_2_exert_pain_medium_1";
	level.exert_sounds[ 3 ][ "hitmed" ][ 2 ] = "vox_plr_2_exert_pain_medium_2";
	level.exert_sounds[ 3 ][ "hitmed" ][ 3 ] = "vox_plr_2_exert_pain_medium_3";
	level.exert_sounds[ 4 ][ "hitmed" ][ 0 ] = "vox_plr_3_exert_pain_medium_0";
	level.exert_sounds[ 4 ][ "hitmed" ][ 1 ] = "vox_plr_3_exert_pain_medium_1";
	level.exert_sounds[ 4 ][ "hitmed" ][ 2 ] = "vox_plr_3_exert_pain_medium_2";
	level.exert_sounds[ 4 ][ "hitmed" ][ 3 ] = "vox_plr_3_exert_pain_medium_3";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 0 ] = "vox_plr_0_exert_pain_high_0";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 1 ] = "vox_plr_0_exert_pain_high_1";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 2 ] = "vox_plr_0_exert_pain_high_2";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 3 ] = "vox_plr_0_exert_pain_high_3";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 0 ] = "vox_plr_1_exert_pain_high_0";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 1 ] = "vox_plr_1_exert_pain_high_1";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 2 ] = "vox_plr_1_exert_pain_high_2";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 3 ] = "vox_plr_1_exert_pain_high_3";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 0 ] = "vox_plr_2_exert_pain_high_0";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 1 ] = "vox_plr_2_exert_pain_high_1";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 2 ] = "vox_plr_2_exert_pain_high_2";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 3 ] = "vox_plr_2_exert_pain_high_3";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 0 ] = "vox_plr_3_exert_pain_high_0";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 1 ] = "vox_plr_3_exert_pain_high_1";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 2 ] = "vox_plr_3_exert_pain_high_2";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 3 ] = "vox_plr_3_exert_pain_high_3";
}

givecustomloadout( takeallweapons, alreadyspawned )
{
	self giveweapon( "knife_zm" );
	self give_start_weapon( 1 );
}

transit_intermission()
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
	maps/mp/_visionset_mgr::vsmgr_deactivate( "overlay", "zm_transit_burn", self );
	self stopshellshock();
	self.game_over_bg = newclienthudelem( self );
	self.game_over_bg.x = 0;
	self.game_over_bg.y = 0;
	self.game_over_bg.horzalign = "fullscreen";
	self.game_over_bg.vertalign = "fullscreen";
	self.game_over_bg.foreground = 1;
	self.game_over_bg.sort = 1;
	self.game_over_bg setshader( "black", 640, 480 );
	self.game_over_bg.alpha = 1;
	if ( !isDefined( level.the_bus ) )
	{
		self.game_over_bg fadeovertime( 1 );
		self.game_over_bg.alpha = 0;
		wait 5;
		self.game_over_bg thread maps/mp/zombies/_zm::fade_up_over_time( 1 );
	}
	else
	{
		zonestocheck = [];
		zonestocheck[ zonestocheck.size ] = "zone_amb_bridge";
		zonestocheck[ zonestocheck.size ] = "zone_trans_11";
		zonestocheck[ zonestocheck.size ] = "zone_town_west";
		zonestocheck[ zonestocheck.size ] = "zone_town_west2";
		zonestocheck[ zonestocheck.size ] = "zone_tow";
		near_bridge = 0;
		_a800 = zonestocheck;
		_k800 = getFirstArrayKey( _a800 );
		while ( isDefined( _k800 ) )
		{
			zone = _a800[ _k800 ];
			if ( level.the_bus maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_amb_bridge" ) )
			{
				near_bridge = 1;
			}
			_k800 = getNextArrayKey( _a800, _k800 );
		}
		if ( near_bridge )
		{
			trig = getent( "bridge_trig", "targetname" );
			trig notify( "trigger" );
		}
		org = spawn( "script_model", level.the_bus gettagorigin( "tag_camera" ) );
		org setmodel( "tag_origin" );
		org.angles = level.the_bus gettagangles( "tag_camera" );
		org linkto( level.the_bus );
		self setorigin( org.origin );
		self.angles = org.angles;
		if ( !flag( "OnPriDoorYar" ) || !flag( "OnPriDoorYar2" ) )
		{
			flag_set( "OnPriDoorYar" );
			wait_network_frame();
		}
		if ( !level.the_bus.ismoving )
		{
			level.the_bus.gracetimeatdestination = 0,1;
			level.the_bus notify( "depart_early" );
		}
		players = get_players();
		j = 0;
		while ( j < players.size )
		{
			player = players[ j ];
			player camerasetposition( org );
			player camerasetlookat();
			player cameraactivate( 1 );
			j++;
		}
		self.game_over_bg fadeovertime( 1 );
		self.game_over_bg.alpha = 0;
		wait 12;
		self.game_over_bg fadeovertime( 1 );
		self.game_over_bg.alpha = 1;
		wait 1;
	}
}

transit_zone_init()
{
	flag_init( "always_on" );
	flag_set( "always_on" );
	add_adjacent_zone( "zone_roadside_west", "zone_din", "always_on" );
	add_adjacent_zone( "zone_roadside_west", "zone_gas", "always_on" );
	add_adjacent_zone( "zone_roadside_east", "zone_gas", "always_on" );
	add_adjacent_zone( "zone_roadside_east", "zone_gar", "always_on" );
	add_adjacent_zone( "zone_gas", "zone_din", "always_on" );
	add_adjacent_zone( "zone_gas", "zone_gar", "always_on" );
}

include_powerups()
{
	gametype = getDvar( "ui_gametype" );
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	if ( gametype != "zgrief" )
	{
		include_powerup( "carpenter" );
	}
}

claymore_safe_to_plant()
{
	if ( self maps/mp/zm_transit_lava::object_touching_lava() )
	{
		return 0;
	}
	if ( self.owner maps/mp/zm_transit_lava::object_touching_lava() )
	{
		return 0;
	}
	return 1;
}

grenade_safe_to_throw( player, weapname )
{
	return 1;
}

grenade_safe_to_bounce( player, weapname )
{
	if ( !is_offhand_weapon( weapname ) && !is_grenade_launcher( weapname ) )
	{
		return 1;
	}
	if ( self maps/mp/zm_transit_lava::object_touching_lava() )
	{
		return 0;
	}
	return 1;
}

offhand_weapon_overrride()
{
	register_lethal_grenade_for_level( "frag_grenade_zm" );
	level.zombie_lethal_grenade_player_init = "frag_grenade_zm";
	register_tactical_grenade_for_level( "cymbal_monkey_zm" );
	level.zombie_tactical_grenade_player_init = undefined;
	level.grenade_safe_to_throw = ::grenade_safe_to_throw;
	level.grenade_safe_to_bounce = ::grenade_safe_to_bounce;
	level.zombie_placeable_mine_player_init = undefined;
	level.claymore_safe_to_plant = ::claymore_safe_to_plant;
	register_melee_weapon_for_level( "knife_zm" );
	register_melee_weapon_for_level( "bowie_knife_zm" );
	level.zombie_melee_weapon_player_init = "knife_zm";
	level.zombie_equipment_player_init = undefined;
}

include_weapons()
{
	gametype = getDvar( "ui_gametype" );
	include_weapon( "knife_zm", 0 );
	include_weapon( "frag_grenade_zm", 0 );
	include_weapon( "m1911_zm", 0 );
	include_weapon( "m1911_upgraded_zm", 0 );
	include_weapon( "python_zm" );
	include_weapon( "python_upgraded_zm", 0 );
	include_weapon( "judge_zm" );
	include_weapon( "judge_upgraded_zm", 0 );
	include_weapon( "kard_zm" );
	include_weapon( "kard_upgraded_zm", 0 );
	include_weapon( "fiveseven_zm" );
	include_weapon( "fiveseven_upgraded_zm", 0 );
	include_weapon( "beretta93r_zm", 0 );
	include_weapon( "beretta93r_upgraded_zm", 0 );
	include_weapon( "fivesevendw_zm" );
	include_weapon( "fivesevendw_upgraded_zm", 0 );
	include_weapon( "ak74u_zm", 0 );
	include_weapon( "ak74u_upgraded_zm", 0 );
	include_weapon( "mp5k_zm", 0 );
	include_weapon( "mp5k_upgraded_zm", 0 );
	include_weapon( "qcw05_zm" );
	include_weapon( "qcw05_upgraded_zm", 0 );
	include_weapon( "870mcs_zm", 0 );
	include_weapon( "870mcs_upgraded_zm", 0 );
	include_weapon( "rottweil72_zm", 0 );
	include_weapon( "rottweil72_upgraded_zm", 0 );
	include_weapon( "saiga12_zm" );
	include_weapon( "saiga12_upgraded_zm", 0 );
	include_weapon( "srm1216_zm" );
	include_weapon( "srm1216_upgraded_zm", 0 );
	include_weapon( "m14_zm", 0 );
	include_weapon( "m14_upgraded_zm", 0 );
	include_weapon( "saritch_zm" );
	include_weapon( "saritch_upgraded_zm", 0 );
	include_weapon( "m16_zm", 0 );
	include_weapon( "m16_gl_upgraded_zm", 0 );
	include_weapon( "xm8_zm" );
	include_weapon( "xm8_upgraded_zm", 0 );
	include_weapon( "type95_zm" );
	include_weapon( "type95_upgraded_zm", 0 );
	include_weapon( "tar21_zm" );
	include_weapon( "tar21_upgraded_zm", 0 );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", 0 );
	include_weapon( "fnfal_zm" );
	include_weapon( "fnfal_upgraded_zm", 0 );
	include_weapon( "dsr50_zm" );
	include_weapon( "dsr50_upgraded_zm", 0 );
	include_weapon( "barretm82_zm" );
	include_weapon( "barretm82_upgraded_zm", 0 );
	include_weapon( "rpd_zm" );
	include_weapon( "rpd_upgraded_zm", 0 );
	include_weapon( "hamr_zm" );
	include_weapon( "hamr_upgraded_zm", 0 );
	include_weapon( "usrpg_zm" );
	include_weapon( "usrpg_upgraded_zm", 0 );
	include_weapon( "m32_zm" );
	include_weapon( "m32_upgraded_zm", 0 );
	include_weapon( "hk416_zm" );
	include_weapon( "hk416_upgraded_zm", 0 );
	include_weapon( "cymbal_monkey_zm" );
	if ( gametype != "zgrief" )
	{
		include_weapon( "ray_gun_zm" );
		include_weapon( "ray_gun_upgraded_zm", 0 );
		add_limited_weapon( "ray_gun_zm", 4 );
		add_limited_weapon( "ray_gun_upgraded_zm", 4 );
	}
	add_limited_weapon( "m1911_zm", 0 );
}

less_than_normal()
{
	return 0,5;
}

custom_add_weapons()
{
	add_zombie_weapon( "m1911_zm", "m1911_upgraded_zm", &"ZOMBIE_WEAPON_M1911", 50, "", "", undefined );
	add_zombie_weapon( "python_zm", "python_upgraded_zm", &"ZOMBIE_WEAPON_PYTHON", 50, "wpck_python", "", undefined, 1 );
	add_zombie_weapon( "judge_zm", "judge_upgraded_zm", &"ZOMBIE_WEAPON_JUDGE", 50, "wpck_judge", "", undefined, 1 );
	add_zombie_weapon( "kard_zm", "kard_upgraded_zm", &"ZOMBIE_WEAPON_KARD", 50, "wpck_kap", "", undefined, 1 );
	add_zombie_weapon( "fiveseven_zm", "fiveseven_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVEN", 50, "wpck_57", "", undefined, 1 );
	add_zombie_weapon( "beretta93r_zm", "beretta93r_upgraded_zm", &"ZOMBIE_WEAPON_BERETTA93r", 1000, "", "", undefined );
	add_zombie_weapon( "fivesevendw_zm", "fivesevendw_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVENDW", 50, "wpck_duel57", "", undefined, 1 );
	add_zombie_weapon( "ak74u_zm", "ak74u_upgraded_zm", &"ZOMBIE_WEAPON_AK74U", 1200, "smg", "", undefined );
	add_zombie_weapon( "mp5k_zm", "mp5k_upgraded_zm", &"ZOMBIE_WEAPON_MP5K", 1000, "smg", "", undefined );
	add_zombie_weapon( "qcw05_zm", "qcw05_upgraded_zm", &"ZOMBIE_WEAPON_QCW05", 50, "wpck_chicom", "", undefined, 1 );
	add_zombie_weapon( "870mcs_zm", "870mcs_upgraded_zm", &"ZOMBIE_WEAPON_870MCS", 1500, "shotgun", "", undefined );
	add_zombie_weapon( "rottweil72_zm", "rottweil72_upgraded_zm", &"ZOMBIE_WEAPON_ROTTWEIL72", 500, "shotgun", "", undefined );
	add_zombie_weapon( "saiga12_zm", "saiga12_upgraded_zm", &"ZOMBIE_WEAPON_SAIGA12", 50, "wpck_saiga12", "", undefined, 1 );
	add_zombie_weapon( "srm1216_zm", "srm1216_upgraded_zm", &"ZOMBIE_WEAPON_SRM1216", 50, "wpck_m1216", "", undefined, 1 );
	add_zombie_weapon( "m14_zm", "m14_upgraded_zm", &"ZOMBIE_WEAPON_M14", 500, "rifle", "", undefined );
	add_zombie_weapon( "saritch_zm", "saritch_upgraded_zm", &"ZOMBIE_WEAPON_SARITCH", 50, "wpck_sidr", "", undefined, 1 );
	add_zombie_weapon( "m16_zm", "m16_gl_upgraded_zm", &"ZOMBIE_WEAPON_M16", 1200, "burstrifle", "", undefined );
	add_zombie_weapon( "xm8_zm", "xm8_upgraded_zm", &"ZOMBIE_WEAPON_XM8", 50, "wpck_m8a1", "", undefined, 1 );
	add_zombie_weapon( "type95_zm", "type95_upgraded_zm", &"ZOMBIE_WEAPON_TYPE95", 50, "wpck_type25", "", undefined, 1 );
	add_zombie_weapon( "tar21_zm", "tar21_upgraded_zm", &"ZOMBIE_WEAPON_TAR21", 50, "wpck_x95l", "", undefined, 1 );
	add_zombie_weapon( "galil_zm", "galil_upgraded_zm", &"ZOMBIE_WEAPON_GALIL", 50, "wpck_galil", "", undefined, 1 );
	add_zombie_weapon( "fnfal_zm", "fnfal_upgraded_zm", &"ZOMBIE_WEAPON_FNFAL", 50, "wpck_fal", "", undefined, 1 );
	add_zombie_weapon( "dsr50_zm", "dsr50_upgraded_zm", &"ZOMBIE_WEAPON_DR50", 50, "wpck_dsr50", "", undefined, 1 );
	add_zombie_weapon( "barretm82_zm", "barretm82_upgraded_zm", &"ZOMBIE_WEAPON_BARRETM82", 50, "sniper", "", undefined );
	add_zombie_weapon( "rpd_zm", "rpd_upgraded_zm", &"ZOMBIE_WEAPON_RPD", 50, "wpck_rpd", "", undefined, 1 );
	add_zombie_weapon( "hamr_zm", "hamr_upgraded_zm", &"ZOMBIE_WEAPON_HAMR", 50, "wpck_hamr", "", undefined, 1 );
	add_zombie_weapon( "frag_grenade_zm", undefined, &"ZOMBIE_WEAPON_FRAG_GRENADE", 250, "grenade", "", 250 );
	add_zombie_weapon( "usrpg_zm", "usrpg_upgraded_zm", &"ZOMBIE_WEAPON_USRPG", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "m32_zm", "m32_upgraded_zm", &"ZOMBIE_WEAPON_M32", 50, "wpck_m32", "", undefined, 1 );
	add_zombie_weapon( "cymbal_monkey_zm", undefined, &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
	add_zombie_weapon( "ray_gun_zm", "ray_gun_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN", 10000, "wpck_ray", "", undefined, 1 );
	add_zombie_weapon( "hk416_zm", "hk416_upgraded_zm", &"ZOMBIE_WEAPON_HK416", 100, "", "", undefined );
}

include_game_modules()
{
}

initial_round_wait_func()
{
	flag_wait( "initial_blackscreen_passed" );
}

zombie_init_done()
{
	self.allowpain = 0;
}

setup_zombie_init()
{
	zombies = getentarray( "zombie_spawner", "script_noteworthy" );
}

assign_lowest_unused_character_index()
{
	charindexarray = [];
	charindexarray[ 0 ] = 0;
	charindexarray[ 1 ] = 1;
	charindexarray[ 2 ] = 2;
	charindexarray[ 3 ] = 3;
	players = get_players();
	if ( players.size == 1 )
	{
		charindexarray = array_randomize( charindexarray );
		return charindexarray[ 0 ];
	}
	else
	{
		if ( players.size == 2 )
		{
			_a1250 = players;
			_k1250 = getFirstArrayKey( _a1250 );
			while ( isDefined( _k1250 ) )
			{
				player = _a1250[ _k1250 ];
				if ( isDefined( player.characterindex ) )
				{
					if ( player.characterindex == 2 || player.characterindex == 0 )
					{
						if ( randomint( 100 ) > 50 )
						{
							return 1;
						}
						return 3;
					}
					else
					{
						if ( player.characterindex == 3 || player.characterindex == 1 )
						{
							if ( randomint( 100 ) > 50 )
							{
								return 0;
							}
							return 2;
						}
					}
				}
				_k1250 = getNextArrayKey( _a1250, _k1250 );
			}
		}
		else _a1276 = players;
		_k1276 = getFirstArrayKey( _a1276 );
		while ( isDefined( _k1276 ) )
		{
			player = _a1276[ _k1276 ];
			if ( isDefined( player.characterindex ) )
			{
				arrayremovevalue( charindexarray, player.characterindex, 0 );
			}
			_k1276 = getNextArrayKey( _a1276, _k1276 );
		}
		if ( charindexarray.size > 0 )
		{
			return charindexarray[ 0 ];
		}
	}
	return 0;
}

zombie_transit_dr_devgui( cmd )
{
/#
	cmd_strings = strtok( cmd, " " );
	switch( cmd_strings[ 0 ] )
	{
		case "blue_monkey":
		case "green_ammo":
		case "green_double":
		case "green_insta":
		case "green_monkey":
		case "green_nuke":
		case "red_ammo":
		case "red_double":
		case "red_nuke":
		case "yellow_double":
		case "yellow_nuke":
			maps/mp/zombies/_zm_devgui::zombie_devgui_give_powerup( cmd_strings[ 0 ], 1 );
			break;
		case "less_time":
			less_time();
			break;
		case "more_time":
			more_time();
			break;
		default:
		}
#/
	}
}

less_time()
{
/#
	level.time_to_add = 30000;
	if ( !isDefined( level.time_to_remove ) )
	{
		level.time_to_remove = 60000;
	}
	else
	{
		level.time_to_remove *= 2;
	}
	if ( maps/mp/gametypes_zm/_globallogic_utils::gettimeremaining() < level.time_to_remove )
	{
		level.time_to_remove = maps/mp/gametypes_zm/_globallogic_utils::gettimeremaining() / 2;
	}
	level.discardtime -= level.time_to_remove;
#/
}

more_time()
{
/#
	level.time_to_remove = 30000;
	if ( !isDefined( level.time_to_add ) )
	{
		level.time_to_add = 60000;
	}
	else
	{
		level.time_to_add *= 2;
	}
	level.discardtime += level.time_to_add;
#/
}

init_transit_dr_stats()
{
	self maps/mp/zm_transit_dr_achievement::init_player_achievement_stats();
}
