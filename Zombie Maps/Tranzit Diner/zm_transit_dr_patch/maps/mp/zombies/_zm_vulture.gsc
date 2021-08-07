#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init_vulture()
{
	setdvarint( "zombies_debug_vulture_perk", 1 );
	setdvarint( "zombies_perk_vulture_pickup_time", 12 );
	setdvarint( "zombies_perk_vulture_drop_chance", 25 );
	setdvarint( "zombies_perk_vulture_ammo_chance", 40 );
	setdvarint( "zombies_perk_vulture_points_chance", 50 );
	setdvarint( "zombies_perk_vulture_stink_chance", 10 );
}

enable_vulture_perk_for_level()
{
	level.zombiemode_using_vulture_perk = 1;
}

give_vulture_perk()
{
	iprintln( "player " + self getentitynumber() + " has vulture perk!" );
	self.hasperkspecialtyvulture = 1;
}

take_vulture_perk()
{
	iprintln( "player " + self getentitynumber() + " has lost vulture perk!" );
	self.hasperkspecialtyvulture = undefined;
}

do_vulture_death( player )
{
	if ( isDefined( self ) )
	{
		self thread _do_vulture_death( player );
	}
}

_do_vulture_death( player )
{
	if ( should_do_vulture_drop() )
	{
		str_bonus = get_vulture_drop_type();
		str_identifier = "_" + self getentitynumber() + "_" + getTime();
		player thread show_debug_info( self.origin, str_identifier, str_bonus );
		self thread check_vulture_drop_pickup( self.origin, player, str_identifier, str_bonus );
	}
}

should_do_vulture_drop()
{
	n_roll = randomint( 100 );
	b_should_drop = n_roll > ( 100 - getDvarInt( #"70E3B3FA" ) );
	return b_should_drop;
}

get_vulture_drop_type()
{
	n_chance_ammo = getDvarInt( #"F75E07AF" );
	n_chance_points = getDvarInt( #"D7BCDBE2" );
	n_chance_stink = getDvarInt( #"4918C38E" );
	n_total_weight = n_chance_ammo + n_chance_points + n_chance_stink;
	n_cutoff_ammo = n_chance_ammo;
	n_cutoff_points = n_chance_ammo + n_chance_points;
	n_roll = randomint( n_total_weight );
	if ( n_roll < n_cutoff_ammo )
	{
		str_bonus = "ammo";
	}
	else if ( n_roll > n_cutoff_ammo && n_roll < n_cutoff_points )
	{
		str_bonus = "points";
	}
	else
	{
		str_bonus = "stink";
	}
	return str_bonus;
}

show_debug_info( v_drop_point, str_identifier, str_bonus )
{
/#
	while ( getDvarInt( #"38E68F2B" ) )
	{
		self endon( str_identifier );
		iprintln( "zombie dropped " + str_bonus );
		i = 0;
		while ( i < ( getDvarInt( #"34FA67DE" ) * 20 ) )
		{
			circle( v_drop_point, 32, get_debug_circle_color( str_bonus ), 0, 1, 1 );
			wait 0,05;
			i++;
#/
		}
	}
}

get_debug_circle_color( str_bonus )
{
	switch( str_bonus )
	{
		case "ammo":
			v_color = ( 1, 1, 1 );
			break;
		case "points":
			v_color = ( 1, 1, 1 );
			break;
		case "stink":
			v_color = ( 1, 1, 1 );
			break;
		default:
			v_color = ( 1, 1, 1 );
			break;
	}
	return v_color;
}

check_vulture_drop_pickup( v_drop_origin, player, str_identifier, str_bonus )
{
	player endon( "death" );
	player endon( "disconnect" );
	b_collected_vulture = 0;
	n_times_to_check = int( getDvarInt( #"34FA67DE" ) / 0,25 );
	i = 0;
	while ( i < n_times_to_check )
	{
		if ( distancesquared( v_drop_origin, player.origin ) < 1024 )
		{
			b_collected_vulture = 1;
			player notify( str_identifier );
			break;
		}
		else
		{
			wait 0,25;
			i++;
		}
	}
	if ( b_collected_vulture )
	{
		player give_vulture_bonus( str_bonus );
	}
}

give_vulture_bonus( str_bonus )
{
	switch( str_bonus )
	{
		case "ammo":
			self give_bonus_ammo();
			break;
		case "points":
			self give_bonus_points();
			break;
		case "stink":
			self give_bonus_stink();
			break;
		default:
/#
			assert( "invalid bonus string '" + str_bonus + "' used in give_vulture_bonus()!" );
#/
			break;
	}
}

give_bonus_ammo()
{
	str_weapon_current = self getcurrentweapon();
	if ( str_weapon_current != "none" )
	{
		n_ammo_count_current = self getweaponammostock( str_weapon_current );
		n_ammo_count_max = weaponmaxammo( str_weapon_current );
		n_bullets_refunded = int( n_ammo_count_max * 0,05 );
		self setweaponammostock( str_weapon_current, n_ammo_count_current + n_bullets_refunded );
/#
		if ( getDvarInt( #"38E68F2B" ) )
		{
			iprintln( ( str_weapon_current + " bullets given: " ) + n_bullets_refunded );
#/
		}
	}
}

give_bonus_points()
{
	self maps/mp/zombies/_zm_score::player_add_points( "vulture", 5 );
}

give_bonus_stink()
{
	iprintln( "zombie stink" );
}
