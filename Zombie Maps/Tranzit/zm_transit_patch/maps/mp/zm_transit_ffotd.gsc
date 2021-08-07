#include maps/mp/zm_transit;
#include maps/mp/zombies/_zm_ffotd;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

main_start()
{
	precachemodel( "collision_wall_256x256x10_standard" );
	precachemodel( "collision_geo_32x32x10_standard" );
	precachemodel( "collision_wall_128x128x10_standard" );
	precachemodel( "collision_wall_64x64x10_standard" );
	precachemodel( "collision_wall_512x512x10_standard" );
	precachemodel( "collision_player_32x32x128" );
	precachemodel( "collision_player_256x256x256" );
	old_roof_trig = getent( "bus_roof_watch", "targetname" );
	level.roof_trig = spawn( "trigger_box", old_roof_trig.origin, 0, 464, 180, 120 );
	level.roof_trig.targetname = "bus_roof_watch";
	old_roof_trig delete();
	if ( isDefined( level.use_swipe_protection ) )
	{
		onplayerconnect_callback( ::claymore_watch_swipes );
	}
	powerdoors = getentarray( "local_electric_door", "script_noteworthy" );
	_a29 = powerdoors;
	_k29 = getFirstArrayKey( _a29 );
	while ( isDefined( _k29 ) )
	{
		door = _a29[ _k29 ];
		if ( isDefined( door.door_hold_trigger ) && door.door_hold_trigger == "zombie_door_hold_diner" )
		{
			if ( isDefined( door.script_flag ) && door.script_flag == "OnPriDoorYar" )
			{
				door.script_flag = undefined;
			}
		}
		_k29 = getNextArrayKey( _a29, _k29 );
	}
}

main_end()
{
	if ( !is_true( level.optimise_for_splitscreen ) )
	{
		maps/mp/zombies/_zm::spawn_kill_brush( ( 33, -450, -90 ), 982, 15 );
		location = level.scr_zm_map_start_location;
		type = level.scr_zm_ui_gametype;
		collision4 = spawn( "script_model", ( 12240, 8480, -720 ) );
		collision4 setmodel( "collision_wall_64x64x10_standard" );
		collision4.angles = ( 0, 1, 0 );
		collision4 ghost();
		collision5 = spawn( "script_model", ( 8320, -6679, 362 ) );
		collision5 setmodel( "collision_wall_256x256x10_standard" );
		collision5.angles = vectorScale( ( 0, 1, 0 ), 300 );
		collision5 ghost();
		collision6 = spawn( "script_model", ( 8340, -5018, 191 ) );
		collision6 setmodel( "collision_geo_32x32x10_standard" );
		collision6.angles = vectorScale( ( 0, 1, 0 ), 270 );
		collision6 ghost();
		collision7 = spawn( "script_model", ( 8340, -5018, 219 ) );
		collision7 setmodel( "collision_geo_32x32x10_standard" );
		collision7.angles = vectorScale( ( 0, 1, 0 ), 270 );
		collision7 ghost();
		collision8 = spawn( "script_model", ( 8044, -5018, 191 ) );
		collision8 setmodel( "collision_geo_32x32x10_standard" );
		collision8.angles = vectorScale( ( 0, 1, 0 ), 270 );
		collision8 ghost();
		collision9 = spawn( "script_model", ( 8044, -5018, 219 ) );
		collision9 setmodel( "collision_geo_32x32x10_standard" );
		collision9.angles = vectorScale( ( 0, 1, 0 ), 270 );
		collision9 ghost();
		if ( location == "town" && type == "zstandard" )
		{
			collision10 = spawn( "script_model", ( 1820, 126, 152 ) );
			collision10 setmodel( "collision_wall_128x128x10_standard" );
			collision10.angles = vectorScale( ( 0, 1, 0 ), 262 );
			collision10 ghost();
		}
		collision11 = spawn( "script_model", ( 11216,3, 8188, -432 ) );
		collision11 setmodel( "collision_wall_128x128x10_standard" );
		collision11.angles = vectorScale( ( 0, 1, 0 ), 180 );
		collision11 ghost();
		collision12 = spawn( "script_model", ( -454, 620,25, -1,75 ) );
		collision12 setmodel( "collision_wall_128x128x10_standard" );
		collision12.angles = vectorScale( ( 0, 1, 0 ), 330 );
		collision12 ghost();
		collision13 = spawn( "script_model", ( 11798, 8410, -734 ) );
		collision13 setmodel( "collision_wall_128x128x10_standard" );
		collision13.angles = ( 90, 260,589, -10,311 );
		collision13 ghost();
		collision14 = spawn( "script_model", ( 652, 240, 124 ) );
		collision14 setmodel( "collision_wall_128x128x10_standard" );
		collision14.angles = vectorScale( ( 0, 1, 0 ), 105 );
		collision14 ghost();
		if ( location == "farm" && type == "zgrief" )
		{
			collision15 = spawn( "script_model", ( 8052, -5204, 380 ) );
			collision15 setmodel( "collision_wall_64x64x10_standard" );
			collision15.angles = vectorScale( ( 0, 1, 0 ), 180 );
			collision15 ghost();
		}
		collision16 = spawn( "script_model", ( -448, 328, 112 ) );
		collision16 setmodel( "collision_wall_512x512x10_standard" );
		collision16.angles = ( 270, 67,822, 22,1776 );
		collision16 ghost();
		collision17 = spawn( "script_model", ( 6040, -5744, 240 ) );
		collision17 setmodel( "collision_player_256x256x256" );
		collision17.angles = vectorScale( ( 0, 1, 0 ), 90 );
		collision17 ghost();
		collision18 = spawn( "script_model", ( -6744, 4184, 64 ) );
		collision18 setmodel( "collision_wall_128x128x10_standard" );
		collision18.angles = vectorScale( ( 0, 1, 0 ), 90 );
		collision18 ghost();
		collision19 = spawn( "script_model", ( -6328, -7168, 264 ) );
		collision19 setmodel( "collision_player_256x256x256" );
		collision19.angles = vectorScale( ( 0, 1, 0 ), 90 );
		collision19 ghost();
		collision20 = spawn( "script_model", ( 9960, 7352, -136 ) );
		collision20 setmodel( "collision_player_256x256x256" );
		collision20.angles = vectorScale( ( 0, 1, 0 ), 90 );
		collision20 ghost();
		collision21 = spawn( "script_model", ( -4656, -7373, 0 ) );
		collision21 setmodel( "collision_player_32x32x128" );
		collision21.angles = vectorScale( ( 0, 1, 0 ), 341,6 );
		collision21 ghost();
	}
	apartment_exploit();
	town_truck_exploit();
	farm_porch_exploit();
	power_station_exploit();
	nacht_exploit();
	level.equipment_dead_zone_pos = [];
	level.equipment_dead_zone_rad2 = [];
	level.equipment_dead_zone_type = [];
	level.equipment_dead_zone_pos[ 0 ] = ( -6252,98, -7947,23, 149,125 );
	level.equipment_dead_zone_rad2[ 0 ] = 3600;
	level.equipment_dead_zone_pos[ 1 ] = ( -11752, -2515, 288 );
	level.equipment_dead_zone_rad2[ 1 ] = 14400;
	level.equipment_dead_zone_type[ 1 ] = "t6_wpn_zmb_shield_world";
	level.equipment_dead_zone_pos[ 2 ] = ( -6664, 4592, -48 );
	level.equipment_dead_zone_rad2[ 2 ] = 2304;
	level.equipment_dead_zone_type[ 2 ] = "t6_wpn_zmb_shield_world";
	level.equipment_dead_zone_pos[ 3 ] = ( 7656, -4741, 38 );
	level.equipment_dead_zone_rad2[ 3 ] = 2304;
	level.equipment_dead_zone_type[ 3 ] = "t6_wpn_zmb_shield_world";
	level.equipment_dead_zone_pos[ 4 ] = ( -11712, -776, 224 );
	level.equipment_dead_zone_rad2[ 4 ] = 16384;
	level.equipment_dead_zone_type[ 4 ] = "t6_wpn_zmb_shield_world";
	level.equipment_dead_zone_pos[ 5 ] = ( -4868, -7713, -42 );
	level.equipment_dead_zone_rad2[ 5 ] = 256;
	level.equipment_dead_zone_type[ 5 ] = "t6_wpn_zmb_shield_world";
	level.equipment_safe_to_drop = ::equipment_safe_to_drop_ffotd;
}

apartment_exploit()
{
	zombie_trigger_origin = ( 994, -1145, 130 );
	zombie_trigger_radius = 32;
	zombie_trigger_height = 64;
	player_trigger_origin = ( 1068, -1085, 130 );
	player_trigger_radius = 72;
	zombie_goto_point = ( 1024, -1024, 136 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
}

nacht_exploit()
{
	zombie_trigger_origin = ( 13720, -639, -188 );
	zombie_trigger_radius = 64;
	zombie_trigger_height = 128;
	player_trigger_origin = ( 13605, -651, -188 );
	player_trigger_radius = 64;
	zombie_goto_point = ( 13671, -745, -188 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
}

town_truck_exploit()
{
	zombie_trigger_origin = ( 1414, -1921, -42 );
	zombie_trigger_radius = 50;
	zombie_trigger_height = 64;
	player_trigger_origin = ( 1476, -1776, -42 );
	player_trigger_radius = 76;
	zombie_goto_point = ( 1476, -1867, -42 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
}

farm_porch_exploit()
{
	zombie_trigger_origin = ( 7864, -6088, 104 );
	zombie_trigger_radius = 85,5;
	zombie_trigger_height = 64;
	player_trigger_origin = ( 7984, -6128, 168 );
	player_trigger_radius = 44;
	zombie_goto_point = ( 7960, -6072, 96 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
	zombie_trigger_origin = ( 7996, -6169, 132 );
	zombie_trigger_radius = 200,1;
	zombie_trigger_height = 64;
	player_trigger_origin = ( 7893, -6078, 121 );
	player_trigger_radius = 50;
	zombie_goto_point = ( 7828, -6052,5, 125 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
}

power_station_exploit()
{
	zombie_trigger_origin = ( 11248, 8504, -560 );
	zombie_trigger_radius = 125;
	zombie_trigger_height = 64;
	player_trigger_origin = ( 11368, 8624, -560 );
	player_trigger_radius = 65;
	zombie_goto_point = ( 11352, 8560, -560 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
	zombie_trigger_origin = ( 11168, 8880, -568 );
	zombie_trigger_radius = 78;
	zombie_trigger_height = 64;
	player_trigger_origin = ( 11048, 8888, -568 );
	player_trigger_radius = 79;
	zombie_goto_point = ( 11072, 8912, -568 );
	level thread maps/mp/zombies/_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
}

equipment_safe_to_drop_ffotd( weapon )
{
	i = 0;
	while ( i < level.equipment_dead_zone_pos.size )
	{
		if ( distancesquared( level.equipment_dead_zone_pos[ i ], weapon.origin ) < level.equipment_dead_zone_rad2[ i ] )
		{
			if ( isDefined( level.equipment_dead_zone_type[ i ] ) || !isDefined( weapon.model ) && level.equipment_dead_zone_type[ i ] == weapon.model )
			{
				return 0;
			}
		}
		i++;
	}
	return self maps/mp/zm_transit::equipment_safe_to_drop( weapon );
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
