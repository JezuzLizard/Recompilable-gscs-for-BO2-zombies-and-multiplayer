//checked matches cerberus output
#include maps/mp/zombies/_zm_game_module_meat;
#include maps/mp/zombies/_zm_game_module_meat_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;

init_item_meat() //checked matches cerberus output
{
	level.item_meat_name = "item_meat_zm";
	precacheitem( level.item_meat_name );
}

move_ring( ring ) //checked changed to match cerberus output
{
	positions = getstructarray( ring.target, "targetname" );
	positions = array_randomize( positions );
	level endon( "end_game" );
	while ( 1 )
	{
		foreach ( position in positions ) 
		{
			self moveto( position.origin, randomintrange( 30, 45 ) );
			self waittill( "movedone" );
		}
	}
}

rotate_ring( forward ) //checked matches cerberus output
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
