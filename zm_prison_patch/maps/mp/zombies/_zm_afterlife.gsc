#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/animscripts/shared;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zm_alcatraz_travel;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_clone;
#include maps/mp/zombies/_zm_perk_electric_cherry;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm;
#include maps/mp/_visionset_mgr;
#include maps/mp/zm_alcatraz_utility;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

init()
{
	level.zombiemode_using_afterlife = 1;
	flag_init( "afterlife_start_over" );
	level.afterlife_revive_tool = "syrette_afterlife_zm";
	precacheitem( level.afterlife_revive_tool );
	precachemodel( "drone_collision" );
	maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_afterlife", 9000, 120, 1, 1 );
	maps/mp/_visionset_mgr::vsmgr_register_info( "overlay", "zm_afterlife_filter", 9000, 120, 1, 1 );
	if ( isDefined( level.afterlife_player_damage_override ) )
	{
		maps/mp/zombies/_zm::register_player_damage_callback( level.afterlife_player_damage_override );
	}
	else
	{
		maps/mp/zombies/_zm::register_player_damage_callback( ::afterlife_player_damage_callback );
	}
	registerclientfield( "toplayer", "player_lives", 9000, 2, "int" );
	registerclientfield( "toplayer", "player_in_afterlife", 9000, 1, "int" );
	registerclientfield( "toplayer", "player_afterlife_mana", 9000, 5, "float" );
	registerclientfield( "allplayers", "player_afterlife_fx", 9000, 1, "int" );
	registerclientfield( "toplayer", "clientfield_afterlife_audio", 9000, 1, "int" );
	registerclientfield( "toplayer", "player_afterlife_refill", 9000, 1, "int" );
	registerclientfield( "scriptmover", "player_corpse_id", 9000, 3, "int" );
	afterlife_load_fx();
	level thread afterlife_hostmigration();
	precachemodel( "c_zom_ghost_viewhands" );
	precachemodel( "c_zom_hero_ghost_fb" );
	precacheitem( "lightning_hands_zm" );
	precachemodel( "p6_zm_al_shock_box_on" );
	precacheshader( "waypoint_revive_afterlife" );
	a_afterlife_interact = getentarray( "afterlife_interact", "targetname" );
	array_thread( a_afterlife_interact, ::afterlife_interact_object_think );
	level.zombie_spawners = getentarray( "zombie_spawner", "script_noteworthy" );
	array_thread( level.zombie_spawners, ::add_spawn_function, ::afterlife_zombie_damage );
	a_afterlife_triggers = getstructarray( "afterlife_trigger", "targetname" );
	_a87 = a_afterlife_triggers;
	_k87 = getFirstArrayKey( _a87 );
	while ( isDefined( _k87 ) )
	{
		struct = _a87[ _k87 ];
		afterlife_trigger_create( struct );
		_k87 = getNextArrayKey( _a87, _k87 );
	}
	level.afterlife_interact_dist = 256;
	level.is_player_valid_override = ::is_player_valid_afterlife;
	level.can_revive = ::can_revive_override;
	level.round_prestart_func = ::afterlife_start_zombie_logic;
	level.custom_pap_validation = ::is_player_valid_afterlife;
	level.player_out_of_playable_area_monitor_callback = ::player_out_of_playable_area;
	level thread afterlife_gameover_cleanup();
	level.afterlife_get_spawnpoint = ::afterlife_get_spawnpoint;
	level.afterlife_zapped = ::afterlife_zapped;
	level.afterlife_give_loadout = ::afterlife_give_loadout;
	level.afterlife_save_loadout = ::afterlife_save_loadout;
}

afterlife_gameover_cleanup()
{
	level waittill( "end_game" );
	_a126 = getplayers();
	_k126 = getFirstArrayKey( _a126 );
	while ( isDefined( _k126 ) )
	{
		player = _a126[ _k126 ];
		player.afterlife = 0;
		player clientnotify( "end_game" );
		player notify( "end_game" );
		if ( isDefined( player.client_hint ) )
		{
			player.client_hint destroy();
		}
		_k126 = getNextArrayKey( _a126, _k126 );
	}
	wait 5;
	_a141 = getplayers();
	_k141 = getFirstArrayKey( _a141 );
	while ( isDefined( _k141 ) )
	{
		player = _a141[ _k141 ];
		if ( isDefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
		{
			maps/mp/_visionset_mgr::vsmgr_deactivate( "overlay", "zm_afterlife_filter", player );
		}
		_k141 = getNextArrayKey( _a141, _k141 );
	}
}

afterlife_load_fx()
{
	level._effect[ "afterlife_teleport" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_zmb_tport" );
	level._effect[ "teleport_ball" ] = loadfx( "weapon/tomahawk/fx_tomahawk_trail_ug" );
	level._effect[ "afterlife_kill_point_fx" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_suicide_area" );
	level._effect[ "afterlife_enter" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_start" );
	level._effect[ "afterlife_leave" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_player_revive" );
	level._effect[ "afterlife_pixie_dust" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_pixies" );
	level._effect[ "afterlife_corpse" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_player_down" );
	level._effect[ "afterlife_damage" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_damage" );
	level._effect[ "afterlife_ghost_fx" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_body" );
	level._effect[ "afterlife_ghost_h_fx" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_head" );
	level._effect[ "afterlife_ghost_arm_fx" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_arm" );
	level._effect[ "afterlife_ghost_hand_fx" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_hand" );
	level._effect[ "afterlife_ghost_hand_r_fx" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_hand_r" );
	level._effect[ "afterlife_transition" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_transition" );
	level._effect[ "fx_alcatraz_ghost_vm_wrist" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist" );
	level._effect[ "fx_alcatraz_ghost_vm_wrist_r" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist_r" );
	level._effect[ "fx_alcatraz_ghost_spectate" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_spec" );
}

afterlife_start_zombie_logic()
{
	flag_wait( "start_zombie_round_logic" );
	wait 0,5;
	b_everyone_alive = 0;
	while ( isDefined( b_everyone_alive ) && !b_everyone_alive )
	{
		b_everyone_alive = 1;
		a_players = getplayers();
		_a192 = a_players;
		_k192 = getFirstArrayKey( _a192 );
		while ( isDefined( _k192 ) )
		{
			player = _a192[ _k192 ];
			if ( isDefined( player.afterlife ) && player.afterlife )
			{
				b_everyone_alive = 0;
				wait 0,05;
				break;
			}
			else
			{
				_k192 = getNextArrayKey( _a192, _k192 );
			}
		}
	}
	wait 0,5;
	while ( level.intermission )
	{
		wait 0,05;
	}
	flag_set( "afterlife_start_over" );
	wait 2;
	array_func( getplayers(), ::afterlife_add );
}

is_player_valid_afterlife( player )
{
	if ( isDefined( player.afterlife ) && player.afterlife )
	{
		return 0;
	}
	return 1;
}

can_revive_override( revivee )
{
	if ( isDefined( self.afterlife ) && self.afterlife )
	{
		return 0;
	}
	return 1;
}

player_out_of_playable_area()
{
	if ( isDefined( self.afterlife ) && self.afterlife )
	{
		return 0;
	}
	if ( isDefined( self.on_a_plane ) && self.on_a_plane )
	{
		return 0;
	}
	return 1;
}

init_player()
{
	flag_wait( "initial_players_connected" );
	if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		self.lives = 3;
	}
	else
	{
		self.lives = 1;
	}
	self setclientfieldtoplayer( "player_lives", self.lives );
	self.afterlife = 0;
	self.afterliferound = level.round_number;
	self.afterlifedeaths = 0;
	self thread afterlife_doors_close();
	self thread afterlife_player_refill_watch();
}

afterlife_remove( b_afterlife_death )
{
	if ( !isDefined( b_afterlife_death ) )
	{
		b_afterlife_death = 0;
	}
	if ( isDefined( b_afterlife_death ) && b_afterlife_death )
	{
		self.lives = 0;
	}
	else
	{
		if ( self.lives > 0 )
		{
			self.lives--;

		}
	}
	self notify( "sndLifeGone" );
	self setclientfieldtoplayer( "player_lives", self.lives );
}

afterlife_add()
{
	if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		if ( self.lives < 3 )
		{
			self.lives++;
			self thread afterlife_add_fx();
		}
	}
	else
	{
		if ( self.lives < 1 )
		{
			self.lives++;
			self thread afterlife_add_fx();
		}
	}
	self playsoundtoplayer( "zmb_afterlife_add", self );
	self setclientfieldtoplayer( "player_lives", self.lives );
}

afterlife_add_fx()
{
	if ( isDefined( self.afterlife ) && !self.afterlife )
	{
		self setclientfieldtoplayer( "player_afterlife_refill", 1 );
		wait 3;
		if ( isDefined( self.afterlife ) && !self.afterlife )
		{
			self setclientfieldtoplayer( "player_afterlife_refill", 0 );
		}
	}
}

afterlife_player_refill_watch()
{
	self endon( "disconnect" );
	self endon( "_zombie_game_over" );
	level endon( "stage_final" );
	while ( 1 )
	{
		level waittill( "end_of_round" );
		wait 2;
		self afterlife_add();
		reset_all_afterlife_unitriggers();
	}
}

afterlife_player_damage_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isDefined( eattacker ) )
	{
		if ( isDefined( eattacker.is_zombie ) && eattacker.is_zombie )
		{
			if ( isDefined( eattacker.custom_damage_func ) )
			{
				idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
			}
			else
			{
				if ( isDefined( eattacker.meleedamage ) && smeansofdeath != "MOD_GRENADE_SPLASH" )
				{
					idamage = eattacker.meleedamage;
				}
			}
			if ( isDefined( self.afterlife ) && self.afterlife )
			{
				self afterlife_reduce_mana( 10 );
				self clientnotify( "al_d" );
				return 0;
			}
		}
	}
	if ( isDefined( self.afterlife ) && self.afterlife )
	{
		return 0;
	}
	if ( isDefined( eattacker ) && isDefined( eattacker.is_zombie ) || eattacker.is_zombie && isplayer( eattacker ) )
	{
		if ( isDefined( self.hasriotshield ) && self.hasriotshield && isDefined( vdir ) )
		{
			item_dmg = 100;
			if ( isDefined( eattacker.custom_item_dmg ) )
			{
				item_dmg = eattacker.custom_item_dmg;
			}
			if ( isDefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped )
			{
				if ( self player_shield_facing_attacker( vdir, 0,2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( item_dmg, 0 );
					return 0;
				}
			}
			else
			{
				if ( !isDefined( self.riotshieldentity ) )
				{
					if ( !self player_shield_facing_attacker( vdir, -0,2 ) && isDefined( self.player_shield_apply_damage ) )
					{
						self [[ self.player_shield_apply_damage ]]( item_dmg, 0 );
						return 0;
					}
				}
			}
		}
	}
	if ( smeansofdeath != "MOD_PROJECTILE" && smeansofdeath != "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" && smeansofdeath == "MOD_GRENADE_SPLASH" )
	{
		if ( sweapon == "blundersplat_explosive_dart_zm" )
		{
			if ( self hasperk( "specialty_flakjacket" ) )
			{
				self.use_adjusted_grenade_damage = 1;
				idamage = 0;
			}
			if ( isalive( self ) && isDefined( self.is_zombie ) && !self.is_zombie )
			{
				self.use_adjusted_grenade_damage = 1;
				idamage = 10;
			}
		}
		else
		{
			if ( self hasperk( "specialty_flakjacket" ) )
			{
				return 0;
			}
			if ( self.health > 75 && isDefined( self.is_zombie ) && !self.is_zombie )
			{
				idamage = 75;
			}
		}
	}
	if ( sweapon == "tower_trap_zm" || sweapon == "tower_trap_upgraded_zm" )
	{
		self.use_adjusted_grenade_damage = 1;
		return 0;
	}
	if ( idamage >= self.health && isDefined( level.intermission ) && !level.intermission )
	{
		if ( self.lives > 0 && isDefined( self.afterlife ) && !self.afterlife )
		{
			self playsoundtoplayer( "zmb_afterlife_death", self );
			self afterlife_remove();
			self.afterlife = 1;
			self thread afterlife_laststand();
			if ( self.health <= 1 )
			{
				return 0;
			}
			else
			{
				idamage = self.health - 1;
			}
		}
		else
		{
			self thread last_stand_conscience_vo();
		}
	}
	return idamage;
}

afterlife_enter()
{
	if ( !isDefined( self.afterlife_visionset ) || self.afterlife_visionset == 0 )
	{
		maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_afterlife", self );
		if ( isDefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
		{
			maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_afterlife_filter", self );
		}
		self.afterlife_visionset = 1;
	}
	self enableafterlife();
	self.str_living_model = self.model;
	self.str_living_view = self getviewmodel();
	self setmodel( "c_zom_hero_ghost_fb" );
	self setviewmodel( "c_zom_ghost_viewhands" );
	self thread afterlife_doors_open();
	self setclientfieldtoplayer( "player_in_afterlife", 1 );
	self setclientfield( "player_afterlife_fx", 1 );
	self afterlife_create_mana_bar( self.e_afterlife_corpse );
	if ( !isDefined( self.keep_perks ) && flag( "afterlife_start_over" ) )
	{
		self increment_downed_stat();
	}
	a_afterlife_triggers = getstructarray( "afterlife_trigger", "targetname" );
	_a534 = a_afterlife_triggers;
	_k534 = getFirstArrayKey( _a534 );
	while ( isDefined( _k534 ) )
	{
		struct = _a534[ _k534 ];
		struct.unitrigger_stub maps/mp/zombies/_zm_unitrigger::run_visibility_function_for_all_triggers();
		_k534 = getNextArrayKey( _a534, _k534 );
	}
	a_exterior_goals = getstructarray( "exterior_goal", "targetname" );
	_a541 = a_exterior_goals;
	_k541 = getFirstArrayKey( _a541 );
	while ( isDefined( _k541 ) )
	{
		struct = _a541[ _k541 ];
		if ( isDefined( struct.unitrigger_stub ) )
		{
			struct.unitrigger_stub maps/mp/zombies/_zm_unitrigger::run_visibility_function_for_all_triggers();
		}
		_k541 = getNextArrayKey( _a541, _k541 );
	}
}

afterlife_leave( b_revived )
{
	if ( !isDefined( b_revived ) )
	{
		b_revived = 1;
	}
	self clientnotify( "al_t" );
	if ( isDefined( self.afterlife_visionset ) && self.afterlife_visionset )
	{
		maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_afterlife", self );
		if ( isDefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
		{
			maps/mp/_visionset_mgr::vsmgr_deactivate( "overlay", "zm_afterlife_filter", self );
		}
		self.afterlife_visionset = 0;
	}
	self disableafterlife();
	self.dontspeak = 0;
	self thread afterlife_doors_close();
	self.health = self.maxhealth;
	self setclientfieldtoplayer( "player_in_afterlife", 0 );
	self setclientfield( "player_afterlife_fx", 0 );
	self setclientfieldtoplayer( "clientfield_afterlife_audio", 0 );
	self maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	self allowstand( 1 );
	self allowcrouch( 1 );
	self allowprone( 1 );
	self setmodel( self.str_living_model );
	self setviewmodel( self.str_living_view );
	if ( self.e_afterlife_corpse.revivetrigger.origin != self.e_afterlife_corpse.origin )
	{
		self setorigin( self.e_afterlife_corpse.revivetrigger.origin );
	}
	else
	{
		self setorigin( self.e_afterlife_corpse.origin );
	}
	while ( isDefined( level.e_gondola ) )
	{
		a_gondola_doors_gates = get_gondola_doors_and_gates();
		i = 0;
		while ( i < a_gondola_doors_gates.size )
		{
			if ( self.e_afterlife_corpse istouching( a_gondola_doors_gates[ i ] ) )
			{
				if ( isDefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving )
				{
					str_location = level.e_gondola.destination;
				}
				else
				{
					str_location = level.e_gondola.location;
				}
				a_s_orgs = getstructarray( "gondola_dropped_parts_" + str_location, "targetname" );
				_a617 = a_s_orgs;
				_k617 = getFirstArrayKey( _a617 );
				while ( isDefined( _k617 ) )
				{
					struct = _a617[ _k617 ];
					if ( !positionwouldtelefrag( struct.origin ) )
					{
						self setorigin( struct.origin );
						break;
					}
					else
					{
						_k617 = getNextArrayKey( _a617, _k617 );
					}
				}
			}
			else i++;
		}
	}
	self setplayerangles( self.e_afterlife_corpse.angles );
	self.afterlife = 0;
	self afterlife_laststand_cleanup( self.e_afterlife_corpse );
	if ( isDefined( b_revived ) && !b_revived )
	{
		self afterlife_remove( 1 );
		self dodamage( 1000, self.origin );
	}
	reset_all_afterlife_unitriggers();
}

afterlife_laststand( b_electric_chair )
{
	if ( !isDefined( b_electric_chair ) )
	{
		b_electric_chair = 0;
	}
	self endon( "disconnect" );
	self endon( "afterlife_bleedout" );
	level endon( "end_game" );
	if ( isDefined( level.afterlife_laststand_override ) )
	{
		self thread [[ level.afterlife_laststand_override ]]( b_electric_chair );
		return;
	}
	self.dontspeak = 1;
	self.health = 1000;
	b_has_electric_cherry = 0;
	if ( self hasperk( "specialty_grenadepulldeath" ) )
	{
		b_has_electric_cherry = 1;
	}
	self [[ level.afterlife_save_loadout ]]();
	self afterlife_fake_death();
	if ( isDefined( b_electric_chair ) && !b_electric_chair )
	{
		wait 1;
	}
	if ( isDefined( b_has_electric_cherry ) && b_has_electric_cherry && isDefined( b_electric_chair ) && !b_electric_chair )
	{
		self maps/mp/zombies/_zm_perk_electric_cherry::electric_cherry_laststand();
		wait 2;
	}
	self setclientfieldtoplayer( "clientfield_afterlife_audio", 1 );
	if ( flag( "afterlife_start_over" ) )
	{
		self clientnotify( "al_t" );
		wait 1;
		self thread fadetoblackforxsec( 0, 1, 0,5, 0,5, "white" );
		wait 0,5;
	}
	self ghost();
	self.e_afterlife_corpse = self afterlife_spawn_corpse();
	self thread afterlife_clean_up_on_disconnect();
	self notify( "player_fake_corpse_created" );
	self afterlife_fake_revive();
	self afterlife_enter();
	self.e_afterlife_corpse setclientfield( "player_corpse_id", self getentitynumber() + 1 );
	wait 0,5;
	self show();
	if ( isDefined( self.hostmigrationcontrolsfrozen ) && !self.hostmigrationcontrolsfrozen )
	{
		self freezecontrols( 0 );
	}
	self disableinvulnerability();
	self.e_afterlife_corpse waittill( "player_revived", e_reviver );
	self notify( "player_revived" );
	self seteverhadweaponall( 1 );
	self enableinvulnerability();
	self.afterlife_revived = 1;
	playsoundatposition( "zmb_afterlife_spawn_leave", self.e_afterlife_corpse.origin );
	self afterlife_leave();
	self thread afterlife_revive_invincible();
	self playsound( "zmb_afterlife_revived_gasp" );
}

afterlife_clean_up_on_disconnect()
{
	e_corpse = self.e_afterlife_corpse;
	e_corpse endon( "death" );
	self waittill( "disconnect" );
	if ( isDefined( e_corpse.revivetrigger ) )
	{
		e_corpse notify( "stop_revive_trigger" );
		e_corpse.revivetrigger delete();
		e_corpse.revivetrigger = undefined;
	}
	e_corpse setclientfield( "player_corpse_id", 0 );
	e_corpse notify( "disconnect" );
	wait_network_frame();
	wait_network_frame();
	e_corpse delete();
}

afterlife_revive_invincible()
{
	self endon( "disconnect" );
	wait 2;
	self disableinvulnerability();
	self seteverhadweaponall( 0 );
	self.afterlife_revived = undefined;
}

afterlife_laststand_cleanup( corpse )
{
	self [[ level.afterlife_give_loadout ]]();
	self afterlife_corpse_cleanup( corpse );
}

afterlife_create_mana_bar( corpse )
{
	if ( self.afterliferound == level.round_number )
	{
		if ( !isDefined( self.keep_perks ) || self.afterlifedeaths == 0 )
		{
			self.afterlifedeaths++;
		}
	}
	else
	{
		self.afterliferound = level.round_number;
		self.afterlifedeaths = 1;
	}
	self.manacur = 200;
	self thread afterlife_mana_watch( corpse );
	self thread afterlife_lightning_watch( corpse );
	self thread afterlife_jump_watch( corpse );
}

afterlife_infinite_mana( b_infinite )
{
	if ( !isDefined( b_infinite ) )
	{
		b_infinite = 1;
	}
	if ( isDefined( b_infinite ) && b_infinite )
	{
		self.infinite_mana = 1;
	}
	else
	{
		self.infinite_mana = 0;
	}
}

afterlife_mana_watch( corpse )
{
	self endon( "disconnect" );
	corpse endon( "player_revived" );
	while ( self.manacur > 0 )
	{
		wait 0,05;
		self afterlife_reduce_mana( 0,05 * self.afterlifedeaths * 3 );
		if ( self.manacur < 0 )
		{
			self.manacur = 0;
		}
		n_mapped_mana = linear_map( self.manacur, 0, 200, 0, 1 );
		self setclientfieldtoplayer( "player_afterlife_mana", n_mapped_mana );
	}
	while ( isDefined( corpse.revivetrigger ) )
	{
		while ( corpse.revivetrigger.beingrevived )
		{
			wait 0,05;
		}
	}
	corpse notify( "stop_revive_trigger" );
	self thread fadetoblackforxsec( 0, 0,5, 0,5, 0,5, "black" );
	wait 0,5;
	self notify( "out_of_mana" );
	self afterlife_leave( 0 );
}

afterlife_doors_open()
{
	n_network_sent = 0;
	a_show = getentarray( "afterlife_show", "targetname" );
	a_show = arraycombine( a_show, getentarray( "afterlife_prop", "script_noteworthy" ), 0, 0 );
	_a888 = a_show;
	_k888 = getFirstArrayKey( _a888 );
	while ( isDefined( _k888 ) )
	{
		ent = _a888[ _k888 ];
		n_network_sent++;
		if ( n_network_sent > 10 )
		{
			n_network_sent = 0;
			wait_network_frame();
		}
		if ( isDefined( ent ) )
		{
			ent setvisibletoplayer( self );
		}
		_k888 = getNextArrayKey( _a888, _k888 );
	}
	a_hide = getentarray( "afterlife_door", "targetname" );
	a_hide = arraycombine( a_hide, getentarray( "zombie_door", "targetname" ), 0, 0 );
	a_hide = arraycombine( a_hide, getentarray( "quest_trigger", "script_noteworthy" ), 0, 0 );
	a_hide = arraycombine( a_hide, getentarray( "trap_trigger", "script_noteworthy" ), 0, 0 );
	a_hide = arraycombine( a_hide, getentarray( "travel_trigger", "script_noteworthy" ), 0, 0 );
	_a907 = a_hide;
	_k907 = getFirstArrayKey( _a907 );
	while ( isDefined( _k907 ) )
	{
		ent = _a907[ _k907 ];
		n_network_sent++;
		if ( n_network_sent > 10 )
		{
			n_network_sent = 0;
			wait_network_frame();
		}
		if ( isDefined( ent ) )
		{
			ent setinvisibletoplayer( self );
		}
		_k907 = getNextArrayKey( _a907, _k907 );
	}
	while ( isDefined( self.claymores ) )
	{
		_a924 = self.claymores;
		_k924 = getFirstArrayKey( _a924 );
		while ( isDefined( _k924 ) )
		{
			claymore = _a924[ _k924 ];
			if ( isDefined( claymore.pickuptrigger ) )
			{
				claymore.pickuptrigger setinvisibletoplayer( self );
			}
			_k924 = getNextArrayKey( _a924, _k924 );
		}
	}
}

afterlife_doors_close()
{
	n_network_sent = 0;
	a_hide = getentarray( "afterlife_show", "targetname" );
	a_hide = arraycombine( a_hide, getentarray( "afterlife_prop", "script_noteworthy" ), 0, 0 );
	_a943 = a_hide;
	_k943 = getFirstArrayKey( _a943 );
	while ( isDefined( _k943 ) )
	{
		ent = _a943[ _k943 ];
		n_network_sent++;
		if ( n_network_sent > 10 )
		{
			n_network_sent = 0;
			wait_network_frame();
		}
		if ( isDefined( ent ) )
		{
			ent setinvisibletoplayer( self );
		}
		_k943 = getNextArrayKey( _a943, _k943 );
	}
	a_show = getentarray( "afterlife_door", "targetname" );
	a_show = arraycombine( a_show, getentarray( "zombie_door", "targetname" ), 0, 0 );
	a_show = arraycombine( a_show, getentarray( "quest_trigger", "script_noteworthy" ), 0, 0 );
	a_show = arraycombine( a_show, getentarray( "trap_trigger", "script_noteworthy" ), 0, 0 );
	a_show = arraycombine( a_show, getentarray( "travel_trigger", "script_noteworthy" ), 0, 0 );
	_a962 = a_show;
	_k962 = getFirstArrayKey( _a962 );
	while ( isDefined( _k962 ) )
	{
		ent = _a962[ _k962 ];
		n_network_sent++;
		if ( n_network_sent > 10 )
		{
			n_network_sent = 0;
			wait_network_frame();
		}
		if ( isDefined( ent ) )
		{
			ent setvisibletoplayer( self );
		}
		_k962 = getNextArrayKey( _a962, _k962 );
	}
	while ( isDefined( self.claymores ) )
	{
		_a979 = self.claymores;
		_k979 = getFirstArrayKey( _a979 );
		while ( isDefined( _k979 ) )
		{
			claymore = _a979[ _k979 ];
			if ( isDefined( claymore.pickuptrigger ) )
			{
				claymore.pickuptrigger setvisibletoplayer( self );
			}
			_k979 = getNextArrayKey( _a979, _k979 );
		}
	}
}

afterlife_corpse_cleanup( corpse )
{
	playsoundatposition( "zmb_afterlife_revived", corpse.origin );
	if ( isDefined( corpse.revivetrigger ) )
	{
		corpse notify( "stop_revive_trigger" );
		corpse.revivetrigger delete();
		corpse.revivetrigger = undefined;
	}
	corpse setclientfield( "player_corpse_id", 0 );
	corpse afterlife_corpse_remove_pois();
	wait_network_frame();
	wait_network_frame();
	corpse delete();
	self.e_afterlife_corpse = undefined;
}

afterlife_spawn_corpse()
{
	if ( isDefined( self.is_on_gondola ) && self.is_on_gondola && level.e_gondola.destination == "roof" )
	{
		corpse = maps/mp/zombies/_zm_clone::spawn_player_clone( self, self.origin, undefined );
	}
	else
	{
		trace_start = self.origin;
		trace_end = self.origin + vectorScale( ( 0, 0, 1 ), 500 );
		corpse_trace = playerphysicstrace( trace_start, trace_end );
		corpse = maps/mp/zombies/_zm_clone::spawn_player_clone( self, corpse_trace, undefined );
	}
	corpse.angles = self.angles;
	corpse.ignoreme = 1;
	corpse maps/mp/zombies/_zm_clone::clone_give_weapon( "m1911_zm" );
	corpse maps/mp/zombies/_zm_clone::clone_animate( "afterlife" );
	corpse.revive_hud = self afterlife_revive_hud_create();
	corpse thread afterlife_revive_trigger_spawn();
	if ( flag( "solo_game" ) )
	{
		corpse thread afterlife_corpse_create_pois();
	}
	return corpse;
}

afterlife_corpse_create_pois()
{
	n_attractors = ceil( get_current_zombie_count() / 3 );
	if ( n_attractors < 4 )
	{
		n_attractors = 4;
	}
	a_nodes = afterlife_corpse_get_array_poi_positions();
	self.pois = [];
	while ( isDefined( a_nodes ) && a_nodes.size > 3 )
	{
		i = 0;
		while ( i < 3 )
		{
			self.pois[ i ] = afterlife_corpse_create_poi( a_nodes[ i ].origin, n_attractors );
			wait 0,05;
			i++;
		}
	}
}

afterlife_corpse_create_poi( v_origin, n_attractors )
{
	e_poi = spawn( "script_origin", v_origin );
	e_poi create_zombie_point_of_interest( 10000, 24, 5000, 1 );
	e_poi thread create_zombie_point_of_interest_attractor_positions();
/#
	e_poi thread print3d_ent( "Corpse POI" );
#/
	return e_poi;
}

afterlife_corpse_remove_pois()
{
	if ( !isDefined( self.pois ) )
	{
		return;
	}
	i = 0;
	while ( i < self.pois.size )
	{
		remove_poi_attractor( self.pois[ i ] );
		self.pois[ i ] delete();
		i++;
	}
	self.pois = undefined;
}

afterlife_corpse_get_array_poi_positions()
{
	n_ideal_dist_sq = 490000;
	a_nodes = getanynodearray( self.origin, 1200 );
	i = 0;
	while ( i < a_nodes.size )
	{
		if ( !a_nodes[ i ] is_valid_teleport_node() )
		{
		}
		i++;
	}
	a_nodes = remove_undefined_from_array( a_nodes );
	return array_randomize( a_nodes );
}

afterlife_revive_hud_create()
{
	self.revive_hud = newclienthudelem( self );
	self.revive_hud.alignx = "center";
	self.revive_hud.aligny = "middle";
	self.revive_hud.horzalign = "center";
	self.revive_hud.vertalign = "bottom";
	self.revive_hud.y = -160;
	self.revive_hud.foreground = 1;
	self.revive_hud.font = "default";
	self.revive_hud.fontscale = 1,5;
	self.revive_hud.alpha = 0;
	self.revive_hud.color = ( 0, 0, 1 );
	self.revive_hud.hidewheninmenu = 1;
	self.revive_hud settext( "" );
	return self.revive_hud;
}

afterlife_revive_trigger_spawn()
{
	radius = getDvarInt( "revive_trigger_radius" );
	self.revivetrigger = spawn( "trigger_radius", ( 0, 0, 1 ), 0, radius, radius );
	self.revivetrigger sethintstring( "" );
	self.revivetrigger setcursorhint( "HINT_NOICON" );
	self.revivetrigger setmovingplatformenabled( 1 );
	self.revivetrigger enablelinkto();
	self.revivetrigger.origin = self.origin;
	self.revivetrigger linkto( self );
	self.revivetrigger.beingrevived = 0;
	self.revivetrigger.createtime = getTime();
	self thread afterlife_revive_trigger_think();
}

afterlife_revive_trigger_think()
{
	self endon( "disconnect" );
	self endon( "stop_revive_trigger" );
	self endon( "death" );
	wait 1;
	while ( 1 )
	{
		wait 0,1;
		self.revivetrigger sethintstring( "" );
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] afterlife_can_revive( self ) )
			{
				self.revivetrigger setrevivehintstring( &"GAME_BUTTON_TO_REVIVE_PLAYER", self.team );
				break;
			}
			else
			{
				i++;
			}
		}
		i = 0;
		while ( i < players.size )
		{
			reviver = players[ i ];
			if ( self == reviver || !reviver is_reviving_afterlife( self ) )
			{
				i++;
				continue;
			}
			else
			{
				gun = reviver getcurrentweapon();
/#
				assert( isDefined( gun ) );
#/
				if ( gun == level.revive_tool || gun == level.afterlife_revive_tool )
				{
					i++;
					continue;
				}
				else
				{
					if ( isDefined( reviver.afterlife ) && reviver.afterlife )
					{
						reviver giveweapon( level.afterlife_revive_tool );
						reviver switchtoweapon( level.afterlife_revive_tool );
						reviver setweaponammostock( level.afterlife_revive_tool, 1 );
					}
					else
					{
						reviver giveweapon( level.revive_tool );
						reviver switchtoweapon( level.revive_tool );
						reviver setweaponammostock( level.revive_tool, 1 );
					}
					revive_success = reviver afterlife_revive_do_revive( self, gun );
					reviver revive_give_back_weapons( gun );
					if ( isplayer( self ) )
					{
						self allowjump( 1 );
					}
					self.laststand = undefined;
					if ( revive_success )
					{
						self thread revive_success( reviver );
						self cleanup_suicide_hud();
						return;
					}
				}
			}
			i++;
		}
	}
}

afterlife_can_revive( revivee )
{
	if ( isDefined( self.afterlife ) && self.afterlife && isDefined( self.e_afterlife_corpse ) && self.e_afterlife_corpse != revivee )
	{
		return 0;
	}
	if ( !isDefined( revivee.revivetrigger ) )
	{
		return 0;
	}
	if ( !isalive( self ) )
	{
		return 0;
	}
	if ( self player_is_in_laststand() )
	{
		return 0;
	}
	if ( self.team != revivee.team )
	{
		return 0;
	}
	if ( self has_powerup_weapon() )
	{
		return 0;
	}
	ignore_sight_checks = 0;
	ignore_touch_checks = 0;
	if ( isDefined( level.revive_trigger_should_ignore_sight_checks ) )
	{
		ignore_sight_checks = [[ level.revive_trigger_should_ignore_sight_checks ]]( self );
		if ( ignore_sight_checks && isDefined( revivee.revivetrigger.beingrevived ) && revivee.revivetrigger.beingrevived == 1 )
		{
			ignore_touch_checks = 1;
		}
	}
	if ( !ignore_touch_checks )
	{
		if ( !self istouching( revivee.revivetrigger ) )
		{
			return 0;
		}
	}
	if ( !ignore_sight_checks )
	{
		if ( !self is_facing( revivee ) )
		{
			return 0;
		}
		if ( !sighttracepassed( self.origin + vectorScale( ( 0, 0, 1 ), 50 ), revivee.origin + vectorScale( ( 0, 0, 1 ), 30 ), 0, undefined ) )
		{
			return 0;
		}
	}
	return 1;
}

afterlife_revive_do_revive( playerbeingrevived, revivergun )
{
/#
	assert( self is_reviving_afterlife( playerbeingrevived ) );
#/
	revivetime = 3;
	playloop = 0;
	if ( isDefined( self.afterlife ) && self.afterlife )
	{
		playloop = 1;
		revivetime = 1;
	}
	timer = 0;
	revived = 0;
	playerbeingrevived.revivetrigger.beingrevived = 1;
	playerbeingrevived.revive_hud settext( &"GAME_PLAYER_IS_REVIVING_YOU", self );
	playerbeingrevived revive_hud_show_n_fade( 3 );
	playerbeingrevived.revivetrigger sethintstring( "" );
	if ( isplayer( playerbeingrevived ) )
	{
		playerbeingrevived startrevive( self );
	}
	if ( !isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar = self createprimaryprogressbar();
	}
	if ( !isDefined( self.revivetexthud ) )
	{
		self.revivetexthud = newclienthudelem( self );
	}
	self thread revive_clean_up_on_gameover();
	self thread laststand_clean_up_on_disconnect( playerbeingrevived, revivergun );
	if ( !isDefined( self.is_reviving_any ) )
	{
		self.is_reviving_any = 0;
	}
	self.is_reviving_any++;
	self thread laststand_clean_up_reviving_any( playerbeingrevived );
	self.reviveprogressbar updatebar( 0,01, 1 / revivetime );
	self.revivetexthud.alignx = "center";
	self.revivetexthud.aligny = "middle";
	self.revivetexthud.horzalign = "center";
	self.revivetexthud.vertalign = "bottom";
	self.revivetexthud.y = -113;
	if ( self issplitscreen() )
	{
		self.revivetexthud.y = -347;
	}
	self.revivetexthud.foreground = 1;
	self.revivetexthud.font = "default";
	self.revivetexthud.fontscale = 1,8;
	self.revivetexthud.alpha = 1;
	self.revivetexthud.color = ( 0, 0, 1 );
	self.revivetexthud.hidewheninmenu = 1;
	if ( isDefined( self.pers_upgrades_awarded[ "revive" ] ) && self.pers_upgrades_awarded[ "revive" ] )
	{
		self.revivetexthud.color = ( 0,5, 0,5, 1 );
	}
	self.revivetexthud settext( &"GAME_REVIVING" );
	self thread check_for_failed_revive( playerbeingrevived );
	e_fx = spawn( "script_model", playerbeingrevived.revivetrigger.origin );
	e_fx setmodel( "tag_origin" );
	e_fx thread revive_fx_clean_up_on_disconnect( playerbeingrevived );
	playfxontag( level._effect[ "afterlife_leave" ], e_fx, "tag_origin" );
	if ( isDefined( playloop ) && playloop )
	{
		e_fx playloopsound( "zmb_afterlife_reviving", 0,05 );
	}
	while ( self is_reviving_afterlife( playerbeingrevived ) )
	{
		wait 0,05;
		timer += 0,05;
		if ( self player_is_in_laststand() )
		{
			break;
		}
		else if ( isDefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
		{
			break;
		}
		else
		{
			if ( timer >= revivetime )
			{
				revived = 1;
				break;
			}
			else
			{
			}
		}
	}
	e_fx delete();
	if ( isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar destroyelem();
	}
	if ( isDefined( self.revivetexthud ) )
	{
		self.revivetexthud destroy();
	}
	if ( isDefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
	{
	}
	else if ( !revived )
	{
		if ( isplayer( playerbeingrevived ) )
		{
			playerbeingrevived stoprevive( self );
		}
	}
	playerbeingrevived.revivetrigger sethintstring( &"GAME_BUTTON_TO_REVIVE_PLAYER" );
	playerbeingrevived.revivetrigger.beingrevived = 0;
	self notify( "do_revive_ended_normally" );
	self.is_reviving_any--;

	if ( !revived )
	{
		playerbeingrevived thread checkforbleedout( self );
	}
	return revived;
}

revive_fx_clean_up_on_disconnect( e_corpse )
{
	self endon( "death" );
	e_corpse waittill( "disconnect" );
	self delete();
}

revive_clean_up_on_gameover()
{
	self endon( "do_revive_ended_normally" );
	level waittill( "end_game" );
	if ( isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar destroyelem();
	}
	if ( isDefined( self.revivetexthud ) )
	{
		self.revivetexthud destroy();
	}
}

is_reviving_afterlife( revivee )
{
	if ( self usebuttonpressed() )
	{
		return afterlife_can_revive( revivee );
	}
}

afterlife_save_loadout()
{
	primaries = self getweaponslistprimaries();
	currentweapon = self getcurrentweapon();
	self.loadout = spawnstruct();
	self.loadout.player = self;
	self.loadout.weapons = [];
	self.loadout.score = self.score;
	self.loadout.current_weapon = 0;
	_a1516 = primaries;
	index = getFirstArrayKey( _a1516 );
	while ( isDefined( index ) )
	{
		weapon = _a1516[ index ];
		self.loadout.weapons[ index ] = weapon;
		self.loadout.stockcount[ index ] = self getweaponammostock( weapon );
		self.loadout.clipcount[ index ] = self getweaponammoclip( weapon );
		if ( weaponisdualwield( weapon ) )
		{
			weapon_dw = weapondualwieldweaponname( weapon );
			self.loadout.clipcount2[ index ] = self getweaponammoclip( weapon_dw );
		}
		weapon_alt = weaponaltweaponname( weapon );
		if ( weapon_alt != "none" )
		{
			self.loadout.stockcountalt[ index ] = self getweaponammostock( weapon_alt );
			self.loadout.clipcountalt[ index ] = self getweaponammoclip( weapon_alt );
		}
		if ( weapon == currentweapon )
		{
			self.loadout.current_weapon = index;
		}
		index = getNextArrayKey( _a1516, index );
	}
	self.loadout.equipment = self get_player_equipment();
	if ( isDefined( self.loadout.equipment ) )
	{
		self equipment_take( self.loadout.equipment );
	}
	if ( self hasweapon( "claymore_zm" ) )
	{
		self.loadout.hasclaymore = 1;
		self.loadout.claymoreclip = self getweaponammoclip( "claymore_zm" );
	}
	if ( self hasweapon( "emp_grenade_zm" ) )
	{
		self.loadout.hasemp = 1;
		self.loadout.empclip = self getweaponammoclip( "emp_grenade_zm" );
	}
	if ( self hasweapon( "bouncing_tomahawk_zm" ) || self hasweapon( "upgraded_tomahawk_zm" ) )
	{
		self.loadout.hastomahawk = 1;
		self setclientfieldtoplayer( "tomahawk_in_use", 0 );
	}
	self.loadout.perks = afterlife_save_perks( self );
	lethal_grenade = self get_player_lethal_grenade();
	if ( self hasweapon( lethal_grenade ) )
	{
		self.loadout.grenade = self getweaponammoclip( lethal_grenade );
	}
	else
	{
		self.loadout.grenade = 0;
	}
	self.loadout.lethal_grenade = lethal_grenade;
	self set_player_lethal_grenade( undefined );
}

afterlife_give_loadout()
{
	self takeallweapons();
	loadout = self.loadout;
	primaries = self getweaponslistprimaries();
	while ( loadout.weapons.size > 1 || primaries.size > 1 )
	{
		_a1601 = primaries;
		_k1601 = getFirstArrayKey( _a1601 );
		while ( isDefined( _k1601 ) )
		{
			weapon = _a1601[ _k1601 ];
			self takeweapon( weapon );
			_k1601 = getNextArrayKey( _a1601, _k1601 );
		}
	}
	i = 0;
	while ( i < loadout.weapons.size )
	{
		if ( !isDefined( loadout.weapons[ i ] ) )
		{
			i++;
			continue;
		}
		else if ( loadout.weapons[ i ] == "none" )
		{
			i++;
			continue;
		}
		else
		{
			weapon = loadout.weapons[ i ];
			stock_amount = loadout.stockcount[ i ];
			clip_amount = loadout.clipcount[ i ];
			if ( !self hasweapon( weapon ) )
			{
				self giveweapon( weapon, 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
				self setweaponammostock( weapon, stock_amount );
				self setweaponammoclip( weapon, clip_amount );
				if ( weaponisdualwield( weapon ) )
				{
					weapon_dw = weapondualwieldweaponname( weapon );
					self setweaponammoclip( weapon_dw, loadout.clipcount2[ i ] );
				}
				weapon_alt = weaponaltweaponname( weapon );
				if ( weapon_alt != "none" )
				{
					self setweaponammostock( weapon_alt, loadout.stockcountalt[ i ] );
					self setweaponammoclip( weapon_alt, loadout.clipcountalt[ i ] );
				}
			}
		}
		i++;
	}
	self setspawnweapon( loadout.weapons[ loadout.current_weapon ] );
	self switchtoweaponimmediate( loadout.weapons[ loadout.current_weapon ] );
	if ( isDefined( self get_player_melee_weapon() ) )
	{
		self giveweapon( self get_player_melee_weapon() );
	}
	self maps/mp/zombies/_zm_equipment::equipment_give( self.loadout.equipment );
	if ( isDefined( loadout.hasclaymore ) && loadout.hasclaymore && !self hasweapon( "claymore_zm" ) )
	{
		self giveweapon( "claymore_zm" );
		self set_player_placeable_mine( "claymore_zm" );
		self setactionslot( 4, "weapon", "claymore_zm" );
		self setweaponammoclip( "claymore_zm", loadout.claymoreclip );
	}
	if ( isDefined( loadout.hasemp ) && loadout.hasemp )
	{
		self giveweapon( "emp_grenade_zm" );
		self setweaponammoclip( "emp_grenade_zm", loadout.empclip );
	}
	if ( isDefined( loadout.hastomahawk ) && loadout.hastomahawk )
	{
		self giveweapon( self.current_tomahawk_weapon );
		self set_player_tactical_grenade( self.current_tomahawk_weapon );
		self setclientfieldtoplayer( "tomahawk_in_use", 1 );
	}
	self.score = loadout.score;
	perk_array = maps/mp/zombies/_zm_perks::get_perk_array( 1 );
	i = 0;
	while ( i < perk_array.size )
	{
		perk = perk_array[ i ];
		self unsetperk( perk );
		self set_perk_clientfield( perk, 0 );
		i++;
	}
	while ( isDefined( self.keep_perks ) && self.keep_perks && isDefined( loadout.perks ) && loadout.perks.size > 0 )
	{
		i = 0;
		while ( i < loadout.perks.size )
		{
			if ( self hasperk( loadout.perks[ i ] ) )
			{
				i++;
				continue;
			}
			else if ( loadout.perks[ i ] == "specialty_quickrevive" && flag( "solo_game" ) )
			{
				level.solo_game_free_player_quickrevive = 1;
			}
			if ( loadout.perks[ i ] == "specialty_finalstand" )
			{
				i++;
				continue;
			}
			else
			{
				maps/mp/zombies/_zm_perks::give_perk( loadout.perks[ i ] );
			}
			i++;
		}
	}
	self.keep_perks = undefined;
	self set_player_lethal_grenade( self.loadout.lethal_grenade );
	if ( loadout.grenade > 0 )
	{
		curgrenadecount = 0;
		if ( self hasweapon( self get_player_lethal_grenade() ) )
		{
			self getweaponammoclip( self get_player_lethal_grenade() );
		}
		else
		{
			self giveweapon( self get_player_lethal_grenade() );
		}
		self setweaponammoclip( self get_player_lethal_grenade(), loadout.grenade + curgrenadecount );
	}
}

afterlife_fake_death()
{
	level notify( "fake_death" );
	self notify( "fake_death" );
	self takeallweapons();
	self allowstand( 0 );
	self allowcrouch( 0 );
	self allowprone( 1 );
	self setstance( "prone" );
	while ( self is_jumping() )
	{
		while ( self is_jumping() )
		{
			wait 0,05;
		}
	}
	playfx( level._effect[ "afterlife_enter" ], self.origin );
	self.ignoreme = 1;
	self enableinvulnerability();
	self freezecontrols( 1 );
}

afterlife_fake_revive()
{
	level notify( "fake_revive" );
	self notify( "fake_revive" );
	playsoundatposition( "zmb_afterlife_spawn_leave", self.origin );
	if ( flag( "afterlife_start_over" ) )
	{
		spawnpoint = [[ level.afterlife_get_spawnpoint ]]();
		trace_start = spawnpoint.origin;
		trace_end = spawnpoint.origin + vectorScale( ( 0, 0, 1 ), 200 );
		respawn_trace = playerphysicstrace( trace_start, trace_end );
		self setorigin( respawn_trace );
		self setplayerangles( spawnpoint.angles );
		playsoundatposition( "zmb_afterlife_spawn_enter", spawnpoint.origin );
	}
	else
	{
		playsoundatposition( "zmb_afterlife_spawn_enter", self.origin );
	}
	self allowstand( 1 );
	self allowcrouch( 0 );
	self allowprone( 0 );
	self.ignoreme = 0;
	self setstance( "stand" );
	self giveweapon( "lightning_hands_zm" );
	self switchtoweapon( "lightning_hands_zm" );
	self.score = 0;
	wait 1;
}

afterlife_get_spawnpoint()
{
	spawnpoint = check_for_valid_spawn_in_zone( self );
	if ( !isDefined( spawnpoint ) )
	{
		spawnpoint = maps/mp/zombies/_zm::check_for_valid_spawn_near_position( self, self.origin, 1 );
	}
	if ( !isDefined( spawnpoint ) )
	{
		spawnpoint = maps/mp/zombies/_zm::check_for_valid_spawn_near_team( self, 1 );
	}
	if ( !isDefined( spawnpoint ) )
	{
		match_string = "";
		location = level.scr_zm_map_start_location;
		if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
		{
			location = level.default_start_location;
		}
		match_string = ( level.scr_zm_ui_gametype + "_" ) + location;
		spawnpoints = [];
		structs = getstructarray( "initial_spawn", "script_noteworthy" );
		while ( isDefined( structs ) )
		{
			_a1858 = structs;
			_k1858 = getFirstArrayKey( _a1858 );
			while ( isDefined( _k1858 ) )
			{
				struct = _a1858[ _k1858 ];
				while ( isDefined( struct.script_string ) )
				{
					tokens = strtok( struct.script_string, " " );
					_a1864 = tokens;
					_k1864 = getFirstArrayKey( _a1864 );
					while ( isDefined( _k1864 ) )
					{
						token = _a1864[ _k1864 ];
						if ( token == match_string )
						{
							spawnpoints[ spawnpoints.size ] = struct;
						}
						_k1864 = getNextArrayKey( _a1864, _k1864 );
					}
				}
				_k1858 = getNextArrayKey( _a1858, _k1858 );
			}
		}
		if ( !isDefined( spawnpoints ) || spawnpoints.size == 0 )
		{
			spawnpoints = getstructarray( "initial_spawn_points", "targetname" );
		}
/#
		assert( isDefined( spawnpoints ), "Could not find initial spawn points!" );
#/
		spawnpoint = maps/mp/zombies/_zm::getfreespawnpoint( spawnpoints, self );
	}
	return spawnpoint;
}

check_for_valid_spawn_in_zone( player )
{
	a_spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	if ( isDefined( level.e_gondola ) && isDefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving )
	{
		if ( player maps/mp/zm_alcatraz_travel::is_player_on_gondola() )
		{
			if ( level.e_gondola.destination == "roof" )
			{
				str_player_zone = "zone_cellblock_west_gondola";
			}
			else
			{
				if ( level.e_gondola.destination == "docks" )
				{
					str_player_zone = "zone_dock";
				}
			}
		}
		else
		{
			str_player_zone = player maps/mp/zombies/_zm_zonemgr::get_player_zone();
		}
	}
	else
	{
		str_player_zone = player maps/mp/zombies/_zm_zonemgr::get_player_zone();
	}
/#
	println( "The player is not in a zone at origin " + player.origin );
#/
	_a1929 = a_spawn_points;
	_k1929 = getFirstArrayKey( _a1929 );
	while ( isDefined( _k1929 ) )
	{
		spawn_point = _a1929[ _k1929 ];
		while ( spawn_point.script_noteworthy == str_player_zone )
		{
			a_spawn_structs = getstructarray( spawn_point.target, "targetname" );
			a_spawn_structs = get_array_of_closest( player.origin, a_spawn_structs );
			_a1939 = a_spawn_structs;
			_k1939 = getFirstArrayKey( _a1939 );
			while ( isDefined( _k1939 ) )
			{
				s_spawn = _a1939[ _k1939 ];
				if ( !flag( "afterlife_start_over" ) )
				{
					if ( isDefined( s_spawn.en_num ) && s_spawn.en_num != player.playernum )
					{
					}
				}
				else
				{
					if ( positionwouldtelefrag( s_spawn.origin ) || distancesquared( player.origin, s_spawn.origin ) < 250000 )
					{
						break;
					}
					else return s_spawn;
				}
				_k1939 = getNextArrayKey( _a1939, _k1939 );
			}
			a_spawn_structs = get_array_of_farthest( player.origin, a_spawn_structs, undefined, 250000 );
			_a1962 = a_spawn_structs;
			_k1962 = getFirstArrayKey( _a1962 );
			while ( isDefined( _k1962 ) )
			{
				s_spawn = _a1962[ _k1962 ];
				if ( positionwouldtelefrag( s_spawn.origin ) )
				{
				}
				else return s_spawn;
				_k1962 = getNextArrayKey( _a1962, _k1962 );
			}
		}
		_k1929 = getNextArrayKey( _a1929, _k1929 );
	}
	return undefined;
}

afterlife_save_perks( ent )
{
	perk_array = ent get_perk_array( 1 );
	_a1989 = perk_array;
	_k1989 = getFirstArrayKey( _a1989 );
	while ( isDefined( _k1989 ) )
	{
		perk = _a1989[ _k1989 ];
		ent unsetperk( perk );
		_k1989 = getNextArrayKey( _a1989, _k1989 );
	}
	return perk_array;
}

afterlife_hostmigration()
{
	while ( 1 )
	{
		level waittill( "host_migration_end" );
		_a2007 = getplayers();
		_k2007 = getFirstArrayKey( _a2007 );
		while ( isDefined( _k2007 ) )
		{
			player = _a2007[ _k2007 ];
			player setclientfieldtoplayer( "player_lives", player.lives );
			if ( isDefined( player.e_afterlife_corpse ) )
			{
				player.e_afterlife_corpse setclientfield( "player_corpse_id", 0 );
			}
			_k2007 = getNextArrayKey( _a2007, _k2007 );
		}
		wait_network_frame();
		wait_network_frame();
		_a2021 = getplayers();
		_k2021 = getFirstArrayKey( _a2021 );
		while ( isDefined( _k2021 ) )
		{
			player = _a2021[ _k2021 ];
			if ( isDefined( player.e_afterlife_corpse ) )
			{
				player.e_afterlife_corpse setclientfield( "player_corpse_id", player getentitynumber() + 1 );
			}
			_k2021 = getNextArrayKey( _a2021, _k2021 );
		}
	}
}

afterlife_reduce_mana( n_mana )
{
	if ( isDefined( self.afterlife ) && !self.afterlife )
	{
		return;
	}
	if ( isDefined( level.hostmigrationtimer ) )
	{
		return;
	}
	if ( isDefined( self.infinite_mana ) && self.infinite_mana )
	{
		self.manacur = 200;
		return;
	}
/#
	if ( getDvarInt( "zombie_cheat" ) >= 1 )
	{
		self.manacur = 200;
		return;
#/
	}
	if ( isDefined( self.e_afterlife_corpse ) && isDefined( self.e_afterlife_corpse.revivetrigger.beingrevived ) && self.e_afterlife_corpse.revivetrigger.beingrevived )
	{
		return;
	}
	self.manacur -= n_mana;
}

afterlife_lightning_watch( corpse )
{
	self endon( "disconnect" );
	corpse endon( "player_revived" );
	while ( 1 )
	{
		self waittill( "weapon_fired" );
		self afterlife_reduce_mana( 1 );
		wait 0,05;
	}
}

afterlife_jump_watch( corpse )
{
	self endon( "disconnect" );
	corpse endon( "player_revived" );
	while ( 1 )
	{
		if ( self is_jumping() )
		{
			self afterlife_reduce_mana( 0,3 );
			earthquake( 0,1, 0,05, self.origin, 200, self );
		}
		wait 0,05;
	}
}

afterlife_trigger_create( s_origin )
{
	s_origin.unitrigger_stub = spawnstruct();
	s_origin.unitrigger_stub.origin = s_origin.origin;
	s_origin.unitrigger_stub.radius = 36;
	s_origin.unitrigger_stub.height = 256;
	s_origin.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	s_origin.unitrigger_stub.hint_string = &"ZM_PRISON_AFTERLIFE_KILL";
	s_origin.unitrigger_stub.cursor_hint = "HINT_NOICON";
	s_origin.unitrigger_stub.require_look_at = 1;
	s_origin.unitrigger_stub.prompt_and_visibility_func = ::afterlife_trigger_visibility;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( s_origin.unitrigger_stub, 1 );
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( s_origin.unitrigger_stub, ::afterlife_trigger_think );
}

reset_all_afterlife_unitriggers()
{
	a_afterlife_triggers = getstructarray( "afterlife_trigger", "targetname" );
	_a2129 = a_afterlife_triggers;
	_k2129 = getFirstArrayKey( _a2129 );
	while ( isDefined( _k2129 ) )
	{
		struct = _a2129[ _k2129 ];
		maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( struct.unitrigger_stub );
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( struct.unitrigger_stub, ::afterlife_trigger_think );
		_k2129 = getNextArrayKey( _a2129, _k2129 );
	}
}

afterlife_trigger_visibility( player )
{
	b_is_invis = player.afterlife;
	self setinvisibletoplayer( player, b_is_invis );
	if ( player.lives == 0 )
	{
		self sethintstring( &"ZM_PRISON_OUT_OF_LIVES" );
	}
	else
	{
		self sethintstring( self.stub.hint_string );
		if ( !isDefined( player.has_played_afterlife_trigger_hint ) && player is_player_looking_at( self.stub.origin, 0,25 ) )
		{
			if ( isDefined( player.dontspeak ) && !player.dontspeak )
			{
				player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "killswitch_clue" );
				player.has_played_afterlife_trigger_hint = 1;
			}
		}
	}
	return !b_is_invis;
}

afterlife_trigger_think()
{
	self endon( "kill_trigger" );
	flag_wait( "start_zombie_round_logic" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		while ( player.lives <= 0 )
		{
			self playsound( "zmb_no_cha_ching" );
		}
		while ( player is_reviving_any() || player player_is_in_laststand() )
		{
			wait 0,1;
		}
		if ( isDefined( player.afterlife ) && !player.afterlife )
		{
			self setinvisibletoplayer( player, 1 );
			self playsound( "zmb_afterlife_trigger_activate" );
			player playsoundtoplayer( "zmb_afterlife_trigger_electrocute", player );
			player thread afterlife_trigger_used_vo();
			self sethintstring( "" );
			player.keep_perks = 1;
			player afterlife_remove();
			player.afterlife = 1;
			player thread afterlife_laststand();
			e_fx = spawn( "script_model", self.origin );
			e_fx setmodel( "tag_origin" );
			e_fx.angles = vectorScale( ( 0, 0, 1 ), 90 );
			playfxontag( level._effect[ "afterlife_kill_point_fx" ], e_fx, "tag_origin" );
			wait 2;
			e_fx delete();
			self sethintstring( &"ZM_PRISON_AFTERLIFE_KILL" );
		}
	}
}

afterlife_interact_object_think()
{
	self endon( "afterlife_interact_complete" );
	if ( isDefined( self.script_int ) && self.script_int > 0 )
	{
		n_total_interact_count = self.script_int;
	}
	else
	{
		if ( !isDefined( self.script_int ) || isDefined( self.script_int ) && self.script_int <= 0 )
		{
			n_total_interact_count = 0;
		}
	}
	n_count = 0;
	self.health = 5000;
	self setcandamage( 1 );
	self useanimtree( -1 );
	self playloopsound( "zmb_afterlife_shockbox_off", 1 );
	if ( !isDefined( level.shockbox_anim ) )
	{
		level.shockbox_anim[ "on" ] = %fxanim_zom_al_shock_box_on_anim;
		level.shockbox_anim[ "off" ] = %fxanim_zom_al_shock_box_off_anim;
	}
	trig_spawn_offset = ( 0, 0, 1 );
	if ( self.model != "p6_anim_zm_al_nixie_tubes" )
	{
		if ( isDefined( self.script_string ) && self.script_string == "intro_powerup_activate" )
		{
			self.t_bump = spawn( "trigger_radius", self.origin + vectorScale( ( 0, 0, 1 ), 28 ), 0, 28, 64 );
		}
		else
		{
			if ( issubstr( self.model, "p6_zm_al_shock_box" ) )
			{
				trig_spawn_offset = ( 0, 11, 46 );
				str_hint = &"ZM_PRISON_AFTERLIFE_INTERACT";
			}
			else
			{
				if ( issubstr( self.model, "p6_zm_al_power_station_panels" ) )
				{
					trig_spawn_offset = ( 32, 35, 58 );
					str_hint = &"ZM_PRISON_AFTERLIFE_OVERLOAD";
				}
			}
			afterlife_interact_hint_trigger_create( self, trig_spawn_offset, str_hint );
		}
	}
	while ( 1 )
	{
		if ( isDefined( self.unitrigger_stub ) )
		{
			self.unitrigger_stub.is_activated_in_afterlife = 0;
		}
		else
		{
			if ( isDefined( self.t_bump ) )
			{
				self.t_bump setcursorhint( "HINT_NOICON" );
				self.t_bump sethintstring( &"ZM_PRISON_AFTERLIFE_INTERACT" );
			}
		}
		self waittill( "damage", amount, attacker );
		if ( attacker == level || isplayer( attacker ) && attacker getcurrentweapon() == "lightning_hands_zm" )
		{
			if ( isDefined( self.script_string ) )
			{
				if ( isDefined( level.afterlife_interact_dist ) )
				{
					if ( attacker == level || distancesquared( attacker.origin, self.origin ) < ( level.afterlife_interact_dist * level.afterlife_interact_dist ) )
					{
						level notify( self.script_string );
						if ( isDefined( self.unitrigger_stub ) )
						{
							self.unitrigger_stub.is_activated_in_afterlife = 1;
							self.unitrigger_stub maps/mp/zombies/_zm_unitrigger::run_visibility_function_for_all_triggers();
						}
						else
						{
							if ( isDefined( self.t_bump ) )
							{
								self.t_bump sethintstring( "" );
							}
						}
						self playloopsound( "zmb_afterlife_shockbox_on", 1 );
						if ( self.model == "p6_zm_al_shock_box_off" )
						{
							if ( !isDefined( self.playing_fx ) )
							{
								playfxontag( level._effect[ "box_activated" ], self, "tag_origin" );
								self.playing_fx = 1;
								self thread afterlife_interact_object_fx_cooldown();
								self playsound( "zmb_powerpanel_activate" );
							}
							self setmodel( "p6_zm_al_shock_box_on" );
							self setanim( level.shockbox_anim[ "on" ] );
						}
						n_count++;
						if ( n_total_interact_count <= 0 || n_count < n_total_interact_count )
						{
							self waittill( "afterlife_interact_reset" );
							self playloopsound( "zmb_afterlife_shockbox_off", 1 );
							if ( self.model == "p6_zm_al_shock_box_on" )
							{
								self setmodel( "p6_zm_al_shock_box_off" );
								self setanim( level.shockbox_anim[ "off" ] );
							}
							if ( isDefined( self.unitrigger_stub ) )
							{
								self.unitrigger_stub.is_activated_in_afterlife = 0;
								self.unitrigger_stub maps/mp/zombies/_zm_unitrigger::run_visibility_function_for_all_triggers();
							}
							break;
						}
						else
						{
							if ( isDefined( self.t_bump ) )
							{
								self.t_bump delete();
							}
							return;
						}
					}
				}
			}
		}
		else
		{
		}
	}
}

afterlife_interact_hint_trigger_create( m_interact, v_trig_offset, str_hint )
{
	m_interact.unitrigger_stub = spawnstruct();
	m_interact.unitrigger_stub.origin = ( ( m_interact.origin + ( anglesToForward( m_interact.angles ) * v_trig_offset[ 0 ] ) ) + ( anglesToRight( m_interact.angles ) * v_trig_offset[ 1 ] ) ) + ( anglesToUp( m_interact.angles ) * v_trig_offset[ 2 ] );
	m_interact.unitrigger_stub.radius = 40;
	m_interact.unitrigger_stub.height = 64;
	m_interact.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	m_interact.unitrigger_stub.hint_string = str_hint;
	m_interact.unitrigger_stub.cursor_hint = "HINT_NOICON";
	m_interact.unitrigger_stub.require_look_at = 1;
	m_interact.unitrigger_stub.ignore_player_valid = 1;
	m_interact.unitrigger_stub.prompt_and_visibility_func = ::afterlife_trigger_visible_in_afterlife;
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( m_interact.unitrigger_stub, ::afterlife_interact_hint_trigger_think );
}

afterlife_trigger_visible_in_afterlife( player )
{
	if ( isDefined( self.stub.is_activated_in_afterlife ) )
	{
		b_is_invis = self.stub.is_activated_in_afterlife;
	}
	self setinvisibletoplayer( player, b_is_invis );
	self sethintstring( self.stub.hint_string );
	if ( !b_is_invis )
	{
		if ( player is_player_looking_at( self.origin, 0,25 ) )
		{
			if ( cointoss() )
			{
				player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "need_electricity" );
			}
			else
			{
				player thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "electric_zap" );
			}
		}
	}
	return !b_is_invis;
}

afterlife_interact_hint_trigger_think()
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger" );
		wait 1000;
	}
}

afterlife_interact_object_fx_cooldown()
{
	wait 2;
	self.playing_fx = undefined;
}

afterlife_zombie_damage()
{
	self.actor_damage_func = ::afterlife_damage_func;
}

afterlife_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( sweapon == "lightning_hands_zm" )
	{
		while ( !isDefined( self.zapped ) )
		{
			a_zombies = get_array_of_closest( self.origin, getaiarray( "axis" ), undefined, 5, 80 );
			i = 0;
			while ( i < a_zombies.size )
			{
				if ( isalive( a_zombies[ i ] ) && !isDefined( a_zombies[ i ].zapped ) )
				{
					a_zombies[ i ] notify( "zapped" );
					a_zombies[ i ] thread [[ level.afterlife_zapped ]]();
					wait 0,05;
				}
				i++;
			}
		}
		return 0;
	}
	return idamage;
}

afterlife_zapped()
{
	self endon( "death" );
	self endon( "zapped" );
	if ( self.ai_state == "find_flesh" )
	{
		self.zapped = 1;
		n_ideal_dist_sq = 490000;
		n_min_dist_sq = 10000;
		a_nodes = getanynodearray( self.origin, 1200 );
		a_nodes = arraycombine( a_nodes, getanynodearray( self.origin + vectorScale( ( 0, 0, 1 ), 120 ), 1200 ), 0, 0 );
		a_nodes = arraycombine( a_nodes, getanynodearray( self.origin - vectorScale( ( 0, 0, 1 ), 120 ), 1200 ), 0, 0 );
		a_nodes = array_randomize( a_nodes );
		nd_target = undefined;
		i = 0;
		while ( i < a_nodes.size )
		{
			if ( distance2dsquared( a_nodes[ i ].origin, self.origin ) > n_ideal_dist_sq )
			{
				if ( a_nodes[ i ] is_valid_teleport_node() )
				{
					nd_target = a_nodes[ i ];
					break;
				}
			}
			else
			{
				i++;
			}
		}
		while ( !isDefined( nd_target ) )
		{
			i = 0;
			while ( i < a_nodes.size )
			{
				if ( distance2dsquared( a_nodes[ i ].origin, self.origin ) > n_min_dist_sq )
				{
					if ( a_nodes[ i ] is_valid_teleport_node() )
					{
						nd_target = a_nodes[ i ];
						break;
					}
				}
				else
				{
					i++;
				}
			}
		}
		if ( isDefined( nd_target ) )
		{
			v_fx_offset = vectorScale( ( 0, 0, 1 ), 40 );
			playfx( level._effect[ "afterlife_teleport" ], self.origin );
			playsoundatposition( "zmb_afterlife_zombie_warp_out", self.origin );
			self hide();
			linker = spawn( "script_model", self.origin + v_fx_offset );
			linker setmodel( "tag_origin" );
			playfxontag( level._effect[ "teleport_ball" ], linker, "tag_origin" );
			linker thread linker_delete_watch( self );
			self linkto( linker );
			linker moveto( nd_target.origin + v_fx_offset, 1 );
			linker waittill( "movedone" );
			linker delete();
			playfx( level._effect[ "afterlife_teleport" ], self.origin );
			playsoundatposition( "zmb_afterlife_zombie_warp_in", self.origin );
			self show();
		}
		else
		{
/#
			iprintln( "Could not teleport" );
#/
			playfx( level._effect[ "afterlife_teleport" ], self.origin );
			playsoundatposition( "zmb_afterlife_zombie_warp_out", self.origin );
			level.zombie_total++;
			self delete();
			return;
		}
		self.zapped = undefined;
		self.ignoreall = 1;
		self notify( "stop_find_flesh" );
		self thread afterlife_zapped_fx();
		i = 0;
		while ( i < 3 )
		{
			self animscripted( self.origin, self.angles, "zm_afterlife_stun" );
			self maps/mp/animscripts/shared::donotetracks( "stunned" );
			i++;
		}
		self.ignoreall = 0;
		self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	}
}

is_valid_teleport_node()
{
	if ( !check_point_in_enabled_zone( self.origin ) )
	{
		return 0;
	}
	if ( self.type != "Path" )
	{
		return 0;
	}
	if ( isDefined( self.script_noteworthy ) && self.script_noteworthy == "no_teleport" )
	{
		return 0;
	}
	if ( isDefined( self.no_teleport ) && self.no_teleport )
	{
		return 0;
	}
	return 1;
}

linker_delete_watch( ai_zombie )
{
	self endon( "death" );
	ai_zombie waittill( "death" );
	self delete();
}

afterlife_zapped_fx()
{
	self endon( "death" );
	playfxontag( level._effect[ "elec_torso" ], self, "J_SpineLower" );
	self playsound( "zmb_elec_jib_zombie" );
	wait 1;
	tagarray = [];
	tagarray[ 0 ] = "J_Elbow_LE";
	tagarray[ 1 ] = "J_Elbow_RI";
	tagarray[ 2 ] = "J_Knee_RI";
	tagarray[ 3 ] = "J_Knee_LE";
	tagarray = array_randomize( tagarray );
	playfxontag( level._effect[ "elec_md" ], self, tagarray[ 0 ] );
	self playsound( "zmb_elec_jib_zombie" );
	wait 1;
	self playsound( "zmb_elec_jib_zombie" );
	tagarray[ 0 ] = "J_Wrist_RI";
	tagarray[ 1 ] = "J_Wrist_LE";
	if ( !isDefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" )
	{
		tagarray[ 2 ] = "J_Ankle_RI";
		tagarray[ 3 ] = "J_Ankle_LE";
	}
	tagarray = array_randomize( tagarray );
	playfxontag( level._effect[ "elec_sm" ], self, tagarray[ 0 ] );
	playfxontag( level._effect[ "elec_sm" ], self, tagarray[ 1 ] );
}

enable_afterlife_prop()
{
	self show();
	self.script_noteworthy = "afterlife_prop";
	a_players = getplayers();
	_a2655 = a_players;
	_k2655 = getFirstArrayKey( _a2655 );
	while ( isDefined( _k2655 ) )
	{
		player = _a2655[ _k2655 ];
		if ( isDefined( player.afterlife ) && player.afterlife )
		{
			self setvisibletoplayer( player );
		}
		else
		{
			self setinvisibletoplayer( player );
		}
		_k2655 = getNextArrayKey( _a2655, _k2655 );
	}
}

disable_afterlife_prop()
{
	self.script_noteworthy = undefined;
	self setvisibletoall();
}

last_stand_conscience_vo()
{
	self endon( "player_revived" );
	self endon( "player_suicide" );
	self endon( "zombified" );
	self endon( "disconnect" );
	self endon( "end_game" );
	if ( !isDefined( self.conscience_vo_played ) )
	{
		self.conscience_vo_played = 0;
	}
	self.conscience_vo_played++;
	convo = [];
	convo = level.conscience_vo[ "conscience_" + self.character_name + "_convo_" + self.conscience_vo_played ];
	while ( isDefined( convo ) )
	{
		wait 5;
		a_players = getplayers();
		while ( a_players.size > 1 )
		{
			_a2708 = a_players;
			_k2708 = getFirstArrayKey( _a2708 );
			while ( isDefined( _k2708 ) )
			{
				player = _a2708[ _k2708 ];
				if ( player != self )
				{
					if ( distancesquared( self.origin, player.origin ) < 1000000 )
					{
						return;
					}
				}
				_k2708 = getNextArrayKey( _a2708, _k2708 );
			}
		}
		self.dontspeak = 1;
		i = 0;
		while ( i < convo.size )
		{
			n_duration = soundgetplaybacktime( convo[ i ] );
			self playsoundtoplayer( convo[ i ], self );
			self thread conscience_vo_ended_early( convo[ i ] );
			wait ( n_duration / 1000 );
			wait 0,5;
			i++;
		}
	}
	self.dontspeak = 0;
}

conscience_vo_ended_early( str_alias )
{
	self notify( "conscience_VO_end_early" );
	self endon( "conscience_VO_end_early" );
	self waittill_any( "player_revived", "player_suicide", "zombified", "death", "end_game" );
	self.dontspeak = 0;
	self stoplocalsound( str_alias );
}

afterlife_trigger_used_vo()
{
	a_vo = level.exert_sounds[ self.characterindex + 1 ][ "hitlrg" ];
	n_index = randomint( a_vo.size );
	self playsound( a_vo[ n_index ] );
}
