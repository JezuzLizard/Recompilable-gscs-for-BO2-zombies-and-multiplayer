#include maps/mp/zombies/_zm_afterlife;
#include maps/mp/zm_prison;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

main_start()
{
	level thread spawned_collision_ffotd();
	t_killbrush_1 = spawn( "trigger_box", ( 142, 9292, 1504 ), 0, 700, 160, 128 );
	t_killbrush_1.script_noteworthy = "kill_brush";
	t_killbrush_2 = spawn( "trigger_box", ( 1822, 9316, 1358 ), 0, 120, 100, 30 );
	t_killbrush_2.script_noteworthy = "kill_brush";
	t_killbrush_3 = spawn( "trigger_box", ( -42, 9348, 1392 ), 0, 200, 100, 128 );
	t_killbrush_3.script_noteworthy = "kill_brush";
}

main_end()
{
	level.equipment_dead_zone_pos = [];
	level.equipment_dead_zone_rad2 = [];
	level.equipment_dead_zone_pos[ 0 ] = ( 408, 10016, 1128 );
	level.equipment_dead_zone_rad2[ 0 ] = 65536;
	level.equipment_dead_zone_pos[ 1 ] = ( -280, 7872, 176 );
	level.equipment_dead_zone_rad2[ 1 ] = 10000;
	level.equipment_dead_zone_pos[ 2 ] = ( -104, 8056, 280 );
	level.equipment_dead_zone_rad2[ 2 ] = 10000;
	level.equipment_dead_zone_pos[ 3 ] = ( -86, 7712, 114 );
	level.equipment_dead_zone_rad2[ 3 ] = 10000;
	level.equipment_dead_zone_pos[ 4 ] = ( 447, 5963, 264 );
	level.equipment_dead_zone_rad2[ 4 ] = 10000;
	level.equipment_dead_zone_pos[ 5 ] = ( 231, 5913, 200 );
	level.equipment_dead_zone_rad2[ 5 ] = 10000;
	level.equipment_dead_zone_pos[ 6 ] = ( 15, 5877, 136 );
	level.equipment_dead_zone_rad2[ 6 ] = 10000;
	level.equipment_dead_zone_pos[ 7 ] = ( -335, 5795, 14 );
	level.equipment_dead_zone_rad2[ 7 ] = 22500;
	level.equipment_dead_zone_pos[ 8 ] = ( -621, 5737, -48 );
	level.equipment_dead_zone_rad2[ 8 ] = 10000;
	level.equipment_dead_zone_pos[ 9 ] = ( 402, 7058, 147 );
	level.equipment_dead_zone_rad2[ 9 ] = 10000;
	level.equipment_dead_zone_pos[ 10 ] = ( 2151, 10180, 1204 );
	level.equipment_dead_zone_rad2[ 10 ] = 625;
	level.equipment_dead_zone_pos[ 11 ] = ( 2144, 9486, 1364 );
	level.equipment_dead_zone_rad2[ 11 ] = 2500;
	level.equipment_safe_to_drop = ::equipment_safe_to_drop_ffotd;
	waittillframeend;
	level.afterlife_give_loadout = ::afterlife_give_loadout_override;
}

equipment_safe_to_drop_ffotd( weapon )
{
	i = 0;
	while ( i < level.equipment_dead_zone_pos.size )
	{
		if ( distancesquared( level.equipment_dead_zone_pos[ i ], weapon.origin ) < level.equipment_dead_zone_rad2[ i ] )
		{
			return 0;
		}
		i++;
	}
	return self maps/mp/zm_prison::equipment_safe_to_drop( weapon );
}

spawned_collision_ffotd()
{
	precachemodel( "collision_ai_64x64x10" );
	precachemodel( "collision_wall_256x256x10_standard" );
	precachemodel( "collision_wall_128x128x10_standard" );
	precachemodel( "collision_wall_512x512x10_standard" );
	precachemodel( "collision_geo_256x256x256_standard" );
	precachemodel( "collision_geo_64x64x256_standard" );
	precachemodel( "collision_geo_128x128x128_standard" );
	flag_wait( "start_zombie_round_logic" );
	if ( !is_true( level.optimise_for_splitscreen ) )
	{
		collision1 = spawn( "script_model", ( 1999, 9643, 1472 ) );
		collision1 setmodel( "collision_ai_64x64x10" );
		collision1.angles = ( 0, 270, -90 );
		collision1 ghost();
		collision2 = spawn( "script_model", ( -437, 6260, 121 ) );
		collision2 setmodel( "collision_wall_256x256x10_standard" );
		collision2.angles = vectorScale( ( 0, 0, 0 ), 11,8 );
		collision2 ghost();
		collision3 = spawn( "script_model", ( 1887,98, 9323, 1489,14 ) );
		collision3 setmodel( "collision_wall_128x128x10_standard" );
		collision3.angles = ( 0, 270, 38,6 );
		collision3 ghost();
		collision4 = spawn( "script_model", ( -261, 8512,02, 1153,14 ) );
		collision4 setmodel( "collision_geo_256x256x256_standard" );
		collision4.angles = vectorScale( ( 0, 0, 0 ), 180 );
		collision4 ghost();
		collision5a = spawn( "script_model", ( 792, 8302, 1620 ) );
		collision5a setmodel( "collision_geo_64x64x256_standard" );
		collision5a.angles = ( 0, 0, 0 );
		collision5a ghost();
		collision5b = spawn( "script_model", ( 1010, 8302, 1620 ) );
		collision5b setmodel( "collision_geo_64x64x256_standard" );
		collision5b.angles = ( 0, 0, 0 );
		collision5b ghost();
		collision6 = spawn( "script_model", ( 554, 8026, 698 ) );
		collision6 setmodel( "collision_wall_128x128x10_standard" );
		collision6.angles = vectorScale( ( 0, 0, 0 ), 22,2 );
		collision6 ghost();
		collision7 = spawn( "script_model", ( 1890, 9911, 1184 ) );
		collision7 setmodel( "collision_geo_64x64x256_standard" );
		collision7.angles = ( 0, 0, 0 );
		collision7 ghost();
		collision8 = spawn( "script_model", ( 258, 9706, 1152 ) );
		collision8 setmodel( "collision_geo_64x64x256_standard" );
		collision8.angles = ( 0, 0, 0 );
		collision8 ghost();
		collision9 = spawn( "script_model", ( 596, 8944, 1160 ) );
		collision9 setmodel( "collision_ai_64x64x10" );
		collision9.angles = ( 270, 180, -180 );
		collision9 ghost();
		collision10 = spawn( "script_model", ( -756,5, 5730, -113,75 ) );
		collision10 setmodel( "collision_geo_128x128x128_standard" );
		collision10.angles = ( 354,9, 11, 0 );
		collision10 ghost();
		collision11 = spawn( "script_model", ( -4, 8314, 808 ) );
		collision11 setmodel( "collision_wall_128x128x10_standard" );
		collision11.angles = vectorScale( ( 0, 0, 0 ), 292 );
		collision11 ghost();
		collision12 = spawn( "script_model", ( 1416, 10708, 1440 ) );
		collision12 setmodel( "collision_wall_512x512x10_standard" );
		collision12.angles = ( 0, 0, 0 );
		collision12 ghost();
	}
}

afterlife_give_loadout_override()
{
	self thread afterlife_leave_freeze();
	self maps/mp/zombies/_zm_afterlife::afterlife_give_loadout();
}

afterlife_leave_freeze()
{
	self endon( "disconnect" );
	self freezecontrols( 1 );
	wait 0,5;
	if ( !is_true( self.hostmigrationcontrolsfrozen ) )
	{
		self freezecontrols( 0 );
	}
}
