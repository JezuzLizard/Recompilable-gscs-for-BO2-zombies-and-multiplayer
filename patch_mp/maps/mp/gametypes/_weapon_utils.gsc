#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/_utility;
#include common_scripts/utility;

isgrenadelauncherweapon( weapon ) //checked matches cerberus output
{
	if ( getsubstr( weapon, 0, 3 ) == "gl_" )
	{
		return 1;
	}
	switch( weapon )
	{
		case "china_lake_mp":
		case "xm25_mp":
			return 1;
		default:
			return 0;
	}
}

isdumbrocketlauncherweapon( weapon ) //checked matches cerberus output
{
	switch( weapon )
	{
		case "m220_tow_mp":
		case "rpg_mp":
			return 1;
		default:
			return 0;
	}
}

isguidedrocketlauncherweapon( weapon ) //checked matches cerberus output
{
	switch( weapon )
	{
		case "fhj18_mp":
		case "javelin_mp":
		case "m202_flash_mp":
		case "m72_law_mp":
		case "smaw_mp":
			return 1;
		default:
			return 0;
	}
}

isrocketlauncherweapon( weapon ) //checked matches cerberus output
{
	if ( isdumbrocketlauncherweapon( weapon ) )
	{
		return 1;
	}
	if ( isguidedrocketlauncherweapon( weapon ) )
	{
		return 1;
	}
	return 0;
}

islauncherweapon( weapon ) //checked matches cerberus output
{
	if ( isrocketlauncherweapon( weapon ) )
	{
		return 1;
	}
	if ( isgrenadelauncherweapon( weapon ) )
	{
		return 1;
	}
	return 0;
}

ishackweapon( weapon ) //checked matches cerberus output
{
	if ( maps/mp/killstreaks/_killstreaks::iskillstreakweapon( weapon ) )
	{
		return 1;
	}
	if ( weapon == "briefcase_bomb_mp" )
	{
		return 1;
	}
	return 0;
}

ispistol( weapon ) //checked changed at own discretion
{
	if ( isDefined( level.side_arm_array[ weapon ] ) )
	{
		return 1;
	}
	return 0;
}

isflashorstunweapon( weapon ) //checked matches cerberus output
{
	if ( isDefined( weapon ) )
	{
		switch( weapon )
		{
			case "concussion_grenade_mp":
			case "flash_grenade_mp":
			case "proximity_grenade_aoe_mp":
			case "proximity_grenade_mp":
				return 1;
		}
	}
	return 0;
}

isflashorstundamage( weapon, meansofdeath ) //checked changed at own discretion
{
	if ( ( meansofdeath == "MOD_GAS" || meansofdeath == "MOD_GRENADE_SPLASH" ) && isflashorstunweapon( weapon ) )
	{
		return 1;
	}
	return 0;
}

