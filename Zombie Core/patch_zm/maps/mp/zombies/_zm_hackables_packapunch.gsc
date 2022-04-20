#include maps/mp/zombies/_zm_equip_hacker;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

hack_packapunch()
{
	vending_weapon_upgrade_trigger = getentarray( "specialty_weapupgrade", "script_noteworthy" );
	perk = getent( vending_weapon_upgrade_trigger[ 0 ].target, "targetname" );
	if ( isDefined( perk ) )
	{
		struct = spawnstruct();
		struct.origin = perk.origin + ( anglesToRight( perk.angles ) * 26 ) + vectorScale( ( 0, 0, 1 ), 48 );
		struct.radius = 48;
		struct.height = 48;
		struct.script_float = 5;
		struct.script_int = -1000;
		level._pack_hack_struct = struct;
		maps/mp/zombies/_zm_equip_hacker::register_pooled_hackable_struct( level._pack_hack_struct, ::packapunch_hack );
		level._pack_hack_struct pack_trigger_think();
	}
}

pack_trigger_think()
{
	if ( !flag_exists( "enter_nml" ) )
	{
		return;
	}
	while ( 1 )
	{
		flag_wait( "enter_nml" );
		self.script_int = -1000;
		while ( flag( "enter_nml" ) )
		{
			wait 1;
		}
	}
}

packapunch_hack( hacker )
{
	maps/mp/zombies/_zm_equip_hacker::deregister_hackable_struct( level._pack_hack_struct );
	level._pack_hack_struct.script_int = 0;
	level notify( "packapunch_hacked" );
}
