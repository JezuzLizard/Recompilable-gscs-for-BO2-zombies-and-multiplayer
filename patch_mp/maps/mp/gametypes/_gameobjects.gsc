//checked includes match cerberus output
#include maps/mp/gametypes/_tweakables;
#include maps/mp/killstreaks/_radar;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_hostmigration;
#include maps/mp/gametypes/_weapons;
#include maps/mp/gametypes/_objpoints;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

main( allowed ) //checked changed to match cerberus output
{
	level.vehiclesenabled = getgametypesetting( "vehiclesEnabled" );
	level.vehiclestimed = getgametypesetting( "vehiclesTimed" );
	level.objectivepingdelay = getgametypesetting( "objectivePingTime" );
	level.nonteambasedteam = "allies";
	/*
/#
	if ( level.script == "mp_vehicle_test" )
	{
		level.vehiclesenabled = 1;
#/
	}
	*/
	if ( level.vehiclesenabled )
	{
		allowed[ allowed.size ] = "vehicle";
		filter_script_vehicles_from_vehicle_descriptors( allowed );
	}
	entities = getentarray();
	for ( entity_index = entities.size - 1; entity_index >= 0; entity_index-- )
	{
		entity = entities[ entity_index ];
		if ( !entity_is_allowed( entity, allowed ) )
		{
			entity delete();
		}

	}
	return;
}

entity_is_allowed( entity, allowed_game_modes ) //checked changed to match cerberus output
{
	if ( is_true( level.createfx_enabled ) )
	{
		return 1;
	}
	allowed = 1;
	if ( isDefined( entity.script_gameobjectname ) && entity.script_gameobjectname != "[all_modes]" )
	{
		allowed = 0;
		gameobjectnames = strtok( entity.script_gameobjectname, " " );
		for ( i = 0; i < allowed_game_modes.size && !allowed; i++ )
		{
			for ( j = 0; j < gameobjectnames.size && !allowed; j++ )
			{
				allowed = gameobjectnames[ j ] == allowed_game_modes[ i ];
			}
		}
	}
	return allowed;
}

filter_script_vehicles_from_vehicle_descriptors( allowed_game_modes ) //checked changed to match cerberus output
{
	vehicle_descriptors = getentarray( "vehicle_descriptor", "targetname" );
	script_vehicles = getentarray( "script_vehicle", "classname" );
	vehicles_to_remove = [];
	for ( descriptor_index = 0; descriptor_index < vehicle_descriptors.size; descriptor_index++ )
	{
		descriptor = vehicle_descriptors[ descriptor_index ];
		closest_distance_sq = 1E+12;
		closest_vehicle = undefined;
		for ( vehicle_index = 0; vehicle_index < script_vehicles.size; vehicle_index++ )
		{
			vehicle = script_vehicles[ vehicle_index ];
			dsquared = distancesquared( vehicle getorigin(), descriptor getorigin() );
			if ( dsquared < closest_distance_sq )
			{
				closest_distance_sq = dsquared;
				closest_vehicle = vehicle;
			}
		}
		if ( isDefined( closest_vehicle ) )
		{
			if ( !entity_is_allowed( descriptor, allowed_game_modes ) )
			{
				vehicles_to_remove[ vehicles_to_remove.size ] = closest_vehicle;
			}
		}
	}
	for ( vehicle_index = 0; vehicle_index < vehicles_to_remove.size; vehicle_index++ )
	{
		vehicles_to_remove[ vehicle_index ] delete();
	}
	return;
}

init() //checked matches cerberus output
{
	level.numgametypereservedobjectives = 0;
	level.releasedobjectives = [];
	if ( !sessionmodeiszombiesgame() )
	{
		precacheitem( "briefcase_bomb_mp" );
		precacheitem( "briefcase_bomb_defuse_mp" );
	}
	level thread onplayerconnect();
}

onplayerconnect() //checked matches cerberus output
{
	level endon( "game_ended" );
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
		player thread ondisconnect();
	}
}

onplayerspawned() //checked matches cerberus output
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread ondeath();
		self.touchtriggers = [];
		self.carryobject = undefined;
		self.claimtrigger = undefined;
		self.canpickupobject = 1;
		self.disabledweapon = 0;
		self.killedinuse = undefined;
	}
}

ondeath() //checked matches cerberus output
{
	level endon( "game_ended" );
	self waittill( "death" );
	if ( isDefined( self.carryobject ) )
	{
		self.carryobject thread setdropped();
	}
}

ondisconnect() //checked matches cerberus output
{
	level endon( "game_ended" );
	self waittill( "disconnect" );
	if ( isDefined( self.carryobject ) )
	{
		self.carryobject thread setdropped();
	}
}

createcarryobject( ownerteam, trigger, visuals, offset, objectivename ) //checked changed to match cerberus output
{
	carryobject = spawnstruct();
	carryobject.type = "carryObject";
	carryobject.curorigin = trigger.origin;
	carryobject.ownerteam = ownerteam;
	carryobject.entnum = trigger getentitynumber();
	if ( issubstr( trigger.classname, "use" ) )
	{
		carryobject.triggertype = "use";
	}
	else
	{
		carryobject.triggertype = "proximity";
	}
	trigger.baseorigin = trigger.origin;
	carryobject.trigger = trigger;
	carryobject.useweapon = undefined;
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	carryobject.offset3d = offset;
	carryobject.newstyle = 0;
	if ( isDefined( objectivename ) )
	{
		carryobject.newstyle = 1;
	}
	else
	{
		objectivename = &"";
	}
	for ( index = 0; index < visuals.size; index++ )
	{
		visuals[ index ].baseorigin = visuals[ index ].origin;
		visuals[ index ].baseangles = visuals[ index ].angles;
	}
	carryobject.visuals = visuals;
	carryobject.compassicons = [];
	carryobject.objid = [];
	if ( !carryobject.newstyle )
	{
		foreach ( team in level.teams )
		{
			carryobject.objid[ team ] = getnextobjid();
		}
	}
	carryobject.objidpingfriendly = 0;
	carryobject.objidpingenemy = 0;
	level.objidstart += 2;
	if ( !carryobject.newstyle )
	{
		if ( level.teambased )
		{
			foreach ( team in level.teams )
			{
				objective_add( carryobject.objid[ team ], "invisible", carryobject.curorigin );
				objective_team( carryobject.objid[ team ], team );
				carryobject.objpoints[ team ] = maps/mp/gametypes/_objpoints::createteamobjpoint( "objpoint_" + team + "_" + carryobject.entnum, carryobject.curorigin + offset, team, undefined );
				carryobject.objpoints[ team ].alpha = 0;
			}
		}
		else 
		{
			objective_add( carryobject.objid[ level.nonteambasedteam ], "invisible", carryobject.curorigin );
			carryobject.objpoints[ level.nonteambasedteam ] = maps/mp/gametypes/_objpoints::createteamobjpoint( "objpoint_" + level.nonteambasedteam + "_" + carryobject.entnum, carryobject.curorigin + offset, "all", undefined );
			carryobject.objpoints[ level.nonteambasedteam ].alpha = 0;
		}
	}
	carryobject.objectiveid = getnextobjid();
	objective_add( carryobject.objectiveid, "invisible", carryobject.curorigin, objectivename );
	carryobject.carrier = undefined;
	carryobject.isresetting = 0;
	carryobject.interactteam = "none";
	carryobject.allowweapons = 0;
	carryobject.visiblecarriermodel = undefined;
	carryobject.worldicons = [];
	carryobject.carriervisible = 0;
	carryobject.visibleteam = "none";
	carryobject.worldiswaypoint = [];
	carryobject.carryicon = undefined;
	carryobject.ondrop = undefined;
	carryobject.onpickup = undefined;
	carryobject.onreset = undefined;
	if ( carryobject.triggertype == "use" )
	{
		carryobject thread carryobjectusethink();
	}
	else
	{
		carryobject.numtouching[ "neutral" ] = 0;
		carryobject.numtouching[ "none" ] = 0;
		carryobject.touchlist[ "neutral" ] = [];
		carryobject.touchlist[ "none" ] = [];
		foreach ( team in level.teams )
		{
			carryobject.numtouching[ team ] = 0;
			carryobject.touchlist[ team ] = [];
		}
		carryobject.curprogress = 0;
		carryobject.usetime = 0;
		carryobject.userate = 0;
		carryobject.claimteam = "none";
		carryobject.claimplayer = undefined;
		carryobject.lastclaimteam = "none";
		carryobject.lastclaimtime = 0;
		carryobject.claimgraceperiod = 0;
		carryobject.mustmaintainclaim = 0;
		carryobject.cancontestclaim = 0;
		carryobject.decayprogress = 0;
		carryobject.teamusetimes = [];
		carryobject.teamusetexts = [];
		carryobject.onuse = ::setpickedup;
		carryobject thread useobjectproxthink();
	}
	carryobject thread updatecarryobjectorigin();
	carryobject thread updatecarryobjectobjectiveorigin();
	return carryobject;
}

carryobjectusethink() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	while ( 1 )
	{
		self.trigger waittill( "trigger", player );
		if ( self.isresetting )
		{
			continue;
		}
		if ( !isalive( player ) )
		{
			continue;
		}
		if ( is_true( player.laststand ) )
		{
			continue;
		}
		if ( !self caninteractwith( player ) )
		{
			continue;
		}
		if ( !player.canpickupobject )
		{
			continue;
		}
		if ( player.throwinggrenade )
		{
			continue;
		}
		if ( isDefined( self.carrier ) )
		{
			continue;
		}
		if ( player isinvehicle() )
		{
			continue;
		}
		if ( player isweaponviewonlylinked() )
		{
			continue;
		}
		if ( !player istouching( self.trigger ) )
		{
			continue;
		}
		self setpickedup( player );
	}
}

carryobjectproxthink() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	while ( 1 )
	{
		self.trigger waittill( "trigger", player );
		if ( self.isresetting )
		{
			continue;
		}
		if ( !isalive( player ) )
		{
			continue;
		}
		if ( is_true( player.laststand ) )
		{
			continue;
		}
		if ( !self caninteractwith( player ) )
		{
			continue;
		}
		if ( !player.canpickupobject )
		{
			continue;
		}
		if ( player.throwinggrenade )
		{
			continue;
		}
		if ( isDefined( self.carrier ) )
		{
			continue;
		}
		if ( player isinvehicle() )
		{
			continue;
		}
		if ( player isweaponviewonlylinked() )
		{
			continue;
		}
		if ( !player istouching( self.trigger ) )
		{
			continue;
		}
		self setpickedup( player );
	}
}

pickupobjectdelay( origin ) //checked changed to match beta dump
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "disconnect" );
	self.canpickupobject = 0;
	for ( ;; )
	{
		if ( distancesquared( self.origin, origin ) > 4096 )
		{
			break;
		}
		wait 0.2;
	}
	self.canpickupobject = 1;
}

setpickedup( player ) //checked changed to match cerberus output
{
	if ( !isalive( player ) )
	{
		return;
	}
	if ( isDefined( player.carryobject ) )
	{
		if ( is_true( player.carryobject.swappable ) )
		{
			player.carryobject thread setdropped();
		}
		else if ( isDefined( self.onpickupfailed ) )
		{
			self [[ self.onpickupfailed ]]( player );
		}
		return;
	}
	player giveobject( self );
	self setcarrier( player );
	for ( index = 0; index < self.visuals.size; index++ )
	{
		self.visuals[ index ] thread hideobject();
	}
	self.trigger.origin += vectorScale( ( 0, 0, 1 ), 10000 );
	self notify( "pickup_object" );
	if ( isDefined( self.onpickup ) )
	{
		self [[ self.onpickup ]]( player );
	}
	self updatecompassicons();
	self updateworldicons();
	self updateobjective();
}

hideobject() //checked changed to match cerberus output
{
	radius = 32;
	origin = self.origin;
	grenades = getentarray( "grenade", "classname" );
	radiussq = radius * radius;
	linkedgrenades = [];
	linkedgrenadesindex = 0;
	self hide();
	for ( i = 0; i < grenades.size; i++ )
	{
		if ( distancesquared( origin, grenades[ i ].origin ) < radiussq )
		{
			if ( grenades[ i ] islinkedto( self ) )
			{
				linkedgrenades[ linkedgrenadesindex ] = grenades[ i ];
				linkedgrenades[ linkedgrenadesindex ] unlink();
				linkedgrenadesindex++;
			}
		}
	}
	self.origin += vectorScale( ( 0, 0, 1 ), 10000 );
	waittillframeend;
	for ( i = 0; i < linkedgrenadesindex; i++ )
	{
		linkedgrenades[ i ] launch( vectorScale( ( 1, 1, 1 ), 5 ) );
	}
}

updatecarryobjectorigin() //checked changed to match beta dump
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	if ( self.newstyle )
	{
		return;
	}
	objpingdelay = level.objectivepingdelay;
	for ( ;; )
	{
		if ( isDefined( self.carrier ) && level.teambased )
		{
			self.curorigin = self.carrier.origin + vectorScale( ( 0, 0, 1 ), 75 );
			foreach ( team in level.teams )
			{
				self.objpoints[ team ] maps/mp/gametypes/_objpoints::updateorigin( self.curorigin );
			}
			if ( ( self.visibleteam == "friendly" || self.visibleteam == "any" ) && self.objidpingfriendly )
			{
				foreach ( team in level.teams )
				{
					if ( self isfriendlyteam( team ) )
					{
						if ( self.objpoints[ team ].isshown )
						{
							self.objpoints[ team ].alpha = self.objpoints[ team ].basealpha;
							self.objpoints[ team ] fadeovertime( objpingdelay + 1 );
							self.objpoints[ team ].alpha = 0;
						}
						objective_position( self.objid[ team ], self.curorigin );
					}
				}
			}
			if ( ( self.visibleteam == "enemy" && self.visibleteam == "any" ) && self.objidpingenemy )
			{
				if ( !self isfriendlyteam( team ) )
				{
					if ( self.objpoints[ team ].isshown )
					{
						self.objpoints[ team ].alpha = self.objpoints[ team ].basealpha;
						self.objpoints[ team ] fadeovertime( objpingdelay + 1 );
						self.objpoints[ team ].alpha = 0;
					}
					objective_position( self.objid[ team ], self.curorigin );
				}
			}
			self wait_endon( objpingdelay, "dropped", "reset" );
		}
		else if ( isDefined( self.carrier ) )
		{
			self.curorigin = self.carrier.origin + vectorScale( ( 0, 0, 1 ), 75 );
			self.objpoints[ level.nonteambasedteam ] maps/mp/gametypes/_objpoints::updateorigin( self.curorigin );
			objective_position( self.objid[ level.nonteambasedteam ], self.curorigin );
			wait 0.05;
		}
		else
		{
			if ( level.teambased )
			{
				foreach ( team in level.teams )
				{
					self.objpoints[ team ] maps/mp/gametypes/_objpoints::updateorigin( self.curorigin + self.offset3d );
				}
			}
			else 
			{
				self.objpoints[ level.nonteambasedteam ] maps/mp/gametypes/_objpoints::updateorigin( self.curorigin + self.offset3d );
			}
			wait 0.05;
		}
	}
}

updatecarryobjectobjectiveorigin() //checked changed to match beta dump
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	if ( !self.newstyle )
	{
		return;
	}
	objpingdelay = level.objectivepingdelay;
	for ( ;; )
	{
		if ( isDefined( self.carrier ) )
		{
			self.curorigin = self.carrier.origin;
			objective_position( self.objectiveid, self.curorigin );
			self wait_endon( objpingdelay, "dropped", "reset" );
		}
		else
		{
			objective_position( self.objectiveid, self.curorigin );
			wait 0.05;
		}
	}
}

giveobject( object ) //checked changed to match beta dump
{
	/*
/#
	assert( !isDefined( self.carryobject ) );
#/
	*/
	self.carryobject = object;
	self thread trackcarrier();
	if ( !object.allowweapons )
	{
		self _disableweapon();
		self thread manualdropthink();
	}
	self.disallowvehicleusage = 1;
	if ( isDefined( object.visiblecarriermodel ) )
	{
		self maps/mp/gametypes/_weapons::forcestowedweaponupdate();
	}
	if ( !object.newstyle )
	{
		if ( isDefined( object.carryicon ) )
		{
			if ( self issplitscreen() )
			{
				self.carryicon = createicon( object.carryicon, 35, 35 );
				self.carryicon.x = -130;
				self.carryicon.y = -90;
				self.carryicon.horzalign = "right";
				self.carryicon.vertalign = "bottom";
			}
			else 
			{
				self.carryicon = createicon( object.carryicon, 50, 50 );
				if ( !object.allowweapons )
				{
					self.carryicon setpoint( "CENTER", "CENTER", 0, 60 );
				}
				else
				{
					self.carryicon.x = 130;
					self.carryicon.y = -60;
					self.carryicon.horzalign = "user_left";
					self.carryicon.vertalign = "user_bottom";
				}
			}
			self.carryicon.alpha = 0.75;
			self.carryicon.hidewhileremotecontrolling = 1;
			self.carryicon.hidewheninkillcam = 1;
		}
	}
}

returnhome() //checked changed to match cerberus output
{
	self.isresetting = 1;
	self notify( "reset" );
	for ( index = 0; index < self.visuals.size; index++ )
	{
		self.visuals[ index ].origin = self.visuals[ index ].baseorigin;
		self.visuals[ index ].angles = self.visuals[ index ].baseangles;
		self.visuals[ index ] show();
	}
	self.trigger.origin = self.trigger.baseorigin;
	self.curorigin = self.trigger.origin;
	if ( isDefined( self.onreset ) )
	{
		self [[ self.onreset ]]();
	}
	self clearcarrier();
	updateworldicons();
	updatecompassicons();
	updateobjective();
	self.isresetting = 0;
}

isobjectawayfromhome() //checked matches cerberus output
{
	if ( isDefined( self.carrier ) )
	{
		return 1;
	}
	if ( distancesquared( self.trigger.origin, self.trigger.baseorigin ) > 4 )
	{
		return 1;
	}
	return 0;
}

setposition( origin, angles ) //checked changed to match cerberus output
{
	self.isresetting = 1;
	for ( index = 0; index < self.visuals.size; index++ )
	{
		visual = self.visuals[ index ];
		visual.origin = origin;
		visual.angles = angles;
		visual show();
	}
	self.trigger.origin = origin;
	self.curorigin = self.trigger.origin;
	self clearcarrier();
	updateworldicons();
	updatecompassicons();
	updateobjective();
	self.isresetting = 0;
}

onplayerlaststand() //checked matches cerberus output
{
	if ( isDefined( self.carryobject ) )
	{
		self.carryobject thread setdropped();
	}
}

setdropped() //checked changed to match cerberus output
{
	self.isresetting = 1;
	self notify( "dropped" );
	startorigin = ( 0, 0, 0 );
	endorigin = ( 0, 0, 0 );
	body = undefined;
	if ( isDefined( self.carrier ) && self.carrier.team != "spectator" )
	{
		startorigin = self.carrier.origin + vectorScale( ( 0, 0, 1 ), 20 );
		endorigin = self.carrier.origin - vectorScale( ( 0, 0, 1 ), 2000 );
		body = self.carrier.body;
		self.visuals[ 0 ].origin = self.carrier.origin;
	}
	else
	{
		startorigin = self.safeorigin + vectorScale( ( 0, 0, 1 ), 20 );
		endorigin = self.safeorigin - vectorScale( ( 0, 0, 1 ), 20 );
	}
	trace = playerphysicstrace( startorigin, endorigin );
	angletrace = bullettrace( startorigin, endorigin, 0, body );
	droppingplayer = self.carrier;
	if ( isDefined( trace ) )
	{
		tempangle = randomfloat( 360 );
		droporigin = trace;
		if ( angletrace[ "fraction" ] < 1 && distance( angletrace[ "position" ], trace ) < 10 )
		{
			forward = ( cos( tempangle ), sin( tempangle ), 0 );
			forward = vectornormalize( forward - vectorScale( angletrace[ "normal" ], vectordot( forward, angletrace[ "normal" ] ) ) );
			dropangles = vectorToAngle( forward );
		}
		else
		{
			dropangles = ( 0, tempangle, 0 );
		}
		for ( index = 0; index < self.visuals.size; index++ ) 
		{
			self.visuals[ index ].origin = droporigin;
			self.visuals[ index ].angles = dropangles;
			self.visuals[ index ] show();
		}
		self.trigger.origin = droporigin;
		self.curorigin = self.trigger.origin;
		self thread pickuptimeout( trace[ 2 ], startorigin[ 2 ] );
	}
	else
	{
		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[ index ].origin = self.visuals[ index ].baseorigin;
			self.visuals[ index ].angles = self.visuals[ index ].baseangles;
			self.visuals[ index ] show();
		}
		self.trigger.origin = self.trigger.baseorigin;
		self.curorigin = self.trigger.baseorigin;
	}
	if ( isDefined( self.ondrop ) )
	{
		self [[ self.ondrop ]]( droppingplayer );
	}
	self clearcarrier();
	self updatecompassicons();
	self updateworldicons();
	self updateobjective();
	self.isresetting = 0;
}

setcarrier( carrier ) //checked matches cerberus output
{
	self.carrier = carrier;
	objective_setplayerusing( self.objectiveid, carrier );
	self thread updatevisibilityaccordingtoradar();
}

clearcarrier() //checked matches cerberus output
{
	if ( !isDefined( self.carrier ) )
	{
		return;
	}
	self.carrier takeobject( self );
	objective_clearplayerusing( self.objectiveid, self.carrier );
	self.carrier = undefined;
	self notify( "carrier_cleared" );
}

shouldbereset( minz, maxz ) //checked changed to match cerberus output
{
	minetriggers = getentarray( "minefield", "targetname" );
	hurttriggers = getentarray( "trigger_hurt", "classname" );
	elevators = getentarray( "script_elevator", "targetname" );
	for ( index = 0; index < minetriggers.size; index++ )
	{
		if ( self.visuals[ 0 ] istouchingswept( minetriggers[ index ], minz, maxz ) )
		{
			return 1;
		}
	}
	for ( index = 0; index < hurttriggers.size; index++ )
	{
		if ( self.visuals[ 0 ] istouchingswept( hurttriggers[ index ], minz, maxz ) )
		{
			return 1;
		}
	}
	for ( index = 0; index < elevators.size; index++ )
	{
		/*
/#
		assert( isDefined( elevators[ index ].occupy_volume ) );
#/
		*/
		if ( self.visuals[ 0 ] istouchingswept( elevators[ index ].occupy_volume, minz, maxz ) )
		{
			return 1;
		}
	}
	return 0;
}

pickuptimeout( minz, maxz ) //checked matches cerberus output
{
	self endon( "pickup_object" );
	self endon( "stop_pickup_timeout" );
	wait 0.05;
	if ( self shouldbereset( minz, maxz ) )
	{
		self returnhome();
		return;
	}
	if ( isDefined( self.autoresettime ) )
	{
		wait self.autoresettime;
		if ( !isDefined( self.carrier ) )
		{
			self returnhome();
		}
	}
}

takeobject( object ) //checked matches cerberus output
{
	if ( isDefined( self.carryicon ) )
	{
		self.carryicon destroyelem();
	}
	if ( isDefined( object.visiblecarriermodel ) )
	{
		self maps/mp/gametypes/_weapons::detach_all_weapons();
	}
	self.carryobject = undefined;
	if ( !isalive( self ) )
	{
		return;
	}
	self notify( "drop_object" );
	self.disallowvehicleusage = 0;
	if ( object.triggertype == "proximity" )
	{
		self thread pickupobjectdelay( object.trigger.origin );
	}
	if ( isDefined( object.visiblecarriermodel ) )
	{
		self maps/mp/gametypes/_weapons::forcestowedweaponupdate();
	}
	if ( !object.allowweapons )
	{
		self _enableweapon();
	}
}

trackcarrier() //checked matches cerberus output
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "drop_object" );
	while ( isDefined( self.carryobject ) && isalive( self ) )
	{
		if ( self isonground() )
		{
			trace = bullettrace( self.origin + vectorScale( ( 0, 0, 1 ), 20 ), self.origin - vectorScale( ( 0, 0, 1 ), 20 ), 0, undefined );
			if ( trace[ "fraction" ] < 1 )
			{
				self.carryobject.safeorigin = trace[ "position" ];
			}
		}
		wait 0.05;
	}
}

manualdropthink() //checked changed to match beta dump
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "drop_object" );
	for ( ;; )
	{
		while ( self attackbuttonpressed() || self fragbuttonpressed() || self secondaryoffhandbuttonpressed() || self meleebuttonpressed() )
		{
			wait 0.05;
		}
		while ( !self attackbuttonpressed() && !self fragbuttonpressed() && !self secondaryoffhandbuttonpressed() && !self meleebuttonpressed() )
		{
			wait 0.05;
		}
		if ( isDefined( self.carryobject ) && !self usebuttonpressed() )
		{
			self.carryobject thread setdropped();
		}
	}
}

createuseobject( ownerteam, trigger, visuals, offset, objectivename ) //checked changed to match cerberus output
{
	useobject = spawnstruct();
	useobject.type = "useObject";
	useobject.curorigin = trigger.origin;
	useobject.ownerteam = ownerteam;
	useobject.entnum = trigger getentitynumber();
	useobject.keyobject = undefined;
	if ( issubstr( trigger.classname, "use" ) )
	{
		useobject.triggertype = "use";
	}
	else
	{
		useobject.triggertype = "proximity";
	}
	useobject.trigger = trigger;
	for ( index = 0; index < visuals.size; index++ )
	{
		visuals[ index ].baseorigin = visuals[ index ].origin;
		visuals[ index ].baseangles = visuals[ index ].angles;
	}
	useobject.visuals = visuals;
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	useobject.offset3d = offset;
	useobject.newstyle = 0;
	if ( isDefined( objectivename ) )
	{
		useobject.newstyle = 1;
	}
	else
	{
		objectivename = &"";
	}
	useobject.compassicons = [];
	useobject.objid = [];
	if ( !useobject.newstyle )
	{
		foreach ( team in level.teams )
		{
			useobject.objid[ team ] = getnextobjid();
		}
		if ( level.teambased )
		{
			foreach ( team in level.teams )
			{
				objective_add( useobject.objid[ team ], "invisible", useobject.curorigin );
				objective_team( useobject.objid[ team ], team );
			}
		}
		else 
		{
			objective_add( useobject.objid[ level.nonteambasedteam ], "invisible", useobject.curorigin );
		}
	}
	useobject.objectiveid = getnextobjid();
	objective_add( useobject.objectiveid, "invisible", useobject.curorigin + offset, objectivename );
	if ( !useobject.newstyle )
	{
		if ( level.teambased )
		{
			foreach ( team in level.teams )
			{
				useobject.objpoints[ team ] = maps/mp/gametypes/_objpoints::createteamobjpoint( "objpoint_" + team + "_" + useobject.entnum, useobject.curorigin + offset, team, undefined );
				useobject.objpoints[ team ].alpha = 0;
			}
		}
		else 
		{
			useobject.objpoints[ level.nonteambasedteam ] = maps/mp/gametypes/_objpoints::createteamobjpoint( "objpoint_allies_" + useobject.entnum, useobject.curorigin + offset, "all", undefined );
			useobject.objpoints[ level.nonteambasedteam ].alpha = 0;
		}
	}
	useobject.interactteam = "none";
	useobject.worldicons = [];
	useobject.visibleteam = "none";
	useobject.worldiswaypoint = [];
	useobject.onuse = undefined;
	useobject.oncantuse = undefined;
	useobject.usetext = "default";
	useobject.usetime = 10000;
	useobject clearprogress();
	useobject.decayprogress = 0;
	if ( useobject.triggertype == "proximity" )
	{
		useobject.numtouching[ "neutral" ] = 0;
		useobject.numtouching[ "none" ] = 0;
		useobject.touchlist[ "neutral" ] = [];
		useobject.touchlist[ "none" ] = [];
		foreach ( team in level.teams )
		{
			useobject.numtouching[ team ] = 0;
			useobject.touchlist[ team ] = [];
		}
		useobject.teamusetimes = [];
		useobject.teamusetexts = [];
		useobject.userate = 0;
		useobject.claimteam = "none";
		useobject.claimplayer = undefined;
		useobject.lastclaimteam = "none";
		useobject.lastclaimtime = 0;
		useobject.claimgraceperiod = 1;
		useobject.mustmaintainclaim = 0;
		useobject.cancontestclaim = 0;
		useobject thread useobjectproxthink();
	}
	else
	{
		useobject.userate = 1;
		useobject thread useobjectusethink();
	}
	return useobject;
}

setkeyobject( object ) //checked matches cerberus output
{
	if ( !isDefined( object ) )
	{
		self.keyobject = undefined;
		return;
	}
	if ( !isDefined( self.keyobject ) )
	{
		self.keyobject = [];
	}
	self.keyobject[ self.keyobject.size ] = object;
}

haskeyobject( use ) //checked changed to match cerberus output
{
	for ( x = 0; x < use.keyobject.size; x++ )
	{
		if ( isDefined( self.carryobject ) && isDefined( use.keyobject[ x ] ) && self.carryobject == use.keyobject[ x ] )
		{
			return 1;
		}
	}
	return 0;
}

useobjectusethink() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	while ( 1 )
	{
		self.trigger waittill( "trigger", player );
		if ( !isalive( player ) )
		{
			continue;
		}
		if ( !self caninteractwith( player ) )
		{
			continue;
		}
		if ( !player isonground() )
		{
			continue;
		}
		if ( player isinvehicle() )
		{
			continue;
		}
		if ( isDefined( self.keyobject ) && !isDefined( player.carryobject ) || !player haskeyobject( self ) )
		{
			if ( isDefined( self.oncantuse ) )
			{
				self [[ self.oncantuse ]]( player );
			}
		}
		result = 1;
		if ( self.usetime > 0 )
		{
			if ( isDefined( self.onbeginuse ) )
			{
				self [[ self.onbeginuse ]]( player );
			}
			team = player.pers[ "team" ];
			result = self useholdthink( player );
			if ( isDefined( self.onenduse ) )
			{
				self [[ self.onenduse ]]( team, player, result );
			}
		}
		if ( !result )
		{
			continue;
		}
		if ( isDefined( self.onuse ) )
		{
			self [[ self.onuse ]]( player );
		}
	}
}

getearliestclaimplayer() //checked changed to match cerberus output
{
	/*
/#
	assert( self.claimteam != "none" );
#/
	*/
	team = self.claimteam;
	earliestplayer = self.claimplayer;
	if ( self.touchlist[ team ].size > 0 )
	{
		earliesttime = undefined;
		players = getarraykeys( self.touchlist[ team ] );
		for ( index = 0; index < players.size; index++ )
		{
			touchdata = self.touchlist[ team ][ players[ index ] ];
			if ( !isDefined( earliesttime ) || touchdata.starttime < earliesttime )
			{
				earliestplayer = touchdata.player;
				earliesttime = touchdata.starttime;
			}
		}
	}
	return earliestplayer;
}

useobjectproxthink() //checked changed to match beta dump
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	self thread proxtriggerthink();
	while ( 1 )
	{
		if ( self.usetime && self.curprogress >= self.usetime )
		{
			self clearprogress();
			creditplayer = getearliestclaimplayer();
			if ( isDefined( self.onenduse ) )
			{
				self [[ self.onenduse ]]( self getclaimteam(), creditplayer, isDefined( creditplayer ) );
			}
			if ( isDefined( creditplayer ) && isDefined( self.onuse ) )
			{
				self [[ self.onuse ]]( creditplayer );
			}
			if ( !self.mustmaintainclaim )
			{
				self setclaimteam( "none" );
				self.claimplayer = undefined;
			}
		}
		if ( self.claimteam != "none" )
		{
			if ( self useobjectlockedforteam( self.claimteam ) )
			{
				if ( isDefined( self.onenduse ) )
				{
					self [[ self.onenduse ]]( self getclaimteam(), self.claimplayer, 0 );
				}
				self setclaimteam( "none" );
				self.claimplayer = undefined;
				self clearprogress();
			}
			else 
			{
				if ( !self.mustmaintainclaim || self getownerteam() != self getclaimteam() && self.usetime )
				{
					if ( self.decayprogress && !self.numtouching[ self.claimteam ] )
					{
						if ( isDefined( self.claimplayer ) )
						{
							if ( isDefined( self.onenduse ) )
							{
								self [[ self.onenduse ]]( self getclaimteam(), self.claimplayer, 0 );
							}
							self.claimplayer = undefined;
						}
						decayscale = 0;
						if ( self.decaytime )
						{
							decayscale = self.usetime / self.decaytime;
						}
						self.curprogress -= 50 * self.userate * decayscale;
						if ( self.curprogress <= 0 )
						{
							self clearprogress();
						}
						self updatecurrentprogress();
						if ( isDefined( self.onuseupdate ) )
						{
							self [[ self.onuseupdate ]]( self getclaimteam(), self.curprogress / self.usetime, ( 50 * self.userate * decayscale ) / self.usetime );
						}
						if ( self.curprogress == 0 )
						{
							self setclaimteam( "none" );
						}
					}
					else if ( !self.numtouching[ self.claimteam ] )
					{
						if ( isDefined( self.onenduse ) )
						{
							self [[ self.onenduse ]]( self getclaimteam(), self.claimplayer, 0 );
						}
						self setclaimteam( "none" );
						self.claimplayer = undefined;
						break;
					}
					else
					{
						self.curprogress += 50 * self.userate;
						self updatecurrentprogress();
						if ( isDefined( self.onuseupdate ) )
						{
							self [[ self.onuseupdate ]]( self getclaimteam(), self.curprogress / self.usetime, ( 50 * self.userate ) / self.usetime );
						}
					}
				}
				else if ( !self.mustmaintainclaim )
				{
					if ( isDefined( self.onuse ) )
					{
						self [[ self.onuse ]]( self.claimplayer );
					}
					if ( !self.mustmaintainclaim )
					{
						self setclaimteam( "none" );
						self.claimplayer = undefined;
					}
				}
				else if ( !self.numtouching[ self.claimteam ] )
				{
					if ( isDefined( self.onunoccupied ) )
					{
						self [[ self.onunoccupied ]]();
					}
					self setclaimteam( "none" );
					self.claimplayer = undefined;
				}
				else if ( self.cancontestclaim )
				{
					numother = getnumtouchingexceptteam( self.claimteam );
					if ( numother > 0 )
					{
						if ( isDefined( self.oncontested ) )
						{
							self [[ self.oncontested ]]();
						}
						self setclaimteam( "none" );
						self.claimplayer = undefined;
					}
				}
			}
		}
		else if ( self.curprogress > 0 && ( getTime() - self.lastclaimtime ) > ( self.claimgraceperiod * 1000 ) )
		{
			self clearprogress();
		}
		if ( self.mustmaintainclaim && self getownerteam() != "none" )
		{
			if ( !self.numtouching[ self getownerteam() ] )
			{
				if ( isDefined( self.onunoccupied ) )
				{
					self [[ self.onunoccupied ]]();
				}
			}
			else if ( self.cancontestclaim && self.lastclaimteam != "none" && self.numtouching[ self.lastclaimteam ] )
			{
				numother = getnumtouchingexceptteam( self.lastclaimteam );
				if ( numother == 0 )
				{
					if ( isDefined( self.onuncontested ) )
					{
						self [[ self.onuncontested ]]( self.lastclaimteam );
					}
				}
			}
		}
		wait 0.05;
		maps/mp/gametypes/_hostmigration::waittillhostmigrationdone();
	}
}

useobjectlockedforteam( team ) //checked matches cerberus output
{
	if ( isDefined( self.teamlock ) && isDefined( level.teams[ team ] ) )
	{
		return self.teamlock[ team ];
	}
	return 0;
}

canclaim( player ) //checked matches cerberus output
{
	if ( isDefined( self.carrier ) )
	{
		return 0;
	}
	if ( self.cancontestclaim )
	{
		numother = getnumtouchingexceptteam( player.pers[ "team" ] );
		if ( numother != 0 )
		{
			return 0;
		}
	}
	if ( !isDefined( self.keyobject ) || isDefined( player.carryobject ) && player haskeyobject( self ) )
	{
		return 1;
	}
	return 0;
}

proxtriggerthink() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	entitynumber = self.entnum;
	while ( 1 )
	{
		self.trigger waittill( "trigger", player );
		if ( !isalive( player ) || self useobjectlockedforteam( player.pers[ "team" ] ) )
		{
			continue;
		}
		if ( player.spawntime == getTime() )
		{
			continue;
		}
		if ( player isweaponviewonlylinked() )
		{
			continue;
		}
		if ( self isexcluded( player ) )
		{
			continue;
		}
		if ( self caninteractwith( player ) && self.claimteam == "none" )
		{
			if ( self canclaim( player ) )
			{
				setclaimteam( player.pers[ "team" ] );
				self.claimplayer = player;
				relativeteam = self getrelativeteam( player.pers[ "team" ] );
				if ( isDefined( self.teamusetimes[ relativeteam ] ) )
				{
					self.usetime = self.teamusetimes[ relativeteam ];
				}
				if ( self.usetime && isDefined( self.onbeginuse ) )
				{
					self [[ self.onbeginuse ]]( self.claimplayer );
				}
			}
			else if ( isDefined( self.oncantuse ) )
			{
				self [[ self.oncantuse ]]( player );
			}
		}
		if ( isalive( player ) && !isDefined( player.touchtriggers[ entitynumber ] ) )
		{
			player thread triggertouchthink( self );
		}
	}
}

isexcluded( player ) //checked changed to match cerberus output
{
	if ( !isDefined( self.exclusions ) )
	{
		return 0;
	}
	foreach ( exclusion in self.exclusions )
	{
		if ( exclusion istouching( player ) )
		{
			return 1;
		}
	}
	return 0;
}

clearprogress() //checked matches cerberus output
{
	self.curprogress = 0;
	self updatecurrentprogress();
	if ( isDefined( self.onuseclear ) )
	{
		self [[ self.onuseclear ]]();
	}
}

setclaimteam( newteam ) //checked changed to match cerberus output
{
	/*
/#
	assert( newteam != self.claimteam );
#/
	*/
	if ( self.claimteam == "none" && ( getTime() - self.lastclaimtime ) > ( self.claimgraceperiod * 1000 ) )
	{
		self clearprogress();
	}
	else if ( newteam != "none" && newteam != self.lastclaimteam )
	{
		self clearprogress();
	}
	self.lastclaimteam = self.claimteam;
	self.lastclaimtime = getTime();
	self.claimteam = newteam;
	self updateuserate();
}

getclaimteam() //checked matches cerberus output
{
	return self.claimteam;
}

continuetriggertouchthink( team, object ) //checked matches cerberus output
{
	if ( !isalive( self ) )
	{
		return 0;
	}
	if ( self useobjectlockedforteam( team ) )
	{
		return 0;
	}
	if ( !self istouching( object.trigger ) )
	{
		return 0;
	}
	return 1;
}

triggertouchthink( object ) //checked changed to match cerberus output
{
	team = self.pers[ "team" ];
	score = 1;
	object.numtouching[ team ] += score;
	if ( object.usetime )
	{
		object updateuserate();
	}
	touchname = "player" + self.clientid;
	struct = spawnstruct();
	struct.player = self;
	struct.starttime = getTime();
	object.touchlist[ team ][ touchname ] = struct;
	objective_setplayerusing( object.objectiveid, self );
	self.touchtriggers[ object.entnum ] = object.trigger;
	if ( isDefined( object.ontouchuse ) )
	{
		object [[ object.ontouchuse ]]( self );
	}
	while ( self continuetriggertouchthink( team, object ) )
	{
		if ( object.usetime )
		{
			self updateproxbar( object, 0 );
		}
		wait 0.05;
	}
	if ( isDefined( self ) )
	{
		if ( object.usetime )
		{
			self updateproxbar( object, 1 );
		}
		self.touchtriggers[object.entnum] = undefined;
		objective_clearplayerusing( object.objectiveid, self );
	}
	if ( level.gameended )
	{
		return;
	}
	object.touchlist[team][touchname] = undefined;
	object.numtouching[ team ] -= score;
	if ( object.numtouching[ team ] < 1 )
	{
		object.numtouching[ team ] = 0;
	}
	if ( object.usetime )
	{
		if ( object.numtouching[ team ] <= 0 && object.curprogress >= object.usetime )
		{
			object.curprogress = object.usetime - 1;
			object updatecurrentprogress();
		}
	}
	if ( isDefined( self ) && isDefined( object.onendtouchuse ) )
	{
		object [[ object.onendtouchuse ]]( self );
	}
	object updateuserate();
}

updateproxbar( object, forceremove ) //checked changed to match beta dump
{
	if ( object.newstyle )
	{
		return;
	}
	if ( !forceremove && object.decayprogress )
	{
		if ( !object caninteractwith( self ) )
		{
			if ( isDefined( self.proxbar ) )
			{
				self.proxbar hideelem();
			}
			if ( isDefined( self.proxbartext ) )
			{
				self.proxbartext hideelem();
			}
			return;
		}
		else 
		{
			if ( !isDefined( self.proxbar ) )
			{
				self.proxbar = createprimaryprogressbar();
				self.proxbar.lastuserate = -1;
			}
			if ( self.pers[ "team" ] == object.claimteam )
			{
				if ( self.proxbar.bar.color != ( 1, 1, 1 ) )
				{
					self.proxbar.bar.color = ( 1, 1, 1 );
					self.proxbar.lastuserate = -1;
				}
			}
			else
			{
				if ( self.proxbar.bar.color != ( 1, 0, 0 ) )
				{
					self.proxbar.bar.color = ( 1, 0, 0 );
					self.proxbar.lastuserate = -1;
				}
			}
		}
	}
	else if ( !forceremove || !object caninteractwith( self ) || self.pers[ "team" ] != object.claimteam )
	{
		if ( isDefined( self.proxbar ) )
		{
			self.proxbar hideelem();
		}
		if ( isDefined( self.proxbartext ) )
		{
			self.proxbartext hideelem();
		}
		return;
	}
	if ( !isDefined( self.proxbar ) )
	{
		self.proxbar = createprimaryprogressbar();
		self.proxbar.lastuserate = -1;
		self.proxbar.lasthostmigrationstate = 0;
	}
	if ( self.proxbar.hidden )
	{
		self.proxbar showelem();
		self.proxbar.lastuserate = -1;
		self.proxbar.lasthostmigrationstate = 0;
	}
	if ( !isDefined( self.proxbartext ) )
	{
		self.proxbartext = createprimaryprogressbartext();
		self.proxbartext settext( object.usetext );
	}
	if ( self.proxbartext.hidden )
	{
		self.proxbartext showelem();
		self.proxbartext settext( object.usetext );
	}
	if ( self.proxbar.lastuserate != object.userate || self.proxbar.lasthostmigrationstate != isDefined( level.hostmigrationtimer ) )
	{
		if ( object.curprogress > object.usetime )
		{
			object.curprogress = object.usetime;
		}
		if ( object.decayprogress && self.pers[ "team" ] != object.claimteam )
		{
			if ( object.curprogress > 0 )
			{
				progress = object.curprogress / object.usetime;
				rate = ( 1000 / object.usetime ) * ( object.userate * -1 );
				if ( isDefined( level.hostmigrationtimer ) )
				{
					rate = 0;
				}
				self.proxbar updatebar( progress, rate );
			}
		}
		else
		{
			progress = object.curprogress / object.usetime;
			rate = ( 1000 / object.usetime ) * object.userate;
			if ( isDefined( level.hostmigrationtimer ) )
			{
				rate = 0;
			}
			self.proxbar updatebar( progress, rate );
		}
		self.proxbar.lasthostmigrationstate = isDefined( level.hostmigrationtimer );
		self.proxbar.lastuserate = object.userate;
	}
}

getnumtouchingexceptteam( ignoreteam ) //checked partially changed to match cerberus output see github for more info
{
	numtouching = 0;
	foreach ( team in level.teams )
	{
		if ( ignoreteam == team )
		{
		}
		else
		{
			numtouching += self.numtouching[ team ];
		}
	}
	return numtouching;
}

updateuserate() //checked changed to match beta dump
{
	numclaimants = self.numtouching[ self.claimteam ];
	numother = 0;
	numother = getnumtouchingexceptteam( self.claimteam );
	self.userate = 0;
	if ( self.decayprogress )
	{
		if ( numclaimants && !numother )
		{
			self.userate = numclaimants;
		}
		else if ( !numclaimants && numother )
		{
			self.userate = numother;
		}
		else if ( !numclaimants && !numother )
		{
			self.userate = 0;
		}
	}
	else
	{
		if ( numclaimants && !numother )
		{
			self.userate = numclaimants;
		}
	}
	if ( isDefined( self.onupdateuserate ) )
	{
		self [[ self.onupdateuserate ]]();
	}
}

useholdthink( player ) //checked changed to match cerberus output
{
	player notify( "use_hold" );
	if ( !is_true( self.dontlinkplayertotrigger ) )
	{
		player playerlinkto( self.trigger );
		player playerlinkedoffsetenable();
	}
	player clientclaimtrigger( self.trigger );
	player.claimtrigger = self.trigger;
	useweapon = self.useweapon;
	lastweapon = player getcurrentweapon();
	if ( isDefined( useweapon ) )
	{
		/*
/#
		assert( isDefined( lastweapon ) );
#/
		*/
		if ( lastweapon == useweapon )
		{
			/*
/#
			assert( isDefined( player.lastnonuseweapon ) );
#/
			*/
			lastweapon = player.lastnonuseweapon;
		}
		/*
/#
		assert( lastweapon != useweapon );
#/
		*/
		player.lastnonuseweapon = lastweapon;
		player giveweapon( useweapon );
		player setweaponammostock( useweapon, 0 );
		player setweaponammoclip( useweapon, 0 );
		player switchtoweapon( useweapon );
	}
	else
	{
		player _disableweapon();
	}
	self clearprogress();
	self.inuse = 1;
	self.userate = 0;
	objective_setplayerusing( self.objectiveid, player );
	player thread personalusebar( self );
	result = useholdthinkloop( player, lastweapon );
	if ( isDefined( player ) )
	{
		objective_clearplayerusing( self.objectiveid, player );
		self clearprogress();
		if ( isDefined( player.attachedusemodel ) )
		{
			player detach( player.attachedusemodel, "tag_inhand" );
			player.attachedusemodel = undefined;
		}
		player notify( "done_using" );
	}
	if ( isDefined( useweapon ) && isDefined( player ) )
	{
		player thread takeuseweapon( useweapon );
	}
	if ( is_true( result ) )
	{
		return 1;
	}
	if ( isDefined( player ) )
	{
		player.claimtrigger = undefined;
		if ( isDefined( useweapon ) )
		{
			ammo = player getweaponammoclip( lastweapon );
			if ( lastweapon != "none" && !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( lastweapon ) && isweaponequipment( lastweapon ) && player getweaponammoclip( lastweapon ) != 0 )
			{
				player switchtoweapon( lastweapon );
			}
			else
			{
				player takeweapon( useweapon );
				player switchtolastnonkillstreakweapon();
			}
		}
		else if ( isalive( player ) )
		{
			player _enableweapon();
		}
		if ( !is_true( self.dontlinkplayertotrigger ) )
		{
			player unlink();
		}
		if ( !isalive( player ) )
		{
			player.killedinuse = 1;
		}
	}
	self.inuse = 0;
	if ( self.trigger.classname == "trigger_radius_use" )
	{
		player clientreleasetrigger( self.trigger );
	}
	else
	{
		self.trigger releaseclaimedtrigger();
	}
	return 0;
}

takeuseweapon( useweapon ) //checked changed to match cerberus output
{
	self endon( "use_hold" );
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	while ( self getcurrentweapon() == useweapon && !self.throwinggrenade )
	{
		wait 0.05;
	}
	self takeweapon( useweapon );
}

continueholdthinkloop( player, waitforweapon, timedout, usetime ) //checked matches cerberus output
{
	maxwaittime = 1.5;
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( is_true( player.laststand ) )
	{
		return 0;
	}
	if ( self.curprogress >= usetime )
	{
		return 0;
	}
	if ( !player usebuttonpressed() )
	{
		return 0;
	}
	if ( player.throwinggrenade )
	{
		return 0;
	}
	if ( player meleebuttonpressed() )
	{
		return 0;
	}
	if ( player isinvehicle() )
	{
		return 0;
	}
	if ( player isremotecontrolling() )
	{
		return 0;
	}
	if ( player isweaponviewonlylinked() )
	{
		return 0;
	}
	if ( !player istouching( self.trigger ) )
	{
		return 0;
	}
	if ( !self.userate && !waitforweapon )
	{
		return 0;
	}
	if ( waitforweapon && timedout > maxwaittime )
	{
		return 0;
	}
	return 1;
}

updatecurrentprogress() //checked matches cerberus output
{
	if ( self.usetime )
	{
		if ( isDefined( self.curprogress ) )
		{
			progress = float( self.curprogress ) / self.usetime;
		}
		else
		{
			progress = 0;
		}
		objective_setprogress( self.objectiveid, clamp( progress, 0, 1 ) );
	}
}

useholdthinkloop( player, lastweapon ) //checked changed to match beta dump
{
	level endon( "game_ended" );
	self endon( "disabled" );
	useweapon = self.useweapon;
	waitforweapon = 1;
	timedout = 0;
	usetime = self.usetime;
	while ( self continueholdthinkloop( player, waitforweapon, timedout, usetime ) )
	{
		timedout += 0.05;
		if ( !isDefined( useweapon ) || player getcurrentweapon() == useweapon )
		{
			self.curprogress += 50 * self.userate;
			self updatecurrentprogress();
			self.userate = 1;
			waitforweapon = 0;
		}
		else
		{
			self.userate = 0;
		}
		if ( self.curprogress >= usetime )
		{
			self.inuse = 0;
			player clientreleasetrigger( self.trigger );
			player.claimtrigger = undefined;
			if ( isDefined( useweapon ) )
			{
				if ( lastweapon != "none" && !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( lastweapon ) && !( isweaponequipment( lastweapon ) && player getweaponammoclip( lastweapon ) == 0 ) )
				{
					player switchtoweapon( lastweapon );
				}
				else
				{
					player takeweapon( useweapon );
					player switchtolastnonkillstreakweapon();
				}
			}
			else
			{
				player _enableweapon();
			}
			if ( !is_true( self.dontlinkplayertotrigger ) )
			{
				player unlink();
			}
			wait 0.05;
			return isalive( player );
		}
		wait 0.05;
		maps/mp/gametypes/_hostmigration::waittillhostmigrationdone();
	}
	return 0;
}

personalusebar( object ) //checked matches cerberus output
{
	self endon( "disconnect" );
	if ( object.newstyle )
	{
		return;
	}
	if ( isDefined( self.usebar ) )
	{
		return;
	}
	self.usebar = createprimaryprogressbar();
	self.usebartext = createprimaryprogressbartext();
	self.usebartext settext( object.usetext );
	usetime = object.usetime;
	lastrate = -1;
	lasthostmigrationstate = isDefined( level.hostmigrationtimer );
	while ( isalive( self ) && object.inuse && !level.gameended )
	{
		if ( lastrate != object.userate || lasthostmigrationstate != isDefined( level.hostmigrationtimer ) )
		{
			if ( object.curprogress > usetime )
			{
				object.curprogress = usetime;
			}
			if ( object.decayprogress && self.pers[ "team" ] != object.claimteam )
			{
				if ( object.curprogress > 0 )
				{
					progress = object.curprogress / usetime;
					rate = ( 1000 / usetime ) * ( object.userate * -1 );
					if ( isDefined( level.hostmigrationtimer ) )
					{
						rate = 0;
					}
					self.proxbar updatebar( progress, rate );
				}
			}
			else
			{
				progress = object.curprogress / usetime;
				rate = ( 1000 / usetime ) * object.userate;
				if ( isDefined( level.hostmigrationtimer ) )
				{
					rate = 0;
				}
				self.usebar updatebar( progress, rate );
			}
			if ( !object.userate )
			{
				self.usebar hideelem();
				self.usebartext hideelem();
			}
			else
			{
				self.usebar showelem();
				self.usebartext showelem();
			}
		}
		lastrate = object.userate;
		lasthostmigrationstate = isDefined( level.hostmigrationtimer );
		wait 0.05;
	}
	self.usebar destroyelem();
	self.usebartext destroyelem();
}

updatetrigger() //checked changed to match cerberus output
{
	if ( self.triggertype != "use" )
	{
		return;
	}
	if ( self.interactteam == "none" )
	{
		self.trigger.origin -= vectorScale( ( 0, 0, 1 ), 50000 );
	}
	else if ( self.interactteam == "any" || !level.teambased )
	{
		self.trigger.origin = self.curorigin;
		self.trigger setteamfortrigger( "none" );
	}
	else if ( self.interactteam == "friendly" )
	{
		self.trigger.origin = self.curorigin;
		if ( isDefined( level.teams[ self.ownerteam ] ) )
		{
			self.trigger setteamfortrigger( self.ownerteam );
		}
		else
		{
			self.trigger.origin -= vectorScale( ( 0, 0, 1 ), 50000 );
		}
	}
	else if ( self.interactteam == "enemy" )
	{
		self.trigger.origin = self.curorigin;
		self.trigger setexcludeteamfortrigger( self.ownerteam );
	}
}

updateobjective() //checked matches cerberus output
{
	if ( !self.newstyle )
	{
		return;
	}
	objective_team( self.objectiveid, self.ownerteam );
	if ( self.visibleteam == "any" )
	{
		objective_state( self.objectiveid, "active" );
		objective_visibleteams( self.objectiveid, level.spawnsystem.ispawn_teammask[ "all" ] );
	}
	else if ( self.visibleteam == "friendly" )
	{
		objective_state( self.objectiveid, "active" );
		objective_visibleteams( self.objectiveid, level.spawnsystem.ispawn_teammask[ self.ownerteam ] );
	}
	else if ( self.visibleteam == "enemy" )
	{
		objective_state( self.objectiveid, "active" );
		objective_visibleteams( self.objectiveid, level.spawnsystem.ispawn_teammask[ "all" ] & level.spawnsystem.ispawn_teammask[ self.ownerteam ] );
	}
	else
	{
		objective_state( self.objectiveid, "invisible" );
		objective_visibleteams( self.objectiveid, 0 );
	}
	if ( self.type == "carryObject" )
	{
		if ( isalive( self.carrier ) )
		{
			objective_onentity( self.objectiveid, self.carrier );
			return;
		}
		else
		{
			objective_clearentity( self.objectiveid );
		}
	}
}

updateworldicons() //checked matches cerberus output
{
	if ( self.visibleteam == "any" )
	{
		updateworldicon( "friendly", 1 );
		updateworldicon( "enemy", 1 );
	}
	else if ( self.visibleteam == "friendly" )
	{
		updateworldicon( "friendly", 1 );
		updateworldicon( "enemy", 0 );
	}
	else if ( self.visibleteam == "enemy" )
	{
		updateworldicon( "friendly", 0 );
		updateworldicon( "enemy", 1 );
	}
	else
	{
		updateworldicon( "friendly", 0 );
		updateworldicon( "enemy", 0 );
	}
}

updateworldicon( relativeteam, showicon ) //checked partially changed to match cerberus output see info.md
{
	if ( self.newstyle )
	{
		return;
	}
	if ( !isDefined( self.worldicons[ relativeteam ] ) )
	{
		showicon = 0;
	}
	updateteams = getupdateteams( relativeteam );
	index = 0;
	while ( index < updateteams.size )
	{
		if ( !level.teambased && updateteams[ index ] != level.nonteambasedteam )
		{
			index++;
			continue;
		}
		else
		{
			opname = "objpoint_" + updateteams[ index ] + "_" + self.entnum;
			objpoint = maps/mp/gametypes/_objpoints::getobjpointbyname( opname );
			objpoint notify( "stop_flashing_thread" );
			objpoint thread maps/mp/gametypes/_objpoints::stopflashing();
			if ( showicon )
			{
				objpoint setshader( self.worldicons[ relativeteam ], level.objpointsize, level.objpointsize );
				objpoint fadeovertime( 0.05 );
				objpoint.alpha = objpoint.basealpha;
				objpoint.isshown = 1;
				iswaypoint = 1;
				if ( isDefined( self.worldiswaypoint[ relativeteam ] ) )
				{
					iswaypoint = self.worldiswaypoint[ relativeteam ];
				}
				if ( isDefined( self.compassicons[ relativeteam ] ) )
				{
					objpoint setwaypoint( iswaypoint, self.worldicons[ relativeteam ] );
				}
				else
				{
					objpoint setwaypoint( iswaypoint );
				}
				if ( self.type == "carryObject" )
				{
					if ( isDefined( self.carrier ) && !shouldpingobject( relativeteam ) )
					{
						objpoint settargetent( self.carrier );
						break;
					}
					else
					{
						objpoint cleartargetent();
					}
				}
				index++;
				continue;
			}
			objpoint fadeovertime( 0,05 );
			objpoint.alpha = 0;
			objpoint.isshown = 0;
			objpoint cleartargetent();
		}
		index++;
	}
}

updatecompassicons() //checked matches cerberus output
{
	if ( self.visibleteam == "any" )
	{
		updatecompassicon( "friendly", 1 );
		updatecompassicon( "enemy", 1 );
	}
	else if ( self.visibleteam == "friendly" )
	{
		updatecompassicon( "friendly", 1 );
		updatecompassicon( "enemy", 0 );
	}
	else if ( self.visibleteam == "enemy" )
	{
		updatecompassicon( "friendly", 0 );
		updatecompassicon( "enemy", 1 );
	}
	else
	{
		updatecompassicon( "friendly", 0 );
		updatecompassicon( "enemy", 0 );
	}
}

updatecompassicon( relativeteam, showicon ) //checked partially changed to match cerberus output see info.md
{
	if ( self.newstyle )
	{
		return;
	}
	updateteams = getupdateteams( relativeteam );
	index = 0;
	while ( index < updateteams.size )
	{
		showiconthisteam = showicon;
		if ( !showiconthisteam && shouldshowcompassduetoradar( updateteams[ index ] ) )
		{
			showiconthisteam = 1;
		}
		if ( level.teambased )
		{
			objid = self.objid[ updateteams[ index ] ];
		}
		else
		{
			objid = self.objid[ level.nonteambasedteam ];
		}
		if ( !isDefined( self.compassicons[ relativeteam ] ) || !showiconthisteam )
		{
			objective_state( objid, "invisible" );
			index++;
			continue;
		}
		objective_icon( objid, self.compassicons[ relativeteam ] );
		objective_state( objid, "active" );
		if ( self.type == "carryObject" )
		{
			if ( isalive( self.carrier ) && !shouldpingobject( relativeteam ) )
			{
				objective_onentity( objid, self.carrier );
				index++;
				continue;
			}
			objective_position( objid, self.curorigin );
		}
		index++;
	}
}

shouldpingobject( relativeteam ) //checked changed to match cerberus output
{
	if ( relativeteam == "friendly" && self.objidpingfriendly )
	{
		return 1;
	}
	else if ( relativeteam == "enemy" && self.objidpingenemy )
	{
		return 1;
	}
	return 0;
}

getupdateteams( relativeteam ) //checked changed to match beta dump
{
	updateteams = [];
	if ( level.teambased )
	{
		if ( relativeteam == "friendly" )
		{
			foreach ( team in level.teams )
			{
				if ( self isfriendlyteam( team ) )
				{
					updateteams[ updateteams.size ] = team;
				}
			}
		}
		else if ( relativeteam == "enemy" )
		{
			foreach ( team in level.teams )
			{
				if ( !self isfriendlyteam( team ) )
				{
					updateteams[ updateteams.size ] = team;
				}
			}
		}
	}
	else 
	{
		if ( relativeteam == "friendly" )
		{
			updateteams[ updateteams.size ] = level.nonteambasedteam;
		}
		else
		{
			updateteams[ updateteams.size ] = "axis";
		}
	}
	return updateteams;
}

shouldshowcompassduetoradar( team ) //checked matches cerberus output
{
	showcompass = 0;
	if ( !isDefined( self.carrier ) )
	{
		return 0;
	}
	if ( self.carrier hasperk( "specialty_gpsjammer" ) == 0 )
	{
		if ( maps/mp/killstreaks/_radar::teamhasspyplane( team ) )
		{
			showcompass = 1;
		}
	}
	if ( maps/mp/killstreaks/_radar::teamhassatellite( team ) )
	{
		showcompass = 1;
	}
	return showcompass;
}

updatevisibilityaccordingtoradar() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "carrier_cleared" );
	while ( 1 )
	{
		level waittill( "radar_status_change" );
		self updatecompassicons();
	}
}

setownerteam( team ) //checked matches cerberus output
{
	self.ownerteam = team;
	self updatetrigger();
	self updatecompassicons();
	self updateworldicons();
	self updateobjective();
}

getownerteam() //checked matches cerberus output
{
	return self.ownerteam;
}

setdecaytime( time ) //checked matches cerberus output
{
	self.decaytime = int( time * 1000 );
}

setusetime( time ) //checked matches cerberus output
{
	self.usetime = int( time * 1000 );
}

setusetext( text ) //checked matches cerberus output
{
	self.usetext = text;
}

setteamusetime( relativeteam, time ) //checked matches cerberus output
{
	self.teamusetimes[ relativeteam ] = int( time * 1000 );
}

setteamusetext( relativeteam, text ) //checked matches cerberus output
{
	self.teamusetexts[ relativeteam ] = text;
}

setusehinttext( text ) //checked matches cerberus output
{
	self.trigger sethintstring( text );
}

allowcarry( relativeteam ) //checked matches cerberus output
{
	allowuse( relativeteam );
}

allowuse( relativeteam ) //checked matches cerberus output
{
	self.interactteam = relativeteam;
	updatetrigger();
}

setvisibleteam( relativeteam ) //checked matches cerberus output
{
	self.visibleteam = relativeteam;
	if ( !maps/mp/gametypes/_tweakables::gettweakablevalue( "hud", "showobjicons" ) )
	{
		self.visibleteam = "none";
	}
	updatecompassicons();
	updateworldicons();
	updateobjective();
}

setmodelvisibility( visibility ) //checked changed to match beta dump
{
	if ( visibility )
	{
		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[ index ] show();
			if ( self.visuals[ index ].classname == "script_brushmodel" || self.visuals[ index ].classname == "script_model" )
			{
				self.visuals[ index ] thread makesolid();
			}
		}
	}
	else 
	{
		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[ index ] hide();
			if ( self.visuals[ index ].classname == "script_brushmodel" || self.visuals[ index ].classname == "script_model" )
			{
				self.visuals[ index ] notify( "changing_solidness" );
				self.visuals[ index ] notsolid();
			}
		}
	}
}

makesolid() //checked changed to match cerberus output
{
	self endon( "death" );
	self notify( "changing_solidness" );
	self endon( "changing_solidness" );
	while ( 1 )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[ i ] istouching( self ) )
			{
				break;
			}
		}
		if ( i == level.players.size )
		{
			self solid();
			return;
		}
		wait 0.05;
	}
}

setcarriervisible( relativeteam ) //checked matches cerberus output
{
	self.carriervisible = relativeteam;
}

setcanuse( relativeteam ) //checked matches cerberus output
{
	self.useteam = relativeteam;
}

set2dicon( relativeteam, shader ) //checked matches cerberus output
{
	self.compassicons[ relativeteam ] = shader;
	updatecompassicons();
}

set3dicon( relativeteam, shader ) //checked matches cerberus output
{
	self.worldicons[ relativeteam ] = shader;
	updateworldicons();
}

set3duseicon( relativeteam, shader ) //checked matches cerberus output
{
	self.worlduseicons[ relativeteam ] = shader;
}

set3diswaypoint( relativeteam, waypoint ) //checked matches cerberus output
{
	self.worldiswaypoint[ relativeteam ] = waypoint;
}

setcarryicon( shader ) //checked matches cerberus output
{
	self.carryicon = shader;
}

setvisiblecarriermodel( visiblemodel ) //checked matches cerberus output
{
	self.visiblecarriermodel = visiblemodel;
}

getvisiblecarriermodel() //checked matches cerberus output
{
	return self.visiblecarriermodel;
}

destroyobject( deletetrigger, forcehide ) //checked changed to match cerberus output
{
	if ( !isDefined( forcehide ) )
	{
		forcehide = 1;
	}
	self disableobject( forcehide );
	foreach ( visual in self.visuals )
	{
		visual hide();
		visual delete();
	}
	self.trigger notify( "destroyed" );
	if ( is_true( deletetrigger ) )
	{
		self.trigger delete();
	}
	else
	{
		self.trigger triggeron();
	}
}

disableobject( forcehide ) //checked changed to match cerberus output
{
	self notify( "disabled" );
	if ( self.type == "carryObject" || is_true( forcehide ) )
	{
		if ( isDefined( self.carrier ) )
		{
			self.carrier takeobject( self );
		}
		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[ index ] hide();
		}
	}
	self.trigger triggeroff();
	self setvisibleteam( "none" );
}

enableobject( forceshow ) //checked changed to match cerberus output
{
	if ( self.type == "carryObject" || is_true( forceshow ) )
	{
		for ( index = 0; index < self.visuals.size; index++ )
		{
			self.visuals[ index ] show();
		}
	}
	self.trigger triggeron();
	self setvisibleteam( "any" );
}

getrelativeteam( team ) //checked changed to match cerberus output
{
	if ( self.ownerteam == "any" )
	{
		return "friendly";
	}
	if ( team == self.ownerteam )
	{
		return "friendly";
	}
	else if ( team == getenemyteam( self.ownerteam ) )
	{
		return "enemy";
	}
	else
	{
		return "neutral";
	}
}

isfriendlyteam( team )
{
	if ( !level.teambased )
	{
		return 1;
	}
	if ( self.ownerteam == "any" )
	{
		return 1;
	}
	if ( self.ownerteam == team )
	{
		return 1;
	}
	return 0;
}

caninteractwith( player ) //checked changed to match beta dump
{
	team = player.pers[ "team" ];
	switch( self.interactteam )
	{
		case "none":
			return 0;
		case "any":
			return 1;
		case "friendly":
			if ( level.teambased )
			{
				if ( team == self.ownerteam )
				{
					return 1;
				}
				else
				{
					return 0;
				}
			}
			else
			{
				if ( player == self.ownerteam )
				{
					return 1;
				}
				else
				{
					return 0;
			}
		}
		case "enemy":
			if ( level.teambased )
			{
				if ( team != self.ownerteam )
				{
					return 1;
				}
				else if ( is_true( self.decayprogress ) && self.curprogress > 0 )
				{
					return 1;
				}
				else
				{
					return 0;
				}
			}
			else
			{
				if ( player != self.ownerteam )
				{
					return 1;
				}
				else
				{
					return 0;
			}
		}
		default:
			/*
/#
			assert( 0, "invalid interactTeam" );
#/
			*/
			return 0;
	}
}

isteam( team ) //checked matches cerberus output
{
	if ( team == "neutral" )
	{
		return 1;
	}
	if ( isDefined( level.teams[ team ] ) )
	{
		return 1;
	}
	if ( team == "any" )
	{
		return 1;
	}
	if ( team == "none" )
	{
		return 1;
	}
	return 0;
}

isrelativeteam( relativeteam ) //checked matches cerberus output
{
	if ( relativeteam == "friendly" )
	{
		return 1;
	}
	if ( relativeteam == "enemy" )
	{
		return 1;
	}
	if ( relativeteam == "any" )
	{
		return 1;
	}
	if ( relativeteam == "none" )
	{
		return 1;
	}
	return 0;
}

getenemyteam( team ) //checked changed to match cerberus output
{
	if ( team == "neutral" )
	{
		return "none";
	}
	else if ( team == "allies" )
	{
		return "axis";
	}
	else
	{
		return "allies";
	}
}

getnextobjid() //checked matches cerberus output
{
	nextid = 0;
	if ( level.releasedobjectives.size > 0 )
	{
		nextid = level.releasedobjectives[ level.releasedobjectives.size - 1 ];
	}
	else
	{
		nextid = level.numgametypereservedobjectives;
		level.numgametypereservedobjectives++;
	}
	/*
/#
	if ( nextid >= 32 )
	{
		println( "^3SCRIPT WARNING: Ran out of objective IDs" );
#/
	}
	*/
	if ( nextid > 31 )
	{
		nextid = 31;
	}
	return nextid;
}

releaseobjid( objid ) //checked changed to match cerberus output
{
	/*
/#
	assert( objid < level.numgametypereservedobjectives );
#/
	*/
	for ( i = 0; i < level.releasedobjectives.size; i++ )
	{
		if ( objid == level.releasedobjectives[ i ] && objid == 31 )
		{
			return;
		}
		/*
/#
		assert( objid != level.releasedobjectives[ i ] );
#/
		*/
	}
	level.releasedobjectives[ level.releasedobjectives.size ] = objid;
}

getlabel() //checked matches cerberus output
{
	label = self.trigger.script_label;
	if ( !isDefined( label ) )
	{
		label = "";
		return label;
	}
	if ( label[ 0 ] != "_" )
	{
		return "_" + label;
	}
	return label;
}

mustmaintainclaim( enabled ) //checked matches cerberus output
{
	self.mustmaintainclaim = enabled;
}

cancontestclaim( enabled ) //checked matches cerberus output
{
	self.cancontestclaim = enabled;
}

setflags( flags ) //checked matches cerberus output
{
	objective_setgamemodeflags( self.objectiveid, flags );
}

getflags( flags ) //checked matches cerberus output
{
	return objective_getgamemodeflags( self.objectiveid );
}


