#include maps/mp/zombies/_zm_audio;
#include maps/mp/zm_transit_lava;
#include maps/mp/zombies/_zm_weap_emp_bomb;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm;
#include maps/mp/zm_transit_ambush;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zm_transit_cling;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "zombie_bus" );
#using_animtree( "zombie_bus_props" );

bussetup()
{
	flag_init( "ladder_attached" );
	flag_init( "catcher_attached" );
	flag_init( "hatch_attached" );
	self.immediatespeed = 0;
	self.currentspeed = 0;
	self.targetspeed = 0;
	self.ismoving = 0;
	self.isstopping = 0;
	self.gas = 100;
	self.accel = 10;
	self.decel = 30;
	self.radius = 88;
	self.height = 240;
	self.frontdist = 340;
	self.backdist = 55;
	self.floor = 36;
	self.frontlocal = ( self.frontdist - ( self.radius / 2 ), 0, 0 );
	self.backlocal = ( ( self.backdist * -1 ) + ( self.radius / 2 ), 0, 0 );
	self.drivepath = 0;
	self.zone = "zone_pri";
	self.roadzone = self.zone;
	self.zombiesinside = 0;
	self.zombiesatwindow = 0;
	self.zombiesonroof = 0;
	self.numplayers = 0;
	self.numplayerson = 0;
	self.numplayersonroof = 0;
	self.numplayersinsidebus = 0;
	self.numplayersnear = 0;
	self.numaliveplayersridingbus = 0;
	self.numflattires = 0;
	self.doorsclosed = 1;
	self.doorsdisabledfortime = 0;
	self.stalled = 0;
	self.issafe = 1;
	self.waittimeatdestination = 0;
	self.gracetimeatdestination = 10;
	self.path_blocking = 0;
	self.chase_pos = self.origin;
	self.chase_pos_time = 0;
	self.istouchingignorewindowsvolume = 0;
	level.zm_mantle_over_40_move_speed_override = ::zm_mantle_over_40_move_speed_override;
	self setmovingplatformenabled( 1 );
	self.supportsanimscripted = 1;
	self setvehmaxspeed( 25 );
	self useanimtree( -1 );
	level.callbackactordamage = ::transit_actor_damage_override_wrapper;
	self maps/mp/zm_transit_automaton::main();
	maps/mp/zm_transit_cling::initializecling();
	self maps/mp/zm_transit_openings::main();
	self bus_upgrades();
	self thread busplowsetup();
	self buslightssetup();
	self busdoorssetup();
	self buspathblockersetup();
	self bussetupbounds();
	self bus_roof_watch();
	self bus_set_nodes();
	self bus_set_exit_triggers();
	self thread bus_audio_setup();
	level thread init_bus_door_anims();
	level thread init_bus_props_anims();
	self thread bususeanimtree();
	self thread bususedoor( 0 );
	self thread busidledoor();
	self thread play_lava_audio();
	self thread busthink();
	self thread busopeningscene();
	busschedule();
	self thread busschedulethink();
	self thread bus_bridge_speedcontrol();
	self.door_nodes_linked = 1;
	self thread bussetdoornodes( 0 );
}

bus_upgrades()
{
	self.upgrades = [];
	self.ladder_local_offset = ( 142, -50, 100 );
	self.upgrades[ "Plow" ] = spawnstruct();
	self.upgrades[ "Plow" ].installed = 0;
}

bus_debug()
{
	while ( 1 )
	{
		bus_forward = vectornormalize( anglesToForward( level.the_bus.angles ) );
		ret = level.the_bus.origin + vectorScale( bus_forward, -144 );
		groundpos = groundpos_ignore_water_new( ret + vectorScale( ( 0, 0, 1 ), 60 ) );
/#
		debugstar( groundpos, 1000, ( 0, 0, 1 ) );
#/
		wait 0,5;
	}
}

bus_set_nodes()
{
	self.front_door_inside = getnode( "front_door_inside_node", "targetname" );
	self.front_door = getnode( "front_door_node", "targetname" );
	self.back_door_inside1 = getnode( "back_door_inside_node1", "targetname" );
	self.back_door_inside2 = getnode( "back_door_inside_node2", "targetname" );
	self.back_door = getnode( "back_door_node", "targetname" );
	self.exit_back_l = getnode( "exit_back_l_node", "targetname" );
	self.exit_back_r = getnode( "exit_back_r_node", "targetname" );
}

bus_set_exit_triggers()
{
	spawnflags = 9;
	trigger_exit = [];
	trigger_exit[ trigger_exit.size ] = spawn( "trigger_radius", self.front_door_inside.origin, spawnflags, 32, 72 );
	trigger_exit[ trigger_exit.size ] = spawn( "trigger_radius", self.exit_back_l.origin, spawnflags, 32, 72 );
	trigger_exit[ trigger_exit.size ] = spawn( "trigger_radius", self.exit_back_r.origin, spawnflags, 32, 72 );
	tags = [];
	tags[ 0 ] = "window_right_front_jnt";
	tags[ 1 ] = "window_left_rear_jnt";
	tags[ 2 ] = "window_right_rear_jnt";
	i = 0;
	while ( i < trigger_exit.size )
	{
		trigger = trigger_exit[ i ];
		trigger enablelinkto();
		trigger linkto( self, "", self worldtolocalcoords( trigger.origin ), ( 0, 0, 1 ) );
		trigger setmovingplatformenabled( 1 );
		trigger setteamfortrigger( level.zombie_team );
		trigger.tag = tags[ i ];
		trigger.substate = i;
		self thread maps/mp/zm_transit_openings::busexitthink( trigger );
		i++;
	}
}

onplayerconnect()
{
	getent( "the_bus", "targetname" ) setclientfield( "the_bus_spawned", 1 );
}

zm_mantle_over_40_move_speed_override()
{
	traversealias = "barrier_walk";
	switch( self.zombie_move_speed )
	{
		case "chase_bus":
			traversealias = "barrier_sprint";
			break;
		default:
/#
			assertmsg( "Zombie move speed of '" + self.zombie_move_speed + "' is not supported for mantle_over_40." );
#/
	}
	return traversealias;
}

follow_path( node )
{
	self endon( "death" );
/#
	assert( isDefined( node ), "vehicle_path() called without a path" );
#/
	self notify( "newpath" );
	if ( isDefined( node ) )
	{
		self.attachedpath = node;
	}
	pathstart = self.attachedpath;
	self.currentnode = self.attachedpath;
	if ( !isDefined( pathstart ) )
	{
		return;
	}
	self attachpath( pathstart );
	self startpath();
	self endon( "newpath" );
	nextpoint = pathstart;
	while ( isDefined( nextpoint ) )
	{
		self waittill( "reached_node", nextpoint );
		self.currentnode = nextpoint;
		nextpoint notify( "trigger" );
		if ( isDefined( nextpoint.script_noteworthy ) )
		{
			self notify( nextpoint.script_noteworthy );
			self notify( "noteworthy" );
		}
		if ( isDefined( nextpoint.script_string ) )
		{
			if ( issubstr( nextpoint.script_string, "map_" ) )
			{
				level thread do_player_bus_location_vox( nextpoint.script_string );
				break;
			}
			else
			{
				level thread do_automoton_vox( nextpoint.script_string );
			}
		}
		waittillframeend;
	}
}

busopeningscene()
{
	startnode = getvehiclenode( "BUS_OPENING", "targetname" );
	self.currentnode = startnode;
	self thread follow_path( startnode );
	self.targetspeed = 0;
	flag_wait( "start_zombie_round_logic" );
	self busstartmoving( 12 );
	self busstartwait();
	self waittill( "opening_end_path" );
	self busstopmoving();
	startnode = getvehiclenode( "BUS_START", "targetname" );
	self.currentnode = startnode;
	self thread follow_path( startnode );
	while ( !flag( "OnPriDoorYar" ) && !flag( "OnPriDoorYar2" ) )
	{
		wait 0,5;
	}
	level.automaton notify( "start_head_think" );
	self notify( "noteworthy" );
}

busschedule()
{
	level.busschedule = busschedulecreate();
	level.busschedule busscheduleadd( "depot", 0, randomintrange( 40, 180 ), 19, 15 );
	level.busschedule busscheduleadd( "tunnel", 1, 10, 27, 5 );
	level.busschedule busscheduleadd( "diner", 0, randomintrange( 40, 180 ), 18, 20 );
	level.busschedule busscheduleadd( "forest", 1, 10, 18, 5 );
	level.busschedule busscheduleadd( "farm", 0, randomintrange( 40, 180 ), 26, 25 );
	level.busschedule busscheduleadd( "cornfields", 1, 10, 23, 10 );
	level.busschedule busscheduleadd( "power", 0, randomintrange( 40, 180 ), 19, 15 );
	level.busschedule busscheduleadd( "power2town", 1, 10, 26, 5 );
	level.busschedule busscheduleadd( "town", 0, randomintrange( 40, 180 ), 18, 20 );
	level.busschedule busscheduleadd( "bridge", 1, 10, 23, 10 );
/#
	_a369 = level.busschedule.destinations;
	index = getFirstArrayKey( _a369 );
	while ( isDefined( index ) )
	{
		stop = _a369[ index ];
		adddebugcommand( "devgui_cmd "Zombies:1/Bus:14/Teleport Bus:4/" + stop.name + ":" + index + "" "zombie_devgui teleport_bus " + stop.name + "\n" );
		index = getNextArrayKey( _a369, index );
#/
	}
}

busschedulethink()
{
	self endon( "death" );
	for ( ;; )
	{
		while ( 1 )
		{
			self waittill( "noteworthy", noteworthy, noteworthynode );
			zoneisempty = 1;
			shouldremovegas = 0;
			destinationindex = level.busschedule busschedulegetdestinationindex( noteworthy );
			while ( !isDefined( destinationindex ) || !isDefined( noteworthynode ) )
			{
/#
				if ( isDefined( noteworthy ) )
				{
					println( "^2Bus Debug: Not A Valid Destination (" + noteworthy + ")" );
					continue;
				}
				else
				{
					println( "^2Bus Debug: Not A Valid Destination" );
#/
				}
			}
			self.destinationindex = destinationindex;
			self.waittimeatdestination = level.busschedule busschedulegetmaxwaittimebeforeleaving( self.destinationindex );
			self.currentnode = noteworthynode;
			targetspeed = level.busschedule busschedulegetbusspeedleaving( self.destinationindex );
			_a416 = level.zones;
			_k416 = getFirstArrayKey( _a416 );
			while ( isDefined( _k416 ) )
			{
				zone = _a416[ _k416 ];
				if ( !isDefined( zone.volumes ) || zone.volumes.size == 0 )
				{
				}
				else
				{
					zonename = zone.volumes[ 0 ].targetname;
					if ( self maps/mp/zombies/_zm_zonemgr::entity_in_zone( zonename ) )
					{
/#
						println( "^2Bus Debug: Bus Is Touching Zone (" + zonename + ")" );
#/
						self.zone = zonename;
						zonestocheck = [];
						zonestocheck[ zonestocheck.size ] = zonename;
						switch( zonename )
						{
							case "zone_station_ext":
								zonestocheck[ zonestocheck.size ] = "zone_trans_1";
								zonestocheck[ zonestocheck.size ] = "zone_pri";
								zonestocheck[ zonestocheck.size ] = "zone_pri2";
								zonestocheck[ zonestocheck.size ] = "zone_amb_bridge";
								zonestocheck[ zonestocheck.size ] = "zone_trans_2b";
								break;
							case "zone_gas":
								zonestocheck[ zonestocheck.size ] = "zone_trans_2";
								zonestocheck[ zonestocheck.size ] = "zone_amb_tunnel";
								zonestocheck[ zonestocheck.size ] = "zone_gar";
								zonestocheck[ zonestocheck.size ] = "zone_trans_diner";
								zonestocheck[ zonestocheck.size ] = "zone_trans_diner2";
								zonestocheck[ zonestocheck.size ] = "zone_diner_roof";
								zonestocheck[ zonestocheck.size ] = "zone_din";
								zonestocheck[ zonestocheck.size ] = "zone_roadside_west";
								zonestocheck[ zonestocheck.size ] = "zone_roadside_east";
								zonestocheck[ zonestocheck.size ] = "zone_trans_3";
								break;
							case "zone_far":
								zonestocheck[ zonestocheck.size ] = "zone_amb_forest";
								zonestocheck[ zonestocheck.size ] = "zone_far_ext";
								zonestocheck[ zonestocheck.size ] = "zone_farm_house";
								zonestocheck[ zonestocheck.size ] = "zone_brn";
								zonestocheck[ zonestocheck.size ] = "zone_trans_5";
								zonestocheck[ zonestocheck.size ] = "zone_trans_6";
								break;
							case "zone_pow":
								zonestocheck[ zonestocheck.size ] = "zone_trans_6";
								zonestocheck[ zonestocheck.size ] = "zone_amb_cornfield";
								zonestocheck[ zonestocheck.size ] = "zone_trans_7";
								zonestocheck[ zonestocheck.size ] = "zone_pow_ext1";
								zonestocheck[ zonestocheck.size ] = "zone_prr";
								zonestocheck[ zonestocheck.size ] = "zone_pcr";
								zonestocheck[ zonestocheck.size ] = "zone_pow_warehouse";
								break;
							case "zone_town_north":
								zonestocheck[ zonestocheck.size ] = "zone_trans_8";
								zonestocheck[ zonestocheck.size ] = "zone_amb_power2town";
								zonestocheck[ zonestocheck.size ] = "zone_tbu";
								zonestocheck[ zonestocheck.size ] = "zone_town_church";
								zonestocheck[ zonestocheck.size ] = "zone_bar";
								zonestocheck[ zonestocheck.size ] = "zone_town_east";
								zonestocheck[ zonestocheck.size ] = "zone_tow";
								zonestocheck[ zonestocheck.size ] = "zone_ban";
								zonestocheck[ zonestocheck.size ] = "zone_ban_vault";
								zonestocheck[ zonestocheck.size ] = "zone_town_west";
								zonestocheck[ zonestocheck.size ] = "zone_town_west2";
								zonestocheck[ zonestocheck.size ] = "zone_town_barber";
								zonestocheck[ zonestocheck.size ] = "zone_town_south";
								zonestocheck[ zonestocheck.size ] = "zone_trans_9";
								break;
						}
						_a500 = zonestocheck;
						_k500 = getFirstArrayKey( _a500 );
						while ( isDefined( _k500 ) )
						{
							zone = _a500[ _k500 ];
							if ( isDefined( zoneisempty ) && !zoneisempty )
							{
							}
							else if ( maps/mp/zombies/_zm_zonemgr::player_in_zone( zone ) )
							{
/#
								println( "^2Bus Debug: Player(s) Detected Near Bus In The Zone (" + zone + ")" );
#/
								zoneisempty = 0;
							}
							_k500 = getNextArrayKey( _a500, _k500 );
						}
						if ( isDefined( zoneisempty ) && zoneisempty )
						{
/#
							println( "^2Bus Debug: No Player(s) Are In The Same Zone As Bus (" + zonename + ")" );
#/
							break;
						}
						else
						{
/#
							println( "^2Bus Debug: Player(s) Are In The Same Zone As Bus (" + zonename + ")" );
#/
						}
					}
				}
				_k416 = getNextArrayKey( _a416, _k416 );
			}
			if ( isDefined( shouldremovegas ) && shouldremovegas )
			{
				self busgasremove( level.busschedule busschedulegetbusgasusage( self.destinationindex ) );
			}
			while ( isDefined( zoneisempty ) && zoneisempty )
			{
/#
				println( "^2Bus Debug: Bus Won't Consider Stopping Since Zone Is Empty." );
#/
				self busstartmoving( targetspeed );
			}
			if ( isDefined( self.skip_next_destination ) && self.skip_next_destination )
			{
/#
				println( "^2Bus Debug: Bus Won't Consider Stopping Since It's Skipping Destination." );
#/
				self notify( "skipping_destination" );
				self busstartmoving( targetspeed );
			}
		}
		else /#
		println( "^2Bus Debug: Bus Will Consider Stopping, Someone Is Nearby." );
#/
		if ( level.busschedule busschedulegetisambushstop( self.destinationindex ) )
		{
/#
			println( "^2Bus Debug: Arrived At Ambush Point." );
#/
			if ( maps/mp/zm_transit_ambush::shouldstartambushround() && self.numplayersinsidebus != 0 )
			{
/#
				println( "^2Bus Debug: Ambush Triggering" );
#/
				self busstopmoving( 1 );
				level.nml_zone_name = "zone_amb_" + noteworthy;
				thread maps/mp/zm_transit_ambush::ambushstartround();
				thread automatonspeak( "inform", "out_of_gas" );
				flag_waitopen( "ambush_round" );
				shouldremovegas = 1;
				thread automatonspeak( "inform", "refueled_gas" );
				break;
			}
			else
			{
/#
				println( "^2Bus Debug: Over Ambush Point But No BreakDown Triggered." );
#/
			}
		}
	}
	else /#
	println( "^2Bus Debug: Arrived At Destination" );
#/
	self notify( "reached_destination" );
	shouldremovegas = 1;
	thread do_automaton_arrival_vox( noteworthy );
	if ( noteworthy != "diner" || noteworthy == "town" && noteworthy == "power" )
	{
		self busstopmoving( 1 );
		if ( noteworthy == "diner" )
		{
			self bussetdineropenings( 0 );
		}
		else if ( noteworthy == "power" )
		{
			self bussetpoweropenings( 0 );
		}
		else
		{
			if ( noteworthy == "town" )
			{
				self bussettownopenings( 0 );
			}
		}
	}
	else
	{
		self busstopmoving();
	}
	self thread busscheduledepartearly();
	waittimeatdestination = self.waittimeatdestination;
/#
	if ( getDvarInt( #"1CF9CD76" ) != 0 )
	{
		println( "^2Bus Debug: Using custom wait time of: " + getDvarInt( #"1CF9CD76" ) + " seconds." );
		waittimeatdestination = getDvarInt( #"1CF9CD76" );
	}
	if ( getDvarInt( "zombie_cheat" ) > 0 )
	{
		thread busshowleavinghud( waittimeatdestination );
#/
	}
	self waittill_any_timeout( waittimeatdestination, "depart_early" );
/#
	while ( getDvarInt( #"F7C16264" ) )
	{
		wait 0,1;
#/
	}
	self notify( "ready_to_depart" );
	self thread buslightsflash();
	self thread buslightsignal( "turn_signal_left" );
	thread automatonspeak( "inform", "leaving_warning" );
	self thread play_bus_audio( "grace" );
	wait self.gracetimeatdestination;
	thread automatonspeak( "inform", "leaving" );
	self.accel = 1;
	self busstartmoving( targetspeed );
	self notify( "departing" );
	self setclientfield( "bus_flashing_lights", 0 );
}
}

busscheduledepartearly()
{
	self endon( "ready_to_depart" );
	wait 15;
	triggerbuswait = 0;
	while ( 1 )
	{
		while ( isDefined( self.disabled_by_emp ) && self.disabled_by_emp )
		{
			wait 1;
		}
		players = get_players();
		nearbyplayers = 0;
		readytoleaveplayers = 0;
		_a717 = players;
		_k717 = getFirstArrayKey( _a717 );
		while ( isDefined( _k717 ) )
		{
			player = _a717[ _k717 ];
			if ( !is_player_valid( player ) )
			{
			}
			else
			{
				if ( distancesquared( self.origin, player.origin ) < 262144 )
				{
					nearbyplayers++;
					if ( player.isonbus )
					{
						readytoleaveplayers++;
					}
				}
			}
			_k717 = getNextArrayKey( _a717, _k717 );
		}
		if ( readytoleaveplayers != 0 && readytoleaveplayers == nearbyplayers )
		{
			if ( !triggerbuswait )
			{
				wait 5;
				triggerbuswait = 1;
			}
			else
			{
				self notify( "depart_early" );
/#
				if ( isDefined( level.bus_leave_hud ) )
				{
					level.bus_leave_hud.alpha = 0;
#/
				}
				return;
			}
		}
		else
		{
			if ( triggerbuswait )
			{
				triggerbuswait = 0;
			}
		}
		wait 1;
	}
}

busschedulecreate()
{
	schedule = spawnstruct();
	schedule.destinations = [];
	return schedule;
}

busscheduleadd( stopname, isambush, maxwaittimebeforeleaving, busspeedleaving, gasusage )
{
/#
	assert( isDefined( stopname ) );
#/
/#
	assert( isDefined( isambush ) );
#/
/#
	assert( isDefined( maxwaittimebeforeleaving ) );
#/
/#
	assert( isDefined( busspeedleaving ) );
#/
	destinationindex = self.destinations.size;
	self.destinations[ destinationindex ] = spawnstruct();
	self.destinations[ destinationindex ].name = stopname;
	self.destinations[ destinationindex ].isambush = isambush;
	self.destinations[ destinationindex ].maxwaittimebeforeleaving = maxwaittimebeforeleaving;
	self.destinations[ destinationindex ].busspeedleaving = busspeedleaving;
	self.destinations[ destinationindex ].gasusage = gasusage;
}

busschedulegetdestinationindex( stopname )
{
	_a800 = self.destinations;
	index = getFirstArrayKey( _a800 );
	while ( isDefined( index ) )
	{
		stop = _a800[ index ];
		if ( stop.name != stopname )
		{
		}
		else
		{
			return index;
		}
		index = getNextArrayKey( _a800, index );
	}
	return undefined;
}

busschedulegetstopname( destinationindex )
{
	return self.destinations[ destinationindex ].name;
}

busschedulegetisambushstop( destinationindex )
{
	return self.destinations[ destinationindex ].isambush;
}

busschedulegetmaxwaittimebeforeleaving( destinationindex )
{
	return self.destinations[ destinationindex ].maxwaittimebeforeleaving;
}

busschedulegetbusspeedleaving( destinationindex )
{
	return self.destinations[ destinationindex ].busspeedleaving;
}

busschedulegetbusgasusage( destinationindex )
{
	return self.destinations[ destinationindex ].gasusage;
}

transit_actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	if ( damage > self.health && isDefined( self.isonbus ) && self.isonbus )
	{
		ret = self maps/mp/zombies/_zm::actor_damage_override_wrapper( inflictor, attacker, self.health - 1, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
		self zombie_in_bus_death_animscript_callback( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
		return ret;
	}
	return self maps/mp/zombies/_zm::actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}

zombie_in_bus_death_animscript_callback( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	if ( isDefined( self ) && isDefined( self.opening ) )
	{
		self.opening.zombie = undefined;
	}
	if ( isDefined( self.exploding ) && self.exploding )
	{
		self notify( "killanimscript" );
		self maps/mp/zombies/_zm_spawner::reset_attack_spot();
		return 1;
	}
	if ( isDefined( self ) && isDefined( self.isonbus ) && !self.isonbus && isDefined( self.onbuswindow ) && !self.onbuswindow && isDefined( self.climbing_into_bus ) || self.climbing_into_bus && isDefined( self.climbing_onto_bus ) && self.climbing_onto_bus )
	{
		level maps/mp/zombies/_zm_spawner::zombie_death_points( self.origin, meansofdeath, shitloc, attacker, self );
		launchvector = undefined;
		if ( isDefined( self.onbuswindow ) && self.onbuswindow && isDefined( self.climbing_into_bus ) || !self.climbing_into_bus && isDefined( self.climbing_onto_bus ) && self.climbing_onto_bus )
		{
			fwd = anglesToForward( flat_angle( self.angles * -1 ) );
			my_velocity = vectorScale( fwd, 50 );
			launchvector = ( my_velocity[ 0 ], my_velocity[ 1 ], 20 );
		}
		self thread maps/mp/zombies/_zm_spawner::zombie_ragdoll_then_explode( launchvector, attacker );
		self notify( "killanimscript" );
		self maps/mp/zombies/_zm_spawner::reset_attack_spot();
		return 1;
	}
	return 0;
}

debug_busnear()
{
/#
	if ( getDvarInt( #"29B9C39F" ) > 0 )
	{
		zombie_front_dist = 1200;
		zombie_side_dist = self.radius + 50;
		zombie_inside_dist = 240;
		zombie_plow_dist = 340;
		forward_dir = anglesToForward( self.angles );
		forward_proj = vectorScale( forward_dir, zombie_front_dist );
		forward_pos = self.origin + forward_proj;
		backward_proj = vectorScale( forward_dir, zombie_inside_dist * -1 );
		backward_pos = self.origin + backward_proj;
		bus_front_dist = 225;
		bus_back_dist = 235;
		bus_width = 120;
		side_dir = anglesToForward( self.angles + vectorScale( ( 0, 0, 1 ), 90 ) );
		side_proj = vectorScale( side_dir, zombie_side_dist );
		inside_pos = self.origin + vectorScale( forward_dir, zombie_inside_dist );
		plow_pos = self.origin + vectorScale( forward_dir, zombie_plow_dist );
		line( backward_pos, forward_pos, ( 0, 0, 1 ), 1, 0, 2 );
		line( inside_pos - side_proj, inside_pos + side_proj, ( 0, 0, 1 ), 1, 0, 2 );
		line( plow_pos - side_proj, plow_pos + side_proj, ( 0, 0, 1 ), 1, 0, 2 );
#/
	}
}

debug_zombieonbus( zombie )
{
/#
	if ( getDvarInt( #"29B9C39F" ) > 0 )
	{
		zombie_front_dist = 1200;
		zombie_side_dist = self.radius + 50;
		zombie_inside_dist = 240;
		zombie_plow_dist = 340;
		forward_dir = anglesToForward( self.angles );
		forward_proj = vectorScale( forward_dir, zombie_front_dist );
		forward_pos = self.origin + forward_proj;
		backward_proj = vectorScale( forward_dir, zombie_inside_dist * -1 );
		backward_pos = self.origin + backward_proj;
		zombie_origin = zombie.origin;
		zombie_origin_proj = pointonsegmentnearesttopoint( backward_pos, forward_pos, zombie_origin );
		if ( isDefined( zombie.isonbus ) && zombie.isonbus )
		{
			line( zombie_origin_proj, zombie_origin, ( 0, 0, 1 ), 1, 0, 2 );
			return;
		}
		else
		{
			line( zombie_origin_proj, zombie_origin, ( 0, 0, 1 ), 1, 0, 2 );
#/
		}
	}
}

busupdatenearzombies()
{
	level endon( "end_game" );
	audiozomonbus_old = 0;
	audiozomonbus_new = 0;
	zombiesatwindow_old = 0;
	zombiesatwindow_new = 0;
	zombiesonroof_old = 0;
	zombiesonroof_new = 0;
	zombiesclimbing_new = 0;
	zombiesclimbing_old = 0;
	while ( 1 )
	{
		self.zombiesinside = 0;
		self.zombies_climbing = 0;
		self.zombies_chasing_bus = 0;
		self.zombiesatwindow = 0;
		self.zombiesonroof = 0;
		self.zombies_near_bus = 0;
/#
		self debug_busnear();
#/
		zombies = get_round_enemy_array();
		while ( isDefined( zombies ) )
		{
			i = 0;
			while ( i < zombies.size )
			{
				if ( !isDefined( zombies[ i ] ) )
				{
					i++;
					continue;
				}
				else zombie = zombies[ i ];
				if ( isDefined( zombie.completed_emerging_into_playable_area ) && !zombie.completed_emerging_into_playable_area )
				{
					i++;
					continue;
				}
				else
				{
					if ( isDefined( zombie.isscreecher ) || zombie.isscreecher && isDefined( zombie.is_avogadro ) && zombie.is_avogadro )
					{
						i++;
						continue;
					}
					else
					{
						if ( !isDefined( zombie.isonbus ) )
						{
							zombie.isonbus = 0;
						}
						zombie.ground_ent = zombie getgroundent();
						if ( isDefined( zombie.ground_ent ) )
						{
							if ( isDefined( zombie.ground_ent.isonbus ) && zombie.ground_ent.isonbus )
							{
								zombie.isonbus = 1;
								break;
							}
							else
							{
								groundname = zombie.ground_ent.targetname;
								if ( isDefined( groundname ) )
								{
									if ( level.the_bus.targetname != groundname || groundname == "bus_path_blocker" && groundname == "hatch_clip" )
									{
										zombie.dont_throw_gib = 1;
										zombie.isonbus = 1;
										if ( isDefined( zombie.entering_bus ) && zombie.entering_bus )
										{
											zombie.entering_bus = undefined;
										}
									}
									else
									{
										zombie.isonbus = 0;
									}
									break;
								}
								else
								{
									zombie.isonbus = 0;
								}
							}
						}
						if ( isDefined( zombie.entering_bus ) && zombie.entering_bus )
						{
							zombie.isonbus = 1;
						}
						zombie.isonbusroof = zombie _entityisonroof();
						if ( isDefined( zombie.isonbusroof ) && zombie.isonbusroof )
						{
							zombie thread play_zmbonbusroof_sound();
						}
						if ( isDefined( zombie.isonbus ) && zombie.isonbus )
						{
							if ( isDefined( zombie.entering_bus ) && !zombie.entering_bus )
							{
								if ( !isDefined( zombie.onbusfunc ) )
								{
									zombie.onbusfunc = ::maps/mp/zm_transit_openings::zombiemoveonbus;
									zombie thread [[ zombie.onbusfunc ]]();
								}
							}
						}
						else
						{
							if ( isDefined( zombie.onbusfunc ) )
							{
								zombie.onbusfunc = undefined;
								zombie notify( "endOnBus" );
								zombie animmode( "normal" );
								zombie orientmode( "face enemy" );
								zombie.forcemovementscriptstate = 0;
								zombie thread maps/mp/zombies/_zm_ai_basic::find_flesh();
							}
						}
						if ( isDefined( zombie.isonbus ) && zombie.isonbus )
						{
							self.zombiesinside++;
						}
						else
						{
							if ( isDefined( zombie.onbuswindow ) && zombie.onbuswindow )
							{
								self.zombiesatwindow++;
								break;
							}
							else
							{
								if ( isDefined( zombie.isonbusroof ) && zombie.isonbusroof )
								{
									self.zombiesonroof++;
									break;
								}
								else
								{
									if ( isDefined( zombie.climbing_into_bus ) && zombie.climbing_into_bus )
									{
										self.zombies_climbing++;
										break;
									}
									else
									{
										if ( distancesquared( zombie.origin, self.origin ) < 122500 )
										{
											if ( zombie.zombie_move_speed == "chase_bus" )
											{
												self.zombies_chasing_bus++;
											}
											self.zombies_near_bus++;
										}
									}
								}
							}
						}
						if ( self.zombies_near_bus && !self.zombiesinside && !self.zombiesatwindow && !self.zombies_climbing & !self.zombiesonroof )
						{
							level.bus_driver_focused = 1;
						}
						else
						{
							level.bus_driver_focused = 0;
						}
						if ( !self.zombiesinside && !self.zombiesatwindow && !self.zombies_climbing || self.zombiesonroof && self.zombies_near_bus )
						{
							level.bus_zombie_danger = 1;
						}
						else
						{
							level.bus_zombie_danger = 0;
						}
						if ( self.ismoving && self getspeedmph() > 5 )
						{
							if ( isDefined( self.plowtrigger ) )
							{
								if ( zombie istouching( self.plowtrigger ) )
								{
/#
									println( "^2Transit Debug: Plow killing zombie." );
#/
									self thread busplowkillzombie( zombie );
									i++;
									continue;
								}
								else }
							else if ( isDefined( self.bussmashtrigger ) )
							{
								if ( !isDefined( zombie.opening ) && isDefined( zombie.isonbus ) && !zombie.isonbus && zombie istouching( self.bussmashtrigger ) )
								{
/#
									println( "^2Transit Debug: Plow pushing zombie." );
#/
									self thread buspushzombie( zombie, self.bussmashtrigger );
									i++;
									continue;
								}
							}
						}
						else
						{
							self update_zombie_move_speed( zombie );
/#
							self debug_zombieonbus( zombie );
#/
							if ( ( i % 4 ) == 3 )
							{
								wait 0,05;
							}
						}
					}
				}
				i++;
			}
		}
		audiozomonbus_new = self.zombiesinside;
		zombiesatwindow_new = self.zombiesatwindow;
		zombiesonroof_new = self.zombiesonroof;
		zombiesclimbing_new = self.zombies_climbing;
		self zomonbusvox( audiozomonbus_old, audiozomonbus_new );
		self zomatwindowvox( zombiesatwindow_old, zombiesatwindow_new );
		self zomonroofvox( zombiesonroof_old, zombiesonroof_new );
		self zomclimbingvox( zombiesclimbing_old, zombiesclimbing_new );
		self zomchasingvox();
		audiozomonbus_old = audiozomonbus_new;
		zombiesatwindow_old = zombiesatwindow_new;
		zombiesonroof_old = zombiesonroof_new;
		zombiesclimbing_old = zombiesclimbing_new;
		wait 0,05;
	}
}

entity_is_on_bus( use_cache )
{
	if ( isDefined( self.isonbus ) && isDefined( use_cache ) && use_cache )
	{
		return self.isonbus;
	}
	self.isonbus = 0;
	self.ground_ent = self getgroundent();
	if ( isDefined( self.ground_ent ) )
	{
		groundname = self.ground_ent.targetname;
		if ( isDefined( groundname ) )
		{
			if ( level.the_bus.targetname != groundname || groundname == "bus_path_blocker" && groundname == "hatch_clip" )
			{
				self.isonbus = 1;
			}
		}
	}
	return self.isonbus;
}

busupdatechasers()
{
	while ( 1 )
	{
		while ( isDefined( self.ismoving ) && self.ismoving && isDefined( self.exceed_chase_speed ) && self.exceed_chase_speed )
		{
			max_speed = 0;
			zombies = getaiarray( level.zombie_team );
			slow_zombies = [];
			_a1238 = zombies;
			_k1238 = getFirstArrayKey( _a1238 );
			while ( isDefined( _k1238 ) )
			{
				zombie = _a1238[ _k1238 ];
				if ( isDefined( zombie.zombie_move_speed ) && zombie.zombie_move_speed == "chase_bus" && isDefined( zombie.close_to_bus ) && !zombie.close_to_bus && !isDefined( zombie.opening ) )
				{
					substate = zombie getanimsubstatefromasd();
					if ( substate == 6 )
					{
						max_speed++;
						break;
					}
					else
					{
						slow_zombies[ slow_zombies.size ] = zombie;
					}
				}
				_k1238 = getNextArrayKey( _a1238, _k1238 );
			}
			while ( max_speed < 3 )
			{
				speed_up = 3 - max_speed;
				if ( speed_up > slow_zombies.size )
				{
					speed_up = slow_zombies.size;
				}
				_a1263 = slow_zombies;
				_k1263 = getFirstArrayKey( _a1263 );
				while ( isDefined( _k1263 ) )
				{
					zombie = _a1263[ _k1263 ];
					zombie setanimstatefromasd( "zm_move_chase_bus", 6 );
					speed_up--;

					if ( speed_up <= 0 )
					{
						break;
					}
					else
					{
						_k1263 = getNextArrayKey( _a1263, _k1263 );
					}
				}
			}
		}
		wait 0,25;
	}
}

play_zmbonbusroof_sound()
{
	if ( isDefined( self.sndbusroofplayed ) && !self.sndbusroofplayed )
	{
		self playsound( "fly_step_zombie_bus" );
		self.sndbusroofplayed = 1;
	}
}

object_is_on_bus()
{
	ground_ent = self getgroundent();
	depth = 0;
	while ( isDefined( ground_ent ) && depth < 2 )
	{
		groundname = ground_ent.targetname;
		if ( isDefined( groundname ) )
		{
			if ( level.the_bus.targetname != groundname || groundname == "bus_path_blocker" && groundname == "hatch_clip" )
			{
				return 1;
			}
		}
		new_ground_ent = ground_ent getgroundent();
		if ( !isDefined( new_ground_ent ) || new_ground_ent == ground_ent )
		{
		}
		else
		{
			ground_ent = new_ground_ent;
			depth++;
		}
	}
	return 0;
}

busupdatenearequipment()
{
	equipment = maps/mp/zombies/_zm_equipment::get_destructible_equipment_list();
	i = 0;
	while ( i < equipment.size )
	{
		item = equipment[ i ];
		if ( !isDefined( item ) )
		{
			i++;
			continue;
		}
		else if ( isDefined( item.isonbus ) && item.isonbus )
		{
			i++;
			continue;
		}
		else
		{
			if ( isDefined( self.bussmashtrigger ) && item istouching( self.bussmashtrigger ) )
			{
				item maps/mp/zombies/_zm_equipment::item_damage( 10000 );
/#
				println( "^2Bus hit an item." );
#/
			}
		}
		i++;
	}
}

update_zombie_move_speed( zombie )
{
	if ( isDefined( zombie.completed_emerging_into_playable_area ) && !zombie.completed_emerging_into_playable_area )
	{
		return;
	}
	if ( !isDefined( zombie.normal_move_speed ) )
	{
		zombie.normal_move_speed = 1;
	}
	if ( !zombie.has_legs )
	{
		return;
	}
	if ( isDefined( zombie.favoriteenemy ) )
	{
		if ( isDefined( zombie.favoriteenemy.isonbus ) )
		{
			enemyonbus = zombie.favoriteenemy.isonbus;
		}
	}
	if ( isDefined( zombie.isonbus ) && zombie.isonbus )
	{
		if ( zombie.normal_move_speed )
		{
			zombie.normal_move_speed = 0;
		}
		walk_state = zombie.zombie_move_speed;
		if ( self.ismoving && isDefined( self.disabled_by_emp ) && !self.disabled_by_emp )
		{
			if ( zombie.zombie_move_speed != "bus_walk" )
			{
				walk_state = "bus_walk";
			}
		}
		else
		{
			if ( zombie.zombie_move_speed != "walk" )
			{
				walk_state = "walk";
			}
		}
		if ( zombie.zombie_move_speed != walk_state )
		{
			zombie set_zombie_run_cycle( walk_state );
		}
		return;
	}
	else
	{
		if ( enemyonbus && !isDefined( zombie.opening ) )
		{
			if ( self should_chase_bus( zombie ) )
			{
				if ( zombie.zombie_move_speed != "chase_bus" )
				{
					zombie.normal_move_speed = 0;
					zombie set_zombie_run_cycle( "chase_bus" );
					zombie.crawl_anim_override = ::normal_move_speed;
				}
				return;
			}
			else
			{
				if ( zombie.zombie_move_speed == "chase_bus" )
				{
					dist_sq = distance2dsquared( self.origin, level.the_bus.origin );
					if ( dist_sq > 90000 )
					{
						return;
					}
				}
			}
		}
	}
	if ( !zombie.normal_move_speed )
	{
		zombie normal_move_speed();
	}
}

should_chase_bus( zombie )
{
	if ( !self.ismoving )
	{
		return 0;
	}
	if ( isDefined( self.exceed_chase_speed ) && !self.exceed_chase_speed )
	{
		return 0;
	}
	if ( isDefined( self.disabled_by_emp ) && self.disabled_by_emp )
	{
		return 0;
	}
	if ( isDefined( zombie.is_inert ) && zombie.is_inert )
	{
		return 0;
	}
	if ( isDefined( zombie.is_traversing ) && zombie.is_traversing )
	{
		return 0;
	}
	if ( !flag( "OnPriDoorYar2" ) )
	{
		if ( !flag( "OnPriDoorYar" ) || !flag( "OnPriDoorYar3" ) )
		{
			if ( zombie maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_pri" ) )
			{
				return 0;
			}
		}
	}
	return 1;
}

normal_move_speed()
{
	self.normal_move_speed = 1;
	self set_zombie_run_cycle();
}

plowhudfade( text )
{
	level endon( "plowHudUpdate" );
	fadein = 0,1;
	fadeout = 3;
	level.hudbuscount fadeovertime( fadein );
	level.hudbuscount.alpha = 1;
	level.hudbuscount settext( text );
	wait fadein;
	level.hudbuscount fadeovertime( 3 );
	level.hudbuscount.alpha = 0;
}

busupdatespeed()
{
	targetspeed = self.targetspeed;
	if ( is_false( self.ismoving ) )
	{
		targetspeed = 0;
	}
	if ( isDefined( self.forcestop ) && self.forcestop )
	{
		targetspeed = 0;
	}
	if ( isDefined( self.stalled ) && self.stalled )
	{
		targetspeed = 0;
	}
	if ( isDefined( self.disabled_by_emp ) && self.disabled_by_emp )
	{
		targetspeed = 0;
	}
	if ( targetspeed < 0 )
	{
		targetspeed = 0;
	}
	if ( self.currentspeed != targetspeed )
	{
		self.currentspeed = targetspeed;
		if ( isDefined( self.immediatespeed ) && self.immediatespeed )
		{
			self setspeedimmediate( targetspeed, self.accel, self.decel );
			self.immediatespeed = undefined;
		}
		else
		{
			if ( targetspeed == 0 )
			{
				self setspeed( 0, 30, 30 );
			}
			else
			{
				self setspeed( targetspeed, self.accel, self.decel );
			}
		}
	}
/#
	if ( getDvarInt( #"6152C9EA" ) > 0 )
	{
		msgorigin = self localtoworldcoords( vectorScale( ( 0, 0, 1 ), 100 ) );
		msgtext = "speed " + self getspeedmph();
		print3d( msgorigin, msgtext, ( 0, 0, 1 ), 1, 0,5, 2 );
#/
	}
}

bus_power_off()
{
	self endon( "power_on" );
	self.pre_disabled_by_emp = 1;
	self thread play_bus_audio( "emp" );
	self buslightsdisableall();
	self notify( "pre_power_off" );
	while ( isDefined( self.ismoving ) && self.ismoving )
	{
		while ( isDefined( self.istouchingignorewindowsvolume ) && self.istouchingignorewindowsvolume )
		{
			wait 0,1;
		}
	}
	self.disabled_by_emp = 1;
	self thread buspathblockerenable();
	self notify( "power_off" );
}

bus_power_on()
{
	self buslightsenableall();
	wait 2;
	self.pre_disabled_by_emp = 0;
	self.disabled_by_emp = 0;
	self thread buspathblockerdisable();
	self notify( "power_on" );
	wait 0,25;
	self thread play_bus_audio( "leaving" );
	wait 3;
	level.automaton automatonspeak( "inform", "doors_open" );
}

bus_disabled_by_emp( disable_time )
{
	self bus_power_off();
	wait ( disable_time - 2 );
	self bus_power_on();
}

busispointinside( entitypos )
{
	entityposinbus = pointonsegmentnearesttopoint( self.frontworld, self.backworld, entitypos );
	entityposzdelta = entitypos[ 2 ] - entityposinbus[ 2 ];
	entityposdist2 = distance2dsquared( entitypos, entityposinbus );
	if ( entityposdist2 > ( self.radius * self.radius ) )
	{
		return 0;
	}
	return 1;
}

busupdateignorewindows()
{
	if ( self getspeed() <= 0 )
	{
		return;
	}
	if ( !isDefined( level.bus_ignore_windows ) )
	{
		level.bus_ignore_windows = getentarray( "bus_ignore_windows", "targetname" );
	}
	ignorewindowsvolume = undefined;
	istouchingignorewindowsvolume = 0;
	while ( isDefined( level.bus_ignore_windows ) && level.bus_ignore_windows.size > 0 )
	{
		_a1639 = level.bus_ignore_windows;
		_k1639 = getFirstArrayKey( _a1639 );
		while ( isDefined( _k1639 ) )
		{
			volume = _a1639[ _k1639 ];
			if ( isDefined( istouchingignorewindowsvolume ) && istouchingignorewindowsvolume )
			{
			}
			else
			{
				if ( self istouching( volume ) )
				{
					ignorewindowsvolume = volume;
					istouchingignorewindowsvolume = 1;
				}
			}
			_k1639 = getNextArrayKey( _a1639, _k1639 );
		}
	}
	self.ignorewindowsvolume = ignorewindowsvolume;
	self.istouchingignorewindowsvolume = istouchingignorewindowsvolume;
}

zombie_surf( zombie )
{
	if ( !isDefined( self.zombie_surf_count ) )
	{
		self.zombie_surf_count = 0;
	}
	damage = int( self.maxhealth / 10 );
	if ( isDefined( zombie.isonbusroof ) && zombie.isonbusroof && ( self.origin[ 2 ] - zombie.origin[ 2 ] ) >= 35 && isDefined( zombie.climbing_onto_bus ) && !zombie.climbing_onto_bus && isDefined( self.hatch_jump ) && !self.hatch_jump )
	{
		damage = int( self.maxhealth / 8 );
		self.zombie_surf_count++;
		if ( isDefined( level.zombie_surfing_kills ) && level.zombie_surfing_kills && self.zombie_surf_count > level.zombie_surfing_kill_count )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "cheat_total", 0 );
			self playlocalsound( level.zmb_laugh_alias );
			self dodamage( self.maxhealth + 1, zombie.origin );
		}
	}
	self applyknockback( damage, ( 0, 0, 1 ) );
}

busupdateplayers()
{
	level endon( "end_game" );
	while ( 1 )
	{
		self.numplayers = 0;
		self.numplayerson = 0;
		self.numplayersonroof = 0;
		self.numplayersinsidebus = 0;
		self.numplayersnear = 0;
		self.numaliveplayersridingbus = 0;
		self.frontworld = self localtoworldcoords( self.frontlocal );
		self.backworld = self localtoworldcoords( self.backlocal );
		self.bus_riders_alive = [];
/#
		if ( getDvarInt( #"10AC3C99" ) > 0 )
		{
			line( self.frontworld + ( 0, 0, self.floor ), self.backworld + ( 0, 0, self.floor ), ( 0, 0, 1 ), 1, 0, 4 );
			line( self.frontworld + ( 0, 0, self.floor ), self.frontworld + ( 0, 0, self.height ), ( 0, 0, 1 ), 1, 0, 4 );
			circle( self.backworld + ( 0, 0, self.floor ), self.radius, ( 0, 0, 1 ), 0, 1, 4 );
			circle( self.frontworld + ( 0, 0, self.floor ), self.radius, ( 0, 0, 1 ), 0, 1, 4 );
#/
		}
		players = get_players();
		_a1717 = players;
		_k1717 = getFirstArrayKey( _a1717 );
		while ( isDefined( _k1717 ) )
		{
			player = _a1717[ _k1717 ];
			if ( !isalive( player ) )
			{
			}
			else
			{
				self.numplayers++;
				if ( distance2d( player.origin, self.origin ) < 1700 )
				{
					self.numplayersnear++;
				}
				playerisinbus = 0;
				mover = player getmoverent();
				if ( isDefined( mover ) )
				{
					if ( isDefined( mover.targetname ) )
					{
						if ( mover.targetname != "the_bus" && mover.targetname != "bus_path_blocker" || mover.targetname == "hatch_clip" && mover.targetname == "ladder_mantle" )
						{
							playerisinbus = 1;
						}
					}
					if ( isDefined( mover.equipname ) )
					{
						if ( mover.equipname == "riotshield_zm" )
						{
							if ( isDefined( mover.isonbus ) && mover.isonbus )
							{
								playerisinbus = 1;
							}
						}
					}
					if ( isDefined( mover.is_zombie ) && mover.is_zombie && isDefined( mover.isonbus ) && mover.isonbus )
					{
						playerisinbus = 1;
					}
				}
				if ( playerisinbus )
				{
					self.numplayerson++;
					if ( is_player_valid( player ) )
					{
						self.numaliveplayersridingbus++;
						self.bus_riders_alive[ self.bus_riders_alive.size ] = player;
					}
				}
				ground_ent = player getgroundent();
				if ( player isonladder() )
				{
					ground_ent = mover;
				}
				if ( isDefined( ground_ent ) )
				{
					if ( isDefined( ground_ent.is_zombie ) && ground_ent.is_zombie )
					{
						player thread zombie_surf( ground_ent );
						break;
					}
					else
					{
						if ( playerisinbus && isDefined( player.isonbus ) && !player.isonbus )
						{
							bbprint( "zombie_events", "category %s type %s round %d playername %s", "BUS", "player_enter", level.round_number, player.name );
							player thread bus_audio_interior_loop( self );
							player clientnotify( "OBS" );
							player setclientplayerpushamount( 0 );
							player allowsprint( 0 );
							player allowprone( 0 );
							player._allow_sprint = 0;
							player._allow_prone = 0;
							isdivingtoprone = player getstance() == "prone";
							if ( isdivingtoprone )
							{
								player thread playerdelayturnoffdivetoprone();
								break;
							}
							if ( randomint( 100 ) > 80 && level.automaton.greeting_timer == 0 )
							{
								thread automatonspeak( "convo", "player_enter" );
								level.automaton thread greeting_timer();
							}
						}
						if ( !playerisinbus && isDefined( player.isonbus ) && player.isonbus )
						{
							bbprint( "zombie_events", "category %s type %s round %d playername %s", "BUS", "player_exit", level.round_number, player.name );
							self.buyable_weapon setinvisibletoplayer( player );
							player setclientplayerpushamount( 1 );
							player allowsprint( 1 );
							player allowprone( 1 );
							player._allow_sprint = undefined;
							player._allow_prone = undefined;
							player notify( "left bus" );
							player clientnotify( "LBS" );
							if ( randomint( 100 ) > 80 && level.automaton.greeting_timer == 0 )
							{
								thread automatonspeak( "convo", "player_leave" );
								level.automaton thread greeting_timer();
							}
						}
						player.isonbus = playerisinbus;
						player.isonbusroof = player _entityisonroof();
					}
				}
				if ( isDefined( player.isonbusroof ) && player.isonbusroof )
				{
					self.buyable_weapon setinvisibletoplayer( player );
					self.numplayersonroof++;
				}
				else
				{
					if ( isDefined( player.isonbus ) && player.isonbus )
					{
						self.buyable_weapon setvisibletoplayer( player );
						self.numplayersinsidebus++;
					}
				}
				wait 0,05;
			}
			_k1717 = getNextArrayKey( _a1717, _k1717 );
		}
		wait 0,05;
	}
}

_entityisonroof()
{
	if ( !isDefined( level.roof_trig ) )
	{
		level.roof_trig = getent( "bus_roof_watch", "targetname" );
	}
	if ( !self.isonbus )
	{
		return 0;
	}
	if ( self istouching( level.roof_trig ) )
	{
		return 1;
	}
	return 0;
}

greeting_timer()
{
	if ( level.automaton.greeting_timer > 0 )
	{
		return;
	}
	level.automaton.greeting_timer = 1;
	wait 20;
	level.automaton.greeting_timer = 0;
}

_updateplayersinsafearea()
{
	players = get_players();
	if ( !isDefined( level._safeareacachevalid ) || !level._safeareacachevalid )
	{
		level.playable_areas = getentarray( "player_volume", "script_noteworthy" );
		level.nogas_areas = getentarray( "no_gas", "targetname" );
		level.ambush_areas = getentarray( "ambush_volume", "script_noteworthy" );
		level._safeareacachevaild = 1;
	}
	p = 0;
	while ( p < players.size )
	{
		players[ p ].insafearea = _isplayerinsafearea( players[ p ] );
		players[ p ] _playercheckpoison();
		p++;
	}
}

_isplayerinsafearea( player )
{
	if ( isDefined( player.isonbus ) && player.isonbus )
	{
		return level.the_bus.issafe;
	}
	if ( player _playertouchingsafearea( level.playable_areas ) )
	{
		return 1;
	}
	if ( player _playertouchingsafearea( level.nogas_areas ) )
	{
		return 1;
	}
	if ( flag( "ambush_safe_area_active" ) )
	{
		return player _playertouchingsafearea( level.ambush_areas );
	}
	return 0;
}

_playertouchingsafearea( areas )
{
	i = 0;
	while ( i < areas.size )
	{
		touching = self istouching( areas[ i ] );
		if ( touching )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

_playercheckpoison()
{
	if ( !isalive( self ) || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return;
	}
	if ( isDefined( self.poisoned ) && self.poisoned )
	{
		return;
	}
	canbepoisoned = self playercanbepoisoned();
	if ( !canbepoisoned )
	{
		return;
	}
	if ( !isDefined( self.insafearea ) || self.insafearea )
	{
		return;
	}
	self thread _playerpoison();
}

playercanbepoisoned()
{
	god_mode = isgodmode( self );
	free_move = self isinmovemode( "ufo", "noclip" );
	zombie_cheat_num = getDvarInt( "zombie_cheat" );
	if ( zombie_cheat_num != 1 && zombie_cheat_num != 2 )
	{
		is_invunerable = zombie_cheat_num == 3;
	}
	if ( !god_mode && !isDefined( free_move ) )
	{
		return !is_invunerable;
	}
}

_playerpoison()
{
	self.poisoned = 1;
	self startpoisoning();
	self playsound( "evt_gas_cough" );
	wait 1;
	damage = 15;
	while ( 1 )
	{
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || !isalive( self ) )
		{
			self stoppoisoning();
			self.poisoned = 0;
			return;
		}
		canbepoisoned = self playercanbepoisoned();
		if ( self.insafearea || !canbepoisoned )
		{
			self stoppoisoning();
			self.poisoned = 0;
			return;
		}
		if ( randomfloat( 100 ) < 60 )
		{
			break;
		}
		self dodamage( damage, self.origin );
		damage += 1;
		wait 1;
	}
}

_updateplayersinhubs()
{
	players = get_players();
	hubs = getentarray( "bus_hub", "script_noteworthy" );
	h = 0;
	while ( h < hubs.size )
	{
		hubs[ h ].active = 0;
		p = 0;
		while ( p < players.size && !hubs[ h ].active )
		{
			hubs[ h ].active = players[ p ] istouching( hubs[ h ] );
			p++;
		}
		h++;
	}
}

playerdelayturnoffdivetoprone()
{
	self endon( "left bus" );
	wait 1,5;
}

busgivepowerup( location )
{
	currentzone = level.zones[ self.zone ];
	if ( isDefined( currentzone.target2 ) )
	{
		spawndestent = getent( currentzone.target2, "targetname" );
		if ( isDefined( spawndestent ) )
		{
			level thread maps/mp/zombies/_zm_powerups::specific_powerup_drop( "full_ammo", spawndestent.origin );
			level.powerup_drop_count = 0;
		}
	}
}

buslightssetup()
{
	self setclientfield( "bus_head_lights", 1 );
}

buslightsflash()
{
	self endon( "departing" );
	while ( 1 )
	{
		self buslightwaitenabled();
		self setclientfield( "bus_flashing_lights", 1 );
		wait 2,5;
		self setclientfield( "bus_flashing_lights", 0 );
		wait 2,5;
	}
}

buslightsbrake()
{
	self buslightwaitenabled();
	self setclientfield( "bus_brake_lights", 1 );
	wait 5;
	while ( is_false( self.ismoving ) )
	{
		self buslightwaitenabled();
		self setclientfield( "bus_brake_lights", 1 );
		wait 0,8;
		self setclientfield( "bus_brake_lights", 0 );
		wait 0,8;
	}
	self setclientfield( "bus_brake_lights", 0 );
}

buslightwaitenabled()
{
	while ( isDefined( self.bus_lights_disabled ) && self.bus_lights_disabled )
	{
		wait 0,2;
	}
}

buslightdisable( light_name )
{
	self.oldlights[ light_name ] = self getclientfield( light_name );
	self setclientfield( light_name, 0 );
}

buslightenable( light_name )
{
	if ( self.oldlights[ light_name ] )
	{
		self setclientfield( light_name, 1 );
	}
}

buslightsignal( turn_signal_side )
{
	self endon( "pre_power_off" );
	self endon( "power_off" );
	blink = 4;
	x = 0;
	while ( x < blink )
	{
		wait 1;
		self setclientfield( "bus_" + turn_signal_side, 1 );
		wait 1;
		self setclientfield( "bus_" + turn_signal_side, 0 );
		x++;
	}
}

buslightsdisableall()
{
	if ( !isDefined( self.oldlights ) )
	{
		self.oldlights = [];
	}
	self buslightdisable( "bus_flashing_lights" );
	self buslightdisable( "bus_head_lights" );
	self buslightdisable( "bus_brake_lights" );
	self buslightdisable( "bus_turn_signal_left" );
	self buslightdisable( "bus_turn_signal_right" );
	self.bus_lights_disabled = 1;
}

buslightsenableall()
{
	self.bus_lights_disabled = 0;
	self buslightenable( "bus_flashing_lights" );
	self buslightenable( "bus_head_lights" );
	self buslightenable( "bus_brake_lights" );
	self buslightenable( "bus_turn_signal_left" );
	self buslightenable( "bus_turn_signal_right" );
}

busdoorssetup()
{
	self.doorblockers = [];
	self.doorblockers = getentarray( "bus_door_blocker", "targetname" );
	doorstrigger = getentarray( "bus_door_trigger", "targetname" );
	i = 0;
	while ( i < self.doorblockers.size )
	{
		self.doorblockers[ i ].offset = self worldtolocalcoords( self.doorblockers[ i ].origin );
		self.doorblockers[ i ] linkto( self, "", self.doorblockers[ i ].offset, ( 0, 0, 1 ) );
		self.doorblockers[ i ] setmovingplatformenabled( 1 );
		i++;
	}
	i = 0;
	while ( i < doorstrigger.size )
	{
		doorstrigger[ i ] enablelinkto();
		doorstrigger[ i ] linkto( self, "", self worldtolocalcoords( doorstrigger[ i ].origin ), ( 0, 0, 1 ) );
		doorstrigger[ i ] setcursorhint( "HINT_NOICON" );
		doorstrigger[ i ] sethintstring( &"ZOMBIE_TRANSIT_OPEN_BUS_DOOR" );
		doorstrigger[ i ] setmovingplatformenabled( 1 );
		doorstrigger[ i ] sethintlowpriority( 1 );
		self thread busdoorthink( doorstrigger[ i ] );
		i++;
	}
	self maps/mp/zm_transit_openings::busopeningsetenabled( "door", 0 );
}

busdoorsopen()
{
	if ( !self.doorsclosed || self.doorsdisabledfortime )
	{
		return;
	}
	self.doorsclosed = 0;
	self thread bussetdoornodes( 1 );
	doorstrigger = getentarray( "bus_door_trigger", "targetname" );
	i = 0;
	while ( i < self.doorblockers.size )
	{
		self.doorblockers[ i ] notsolid();
		self.doorblockers[ i ] playsound( "zmb_bus_door_open" );
		i++;
	}
	i = 0;
	while ( i < doorstrigger.size )
	{
		doorstrigger[ i ] sethintstring( &"ZOMBIE_TRANSIT_CLOSE_BUS_DOOR" );
		i++;
	}
	self bususeanimtree();
	self bususedoor( 1 );
	self maps/mp/zm_transit_openings::busopeningsetenabled( "door", 1 );
}

busdoorsclose()
{
	if ( self.doorsclosed || self.doorsdisabledfortime )
	{
		return;
	}
	self.doorsclosed = 1;
	self thread bussetdoornodes( 0 );
	level.the_bus showpart( "doors_front_left_2_jnt" );
	level.the_bus showpart( "doors_front_right_2_jnt" );
	level.the_bus showpart( "doors_rear_left_2_jnt" );
	level.the_bus showpart( "doors_rear_right_2_jnt" );
	doorstrigger = getentarray( "bus_door_trigger", "targetname" );
	i = 0;
	while ( i < self.doorblockers.size )
	{
		self.doorblockers[ i ] solid();
		self.doorblockers[ i ] playsound( "zmb_bus_door_close" );
		i++;
	}
	i = 0;
	while ( i < doorstrigger.size )
	{
		doorstrigger[ i ] sethintstring( &"ZOMBIE_TRANSIT_OPEN_BUS_DOOR" );
		i++;
	}
	self bususeanimtree();
	self bususedoor( 0 );
	self maps/mp/zm_transit_openings::busopeningsetenabled( "door", 0 );
}

busdoorsdisablefortime( time )
{
	doorstrigger = getentarray( "bus_door_trigger", "targetname" );
	i = 0;
	while ( i < doorstrigger.size )
	{
		doorstrigger[ i ] setinvisibletoall();
		i++;
	}
	self.doorsdisabledfortime = 1;
	wait time;
	self.doorsdisabledfortime = 0;
	i = 0;
	while ( i < doorstrigger.size )
	{
		doorstrigger[ i ] setvisibletoall();
		i++;
	}
}

init_animtree()
{
	scriptmodelsuseanimtree( -1 );
}

init_bus_door_anims()
{
	level.bus_door_open_state = %v_zombie_bus_all_doors_open;
	level.bus_door_close_state = %v_zombie_bus_all_doors_close;
	level.bus_door_open_idle_state = %v_zombie_bus_all_doors_idle_open;
	level.bus_door_close_idle_state = %v_zombie_bus_all_doors_idle_closed;
}

bususeanimtree()
{
	self useanimtree( -1 );
}

bususedoor( set )
{
	self endon( "death" );
	animtime = 1;
	if ( set )
	{
		self.door_state = set;
		self setanim( level.bus_door_open_state, 1, animtime, 1 );
	}
	else
	{
		self.door_state = set;
		self playsound( "zmb_bus_door_close" );
		self setanim( level.bus_door_close_state, 1, animtime, 1 );
	}
	self notify( "BusUseDoor" );
}

busidledoor()
{
	while ( 1 )
	{
		notifystring = self waittill_any_return( "departing", "BusUseDoor", "stopping" );
		if ( notifystring == "departing" || notifystring == "BusUseDoor" )
		{
			if ( isDefined( self.ismoving ) && self.ismoving && isDefined( self.door_state ) )
			{
				wait 1;
				if ( self.door_state )
				{
					self setanim( level.bus_door_open_idle_state );
					break;
				}
				else
				{
					self setanim( level.bus_door_close_idle_state );
				}
			}
			continue;
		}
		else
		{
			if ( notifystring == "stopping" )
			{
			}
		}
	}
}

init_props_animtree()
{
	scriptmodelsuseanimtree( -1 );
}

init_bus_props_anims()
{
	level.bus_props_start_state = %fxanim_zom_bus_interior_start_anim;
	level.bus_props_idle_state = %fxanim_zom_bus_interior_idle_anim;
	level.bus_props_end_state = %fxanim_zom_bus_interior_end_anim;
}

busfxanims()
{
	self.fxanimmodel = spawn( "script_model", self gettagorigin( "tag_body" ) );
	self.fxanimmodel setmodel( "fxanim_zom_bus_interior_mod" );
	self.fxanimmodel linkto( self, "tag_body" );
	self.fxanimmodel useanimtree( -1 );
}

busfxanims_start()
{
	if ( !isDefined( self.fxanimmodel ) )
	{
		return;
	}
	self.fxanimmodel setanim( level.bus_props_start_state );
	wait getanimlength( level.bus_props_start_state );
	if ( isDefined( self.ismoving ) && self.ismoving )
	{
		self.fxanimmodel setanim( level.bus_props_idle_state );
	}
}

busfxanims_end()
{
	if ( !isDefined( self.fxanimmodel ) )
	{
		return;
	}
	self.fxanimmodel setanim( level.bus_props_start_state );
}

busdoorthink( trigger )
{
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		if ( isDefined( self.force_lock_doors ) && self.force_lock_doors )
		{
			continue;
		}
		if ( self.doorsclosed )
		{
			if ( isDefined( level.bus_intro_done ) && !level.bus_intro_done )
			{
				thread automatonspeak( "scripted", "discover_bus" );
				level.bus_intro_done = 1;
			}
			else
			{
				if ( randomint( 100 ) > 75 && !isDefined( level.automaton.dmgfxorigin ) )
				{
					thread automatonspeak( "inform", "doors_open" );
				}
			}
			self busdoorsopen();
		}
		else
		{
			if ( randomint( 100 ) > 75 && !isDefined( level.automaton.dmgfxorigin ) )
			{
				thread automatonspeak( "inform", "doors_close" );
			}
			self busdoorsclose();
		}
		wait 1;
	}
}

busfueltanksetup()
{
	script_origin = spawn( "script_origin", self.origin + ( -193, 75, 48 ) );
	script_origin.angles = vectorScale( ( 0, 0, 1 ), 180 );
	script_origin linkto( self );
	self.fueltankmodelpoint = script_origin;
	script_origin = spawn( "script_origin", self.origin + ( -193, 128, 48 ) );
	script_origin linkto( self );
	self.fueltanktriggerpoint = script_origin;
}

busdeferredinitplowclip( clip )
{
	origin = self worldtolocalcoords( clip.origin );
	clip.origin = vectorScale( ( 0, 0, 1 ), 100 );
	wait_for_buildable( "cattlecatcher" );
	trigger = getent( "trigger_plow", "targetname" );
	while ( 1 )
	{
		canbreak = 1;
		players = get_players();
		_a2655 = players;
		_k2655 = getFirstArrayKey( _a2655 );
		while ( isDefined( _k2655 ) )
		{
			player = _a2655[ _k2655 ];
			if ( player istouching( trigger ) )
			{
				canbreak = 0;
			}
			_k2655 = getNextArrayKey( _a2655, _k2655 );
		}
		if ( canbreak )
		{
			break;
		}
		else
		{
			wait 0,05;
		}
	}
	self.plow_clip_attached = 1;
	clip linkto( self, "", origin, ( 0, 0, 1 ) );
	clip setmovingplatformenabled( 1 );
}

busplowupdatesolid()
{
	if ( isDefined( self.cow_catcher_blocker ) )
	{
		if ( isDefined( self.ismoving ) && !self.ismoving && isDefined( self.plow_attached ) && self.plow_attached )
		{
			self.cow_catcher_blocker solid();
			self.cow_catcher_blocker disconnectpaths();
			return;
		}
		else
		{
			self.cow_catcher_blocker notsolid();
			self.cow_catcher_blocker connectpaths();
		}
	}
}

busplowsetup()
{
	clipbrush = getentarray( "plow_clip", "targetname" );
	while ( isDefined( clipbrush ) && clipbrush.size > 0 )
	{
		i = 0;
		while ( i < clipbrush.size )
		{
			self thread busdeferredinitplowclip( clipbrush[ i ] );
			i++;
		}
	}
	level.the_bus.plow_clip = clipbrush;
	level.the_bus hidepart( "tag_plow_attach" );
	trigger = getent( "trigger_plow", "targetname" );
	trigger linkto( level.the_bus );
	trigger setmovingplatformenabled( 1 );
	self thread busplowmoveplayeronbuilt();
	self thread busplowmoveplayer();
	self.bussmashtrigger = trigger;
	cow_catcher_blocker = getent( "cow_catcher_path_blocker", "targetname" );
	if ( isDefined( cow_catcher_blocker ) )
	{
		self.cow_catcher_blocker = cow_catcher_blocker;
		if ( !isDefined( self.path_blockers ) )
		{
			self.path_blockers = [];
		}
		self.path_blockers[ self.path_blockers.size ] = cow_catcher_blocker;
		self busplowupdatesolid();
	}
	player = wait_for_buildable( "cattlecatcher" );
	flag_set( "catcher_attached" );
	self.plow_attached = 1;
	self busplowupdatesolid();
	self.plowtrigger = trigger;
	level.the_bus showpart( "tag_plow_attach" );
	level.the_bus.upgrades[ "Plow" ].installed = 1;
	level.the_bus maps/mp/zm_transit_openings::busopeningsetenabled( "front", 0 );
	player maps/mp/zombies/_zm_buildables::track_placed_buildables( "cattlecatcher" );
}

busplowmoveplayeronbuilt()
{
	wait_for_buildable( "cattlecatcher" );
	while ( isDefined( self.plow_clip_attached ) && !self.plow_clip_attached )
	{
		self busplowmoveplayerthink();
		wait 0,05;
	}
}

busplowmoveplayer()
{
	while ( 1 )
	{
		while ( is_false( self.ismoving ) || isDefined( self.disabled_by_emp ) && self.disabled_by_emp )
		{
			wait 0,1;
		}
		self busplowmoveplayerthink();
		wait 0,05;
	}
}

busplowmoveplayerthink()
{
	if ( !isDefined( level.triggerplow ) )
	{
		level.triggerplow = getent( "trigger_plow", "targetname" );
	}
	players = get_players();
	_a2797 = players;
	_k2797 = getFirstArrayKey( _a2797 );
	while ( isDefined( _k2797 ) )
	{
		player = _a2797[ _k2797 ];
		if ( isDefined( player.isonbus ) && player.isonbus )
		{
		}
		else
		{
			if ( player istouching( level.triggerplow ) )
			{
				rightdistance = distancesquared( player.origin, self gettagorigin( "tag_wheel_front_right" ) );
				leftdistance = distancesquared( player.origin, self gettagorigin( "tag_wheel_front_left" ) );
				bus_dir = undefined;
				if ( isDefined( player.is_burning ) && player getstance() == "stand" )
				{
					player setstance( "crouch" );
				}
				if ( rightdistance < leftdistance )
				{
					bus_dir = vectorScale( anglesToForward( self.angles + ( -60, -60, 30 ) ), 512 );
				}
				else
				{
					bus_dir = vectorScale( anglesToForward( self.angles + ( 60, 60, 30 ) ), 512 );
				}
				bus_vel = self getvelocity();
				boost_velocity = bus_vel + bus_dir;
				player setvelocity( boost_velocity );
			}
		}
		_k2797 = getNextArrayKey( _a2797, _k2797 );
	}
}

buspushzombie( zombie, trigger )
{
	opening = level.the_bus maps/mp/zm_transit_openings::busopeningbyname( "front" );
	if ( isDefined( opening ) && isDefined( opening.zombie ) || opening.zombie != zombie && isDefined( zombie.is_inert ) && zombie.is_inert )
	{
		busplowkillzombie( zombie );
	}
	else
	{
		zombie thread zombieattachtobus( level.the_bus, opening, 0 );
	}
}

busplowkillzombie( zombie )
{
	zombie.killedbyplow = 1;
	if ( isDefined( zombie.busplowkillzombie ) )
	{
		zombie thread [[ zombie.busplowkillzombie ]]();
		return;
	}
	if ( is_mature() )
	{
		if ( isDefined( level._effect[ "zomb_gib" ] ) )
		{
			playfxontag( level._effect[ "zomb_gib" ], zombie, "J_SpineLower" );
		}
	}
	else
	{
		if ( isDefined( level._effect[ "spawn_cloud" ] ) )
		{
			playfxontag( level._effect[ "spawn_cloud" ], zombie, "J_SpineLower" );
		}
	}
	zombie thread busplowkillzombieuntildeath();
	wait 1;
	if ( isDefined( zombie ) )
	{
		zombie hide();
	}
	if ( !isDefined( self.upgrades[ "Plow" ].killcount ) )
	{
		self.upgrades[ "Plow" ].killcount = 0;
	}
	self.upgrades[ "Plow" ].killcount++;
}

busplowkillzombieuntildeath()
{
	self endon( "death" );
	while ( isDefined( self ) && isalive( self ) )
	{
		if ( isDefined( self.health ) )
		{
			self.marked_for_recycle = 1;
			self dodamage( self.health + 666, self.origin, self, self, "none", "MOD_SUICIDE" );
		}
		wait 1;
	}
}

bus_roof_watch()
{
	roof_trig = getent( "bus_roof_watch", "targetname" );
	roof_trig enablelinkto();
	roof_trig linkto( self, "", self worldtolocalcoords( roof_trig.origin ), roof_trig.angles + self.angles );
	roof_trig setmovingplatformenabled( 1 );
}

busroofjumpoffpositionssetup()
{
	jump_positions = getentarray( "roof_jump_off_positions", "targetname" );
/#
	assert( jump_positions.size > 0 );
#/
	i = 0;
	while ( i < jump_positions.size )
	{
		jump_positions[ i ] linkto( self, "", self worldtolocalcoords( jump_positions[ i ].origin ), jump_positions[ i ].angles + self.angles );
		i++;
	}
}

bussideladderssetup()
{
	side_ladders = getentarray( "roof_ladder_outside", "targetname" );
	i = 0;
	while ( i < side_ladders.size )
	{
		side_ladders[ i ].trigger = getent( side_ladders[ i ].target, "targetname" );
		if ( !isDefined( side_ladders[ i ].trigger ) )
		{
			side_ladders[ i ] delete();
			i++;
			continue;
		}
		else
		{
			side_ladders[ i ] linkto( self, "", self worldtolocalcoords( side_ladders[ i ].origin ), side_ladders[ i ].angles + self.angles );
			side_ladders[ i ].trigger enablelinkto();
			side_ladders[ i ].trigger linkto( self, "", self worldtolocalcoords( side_ladders[ i ].trigger.origin ), side_ladders[ i ].trigger.angles + self.angles );
			self thread bussideladderthink( side_ladders[ i ], side_ladders[ i ].trigger );
		}
		i++;
	}
}

bussideladderthink( ladder, trigger )
{
	if ( 1 )
	{
		trigger delete();
		return;
	}
	trigger setcursorhint( "HINT_NOICON" );
	trigger sethintstring( &"ZOMBIE_TRANSIT_BUS_CLIMB_ROOF" );
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		teleport_location = self localtoworldcoords( ladder.script_vector );
		player setorigin( teleport_location );
		trigger setinvisibletoall();
		wait 1;
		trigger setvisibletoall();
	}
}

buspathblockersetup()
{
	self.path_blockers = getentarray( "bus_path_blocker", "targetname" );
	i = 0;
	while ( i < self.path_blockers.size )
	{
		self.path_blockers[ i ] linkto( self, "", self worldtolocalcoords( self.path_blockers[ i ].origin ), self.path_blockers[ i ].angles + self.angles );
		i++;
	}
	cow_catcher_blocker = getent( "cow_catcher_path_blocker", "targetname" );
	if ( isDefined( cow_catcher_blocker ) )
	{
		cow_catcher_blocker linkto( self, "", self worldtolocalcoords( cow_catcher_blocker.origin ), cow_catcher_blocker.angles + self.angles );
	}
	trig = getent( "bus_buyable_weapon1", "script_noteworthy" );
	trig enablelinkto();
	trig linkto( self, "", self worldtolocalcoords( trig.origin ), ( 0, 0, 1 ) );
	trig setinvisibletoall();
	self.buyable_weapon = trig;
	level._spawned_wallbuys[ level._spawned_wallbuys.size ] = trig;
	weapon_model = getent( trig.target, "targetname" );
	weapon_model linkto( self, "", self worldtolocalcoords( weapon_model.origin ), weapon_model.angles + self.angles );
	weapon_model setmovingplatformenabled( 1 );
	weapon_model._linked_ent = trig;
}

bussetdoornodes( enable )
{
	if ( isDefined( self.door_nodes_avoid_linking ) && self.door_nodes_avoid_linking )
	{
		return;
	}
	if ( enable )
	{
		if ( !self.door_nodes_linked )
		{
			link_nodes( self.front_door_inside, self.front_door );
			link_nodes( self.front_door, self.front_door_inside );
			link_nodes( self.back_door_inside1, self.back_door );
			link_nodes( self.back_door, self.back_door_inside1 );
			link_nodes( self.back_door_inside2, self.back_door );
			link_nodes( self.back_door, self.back_door_inside2 );
			self.door_nodes_linked = 1;
		}
	}
	else
	{
		if ( self.door_nodes_linked )
		{
			unlink_nodes( self.front_door_inside, self.front_door );
			unlink_nodes( self.front_door, self.front_door_inside );
			unlink_nodes( self.back_door_inside1, self.back_door );
			unlink_nodes( self.back_door, self.back_door_inside1 );
			unlink_nodes( self.back_door_inside2, self.back_door );
			unlink_nodes( self.back_door, self.back_door_inside2 );
			self.door_nodes_linked = 0;
		}
	}
}

buspathblockerenable()
{
	if ( !isDefined( self.path_blockers ) )
	{
		return;
	}
	if ( self.path_blocking )
	{
		return;
	}
	while ( level.the_bus getspeed() > 0 )
	{
		wait 0,1;
	}
	i = 0;
	while ( i < self.path_blockers.size )
	{
		self.path_blockers[ i ] disconnectpaths();
		i++;
	}
	self.link_start = [];
	self.link_end = [];
	self buslinkdoornodes( "front_door_node" );
	self buslinkdoornodes( "back_door_node" );
	self.path_blocking = 1;
}

buslinkdoornodes( node_name )
{
	start_node = getnode( node_name, "targetname" );
	start_node.links = [];
	while ( isDefined( start_node ) )
	{
		near_nodes = getnodesinradiussorted( start_node.origin, 128, 0, 64, "pathnodes" );
		links = 0;
		_a3071 = near_nodes;
		_k3071 = getFirstArrayKey( _a3071 );
		while ( isDefined( _k3071 ) )
		{
			node = _a3071[ _k3071 ];
			if ( !isDefined( node.target ) || node.target != "the_bus" )
			{
				self.link_start[ self.link_start.size ] = start_node;
				self.link_end[ self.link_end.size ] = node;
				link_nodes( start_node, node );
				link_nodes( node, start_node );
				start_node.links[ start_node.links.size ] = node;
				links++;
				if ( links == 2 )
				{
					return;
				}
			}
			else
			{
				_k3071 = getNextArrayKey( _a3071, _k3071 );
			}
		}
	}
}

busunlinkdoornodes( node_name )
{
	start_node = getnode( node_name, "targetname" );
	while ( isDefined( start_node ) && isDefined( start_node.links ) )
	{
		linked_nodes = start_node.links;
		_a3098 = linked_nodes;
		_k3098 = getFirstArrayKey( _a3098 );
		while ( isDefined( _k3098 ) )
		{
			node = _a3098[ _k3098 ];
			if ( !isDefined( node.target ) || node.target != "the_bus" )
			{
				unlink_nodes( start_node, node );
				unlink_nodes( node, start_node );
			}
			_k3098 = getNextArrayKey( _a3098, _k3098 );
		}
	}
}

buspathblockerdisable()
{
	if ( !isDefined( self.path_blockers ) )
	{
		return;
	}
	if ( !self.path_blocking )
	{
		return;
	}
	i = 0;
	while ( i < self.path_blockers.size )
	{
		self.path_blockers[ i ] connectpaths();
		i++;
	}
	self.link_start = [];
	self.link_end = [];
	self busunlinkdoornodes( "front_door_node" );
	self busunlinkdoornodes( "back_door_node" );
	self.path_blocking = 0;
	self bussetdineropenings( 1 );
	self bussetpoweropenings( 1 );
	self bussettownopenings( 1 );
}

bussetupbounds()
{
	self.bounds_origins = getentarray( "bus_bounds_origin", "targetname" );
	i = 0;
	while ( i < self.bounds_origins.size )
	{
		self.bounds_origins[ i ] linkto( self, "", self worldtolocalcoords( self.bounds_origins[ i ].origin ), self.angles );
		i++;
	}
}

busstartwait()
{
	while ( self getspeed() == 0 )
	{
		wait 0,1;
	}
}

busshowleavinghud( time )
{
	if ( !isDefined( level.bus_leave_hud ) )
	{
		level.bus_leave_hud = newhudelem();
		level.bus_leave_hud.color = ( 0, 0, 1 );
		level.bus_leave_hud.fontscale = 4;
		level.bus_leave_hud.x = -300;
		level.bus_leave_hud.y = 100;
		level.bus_leave_hud.alignx = "center";
		level.bus_leave_hud.aligny = "bottom";
		level.bus_leave_hud.horzalign = "center";
		level.bus_leave_hud.vertalign = "middle";
		level.bus_leave_hud.font = "objective";
		level.bus_leave_hud.glowcolor = ( 0,3, 0,6, 0,3 );
		level.bus_leave_hud.glowalpha = 1;
		level.bus_leave_hud.foreground = 1;
		level.bus_leave_hud.hidewheninmenu = 1;
	}
	level.bus_leave_hud.alpha = 0,3;
	level.bus_leave_hud settimer( time );
	wait time;
	level.bus_leave_hud.alpha = 0;
}

busstartmoving( targetspeed )
{
	if ( !self.ismoving )
	{
		self.ismoving = 1;
		self.isstopping = 0;
		self thread busexceedchasespeed();
		bbprint( "zombie_events", "%s", "bus_start" );
		self setclientfield( "bus_brake_lights", 0 );
		self buspathblockerdisable();
		self thread busfxanims_start();
		self busplowupdatesolid();
		if ( !flag( "ambush_round" ) )
		{
			level.numbusstopssincelastambushround++;
		}
	}
	if ( isDefined( targetspeed ) )
	{
		self.targetspeed = targetspeed;
	}
	self notify( "OnKeysUsed" );
	self thread play_bus_audio( "leaving" );
}

busexceedchasespeed()
{
	self notify( "exceed_chase_speed" );
	self endon( "exceed_chase_speed" );
	while ( isDefined( self.ismoving ) && self.ismoving )
	{
		if ( self getspeedmph() > 12 )
		{
			self.exceed_chase_speed = 1;
			return;
		}
		wait 0,1;
	}
}

busstopwait()
{
	while ( self.ismoving && !self.isstopping )
	{
		self.isstopping = 1;
		bbprint( "zombie_events", "%s", "bus_stop" );
		while ( self getspeed() > 0 )
		{
			wait 0,1;
		}
	}
}

busstopmoving( immediatestop )
{
	if ( self.ismoving )
	{
		if ( isDefined( immediatestop ) && immediatestop )
		{
			self.immediatespeed = 1;
		}
		self notify( "stopping" );
		self thread play_bus_audio( "stopping" );
		self.targetspeed = 0;
		self setspeedimmediate( self.targetspeed, 30, 30 );
		self.ismoving = 0;
		self.isstopping = 0;
		self.exceed_chase_speed = 0;
		self busplowupdatesolid();
		self thread buslightsbrake();
		self thread buspathblockerenable();
		self thread shakeplayersonbus();
		self thread busfxanims_end();
	}
}

shakeplayersonbus()
{
	players = get_players();
	_a3289 = players;
	_k3289 = getFirstArrayKey( _a3289 );
	while ( isDefined( _k3289 ) )
	{
		player = _a3289[ _k3289 ];
		if ( isDefined( player.isonbus ) && player.isonbus )
		{
			earthquake( randomfloatrange( 0,3, 0,4 ), randomfloatrange( 0,2, 0,4 ), player.origin + vectorScale( ( 0, 0, 1 ), 32 ), 150 );
		}
		_k3289 = getNextArrayKey( _a3289, _k3289 );
	}
}

busgasadd( percent )
{
	newgaslevel = level.the_bus.gas + percent;
/#
	println( "^2Bus Debug: Old Gas Level is " + newgaslevel );
#/
	if ( newgaslevel < 0 )
	{
		newgaslevel = 0;
	}
	else
	{
		if ( newgaslevel > 100 )
		{
			newgaslevel = 100;
		}
	}
	level.the_bus.gas = newgaslevel;
/#
	println( "^2Bus Debug: New Gas Level is " + newgaslevel );
#/
}

busgasremove( percent )
{
	busgasadd( percent * -1 );
}

busgasempty()
{
	if ( level.the_bus.gas <= 0 )
	{
		return 1;
	}
	return 0;
}

busrestartzombiespawningaftertime( seconds )
{
	wait seconds;
	maps/mp/zm_transit_utility::try_resume_zombie_spawning();
}

busthink()
{
	no_danger = 0;
	self thread busupdatechasers();
	self.buyable_weapon notify( "stop_hint_logic" );
	self thread busupdateplayers();
	self thread busupdatenearzombies();
	while ( 1 )
	{
		waittillframeend;
		self busupdatespeed();
		self busupdateignorewindows();
		if ( self.ismoving )
		{
			self busupdatenearequipment();
		}
		if ( isDefined( level.bus_zombie_danger ) && !level.bus_zombie_danger || self.numplayersonroof && self.numplayersinsidebus )
		{
			no_danger++;
			if ( no_danger > 40 )
			{
				level thread do_player_bus_zombie_vox( "bus_zom_none", 40, 60 );
				no_danger = 0;
			}
		}
		else
		{
			no_danger = 0;
		}
		wait 0,1;
	}
}

zomclimbingvox( old, new )
{
	if ( new <= old )
	{
		return;
	}
	if ( new == 1 || new == 3 )
	{
		level thread do_player_bus_zombie_vox( "bus_zom_climb", 30 );
	}
}

zomchasingvox()
{
	if ( self.zombies_chasing_bus > 2 )
	{
		level thread do_player_bus_zombie_vox( "bus_zom_chase", 15 );
	}
}

zomonbusvox( old, new )
{
	if ( new == old )
	{
		return;
	}
	if ( new != 1 && new != 4 && new == 8 && randomint( 100 ) < 20 )
	{
		level thread automatonspeak( "inform", "zombie_on_board" );
	}
	else
	{
		if ( new >= 1 )
		{
			level thread do_player_bus_zombie_vox( "bus_zom_ent", 25 );
		}
	}
}

zomatwindowvox( old, new )
{
	if ( new <= old )
	{
		return;
	}
	if ( new != 1 && new != 3 && new == 5 && randomint( 100 ) < 35 )
	{
		level thread automatonspeak( "inform", "zombie_at_window" );
	}
	else
	{
		if ( new >= 1 )
		{
			level thread do_player_bus_zombie_vox( "bus_zom_atk", 25 );
		}
	}
}

zomonroofvox( old, new )
{
	if ( new <= old )
	{
		return;
	}
	if ( new != 1 && new != 4 && new == 8 && randomint( 100 ) < 35 )
	{
		level thread automatonspeak( "inform", "zombie_on_roof" );
	}
	else
	{
		if ( new >= 1 )
		{
			level thread do_player_bus_zombie_vox( "bus_zom_roof", 25 );
		}
	}
}

bussetdineropenings( enable )
{
	_a3464 = self.openings;
	_k3464 = getFirstArrayKey( _a3464 );
	while ( isDefined( _k3464 ) )
	{
		opening = _a3464[ _k3464 ];
		if ( opening.bindtag != "window_right_2_jnt" && opening.bindtag != "window_right_3_jnt" || opening.bindtag == "window_left_2_jnt" && opening.bindtag == "window_left_3_jnt" )
		{
			opening.enabled = enable;
		}
		_k3464 = getNextArrayKey( _a3464, _k3464 );
	}
}

bussetpoweropenings( enable )
{
	_a3476 = self.openings;
	_k3476 = getFirstArrayKey( _a3476 );
	while ( isDefined( _k3476 ) )
	{
		opening = _a3476[ _k3476 ];
		if ( opening.bindtag == "window_right_4_jnt" )
		{
			opening.enabled = enable;
		}
		_k3476 = getNextArrayKey( _a3476, _k3476 );
	}
}

bussettownopenings( enable )
{
	_a3487 = self.openings;
	_k3487 = getFirstArrayKey( _a3487 );
	while ( isDefined( _k3487 ) )
	{
		opening = _a3487[ _k3487 ];
		if ( opening.bindtag == "window_right_4_jnt" )
		{
			opening.enabled = enable;
		}
		_k3487 = getNextArrayKey( _a3487, _k3487 );
	}
}

busgetclosestopening()
{
	enemy = self.favoriteenemy;
	closestorigin = undefined;
	closestopeningtozombie = undefined;
	closestdisttozombie = -1;
	closestorigintozombie = undefined;
	closestopeningtoplayer = undefined;
	closestdisttoplayer = -1;
	closestorigintoplayer = undefined;
	i = 0;
	while ( i < level.the_bus.openings.size )
	{
		opening = level.the_bus.openings[ i ];
		if ( !opening.enabled )
		{
			i++;
			continue;
		}
		else if ( maps/mp/zm_transit_openings::_isopeningdoor( opening.bindtag ) )
		{
			i++;
			continue;
		}
		else jump_origin = maps/mp/zm_transit_openings::_determinejumpfromorigin( opening );
		dist2 = distancesquared( enemy.origin, jump_origin );
		if ( !isDefined( closestopeningtoplayer ) || dist2 < closestdisttoplayer )
		{
			closestopeningtoplayer = opening;
			closestorigintoplayer = jump_origin;
			closestdisttoplayer = dist2;
		}
		if ( isDefined( opening.zombie ) )
		{
			i++;
			continue;
		}
		else
		{
			dist2 = distancesquared( self.origin, jump_origin );
			if ( !isDefined( closestopeningtozombie ) || dist2 < closestdisttozombie )
			{
				closestopeningtozombie = opening;
				closestorigintozombie = jump_origin;
				closestdisttozombie = dist2;
			}
		}
		i++;
	}
	if ( isDefined( closestopeningtozombie ) )
	{
		closestorigin = closestorigintozombie;
	}
	else
	{
		closestorigin = closestorigintoplayer;
	}
	return closestorigin;
}

busgetclosestexit()
{
	enemy = self.favoriteenemy;
	goal_node = level.the_bus.front_door_inside;
	if ( isDefined( enemy ) )
	{
		dist_f = distancesquared( enemy.origin, level.the_bus.front_door_inside );
		dist_bl = distancesquared( enemy.origin, level.the_bus.exit_back_l );
		dist_br = distancesquared( enemy.origin, level.the_bus.exit_back_r );
		if ( dist_bl < dist_br )
		{
			if ( dist_bl < dist_f )
			{
				goal_node = dist_bl;
			}
		}
		else
		{
			if ( dist_br < dist_f )
			{
				goal_node = dist_br;
			}
		}
	}
	return goal_node.origin;
}

enemy_location_override()
{
	enemy = self.favoriteenemy;
	location = enemy.origin;
	bus = level.the_bus;
	if ( isDefined( self.isscreecher ) || self.isscreecher && isDefined( self.is_avogadro ) && self.is_avogadro )
	{
		return location;
	}
	if ( isDefined( self.item ) )
	{
		return self.origin;
	}
	if ( is_true( self.reroute ) )
	{
		if ( isDefined( self.reroute_origin ) )
		{
			location = self.reroute_origin;
		}
	}
	if ( isDefined( enemy.isonbus ) && enemy.isonbus && isDefined( self.solo_revive_exit ) && !self.solo_revive_exit )
	{
		if ( isDefined( self.isonbus ) && !self.isonbus )
		{
			if ( isDefined( bus.ismoving ) && bus.ismoving && isDefined( bus.disabled_by_emp ) && !bus.disabled_by_emp )
			{
				self.ignoreall = 1;
				if ( isDefined( self.close_to_bus ) && self.close_to_bus && isDefined( bus.istouchingignorewindowsvolume ) && !bus.istouchingignorewindowsvolume )
				{
					self.goalradius = 2;
					location = self busgetclosestopening();
					location = groundpos_ignore_water_new( location + vectorScale( ( 0, 0, 1 ), 60 ) );
				}
				else
				{
					self.goalradius = 32;
					while ( getTime() != bus.chase_pos_time )
					{
						bus.chase_pos_time = getTime();
						bus.chase_pos_index = 0;
						bus_forward = vectornormalize( anglesToForward( level.the_bus.angles ) );
						bus_right = vectornormalize( anglesToRight( level.the_bus.angles ) );
						bus.chase_pos = [];
						bus.chase_pos[ 0 ] = level.the_bus.origin + vectorScale( bus_forward, -144 );
						bus.chase_pos[ 1 ] = bus.chase_pos[ 0 ] + vectorScale( bus_right, 64 );
						bus.chase_pos[ 2 ] = bus.chase_pos[ 0 ] + vectorScale( bus_right, -64 );
						_a3656 = bus.chase_pos;
						_k3656 = getFirstArrayKey( _a3656 );
						while ( isDefined( _k3656 ) )
						{
							pos = _a3656[ _k3656 ];
							pos = groundpos_ignore_water_new( pos + vectorScale( ( 0, 0, 1 ), 60 ) );
							_k3656 = getNextArrayKey( _a3656, _k3656 );
						}
					}
					location = bus.chase_pos[ bus.chase_pos_index ];
					bus.chase_pos_index++;
					if ( bus.chase_pos_index >= 3 )
					{
						bus.chase_pos_index = 0;
					}
					dist_sq = distancesquared( self.origin, location );
					if ( dist_sq < 2304 )
					{
						self.close_to_bus = 1;
					}
				}
				return location;
			}
			self.close_to_bus = 0;
			if ( isDefined( bus.doorsclosed ) && bus.doorsclosed )
			{
				self.ignoreall = 1;
				self.goalradius = 2;
				location = self busgetclosestopening();
			}
			else
			{
				if ( isDefined( enemy.isonbusroof ) && enemy.isonbusroof )
				{
					self.ignoreall = 1;
					self.goalradius = 2;
					location = self busgetclosestopening();
				}
				else
				{
					front_dist = distance2dsquared( enemy.origin, level.the_bus.front_door.origin );
					back_dist = distance2dsquared( enemy.origin, level.the_bus.back_door.origin );
					if ( front_dist < back_dist )
					{
						location = level.the_bus.front_door_inside.origin;
					}
					else
					{
						location = level.the_bus.back_door_inside1.origin;
					}
					self.ignoreall = 0;
					self.goalradius = 32;
				}
			}
		}
	}
	return location;
}

adjust_enemyoverride()
{
	location = self.enemyoverride[ 0 ];
	bus = level.the_bus;
	ent = self.enemyoverride[ 1 ];
	if ( isDefined( ent ) )
	{
		if ( ent entity_is_on_bus( 1 ) )
		{
			if ( isDefined( self.isonbus ) && !self.isonbus )
			{
				if ( isDefined( bus.doorsclosed ) && bus.doorsclosed )
				{
					self.goalradius = 2;
					location = self busgetclosestopening();
				}
			}
			else
			{
				self.goalradius = 32;
			}
		}
	}
	return location;
}

attachpoweruptobus( powerup )
{
	if ( !isDefined( powerup ) || !isDefined( level.the_bus ) )
	{
		return;
	}
	distanceoutsideofbus = 50;
	heightofroofpowerup = 60;
	heightoffloorpowerup = 25;
	originofbus = level.the_bus gettagorigin( "tag_origin" );
	floorofbus = originofbus[ 2 ] + level.the_bus.floor;
	adjustup = 0;
	adjustdown = 0;
	adjustin = 0;
	pos = powerup.origin;
	posinbus = pointonsegmentnearesttopoint( level.the_bus.frontworld, level.the_bus.backworld, pos );
	posdist2 = distance2dsquared( pos, posinbus );
	if ( posdist2 > ( level.the_bus.radius * level.the_bus.radius ) )
	{
		radiusplus = level.the_bus.radius + distanceoutsideofbus;
		if ( posdist2 > ( radiusplus * radiusplus ) )
		{
			return;
		}
		adjustin = 1;
	}
	if ( !adjustin )
	{
		bus_front_local = ( 276, 28, 0 );
		bus_front_local_world = level.the_bus localtoworldcoords( bus_front_local );
		bus_front_radius2 = 10000;
		front_dist2 = distance2dsquared( powerup.origin, bus_front_local_world );
		if ( front_dist2 < bus_front_radius2 )
		{
			adjustin = 1;
		}
	}
	if ( adjustin )
	{
		directiontobus = posinbus - pos;
		directiontobusn = vectornormalize( directiontobus );
		howfarintobus = distanceoutsideofbus + 10;
		powerup.origin += directiontobusn * howfarintobus;
	}
	poszdelta = powerup.origin[ 2 ] - posinbus[ 2 ];
	if ( poszdelta < ( level.the_bus.floor + heightoffloorpowerup ) )
	{
		adjustup = 1;
	}
	else
	{
		if ( poszdelta > ( level.the_bus.height - 20 ) )
		{
			adjustdown = 1;
		}
	}
	if ( adjustup )
	{
		powerup.origin = ( powerup.origin[ 0 ], powerup.origin[ 1 ], floorofbus + heightoffloorpowerup );
	}
	else
	{
		if ( adjustdown )
		{
			powerup.origin = ( powerup.origin[ 0 ], powerup.origin[ 1 ], floorofbus + heightofroofpowerup );
		}
	}
	powerup linkto( level.the_bus, "", level.the_bus worldtolocalcoords( powerup.origin ), powerup.angles - level.the_bus.angles );
}

shouldsuppressgibs( zombie )
{
	if ( !isDefined( zombie ) || !isDefined( level.the_bus ) )
	{
		return 0;
	}
	pos = zombie.origin;
	posinbus = pointonsegmentnearesttopoint( level.the_bus.frontworld, level.the_bus.backworld, pos );
	poszdelta = pos[ 2 ] - posinbus[ 2 ];
	if ( poszdelta < ( level.the_bus.floor - 10 ) )
	{
		return 0;
	}
	posdist2 = distance2dsquared( pos, posinbus );
	if ( posdist2 > ( level.the_bus.radius * level.the_bus.radius ) )
	{
		return 0;
	}
	return 1;
}

bus_bridge_speedcontrol()
{
	while ( 1 )
	{
		self waittill( "reached_node", nextpoint );
/#
		if ( getDvarInt( #"583AF524" ) != 0 )
		{
			if ( isDefined( nextpoint.target ) )
			{
				futurenode = getvehiclenode( nextpoint.target, "targetname" );
				if ( isDefined( futurenode.script_noteworthy ) && futurenode.script_noteworthy == "emp_stop_point" )
				{
					player = get_players()[ 0 ];
					player thread maps/mp/zombies/_zm_weap_emp_bomb::emp_detonate( player magicgrenadetype( "emp_grenade_zm", self.origin + vectorScale( ( 0, 0, 1 ), 10 ), ( 0, 0, 1 ), 0,05 ) );
#/
				}
			}
		}
		if ( isDefined( nextpoint.script_string ) )
		{
			if ( nextpoint.script_string == "arrival_slowdown" )
			{
				self thread start_stopping_bus();
			}
			if ( nextpoint.script_string == "arrival_slowdown_fast" )
			{
				self thread start_stopping_bus( 1 );
			}
		}
		while ( isDefined( nextpoint.script_noteworthy ) )
		{
			if ( nextpoint.script_noteworthy == "slow_down" )
			{
				self.targetspeed = 10;
				if ( isDefined( nextpoint.script_float ) )
				{
					self.targetspeed = nextpoint.script_float;
				}
				self setspeed( self.targetspeed, 80, 5 );
				break;
			}
			else if ( nextpoint.script_noteworthy == "turn_signal_left" || nextpoint.script_noteworthy == "turn_signal_right" )
			{
				self thread buslightsignal( nextpoint.script_noteworthy );
				break;
			}
			else
			{
				if ( nextpoint.script_noteworthy == "resume_speed" )
				{
					self.targetspeed = 12;
					if ( isDefined( nextpoint.script_float ) )
					{
						self.targetspeed = nextpoint.script_float;
					}
					self setspeed( self.targetspeed, 60, 60 );
					break;
				}
				else if ( nextpoint.script_noteworthy == "emp_stop_point" )
				{
					self notify( "reached_emp_stop_point" );
					break;
				}
				else if ( nextpoint.script_noteworthy == "start_lava" )
				{
					playfxontag( level._effect[ "bus_lava_driving" ], self, "tag_origin" );
					break;
				}
				else if ( nextpoint.script_noteworthy == "stop_lava" )
				{
					break;
				}
				else if ( nextpoint.script_noteworthy == "bus_scrape" )
				{
					self playsound( "zmb_bus_car_scrape" );
					break;
				}
				else if ( nextpoint.script_noteworthy == "arriving" )
				{
					self thread begin_arrival_slowdown();
					self thread play_bus_audio( "arriving" );
					level thread do_player_bus_zombie_vox( "bus_stop", 10 );
					self thread buslightsignal( "turn_signal_right" );
					break;
				}
				else if ( nextpoint.script_noteworthy == "enter_transition" )
				{
					playfxontag( level._effect[ "fx_zbus_trans_fog" ], self, "tag_headlights" );
					break;
				}
				else if ( nextpoint.script_noteworthy == "bridge" )
				{
					level thread do_automaton_arrival_vox( "bridge" );
					player_near = 0;
					node = getvehiclenode( "bridge_accel_point", "script_noteworthy" );
					while ( isDefined( node ) )
					{
						players = get_players();
						_a3956 = players;
						_k3956 = getFirstArrayKey( _a3956 );
						while ( isDefined( _k3956 ) )
						{
							player = _a3956[ _k3956 ];
							if ( player.isonbus )
							{
							}
							else
							{
								if ( distancesquared( player.origin, node.origin ) < 6760000 )
								{
									player_near = 1;
								}
							}
							_k3956 = getNextArrayKey( _a3956, _k3956 );
						}
					}
					if ( player_near )
					{
						trig = getent( "bridge_trig", "targetname" );
						trig notify( "trigger" );
					}
					break;
				}
				else
				{
					while ( nextpoint.script_noteworthy == "depot" )
					{
						volume = getent( "depot_lava_pit", "targetname" );
						traverse_volume = getent( "depot_pit_traverse", "targetname" );
						while ( isDefined( volume ) )
						{
							zombies = getaiarray( level.zombie_team );
							i = 0;
							while ( i < zombies.size )
							{
								if ( isDefined( zombies[ i ].depot_lava_pit ) )
								{
									if ( zombies[ i ] istouching( volume ) )
									{
										zombies[ i ] thread [[ zombies[ i ].depot_lava_pit ]]();
									}
									i++;
									continue;
								}
								else if ( zombies[ i ] istouching( volume ) )
								{
									zombies[ i ] dodamage( zombies[ i ].health + 100, zombies[ i ].origin );
									i++;
									continue;
								}
								else
								{
									if ( zombies[ i ] istouching( traverse_volume ) )
									{
										zombies[ i ] dodamage( zombies[ i ].health + 100, zombies[ i ].origin );
									}
								}
								i++;
							}
						}
					}
				}
			}
		}
		waittillframeend;
	}
}

bus_audio_setup()
{
	if ( !isDefined( self ) )
	{
		return;
	}
	self.engine_ent_1 = spawn( "script_origin", self.origin );
	self.engine_ent_1 linkto( self, "tag_wheel_back_left" );
	self.engine_ent_2 = spawn( "script_origin", self.origin );
	self.engine_ent_2 linkto( self, "tag_wheel_back_left" );
}

play_bus_audio( type )
{
	level notify( "playing_bus_audio" );
	level endon( "playing_bus_audio" );
	if ( isDefined( self.disabled_by_emp ) && self.disabled_by_emp && type != "emp" )
	{
		self notify( "stop_bus_audio" );
		self.engine_ent_1 stoploopsound( 0,5 );
		self.engine_ent_2 stoploopsound( 0,5 );
		return;
	}
	switch( type )
	{
		case "grace":
			self.engine_ent_1 playloopsound( "zmb_bus_start_idle", 0,05 );
			level.automaton playsound( "zmb_bus_horn_warn" );
			break;
		case "leaving":
			level.automaton playsound( "zmb_bus_horn_leave" );
			self.engine_ent_2 playloopsound( "zmb_bus_start_move", 0,05 );
			self.engine_ent_1 stoploopsound( 2 );
			wait 7;
			if ( isDefined( self.disabled_by_emp ) && !self.disabled_by_emp )
			{
				self.engine_ent_1 playloopsound( "zmb_bus_exterior_loop", 2 );
				self.engine_ent_2 stoploopsound( 3 );
			}
			break;
		case "arriving":
			level.automaton playsound( "zmb_bus_horn_leave" );
			break;
		case "stopping":
			self notify( "stop_bus_audio" );
			level.automaton playsound( "zmb_bus_horn_leave" );
			self.engine_ent_1 stoploopsound( 3 );
			self.engine_ent_2 stoploopsound( 3 );
			self.engine_ent_2 playsound( "zmb_bus_stop_move" );
			self playsound( "zmb_bus_car_scrape" );
			break;
		case "emp":
			self notify( "stop_bus_audio" );
			self.engine_ent_1 stoploopsound( 0,5 );
			self.engine_ent_2 stoploopsound( 0,5 );
			self.engine_ent_2 playsound( "zmb_bus_emp_shutdown" );
			break;
	}
}

bus_audio_interior_loop( bus )
{
	self endon( "left bus" );
	while ( !bus.ismoving || isDefined( bus.disabled_by_emp ) && bus.disabled_by_emp )
	{
		wait 0,1;
	}
	self clientnotify( "buslps" );
	self thread bus_audio_turnoff_interior_player( bus );
	self thread bus_audio_turnoff_interior_bus( bus );
}

bus_audio_turnoff_interior_player( bus )
{
	bus endon( "stop_bus_audio" );
	self waittill_any( "left bus", "death", "player_suicide", "bled_out" );
	self clientnotify( "buslpe" );
}

bus_audio_turnoff_interior_bus( bus )
{
	self endon( "left bus" );
	self endon( "death" );
	self endon( "player_suicide" );
	self endon( "bled_out" );
	bus waittill( "stop_bus_audio" );
	self clientnotify( "buslpe" );
}

play_lava_audio()
{
	ent_back = spawn( "script_origin", self gettagorigin( "tag_wheel_back_left" ) );
	ent_back linkto( self, "tag_wheel_back_left" );
	ent_front = spawn( "script_origin", self gettagorigin( "tag_wheel_front_right" ) );
	ent_front linkto( self, "tag_wheel_front_right" );
	while ( 1 )
	{
		while ( isDefined( self.ismoving ) && !self.ismoving )
		{
			wait 1;
		}
		while ( self maps/mp/zm_transit_lava::object_touching_lava() && self.zone != "zone_station_ext" && self.zone != "zone_pri" )
		{
			ent_front playloopsound( "zmb_bus_lava_wheels_loop", 0,5 );
			ent_back playloopsound( "zmb_bus_lava_wheels_loop", 0,5 );
			wait 2;
			while ( self maps/mp/zm_transit_lava::object_touching_lava() )
			{
				wait 2;
			}
		}
		if ( isDefined( ent_back ) && isDefined( ent_front ) )
		{
			ent_front stoploopsound( 1 );
			ent_back stoploopsound( 1 );
		}
		wait 2;
	}
}

delete_lava_audio_ents( ent1, ent2 )
{
	self waittill( "stop_bus_audio" );
	ent1 delete();
	ent2 delete();
}

start_stopping_bus( stop_fast )
{
	if ( isDefined( stop_fast ) && stop_fast )
	{
		self setspeed( 4, 15 );
	}
	else
	{
		self setspeed( 4, 5 );
	}
}

begin_arrival_slowdown()
{
	self setspeed( 5 );
}

do_automoton_vox( name )
{
	if ( !issubstr( name, "vox_" ) )
	{
		return;
	}
	if ( !isDefined( level.stops ) )
	{
		level.stops = [];
	}
	if ( !isDefined( level.stops[ name ] ) )
	{
		level.stops[ name ] = 0;
	}
	level.stops[ name ]++;
	if ( level.stops[ name ] > 5 )
	{
		level.stops[ name ] = 4;
	}
	switch( name )
	{
		case "vox_enter_tunnel":
			level thread automatonspeak( "inform", "near_tunnel" + level.stops[ name ] );
			break;
		case "vox_ride_generic":
			if ( isDefined( level.stops ) && isDefined( level.stops[ "depot" ] ) && level.stops[ "depot" ] < 1 )
			{
				return;
			}
			level thread automatonspeak( "inform", "ride_generic" );
			break;
		case "vox_exit_tunnel":
			if ( isDefined( level.tunnel_exit_vox_played ) && !level.tunnel_exit_vox_played )
			{
				level thread automatonspeak( "inform", "leave_tunnel" );
				level.tunnel_exit_vox_played = 1;
			}
			break;
		case "vox_cornfield":
			level thread automatonspeak( "inform", "near_corn" + level.stops[ name ] );
			break;
		case "vox_forest1":
			level thread automatonspeak( "inform", "near_forest1_" + level.stops[ name ] );
			break;
		case "vox_forest2":
			level thread automatonspeak( "inform", "near_forest2_" + level.stops[ name ] );
			break;
	}
}

do_automaton_arrival_vox( destination )
{
	if ( !isDefined( level.stops ) )
	{
		level.stops = [];
	}
	if ( !isDefined( level.stops[ destination ] ) )
	{
		level.stops[ destination ] = 0;
	}
	if ( destination == "depot" && isDefined( level.bus_intro_done ) && !level.bus_intro_done )
	{
		return;
	}
	level.stops[ destination ]++;
	if ( level.stops[ destination ] > 5 )
	{
		level.stops[ destination ] = 4;
	}
	switch( destination )
	{
		case "depot":
			if ( isDefined( level.bus_intro_done ) && !level.bus_intro_done )
			{
				break;
		}
		else
		{
			level thread automatonspeak( "inform", "near_station" + level.stops[ destination ] );
			break;
		return;
		case "diner":
		case "farm":
		case "power":
		case "town":
			level thread automatonspeak( "inform", "near_" + destination + level.stops[ destination ] );
			break;
		return;
		case "bridge":
			if ( isDefined( level.collapse_vox_said ) && level.collapse_vox_said )
			{
				level thread automatonspeak( "inform", "near_" + destination + level.stops[ destination ] );
			}
			break;
		return;
	}
}
}

do_player_bus_location_vox( node_info )
{
	players = get_players();
	players = array_randomize( players );
	valid_player = undefined;
	_a4291 = players;
	_k4291 = getFirstArrayKey( _a4291 );
	while ( isDefined( _k4291 ) )
	{
		player = _a4291[ _k4291 ];
		if ( isDefined( player.isonbus ) && player.isonbus )
		{
			valid_player = player;
			break;
		}
		else
		{
			_k4291 = getNextArrayKey( _a4291, _k4291 );
		}
	}
	if ( !isDefined( valid_player ) )
	{
		return;
	}
	if ( isDefined( level.bus_zombie_danger ) && level.bus_zombie_danger && !valid_player.talks_in_danger )
	{
		return;
	}
	vo_line = undefined;
	if ( issubstr( node_info, "map_in" ) )
	{
		if ( !isDefined( level.arrivals ) )
		{
			level.arrivals = [];
		}
		if ( !isDefined( level.arrivals[ node_info ] ) )
		{
			level.arrivals[ node_info ] = 0;
		}
		level.arrivals[ node_info ]++;
		if ( level.arrivals[ node_info ] > 4 )
		{
			level.arrivals[ node_info ] = 4;
		}
		vo_line = node_info + level.arrivals[ node_info ];
	}
	else
	{
		vo_line = node_info;
		if ( randomint( 100 ) > 75 )
		{
			vo_line = "bus_ride";
		}
	}
	if ( !isDefined( vo_line ) )
	{
		return;
	}
	if ( randomint( 100 ) < 25 )
	{
		valid_player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", vo_line );
	}
}

do_player_bus_zombie_vox( event, chance, timer )
{
	if ( isDefined( level.doing_bus_zombie_vox ) || level.doing_bus_zombie_vox && !isDefined( event ) )
	{
		return;
	}
	if ( !isDefined( chance ) )
	{
		chance = 100;
	}
	time = 30;
	if ( isDefined( timer ) )
	{
		time = timer;
	}
	players = get_players();
	players = array_randomize( players );
	valid_player = undefined;
	_a4374 = players;
	_k4374 = getFirstArrayKey( _a4374 );
	while ( isDefined( _k4374 ) )
	{
		player = _a4374[ _k4374 ];
		if ( isDefined( player.isonbus ) && player.isonbus )
		{
			valid_player = player;
			break;
		}
		else
		{
			_k4374 = getNextArrayKey( _a4374, _k4374 );
		}
	}
	if ( isDefined( valid_player ) )
	{
		valid_player thread do_player_general_vox( "general", event, time, chance );
		level.doing_bus_zombie_vox = 1;
		wait 10;
		level.doing_bus_zombie_vox = 0;
	}
}
