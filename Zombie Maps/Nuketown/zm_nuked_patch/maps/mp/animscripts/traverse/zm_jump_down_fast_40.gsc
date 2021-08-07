#include maps/mp/animscripts/traverse/zm_shared;
#include maps/mp/animscripts/traverse/shared;

main()
{
	if ( self.zombie_move_speed == "sprint" )
	{
		dosimpletraverse( "jump_down_fast_40" );
	}
	else
	{
		dosimpletraverse( "jump_down_40" );
	}
}
