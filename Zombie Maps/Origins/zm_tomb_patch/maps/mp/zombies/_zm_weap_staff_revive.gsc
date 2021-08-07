#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	onplayerconnect_callback( ::onplayerconnect );
}

onplayerconnect()
{
	self thread onplayerspawned();
}

onplayerspawned()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "spawned_player" );
		self thread watch_staff_revive_fired();
	}
}

watch_staff_revive_fired()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "missile_fire", e_projectile, str_weapon );
		while ( str_weapon != "staff_revive_zm" )
		{
			continue;
		}
		self waittill( "projectile_impact", e_ent, v_explode_point, n_radius, str_name, n_impact );
		self thread staff_revive_impact( v_explode_point );
	}
}

staff_revive_impact( v_explode_point )
{
	self endon( "disconnect" );
	e_closest_player = undefined;
	n_closest_dist_sq = 1024;
	playsoundatposition( "wpn_revivestaff_proj_impact", v_explode_point );
	a_e_players = getplayers();
	_a70 = a_e_players;
	_k70 = getFirstArrayKey( _a70 );
	while ( isDefined( _k70 ) )
	{
		e_player = _a70[ _k70 ];
		if ( e_player == self || !e_player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
		}
		else
		{
			n_dist_sq = distancesquared( v_explode_point, e_player.origin );
			if ( n_dist_sq < n_closest_dist_sq )
			{
				e_closest_player = e_player;
			}
		}
		_k70 = getNextArrayKey( _a70, _k70 );
	}
	if ( isDefined( e_closest_player ) )
	{
		e_closest_player notify( "remote_revive" );
		e_closest_player playsoundtoplayer( "wpn_revivestaff_revive_plr", e_player );
		self notify( "revived_player_with_upgraded_staff" );
	}
}
