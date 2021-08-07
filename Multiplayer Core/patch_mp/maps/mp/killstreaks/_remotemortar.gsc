#include maps/mp/killstreaks/_spyplane;
#include maps/mp/_popups;
#include maps/mp/_challenges;
#include maps/mp/_scoreevents;
#include maps/mp/gametypes/_weapon_utils;
#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/gametypes/_hostmigration;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_hud;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/_heatseekingmissile;
#include maps/mp/killstreaks/_killstreakrules;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/killstreaks/_helicopter;
#include maps/mp/killstreaks/_airsupport;
#include maps/mp/killstreaks/_killstreaks;
#include common_scripts/utility;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;

init()
{
	precachemodel( "veh_t6_drone_pegasus_mp" );
	precacheshader( "compass_lodestar" );
	precacheitem( "remote_mortar_missile_mp" );
	precachestring( &"remotemortar" );
	level.remote_mortar_fx[ "laserTarget" ] = loadfx( "weapon/remote_mortar/fx_rmt_mortar_laser_loop" );
	level.remote_mortar_fx[ "missileExplode" ] = loadfx( "weapon/remote_mortar/fx_rmt_mortar_explosion" );
	registerkillstreak( "remote_mortar_mp", "remote_mortar_mp", "killstreak_remote_mortar", "remote_mortar_used", ::remote_mortar_killstreak, 1 );
	registerkillstreakaltweapon( "remote_mortar_mp", "remote_mortar_missile_mp" );
	registerkillstreakstrings( "remote_mortar_mp", &"KILLSTREAK_EARNED_REMOTE_MORTAR", &"KILLSTREAK_REMOTE_MORTAR_NOT_AVAILABLE", &"KILLSTREAK_REMOTE_MORTAR_INBOUND" );
	registerkillstreakdialog( "remote_mortar_mp", "mpl_killstreak_planemortar", "kls_reaper_used", "", "kls_reaper_enemy", "", "kls_reaper_ready" );
	registerkillstreakdevdvar( "remote_mortar_mp", "scr_givemortarremote" );
	setkillstreakteamkillpenaltyscale( "remote_mortar_mp", level.teamkillreducedpenalty );
	overrideentitycameraindemo( "remote_mortar_mp", 1 );
	set_dvar_float_if_unset( "scr_remote_mortar_lifetime", 45 );
	level.remore_mortar_infrared_vision = "remote_mortar_infrared";
	level.remore_mortar_enhanced_vision = "remote_mortar_enhanced";
	minimaporigins = getentarray( "minimap_corner", "targetname" );
	if ( minimaporigins.size )
	{
		uavorigin = maps/mp/gametypes/_spawnlogic::findboxcenter( minimaporigins[ 0 ].origin, minimaporigins[ 1 ].origin );
	}
	else
	{
		uavorigin = ( 0, 0, 1 );
	}
	if ( level.script == "mp_la" )
	{
		uavorigin += vectorScale( ( 0, 0, 1 ), 1200 );
	}
	if ( level.script == "mp_hydro" )
	{
		uavorigin += vectorScale( ( 0, 0, 1 ), 2000 );
	}
	if ( level.script == "mp_concert" )
	{
		uavorigin += vectorScale( ( 0, 0, 1 ), 750 );
	}
	if ( level.script == "mp_vertigo" )
	{
		uavorigin += vectorScale( ( 0, 0, 1 ), 500 );
	}
	level.remotemortarrig = spawn( "script_model", uavorigin );
	level.remotemortarrig setmodel( "tag_origin" );
	level.remotemortarrig.angles = vectorScale( ( 0, 0, 1 ), 115 );
	level.remotemortarrig hide();
	level.remotemortarrig thread rotaterig( 1 );
	level.remote_zoffset = 8000;
	level.remote_radiusoffset = 9000;
	remote_mortar_height = getstruct( "remote_mortar_height", "targetname" );
	if ( isDefined( remote_mortar_height ) )
	{
		level.remote_radiusoffset = ( remote_mortar_height.origin[ 2 ] / level.remote_zoffset ) * level.remote_radiusoffset;
		level.remote_zoffset = remote_mortar_height.origin[ 2 ];
	}
}

remote_mortar_killstreak( hardpointtype )
{
/#
	assert( hardpointtype == "remote_mortar_mp" );
#/
	if ( self maps/mp/killstreaks/_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
	{
		return 0;
	}
	if ( !self isonground() || self isusingremote() )
	{
		self iprintlnbold( &"KILLSTREAK_REMOTE_MORTAR_NOT_USABLE" );
		return 0;
	}
	self setusingremote( hardpointtype );
	self freezecontrolswrapper( 1 );
	self disableweaponcycling();
	result = self maps/mp/killstreaks/_killstreaks::initridekillstreak( "qrdrone" );
	if ( result != "success" )
	{
		if ( result != "disconnect" )
		{
			self notify( "remote_mortar_unlock" );
			self clearusingremote();
			self enableweaponcycling();
		}
		return 0;
	}
	killstreak_id = self maps/mp/killstreaks/_killstreakrules::killstreakstart( hardpointtype, self.team, 0, 1 );
	if ( killstreak_id == -1 )
	{
		self clearusingremote();
		self enableweaponcycling();
		self notify( "remote_mortar_unlock" );
		return 0;
	}
	self.killstreak_waitamount = getDvarFloat( #"F9AB897A" ) * 1000;
	remote = self remote_mortar_spawn();
	remote setdrawinfrared( 1 );
	remote thread remote_killstreak_abort();
	remote thread remote_killstreak_game_end();
	remote thread remote_owner_exit();
	remote thread remote_owner_teamkillkicked();
	remote thread remote_damage_think();
	remote thread play_lockon_sounds( self );
	remote thread maps/mp/_heatseekingmissile::missiletarget_lockonmonitor( self, "remote_end" );
	remote thread maps/mp/_heatseekingmissile::missiletarget_proximitydetonateincomingmissile( "crashing" );
	remote.killstreak_id = killstreak_id;
	remote thread play_remote_fx();
	remote playloopsound( "mpl_ks_reaper_exterior_loop", 1 );
	self.pilottalking = 0;
	remote.copilotvoicenumber = self.bcvoicenumber;
	remote.pilotvoicenumber = self.bcvoicenumber + 1;
	if ( remote.pilotvoicenumber > 3 )
	{
		remote.pilotvoicenumber = 0;
	}
	self clientnotify( "krms" );
	self player_linkto_remote( remote );
	self freezecontrolswrapper( 0 );
	self thread player_aim_think( remote );
	self thread player_fire_think( remote );
	self maps/mp/killstreaks/_killstreaks::playkillstreakstartdialog( "remote_mortar_mp", self.pers[ "team" ] );
	remote thread remote_killstreak_copilot( remote.copilotvoicenumber );
	level.globalkillstreakscalled++;
	self addweaponstat( "remote_mortar_mp", "used", 1 );
	self thread visionswitch();
	level waittill( "remote_unlinked" );
	if ( isDefined( remote ) )
	{
		remote stoploopsound( 4 );
	}
	if ( !isDefined( self ) )
	{
		return 1;
	}
	self clientnotify( "krme" );
	self clearclientflag( 1 );
	self clientnotify( "nofutz" );
	self clearusingremote();
	return 1;
}

remote_killstreak_copilot( voice )
{
	level endon( "remote_end" );
	wait 2,5;
	while ( 1 )
	{
		self thread playpilotdialog( "reaper_used", 0, voice );
		wait randomfloatrange( 4,5, 15 );
	}
}

remote_killstreak_abort()
{
	level endon( "remote_end" );
/#
	assert( isDefined( self.owner ) );
#/
/#
	assert( isplayer( self.owner ) );
#/
	self.owner waittill_any( "disconnect", "joined_team", "joined_spectators" );
	self thread remote_killstreak_end( 0, 1 );
}

remote_owner_teamkillkicked( hardpointtype )
{
	level endon( "remote_end" );
	self.owner waittill( "teamKillKicked" );
	self thread remote_killstreak_end();
}

remote_owner_exit()
{
	level endon( "remote_end" );
	wait 1;
	while ( 1 )
	{
		timeused = 0;
		while ( self.owner usebuttonpressed() )
		{
			timeused += 0,05;
			if ( timeused > 0,25 )
			{
				self thread remote_killstreak_end();
				return;
			}
			wait 0,05;
		}
		wait 0,05;
	}
}

remote_killstreak_game_end()
{
	level endon( "remote_end" );
/#
	assert( isDefined( self.owner ) );
#/
/#
	assert( isplayer( self.owner ) );
#/
	level waittill( "game_ended" );
	self thread remote_killstreak_end();
}

remote_mortar_spawn()
{
	self setclientflag( 1 );
	self clientnotify( "reapfutz" );
	remote = spawnplane( self, "script_model", level.remotemortarrig gettagorigin( "tag_origin" ) );
/#
	assert( isDefined( remote ) );
#/
	remote setmodel( "veh_t6_drone_pegasus_mp" );
	remote.targetname = "remote_mortar";
	remote setowner( self );
	remote setteam( self.team );
	remote.team = self.team;
	remote.owner = self;
	remote.numflares = 2;
	remote.flareoffset = vectorScale( ( 0, 0, 1 ), 256 );
	remote.attackers = [];
	remote.attackerdata = [];
	remote.attackerdamage = [];
	remote.flareattackerdamage = [];
	remote.pilotvoicenumber = self.bcvoicenumber + 1;
	if ( remote.pilotvoicenumber > 3 )
	{
		remote.pilotvoicenumber = 0;
	}
	angle = randomint( 360 );
	xoffset = cos( angle ) * level.remote_radiusoffset;
	yoffset = sin( angle ) * level.remote_radiusoffset;
	anglevector = vectornormalize( ( xoffset, yoffset, level.remote_zoffset ) );
	anglevector *= 6100;
	remote linkto( level.remotemortarrig, "tag_origin", anglevector, ( 0, angle - 90, 0 ) );
	remoteobjidfriendly = maps/mp/gametypes/_gameobjects::getnextobjid();
	objective_add( remoteobjidfriendly, "invisible", remote.origin, &"remotemortar", self );
	objective_state( remoteobjidfriendly, "active" );
	objective_onentity( remoteobjidfriendly, remote );
	objective_team( remoteobjidfriendly, self.team );
	self.remoteobjidfriendly = remoteobjidfriendly;
	remote.fx = spawn( "script_model", ( 0, 0, 1 ) );
	remote.fx setmodel( "tag_origin" );
	remote.fx setinvisibletoplayer( remote.owner, 1 );
	remote remote_mortar_visibility();
	target_setturretaquire( remote, 1 );
	return remote;
}

rotaterig( clockwise )
{
	turn = 360;
	if ( clockwise )
	{
		turn = -360;
	}
	for ( ;; )
	{
		if ( !clockwise )
		{
			self rotateyaw( turn, 30 );
			wait 30;
			continue;
		}
		else
		{
			self rotateyaw( turn, 45 );
			wait 45;
		}
	}
}

remote_mortar_visibility()
{
	players = get_players();
	_a315 = players;
	_k315 = getFirstArrayKey( _a315 );
	while ( isDefined( _k315 ) )
	{
		player = _a315[ _k315 ];
		if ( player == self.owner )
		{
			self setinvisibletoplayer( player );
		}
		else
		{
			self setvisibletoplayer( player );
		}
		_k315 = getNextArrayKey( _a315, _k315 );
	}
}

play_lockon_sounds( player )
{
	player endon( "disconnect" );
	self endon( "death" );
	self endon( "remote_end" );
	self.locksounds = spawn( "script_model", self.origin );
	wait 0,1;
	self.locksounds linkto( self, "tag_player" );
	while ( 1 )
	{
		self waittill( "locking on" );
		while ( 1 )
		{
			if ( enemy_locking() )
			{
				self playsoundtoplayer( "uin_alert_lockon", player );
				wait 0,125;
			}
			if ( enemy_locked() )
			{
				self playsoundtoplayer( "uin_alert_lockon", player );
				wait 0,125;
			}
			if ( !enemy_locking() && !enemy_locked() )
			{
				break;
			}
			else
			{
			}
		}
	}
}

enemy_locking()
{
	if ( isDefined( self.locking_on ) && self.locking_on )
	{
		return 1;
	}
	return 0;
}

enemy_locked()
{
	if ( isDefined( self.locked_on ) && self.locked_on )
	{
		return 1;
	}
	return 0;
}

create_remote_mortar_hud( remote )
{
	self.missile_hud = newclienthudelem( self );
	self.missile_hud.alignx = "left";
	self.missile_hud.aligny = "bottom";
	self.missile_hud.horzalign = "user_left";
	self.missile_hud.vertalign = "user_bottom";
	self.missile_hud.font = "small";
	self.missile_hud settext( "[{+attack}]" + "Fire Missile" );
	self.missile_hud.hidewheninmenu = 1;
	self.missile_hud.hidewhenindemo = 1;
	self.missile_hud.x = 5;
	self.missile_hud.y = -40;
	self.missile_hud.fontscale = 1,25;
	self.zoom_hud = newclienthudelem( self );
	self.zoom_hud.alignx = "left";
	self.zoom_hud.aligny = "bottom";
	self.zoom_hud.horzalign = "user_left";
	self.zoom_hud.vertalign = "user_bottom";
	self.zoom_hud.font = "small";
	self.zoom_hud settext( &"KILLSTREAK_INCREASE_ZOOM" );
	self.zoom_hud.hidewheninmenu = 1;
	self.zoom_hud.hidewhenindemo = 1;
	self.zoom_hud.x = 5;
	self.zoom_hud.y = -25;
	self.zoom_hud.fontscale = 1,25;
	self.hud_prompt_exit = newclienthudelem( self );
	self.hud_prompt_exit.alignx = "left";
	self.hud_prompt_exit.aligny = "bottom";
	self.hud_prompt_exit.horzalign = "user_left";
	self.hud_prompt_exit.vertalign = "user_bottom";
	self.hud_prompt_exit.font = "small";
	self.hud_prompt_exit.fontscale = 1,25;
	self.hud_prompt_exit.hidewheninmenu = 1;
	self.hud_prompt_exit.hidewhenindemo = 1;
	self.hud_prompt_exit.archived = 0;
	self.hud_prompt_exit.x = 5;
	self.hud_prompt_exit.y = -10;
	self.hud_prompt_exit settext( level.remoteexithint );
	self thread fade_out_hint_hud( remote );
}

fade_out_hint_hud( remote )
{
	self endon( "disconnect" );
	remote endon( "death" );
	wait 8;
	time = 0;
	while ( time < 2 )
	{
		if ( !isDefined( self.missile_hud ) )
		{
			return;
		}
		self.missile_hud.alpha -= 0,025;
		self.zoom_hud.alpha -= 0,025;
		time += 0,05;
		wait 0,05;
	}
	self.missile_hud.alpha = 0;
	self.zoom_hud.alpha = 0;
}

remove_hud()
{
	if ( isDefined( self.missile_hud ) )
	{
		self.missile_hud destroy();
	}
	if ( isDefined( self.zoom_hud ) )
	{
		self.zoom_hud destroy();
	}
	if ( isDefined( self.hud_prompt_exit ) )
	{
		self.hud_prompt_exit destroy();
	}
}

remote_killstreak_end( explode, disconnected )
{
	level notify( "remote_end" );
	if ( !isDefined( explode ) )
	{
		explode = 0;
	}
	if ( !isDefined( disconnected ) )
	{
		disconnected = 0;
	}
	if ( isDefined( self.owner ) )
	{
		if ( disconnected == 0 )
		{
			if ( explode )
			{
				self.owner sendkillstreakdamageevent( 600 );
				self.owner thread maps/mp/gametypes/_hud::fadetoblackforxsec( 0,5, 0,5, 0,1, 0,25 );
				wait 1;
			}
			else
			{
				self.owner sendkillstreakdamageevent( 600 );
				self.owner thread maps/mp/gametypes/_hud::fadetoblackforxsec( 0, 0,25, 0,1, 0,25 );
				wait 0,25;
			}
		}
		self.owner unlink();
		self.owner.killstreak_waitamount = undefined;
		self.owner enableweaponcycling();
		self.owner remove_hud();
		if ( isDefined( level.gameended ) && level.gameended )
		{
			self.owner freezecontrolswrapper( 1 );
		}
	}
	self maps/mp/gametypes/_spawning::remove_tvmissile_influencers();
	objective_delete( self.owner.remoteobjidfriendly );
	releaseobjid( self.owner.remoteobjidfriendly );
	target_setturretaquire( self, 0 );
	level notify( "remote_unlinked" );
	maps/mp/killstreaks/_killstreakrules::killstreakstop( "remote_mortar_mp", self.team, self.killstreak_id );
	if ( isDefined( self.owner ) )
	{
		self.owner setinfraredvision( 0 );
		self.owner useservervisionset( 0 );
	}
	if ( isDefined( self.fx ) )
	{
		self.fx delete();
	}
	if ( explode )
	{
		self remote_explode();
	}
	else
	{
		self remote_leave();
	}
}

player_linkto_remote( remote )
{
	leftarc = 40;
	rightarc = 40;
	uparc = 25;
	downarc = 65;
	if ( isDefined( level.remotemotarviewleft ) )
	{
		leftarc = level.remotemotarviewleft;
	}
	if ( isDefined( level.remotemotarviewright ) )
	{
		rightarc = level.remotemotarviewright;
	}
	if ( isDefined( level.remotemotarviewup ) )
	{
		uparc = level.remotemotarviewup;
	}
	if ( isDefined( level.remotemotarviewdown ) )
	{
		downarc = level.remotemotarviewdown;
	}
/#
	leftarc = getdvarintdefault( "scr_remotemortar_right", leftarc );
	rightarc = getdvarintdefault( "scr_remotemortar_left", rightarc );
	uparc = getdvarintdefault( "scr_remotemortar_up", uparc );
	downarc = getdvarintdefault( "scr_remotemortar_down", downarc );
#/
	self playerlinkweaponviewtodelta( remote, "tag_player", 1, leftarc, rightarc, uparc, downarc );
	self player_center_view();
}

player_center_view( org )
{
	wait 0,05;
	lookvec = vectorToAngle( level.uavrig.origin - self geteye() );
	self setplayerangles( lookvec );
}

player_aim_think( remote )
{
	level endon( "remote_end" );
	wait 0,25;
	playfxontag( level.remote_mortar_fx[ "laserTarget" ], remote.fx, "tag_origin" );
	remote.fx playloopsound( "mpl_ks_reaper_laser" );
	while ( 1 )
	{
		origin = self geteye();
		forward = anglesToForward( self getplayerangles() );
		endpoint = origin + ( forward * 15000 );
		trace = bullettrace( origin, endpoint, 0, remote );
		remote.fx.origin = trace[ "position" ];
		remote.fx.angles = vectorToAngle( trace[ "normal" ] );
		if ( isDefined( self.pegasus_influencer ) )
		{
			removeinfluencer( self.pegasus_influencer );
			self.pegasus_influencer = undefined;
		}
		if ( isDefined( self.active_pegasus ) )
		{
			self.pegasus_influencer = maps/mp/gametypes/_spawning::create_pegasus_influencer( trace[ "position" ], self.team );
		}
		wait 0,05;
	}
}

player_fire_think( remote )
{
	level endon( "remote_end" );
	end_time = getTime() + self.killstreak_waitamount;
	shot = 0;
	while ( getTime() < end_time )
	{
		self.active_pegasus = undefined;
		while ( !self attackbuttonpressed() )
		{
			wait 0,05;
		}
		self playlocalsound( "mpl_ks_reaper_fire" );
		self playrumbleonentity( "sniper_fire" );
		if ( ( shot % 3 ) == 1 )
		{
			if ( isDefined( remote.owner ) && isDefined( remote.owner.pilottalking ) && remote.owner.pilottalking )
			{
				shot = 0;
			}
			remote thread playpilotdialog( "reaper_fire", 0,25, undefined, 0 );
		}
		shot = ( shot + 1 ) % 3;
		origin = self geteye();
		earthquake( 0,3, 0,5, origin, 256 );
		angles = self getplayerangles();
		forward = anglesToForward( angles );
		right = anglesToRight( angles );
		up = anglesToUp( angles );
		offset = ( ( origin + ( forward * 100 ) ) + ( right * -40 ) ) + ( up * -100 );
		missile = magicbullet( "remote_mortar_missile_mp", offset, ( origin + ( forward * 1000 ) ) + ( up * -100 ), self, remote.fx );
		self.active_pegasus = missile;
		missile thread remote_missile_life( remote );
		missile waittill( "death" );
		self playlocalsound( "mpl_ks_reaper_explosion" );
	}
	if ( isDefined( self.pegasus_influencer ) )
	{
		removeinfluencer( self.pegasus_influencer );
		self.pegasus_influencer = undefined;
	}
	remote thread remote_killstreak_end();
}

remote_missile_life( remote )
{
	self endon( "death" );
	maps/mp/gametypes/_hostmigration::waitlongdurationwithhostmigrationpause( 6 );
	playfx( level.remote_mortar_fx[ "missileExplode" ], self.origin );
	self delete();
}

remote_damage_think()
{
	level endon( "remote_end" );
	self.health = 999999;
	maxhealth = level.heli_amored_maxhealth;
	damagetaken = 0;
	self.lowhealth = 0;
	self setcandamage( 1 );
	target_set( self, vectorScale( ( 0, 0, 1 ), 30 ) );
	while ( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, meansofdeath, tagname, modelname, partname, weapon );
		self.health = 999999;
		heli_friendlyfire = maps/mp/gametypes/_weaponobjects::friendlyfirecheck( self.owner, attacker );
		while ( !heli_friendlyfire )
		{
			continue;
		}
		if ( isplayer( attacker ) )
		{
			attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback( meansofdeath );
			if ( attacker hasperk( "specialty_armorpiercing" ) )
			{
				if ( meansofdeath == "MOD_RIFLE_BULLET" || meansofdeath == "MOD_PISTOL_BULLET" )
				{
					damage += int( damage * level.cac_armorpiercing_data );
				}
			}
		}
		if ( meansofdeath == "MOD_RIFLE_BULLET" || meansofdeath == "MOD_PISTOL_BULLET" )
		{
			damage *= level.heli_armor_bulletdamage;
		}
		if ( isDefined( weapon ) )
		{
			if ( maps/mp/gametypes/_weapon_utils::islauncherweapon( weapon ) || weapon == "remote_missile_missile_mp" )
			{
				damage = maxhealth + 1;
			}
		}
		while ( damage <= 0 )
		{
			continue;
		}
		self.owner playlocalsound( "reaper_damaged" );
		self.owner sendkillstreakdamageevent( int( damage ) );
		damagetaken += damage;
		if ( damagetaken >= maxhealth )
		{
			if ( self.owner isenemyplayer( attacker ) )
			{
				maps/mp/_scoreevents::processscoreevent( "destroyed_remote_mortar", attacker, self.owner, weapon );
				attacker maps/mp/_challenges::addflyswatterstat( weapon, self );
				attacker addweaponstat( weapon, "destroyed_controlled_killstreak", 1 );
				attacker destroyedplayercontrolledaircraft();
				break;
			}
			level thread maps/mp/_popups::displayteammessagetoall( &"KILLSTREAK_DESTROYED_REMOTE_MORTAR", attacker );
			self thread remote_killstreak_end( 1 );
			return;
			continue;
		}
		else
		{
			if ( !self.lowhealth && damagetaken >= ( maxhealth / 2 ) )
			{
				playfxontag( level.fx_u2_damage_trail, self, "tag_origin" );
				self.lowhealth = 1;
			}
		}
	}
}

remote_leave()
{
	level endon( "game_ended" );
	self endon( "death" );
	self unlink();
	tries = 10;
	yaw = 0;
	while ( tries > 0 )
	{
		exitvector = anglesToForward( self.angles + ( 0, yaw, 0 ) ) * 20000;
		exitpoint = ( self.origin[ 0 ] + exitvector[ 0 ], self.origin[ 1 ] + exitvector[ 1 ], self.origin[ 2 ] - 2500 );
		exitpoint = self.origin + exitvector;
		nfz = crossesnoflyzone( self.origin, exitpoint );
		if ( isDefined( nfz ) )
		{
			if ( ( tries % 2 ) == 1 && tries != 1 )
			{
				yaw *= -1;
				tries--;
				continue;
			}
			else
			{
				if ( tries != 1 )
				{
					yaw += 10;
					yaw *= -1;
				}
			}
			tries--;

			continue;
		}
		else
		{
			tries = 0;
		}
	}
	self thread maps/mp/killstreaks/_spyplane::flattenyaw( self.angles[ 1 ] + yaw );
	self moveto( exitpoint, 8, 4 );
	if ( self.lowhealth )
	{
		playfxontag( level.chopper_fx[ "damage" ][ "heavy_smoke" ], self, "tag_origin" );
	}
	self thread play_afterburner_fx();
	maps/mp/gametypes/_hostmigration::waitlongdurationwithhostmigrationpause( 8 );
	self delete();
}

play_remote_fx()
{
	self.exhaustfx = spawn( "script_model", self.origin );
	self.exhaustfx setmodel( "tag_origin" );
	self.exhaustfx linkto( self, "tag_turret", vectorScale( ( 0, 0, 1 ), 25 ) );
	wait 0,1;
	playfxontag( level.fx_cuav_burner, self.exhaustfx, "tag_origin" );
}

play_afterburner_fx()
{
	if ( !isDefined( self.exhaustfx ) )
	{
		self.exhaustfx = spawn( "script_model", self.origin );
		self.exhaustfx setmodel( "tag_origin" );
		self.exhaustfx linkto( self, "tag_turret", vectorScale( ( 0, 0, 1 ), 25 ) );
	}
	self endon( "death" );
	wait 0,1;
	playfxontag( level.fx_cuav_afterburner, self.exhaustfx, "tag_origin" );
}

remote_explode()
{
	self notify( "death" );
	self hide();
	forward = anglesToForward( self.angles ) * 200;
	playfx( level.fx_u2_explode, self.origin, forward );
	self playsound( "evt_helicopter_midair_exp" );
	wait 0,2;
	self notify( "delete" );
	self delete();
}

visionswitch()
{
	self endon( "disconnect" );
	level endon( "remote_end" );
	inverted = 1;
	self setinfraredvision( 1 );
	self useservervisionset( 1 );
	self setvisionsetforplayer( level.remore_mortar_infrared_vision, 1 );
	for ( ;; )
	{
		while ( self changeseatbuttonpressed() )
		{
			if ( !inverted )
			{
				self setinfraredvision( 1 );
				self setvisionsetforplayer( level.remore_mortar_infrared_vision, 0,5 );
				self playlocalsound( "mpl_ks_reaper_view_select" );
			}
			else
			{
				self setinfraredvision( 0 );
				self setvisionsetforplayer( level.remore_mortar_enhanced_vision, 0,5 );
				self playlocalsound( "mpl_ks_reaper_view_select" );
			}
			inverted = !inverted;
			while ( self changeseatbuttonpressed() )
			{
				wait 0,05;
			}
		}
		wait 0,05;
	}
}
