#include maps/mp/zombies/_zm_equip_hacker;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

door_struct_debug()
{
	while ( 1 )
	{
		wait 0,1;
		origin = self.origin;
		point = origin;
		i = 1;
		while ( i < 5 )
		{
			point = origin + ( anglesToForward( self.door.angles ) * ( i * 2 ) );
			passed = bullettracepassed( point, origin, 0, undefined );
			color = vectorScale( ( 1, 0, 0 ), 255 );
			if ( !passed )
			{
				color = vectorScale( ( 1, 0, 0 ), 255 );
			}
/#
			print3d( point, "+", color, 1, 1 );
#/
			i++;
		}
	}
}

hack_doors( targetname, door_activate_func )
{
	if ( !isDefined( targetname ) )
	{
		targetname = "zombie_door";
	}
	doors = getentarray( targetname, "targetname" );
	if ( !isDefined( door_activate_func ) )
	{
		door_activate_func = ::maps/mp/zombies/_zm_blockers::door_opened;
	}
	i = 0;
	while ( i < doors.size )
	{
		door = doors[ i ];
		struct = spawnstruct();
		struct.origin = door.origin + ( anglesToForward( door.angles ) * 2 );
		struct.radius = 48;
		struct.height = 72;
		struct.script_float = 32,7;
		struct.script_int = 200;
		struct.door = door;
		struct.no_bullet_trace = 1;
		struct.door_activate_func = door_activate_func;
		trace_passed = 0;
		door thread hide_door_buy_when_hacker_active( struct );
		maps/mp/zombies/_zm_equip_hacker::register_pooled_hackable_struct( struct, ::door_hack );
		door thread watch_door_for_open( struct );
		i++;
	}
}

hide_door_buy_when_hacker_active( door_struct )
{
	self endon( "death" );
	self endon( "door_hacked" );
	self endon( "door_opened" );
	maps/mp/zombies/_zm_equip_hacker::hide_hint_when_hackers_active();
}

watch_door_for_open( door_struct )
{
	self waittill( "door_opened" );
	self endon( "door_hacked" );
	remove_all_door_hackables_that_target_door( door_struct.door );
}

door_hack( hacker )
{
	self.door notify( "door_hacked" );
	self.door notify( "kill_door_think" );
	remove_all_door_hackables_that_target_door( self.door );
	self.door [[ self.door_activate_func ]]();
	self.door._door_open = 1;
}

remove_all_door_hackables_that_target_door( door )
{
	candidates = [];
	i = 0;
	while ( i < level._hackable_objects.size )
	{
		obj = level._hackable_objects[ i ];
		if ( isDefined( obj.door ) && obj.door.target == door.target )
		{
			candidates[ candidates.size ] = obj;
		}
		i++;
	}
	i = 0;
	while ( i < candidates.size )
	{
		maps/mp/zombies/_zm_equip_hacker::deregister_hackable_struct( candidates[ i ] );
		i++;
	}
}
