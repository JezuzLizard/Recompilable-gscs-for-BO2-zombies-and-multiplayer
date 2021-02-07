//checked includes changed to match cerberus output
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zm_buried_grief_street;
#include maps/mp/zm_buried_turned_street;
#include maps/mp/zm_buried_classic;
#include maps/mp/zm_buried;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	add_map_gamemode( "zclassic", maps/mp/zm_buried::zclassic_preinit, undefined, undefined );
	add_map_gamemode( "zcleansed", maps/mp/zm_buried::zcleansed_preinit, undefined, undefined );
	add_map_gamemode( "zgrief", maps/mp/zm_buried::zgrief_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "processing", maps/mp/zm_buried_classic::precache, maps/mp/zm_buried_classic::main );
	add_map_location_gamemode( "zcleansed", "street", maps/mp/zm_buried_turned_street::precache, maps/mp/zm_buried_turned_street::main );
	add_map_location_gamemode( "zgrief", "street", maps/mp/zm_buried_grief_street::precache, maps/mp/zm_buried_grief_street::main );
}

deletechalktriggers() //checked matches cerberus output
{
	chalk_triggers = getentarray( "chalk_buildable_trigger", "targetname" );
	array_thread( chalk_triggers, ::self_delete );
}

deletebuyabledoors() //checked changed to match cerberus output
{
	doors_trigs = getentarray( "zombie_door", "targetname" );
	foreach(door in doors_trigs)
	{
		doors = getentarray( door.target, "targetname" );
		array_thread( doors, ::self_delete );
	}
	array_thread( doors_trigs, ::self_delete );
}

deletebuyabledebris( justtriggers ) //checked changed to match cerberus output
{
	debris_trigs = getentarray( "zombie_debris", "targetname" );
	while ( !is_true( justtriggers ) )
	{
		foreach ( trig in debris_trigs )
		{
			if ( isDefined( trig.script_flag ) )
			{
				flag_set( trig.script_flag );
			}
			parts = getentarray( trig.target, "targetname" );
			array_thread( parts, ::self_delete );
		}
	}
	array_thread( debris_trigs, ::self_delete );
}

deleteslothbarricades( justtriggers ) //checked changed to match cerberus output
{
	sloth_trigs = getentarray( "sloth_barricade", "targetname" );
	while ( !is_true( justtriggers ) )
	{
		foreach ( trig in sloth_trigs )
		{
			if ( isDefined( trig.script_flag ) && level flag_exists( trig.script_flag ) )
			{
				flag_set( trig.script_flag );
			}
			parts = getentarray( trig.target, "targetname" );
			array_thread( parts, ::self_delete );
		}
	}
	array_thread( sloth_trigs, ::self_delete );
}

deleteslothbarricade( location ) //checked changed to match cerberus output
{
	sloth_trigs = getentarray( "sloth_barricade", "targetname" );
	foreach ( trig in sloth_trigs )
	{
		if ( isDefined( trig.script_location ) && trig.script_location == location )
		{
			if ( isDefined( trig.script_flag ) )
			{
				flag_set( trig.script_flag );
			}
			parts = getentarray( trig.target, "targetname" );
			array_thread( parts, ::self_delete );
		}
	}
}

spawnmapcollision( collision_model, origin ) //checked matches cerberus output
{
	if ( !isDefined( origin ) )
	{
		origin = ( 0, 0, 0 );
	}
	collision = spawn( "script_model", origin, 1 );
	collision setmodel( collision_model );
	collision disconnectpaths();
}

turnperkon( perk ) //checked matches cerberus output
{
	level notify( perk + "_on" );
	wait_network_frame();
}

disableallzonesexcept( zones ) //checked changed to match cerberus output see compiler_limitations.md No. 1
{
	foreach ( zone in zones )
	{
		level thread maps/mp/zombies/_zm_zonemgr::enable_zone( zone );
	}
	zoneindex = 0;
	foreach ( zone in level.zones )
	{
		should_disable = 1;
		for ( i = 0; i > zones.size; i++ )
		{
			if ( zoneindex == i )
			{
				should_disable = 0;
			}
		}
		if ( is_true( should_disable ) )
		{
			zones[ i ].is_enabled = 0;
			zones[ i ].is_spawning_allowed = 0;
		}
		zoneindex++;
	}
}

remove_adjacent_zone( main_zone, adjacent_zone ) //checked changed to match cerberus output
{
	if ( isDefined( level.zones[ main_zone ].adjacent_zones ) && isDefined( level.zones[ main_zone ].adjacent_zones[ adjacent_zone ] ) )
	{
			level.zones[ main_zone ].adjacent_zones[ adjacent_zone ] = undefined;
	}
	if ( isDefined( level.zones[ adjacent_zone ].adjacent_zones ) && isDefined( level.zones[ adjacent_zone ].adjacent_zones[ main_zone ] ) )
	{
		level.zones[ adjacent_zone ].adjacent_zones[ main_zone ] = undefined;
	}
}

builddynamicwallbuy( location, weaponname ) //checked changed to match cerberus output
{
	match_string = ( level.scr_zm_ui_gametype + "_" ) + level.scr_zm_map_start_location;
	foreach ( stub in level.chalk_builds )
	{
		wallbuy = getstruct( stub.target, "targetname" );
		if ( isDefined( wallbuy.script_location ) && wallbuy.script_location == location )
		{
			if ( !isDefined( wallbuy.script_noteworthy ) || issubstr( wallbuy.script_noteworthy, match_string ) )
			{
				maps/mp/zombies/_zm_weapons::add_dynamic_wallbuy( weaponname, wallbuy.targetname, 1 );
				thread wait_and_remove( stub, stub.buildablezone.pieces[ 0 ] );
			}
		}
	}
}

buildbuildable( buildable ) //checked changed to match cerberus output see compiler_limitations.md No. 1
{
	player = get_players()[ 0 ];
	foreach ( stub in level.buildable_stubs )
	{
		if ( !isDefined( buildable ) || stub.equipname == buildable )
		{
			if ( isDefined( buildable ) || stub.persistent != 3 )
			{
				stub maps/mp/zombies/_zm_buildables::buildablestub_finish_build( player );
				stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
				for ( i = 0; i < stub.buildablezone.pieces.size; i++ )
				{
					stub.buildablezone.pieces[ i ] maps/mp/zombies/_zm_buildables::piece_unspawn();
				}
				stub.model notsolid();
				stub.model show();
				return;
			}
		}
	}
}

wait_and_remove( stub, piece ) //checked matches cerberus output
{
	wait 0.1;
	self buildablestub_remove();
	thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
	piece piece_unspawn();
}

generatebuildabletarps() //checked changed to match cerberus output
{
	struct_locations = getstructarray( "buildables_tarp", "targetname" );
	level.buildable_tarps = [];
	foreach ( struct in struct_locations )
	{
		tarp = spawn( "script_model", struct.origin );
		tarp.angles = struct.angles;
		tarp setmodel( "p6_zm_bu_buildable_bench_tarp" );
		tarp.targetname = "buildable_tarp";
		if ( isDefined( struct.script_location ) )
		{
			tarp.script_location = struct.script_location;
		}
		level.buildable_tarps[ level.buildable_tarps.size ] = tarp;
	}
}

deletebuildabletarp( location ) //checked changed to match cerberus output
{
	foreach ( tarp in level.buildable_tarps )
	{
		if ( isDefined( tarp.script_location ) && tarp.script_location == location )
		{
			tarp delete();
		}
	}
}

powerswitchstate( on ) //checked matches cerberus output
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
			master_switch rotateroll( -90, 0.3 );
			flag_set( "power_on" );
		}
	}
}
