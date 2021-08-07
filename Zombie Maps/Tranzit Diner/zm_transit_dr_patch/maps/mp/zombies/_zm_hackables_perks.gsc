#include maps/mp/zombies/_zm_equip_hacker;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

hack_perks()
{
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	i = 0;
	while ( i < vending_triggers.size )
	{
		struct = spawnstruct();
		machine = getentarray( vending_triggers[ i ].target, "targetname" );
		struct.origin = machine[ 0 ].origin + ( anglesToRight( machine[ 0 ].angles ) * 18 ) + vectorScale( ( 0, 0, 1 ), 48 );
		struct.radius = 48;
		struct.height = 64;
		struct.script_float = 5;
		while ( !isDefined( vending_triggers[ i ].cost ) )
		{
			wait 0,05;
		}
		struct.script_int = int( vending_triggers[ i ].cost * -1 );
		struct.perk = vending_triggers[ i ];
		vending_triggers[ i ].hackable = struct;
		maps/mp/zombies/_zm_equip_hacker::register_pooled_hackable_struct( struct, ::perk_hack, ::perk_hack_qualifier );
		i++;
	}
	level._solo_revive_machine_expire_func = ::solo_revive_expire_func;
}

solo_revive_expire_func()
{
	if ( isDefined( self.hackable ) )
	{
		maps/mp/zombies/_zm_equip_hacker::deregister_hackable_struct( self.hackable );
		self.hackable = undefined;
	}
}

perk_hack_qualifier( player )
{
	if ( isDefined( player._retain_perks ) )
	{
		return 0;
	}
	if ( player hasperk( self.perk.script_noteworthy ) )
	{
		return 1;
	}
	return 0;
}

perk_hack( hacker )
{
	if ( flag( "solo_game" ) && self.perk.script_noteworthy == "specialty_quickrevive" )
	{
		hacker.lives--;

	}
	hacker notify( self.perk.script_noteworthy + "_stop" );
	hacker playsoundtoplayer( "evt_perk_throwup", hacker );
	while ( isDefined( hacker.perk_hud ) )
	{
		keys = getarraykeys( hacker.perk_hud );
		i = 0;
		while ( i < hacker.perk_hud.size )
		{
			hacker.perk_hud[ keys[ i ] ].x = i * 30;
			i++;
		}
	}
}
