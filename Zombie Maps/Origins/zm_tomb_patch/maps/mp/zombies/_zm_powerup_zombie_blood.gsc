#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/_utility;
#include common_scripts/utility;

init( str_zombie_model )
{
	level.str_zombie_blood_model = str_zombie_model;
	precachemodel( level.str_zombie_blood_model );
	registerclientfield( "allplayers", "player_zombie_blood_fx", 14000, 1, "int" );
	level._effect[ "zombie_blood" ] = loadfx( "maps/zombie_tomb/fx_tomb_pwr_up_zmb_blood" );
	level._effect[ "zombie_blood_1st" ] = loadfx( "maps/zombie_tomb/fx_zm_blood_overlay_pclouds" );
	add_zombie_powerup( "zombie_blood", "p6_zm_tm_blood_power_up", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 1, 0, 0, undefined, "powerup_zombie_blood", "zombie_powerup_zombie_blood_time", "zombie_powerup_zombie_blood_on" );
	powerup_set_can_pick_up_in_last_stand( "zombie_blood", 0 );
	onplayerconnect_callback( ::init_player_zombie_blood_vars );
	level.a_zombie_blood_entities = [];
	array_thread( getentarray( "zombie_blood_visible", "targetname" ), ::make_zombie_blood_entity );
	if ( !isDefined( level.vsmgr_prio_visionset_zm_powerup_zombie_blood ) )
	{
		level.vsmgr_prio_visionset_zm_powerup_zombie_blood = 15;
	}
	if ( !isDefined( level.vsmgr_prio_overlay_zm_powerup_zombie_blood ) )
	{
		level.vsmgr_prio_overlay_zm_powerup_zombie_blood = 16;
	}
	maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_powerup_zombie_blood_visionset", 14000, level.vsmgr_prio_visionset_zm_powerup_zombie_blood, 15, 1 );
	maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zm_powerup_zombie_blood_overlay", 14000, level.vsmgr_prio_overlay_zm_powerup_zombie_blood, 15, 1 );
}

init_player_zombie_blood_vars()
{
	self.zombie_vars[ "zombie_powerup_zombie_blood_on" ] = 0;
	self.zombie_vars[ "zombie_powerup_zombie_blood_time" ] = 30;
}

zombie_blood_powerup( m_powerup, e_player )
{
	e_player notify( "zombie_blood" );
	e_player endon( "zombie_blood" );
	e_player endon( "disconnect" );
	e_player thread powerup_vo( "zombie_blood" );
	e_player.ignoreme = 1;
	e_player._show_solo_hud = 1;
	e_player.zombie_vars[ "zombie_powerup_zombie_blood_time" ] = 30;
	e_player.zombie_vars[ "zombie_powerup_zombie_blood_on" ] = 1;
	level notify( "player_zombie_blood" );
	maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_powerup_zombie_blood_visionset", e_player );
	maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_powerup_zombie_blood_overlay", e_player );
	e_player setclientfield( "player_zombie_blood_fx", 1 );
	__new = [];
	_a73 = level.a_zombie_blood_entities;
	__key = getFirstArrayKey( _a73 );
	while ( isDefined( __key ) )
	{
		__value = _a73[ __key ];
		if ( isDefined( __value ) )
		{
			if ( isstring( __key ) )
			{
				__new[ __key ] = __value;
				break;
			}
			else
			{
				__new[ __new.size ] = __value;
			}
		}
		__key = getNextArrayKey( _a73, __key );
	}
	level.a_zombie_blood_entities = __new;
	_a74 = level.a_zombie_blood_entities;
	_k74 = getFirstArrayKey( _a74 );
	while ( isDefined( _k74 ) )
	{
		e_zombie_blood = _a74[ _k74 ];
		if ( isDefined( e_zombie_blood.e_unique_player ) )
		{
			if ( e_zombie_blood.e_unique_player == e_player )
			{
				e_zombie_blood setvisibletoplayer( e_player );
			}
		}
		else
		{
			e_zombie_blood setvisibletoplayer( e_player );
		}
		_k74 = getNextArrayKey( _a74, _k74 );
	}
	if ( !isDefined( e_player.m_fx ) )
	{
		v_origin = e_player gettagorigin( "J_Eyeball_LE" );
		v_angles = e_player gettagangles( "J_Eyeball_LE" );
		m_fx = spawn( "script_model", v_origin );
		m_fx setmodel( "tag_origin" );
		m_fx.angles = v_angles;
		m_fx linkto( e_player, "J_Eyeball_LE", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		m_fx thread fx_disconnect_watch( e_player );
		playfxontag( level._effect[ "zombie_blood" ], m_fx, "tag_origin" );
		e_player.m_fx = m_fx;
		e_player.m_fx playloopsound( "zmb_zombieblood_3rd_loop", 1 );
		if ( isDefined( level.str_zombie_blood_model ) )
		{
			e_player.hero_model = e_player.model;
			e_player setmodel( level.str_zombie_blood_model );
		}
	}
	e_player thread watch_zombie_blood_early_exit();
	while ( e_player.zombie_vars[ "zombie_powerup_zombie_blood_time" ] >= 0 )
	{
		wait 0,05;
		e_player.zombie_vars[ "zombie_powerup_zombie_blood_time" ] -= 0,05;
	}
	e_player notify( "zombie_blood_over" );
	if ( isDefined( e_player.characterindex ) )
	{
		e_player playsound( "vox_plr_" + e_player.characterindex + "_exert_grunt_" + randomintrange( 0, 3 ) );
	}
	e_player.m_fx delete();
	maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_powerup_zombie_blood_visionset", e_player );
	maps/mp/_visionset_mgr::vsmgr_deactivate( "overlay", "zm_powerup_zombie_blood_overlay", e_player );
	e_player.zombie_vars[ "zombie_powerup_zombie_blood_on" ] = 0;
	e_player.zombie_vars[ "zombie_powerup_zombie_blood_time" ] = 30;
	e_player._show_solo_hud = 0;
	e_player setclientfield( "player_zombie_blood_fx", 0 );
	if ( !isDefined( e_player.early_exit ) )
	{
		e_player.ignoreme = 0;
	}
	else
	{
		e_player.early_exit = undefined;
	}
	__new = [];
	_a145 = level.a_zombie_blood_entities;
	__key = getFirstArrayKey( _a145 );
	while ( isDefined( __key ) )
	{
		__value = _a145[ __key ];
		if ( isDefined( __value ) )
		{
			if ( isstring( __key ) )
			{
				__new[ __key ] = __value;
				break;
			}
			else
			{
				__new[ __new.size ] = __value;
			}
		}
		__key = getNextArrayKey( _a145, __key );
	}
	level.a_zombie_blood_entities = __new;
	_a146 = level.a_zombie_blood_entities;
	_k146 = getFirstArrayKey( _a146 );
	while ( isDefined( _k146 ) )
	{
		e_zombie_blood = _a146[ _k146 ];
		e_zombie_blood setinvisibletoplayer( e_player );
		_k146 = getNextArrayKey( _a146, _k146 );
	}
	if ( isDefined( e_player.hero_model ) )
	{
		e_player setmodel( e_player.hero_model );
		e_player.hero_model = undefined;
	}
}

fx_disconnect_watch( e_player )
{
	self endon( "death" );
	e_player waittill( "disconnect" );
	self delete();
}

watch_zombie_blood_early_exit()
{
	self notify( "early_exit_watch" );
	self endon( "early_exit_watch" );
	self endon( "zombie_blood_over" );
	self endon( "disconnect" );
	waittill_any_ents_two( self, "player_downed", level, "end_game" );
	self.zombie_vars[ "zombie_powerup_zombie_blood_time" ] = -0,05;
	self.early_exit = 1;
}

make_zombie_blood_entity()
{
/#
	assert( isDefined( level.a_zombie_blood_entities ), "zombie blood powerup not initiliazed in level" );
#/
	level.a_zombie_blood_entities[ level.a_zombie_blood_entities.size ] = self;
	self setinvisibletoall();
	_a196 = getplayers();
	_k196 = getFirstArrayKey( _a196 );
	while ( isDefined( _k196 ) )
	{
		e_player = _a196[ _k196 ];
		if ( e_player.zombie_vars[ "zombie_powerup_zombie_blood_on" ] )
		{
			if ( isDefined( self.e_unique_player ) )
			{
				if ( self.e_unique_player == e_player )
				{
					self setvisibletoplayer( e_player );
				}
				break;
			}
			else
			{
				self setvisibletoplayer( e_player );
			}
		}
		_k196 = getNextArrayKey( _a196, _k196 );
	}
}
