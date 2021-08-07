#include maps/mp/zombies/_zm_spawner;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zombies/_zm_ai_mechz;
#include maps/mp/zombies/_zm_ai_mechz_dev;
#include maps/mp/zm_tomb_tank;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_net;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_zonemgr;

#using_animtree( "mechz_claw" );

mechz_in_range_for_jump()
{
	if ( !isDefined( self.jump_pos ) )
	{
/#
		iprintln( "\nMZ Error: Trying to jump without valid jump_pos\n" );
#/
		self.jump_requested = 0;
		return 0;
	}
	dist = distancesquared( self.origin, self.jump_pos.origin );
	if ( dist <= 100 )
	{
		return 1;
	}
	return 0;
}

mechz_jump_think( spawn_pos )
{
	self endon( "death" );
	self endon( "stop_jump_think" );
	self.closest_jump_point = spawn_pos;
	self.goal_pos = self.origin;
	self setgoalpos( self.goal_pos );
	self thread mechz_jump_stuck_watcher();
	while ( 1 )
	{
		while ( isDefined( self.jump_requested ) && self.jump_requested )
		{
			if ( !self mechz_should_jump() )
			{
				self.jump_requested = 0;
				self.jump_pos = undefined;
			}
			wait 1;
		}
		while ( !isDefined( self.ai_state ) || self.ai_state != "find_flesh" )
		{
			wait 0,05;
		}
		while ( isDefined( self.not_interruptable ) && self.not_interruptable )
		{
			wait 0,05;
		}
/#
		while ( isDefined( self.force_behavior ) && self.force_behavior )
		{
			wait 0,05;
#/
		}
		if ( self mechz_should_jump() )
		{
			self.jump_requested = 1;
			self.jump_pos = get_closest_mechz_spawn_pos( self.origin );
			if ( !isDefined( self.jump_pos ) )
			{
				self.jump_requested = 0;
			}
		}
		wait 1;
	}
}

watch_for_riot_shield_melee()
{
	self endon( "new_stuck_watcher" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "item_attack" );
/#
		if ( getDvarInt( #"E7121222" ) > 1 )
		{
			println( "\n\tMZ: Resetting fail count because of item attack\n" );
#/
		}
		self.fail_count = 0;
	}
}

watch_for_valid_melee()
{
	self endon( "new_stuck_watcher" );
	self endon( "death" );
	while ( 1 )
	{
		self waittillmatch( "melee_anim" );
		return "end";
		if ( isDefined( self.favoriteenemy ) && distancesquared( self.origin, self.favoriteenemy.origin ) < 16384 )
		{
/#
			if ( getDvarInt( #"E7121222" ) > 1 )
			{
				println( "\n\tMZ: Resetting fail count because of melee\n" );
#/
			}
			self.fail_count = 0;
		}
	}
}

mechz_jump_stuck_watcher()
{
	self notify( "new_stuck_watcher" );
	self endon( "death" );
	self endon( "new_stuck_watcher" );
	self.fail_count = 0;
	self thread watch_for_valid_melee();
	self thread watch_for_riot_shield_melee();
	while ( 1 )
	{
		while ( !isDefined( self.goal_pos ) )
		{
			wait 0,05;
		}
		while ( isDefined( self.not_interruptable ) && self.not_interruptable )
		{
			wait 0,05;
		}
		while ( isDefined( self.ai_state ) && self.ai_state != "find_flesh" )
		{
			wait 0,05;
		}
/#
		while ( isDefined( self.force_behavior ) && self.force_behavior )
		{
			wait 0,05;
#/
		}
		if ( !findpath( self.origin, self.goal_pos, self, 0, 0 ) )
		{
/#
			if ( getDvarInt( #"E7121222" ) > 1 )
			{
				println( "\n\tMZ: Incrementing fail count\n" );
#/
			}
/#
			println( "Mechz could not path to goal_pos " + self.goal_pos );
#/
			self.fail_count++;
		}
		else
		{
/#
			if ( getDvarInt( #"E7121222" ) > 1 )
			{
				println( "\n\tMZ: Resetting fail count because of good path\n" );
#/
			}
			self.fail_count = 0;
		}
		wait 1;
	}
}

mechz_should_jump()
{
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\n\tMZ: Checking should jump\n" );
#/
	}
	if ( !isDefined( self.favoriteenemy ) )
	{
/#
		if ( getDvarInt( #"E7121222" ) > 1 )
		{
			println( "\n\t\tMZ: Not doing jump because has no enemy\n" );
#/
		}
		return 0;
	}
	dist = distancesquared( self.origin, self.favoriteenemy.origin );
	if ( dist >= level.mechz_jump_dist_threshold )
	{
/#
		if ( getDvarInt( #"E7121222" ) > 1 )
		{
			println( "\n\t\tMZ: Doing jump because target is too far\n" );
#/
		}
		return 1;
	}
	if ( self.fail_count >= level.mechz_failed_paths_to_jump )
	{
/#
		if ( getDvarInt( #"E7121222" ) > 1 )
		{
			println( "\n\t\tMZ: Doing jump because has failed too many pathfind checks\n" );
#/
		}
		return 1;
	}
	return 0;
}

mechz_do_jump( wait_for_stationary_tank )
{
	self endon( "death" );
	self endon( "kill_jump" );
/#
	if ( getDvarInt( #"E7121222" ) > 0 )
	{
		println( "\nMZ: Doing Jump-Teleport\n" );
#/
	}
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\nMZ: Jump setting not interruptable\n" );
#/
	}
	self.not_interruptable = 1;
	self setfreecameralockonallowed( 0 );
	self thread mechz_jump_vo();
	self animscripted( self.origin, self.angles, "zm_fly_out" );
	self maps/mp/animscripts/zm_shared::donotetracks( "jump_anim" );
	self ghost();
	self.mechz_hidden = 1;
	if ( isDefined( self.m_claw ) )
	{
		self.m_claw ghost();
	}
	if ( self.fx_field )
	{
		self.fx_field_old = self.fx_field;
	}
	self thread maps/mp/zombies/_zm_spawner::zombie_eye_glow_stop();
	self fx_cleanup();
	self animscripted( self.origin, self.angles, "zm_fly_hover" );
	wait level.mechz_jump_delay;
	if ( isDefined( wait_for_stationary_tank ) && wait_for_stationary_tank )
	{
		level.vh_tank ent_flag_waitopen( "tank_moving" );
	}
	self notsolid();
	closest_jump_point = get_best_mechz_spawn_pos( 1 );
	if ( isDefined( closest_jump_point ) )
	{
		self.closest_jump_point = closest_jump_point;
	}
	if ( !isDefined( self.closest_jump_point.angles ) )
	{
		self.closest_jump_point.angles = ( 0, 0, 0 );
	}
	self animscripted( self.closest_jump_point.origin, self.closest_jump_point.angles, "zm_fly_in" );
	self solid();
	self.mechz_hidden = 0;
	self show();
	self.fx_field = self.fx_field_old;
	self.fx_field_old = undefined;
	self setclientfield( "mechz_fx", self.fx_field );
	self thread maps/mp/zombies/_zm_spawner::zombie_eye_glow();
	if ( isDefined( self.m_claw ) )
	{
		self.m_claw show();
	}
	self maps/mp/animscripts/zm_shared::donotetracks( "jump_anim" );
	self.not_interruptable = 0;
	self setfreecameralockonallowed( 1 );
/#
	if ( getDvarInt( #"E7121222" ) > 1 )
	{
		println( "\nMZ: Jump clearing not interruptable\n" );
#/
	}
	mechz_jump_cleanup();
}

mechz_kill_jump_watcher()
{
	self endon( "jump_complete" );
	self waittill_either( "death", "kill_jump" );
	self mechz_jump_cleanup();
}

mechz_jump_cleanup()
{
	self.fx_field &= 128;
	self setclientfield( "mechz_fx", self.fx_field );
	self stopanimscripted();
	self notify( "jump_complete" );
}
