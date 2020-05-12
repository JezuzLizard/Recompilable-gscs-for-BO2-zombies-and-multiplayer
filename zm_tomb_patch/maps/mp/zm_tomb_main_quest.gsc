#include maps/mp/zombies/_zm_audio;
#include maps/mp/zm_tomb_amb;
#include maps/mp/zm_tomb_challenges;
#include maps/mp/zm_tomb_ee_main_step_7;
#include maps/mp/zombies/_zm_challenges;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_tomb_craftables;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zm_tomb_teleporter;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "fxanim_props_dlc4" );

main_quest_init()
{
	flag_init( "dug" );
	flag_init( "air_open" );
	flag_init( "fire_open" );
	flag_init( "lightning_open" );
	flag_init( "ice_open" );
	flag_init( "panels_solved" );
	flag_init( "fire_solved" );
	flag_init( "ice_solved" );
	flag_init( "chamber_puzzle_cheat" );
	flag_init( "activate_zone_crypt" );
	level.callbackvehicledamage = ::aircrystalbiplanecallback_vehicledamage;
	level.game_mode_custom_onplayerdisconnect = ::player_disconnect_callback;
	onplayerconnect_callback( ::onplayerconnect );
	staff_air = getent( "prop_staff_air", "targetname" );
	staff_fire = getent( "prop_staff_fire", "targetname" );
	staff_lightning = getent( "prop_staff_lightning", "targetname" );
	staff_water = getent( "prop_staff_water", "targetname" );
	staff_air.weapname = "staff_air_zm";
	staff_fire.weapname = "staff_fire_zm";
	staff_lightning.weapname = "staff_lightning_zm";
	staff_water.weapname = "staff_water_zm";
	staff_air.element = "air";
	staff_fire.element = "fire";
	staff_lightning.element = "lightning";
	staff_water.element = "water";
	staff_air.craftable_name = "elemental_staff_air";
	staff_fire.craftable_name = "elemental_staff_fire";
	staff_lightning.craftable_name = "elemental_staff_lightning";
	staff_water.craftable_name = "elemental_staff_water";
	staff_air.charger = getstruct( "staff_air_charger", "script_noteworthy" );
	staff_fire.charger = getstruct( "staff_fire_charger", "script_noteworthy" );
	staff_lightning.charger = getstruct( "zone_bolt_chamber", "script_noteworthy" );
	staff_water.charger = getstruct( "staff_ice_charger", "script_noteworthy" );
	staff_fire.quest_clientfield = "quest_state1";
	staff_air.quest_clientfield = "quest_state2";
	staff_lightning.quest_clientfield = "quest_state3";
	staff_water.quest_clientfield = "quest_state4";
	staff_fire.enum = 1;
	staff_air.enum = 2;
	staff_lightning.enum = 3;
	staff_water.enum = 4;
	level.a_elemental_staffs = [];
	level.a_elemental_staffs[ level.a_elemental_staffs.size ] = staff_air;
	level.a_elemental_staffs[ level.a_elemental_staffs.size ] = staff_fire;
	level.a_elemental_staffs[ level.a_elemental_staffs.size ] = staff_lightning;
	level.a_elemental_staffs[ level.a_elemental_staffs.size ] = staff_water;
	_a90 = level.a_elemental_staffs;
	_k90 = getFirstArrayKey( _a90 );
	while ( isDefined( _k90 ) )
	{
		staff = _a90[ _k90 ];
		staff.charger.charges_received = 0;
		staff.charger.is_inserted = 0;
		staff thread place_staffs_encasement();
		staff thread staff_charger_check();
		staff ghost();
		_k90 = getNextArrayKey( _a90, _k90 );
	}
	staff_air_upgraded = getent( "prop_staff_air_upgraded", "targetname" );
	staff_fire_upgraded = getent( "prop_staff_fire_upgraded", "targetname" );
	staff_lightning_upgraded = getent( "prop_staff_lightning_upgraded", "targetname" );
	staff_water_upgraded = getent( "prop_staff_water_upgraded", "targetname" );
	staff_air_upgraded.weapname = "staff_air_upgraded_zm";
	staff_fire_upgraded.weapname = "staff_fire_upgraded_zm";
	staff_lightning_upgraded.weapname = "staff_lightning_upgraded_zm";
	staff_water_upgraded.weapname = "staff_water_upgraded_zm";
	staff_air_upgraded.melee = "staff_air_melee_zm";
	staff_fire_upgraded.melee = "staff_fire_melee_zm";
	staff_lightning_upgraded.melee = "staff_lightning_melee_zm";
	staff_water_upgraded.melee = "staff_water_melee_zm";
	staff_air_upgraded.base_weapname = "staff_air_zm";
	staff_fire_upgraded.base_weapname = "staff_fire_zm";
	staff_lightning_upgraded.base_weapname = "staff_lightning_zm";
	staff_water_upgraded.base_weapname = "staff_water_zm";
	staff_air_upgraded.element = "air";
	staff_fire_upgraded.element = "fire";
	staff_lightning_upgraded.element = "lightning";
	staff_water_upgraded.element = "water";
	staff_air_upgraded.charger = staff_air.charger;
	staff_fire_upgraded.charger = staff_fire.charger;
	staff_lightning_upgraded.charger = staff_lightning.charger;
	staff_water_upgraded.charger = staff_water.charger;
	staff_fire_upgraded.enum = 1;
	staff_air_upgraded.enum = 2;
	staff_lightning_upgraded.enum = 3;
	staff_water_upgraded.enum = 4;
	staff_air.upgrade = staff_air_upgraded;
	staff_fire.upgrade = staff_fire_upgraded;
	staff_water.upgrade = staff_water_upgraded;
	staff_lightning.upgrade = staff_lightning_upgraded;
	level.a_elemental_staffs_upgraded = [];
	level.a_elemental_staffs_upgraded[ level.a_elemental_staffs_upgraded.size ] = staff_air_upgraded;
	level.a_elemental_staffs_upgraded[ level.a_elemental_staffs_upgraded.size ] = staff_fire_upgraded;
	level.a_elemental_staffs_upgraded[ level.a_elemental_staffs_upgraded.size ] = staff_lightning_upgraded;
	level.a_elemental_staffs_upgraded[ level.a_elemental_staffs_upgraded.size ] = staff_water_upgraded;
	_a147 = level.a_elemental_staffs_upgraded;
	_k147 = getFirstArrayKey( _a147 );
	while ( isDefined( _k147 ) )
	{
		staff_upgraded = _a147[ _k147 ];
		staff_upgraded.charger.charges_received = 0;
		staff_upgraded.charger.is_inserted = 0;
		staff_upgraded.charger.is_charged = 0;
		staff_upgraded.prev_ammo_clip = weaponclipsize( staff_upgraded.weapname );
		staff_upgraded.prev_ammo_stock = weaponmaxammo( staff_upgraded.weapname );
		staff_upgraded thread place_staffs_encasement();
		staff_upgraded ghost();
		_k147 = getNextArrayKey( _a147, _k147 );
	}
	_a159 = level.a_elemental_staffs;
	_k159 = getFirstArrayKey( _a159 );
	while ( isDefined( _k159 ) )
	{
		staff = _a159[ _k159 ];
		staff.prev_ammo_clip = weaponclipsize( staff_upgraded.weapname );
		staff.prev_ammo_stock = weaponmaxammo( staff_upgraded.weapname );
		staff.upgrade.downgrade = staff;
		staff.upgrade useweaponmodel( staff.weapname );
		staff.upgrade showallparts();
		_k159 = getNextArrayKey( _a159, _k159 );
	}
	level.staffs_charged = 0;
	array_thread( level.zombie_spawners, ::add_spawn_function, ::zombie_spawn_func );
	level thread watch_for_staff_upgrades();
	level thread chambers_init();
	level thread maps/mp/zm_tomb_quest_air::main();
	level thread maps/mp/zm_tomb_quest_fire::main();
	level thread maps/mp/zm_tomb_quest_ice::main();
	level thread maps/mp/zm_tomb_quest_elec::main();
	level thread maps/mp/zm_tomb_quest_crypt::main();
	level thread maps/mp/zm_tomb_chamber::main();
	level thread maps/mp/zm_tomb_vo::watch_occasional_line( "puzzle", "puzzle_confused", "vo_puzzle_confused" );
	level thread maps/mp/zm_tomb_vo::watch_occasional_line( "puzzle", "puzzle_good", "vo_puzzle_good" );
	level thread maps/mp/zm_tomb_vo::watch_occasional_line( "puzzle", "puzzle_bad", "vo_puzzle_bad" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_samantha_clue( "vox_sam_ice_staff_clue_0", "sam_clue_dig", "elemental_staff_water_all_pieces_found" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_samantha_clue( "vox_sam_fire_staff_clue_0", "sam_clue_mechz", "mechz_killed" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_samantha_clue( "vox_sam_fire_staff_clue_1", "sam_clue_biplane", "biplane_down" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_samantha_clue( "vox_sam_fire_staff_clue_2", "sam_clue_zonecap", "staff_piece_capture_complete" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_samantha_clue( "vox_sam_lightning_staff_clue_0", "sam_clue_tank", "elemental_staff_lightning_all_pieces_found" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_samantha_clue( "vox_sam_wind_staff_clue_0", "sam_clue_giant", "elemental_staff_air_all_pieces_found" );
	level.dig_spawners = getentarray( "zombie_spawner_dig", "script_noteworthy" );
	array_thread( level.dig_spawners, ::add_spawn_function, ::dug_zombie_spawn_init );
}

onplayerconnect()
{
}

player_disconnect_callback( player )
{
	n_player = player getentitynumber() + 1;
	level delay_thread( 0,5, ::clear_player_staff_by_player_number, n_player );
}

place_staffs_encasement()
{
	s_pos = getstruct( "staff_pos_" + self.element, "targetname" );
	self.origin = s_pos.origin;
	self.angles = s_pos.angles;
}

chambers_init()
{
	flag_init( "gramophone_placed" );
	array_thread( getentarray( "trigger_death_floor", "targetname" ), ::monitor_chamber_death_trigs );
	a_stargate_gramophones = getstructarray( "stargate_gramophone_pos", "targetname" );
	array_thread( a_stargate_gramophones, ::run_gramophone_teleporter );
	a_door_main = getentarray( "chamber_entrance", "targetname" );
	array_thread( a_door_main, ::run_gramophone_door, "vinyl_master" );
}

monitor_chamber_death_trigs()
{
	while ( 1 )
	{
		self waittill( "trigger", ent );
		if ( isplayer( ent ) )
		{
			ent.bleedout_time = 0;
		}
		ent dodamage( ent.health + 666, ent.origin );
		wait 0,05;
	}
}

watch_gramophone_vinyl_pickup()
{
	str_vinyl_record = "vinyl_main";
	switch( self.script_int )
	{
		case 1:
			str_vinyl_record = "vinyl_fire";
			break;
		case 2:
			str_vinyl_record = "vinyl_air";
			break;
		case 3:
			str_vinyl_record = "vinyl_elec";
			break;
		case 4:
			str_vinyl_record = "vinyl_ice";
			break;
		default:
			str_vinyl_record = "vinyl_master";
			break;
	}
	level waittill( "gramophone_" + str_vinyl_record + "_picked_up" );
	self.has_vinyl = 1;
}

get_gramophone_song()
{
	switch( self.script_int )
	{
		case 1:
			return "mus_gramophone_fire";
			case 2:
				return "mus_gramophone_air";
				case 3:
					return "mus_gramophone_electric";
					case 4:
						return "mus_gramophone_ice";
						default:
							return "mus_gramophone_electric";
						}
					}
				}
			}
		}
	}
}

run_gramophone_teleporter( str_vinyl_record )
{
	self.has_vinyl = 0;
	self.gramophone_model = undefined;
	self thread watch_gramophone_vinyl_pickup();
	t_gramophone = tomb_spawn_trigger_radius( self.origin, 60, 1 );
	t_gramophone set_unitrigger_hint_string( &"ZOMBIE_BUILD_PIECE_MORE" );
	level waittill( "gramophone_vinyl_player_picked_up" );
	str_craftablename = "gramophone";
	t_gramophone set_unitrigger_hint_string( &"ZM_TOMB_RU" );
	while ( !self.has_vinyl )
	{
		wait 0,05;
	}
	t_gramophone set_unitrigger_hint_string( &"ZM_TOMB_PLGR" );
	while ( 1 )
	{
		t_gramophone waittill( "trigger", player );
		if ( !isDefined( self.gramophone_model ) )
		{
			if ( !flag( "gramophone_placed" ) )
			{
				self.gramophone_model = spawn( "script_model", self.origin );
				self.gramophone_model.angles = self.angles;
				self.gramophone_model setmodel( "p6_zm_tm_gramophone" );
				level setclientfield( "piece_record_zm_player", 0 );
				flag_set( "gramophone_placed" );
				t_gramophone set_unitrigger_hint_string( "" );
				t_gramophone trigger_off();
				str_song_id = self get_gramophone_song();
				self.gramophone_model playsound( str_song_id );
				player thread maps/mp/zm_tomb_vo::play_gramophone_place_vo();
				maps/mp/zm_tomb_teleporter::stargate_teleport_enable( self.script_int );
				flag_wait( "teleporter_building_" + self.script_int );
				flag_waitopen( "teleporter_building_" + self.script_int );
				t_gramophone trigger_on();
				t_gramophone set_unitrigger_hint_string( &"ZM_TOMB_PUGR" );
				if ( isDefined( self.script_flag ) )
				{
					flag_set( self.script_flag );
				}
			}
			else
			{
				player door_gramophone_elsewhere_hint();
			}
			continue;
		}
		else
		{
			self.gramophone_model delete();
			self.gramophone_model = undefined;
			player playsound( "zmb_craftable_pickup" );
			flag_clear( "gramophone_placed" );
			level setclientfield( "piece_record_zm_player", 1 );
			maps/mp/zm_tomb_teleporter::stargate_teleport_disable( self.script_int );
			t_gramophone set_unitrigger_hint_string( &"ZM_TOMB_PLGR" );
		}
	}
}

door_watch_open_sesame()
{
/#
	level waittill_any( "open_sesame", "open_all_gramophone_doors" );
	self.has_vinyl = 1;
	level.b_open_all_gramophone_doors = 1;
	wait 0,5;
	if ( isDefined( self.trigger ) )
	{
		self.trigger notify( "trigger" );
#/
	}
}

run_gramophone_door( str_vinyl_record )
{
	flag_init( self.targetname + "_opened" );
	trig_position = getstruct( self.targetname + "_position", "targetname" );
	trig_position.has_vinyl = 0;
	trig_position.gramophone_model = undefined;
	trig_position thread watch_gramophone_vinyl_pickup();
	trig_position thread door_watch_open_sesame();
	t_door = tomb_spawn_trigger_radius( trig_position.origin, 60, 1 );
	t_door set_unitrigger_hint_string( &"ZOMBIE_BUILD_PIECE_MORE" );
	level waittill_any( "gramophone_vinyl_player_picked_up", "open_sesame", "open_all_gramophone_doors" );
	str_craftablename = "gramophone";
	t_door set_unitrigger_hint_string( &"ZM_TOMB_RU" );
	trig_position.trigger = t_door;
	while ( !trig_position.has_vinyl )
	{
		wait 0,05;
	}
	t_door set_unitrigger_hint_string( &"ZM_TOMB_PLGR" );
	while ( 1 )
	{
		t_door waittill( "trigger", player );
		if ( !isDefined( trig_position.gramophone_model ) )
		{
			if ( !flag( "gramophone_placed" ) || isDefined( level.b_open_all_gramophone_doors ) && level.b_open_all_gramophone_doors )
			{
				if ( isDefined( level.b_open_all_gramophone_doors ) && !level.b_open_all_gramophone_doors )
				{
					trig_position.gramophone_model = spawn( "script_model", trig_position.origin );
					trig_position.gramophone_model.angles = trig_position.angles;
					trig_position.gramophone_model setmodel( "p6_zm_tm_gramophone" );
					flag_set( "gramophone_placed" );
					level setclientfield( "piece_record_zm_player", 0 );
				}
				t_door trigger_off();
				str_song = trig_position get_gramophone_song();
				playsoundatposition( str_song, self.origin );
				self playsound( "zmb_crypt_stairs" );
				wait 6;
				chamber_blocker();
				flag_set( self.targetname + "_opened" );
				if ( isDefined( trig_position.script_flag ) )
				{
					flag_set( trig_position.script_flag );
				}
				level setclientfield( "crypt_open_exploder", 1 );
				self movez( -260, 10, 1, 1 );
				self waittill( "movedone" );
				self connectpaths();
				self delete();
				t_door trigger_on();
				t_door set_unitrigger_hint_string( &"ZM_TOMB_PUGR" );
				if ( isDefined( level.b_open_all_gramophone_doors ) && level.b_open_all_gramophone_doors )
				{
					break;
				}
				else
				{
				}
				else player door_gramophone_elsewhere_hint();
				continue;
			}
			else
			{
				trig_position.gramophone_model delete();
				trig_position.gramophone_model = undefined;
				flag_clear( "gramophone_placed" );
				player playsound( "zmb_craftable_pickup" );
				level setclientfield( "piece_record_zm_player", 1 );
				break;
			}
		}
	}
	t_door tomb_unitrigger_delete();
	trig_position.trigger = undefined;
}

chamber_blocker()
{
	a_blockers = getentarray( "junk_nml_chamber", "targetname" );
	m_blocker = getent( "junk_nml_chamber", "targetname" );
	s_blocker_end = getstruct( m_blocker.script_linkto, "script_linkname" );
	m_blocker thread maps/mp/zombies/_zm_blockers::debris_move( s_blocker_end );
	m_blocker_clip = getent( "junk_nml_chamber_clip", "targetname" );
	m_blocker_clip connectpaths();
	m_blocker waittill( "movedone" );
	m_blocker_clip delete();
}

watch_for_staff_upgrades()
{
	_a561 = level.a_elemental_staffs;
	_k561 = getFirstArrayKey( _a561 );
	while ( isDefined( _k561 ) )
	{
		staff = _a561[ _k561 ];
		staff thread staff_upgrade_watch();
		_k561 = getNextArrayKey( _a561, _k561 );
	}
}

staff_upgrade_watch()
{
	flag_wait( self.weapname + "_upgrade_unlocked" );
	self thread place_staff_in_charger();
}

staff_get_pickup_message()
{
	if ( self.element == "air" )
	{
		return &"ZM_TOMB_PUAS";
	}
	else
	{
		if ( self.element == "fire" )
		{
			return &"ZM_TOMB_PUFS";
		}
		else
		{
			if ( self.element == "lightning" )
			{
				return &"ZM_TOMB_PULS";
			}
			else
			{
				return &"ZM_TOMB_PUIS";
			}
		}
	}
}

staff_get_insert_message()
{
	if ( self.element == "air" )
	{
		return &"ZM_TOMB_INAS";
	}
	else
	{
		if ( self.element == "fire" )
		{
			return &"ZM_TOMB_INFS";
		}
		else
		{
			if ( self.element == "lightning" )
			{
				return &"ZM_TOMB_INLS";
			}
			else
			{
				return &"ZM_TOMB_INWS";
			}
		}
	}
}

player_has_staff()
{
	a_weapons = self getweaponslistprimaries();
	_a617 = a_weapons;
	_k617 = getFirstArrayKey( _a617 );
	while ( isDefined( _k617 ) )
	{
		weapon = _a617[ _k617 ];
		if ( issubstr( weapon, "staff" ) )
		{
			return 1;
		}
		_k617 = getNextArrayKey( _a617, _k617 );
	}
	return 0;
}

can_pickup_staff()
{
	b_has_staff = self player_has_staff();
	b_staff_equipped = issubstr( self getcurrentweapon(), "staff" );
	if ( b_has_staff && !b_staff_equipped )
	{
		self thread swap_staff_hint();
	}
	if ( b_has_staff )
	{
		return b_staff_equipped;
	}
}

watch_for_player_pickup_staff()
{
	staff_picked_up = 0;
	pickup_message = self staff_get_pickup_message();
	self.trigger set_unitrigger_hint_string( pickup_message );
	self show();
	self.trigger trigger_on();
	while ( !staff_picked_up )
	{
		self.trigger waittill( "trigger", player );
		self notify( "retrieved" );
		if ( player can_pickup_staff() )
		{
			weapon_drop = player getcurrentweapon();
			a_weapons = player getweaponslistprimaries();
			n_max_other_weapons = get_player_weapon_limit( player ) - 1;
			if ( a_weapons.size > n_max_other_weapons || issubstr( weapon_drop, "staff" ) )
			{
				player takeweapon( weapon_drop );
			}
			player thread watch_staff_ammo_reload();
			self ghost();
			self setinvisibletoall();
			player giveweapon( self.weapname );
			player switchtoweapon( self.weapname );
			clip_size = weaponclipsize( self.weapname );
			player setweaponammoclip( self.weapname, clip_size );
			self.owner = player;
			level notify( "stop_staff_sound" );
			self notify( "staff_equip" );
			staff_picked_up = 1;
			self.charger.is_inserted = 0;
			self setclientfield( "staff_charger", 0 );
			self.charger.full = 1;
			maps/mp/zm_tomb_craftables::set_player_staff( self.weapname, player );
		}
	}
}

watch_staff_ammo_reload()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "zmb_max_ammo" );
		a_weapons = self getweaponslistprimaries();
		_a715 = a_weapons;
		_k715 = getFirstArrayKey( _a715 );
		while ( isDefined( _k715 ) )
		{
			weapon = _a715[ _k715 ];
			if ( issubstr( weapon, "staff" ) )
			{
				self setweaponammoclip( weapon, weaponmaxammo( weapon ) );
			}
			_k715 = getNextArrayKey( _a715, _k715 );
		}
	}
}

rotate_forever( rotate_time )
{
	if ( !isDefined( rotate_time ) )
	{
		rotate_time = 20;
	}
	self endon( "death" );
	while ( 1 )
	{
		self rotateyaw( 360, 20, 0, 0 );
		self waittill( "rotatedone" );
	}
}

staff_crystal_wait_for_teleport( n_element_enum )
{
	flag_init( "charger_ready_" + n_element_enum );
	self craftable_waittill_spawned();
	self.origin = self.piecespawn.model.origin;
	self.piecespawn.model ghost();
	self.piecespawn.model movez( -1000, 0,05 );
	e_plinth = getent( "crystal_plinth" + n_element_enum, "targetname" );
	e_plinth.v_start = e_plinth.origin;
	e_plinth.v_start = ( e_plinth.v_start[ 0 ], e_plinth.v_start[ 1 ], e_plinth.origin[ 2 ] - 78 );
	e_plinth.v_crystal = e_plinth.origin;
	e_plinth.v_crystal = ( e_plinth.v_crystal[ 0 ], e_plinth.v_crystal[ 1 ], e_plinth.origin[ 2 ] - 40 );
	e_plinth.v_staff = e_plinth.origin;
	e_plinth.v_staff = ( e_plinth.v_staff[ 0 ], e_plinth.v_staff[ 1 ], e_plinth.origin[ 2 ] + 15 );
	e_plinth moveto( e_plinth.v_start, 0,05 );
	while ( 1 )
	{
		level waittill( "player_teleported", e_player, n_teleport_enum );
		if ( n_teleport_enum == n_element_enum )
		{
			break;
		}
		else
		{
		}
	}
	e_plinth moveto( e_plinth.v_crystal, 6 );
	e_plinth thread sndmoveplinth( 6 );
	lookat_dot = cos( 90 );
	dist_sq = 250000;
	lookat_time = 0;
	while ( lookat_time < 1 && isDefined( self.piecespawn.model ) )
	{
		wait 0,1;
		if ( !isDefined( self.piecespawn.model ) )
		{
		}
		else if ( self.piecespawn.model any_player_looking_at_plinth( lookat_dot, dist_sq ) )
		{
			lookat_time += 0,1;
			continue;
		}
		else
		{
			lookat_time = 0;
		}
	}
	if ( isDefined( self.piecespawn.model ) )
	{
		self.piecespawn.model movez( 985, 0,05 );
		self.piecespawn.model waittill( "movedone" );
		self.piecespawn.model show();
		self.piecespawn.model thread rotate_forever();
		self.piecespawn.model movez( 15, 2 );
		self.piecespawn.model playloopsound( "zmb_squest_crystal_loop", 4,25 );
	}
	flag_wait( "charger_ready_" + n_element_enum );
	while ( !maps/mp/zm_tomb_chamber::is_chamber_occupied() )
	{
		wait_network_frame();
	}
	e_plinth moveto( e_plinth.v_staff, 3 );
	e_plinth thread sndmoveplinth( 3 );
	e_plinth waittill( "movedone" );
}

sndmoveplinth( time )
{
	self notify( "sndMovePlinth" );
	self endon( "sndMovePlinth" );
	self playloopsound( "zmb_chamber_plinth_move", 0,25 );
	wait time;
	self stoploopsound( 0,1 );
	self playsound( "zmb_chamber_plinth_stop" );
}

staff_mechz_drop_pieces( s_piece )
{
	s_piece craftable_waittill_spawned();
	s_piece.piecespawn.model ghost();
	i = 0;
	while ( i < 1 )
	{
		level waittill( "mechz_killed", origin );
		i++;
	}
	s_piece.piecespawn.canmove = 1;
	maps/mp/zombies/_zm_unitrigger::reregister_unitrigger_as_dynamic( s_piece.piecespawn.unitrigger );
	origin = groundpos_ignore_water_new( origin + vectorScale( ( 0, 0, 1 ), 40 ) );
	s_piece.piecespawn.model moveto( origin + vectorScale( ( 0, 0, 1 ), 32 ), 0,05 );
	s_piece.piecespawn.model waittill( "movedone" );
	if ( isDefined( s_piece.piecespawn.model ) )
	{
		s_piece.piecespawn.model show();
		s_piece.piecespawn.model notify( "staff_piece_glow" );
		s_piece.piecespawn.model thread mechz_staff_piece_failsafe();
	}
}

mechz_staff_piece_failsafe()
{
	min_dist_sq = 1000000;
	self endon( "death" );
	wait 120;
	while ( 1 )
	{
		a_players = getplayers();
		b_anyone_near = 0;
		_a891 = a_players;
		_k891 = getFirstArrayKey( _a891 );
		while ( isDefined( _k891 ) )
		{
			e_player = _a891[ _k891 ];
			dist_sq = distance2dsquared( e_player.origin, self.origin );
			if ( dist_sq < min_dist_sq )
			{
				b_anyone_near = 1;
			}
			_k891 = getNextArrayKey( _a891, _k891 );
		}
		if ( !b_anyone_near )
		{
			break;
		}
		else
		{
			wait 1;
		}
	}
	a_locations = getstructarray( "mechz_location", "script_noteworthy" );
	s_location = get_closest_2d( self.origin, a_locations );
	self moveto( s_location.origin + vectorScale( ( 0, 0, 1 ), 32 ), 3 );
}

biplane_clue()
{
	self endon( "death" );
	level endon( "biplane_down" );
	while ( 1 )
	{
		cur_round = level.round_number;
		while ( level.round_number == cur_round )
		{
			wait 1;
		}
		wait randomfloatrange( 5, 15 );
		a_players = getplayers();
		_a933 = a_players;
		_k933 = getFirstArrayKey( _a933 );
		while ( isDefined( _k933 ) )
		{
			e_player = _a933[ _k933 ];
			level notify( "sam_clue_biplane" );
			_k933 = getNextArrayKey( _a933, _k933 );
		}
	}
}

staff_biplane_drop_pieces( a_staff_pieces )
{
	_a942 = a_staff_pieces;
	_k942 = getFirstArrayKey( _a942 );
	while ( isDefined( _k942 ) )
	{
		staff_piece = _a942[ _k942 ];
		staff_piece craftable_waittill_spawned();
		staff_piece.origin = staff_piece.piecespawn.model.origin;
		staff_piece.piecespawn.model notify( "staff_piece_glow" );
		staff_piece.piecespawn.model ghost();
		staff_piece.piecespawn.model movez( -500, 0,05 );
		_k942 = getNextArrayKey( _a942, _k942 );
	}
	flag_wait( "activate_zone_village_0" );
	cur_round = level.round_number;
	while ( level.round_number == cur_round )
	{
		wait 1;
	}
	s_biplane_pos = getstruct( "air_crystal_biplane_pos", "targetname" );
	vh_biplane = spawnvehicle( "veh_t6_dlc_zm_biplane", "air_crystal_biplane", "biplane_zm", s_biplane_pos.origin, s_biplane_pos.angles );
	vh_biplane ent_flag_init( "biplane_down", 0 );
	vh_biplane thread biplane_clue();
	e_fx_tag = getent( "air_crystal_biplane_tag", "targetname" );
	e_fx_tag moveto( vh_biplane.origin, 0,05 );
	e_fx_tag waittill( "movedone" );
	e_fx_tag linkto( vh_biplane, "tag_origin" );
	vh_biplane.health = 10000;
	vh_biplane setcandamage( 1 );
	vh_biplane setforcenocull();
	vh_biplane attachpath( getvehiclenode( "biplane_start", "targetname" ) );
	vh_biplane startpath();
	s_biplane_pos structdelete();
	e_fx_tag setclientfield( "element_glow_fx", 1 );
	vh_biplane ent_flag_wait( "biplane_down" );
	vh_biplane playsound( "zmb_zombieblood_3rd_plane_explode" );
	_a992 = a_staff_pieces;
	_k992 = getFirstArrayKey( _a992 );
	while ( isDefined( _k992 ) )
	{
		staff_piece = _a992[ _k992 ];
		staff_piece.e_fx = spawn( "script_model", e_fx_tag.origin );
		staff_piece.e_fx setmodel( "tag_origin" );
		staff_piece.e_fx setclientfield( "element_glow_fx", 1 );
		staff_piece.e_fx moveto( staff_piece.origin, 5 );
		_k992 = getNextArrayKey( _a992, _k992 );
	}
	playfx( level._effect[ "biplane_explode" ], vh_biplane.origin );
	vh_biplane delete();
	e_fx_tag delete();
	a_staff_pieces[ 0 ].e_fx waittill( "movedone" );
	_a1009 = a_staff_pieces;
	_k1009 = getFirstArrayKey( _a1009 );
	while ( isDefined( _k1009 ) )
	{
		staff_piece = _a1009[ _k1009 ];
		staff_piece.e_fx delete();
		staff_piece.piecespawn.model show();
		staff_piece.piecespawn.model movez( 500, 0,05 );
		staff_piece.piecespawn.model waittill( "movedone" );
		_k1009 = getNextArrayKey( _a1009, _k1009 );
	}
}

aircrystalbiplanecallback_vehicledamage( e_inflictor, e_attacker, n_damage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name )
{
	if ( isplayer( e_attacker ) && self.vehicletype == "biplane_zm" && !self ent_flag( "biplane_down" ) )
	{
		self ent_flag_set( "biplane_down" );
		level notify( "biplane_down" );
	}
	return n_damage;
}

zone_capture_clue( str_zone )
{
	level endon( "staff_piece_capture_complete" );
	while ( 1 )
	{
		wait 5;
		while ( !level.zones[ str_zone ].is_occupied )
		{
			wait 1;
		}
		a_players = getplayers();
		_a1044 = a_players;
		_k1044 = getFirstArrayKey( _a1044 );
		while ( isDefined( _k1044 ) )
		{
			e_player = _a1044[ _k1044 ];
			level notify( "sam_clue_zonecap" );
			_k1044 = getNextArrayKey( _a1044, _k1044 );
		}
	}
}

staff_unlock_with_zone_capture( s_staff_piece )
{
	flag_wait( "start_zombie_round_logic" );
	s_staff_piece craftable_waittill_spawned();
	str_zone = maps/mp/zombies/_zm_zonemgr::get_zone_from_position( s_staff_piece.piecespawn.model.origin, 1 );
	if ( !isDefined( str_zone ) )
	{
/#
		assertmsg( "Zone capture staff piece is not in a zone." );
#/
		return;
	}
	level thread zone_capture_clue( str_zone );
	s_staff_piece.piecespawn.model ghost();
	while ( 1 )
	{
		level waittill( "zone_captured_by_player", str_captured_zone );
		if ( str_captured_zone == str_zone )
		{
			break;
		}
		else
		{
		}
	}
	level notify( "staff_piece_capture_complete" );
	_a1082 = level.a_uts_challenge_boxes;
	_k1082 = getFirstArrayKey( _a1082 );
	while ( isDefined( _k1082 ) )
	{
		uts_box = _a1082[ _k1082 ];
		if ( uts_box.str_location == "church_capture" )
		{
			uts_box.s_staff_piece = s_staff_piece;
			level thread maps/mp/zombies/_zm_challenges::open_box( undefined, uts_box, ::reward_staff_piece );
			return;
		}
		_k1082 = getNextArrayKey( _a1082, _k1082 );
	}
}

reward_staff_piece( player, s_stat )
{
	m_piece = spawn( "script_model", self.origin );
	m_piece.angles = self.angles + vectorScale( ( 0, 0, 1 ), 180 );
	m_piece setmodel( "t6_wpn_zmb_staff_tip_fire_world" );
	m_piece.origin = self.origin;
	m_piece.angles = self.angles + vectorScale( ( 0, 0, 1 ), 90 );
	m_piece setclientfield( "element_glow_fx", 1 );
	wait_network_frame();
	if ( !reward_rise_and_grab( m_piece, 50, 2, 2, -1 ) )
	{
		return 0;
	}
	n_dist = 9999;
	a_players = getplayers();
	a_players = get_array_of_closest( self.m_box.origin, a_players );
	if ( isDefined( a_players[ 0 ] ) )
	{
		a_players[ 0 ] maps/mp/zombies/_zm_craftables::player_take_piece( self.s_staff_piece.piecespawn );
	}
	m_piece delete();
	return 1;
}

dig_spot_get_staff_piece( e_player )
{
	level notify( "sam_clue_dig" );
	str_zone = self.str_zone;
	_a1142 = level.ice_staff_pieces;
	_k1142 = getFirstArrayKey( _a1142 );
	while ( isDefined( _k1142 ) )
	{
		s_staff = _a1142[ _k1142 ];
		if ( !isDefined( s_staff.num_misses ) )
		{
			s_staff.num_misses = 0;
		}
		if ( issubstr( str_zone, s_staff.zone_substr ) )
		{
			miss_chance = 100 / ( s_staff.num_misses + 1 );
			if ( level.weather_snow <= 0 )
			{
				miss_chance = 101;
			}
			if ( randomint( 100 ) > miss_chance || s_staff.num_misses > 3 && miss_chance < 100 )
			{
				return s_staff;
			}
			else
			{
				s_staff.num_misses++;
				break;
			}
		}
		else
		{
			_k1142 = getNextArrayKey( _a1142, _k1142 );
		}
	}
	return undefined;
}

show_ice_staff_piece( origin )
{
	arrayremovevalue( level.ice_staff_pieces, self );
	wait 0,5;
	self.piecespawn.canmove = 1;
	maps/mp/zombies/_zm_unitrigger::reregister_unitrigger_as_dynamic( self.piecespawn.unitrigger );
	vert_offset = 32;
	self.piecespawn.model moveto( origin + ( 0, 0, vert_offset ), 0,05 );
	self.piecespawn.model waittill( "movedone" );
	self.piecespawn.model showindemo();
	self.piecespawn.model show();
	self.piecespawn.model notify( "staff_piece_glow" );
	self.piecespawn.model playsound( "evt_staff_digup" );
	self.piecespawn.model playloopsound( "evt_staff_digup_lp" );
}

staff_ice_dig_pieces( a_staff_pieces )
{
	flag_wait( "start_zombie_round_logic" );
	level.ice_staff_pieces = arraycopy( a_staff_pieces );
	_a1199 = level.ice_staff_pieces;
	_k1199 = getFirstArrayKey( _a1199 );
	while ( isDefined( _k1199 ) )
	{
		s_piece = _a1199[ _k1199 ];
		s_piece craftable_waittill_spawned();
		s_piece.piecespawn.model ghost();
		_k1199 = getNextArrayKey( _a1199, _k1199 );
	}
	level.ice_staff_pieces[ 0 ].zone_substr = "bunker";
	level.ice_staff_pieces[ 1 ].zone_substr = "nml";
	level.ice_staff_pieces[ 2 ].zone_substr = "village";
	level.ice_staff_pieces[ 2 ].num_misses = 2;
}

crystal_play_glow_fx( s_crystal )
{
	flag_wait( "start_zombie_round_logic" );
	switch( s_crystal.modelname )
	{
		case "t6_wpn_zmb_staff_crystal_air_part":
			watch_for_crystal_pickup( s_crystal, 2 );
			break;
		case "t6_wpn_zmb_staff_crystal_fire_part":
			watch_for_crystal_pickup( s_crystal, 1 );
			break;
		case "t6_wpn_zmb_staff_crystal_bolt_part":
			watch_for_crystal_pickup( s_crystal, 3 );
			break;
		case "t6_wpn_zmb_staff_crystal_water_part":
			watch_for_crystal_pickup( s_crystal, 4 );
			break;
	}
}

watch_for_crystal_pickup( s_crystal, n_enum )
{
	s_crystal.piecespawn.model setclientfield( "element_glow_fx", n_enum );
	s_crystal.piecespawn waittill( "pickup" );
	self playsound( "evt_crystal" );
	level.n_crystals_pickedup++;
}

crystal_dropped( s_crystal )
{
	flag_wait( "start_zombie_round_logic" );
	s_crystal.piecespawn waittill( "piece_released" );
	level.n_crystals_pickedup--;

	level thread crystal_play_glow_fx( s_crystal );
}

staff_charger_get_player_msg( e_player )
{
	weapon_available = 1;
	charge_ready = 0;
	if ( self.stub.staff_data.charger.is_inserted )
	{
		if ( self.stub.staff_data.charger.is_charged )
		{
			charge_ready = 1;
		}
	}
	if ( e_player hasweapon( self.stub.staff_data.weapname ) )
	{
		msg = self.stub.staff_data staff_get_insert_message();
		return msg;
	}
	else
	{
		if ( charge_ready )
		{
			msg = self.stub.staff_data staff_get_pickup_message();
			return msg;
		}
		else
		{
			return "";
		}
	}
}

place_staff_in_charger()
{
	flag_set( "charger_ready_" + self.enum );
	v_trigger_pos = self.charger.origin;
	v_trigger_pos = ( v_trigger_pos[ 0 ], v_trigger_pos[ 1 ], v_trigger_pos[ 2 ] - 30 );
	if ( isDefined( self.charge_trigger ) )
	{
		self.charge_trigger tomb_unitrigger_delete();
	}
	self.charge_trigger = tomb_spawn_trigger_radius( v_trigger_pos, 120, 1, ::staff_charger_get_player_msg );
	self.charge_trigger.require_look_at = 1;
	self.charge_trigger.staff_data = self;
	waittill_staff_inserted();
}

debug_staff_charge()
{
/#
	if ( !isDefined( self.charger.charges_received ) )
	{
		self.charger.charges_received = 0;
	}
	while ( self.charger.is_inserted )
	{
		if ( self.charger.is_charged )
		{
			maxammo = weaponmaxammo( self.weapname );
			if ( !isDefined( self.prev_ammo_stock ) )
			{
				self.prev_ammo_stock = maxammo;
			}
			print3d( self.origin, ( self.prev_ammo_stock + "/" ) + maxammo, vectorScale( ( 0, 0, 1 ), 255 ), 1 );
		}
		else
		{
			print3d( self.origin, ( self.charger.charges_received + "/" ) + 20, vectorScale( ( 0, 0, 1 ), 255 ), 1 );
		}
		wait 0,05;
#/
	}
}

waittill_staff_inserted()
{
	while ( 1 )
	{
		self.charge_trigger waittill( "trigger", player );
		weapon_available = 1;
		if ( isDefined( player ) )
		{
			weapon_available = player hasweapon( self.weapname );
			if ( weapon_available )
			{
				player takeweapon( self.weapname );
			}
		}
		if ( weapon_available )
		{
			self.charger.is_inserted = 1;
			self thread debug_staff_charge();
			maps/mp/zm_tomb_craftables::clear_player_staff( self.weapname );
			self.charge_trigger trigger_off();
			if ( isDefined( self.charger.angles ) )
			{
				self.angles = self.charger.angles;
			}
			self moveto( self.charger.origin, 0,05 );
			self waittill( "movedone" );
			self setclientfield( "staff_charger", self.enum );
			self.charger.full = 0;
			self show();
			self playsound( "zmb_squest_charge_place_staff" );
			return;
		}
	}
}

zombie_spawn_func()
{
	self.actor_killed_override = ::zombie_killed_override;
}

zombie_killed_override( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime )
{
	if ( flag( "ee_sam_portal_active" ) && !flag( "ee_souls_absorbed" ) )
	{
		maps/mp/zm_tomb_ee_main_step_7::ee_zombie_killed_override( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
		return;
	}
	if ( maps/mp/zm_tomb_challenges::footprint_zombie_killed( attacker ) )
	{
		return;
	}
	n_max_dist_sq = 9000000;
	if ( isplayer( attacker ) || sweapon == "one_inch_punch_zm" )
	{
		if ( !flag( "fire_puzzle_1_complete" ) )
		{
			maps/mp/zm_tomb_quest_fire::sacrifice_puzzle_zombie_killed( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
		}
		s_nearest_staff = undefined;
		n_nearest_dist_sq = n_max_dist_sq;
		_a1434 = level.a_elemental_staffs;
		_k1434 = getFirstArrayKey( _a1434 );
		while ( isDefined( _k1434 ) )
		{
			staff = _a1434[ _k1434 ];
			if ( isDefined( staff.charger.full ) && staff.charger.full )
			{
			}
			else
			{
				if ( staff.charger.is_inserted || staff.upgrade.charger.is_inserted )
				{
					if ( isDefined( staff.charger.is_charged ) && !staff.charger.is_charged )
					{
						dist_sq = distance2dsquared( self.origin, staff.origin );
						if ( dist_sq <= n_nearest_dist_sq )
						{
							n_nearest_dist_sq = dist_sq;
							s_nearest_staff = staff;
						}
					}
				}
			}
			_k1434 = getNextArrayKey( _a1434, _k1434 );
		}
		if ( isDefined( s_nearest_staff ) )
		{
			if ( s_nearest_staff.charger.is_charged )
			{
				return;
			}
			else
			{
				s_nearest_staff.charger.charges_received++;
				s_nearest_staff.charger thread zombie_soul_to_charger( self, s_nearest_staff.enum );
			}
		}
	}
}

zombie_soul_to_charger( ai_zombie, n_element )
{
	ai_zombie setclientfield( "zombie_soul", 1 );
	wait 1,5;
	self notify( "soul_received" );
}

staff_charger_check()
{
	self.charger.is_charged = 0;
	flag_wait( self.weapname + "_upgrade_unlocked" );
	self useweaponmodel( self.weapname );
	self showallparts();
	while ( 1 )
	{
		if ( self.charger.charges_received >= 20 || getDvarInt( "zombie_cheat" ) >= 2 && self.charger.is_inserted )
		{
			wait 0,5;
			self.charger.is_charged = 1;
			e_player = get_closest_player( self.charger.origin );
			e_player thread maps/mp/zm_tomb_vo::say_puzzle_completion_line( self.enum );
			self setclientfield( "staff_charger", 0 );
			self.charger.full = 1;
			level setclientfield( self.quest_clientfield, 4 );
			level thread spawn_upgraded_staff_triggers( self.enum );
			level.staffs_charged++;
			if ( level.staffs_charged == 4 )
			{
				flag_set( "ee_all_staffs_upgraded" );
			}
			self thread staff_sound();
			return;
		}
		else
		{
			wait 1;
		}
	}
}

staff_sound()
{
	self thread sndstaffupgradedstinger();
	self playsound( "zmb_squest_charge_soul_full" );
	self playloopsound( "zmb_squest_charge_soul_full_loop", 0,1 );
	level waittill( "stop_staff_sound" );
	self stoploopsound( 0,1 );
}

sndstaffupgradedstinger()
{
	if ( level.staffs_charged == 4 )
	{
		level thread maps/mp/zm_tomb_amb::sndplaystingerwithoverride( "mus_event_staff_all_upgraded", 55 );
		return;
	}
	if ( self.weapname == "staff_air_zm" )
	{
		level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "staff_wind_upgraded" );
	}
	if ( self.weapname == "staff_fire_zm" )
	{
		level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "staff_fire_upgraded" );
	}
	if ( self.weapname == "staff_lightning_zm" )
	{
		level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "staff_lightning_upgraded" );
	}
	if ( self.weapname == "staff_water_zm" )
	{
		level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "staff_ice_upgraded" );
	}
}

spawn_upgraded_staff_triggers( n_index )
{
	e_staff_standard = get_staff_info_from_element_index( n_index );
	e_staff_standard_upgraded = e_staff_standard.upgrade;
	e_staff_standard.charge_trigger trigger_on();
	e_staff_standard.charge_trigger.require_look_at = 1;
	pickup_message = e_staff_standard staff_get_pickup_message();
	e_staff_standard.charge_trigger set_unitrigger_hint_string( pickup_message );
	e_staff_standard ghost();
	e_staff_standard_upgraded.trigger = e_staff_standard.charge_trigger;
	e_staff_standard_upgraded.angles = e_staff_standard.angles;
	e_staff_standard_upgraded moveto( e_staff_standard.origin, 0,05 );
	e_staff_standard_upgraded waittill( "movedone" );
	e_staff_standard_upgraded show();
	e_fx = spawn( "script_model", e_staff_standard_upgraded.origin + vectorScale( ( 0, 0, 1 ), 8 ) );
	e_fx setmodel( "tag_origin" );
	wait 0,6;
	e_fx setclientfield( "element_glow_fx", e_staff_standard.enum );
	e_staff_standard_upgraded watch_for_player_pickup_staff();
	e_staff_standard_upgraded.trigger trigger_off();
	player = e_staff_standard_upgraded.owner;
	e_fx delete();
	while ( 1 )
	{
		if ( e_staff_standard.charger.is_charged )
		{
			e_staff_standard_upgraded thread staff_upgraded_reload_monitor();
			return;
		}
		else
		{
			wait_network_frame();
		}
	}
}

staff_upgraded_reload_monitor()
{
	self.weaponname = self.weapname;
	self thread track_staff_weapon_respawn( self.owner );
	while ( 1 )
	{
		place_staff_in_charger();
		self thread staff_upgraded_reload();
		self watch_for_player_pickup_staff();
		self.trigger trigger_off();
		self.charger.is_inserted = 0;
		maxammo = weaponmaxammo( self.weapname );
		n_ammo = int( min( maxammo, self.prev_ammo_stock ) );
		if ( isDefined( self.owner ) )
		{
			self.owner setweaponammostock( self.weapname, n_ammo );
			self.owner setweaponammoclip( self.weapname, self.prev_ammo_clip );
			self thread track_staff_weapon_respawn( self.owner );
		}
	}
}

staff_upgraded_reload()
{
	self endon( "staff_equip" );
	max_ammo = weaponmaxammo( self.weapname );
	n_count = int( max_ammo / 20 );
	b_reloaded = 0;
	while ( 1 )
	{
		self.charger waittill( "soul_received" );
		self.prev_ammo_stock += n_count;
		if ( self.prev_ammo_stock > max_ammo )
		{
			self.prev_ammo_stock = max_ammo;
			self setclientfield( "staff_charger", 0 );
			self.charger.full = 1;
		}
		if ( !b_reloaded )
		{
			self.trigger trigger_on();
			b_reloaded = 1;
		}
	}
}
