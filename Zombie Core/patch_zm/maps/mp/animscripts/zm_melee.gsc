#include maps/mp/animscripts/zm_combat;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/utility;
#include maps/mp/animscripts/shared;
#include common_scripts/utility;

meleecombat()
{
	self endon( "end_melee" );
	self endon( "killanimscript" );
/#
	assert( canmeleeanyrange() );
#/
	self orientmode( "face enemy" );
	if ( is_true( self.sliding_on_goo ) )
	{
		self animmode( "slide" );
	}
	else
	{
		self animmode( "zonly_physics" );
	}
	for ( ;; )
	{
		if ( isDefined( self.marked_for_death ) )
		{
			return;
		}
		if ( isDefined( self.enemy ) )
		{
			angles = vectorToAngle( self.enemy.origin - self.origin );
			self orientmode( "face angle", angles[ 1 ] );
		}
		if ( isDefined( self.zmb_vocals_attack ) )
		{
			self playsound( self.zmb_vocals_attack );
		}
		if ( isDefined( self.nochangeduringmelee ) && self.nochangeduringmelee )
		{
			self.safetochangescript = 0;
		}
		if ( isDefined( self.is_inert ) && self.is_inert )
		{
			return;
		}
		set_zombie_melee_anim_state( self );
		if ( isDefined( self.melee_anim_func ) )
		{
			self thread [[ self.melee_anim_func ]]();
		}
		while ( 1 )
		{
			self waittill( "melee_anim", note );
			if ( note == "end" )
			{
				break;
			}
			else if ( note == "fire" )
			{
				if ( !isDefined( self.enemy ) )
				{
					break;
				}
				else if ( isDefined( self.dont_die_on_me ) && self.dont_die_on_me )
				{
					break;
				}
				else
				{
					self.enemy notify( "melee_swipe" );
					oldhealth = self.enemy.health;
					self melee();
					if ( !isDefined( self.enemy ) )
					{
						break;
					}
					else if ( self.enemy.health >= oldhealth )
					{
						if ( isDefined( self.melee_miss_func ) )
						{
							self [[ self.melee_miss_func ]]();
							break;
						}
						else
						{
							if ( isDefined( level.melee_miss_func ) )
							{
								self [[ level.melee_miss_func ]]();
							}
						}
					}
/#
					if ( getDvarInt( #"7F11F572" ) )
					{
						if ( self.enemy.health < oldhealth )
						{
							zombie_eye = self geteye();
							player_eye = self.enemy geteye();
							trace = bullettrace( zombie_eye, player_eye, 1, self );
							hitpos = trace[ "position" ];
							dist = distance( zombie_eye, hitpos );
							iprintln( "melee HIT " + dist );
#/
						}
					}
					continue;
				}
				else
				{
					if ( note == "stop" )
					{
						if ( !cancontinuetomelee() )
						{
							break;
						}
					}
				}
				else
				{
				}
			}
		}
		if ( is_true( self.sliding_on_goo ) )
		{
			self orientmode( "face enemy" );
		}
		else self orientmode( "face default" );
		if ( isDefined( self.nochangeduringmelee ) || self.nochangeduringmelee && is_true( self.sliding_on_goo ) )
		{
			if ( isDefined( self.enemy ) )
			{
				dist_sq = distancesquared( self.origin, self.enemy.origin );
				if ( dist_sq > ( self.meleeattackdist * self.meleeattackdist ) )
				{
					self.safetochangescript = 1;
					wait 0,1;
					break;
				}
				else }
			else self.safetochangescript = 1;
			wait 0,1;
			break;
		}
		else
		{
		}
	}
	if ( is_true( self.sliding_on_goo ) )
	{
		self animmode( "slide" );
	}
	else self animmode( "none" );
	self thread maps/mp/animscripts/zm_combat::main();
}

cancontinuetomelee()
{
	return canmeleeinternal( "already started" );
}

canmeleeanyrange()
{
	return canmeleeinternal( "any range" );
}

canmeleedesperate()
{
	return canmeleeinternal( "long range" );
}

canmelee()
{
	return canmeleeinternal( "normal" );
}

canmeleeinternal( state )
{
	if ( !issentient( self.enemy ) )
	{
		return 0;
	}
	if ( !isalive( self.enemy ) )
	{
		return 0;
	}
	if ( isDefined( self.disablemelee ) )
	{
/#
		assert( self.disablemelee );
#/
		return 0;
	}
	yaw = abs( getyawtoenemy() );
	if ( yaw > 60 || state != "already started" && yaw > 110 )
	{
		return 0;
	}
	enemypoint = self.enemy getorigin();
	vectoenemy = enemypoint - self.origin;
	self.enemydistancesq = lengthsquared( vectoenemy );
	if ( self.enemydistancesq <= anim.meleerangesq )
	{
		if ( !ismeleepathclear( vectoenemy, enemypoint ) )
		{
			return 0;
		}
		return 1;
	}
	if ( state != "any range" )
	{
		chargerangesq = anim.chargerangesq;
		if ( state == "long range" )
		{
			chargerangesq = anim.chargelongrangesq;
		}
		if ( self.enemydistancesq > chargerangesq )
		{
			return 0;
		}
	}
	if ( state == "already started" )
	{
		return 0;
	}
	if ( isDefined( self.check_melee_path ) && self.check_melee_path )
	{
		if ( !ismeleepathclear( vectoenemy, enemypoint ) )
		{
			self notify( "melee_path_blocked" );
			return 0;
		}
	}
	if ( isDefined( level.can_melee ) )
	{
		if ( !( self [[ level.can_melee ]]() ) )
		{
			return 0;
		}
	}
	return 1;
}

ismeleepathclear( vectoenemy, enemypoint )
{
	dirtoenemy = vectornormalize( ( vectoenemy[ 0 ], vectoenemy[ 1 ], 0 ) );
	meleepoint = enemypoint - ( dirtoenemy[ 0 ] * 28, dirtoenemy[ 1 ] * 28, 0 );
	if ( !self isingoal( meleepoint ) )
	{
		return 0;
	}
	if ( self maymovetopoint( meleepoint ) )
	{
		return 1;
	}
	trace1 = bullettrace( self.origin + vectorScale( ( 0, 0, 1 ), 20 ), meleepoint + vectorScale( ( 0, 0, 1 ), 20 ), 1, self );
	trace2 = bullettrace( self.origin + vectorScale( ( 0, 0, 1 ), 72 ), meleepoint + vectorScale( ( 0, 0, 1 ), 72 ), 1, self );
	if ( isDefined( trace1[ "fraction" ] ) && trace1[ "fraction" ] == 1 && isDefined( trace2[ "fraction" ] ) && trace2[ "fraction" ] == 1 )
	{
		return 1;
	}
	if ( isDefined( trace1[ "entity" ] ) && trace1[ "entity" ] == self.enemy && isDefined( trace2[ "entity" ] ) && trace2[ "entity" ] == self.enemy )
	{
		return 1;
	}
	if ( isDefined( level.zombie_melee_in_water ) && level.zombie_melee_in_water )
	{
		if ( isDefined( trace1[ "surfacetype" ] ) && trace1[ "surfacetype" ] == "water" && isDefined( trace2[ "fraction" ] ) && trace2[ "fraction" ] == 1 )
		{
			return 1;
		}
	}
	return 0;
}

set_zombie_melee_anim_state( zombie )
{
	if ( isDefined( level.melee_anim_state ) )
	{
		melee_anim_state = self [[ level.melee_anim_state ]]();
	}
	if ( !isDefined( melee_anim_state ) )
	{
		if ( !zombie.has_legs && zombie.a.gib_ref == "no_legs" )
		{
			melee_anim_state = "zm_stumpy_melee";
			break;
	}
	else
	{
		switch( zombie.zombie_move_speed )
		{
			case "walk":
				melee_anim_state = append_missing_legs_suffix( "zm_walk_melee" );
				break;
			case "run":
			case "sprint":
			default:
				melee_anim_state = append_missing_legs_suffix( "zm_run_melee" );
				break;
		}
	}
}
zombie setanimstatefromasd( melee_anim_state );
}
