#include maps/mp/zm_transit_turned_diner;
#include maps/mp/zm_transit_dr;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	add_map_gamemode( "zcleansed", ::maps/mp/zm_transit_dr::zcleansed_preinit, undefined, undefined );
	add_map_gamemode( "zturned", ::maps/mp/zm_transit_dr::zturned_preinit, undefined, undefined );
	add_map_location_gamemode( "zcleansed", "diner", ::maps/mp/zm_transit_turned_diner::precache, ::maps/mp/zm_transit_turned_diner::main );
}
