#include maps/mp/animscripts/zm_run;
#include maps/mp/animscripts/zm_shared;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/animscripts/utility;

init_traverse()
{
	point = getent( self.target, "targetname" );
	if ( isDefined( point ) )
	{
		self.traverse_height = point.origin[ 2 ];
		point delete();
	}
	else
	{
		point = getstruct( self.target, "targetname" );
		if ( isDefined( point ) )
		{
			self.traverse_height = point.origin[ 2 ];
		}
	}
}

teleportthread( verticaloffset )
{
	self endon( "killanimscript" );
	self notify( "endTeleportThread" );
	self endon( "endTeleportThread" );
	reps = 5;
	offset = ( 0, 0, verticaloffset / reps );
	i = 0;
	while ( i < reps )
	{
		self teleport( self.origin + offset );
		wait 0,05;
		i++;
	}
}

teleportthreadex( verticaloffset, delay, frames )
{
	self endon( "killanimscript" );
	self notify( "endTeleportThread" );
	self endon( "endTeleportThread" );
	if ( verticaloffset == 0 )
	{
		return;
	}
	wait delay;
	amount = verticaloffset / frames;
	if ( amount > 10 )
	{
		amount = 10;
	}
	else
	{
		if ( amount < -10 )
		{
			amount = -10;
		}
	}
	offset = ( 0, 0, amount );
	i = 0;
	while ( i < frames )
	{
		self teleport( self.origin + offset );
		wait 0,05;
		i++;
	}
}

handletraversealignment()
{
	self traversemode( "nogravity" );
	self traversemode( "noclip" );
	if ( isDefined( self.traverseheight ) && isDefined( self.traversestartnode.traverse_height ) )
	{
		currentheight = self.traversestartnode.traverse_height - self.traversestartz;
		self thread teleportthread( currentheight - self.traverseheight );
	}
}

dosimpletraverse( traversealias, no_powerups, traversestate )
{
	if ( !isDefined( traversestate ) )
	{
		traversestate = "zm_traverse";
	}
	if ( isDefined( level.ignore_traverse ) )
	{
		if ( self [[ level.ignore_traverse ]]() )
		{
			return;
		}
	}
	if ( isDefined( level.zm_traversal_override ) )
	{
		traversealias = self [[ level.zm_traversal_override ]]( traversealias );
	}
	if ( !self.has_legs )
	{
		traversestate += "_crawl";
		traversealias += "_crawl";
	}
	self dotraverse( traversestate, traversealias, no_powerups );
}

dotraverse( traversestate, traversealias, no_powerups )
{
	self endon( "killanimscript" );
	self traversemode( "nogravity" );
	self traversemode( "noclip" );
	old_powerups = 0;
	if ( isDefined( no_powerups ) && no_powerups )
	{
		old_powerups = self.no_powerups;
		self.no_powerups = 1;
	}
	self.is_traversing = 1;
	self notify( "zombie_start_traverse" );
	self.traversestartnode = self getnegotiationstartnode();
/#
	assert( isDefined( self.traversestartnode ) );
#/
	self orientmode( "face angle", self.traversestartnode.angles[ 1 ] );
	self.traversestartz = self.origin[ 2 ];
	if ( isDefined( self.pre_traverse ) )
	{
		self [[ self.pre_traverse ]]();
	}
	self setanimstatefromasd( traversestate, traversealias );
	self maps/mp/animscripts/zm_shared::donotetracks( "traverse_anim" );
	self traversemode( "gravity" );
	self.a.nodeath = 0;
	if ( isDefined( self.post_traverse ) )
	{
		self [[ self.post_traverse ]]();
	}
	self maps/mp/animscripts/zm_run::needsupdate();
	if ( !self.isdog )
	{
		self maps/mp/animscripts/zm_run::moverun();
	}
	self.is_traversing = 0;
	self notify( "zombie_end_traverse" );
	if ( isDefined( no_powerups ) && no_powerups )
	{
		self.no_powerups = old_powerups;
	}
}
