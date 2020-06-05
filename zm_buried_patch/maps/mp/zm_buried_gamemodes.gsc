#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zm_buried;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	add_map_gamemode( "zclassic", ::maps/mp/zm_buried::zclassic_preinit, undefined, undefined );
	add_map_gamemode( "zcleansed", ::maps/mp/zm_buried::zcleansed_preinit, undefined, undefined );
	add_map_gamemode( "zgrief", ::maps/mp/zm_buried::zgrief_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "processing", ::maps/mp/zm_buried_classic::precache, ::maps/mp/zm_buried_classic::main );
	add_map_location_gamemode( "zcleansed", "street", ::maps/mp/zm_buried_turned_street::precache, ::maps/mp/zm_buried_turned_street::main );
	add_map_location_gamemode( "zgrief", "street", ::maps/mp/zm_buried_grief_street::precache, ::maps/mp/zm_buried_grief_street::main );
}

deletechalktriggers()
{
	chalk_triggers = getentarray( "chalk_buildable_trigger", "targetname" );
	array_thread( chalk_triggers, ::self_delete );
}

deletebuyabledoors()
{
	doors_trigs = getentarray( "zombie_door", "targetname" );
	_a41 = doors_trigs;
	_k41 = getFirstArrayKey( _a41 );
	while ( isDefined( _k41 ) )
	{
		door = _a41[ _k41 ];
		doors = getentarray( door.target, "targetname" );
		array_thread( doors, ::self_delete );
		_k41 = getNextArrayKey( _a41, _k41 );
	}
	array_thread( doors_trigs, ::self_delete );
}

deletebuyabledebris( justtriggers )
{
	debris_trigs = getentarray( "zombie_debris", "targetname" );
	while ( !is_true( justtriggers ) )
	{
		_a56 = debris_trigs;
		_k56 = getFirstArrayKey( _a56 );
		while ( isDefined( _k56 ) )
		{
			trig = _a56[ _k56 ];
			if ( isDefined( trig.script_flag ) )
			{
				flag_set( trig.script_flag );
			}
			parts = getentarray( trig.target, "targetname" );
			array_thread( parts, ::self_delete );
			_k56 = getNextArrayKey( _a56, _k56 );
		}
	}
	array_thread( debris_trigs, ::self_delete );
}

deleteslothbarricades( justtriggers )
{
	sloth_trigs = getentarray( "sloth_barricade", "targetname" );
	while ( !is_true( justtriggers ) )
	{
		_a77 = sloth_trigs;
		_k77 = getFirstArrayKey( _a77 );
		while ( isDefined( _k77 ) )
		{
			trig = _a77[ _k77 ];
			if ( isDefined( trig.script_flag ) && level flag_exists( trig.script_flag ) )
			{
				flag_set( trig.script_flag );
			}
			parts = getentarray( trig.target, "targetname" );
			array_thread( parts, ::self_delete );
			_k77 = getNextArrayKey( _a77, _k77 );
		}
	}
	array_thread( sloth_trigs, ::self_delete );
}

deleteslothbarricade( location )
{
	sloth_trigs = getentarray( "sloth_barricade", "targetname" );
	_a96 = sloth_trigs;
	_k96 = getFirstArrayKey( _a96 );
	while ( isDefined( _k96 ) )
	{
		trig = _a96[ _k96 ];
		if ( isDefined( trig.script_location ) && trig.script_location == location )
		{
			if ( isDefined( trig.script_flag ) )
			{
				flag_set( trig.script_flag );
			}
			parts = getentarray( trig.target, "targetname" );
			array_thread( parts, ::self_delete );
		}
		_k96 = getNextArrayKey( _a96, _k96 );
	}
}

spawnmapcollision( collision_model, origin )
{
	if ( !isDefined( origin ) )
	{
		origin = ( 0, 0, 0 );
	}
	collision = spawn( "script_model", origin, 1 );
	collision setmodel( collision_model );
	collision disconnectpaths();
}

turnperkon( perk )
{
	level notify( perk + "_on" );
	wait_network_frame();
}

disableallzonesexcept( zones )
{
	_a133 = zones;
	_k133 = getFirstArrayKey( _a133 );
	while ( isDefined( _k133 ) )
	{
		zone = _a133[ _k133 ];
		level thread maps/mp/zombies/_zm_zonemgr::enable_zone( zone );
		_k133 = getNextArrayKey( _a133, _k133 );
	}
	_a140 = level.zones;
	zoneindex = getFirstArrayKey( _a140 );
	while ( isDefined( zoneindex ) )
	{
		zone = _a140[ zoneindex ];
		should_disable = 1;
		_a144 = zones;
		_k144 = getFirstArrayKey( _a144 );
		while ( isDefined( _k144 ) )
		{
			cleared_zone = _a144[ _k144 ];
			if ( zoneindex == cleared_zone )
			{
				should_disable = 0;
			}
			_k144 = getNextArrayKey( _a144, _k144 );
		}
		if ( is_true( should_disable ) )
		{
			zone.is_enabled = 0;
			zone.is_spawning_allowed = 0;
		}
		zoneindex = getNextArrayKey( _a140, zoneindex );
	}
}

remove_adjacent_zone( main_zone, adjacent_zone )
{
	if ( isDefined( level.zones[ main_zone ].adjacent_zones ) && isDefined( level.zones[ main_zone ].adjacent_zones[ adjacent_zone ] ) )
	{
	}
	if ( isDefined( level.zones[ adjacent_zone ].adjacent_zones ) && isDefined( level.zones[ adjacent_zone ].adjacent_zones[ main_zone ] ) )
	{
	}
}

builddynamicwallbuy( location, weaponname )
{
	match_string = ( level.scr_zm_ui_gametype + "_" ) + level.scr_zm_map_start_location;
	_a177 = level.chalk_builds;
	_k177 = getFirstArrayKey( _a177 );
	while ( isDefined( _k177 ) )
	{
		stub = _a177[ _k177 ];
		wallbuy = getstruct( stub.target, "targetname" );
		if ( isDefined( wallbuy.script_location ) && wallbuy.script_location == location )
		{
			if ( !isDefined( wallbuy.script_noteworthy ) || issubstr( wallbuy.script_noteworthy, match_string ) )
			{
				maps/mp/zombies/_zm_weapons::add_dynamic_wallbuy( weaponname, wallbuy.targetname, 1 );
				thread wait_and_remove( stub, stub.buildablezone.pieces[ 0 ] );
			}
		}
		_k177 = getNextArrayKey( _a177, _k177 );
	}
}

buildbuildable( buildable )
{
	player = get_players()[ 0 ];
	_a197 = level.buildable_stubs;
	_k197 = getFirstArrayKey( _a197 );
	while ( isDefined( _k197 ) )
	{
		stub = _a197[ _k197 ];
		if ( !isDefined( buildable ) || stub.equipname == buildable )
		{
			if ( isDefined( buildable ) || stub.persistent != 3 )
			{
				stub maps/mp/zombies/_zm_buildables::buildablestub_finish_build( player );
				stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
				_a206 = stub.buildablezone.pieces;
				_k206 = getFirstArrayKey( _a206 );
				while ( isDefined( _k206 ) )
				{
					piece = _a206[ _k206 ];
					piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					_k206 = getNextArrayKey( _a206, _k206 );
				}
				stub.model notsolid();
				stub.model show();
				return;
			}
		}
		_k197 = getNextArrayKey( _a197, _k197 );
	}
}

wait_and_remove( stub, piece )
{
	wait 0,1;
	self buildablestub_remove();
	thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
	piece piece_unspawn();
}

generatebuildabletarps()
{
	struct_locations = getstructarray( "buildables_tarp", "targetname" );
	level.buildable_tarps = [];
	_a234 = struct_locations;
	_k234 = getFirstArrayKey( _a234 );
	while ( isDefined( _k234 ) )
	{
		struct = _a234[ _k234 ];
		tarp = spawn( "script_model", struct.origin );
		tarp.angles = struct.angles;
		tarp setmodel( "p6_zm_bu_buildable_bench_tarp" );
		tarp.targetname = "buildable_tarp";
		if ( isDefined( struct.script_location ) )
		{
			tarp.script_location = struct.script_location;
		}
		level.buildable_tarps[ level.buildable_tarps.size ] = tarp;
		_k234 = getNextArrayKey( _a234, _k234 );
	}
}

deletebuildabletarp( location )
{
	_a252 = level.buildable_tarps;
	_k252 = getFirstArrayKey( _a252 );
	while ( isDefined( _k252 ) )
	{
		tarp = _a252[ _k252 ];
		if ( isDefined( tarp.script_location ) && tarp.script_location == location )
		{
			tarp delete();
		}
		_k252 = getNextArrayKey( _a252, _k252 );
	}
}

powerswitchstate( on )
{
	trigger = getent( "use_elec_switch", "targetname" );
	if ( isDefined( trigger ) )
	{
		trigger delete();
	}
	master_switch = getent( "elec_switch", "targetname" );
	if ( isDefined( master_switch ) )
	{
		master_switch notsolid();
		if ( is_true( on ) )
		{
			master_switch rotateroll( -90, 0,3 );
			flag_set( "power_on" );
		}
	}
}
