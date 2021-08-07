//checked includes match cerberus output
#include maps/mp/zm_nuked_standard;
#include maps/mp/zm_nuked;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	add_map_gamemode( "zstandard", maps/mp/zm_nuked::zstandard_preinit, undefined, undefined );
	add_map_location_gamemode( "zstandard", "nuked", maps/mp/zm_nuked_standard::precache, maps/mp/zm_nuked_standard::main );
}
