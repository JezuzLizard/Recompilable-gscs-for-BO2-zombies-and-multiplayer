#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/shared;
#include maps/mp/animscripts/utility;

main()
{
	self endon( "killanimscript" );
	debug_anim_print( "dog_turn::main()" );
	self setaimanimweights( 0, 0 );
	self.safetochangescript = 0;
	deltayaw = self getdeltaturnyaw();
	if ( need_to_turn_around( deltayaw ) )
	{
		turn_180( deltayaw );
	}
	else
	{
		turn_90( deltayaw );
	}
	move_out_of_turn();
	self.skipstartmove = 1;
	self.safetochangescript = 1;
}

need_to_turn_around( deltayaw )
{
	angle = getDvarFloat( "dog_turn180_angle" );
	if ( deltayaw > angle || deltayaw < ( -1 * angle ) )
	{
		debug_turn_print( "need_to_turn_around: " + deltayaw + " YES" );
		return 1;
	}
	debug_turn_print( "need_to_turn_around: " + deltayaw + " NO" );
	return 0;
}

do_turn_anim( stopped_anim, run_anim, wait_time, run_wait_time )
{
	speed = length( self getvelocity() );
	do_anim = stopped_anim;
	if ( level.dogrunturnspeed < speed )
	{
		do_anim = run_anim;
		wait_time = run_wait_time;
	}
	debug_anim_print( "dog_move::do_turn_anim() - Setting " + do_anim );
	self setanimstatefromasd( do_anim );
	maps/mp/animscripts/zm_shared::donotetracksfortime( run_wait_time, "move_turn" );
	debug_anim_print( "dog_move::turn_around_right() - done with " + do_anim + " wait time " + run_wait_time );
}

turn_left()
{
	self do_turn_anim( "move_turn_left", "move_run_turn_left", 0,5, 0,5 );
}

turn_right()
{
	self do_turn_anim( "move_turn_right", "move_run_turn_right", 0,5, 0,5 );
}

turn_180_left()
{
	self do_turn_anim( "move_turn_around_left", "move_run_turn_around_left", 0,5, 0,7 );
}

turn_180_right()
{
	self do_turn_anim( "move_turn_around_right", "move_run_turn_around_right", 0,5, 0,7 );
}

move_out_of_turn()
{
	if ( self.a.movement == "run" )
	{
		debug_anim_print( "dog_move::move_out_of_turn() - Setting move_run" );
		self setanimstatefromasd( "zm_move_run" );
		maps/mp/animscripts/zm_shared::donotetracksfortime( 0,1, "move_run" );
		debug_anim_print( "dog_move::move_out_of_turn() - move_run wait 0.1 done " );
	}
	else
	{
		debug_anim_print( "dog_move::move_out_of_turn() - Setting move_start " );
		self setanimstatefromasd( "zm_move_walk" );
		maps/mp/animscripts/zm_shared::donotetracks( "move_walk" );
	}
}

turn_90( deltayaw )
{
	self animmode( "zonly_physics" );
	debug_turn_print( "turn_90 deltaYaw: " + deltayaw );
	if ( deltayaw > getDvarFloat( "dog_turn90_angle" ) )
	{
		debug_turn_print( "turn_90 left", 1 );
		self turn_left();
	}
	else
	{
		debug_turn_print( "turn_90 right", 1 );
		self turn_right();
	}
}

turn_180( deltayaw )
{
	self animmode( "zonly_physics" );
	debug_turn_print( "turn_180 deltaYaw: " + deltayaw );
	if ( deltayaw > 177 || deltayaw < -177 )
	{
		if ( randomint( 2 ) == 0 )
		{
			debug_turn_print( "turn_around random right", 1 );
			self turn_180_right();
		}
		else
		{
			debug_turn_print( "turn_around random left", 1 );
			self turn_180_left();
		}
	}
	else
	{
		if ( deltayaw > getDvarFloat( "dog_turn180_angle" ) )
		{
			debug_turn_print( "turn_around left", 1 );
			self turn_180_left();
			return;
		}
		else
		{
			debug_turn_print( "turn_around right", 1 );
			self turn_180_right();
		}
	}
}
