#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm;
#include maps/mp/zm_transit_distance_tracking;
#include maps/mp/zm_transit;
#include maps/mp/zm_transit_power;
#include maps/mp/zm_transit_ai_screecher;
#include maps/mp/zm_transit_bus;
#include maps/mp/zm_transit_buildables;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

precache()
{
	maps/mp/zombies/_zm_ai_screecher::precache();
	maps/mp/zombies/_zm_ai_avogadro::precache();
	maps/mp/zm_transit_buildables::include_buildables();
	maps/mp/zm_transit_buildables::init_buildables();
	maps/mp/zm_transit_sq::init();
	maps/mp/zombies/_zm_equip_turbine::init();
	maps/mp/zombies/_zm_equip_turret::init();
	maps/mp/zombies/_zm_equip_electrictrap::init();
	precachemodel( "zm_collision_transit_town_classic" );
	precachemodel( "p_glo_tools_chest_tall" );
	precachemodel( "fxanim_zom_bus_interior_mod" );
	precachemodel( "p6_anim_zm_barricade_board_collision" );
	precachemodel( "p6_anim_zm_barricade_board_bus_collision" );
	registerclientfield( "vehicle", "the_bus_spawned", 1, 1, "int" );
	registerclientfield( "vehicle", "bus_flashing_lights", 1, 1, "int" );
	registerclientfield( "vehicle", "bus_head_lights", 1, 1, "int" );
	registerclientfield( "vehicle", "bus_brake_lights", 1, 1, "int" );
	registerclientfield( "vehicle", "bus_turn_signal_left", 1, 1, "int" );
	registerclientfield( "vehicle", "bus_turn_signal_right", 1, 1, "int" );
	registerclientfield( "allplayers", "screecher_sq_lights", 1, 1, "int" );
	registerclientfield( "allplayers", "screecher_maxis_lights", 1, 1, "int" );
	registerclientfield( "allplayers", "sq_tower_sparks", 1, 1, "int" );
	onplayerconnect_callback( ::maps/mp/zm_transit_bus::onplayerconnect );
	onplayerconnect_callback( ::onplayerconnect_bank_deposit_box );
	onplayerconnect_callback( ::maps/mp/zm_transit_ai_screecher::portal_player_watcher );
}

main()
{
	level.ta_vaultfee = 100;
	level.ta_tellerfee = 100;
	if ( !isDefined( level.custom_ai_type ) )
	{
		level.custom_ai_type = [];
	}
	level.custom_ai_type[ level.custom_ai_type.size ] = ::maps/mp/zombies/_zm_ai_screecher::init;
	level.custom_ai_type[ level.custom_ai_type.size ] = ::maps/mp/zombies/_zm_ai_avogadro::init;
	level.enemy_location_override_func = ::maps/mp/zm_transit_bus::enemy_location_override;
	level.adjust_enemyoverride_func = ::maps/mp/zm_transit_bus::adjust_enemyoverride;
	level.closest_player_override = ::closest_player_transit;
	door_triggers = getentarray( "electric_door", "script_noteworthy" );
	_a80 = door_triggers;
	_k80 = getFirstArrayKey( _a80 );
	while ( isDefined( _k80 ) )
	{
		trigger = _a80[ _k80 ];
		if ( isDefined( trigger.script_flag ) && trigger.script_flag == "OnPowDoorWH" )
		{
		}
		else
		{
			trigger.power_door_ignore_flag_wait = 1;
		}
		_k80 = getNextArrayKey( _a80, _k80 );
	}
	door_triggers = getentarray( "local_electric_door", "script_noteworthy" );
	_a91 = door_triggers;
	_k91 = getFirstArrayKey( _a91 );
	while ( isDefined( _k91 ) )
	{
		trigger = _a91[ _k91 ];
		if ( isDefined( trigger.script_flag ) && trigger.script_flag == "OnPowDoorWH" )
		{
		}
		else
		{
			trigger.power_door_ignore_flag_wait = 1;
		}
		_k91 = getNextArrayKey( _a91, _k91 );
	}
	level.zm_traversal_override = ::zm_traversal_override;
	level.the_bus = getent( "the_bus", "targetname" );
	level thread init_bus();
	level thread maps/mp/zm_transit_sq::start_transit_sidequest();
	level thread inert_zombies_init();
	level thread maps/mp/zm_transit_power::initializepower();
	level thread maps/mp/zm_transit_ambush::main();
	level thread maps/mp/zm_transit::falling_death_init();
	level.check_valid_spawn_override = ::maps/mp/zm_transit::transit_respawn_override;
	level.zombie_check_suppress_gibs = ::maps/mp/zm_transit_bus::shouldsuppressgibs;
	level thread transit_vault_breach_init();
	level thread maps/mp/zm_transit_distance_tracking::zombie_tracking_init();
	level thread solo_tombstone_removal();
	level thread collapsing_bridge_init();
	level thread bank_deposit_box();
	level thread bus_roof_damage_init();
	level thread diner_hatch_access();
	level thread maps/mp/zombies/_zm_buildables::think_buildables();
	setdvar( "r_rimIntensity_debug", 1 );
	setdvar( "r_rimIntensity", 3,5 );
	level thread zm_traversal_override_ignores();
	level thread maps/mp/zombies/_zm::post_main();
	level.spectator_respawn_custom_score = ::callback_spectator_respawn_custom_score;
	level thread triggerweaponslockerwatch();
	level.custom_pap_deny_vo_func = ::transit_custom_deny_vox;
	level.custom_generic_deny_vo_func = ::transit_custom_deny_vox;
	level.custom_player_death_vo_func = ::transit_custom_death_vox;
	level.custom_powerup_vo_response = ::transit_custom_powerup_vo_response;
	level.zombie_vars[ "zombie_intermission_time" ] = 12;
}

zm_traversal_override_ignores()
{
}

zm_traversal_override( traversealias )
{
	suffix = "";
	sndalias = undefined;
	chance = 0;
	sndchance = 0;
	if ( isDefined( self.isscreecher ) && !self.isscreecher && isDefined( self.is_avogadro ) && !self.is_avogadro )
	{
		if ( isDefined( self.traversestartnode ) && isDefined( self.traversestartnode.script_string ) && self.traversestartnode.script_string == "ignore_traverse_override" )
		{
			return traversealias;
		}
		switch( traversealias )
		{
			case "jump_down_48":
				if ( isDefined( self.has_legs ) && self.has_legs )
				{
					suffix = "_stumble";
					chance = 0;
				}
				break;
			case "jump_down_127":
			case "jump_down_190":
			case "jump_down_222":
			case "jump_down_90":
				if ( isDefined( self.has_legs ) && self.has_legs )
				{
					suffix = "_stumble";
					chance = 30;
				}
				break;
			case "jump_up_127":
			case "jump_up_190":
			case "jump_up_222":
			case "jump_up_48":
				sndalias = "vox_zmba_zombie_pickup_" + randomint( 2 );
				suffix = "_grabbed";
				chance = 6;
				sndchance = 3;
				break;
		}
		if ( chance != 0 && randomint( 100 ) <= chance )
		{
			if ( isDefined( sndalias ) && randomint( 100 ) <= sndchance )
			{
				playsoundatposition( sndalias, self.origin );
			}
			traversealias += suffix;
		}
	}
	return traversealias;
}

init_bus()
{
	flag_wait( "start_zombie_round_logic" );
	level.the_bus thread maps/mp/zm_transit_bus::bussetup();
}

closest_player_transit( origin, players )
{
	if ( isDefined( level.the_bus ) || level.the_bus.numaliveplayersridingbus > 0 && isDefined( level.calc_closest_player_using_paths ) && !level.calc_closest_player_using_paths )
	{
		player = getclosest( origin, players );
	}
	else
	{
		player = get_closest_player_using_paths( origin, players );
	}
	return player;
}

transit_vault_breach_init()
{
	vault_doors = getentarray( "town_bunker_door", "targetname" );
	array_thread( vault_doors, ::transit_vault_breach );
}

transit_vault_breach()
{
	if ( isDefined( self ) )
	{
		self.damage_state = 0;
		if ( isDefined( self.target ) )
		{
			clip = getent( self.target, "targetname" );
			clip linkto( self );
			self.clip = clip;
		}
		self thread vault_breach_think();
	}
	else
	{
		return;
	}
}

vault_breach_think()
{
	level endon( "intermission" );
	self.health = 99999;
	self setcandamage( 1 );
	self.damage_state = 0;
	self.clip.health = 99999;
	self.clip setcandamage( 1 );
	while ( 1 )
	{
		self thread track_clip_damage();
		self waittill( "damage", amount, attacker, direction, point, dmg_type, modelname, tagname, partname, weaponname );
		if ( isDefined( weaponname ) && weaponname != "emp_grenade_zm" || weaponname == "ray_gun_zm" && weaponname == "ray_gun_upgraded_zm" )
		{
			continue;
		}
		if ( isDefined( amount ) && amount <= 1 )
		{
			continue;
		}
		if ( isplayer( attacker ) && dmg_type != "MOD_PROJECTILE" && dmg_type != "MOD_PROJECTILE_SPLASH" && dmg_type != "MOD_EXPLOSIVE" && dmg_type != "MOD_EXPLOSIVE_SPLASH" || dmg_type == "MOD_GRENADE" && dmg_type == "MOD_GRENADE_SPLASH" )
		{
			if ( self.damage_state == 0 )
			{
				self.damage_state = 1;
			}
			playfxontag( level._effect[ "def_explosion" ], self, "tag_origin" );
			self playsound( "exp_vault_explode" );
			self bunkerdoorrotate( 1 );
			if ( isDefined( self.script_flag ) )
			{
				flag_set( self.script_flag );
			}
			if ( isDefined( self.clip ) )
			{
				self.clip connectpaths();
			}
			wait 1;
			playsoundatposition( "zmb_cha_ching_loud", self.origin );
			return;
		}
	}
}

track_clip_damage()
{
	self endon( "damage" );
	self.clip waittill( "damage", amount, attacker, direction, point, dmg_type );
	self notify( "damage" );
}

bunkerdoorrotate( open, time )
{
	if ( !isDefined( time ) )
	{
		time = 0,2;
	}
	rotate = self.script_float;
	if ( !open )
	{
		rotate *= -1;
	}
	if ( isDefined( self.script_angles ) )
	{
		self notsolid();
		self rotateto( self.script_angles, time, 0, 0 );
		self thread maps/mp/zombies/_zm_blockers::door_solid_thread();
	}
}

collapsing_bridge_init()
{
	time = 1,5;
	trig = getent( "bridge_trig", "targetname" );
	if ( !isDefined( trig ) )
	{
		return;
	}
	bridge = getentarray( trig.target, "targetname" );
	if ( !isDefined( bridge ) )
	{
		return;
	}
	trig waittill( "trigger", who );
	trig playsound( "evt_bridge_collapse_start" );
	trig thread play_delayed_sound( time );
	i = 0;
	while ( i < bridge.size )
	{
		if ( isDefined( bridge[ i ].script_angles ) )
		{
			rot_angle = bridge[ i ].script_angles;
		}
		else
		{
			rot_angle = ( 0, 0, 0 );
		}
		earthquake( randomfloatrange( 0,5, 1 ), 1,5, bridge[ i ].origin, 1000 );
		exploder( 150 );
		bridge[ i ] rotateto( rot_angle, time, 0, 0 );
		i++;
	}
	wait 1;
	if ( !isDefined( level.collapse_vox_said ) )
	{
		level thread automatonspeak( "inform", "bridge_collapse" );
		level.collapse_vox_said = 1;
	}
}

play_delayed_sound( time )
{
	wait time;
	self playsound( "evt_bridge_collapse_end" );
}

bank_deposit_box()
{
	level.bank_deposit_max_amount = 250000;
	level.bank_deposit_ddl_increment_amount = 1000;
	deposit_trig = spawn( "trigger_radius_use", ( 588, 441,5, 6 ), 0, 4, 32 );
	deposit_trig sethintstring( &"ZOMBIE_BANK_DEPOSIT_PROMPT", level.bank_deposit_ddl_increment_amount );
	deposit_trig setcursorhint( "HINT_NOICON" );
	deposit_trig triggerignoreteam();
	deposit_trig thread bank_deposit_box_think( 1 );
	level.deposit_trig = deposit_trig;
	withdraw_trig = spawn( "trigger_radius_use", ( 588, 450, 6 ), 0, 4, 32 );
	withdraw_trig sethintstring( &"ZOMBIE_BANK_WITHDRAW_PROMPT", level.bank_deposit_ddl_increment_amount, level.ta_vaultfee );
	withdraw_trig setcursorhint( "HINT_NOICON" );
	withdraw_trig triggerignoreteam();
	withdraw_trig thread bank_deposit_box_think( 0 );
	level.withdraw_trig = withdraw_trig;
}

onplayerconnect_bank_deposit_box()
{
	account_val = self maps/mp/zombies/_zm_stats::get_map_stat( "depositBox" );
	if ( account_val >= level.bank_deposit_max_amount )
	{
		level.deposit_trig setinvisibletoplayer( self );
	}
}

bank_deposit_box_think( is_deposit )
{
	account_max = level.bank_deposit_max_amount / level.bank_deposit_ddl_increment_amount;
	account_increment = int( level.bank_deposit_ddl_increment_amount / 1000 );
	online_game = sessionmodeisonlinegame();
	for ( ;; )
	{
		while ( 1 )
		{
			self waittill( "trigger", player );
			while ( !is_player_valid( player ) )
			{
				continue;
			}
			account_val = player maps/mp/zombies/_zm_stats::get_map_stat( "depositBox" );
			if ( !online_game )
			{
				if ( !isDefined( player.account_val ) )
				{
					player.account_val = 0;
				}
				account_val = player.account_val;
			}
			account_deposit_expected = account_val + account_increment;
			if ( isDefined( is_deposit ) && is_deposit && player.score >= level.bank_deposit_ddl_increment_amount && account_deposit_expected <= account_max )
			{
				player playsoundtoplayer( "zmb_vault_bank_deposit", player );
				player.score -= level.bank_deposit_ddl_increment_amount;
				player maps/mp/zombies/_zm_stats::set_map_stat( "depositBox", account_val + account_increment );
				if ( !online_game )
				{
					player.account_val += account_increment;
				}
				if ( account_deposit_expected >= account_max )
				{
					level.deposit_trig setinvisibletoplayer( player );
				}
				break;
			}
			else
			{
				if ( isDefined( is_deposit ) && !is_deposit && account_val >= account_increment )
				{
					player playsoundtoplayer( "zmb_vault_bank_deposit", player );
					player.score += level.bank_deposit_ddl_increment_amount;
					player maps/mp/zombies/_zm_stats::set_map_stat( "depositBox", account_val - account_increment );
					if ( !online_game )
					{
						player.account_val -= account_increment;
					}
					player thread do_player_general_vox( "general", "exert_laugh", 10, 50 );
					player thread player_withdraw_fee();
					break;
				}
				else
				{
					player thread do_player_general_vox( "general", "exert_sigh", 10, 50 );
				}
			}
		}
	}
}

player_withdraw_fee()
{
	self endon( "disconnect" );
	wait_network_frame();
	self.score -= level.ta_vaultfee;
	level.deposit_trig setvisibletoplayer( self );
}

bus_roof_damage_init()
{
	trigs = getentarray( "bus_knock_off", "targetname" );
	array_thread( trigs, ::bus_roof_damage );
}

bus_roof_damage()
{
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( isplayer( who ) )
		{
			if ( who getstance() == "stand" )
			{
				who dodamage( 1, who.origin );
			}
		}
		else
		{
			if ( isDefined( who.marked_for_death ) && !who.marked_for_death && isDefined( who.has_legs ) && who.has_legs )
			{
				who dodamage( who.health + 100, who.origin );
				who.marked_for_death = 1;
				level.zombie_total++;
			}
		}
		wait 0,1;
	}
}

diner_hatch_access()
{
	diner_hatch = getent( "diner_hatch", "targetname" );
	diner_hatch_col = getent( "diner_hatch_collision", "targetname" );
	diner_hatch_mantle = getent( "diner_hatch_mantle", "targetname" );
	if ( !isDefined( diner_hatch ) || !isDefined( diner_hatch_col ) )
	{
		return;
	}
	diner_hatch hide();
	diner_hatch_mantle.start_origin = diner_hatch_mantle.origin;
	diner_hatch_mantle.origin += vectorScale( ( 0, 0, 0 ), 500 );
	player = wait_for_buildable( "dinerhatch" );
	diner_hatch show();
	diner_hatch_col delete();
	diner_hatch_mantle.origin = diner_hatch_mantle.start_origin;
	player maps/mp/zombies/_zm_buildables::track_placed_buildables( "dinerhatch" );
}

inert_zombies_init()
{
	inert_spawn_location = getstructarray( "inert_location", "script_noteworthy" );
	if ( isDefined( inert_spawn_location ) )
	{
		array_thread( inert_spawn_location, ::spawn_inert_zombies );
	}
}

spawn_inert_zombies()
{
	if ( !isDefined( self.angles ) )
	{
		self.angles = ( 0, 0, 0 );
	}
	wait 0,1;
	if ( isDefined( level.zombie_spawners ) )
	{
		spawner = random( level.zombie_spawners );
		ai = spawn_zombie( spawner );
	}
	if ( isDefined( ai ) )
	{
		ai forceteleport( self.origin, self.angles );
		ai.start_inert = 1;
	}
}

sparking_power_lines()
{
	lines = getentarray( "power_line_sparking", "targetname" );
}

callback_spectator_respawn_custom_score()
{
	difference = 1500 - self.score;
	money_required = 1;
	if ( difference >= 1000 )
	{
		money_required = 2;
	}
	if ( !sessionmodeisonlinegame() )
	{
		if ( !isDefined( self.account_val ) )
		{
			self.account_val = 0;
		}
		if ( self.account_val >= money_required )
		{
			self.account_val -= money_required;
		}
		else
		{
			self.account_val = 0;
		}
	}
	else account_val = self maps/mp/zombies/_zm_stats::get_map_stat( "depositBox" );
	if ( account_val >= money_required )
	{
		self set_map_stat( "depositBox", account_val - money_required );
	}
	else
	{
		self set_map_stat( "depositBox", 0 );
	}
}

transit_custom_deny_vox( door_buy )
{
	switch( self.characterindex )
	{
		case 0:
			alias = randomintrange( 2, 5 );
			if ( isDefined( door_buy ) && door_buy )
			{
				alias = undefined;
			}
			self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "door_deny", undefined, alias );
			break;
		case 1:
			self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			break;
		case 2:
			self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			break;
		case 3:
			x = randomint( 100 );
			if ( x > 66 )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			}
			else if ( x > 33 )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_box", undefined, 0 );
			}
			else
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon", undefined, 0 );
			}
			break;
	}
}

transit_custom_death_vox()
{
	if ( self.characterindex != 2 )
	{
		return 0;
	}
	self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "pain_high" );
	return 1;
}

transit_custom_powerup_vo_response( powerup_player, powerup )
{
	dist = 250000;
	players = get_players();
	_a746 = players;
	_k746 = getFirstArrayKey( _a746 );
	while ( isDefined( _k746 ) )
	{
		player = _a746[ _k746 ];
		if ( player == powerup_player )
		{
		}
		else if ( distancesquared( player.origin, powerup_player.origin ) < dist )
		{
			player do_player_general_vox( "general", "exert_laugh", 10, 5 );
		}
		_k746 = getNextArrayKey( _a746, _k746 );
	}
}
