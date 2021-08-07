#include maps/mp/_utility;
#include common_scripts/utility;

isgrenadelauncherweapon( weapon )
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

isdumbrocketlauncherweapon( weapon )
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

isguidedrocketlauncherweapon( weapon )
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

isrocketlauncherweapon( weapon )
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

islauncherweapon( weapon )
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

isreducedteamkillweapon( weapon )
{
	switch( weapon )
	{
		case "planemortar_mp":
			return 1;
		default:
			return 0;
	}
}

ishackweapon( weapon )
{
	return 0;
}

ispistol( weapon )
{
	return isDefined( level.side_arm_array[ weapon ] );
}

isflashorstunweapon( weapon )
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

isflashorstundamage( weapon, meansofdeath )
{
	if ( isflashorstunweapon( weapon ) )
	{
		if ( meansofdeath != "MOD_GRENADE_SPLASH" )
		{
			return meansofdeath == "MOD_GAS";
		}
	}
}
