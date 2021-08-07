#include maps/mp/killstreaks/_supplydrop;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/gametypes/ctf;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/killstreaks/_rcbomb;
#include maps/mp/_tacticalinsertion;
#include maps/mp/_events;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	precachevehicle( "express_train_engine_mp" );
	precachemodel( "p6_bullet_train_car_phys" );
	precachemodel( "p6_bullet_train_engine_rev" );
	precacheshader( "compass_train_carriage" );
	precachestring( &"traincar" );
	precachestring( &"trainengine" );
	gates = getentarray( "train_gate_rail", "targetname" );
	brushes = getentarray( "train_gate_rail_brush", "targetname" );
	triggers = getentarray( "train_gate_kill_trigger", "targetname" );
	traintriggers = getentarray( "train_kill_trigger", "targetname" );
	_a22 = brushes;
	_k22 = getFirstArrayKey( _a22 );
	while ( isDefined( _k22 ) )
	{
		brush = _a22[ _k22 ];
		brush disconnectpaths();
		_k22 = getNextArrayKey( _a22, _k22 );
	}
	waittime = 0,05;
	_a28 = gates;
	_k28 = getFirstArrayKey( _a28 );
	while ( isDefined( _k28 ) )
	{
		gate = _a28[ _k28 ];
		gate.waittime = waittime;
		waittime += 0,05;
		gate.og_origin = gate.origin;
		brush = getclosest( gate.origin, brushes );
		brush linkto( gate );
		gate.kill_trigger = getclosest( gate.origin, triggers );
		if ( isDefined( gate.kill_trigger ) )
		{
			gate.kill_trigger enablelinkto();
			gate.kill_trigger linkto( gate );
		}
		_k28 = getNextArrayKey( _a28, _k28 );
	}
	start = getvehiclenode( "train_start", "targetname" );
	endgates = getentarray( "train_gate_rail_end", "targetname" );
	entrygate = getclosest( start.origin, endgates );
	i = 0;
	while ( i < endgates.size )
	{
		if ( endgates[ i ] == entrygate )
		{
			i++;
			continue;
		}
		else
		{
			exitgate = endgates[ i ];
			break;
		}
		i++;
	}
	cars = [];
	cars[ 0 ] = spawnvehicle( "p6_bullet_train_engine_phys", "train", "express_train_engine_mp", start.origin, ( 0, 0, 1 ) );
	cars[ 0 ] ghost();
	cars[ 0 ] setcheapflag( 1 );
	_a64 = traintriggers;
	_k64 = getFirstArrayKey( _a64 );
	while ( isDefined( _k64 ) )
	{
		traintrigger = _a64[ _k64 ];
		cars[ 0 ].trainkilltrigger = traintrigger;
		traintrigger.origin = start.origin;
		traintrigger enablelinkto();
		traintrigger linkto( cars[ 0 ] );
		_k64 = getNextArrayKey( _a64, _k64 );
	}
	i = 1;
	while ( i < 20 )
	{
		cars[ i ] = spawn( "script_model", start.origin );
		cars[ i ] setmodel( "p6_bullet_train_car_phys" );
		cars[ i ] ghost();
		cars[ i ] setcheapflag( 1 );
		i++;
	}
	cars[ 20 ] = spawn( "script_model", start.origin );
	cars[ 20 ] setmodel( "p6_bullet_train_engine_rev" );
	cars[ 20 ] ghost();
	cars[ 20 ] setcheapflag( 1 );
	if ( level.timelimit )
	{
		seconds = level.timelimit * 60;
		add_timed_event( int( seconds * 0,25 ), "train_start" );
		add_timed_event( int( seconds * 0,75 ), "train_start" );
	}
	else
	{
		if ( level.scorelimit )
		{
			add_score_event( int( level.scorelimit * 0,25 ), "train_start" );
			add_score_event( int( level.scorelimit * 0,75 ), "train_start" );
		}
	}
	level thread train_think( gates, entrygate, exitgate, cars, start );
}

showaftertime( time )
{
	wait time;
	self show();
}

train_think( gates, entrygate, exitgate, cars, start )
{
	level endon( "game_ended" );
	for ( ;; )
	{
		level waittill( "train_start" );
		entrygate gate_move( -172 );
		traintiming = getdvarfloatdefault( "scr_express_trainTiming", 4 );
		exitgate thread waitthenmove( traintiming, -172 );
		array_func( gates, ::gate_move, -172 );
		_a121 = gates;
		_k121 = getFirstArrayKey( _a121 );
		while ( isDefined( _k121 ) )
		{
			gate = _a121[ _k121 ];
			gate playloopsound( "amb_train_incomming_beep" );
			gate playsound( "amb_gate_move" );
			_k121 = getNextArrayKey( _a121, _k121 );
		}
		gatedownwait = getdvarintdefault( "scr_express_gateDownWait", 2 );
		wait gatedownwait;
		_a129 = gates;
		_k129 = getFirstArrayKey( _a129 );
		while ( isDefined( _k129 ) )
		{
			gate = _a129[ _k129 ];
			gate stoploopsound( 2 );
			_k129 = getNextArrayKey( _a129, _k129 );
		}
		wait 2;
		cars[ 0 ] attachpath( start );
		if ( isDefined( cars[ 0 ].trainkilltrigger ) )
		{
			cars[ 0 ] thread train_move_think( cars[ 0 ].trainkilltrigger );
		}
		cars[ 0 ] startpath();
		cars[ 0 ] showaftertime( 0,2 );
		cars[ 0 ] thread record_positions();
		cars[ 0 ] thread watch_end();
		cars[ 0 ] playloopsound( "amb_train_lp" );
		cars[ 0 ] setclientfield( "train_moving", 1 );
		next = "_b";
		i = 1;
		while ( i < cars.size )
		{
			if ( i == 1 )
			{
				wait 0,4;
			}
			else
			{
				wait 0,35;
			}
			if ( i >= 3 && ( i % 3 ) == 0 )
			{
				cars[ i ] playloopsound( "amb_train_lp" + next );
				switch( next )
				{
					case "_b":
						next = "_c";
						break;
					break;
					case "_c":
						next = "_d";
						break;
					break;
					case "_d":
						next = "";
						break;
					break;
					default:
						next = "_b";
						break;
					break;
				}
			}
			cars[ i ] thread watch_player_touch();
			if ( i == ( cars.size - 1 ) )
			{
				cars[ i ] thread car_move();
				i++;
				continue;
			}
			else
			{
				cars[ i ] thread car_move();
			}
			i++;
		}
		traintiming = getdvarfloatdefault( "scr_express_trainTiming2", 2 );
		entrygate thread waitthenmove( traintiming );
		gateupwait = getdvarfloatdefault( "scr_express_gateUpWait", 6,5 );
		wait gateupwait;
		exitgate gate_move();
		array_func( gates, ::gate_move );
		_a205 = gates;
		_k205 = getFirstArrayKey( _a205 );
		while ( isDefined( _k205 ) )
		{
			gate = _a205[ _k205 ];
			gate playsound( "amb_gate_move" );
			_k205 = getNextArrayKey( _a205, _k205 );
		}
		wait 6;
	}
}

waitthenmove( time, distance )
{
	wait time;
	self gate_move( distance );
}

record_positions()
{
	self endon( "reached_end_node" );
	if ( isDefined( level.train_positions ) )
	{
		return;
	}
	level.train_positions = [];
	level.train_angles = [];
	for ( ;; )
	{
		level.train_positions[ level.train_positions.size ] = self.origin;
		level.train_angles[ level.train_angles.size ] = self.angles;
		wait 0,05;
	}
}

watch_player_touch()
{
	self endon( "end_of_track" );
	self endon( "delete" );
	self endon( "death" );
	for ( ;; )
	{
		self waittill( "touch", entity );
		if ( isplayer( entity ) )
		{
			entity dodamage( entity.health * 2, self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
		}
	}
}

watch_end()
{
	self waittill( "reached_end_node" );
	self ghost();
	self setclientfield( "train_moving", 0 );
	self stoploopsound( 0,2 );
	self playsound( "amb_train_end" );
}

car_move()
{
	self setclientfield( "train_moving", 1 );
	i = 0;
	while ( i < level.train_positions.size )
	{
		self.origin = level.train_positions[ i ];
		self.angles = level.train_angles[ i ];
		wait 0,05;
		if ( i == 4 )
		{
			self show();
		}
		i++;
	}
	self notify( "end_of_track" );
	self ghost();
	self setclientfield( "train_moving", 0 );
	self stoploopsound( 0,2 );
	self playsound( "amb_train_end" );
}

gate_rotate( yaw )
{
	self rotateyaw( yaw, 5 );
}

gate_move( z_dist )
{
	if ( isDefined( self.kill_trigger ) )
	{
		self thread gate_move_think( isDefined( z_dist ) );
	}
	if ( !isDefined( z_dist ) )
	{
		self moveto( self.og_origin, 5 );
	}
	else
	{
		self.og_origin = self.origin;
		self movez( z_dist, 5 );
	}
}

train_move_think( kill_trigger )
{
	self endon( "movedone" );
	for ( ;; )
	{
		wait 0,05;
		pixbeginevent( "train_move_think" );
		entities = getdamageableentarray( self.origin, 200 );
		_a327 = entities;
		_k327 = getFirstArrayKey( _a327 );
		while ( isDefined( _k327 ) )
		{
			entity = _a327[ _k327 ];
			if ( isDefined( entity.targetname ) && entity.targetname == "train" )
			{
			}
			else
			{
				if ( isplayer( entity ) )
				{
					break;
				}
				else if ( !entity istouching( kill_trigger ) )
				{
					break;
				}
				else if ( isDefined( entity.model ) && entity.model == "t6_wpn_tac_insert_world" )
				{
					entity maps/mp/_tacticalinsertion::destroy_tactical_insertion();
					break;
				}
				else
				{
					if ( !isalive( entity ) )
					{
						break;
					}
					else if ( isDefined( entity.targetname ) )
					{
						if ( entity.targetname == "talon" )
						{
							entity notify( "death" );
							break;
						}
						else if ( entity.targetname == "rcbomb" )
						{
							entity maps/mp/killstreaks/_rcbomb::rcbomb_force_explode();
							break;
						}
						else if ( entity.targetname == "riotshield_mp" )
						{
							entity dodamage( 1, self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
							break;
						}
					}
					else if ( isDefined( entity.helitype ) && entity.helitype == "qrdrone" )
					{
						watcher = entity.owner maps/mp/gametypes/_weaponobjects::getweaponobjectwatcher( "qrdrone" );
						watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( entity, 0, undefined );
						break;
					}
					else
					{
						if ( entity.classname == "grenade" )
						{
							if ( !isDefined( entity.name ) )
							{
								break;
							}
							else if ( !isDefined( entity.owner ) )
							{
								break;
							}
							else if ( entity.name == "proximity_grenade_mp" )
							{
								watcher = entity.owner getwatcherforweapon( entity.name );
								watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( entity, 0, undefined, "script_mover_mp" );
								break;
							}
							else if ( !isweaponequipment( entity.name ) )
							{
								break;
							}
							else watcher = entity.owner getwatcherforweapon( entity.name );
							if ( !isDefined( watcher ) )
							{
								break;
							}
							else watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( entity, 0, undefined, "script_mover_mp" );
							break;
						}
						else if ( entity.classname == "auto_turret" )
						{
							if ( !isDefined( entity.damagedtodeath ) || !entity.damagedtodeath )
							{
								entity domaxdamage( self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
							}
							break;
						}
						else
						{
							entity dodamage( entity.health * 2, self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
						}
					}
				}
			}
			_k327 = getNextArrayKey( _a327, _k327 );
		}
		self destroy_supply_crates();
		if ( level.gametype == "ctf" )
		{
			_a434 = level.flags;
			_k434 = getFirstArrayKey( _a434 );
			while ( isDefined( _k434 ) )
			{
				flag = _a434[ _k434 ];
				if ( flag.curorigin != flag.trigger.baseorigin && flag.visuals[ 0 ] istouching( kill_trigger ) )
				{
					flag maps/mp/gametypes/ctf::returnflag();
				}
				_k434 = getNextArrayKey( _a434, _k434 );
			}
		}
		else if ( level.gametype == "sd" && !level.multibomb )
		{
			if ( level.sdbomb.visuals[ 0 ] istouching( kill_trigger ) )
			{
				level.sdbomb maps/mp/gametypes/_gameobjects::returnhome();
			}
		}
		pixendevent();
	}
}

gate_move_think( ignoreplayers )
{
	self endon( "movedone" );
	corpse_delay = 0;
	if ( isDefined( self.waittime ) )
	{
		wait self.waittime;
	}
	for ( ;; )
	{
		wait 0,4;
		pixbeginevent( "gate_move_think" );
		entities = getdamageableentarray( self.origin, 100 );
		_a473 = entities;
		_k473 = getFirstArrayKey( _a473 );
		while ( isDefined( _k473 ) )
		{
			entity = _a473[ _k473 ];
			if ( ignoreplayers == 1 && isplayer( entity ) )
			{
			}
			else
			{
				if ( !entity istouching( self.kill_trigger ) )
				{
					break;
				}
				else if ( isDefined( entity.model ) && entity.model == "t6_wpn_tac_insert_world" )
				{
					entity maps/mp/_tacticalinsertion::destroy_tactical_insertion();
					break;
				}
				else
				{
					if ( !isalive( entity ) )
					{
						break;
					}
					else if ( isDefined( entity.targetname ) )
					{
						if ( entity.targetname == "talon" )
						{
							entity notify( "death" );
							break;
						}
						else if ( entity.targetname == "rcbomb" )
						{
							entity maps/mp/killstreaks/_rcbomb::rcbomb_force_explode();
							break;
						}
						else if ( entity.targetname == "riotshield_mp" )
						{
							entity dodamage( 1, self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
							break;
						}
					}
					else if ( isDefined( entity.helitype ) && entity.helitype == "qrdrone" )
					{
						watcher = entity.owner maps/mp/gametypes/_weaponobjects::getweaponobjectwatcher( "qrdrone" );
						watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( entity, 0, undefined );
						break;
					}
					else
					{
						if ( entity.classname == "grenade" )
						{
							if ( !isDefined( entity.name ) )
							{
								break;
							}
							else if ( !isDefined( entity.owner ) )
							{
								break;
							}
							else if ( entity.name == "proximity_grenade_mp" )
							{
								watcher = entity.owner getwatcherforweapon( entity.name );
								watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( entity, 0, undefined, "script_mover_mp" );
								break;
							}
							else if ( !isweaponequipment( entity.name ) )
							{
								break;
							}
							else watcher = entity.owner getwatcherforweapon( entity.name );
							if ( !isDefined( watcher ) )
							{
								break;
							}
							else watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( entity, 0, undefined, "script_mover_mp" );
							break;
						}
						else if ( entity.classname == "auto_turret" )
						{
							if ( !isDefined( entity.damagedtodeath ) || !entity.damagedtodeath )
							{
								entity domaxdamage( self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
							}
							break;
						}
						else
						{
							entity dodamage( entity.health * 2, self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
						}
					}
				}
			}
			_k473 = getNextArrayKey( _a473, _k473 );
		}
		self destroy_supply_crates();
		if ( getTime() > corpse_delay )
		{
			self destroy_corpses();
		}
		if ( level.gametype == "ctf" )
		{
			_a578 = level.flags;
			_k578 = getFirstArrayKey( _a578 );
			while ( isDefined( _k578 ) )
			{
				flag = _a578[ _k578 ];
				if ( flag.visuals[ 0 ] istouching( self.kill_trigger ) )
				{
					flag maps/mp/gametypes/ctf::returnflag();
				}
				_k578 = getNextArrayKey( _a578, _k578 );
			}
		}
		else if ( level.gametype == "sd" && !level.multibomb )
		{
			if ( level.sdbomb.visuals[ 0 ] istouching( self.kill_trigger ) )
			{
				level.sdbomb maps/mp/gametypes/_gameobjects::returnhome();
			}
		}
		pixendevent();
	}
}

getwatcherforweapon( weapname )
{
	if ( !isDefined( self ) )
	{
		return undefined;
	}
	if ( !isplayer( self ) )
	{
		return undefined;
	}
	i = 0;
	while ( i < self.weaponobjectwatcherarray.size )
	{
		if ( self.weaponobjectwatcherarray[ i ].weapon != weapname )
		{
			i++;
			continue;
		}
		else
		{
			return self.weaponobjectwatcherarray[ i ];
		}
		i++;
	}
	return undefined;
}

destroy_supply_crates()
{
	crates = getentarray( "care_package", "script_noteworthy" );
	_a628 = crates;
	_k628 = getFirstArrayKey( _a628 );
	while ( isDefined( _k628 ) )
	{
		crate = _a628[ _k628 ];
		if ( distancesquared( crate.origin, self.origin ) < 10000 )
		{
			if ( crate istouching( self ) )
			{
				playfx( level._supply_drop_explosion_fx, crate.origin );
				playsoundatposition( "wpn_grenade_explode", crate.origin );
				wait 0,1;
				crate maps/mp/killstreaks/_supplydrop::cratedelete();
			}
		}
		_k628 = getNextArrayKey( _a628, _k628 );
	}
}

destroy_corpses()
{
	corpses = getcorpsearray();
	i = 0;
	while ( i < corpses.size )
	{
		if ( distancesquared( corpses[ i ].origin, self.origin ) < 10000 )
		{
			corpses[ i ] delete();
		}
		i++;
	}
}
