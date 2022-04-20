#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/utility;
#include maps/mp/animscripts/shared;

moverun()
{
	self endon( "death" );
	if ( isDefined( self.needs_run_update ) && !self.needs_run_update )
	{
		self waittill( "needs_run_update" );
	}
	if ( isDefined( self.is_inert ) && self.is_inert )
	{
		wait 0,1;
		return;
	}
	self setaimanimweights( 0, 0 );
	self setanimstatefromspeed();
	maps/mp/animscripts/zm_shared::donotetracksfortime( 0,05, "move_anim" );
	self.needs_run_update = 0;
}

setanimstatefromspeed()
{
	animstate = self append_missing_legs_suffix( "zm_move_" + self.zombie_move_speed );
	if ( isDefined( self.a.gib_ref ) && self.a.gib_ref == "no_legs" )
	{
		animstate = "zm_move_stumpy";
	}
	if ( isDefined( self.preserve_asd_substates ) && self.preserve_asd_substates && animstate == self getanimstatefromasd() )
	{
		substate = self getanimsubstatefromasd();
		self setanimstatefromasd( animstate, substate );
	}
	else
	{
		self setanimstatefromasd( animstate );
	}
	if ( isDefined( self.setanimstatefromspeed ) )
	{
		self [[ self.setanimstatefromspeed ]]( animstate, substate );
	}
}

needsupdate()
{
	self.needs_run_update = 1;
	self notify( "needs_run_update" );
}

needsdelayedupdate()
{
	self endon( "death" );
	while ( isDefined( self.needs_run_update ) && self.needs_run_update )
	{
		wait 0,1;
	}
	self.needs_run_update = 1;
	self notify( "needs_run_update" );
}
