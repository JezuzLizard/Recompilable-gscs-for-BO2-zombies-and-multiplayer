#include maps/mp/zombies/_zm_game_module_meat;
#include maps/mp/zombies/_zm_game_module_meat_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;

init_item_meat()
{
	level.item_meat_name = "item_meat_zm";
	precacheitem( level.item_meat_name );
}

move_ring( ring )
{
	positions = getstructarray( ring.target, "targetname" );
	positions = array_randomize( positions );
	level endon( "end_game" );
	while ( 1 )
	{
		_a23 = positions;
		_k23 = getFirstArrayKey( _a23 );
		while ( isDefined( _k23 ) )
		{
			position = _a23[ _k23 ];
			self moveto( position.origin, randomintrange( 30, 45 ) );
			self waittill( "movedone" );
			_k23 = getNextArrayKey( _a23, _k23 );
		}
	}
}

rotate_ring( forward )
{
	level endon( "end_game" );
	dir = -360;
	if ( forward )
	{
		dir = 360;
	}
	while ( 1 )
	{
		self rotateyaw( dir, 9 );
		wait 9;
	}
}
