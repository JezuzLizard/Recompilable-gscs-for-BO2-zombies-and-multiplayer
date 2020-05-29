#include maps/mp/killstreaks/_supplydrop;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/gametypes/ctf;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/killstreaks/_rcbomb;
#include maps/mp/_tacticalinsertion;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	precachemodel( "p6_dockside_container_lrg_white" );
	crane_dvar_init();
	level.crate_models = [];
	level.crate_models[ 0 ] = "p6_dockside_container_lrg_red";
	level.crate_models[ 1 ] = "p6_dockside_container_lrg_blue";
	level.crate_models[ 2 ] = "p6_dockside_container_lrg_white";
	level.crate_models[ 3 ] = "p6_dockside_container_lrg_orange";
	claw = getent( "claw_base", "targetname" );
	claw.z_upper = claw.origin[ 2 ];
	claw thread sound_wires_move();
	arms_y = getentarray( "claw_arm_y", "targetname" );
	arms_z = getentarray( "claw_arm_z", "targetname" );
	claw.arms = arraycombine( arms_y, arms_z, 1, 0 );
	_a32 = arms_z;
	_k32 = getFirstArrayKey( _a32 );
	while ( isDefined( _k32 ) )
	{
		arm_z = _a32[ _k32 ];
		arm_y = getclosest( arm_z.origin, arms_y );
		arm_z.parent = arm_y;
		_k32 = getNextArrayKey( _a32, _k32 );
	}
	_a39 = arms_y;
	_k39 = getFirstArrayKey( _a39 );
	while ( isDefined( _k39 ) )
	{
		arm_y = _a39[ _k39 ];
		arm_y.parent = claw;
		_k39 = getNextArrayKey( _a39, _k39 );
	}
	claw claw_link_arms( "claw_arm_y" );
	claw claw_link_arms( "claw_arm_z" );
	crates = getentarray( "crate", "targetname" );
	array_thread( crates, ::sound_pit_move );
	crate_data = [];
	i = 0;
	while ( i < crates.size )
	{
		crates[ i ] disconnectpaths();
		data = spawnstruct();
		data.origin = crates[ i ].origin;
		data.angles = crates[ i ].angles;
		crate_data[ i ] = data;
		i++;
	}
	rail = getent( "crane_rail", "targetname" );
	rail thread sound_ring_move();
	rail.roller = getent( "crane_roller", "targetname" );
	rail.roller.wheel = getent( "crane_wheel", "targetname" );
	claw.wires = getentarray( "crane_wire", "targetname" );
	claw.z_wire_max = rail.roller.wheel.origin[ 2 ] - 50;
	_a73 = claw.wires;
	_k73 = getFirstArrayKey( _a73 );
	while ( isDefined( _k73 ) )
	{
		wire = _a73[ _k73 ];
		wire linkto( claw );
		if ( wire.origin[ 2 ] > claw.z_wire_max )
		{
			wire ghost();
		}
		_k73 = getNextArrayKey( _a73, _k73 );
	}
	placements = getentarray( "crate_placement", "targetname" );
	_a85 = placements;
	_k85 = getFirstArrayKey( _a85 );
	while ( isDefined( _k85 ) )
	{
		placement = _a85[ _k85 ];
		placement.angles += vectorScale( ( 0, 0, 1 ), 90 );
		crates[ crates.size ] = spawn( "script_model", placement.origin );
		_k85 = getNextArrayKey( _a85, _k85 );
	}
	triggers = getentarray( "crate_kill_trigger", "targetname" );
	_a93 = crates;
	_k93 = getFirstArrayKey( _a93 );
	while ( isDefined( _k93 ) )
	{
		crate = _a93[ _k93 ];
		crate.kill_trigger = getclosest( crate.origin, triggers );
		crate.kill_trigger.origin = crate.origin - vectorScale( ( 0, 0, 1 ), 5 );
		crate.kill_trigger enablelinkto();
		crate.kill_trigger linkto( crate );
		if ( crate.model != "" )
		{
			crate.kill_trigger.active = 1;
		}
		else
		{
			crate.kill_trigger.active = 0;
		}
		_k93 = getNextArrayKey( _a93, _k93 );
	}
	trigger = getclosest( claw.origin, triggers );
	trigger enablelinkto();
	trigger linkto( claw );
	trigger.active = 1;
	placements = array_randomize( placements );
	level thread crane_think( claw, rail, crates, crate_data, placements );
}

crane_dvar_init()
{
	set_dvar_float_if_unset( "scr_crane_claw_move_time", "5" );
	set_dvar_float_if_unset( "scr_crane_crate_lower_time", "5" );
	set_dvar_float_if_unset( "scr_crane_crate_raise_time", "5" );
	set_dvar_float_if_unset( "scr_crane_arm_y_move_time", "3" );
	set_dvar_float_if_unset( "scr_crane_arm_z_move_time", "3" );
	set_dvar_float_if_unset( "scr_crane_claw_drop_speed", "25" );
	set_dvar_float_if_unset( "scr_crane_claw_drop_time_min", "5" );
}

wire_render()
{
	self endon( "movedone" );
	for ( ;; )
	{
		wait 0,05;
		_a139 = self.wires;
		_k139 = getFirstArrayKey( _a139 );
		while ( isDefined( _k139 ) )
		{
			wire = _a139[ _k139 ];
			if ( wire.origin[ 2 ] > self.z_wire_max )
			{
				wire ghost();
			}
			else
			{
				wire show();
			}
			_k139 = getNextArrayKey( _a139, _k139 );
		}
	}
}

crane_think( claw, rail, crates, crate_data, placements )
{
	wait 1;
	claw arms_open();
	for ( ;; )
	{
		i = 0;
		while ( i < ( crates.size - placements.size ) )
		{
			crate = getclosest( crate_data[ i ].origin, crates );
			rail crane_move( claw, crate_data[ i ], -318 );
			level notify( "wires_move" );
			claw claw_crate_grab( crate, 318 );
			lower = 1;
			target = ( i + 1 ) % ( crates.size - placements.size );
			target_crate = getclosest( crate_data[ target ].origin, crates );
			while ( cointoss() )
			{
				placement_index = 0;
				while ( placement_index < placements.size )
				{
					placement = placements[ placement_index ];
					if ( !isDefined( placement.crate ) )
					{
						lower = 0;
						break;
					}
					else
					{
						placement_index++;
					}
				}
			}
			if ( !lower )
			{
				z_dist = crate.origin[ 2 ] - placement.origin[ 2 ] - 33;
				rail crane_move( claw, placement, z_dist * -1 );
				level notify( "wires_move" );
				placement.crate = crate;
			}
			else
			{
				rail crane_move( claw, crate_data[ target ], -181 );
				level notify( "wires_move" );
			}
			claw claw_crate_move( crate );
			if ( lower )
			{
				crate crate_lower( target_crate, crate_data[ target ] );
			}
			crate = target_crate;
			target = ( i + 2 ) % ( crates.size - placements.size );
			target_crate = getclosest( crate_data[ target ].origin, crates );
			if ( !lower )
			{
				crate = crates[ 3 + placement_index ];
				crate.origin = target_crate.origin - vectorScale( ( 0, 0, 1 ), 137 );
				crate.angles = target_crate.angles;
				wait 0,25;
				claw waittill( "movedone" );
			}
			crate crate_raise( target_crate, crate_data[ target ] );
			rail crane_move( claw, crate_data[ target ], -181 );
			level notify( "wires_move" );
			claw claw_crate_grab( target_crate, 181 );
			crate = target_crate;
			target = ( i + 3 ) % ( crates.size - placements.size );
			rail crane_move( claw, crate_data[ target ], -318 );
			level notify( "wires_move" );
			claw claw_crate_drop( crate, crate_data[ target ] );
			i++;
		}
	}
}

crane_move( claw, desired, z_dist )
{
	self.roller linkto( self );
	self.roller.wheel linkto( self.roller );
	claw linkto( self.roller.wheel );
	goal = ( desired.origin[ 0 ], desired.origin[ 1 ], self.origin[ 2 ] );
	dir = vectornormalize( goal - self.origin );
	angles = vectorToAngle( dir );
	angles = ( self.angles[ 0 ], angles[ 1 ] + 90, self.angles[ 2 ] );
	yawdiff = absangleclamp360( self.angles[ 1 ] - angles[ 1 ] );
	time = yawdiff / 25;
	self rotateto( angles, time, time * 0,35, time * 0,45 );
	self thread physics_move();
	level notify( "wires_stop" );
	level notify( "ring_move" );
	self waittill( "rotatedone" );
	self.roller unlink();
	goal = ( desired.origin[ 0 ], desired.origin[ 1 ], self.roller.origin[ 2 ] );
	diff = distance2d( goal, self.roller.origin );
	speed = getDvarFloat( #"C39D2ABF" );
	time = diff / speed;
	if ( time < getDvarFloat( #"F60036C0" ) )
	{
		time = getDvarFloat( #"F60036C0" );
	}
	self.roller moveto( goal, time, time * 0,25, time * 0,25 );
	self.roller thread physics_move();
	goal = ( desired.origin[ 0 ], desired.origin[ 1 ], self.roller.wheel.origin[ 2 ] );
	self.roller.wheel unlink();
	self.roller.wheel moveto( goal, time, time * 0,25, time * 0,25 );
	self.roller.wheel rotateto( desired.angles + vectorScale( ( 0, 0, 1 ), 90 ), time, time * 0,25, time * 0,25 );
	claw.z_initial = claw.origin[ 2 ];
	claw unlink();
	claw rotateto( desired.angles, time, time * 0,25, time * 0,25 );
	claw.goal = ( goal[ 0 ], goal[ 1 ], claw.origin[ 2 ] + z_dist );
	claw.time = time;
	claw moveto( claw.goal, time, time * 0,25, time * 0,25 );
	level notify( "ring_stop" );
}

physics_move()
{
	self endon( "rotatedone" );
	self endon( "movedone" );
	for ( ;; )
	{
		wait 0,05;
		crates = getentarray( "care_package", "script_noteworthy" );
		_a318 = crates;
		_k318 = getFirstArrayKey( _a318 );
		while ( isDefined( _k318 ) )
		{
			crate = _a318[ _k318 ];
			if ( crate istouching( self ) )
			{
				crate physicslaunch( crate.origin, ( 0, 0, 1 ) );
			}
			_k318 = getNextArrayKey( _a318, _k318 );
		}
	}
}

claw_crate_grab( crate, z_dist )
{
	self thread wire_render();
	self waittill( "movedone" );
	level notify( "wires_stop" );
	self playsound( "amb_crane_arms_b" );
	self claw_z_arms( -33 );
	self playsound( "amb_crane_arms" );
	self arms_close( crate );
	crate movez( 33, getDvarFloat( #"92CC26F1" ) );
	self claw_z_arms( 33 );
	crate linkto( self );
	self movez( z_dist, getDvarFloat( #"33ED9F5F" ) );
	self thread wire_render();
	level notify( "wires_move" );
	self waittill( "movedone" );
	self playsound( "amb_crane_arms" );
}

sound_wires_move()
{
	while ( 1 )
	{
		level waittill( "wires_move" );
		self playsound( "amb_crane_wire_start" );
		self playloopsound( "amb_crane_wire_lp" );
		level waittill( "wires_stop" );
		self playsound( "amb_crane_wire_end" );
		wait 0,1;
		self stoploopsound( 0,2 );
	}
}

sound_ring_move()
{
	while ( 1 )
	{
		level waittill( "ring_move" );
		self playsound( "amb_crane_ring_start" );
		self playloopsound( "amb_crane_ring_lp" );
		level waittill( "ring_stop" );
		self playsound( "amb_crane_ring_end" );
		wait 0,1;
		self stoploopsound( 0,2 );
	}
}

sound_pit_move()
{
	while ( 1 )
	{
		level waittill( "pit_move" );
		self playsound( "amb_crane_pit_start" );
		self playloopsound( "amb_crane_pit_lp" );
		level waittill( "pit_stop" );
		self playsound( "amb_crane_pit_end" );
		self stoploopsound( 0,2 );
		wait 0,2;
	}
}

claw_crate_move( crate, claw )
{
	self thread wire_render();
	self waittill( "movedone" );
	crate unlink();
	self playsound( "amb_crane_arms_b" );
	level notify( "wires_stop" );
	crate movez( -33, getDvarFloat( #"92CC26F1" ) );
	self claw_z_arms( -33 );
	self playsound( "amb_crane_arms_b" );
	playfxontag( level._effect[ "crane_dust" ], crate, "tag_origin" );
	crate playsound( "amb_crate_drop" );
	self arms_open();
	level notify( "wires_move" );
	self claw_z_arms( 33 );
	z_dist = self.z_initial - self.origin[ 2 ];
	self movez( z_dist, getDvarFloat( #"33ED9F5F" ) );
	self thread wire_render();
}

claw_crate_drop( target, data )
{
	target thread crate_drop_think( self );
	self thread wire_render();
	self waittill( "claw_movedone" );
	target unlink();
	level notify( "wires_stop" );
	self playsound( "amb_crane_arms_b" );
	target movez( -33, getDvarFloat( #"92CC26F1" ) );
	self claw_z_arms( -33 );
	playfxontag( level._effect[ "crane_dust" ], target, "tag_origin" );
	self playsound( "amb_crate_drop" );
	target notify( "claw_done" );
	self playsound( "amb_crane_arms" );
	self arms_open();
	level notify( "wires_move" );
	target.origin = data.origin;
	self claw_z_arms( 33 );
	self playsound( "amb_crane_arms" );
	self movez( 318, getDvarFloat( #"33ED9F5F" ) );
	self thread wire_render();
	self waittill( "movedone" );
}

crate_lower( lower, data )
{
	z_dist = abs( self.origin[ 2 ] - lower.origin[ 2 ] );
	self movez( z_dist * -1, getDvarFloat( #"CFA0F999" ) );
	lower movez( z_dist * -1, getDvarFloat( #"CFA0F999" ) );
	level notify( "pit_move" );
	lower waittill( "movedone" );
	level notify( "pit_stop" );
	lower ghost();
	self.origin = data.origin;
	wait 0,25;
}

crate_raise( upper, data )
{
	self crate_set_random_model( upper );
	self.kill_trigger.active = 1;
	self.origin = ( data.origin[ 0 ], data.origin[ 1 ], self.origin[ 2 ] );
	self.angles = data.angles;
	wait 0,2;
	self show();
	z_dist = abs( upper.origin[ 2 ] - self.origin[ 2 ] );
	self movez( z_dist, getDvarFloat( #"B4D4D064" ) );
	upper movez( z_dist, getDvarFloat( #"B4D4D064" ) );
	level notify( "wires_stop" );
	level notify( "pit_move" );
	upper thread raise_think();
}

raise_think()
{
	self waittill( "movedone" );
	level notify( "pit_stop" );
}

crate_set_random_model( other )
{
	models = array_randomize( level.crate_models );
	_a513 = models;
	_k513 = getFirstArrayKey( _a513 );
	while ( isDefined( _k513 ) )
	{
		model = _a513[ _k513 ];
		if ( model == other.model )
		{
		}
		else
		{
			self setmodel( model );
			return;
		}
		_k513 = getNextArrayKey( _a513, _k513 );
	}
}

arms_open()
{
	self claw_move_arms( -15 );
	self playsound( "amb_crane_arms" );
}

arms_close( crate )
{
	self claw_move_arms( 15, crate );
	self playsound( "amb_crane_arms" );
}

claw_link_arms( name )
{
	_a541 = self.arms;
	_k541 = getFirstArrayKey( _a541 );
	while ( isDefined( _k541 ) )
	{
		arm = _a541[ _k541 ];
		if ( arm.targetname == name )
		{
			arm linkto( arm.parent );
		}
		_k541 = getNextArrayKey( _a541, _k541 );
	}
}

claw_unlink_arms( name )
{
	_a552 = self.arms;
	_k552 = getFirstArrayKey( _a552 );
	while ( isDefined( _k552 ) )
	{
		arm = _a552[ _k552 ];
		if ( arm.targetname == name )
		{
			arm unlink();
		}
		_k552 = getNextArrayKey( _a552, _k552 );
	}
}

claw_move_arms( dist, crate )
{
	claw_unlink_arms( "claw_arm_y" );
	arms = [];
	_a566 = self.arms;
	_k566 = getFirstArrayKey( _a566 );
	while ( isDefined( _k566 ) )
	{
		arm = _a566[ _k566 ];
		forward = anglesToForward( arm.angles );
		arm.goal = arm.origin + vectorScale( forward, dist );
		if ( arm.targetname == "claw_arm_y" )
		{
			arms[ arms.size ] = arm;
			arm moveto( arm.goal, getDvarFloat( #"0D6F71B0" ) );
		}
		_k566 = getNextArrayKey( _a566, _k566 );
	}
	if ( dist > 0 )
	{
		wait ( getDvarFloat( #"0D6F71B0" ) / 2 );
		_a582 = self.arms;
		_k582 = getFirstArrayKey( _a582 );
		while ( isDefined( _k582 ) )
		{
			arm = _a582[ _k582 ];
			if ( arm.targetname == "claw_arm_y" )
			{
				arm moveto( arm.goal, 0,1 );
				self playsound( "amb_crane_arms_b" );
			}
			_k582 = getNextArrayKey( _a582, _k582 );
		}
		wait 0,05;
		playfxontag( level._effect[ "crane_spark" ], crate, "tag_origin" );
		self playsound( "amb_arms_latch" );
	}
/#
	assert( arms.size == 4 );
#/
	waittill_multiple_ents( arms[ 0 ], "movedone", arms[ 1 ], "movedone", arms[ 2 ], "movedone", arms[ 3 ], "movedone" );
	_a600 = self.arms;
	_k600 = getFirstArrayKey( _a600 );
	while ( isDefined( _k600 ) )
	{
		arm = _a600[ _k600 ];
		arm.origin = arm.goal;
		_k600 = getNextArrayKey( _a600, _k600 );
	}
	self claw_link_arms( "claw_arm_y" );
}

claw_z_arms( z )
{
	claw_unlink_arms( "claw_arm_z" );
	arms = [];
	_a613 = self.arms;
	_k613 = getFirstArrayKey( _a613 );
	while ( isDefined( _k613 ) )
	{
		arm = _a613[ _k613 ];
		if ( arm.targetname == "claw_arm_z" )
		{
			arms[ arms.size ] = arm;
			arm movez( z, getDvarFloat( #"92CC26F1" ) );
		}
		_k613 = getNextArrayKey( _a613, _k613 );
	}
/#
	assert( arms.size == 4 );
#/
	waittill_multiple_ents( arms[ 0 ], "movedone", arms[ 1 ], "movedone", arms[ 2 ], "movedone", arms[ 3 ], "movedone" );
	self claw_link_arms( "claw_arm_z" );
}

crate_drop_think( claw )
{
	self endon( "claw_done" );
	self.disablefinalkillcam = 1;
	claw thread claw_drop_think();
	corpse_delay = 0;
	for ( ;; )
	{
		wait 0,2;
		entities = getdamageableentarray( self.origin, 200 );
		_a642 = entities;
		_k642 = getFirstArrayKey( _a642 );
		while ( isDefined( _k642 ) )
		{
			entity = _a642[ _k642 ];
			if ( !entity istouching( self.kill_trigger ) )
			{
			}
			else if ( isDefined( entity.model ) && entity.model == "t6_wpn_tac_insert_world" )
			{
				entity maps/mp/_tacticalinsertion::destroy_tactical_insertion();
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
						if ( isplayer( entity ) )
						{
							claw thread claw_drop_pause();
							corpse_delay = getTime() + 3000;
						}
					}
				}
			}
			_k642 = getNextArrayKey( _a642, _k642 );
		}
		self destroy_supply_crates();
		if ( getTime() > corpse_delay )
		{
			self destroy_corpses();
		}
		if ( level.gametype == "ctf" )
		{
			_a748 = level.flags;
			_k748 = getFirstArrayKey( _a748 );
			while ( isDefined( _k748 ) )
			{
				flag = _a748[ _k748 ];
				if ( flag.visuals[ 0 ] istouching( self.kill_trigger ) )
				{
					flag maps/mp/gametypes/ctf::returnflag();
				}
				_k748 = getNextArrayKey( _a748, _k748 );
			}
		}
		else if ( level.gametype == "sd" && !level.multibomb )
		{
			if ( level.sdbomb.visuals[ 0 ] istouching( self.kill_trigger ) )
			{
				level.sdbomb maps/mp/gametypes/_gameobjects::returnhome();
			}
		}
	}
}

claw_drop_think()
{
	self endon( "claw_pause" );
	self waittill( "movedone" );
	self notify( "claw_movedone" );
}

claw_drop_pause()
{
	self notify( "claw_pause" );
	self endon( "claw_pause" );
	z_diff = abs( self.goal[ 2 ] - self.origin[ 2 ] );
	frac = z_diff / 318;
	time = self.time * frac;
	if ( time <= 0 )
	{
		return;
	}
	self moveto( self.origin, 0,01 );
	wait 3;
	self thread claw_drop_think();
	self moveto( self.goal, time );
}

destroy_supply_crates()
{
	crates = getentarray( "care_package", "script_noteworthy" );
	_a802 = crates;
	_k802 = getFirstArrayKey( _a802 );
	while ( isDefined( _k802 ) )
	{
		crate = _a802[ _k802 ];
		if ( distancesquared( crate.origin, self.origin ) < 40000 )
		{
			if ( crate istouching( self ) )
			{
				playfx( level._supply_drop_explosion_fx, crate.origin );
				playsoundatposition( "wpn_grenade_explode", crate.origin );
				wait 0,1;
				crate maps/mp/killstreaks/_supplydrop::cratedelete();
			}
		}
		_k802 = getNextArrayKey( _a802, _k802 );
	}
}

destroy_corpses()
{
	corpses = getcorpsearray();
	i = 0;
	while ( i < corpses.size )
	{
		if ( distancesquared( corpses[ i ].origin, self.origin ) < 40000 )
		{
			corpses[ i ] delete();
		}
		i++;
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
