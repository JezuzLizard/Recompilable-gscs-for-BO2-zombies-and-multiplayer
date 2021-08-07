#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

zombie_tracking_init()
{
	level.zombie_respawned_health = [];
	if ( !isDefined( level.zombie_tracking_dist ) )
	{
		level.zombie_tracking_dist = 1500;
	}
	if ( !isDefined( level.zombie_tracking_wait ) )
	{
		level.zombie_tracking_wait = 10;
	}
	for ( ;; )
	{
		while ( 1 )
		{
			zombies = get_round_enemy_array();
			if ( !isDefined( zombies ) || isDefined( level.ignore_distance_tracking ) && level.ignore_distance_tracking )
			{
				wait level.zombie_tracking_wait;
			}
		}
		else i = 0;
		while ( i < zombies.size )
		{
			if ( isDefined( zombies[ i ] ) && isDefined( zombies[ i ].ignore_distance_tracking ) && !zombies[ i ].ignore_distance_tracking )
			{
				zombies[ i ] thread delete_zombie_noone_looking( level.zombie_tracking_dist );
			}
			i++;
		}
		wait level.zombie_tracking_wait;
	}
}

delete_zombie_noone_looking( how_close )
{
	self endon( "death" );
	if ( !isDefined( how_close ) )
	{
		how_close = 1000;
	}
	distance_squared_check = how_close * how_close;
	too_far_dist = distance_squared_check * 3;
	if ( isDefined( level.zombie_tracking_too_far_dist ) )
	{
		too_far_dist = level.zombie_tracking_too_far_dist * level.zombie_tracking_too_far_dist;
	}
	self.inview = 0;
	self.player_close = 0;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].sessionstate == "spectator" )
		{
			i++;
			continue;
		}
		else if ( isDefined( level.only_track_targeted_players ) )
		{
			if ( !isDefined( self.favoriteenemy ) || self.favoriteenemy != players[ i ] )
			{
				i++;
				continue;
			}
		}
		else
		{
			can_be_seen = self player_can_see_me( players[ i ] );
			if ( can_be_seen && distancesquared( self.origin, players[ i ].origin ) < too_far_dist )
			{
				self.inview++;
			}
			if ( distancesquared( self.origin, players[ i ].origin ) < distance_squared_check )
			{
				self.player_close++;
			}
		}
		i++;
	}
	wait 0,1;
	if ( self.inview == 0 && self.player_close == 0 )
	{
		if ( !isDefined( self.animname ) || isDefined( self.animname ) && self.animname != "zombie" )
		{
			return;
		}
		if ( isDefined( self.electrified ) && self.electrified == 1 )
		{
			return;
		}
		if ( isDefined( self.in_the_ground ) && self.in_the_ground == 1 )
		{
			return;
		}
		zombies = getaiarray( "axis" );
		if ( isDefined( self.damagemod ) && self.damagemod == "MOD_UNKNOWN" && self.health < self.maxhealth )
		{
			if ( isDefined( self.exclude_distance_cleanup_adding_to_total ) && !self.exclude_distance_cleanup_adding_to_total && isDefined( self.isscreecher ) && !self.isscreecher )
			{
				level.zombie_total++;
				level.zombie_respawned_health[ level.zombie_respawned_health.size ] = self.health;
			}
		}
		else
		{
			if ( ( zombies.size + level.zombie_total ) > 24 || ( zombies.size + level.zombie_total ) <= 24 && self.health >= self.maxhealth )
			{
				if ( isDefined( self.exclude_distance_cleanup_adding_to_total ) && !self.exclude_distance_cleanup_adding_to_total && isDefined( self.isscreecher ) && !self.isscreecher )
				{
					level.zombie_total++;
					if ( self.health < level.zombie_health )
					{
						level.zombie_respawned_health[ level.zombie_respawned_health.size ] = self.health;
					}
				}
			}
		}
		self maps/mp/zombies/_zm_spawner::reset_attack_spot();
		self notify( "zombie_delete" );
		self delete();
		recalc_zombie_array();
	}
}

player_can_see_me( player )
{
	playerangles = player getplayerangles();
	playerforwardvec = anglesToForward( playerangles );
	playerunitforwardvec = vectornormalize( playerforwardvec );
	banzaipos = self.origin;
	playerpos = player getorigin();
	playertobanzaivec = banzaipos - playerpos;
	playertobanzaiunitvec = vectornormalize( playertobanzaivec );
	forwarddotbanzai = vectordot( playerunitforwardvec, playertobanzaiunitvec );
	if ( forwarddotbanzai >= 1 )
	{
		anglefromcenter = 0;
	}
	else if ( forwarddotbanzai <= -1 )
	{
		anglefromcenter = 180;
	}
	else
	{
		anglefromcenter = acos( forwarddotbanzai );
	}
	playerfov = getDvarFloat( "cg_fov" );
	banzaivsplayerfovbuffer = getDvarFloat( "g_banzai_player_fov_buffer" );
	if ( banzaivsplayerfovbuffer <= 0 )
	{
		banzaivsplayerfovbuffer = 0,2;
	}
	playercanseeme = anglefromcenter <= ( ( playerfov * 0,5 ) * ( 1 - banzaivsplayerfovbuffer ) );
	return playercanseeme;
}
