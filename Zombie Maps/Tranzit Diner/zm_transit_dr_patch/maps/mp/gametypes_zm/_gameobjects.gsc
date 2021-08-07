#include maps/mp/gametypes_zm/_tweakables;
#include maps/mp/gametypes_zm/_hostmigration;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

main( allowed )
{
	level.vehiclesenabled = getgametypesetting( "vehiclesEnabled" );
	level.vehiclestimed = getgametypesetting( "vehiclesTimed" );
	level.objectivepingdelay = getgametypesetting( "objectivePingTime" );
	level.nonteambasedteam = "allies";
/#
	if ( level.script == "mp_vehicle_test" )
	{
		level.vehiclesenabled = 1;
#/
	}
	if ( level.vehiclesenabled )
	{
		allowed[ allowed.size ] = "vehicle";
		filter_script_vehicles_from_vehicle_descriptors( allowed );
	}
	entities = getentarray();
	entity_index = entities.size - 1;
	while ( entity_index >= 0 )
	{
		entity = entities[ entity_index ];
		if ( !entity_is_allowed( entity, allowed ) )
		{
			entity delete();
		}
		entity_index--;

	}
	return;
}

entity_is_allowed( entity, allowed_game_modes )
{
	if ( isDefined( level.createfx_enabled ) && level.createfx_enabled )
	{
		return 1;
	}
	allowed = 1;
	while ( isDefined( entity.script_gameobjectname ) && entity.script_gameobjectname != "[all_modes]" )
	{
		allowed = 0;
		gameobjectnames = strtok( entity.script_gameobjectname, " " );
		i = 0;
		while ( i < allowed_game_modes.size && !allowed )
		{
			j = 0;
			while ( j < gameobjectnames.size && !allowed )
			{
				allowed = gameobjectnames[ j ] == allowed_game_modes[ i ];
				j++;
			}
			i++;
		}
	}
	return allowed;
}

filter_script_vehicles_from_vehicle_descriptors( allowed_game_modes )
{
	vehicle_descriptors = getentarray( "vehicle_descriptor", "targetname" );
	script_vehicles = getentarray( "script_vehicle", "classname" );
	vehicles_to_remove = [];
	descriptor_index = 0;
	while ( descriptor_index < vehicle_descriptors.size )
	{
		descriptor = vehicle_descriptors[ descriptor_index ];
		closest_distance_sq = 1E+12;
		closest_vehicle = undefined;
		vehicle_index = 0;
		while ( vehicle_index < script_vehicles.size )
		{
			vehicle = script_vehicles[ vehicle_index ];
			dsquared = distancesquared( vehicle getorigin(), descriptor getorigin() );
			if ( dsquared < closest_distance_sq )
			{
				closest_distance_sq = dsquared;
				closest_vehicle = vehicle;
			}
			vehicle_index++;
		}
		if ( isDefined( closest_vehicle ) )
		{
			if ( !entity_is_allowed( descriptor, allowed_game_modes ) )
			{
				vehicles_to_remove[ vehicles_to_remove.size ] = closest_vehicle;
			}
		}
		descriptor_index++;
	}
	vehicle_index = 0;
	while ( vehicle_index < vehicles_to_remove.size )
	{
		vehicles_to_remove[ vehicle_index ] delete();
		vehicle_index++;
	}
	return;
}

init()
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

onplayerconnect()
{
	level endon( "game_ended" );
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
		player thread ondisconnect();
	}
}

onplayerspawned()
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

ondeath()
{
	level endon( "game_ended" );
	self endon( "spawned_player" );
	self waittill( "death" );
	if ( isDefined( self.carryobject ) )
	{
		self.carryobject thread setdropped();
	}
}

ondisconnect()
{
	level endon( "game_ended" );
	self waittill( "disconnect" );
	if ( isDefined( self.carryobject ) )
	{
		self.carryobject thread setdropped();
	}
}

createcarryobject( ownerteam, trigger, visuals, offset, objectivename )
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
		offset = ( 0, 0, 1 );
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
	index = 0;
	while ( index < visuals.size )
	{
		visuals[ index ].baseorigin = visuals[ index ].origin;
		visuals[ index ].baseangles = visuals[ index ].angles;
		index++;
	}
	carryobject.visuals = visuals;
	carryobject.compassicons = [];
	carryobject.objid = [];
	while ( !carryobject.newstyle )
	{
		_a272 = level.teams;
		_k272 = getFirstArrayKey( _a272 );
		while ( isDefined( _k272 ) )
		{
			team = _a272[ _k272 ];
			carryobject.objid[ team ] = getnextobjid();
			_k272 = getNextArrayKey( _a272, _k272 );
		}
	}
	carryobject.objidpingfriendly = 0;
	carryobject.objidpingenemy = 0;
	level.objidstart += 2;
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
		carryobject thread carryobjectproxthink();
	}
	carryobject thread updatecarryobjectorigin();
	carryobject thread updatecarryobjectobjectiveorigin();
	return carryobject;
}

carryobjectusethink()
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	while ( 1 )
	{
		self.trigger waittill( "trigger", player );
		while ( self.isresetting )
		{
			continue;
		}
		while ( !isalive( player ) )
		{
			continue;
		}
		if ( isDefined( player.laststand ) && player.laststand )
		{
			continue;
		}
		while ( !self caninteractwith( player ) )
		{
			continue;
		}
		while ( !player.canpickupobject )
		{
			continue;
		}
		while ( player.throwinggrenade )
		{
			continue;
		}
		while ( isDefined( self.carrier ) )
		{
			continue;
		}
		while ( player isinvehicle() )
		{
			continue;
		}
		while ( player isweaponviewonlylinked() )
		{
			continue;
		}
		while ( !player istouching( self.trigger ) )
		{
			continue;
		}
		self setpickedup( player );
	}
}

carryobjectproxthink()
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	while ( 1 )
	{
		self.trigger waittill( "trigger", player );
		while ( self.isresetting )
		{
			continue;
		}
		while ( !isalive( player ) )
		{
			continue;
		}
		if ( isDefined( player.laststand ) && player.laststand )
		{
			continue;
		}
		while ( !self caninteractwith( player ) )
		{
			continue;
		}
		while ( !player.canpickupobject )
		{
			continue;
		}
		while ( player.throwinggrenade )
		{
			continue;
		}
		while ( isDefined( self.carrier ) )
		{
			continue;
		}
		while ( player isinvehicle() )
		{
			continue;
		}
		while ( player isweaponviewonlylinked() )
		{
			continue;
		}
		while ( !player istouching( self.trigger ) )
		{
			continue;
		}
		self setpickedup( player );
	}
}

pickupobjectdelay( origin )
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
		else
		{
			wait 0,2;
		}
	}
	self.canpickupobject = 1;
}

setpickedup( player )
{
	if ( isDefined( player.carryobject ) )
	{
		if ( isDefined( player.carryobject.swappable ) && player.carryobject.swappable )
		{
			player.carryobject thread setdropped();
		}
		else
		{
			if ( isDefined( self.onpickupfailed ) )
			{
				self [[ self.onpickupfailed ]]( player );
			}
			return;
		}
	}
	player giveobject( self );
	self setcarrier( player );
	index = 0;
	while ( index < self.visuals.size )
	{
		self.visuals[ index ] thread hideobject();
		index++;
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

hideobject()
{
	radius = 32;
	origin = self.origin;
	grenades = getentarray( "grenade", "classname" );
	radiussq = radius * radius;
	linkedgrenades = [];
	linkedgrenadesindex = 0;
	self hide();
	i = 0;
	while ( i < grenades.size )
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
		i++;
	}
	self.origin += vectorScale( ( 0, 0, 1 ), 10000 );
	waittillframeend;
	i = 0;
	while ( i < linkedgrenadesindex )
	{
		linkedgrenades[ i ] launch( vectorScale( ( 0, 0, 1 ), 5 ) );
		i++;
	}
}

updatecarryobjectorigin()
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
			while ( self.visibleteam != "friendly" && self.visibleteam == "any" && self.objidpingfriendly )
			{
				_a579 = level.teams;
				_k579 = getFirstArrayKey( _a579 );
				while ( isDefined( _k579 ) )
				{
					team = _a579[ _k579 ];
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
					_k579 = getNextArrayKey( _a579, _k579 );
				}
			}
			if ( self.visibleteam != "enemy" && self.visibleteam == "any" && self.objidpingenemy )
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
			continue;
		}
		else
		{
			if ( isDefined( self.carrier ) )
			{
				self.curorigin = self.carrier.origin + vectorScale( ( 0, 0, 1 ), 75 );
				wait 0,05;
				break;
			}
			else
			{
				wait 0,05;
			}
		}
	}
}

updatecarryobjectobjectiveorigin()
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
			continue;
		}
		else
		{
			objective_position( self.objectiveid, self.curorigin );
			wait 0,05;
		}
	}
}

giveobject( object )
{
/#
	assert( !isDefined( self.carryobject ) );
#/
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
		self maps/mp/gametypes_zm/_weapons::forcestowedweaponupdate();
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
			else self.carryicon = createicon( object.carryicon, 50, 50 );
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
			self.carryicon.alpha = 0,75;
			self.carryicon.hidewhileremotecontrolling = 1;
			self.carryicon.hidewheninkillcam = 1;
		}
	}
}

returnhome()
{
	self.isresetting = 1;
	self notify( "reset" );
	index = 0;
	while ( index < self.visuals.size )
	{
		self.visuals[ index ].origin = self.visuals[ index ].baseorigin;
		self.visuals[ index ].angles = self.visuals[ index ].baseangles;
		self.visuals[ index ] show();
		index++;
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

isobjectawayfromhome()
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

setposition( origin, angles )
{
	self.isresetting = 1;
	index = 0;
	while ( index < self.visuals.size )
	{
		visual = self.visuals[ index ];
		visual.origin = origin;
		visual.angles = angles;
		visual show();
		index++;
	}
	self.trigger.origin = origin;
	self.curorigin = self.trigger.origin;
	self clearcarrier();
	updateworldicons();
	updatecompassicons();
	updateobjective();
	self.isresetting = 0;
}

onplayerlaststand()
{
	if ( isDefined( self.carryobject ) )
	{
		self.carryobject thread setdropped();
	}
}

setdropped()
{
	self.isresetting = 1;
	self notify( "dropped" );
	startorigin = ( 0, 0, 1 );
	endorigin = ( 0, 0, 1 );
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
		index = 0;
		while ( index < self.visuals.size )
		{
			self.visuals[ index ].origin = droporigin;
			self.visuals[ index ].angles = dropangles;
			self.visuals[ index ] show();
			index++;
		}
		self.trigger.origin = droporigin;
		self.curorigin = self.trigger.origin;
		self thread pickuptimeout( trace[ 2 ], startorigin[ 2 ] );
	}
	else
	{
		index = 0;
		while ( index < self.visuals.size )
		{
			self.visuals[ index ].origin = self.visuals[ index ].baseorigin;
			self.visuals[ index ].angles = self.visuals[ index ].baseangles;
			self.visuals[ index ] show();
			index++;
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

setcarrier( carrier )
{
	self.carrier = carrier;
	objective_setplayerusing( self.objectiveid, carrier );
	self thread updatevisibilityaccordingtoradar();
}

clearcarrier()
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

shouldbereset( minz, maxz )
{
	minetriggers = getentarray( "minefield", "targetname" );
	hurttriggers = getentarray( "trigger_hurt", "classname" );
	elevators = getentarray( "script_elevator", "targetname" );
	index = 0;
	while ( index < minetriggers.size )
	{
		if ( self.visuals[ 0 ] istouchingswept( minetriggers[ index ], minz, maxz ) )
		{
			return 1;
		}
		index++;
	}
	index = 0;
	while ( index < hurttriggers.size )
	{
		if ( self.visuals[ 0 ] istouchingswept( hurttriggers[ index ], minz, maxz ) )
		{
			return 1;
		}
		index++;
	}
	index = 0;
	while ( index < elevators.size )
	{
/#
		assert( isDefined( elevators[ index ].occupy_volume ) );
#/
		if ( self.visuals[ 0 ] istouchingswept( elevators[ index ].occupy_volume, minz, maxz ) )
		{
			return 1;
		}
		index++;
	}
	return 0;
}

pickuptimeout( minz, maxz )
{
	self endon( "pickup_object" );
	self endon( "stop_pickup_timeout" );
	wait 0,05;
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

takeobject( object )
{
	if ( isDefined( self.carryicon ) )
	{
		self.carryicon destroyelem();
	}
	if ( isDefined( object.visiblecarriermodel ) )
	{
		self maps/mp/gametypes_zm/_weapons::detach_all_weapons();
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
		self maps/mp/gametypes_zm/_weapons::forcestowedweaponupdate();
	}
	if ( !object.allowweapons )
	{
		self _enableweapon();
	}
}

trackcarrier()
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
		wait 0,05;
	}
}

manualdropthink()
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "drop_object" );
	for ( ;; )
	{
		while ( !self attackbuttonpressed() && !self fragbuttonpressed() || self secondaryoffhandbuttonpressed() && self meleebuttonpressed() )
		{
			wait 0,05;
		}
		while ( !self attackbuttonpressed() && !self fragbuttonpressed() && !self secondaryoffhandbuttonpressed() && !self meleebuttonpressed() )
		{
			wait 0,05;
		}
		if ( isDefined( self.carryobject ) && !self usebuttonpressed() )
		{
			self.carryobject thread setdropped();
		}
	}
}

createuseobject( ownerteam, trigger, visuals, offset, objectivename )
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
	index = 0;
	while ( index < visuals.size )
	{
		visuals[ index ].baseorigin = visuals[ index ].origin;
		visuals[ index ].baseangles = visuals[ index ].angles;
		index++;
	}
	useobject.visuals = visuals;
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 1 );
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
		_a1138 = level.teams;
		_k1138 = getFirstArrayKey( _a1138 );
		while ( isDefined( _k1138 ) )
		{
			team = _a1138[ _k1138 ];
			useobject.objid[ team ] = getnextobjid();
			_k1138 = getNextArrayKey( _a1138, _k1138 );
		}
		if ( level.teambased )
		{
			_a1145 = level.teams;
			_k1145 = getFirstArrayKey( _a1145 );
			while ( isDefined( _k1145 ) )
			{
				team = _a1145[ _k1145 ];
				objective_add( useobject.objid[ team ], "invisible", useobject.curorigin );
				objective_team( useobject.objid[ team ], team );
				_k1145 = getNextArrayKey( _a1145, _k1145 );
			}
		}
		else objective_add( useobject.objid[ level.nonteambasedteam ], "invisible", useobject.curorigin );
	}
	useobject.objectiveid = getnextobjid();
	objective_add( useobject.objectiveid, "invisible", useobject.curorigin, objectivename );
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
		_a1208 = level.teams;
		_k1208 = getFirstArrayKey( _a1208 );
		while ( isDefined( _k1208 ) )
		{
			team = _a1208[ _k1208 ];
			useobject.numtouching[ team ] = 0;
			useobject.touchlist[ team ] = [];
			_k1208 = getNextArrayKey( _a1208, _k1208 );
		}
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

setkeyobject( object )
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

haskeyobject( use )
{
	x = 0;
	while ( x < use.keyobject.size )
	{
		if ( isDefined( self.carryobject ) && isDefined( use.keyobject[ x ] ) && self.carryobject == use.keyobject[ x ] )
		{
			return 1;
		}
		x++;
	}
	return 0;
}

useobjectusethink()
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	while ( 1 )
	{
		self.trigger waittill( "trigger", player );
		while ( !isalive( player ) )
		{
			continue;
		}
		while ( !self caninteractwith( player ) )
		{
			continue;
		}
		while ( !player isonground() )
		{
			continue;
		}
		while ( player isinvehicle() )
		{
			continue;
		}
		while ( isDefined( self.keyobject ) || !isDefined( player.carryobject ) && !player haskeyobject( self ) )
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
		while ( !result )
		{
			continue;
		}
		if ( isDefined( self.onuse ) )
		{
			self [[ self.onuse ]]( player );
		}
	}
}

getearliestclaimplayer()
{
/#
	assert( self.claimteam != "none" );
#/
	team = self.claimteam;
	earliestplayer = self.claimplayer;
	while ( self.touchlist[ team ].size > 0 )
	{
		earliesttime = undefined;
		players = getarraykeys( self.touchlist[ team ] );
		index = 0;
		while ( index < players.size )
		{
			touchdata = self.touchlist[ team ][ players[ index ] ];
			if ( !isDefined( earliesttime ) || touchdata.starttime < earliesttime )
			{
				earliestplayer = touchdata.player;
				earliesttime = touchdata.starttime;
			}
			index++;
		}
	}
	return earliestplayer;
}

useobjectproxthink()
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
			self setclaimteam( "none" );
			self.claimplayer = undefined;
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
			else if ( self.usetime )
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
				else
				{
					if ( !self.numtouching[ self.claimteam ] )
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
			else
			{
				if ( self.cancontestclaim )
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
		else
		{
			if ( self.curprogress > 0 && ( getTime() - self.lastclaimtime ) > ( self.claimgraceperiod * 1000 ) )
			{
				self clearprogress();
			}
		}
		wait 0,05;
		maps/mp/gametypes_zm/_hostmigration::waittillhostmigrationdone();
	}
}

useobjectlockedforteam( team )
{
	if ( isDefined( self.teamlock ) && isDefined( level.teams[ team ] ) )
	{
		return self.teamlock[ team ];
	}
	return 0;
}

canclaim( player )
{
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

proxtriggerthink()
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
		while ( player isinvehicle() )
		{
			continue;
		}
		while ( player isweaponviewonlylinked() )
		{
			continue;
		}
		if ( self caninteractwith( player ) && self.claimteam == "none" )
		{
			if ( self canclaim( player ) )
			{
				setclaimteam( player.pers[ "team" ] );
				self.claimplayer = player;
				if ( self.usetime && isDefined( self.onbeginuse ) )
				{
					self [[ self.onbeginuse ]]( self.claimplayer );
				}
				break;
			}
			else
			{
				if ( isDefined( self.oncantuse ) )
				{
					self [[ self.oncantuse ]]( player );
				}
			}
		}
		if ( isalive( player ) && !isDefined( player.touchtriggers[ entitynumber ] ) )
		{
			player thread triggertouchthink( self );
		}
	}
}

clearprogress()
{
	self.curprogress = 0;
	self updatecurrentprogress();
	if ( isDefined( self.onuseclear ) )
	{
		self [[ self.onuseclear ]]();
	}
}

setclaimteam( newteam )
{
/#
	assert( newteam != self.claimteam );
#/
	if ( self.claimteam == "none" && ( getTime() - self.lastclaimtime ) > ( self.claimgraceperiod * 1000 ) )
	{
		self clearprogress();
	}
	else
	{
		if ( newteam != "none" && newteam != self.lastclaimteam )
		{
			self clearprogress();
		}
	}
	self.lastclaimteam = self.claimteam;
	self.lastclaimtime = getTime();
	self.claimteam = newteam;
	self updateuserate();
}

getclaimteam()
{
	return self.claimteam;
}

continuetriggertouchthink( team, object )
{
	if ( !isalive( self ) )
	{
		return 0;
	}
	if ( self useobjectlockedforteam( team ) )
	{
		return 0;
	}
	if ( self isinvehicle() )
	{
		return 0;
	}
	if ( !self istouching( object.trigger ) )
	{
		return 0;
	}
	return 1;
}

triggertouchthink( object )
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
		wait 0,05;
	}
	if ( isDefined( self ) )
	{
		if ( object.usetime )
		{
			self updateproxbar( object, 1 );
		}
		objective_clearplayerusing( object.objectiveid, self );
	}
	if ( level.gameended )
	{
		return;
	}
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

updateproxbar( object, forceremove )
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
		else if ( !isDefined( self.proxbar ) )
		{
			self.proxbar = createprimaryprogressbar();
			self.proxbar.lastuserate = -1;
		}
		if ( self.pers[ "team" ] == object.claimteam )
		{
			if ( self.proxbar.bar.color != ( 0, 0, 1 ) )
			{
				self.proxbar.bar.color = ( 0, 0, 1 );
				self.proxbar.lastuserate = -1;
			}
		}
		else
		{
			if ( self.proxbar.bar.color != ( 0, 0, 1 ) )
			{
				self.proxbar.bar.color = ( 0, 0, 1 );
				self.proxbar.lastuserate = -1;
			}
		}
	}
	else
	{
		if ( !forceremove || !object caninteractwith( self ) && self.pers[ "team" ] != object.claimteam )
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
	}
	if ( !isDefined( self.proxbar ) )
	{
		self.proxbar = self createprimaryprogressbar();
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
		self.proxbartext = self createprimaryprogressbartext();
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

getnumtouchingexceptteam( ignoreteam )
{
	numtouching = 0;
	_a1855 = level.teams;
	_k1855 = getFirstArrayKey( _a1855 );
	while ( isDefined( _k1855 ) )
	{
		team = _a1855[ _k1855 ];
		if ( ignoreteam == team )
		{
		}
		else
		{
			numtouching += self.numtouching[ team ];
		}
		_k1855 = getNextArrayKey( _a1855, _k1855 );
	}
	return numtouching;
}

updateuserate()
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
		else
		{
			if ( !numclaimants && numother )
			{
				self.userate = numother;
			}
			else
			{
				if ( !numclaimants && !numother )
				{
					self.userate = 0;
				}
			}
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

useholdthink( player )
{
	player notify( "use_hold" );
	if ( isDefined( self.dontlinkplayertotrigger ) && !self.dontlinkplayertotrigger )
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
/#
		assert( isDefined( lastweapon ) );
#/
		if ( lastweapon == useweapon )
		{
/#
			assert( isDefined( player.lastnonuseweapon ) );
#/
			lastweapon = player.lastnonuseweapon;
		}
/#
		assert( lastweapon != useweapon );
#/
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
	if ( isDefined( result ) && result )
	{
		return 1;
	}
	if ( isDefined( player ) )
	{
		player.claimtrigger = undefined;
		if ( isDefined( useweapon ) )
		{
			ammo = player getweaponammoclip( lastweapon );
			if ( lastweapon != "none" && isweaponequipment( lastweapon ) && player getweaponammoclip( lastweapon ) != 0 )
			{
				player switchtoweapon( lastweapon );
			}
			else
			{
				player takeweapon( useweapon );
			}
		}
		else
		{
			if ( isalive( player ) )
			{
				player _enableweapon();
			}
		}
		if ( isDefined( self.dontlinkplayertotrigger ) && !self.dontlinkplayertotrigger )
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

takeuseweapon( useweapon )
{
	self endon( "use_hold" );
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	while ( self getcurrentweapon() == useweapon && !self.throwinggrenade )
	{
		wait 0,05;
	}
	self takeweapon( useweapon );
}

continueholdthinkloop( player, waitforweapon, timedout, usetime )
{
	maxwaittime = 1,5;
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( isDefined( player.laststand ) && player.laststand )
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

updatecurrentprogress()
{
	if ( self.usetime )
	{
		progress = float( self.curprogress ) / self.usetime;
		objective_setprogress( self.objectiveid, clamp( progress, 0, 1 ) );
	}
}

useholdthinkloop( player, lastweapon )
{
	level endon( "game_ended" );
	self endon( "disabled" );
	useweapon = self.useweapon;
	waitforweapon = 1;
	timedout = 0;
	usetime = self.usetime;
	while ( self continueholdthinkloop( player, waitforweapon, timedout, usetime ) )
	{
		timedout += 0,05;
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
				player setweaponammostock( useweapon, 1 );
				player setweaponammoclip( useweapon, 1 );
				if ( lastweapon != "none" && isweaponequipment( lastweapon ) && player getweaponammoclip( lastweapon ) != 0 )
				{
					player switchtoweapon( lastweapon );
				}
				else
				{
					player takeweapon( useweapon );
				}
			}
			else
			{
				player _enableweapon();
			}
			if ( isDefined( self.dontlinkplayertotrigger ) && !self.dontlinkplayertotrigger )
			{
				player unlink();
			}
			wait 0,05;
			return isalive( player );
		}
		wait 0,05;
		maps/mp/gametypes_zm/_hostmigration::waittillhostmigrationdone();
	}
	return 0;
}

personalusebar( object )
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
	self.usebar = self createprimaryprogressbar();
	self.usebartext = self createprimaryprogressbartext();
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
		wait 0,05;
	}
	self.usebar destroyelem();
	self.usebartext destroyelem();
}

updatetrigger()
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
	else
	{
		if ( self.interactteam == "friendly" )
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
			return;
		}
		else
		{
			if ( self.interactteam == "enemy" )
			{
				self.trigger.origin = self.curorigin;
				self.trigger setexcludeteamfortrigger( self.ownerteam );
			}
		}
	}
}

updateobjective()
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

updateworldicons()
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

updateworldicon( relativeteam, showicon )
{
}

updatecompassicons()
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

updatecompassicon( relativeteam, showicon )
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
		else
		{
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
				else
				{
					objective_position( objid, self.curorigin );
				}
			}
		}
		index++;
	}
}

shouldpingobject( relativeteam )
{
	if ( relativeteam == "friendly" && self.objidpingfriendly )
	{
		return 1;
	}
	else
	{
		if ( relativeteam == "enemy" && self.objidpingenemy )
		{
			return 1;
		}
	}
	return 0;
}

getupdateteams( relativeteam )
{
	updateteams = [];
	if ( level.teambased )
	{
		if ( relativeteam == "friendly" )
		{
			_a2479 = level.teams;
			_k2479 = getFirstArrayKey( _a2479 );
			while ( isDefined( _k2479 ) )
			{
				team = _a2479[ _k2479 ];
				if ( self isfriendlyteam( team ) )
				{
					updateteams[ updateteams.size ] = team;
				}
				_k2479 = getNextArrayKey( _a2479, _k2479 );
			}
		}
		else while ( relativeteam == "enemy" )
		{
			_a2487 = level.teams;
			_k2487 = getFirstArrayKey( _a2487 );
			while ( isDefined( _k2487 ) )
			{
				team = _a2487[ _k2487 ];
				if ( !self isfriendlyteam( team ) )
				{
					updateteams[ updateteams.size ] = team;
				}
				_k2487 = getNextArrayKey( _a2487, _k2487 );
			}
		}
	}
	else if ( relativeteam == "friendly" )
	{
		updateteams[ updateteams.size ] = level.nonteambasedteam;
	}
	else
	{
		updateteams[ updateteams.size ] = "axis";
	}
	return updateteams;
}

shouldshowcompassduetoradar( team )
{
	showcompass = 0;
	return showcompass;
}

updatevisibilityaccordingtoradar()
{
	self endon( "death" );
	self endon( "carrier_cleared" );
	while ( 1 )
	{
		level waittill( "radar_status_change" );
		self updatecompassicons();
	}
}

setownerteam( team )
{
	self.ownerteam = team;
	self updatetrigger();
	self updatecompassicons();
	self updateworldicons();
	self updateobjective();
}

getownerteam()
{
	return self.ownerteam;
}

setdecaytime( time )
{
	self.decaytime = int( time * 1000 );
}

setusetime( time )
{
	self.usetime = int( time * 1000 );
}

setusetext( text )
{
	self.usetext = text;
}

setusehinttext( text )
{
	self.trigger sethintstring( text );
}

allowcarry( relativeteam )
{
	self.interactteam = relativeteam;
}

allowuse( relativeteam )
{
	self.interactteam = relativeteam;
	updatetrigger();
}

setvisibleteam( relativeteam )
{
	self.visibleteam = relativeteam;
	if ( !maps/mp/gametypes_zm/_tweakables::gettweakablevalue( "hud", "showobjicons" ) )
	{
		self.visibleteam = "none";
	}
	updatecompassicons();
	updateworldicons();
	updateobjective();
}

setmodelvisibility( visibility )
{
	if ( visibility )
	{
		index = 0;
		while ( index < self.visuals.size )
		{
			self.visuals[ index ] show();
			if ( self.visuals[ index ].classname == "script_brushmodel" || self.visuals[ index ].classname == "script_model" )
			{
				self.visuals[ index ] thread makesolid();
			}
			index++;
		}
	}
	else index = 0;
	while ( index < self.visuals.size )
	{
		self.visuals[ index ] hide();
		if ( self.visuals[ index ].classname == "script_brushmodel" || self.visuals[ index ].classname == "script_model" )
		{
			self.visuals[ index ] notify( "changing_solidness" );
			self.visuals[ index ] notsolid();
		}
		index++;
	}
}

makesolid()
{
	self endon( "death" );
	self notify( "changing_solidness" );
	self endon( "changing_solidness" );
	while ( 1 )
	{
		i = 0;
		while ( i < level.players.size )
		{
			if ( level.players[ i ] istouching( self ) )
			{
				break;
			}
			else
			{
				i++;
			}
		}
		if ( i == level.players.size )
		{
			self solid();
			return;
		}
		else
		{
			wait 0,05;
		}
	}
}

setcarriervisible( relativeteam )
{
	self.carriervisible = relativeteam;
}

setcanuse( relativeteam )
{
	self.useteam = relativeteam;
}

set2dicon( relativeteam, shader )
{
	self.compassicons[ relativeteam ] = shader;
	updatecompassicons();
}

set3dicon( relativeteam, shader )
{
	self.worldicons[ relativeteam ] = shader;
	updateworldicons();
}

set3duseicon( relativeteam, shader )
{
	self.worlduseicons[ relativeteam ] = shader;
}

set3diswaypoint( relativeteam, waypoint )
{
	self.worldiswaypoint[ relativeteam ] = waypoint;
}

setcarryicon( shader )
{
	self.carryicon = shader;
}

setvisiblecarriermodel( visiblemodel )
{
	self.visiblecarriermodel = visiblemodel;
}

getvisiblecarriermodel()
{
	return self.visiblecarriermodel;
}

destroyobject( deletetrigger, forcehide )
{
	if ( !isDefined( forcehide ) )
	{
		forcehide = 1;
	}
	self disableobject( forcehide );
	_a2695 = self.visuals;
	_k2695 = getFirstArrayKey( _a2695 );
	while ( isDefined( _k2695 ) )
	{
		visual = _a2695[ _k2695 ];
		visual hide();
		visual delete();
		_k2695 = getNextArrayKey( _a2695, _k2695 );
	}
	self.trigger notify( "destroyed" );
	if ( isDefined( deletetrigger ) && deletetrigger )
	{
		self.trigger delete();
	}
	else
	{
		self.trigger triggeron();
	}
}

disableobject( forcehide )
{
	self notify( "disabled" );
	while ( self.type == "carryObject" || isDefined( forcehide ) && forcehide )
	{
		if ( isDefined( self.carrier ) )
		{
			self.carrier takeobject( self );
		}
		index = 0;
		while ( index < self.visuals.size )
		{
			self.visuals[ index ] hide();
			index++;
		}
	}
	self.trigger triggeroff();
	self setvisibleteam( "none" );
}

enableobject( forceshow )
{
	while ( self.type == "carryObject" || isDefined( forceshow ) && forceshow )
	{
		index = 0;
		while ( index < self.visuals.size )
		{
			self.visuals[ index ] show();
			index++;
		}
	}
	self.trigger triggeron();
	self setvisibleteam( "any" );
}

getrelativeteam( team )
{
	if ( self.ownerteam == "any" )
	{
		return "friendly";
	}
	if ( team == self.ownerteam )
	{
		return "friendly";
	}
	else
	{
		if ( team == getenemyteam( self.ownerteam ) )
		{
			return "enemy";
		}
		else
		{
			return "neutral";
		}
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

caninteractwith( player )
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
				else
				{
					if ( isDefined( self.decayprogress ) && self.decayprogress && self.curprogress > 0 )
					{
						return 1;
					}
					else
					{
						return 0;
					}
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
/#
			assert( 0, "invalid interactTeam" );
#/
			return 0;
	}
}

isteam( team )
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

isrelativeteam( relativeteam )
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

getenemyteam( team )
{
	if ( team == "neutral" )
	{
		return "none";
	}
	else
	{
		if ( team == "allies" )
		{
			return "axis";
		}
		else
		{
			return "allies";
		}
	}
}

getnextobjid()
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
/#
	assert( nextid < 32, "Ran out of objective IDs" );
#/
	return nextid;
}

releaseobjid( objid )
{
/#
	assert( objid < level.numgametypereservedobjectives );
#/
	i = 0;
	while ( i < level.releasedobjectives.size )
	{
		if ( objid == level.releasedobjectives[ i ] && objid == 31 )
		{
			return;
		}
/#
		assert( objid != level.releasedobjectives[ i ] );
#/
		i++;
	}
	level.releasedobjectives[ level.releasedobjectives.size ] = objid;
}

getlabel()
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

mustmaintainclaim( enabled )
{
	self.mustmaintainclaim = enabled;
}

cancontestclaim( enabled )
{
	self.cancontestclaim = enabled;
}

setflags( flags )
{
	objective_setgamemodeflags( self.objectiveid, flags );
}

getflags( flags )
{
	return objective_getgamemodeflags( self.objectiveid );
}
