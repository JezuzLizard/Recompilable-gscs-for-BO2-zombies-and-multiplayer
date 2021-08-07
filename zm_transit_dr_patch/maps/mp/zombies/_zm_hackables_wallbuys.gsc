#include maps/mp/zombies/_zm_equip_hacker;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

hack_wallbuys()
{
	weapon_spawns = getentarray( "weapon_upgrade", "targetname" );
	i = 0;
	while ( i < weapon_spawns.size )
	{
		if ( weapontype( weapon_spawns[ i ].zombie_weapon_upgrade ) == "grenade" )
		{
			i++;
			continue;
		}
		else if ( weapontype( weapon_spawns[ i ].zombie_weapon_upgrade ) == "melee" )
		{
			i++;
			continue;
		}
		else if ( weapontype( weapon_spawns[ i ].zombie_weapon_upgrade ) == "mine" )
		{
			i++;
			continue;
		}
		else if ( weapontype( weapon_spawns[ i ].zombie_weapon_upgrade ) == "bomb" )
		{
			i++;
			continue;
		}
		else
		{
			struct = spawnstruct();
			struct.origin = weapon_spawns[ i ].origin;
			struct.radius = 48;
			struct.height = 48;
			struct.script_float = 2;
			struct.script_int = 3000;
			struct.wallbuy = weapon_spawns[ i ];
			maps/mp/zombies/_zm_equip_hacker::register_pooled_hackable_struct( struct, ::wallbuy_hack );
		}
		i++;
	}
	bowie_triggers = getentarray( "bowie_upgrade", "targetname" );
	array_thread( bowie_triggers, ::maps/mp/zombies/_zm_equip_hacker::hide_hint_when_hackers_active );
}

wallbuy_hack( hacker )
{
	self.wallbuy.hacked = 1;
	model = getent( self.wallbuy.target, "targetname" );
	model rotateroll( 180, 0,5 );
	maps/mp/zombies/_zm_equip_hacker::deregister_hackable_struct( self );
}
