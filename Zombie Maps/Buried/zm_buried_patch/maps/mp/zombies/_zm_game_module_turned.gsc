#include maps/mp/zombies/_zm_game_module_cleansed;
#include maps/mp/zombies/_zm_turned;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;

register_game_module()
{
	level.game_module_turned_index = 6;
	maps/mp/zombies/_zm_game_module::register_game_module( level.game_module_turned_index, "zturned", ::maps/mp/zombies/_zm_game_module_cleansed::onpreinitgametype, ::onpostinitgametype, undefined, ::maps/mp/zombies/_zm_game_module_cleansed::onspawnzombie, ::maps/mp/zombies/_zm_game_module_cleansed::onstartgametype );
}

register_turned_match( start_func, end_func, name )
{
	if ( !isDefined( level._registered_turned_matches ) )
	{
		level._registered_turned_matches = [];
	}
	match = spawnstruct();
	match.match_name = name;
	match.match_start_func = start_func;
	match.match_end_func = end_func;
	level._registered_turned_matches[ level._registered_turned_matches.size ] = match;
}

get_registered_turned_match( name )
{
	_a41 = level._registered_turned_matches;
	_k41 = getFirstArrayKey( _a41 );
	while ( isDefined( _k41 ) )
	{
		struct = _a41[ _k41 ];
		if ( struct.match_name == name )
		{
			return struct;
		}
		_k41 = getNextArrayKey( _a41, _k41 );
	}
}

set_current_turned_match( name )
{
	level._current_turned_match = name;
}

get_current_turned_match()
{
	return level._current_turned_match;
}

init_zombie_weapon()
{
	maps/mp/zombies/_zm_turned::init();
}

onpostinitgametype()
{
	if ( level.scr_zm_game_module != level.game_module_turned_index )
	{
		return;
	}
	level thread init_zombie_weapon();
}
