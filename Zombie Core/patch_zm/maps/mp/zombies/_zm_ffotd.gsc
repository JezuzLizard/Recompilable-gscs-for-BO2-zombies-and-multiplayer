#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

main_start() //checked matches cerberus output
{
	mapname = tolower( getDvar( "mapname" ) );
	gametype = getDvar( "ui_gametype" );
	if ( tolower( getDvar( "mapname" ) ) == "zm_transit" && getDvar( "ui_gametype" ) == "zclassic" )
	{
		level thread transit_navcomputer_remove_card_on_success();
	}
	if ( tolower( getDvar( "mapname" ) ) == "zm_prison" && getDvar( "ui_gametype" ) == "zgrief" )
	{
		level.zbarrier_script_string_sets_collision = 1;
	}
	if ( mapname != "zm_transit" && mapname == "zm_highrise" && gametype == "zclassic" )
	{
		level.pers_upgrade_sniper = 1;
		level.pers_upgrade_pistol_points = 1;
		level.pers_upgrade_perk_lose = 1;
		level.pers_upgrade_double_points = 1;
		level.pers_upgrade_nube = 1;
	}
}

main_end() //checked matches cerberus output
{
	onfinalizeinitialization_callback( ::force_navcomputer_trigger_think );
	level.original_melee_miss_func = level.melee_miss_func;
	level.melee_miss_func = ::ffotd_melee_miss_func;
}

force_navcomputer_trigger_think() //checked changed to match cerberus output
{
	if ( !isDefined( level.zombie_include_buildables ) || !level.zombie_include_buildables.size )
	{
		return;
	}
	foreach ( buildable in level.zombie_include_buildables )
	{
		if ( buildable.name == "sq_common" )
		{
			if ( isDefined( buildable.triggerthink ) )
			{
				level [[ buildable.triggerthink ]]();
				trigger_think_func = buildable.triggerthink;
				buildable.triggerthink = undefined;
				level waittill( "buildables_setup" );
				buildable.triggerthink = trigger_think_func;
				return;
			}
		}
	}
}

transit_navcomputer_remove_card_on_success() //checked changed to match cerberus output
{
	wait_for_buildable( "sq_common" );
	wait_network_frame();
	trig_pos = getstruct( "sq_common_key", "targetname" );
	trigs = getentarray( "trigger_radius_use", "classname" );
	nav_trig = undefined;
	foreach ( trig in trigs )
	{
		if ( trig.origin == trig_pos.origin )
		{
			nav_trig = trig;
		}
		_k81 = getNextArrayKey( _a81, _k81 );
	}
	if ( isDefined( nav_trig ) )
	{
		while ( 1 )
		{
			nav_trig waittill( "trigger", who );
			if ( isplayer( who ) && is_player_valid( who ) && does_player_have_correct_navcard( who ) )
			{
				break;
			}
		}
		players = get_players();
		foreach ( player in players )
		{
			player maps/mp/zombies/_zm_stats::set_global_stat( level.navcard_needed, 0 );
		}
		level thread sq_refresh_player_navcard_hud();
	}
}

sq_refresh_player_navcard_hud() //checked changed to match cerberus output
{
	if ( !isDefined( level.navcards ) )
	{
		return;
	}
	players = get_players();
	foreach ( player in players )
	{
		navcard_bits = 0;
		for ( i = 0; i < level.navcards.size; i++ )
		{
			hasit = player maps/mp/zombies/_zm_stats::get_global_stat( level.navcards[ i ] );
			if ( isDefined( player.navcard_grabbed ) && player.navcard_grabbed == level.navcards[ i ] )
			{
				hasit = 1;
			}
			if ( hasit )
			{
				navcard_bits = navcard_bits + 1;
			}
		}
		wait_network_frame();
		player setclientfield( "navcard_held", 0 );
		if ( navcard_bits > 0 )
		{
			wait_network_frame();
			player setclientfield( "navcard_held", navcard_bits );
		}
	}
}

player_in_exploit_area( player_trigger_origin, player_trigger_radius )
{
	if ( distancesquared( player_trigger_origin, self.origin ) < player_trigger_radius * player_trigger_radius )
	{
	/*
/#
		iprintlnbold( "player exploit detected" );
#/
	*/
		return 1;
	}
	return 0;
}

path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point ) //checked matches cerberus output
{
	spawnflags = 9;
	zombie_trigger = spawn( "trigger_radius", zombie_trigger_origin, spawnflags, zombie_trigger_radius, zombie_trigger_height );
	zombie_trigger setteamfortrigger( level.zombie_team );
	/*
/#
	thread debug_exploit( zombie_trigger_origin, zombie_trigger_radius, player_trigger_origin, player_trigger_radius, zombie_goto_point );
#/
	*/
	while ( 1 )
	{
		zombie_trigger waittill( "trigger", who );
		if ( !is_true( who.reroute ) )
		{
			who thread exploit_reroute( zombie_trigger, player_trigger_origin, player_trigger_radius, zombie_goto_point );
		}
	}
}

exploit_reroute( zombie_trigger, player_trigger_origin, player_trigger_radius, zombie_goto_point ) //checked matches cerberus output
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
				break;
			}
		}
		else
		{
			break;
		}
		wait 0.2;
	}
	self.reroute = 0;
}

debug_exploit( player_origin, player_radius, enemy_origin, enemy_radius, zombie_goto_point ) //dev call commented out
{
/*
/#
	while ( isDefined( self ) )
	{
		circle( player_origin, player_radius, ( 1, 1, 0 ), 0, 1, 1 );
		circle( enemy_origin, enemy_radius, ( 1, 1, 0 ), 0, 1, 1 );
		line( player_origin, enemy_origin, ( 1, 1, 0 ), 1 );
		line( enemy_origin, zombie_goto_point, ( 1, 1, 0 ), 1 );
		wait 0.05;
#/
	}
*/
}

ffotd_melee_miss_func() //checked matches cerberus output
{
	if ( isDefined( self.enemy ) )
	{
		if ( isplayer( self.enemy ) && self.enemy getcurrentweapon() == "claymore_zm" )
		{
			dist_sq = distancesquared( self.enemy.origin, self.origin );
			melee_dist_sq = self.meleeattackdist * self.meleeattackdist;
			if ( dist_sq < melee_dist_sq )
			{
				self.enemy dodamage( self.meleedamage, self.origin, self, self, "none", "MOD_MELEE" );
				return;
			}
		}
	}
	if ( isDefined( level.original_melee_miss_func ) )
	{
		self [[ level.original_melee_miss_func ]]();
	}
}

