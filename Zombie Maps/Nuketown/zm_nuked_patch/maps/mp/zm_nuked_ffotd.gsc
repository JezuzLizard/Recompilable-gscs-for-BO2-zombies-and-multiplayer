#include maps/mp/zombies/_zm_ffotd;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

main_start()
{
	precachemodel( "collision_wall_128x128x10_standard" );
	precachemodel( "collision_player_256x256x10" );
	precachemodel( "collision_wall_64x64x10_standard" );
	if ( isDefined( level.use_swipe_protection ) )
	{
		onplayerconnect_callback( ::claymore_watch_swipes );
	}
}

main_end()
{
	setdvar( "zombiemode_path_minz_bias", 28 );
	collision7 = spawn( "script_model", ( -490, 963, 63 ) );
	collision7 setmodel( "collision_player_256x256x10" );
	collision7.angles = ( 0, 25,2, -90 );
	collision7 ghost();
	collision9 = spawn( "script_model", ( -1349, 1016, 0 ) );
	collision9 setmodel( "collision_wall_128x128x10_standard" );
	collision9.angles = vectorScale( ( 0, 1, 0 ), 339,8 );
	collision9 ghost();
	collision11 = spawn( "script_model", ( 1074, 584, 126 ) );
	collision11 setmodel( "collision_wall_64x64x10_standard" );
	collision11.angles = vectorScale( ( 0, 1, 0 ), 15 );
	collision11 ghost();
	collision12 = spawn( "script_model", ( 380, -112, 150 ) );
	collision12 setmodel( "collision_wall_128x128x10_standard" );
	collision12.angles = vectorScale( ( 0, 1, 0 ), 275 );
	collision12 ghost();
	collision13 = spawn( "script_model", ( 501, 212, 64 ) );
	collision13 setmodel( "collision_wall_64x64x10_standard" );
	collision13.angles = ( 0, 10,8, 90 );
	collision13 ghost();
	level thread prone_under_garage_door_exploit();
}

prone_under_garage_door_exploit()
{
	zombie_trigger_origin = ( -679, 339, -40 );
	zombie_trigger_radius = 100;
	zombie_trigger_height = 128;
	player_trigger_origin = ( -750, 189, -60 );
	player_trigger_radius = 72;
	zombie_goto_point = ( -863, 320, -40 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
	zombie_trigger_origin = ( -652,6, 143,2, -58,6015 );
	zombie_trigger_radius = 85;
	zombie_trigger_height = 128;
	player_trigger_origin = ( -741, 177, -52 );
	player_trigger_radius = 35;
	zombie_goto_point = ( -729,61, 156,24, -50 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
	zombie_trigger_origin = ( -863, 320, -20 );
	zombie_trigger_radius = 150;
	zombie_trigger_height = 128;
	player_trigger_origin = ( -750, 189, -60 );
	player_trigger_radius = 72;
	zombie_goto_point = ( -804,61, 198,24, -40 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
}

claymore_watch_swipes()
{
	self endon( "disconnect" );
	self notify( "claymore_watch_swipes" );
	self endon( "claymore_watch_swipes" );
	while ( 1 )
	{
		self waittill( "weapon_change", weapon );
		if ( is_placeable_mine( weapon ) )
		{
			self.mine_damage = 0;
			self thread watch_melee_swipes( weapon );
		}
	}
}

watch_melee_swipes( weapname )
{
	self endon( "weapon_change" );
	self endon( "death" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "melee_swipe", zombie );
		self.mine_damage++;
		if ( self.mine_damage > 5 )
		{
			self.mine_damage = 0;
			ammo = self getweaponammoclip( weapname );
			if ( ammo >= 1 )
			{
				self setweaponammoclip( weapname, ammo - 1 );
				if ( ammo == 1 )
				{
					self setweaponammoclip( weapname, ammo - 1 );
					primaryweapons = self getweaponslistprimaries();
					if ( isDefined( primaryweapons[ 0 ] ) )
					{
						self switchtoweapon( primaryweapons[ 0 ] );
					}
				}
				break;
			}
			else
			{
				self takeweapon( weapname );
			}
		}
	}
}
