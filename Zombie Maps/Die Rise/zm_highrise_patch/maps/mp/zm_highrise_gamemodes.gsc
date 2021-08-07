//checked includes match cerberus output
#include maps/mp/zm_highrise_classic;
#include maps/mp/zm_highrise;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	add_map_gamemode( "zclassic", maps/mp/zm_highrise::zclassic_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "rooftop", maps/mp/zm_highrise_classic::precache, maps/mp/zm_highrise_classic::main );
}
