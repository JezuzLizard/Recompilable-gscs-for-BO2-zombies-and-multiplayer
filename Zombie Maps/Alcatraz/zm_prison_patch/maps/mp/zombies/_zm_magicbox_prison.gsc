#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	registerclientfield( "zbarrier", "magicbox_initial_fx", 2000, 1, "int" );
	registerclientfield( "zbarrier", "magicbox_amb_fx", 2000, 2, "int" );
	registerclientfield( "zbarrier", "magicbox_open_fx", 2000, 1, "int" );
	registerclientfield( "zbarrier", "magicbox_leaving_fx", 2000, 1, "int" );
	level._effect[ "lght_marker" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_marker" );
	level._effect[ "lght_marker_flare" ] = loadfx( "maps/zombie_alcatraz/fx_zmb_tranzit_marker_fl" );
	level._effect[ "poltergeist" ] = loadfx( "system_elements/fx_null" );
	level._effect[ "box_gone_ambient" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_magicbox_amb" );
	level._effect[ "box_here_ambient" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_magicbox_arrive" );
	level._effect[ "box_is_open" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_magicbox_open" );
	level._effect[ "box_is_locked" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_magicbox_lock" );
	level._effect[ "box_is_leaving" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_magicbox_leave" );
	level.using_locked_magicbox = 1;
	level.chest_joker_model = "p6_anim_zm_al_magic_box_lock_red";
	precachemodel( level.chest_joker_model );
	level.chest_joker_custom_movement = ::custom_joker_movement;
	level.magic_box_zbarrier_state_func = ::set_magic_box_zbarrier_state;
	level thread wait_then_create_base_magic_box_fx();
	level thread handle_fire_sale();
}

custom_joker_movement()
{
	v_origin = self.weapon_model.origin - vectorScale( ( 0, 1, 0 ), 5 );
	self.weapon_model delete();
	m_lock = spawn( "script_model", v_origin );
	m_lock setmodel( level.chest_joker_model );
	m_lock.angles = self.angles + vectorScale( ( 0, 1, 0 ), 180 );
	wait 0,5;
	level notify( "weapon_fly_away_start" );
	wait 1;
	m_lock rotateyaw( 3000, 4, 4 );
	wait 3;
	m_lock movez( 20, 0,5, 0,5 );
	m_lock waittill( "movedone" );
	m_lock movez( -100, 0,5, 0,5 );
	m_lock waittill( "movedone" );
	m_lock delete();
	self notify( "box_moving" );
	level notify( "weapon_fly_away_end" );
}

wait_then_create_base_magic_box_fx()
{
	while ( !isDefined( level.chests ) )
	{
		wait 0,5;
	}
	while ( !isDefined( level.chests[ level.chests.size - 1 ].zbarrier ) )
	{
		wait 0,5;
	}
	_a92 = level.chests;
	_k92 = getFirstArrayKey( _a92 );
	while ( isDefined( _k92 ) )
	{
		chest = _a92[ _k92 ];
		chest.zbarrier setclientfield( "magicbox_initial_fx", 1 );
		_k92 = getNextArrayKey( _a92, _k92 );
	}
}

set_magic_box_zbarrier_state( state )
{
	i = 0;
	while ( i < self getnumzbarrierpieces() )
	{
		self hidezbarrierpiece( i );
		i++;
	}
	self notify( "zbarrier_state_change" );
	switch( state )
	{
		case "away":
			self showzbarrierpiece( 0 );
			self.state = "away";
			self.owner.is_locked = 0;
			break;
		case "arriving":
			self showzbarrierpiece( 1 );
			self thread magic_box_arrives();
			self.state = "arriving";
			break;
		case "initial":
			self showzbarrierpiece( 1 );
			self thread magic_box_initial();
			thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.owner.unitrigger_stub, ::maps/mp/zombies/_zm_magicbox::magicbox_unitrigger_think );
			self.state = "close";
			break;
		case "open":
			self showzbarrierpiece( 2 );
			self thread magic_box_opens();
			self.state = "open";
			break;
		case "close":
			self showzbarrierpiece( 2 );
			self thread magic_box_closes();
			self.state = "close";
			break;
		case "leaving":
			self showzbarrierpiece( 1 );
			self thread magic_box_leaves();
			self.state = "leaving";
			self.owner.is_locked = 0;
			break;
		default:
			if ( isDefined( level.custom_magicbox_state_handler ) )
			{
				self [[ level.custom_magicbox_state_handler ]]( state );
			}
			break;
	}
}

magic_box_initial()
{
	self setzbarrierpiecestate( 1, "open" );
	wait 1;
	self setclientfield( "magicbox_amb_fx", 1 );
}

magic_box_arrives()
{
	self setclientfield( "magicbox_leaving_fx", 0 );
	self setclientfield( "magicbox_amb_fx", 1 );
	self setzbarrierpiecestate( 1, "opening" );
	while ( self getzbarrierpiecestate( 1 ) == "opening" )
	{
		wait 0,05;
	}
	self notify( "arrived" );
	self.state = "close";
}

magic_box_leaves()
{
	self setclientfield( "magicbox_leaving_fx", 1 );
	self setclientfield( "magicbox_open_fx", 0 );
	self setzbarrierpiecestate( 1, "closing" );
	self playsound( "zmb_hellbox_rise" );
	while ( self getzbarrierpiecestate( 1 ) == "closing" )
	{
		wait 0,1;
	}
	self notify( "left" );
	self setclientfield( "magicbox_amb_fx", 0 );
}

magic_box_opens()
{
	self setclientfield( "magicbox_open_fx", 1 );
	self setzbarrierpiecestate( 2, "opening" );
	self playsound( "zmb_hellbox_open" );
	while ( self getzbarrierpiecestate( 2 ) == "opening" )
	{
		wait 0,1;
	}
	self notify( "opened" );
}

magic_box_closes()
{
	self setzbarrierpiecestate( 2, "closing" );
	self playsound( "zmb_hellbox_close" );
	while ( self getzbarrierpiecestate( 2 ) == "closing" )
	{
		wait 0,1;
	}
	self notify( "closed" );
	self setclientfield( "magicbox_open_fx", 0 );
}

magic_box_do_weapon_rise()
{
	self endon( "box_hacked_respin" );
	self setzbarrierpiecestate( 3, "closed" );
	self setzbarrierpiecestate( 4, "closed" );
	wait_network_frame();
	self zbarrierpieceuseboxriselogic( 3 );
	self zbarrierpieceuseboxriselogic( 4 );
	self showzbarrierpiece( 3 );
	self showzbarrierpiece( 4 );
	self setzbarrierpiecestate( 3, "opening" );
	self setzbarrierpiecestate( 4, "opening" );
	while ( self getzbarrierpiecestate( 3 ) != "open" )
	{
		wait 0,5;
	}
	self hidezbarrierpiece( 3 );
	self hidezbarrierpiece( 4 );
}

handle_fire_sale()
{
	while ( 1 )
	{
		level waittill( "fire_sale_off" );
		i = 0;
		while ( i < level.chests.size )
		{
			if ( level.chest_index != i && isDefined( level.chests[ i ].was_temp ) )
			{
				level.chests[ i ].zbarrier setclientfield( "magicbox_amb_fx", 0 );
			}
			i++;
		}
	}
}
