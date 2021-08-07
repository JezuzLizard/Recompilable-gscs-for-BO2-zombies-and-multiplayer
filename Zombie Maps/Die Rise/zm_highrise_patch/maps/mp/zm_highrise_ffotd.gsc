//checked includes match cerberus output
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

main_start() //checked matches cerberus output
{
	level thread spawned_collision_ffotd();
	level thread eject_player_trigger_init();
	level thread change_bad_spawner();
}

main_end() //checked matches cerberus output
{
	level thread eject_player_trigger();
}

spawned_collision_ffotd() //checked changed to match cerberus output
{
	precachemodel( "collision_wall_32x32x10_standard" );
	flag_wait( "start_zombie_round_logic" );
	if ( !is_true( level.optimise_for_splitscreen ) )
	{
		collision1 = spawn( "script_model", ( 2044, 499, 2893 ) );
		collision1 setmodel( "collision_wall_32x32x10_standard" );
		collision1.angles = vectorScale( ( 0, 1, 0 ), 330 );
		collision1 ghost();
		collision2 = spawn( "script_model", ( 2044, 499, 2925 ) );
		collision2 setmodel( "collision_wall_32x32x10_standard" );
		collision2.angles = vectorScale( ( 0, 1, 0 ), 330 );
		collision2 ghost();
		collision3 = spawn( "script_model", ( 1768, 1507, 3075 ) );
		collision3 setmodel( "collision_wall_256x256x10_standard" );
		collision3.angles = ( 0, 0, 0 );
		collision3 ghost();
		collision3b = spawn( "script_model", ( 1740, 1497, 3075 ) );
		collision3b setmodel( "collision_wall_256x256x10_standard" );
		collision3b.angles = ( 0, 0, 0 );
		collision3b ghost();
		collision3 = spawn( "script_model", ( 2054, 1455, 3440 ) );
		collision3 setmodel( "collision_wall_128x128x10_standard" );
		collision3.angles = ( 0, 0, 0 );
		collision3 ghost();
		collision4 = spawn( "script_model", ( 2257, 2374, 3101 ) );
		collision4 setmodel( "collision_wall_256x256x10_standard" );
		collision4.angles = vectorScale( ( 0, 1, 0 ), 270 );
		collision4 ghost();
		collision5 = spawn( "script_model", ( 3076, 1598, 2791 ) );
		collision5 setmodel( "collision_wall_256x256x10_standard" );
		collision5.angles = vectorScale( ( 1, 0, 0 ), 347.6 );
		collision5 ghost();
		collision6b = spawn( "script_model", ( 3693, 1840, 1897 ) );
		collision6b setmodel( "collision_wall_256x256x10_standard" );
		collision6b.angles = ( 0, 270, 12 );
		collision6b ghost();
		collision6c = spawn( "script_model", ( 3666, 1840, 2023 ) );
		collision6c setmodel( "collision_wall_256x256x10_standard" );
		collision6c.angles = ( 0, 270, 12 );
		collision6c ghost();
		collision7 = spawn( "script_model", ( 2157, 839, 3129 ) );
		collision7 setmodel( "collision_wall_128x128x10_standard" );
		collision7.angles = ( 0, 9.79996, -90 );
		collision7 ghost();
		collision7 = spawn( "script_model", ( 3594, 1708, 2247 ) );
		collision7 setmodel( "collision_wall_128x128x10_standard" );
		collision7.angles = ( 0, 270, 12 );
		collision7 ghost();
	}
}

eject_player_trigger_init() //checked matches cerberus output
{
	trig1 = spawn( "trigger_box", ( 3172, 1679, 1296.09 ), 0, 64, 10, 64 );
	trig1.angles = ( 0, 0, 0 );
	trig1.targetname = "eject_player_pos";
	trig1.point = spawn( "script_origin", ( 3266, 1703.5, 1325 ) );
	trig2 = spawn( "trigger_box", ( 3225.5, 1153, 1346.48 ), 0, 64, 10, 64 );
	trig2.angles = ( 0, 0, 0 );
	trig2.targetname = "eject_player_pos";
	trig2.point = spawn( "script_origin", ( 3074, 1137.5, 1282.26 ) );
	trig3 = spawn( "trigger_radius", ( 3583, 1964, 2751.95 ), 0, 30, 64 );
	trig3.angles = ( 0, 0, 0 );
	trig3.targetname = "eject_player_pos";
	trig3.point = spawn( "script_origin", ( 3590.2, 2068, 2720.34 ) );
}

eject_player_trigger() //checked matches cerberus output
{
	trigs = getentarray( "eject_player_pos", "targetname" );
	array_thread( trigs, ::player_eject_watcher );
}

player_eject_watcher() //checked matches cerberus output
{
	time = 0;
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( is_player_valid( who ) )
		{
			while ( who istouching( self ) )
			{
				time++;
				if ( time >= 6 )
				{
					if ( isDefined( self.point ) )
					{
						if ( !positionwouldtelefrag( self.point.origin ) )
						{
							who setorigin( self.point.origin );
							who playlocalsound( level.zmb_laugh_alias );
							who playrumbleonentity( "damage_light" );
							earthquake( 0.5, 0.5, who.origin, 100 );
							who thread ejected_overrun( self );
						}
					}
				}
				wait 1;
			}
			time = 0;
		}
		wait 0.1;
	}
}

ejected_overrun( trig ) //checked changed to match cerberus output
{
	if ( !isDefined( trig.ejected ) )
	{
		trig.ejected = 1;
	}
	else
	{
		trig.ejected++;
		if ( trig.ejected >= 3 )
		{
			primaries = self getweaponslistprimaries();
			foreach ( weapon in primaries )
			{
				self takeweapon( weapon );
			}
			lethal = self get_player_lethal_grenade();
			if ( isDefined( lethal ) && lethal != "" )
			{
				self takeweapon( lethal );
				maps/mp/zombies/_zm_weapons::unacquire_weapon_toggle( lethal );
			}
			tactical = self get_player_tactical_grenade();
			if ( isDefined( tactical ) && tactical != "" )
			{
				self takeweapon( tactical );
				maps/mp/zombies/_zm_weapons::unacquire_weapon_toggle( tactical );
			}
			mine = self get_player_placeable_mine();
			if ( isDefined( mine ) )
			{
				self takeweapon( mine );
				maps/mp/zombies/_zm_weapons::unacquire_weapon_toggle( mine );
			}
			melee_weapon = self get_player_melee_weapon();
			if ( isDefined( melee_weapon ) )
			{
				self takeweapon( melee_weapon );
				maps/mp/zombies/_zm_weapons::unacquire_weapon_toggle( melee_weapon );
			}
			self giveweapon( "knife_zm" );
			self.current_melee_weapon = "knife_zm";
			self give_start_weapon( 1 );
			self.currentweapon = "m1911_zm";
		}
	}
}

change_bad_spawner() //checked changed to match cerberus output
{
	flag_wait( "always_on" );
	spawner_array = getstructarray( "zone_blue_level4a_spawners", "targetname" );
	foreach ( struct in spawner_array )
	{
		if ( isDefined( struct.origin ) && struct.origin == ( 2154, 748.5, 1312 ) )
		{
			struct.script_noteworthy = "riser_location";
			return;
		}
	}
}

