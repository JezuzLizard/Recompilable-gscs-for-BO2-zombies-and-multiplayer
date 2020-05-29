#include maps/mp/_scoreevents;
#include maps/mp/gametypes/_hud;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/killstreaks/_airsupport;
#include maps/mp/killstreaks/_killstreaks;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	precacheitem( "remote_missile_missile_mp" );
	precacheitem( "remote_missile_bomblet_mp" );
	precacheshader( "mp_hud_cluster_status" );
	precacheshader( "mp_hud_armed" );
	precacheshader( "mp_hud_deployed" );
	precacheshader( "reticle_side_round_big_top" );
	precacheshader( "reticle_side_round_big_right" );
	precacheshader( "reticle_side_round_big_left" );
	precacheshader( "reticle_side_round_big_bottom" );
	precacheshader( "hud_remote_missile_target" );
	level.rockets = [];
	registerkillstreak( "remote_missile_mp", "remote_missile_mp", "killstreak_remote_missile", "remote_missle_used", ::tryusepredatormissile, 1 );
	registerkillstreakaltweapon( "remote_missile_mp", "remote_missile_missile_mp" );
	registerkillstreakaltweapon( "remote_missile_mp", "remote_missile_bomblet_mp" );
	registerkillstreakstrings( "remote_missile_mp", &"KILLSTREAK_EARNED_REMOTE_MISSILE", &"KILLSTREAK_REMOTE_MISSILE_NOT_AVAILABLE", &"KILLSTREAK_REMOTE_MISSILE_INBOUND" );
	registerkillstreakdialog( "remote_missile_mp", "mpl_killstreak_cruisemissile", "kls_predator_used", "", "", "", "kls_predator_ready" );
	registerkillstreakdevdvar( "remote_missile_mp", "scr_givemissileremote" );
	setkillstreakteamkillpenaltyscale( "remote_missile_mp", level.teamkillreducedpenalty );
	overrideentitycameraindemo( "remote_missile_mp", 1 );
	registerclientfield( "missile", "remote_missile_bomblet_fired", 1, 1, "int" );
	registerclientfield( "missile", "remote_missile_fired", 1, 2, "int" );
	level.missilesforsighttraces = [];
	level.missileremotedeployfx = loadfx( "weapon/predator/fx_predator_cluster_trigger" );
	level.missileremotelaunchvert = 18000;
	level.missileremotelaunchhorz = 7000;
	level.missileremotelaunchtargetdist = 1500;
}

remote_missile_game_end_think( missile, team, killstreak_id, snd_first, snd_third )
{
	missile endon( "deleted" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	self endon( "disconnect" );
	self endon( "Remotemissle_killstreak_done" );
	level waittill( "game_ended" );
	missile_end_sounds( missile, snd_first, snd_third );
	self player_missile_end( missile, 1, 1 );
	maps/mp/killstreaks/_killstreakrules::killstreakstop( "remote_missile_mp", team, killstreak_id );
	if ( isDefined( missile ) )
	{
		missile delete();
	}
	self notify( "Remotemissle_killstreak_done" );
}

tryusepredatormissile( lifeid )
{
	if ( !self isonground() || self isusingremote() )
	{
		self iprintlnbold( &"KILLSTREAK_REMOTE_MISSILE_NOT_USABLE" );
		return 0;
	}
	team = self.team;
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( "remote_missile_mp", team, 0, 1 );
	if ( killstreak_id == -1 )
	{
		return 0;
	}
	returnvar = _fire( lifeid, self, team, killstreak_id );
	return returnvar;
}

getbestspawnpoint( remotemissilespawnpoints )
{
	validenemies = [];
	_a102 = remotemissilespawnpoints;
	_k102 = getFirstArrayKey( _a102 );
	while ( isDefined( _k102 ) )
	{
		spawnpoint = _a102[ _k102 ];
		spawnpoint.validplayers = [];
		spawnpoint.spawnscore = 0;
		_k102 = getNextArrayKey( _a102, _k102 );
	}
	_a108 = level.players;
	_k108 = getFirstArrayKey( _a108 );
	while ( isDefined( _k108 ) )
	{
		player = _a108[ _k108 ];
		if ( !isalive( player ) )
		{
		}
		else if ( player.team == self.team )
		{
		}
		else if ( player.team == "spectator" )
		{
		}
		else
		{
			bestdistance = 999999999;
			bestspawnpoint = undefined;
			_a122 = remotemissilespawnpoints;
			_k122 = getFirstArrayKey( _a122 );
			while ( isDefined( _k122 ) )
			{
				spawnpoint = _a122[ _k122 ];
				spawnpoint.validplayers[ spawnpoint.validplayers.size ] = player;
				potentialbestdistance = distance2dsquared( spawnpoint.targetent.origin, player.origin );
				if ( potentialbestdistance <= bestdistance )
				{
					bestdistance = potentialbestdistance;
					bestspawnpoint = spawnpoint;
				}
				_k122 = getNextArrayKey( _a122, _k122 );
			}
			bestspawnpoint.spawnscore += 2;
		}
		_k108 = getNextArrayKey( _a108, _k108 );
	}
	bestspawn = remotemissilespawnpoints[ 0 ];
	_a140 = remotemissilespawnpoints;
	_k140 = getFirstArrayKey( _a140 );
	while ( isDefined( _k140 ) )
	{
		spawnpoint = _a140[ _k140 ];
		_a142 = spawnpoint.validplayers;
		_k142 = getFirstArrayKey( _a142 );
		while ( isDefined( _k142 ) )
		{
			player = _a142[ _k142 ];
			spawnpoint.spawnscore += 1;
			if ( bullettracepassed( player.origin + vectorScale( ( 0, 0, 1 ), 32 ), spawnpoint.origin, 0, player ) )
			{
				spawnpoint.spawnscore += 3;
			}
			if ( spawnpoint.spawnscore > bestspawn.spawnscore )
			{
				bestspawn = spawnpoint;
			}
			else
			{
				if ( spawnpoint.spawnscore == bestspawn.spawnscore )
				{
					if ( cointoss() )
					{
						bestspawn = spawnpoint;
					}
				}
			}
			_k142 = getNextArrayKey( _a142, _k142 );
		}
		_k140 = getNextArrayKey( _a140, _k140 );
	}
	return bestspawn;
}

drawline( start, end, timeslice, color )
{
/#
	drawtime = int( timeslice * 20 );
	time = 0;
	while ( time < drawtime )
	{
		line( start, end, color, 0, 1 );
		wait 0,05;
		time++;
#/
	}
}

_fire( lifeid, player, team, killstreak_id )
{
	remotemissilespawnarray = getentarray( "remoteMissileSpawn", "targetname" );
	_a180 = remotemissilespawnarray;
	_k180 = getFirstArrayKey( _a180 );
	while ( isDefined( _k180 ) )
	{
		spawn = _a180[ _k180 ];
		if ( isDefined( spawn.target ) )
		{
			spawn.targetent = getent( spawn.target, "targetname" );
		}
		_k180 = getNextArrayKey( _a180, _k180 );
	}
	if ( remotemissilespawnarray.size > 0 )
	{
		remotemissilespawn = player getbestspawnpoint( remotemissilespawnarray );
	}
	else
	{
		remotemissilespawn = undefined;
	}
	if ( isDefined( remotemissilespawn ) )
	{
		startpos = remotemissilespawn.origin;
		targetpos = remotemissilespawn.targetent.origin;
		vector = vectornormalize( startpos - targetpos );
		startpos = ( vector * level.missileremotelaunchvert ) + targetpos;
	}
	else
	{
		upvector = ( 0, 0, level.missileremotelaunchvert );
		backdist = level.missileremotelaunchhorz;
		targetdist = level.missileremotelaunchtargetdist;
		forward = anglesToForward( player.angles );
		startpos = ( player.origin + upvector ) + ( forward * backdist * -1 );
		targetpos = player.origin + ( forward * targetdist );
	}
	player.killstreak_waitamount = 10;
	self setusingremote( "remote_missile_mp" );
	self freezecontrolswrapper( 1 );
	player disableweaponcycling();
	result = self maps/mp/killstreaks/_killstreaks::initridekillstreak( "qrdrone" );
	if ( result != "success" )
	{
		if ( result != "disconnect" )
		{
			player freezecontrolswrapper( 0 );
			player clearusingremote();
			player enableweaponcycling();
			player.killstreak_waitamount = undefined;
			maps/mp/killstreaks/_killstreakrules::killstreakstop( "remote_missile_mp", team, killstreak_id );
		}
		return 0;
	}
	rocket = magicbullet( "remote_missile_missile_mp", startpos, targetpos, player );
	forceanglevector = vectornormalize( targetpos - startpos );
	rocket.angles = vectorToAngle( forceanglevector );
	rocket.targetname = "remote_missile";
	rocket.team = team;
	rocket setteam( team );
	rocket thread handledamage();
	player linktomissile( rocket, 1 );
	rocket.owner = player;
	rocket.killcament = player;
	player thread cleanupwaiter( rocket, player.team, killstreak_id, rocket.snd_first, rocket.snd_third );
	if ( isDefined( level.remote_missile_vision ) )
	{
		self useservervisionset( 1 );
		self setvisionsetforplayer( level.remote_missile_vision, 1 );
	}
	self setclientflag( 2 );
	self maps/mp/killstreaks/_killstreaks::playkillstreakstartdialog( "remote_missile_mp", self.pers[ "team" ] );
	level.globalkillstreakscalled++;
	self addweaponstat( "remote_missile_mp", "used", 1 );
	rocket thread setup_rockect_map_icon();
	rocket missile_sound_play( player );
	rocket thread missile_timeout_watch();
	rocket thread missile_sound_impact( player, 4000 );
	player thread missile_sound_boost( rocket );
	player thread missile_deploy_watch( rocket );
	player thread watchownerteamkillkicked( rocket );
	player thread remote_missile_game_end_think( rocket, player.team, killstreak_id, rocket.snd_first, rocket.snd_third );
	player thread watch_missile_death( rocket, player.team, killstreak_id, rocket.snd_first, rocket.snd_third );
	rocket maps/mp/gametypes/_spawning::create_tvmissile_influencers( team );
	player freezecontrolswrapper( 0 );
	player clearusingremote();
	player enableweaponcycling();
	player waittill( "Remotemissle_killstreak_done" );
	return 1;
}

setup_rockect_map_icon()
{
	wait 0,1;
	self setclientfield( "remote_missile_fired", 1 );
}

watchownerteamkillkicked( rocket )
{
	rocket endon( "death" );
	rocket endon( "deleted" );
	self waittill( "teamKillKicked" );
	rocket remove_tvmissile_influencers();
	rocket detonate();
}

watch_missile_death( rocket, team, killstreak_id, snd_first, snd_third )
{
	level endon( "game_ended" );
	rocket endon( "deleted" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	self endon( "disconnect" );
	rocket waittill( "death" );
	missile_end_sounds( rocket, snd_first, snd_third );
	self player_missile_end( rocket, 1, 1 );
	maps/mp/killstreaks/_killstreakrules::killstreakstop( "remote_missile_mp", team, killstreak_id );
	self notify( "Remotemissle_killstreak_done" );
}

player_missile_end( rocket, performplayerkillstreakend, unlink )
{
	if ( isDefined( self ) )
	{
		self thread destroy_missile_hud();
		if ( isDefined( performplayerkillstreakend ) && performplayerkillstreakend )
		{
			self playrumbleonentity( "grenade_rumble" );
			if ( level.gameended == 0 )
			{
				self sendkillstreakdamageevent( 600 );
				self thread maps/mp/gametypes/_hud::fadetoblackforxsec( 0, 0,25, 0,1, 0,25 );
				wait 0,25;
			}
			if ( isDefined( rocket ) )
			{
				rocket hide();
			}
		}
		self clearclientflag( 2 );
		self useservervisionset( 0 );
		if ( unlink )
		{
			self unlinkfrommissile();
		}
		self notify( "remotemissile_done" );
		self freezecontrolswrapper( 0 );
		self clearusingremote();
		self enableweaponcycling();
		if ( isDefined( self ) )
		{
			self.killstreak_waitamount = undefined;
		}
	}
}

missile_end_sounds( rocket, snd_first, snd_third )
{
	if ( isDefined( rocket ) )
	{
		rocket maps/mp/gametypes/_spawning::remove_tvmissile_influencers();
		rocket missile_sound_stop();
	}
	else
	{
		if ( isDefined( snd_first ) )
		{
			snd_first delete();
		}
		if ( isDefined( snd_third ) )
		{
			snd_third delete();
		}
	}
}

missile_timeout_watch()
{
	self endon( "death" );
	wait 9,95;
	if ( isDefined( self ) )
	{
		self maps/mp/gametypes/_spawning::remove_tvmissile_influencers();
		self missile_sound_stop();
	}
}

cleanupwaiter( rocket, team, killstreak_id, snd_first, snd_third )
{
	rocket endon( "death" );
	rocket endon( "deleted" );
	self waittill_any( "joined_team", "joined_spectators", "disconnect" );
	missile_end_sounds( rocket, snd_first, snd_third );
	self player_missile_end( rocket, 0, 0 );
	maps/mp/killstreaks/_killstreakrules::killstreakstop( "remote_missile_mp", team, killstreak_id );
	if ( isDefined( rocket ) )
	{
		rocket delete();
	}
	self notify( "Remotemissle_killstreak_done" );
}

_fire_noplayer( lifeid, player )
{
/#
	upvector = ( 0, 0, level.missileremotelaunchvert );
	backdist = level.missileremotelaunchhorz;
	targetdist = level.missileremotelaunchtargetdist;
	forward = anglesToForward( player.angles );
	startpos = ( player.origin + upvector ) + ( forward * backdist * -1 );
	targetpos = player.origin + ( forward * targetdist );
	rocket = magicbullet( "remotemissile_projectile_mp", startpos, targetpos, player );
	if ( !isDefined( rocket ) )
	{
		return;
	}
	rocket thread handledamage();
	rocket.lifeid = lifeid;
	rocket.type = "remote";
	rocket thread rocket_cleanupondeath();
	wait 2;
#/
}

handledamage()
{
	self endon( "death" );
	self endon( "deleted" );
	self setcandamage( 1 );
	self.health = 99999;
	for ( ;; )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, meansofdeath, tagname, modelname, partname, weapon );
		if ( isDefined( attacker ) && isDefined( self.owner ) )
		{
			if ( self.owner isenemyplayer( attacker ) )
			{
				maps/mp/_scoreevents::processscoreevent( "destroyed_remote_missile", attacker, self.owner, weapon );
				attacker addweaponstat( weapon, "destroyed_controlled_killstreak", 1 );
				break;
			}
			self.owner sendkillstreakdamageevent( int( damage ) );
		}
		self remove_tvmissile_influencers();
		self detonate();
	}
}

staticeffect( duration )
{
	self endon( "disconnect" );
	staticbg = newclienthudelem( self );
	staticbg.horzalign = "fullscreen";
	staticbg.vertalign = "fullscreen";
	staticbg setshader( "white", 640, 480 );
	staticbg.archive = 1;
	staticbg.sort = 10;
	staticbg.immunetodemogamehudsettings = 1;
	static = newclienthudelem( self );
	static.horzalign = "fullscreen";
	static.vertalign = "fullscreen";
	static.archive = 1;
	static.sort = 20;
	static.immunetodemogamehudsettings = 1;
	self setclientflag( 4 );
	wait duration;
	self clearclientflag( 4 );
	static destroy();
	staticbg destroy();
}

rocket_cleanupondeath()
{
	entitynumber = self getentitynumber();
	level.rockets[ entitynumber ] = self;
	self waittill( "death" );
}

missile_sound_play( player )
{
	snd_first_person = spawn( "script_model", self.origin );
	snd_first_person setmodel( "tag_origin" );
	snd_first_person linkto( self );
	snd_first_person setinvisibletoall();
	snd_first_person setvisibletoplayer( player );
	snd_first_person playloopsound( "wpn_remote_missile_loop_plr", 0,5 );
	self.snd_first = snd_first_person;
	snd_third_person = spawn( "script_model", self.origin );
	snd_third_person setmodel( "tag_origin" );
	snd_third_person linkto( self );
	snd_third_person setvisibletoall();
	snd_third_person setinvisibletoplayer( player );
	snd_third_person playloopsound( "wpn_remote_missile_loop_npc", 0,2 );
	self.snd_third = snd_third_person;
}

missile_sound_boost( rocket )
{
	self endon( "remotemissile_done" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	self endon( "disconnect" );
	self waittill( "missile_boost" );
	rocket.snd_first playloopsound( "wpn_remote_missile_boost_plr" );
	rocket.snd_first playsound( "wpn_remote_missile_fire_boost" );
	self playrumbleonentity( "sniper_fire" );
	if ( ( rocket.origin[ 2 ] - self.origin[ 2 ] ) > 4000 )
	{
		rocket notify( "stop_impact_sound" );
		rocket thread missile_sound_impact( self, 6000 );
	}
}

missile_sound_impact( player, distance )
{
	self endon( "death" );
	self endon( "stop_impact_sound" );
	player endon( "disconnect" );
	player endon( "remotemissile_done" );
	player endon( "joined_team" );
	player endon( "joined_spectators" );
	for ( ;; )
	{
		if ( ( self.origin[ 2 ] - player.origin[ 2 ] ) < distance )
		{
			self playsound( "wpn_remote_missile_inc" );
			return;
		}
		wait 0,05;
	}
}

missile_sound_deploy_bomblets()
{
	self.snd_first playloopsound( "wpn_remote_missile_loop_plr", 0,5 );
}

missile_sound_stop()
{
	self.snd_first delete();
	self.snd_third delete();
}

getvalidtargets( rocket, trace )
{
	pixbeginevent( "remotemissile_getVTs_header" );
	targets = [];
	forward = anglesToForward( rocket.angles );
	rocketz = rocket.origin[ 2 ];
	mapcenterz = level.mapcenter[ 2 ];
	diff = mapcenterz - rocketz;
	ratio = diff / forward[ 2 ];
	aimtarget = rocket.origin + ( forward * ratio );
	rocket.aimtarget = aimtarget;
	pixendevent();
	pixbeginevent( "remotemissile_getVTs_enemies" );
	enemies = self getenemies( 1 );
	_a606 = enemies;
	_k606 = getFirstArrayKey( _a606 );
	while ( isDefined( _k606 ) )
	{
		player = _a606[ _k606 ];
		if ( distance2dsquared( player.origin, aimtarget ) < 360000 && !player hasperk( "specialty_nokillstreakreticle" ) )
		{
			if ( trace )
			{
				if ( bullettracepassed( player.origin + vectorScale( ( 0, 0, 1 ), 60 ), player.origin + vectorScale( ( 0, 0, 1 ), 180 ), 0, player ) )
				{
					targets[ targets.size ] = player;
				}
				break;
			}
			else
			{
				targets[ targets.size ] = player;
			}
		}
		_k606 = getNextArrayKey( _a606, _k606 );
	}
	dogs = getentarray( "attack_dog", "targetname" );
	_a626 = dogs;
	_k626 = getFirstArrayKey( _a626 );
	while ( isDefined( _k626 ) )
	{
		dog = _a626[ _k626 ];
		if ( dog.aiteam != self.team && distance2dsquared( dog.origin, aimtarget ) < 360000 )
		{
			if ( trace )
			{
				if ( bullettracepassed( dog.origin + vectorScale( ( 0, 0, 1 ), 60 ), dog.origin + vectorScale( ( 0, 0, 1 ), 180 ), 0, dog ) )
				{
					targets[ targets.size ] = dog;
				}
				break;
			}
			else
			{
				targets[ targets.size ] = dog;
			}
		}
		_k626 = getNextArrayKey( _a626, _k626 );
	}
	tanks = getentarray( "talon", "targetname" );
	_a646 = tanks;
	_k646 = getFirstArrayKey( _a646 );
	while ( isDefined( _k646 ) )
	{
		tank = _a646[ _k646 ];
		if ( tank.aiteam != self.team && distance2dsquared( tank.origin, aimtarget ) < 360000 )
		{
			if ( trace )
			{
				if ( bullettracepassed( tank.origin + vectorScale( ( 0, 0, 1 ), 60 ), tank.origin + vectorScale( ( 0, 0, 1 ), 180 ), 0, tank ) )
				{
					targets[ targets.size ] = tank;
				}
				break;
			}
			else
			{
				targets[ targets.size ] = tank;
			}
		}
		_k646 = getNextArrayKey( _a646, _k646 );
	}
	turrets = getentarray( "auto_turret", "classname" );
	_a665 = turrets;
	_k665 = getFirstArrayKey( _a665 );
	while ( isDefined( _k665 ) )
	{
		turret = _a665[ _k665 ];
		if ( turret.team != self.team && distance2dsquared( turret.origin, aimtarget ) < 360000 )
		{
			if ( trace )
			{
				if ( bullettracepassed( turret.origin + vectorScale( ( 0, 0, 1 ), 60 ), turret.origin + vectorScale( ( 0, 0, 1 ), 180 ), 0, turret ) )
				{
					targets[ targets.size ] = turret;
				}
				break;
			}
			else
			{
				targets[ targets.size ] = turret;
			}
		}
		_k665 = getNextArrayKey( _a665, _k665 );
	}
	pixendevent();
	return targets;
}

create_missile_hud( rocket )
{
	self.deploy_hud_armed = newclienthudelem( self );
	self.deploy_hud_armed.alignx = "center";
	self.deploy_hud_armed.aligny = "middle";
	self.deploy_hud_armed.horzalign = "user_center";
	self.deploy_hud_armed.vertalign = "user_center";
	self.deploy_hud_armed setshader( "mp_hud_armed", 110, 55 );
	self.deploy_hud_armed.hidewheninmenu = 1;
	self.deploy_hud_armed.immunetodemogamehudsettings = 1;
	self.deploy_hud_armed.x = -25;
	self.deploy_hud_armed.y = 161;
	self.deploy_hud_deployed = newclienthudelem( self );
	self.deploy_hud_deployed.alignx = "center";
	self.deploy_hud_deployed.aligny = "middle";
	self.deploy_hud_deployed.horzalign = "user_center";
	self.deploy_hud_deployed.vertalign = "user_center";
	self.deploy_hud_deployed setshader( "mp_hud_deployed", 110, 55 );
	self.deploy_hud_deployed.hidewheninmenu = 1;
	self.deploy_hud_deployed.immunetodemogamehudsettings = 1;
	self.deploy_hud_deployed.alpha = 0,35;
	self.deploy_hud_deployed.x = 25;
	self.deploy_hud_deployed.y = 161;
	self.missile_reticle_top = newclienthudelem( self );
	self.missile_reticle_top.alignx = "center";
	self.missile_reticle_top.aligny = "middle";
	self.missile_reticle_top.horzalign = "user_center";
	self.missile_reticle_top.vertalign = "user_center";
	self.missile_reticle_top.font = "small";
	self.missile_reticle_top setshader( "reticle_side_round_big_top", 140, 64 );
	self.missile_reticle_top.hidewheninmenu = 0;
	self.missile_reticle_top.immunetodemogamehudsettings = 1;
	self.missile_reticle_top.x = 0;
	self.missile_reticle_top.y = 0;
	self.missile_reticle_bottom = newclienthudelem( self );
	self.missile_reticle_bottom.alignx = "center";
	self.missile_reticle_bottom.aligny = "middle";
	self.missile_reticle_bottom.horzalign = "user_center";
	self.missile_reticle_bottom.vertalign = "user_center";
	self.missile_reticle_bottom.font = "small";
	self.missile_reticle_bottom setshader( "reticle_side_round_big_bottom", 140, 64 );
	self.missile_reticle_bottom.hidewheninmenu = 0;
	self.missile_reticle_bottom.immunetodemogamehudsettings = 1;
	self.missile_reticle_bottom.x = 0;
	self.missile_reticle_bottom.y = 0;
	self.missile_reticle_right = newclienthudelem( self );
	self.missile_reticle_right.alignx = "center";
	self.missile_reticle_right.aligny = "middle";
	self.missile_reticle_right.horzalign = "user_center";
	self.missile_reticle_right.vertalign = "user_center";
	self.missile_reticle_right.font = "small";
	self.missile_reticle_right setshader( "reticle_side_round_big_right", 64, 140 );
	self.missile_reticle_right.hidewheninmenu = 0;
	self.missile_reticle_right.immunetodemogamehudsettings = 1;
	self.missile_reticle_right.x = 0;
	self.missile_reticle_right.y = 0;
	self.missile_reticle_left = newclienthudelem( self );
	self.missile_reticle_left.alignx = "center";
	self.missile_reticle_left.aligny = "middle";
	self.missile_reticle_left.horzalign = "user_center";
	self.missile_reticle_left.vertalign = "user_center";
	self.missile_reticle_left.font = "small";
	self.missile_reticle_left setshader( "reticle_side_round_big_left", 64, 140 );
	self.missile_reticle_left.hidewheninmenu = 0;
	self.missile_reticle_left.immunetodemogamehudsettings = 1;
	self.missile_reticle_left.x = 0;
	self.missile_reticle_left.y = 0;
	self.missile_target_icons = [];
	_a764 = level.players;
	_k764 = getFirstArrayKey( _a764 );
	while ( isDefined( _k764 ) )
	{
		player = _a764[ _k764 ];
		if ( player == self )
		{
		}
		else if ( level.teambased && player.team == self.team )
		{
		}
		else
		{
			index = player.clientid;
			self.missile_target_icons[ index ] = newclienthudelem( self );
			self.missile_target_icons[ index ].x = 0;
			self.missile_target_icons[ index ].y = 0;
			self.missile_target_icons[ index ].z = 0;
			self.missile_target_icons[ index ].alpha = 0;
			self.missile_target_icons[ index ].archived = 1;
			self.missile_target_icons[ index ] setshader( "hud_remote_missile_target", 450, 450 );
			self.missile_target_icons[ index ] setwaypoint( 0 );
			self.missile_target_icons[ index ].hidewheninmenu = 1;
			self.missile_target_icons[ index ].immunetodemogamehudsettings = 1;
		}
		_k764 = getNextArrayKey( _a764, _k764 );
	}
	i = 0;
	while ( i < 3 )
	{
		self.missile_target_other[ i ] = newclienthudelem( self );
		self.missile_target_other[ i ].x = 0;
		self.missile_target_other[ i ].y = 0;
		self.missile_target_other[ i ].z = 0;
		self.missile_target_other[ i ].alpha = 0;
		self.missile_target_other[ i ].archived = 1;
		self.missile_target_other[ i ] setshader( "hud_remote_missile_target", 450, 450 );
		self.missile_target_other[ i ] setwaypoint( 0 );
		self.missile_target_other[ i ].hidewheninmenu = 1;
		self.missile_target_other[ i ].immunetodemogamehudsettings = 1;
		i++;
	}
	rocket.iconindexother = 0;
	self thread targeting_hud_think( rocket );
	self thread reticle_hud_think( rocket );
	self thread flash_cluster_armed( rocket );
}

destroy_missile_hud()
{
	if ( isDefined( self.deploy_hud_armed ) )
	{
		self.deploy_hud_armed destroy();
	}
	if ( isDefined( self.deploy_hud_deployed ) )
	{
		self.deploy_hud_deployed destroy();
	}
	if ( isDefined( self.missile_reticle ) )
	{
		self.missile_reticle destroy();
	}
	if ( isDefined( self.missile_reticle_top ) )
	{
		self.missile_reticle_top destroy();
	}
	if ( isDefined( self.missile_reticle_bottom ) )
	{
		self.missile_reticle_bottom destroy();
	}
	if ( isDefined( self.missile_reticle_right ) )
	{
		self.missile_reticle_right destroy();
	}
	if ( isDefined( self.missile_reticle_left ) )
	{
		self.missile_reticle_left destroy();
	}
	while ( isDefined( self.missile_target_icons ) )
	{
		_a838 = level.players;
		_k838 = getFirstArrayKey( _a838 );
		while ( isDefined( _k838 ) )
		{
			player = _a838[ _k838 ];
			if ( player == self )
			{
			}
			else if ( level.teambased && player.team == self.team )
			{
			}
			else
			{
				index = player.clientid;
				if ( isDefined( self.missile_target_icons[ index ] ) )
				{
					self.missile_target_icons[ index ] destroy();
				}
			}
			_k838 = getNextArrayKey( _a838, _k838 );
		}
	}
	while ( isDefined( self.missile_target_other ) )
	{
		i = 0;
		while ( i < 3 )
		{
			if ( isDefined( self.missile_target_other[ i ] ) )
			{
				self.missile_target_other[ i ] destroy();
			}
			i++;
		}
	}
}

flash_cluster_armed( rocket )
{
	self endon( "disconnect" );
	self endon( "remotemissile_done" );
	level endon( "game_ended" );
	rocket endon( "death" );
	self endon( "bomblets_deployed" );
	for ( ;; )
	{
		self.deploy_hud_armed.alpha = 1;
		wait 0,35;
		self.deploy_hud_armed.alpha = 0;
		wait 0,15;
	}
}

flash_cluster_deployed( rocket )
{
	self endon( "disconnect" );
	self endon( "remotemissile_done" );
	level endon( "game_ended" );
	rocket endon( "death" );
	self.deploy_hud_armed.alpha = 0,35;
	for ( ;; )
	{
		self.deploy_hud_deployed.alpha = 1;
		wait 0,35;
		self.deploy_hud_deployed.alpha = 0;
		wait 0,15;
	}
}

targeting_hud_think( rocket )
{
	self endon( "disconnect" );
	self endon( "remotemissile_done" );
	rocket endon( "death" );
	level endon( "game_ended" );
	targets = self getvalidtargets( rocket, 1 );
	framessincetargetscan = 0;
	while ( 1 )
	{
		_a910 = self.missile_target_icons;
		_k910 = getFirstArrayKey( _a910 );
		while ( isDefined( _k910 ) )
		{
			icon = _a910[ _k910 ];
			icon.alpha = 0;
			_k910 = getNextArrayKey( _a910, _k910 );
		}
		framessincetargetscan++;
		if ( framessincetargetscan > 5 )
		{
			targets = self getvalidtargets( rocket, 1 );
			framessincetargetscan = 0;
		}
		while ( targets.size > 0 )
		{
			_a925 = targets;
			_k925 = getFirstArrayKey( _a925 );
			while ( isDefined( _k925 ) )
			{
				target = _a925[ _k925 ];
				if ( isDefined( target ) == 0 )
				{
				}
				else if ( isplayer( target ) )
				{
					if ( isalive( target ) )
					{
						index = target.clientid;
/#
						assert( isDefined( index ) );
#/
						self.missile_target_icons[ index ].x = target.origin[ 0 ];
						self.missile_target_icons[ index ].y = target.origin[ 1 ];
						self.missile_target_icons[ index ].z = target.origin[ 2 ] + 47;
						self.missile_target_icons[ index ].alpha = 1;
					}
				}
				else
				{
					if ( !isDefined( target.missileiconindex ) )
					{
						target.missileiconindex = rocket.iconindexother;
						rocket.iconindexother = ( rocket.iconindexother + 1 ) % 3;
					}
					index = target.missileiconindex;
					self.missile_target_other[ index ].x = target.origin[ 0 ];
					self.missile_target_other[ index ].y = target.origin[ 1 ];
					self.missile_target_other[ index ].z = target.origin[ 2 ];
					self.missile_target_other[ index ].alpha = 1;
				}
				_k925 = getNextArrayKey( _a925, _k925 );
			}
		}
		wait 0,1;
	}
}

reticle_hud_think( rocket )
{
	self endon( "disconnect" );
	self endon( "remotemissile_done" );
	rocket endon( "death" );
	level endon( "game_ended" );
	first = 1;
	while ( 1 )
	{
		reticlesize = int( min( max( 0, ( 1000 * atan( 600 / max( 0,1, rocket.origin[ 2 ] - self.origin[ 2 ] ) ) ) / 9 ), 1500 ) );
		if ( !first )
		{
			self.missile_reticle_top moveovertime( 0,1 );
			self.missile_reticle_bottom moveovertime( 0,1 );
			self.missile_reticle_right moveovertime( 0,1 );
			self.missile_reticle_left moveovertime( 0,1 );
		}
		else
		{
			first = 0;
		}
		self.missile_reticle_top.y = ( reticlesize * -1 ) / 2,4;
		self.missile_reticle_bottom.y = reticlesize / 2,4;
		self.missile_reticle_right.x = reticlesize / 2,4;
		self.missile_reticle_left.x = ( reticlesize * -1 ) / 2,4;
		wait 0,1;
	}
}

missile_deploy_watch( rocket )
{
	self endon( "disconnect" );
	self endon( "remotemissile_done" );
	rocket endon( "death" );
	level endon( "game_ended" );
	wait 0,25;
	self thread create_missile_hud( rocket );
	waitframes = 2;
	explosionradius = 0;
	while ( 1 )
	{
		if ( self attackbuttonpressed() )
		{
			targets = self getvalidtargets( rocket, 0 );
			while ( targets.size > 0 )
			{
				_a1017 = targets;
				_k1017 = getFirstArrayKey( _a1017 );
				while ( isDefined( _k1017 ) )
				{
					target = _a1017[ _k1017 ];
					self thread fire_bomblet( rocket, explosionradius, target, waitframes );
					waitframes++;
					_k1017 = getNextArrayKey( _a1017, _k1017 );
				}
			}
			bomblet = magicbullet( "remote_missile_bomblet_mp", rocket.origin, rocket.origin + ( anglesToForward( rocket.angles ) * 1000 ), self );
			bomblet.team = self.team;
			bomblet setteam( self.team );
			if ( ( rocket.origin[ 2 ] - self.origin[ 2 ] ) > 4000 )
			{
				bomblet thread missile_sound_impact( self, 8000 );
				rocket notify( "stop_impact_sound" );
			}
			bomblet thread setup_bomblet_map_icon();
			rocket setclientfield( "remote_missile_fired", 2 );
			bomblet.killcament = self;
			i = targets.size;
			while ( i <= 8 )
			{
				self thread fire_random_bomblet( rocket, explosionradius, i % 6, waitframes );
				waitframes++;
				i++;
			}
			playfx( level.missileremotedeployfx, rocket.origin, anglesToForward( rocket.angles ) );
			self playlocalsound( "mpl_rc_exp" );
			self playrumbleonentity( "sniper_fire" );
			earthquake( 0,2, 0,2, rocket.origin, 200 );
			rocket hide();
			rocket setmissilecoasting( 1 );
			self thread maps/mp/gametypes/_hud::fadetoblackforxsec( 0, 0,15, 0, 0, "white" );
			rocket missile_sound_deploy_bomblets();
			self thread bomblet_camera_waiter( rocket );
			self thread flash_cluster_deployed( rocket );
			self notify( "bomblets_deployed" );
			return;
			continue;
		}
		else
		{
			wait 0,05;
		}
	}
}

bomblet_camera_waiter( rocket )
{
	self endon( "disconnect" );
	self endon( "remotemissile_done" );
	rocket endon( "death" );
	level endon( "game_ended" );
	delay = getdvarfloatdefault( "scr_rmbomblet_camera_delaytime", 1 );
	self waittill( "bomblet_exploded" );
	wait delay;
	rocket notify( "death" );
	self notify( "remotemissile_done" );
}

fire_bomblet( rocket, explosionradius, target, waitframes )
{
	origin = rocket.origin;
	targetorigin = target.origin + vectorScale( ( 0, 0, 1 ), 50 );
	wait ( waitframes * 0,05 );
	if ( isDefined( rocket ) )
	{
		origin = rocket.origin;
	}
	bomblet = magicbullet( "remote_missile_bomblet_mp", origin, targetorigin, self, target, vectorScale( ( 0, 0, 1 ), 30 ) );
	bomblet.team = self.team;
	bomblet setteam( self.team );
	bomblet.killcament = self;
	bomblet thread setup_bomblet_map_icon();
	bomblet thread bomblet_explostion_waiter( self );
}

setup_bomblet_map_icon()
{
	wait 0,1;
	self setclientfield( "remote_missile_bomblet_fired", 1 );
}

fire_random_bomblet( rocket, explosionradius, quadrant, waitframes )
{
	origin = rocket.origin;
	angles = rocket.angles;
	owner = rocket.owner;
	aimtarget = rocket.aimtarget;
	wait ( waitframes * 0,05 );
	angle = randomintrange( 10 + ( 60 * quadrant ), 50 + ( 60 * quadrant ) );
	radius = randomintrange( 200, 700 );
	x = min( radius, 550 ) * cos( angle );
	y = min( radius, 550 ) * sin( angle );
	bomblet = magicbullet( "remote_missile_bomblet_mp", origin, aimtarget + ( x, y, 0 ), self );
	bomblet.team = self.team;
	bomblet setteam( self.team );
	bomblet thread setup_bomblet_map_icon();
	bomblet.killcament = self;
	bomblet thread bomblet_explostion_waiter( self );
}

bomblet_explostion_waiter( player )
{
	player endon( "disconnect" );
	player endon( "remotemissile_done" );
	player endon( "death" );
	level endon( "game_ended" );
	self waittill( "death" );
	player notify( "bomblet_exploded" );
}
