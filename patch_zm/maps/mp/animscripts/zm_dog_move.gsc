#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/dog_stop;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/shared;
#include maps/mp/animscripts/utility;

setup_sound_variables()
{
	level.dog_sounds[ "far" ] = spawnstruct();
	level.dog_sounds[ "close" ] = spawnstruct();
	level.dog_sounds[ "close" ].minrange = 0;
	level.dog_sounds[ "close" ].maxrange = 500;
	level.dog_sounds[ "close" ].sound = "aml_dog_bark_close";
	level.dog_sounds[ "close" ].soundlengthplaceholder = 0,2;
	level.dog_sounds[ "close" ].aftersoundwaitmin = 0,1;
	level.dog_sounds[ "close" ].aftersoundwaitmax = 0,3;
	level.dog_sounds[ "close" ].minrangesqr = level.dog_sounds[ "close" ].minrange * level.dog_sounds[ "close" ].minrange;
	level.dog_sounds[ "close" ].maxrangesqr = level.dog_sounds[ "close" ].maxrange * level.dog_sounds[ "close" ].maxrange;
	level.dog_sounds[ "far" ].minrange = 500;
	level.dog_sounds[ "far" ].maxrange = 0;
	level.dog_sounds[ "far" ].sound = "aml_dog_bark";
	level.dog_sounds[ "far" ].soundlengthplaceholder = 0,2;
	level.dog_sounds[ "far" ].aftersoundwaitmin = 0,1;
	level.dog_sounds[ "far" ].aftersoundwaitmax = 0,3;
	level.dog_sounds[ "far" ].minrangesqr = level.dog_sounds[ "far" ].minrange * level.dog_sounds[ "far" ].minrange;
	level.dog_sounds[ "far" ].maxrangesqr = level.dog_sounds[ "far" ].maxrange * level.dog_sounds[ "far" ].maxrange;
}

main()
{
	self endon( "killanimscript" );
	debug_anim_print( "dog_move::main()" );
	self setaimanimweights( 0, 0 );
	do_movement = 1;
/#
	if ( !debug_allow_movement() )
	{
		do_movement = 0;
#/
	}
	if ( isDefined( level.hostmigrationtimer ) )
	{
		do_movement = 0;
	}
	if ( !isDefined( self.traversecomplete ) && !isDefined( self.skipstartmove ) && self.a.movement == "run" && do_movement )
	{
		self startmove();
		blendtime = 0;
	}
	else
	{
		blendtime = 0,2;
	}
	self.traversecomplete = undefined;
	self.skipstartmove = undefined;
	if ( do_movement )
	{
		if ( self.a.movement == "run" )
		{
			debug_anim_print( "dog_move::main() - Setting move_run" );
			self setanimstatefromasd( "zm_move_run" );
			maps/mp/animscripts/zm_shared::donotetracksfortime( 0,1, "move_run" );
			debug_anim_print( "dog_move::main() - move_run wait 0.1 done " );
		}
		else
		{
			debug_anim_print( "dog_move::main() - Setting move_start " );
			self setanimstatefromasd( "zm_move_walk" );
			maps/mp/animscripts/zm_shared::donotetracks( "move_walk" );
		}
	}
	self thread maps/mp/animscripts/dog_stop::lookattarget( "normal" );
	while ( 1 )
	{
		self moveloop();
		if ( self.a.movement == "run" )
		{
			if ( self.disablearrivals == 0 )
			{
				self thread stopmove();
			}
			self waittill( "run" );
		}
	}
}

moveloop()
{
	self endon( "killanimscript" );
	self endon( "stop_soon" );
	while ( 1 )
	{
		do_movement = 1;
/#
		if ( !debug_allow_movement() )
		{
			do_movement = 0;
#/
		}
		if ( isDefined( level.hostmigrationtimer ) )
		{
			do_movement = 0;
		}
		while ( !do_movement )
		{
			self setaimanimweights( 0, 0 );
			self setanimstatefromasd( "zm_stop_idle" );
			maps/mp/animscripts/zm_shared::donotetracks( "stop_idle" );
		}
		if ( self.disablearrivals )
		{
			self.stopanimdistsq = 0;
		}
		else
		{
			self.stopanimdistsq = level.dogstoppingdistsq;
		}
		if ( self.a.movement == "run" )
		{
			debug_anim_print( "dog_move::moveLoop() - Setting move_run" );
			self setanimstatefromasd( "zm_move_run" );
			maps/mp/animscripts/zm_shared::donotetracksfortime( 0,2, "move_run" );
			debug_anim_print( "dog_move::moveLoop() - move_run wait 0.2 done " );
			continue;
		}
		else
		{
/#
			assert( self.a.movement == "walk" );
#/
			debug_anim_print( "dog_move::moveLoop() - Setting move_walk " );
			self setanimstatefromasd( "zm_move_walk" );
			maps/mp/animscripts/zm_shared::donotetracksfortime( 0,1, "move_walk" );
			if ( self need_to_run() )
			{
				self.a.movement = "run";
				self notify( "dog_running" );
			}
			debug_anim_print( "dog_move::moveLoop() - move_walk wait 0.2 done " );
		}
	}
}

startmovetracklookahead()
{
	self endon( "killanimscript" );
	i = 0;
	while ( i < 2 )
	{
		lookaheadangle = vectorToAngle( self.lookaheaddir );
		self set_orient_mode( "face angle", lookaheadangle );
		i++;
	}
}

startmove()
{
	debug_anim_print( "dog_move::startMove() - Setting move_start " );
	self setanimstatefromasd( "zm_move_start" );
	maps/mp/animscripts/zm_shared::donotetracks( "move_start" );
	debug_anim_print( "dog_move::startMove() - move_start notify done." );
	self animmode( "none" );
	self set_orient_mode( "face motion" );
}

stopmove()
{
	self endon( "killanimscript" );
	self endon( "run" );
	debug_anim_print( "dog_move::stopMove() - Setting move_stop" );
	self setanimstatefromasd( "zm_move_stop" );
	maps/mp/animscripts/zm_shared::donotetracks( "move_stop" );
	debug_anim_print( "dog_move::stopMove() - move_stop notify done." );
}

getenemydistancesqr()
{
	if ( isDefined( self.enemy ) )
	{
		return distancesquared( self.origin, self.enemy.origin );
	}
	return 100000000;
}

getsoundkey( distancesqr )
{
	keys = getarraykeys( level.dog_sounds );
	i = 0;
	while ( i < keys.size )
	{
		sound_set = level.dog_sounds[ keys[ i ] ];
		if ( sound_set.minrangesqr > distancesqr )
		{
			i++;
			continue;
		}
		else if ( sound_set.maxrangesqr && sound_set.maxrangesqr < distancesqr )
		{
			i++;
			continue;
		}
		else
		{
			return keys[ i ];
		}
		i++;
	}
	return keys[ keys.size - 1 ];
}

need_to_run()
{
	run_dist_squared = 147456;
	if ( getDvar( "scr_dog_run_distance" ) != "" )
	{
		dist = getDvarInt( "scr_dog_run_distance" );
		run_dist_squared = dist * dist;
	}
	run_yaw = 20;
	run_pitch = 30;
	run_height = 64;
	if ( self.a.movement != "walk" )
	{
		return 0;
	}
	if ( self.health < self.maxhealth )
	{
		return 1;
	}
	if ( !isDefined( self.enemy ) || !isalive( self.enemy ) )
	{
		return 0;
	}
	if ( !self cansee( self.enemy ) )
	{
		return 0;
	}
	dist = distancesquared( self.origin, self.enemy.origin );
	if ( dist > run_dist_squared )
	{
		return 0;
	}
	height = self.origin[ 2 ] - self.enemy.origin[ 2 ];
	if ( abs( height ) > run_height )
	{
		return 0;
	}
	yaw = self maps/mp/animscripts/zm_utility::absyawtoenemy();
	if ( yaw > run_yaw )
	{
		return 0;
	}
	pitch = angleClamp180( vectorToAngle( self.origin - self.enemy.origin )[ 0 ] );
	if ( abs( pitch ) > run_pitch )
	{
		return 0;
	}
	return 1;
}
