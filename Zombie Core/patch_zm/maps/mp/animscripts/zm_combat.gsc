#include maps/mp/animscripts/zm_melee;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/utility;
#include maps/mp/animscripts/shared;
#include common_scripts/utility;

main()
{
	self endon( "killanimscript" );
	self endon( "melee" );
	maps/mp/animscripts/zm_utility::initialize( "zombie_combat" );
	self animmode( "zonly_physics", 0 );
	if ( isDefined( self.combat_animmode ) )
	{
		self [[ self.combat_animmode ]]();
	}
	self orientmode( "face angle", self.angles[ 1 ] );
	for ( ;; )
	{
		if ( trymelee() )
		{
			return;
		}
		exposedwait();
	}
}

exposedwait()
{
	if ( !isDefined( self.can_always_see ) || !isDefined( self.enemy ) && !self cansee( self.enemy ) )
	{
		self endon( "enemy" );
		wait ( 0,2 + randomfloat( 0,1 ) );
	}
	else
	{
		if ( !isDefined( self.enemy ) )
		{
			self endon( "enemy" );
			wait ( 0,2 + randomfloat( 0,1 ) );
			return;
		}
		else
		{
			wait 0,05;
		}
	}
}

trymelee()
{
	if ( isDefined( self.cant_melee ) && self.cant_melee )
	{
		return 0;
	}
	if ( !isDefined( self.enemy ) )
	{
		return 0;
	}
	if ( distancesquared( self.origin, self.enemy.origin ) > 262144 )
	{
		return 0;
	}
	canmelee = maps/mp/animscripts/zm_melee::canmeleedesperate();
	if ( !canmelee )
	{
		return 0;
	}
	self thread maps/mp/animscripts/zm_melee::meleecombat();
	return 1;
}
