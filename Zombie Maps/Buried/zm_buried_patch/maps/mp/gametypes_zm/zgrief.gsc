#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/_demo;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_weap_cymbal_monkey;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_game_module_meat_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/gametypes_zm/zmeat;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;

main()
{
	maps/mp/gametypes_zm/_zm_gametype::main();
	level.onprecachegametype = ::onprecachegametype;
	level.onstartgametype = ::onstartgametype;
	level.custom_spectate_permissions = ::setspectatepermissionsgrief;
	level._game_module_custom_spawn_init_func = ::maps/mp/gametypes_zm/_zm_gametype::custom_spawn_init_func;
	level._game_module_stat_update_func = ::maps/mp/zombies/_zm_stats::grief_custom_stat_update;
	level._game_module_player_damage_callback = ::maps/mp/gametypes_zm/_zm_gametype::game_module_player_damage_callback;
	level.custom_end_screen = ::custom_end_screen;
	level.gamemode_map_postinit[ "zgrief" ] = ::postinit_func;
	level._supress_survived_screen = 1;
	level.game_module_team_name_override_og_x = 155;
	level.prevent_player_damage = ::player_prevent_damage;
	level._game_module_player_damage_grief_callback = ::game_module_player_damage_grief_callback;
	level._grief_reset_message = ::grief_reset_message;
	level._game_module_player_laststand_callback = ::grief_laststand_weapon_save;
	level.onplayerspawned_restore_previous_weapons = ::grief_laststand_weapons_return;
	level.game_module_onplayerconnect = ::grief_onplayerconnect;
	level.game_mode_spawn_player_logic = ::game_mode_spawn_player_logic;
	level.game_mode_custom_onplayerdisconnect = ::grief_onplayerdisconnect;
	maps/mp/gametypes_zm/_zm_gametype::post_gametype_main( "zgrief" );
}

grief_onplayerconnect()
{
	self thread move_team_icons();
	self thread maps/mp/gametypes_zm/zmeat::create_item_meat_watcher();
	self thread zgrief_player_bled_out_msg();
}

grief_onplayerdisconnect( disconnecting_player )
{
	level thread update_players_on_bleedout_or_disconnect( disconnecting_player );
}

setspectatepermissionsgrief()
{
	self allowspectateteam( "allies", 1 );
	self allowspectateteam( "axis", 1 );
	self allowspectateteam( "freelook", 0 );
	self allowspectateteam( "none", 1 );
}

custom_end_screen()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ].game_over_hud = newclienthudelem( players[ i ] );
		players[ i ].game_over_hud.alignx = "center";
		players[ i ].game_over_hud.aligny = "middle";
		players[ i ].game_over_hud.horzalign = "center";
		players[ i ].game_over_hud.vertalign = "middle";
		players[ i ].game_over_hud.y -= 130;
		players[ i ].game_over_hud.foreground = 1;
		players[ i ].game_over_hud.fontscale = 3;
		players[ i ].game_over_hud.alpha = 0;
		players[ i ].game_over_hud.color = ( 1, 1, 1 );
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
		players[ i ].survived_hud.color = ( 1, 1, 1 );
		players[ i ].survived_hud.hidewheninmenu = 1;
		if ( players[ i ] issplitscreen() )
		{
			players[ i ].survived_hud.fontscale = 1,5;
			players[ i ].survived_hud.y += 40;
		}
		winner_text = &"ZOMBIE_GRIEF_WIN";
		loser_text = &"ZOMBIE_GRIEF_LOSE";
		if ( level.round_number < 2 )
		{
			winner_text = &"ZOMBIE_GRIEF_WIN_SINGLE";
			loser_text = &"ZOMBIE_GRIEF_LOSE_SINGLE";
		}
		if ( isDefined( level.host_ended_game ) && level.host_ended_game )
		{
			players[ i ].survived_hud settext( &"MP_HOST_ENDED_GAME" );
		}
		else
		{
			if ( isDefined( level.gamemodulewinningteam ) && players[ i ]._encounters_team == level.gamemodulewinningteam )
			{
				players[ i ].survived_hud settext( winner_text, level.round_number );
				break;
			}
			else
			{
				players[ i ].survived_hud settext( loser_text, level.round_number );
			}
		}
		players[ i ].survived_hud fadeovertime( 1 );
		players[ i ].survived_hud.alpha = 1;
		i++;
	}
}

postinit_func()
{
	level.min_humans = 1;
	level.zombie_ai_limit = 24;
	level.prevent_player_damage = ::player_prevent_damage;
	level.lock_player_on_team_score = 1;
	level._zombiemode_powerup_grab = ::meat_stink_powerup_grab;
	level.meat_bounce_override = ::meat_bounce_override;
	level._zombie_spawning = 0;
	level._get_game_module_players = undefined;
	level.powerup_drop_count = 0;
	level.is_zombie_level = 1;
	level._effect[ "meat_impact" ] = loadfx( "maps/zombie/fx_zmb_meat_impact" );
	level._effect[ "spawn_cloud" ] = loadfx( "maps/zombie/fx_zmb_race_zombie_spawn_cloud" );
	level._effect[ "meat_stink_camera" ] = loadfx( "maps/zombie/fx_zmb_meat_stink_camera" );
	level._effect[ "meat_stink_torso" ] = loadfx( "maps/zombie/fx_zmb_meat_stink_torso" );
	include_powerup( "meat_stink" );
	maps/mp/zombies/_zm_powerups::add_zombie_powerup( "meat_stink", "t6_wpn_zmb_meat_world", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_drop_meat, 0, 0, 0 );
	setmatchtalkflag( "DeadChatWithDead", 1 );
	setmatchtalkflag( "DeadChatWithTeam", 1 );
	setmatchtalkflag( "DeadHearTeamLiving", 1 );
	setmatchtalkflag( "DeadHearAllLiving", 1 );
	setmatchtalkflag( "EveryoneHearsEveryone", 1 );
}

func_should_drop_meat()
{
	if ( minigun_no_drop() )
	{
		return 0;
	}
	return 1;
}

minigun_no_drop()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].ignoreme == 1 )
		{
			return 1;
		}
		i++;
	}
	if ( isDefined( level.meat_on_ground ) && level.meat_on_ground )
	{
		return 1;
	}
	return 0;
}

grief_game_end_check_func()
{
	return 0;
}

player_prevent_damage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isDefined( eattacker ) && isplayer( eattacker ) && self != eattacker && !eattacker hasperk( "specialty_noname" ) && isDefined( self.is_zombie ) && !self.is_zombie )
	{
		return 1;
	}
	return 0;
}

game_module_player_damage_grief_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	penalty = 10;
	if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker != self && eattacker.team != self.team && smeansofdeath == "MOD_MELEE" )
	{
		self applyknockback( idamage, vdir );
	}
}

onprecachegametype()
{
	level.playersuicideallowed = 1;
	level.canplayersuicide = ::canplayersuicide;
	level.suicide_weapon = "death_self_zm";
	precacheitem( "death_self_zm" );
	precacheshellshock( "grief_stab_zm" );
	precacheshader( "faction_cdc" );
	precacheshader( "faction_cia" );
	precacheshader( "waypoint_revive_cdc_zm" );
	precacheshader( "waypoint_revive_cia_zm" );
	level._effect[ "butterflies" ] = loadfx( "maps/zombie/fx_zmb_impact_noharm" );
	level thread maps/mp/zombies/_zm_game_module_meat_utility::init_item_meat( "zgrief" );
	level thread maps/mp/gametypes_zm/_zm_gametype::init();
	maps/mp/gametypes_zm/_zm_gametype::rungametypeprecache( "zgrief" );
}

onstartgametype()
{
	level.no_end_game_check = 1;
	level._game_module_game_end_check = ::grief_game_end_check_func;
	level.round_end_custom_logic = ::grief_round_end_custom_logic;
	maps/mp/gametypes_zm/_zm_gametype::setup_classic_gametype();
	maps/mp/gametypes_zm/_zm_gametype::rungametypemain( "zgrief", ::zgrief_main );
}

zgrief_main()
{
	level thread maps/mp/zombies/_zm::round_start();
	level thread maps/mp/gametypes_zm/_zm_gametype::kill_all_zombies();
	flag_wait( "initial_blackscreen_passed" );
	level thread maps/mp/zombies/_zm_game_module::wait_for_team_death_and_round_end();
	players = get_players();
	_a302 = players;
	_k302 = getFirstArrayKey( _a302 );
	while ( isDefined( _k302 ) )
	{
		player = _a302[ _k302 ];
		player.is_hotjoin = 0;
		_k302 = getNextArrayKey( _a302, _k302 );
	}
	wait 1;
	playsoundatposition( "vox_zmba_grief_intro_0", ( 1, 1, 1 ) );
}

move_team_icons()
{
	self endon( "disconnect" );
	flag_wait( "initial_blackscreen_passed" );
	wait 0,5;
}

kill_start_chest()
{
	flag_wait( "initial_blackscreen_passed" );
	wait 2;
	start_chest = getstruct( "start_chest", "script_noteworthy" );
	start_chest maps/mp/zombies/_zm_magicbox::hide_chest();
}

meat_stink_powerup_grab( powerup, who )
{
	switch( powerup.powerup_name )
	{
		case "meat_stink":
			level thread meat_stink( who );
			break;
	}
}

meat_stink( who )
{
	weapons = who getweaponslist();
	has_meat = 0;
	_a353 = weapons;
	_k353 = getFirstArrayKey( _a353 );
	while ( isDefined( _k353 ) )
	{
		weapon = _a353[ _k353 ];
		if ( weapon == "item_meat_zm" )
		{
			has_meat = 1;
		}
		_k353 = getNextArrayKey( _a353, _k353 );
	}
	if ( has_meat )
	{
		return;
	}
	who.pre_meat_weapon = who getcurrentweapon();
	level notify( "meat_grabbed" );
	who notify( "meat_grabbed" );
	who playsound( "zmb_pickup_meat" );
	who increment_is_drinking();
	who giveweapon( "item_meat_zm" );
	who switchtoweapon( "item_meat_zm" );
	who setweaponammoclip( "item_meat_zm", 1 );
}

meat_stink_on_ground( position_to_play )
{
	level.meat_on_ground = 1;
	attractor_point = spawn( "script_model", position_to_play );
	attractor_point setmodel( "tag_origin" );
	attractor_point playsound( "zmb_land_meat" );
	wait 0,2;
	playfxontag( level._effect[ "meat_stink_torso" ], attractor_point, "tag_origin" );
	attractor_point playloopsound( "zmb_meat_flies" );
	attractor_point create_zombie_point_of_interest( 1536, 32, 10000 );
	attractor_point.attract_to_origin = 1;
	attractor_point thread create_zombie_point_of_interest_attractor_positions( 4, 45 );
	attractor_point thread maps/mp/zombies/_zm_weap_cymbal_monkey::wait_for_attractor_positions_complete();
	attractor_point delay_thread( 15, ::self_delete );
	wait 16;
	level.meat_on_ground = undefined;
}

meat_bounce_override( pos, normal, ent )
{
	if ( isDefined( ent ) && isplayer( ent ) )
	{
		if ( !ent maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			level thread meat_stink_player( ent );
			if ( isDefined( self.owner ) )
			{
				maps/mp/_demo::bookmark( "zm_player_meat_stink", getTime(), ent, self.owner, 0, self );
				self.owner maps/mp/zombies/_zm_stats::increment_client_stat( "contaminations_given" );
			}
		}
	}
	else
	{
		players = getplayers();
		closest_player = undefined;
		closest_player_dist = 10000;
		player_index = 0;
		while ( player_index < players.size )
		{
			player_to_check = players[ player_index ];
			if ( self.owner == player_to_check )
			{
				player_index++;
				continue;
			}
			else if ( player_to_check maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
			{
				player_index++;
				continue;
			}
			else
			{
				distsq = distancesquared( pos, player_to_check.origin );
				if ( distsq < closest_player_dist )
				{
					closest_player = player_to_check;
					closest_player_dist = distsq;
				}
			}
			player_index++;
		}
		if ( isDefined( closest_player ) )
		{
			level thread meat_stink_player( closest_player );
			if ( isDefined( self.owner ) )
			{
				maps/mp/_demo::bookmark( "zm_player_meat_stink", getTime(), closest_player, self.owner, 0, self );
				self.owner maps/mp/zombies/_zm_stats::increment_client_stat( "contaminations_given" );
			}
		}
		else
		{
			valid_poi = check_point_in_enabled_zone( pos, undefined, undefined );
			if ( valid_poi )
			{
				self hide();
				level thread meat_stink_on_ground( self.origin );
			}
		}
		playfx( level._effect[ "meat_impact" ], self.origin );
	}
	self delete();
}

meat_stink_player( who )
{
	level notify( "new_meat_stink_player" );
	level endon( "new_meat_stink_player" );
	who.ignoreme = 0;
	players = get_players();
	_a486 = players;
	_k486 = getFirstArrayKey( _a486 );
	while ( isDefined( _k486 ) )
	{
		player = _a486[ _k486 ];
		player thread meat_stink_player_cleanup();
		if ( player != who )
		{
			player.ignoreme = 1;
		}
		_k486 = getNextArrayKey( _a486, _k486 );
	}
	who thread meat_stink_player_create();
	who waittill_any_or_timeout( 30, "disconnect", "player_downed", "bled_out" );
	players = get_players();
	_a501 = players;
	_k501 = getFirstArrayKey( _a501 );
	while ( isDefined( _k501 ) )
	{
		player = _a501[ _k501 ];
		player thread meat_stink_player_cleanup();
		player.ignoreme = 0;
		_k501 = getNextArrayKey( _a501, _k501 );
	}
}

meat_stink_player_create()
{
	self maps/mp/zombies/_zm_stats::increment_client_stat( "contaminations_received" );
	self endon( "disconnect" );
	self endon( "death" );
	tagname = "J_SpineLower";
	self.meat_stink_3p = spawn( "script_model", self gettagorigin( tagname ) );
	self.meat_stink_3p setmodel( "tag_origin" );
	self.meat_stink_3p linkto( self, tagname );
	wait 0,5;
	playfxontag( level._effect[ "meat_stink_torso" ], self.meat_stink_3p, "tag_origin" );
	self setclientfieldtoplayer( "meat_stink", 1 );
}

meat_stink_player_cleanup()
{
	if ( isDefined( self.meat_stink_3p ) )
	{
		self.meat_stink_3p unlink();
		self.meat_stink_3p delete();
	}
	self setclientfieldtoplayer( "meat_stink", 0 );
}

door_close_zombie_think()
{
	self endon( "death" );
	while ( isalive( self ) )
	{
		if ( isDefined( self.enemy ) && isplayer( self.enemy ) )
		{
			insamezone = 0;
			keys = getarraykeys( level.zones );
			i = 0;
			while ( i < keys.size )
			{
				if ( self maps/mp/zombies/_zm_zonemgr::entity_in_zone( keys[ i ] ) && self.enemy maps/mp/zombies/_zm_zonemgr::entity_in_zone( keys[ i ] ) )
				{
					insamezone = 1;
				}
				i++;
			}
			while ( insamezone )
			{
				wait 3;
			}
			nearestzombienode = getnearestnode( self.origin );
			nearestplayernode = getnearestnode( self.enemy.origin );
			if ( isDefined( nearestzombienode ) && isDefined( nearestplayernode ) )
			{
				if ( !nodesvisible( nearestzombienode, nearestplayernode ) && !nodescanpath( nearestzombienode, nearestplayernode ) )
				{
					self silentlyremovezombie();
				}
			}
		}
		wait 1;
	}
}

silentlyremovezombie()
{
	level.zombie_total++;
	playfx( level._effect[ "spawn_cloud" ], self.origin );
	self.skip_death_notetracks = 1;
	self.nodeathragdoll = 1;
	self dodamage( self.maxhealth * 2, self.origin, self, self, "none", "MOD_SUICIDE" );
	self self_delete();
}

zgrief_player_bled_out_msg()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "bled_out" );
		level thread update_players_on_bleedout_or_disconnect( self );
	}
}

show_grief_hud_msg( msg, msg_parm, offset, cleanup_end_game )
{
	self endon( "disconnect" );
	while ( isDefined( level.hostmigrationtimer ) )
	{
		wait 0,05;
	}
	zgrief_hudmsg = newclienthudelem( self );
	zgrief_hudmsg.alignx = "center";
	zgrief_hudmsg.aligny = "middle";
	zgrief_hudmsg.horzalign = "center";
	zgrief_hudmsg.vertalign = "middle";
	zgrief_hudmsg.y -= 130;
	if ( self issplitscreen() )
	{
		zgrief_hudmsg.y += 70;
	}
	if ( isDefined( offset ) )
	{
		zgrief_hudmsg.y += offset;
	}
	zgrief_hudmsg.foreground = 1;
	zgrief_hudmsg.fontscale = 5;
	zgrief_hudmsg.alpha = 0;
	zgrief_hudmsg.color = ( 1, 1, 1 );
	zgrief_hudmsg.hidewheninmenu = 1;
	zgrief_hudmsg.font = "default";
	if ( isDefined( cleanup_end_game ) && cleanup_end_game )
	{
		level endon( "end_game" );
		zgrief_hudmsg thread show_grief_hud_msg_cleanup();
	}
	if ( isDefined( msg_parm ) )
	{
		zgrief_hudmsg settext( msg, msg_parm );
	}
	else
	{
		zgrief_hudmsg settext( msg );
	}
	zgrief_hudmsg changefontscaleovertime( 0,25 );
	zgrief_hudmsg fadeovertime( 0,25 );
	zgrief_hudmsg.alpha = 1;
	zgrief_hudmsg.fontscale = 2;
	wait 3,25;
	zgrief_hudmsg changefontscaleovertime( 1 );
	zgrief_hudmsg fadeovertime( 1 );
	zgrief_hudmsg.alpha = 0;
	zgrief_hudmsg.fontscale = 5;
	wait 1;
	zgrief_hudmsg notify( "death" );
	if ( isDefined( zgrief_hudmsg ) )
	{
		zgrief_hudmsg destroy();
	}
}

show_grief_hud_msg_cleanup()
{
	self endon( "death" );
	level waittill( "end_game" );
	if ( isDefined( self ) )
	{
		self destroy();
	}
}

grief_reset_message()
{
	msg = &"ZOMBIE_GRIEF_RESET";
	players = get_players();
	if ( isDefined( level.hostmigrationtimer ) )
	{
		while ( isDefined( level.hostmigrationtimer ) )
		{
			wait 0,05;
		}
		wait 4;
	}
	_a697 = players;
	_k697 = getFirstArrayKey( _a697 );
	while ( isDefined( _k697 ) )
	{
		player = _a697[ _k697 ];
		player thread show_grief_hud_msg( msg );
		_k697 = getNextArrayKey( _a697, _k697 );
	}
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "grief_restarted" );
}

grief_laststand_weapon_save( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	self.grief_savedweapon_weapons = self getweaponslist();
	self.grief_savedweapon_weaponsammo_stock = [];
	self.grief_savedweapon_weaponsammo_clip = [];
	self.grief_savedweapon_currentweapon = self getcurrentweapon();
	self.grief_savedweapon_grenades = self get_player_lethal_grenade();
	if ( isDefined( self.grief_savedweapon_grenades ) )
	{
		self.grief_savedweapon_grenades_clip = self getweaponammoclip( self.grief_savedweapon_grenades );
	}
	self.grief_savedweapon_tactical = self get_player_tactical_grenade();
	if ( isDefined( self.grief_savedweapon_tactical ) )
	{
		self.grief_savedweapon_tactical_clip = self getweaponammoclip( self.grief_savedweapon_tactical );
	}
	i = 0;
	while ( i < self.grief_savedweapon_weapons.size )
	{
		self.grief_savedweapon_weaponsammo_clip[ i ] = self getweaponammoclip( self.grief_savedweapon_weapons[ i ] );
		self.grief_savedweapon_weaponsammo_stock[ i ] = self getweaponammostock( self.grief_savedweapon_weapons[ i ] );
		i++;
	}
	if ( isDefined( self.hasriotshield ) && self.hasriotshield )
	{
		self.grief_hasriotshield = 1;
	}
	if ( self hasweapon( "claymore_zm" ) )
	{
		self.grief_savedweapon_claymore = 1;
		self.grief_savedweapon_claymore_clip = self getweaponammoclip( "claymore_zm" );
	}
	if ( isDefined( self.current_equipment ) )
	{
		self.grief_savedweapon_equipment = self.current_equipment;
	}
}

grief_laststand_weapons_return()
{
	if ( isDefined( level.isresetting_grief ) && !level.isresetting_grief )
	{
		return 0;
	}
	if ( !isDefined( self.grief_savedweapon_weapons ) )
	{
		return 0;
	}
	primary_weapons_returned = 0;
	_a766 = self.grief_savedweapon_weapons;
	index = getFirstArrayKey( _a766 );
	while ( isDefined( index ) )
	{
		weapon = _a766[ index ];
		if ( isDefined( self.grief_savedweapon_grenades ) || weapon == self.grief_savedweapon_grenades && isDefined( self.grief_savedweapon_tactical ) && weapon == self.grief_savedweapon_tactical )
		{
		}
		else
		{
			if ( isweaponprimary( weapon ) )
			{
				if ( primary_weapons_returned >= 2 )
				{
					break;
				}
				else primary_weapons_returned++;
			}
			if ( weapon == "item_meat_zm" )
			{
				break;
			}
			else
			{
				self giveweapon( weapon, 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
				if ( isDefined( self.grief_savedweapon_weaponsammo_clip[ index ] ) )
				{
					self setweaponammoclip( weapon, self.grief_savedweapon_weaponsammo_clip[ index ] );
				}
				if ( isDefined( self.grief_savedweapon_weaponsammo_stock[ index ] ) )
				{
					self setweaponammostock( weapon, self.grief_savedweapon_weaponsammo_stock[ index ] );
				}
			}
		}
		index = getNextArrayKey( _a766, index );
	}
	if ( isDefined( self.grief_savedweapon_grenades ) )
	{
		self giveweapon( self.grief_savedweapon_grenades );
		if ( isDefined( self.grief_savedweapon_grenades_clip ) )
		{
			self setweaponammoclip( self.grief_savedweapon_grenades, self.grief_savedweapon_grenades_clip );
		}
	}
	if ( isDefined( self.grief_savedweapon_tactical ) )
	{
		self giveweapon( self.grief_savedweapon_tactical );
		if ( isDefined( self.grief_savedweapon_tactical_clip ) )
		{
			self setweaponammoclip( self.grief_savedweapon_tactical, self.grief_savedweapon_tactical_clip );
		}
	}
	if ( isDefined( self.current_equipment ) )
	{
		self maps/mp/zombies/_zm_equipment::equipment_take( self.current_equipment );
	}
	if ( isDefined( self.grief_savedweapon_equipment ) )
	{
		self.do_not_display_equipment_pickup_hint = 1;
		self maps/mp/zombies/_zm_equipment::equipment_give( self.grief_savedweapon_equipment );
		self.do_not_display_equipment_pickup_hint = undefined;
	}
	if ( isDefined( self.grief_hasriotshield ) && self.grief_hasriotshield )
	{
		if ( isDefined( self.player_shield_reset_health ) )
		{
			self [[ self.player_shield_reset_health ]]();
		}
	}
	if ( isDefined( self.grief_savedweapon_claymore ) && self.grief_savedweapon_claymore )
	{
		self giveweapon( "claymore_zm" );
		self set_player_placeable_mine( "claymore_zm" );
		self setactionslot( 4, "weapon", "claymore_zm" );
		self setweaponammoclip( "claymore_zm", self.grief_savedweapon_claymore_clip );
	}
	primaries = self getweaponslistprimaries();
	_a859 = primaries;
	_k859 = getFirstArrayKey( _a859 );
	while ( isDefined( _k859 ) )
	{
		weapon = _a859[ _k859 ];
		if ( isDefined( self.grief_savedweapon_currentweapon ) && self.grief_savedweapon_currentweapon == weapon )
		{
			self switchtoweapon( weapon );
			return 1;
		}
		_k859 = getNextArrayKey( _a859, _k859 );
	}
	if ( primaries.size > 0 )
	{
		self switchtoweapon( primaries[ 0 ] );
		return 1;
	}
/#
	assert( primaries.size > 0, "GRIEF: There was a problem restoring the weapons" );
#/
	return 0;
}

grief_store_player_scores()
{
	players = get_players();
	_a883 = players;
	_k883 = getFirstArrayKey( _a883 );
	while ( isDefined( _k883 ) )
	{
		player = _a883[ _k883 ];
		player._pre_round_score = player.score;
		_k883 = getNextArrayKey( _a883, _k883 );
	}
}

grief_restore_player_score()
{
	if ( !isDefined( self._pre_round_score ) )
	{
		self._pre_round_score = self.score;
	}
	if ( isDefined( self._pre_round_score ) )
	{
		self.score = self._pre_round_score;
		self.pers[ "score" ] = self._pre_round_score;
	}
}

game_mode_spawn_player_logic()
{
	if ( flag( "start_zombie_round_logic" ) && !isDefined( self.is_hotjoin ) )
	{
		self.is_hotjoin = 1;
		return 1;
	}
	return 0;
}

update_players_on_bleedout_or_disconnect( excluded_player )
{
	other_team = undefined;
	players = get_players();
	players_remaining = 0;
	_a920 = players;
	_k920 = getFirstArrayKey( _a920 );
	while ( isDefined( _k920 ) )
	{
		player = _a920[ _k920 ];
		if ( player == excluded_player )
		{
		}
		else if ( player.team == excluded_player.team )
		{
			if ( is_player_valid( player ) )
			{
				players_remaining++;
			}
			break;
		}
		_k920 = getNextArrayKey( _a920, _k920 );
	}
	_a937 = players;
	_k937 = getFirstArrayKey( _a937 );
	while ( isDefined( _k937 ) )
	{
		player = _a937[ _k937 ];
		if ( player == excluded_player )
		{
		}
		else if ( player.team != excluded_player.team )
		{
			other_team = player.team;
			if ( players_remaining < 1 )
			{
				player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_ALL_PLAYERS_DOWN", undefined, undefined, 1 );
				player delay_thread_watch_host_migrate( 2, ::show_grief_hud_msg, &"ZOMBIE_ZGRIEF_SURVIVE", undefined, 30, 1 );
				break;
			}
			else
			{
				player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_PLAYER_BLED_OUT", players_remaining );
			}
		}
		_k937 = getNextArrayKey( _a937, _k937 );
	}
	if ( players_remaining == 1 )
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "last_player", excluded_player.team );
	}
	if ( !isDefined( other_team ) )
	{
		return;
	}
	if ( players_remaining < 1 )
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "4_player_down", other_team );
	}
	else
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( players_remaining + "_player_left", other_team );
	}
}

delay_thread_watch_host_migrate( timer, func, param1, param2, param3, param4, param5, param6 )
{
	self thread _delay_thread_watch_host_migrate_proc( func, timer, param1, param2, param3, param4, param5, param6 );
}

_delay_thread_watch_host_migrate_proc( func, timer, param1, param2, param3, param4, param5, param6 )
{
	self endon( "death" );
	self endon( "disconnect" );
	wait timer;
	if ( isDefined( level.hostmigrationtimer ) )
	{
		while ( isDefined( level.hostmigrationtimer ) )
		{
			wait 0,05;
		}
		wait timer;
	}
	single_thread( self, func, param1, param2, param3, param4, param5, param6 );
}

grief_round_end_custom_logic()
{
	waittillframeend;
	if ( isDefined( level.gamemodulewinningteam ) )
	{
		level notify( "end_round_think" );
	}
}
