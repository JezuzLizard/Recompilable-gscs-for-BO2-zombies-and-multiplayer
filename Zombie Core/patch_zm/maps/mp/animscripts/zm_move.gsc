#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/zm_run;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/utility;
#include maps/mp/animscripts/shared;
#include common_scripts/utility;

main()
{
	self endon( "killanimscript" );
	self setaimanimweights( 0, 0 );
	previousscript = self.a.script;
	maps/mp/animscripts/zm_utility::initialize( "zombie_move" );
	movemainloop();
}

movemainloop()
{
	self endon( "killanimscript" );
	self endon( "stop_soon" );
	self.needs_run_update = 1;
	self notify( "needs_run_update" );
	self sidestepinit();
	self thread trysidestepthread();
	for ( ;; )
	{
		self maps/mp/animscripts/zm_run::moverun();
		if ( isDefined( self.zombie_can_sidestep ) && self.zombie_can_sidestep )
		{
			self trysidestep();
		}
	}
}

sidestepinit()
{
	self.a.steppeddir = 0;
	self.a.lastsidesteptime = getTime();
}

trysidestepthread()
{
	self endon( "death" );
	self notify( "new_trySideStepThread" );
	self endon( "new_trySideStepThread" );
	if ( !isDefined( self.zombie_can_sidestep ) )
	{
		return 0;
	}
	if ( isDefined( self.zombie_can_sidestep ) && !self.zombie_can_sidestep )
	{
		return 0;
	}
	while ( 1 )
	{
		self trysidestep();
		wait 0,05;
	}
}

trysidestep()
{
	if ( isDefined( self.shouldsidestepfunc ) )
	{
		self.sidesteptype = self [[ self.shouldsidestepfunc ]]();
	}
	else
	{
		self.sidesteptype = shouldsidestep();
	}
	if ( self.sidesteptype == "none" )
	{
		if ( isDefined( self.zombie_can_forwardstep ) && self.zombie_can_forwardstep )
		{
			self.sidesteptype = shouldforwardstep();
		}
	}
	if ( self.sidesteptype == "none" )
	{
		return 0;
	}
	self.desiredstepdir = getdesiredsidestepdir( self.sidesteptype );
	self.asd_name = "zm_" + self.sidesteptype + "_" + self.desiredstepdir;
	self.substate_index = self getanimsubstatefromasd( self.asd_name );
	self.stepanim = self getanimfromasd( self.asd_name, self.substate_index );
	if ( !self checkroomforanim( self.stepanim ) )
	{
		return 0;
	}
	self.allowpain = 0;
	self animcustom( ::dosidestep );
	self waittill( "sidestep_done" );
	self.allowpain = 1;
}

getdesiredsidestepdir( sidesteptype )
{
	if ( sidesteptype == "roll" || sidesteptype == "phase" )
	{
		self.desiredstepdir = "forward";
		return self.desiredstepdir;
	}
/#
	assert( sidesteptype == "step", "Unsupported SideStepType" );
#/
	randomroll = randomfloat( 1 );
	if ( self.a.steppeddir < 0 )
	{
		self.desiredstepdir = "right";
	}
	else if ( self.a.steppeddir > 0 )
	{
		self.desiredstepdir = "left";
	}
	else if ( randomroll < 0,5 )
	{
		self.desiredstepdir = "right";
	}
	else
	{
		self.desiredstepdir = "left";
	}
	return self.desiredstepdir;
}

checkroomforanim( stepanim )
{
	if ( !self maymovefrompointtopoint( self.origin, getanimendpos( stepanim ) ) )
	{
		return 0;
	}
	return 1;
}

shouldsidestep()
{
	if ( cansidestep() && isplayer( self.enemy ) && self.enemy islookingat( self ) )
	{
		if ( self.zombie_move_speed != "sprint" || randomfloat( 1 ) < 0,7 )
		{
			return "step";
		}
		else
		{
			return "roll";
		}
	}
	return "none";
}

cansidestep()
{
	if ( !isDefined( self.zombie_can_sidestep ) || !self.zombie_can_sidestep )
	{
		return 0;
	}
	if ( ( getTime() - self.a.lastsidesteptime ) < 2000 )
	{
		return 0;
	}
	if ( !isDefined( self.enemy ) )
	{
		return 0;
	}
	if ( self.a.pose != "stand" )
	{
		return 0;
	}
	distsqfromenemy = distancesquared( self.origin, self.enemy.origin );
	if ( distsqfromenemy < 4096 )
	{
		return 0;
	}
	if ( distsqfromenemy > 1000000 )
	{
		return 0;
	}
	if ( !isDefined( self.pathgoalpos ) || distancesquared( self.origin, self.pathgoalpos ) < 4096 )
	{
		return 0;
	}
	if ( abs( self getmotionangle() ) > 15 )
	{
		return 0;
	}
	yaw = getyawtoorigin( self.enemy.origin );
	if ( abs( yaw ) > 45 )
	{
		return 0;
	}
	return 1;
}

shouldforwardstep()
{
	if ( canforwardstep() && isplayer( self.enemy ) )
	{
		return "phase";
	}
	return "none";
}

canforwardstep()
{
	if ( isDefined( self.a.lastsidesteptime ) && ( getTime() - self.a.lastsidesteptime ) < 2000 )
	{
		return 0;
	}
	if ( !isDefined( self.enemy ) )
	{
		return 0;
	}
	if ( self.a.pose != "stand" )
	{
		return 0;
	}
	distsqfromenemy = distancesquared( self.origin, self.enemy.origin );
	if ( distsqfromenemy < 14400 )
	{
		return 0;
	}
	if ( distsqfromenemy > 5760000 )
	{
		return 0;
	}
	if ( !isDefined( self.pathgoalpos ) || distancesquared( self.origin, self.pathgoalpos ) < 4096 )
	{
		return 0;
	}
	if ( abs( self getmotionangle() ) > 15 )
	{
		return 0;
	}
	yaw = getyawtoorigin( self.enemy.origin );
	if ( abs( yaw ) > 45 )
	{
		return 0;
	}
	return 1;
}

dosidestep()
{
	self endon( "death" );
	self endon( "killanimscript" );
	self playsidestepanim( self.stepanim, self.sidesteptype );
	if ( self.desiredstepdir == "left" )
	{
		self.a.steppeddir--;

	}
	else
	{
		self.a.steppeddir++;
	}
	self.a.lastsidesteptime = getTime();
	self notify( "sidestep_done" );
}

playsidestepanim( stepanim, sidesteptype )
{
	self animmode( "gravity", 0 );
	self orientmode( "face angle", self.angles[ 1 ] );
	runblendouttime = 0,2;
	if ( isDefined( self.sidestepfunc ) )
	{
		self thread [[ self.sidestepfunc ]]( "step_anim", stepanim );
	}
	self setanimstatefromasd( self.asd_name, self.substate_index );
	maps/mp/animscripts/zm_shared::donotetracks( "step_anim" );
	if ( isalive( self ) )
	{
		self thread facelookaheadforabit();
	}
}

facelookaheadforabit()
{
	self endon( "death" );
	self endon( "killanimscript" );
	lookaheadangles = vectorToAngle( self.lookaheaddir );
	self orientmode( "face angle", lookaheadangles[ 1 ] );
	wait 0,2;
	self animmode( "normal", 0 );
	self orientmode( "face default" );
}
