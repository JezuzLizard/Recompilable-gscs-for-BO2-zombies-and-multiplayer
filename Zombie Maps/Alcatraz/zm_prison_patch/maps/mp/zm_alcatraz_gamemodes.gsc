//checked includes changed to match cerberus output
#include maps/mp/zm_alcatraz_classic;
#include maps/mp/zm_alcatraz_grief_cellblock;
#include maps/mp/zm_prison;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	level.custom_vending_precaching = maps/mp/zm_prison::custom_vending_precaching;
	add_map_gamemode( "zclassic", maps/mp/zm_prison::zclassic_preinit, undefined, undefined );
	add_map_gamemode( "zgrief", maps/mp/zm_alcatraz_grief_cellblock::zgrief_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "prison", maps/mp/zm_alcatraz_classic::precache, maps/mp/zm_alcatraz_classic::main );
	add_map_location_gamemode( "zgrief", "cellblock", maps/mp/zm_alcatraz_grief_cellblock::precache, maps/mp/zm_alcatraz_grief_cellblock::main );
}
