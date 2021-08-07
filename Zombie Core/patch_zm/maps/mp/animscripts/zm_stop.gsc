#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/utility;
#include maps/mp/animscripts/shared;

main()
{
	self endon( "killanimscript" );
	for ( ;; )
	{
		if ( isDefined( level.ignore_stop_func ) )
		{
			if ( self [[ level.ignore_stop_func ]]() )
			{
				return;
			}
		}
		if ( !self hasanimstatefromasd( "zm_idle" ) )
		{
			return;
		}
		animstate = maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "zm_idle" );
		self setanimstatefromasd( animstate );
		maps/mp/animscripts/zm_shared::donotetracks( "idle_anim" );
	}
}
