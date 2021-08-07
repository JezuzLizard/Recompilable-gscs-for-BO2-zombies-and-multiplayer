#include maps/mp/animscripts/traverse/zm_shared;
#include maps/mp/animscripts/traverse/shared;

main()
{
	speed = "";
	if ( !self.has_legs )
	{
		switch( self.zombie_move_speed )
		{
			case "sprint":
			case "sprint_slide":
			case "super_sprint":
				speed = "_sprint";
				break;
			default:
			}
		}
		dosimpletraverse( "traverse_car_reverse" + speed, 1 );
	}
}
