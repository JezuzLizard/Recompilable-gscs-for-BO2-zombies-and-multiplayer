#include maps/mp/animscripts/traverse/zm_shared;
#include maps/mp/animscripts/traverse/shared;

main()
{
	traversestate = "zm_traverse_barrier";
	traversealias = "barrier_walk";
	if ( self.has_legs )
	{
		switch( self.zombie_move_speed )
		{
			case "walk":
			case "walk_slide":
				traversealias = "barrier_walk";
				break;
			case "run":
			case "run_slide":
				traversealias = "barrier_run";
				break;
			case "sprint":
			case "sprint_slide":
			case "super_sprint":
				traversealias = "barrier_sprint";
				break;
			default:
				if ( isDefined( level.zm_mantle_over_40_move_speed_override ) )
				{
					traversealias = self [[ level.zm_mantle_over_40_move_speed_override ]]();
				}
				else /#
				assertmsg( "Zombie move speed of '" + self.zombie_move_speed + "' is not supported for mantle_over_40." );
#/
		}
	}
	else
	{
		traversestate = "zm_traverse_barrier_crawl";
		traversealias = "barrier_crawl";
	}
	self dotraverse( traversestate, traversealias );
}
