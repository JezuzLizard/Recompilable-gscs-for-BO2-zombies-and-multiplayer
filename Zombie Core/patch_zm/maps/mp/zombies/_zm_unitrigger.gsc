#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked changed to match cerberus output
{
	level._unitriggers = spawnstruct();
	level._unitriggers._deferredinitlist = [];
	level._unitriggers.trigger_pool = [];
	level._unitriggers.trigger_stubs = [];
	level._unitriggers.dynamic_stubs = [];
	level._unitriggers.system_trigger_funcs = [];
	level._unitriggers.largest_radius = 64;
	stubs_keys = array( "unitrigger_radius", "unitrigger_radius_use", "unitrigger_box", "unitrigger_box_use" );
	stubs = [];
	for ( i = 0; i < stubs_keys.size; i++ )
	{
		stubs = arraycombine( stubs, getstructarray( stubs_keys[ i ], "script_unitrigger_type" ), 1, 0 );
	}
	for ( i = 0; i < stubs.size; i++ )
	{
		register_unitrigger( stubs[ i ] );
	}
}

register_unitrigger_system_func( system, trigger_func ) //checked matches cerberus output
{
	level._unitriggers.system_trigger_funcs[ system ] = trigger_func;
}

unitrigger_force_per_player_triggers( unitrigger_stub, opt_on_off ) //checked matches cerberus output
{
	if ( !isDefined( opt_on_off ) )
	{
		opt_on_off = 1;
	}
	unitrigger_stub.trigger_per_player = opt_on_off;
}

unitrigger_trigger( player ) //checked matches cerberus output
{
	if ( self.trigger_per_player )
	{
		return self.playertrigger[ player getentitynumber() ];
	}
	else
	{
		return self.trigger;
	}
}

unitrigger_origin() //checked matches cerberus output
{
	if ( isDefined( self.originfunc ) )
	{
		origin = self [[ self.originfunc ]]();
	}
	else
	{
		origin = self.origin;
	}
	return origin;
}

register_unitrigger_internal( unitrigger_stub, trigger_func ) //checked changed to match cerberus output
{
	if ( !isDefined( unitrigger_stub.script_unitrigger_type ) )
	{
		/*
/#
		println( "Cannot register a unitrigger with no script_unitrigger_type.  Ignoring." );
#/
		*/
		return;
	}
	if ( isDefined( trigger_func ) )
	{
		unitrigger_stub.trigger_func = trigger_func;
	}
	else if ( isDefined( unitrigger_stub.unitrigger_system ) && isDefined( level._unitriggers.system_trigger_funcs[ unitrigger_stub.unitrigger_system ] ) )
	{
		unitrigger_stub.trigger_func = level._unitriggers.system_trigger_funcs[ unitrigger_stub.unitrigger_system ];
	}
	switch( unitrigger_stub.script_unitrigger_type )
	{
		case "unitrigger_radius":
		case "unitrigger_radius_use":
			if ( !isDefined( unitrigger_stub.radius ) )
			{
				unitrigger_stub.radius = 32;
			}
			if ( !isDefined( unitrigger_stub.script_height ) )
			{
				unitrigger_stub.script_height = 64;
			}
			unitrigger_stub.test_radius_sq = ( unitrigger_stub.radius + 15 ) * ( unitrigger_stub.radius + 15 );
			break;
		case "unitrigger_box":
		case "unitrigger_box_use":
			if ( !isDefined( unitrigger_stub.script_width ) )
			{
				unitrigger_stub.script_width = 64;
			}
			if ( !isDefined( unitrigger_stub.script_height ) )
			{
				unitrigger_stub.script_height = 64;
			}
			if ( !isDefined( unitrigger_stub.script_length ) )
			{
				unitrigger_stub.script_length = 64;
			}
			box_radius = length( ( unitrigger_stub.script_width / 2, unitrigger_stub.script_length / 2, unitrigger_stub.script_height / 2 ) );
			if ( !isDefined( unitrigger_stub.radius ) || unitrigger_stub.radius < box_radius )
			{
				unitrigger_stub.radius = box_radius;
			}
			unitrigger_stub.test_radius_sq = ( box_radius + 15 ) * ( box_radius + 15 );
			break;
		default:
			/*
/#
			println( "Unknown unitrigger type registered : " + unitrigger_stub.targetname + " - ignoring." );
#/
			*/
			return;
	}
	if ( unitrigger_stub.radius > level._unitriggers.largest_radius )
	{
		level._unitriggers.largest_radius = min( 113, unitrigger_stub.radius );
		if ( isDefined( level.fixed_max_player_use_radius ) )
		{
			if ( level.fixed_max_player_use_radius > getDvarFloat( "player_useRadius_zm" ) )
			{
				setdvar( "player_useRadius_zm", level.fixed_max_player_use_radius );
			}
		}
		else if ( level._unitriggers.largest_radius > getDvarFloat( "player_useRadius_zm" ) )
		{
			setdvar( "player_useRadius_zm", level._unitriggers.largest_radius );
		}
	}
	level._unitriggers.trigger_stubs[ level._unitriggers.trigger_stubs.size ] = unitrigger_stub;
	unitrigger_stub.registered = 1;
}

register_unitrigger( unitrigger_stub, trigger_func ) //checked matches cerberus output
{
	register_unitrigger_internal( unitrigger_stub, trigger_func );
	level._unitriggers.dynamic_stubs[ level._unitriggers.dynamic_stubs.size ] = unitrigger_stub;
}

unregister_unitrigger( unitrigger_stub ) //checked matches cerberus output
{
	thread unregister_unitrigger_internal( unitrigger_stub );
}

unregister_unitrigger_internal( unitrigger_stub ) //checked changed to match cerberus output
{
	if ( !isDefined( unitrigger_stub ) )
	{
		return;
	}
	unitrigger_stub.registered = 0;
	if ( is_true( unitrigger_stub.trigger_per_player ) )
	{
		if ( isDefined( unitrigger_stub.playertrigger ) && unitrigger_stub.playertrigger.size > 0 )
		{
			keys = getarraykeys( unitrigger_stub.playertrigger );
			foreach ( key in keys )
			{
				trigger = unitrigger_stub.playertrigger[ key ];
				trigger notify( "kill_trigger" );
				if ( isDefined( trigger ) )
				{
					trigger delete();
				}
			}
			unitrigger_stub.playertrigger = [];
		}
	}
	else if ( isDefined( unitrigger_stub.trigger ) )
	{
		trigger = unitrigger_stub.trigger;
		trigger notify( "kill_trigger" );
		trigger.stub.trigger = undefined;
		trigger delete();
	}
	if ( isDefined( unitrigger_stub.in_zone ) )
	{
		arrayremovevalue( level.zones[ unitrigger_stub.in_zone ].unitrigger_stubs, unitrigger_stub );
		unitrigger_stub.in_zone = undefined;
	}
	arrayremovevalue( level._unitriggers.trigger_stubs, unitrigger_stub );
	arrayremovevalue( level._unitriggers.dynamic_stubs, unitrigger_stub );
}

delay_delete_contact_ent() //checked matches cerberus output
{
	self.last_used_time = 0;
	while ( 1 )
	{
		wait 1;
		if ( getTime() - self.last_used_time > 1000 )
		{
			self delete();
			level._unitriggers.contact_ent = undefined;
			return;
		}
	}
}

register_static_unitrigger( unitrigger_stub, trigger_func, recalculate_zone ) //checked changed to match cerberus output
{
	if ( level.zones.size == 0 )
	{
		unitrigger_stub.trigger_func = trigger_func;
		level._unitriggers._deferredinitlist[ level._unitriggers._deferredinitlist.size ] = unitrigger_stub;
		return;
	}
	if ( !isDefined( level._unitriggers.contact_ent ) )
	{
		level._unitriggers.contact_ent = spawn( "script_origin", ( 0, 0, 0 ) );
		level._unitriggers.contact_ent thread delay_delete_contact_ent();
	}
	register_unitrigger_internal( unitrigger_stub, trigger_func );
	if ( !isDefined( level._no_static_unitriggers ) )
	{
		level._unitriggers.contact_ent.last_used_time = getTime();
		level._unitriggers.contact_ent.origin = unitrigger_stub.origin;
		if ( isDefined( unitrigger_stub.in_zone ) && !isDefined( recalculate_zone ) )
		{
			level.zones[ unitrigger_stub.in_zone ].unitrigger_stubs[ level.zones[ unitrigger_stub.in_zone ].unitrigger_stubs.size ] = unitrigger_stub;
			return;
		}
		keys = getarraykeys( level.zones );
		for ( i = 0; i < keys.size; i++ )
		{
			if ( level._unitriggers.contact_ent maps/mp/zombies/_zm_zonemgr::entity_in_zone( keys[ i ], 1 ) )
			{
				if ( !isDefined( level.zones[ keys[ i ] ].unitrigger_stubs ) )
				{
					level.zones[ keys[ i ] ].unitrigger_stubs = [];
				}
				level.zones[ keys[ i ] ].unitrigger_stubs[ level.zones[ keys[ i ] ].unitrigger_stubs.size ] = unitrigger_stub;
				unitrigger_stub.in_zone = keys[ i ];
				return;
			}
		}
	}
	level._unitriggers.dynamic_stubs[ level._unitriggers.dynamic_stubs.size ] = unitrigger_stub;
	unitrigger_stub.registered = 1;
}

reregister_unitrigger_as_dynamic( unitrigger_stub ) //checked matches cerberus output
{
	unregister_unitrigger_internal( unitrigger_stub );
	register_unitrigger( unitrigger_stub, unitrigger_stub.trigger_func );
}

debug_unitriggers() //checked changed to match cerberus output dvar taken from beta dump
{
	/*
/#
	while ( 1 )
	{
		if ( getDvarInt( "debug_unitrigger" ) > 0 )
		{
			for ( i = 0; i < level._unitriggers.trigger_stubs.size; i++ )
			{
				triggerstub = level._unitriggers.trigger_stubs[ i ];
				color = vectorScale( ( 1, 0, 0 ), 0.75 );
				if ( !isDefined( triggerstub.in_zone ) )
				{
					color = vectorScale( ( 1, 1, 0 ), 0.65 );
				}
				else
				{
					if ( level.zones[ triggerstub.in_zone ].is_active )
					{
						color = ( 1, 1, 0 );
					}
				}
				if ( isDefined( triggerstub.trigger ) || isDefined( triggerstub.playertrigger ) && triggerstub.playertrigger.size > 0 )
				{
					color = ( 0, 1, 0 );
					if ( isDefined( triggerstub.playertrigger ) && triggerstub.playertrigger.size > 0 )
					{
						print3d( triggerstub.origin, triggerstub.playertrigger.size, color, 1, 1, 1 );
					}
				}
				origin = triggerstub unitrigger_origin();
				switch( triggerstub.script_unitrigger_type )
				{
					case "unitrigger_radius":
					case "unitrigger_radius_use":
						if ( triggerstub.radius )
						{
							circle( origin, triggerstub.radius, color, 0, 0, 1 );
						}
						if ( triggerstub.script_height )
						{
							line( origin, origin + ( 0, 0, triggerstub.script_height ), color, 0, 1 );
						}
						break;
					case "unitrigger_box":
					case "unitrigger_box_use":
						vec = ( triggerstub.script_width / 2, triggerstub.script_length / 2, triggerstub.script_height / 2 );
						box( origin, vec * -1, vec, triggerstub.angles[ 1 ], color, 1, 0, 1 );
						break;
				}
			}
		}
		wait 0.05;
#/
	}
	*/
}

cleanup_trigger( trigger, player ) //checked changed to match cerberus output
{
	trigger notify( "kill_trigger" );
	if ( is_true( trigger.stub.trigger_per_player ) )
	{
		trigger.stub.playertrigger[player getentitynumber()] = undefined;
	}
	else
	{
		trigger.stub.trigger = undefined;
	}
	trigger delete();
	level._unitriggers.trigger_pool[player getentitynumber()] = undefined;
}

assess_and_apply_visibility( trigger, stub, player, default_keep ) //checked changed to match cerberus output
{
	if ( !isDefined( trigger ) || !isDefined( stub ) )
	{
		return 0;
	}
	keep_thread = default_keep;
	if ( !isDefined( stub.prompt_and_visibility_func ) || trigger [[ stub.prompt_and_visibility_func ]]( player ) )
	{
		keep_thread = 1;
		if ( !is_true( trigger.thread_running ) )
		{
			trigger thread trigger_thread( trigger.stub.trigger_func );
		}
		trigger.thread_running = 1;
		if ( isDefined( trigger.reassess_time ) && trigger.reassess_time <= 0 )
		{
			trigger.reassess_time = undefined;
		}
	}
	else if ( is_true( trigger.thread_running ) )
	{
		keep_thread = 0;
	}
	trigger.thread_running = 0;
	if ( isDefined( stub.inactive_reasses_time ) )
	{
		trigger.reassess_time = stub.inactive_reasses_time;
	}
	else
	{
		trigger.reassess_time = 1;
	}
	return keep_thread;
}

main() //checked against bo3 _zm_unitrigger.gsc and cerberus output changed at own discretion
{
	level thread debug_unitriggers();
	if ( level._unitriggers._deferredinitlist.size )
	{
		for ( i = 0; i < level._unitriggers._deferredinitlist.size; i++ )
		{
			register_static_unitrigger( level._unitriggers._deferredinitlist[ i ], level._unitriggers._deferredinitlist[ i ].trigger_func );
		}
		for ( i = 0; i < level._unitriggers._deferredinitlist.size; i++ )
		{
			level._unitriggers._deferredinitlist[i] = undefined;
		}
		level._unitriggers._deferredinitlist = undefined;
	}
	valid_range = level._unitriggers.largest_radius + 15;
	valid_range_sq = valid_range * valid_range;
	while ( !isDefined( level.active_zone_names ) )
	{
		wait 0.1;
	}
	while ( 1 )
	{
		waited = 0;
		active_zone_names = level.active_zone_names;
		candidate_list = [];
		for ( j = 0; j < active_zone_names.size; j++ )
		{
			if ( isDefined( level.zones[ active_zone_names[ j ] ].unitrigger_stubs ) )
			{
				candidate_list = arraycombine( candidate_list, level.zones[ active_zone_names[ j ] ].unitrigger_stubs, 1, 0 );
			}
		}
		candidate_list = arraycombine( candidate_list, level._unitriggers.dynamic_stubs, 1, 0 );
		players = getplayers();
		i = 0;
		while ( i < players.size )
		{
			player = players[ i ];
			if ( !isDefined( player ) )
			{
				i++;
				continue;
			}
			player_origin = player.origin + vectorScale( ( 0, 0, 1 ), 35 );
			trigger = level._unitriggers.trigger_pool[ player getentitynumber() ];
			closest = [];
			if ( isDefined( trigger ) )
			{
				dst = valid_range_sq;
				origin = trigger unitrigger_origin();
				dst = trigger.stub.test_radius_sq;
				time_to_ressess = 0;
				if ( distance2dsquared( player_origin, origin ) < dst )
				{
					if ( isDefined( trigger.reassess_time ) )
					{
						trigger.reassess_time -= 0.05;
						if ( trigger.reassess_time > 0 )
						{
							i++;
							continue;
						}
						time_to_ressess = 1;
					}
				}
				closest = get_closest_unitriggers( player_origin, candidate_list, valid_range );
				if ( isDefined( trigger ) && time_to_ressess && closest.size < 2 || is_true( trigger.thread_running ) )
				{
					if ( assess_and_apply_visibility( trigger, trigger.stub, player, 1 ) )
					{
						i++;
						continue;
					}
				}
				else if ( isDefined( trigger ) )
				{
					cleanup_trigger( trigger, player );
				}
			}
			else
			{
				closest = get_closest_unitriggers( player_origin, candidate_list, valid_range );
			}
			index = 0;
			last_trigger = undefined;
			while ( index < closest.size )
			{
				if ( !maps/mp/zombies/_zm_utility::is_player_valid( player ) && !is_true( closest[ index ].ignore_player_valid ) )
				{
					index++;
					continue;
				}
				if ( !is_true( closest[ index ].registered ) )
				{
					index++;
					continue;
				}
				if ( isDefined( last_trigger ) )
				{
					cleanup_trigger( last_trigger, player );
					last_trigger = undefined;
				}
				trigger = undefined;
				if ( is_true( closest[ index ].trigger_per_player ) )
				{
					if ( !isDefined( closest[ index ].playertrigger ) )
					{
						closest[ index ].playertrigger = [];
					}
					if ( !isDefined( closest[ index ].playertrigger[ player getentitynumber() ] ) )
					{
						trigger = build_trigger_from_unitrigger_stub( closest[ index ], player );
						level._unitriggers.trigger_pool[ player getentitynumber() ] = trigger;
					}
				}
				else if ( !isDefined( closest[ index ].trigger ) )
				{
					trigger = build_trigger_from_unitrigger_stub( closest[ index ], player );
					level._unitriggers.trigger_pool[ player getentitynumber() ] = trigger;
				}
				if ( isDefined( trigger ) )
				{
					trigger.parent_player = player;
					if ( assess_and_apply_visibility( trigger, closest[ index ], player, 0 ) )
					{
						break;
					}
					last_trigger = trigger;
				}
				index++;
				waited = 1;
				wait 0.05;
			}
			i++;
		}
		if ( !waited )
		{
			wait 0.05;
		}
	}
}

run_visibility_function_for_all_triggers() //checked changed to match cerberus output
{
	if ( !isDefined( self.prompt_and_visibility_func ) )
	{
		return;
	}
	if ( is_true( self.trigger_per_player ) )
	{
		if ( !isDefined( self.playertrigger ) )
		{
			return;
		}
		players = getplayers();
        for ( i = 0; i < players.size; i++ )
		{
			if ( isDefined( self.playertrigger[ players[ i ] getentitynumber() ] ) )
			{
				self.playertrigger[ players[ i ] getentitynumber() ] [[ self.prompt_and_visibility_func ]]( players[ i ] );
			}
		}
	}
	else if ( isDefined( self.trigger ) )
	{
		self.trigger [[ self.prompt_and_visibility_func ]]( getplayers()[ 0 ] );
	}
}

build_trigger_from_unitrigger_stub( stub, player ) //checked matches cerberus output
{
	if ( isDefined( level._zm_build_trigger_from_unitrigger_stub_override ) )
	{
		if ( stub [[ level._zm_build_trigger_from_unitrigger_stub_override ]]( player ) )
		{
			return;
		}
	}
	radius = stub.radius;
	if ( !isDefined( radius ) )
	{
		radius = 64;
	}
	script_height = stub.script_height;
	if ( !isDefined( script_height ) )
	{
		script_height = 64;
	}
	script_width = stub.script_width;
	if ( !isDefined( script_width ) )
	{
		script_width = 64;
	}
	script_length = stub.script_length;
	if ( !isDefined( script_length ) )
	{
		script_length = 64;
	}
	trigger = undefined;
	origin = stub unitrigger_origin();
	switch( stub.script_unitrigger_type )
	{
		case "unitrigger_radius":
			trigger = spawn( "trigger_radius", origin, 0, radius, script_height );
			break;
		case "unitrigger_radius_use":
			trigger = spawn( "trigger_radius_use", origin, 0, radius, script_height );
			break;
		case "unitrigger_box":
			trigger = spawn( "trigger_box", origin, 0, script_width, script_length, script_height );
			break;
		case "unitrigger_box_use":
			trigger = spawn( "trigger_box_use", origin, 0, script_width, script_length, script_height );
			break;
	}
	if ( isDefined( trigger ) )
	{
		if ( isDefined( stub.angles ) )
		{
			trigger.angles = stub.angles;
		}
		if ( isDefined( stub.onspawnfunc ) )
		{
			stub [[ stub.onspawnfunc ]]( trigger );
		}
		if ( isDefined( stub.cursor_hint ) )
		{
			if ( stub.cursor_hint == "HINT_WEAPON" && isDefined( stub.cursor_hint_weapon ) )
			{
				trigger setcursorhint( stub.cursor_hint, stub.cursor_hint_weapon );
			}
			else
			{
				trigger setcursorhint( stub.cursor_hint );
			}
		}
		trigger triggerignoreteam();
		if ( is_true( stub.require_look_at ) )
		{
			trigger usetriggerrequirelookat();
		}
		if ( isDefined( stub.hint_string ) )
		{
			if ( isDefined( stub.hint_parm2 ) )
			{
				trigger sethintstring( stub.hint_string, stub.hint_parm1, stub.hint_parm2 );
			}
			else if ( isDefined( stub.hint_parm1 ) )
			{
				trigger sethintstring( stub.hint_string, stub.hint_parm1 );
			}
			else if ( isDefined( stub.cost ) )
			{
				trigger sethintstring( stub.hint_string, stub.cost );
			}
			else
			{
				trigger sethintstring( stub.hint_string );
			}
		}
		trigger.stub = stub;
	}
	copy_zombie_keys_onto_trigger( trigger, stub );
	if ( is_true( stub.trigger_per_player ) )
	{
		if ( isDefined( trigger ) )
		{
			trigger setinvisibletoall();
			trigger setvisibletoplayer( player );
		}
		if ( !isDefined( stub.playertrigger ) )
		{
			stub.playertrigger = [];
		}
		stub.playertrigger[ player getentitynumber() ] = trigger;
	}
	else
	{
		stub.trigger = trigger;
	}
	trigger.thread_running = 0;
	return trigger;
}

copy_zombie_keys_onto_trigger( trig, stub ) //checked matches cerberus output
{
	trig.script_noteworthy = stub.script_noteworthy;
	trig.targetname = stub.targetname;
	trig.target = stub.target;
	trig.zombie_weapon_upgrade = stub.zombie_weapon_upgrade;
	trig.clientfieldname = stub.clientfieldname;
	trig.usetime = stub.usetime;
}

trigger_thread( trigger_func ) //checked matches cerberus output
{
	self endon( "kill_trigger" );
	if ( isDefined( trigger_func ) )
	{
		self [[ trigger_func ]]();
	}
}

get_closest_unitrigger_index( org, array, dist ) //checked partially changed to match cerberus output //did not change while loop to for loop to prevent infinite loop due to continue
{
	if ( !isDefined( dist ) )
	{
		dist = 9999999;
	}
	distsq = dist * dist;
	if ( array.size < 1 )
	{
		return;
	}
	index = undefined;
	i = 0;
	while ( i < array.size )
	{
		origin = array[ i ] unitrigger_origin();
		radius_sq = array[ i ].test_radius_sq;
		newdistsq = distance2dsquared( origin, org );
		if ( newdistsq >= radius_sq )
		{
			i++;
			continue;
		}
		else if ( newdistsq >= distsq )
		{
			i++;
			continue;
		}
		distsq = newdistsq;
		index = i;
		i++;
	}
	return index;
}

get_closest_unitriggers( org, array, dist ) //checked partially changed to match cerberus output did not change while loop to for loop to prevent infinite loop due to continue
{
	triggers = [];
	if ( !isDefined( dist ) )
	{
		dist = 9999999;
	}
	distsq = dist * dist;
	if ( array.size < 1 )
	{
		return triggers;
	}
	index = undefined;
	i = 0;
	while ( i < array.size )
	{
		if ( !isDefined( array[ i ] ) )
		{
			i++;
			continue;
		}
		origin = array[ i ] unitrigger_origin();
		radius_sq = array[ i ].test_radius_sq;
		newdistsq = distance2dsquared( origin, org );
		if ( newdistsq >= radius_sq )
		{
			i++;
			continue;
		}
		if ( abs( origin[ 2 ] - org[ 2 ] ) > 42 )
		{
			i++;
			continue;
		}
		array[ i ].dsquared = newdistsq;
		for ( j = 0; j < triggers.size && newdistsq > triggers[j].dsquared; j++ )
		{
		}
		arrayinsert( triggers, array[ i ], j );
		if ( ( i % 10 ) == 9 )
		{
			wait 0.05;
		}
		i++;
	}
	return triggers;
}


