#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_weapon_locker;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

register_time_bomb_enemy( str_type, func_conditions_for_round, func_save_enemy_data, func_respawn_enemies )
{
/#
	assert( isDefined( str_type ), "str_type is a required parameter for register_time_bomb_enemy! This identifies the round type" );
#/
/#
	assert( isDefined( func_conditions_for_round ), "func_conditions_for_round is a required parameter for register_time_bomb_enemy! This returns a bool that tells the script what type of round it is." );
#/
/#
	assert( isDefined( func_save_enemy_data ), "func_save_enemy_data is a required parameter for register_time_bomb_enemy! This should store all relevant data about an individual enemy, and requires one input argument." );
#/
/#
	assert( isDefined( func_respawn_enemies ), "func_respawn is a required parameter for register_time_bomb_enemy! This will run a function to respawn the new creature type." );
#/
	if ( !isDefined( level._time_bomb.enemy_type[ str_type ] ) )
	{
		level._time_bomb.enemy_type[ str_type ] = spawnstruct();
	}
	level._time_bomb.enemy_type[ str_type ].conditions_for_round = func_conditions_for_round;
	level._time_bomb.enemy_type[ str_type ].enemy_data_save_func = func_save_enemy_data;
	level._time_bomb.enemy_type[ str_type ].respawn_func = func_respawn_enemies;
}

register_time_bomb_enemy_save_filter( str_type, func_filter_save )
{
/#
	assert( isDefined( str_type ), "str_type is a required parameter for register_time_bomb_enemy_save_filter! This identifies the round type where the filter function should run." );
#/
/#
	assert( isDefined( level._time_bomb.enemy_type ), str_type + " enemy type is not yet registered with the time bomb system scripts. Register that type before calling register_time_bomb_enemy_save_filter()" );
#/
	level._time_bomb.enemy_type[ str_type ].enemy_data_save_filter_func = func_filter_save;
}

register_time_bomb_enemy_default( str_type )
{
/#
	assert( isDefined( level._time_bomb.enemy_type[ str_type ] ), str_type + " enemy type is not set up in time bomb enemy array! Initialize this enemy before trying to make it the default." );
#/
	level._time_bomb.enemy_type_default = str_type;
}

time_bomb_add_custom_func_global_save( func_save )
{
	if ( !isDefined( level._time_bomb.custom_funcs_save ) )
	{
		level._time_bomb.custom_funcs_save = [];
	}
	level._time_bomb.custom_funcs_save[ level._time_bomb.custom_funcs_save.size ] = func_save;
}

time_bomb_add_custom_func_global_restore( func_restore )
{
	if ( !isDefined( level._time_bomb.custom_funcs_restore ) )
	{
		level._time_bomb.custom_funcs_restore = [];
	}
	level._time_bomb.custom_funcs_restore[ level._time_bomb.custom_funcs_restore.size ] = func_restore;
}

get_time_bomb_saved_round_type()
{
	if ( !isDefined( level.time_bomb_save_data ) || !isDefined( level.time_bomb_save_data.round_type ) )
	{
		str_type = "none";
	}
	else
	{
		str_type = level.time_bomb_save_data.round_type;
	}
	return str_type;
}

init_time_bomb()
{
	time_bomb_precache();
	level thread time_bomb_post_init();
	flag_init( "time_bomb_round_killed" );
	flag_init( "time_bomb_enemies_restored" );
	flag_init( "time_bomb_zombie_respawning_done" );
	flag_init( "time_bomb_restore_active" );
	flag_init( "time_bomb_restore_done" );
	flag_init( "time_bomb_global_restore_done" );
	flag_init( "time_bomb_detonation_enabled" );
	flag_init( "time_bomb_stores_door_state" );
	registerclientfield( "world", "time_bomb_saved_round_number", 12000, 8, "int" );
	registerclientfield( "world", "time_bomb_lua_override", 12000, 1, "int" );
	registerclientfield( "world", "time_bomb_hud_toggle", 12000, 1, "int" );
	registerclientfield( "toplayer", "sndTimebombLoop", 12000, 2, "int" );
	maps/mp/zombies/_zm_weapons::register_zombie_weapon_callback( "time_bomb_zm", ::player_give_time_bomb );
	level.zombiemode_time_bomb_give_func = ::player_give_time_bomb;
	include_weapon( "time_bomb_zm", 1 );
	maps/mp/zombies/_zm_weapons::add_limited_weapon( "time_bomb_zm", 1 );
	register_tactical_grenade_for_level( "time_bomb_zm" );
	add_time_bomb_to_mystery_box();
	register_equipment_for_level( "time_bomb_zm" );
	register_equipment_for_level( "time_bomb_detonator_zm" );
	if ( !isDefined( level.round_wait_func ) )
	{
		level.round_wait_func = ::time_bomb_round_wait;
	}
	level.zombie_round_change_custom = ::time_bomb_custom_round_change;
	level._effect[ "time_bomb_set" ] = loadfx( "weapon/time_bomb/fx_time_bomb_detonate" );
	level._effect[ "time_bomb_ammo_fx" ] = loadfx( "misc/fx_zombie_powerup_on" );
	level._effect[ "time_bomb_respawns_enemy" ] = loadfx( "maps/zombie_buried/fx_buried_time_bomb_spawn" );
	level._effect[ "time_bomb_kills_enemy" ] = loadfx( "maps/zombie_buried/fx_buried_time_bomb_death" );
	level._time_bomb = spawnstruct();
	level._time_bomb.enemy_type = [];
	register_time_bomb_enemy( "zombie", ::is_zombie_round, ::time_bomb_saves_zombie_data, ::time_bomb_respawns_zombies );
	register_time_bomb_enemy_default( "zombie" );
	level._time_bomb.last_round_restored = -1;
	flag_set( "time_bomb_detonation_enabled" );
/#
	level thread test_mode();
#/
}

has_time_bomb_restored_this_round()
{
	return level._time_bomb.last_round_restored == level.round_number;
}

time_bomb_precache()
{
	precacheshader( "zombie_hud_time_bomb" );
	precacheitem( "time_bomb_detonator_zm" );
}

time_bomb_post_init()
{
	maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zombie_time_bomb_overlay", 12000, 200, 20, 0, ::time_bomb_overlay_lerp_thread );
}

add_time_bomb_to_mystery_box()
{
	maps/mp/zombies/_zm_weapons::add_zombie_weapon( "time_bomb_zm", undefined, &"ZOMBIE_WEAPON_TIME_BOMB", 50, "pickup_bomb", "", undefined, 1 );
}

player_give_time_bomb()
{
/#
	assert( isplayer( self ), "player_give_time_bomb can only be used on players!" );
#/
	self giveweapon( "time_bomb_zm" );
	self swap_weapon_to_time_bomb();
	self thread show_time_bomb_hints();
	self thread time_bomb_think();
	self thread watch_for_tactical_grenade_change();
	self thread detonator_think();
	self thread time_bomb_inventory_slot_think();
	self thread destroy_time_bomb_save_if_user_bleeds_out_or_disconnects();
	self thread sndwatchforweapswitch();
}

sndwatchforweapswitch()
{
	self endon( "disconnect" );
	self.sndlastweapon = "";
	while ( 1 )
	{
		self waittill( "weapon_change", weapon );
		if ( weapon == "time_bomb_zm" )
		{
			self setclientfieldtoplayer( "sndTimebombLoop", 1 );
			self.sndlastweapon = "time_bomb_zm";
			continue;
		}
		else if ( weapon == "time_bomb_detonator_zm" )
		{
			self setclientfieldtoplayer( "sndTimebombLoop", 2 );
			self.sndlastweapon = "time_bomb_detonator_zm";
			continue;
		}
		else
		{
			if ( self.sndlastweapon == "time_bomb_zm" || self.sndlastweapon == "time_bomb_detonator_zm" )
			{
				self setclientfieldtoplayer( "sndTimebombLoop", 0 );
			}
		}
	}
}

time_bomb_think()
{
	self notify( "_time_bomb_kill_thread" );
	self endon( "_time_bomb_kill_thread" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "player_lost_time_bomb" );
	while ( 1 )
	{
		self waittill( "grenade_fire", e_grenade, str_grenade_name );
		if ( str_grenade_name == "time_bomb_zm" )
		{
			if ( isDefined( str_grenade_name ) && str_grenade_name == "time_bomb_zm" )
			{
				e_grenade thread setup_time_bomb_detonation_model();
				time_bomb_saves_data();
				e_grenade time_bomb_model_init();
				self thread swap_weapon_to_detonator( e_grenade );
				self thread time_bomb_thrown_vo();
			}
		}
	}
}

time_bomb_thrown_vo()
{
	self endon( "death" );
	self endon( "disconnect" );
	wait 1,5;
	self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "throw_bomb" );
}

time_bomb_model_init()
{
	delete_existing_time_bomb_model();
	level.time_bomb_save_data.time_bomb_model = self;
	level.time_bomb_save_data.time_bomb_model playloopsound( "zmb_timebomb_3d_timer", 1 );
	level notify( "new_time_bomb_set" );
	playsoundatposition( "zmb_timebomb_plant_2d", ( 0, 0, 0 ) );
}

delete_existing_time_bomb_model()
{
	if ( isDefined( level.time_bomb_save_data ) && isDefined( level.time_bomb_save_data.time_bomb_model ) && isDefined( level.time_bomb_save_data.time_bomb_model.origin ) )
	{
		level.time_bomb_save_data.time_bomb_model delete_time_bomb_model();
	}
}

setup_time_bomb_detonation_model()
{
	playfxontag( level._effect[ "time_bomb_ammo_fx" ], self, "tag_origin" );
}

detonate_time_bomb()
{
	if ( isDefined( level.time_bomb_save_data.time_bomb_model ) && isDefined( level.time_bomb_save_data.time_bomb_model.origin ) )
	{
		playsoundatposition( "zmb_timebomb_3d_timer_end", level.time_bomb_save_data.time_bomb_model.origin );
	}
	delete_time_bomb_model();
	if ( time_bomb_save_exists() )
	{
		level thread time_bomb_restores_saved_data();
	}
}

delete_time_bomb_model()
{
	if ( isDefined( self ) && isDefined( self.origin ) )
	{
		playfx( level._effect[ "time_bomb_set" ], self.origin );
		self delete();
	}
}

watch_for_tactical_grenade_change()
{
	self notify( "_time_bomb_kill_tactical_grenade_watch" );
	self endon( "_time_bomb_kill_tactical_grenade_watch" );
	self endon( "death" );
	self endon( "disconnect" );
	while ( self hasweapon( "time_bomb_zm" ) )
	{
		self waittill( "new_tactical_grenade" );
	}
	if ( self hasweapon( "time_bomb_detonator_zm" ) )
	{
		self takeweapon( "time_bomb_detonator_zm" );
	}
	self notify( "player_lost_time_bomb" );
	destroy_time_bomb_save();
}

destroy_time_bomb_save()
{
	delete_existing_time_bomb_model();
	time_bomb_destroy_hud_elem();
	time_bomb_clears_global_data();
	self clean_up_time_bomb_notifications();
}

show_time_bomb_notification( str_text )
{
	self thread show_equipment_hint_text( str_text );
}

clean_up_time_bomb_notifications()
{
	self notify( "hide_equipment_hint_text" );
}

time_bomb_saves_data( b_show_icon, save_struct )
{
	level thread _time_bomb_saves_data( b_show_icon, save_struct );
}

_time_bomb_saves_data( b_show_icon, save_struct )
{
	if ( !isDefined( b_show_icon ) )
	{
		b_show_icon = 1;
	}
	debug_time_bomb_print( "TIME BOMB SET! Saving..." );
	if ( !isDefined( save_struct ) && !time_bomb_save_exists() )
	{
		level.time_bomb_save_data = spawnstruct();
	}
	time_bomb_saves_global_data( save_struct );
	time_bomb_saves_player_data( save_struct );
	if ( isDefined( save_struct ) )
	{
		save_struct.save_ready = 1;
	}
	else
	{
		level.time_bomb_save_data.save_ready = 1;
	}
	if ( b_show_icon )
	{
		time_bomb_hud_icon_show();
	}
}

time_bomb_saves_global_data( save_struct )
{
	if ( !isDefined( save_struct ) )
	{
		s_temp = level.time_bomb_save_data;
	}
	else
	{
		s_temp = save_struct;
	}
	s_temp.n_time_id = getTime();
	s_temp.round_number = level.round_number;
	s_temp.round_initialized = level._time_bomb.round_initialized;
	s_temp.round_type = _get_time_bomb_round_type();
	s_temp = _time_bomb_saves_enemy_info( s_temp );
	if ( flag( "time_bomb_stores_door_state" ) )
	{
		_time_bomb_saves_door_states( s_temp );
	}
	s_temp.custom_data = spawnstruct();
	while ( isDefined( level._time_bomb.custom_funcs_save ) )
	{
		i = 0;
		while ( i < level._time_bomb.custom_funcs_save.size )
		{
			s_temp.custom_data [[ level._time_bomb.custom_funcs_save[ i ] ]]();
			i++;
		}
	}
	if ( !isDefined( save_struct ) )
	{
		level.time_bomb_save_data = s_temp;
	}
}

_time_bomb_saves_door_states( s_temp )
{
	a_doors = getentarray( "zombie_door", "targetname" );
	s_temp.door_states = [];
	_a426 = a_doors;
	_k426 = getFirstArrayKey( _a426 );
	while ( isDefined( _k426 ) )
	{
		door = _a426[ _k426 ];
		door thread store_door_state( s_temp );
		_k426 = getNextArrayKey( _a426, _k426 );
	}
}

store_door_state( s_temp )
{
	s_door_struct = spawnstruct();
	s_door_struct.doors = [];
	if ( isDefined( self._door_open ) || self._door_open && isDefined( self.has_been_opened ) && self.has_been_opened )
	{
		if ( isDefined( self.is_moving ) && self.is_moving )
		{
			self waittill_either( "movedone", "rotatedone" );
		}
		_a445 = self.doors;
		_k445 = getFirstArrayKey( _a445 );
		while ( isDefined( _k445 ) )
		{
			door = _a445[ _k445 ];
			s = spawnstruct();
			s.saved_angles = door.angles;
			s.saved_origin = door.origin;
			s_door_struct.doors[ s_door_struct.doors.size ] = s;
			_k445 = getNextArrayKey( _a445, _k445 );
		}
		s_door_struct.state = 1;
	}
	else
	{
		_a459 = self.doors;
		_k459 = getFirstArrayKey( _a459 );
		while ( isDefined( _k459 ) )
		{
			door = _a459[ _k459 ];
			s = spawnstruct();
			s.saved_angles = door.og_angles;
			s.saved_origin = door.origin;
			s_door_struct.doors[ s_door_struct.doors.size ] = s;
			_k459 = getNextArrayKey( _a459, _k459 );
		}
		s_door_struct.state = 0;
	}
	s_temp.door_states[ self getentitynumber() ] = s_door_struct;
}

_time_bomb_restores_door_states( s_temp )
{
	if ( !isDefined( s_temp.door_states ) )
	{
/#
		assertmsg( "Trying to restore door states, where none have been saved." );
#/
		return;
	}
	a_doors = getentarray( "zombie_door", "targetname" );
	_a486 = a_doors;
	_k486 = getFirstArrayKey( _a486 );
	while ( isDefined( _k486 ) )
	{
		door = _a486[ _k486 ];
		door thread restore_door_state( s_temp );
		_k486 = getNextArrayKey( _a486, _k486 );
	}
}

restore_door_state( s_temp )
{
	s_door_struct = s_temp.door_states[ self getentitynumber() ];
	if ( !isDefined( s_door_struct ) )
	{
/#
		assertmsg( "Trying to restore doorstate for door @ " + self.origin + " but none saved." );
#/
		return;
	}
	if ( isDefined( self._door_open ) || self._door_open && isDefined( self.has_been_opened ) && self.has_been_opened )
	{
		if ( s_door_struct.state == 1 )
		{
			return;
		}
		i = 0;
		while ( i < s_door_struct.doors.size )
		{
			if ( isDefined( self.doors[ i ].script_string ) && self.doors[ i ].script_string == "rotate" )
			{
				self.doors[ i ] rotateto( self.doors[ i ].og_angles, 0,05, 0, 0 );
				wait 0,05;
			}
			self.doors[ i ] solid();
			self.doors[ i ] disconnectpaths();
			i++;
		}
		self._door_open = 0;
		self.has_been_opened = 0;
		self setvisibletoall();
		self notify( "kill_door_think" );
		self thread maps/mp/zombies/_zm_blockers::door_init();
	}
	else
	{
		if ( s_door_struct.state == 0 )
		{
			return;
		}
		i = 0;
		while ( i < s_door_struct.doors.size )
		{
			if ( isDefined( self.doors[ i ].script_string ) && self.doors[ i ].script_string == "rotate" )
			{
				self.doors[ i ] rotateto( s_door_struct.doors[ i ].script_angles, 0,05, 0, 0 );
			}
			self.doors[ i ] notsolid();
			self.doors[ i ] disconnectpaths();
			i++;
		}
		self._door_open = 1;
		self.has_been_opened = 1;
		self setinvisibletoall();
		self notify( "kill_door_think" );
	}
}

_time_bomb_saves_enemy_info( s_temp )
{
	s_temp.enemies = [];
	s_temp.zombie_total = level.zombie_total;
	a_enemies = time_bomb_get_enemy_array();
/#
	assert( isDefined( level._time_bomb.enemy_type[ s_temp.round_type ].enemy_data_save_func ), "enemy save data func is missing for AI type " + s_temp.round_type );
#/
	i = 0;
	while ( i < a_enemies.size )
	{
		s_data = spawnstruct();
		if ( !isDefined( level._time_bomb.enemy_type[ s_temp.round_type ].enemy_data_save_filter_func ) || a_enemies[ i ] [[ level._time_bomb.enemy_type[ s_temp.round_type ].enemy_data_save_filter_func ]]() )
		{
			a_enemies[ i ] [[ level._time_bomb.enemy_type[ s_temp.round_type ].enemy_data_save_func ]]( s_data );
			s_temp.enemies[ s_temp.enemies.size ] = s_data;
		}
		i++;
	}
	return s_temp;
}

time_bomb_saves_player_data( save_struct )
{
	a_players = get_players();
	if ( isDefined( save_struct ) )
	{
		save_struct.player_saves = [];
	}
	_a593 = a_players;
	_k593 = getFirstArrayKey( _a593 );
	while ( isDefined( _k593 ) )
	{
		player = _a593[ _k593 ];
		player_save_struct = undefined;
		if ( isDefined( save_struct ) )
		{
			save_struct.player_saves[ player getentitynumber() ] = spawnstruct();
			player_save_struct = save_struct;
		}
		player _time_bomb_save_internal( player_save_struct );
		_k593 = getNextArrayKey( _a593, _k593 );
	}
}

_time_bomb_save_internal( save_struct )
{
	if ( !isDefined( save_struct ) && !isDefined( self.time_bomb_save_data ) )
	{
		self.time_bomb_save_data = spawnstruct();
	}
	if ( !self ent_flag_exist( "time_bomb_restore_thread_done" ) )
	{
		self ent_flag_init( "time_bomb_restore_thread_done" );
	}
	self ent_flag_clear( "time_bomb_restore_thread_done" );
	s_temp = spawnstruct();
	s_temp.weapons = spawnstruct();
	if ( isDefined( save_struct ) )
	{
		s_temp.n_time_id = save_struct.n_time_id;
	}
	else
	{
		s_temp.n_time_id = level.time_bomb_save_data.n_time_id;
	}
	s_temp.player_origin = self.origin;
	s_temp.player_angles = self getplayerangles();
	s_temp.player_stance = self getstance();
	s_temp.is_last_stand = self maps/mp/zombies/_zm_laststand::player_is_in_laststand();
	s_temp.stored_weapon_info = self.stored_weapon_info;
	s_temp.is_spectator = self is_spectator();
	s_temp.weapons.array = self getweaponslist();
	s_temp.weapons.ammo_reserve = [];
	s_temp.weapons.ammo_clip = [];
	s_temp.weapons.type = [];
	s_temp.weapons.primary = self getcurrentweapon();
	if ( s_temp.weapons.primary == "none" || s_temp.weapons.primary == "time_bomb_zm" )
	{
		self thread _save_time_bomb_weapon_after_switch( save_struct );
	}
	i = 0;
	while ( i < s_temp.weapons.array.size )
	{
		str_weapon_temp = s_temp.weapons.array[ i ];
		s_temp.weapons.ammo_reserve[ i ] = self getweaponammostock( str_weapon_temp );
		if ( weaponfuellife( str_weapon_temp ) > 0 )
		{
			n_ammo_amount = self getweaponammofuel( str_weapon_temp );
			n_type = 1;
		}
		else if ( self isweaponoverheating( 1, str_weapon_temp ) > 0 )
		{
			n_ammo_amount = self isweaponoverheating( 1, str_weapon_temp );
			n_type = 2;
		}
		else
		{
			n_ammo_amount = self getweaponammoclip( str_weapon_temp );
			n_type = 0;
		}
		s_temp.weapons.type[ i ] = n_type;
		s_temp.weapons.ammo_clip[ i ] = n_ammo_amount;
		i++;
	}
	s_temp.current_equipment = self.current_equipment;
	s_temp.perks_all = self get_player_perk_list();
	s_temp.perks_disabled = self.disabled_perks;
	s_temp.perk_count = self.num_perks;
	s_temp.lives_remaining = self.lives;
	if ( isDefined( self.perks_active ) )
	{
		s_temp.perks_active = arraycopy( self.perks_active );
	}
	s_temp.points_current = self.score;
	if ( is_weapon_locker_available_in_game() )
	{
		s_temp.weapon_locker_data = self maps/mp/zombies/_zm_weapon_locker::wl_get_stored_weapondata();
	}
	s_temp.account_value = self.account_value;
	s_temp.save_ready = 1;
	if ( isDefined( save_struct ) )
	{
		save_struct.player_saves[ self getentitynumber() ] = s_temp;
	}
	else
	{
		self.time_bomb_save_data = s_temp;
	}
}

is_weapon_locker_available_in_game()
{
	if ( isDefined( level.weapon_locker_online ) && level.weapon_locker_online )
	{
		return isDefined( level.weapon_locker_map );
	}
}

_save_time_bomb_weapon_after_switch( save_struct )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "time_bomb_restore_active" );
	if ( !self is_spectator() )
	{
		self waittill( "weapon_change" );
		str_weapon = self getcurrentweapon();
		if ( str_weapon == "none" )
		{
			b_valid_weapon = 0;
		}
		else
		{
			str_type = weapontype( str_weapon );
			if ( str_type != "grenade" && str_type != "melee" )
			{
				b_valid_weapon = str_weapon != "time_bomb_zm";
			}
		}
		if ( isDefined( save_struct ) )
		{
			save_struct.player_saves[ self getentitynumber() ].weapons.primary = str_weapon;
			return;
		}
		else
		{
			self.time_bomb_save_data.weapons.primary = str_weapon;
		}
	}
}

time_bomb_save_exists()
{
	if ( isDefined( level.time_bomb_save_data ) )
	{
		if ( isDefined( level.time_bomb_save_data.save_ready ) )
		{
			return level.time_bomb_save_data.save_ready;
		}
	}
}

detonator_think()
{
	self notify( "_detonator_think_done" );
	self endon( "_detonator_think_done" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "player_lost_time_bomb" );
	debug_time_bomb_print( "player picked up detonator" );
	while ( 1 )
	{
		self waittill( "detonate" );
		debug_time_bomb_print( "detonate detected! " );
		if ( time_bomb_save_exists() && flag( "time_bomb_detonation_enabled" ) )
		{
			level.time_bomb_save_data.player_used = self;
			level.time_bomb_save_data.time_bomb_model thread detonate_time_bomb();
			self notify( "player_activates_timebomb" );
			self thread time_bomb_detonation_vo();
		}
	}
}

time_bomb_detonation_vo()
{
	self endon( "death" );
	self endon( "disconnect" );
	level.time_bomb_detonation_vo = 1;
	level waittill( "time_bomb_detonation_complete" );
	wait 2;
	self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "activate_bomb" );
	level.time_bomb_detonation_vo = 0;
}

_watch_for_detonation()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "_kill_detonator_watcher" );
	while ( 1 )
	{
		self waittill( "detonate" );
		if ( time_bomb_save_exists() )
		{
			level thread time_bomb_restores_saved_data();
		}
	}
}

time_bomb_inventory_slot_think()
{
	self notify( "_time_bomb_inventory_think_done" );
	self endon( "_time_bomb_inventory_think_done" );
	self endon( "death_or_disconnect" );
	self endon( "player_lost_time_bomb" );
	self.time_bomb_detonator_only = 0;
	while ( 1 )
	{
		self waittill( "zmb_max_ammo" );
		if ( self.time_bomb_detonator_only )
		{
			self.time_bomb_detonator_only = 0;
		}
		self swap_weapon_to_time_bomb();
	}
}

time_bomb_restores_saved_data( b_show_fx, save_struct )
{
	if ( !isDefined( b_show_fx ) )
	{
		b_show_fx = 1;
	}
	level setclientfield( "time_bomb_lua_override", 1 );
	debug_time_bomb_print( "GO BACK IN TIME!" );
	n_time_start = getTime();
	flag_set( "time_bomb_restore_active" );
	if ( isDefined( level._time_bomb.functionality_override ) && level._time_bomb.functionality_override )
	{
		return;
	}
	if ( b_show_fx )
	{
		playsoundatposition( "zmb_timebomb_timechange_2d", ( 0, 0, 0 ) );
		_time_bomb_show_overlay();
	}
	flag_clear( "time_bomb_enemies_restored" );
	flag_clear( "time_bomb_round_killed" );
	slow_all_actors();
	level thread time_bomb_restores_global_data( save_struct, n_time_start );
	flag_wait( "time_bomb_round_killed" );
	timebomb_wait_for_hostmigration();
	time_bomb_restores_player_data( n_time_start, save_struct );
	timebomb_wait_for_hostmigration();
	if ( !isDefined( save_struct ) )
	{
		time_bomb_clears_global_data();
		time_bomb_clears_player_data();
	}
	timebomb_wait_for_hostmigration();
	flag_wait( "time_bomb_global_restore_done" );
	if ( b_show_fx )
	{
		_time_bomb_hide_overlay( n_time_start );
	}
	time_bomb_destroy_hud_elem();
	flag_clear( "time_bomb_restore_active" );
	level setclientfield( "time_bomb_lua_override", 0 );
	level thread all_actors_resume_speed();
	level notify( "time_bomb_detonation_complete" );
}

timebomb_wait_for_hostmigration()
{
	while ( isDefined( level.hostmigrationtimer ) )
	{
		wait 0,05;
	}
}

time_bomb_restores_global_data( save_struct, n_time_start )
{
	timebomb_wait_for_hostmigration();
	debug_time_bomb_print( "TIME BOMB RESTORE GLOBAL DATA" );
	if ( isDefined( save_struct ) )
	{
		s_temp = save_struct;
	}
	else
	{
		s_temp = level.time_bomb_save_data;
	}
	flag_clear( "time_bomb_global_restore_done" );
	s_temp.current_round = level.round_number;
	level._time_bomb.changing_round = s_temp.round_number != level.round_number;
	level._time_bomb.last_round_restored = s_temp.round_number;
	timebomb_wait_for_hostmigration();
	if ( level._time_bomb.changing_round )
	{
		level timebomb_change_to_round( s_temp.round_number );
	}
	timebomb_wait_for_hostmigration();
	level _time_bomb_kill_all_active_enemies();
	timebomb_wait_for_hostmigration();
	level _time_bomb_restores_enemies( s_temp, n_time_start );
	if ( flag( "time_bomb_stores_door_state" ) )
	{
		_time_bomb_restores_door_states( s_temp );
	}
	timebomb_wait_for_hostmigration();
	_pack_a_punch_sequence_ends();
	timebomb_wait_for_hostmigration();
	close_magic_boxes();
	timebomb_wait_for_hostmigration();
	while ( isDefined( level._time_bomb.custom_funcs_restore ) )
	{
		i = 0;
		while ( i < level._time_bomb.custom_funcs_restore.size )
		{
			s_temp.custom_data [[ level._time_bomb.custom_funcs_restore[ i ] ]]();
			i++;
		}
	}
	timebomb_wait_for_hostmigration();
	flag_set( "time_bomb_global_restore_done" );
}

_pack_a_punch_sequence_ends()
{
	while ( flag( "pack_machine_in_use" ) )
	{
		_a983 = get_players();
		_k983 = getFirstArrayKey( _a983 );
		while ( isDefined( _k983 ) )
		{
			player = _a983[ _k983 ];
			player notify( "pap_player_disconnected" );
			_k983 = getNextArrayKey( _a983, _k983 );
		}
		_a989 = level.pap_triggers;
		_k989 = getFirstArrayKey( _a989 );
		while ( isDefined( _k989 ) )
		{
			trigger = _a989[ _k989 ];
			trigger notify( "pap_player_disconnected" );
			if ( isDefined( trigger.current_weapon ) && !isDefined( trigger.upgrade_name ) )
			{
				trigger.upgrade_name = maps/mp/zombies/_zm_weapons::get_upgrade_weapon( trigger.current_weapon, trigger will_upgrade_weapon_as_attachment( self.current_weapon ) );
			}
			_k989 = getNextArrayKey( _a989, _k989 );
		}
		waittillframeend;
		_a1003 = level.pap_triggers;
		_k1003 = getFirstArrayKey( _a1003 );
		while ( isDefined( _k1003 ) )
		{
			trigger = _a1003[ _k1003 ];
			trigger notify( "pap_timeout" );
			_k1003 = getNextArrayKey( _a1003, _k1003 );
		}
	}
}

close_magic_boxes()
{
	if ( isDefined( level.chest_index ) && isDefined( level.chests ) && level.chests.size > 0 )
	{
		level.chests[ level.chest_index ] _close_magic_box();
	}
	while ( isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && level.zombie_vars[ "zombie_powerup_fire_sale_on" ] )
	{
		i = 0;
		while ( i < level.chests.size )
		{
			if ( isDefined( level.chest_index ) && i != level.chest_index && isDefined( level.chests[ i ]._box_opened_by_fire_sale ) && level.chests[ i ]._box_opened_by_fire_sale )
			{
				level.chests[ i ] _close_magic_box();
			}
			i++;
		}
	}
}

_close_magic_box()
{
	if ( !flag( "moving_chest_now" ) && self.zbarrier.state == "open" )
	{
		if ( isDefined( self.weapon_out ) && self.weapon_out && !isDefined( self.zbarrier.weapon_model ) )
		{
			self.zbarrier waittill( "randomization_done" );
			wait_network_frame();
		}
		self notify( "trigger" );
		self.zbarrier notify( "weapon_grabbed" );
		self.zbarrier notify( "box_hacked_respin" );
		self.zbarrier maps/mp/zombies/_zm_magicbox::magic_box_closes();
	}
}

_time_bomb_restores_enemies( save_struct, n_time_start )
{
	_time_bomb_resets_all_barrier_attack_spots_taken();
	str_type = save_struct.round_type;
/#
	assert( isDefined( level._time_bomb.enemy_type[ str_type ] ), str_type + " respawn type isn't set up for time bomb!" );
#/
	_get_wait_time( n_time_start );
	timebomb_wait_for_hostmigration();
	[[ level._time_bomb.enemy_type[ str_type ].respawn_func ]]( save_struct );
}

_get_wait_time( n_time_start )
{
	n_time_end = getTime();
	n_time_elapsed = ( n_time_end - n_time_start ) * 0,001;
	n_delay = 2 - n_time_elapsed;
	if ( n_delay > 0 )
	{
		wait n_delay;
	}
}

_get_time_bomb_zombie_spawn_location()
{
	a_spawn_locations = level.zombie_spawn_locations;
	a_valid_spawners = [];
	i = 0;
	while ( i < a_spawn_locations.size )
	{
		if ( isDefined( a_spawn_locations[ i ].script_noteworthy ) )
		{
			b_is_standard_spawn = a_spawn_locations[ i ].script_noteworthy == "spawn_location";
		}
		if ( b_is_standard_spawn )
		{
			a_valid_spawners[ a_valid_spawners.size ] = a_spawn_locations[ i ];
		}
		i++;
	}
/#
	assert( a_valid_spawners.size > 0, "_get_time_bomb_zombie_spawn_location found no valid spawn locations!" );
#/
	s_spawn_point = random( a_valid_spawners );
	return s_spawn_point;
}

time_bomb_restores_player_data( n_time_start, save_struct )
{
	_get_wait_time( n_time_start );
	white_screen_flash();
	a_players = get_players();
	_a1107 = a_players;
	_k1107 = getFirstArrayKey( _a1107 );
	while ( isDefined( _k1107 ) )
	{
		player = _a1107[ _k1107 ];
		player _time_bomb_restores_player_data_internal( save_struct );
		_k1107 = getNextArrayKey( _a1107, _k1107 );
	}
	remove_white_screen_flash();
}

has_packapunch_weapon()
{
	b_player_has_packapunch_weapon = 0;
	if ( isDefined( level.machine_assets ) && isDefined( level.machine_assets[ "packapunch" ] ) && isDefined( level.machine_assets[ "packapunch" ].weapon ) )
	{
		b_player_has_packapunch_weapon = self hasweapon( level.machine_assets[ "packapunch" ].weapon );
	}
	return b_player_has_packapunch_weapon;
}

_time_bomb_restores_player_data_internal( save_struct )
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		debug_time_bomb_print( "TIMEBOMB >> " + self.name + " in last stand, reviving..." );
		self maps/mp/zombies/_zm_laststand::auto_revive( self );
	}
	else
	{
		if ( isDefined( self.sessionstate ) && self.sessionstate == "spectator" )
		{
			self [[ level.spawnplayer ]]();
			self thread refresh_player_navcard_hud();
		}
	}
	if ( isDefined( self.is_drinking ) && self.is_drinking )
	{
		if ( self has_packapunch_weapon() )
		{
			self.is_drinking++;
		}
		self thread maps/mp/zombies/_zm_perks::perk_abort_drinking( 0,1 );
	}
	if ( self can_time_bomb_restore_data_on_player( save_struct ) )
	{
		debug_time_bomb_print( "TIMEBOMB >> restoring player " + self.name );
		if ( !isDefined( self.time_bomb_save_data ) && !isDefined( save_struct ) )
		{
			self.time_bomb_save_data = spawnstruct();
		}
		if ( !isDefined( save_struct ) )
		{
			s_temp = self.time_bomb_save_data;
		}
		else
		{
			s_temp = save_struct.player_saves[ self getentitynumber() ];
		}
		self setorigin( s_temp.player_origin );
		self setplayerangles( s_temp.player_angles );
		self setstance( s_temp.player_stance );
		self thread _restore_player_perks_and_weapons( s_temp );
		n_difference_in_score = s_temp.points_current - self.score;
		if ( n_difference_in_score > 0 )
		{
			self maps/mp/zombies/_zm_score::add_to_player_score( n_difference_in_score );
		}
		else
		{
			self maps/mp/zombies/_zm_score::minus_to_player_score( abs( n_difference_in_score ) );
		}
		if ( is_weapon_locker_available_in_game() )
		{
			if ( isDefined( s_temp.weapon_locker_data ) )
			{
				self maps/mp/zombies/_zm_weapon_locker::wl_set_stored_weapondata( s_temp.weapon_locker_data );
			}
			else
			{
				self maps/mp/zombies/_zm_weapon_locker::wl_clear_stored_weapondata();
			}
		}
		if ( isDefined( s_temp.account_value ) && isDefined( level.banking_map ) )
		{
			self.account_value = s_temp.account_value;
			self maps/mp/zombies/_zm_stats::set_map_stat( "depositBox", self.account_value, level.banking_map );
		}
		s_temp.save_ready = 1;
		if ( !isDefined( save_struct ) )
		{
			self.time_bomb_save_data = s_temp;
		}
		self ent_flag_wait( "time_bomb_restore_thread_done" );
	}
	else
	{
		debug_time_bomb_print( "TIMEBOMB >> restoring player " + self.name + " FAILED. No matching save detected" );
		self restore_player_to_initial_loadout();
	}
	self _give_revive_points( s_temp );
}

_restore_player_perks_and_weapons( s_temp )
{
	if ( isDefined( s_temp.is_spectator ) && s_temp.is_spectator )
	{
		self restore_player_to_initial_loadout( s_temp );
	}
	else
	{
		if ( isDefined( s_temp.is_last_stand ) && s_temp.is_last_stand )
		{
			self.stored_weapon_info = s_temp.stored_weapon_info;
/#
			assert( isDefined( level.zombie_last_stand_ammo_return ), "time bomb attempting to give player back weapons taken by last stand, but level.zombie_last_stand_ammo_return is undefined!" );
#/
			self [[ level.zombie_last_stand_ammo_return ]]();
		}
		else
		{
			a_current_perks = self get_player_perk_list();
			_a1251 = a_current_perks;
			_k1251 = getFirstArrayKey( _a1251 );
			while ( isDefined( _k1251 ) )
			{
				perk = _a1251[ _k1251 ];
				self notify( perk + "_stop" );
				_k1251 = getNextArrayKey( _a1251, _k1251 );
			}
			wait_network_frame();
			if ( get_players().size == 1 )
			{
				if ( isinarray( s_temp.perks_all, "specialty_quickrevive" ) && isDefined( level.solo_lives_given ) && level.solo_lives_given > 0 && level.solo_lives_given < 3 && isDefined( self.lives ) && self.lives == 1 )
				{
					level.solo_lives_given--;

				}
			}
			while ( isDefined( s_temp.perks_active ) )
			{
				i = 0;
				while ( i < s_temp.perks_active.size )
				{
					if ( get_players().size == 1 && s_temp.perks_active[ i ] == "specialty_quickrevive" )
					{
						if ( isDefined( level.solo_lives_given ) && level.solo_lives_given == 3 && isDefined( self.lives ) && self.lives == 0 )
						{
							i++;
							continue;
						}
					}
					else
					{
						self maps/mp/zombies/_zm_perks::give_perk( s_temp.perks_active[ i ] );
						wait_network_frame();
						if ( isDefined( s_temp.perks_disabled ) && isDefined( s_temp.perks_disabled[ s_temp.perks_active[ i ] ] ) && s_temp.perks_disabled[ s_temp.perks_active[ i ] ] )
						{
							self maps/mp/zombies/_zm_perks::perk_pause( s_temp.perks_active[ i ] );
							wait_network_frame();
						}
					}
					i++;
				}
			}
			self.disabled_perks = s_temp.perks_disabled;
			self.num_perks = s_temp.perk_count;
			self.lives = s_temp.lives_remaining;
			self takeallweapons();
			self set_player_melee_weapon( level.zombie_melee_weapon_player_init );
			i = 0;
			while ( i < s_temp.weapons.array.size )
			{
				str_weapon_temp = s_temp.weapons.array[ i ];
				n_ammo_reserve = s_temp.weapons.ammo_reserve[ i ];
				n_ammo_clip = s_temp.weapons.ammo_clip[ i ];
				n_type = s_temp.weapons.type[ i ];
				if ( !is_temporary_zombie_weapon( str_weapon_temp ) && str_weapon_temp != "time_bomb_zm" )
				{
					if ( isDefined( level.zombie_weapons[ str_weapon_temp ] ) && isDefined( level.zombie_weapons[ str_weapon_temp ].vox ) )
					{
						self maps/mp/zombies/_zm_weapons::weapon_give( str_weapon_temp, issubstr( str_weapon_temp, "upgrade" ) );
					}
					else
					{
						self giveweapon( str_weapon_temp, 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( str_weapon_temp ) );
					}
					if ( n_type == 1 )
					{
						self setweaponammofuel( str_weapon_temp, n_ammo_clip );
					}
					else if ( n_type == 2 )
					{
						self setweaponoverheating( 0, n_ammo_clip, str_weapon_temp );
					}
					else
					{
						if ( isDefined( n_ammo_clip ) )
						{
							self setweaponammoclip( str_weapon_temp, n_ammo_clip );
						}
					}
					self setweaponammostock( str_weapon_temp, n_ammo_reserve );
				}
				i++;
			}
			if ( s_temp.weapons.primary == "none" || s_temp.weapons.primary == "time_bomb_zm" )
			{
				i = 0;
				while ( i < s_temp.weapons.array.size )
				{
					str_weapon_type = weapontype( s_temp.weapons.array[ i ] );
					if ( !is_player_equipment( str_weapon_type ) || str_weapon_type == "bullet" && str_weapon_type == "projectile" )
					{
						str_weapon_temp = s_temp.weapons.array[ i ];
						break;
					}
					else
					{
						i++;
					}
				}
				self switchtoweapon( str_weapon_temp );
			}
			else
			{
				self switchtoweapon( s_temp.weapons.primary );
			}
			self maps/mp/zombies/_zm_equipment::equipment_take( self.current_equipment );
			if ( isDefined( self.deployed_equipment ) && isinarray( self.deployed_equipment, s_temp.current_equipment ) )
			{
				self maps/mp/zombies/_zm_equipment::equipment_take( s_temp.current_equipment );
			}
			if ( isDefined( s_temp.current_equipment ) )
			{
				self.do_not_display_equipment_pickup_hint = 1;
				self maps/mp/zombies/_zm_equipment::equipment_give( s_temp.current_equipment );
				self.do_not_display_equipment_pickup_hint = undefined;
			}
			if ( isinarray( s_temp.weapons.array, "time_bomb_zm" ) )
			{
				wait_network_frame();
				self.time_bomb_detonator_only = 1;
				self swap_weapon_to_detonator();
			}
		}
	}
	self ent_flag_set( "time_bomb_restore_thread_done" );
}

get_player_perk_list()
{
	a_perks = [];
	while ( isDefined( self.disabled_perks ) && isarray( self.disabled_perks ) )
	{
		a_keys = getarraykeys( self.disabled_perks );
		i = 0;
		while ( i < a_keys.size )
		{
			if ( self.disabled_perks[ a_keys[ i ] ] )
			{
				a_perks[ a_perks.size ] = a_keys[ i ];
			}
			i++;
		}
	}
	if ( isDefined( self.perks_active ) && isarray( self.perks_active ) )
	{
		a_perks = arraycombine( self.perks_active, a_perks, 0, 0 );
	}
	return a_perks;
}

restore_player_to_initial_loadout( s_temp )
{
	self takeallweapons();
/#
	assert( isDefined( level.start_weapon ), "time bomb attempting to restore a spectator, but level.start_weapon isn't defined!" );
#/
	self maps/mp/zombies/_zm_weapons::weapon_give( level.start_weapon );
/#
	assert( isDefined( level.zombie_lethal_grenade_player_init ), "time bomb attempting to restore a spectator, but level.zombie_lethal_grenade_player_init isn't defined!" );
#/
	self set_player_lethal_grenade( level.zombie_lethal_grenade_player_init );
	self giveweapon( level.zombie_lethal_grenade_player_init );
	self setweaponammoclip( level.zombie_lethal_grenade_player_init, 2 );
/#
	assert( isDefined( level.zombie_melee_weapon_player_init ), "time bomb attempting to restore a spectator, but level.zombie_melee_weapon_player_init isn't defined!" );
#/
	self giveweapon( level.zombie_melee_weapon_player_init );
	a_current_perks = self get_player_perk_list();
	_a1434 = a_current_perks;
	_k1434 = getFirstArrayKey( _a1434 );
	while ( isDefined( _k1434 ) )
	{
		perk = _a1434[ _k1434 ];
		self notify( perk + "_stop" );
		_k1434 = getNextArrayKey( _a1434, _k1434 );
	}
	if ( isDefined( s_temp ) && s_temp.points_current < 1500 && self.score < 1500 || level.round_number > 6 && self.score < 1500 && level.round_number > 6 )
	{
		self.score = 1500;
	}
}

_give_revive_points( save_struct )
{
	while ( isDefined( save_struct ) && isDefined( save_struct.player_used ) && save_struct.player_used == self )
	{
		_a1451 = get_players();
		_k1451 = getFirstArrayKey( _a1451 );
		while ( isDefined( _k1451 ) )
		{
			player = _a1451[ _k1451 ];
			if ( isDefined( player.score_lost_when_downed ) )
			{
				self maps/mp/zombies/_zm_score::player_add_points( "reviver", player.score_lost_when_downed );
			}
			_k1451 = getNextArrayKey( _a1451, _k1451 );
		}
	}
}

can_time_bomb_restore_data_on_player( save_struct )
{
	b_can_restore_data_on_player = 0;
	if ( isDefined( save_struct ) )
	{
		if ( isDefined( save_struct.player_saves ) )
		{
			b_can_restore_data_on_player = isDefined( save_struct.player_saves[ self getentitynumber() ] );
		}
	}
	else
	{
		b_global_save_exists = isDefined( level.time_bomb_save_data.n_time_id );
		if ( isDefined( self.time_bomb_save_data ) )
		{
			b_player_save_exists = isDefined( self.time_bomb_save_data.n_time_id );
		}
		if ( b_global_save_exists && b_player_save_exists )
		{
			if ( level.time_bomb_save_data.n_time_id == self.time_bomb_save_data.n_time_id )
			{
				b_can_restore_data_on_player = 1;
			}
		}
	}
	return b_can_restore_data_on_player;
}

time_bomb_clears_global_data()
{
	level setclientfield( "time_bomb_saved_round_number", 0 );
	if ( isDefined( level.time_bomb_save_data ) )
	{
		level.time_bomb_save_data.save_ready = 0;
		level.time_bomb_save_data.ammo_respawned_in_round = undefined;
	}
}

time_bomb_clears_player_data()
{
	a_players = get_players();
	_a1502 = a_players;
	_k1502 = getFirstArrayKey( _a1502 );
	while ( isDefined( _k1502 ) )
	{
		player = _a1502[ _k1502 ];
		if ( isDefined( player.time_bomb_save_data ) )
		{
			player.time_bomb_save_data = undefined;
		}
		_k1502 = getNextArrayKey( _a1502, _k1502 );
	}
}

timebomb_change_to_round( n_target_round )
{
	debug_time_bomb_print( "TIMEBOMB >> changing from round " + level.round_number + " to round " + n_target_round );
	if ( n_target_round < 1 )
	{
		n_target_round = 1;
	}
	level.time_bomb_round_change = 1;
	level.zombie_round_start_delay = 0;
	level.zombie_round_end_delay = 0;
	n_between_round_time = level.zombie_vars[ "zombie_between_round_time" ];
	level.zombie_vars[ "zombie_between_round_time" ] = 0;
	level notify( "end_of_round" );
	flag_set( "end_round_wait" );
	maps/mp/zombies/_zm::ai_calculate_health( n_target_round );
	if ( level._time_bomb.round_initialized )
	{
		level._time_bomb.restoring_initialized_round = 1;
		n_target_round--;

	}
	level.round_number = n_target_round;
	setroundsplayed( n_target_round );
	level waittill( "between_round_over" );
	timebomb_wait_for_hostmigration();
	level.zombie_round_start_delay = undefined;
	level.time_bomb_round_change = undefined;
	level.zombie_vars[ "zombie_between_round_time" ] = n_between_round_time;
	flag_clear( "end_round_wait" );
}

_time_bomb_kill_all_active_enemies()
{
	flag_clear( "spawn_zombies" );
	zombies = time_bomb_get_enemy_array();
	while ( zombies.size > 0 )
	{
		i = 0;
		while ( i < zombies.size )
		{
			timebomb_wait_for_hostmigration();
			if ( isDefined( zombies[ i ] ) )
			{
				zombies[ i ] thread _kill_time_bomb_enemy();
			}
			if ( ( i % 3 ) == 0 )
			{
				wait_network_frame();
			}
			i++;
		}
		zombies = time_bomb_get_enemy_array();
	}
	flag_set( "time_bomb_round_killed" );
}

_kill_time_bomb_enemy()
{
	self dodamage( self.health + 100, self.origin, self, self, self.origin );
	self ghost();
	playfx( level._effect[ "time_bomb_kills_enemy" ], self.origin );
	if ( isDefined( self ) && isDefined( self.anchor ) )
	{
		self.anchor delete();
	}
	wait_network_frame();
	if ( isDefined( self ) )
	{
		if ( isDefined( self.script_mover ) )
		{
			self.script_mover delete();
		}
		self delete();
	}
}

time_bomb_get_enemy_array()
{
	if ( isDefined( level._time_bomb.custom_funcs_get_enemies ) )
	{
		a_enemies = [[ level._time_bomb.custom_funcs_get_enemies ]]();
	}
	else
	{
		a_enemies = get_round_enemy_array();
	}
	return a_enemies;
}

_time_bomb_show_overlay()
{
	flag_clear( "time_bomb_restore_done" );
	level setclientfield( "time_bomb_hud_toggle", 1 );
	a_players = get_players();
	_a1628 = a_players;
	_k1628 = getFirstArrayKey( _a1628 );
	while ( isDefined( _k1628 ) )
	{
		player = _a1628[ _k1628 ];
		maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zombie_time_bomb_overlay", player );
		player freezecontrols( 1 );
		player enableinvulnerability();
		_k1628 = getNextArrayKey( _a1628, _k1628 );
	}
	level thread kill_overlay_at_match_end();
}

_time_bomb_hide_overlay( n_time_start )
{
	n_time_end = getTime();
	if ( isDefined( n_time_start ) )
	{
		n_time_elapsed = ( n_time_end - n_time_start ) * 0,001;
		n_delay = 4 - n_time_elapsed;
		n_delay = clamp( n_delay, 0, 4 );
		if ( n_delay > 0 )
		{
			wait n_delay;
			timebomb_wait_for_hostmigration();
		}
	}
	timebomb_wait_for_hostmigration();
	a_players = get_players();
	level setclientfield( "time_bomb_hud_toggle", 0 );
	flag_set( "time_bomb_restore_done" );
	_a1664 = a_players;
	_k1664 = getFirstArrayKey( _a1664 );
	while ( isDefined( _k1664 ) )
	{
		player = _a1664[ _k1664 ];
		player freezecontrols( 0 );
		player thread _disable_invulnerability();
		_k1664 = getNextArrayKey( _a1664, _k1664 );
	}
}

kill_overlay_at_match_end()
{
	level endon( "time_bomb_overlay_deactivated" );
	level waittill( "end_game" );
	if ( flag( "time_bomb_restore_active" ) )
	{
		wait 5;
	}
	level thread _deactivate_lerp_thread();
}

_disable_invulnerability()
{
	self endon( "death" );
	self endon( "disconnect" );
	wait 2;
	if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
/#
		if ( getDvarInt( "zombie_cheat" ) >= 1 )
		{
			return;
#/
		}
		debug_time_bomb_print( "disabling invulnerability on " + self.name );
		self disableinvulnerability();
	}
}

debug_time_bomb_print( str_text )
{
/#
	if ( getDvarInt( #"6F8A0CF1" ) )
	{
		iprintln( str_text );
#/
	}
}

time_bomb_spawn_func()
{
	self endon( "death" );
	s_temp = level.time_bomb_save_data;
	if ( isDefined( level.timebomb_override_struct ) )
	{
		s_temp = level.timebomb_override_struct;
	}
	if ( !isDefined( s_temp.respawn_count ) )
	{
		s_temp.respawn_count = 0;
	}
	b_can_respawn_zombie = s_temp.enemies.size > s_temp.respawn_count;
	if ( b_can_respawn_zombie )
	{
		self _restore_zombie_data( s_temp.enemies[ s_temp.respawn_count ] );
		self.spawn_point_override = s_temp.enemies[ s_temp.respawn_count ];
		s_temp.respawn_count++;
		self thread _time_bomb_spawns_zombie();
	}
	if ( s_temp.enemies.size == s_temp.respawn_count )
	{
		flag_set( "time_bomb_zombie_respawning_done" );
	}
	return 1;
}

time_bomb_enemy_respawn_failsafe()
{
	while ( !flag( "time_bomb_zombie_respawning_done" ) )
	{
		if ( get_current_zombie_count() >= level.zombie_ai_limit || level.zombie_total == 0 )
		{
			flag_set( "time_bomb_zombie_respawning_done" );
		}
		wait 0,5;
	}
}

_time_bomb_spawns_zombie()
{
	if ( isDefined( self.anchor ) )
	{
		self.anchor delete();
	}
	self maps/mp/zombies/_zm_spawner::do_zombie_spawn();
	self thread _zombies_go_back_into_ai_when_time_bomb_is_done();
}

_restore_zombie_data( s_info )
{
	if ( isDefined( s_info.zombie_move_speed ) )
	{
		self.zombie_move_speed = s_info.zombie_move_speed;
	}
	self.targetname = s_info.targetname;
	self.script_noteworthy = s_info.script_noteworthy;
	self.script_string = s_info.script_string;
	self.target = s_info.target;
	if ( isDefined( s_info.is_traversing ) || s_info.is_traversing && isDefined( self.is_traversing ) && self.is_traversing )
	{
		self notify( "killanimscript" );
	}
	self.is_traversing = 0;
	self.attacking_node = s_info.attacking_node;
	self.attacking_spot = s_info.attacking_spot;
	self.first_node = s_info.first_node;
	self.attacking_spot_index = s_info.attacking_spot_index;
	self maps/mp/zombies/_zm_spawner::reset_attack_spot();
	self.entrance_nodes = s_info.entrance_nodes;
	self.attacking_spot_string = s_info.attacking_spot_string;
	if ( !isDefined( s_info.completed_emerging_into_playable_area ) )
	{
		s_info.completed_emerging_into_playable_area = 0;
	}
	self.completed_emerging_into_playable_area = s_info.completed_emerging_into_playable_area;
	if ( isDefined( self.completed_emerging_into_playable_area ) && self.completed_emerging_into_playable_area )
	{
	}
	if ( isDefined( s_info.has_legs ) )
	{
		self.has_legs = s_info.has_legs;
		if ( isDefined( self.has_legs ) && !self.has_legs )
		{
			self setphysparams( 15, 0, 24 );
		}
	}
	self.a.gib_ref = s_info.gib_ref;
	if ( isDefined( self.has_legs ) && !self.has_legs && isDefined( self.a.gib_ref ) )
	{
		self thread maps/mp/animscripts/zm_death::do_gib();
	}
	if ( isDefined( s_info.in_the_ground ) && s_info.in_the_ground )
	{
		self maps/mp/zombies/_zm_spawner::zombie_eye_glow();
		self._rise_spot = s_info;
	}
	if ( isDefined( s_info.zombie_faller_location ) && isDefined( s_info.spawn_point ) && isDefined( s_info.spawn_point.script_noteworthy ) )
	{
		s_info.script_noteworthy = s_info.spawn_point.script_noteworthy;
	}
	self.doing_equipment_attack = s_info.doing_equipment_attack;
	if ( isDefined( self.doing_equipment_attack ) && self.doing_equipment_attack )
	{
		self stopanimscripted();
	}
	self.is_traversing = s_info.is_traversing;
	self.spawn_point = s_info.spawn_point;
	if ( isDefined( s_info.spawn_point ) && !self.completed_emerging_into_playable_area )
	{
		self.script_noteworthy = s_info.spawn_point.script_noteworthy;
		self.script_string = s_info.spawn_point.script_string;
		self.target = s_info.spawn_point.target;
	}
	self.time_bomb_restored_data = s_info;
	self zombie_history( "time bomb -> all data restored " );
}

time_bomb_round_wait()
{
	maps/mp/zombies/_zm::round_wait();
	if ( isDefined( level._time_bomb.restoring_initialized_round ) && level._time_bomb.restoring_initialized_round && isDefined( level.time_bomb_save_data ) && isDefined( level.time_bomb_save_data.round_initialized ) && !level.time_bomb_save_data.round_initialized )
	{
		level.round_number--;

	}
	else
	{
		if ( isDefined( level._time_bomb.changing_round ) && !level._time_bomb.changing_round && !level.time_bomb_save_data.round_initialized && level._time_bomb.round_initialized )
		{
			level.round_number--;

		}
		else
		{
			if ( isDefined( level._time_bomb.changing_round ) && level._time_bomb.changing_round && !level._time_bomb.round_initialized )
			{
				level.round_number--;

			}
		}
	}
	level._time_bomb.changing_round = undefined;
	level._time_bomb.restoring_initialized_round = undefined;
	level._time_bomb.round_initialized = 0;
	if ( flag( "time_bomb_restore_active" ) )
	{
		if ( !is_time_bomb_round_change() )
		{
			flag_wait( "time_bomb_round_killed" );
			flag_wait( "time_bomb_enemies_restored" );
			time_bomb_round_wait();
		}
	}
	if ( isDefined( level.time_bomb_restored_into_current_round ) && level.time_bomb_restored_into_current_round )
	{
		level.old_music_state = undefined;
		level.time_bomb_restored_into_current_round = undefined;
	}
	level notify( "time_bomb_round_wait_done" );
}

_zombies_go_back_into_ai_when_time_bomb_is_done()
{
	self endon( "death" );
	if ( isDefined( self ) )
	{
		playfxontag( level._effect[ "time_bomb_respawns_enemy" ], self, "J_SpineLower" );
		self setgoalpos( self.origin );
		self.angles = self.time_bomb_restored_data.angles;
		flag_waitopen( "time_bomb_restore_active" );
		str_restore_state = self.time_bomb_restored_data.ai_state;
		s_temp = self.time_bomb_restored_data;
		str_notify_message = undefined;
		if ( isDefined( str_restore_state ) )
		{
			if ( str_restore_state == "find_flesh" )
			{
				str_notify_message = self _handle_find_flesh( s_temp );
			}
			else if ( str_restore_state == "zombie_goto_entrance" )
			{
				str_notify_message = self _send_zombie_to_barricade();
			}
			else if ( str_restore_state == "zombie_think" || str_restore_state == "idle" )
			{
				if ( isDefined( self.in_the_ground ) && self.in_the_ground )
				{
					self waittill( "risen" );
					str_notify_message = self _handle_find_flesh( s_temp );
				}
				else
				{
					if ( isDefined( self.completed_emerging_into_playable_area ) )
					{
						if ( self.completed_emerging_into_playable_area )
						{
							str_notify_message = self _handle_find_flesh( s_temp );
						}
						else
						{
							str_notify_message = self _send_zombie_to_barricade();
						}
					}
				}
			}
		}
		self notify( "zombie_custom_think_done" );
		if ( !isDefined( str_notify_message ) )
		{
			str_notify_message = "<undefined>";
		}
		self zombie_history( "time bomb -> zombie restored with string = " + str_notify_message );
	}
}

_handle_find_flesh( s_temp )
{
	if ( s_temp.completed_emerging_into_playable_area )
	{
		self notify( "stop_zombie_goto_entrance" );
		self.target = undefined;
	}
	else
	{
		self.target = s_temp.spawn_point.target;
	}
	return "find_flesh";
}

_send_zombie_to_barricade()
{
	if ( isDefined( self.time_bomb_restored_data.entrance_nodes ) && self.time_bomb_restored_data.entrance_nodes.size > 0 )
	{
		a_entrance_nodes = self.time_bomb_restored_data.entrance_nodes;
	}
	else
	{
		a_entrance_nodes = level.exterior_goals;
	}
	nd_closest = getclosest( self.origin, a_entrance_nodes );
	str_notify_message = nd_closest.script_string;
	if ( isDefined( self.time_bomb_restored_data.traversing_over_barrier_into_playspace ) && self.time_bomb_restored_data.traversing_over_barrier_into_playspace )
	{
		self thread _barrier_jump_failsafe();
	}
	return str_notify_message;
}

_barrier_jump_failsafe()
{
	self endon( "death" );
	wait randomfloatrange( 2,5, 3 );
	if ( !isDefined( self.completed_emerging_into_playable_area ) || !self.completed_emerging_into_playable_area && self in_playable_area() )
	{
		self notify( "goal" );
		self zombie_complete_emerging_into_playable_area();
		self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	}
}

time_bomb_custom_round_change()
{
	level thread _monitor_zombie_total_init();
	if ( is_time_bomb_round_change() )
	{
		level.time_bomb_restored_into_current_round = 1;
	}
	else
	{
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
		round_one_up();
	}
}

_monitor_zombie_total_init()
{
	level notify( "_kill_end_of_round_monitor" );
	level endon( "_kill_end_of_round_monitor" );
	level endon( "end_of_round" );
	level._time_bomb.round_initialized = 0;
	level waittill( "zombie_total_set" );
	level._time_bomb.round_initialized = 1;
}

is_time_bomb_round_change()
{
	if ( isDefined( level.time_bomb_round_change ) )
	{
		return level.time_bomb_round_change;
	}
}

time_bomb_overlay_lerp_thread()
{
	level endon( "time_bomb_overlay_deactivated" );
	n_frames = 40;
	n_change_per_frame = 1 / n_frames;
	i = 0;
	while ( i < n_frames )
	{
		a_players = get_players();
		j = 0;
		while ( j < a_players.size )
		{
			self maps/mp/_visionset_mgr::vsmgr_set_state_active( a_players[ j ], clamp( i * n_change_per_frame, 0, 1 ) );
			j++;
		}
		wait 0,05;
		i++;
	}
	flag_wait( "time_bomb_restore_done" );
	i = 0;
	while ( i < n_frames )
	{
		a_players = get_players();
		j = 0;
		while ( j < a_players.size )
		{
			self maps/mp/_visionset_mgr::vsmgr_set_state_active( a_players[ j ], clamp( 1 - ( i * n_change_per_frame ), 0, 1 ) );
			j++;
		}
		wait 0,05;
		i++;
	}
	level thread _deactivate_lerp_thread();
}

_deactivate_lerp_thread()
{
	a_players = get_players();
	i = 0;
	while ( i < a_players.size )
	{
		maps/mp/_visionset_mgr::deactivate_per_player( "overlay", "zombie_time_bomb_overlay", a_players[ i ] );
		i++;
	}
	level notify( "time_bomb_overlay_deactivated" );
}

time_bomb_hud_icon_show()
{
	time_bomb_destroy_hud_elem();
	level setclientfield( "time_bomb_saved_round_number", level.round_number );
}

time_bomb_destroy_hud_elem()
{
	level setclientfield( "time_bomb_saved_round_number", 0 );
}

is_zombie_round()
{
	return 0;
}

time_bomb_respawns_zombies( save_struct )
{
	s_temp = save_struct;
	if ( save_struct.round_number != level.round_number )
	{
		flag_wait( "time_bomb_round_killed" );
	}
	flag_clear( "time_bomb_zombie_respawning_done" );
	n_time_start = getTime();
	n_old_spawn_delay = level.zombie_vars[ "zombie_spawn_delay" ];
	level.zombie_vars[ "zombie_spawn_delay" ] = 0;
	level.zombie_total = save_struct.enemies.size + save_struct.zombie_total;
	level.zombie_custom_think_logic = ::time_bomb_spawn_func;
	level thread time_bomb_enemy_respawn_failsafe();
	if ( level.zombie_total == 0 )
	{
		flag_set( "time_bomb_zombie_respawning_done" );
	}
	flag_set( "spawn_zombies" );
	flag_wait( "time_bomb_zombie_respawning_done" );
	level.zombie_vars[ "zombie_spawn_delay" ] = n_old_spawn_delay;
	flag_set( "time_bomb_enemies_restored" );
	n_time_end = getTime();
	n_restore_time = ( n_time_end - n_time_start ) * 0,001;
	debug_time_bomb_print( "TIMEBOMB >> ENEMIES RESTORED IN " + n_restore_time + " SECONDS!" );
	level.zombie_custom_think_logic = undefined;
}

time_bomb_saves_zombie_data( s_data )
{
	s_data.origin = self.origin;
	s_data.angles = self.angles;
	s_data.targetname = self.targetname;
	s_data.script_noteworthy = self.script_noteworthy;
	if ( !isDefined( s_data.script_noteworthy ) )
	{
		s_data.script_noteworthy = "spawn_location";
	}
	s_data.spawn_point = self.spawn_point;
	s_data.is_traversing = self.is_traversing;
	s_data.traversestartnode = self.traversestartnode;
	if ( isDefined( s_data.is_traversing ) && s_data.is_traversing )
	{
		if ( isDefined( self.traversestartnode ) && isDefined( self.traversestartnode.origin ) )
		{
			s_data.origin = self.traversestartnode.origin;
		}
	}
	if ( self _is_traversing_over_barrier_from_outside_playable_space() )
	{
		s_data.traversing_over_barrier_into_playspace = 1;
		s_data.origin = self.entrance_nodes[ 0 ].neg_start.origin;
	}
	s_data.target = self.target;
	s_data.is_traversing = self.is_traversing;
	s_data.ai_state = self.ai_state;
	s_data.attacking_node = self.attacking_node;
	s_data.attacking_spot = self.attacking_spot;
	s_data.attacking_spot_index = self.attacking_spot_index;
	if ( isDefined( s_data.attacking_node ) )
	{
		s_data.attacking_spot_string = self.attacking_node.script_string;
	}
	s_data.entrance_nodes = self.entrance_nodes;
	s_data.completed_emerging_into_playable_area = self.completed_emerging_into_playable_area;
	s_data.in_the_ground = self.in_the_ground;
	s_data._rise_spot = self._rise_spot;
	s_data.doing_equipment_attack = self.doing_equipment_attack;
	s_data.is_traversing = self.is_traversing;
	s_data.first_node = self.first_node;
	s_data.has_legs = self.has_legs;
	s_data.gib_ref = self.a.gib_ref;
	s_data.zombie_faller_location = self.zombie_faller_location;
	s_data.zombie_move_speed = self.zombie_move_speed;
	return s_data;
}

_is_traversing_over_barrier_from_outside_playable_space()
{
	if ( isDefined( self.completed_emerging_into_playable_area ) && !self.completed_emerging_into_playable_area && isDefined( self.entrance_nodes ) && self.entrance_nodes.size == 1 && self.ai_state == "zombie_goto_entrance" && self isinscriptedstate() && isDefined( self.target ) )
	{
		b_is_traversing_into_playspace = self.target == self.entrance_nodes[ 0 ].neg_start.targetname;
	}
	return b_is_traversing_into_playspace;
}

_get_time_bomb_round_type()
{
	a_round_type = [];
	a_keys = getarraykeys( level._time_bomb.enemy_type );
	i = 0;
	while ( i < a_keys.size )
	{
		if ( [[ level._time_bomb.enemy_type[ a_keys[ i ] ].conditions_for_round ]]() )
		{
			a_round_type[ a_round_type.size ] = a_keys[ i ];
		}
		i++;
	}
	if ( a_round_type.size == 0 )
	{
		a_round_type[ 0 ] = level._time_bomb.enemy_type_default;
	}
	if ( a_round_type.size > 1 )
	{
		str_types = "";
		i = 0;
		while ( i < a_round_type.size )
		{
			str_types = ( str_types + " " ) + a_round_type;
			i++;
		}
/#
		assertmsg( "_get_time_bomb_round_type conditions passed multiple times for the following types: " + str_types );
#/
	}
	debug_time_bomb_print( "round type = " + a_round_type[ 0 ] );
	return a_round_type[ 0 ];
}

is_spectator()
{
	if ( isplayer( self ) && isDefined( self.sessionstate ) )
	{
		return self.sessionstate == "spectator";
	}
}

_time_bomb_resets_all_barrier_attack_spots_taken()
{
	_a2282 = level.exterior_goals;
	_k2282 = getFirstArrayKey( _a2282 );
	while ( isDefined( _k2282 ) )
	{
		barrier = _a2282[ _k2282 ];
		i = 0;
		while ( i < barrier.attack_spots_taken.size )
		{
			barrier.attack_spots_taken[ i ] = 0;
			i++;
		}
		_k2282 = getNextArrayKey( _a2282, _k2282 );
	}
}

destroy_time_bomb_save_if_user_bleeds_out_or_disconnects()
{
	self endon( "player_lost_time_bomb" );
	self waittill_any( "bled_out", "disconnect" );
	destroy_time_bomb_save();
}

show_time_bomb_hints()
{
	self endon( "death_or_disconnect" );
	self endon( "player_lost_time_bomb" );
	if ( !isDefined( self.time_bomb_hints_shown ) )
	{
		self.time_bomb_hints_shown = 0;
	}
	if ( !self.time_bomb_hints_shown )
	{
		self.time_bomb_hints_shown = 1;
		wait 0,5;
		self show_time_bomb_notification( &"ZOMBIE_TIMEBOMB_PICKUP" );
		self thread _watch_for_player_switch_to_time_bomb();
		self waittill_notify_or_timeout( "player_holding_time_bomb", 3,5 );
		self clean_up_time_bomb_notifications();
		if ( !isDefined( self.time_bomb_held ) )
		{
			self waittill( "player_holding_time_bomb" );
		}
		wait 0,5;
		self show_time_bomb_notification( &"ZOMBIE_TIMEBOMB_HOWTO" );
		self waittill_notify_or_timeout( "player_activates_timebomb", 3,5 );
		self clean_up_time_bomb_notifications();
	}
}

_watch_for_player_switch_to_time_bomb()
{
	self endon( "death_or_disconnect" );
	self waittill( "weapon_change", new_weapon );
	self notify( "player_holding_time_bomb" );
	self.time_bomb_held = 1;
}

slow_all_actors()
{
	level endon( "time_bomb_stop_slow_all_actors" );
	set_all_actor_anim_rate( 0,8 );
	wait 0,5;
	timebomb_wait_for_hostmigration();
	set_all_actor_anim_rate( 0,6 );
	wait 0,5;
	timebomb_wait_for_hostmigration();
	set_all_actor_anim_rate( 0,4 );
	wait 0,5;
	timebomb_wait_for_hostmigration();
	set_all_actor_anim_rate( 0,2 );
	wait 0,5;
	timebomb_wait_for_hostmigration();
	set_all_actor_anim_rate( 0,05 );
	wait 2;
}

all_actors_resume_speed()
{
	flag_wait( "time_bomb_enemies_restored" );
	timebomb_wait_for_hostmigration();
	wait_network_frame();
	wait_network_frame();
	level notify( "time_bomb_stop_slow_all_actors" );
	set_actor_traverse_callbacks();
	set_all_actor_anim_rate( 0,2 );
	wait 0,5;
	timebomb_wait_for_hostmigration();
	set_all_actor_anim_rate( 0,4 );
	wait 0,5;
	timebomb_wait_for_hostmigration();
	set_all_actor_anim_rate( 0,6 );
	wait 0,5;
	timebomb_wait_for_hostmigration();
	set_all_actor_anim_rate( 0,8 );
	wait 0,5;
	timebomb_wait_for_hostmigration();
	set_all_actor_anim_rate( 1, 1 );
	level thread restore_actor_traverse_callbacks();
	wait_network_frame();
	cleanup_actor_anim_flags();
}

set_actor_traverse_callbacks()
{
	actors = getaispeciesarray( "all", "all" );
	i = 0;
	while ( i < actors.size )
	{
		actors[ i ].pre_traverse_old = actors[ i ].pre_traverse;
		actors[ i ].pre_traverse = ::time_bomb_pre_traverse;
		actors[ i ].post_traverse_old = actors[ i ].post_traverse;
		actors[ i ].post_traverse = ::time_bomb_post_traverse;
		if ( isDefined( actors[ i ].in_the_ground ) && !actors[ i ].in_the_ground || actors[ i ] isinscriptedstate() || !isDefined( actors[ i ].zombie_init_done ) && !actors[ i ].zombie_init_done )
		{
			actors[ i ].do_not_set_anim_rate = 1;
			actors[ i ] setclientfield( "anim_rate", 1 );
			qrate = actors[ i ] getclientfield( "anim_rate" );
			actors[ i ] setentityanimrate( qrate );
		}
		if ( isDefined( level.time_bomb_custom_actor_speedup_func ) )
		{
			actors[ i ] [[ level.time_bomb_custom_actor_speedup_func ]]();
		}
		i++;
	}
}

restore_actor_traverse_callbacks()
{
	actors = getaispeciesarray( "all", "all" );
	i = 0;
	while ( i < actors.size )
	{
		actors[ i ].pre_traverse = undefined;
		actors[ i ].post_traverse = undefined;
		if ( isDefined( actors[ i ].pre_traverse_old ) )
		{
			actors[ i ].pre_traverse = actors[ i ].pre_traverse_old;
		}
		if ( isDefined( actors[ i ].post_traverse_old ) )
		{
			actors[ i ].post_traverse = actors[ i ].post_traverse_old;
		}
		i++;
	}
}

time_bomb_pre_traverse()
{
	self.is_about_to_traverse = 1;
}

time_bomb_post_traverse()
{
	self.is_about_to_traverse = undefined;
}

set_actor_anim_rate( rate, b_force_update )
{
	if ( !isDefined( b_force_update ) )
	{
		b_force_update = 0;
	}
	self endon( "death" );
	level endon( "time_bomb_stop_slow_all_actors" );
	if ( !b_force_update )
	{
		if ( isDefined( self.in_the_ground ) && !self.in_the_ground || self isinscriptedstate() && isDefined( self.do_not_set_anim_rate ) && self.do_not_set_anim_rate )
		{
			return;
		}
		if ( isDefined( self.is_about_to_traverse ) || isDefined( self.ignore_timebomb_slowdown ) && self.ignore_timebomb_slowdown )
		{
			rate = 1;
		}
	}
	self setclientfield( "anim_rate", rate );
	qrate = self getclientfield( "anim_rate" );
	self setentityanimrate( qrate );
	wait ( 0,5 * 0,5 );
	self.preserve_asd_substates = 1;
	self.needs_run_update = 1;
	self notify( "needs_run_update" );
}

set_all_actor_anim_rate( rate, b_force )
{
	actors = getaispeciesarray( "all", "all" );
	i = 0;
	while ( i < actors.size )
	{
		actors[ i ] thread set_actor_anim_rate( rate, b_force );
		i++;
	}
}

cleanup_actor_anim_flags()
{
	actors = getaispeciesarray( "all", "all" );
	i = 0;
	while ( i < actors.size )
	{
		actors[ i ].preserve_asd_substates = 0;
		i++;
	}
}

white_screen_flash()
{
	level.time_bomb_whiteout_hudelem = _create_white_screen_hud_elem();
	level.time_bomb_whiteout_hudelem fadeovertime( 0,2 );
	level.time_bomb_whiteout_hudelem.alpha = 1;
}

_create_white_screen_hud_elem()
{
	hud_elem = newhudelem();
	hud_elem.x = 0;
	hud_elem.y = 0;
	hud_elem.horzalign = "fullscreen";
	hud_elem.vertalign = "fullscreen";
	hud_elem.foreground = 1;
	hud_elem.alpha = 0;
	hud_elem.hidewheninmenu = 0;
	hud_elem.shader = "white";
	hud_elem setshader( "white", 640, 480 );
	return hud_elem;
}

remove_white_screen_flash()
{
	level.time_bomb_whiteout_hudelem fadeovertime( 0,2 );
	level.time_bomb_whiteout_hudelem.alpha = 0;
	wait 0,2;
	level.time_bomb_whiteout_hudelem destroy();
}

swap_weapon_to_detonator( e_grenade )
{
	self endon( "death_or_disconnect" );
	self endon( "player_lost_time_bomb" );
	b_switch_to_weapon = 0;
	if ( isDefined( e_grenade ) )
	{
		b_switch_to_weapon = 1;
		e_grenade waittill_notify_or_timeout( "stationary", 0,6 );
	}
	self takeweapon( "time_bomb_zm" );
	self giveweapon( "time_bomb_detonator_zm" );
	self setweaponammoclip( "time_bomb_detonator_zm", 0 );
	self setweaponammostock( "time_bomb_detonator_zm", 0 );
	self setactionslot( 2, "weapon", "time_bomb_detonator_zm" );
	if ( b_switch_to_weapon )
	{
		self switchtoweapon( "time_bomb_detonator_zm" );
	}
	self giveweapon( "time_bomb_zm" );
}

swap_weapon_to_time_bomb()
{
	self takeweapon( "time_bomb_detonator_zm" );
	self giveweapon( "time_bomb_zm" );
	self setactionslot( 2, "weapon", "time_bomb_zm" );
}

test_mode()
{
	self endon( "death_or_disconnect" );
	while ( 1 )
	{
		level waittill( "time_bomb_test_mode_start" );
		_test_mode_loop();
	}
}

_test_mode_loop()
{
	level endon( "time_bomb_test_mode_end" );
	player = get_players()[ 0 ];
	if ( !player hasweapon( "time_bomb_zm" ) )
	{
		player player_give_time_bomb();
	}
	while ( 1 )
	{
		time_bomb_saves_data();
		print_ent_count();
		wait 8;
		detonate_time_bomb();
		print_ent_count();
		wait 12;
	}
}

print_ent_count()
{
	a_ents_origins = getentarray( "script_origin", "classname" );
	a_ents_models = getentarray( "script_model", "classname" );
	iprintln( "ENT COUNT - script_origins: " + a_ents_origins.size + ". script_models: " + a_ents_models.size );
}
