#include maps/mp/gametypes_zm/_spawnlogic;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/_visionset_mgr;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	level.turnedmeleeweapon = "zombiemelee_zm";
	level.turnedmeleeweapon_dw = "zombiemelee_dw";
	precacheitem( level.turnedmeleeweapon );
	precacheitem( level.turnedmeleeweapon_dw );
	precachemodel( "c_zom_player_zombie_fb" );
	precachemodel( "c_zom_zombie_viewhands" );
	if ( !isDefined( level.vsmgr_prio_visionset_zombie_turned ) )
	{
		level.vsmgr_prio_visionset_zombie_turned = 123;
	}
	maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_turned", 3000, level.vsmgr_prio_visionset_zombie_turned, 1, 1 );
	registerclientfield( "toplayer", "turned_ir", 3000, 1, "int" );
	registerclientfield( "allplayers", "player_has_eyes", 3000, 1, "int" );
	registerclientfield( "allplayers", "player_eyes_special", 5000, 1, "int" );
	level._effect[ "player_eye_glow" ] = loadfx( "maps/zombie/fx_zombie_eye_returned_blue" );
	level._effect[ "player_eye_glow_orng" ] = loadfx( "maps/zombie/fx_zombie_eye_returned_orng" );
	thread setup_zombie_exerts();
}

setup_zombie_exerts()
{
	wait 0,05;
	level.exert_sounds[ 1 ][ "burp" ] = "null";
	level.exert_sounds[ 1 ][ "hitmed" ] = "null";
	level.exert_sounds[ 1 ][ "hitlrg" ] = "null";
}

delay_turning_on_eyes()
{
	self endon( "death" );
	self endon( "disconnect" );
	wait_network_frame();
	wait 0,1;
	self setclientfield( "player_has_eyes", 1 );
}

turn_to_zombie()
{
	if ( self.sessionstate == "playing" && isDefined( self.is_zombie ) && self.is_zombie && isDefined( self.laststand ) && !self.laststand )
	{
		return;
	}
	if ( isDefined( self.is_in_process_of_zombify ) && self.is_in_process_of_zombify )
	{
		return;
	}
	while ( isDefined( self.is_in_process_of_humanify ) && self.is_in_process_of_humanify )
	{
		wait 0,1;
	}
	if ( !flag( "pregame" ) )
	{
		self playsoundtoplayer( "evt_spawn", self );
		playsoundatposition( "evt_disappear_3d", self.origin );
		if ( !self.is_zombie )
		{
			playsoundatposition( "vox_plr_" + randomintrange( 0, 4 ) + "_exert_death_high_" + randomintrange( 0, 4 ), self.origin );
		}
	}
	self._can_score = 1;
	self setclientfield( "player_has_eyes", 0 );
	self ghost();
	self turned_disable_player_weapons();
	self notify( "clear_red_flashing_overlay" );
	self notify( "zombify" );
	self.is_in_process_of_zombify = 1;
	self.team = level.zombie_team;
	self.pers[ "team" ] = level.zombie_team;
	self.sessionteam = level.zombie_team;
	wait_network_frame();
	self maps/mp/gametypes_zm/_zm_gametype::onspawnplayer();
	self freezecontrols( 1 );
	self.is_zombie = 1;
	self setburn( 0 );
	if ( isDefined( self.turned_visionset ) && self.turned_visionset )
	{
		maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_turned", self );
		wait_network_frame();
		wait_network_frame();
		if ( !isDefined( self ) )
		{
			return;
		}
	}
	maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_turned", self );
	self.turned_visionset = 1;
	self setclientfieldtoplayer( "turned_ir", 1 );
	self maps/mp/zombies/_zm_audio::setexertvoice( 1 );
	self.laststand = undefined;
	wait_network_frame();
	if ( !isDefined( self ) )
	{
		return;
	}
	self enableweapons();
	self show();
	playsoundatposition( "evt_appear_3d", self.origin );
	playsoundatposition( "zmb_zombie_spawn", self.origin );
	self thread delay_turning_on_eyes();
	self thread turned_player_buttons();
	self setperk( "specialty_noname" );
	self setperk( "specialty_unlimitedsprint" );
	self setperk( "specialty_fallheight" );
	self turned_give_melee_weapon();
	self setmovespeedscale( 1 );
	self.animname = "zombie";
	self disableoffhandweapons();
	self allowstand( 1 );
	self allowprone( 0 );
	self allowcrouch( 0 );
	self allowads( 0 );
	self allowjump( 0 );
	self disableweaponcycling();
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
	self stopshellshock();
	self.maxhealth = 256;
	self.health = 256;
	self.meleedamage = 1000;
	self detachall();
	self setmodel( "c_zom_player_zombie_fb" );
	self.voice = "american";
	self.skeleton = "base";
	self setviewmodel( "c_zom_zombie_viewhands" );
	self.shock_onpain = 0;
	self disableinvulnerability();
	if ( isDefined( level.player_movement_suppressed ) )
	{
		self freezecontrols( level.player_movement_suppressed );
	}
	else
	{
		self freezecontrols( 0 );
	}
	self.is_in_process_of_zombify = 0;
}

turn_to_human()
{
	if ( self.sessionstate == "playing" && isDefined( self.is_zombie ) && !self.is_zombie && isDefined( self.laststand ) && !self.laststand )
	{
		return;
	}
	if ( isDefined( self.is_in_process_of_humanify ) && self.is_in_process_of_humanify )
	{
		return;
	}
	while ( isDefined( self.is_in_process_of_zombify ) && self.is_in_process_of_zombify )
	{
		wait 0,1;
	}
	self playsoundtoplayer( "evt_spawn", self );
	playsoundatposition( "evt_disappear_3d", self.origin );
	self setclientfield( "player_has_eyes", 0 );
	self ghost();
	self notify( "humanify" );
	self.is_in_process_of_humanify = 1;
	self.is_zombie = 0;
	self notify( "clear_red_flashing_overlay" );
	self.team = self.prevteam;
	self.pers[ "team" ] = self.prevteam;
	self.sessionteam = self.prevteam;
	wait_network_frame();
	self maps/mp/gametypes_zm/_zm_gametype::onspawnplayer();
	self.maxhealth = 100;
	self.health = 100;
	self freezecontrols( 1 );
	if ( self hasweapon( "death_throe_zm" ) )
	{
		self takeweapon( "death_throe_zm" );
	}
	self unsetperk( "specialty_noname" );
	self unsetperk( "specialty_unlimitedsprint" );
	self unsetperk( "specialty_fallheight" );
	self turned_enable_player_weapons();
	self maps/mp/zombies/_zm_audio::setexertvoice( 0 );
	self.turned_visionset = 0;
	maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_turned", self );
	self setclientfieldtoplayer( "turned_ir", 0 );
	self setmovespeedscale( 1 );
	self.ignoreme = 0;
	self.shock_onpain = 1;
	self enableweaponcycling();
	self allowstand( 1 );
	self allowprone( 1 );
	self allowcrouch( 1 );
	self allowads( 1 );
	self allowjump( 1 );
	self turnedhuman();
	self enableoffhandweapons();
	self stopshellshock();
	self.laststand = undefined;
	self.is_burning = undefined;
	self.meleedamage = undefined;
	self detachall();
	self [[ level.givecustomcharacters ]]();
	if ( !self hasweapon( "knife_zm" ) )
	{
		self giveweapon( "knife_zm" );
	}
	wait_network_frame();
	if ( !isDefined( self ) )
	{
		return;
	}
	self disableinvulnerability();
	if ( isDefined( level.player_movement_suppressed ) )
	{
		self freezecontrols( level.player_movement_suppressed );
	}
	else
	{
		self freezecontrols( 0 );
	}
	self show();
	playsoundatposition( "evt_appear_3d", self.origin );
	self.is_in_process_of_humanify = 0;
}

deletezombiesinradius( origin )
{
	zombies = get_round_enemy_array();
	maxradius = 128;
	_a301 = zombies;
	_k301 = getFirstArrayKey( _a301 );
	while ( isDefined( _k301 ) )
	{
		zombie = _a301[ _k301 ];
		if ( isDefined( zombie ) && isalive( zombie ) && isDefined( zombie.is_being_used_as_spawner ) && !zombie.is_being_used_as_spawner )
		{
			if ( distancesquared( zombie.origin, origin ) < ( maxradius * maxradius ) )
			{
				playfx( level._effect[ "wood_chunk_destory" ], zombie.origin );
				zombie thread silentlyremovezombie();
			}
			wait 0,05;
		}
		_k301 = getNextArrayKey( _a301, _k301 );
	}
}

turned_give_melee_weapon()
{
/#
	assert( isDefined( self.turnedmeleeweapon ) );
#/
/#
	assert( self.turnedmeleeweapon != "none" );
#/
	self.turned_had_knife = self hasweapon( "knife_zm" );
	if ( isDefined( self.turned_had_knife ) && self.turned_had_knife )
	{
		self takeweapon( "knife_zm" );
	}
	self giveweapon( self.turnedmeleeweapon_dw );
	self givemaxammo( self.turnedmeleeweapon_dw );
	self giveweapon( self.turnedmeleeweapon );
	self givemaxammo( self.turnedmeleeweapon );
	self switchtoweapon( self.turnedmeleeweapon_dw );
	self switchtoweapon( self.turnedmeleeweapon );
}

turned_player_buttons()
{
	self endon( "disconnect" );
	self endon( "humanify" );
	level endon( "end_game" );
	while ( isDefined( self.is_zombie ) && self.is_zombie )
	{
		while ( !self attackbuttonpressed() || self adsbuttonpressed() && self meleebuttonpressed() )
		{
			if ( cointoss() )
			{
				self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "attack", undefined );
			}
			while ( !self attackbuttonpressed() || self adsbuttonpressed() && self meleebuttonpressed() )
			{
				wait 0,05;
			}
		}
		while ( self usebuttonpressed() )
		{
			self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "taunt", undefined );
			while ( self usebuttonpressed() )
			{
				wait 0,05;
			}
		}
		while ( self issprinting() )
		{
			while ( self issprinting() )
			{
				self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "sprint", undefined );
				wait 0,05;
			}
		}
		wait 0,05;
	}
}

turned_disable_player_weapons()
{
	if ( isDefined( self.is_zombie ) && self.is_zombie )
	{
		return;
	}
	weaponinventory = self getweaponslist();
	self.lastactiveweapon = self getcurrentweapon();
	self setlaststandprevweap( self.lastactiveweapon );
	self.laststandpistol = undefined;
	self.hadpistol = 0;
	if ( !isDefined( self.turnedmeleeweapon ) )
	{
		self.turnedmeleeweapon = level.turnedmeleeweapon;
	}
	if ( !isDefined( self.turnedmeleeweapon_dw ) )
	{
		self.turnedmeleeweapon_dw = level.turnedmeleeweapon_dw;
	}
	self takeallweapons();
	self disableweaponcycling();
}

turned_enable_player_weapons()
{
	self takeallweapons();
	self enableweaponcycling();
	self enableoffhandweapons();
	self.turned_had_knife = undefined;
	if ( isDefined( level.humanify_custom_loadout ) )
	{
		self thread [[ level.humanify_custom_loadout ]]();
		return;
	}
	else
	{
		if ( !self hasweapon( "rottweil72_zm" ) )
		{
			self giveweapon( "rottweil72_zm" );
			self switchtoweapon( "rottweil72_zm" );
		}
	}
	if ( isDefined( self.is_zombie ) && !self.is_zombie && !self hasweapon( level.start_weapon ) )
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

get_farthest_available_zombie( player )
{
	while ( 1 )
	{
		zombies = get_array_of_closest( player.origin, getaiarray( level.zombie_team ) );
		x = 0;
		while ( x < zombies.size )
		{
			zombie = zombies[ x ];
			if ( isDefined( zombie ) && isalive( zombie ) && isDefined( zombie.in_the_ground ) && !zombie.in_the_ground && isDefined( zombie.gibbed ) && !zombie.gibbed && isDefined( zombie.head_gibbed ) && !zombie.head_gibbed && isDefined( zombie.is_being_used_as_spawnpoint ) && !zombie.is_being_used_as_spawnpoint && zombie in_playable_area() )
			{
				zombie.is_being_used_as_spawnpoint = 1;
				return zombie;
			}
			x++;
		}
		wait 0,05;
	}
}

get_available_human()
{
	players = get_players();
	_a512 = players;
	_k512 = getFirstArrayKey( _a512 );
	while ( isDefined( _k512 ) )
	{
		player = _a512[ _k512 ];
		if ( isDefined( player.is_zombie ) && !player.is_zombie )
		{
			return player;
		}
		_k512 = getNextArrayKey( _a512, _k512 );
	}
}

silentlyremovezombie()
{
	self.skip_death_notetracks = 1;
	self.nodeathragdoll = 1;
	self dodamage( self.maxhealth * 2, self.origin, self, self, "none", "MOD_SUICIDE" );
	self self_delete();
}

getspawnpoint()
{
	spawnpoint = self maps/mp/gametypes_zm/_spawnlogic::getspawnpoint_dm( level._turned_zombie_respawnpoints );
	return spawnpoint;
}
