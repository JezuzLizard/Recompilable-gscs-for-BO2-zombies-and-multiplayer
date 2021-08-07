#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

main_start()
{
}

main_end()
{
}

player_in_exploit_area( player_trigger_origin, player_trigger_radius )
{
	if ( distancesquared( player_trigger_origin, self.origin ) < ( player_trigger_radius * player_trigger_radius ) )
	{
/#
		iprintlnbold( "player exploit detectect" );
#/
		return 1;
	}
	return 0;
}

path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point )
{
	spawnflags = 9;
	zombie_trigger = spawn( "trigger_radius", zombie_trigger_origin, spawnflags, zombie_trigger_radius, zombie_trigger_height );
	zombie_trigger setteamfortrigger( level.zombie_team );
/#
	thread debug_exploit( zombie_trigger_origin, zombie_trigger_radius, player_trigger_origin, player_trigger_radius, zombie_goto_point );
#/
	while ( 1 )
	{
		zombie_trigger waittill( "trigger", who );
		if ( !is_true( who.reroute ) )
		{
			who thread exploit_reroute( zombie_trigger, player_trigger_origin, player_trigger_radius, zombie_goto_point );
		}
	}
}

exploit_reroute( zombie_trigger, player_trigger_origin, player_trigger_radius, zombie_goto_point )
{
	self endon( "death" );
	self.reroute = 1;
	while ( 1 )
	{
		if ( self istouching( zombie_trigger ) )
		{
			player = self.favoriteenemy;
			if ( isDefined( player ) && player player_in_exploit_area( player_trigger_origin, player_trigger_radius ) )
			{
				self.reroute_origin = zombie_goto_point;
			}
			else
			{
			}
		}
		else wait 0,2;
	}
	self.reroute = 0;
}

debug_exploit( player_origin, player_radius, enemy_origin, enemy_radius, zombie_goto_point )
{
/#
	while ( isDefined( self ) )
	{
		circle( player_origin, player_radius, ( 1, 1, 0 ), 0, 1, 1 );
		circle( enemy_origin, enemy_radius, ( 1, 1, 0 ), 0, 1, 1 );
		line( player_origin, enemy_origin, ( 1, 1, 0 ), 1 );
		line( enemy_origin, zombie_goto_point, ( 1, 1, 0 ), 1 );
		wait 0,05;
#/
	}
}
