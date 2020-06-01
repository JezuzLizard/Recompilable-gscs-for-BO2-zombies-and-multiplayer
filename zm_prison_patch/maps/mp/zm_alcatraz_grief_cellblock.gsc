#include maps/mp/gametypes_zm/zmeat;
#include maps/mp/zm_alcatraz_traps;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zm_prison;
#include maps/mp/zombies/_zm_race_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

precache()
{
}

zgrief_preinit()
{
	registerclientfield( "toplayer", "meat_stink", 1, 1, "int" );
	level.givecustomloadout = ::maps/mp/zm_prison::givecustomloadout;
	zgrief_init();
}

zgrief_init()
{
	encounter_init();
	flag_wait( "start_zombie_round_logic" );
	if ( level.round_number < 4 && level.gamedifficulty != 0 )
	{
		level.zombie_move_speed = 35;
	}
}

encounter_init()
{
	level._game_module_player_laststand_callback = ::alcatraz_grief_laststand_weapon_save;
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
	level.gamemode_post_spawn_logic = ::give_player_shiv;
}

alcatraz_grief_laststand_weapon_save( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( self hasperk( "specialty_additionalprimaryweapon" ) )
	{
		primary_weapons_that_can_be_taken = [];
		primaryweapons = self getweaponslistprimaries();
		i = 0;
		while ( i < primaryweapons.size )
		{
			if ( maps/mp/zombies/_zm_weapons::is_weapon_included( primaryweapons[ i ] ) || maps/mp/zombies/_zm_weapons::is_weapon_upgraded( primaryweapons[ i ] ) )
			{
				primary_weapons_that_can_be_taken[ primary_weapons_that_can_be_taken.size ] = primaryweapons[ i ];
			}
			i++;
		}
		if ( primary_weapons_that_can_be_taken.size >= 3 )
		{
			weapon_to_take = primary_weapons_that_can_be_taken[ primary_weapons_that_can_be_taken.size - 1 ];
			self takeweapon( weapon_to_take );
			self.weapon_taken_by_losing_specialty_additionalprimaryweapon = weapon_to_take;
		}
	}
	self.grief_savedweapon_weapons = self getweaponslist();
	self.grief_savedweapon_weaponsammo_stock = [];
	self.grief_savedweapon_weaponsammo_clip = [];
	self.grief_savedweapon_currentweapon = self getcurrentweapon();
	self.grief_savedweapon_grenades = self get_player_lethal_grenade();
	if ( isDefined( self.grief_savedweapon_grenades ) )
	{
		self.grief_savedweapon_grenades_clip = self getweaponammoclip( self.grief_savedweapon_grenades );
	}
	self.grief_savedweapon_tactical = self get_player_tactical_grenade();
	if ( isDefined( self.grief_savedweapon_tactical ) )
	{
		self.grief_savedweapon_tactical_clip = self getweaponammoclip( self.grief_savedweapon_tactical );
	}
	i = 0;
	while ( i < self.grief_savedweapon_weapons.size )
	{
		self.grief_savedweapon_weaponsammo_clip[ i ] = self getweaponammoclip( self.grief_savedweapon_weapons[ i ] );
		self.grief_savedweapon_weaponsammo_stock[ i ] = self getweaponammostock( self.grief_savedweapon_weapons[ i ] );
		i++;
	}
	if ( isDefined( self.hasriotshield ) && self.hasriotshield )
	{
		self.grief_hasriotshield = 1;
	}
	if ( self hasweapon( "claymore_zm" ) )
	{
		self.grief_savedweapon_claymore = 1;
		self.grief_savedweapon_claymore_clip = self getweaponammoclip( "claymore_zm" );
	}
}

precache_team_characters()
{
	precachemodel( "c_zom_player_grief_guard_fb" );
	precachemodel( "c_zom_oleary_shortsleeve_viewhands" );
	precachemodel( "c_zom_player_grief_inmate_fb" );
	precachemodel( "c_zom_grief_guard_viewhands" );
}

give_team_characters()
{
	self detachall();
	self set_player_is_female( 0 );
	if ( !isDefined( self.characterindex ) )
	{
		self.characterindex = 1;
		if ( self.team == "axis" )
		{
			self.characterindex = 0;
		}
	}
	switch( self.characterindex )
	{
		case 0:
		case 2:
			self setmodel( "c_zom_player_grief_inmate_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
			self.characterindex = 0;
			break;
		case 1:
		case 3:
			self setmodel( "c_zom_player_grief_guard_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_grief_guard_viewhands" );
			self.characterindex = 1;
			break;
	}
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
}

give_player_shiv()
{
	self takeweapon( "knife_zm" );
	self giveweapon( "knife_zm_alcatraz" );
}

grief_treasure_chest_init()
{
	chest1 = getstruct( "start_chest", "script_noteworthy" );
	chest2 = getstruct( "cafe_chest", "script_noteworthy" );
	setdvar( "disableLookAtEntityLogic", 1 );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	level.chests[ level.chests.size ] = chest2;
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
}

main()
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "cellblock" );
	grief_treasure_chest_init();
	precacheshader( "zm_al_wth_zombie" );
	array_thread( level.zombie_spawners, ::add_spawn_function, ::remove_zombie_hats_for_grief );
	maps/mp/zombies/_zm_ai_brutus::precache();
	maps/mp/zombies/_zm_ai_brutus::init();
	level.enemy_location_override_func = ::enemy_location_override;
	level._effect[ "butterflies" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_skull_elec" );
	a_t_door_triggers = getentarray( "zombie_door", "targetname" );
	_a207 = a_t_door_triggers;
	_k207 = getFirstArrayKey( _a207 );
	while ( isDefined( _k207 ) )
	{
		trigger = _a207[ _k207 ];
		if ( isDefined( trigger.script_flag ) )
		{
			if ( trigger.script_flag != "activate_cellblock_citadel" && trigger.script_flag != "activate_shower_room" || trigger.script_flag == "activate_cellblock_infirmary" && trigger.script_flag == "activate_infirmary" )
			{
				trigger delete();
				break;
			}
			else
			{
				if ( trigger.script_flag != "activate_cafeteria" && trigger.script_flag != "activate_cellblock_east" && trigger.script_flag != "activate_cellblock_west" && trigger.script_flag != "activate_cellblock_barber" && trigger.script_flag != "activate_cellblock_gondola" || trigger.script_flag == "activate_cellblock_east_west" && trigger.script_flag == "activate_warden_office" )
				{
					break;
				}
				else while ( isDefined( trigger.target ) )
				{
					str_target = trigger.target;
					a_door_and_clip = getentarray( str_target, "targetname" );
					_a229 = a_door_and_clip;
					_k229 = getFirstArrayKey( _a229 );
					while ( isDefined( _k229 ) )
					{
						ent = _a229[ _k229 ];
						ent delete();
						_k229 = getNextArrayKey( _a229, _k229 );
					}
				}
				trigger delete();
			}
		}
		_k207 = getNextArrayKey( _a207, _k207 );
	}
	a_t_doors = getentarray( "zombie_door", "targetname" );
	_a244 = a_t_doors;
	_k244 = getFirstArrayKey( _a244 );
	while ( isDefined( _k244 ) )
	{
		t_door = _a244[ _k244 ];
		if ( isDefined( t_door.script_flag ) )
		{
			if ( t_door.script_flag == "activate_cellblock_east_west" || t_door.script_flag == "activate_cellblock_barber" )
			{
				t_door maps/mp/zombies/_zm_blockers::door_opened( self.zombie_cost );
			}
		}
		_k244 = getNextArrayKey( _a244, _k244 );
	}
	zbarriers = getzbarrierarray();
	a_str_zones = [];
	a_str_zones[ 0 ] = "zone_start";
	a_str_zones[ 1 ] = "zone_library";
	a_str_zones[ 2 ] = "zone_cafeteria";
	a_str_zones[ 3 ] = "zone_cafeteria_end";
	a_str_zones[ 4 ] = "zone_warden_office";
	a_str_zones[ 5 ] = "zone_cellblock_east";
	a_str_zones[ 6 ] = "zone_cellblock_west_warden";
	a_str_zones[ 7 ] = "zone_cellblock_west_barber";
	a_str_zones[ 8 ] = "zone_cellblock_west";
	a_str_zones[ 9 ] = "zone_cellblock_west_gondola";
	_a269 = zbarriers;
	_k269 = getFirstArrayKey( _a269 );
	while ( isDefined( _k269 ) )
	{
		barrier = _a269[ _k269 ];
		if ( isDefined( barrier.script_noteworthy ) )
		{
			if ( barrier.script_noteworthy == "cafe_chest_zbarrier" || barrier.script_noteworthy == "start_chest_zbarrier" )
			{
			}
		}
		else
		{
			str_model = barrier.model;
			b_delete_barrier = 1;
			i = 0;
			while ( i < a_str_zones.size )
			{
				if ( str_model == a_str_zones[ i ] )
				{
					b_delete_barrier = 0;
					break;
				}
				else
				{
					i++;
				}
			}
			if ( b_delete_barrier == 1 )
			{
				barrier delete();
			}
		}
		_k269 = getNextArrayKey( _a269, _k269 );
	}
	t_temp = getent( "tower_trap_activate_trigger", "targetname" );
	t_temp delete();
	t_temp = getent( "tower_trap_range_trigger", "targetname" );
	t_temp delete();
	e_model = getent( "trap_control_docks", "targetname" );
	e_model delete();
	e_brush = getent( "tower_shockbox_door", "targetname" );
	e_brush delete();
	a_t_travel_triggers = getentarray( "travel_trigger", "script_noteworthy" );
	_a312 = a_t_travel_triggers;
	_k312 = getFirstArrayKey( _a312 );
	while ( isDefined( _k312 ) )
	{
		trigger = _a312[ _k312 ];
		trigger delete();
		_k312 = getNextArrayKey( _a312, _k312 );
	}
	a_e_gondola_lights = getentarray( "gondola_state_light", "targetname" );
	_a318 = a_e_gondola_lights;
	_k318 = getFirstArrayKey( _a318 );
	while ( isDefined( _k318 ) )
	{
		light = _a318[ _k318 ];
		light delete();
		_k318 = getNextArrayKey( _a318, _k318 );
	}
	a_e_gondola_landing_gates = getentarray( "gondola_landing_gates", "targetname" );
	_a324 = a_e_gondola_landing_gates;
	_k324 = getFirstArrayKey( _a324 );
	while ( isDefined( _k324 ) )
	{
		model = _a324[ _k324 ];
		model delete();
		_k324 = getNextArrayKey( _a324, _k324 );
	}
	a_e_gondola_landing_doors = getentarray( "gondola_landing_doors", "targetname" );
	_a330 = a_e_gondola_landing_doors;
	_k330 = getFirstArrayKey( _a330 );
	while ( isDefined( _k330 ) )
	{
		model = _a330[ _k330 ];
		model delete();
		_k330 = getNextArrayKey( _a330, _k330 );
	}
	a_e_gondola_gates = getentarray( "gondola_gates", "targetname" );
	_a336 = a_e_gondola_gates;
	_k336 = getFirstArrayKey( _a336 );
	while ( isDefined( _k336 ) )
	{
		model = _a336[ _k336 ];
		model delete();
		_k336 = getNextArrayKey( _a336, _k336 );
	}
	a_e_gondola_doors = getentarray( "gondola_doors", "targetname" );
	_a342 = a_e_gondola_doors;
	_k342 = getFirstArrayKey( _a342 );
	while ( isDefined( _k342 ) )
	{
		model = _a342[ _k342 ];
		model delete();
		_k342 = getNextArrayKey( _a342, _k342 );
	}
	m_gondola = getent( "zipline_gondola", "targetname" );
	m_gondola delete();
	t_ride_trigger = getent( "gondola_ride_trigger", "targetname" );
	t_ride_trigger delete();
	a_classic_clips = getentarray( "classic_clips", "targetname" );
	_a355 = a_classic_clips;
	_k355 = getFirstArrayKey( _a355 );
	while ( isDefined( _k355 ) )
	{
		clip = _a355[ _k355 ];
		clip connectpaths();
		clip delete();
		_k355 = getNextArrayKey( _a355, _k355 );
	}
	a_afterlife_props = getentarray( "afterlife_show", "targetname" );
	_a363 = a_afterlife_props;
	_k363 = getFirstArrayKey( _a363 );
	while ( isDefined( _k363 ) )
	{
		m_prop = _a363[ _k363 ];
		m_prop delete();
		_k363 = getNextArrayKey( _a363, _k363 );
	}
	spork_portal = getent( "afterlife_show_spork", "targetname" );
	spork_portal delete();
	a_audio = getentarray( "at_headphones", "script_noteworthy" );
	_a373 = a_audio;
	_k373 = getFirstArrayKey( _a373 );
	while ( isDefined( _k373 ) )
	{
		model = _a373[ _k373 ];
		model delete();
		_k373 = getNextArrayKey( _a373, _k373 );
	}
	m_spoon_pickup = getent( "pickup_spoon", "targetname" );
	m_spoon_pickup delete();
	t_sq_bg = getent( "sq_bg_reward_pickup", "targetname" );
	t_sq_bg delete();
	t_crafting_table = getentarray( "open_craftable_trigger", "targetname" );
	_a386 = t_crafting_table;
	_k386 = getFirstArrayKey( _a386 );
	while ( isDefined( _k386 ) )
	{
		trigger = _a386[ _k386 ];
		trigger delete();
		_k386 = getNextArrayKey( _a386, _k386 );
	}
	t_warden_fence = getent( "warden_fence_damage", "targetname" );
	t_warden_fence delete();
	m_plane_about_to_crash = getent( "plane_about_to_crash", "targetname" );
	m_plane_about_to_crash delete();
	m_plane_craftable = getent( "plane_craftable", "targetname" );
	m_plane_craftable delete();
	i = 1;
	while ( i <= 5 )
	{
		m_key_lock = getent( "masterkey_lock_" + i, "targetname" );
		m_key_lock delete();
		i++;
	}
	m_shower_door = getent( "shower_key_door", "targetname" );
	m_shower_door delete();
	m_nixie_door = getent( "nixie_door_left", "targetname" );
	m_nixie_door delete();
	m_nixie_door = getent( "nixie_door_right", "targetname" );
	m_nixie_door delete();
	m_nixie_brush = getent( "nixie_tube_weaponclip", "targetname" );
	m_nixie_brush delete();
	i = 1;
	while ( i <= 3 )
	{
		m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );
		m_nixie_tube delete();
		i++;
	}
	t_elevator_door = getent( "nixie_elevator_door", "targetname" );
	t_elevator_door delete();
	e_elevator_clip = getent( "elevator_door_playerclip", "targetname" );
	e_elevator_clip delete();
	e_elevator_bottom_gate = getent( "elevator_bottom_gate_l", "targetname" );
	e_elevator_bottom_gate delete();
	e_elevator_bottom_gate = getent( "elevator_bottom_gate_r", "targetname" );
	e_elevator_bottom_gate delete();
	m_docks_puzzle = getent( "cable_puzzle_gate_01", "targetname" );
	m_docks_puzzle delete();
	m_docks_puzzle = getent( "cable_puzzle_gate_02", "targetname" );
	m_docks_puzzle delete();
	m_infirmary_case = getent( "infirmary_case_door_left", "targetname" );
	m_infirmary_case delete();
	m_infirmary_case = getent( "infirmary_case_door_right", "targetname" );
	m_infirmary_case delete();
	fake_plane_part = getent( "fake_veh_t6_dlc_zombie_part_control", "targetname" );
	fake_plane_part delete();
	i = 1;
	while ( i <= 3 )
	{
		m_generator = getent( "generator_panel_" + i, "targetname" );
		m_generator delete();
		i++;
	}
	a_m_generator_core = getentarray( "generator_core", "targetname" );
	_a462 = a_m_generator_core;
	_k462 = getFirstArrayKey( _a462 );
	while ( isDefined( _k462 ) )
	{
		generator = _a462[ _k462 ];
		generator delete();
		_k462 = getNextArrayKey( _a462, _k462 );
	}
	e_playerclip = getent( "electric_chair_playerclip", "targetname" );
	e_playerclip delete();
	i = 1;
	while ( i <= 4 )
	{
		t_use = getent( "trigger_electric_chair_" + i, "targetname" );
		t_use delete();
		m_chair = getent( "electric_chair_" + i, "targetname" );
		m_chair delete();
		i++;
	}
	a_afterlife_interact = getentarray( "afterlife_interact", "targetname" );
	_a482 = a_afterlife_interact;
	_k482 = getFirstArrayKey( _a482 );
	while ( isDefined( _k482 ) )
	{
		model = _a482[ _k482 ];
		model turn_afterlife_interact_on();
		wait 0,1;
		_k482 = getNextArrayKey( _a482, _k482 );
	}
	flag_wait( "initial_blackscreen_passed" );
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	flag_wait( "start_zombie_round_logic" );
	level thread maps/mp/zm_alcatraz_traps::init_fan_trap_trigs();
	level thread maps/mp/zm_alcatraz_traps::init_acid_trap_trigs();
	wait 1;
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "electric_cherry_on" );
	wait_network_frame();
	level notify( "deadshot_on" );
	wait_network_frame();
	level notify( "divetonuke_on" );
	wait_network_frame();
	level notify( "additionalprimaryweapon_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
/#
	level thread maps/mp/gametypes_zm/zmeat::spawn_level_meat_manager();
#/
}

remove_zombie_hats_for_grief()
{
	self detach( "c_zom_guard_hat" );
}

enemy_location_override( zombie, enemy )
{
	location = enemy.origin;
	if ( is_true( self.reroute ) )
	{
		if ( isDefined( self.reroute_origin ) )
		{
			location = self.reroute_origin;
		}
	}
	return location;
}

magicbox_face_spawn()
{
	self endon( "disconnect" );
	if ( !is_gametype_active( "zgrief" ) )
	{
		return;
	}
	while ( 1 )
	{
		self waittill( "user_grabbed_weapon" );
		if ( randomint( 50000 ) == 115 )
		{
			self playsoundtoplayer( "zmb_easteregg_face", self );
			self.wth_elem = newclienthudelem( self );
			self.wth_elem.horzalign = "fullscreen";
			self.wth_elem.vertalign = "fullscreen";
			self.wth_elem.sort = 1000;
			self.wth_elem.foreground = 0;
			self.wth_elem.alpha = 1;
			self.wth_elem setshader( "zm_al_wth_zombie", 640, 480 );
			self.wth_elem.hidewheninmenu = 1;
			wait 0,25;
			self.wth_elem destroy();
		}
		wait 0,05;
	}
}

turn_afterlife_interact_on()
{
	if ( self.script_string != "cell_1_powerup_activate" && self.script_string != "intro_powerup_activate" || self.script_string == "cell_2_powerup_activate" && self.script_string == "wires_shower_door" )
	{
		return;
	}
	if ( self.script_string != "electric_cherry_on" || self.script_string == "sleight_on" && self.script_string == "wires_admin_door" )
	{
		if ( !isDefined( level.shockbox_anim ) )
		{
			level.shockbox_anim[ "on" ] = %fxanim_zom_al_shock_box_on_anim;
			level.shockbox_anim[ "off" ] = %fxanim_zom_al_shock_box_off_anim;
		}
		if ( issubstr( self.model, "p6_zm_al_shock_box" ) )
		{
			self useanimtree( -1 );
			self setmodel( "p6_zm_al_shock_box_on" );
			self setanim( level.shockbox_anim[ "on" ] );
		}
	}
	else
	{
		self delete();
	}
}
