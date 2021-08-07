#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_vulture;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/_demo;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( !level.createfx_enabled )
	{
		perks_register_clientfield();
	}
	if ( !level.enable_magic )
	{
		return;
	}
	perk_machine_spawn_init();
	vending_weapon_upgrade_trigger = [];
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	i = 0;
	while ( i < vending_triggers.size )
	{
		if ( isDefined( vending_triggers[ i ].script_noteworthy ) && vending_triggers[ i ].script_noteworthy == "specialty_weapupgrade" )
		{
			vending_weapon_upgrade_trigger[ vending_weapon_upgrade_trigger.size ] = vending_triggers[ i ];
			arrayremovevalue( vending_triggers, vending_triggers[ i ] );
		}
		i++;
	}
	old_packs = getentarray( "zombie_vending_upgrade", "targetname" );
	i = 0;
	while ( i < old_packs.size )
	{
		vending_weapon_upgrade_trigger[ vending_weapon_upgrade_trigger.size ] = old_packs[ i ];
		i++;
	}
	flag_init( "pack_machine_in_use" );
	if ( vending_triggers.size < 1 )
	{
		return;
	}
	if ( vending_weapon_upgrade_trigger.size >= 1 )
	{
		array_thread( vending_weapon_upgrade_trigger, ::vending_weapon_upgrade );
	}
	if ( !isDefined( level.custom_vending_precaching ) )
	{
		level.custom_vending_precaching = ::default_vending_precaching;
	}
	[[ level.custom_vending_precaching ]]();
	if ( !isDefined( level.packapunch_timeout ) )
	{
		level.packapunch_timeout = 15;
	}
	set_zombie_var( "zombie_perk_cost", 2000 );
	set_zombie_var( "zombie_perk_juggernaut_health", 160 );
	set_zombie_var( "zombie_perk_juggernaut_health_upgrade", 190 );
	array_thread( vending_triggers, ::vending_trigger_think );
	array_thread( vending_triggers, ::electric_perks_dialog );
	level thread turn_doubletap_on();
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		level thread turn_marathon_on();
	}
	if ( isDefined( level.zombiemode_using_divetonuke_perk ) && level.zombiemode_using_divetonuke_perk )
	{
		level thread turn_divetonuke_on();
		level.zombiemode_divetonuke_perk_func = ::divetonuke_explode;
		level._effect[ "divetonuke_groundhit" ] = loadfx( "maps/zombie/fx_zmb_phdflopper_exp" );
		set_zombie_var( "zombie_perk_divetonuke_radius", 300 );
		set_zombie_var( "zombie_perk_divetonuke_min_damage", 1000 );
		set_zombie_var( "zombie_perk_divetonuke_max_damage", 5000 );
	}
	level thread turn_jugger_on();
	level thread turn_revive_on();
	level thread turn_sleight_on();
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		level thread turn_deadshot_on();
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		level thread turn_tombstone_on();
	}
	if ( isDefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
	{
		level thread turn_additionalprimaryweapon_on();
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		level thread turn_chugabud_on();
	}
	if ( isDefined( level.zombiemode_using_electric_cherry_perk ) && level.zombiemode_using_electric_cherry_perk )
	{
		level thread turn_electric_cherry_on();
	}
	if ( isDefined( level.zombiemode_using_vulture_perk ) && level.zombiemode_using_vulture_perk )
	{
		level thread turn_vulture_on();
	}
	level thread turn_packapunch_on();
	if ( isDefined( level.quantum_bomb_register_result_func ) )
	{
		[[ level.quantum_bomb_register_result_func ]]( "give_nearest_perk", ::quantum_bomb_give_nearest_perk_result, 10, ::quantum_bomb_give_nearest_perk_validation );
	}
	level thread perk_hostmigration();
}

default_vending_precaching()
{
	if ( isDefined( level.zombiemode_using_pack_a_punch ) && level.zombiemode_using_pack_a_punch )
	{
		precacheitem( "zombie_knuckle_crack" );
		precachemodel( "p6_anim_zm_buildable_pap" );
		precachemodel( "p6_anim_zm_buildable_pap_on" );
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH" );
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH_ATT" );
		level._effect[ "packapunch_fx" ] = loadfx( "maps/zombie/fx_zombie_packapunch" );
	}
	if ( isDefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
	{
		precacheitem( "zombie_perk_bottle_additionalprimaryweapon" );
		precacheshader( "specialty_additionalprimaryweapon_zombies" );
		precachemodel( "zombie_vending_three_gun" );
		precachemodel( "zombie_vending_three_gun_on" );
		precachestring( &"ZOMBIE_PERK_ADDITIONALWEAPONPERK" );
		level._effect[ "additionalprimaryweapon_light" ] = loadfx( "misc/fx_zombie_cola_arsenal_on" );
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		precacheitem( "zombie_perk_bottle_deadshot" );
		precacheshader( "specialty_ads_zombies" );
		precachemodel( "zombie_vending_ads" );
		precachemodel( "zombie_vending_ads_on" );
		precachestring( &"ZOMBIE_PERK_DEADSHOT" );
		level._effect[ "deadshot_light" ] = loadfx( "misc/fx_zombie_cola_dtap_on" );
	}
	if ( isDefined( level.zombiemode_using_divetonuke_perk ) && level.zombiemode_using_divetonuke_perk )
	{
		precacheitem( "zombie_perk_bottle_nuke" );
		precacheshader( "specialty_divetonuke_zombies" );
		precachemodel( "zombie_vending_nuke" );
		precachemodel( "zombie_vending_nuke_on" );
		precachestring( &"ZOMBIE_PERK_DIVETONUKE" );
		level._effect[ "divetonuke_light" ] = loadfx( "misc/fx_zombie_cola_dtap_on" );
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		precacheitem( "zombie_perk_bottle_doubletap" );
		precacheshader( "specialty_doubletap_zombies" );
		precachemodel( "zombie_vending_doubletap2" );
		precachemodel( "zombie_vending_doubletap2_on" );
		precachestring( &"ZOMBIE_PERK_DOUBLETAP" );
		level._effect[ "doubletap_light" ] = loadfx( "misc/fx_zombie_cola_dtap_on" );
	}
	if ( isDefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
	{
		precacheitem( "zombie_perk_bottle_jugg" );
		precacheshader( "specialty_juggernaut_zombies" );
		precachemodel( "zombie_vending_jugg" );
		precachemodel( "zombie_vending_jugg_on" );
		precachestring( &"ZOMBIE_PERK_JUGGERNAUT" );
		level._effect[ "jugger_light" ] = loadfx( "misc/fx_zombie_cola_jugg_on" );
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		precacheitem( "zombie_perk_bottle_marathon" );
		precacheshader( "specialty_marathon_zombies" );
		precachemodel( "zombie_vending_marathon" );
		precachemodel( "zombie_vending_marathon_on" );
		precachestring( &"ZOMBIE_PERK_MARATHON" );
		level._effect[ "marathon_light" ] = loadfx( "maps/zombie/fx_zmb_cola_staminup_on" );
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		precacheitem( "zombie_perk_bottle_revive" );
		precacheshader( "specialty_quickrevive_zombies" );
		precachemodel( "zombie_vending_revive" );
		precachemodel( "zombie_vending_revive_on" );
		precachestring( &"ZOMBIE_PERK_QUICKREVIVE" );
		level._effect[ "revive_light" ] = loadfx( "misc/fx_zombie_cola_revive_on" );
		level._effect[ "revive_light_flicker" ] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		precacheitem( "zombie_perk_bottle_sleight" );
		precacheshader( "specialty_fastreload_zombies" );
		precachemodel( "zombie_vending_sleight" );
		precachemodel( "zombie_vending_sleight_on" );
		precachestring( &"ZOMBIE_PERK_FASTRELOAD" );
		level._effect[ "sleight_light" ] = loadfx( "misc/fx_zombie_cola_on" );
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		precacheitem( "zombie_perk_bottle_tombstone" );
		precacheshader( "specialty_tombstone_zombies" );
		precachemodel( "zombie_vending_tombstone" );
		precachemodel( "zombie_vending_tombstone_on" );
		precachemodel( "ch_tombstone1" );
		precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
		level._effect[ "tombstone_light" ] = loadfx( "misc/fx_zombie_cola_on" );
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		precacheitem( "zombie_perk_bottle_whoswho" );
		precacheshader( "specialty_quickrevive_zombies" );
		precachemodel( "p6_zm_vending_chugabud" );
		precachemodel( "p6_zm_vending_chugabud_on" );
		precachemodel( "ch_tombstone1" );
		precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
		level._effect[ "tombstone_light" ] = loadfx( "misc/fx_zombie_cola_on" );
	}
	if ( isDefined( level.zombiemode_using_electric_cherry_perk ) && level.zombiemode_using_electric_cherry_perk )
	{
		precacheitem( "zombie_perk_bottle_cherry" );
		precacheshader( "specialty_fastreload_zombies" );
		precachemodel( "p6_zm_vending_electric_cherry_off" );
		precachemodel( "p6_zm_vending_electric_cherry_on" );
		precachestring( &"ZOMBIE_PERK_FASTRELOAD" );
		level._effect[ "sleight_light" ] = loadfx( "misc/fx_zombie_cola_on" );
	}
	if ( isDefined( level.zombiemode_using_vulture_perk ) && level.zombiemode_using_vulture_perk )
	{
		precacheitem( "zombie_perk_bottle_vulture" );
		precacheshader( "specialty_vulture_zombies" );
		precachemodel( "zombie_vending_revive" );
		precachemodel( "zombie_vending_revive_on" );
		precachestring( &"ZOMBIE_PERK_VULTURE" );
		level._effect[ "vulture_light" ] = loadfx( "misc/fx_zombie_cola_revive_on" );
		level._effect[ "vulture_light_flicker" ] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
	}
}

pap_weapon_move_in( trigger, origin_offset, angles_offset )
{
	level endon( "Pack_A_Punch_off" );
	trigger endon( "pap_player_disconnected" );
	trigger.worldgun rotateto( self.angles + angles_offset + vectorScale( ( 0, -1, 0 ), 90 ), 0,35, 0, 0 );
	offsetdw = vectorScale( ( 0, -1, 0 ), 3 );
	if ( isDefined( trigger.worldgun.worldgundw ) )
	{
		trigger.worldgun.worldgundw rotateto( self.angles + angles_offset + vectorScale( ( 0, -1, 0 ), 90 ), 0,35, 0, 0 );
	}
	wait 0,5;
	trigger.worldgun moveto( self.origin + origin_offset, 0,5, 0, 0 );
	if ( isDefined( trigger.worldgun.worldgundw ) )
	{
		trigger.worldgun.worldgundw moveto( self.origin + origin_offset + offsetdw, 0,5, 0, 0 );
	}
}

pap_weapon_move_out( trigger, origin_offset, interact_offset )
{
	level endon( "Pack_A_Punch_off" );
	trigger endon( "pap_player_disconnected" );
	offsetdw = vectorScale( ( 0, -1, 0 ), 3 );
	trigger.worldgun moveto( self.origin + interact_offset, 0,5, 0, 0 );
	if ( isDefined( trigger.worldgun.worldgundw ) )
	{
		trigger.worldgun.worldgundw moveto( self.origin + interact_offset + offsetdw, 0,5, 0, 0 );
	}
	wait 0,5;
	trigger.worldgun moveto( self.origin + origin_offset, level.packapunch_timeout, 0, 0 );
	if ( isDefined( trigger.worldgun.worldgundw ) )
	{
		trigger.worldgun.worldgundw moveto( self.origin + origin_offset + offsetdw, level.packapunch_timeout, 0, 0 );
	}
}

fx_ent_failsafe()
{
	wait 25;
	self delete();
}

third_person_weapon_upgrade( current_weapon, upgrade_weapon, packa_rollers, perk_machine, trigger )
{
	level endon( "Pack_A_Punch_off" );
	trigger endon( "pap_player_disconnected" );
	rel_entity = trigger.perk_machine;
	origin_offset = ( 0, -1, 0 );
	angles_offset = ( 0, -1, 0 );
	origin_base = self.origin;
	angles_base = self.angles;
	if ( isDefined( rel_entity ) )
	{
		if ( isDefined( level.pap_interaction_height ) )
		{
			origin_offset = ( 0, 0, level.pap_interaction_height );
		}
		else
		{
			origin_offset = vectorScale( ( 0, -1, 0 ), 35 );
		}
		angles_offset = vectorScale( ( 0, -1, 0 ), 90 );
		origin_base = rel_entity.origin;
		angles_base = rel_entity.angles;
	}
	else
	{
		rel_entity = self;
	}
	forward = anglesToForward( angles_base + angles_offset );
	interact_offset = origin_offset + ( forward * -25 );
	if ( !isDefined( perk_machine.fx_ent ) )
	{
		perk_machine.fx_ent = spawn( "script_model", origin_base + origin_offset + ( 0, 1, -34 ) );
		perk_machine.fx_ent.angles = angles_base + angles_offset;
		perk_machine.fx_ent setmodel( "tag_origin" );
		perk_machine.fx_ent linkto( perk_machine );
	}
	fx = playfxontag( level._effect[ "packapunch_fx" ], perk_machine.fx_ent, "tag_origin" );
	offsetdw = vectorScale( ( 0, -1, 0 ), 3 );
	weoptions = self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( current_weapon );
	trigger.worldgun = spawn_weapon_model( current_weapon, undefined, origin_base + interact_offset, self.angles, weoptions );
	worldgundw = undefined;
	if ( maps/mp/zombies/_zm_magicbox::weapon_is_dual_wield( current_weapon ) )
	{
		worldgundw = spawn_weapon_model( current_weapon, maps/mp/zombies/_zm_magicbox::get_left_hand_weapon_model_name( current_weapon ), origin_base + interact_offset + offsetdw, self.angles, weoptions );
	}
	trigger.worldgun.worldgundw = worldgundw;
	if ( isDefined( level.custom_pap_move_in ) )
	{
		perk_machine [[ level.custom_pap_move_in ]]( trigger, origin_offset, angles_offset, perk_machine );
	}
	else
	{
		perk_machine pap_weapon_move_in( trigger, origin_offset, angles_offset );
	}
	self playsound( "zmb_perks_packa_upgrade" );
	if ( isDefined( perk_machine.wait_flag ) )
	{
		perk_machine.wait_flag rotateto( perk_machine.wait_flag.angles + vectorScale( ( 0, -1, 0 ), 179 ), 0,25, 0, 0 );
	}
	wait 0,35;
	trigger.worldgun delete();
	if ( isDefined( worldgundw ) )
	{
		worldgundw delete();
	}
	wait 3;
	if ( isDefined( self ) )
	{
		self playsound( "zmb_perks_packa_ready" );
	}
	upoptions = self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( upgrade_weapon );
	trigger.current_weapon = current_weapon;
	trigger.upgrade_name = upgrade_weapon;
	trigger.worldgun = spawn_weapon_model( upgrade_weapon, undefined, origin_base + origin_offset, angles_base + angles_offset + vectorScale( ( 0, -1, 0 ), 90 ), upoptions );
	worldgundw = undefined;
	if ( maps/mp/zombies/_zm_magicbox::weapon_is_dual_wield( upgrade_weapon ) )
	{
		worldgundw = spawn_weapon_model( upgrade_weapon, maps/mp/zombies/_zm_magicbox::get_left_hand_weapon_model_name( upgrade_weapon ), origin_base + origin_offset + offsetdw, angles_base + angles_offset + vectorScale( ( 0, -1, 0 ), 90 ), upoptions );
	}
	trigger.worldgun.worldgundw = worldgundw;
	if ( isDefined( perk_machine.wait_flag ) )
	{
		perk_machine.wait_flag rotateto( perk_machine.wait_flag.angles - vectorScale( ( 0, -1, 0 ), 179 ), 0,25, 0, 0 );
	}
	if ( isDefined( level.custom_pap_move_out ) )
	{
		rel_entity thread [[ level.custom_pap_move_out ]]( trigger, origin_offset, interact_offset );
	}
	else
	{
		rel_entity thread pap_weapon_move_out( trigger, origin_offset, interact_offset );
	}
	return trigger.worldgun;
}

vending_machine_trigger_think()
{
	self endon( "death" );
	level endon( "Pack_A_Punch_off" );
	if ( !maps/mp/zombies/_zm_equipment::is_equipment_included( "equip_hacker_zm" ) )
	{
		return;
	}
	while ( 1 )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] hacker_active() || players[ i ] getcurrentweapon() == "riotshield_zm" )
			{
				self setinvisibletoplayer( players[ i ], 1 );
				i++;
				continue;
			}
			else
			{
				self setinvisibletoplayer( players[ i ], 0 );
			}
			i++;
		}
		wait 0,1;
	}
}

vending_weapon_upgrade()
{
	level endon( "Pack_A_Punch_off" );
	wait 0,01;
	perk_machine = getent( self.target, "targetname" );
	self.perk_machine = perk_machine;
	perk_machine_sound = getentarray( "perksacola", "targetname" );
	packa_rollers = spawn( "script_origin", self.origin );
	packa_timer = spawn( "script_origin", self.origin );
	packa_rollers linkto( self );
	packa_timer linkto( self );
	if ( isDefined( perk_machine.target ) )
	{
		perk_machine.wait_flag = getent( perk_machine.target, "targetname" );
	}
	pap_is_buildable = self is_buildable();
	if ( pap_is_buildable )
	{
		self trigger_off();
		perk_machine hide();
		if ( isDefined( perk_machine.wait_flag ) )
		{
			perk_machine.wait_flag hide();
		}
		wait_for_buildable( "pap" );
		self trigger_on();
		perk_machine show();
		if ( isDefined( perk_machine.wait_flag ) )
		{
			perk_machine.wait_flag show();
		}
	}
	self usetriggerrequirelookat();
	self sethintstring( &"ZOMBIE_NEED_POWER" );
	self setcursorhint( "HINT_NOICON" );
	power_off = !self maps/mp/zombies/_zm_power::pap_is_on();
	if ( power_off )
	{
		level waittill( "Pack_A_Punch_on" );
	}
	self enable_trigger();
	self thread vending_machine_trigger_think();
	self thread maps/mp/zombies/_zm_magicbox::decide_hide_show_hint( "Pack_A_Punch_off" );
	perk_machine playloopsound( "zmb_perks_packa_loop" );
	self thread shutoffpapsounds( perk_machine, packa_rollers, packa_timer );
	self thread vending_weapon_upgrade_cost();
	for ( ;; )
	{
		self waittill( "trigger", player );
		index = maps/mp/zombies/_zm_weapons::get_player_index( player );
		current_weapon = player getcurrentweapon();
		if ( current_weapon == "microwavegun_zm" )
		{
			current_weapon = "microwavegundw_zm";
		}
		current_weapon = player maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( current_weapon );
		if ( player maps/mp/zombies/_zm_magicbox::can_buy_weapon() && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && isDefined( player.intermission ) && !player.intermission || player isthrowinggrenade() && !player maps/mp/zombies/_zm_weapons::can_upgrade_weapon( current_weapon ) )
		{
			wait 0,1;
			continue;
		}
		else
		{
			if ( isDefined( level.pap_moving ) && level.pap_moving )
			{
				break;
			}
			else
			{
				if ( player isswitchingweapons() )
				{
					wait 0,1;
					if ( player isswitchingweapons() )
					{
						break;
					}
				}
				else if ( !maps/mp/zombies/_zm_weapons::is_weapon_or_base_included( current_weapon ) )
				{
					break;
				}
				else current_cost = self.cost;
				player.restore_ammo = undefined;
				player.restore_clip = undefined;
				player.restore_stock = undefined;
				player_restore_clip_size = undefined;
				player.restore_max = undefined;
				upgrade_as_attachment = will_upgrade_weapon_as_attachment( current_weapon );
				if ( upgrade_as_attachment )
				{
					current_cost = self.attachment_cost;
					player.restore_ammo = 1;
					player.restore_clip = player getweaponammoclip( current_weapon );
					player.restore_clip_size = weaponclipsize( current_weapon );
					player.restore_stock = player getweaponammostock( current_weapon );
					player.restore_max = weaponmaxammo( current_weapon );
				}
				if ( player.score < current_cost )
				{
					self playsound( "deny" );
					if ( isDefined( level.custom_pap_deny_vo_func ) )
					{
						player [[ level.custom_pap_deny_vo_func ]]();
					}
					else
					{
						player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
					}
					break;
				}
				else
				{
					flag_set( "pack_machine_in_use" );
					maps/mp/_demo::bookmark( "zm_player_use_packapunch", getTime(), player );
					player maps/mp/zombies/_zm_stats::increment_client_stat( "use_pap" );
					player maps/mp/zombies/_zm_stats::increment_player_stat( "use_pap" );
					self thread destroy_weapon_in_blackout( player );
					self thread destroy_weapon_on_disconnect( player );
					player maps/mp/zombies/_zm_score::minus_to_player_score( current_cost );
					sound = "evt_bottle_dispense";
					playsoundatposition( sound, self.origin );
					self thread maps/mp/zombies/_zm_audio::play_jingle_or_stinger( "mus_perks_packa_sting" );
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "weapon_pickup", "upgrade_wait" );
					self disable_trigger();
					if ( isDefined( upgrade_as_attachment ) && !upgrade_as_attachment )
					{
						player thread do_player_general_vox( "general", "pap_wait", 10, 100 );
					}
					else
					{
						player thread do_player_general_vox( "general", "pap_wait2", 10, 100 );
					}
					player thread do_knuckle_crack();
					self.current_weapon = current_weapon;
					upgrade_name = maps/mp/zombies/_zm_weapons::get_upgrade_weapon( current_weapon, upgrade_as_attachment );
					player third_person_weapon_upgrade( current_weapon, upgrade_name, packa_rollers, perk_machine, self );
					self enable_trigger();
					self sethintstring( &"ZOMBIE_GET_UPGRADED" );
					if ( isDefined( player ) )
					{
						self setvisibletoplayer( player );
						self thread wait_for_player_to_take( player, current_weapon, packa_timer, upgrade_as_attachment );
					}
					self thread wait_for_timeout( current_weapon, packa_timer, player );
					self waittill_any( "pap_timeout", "pap_taken", "pap_player_disconnected" );
					self.current_weapon = "";
					if ( isDefined( self.worldgun ) && isDefined( self.worldgun.worldgundw ) )
					{
						self.worldgun.worldgundw delete();
					}
					if ( isDefined( self.worldgun ) )
					{
						self.worldgun delete();
					}
					if ( isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch )
					{
						self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH_ATT", self.cost );
					}
					else
					{
						self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH", self.cost );
					}
					self setvisibletoall();
					flag_clear( "pack_machine_in_use" );
				}
			}
		}
	}
}

shutoffpapsounds( ent1, ent2, ent3 )
{
	while ( 1 )
	{
		level waittill( "Pack_A_Punch_off" );
		level thread turnonpapsounds( ent1 );
		ent1 stoploopsound( 0,1 );
		ent2 stoploopsound( 0,1 );
		ent3 stoploopsound( 0,1 );
	}
}

turnonpapsounds( ent )
{
	level waittill( "Pack_A_Punch_on" );
	ent playloopsound( "zmb_perks_packa_loop" );
}

vending_weapon_upgrade_cost()
{
	level endon( "Pack_A_Punch_off" );
	while ( 1 )
	{
		self.cost = 5000;
		self.attachment_cost = 2000;
		if ( isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch )
		{
			self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH_ATT", self.cost );
		}
		else
		{
			self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH", self.cost );
		}
		level waittill( "powerup bonfire sale" );
		self.cost = 1000;
		self.attachment_cost = 1000;
		if ( isDefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch )
		{
			self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH_ATT", self.cost );
		}
		else
		{
			self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH", self.cost );
		}
		level waittill( "bonfire_sale_off" );
	}
}

wait_for_player_to_take( player, weapon, packa_timer, upgrade_as_attachment )
{
	current_weapon = self.current_weapon;
	upgrade_name = self.upgrade_name;
/#
	assert( isDefined( current_weapon ), "wait_for_player_to_take: weapon does not exist" );
#/
/#
	assert( isDefined( upgrade_name ), "wait_for_player_to_take: upgrade_weapon does not exist" );
#/
	upgrade_weapon = upgrade_name;
	self endon( "pap_timeout" );
	level endon( "Pack_A_Punch_off" );
	while ( 1 )
	{
		packa_timer playloopsound( "zmb_perks_packa_ticktock" );
		self waittill( "trigger", trigger_player );
		if ( isDefined( level.pap_grab_by_anyone ) && level.pap_grab_by_anyone )
		{
			player = trigger_player;
		}
		packa_timer stoploopsound( 0,05 );
		if ( trigger_player == player )
		{
			player maps/mp/zombies/_zm_stats::increment_client_stat( "pap_weapon_grabbed" );
			player maps/mp/zombies/_zm_stats::increment_player_stat( "pap_weapon_grabbed" );
			current_weapon = player getcurrentweapon();
/#
			if ( current_weapon == "none" )
			{
				iprintlnbold( "WEAPON IS NONE, PACKAPUNCH RETRIEVAL DENIED" );
#/
			}
			if ( is_player_valid( player ) && player.is_drinking > 0 && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && level.revive_tool != current_weapon && current_weapon != "none" && !player hacker_active() )
			{
				maps/mp/_demo::bookmark( "zm_player_grabbed_packapunch", getTime(), player );
				self notify( "pap_taken" );
				player notify( "pap_taken" );
				player.pap_used = 1;
				if ( isDefined( upgrade_as_attachment ) && !upgrade_as_attachment )
				{
					player thread do_player_general_vox( "general", "pap_arm", 15, 100 );
				}
				else
				{
					player thread do_player_general_vox( "general", "pap_arm2", 15, 100 );
				}
				weapon_limit = 2;
				if ( player hasperk( "specialty_additionalprimaryweapon" ) )
				{
					weapon_limit = 3;
				}
				player maps/mp/zombies/_zm_weapons::take_fallback_weapon();
				primaries = player getweaponslistprimaries();
				if ( isDefined( primaries ) && primaries.size >= weapon_limit )
				{
					player maps/mp/zombies/_zm_weapons::weapon_give( upgrade_weapon );
				}
				else
				{
					player giveweapon( upgrade_weapon, 0, player maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ) );
					player givestartammo( upgrade_weapon );
				}
				player switchtoweapon( upgrade_weapon );
				if ( isDefined( player.restore_ammo ) && player.restore_ammo )
				{
					new_clip = player.restore_clip + ( weaponclipsize( upgrade_weapon ) - player.restore_clip_size );
					new_stock = player.restore_stock + ( weaponmaxammo( upgrade_weapon ) - player.restore_max );
					player setweaponammostock( upgrade_weapon, new_stock );
					player setweaponammoclip( upgrade_weapon, new_clip );
				}
				player.restore_ammo = undefined;
				player.restore_clip = undefined;
				player.restore_stock = undefined;
				player.restore_max = undefined;
				player.restore_clip_size = undefined;
				player maps/mp/zombies/_zm_weapons::play_weapon_vo( upgrade_weapon );
				return;
			}
		}
		wait 0,05;
	}
}

wait_for_timeout( weapon, packa_timer, player )
{
	self endon( "pap_taken" );
	self endon( "pap_player_disconnected" );
	self thread wait_for_disconnect( player );
	wait level.packapunch_timeout;
	self notify( "pap_timeout" );
	packa_timer stoploopsound( 0,05 );
	packa_timer playsound( "zmb_perks_packa_deny" );
	maps/mp/zombies/_zm_weapons::unacquire_weapon_toggle( weapon );
	if ( isDefined( player ) )
	{
		player maps/mp/zombies/_zm_stats::increment_client_stat( "pap_weapon_not_grabbed" );
		player maps/mp/zombies/_zm_stats::increment_player_stat( "pap_weapon_not_grabbed" );
	}
}

wait_for_disconnect( player )
{
	self endon( "pap_taken" );
	self endon( "pap_timeout" );
	while ( isDefined( player ) )
	{
		wait 0,1;
	}
/#
	println( "*** PAP : User disconnected." );
#/
	self notify( "pap_player_disconnected" );
}

destroy_weapon_on_disconnect( player )
{
	self endon( "pap_timeout" );
	self endon( "pap_taken" );
	level endon( "Pack_A_Punch_off" );
	player waittill( "disconnect" );
	if ( isDefined( self.worldgun ) )
	{
		if ( isDefined( self.worldgun.worldgundw ) )
		{
			self.worldgun.worldgundw delete();
		}
		self.worldgun delete();
	}
}

destroy_weapon_in_blackout( player )
{
	self endon( "pap_timeout" );
	self endon( "pap_taken" );
	self endon( "pap_player_disconnected" );
	level waittill( "Pack_A_Punch_off" );
	if ( isDefined( self.worldgun ) )
	{
		self.worldgun rotateto( self.worldgun.angles + ( randomint( 90 ) - 45, 0, randomint( 360 ) - 180 ), 1,5, 0, 0 );
		player playlocalsound( level.zmb_laugh_alias );
		wait 1,5;
		if ( isDefined( self.worldgun.worldgundw ) )
		{
			self.worldgun.worldgundw delete();
		}
		self.worldgun delete();
	}
}

do_knuckle_crack()
{
	gun = self upgrade_knuckle_crack_begin();
	self waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );
	self upgrade_knuckle_crack_end( gun );
}

upgrade_knuckle_crack_begin()
{
	self increment_is_drinking();
	self disable_player_move_states( 1 );
	primaries = self getweaponslistprimaries();
	gun = self getcurrentweapon();
	weapon = "zombie_knuckle_crack";
	if ( gun != "none" && !is_placeable_mine( gun ) && !is_equipment( gun ) )
	{
		self notify( "zmb_lost_knife" );
		self takeweapon( gun );
	}
	else
	{
		return;
	}
	self giveweapon( weapon );
	self switchtoweapon( weapon );
	return gun;
}

upgrade_knuckle_crack_end( gun )
{
/#
	assert( !is_zombie_perk_bottle( gun ) );
#/
/#
	assert( gun != level.revive_tool );
#/
	self enable_player_move_states();
	weapon = "zombie_knuckle_crack";
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined( self.intermission ) && self.intermission )
	{
		self takeweapon( weapon );
		return;
	}
	self decrement_is_drinking();
	self takeweapon( weapon );
	primaries = self getweaponslistprimaries();
	if ( self.is_drinking > 0 )
	{
		return;
	}
	else if ( isDefined( primaries ) && primaries.size > 0 )
	{
		self switchtoweapon( primaries[ 0 ] );
	}
	else
	{
		if ( self hasweapon( level.laststandpistol ) )
		{
			self switchtoweapon( level.laststandpistol );
			return;
		}
		else
		{
			self maps/mp/zombies/_zm_weapons::give_fallback_weapon();
		}
	}
}

turn_packapunch_on()
{
	vending_weapon_upgrade_trigger = getentarray( "specialty_weapupgrade", "script_noteworthy" );
	i = 0;
	while ( i < vending_weapon_upgrade_trigger.size )
	{
		perk = getent( vending_weapon_upgrade_trigger[ i ].target, "targetname" );
		if ( isDefined( perk ) )
		{
			perk setmodel( "p6_anim_zm_buildable_pap" );
		}
		i++;
	}
	for ( ;; )
	{
		level waittill( "Pack_A_Punch_on" );
		i = 0;
		while ( i < vending_weapon_upgrade_trigger.size )
		{
			perk = getent( vending_weapon_upgrade_trigger[ i ].target, "targetname" );
			if ( isDefined( perk ) )
			{
				perk thread activate_packapunch();
			}
			i++;
		}
		level waittill( "Pack_A_Punch_off" );
		i = 0;
		while ( i < vending_weapon_upgrade_trigger.size )
		{
			perk = getent( vending_weapon_upgrade_trigger[ i ].target, "targetname" );
			if ( isDefined( perk ) )
			{
				perk thread deactivate_packapunch();
			}
			i++;
		}
	}
}

activate_packapunch()
{
	self setmodel( "p6_anim_zm_buildable_pap_on" );
	self playsound( "zmb_perks_power_on" );
	self vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
	timer = 0;
	duration = 0,05;
}

deactivate_packapunch()
{
	self setmodel( "p6_anim_zm_buildable_pap" );
}

turn_sleight_on()
{
	while ( 1 )
	{
		machine = getentarray( "vending_sleight", "targetname" );
		machine_triggers = getentarray( "vending_sleight", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_sleight" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "sleight_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_sleight_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "sleight_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 1 );
		level notify( "specialty_fastreload_power_on" );
		level waittill( "sleight_off" );
		array_thread( machine, ::turn_perk_off );
	}
}

use_solo_revive()
{
	if ( isDefined( level.using_solo_revive ) )
	{
		return level.using_solo_revive;
	}
	players = get_players();
	solo_mode = 0;
	if ( players.size == 1 || isDefined( level.force_solo_quick_revive ) && level.force_solo_quick_revive )
	{
		solo_mode = 1;
	}
	level.using_solo_revive = solo_mode;
	return solo_mode;
}

turn_revive_on()
{
	level endon( "stop_quickrevive_logic" );
	machine = getentarray( "vending_revive", "targetname" );
	machine_triggers = getentarray( "vending_revive", "target" );
	machine_model = undefined;
	machine_clip = undefined;
	flag_wait( "start_zombie_round_logic" );
	players = get_players();
	solo_mode = 0;
	if ( use_solo_revive() )
	{
		solo_mode = 1;
	}
	start_state = 0;
	start_state = solo_mode;
	while ( 1 )
	{
		machine = getentarray( "vending_revive", "targetname" );
		machine_triggers = getentarray( "vending_revive", "target" );
		i = 0;
		while ( i < machine.size )
		{
			if ( flag_exists( "solo_game" ) && flag_exists( "solo_revive" ) && flag( "solo_game" ) && flag( "solo_revive" ) )
			{
				machine[ i ] hide();
			}
			machine[ i ] setmodel( "zombie_vending_revive" );
			if ( isDefined( level.quick_revive_final_pos ) )
			{
				level.quick_revive_default_origin = level.quick_revive_final_pos;
			}
			if ( !isDefined( level.quick_revive_default_origin ) )
			{
				level.quick_revive_default_origin = machine[ i ].origin;
				level.quick_revive_default_angles = machine[ i ].angles;
			}
			level.quick_revive_machine = machine[ i ];
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		if ( isDefined( start_state ) && !start_state )
		{
			level waittill( "revive_on" );
		}
		start_state = 0;
		i = 0;
		while ( i < machine.size )
		{
			if ( isDefined( machine[ i ].classname ) && machine[ i ].classname == "script_model" )
			{
				if ( isDefined( machine[ i ].script_noteworthy ) && machine[ i ].script_noteworthy == "clip" )
				{
					machine_clip = machine[ i ];
					i++;
					continue;
				}
				else
				{
					machine[ i ] setmodel( "zombie_vending_revive_on" );
					machine[ i ] playsound( "zmb_perks_power_on" );
					machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
					machine_model = machine[ i ];
					machine[ i ] thread perk_fx( "revive_light" );
					machine[ i ] notify( "stop_loopsound" );
					machine[ i ] thread play_loop_on_machine();
					if ( isDefined( machine_triggers[ i ] ) )
					{
						machine_clip = machine_triggers[ i ].clip;
					}
					if ( isDefined( machine_triggers[ i ] ) )
					{
						blocker_model = machine_triggers[ i ].blocker_model;
					}
				}
			}
			i++;
		}
		wait_network_frame();
		if ( solo_mode && isDefined( machine_model ) && !is_true( machine_model.ishidden ) )
		{
			machine_model thread revive_solo_fx( machine_clip, blocker_model );
		}
		array_thread( machine_triggers, ::set_power_on, 1 );
		level notify( "specialty_quickrevive_power_on" );
		if ( isDefined( machine_model ) )
		{
			machine_model.ishidden = 0;
		}
		notify_str = level waittill_any_return( "revive_off", "revive_hide" );
		should_hide = 0;
		if ( notify_str == "revive_hide" )
		{
			should_hide = 1;
		}
		i = 0;
		while ( i < machine.size )
		{
			if ( isDefined( machine[ i ].classname ) && machine[ i ].classname == "script_model" )
			{
				machine[ i ] turn_perk_off( should_hide );
			}
			i++;
		}
	}
}

revive_solo_fx( machine_clip, blocker_model )
{
	if ( level flag_exists( "solo_revive" ) && flag( "solo_revive" ) && !flag( "solo_game" ) )
	{
		return;
	}
	if ( isDefined( machine_clip ) )
	{
		level.quick_revive_machine_clip = machine_clip;
	}
	if ( !isDefined( level.solo_revive_init ) )
	{
		level.solo_revive_init = 1;
		flag_init( "solo_revive" );
	}
	level notify( "revive_solo_fx" );
	level endon( "revive_solo_fx" );
	self endon( "death" );
	flag_wait( "solo_revive" );
	if ( isDefined( level.revive_solo_fx_func ) )
	{
		level thread [[ level.revive_solo_fx_func ]]();
	}
	wait 2;
	self playsound( "zmb_box_move" );
	playsoundatposition( "zmb_whoosh", self.origin );
	if ( isDefined( self._linked_ent ) )
	{
		self unlink();
	}
	self moveto( self.origin + vectorScale( ( 0, -1, 0 ), 40 ), 3 );
	if ( isDefined( level.custom_vibrate_func ) )
	{
		[[ level.custom_vibrate_func ]]( self );
	}
	else
	{
		direction = self.origin;
		direction = ( direction[ 1 ], direction[ 0 ], 0 );
		if ( direction[ 1 ] < 0 || direction[ 0 ] > 0 && direction[ 1 ] > 0 )
		{
			direction = ( direction[ 0 ], direction[ 1 ] * -1, 0 );
		}
		else
		{
			if ( direction[ 0 ] < 0 )
			{
				direction = ( direction[ 0 ] * -1, direction[ 1 ], 0 );
			}
		}
		self vibrate( direction, 10, 0,5, 5 );
	}
	self waittill( "movedone" );
	playfx( level._effect[ "poltergeist" ], self.origin );
	playsoundatposition( "zmb_box_poof", self.origin );
	level clientnotify( "drb" );
	if ( isDefined( self.fx ) )
	{
		self.fx unlink();
		self.fx delete();
	}
	if ( isDefined( machine_clip ) )
	{
		machine_clip trigger_off();
		machine_clip connectpaths();
	}
	if ( isDefined( blocker_model ) )
	{
		blocker_model show();
	}
	level notify( "revive_hide" );
}

turn_jugger_on()
{
	while ( 1 )
	{
		machine = getentarray( "vending_jugg", "targetname" );
		machine_triggers = getentarray( "vending_jugg", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_jugg" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "juggernog_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_jugg_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "jugger_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_armorvest_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "juggernog_off" );
		array_thread( machine, ::turn_perk_off );
	}
}

turn_doubletap_on()
{
	while ( 1 )
	{
		machine = getentarray( "vending_doubletap", "targetname" );
		machine_triggers = getentarray( "vending_doubletap", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_doubletap2" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "doubletap_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_doubletap2_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "doubletap_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_rof_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "doubletap_off" );
		array_thread( machine, ::turn_perk_off );
	}
}

turn_marathon_on()
{
	while ( 1 )
	{
		machine = getentarray( "vending_marathon", "targetname" );
		machine_triggers = getentarray( "vending_marathon", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_marathon" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "marathon_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_marathon_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "marathon_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_longersprint_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "marathon_off" );
		array_thread( machine, ::turn_perk_off );
	}
}

turn_divetonuke_on()
{
	while ( 1 )
	{
		machine = getentarray( "vending_divetonuke", "targetname" );
		machine_triggers = getentarray( "vending_divetonuke", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_nuke" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "divetonuke_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_nuke_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "divetonuke_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_flakjacket_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "divetonuke_off" );
		array_thread( machine, ::turn_perk_off );
	}
}

divetonuke_explode( attacker, origin )
{
	radius = level.zombie_vars[ "zombie_perk_divetonuke_radius" ];
	min_damage = level.zombie_vars[ "zombie_perk_divetonuke_min_damage" ];
	max_damage = level.zombie_vars[ "zombie_perk_divetonuke_max_damage" ];
	radiusdamage( origin, radius, max_damage, min_damage, attacker, "MOD_GRENADE_SPLASH" );
	playfx( level._effect[ "divetonuke_groundhit" ], origin );
	attacker playsound( "zmb_phdflop_explo" );
	attacker setclientfieldtoplayer( "dive2nuke_visionset", 1 );
	wait_network_frame();
	wait_network_frame();
	attacker setclientfieldtoplayer( "dive2nuke_visionset", 0 );
}

turn_deadshot_on()
{
	while ( 1 )
	{
		machine = getentarray( "vending_deadshot", "targetname" );
		machine_triggers = getentarray( "vending_deadshot", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_ads" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "deadshot_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_ads_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "deadshot_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_deadshot_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "deadshot_off" );
		array_thread( machine, ::turn_perk_off );
	}
}

turn_tombstone_on()
{
	level endon( "tombstone_removed" );
	while ( 1 )
	{
		machine = getentarray( "vending_tombstone", "targetname" );
		machine_triggers = getentarray( "vending_tombstone", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_tombstone" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "tombstone_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_tombstone_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "tombstone_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_scavenger_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "tombstone_off" );
		array_thread( machine, ::turn_perk_off );
		players = get_players();
		_a1593 = players;
		_k1593 = getFirstArrayKey( _a1593 );
		while ( isDefined( _k1593 ) )
		{
			player = _a1593[ _k1593 ];
			player.hasperkspecialtytombstone = undefined;
			_k1593 = getNextArrayKey( _a1593, _k1593 );
		}
	}
}

turn_additionalprimaryweapon_on()
{
	while ( 1 )
	{
		machine = getentarray( "vending_additionalprimaryweapon", "targetname" );
		machine_triggers = getentarray( "vending_additionalprimaryweapon", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_three_gun" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		if ( level.script != "zombie_cod5_prototype" && level.script != "zombie_cod5_sumpf" )
		{
			flag_wait( "power_on" );
		}
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_three_gun_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "additionalprimaryweapon_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_additionalprimaryweapon_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "additionalprimaryweapon_off" );
		array_thread( machine, ::turn_perk_off );
	}
}

turn_chugabud_on()
{
	maps/mp/zombies/_zm_chugabud::init();
	if ( isDefined( level.vsmgr_prio_visionset_zm_whos_who ) )
	{
		maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_whos_who", 5000, level.vsmgr_prio_visionset_zm_whos_who, 1, 1 );
	}
	while ( 1 )
	{
		machine = getentarray( "vending_chugabud", "targetname" );
		machine_triggers = getentarray( "vending_chugabud", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "p6_zm_vending_chugabud" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "chugabud_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "p6_zm_vending_chugabud_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "tombstone_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_finalstand_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "chugabud_off" );
		array_thread( machine, ::turn_perk_off );
		players = get_players();
		_a1679 = players;
		_k1679 = getFirstArrayKey( _a1679 );
		while ( isDefined( _k1679 ) )
		{
			player = _a1679[ _k1679 ];
			player.hasperkspecialtychugabud = undefined;
			_k1679 = getNextArrayKey( _a1679, _k1679 );
		}
	}
}

turn_electric_cherry_on()
{
	maps/mp/zombies/_zm_electric_cherry::init();
	if ( isDefined( level.vsmgr_prio_visionset_zm_electric_cherry ) )
	{
		maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_electric_cherry", 5000, level.vsmgr_prio_visionset_zm_electric_cherry, 1, 1 );
	}
	while ( 1 )
	{
		machine = getentarray( "vending_electriccherry", "targetname" );
		machine_triggers = getentarray( "vending_electriccherry", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "p6_zm_vending_electric_cherry_off" );
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "electric_cherry_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "p6_zm_vending_electric_cherry_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "jugger_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_grenadepulldeath_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "electric_cherry_off" );
		array_thread( machine, ::turn_perk_off );
	}
}

turn_sixth_sense_on()
{
}

turn_oneinch_punch_on()
{
}

turn_vulture_on()
{
	maps/mp/zombies/_zm_vulture::init_vulture();
	while ( 1 )
	{
		machine = getentarray( "vending_vulture", "targetname" );
		machine_triggers = getentarray( "vending_vulture", "target" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_revive" );
			i++;
		}
		level waittill( "vulture_on" );
		level notify( "specialty_nomotionsensor" + "_power_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( "zombie_vending_revive_on" );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "vulture_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		array_thread( machine_triggers, ::set_power_on, 1 );
		level waittill( "vulture_off" );
		array_thread( machine, ::turn_perk_off );
	}
}

set_power_on( state )
{
	self.power_on = state;
}

turn_perk_off( ishidden )
{
	self notify( "stop_loopsound" );
	newmachine = spawn( "script_model", self.origin );
	newmachine.angles = self.angles;
	newmachine.targetname = self.targetname;
	if ( is_true( ishidden ) )
	{
		newmachine.ishidden = 1;
		newmachine hide();
	}
	self delete();
}

play_loop_on_machine()
{
	sound_ent = spawn( "script_origin", self.origin );
	sound_ent playloopsound( "zmb_perks_machine_loop" );
	sound_ent linkto( self );
	self waittill( "stop_loopsound" );
	sound_ent unlink();
	sound_ent delete();
}

perk_fx( fx, turnofffx )
{
	if ( isDefined( turnofffx ) )
	{
		self.perk_fx = 0;
	}
	else
	{
		wait 3;
		if ( isDefined( self ) && !is_true( self.perk_fx ) )
		{
			playfxontag( level._effect[ fx ], self, "tag_origin" );
			self.perk_fx = 1;
		}
	}
}

electric_perks_dialog()
{
	self endon( "death" );
	wait 0,01;
	flag_wait( "start_zombie_round_logic" );
	players = get_players();
	if ( players.size == 1 )
	{
		return;
	}
	self endon( "warning_dialog" );
	level endon( "switch_flipped" );
	timer = 0;
	while ( 1 )
	{
		wait 0,5;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( !isDefined( players[ i ] ) )
			{
				i++;
				continue;
			}
			else dist = distancesquared( players[ i ].origin, self.origin );
			if ( dist > 4900 )
			{
				timer = 0;
				i++;
				continue;
			}
			else if ( dist < 4900 && timer < 3 )
			{
				wait 0,5;
				timer++;
			}
			if ( dist < 4900 && timer == 3 )
			{
				if ( !isDefined( players[ i ] ) )
				{
					i++;
					continue;
				}
				else
				{
					players[ i ] thread do_player_vo( "vox_start", 5 );
					wait 3;
					self notify( "warning_dialog" );
/#
					iprintlnbold( "warning_given" );
#/
				}
			}
			i++;
		}
	}
}

vending_trigger_think()
{
	self endon( "death" );
	wait 0,01;
	perk = self.script_noteworthy;
	solo = 0;
	start_on = 0;
	level.revive_machine_is_solo = 0;
	if ( isDefined( perk ) || perk == "specialty_quickrevive" && perk == "specialty_quickrevive_upgrade" )
	{
		flag_wait( "start_zombie_round_logic" );
		solo = use_solo_revive();
		self endon( "stop_quickrevive_logic" );
		level.quick_revive_trigger = self;
		if ( solo )
		{
			if ( !is_true( level.revive_machine_is_solo ) )
			{
				start_on = 1;
				players = get_players();
				_a1994 = players;
				_k1994 = getFirstArrayKey( _a1994 );
				while ( isDefined( _k1994 ) )
				{
					player = _a1994[ _k1994 ];
					if ( !isDefined( player.lives ) )
					{
						player.lives = 0;
					}
					_k1994 = getNextArrayKey( _a1994, _k1994 );
				}
				level maps/mp/zombies/_zm::zombiemode_solo_last_stand_pistol();
			}
			level.revive_machine_is_solo = 1;
		}
	}
	self sethintstring( &"ZOMBIE_NEED_POWER" );
	self setcursorhint( "HINT_NOICON" );
	self usetriggerrequirelookat();
	cost = level.zombie_vars[ "zombie_perk_cost" ];
	switch( perk )
	{
		case "specialty_armorvest":
		case "specialty_armorvest_upgrade":
			cost = 2500;
			break;
		case "specialty_quickrevive":
		case "specialty_quickrevive_upgrade":
			if ( solo )
			{
				cost = 500;
			}
			else
			{
				cost = 1500;
			}
			break;
		case "specialty_fastreload":
		case "specialty_fastreload_upgrade":
			cost = 3000;
			break;
		case "specialty_rof":
		case "specialty_rof_upgrade":
			cost = 2000;
			break;
		case "specialty_longersprint":
		case "specialty_longersprint_upgrade":
			cost = 2000;
			break;
		case "specialty_flakjacket":
		case "specialty_flakjacket_upgrade":
			cost = 2000;
			break;
		case "specialty_deadshot":
		case "specialty_deadshot_upgrade":
			cost = 1500;
			break;
		case "specialty_additionalprimaryweapon":
		case "specialty_additionalprimaryweapon_upgrade":
			cost = 4000;
			break;
		case "specialty_grenadepulldeath":
		case "specialty_grenadepulldeath_upgrade":
			cost = 2000;
			break;
		case "specialty_nomotionsensor":
			cost = 2000;
			break;
	}
	self.cost = cost;
	if ( !start_on )
	{
		notify_name = perk + "_power_on";
		level waittill( notify_name );
	}
	start_on = 0;
	if ( !isDefined( level._perkmachinenetworkchoke ) )
	{
		level._perkmachinenetworkchoke = 0;
	}
	else
	{
		level._perkmachinenetworkchoke++;
	}
	i = 0;
	while ( i < level._perkmachinenetworkchoke )
	{
		wait_network_frame();
		i++;
	}
	self thread maps/mp/zombies/_zm_audio::perks_a_cola_jingle_timer();
	self thread check_player_has_perk( perk );
	switch( perk )
	{
		case "specialty_armorvest":
		case "specialty_armorvest_upgrade":
			self sethintstring( &"ZOMBIE_PERK_JUGGERNAUT", cost );
			break;
		case "specialty_quickrevive":
		case "specialty_quickrevive_upgrade":
			if ( solo )
			{
				self sethintstring( &"ZOMBIE_PERK_QUICKREVIVE_SOLO", cost );
			}
			else
			{
				self sethintstring( &"ZOMBIE_PERK_QUICKREVIVE", cost );
			}
			break;
		case "specialty_fastreload":
		case "specialty_fastreload_upgrade":
			self sethintstring( &"ZOMBIE_PERK_FASTRELOAD", cost );
			break;
		case "specialty_rof":
		case "specialty_rof_upgrade":
			self sethintstring( &"ZOMBIE_PERK_DOUBLETAP", cost );
			break;
		case "specialty_longersprint":
		case "specialty_longersprint_upgrade":
			self sethintstring( &"ZOMBIE_PERK_MARATHON", cost );
			break;
		case "specialty_flakjacket":
		case "specialty_flakjacket_upgrade":
			self sethintstring( &"ZOMBIE_PERK_DIVETONUKE", cost );
			break;
		case "specialty_deadshot":
		case "specialty_deadshot_upgrade":
			self sethintstring( &"ZOMBIE_PERK_DEADSHOT", cost );
			break;
		case "specialty_additionalprimaryweapon":
		case "specialty_additionalprimaryweapon_upgrade":
			self sethintstring( &"ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", cost );
			break;
		case "specialty_scavenger":
		case "specialty_scavenger_upgrade":
			self sethintstring( &"ZOMBIE_PERK_TOMBSTONE", cost );
			break;
		case "specialty_finalstand":
		case "specialty_finalstand_upgrade":
			self sethintstring( &"ZOMBIE_PERK_CHUGABUD", cost );
			break;
		case "specialty_grenadepulldeath":
		case "specialty_grenadepulldeath_upgrade":
			self sethintstring( &"ZOMBIE_PERK_FASTRELOAD", cost );
			break;
		case "specialty_nomotionsensor":
			self sethintstring( &"ZOMBIE_PERK_VULTURE", cost );
			break;
		default:
			self sethintstring( ( perk + " Cost: " ) + level.zombie_vars[ "zombie_perk_cost" ] );
	}
	for ( ;; )
	{
		self waittill( "trigger", player );
		index = maps/mp/zombies/_zm_weapons::get_player_index( player );
		if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined( player.intermission ) && player.intermission )
		{
			continue;
		}
		else
		{
			if ( player in_revive_trigger() )
			{
				break;
			}
			else if ( !player maps/mp/zombies/_zm_magicbox::can_buy_weapon() )
			{
				wait 0,1;
				break;
			}
			else if ( player isthrowinggrenade() )
			{
				wait 0,1;
				break;
			}
			else if ( player isswitchingweapons() )
			{
				wait 0,1;
				break;
			}
			else if ( player.is_drinking > 0 )
			{
				wait 0,1;
				break;
			}
			else if ( player hasperk( perk ) || player has_perk_paused( perk ) )
			{
				cheat = 0;
/#
				if ( getDvarInt( "zombie_cheat" ) >= 5 )
				{
					cheat = 1;
#/
				}
				if ( cheat != 1 )
				{
					self playsound( "deny" );
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 1 );
					break;
				}
			}
			else if ( player.score < cost )
			{
				self playsound( "evt_perk_deny" );
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
				break;
			}
			else if ( player.num_perks >= 4 )
			{
				self playsound( "evt_perk_deny" );
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "sigh" );
				break;
			}
			else
			{
				sound = "evt_bottle_dispense";
				playsoundatposition( sound, self.origin );
				player maps/mp/zombies/_zm_score::minus_to_player_score( cost );
				player.perk_purchased = perk;
				self thread maps/mp/zombies/_zm_audio::play_jingle_or_stinger( self.script_label );
				self thread vending_trigger_post_think( player, perk );
			}
		}
		break;
}
}

vending_trigger_post_think( player, perk )
{
	player endon( "disconnect" );
	player endon( "end_game" );
	player endon( "perk_abort_drinking" );
	gun = player perk_give_bottle_begin( perk );
	evt = player waittill_any_return( "fake_death", "death", "player_downed", "weapon_change_complete" );
	if ( evt == "weapon_change_complete" )
	{
		player thread wait_give_perk( perk, 1 );
	}
	player perk_give_bottle_end( gun, perk );
	if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined( player.intermission ) && player.intermission )
	{
		return;
	}
	player notify( "burp" );
	if ( is_classic() )
	{
		player cash_back_player_drinks_perk();
	}
	if ( isDefined( level.perk_bought_func ) )
	{
		player [[ level.perk_bought_func ]]( perk );
	}
	player.perk_purchased = undefined;
	if ( is_false( self.power_on ) )
	{
		wait 1;
		perk_pause( self.script_noteworthy );
	}
	bbprint( "zombie_uses", "playername %s playerscore %d round %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, perk, self.origin, "perk" );
}

cash_back_player_drinks_perk()
{
	if ( isDefined( level.pers_upgrade_cash_back ) && level.pers_upgrade_cash_back )
	{
		if ( isDefined( self.pers_upgrades_awarded[ "cash_back" ] ) && self.pers_upgrades_awarded[ "cash_back" ] )
		{
			self thread cash_back_money_reward();
			self thread cash_back_player_prone_check( 1 );
			return;
		}
		else
		{
			if ( self.pers[ "pers_cash_back_bought" ] < level.pers_cash_back_num_perks_required )
			{
				self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_cash_back_bought", 0 );
				return;
			}
			else
			{
				self thread cash_back_player_prone_check( 0 );
			}
		}
	}
}

cash_back_money_reward()
{
	self endon( "death" );
	step = 5;
	amount_per_step = int( level.pers_cash_back_money_reward / step );
	i = 0;
	while ( i < step )
	{
		self maps/mp/zombies/_zm_score::add_to_player_score( amount_per_step );
		wait 0,2;
		i++;
	}
}

cash_back_player_prone_check( got_ability )
{
	self endon( "death" );
	prone_time = 2,5;
	start_time = getTime();
	while ( 1 )
	{
		time = getTime();
		dt = ( time - start_time ) / 1000;
		if ( dt > prone_time )
		{
			break;
		}
		else
		{
			if ( self getstance() == "prone" )
			{
				if ( !got_ability )
				{
					self maps/mp/zombies/_zm_stats::increment_client_stat( "pers_cash_back_prone", 0 );
					wait 0,8;
				}
				return;
			}
			wait 0,01;
		}
	}
	if ( got_ability )
	{
		self notify( "cash_back_failed_prone" );
	}
}

solo_revive_buy_trigger_move( revive_trigger_noteworthy )
{
	self endon( "death" );
	revive_perk_triggers = getentarray( revive_trigger_noteworthy, "script_noteworthy" );
	_a2453 = revive_perk_triggers;
	_k2453 = getFirstArrayKey( _a2453 );
	while ( isDefined( _k2453 ) )
	{
		revive_perk_trigger = _a2453[ _k2453 ];
		self thread solo_revive_buy_trigger_move_trigger( revive_perk_trigger );
		_k2453 = getNextArrayKey( _a2453, _k2453 );
	}
}

solo_revive_buy_trigger_move_trigger( revive_perk_trigger )
{
	self endon( "death" );
	revive_perk_trigger setinvisibletoplayer( self );
	if ( level.solo_lives_given >= 3 )
	{
		revive_perk_trigger trigger_off();
		if ( isDefined( level._solo_revive_machine_expire_func ) )
		{
			revive_perk_trigger [[ level._solo_revive_machine_expire_func ]]();
		}
		return;
	}
	while ( self.lives > 0 )
	{
		wait 0,1;
	}
	revive_perk_trigger setvisibletoplayer( self );
}

wait_give_perk( perk, bought )
{
	self endon( "player_downed" );
	self endon( "disconnect" );
	self endon( "end_game" );
	self endon( "perk_abort_drinking" );
	self waittill_notify_or_timeout( "burp", 0,5 );
	self give_perk( perk, bought );
}

give_perk( perk, bought )
{
	self setperk( perk );
	self.num_perks++;
	if ( isDefined( bought ) && bought )
	{
		self maps/mp/zombies/_zm_audio::playerexert( "burp" );
		self delay_thread( 1,5, ::maps/mp/zombies/_zm_audio::perk_vox, perk );
		self setblur( 4, 0,1 );
		wait 0,1;
		self setblur( 0, 0,1 );
		self notify( "perk_bought" );
	}
	self perk_set_max_health_if_jugg( perk, 1, 0 );
	if ( perk == "specialty_deadshot" )
	{
		self setclientfieldtoplayer( "deadshot_perk", 1 );
	}
	else
	{
		if ( perk == "specialty_deadshot_upgrade" )
		{
			self setclientfieldtoplayer( "deadshot_perk", 1 );
		}
	}
	if ( perk == "specialty_scavenger" )
	{
		self.hasperkspecialtytombstone = 1;
	}
	players = get_players();
	if ( use_solo_revive() && perk == "specialty_quickrevive" )
	{
		self.lives = 1;
		if ( !isDefined( level.solo_lives_given ) )
		{
			level.solo_lives_given = 0;
		}
		if ( isDefined( level.solo_game_free_player_quickrevive ) )
		{
			level.solo_game_free_player_quickrevive = undefined;
		}
		else
		{
			level.solo_lives_given++;
		}
		if ( level.solo_lives_given >= 3 )
		{
			flag_set( "solo_revive" );
		}
		self thread solo_revive_buy_trigger_move( perk );
	}
	if ( perk == "specialty_finalstand" )
	{
		self.lives = 1;
		self.hasperkspecialtychugabud = 1;
		self notify( "perk_chugabud_activated" );
	}
	if ( perk == "specialty_nomotionsensor" )
	{
		self maps/mp/zombies/_zm_vulture::give_vulture_perk();
	}
	self set_perk_clientfield( perk, 1 );
	maps/mp/_demo::bookmark( "zm_player_perk", getTime(), self );
	self maps/mp/zombies/_zm_stats::increment_client_stat( "perks_drank" );
	self maps/mp/zombies/_zm_stats::increment_client_stat( perk + "_drank" );
	self maps/mp/zombies/_zm_stats::increment_player_stat( perk + "_drank" );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "perks_drank" );
	if ( !isDefined( self.perk_history ) )
	{
		self.perk_history = [];
	}
	self.perk_history = add_to_array( self.perk_history, perk, 0 );
	self notify( "perk_acquired" );
	self thread perk_think( perk );
}

perk_set_max_health_if_jugg( perk, set_premaxhealth, clamp_health_to_max_health )
{
	max_total_health = undefined;
	if ( perk == "specialty_armorvest" )
	{
		if ( set_premaxhealth )
		{
			self.premaxhealth = self.maxhealth;
		}
		max_total_health = level.zombie_vars[ "zombie_perk_juggernaut_health" ];
	}
	else if ( perk == "specialty_armorvest_upgrade" )
	{
		if ( set_premaxhealth )
		{
			self.premaxhealth = self.maxhealth;
		}
		max_total_health = level.zombie_vars[ "zombie_perk_juggernaut_health_upgrade" ];
	}
	else if ( perk == "jugg_upgrade" )
	{
		if ( set_premaxhealth )
		{
			self.premaxhealth = self.maxhealth;
		}
		if ( self hasperk( "specialty_armorvest" ) )
		{
			max_total_health = level.zombie_vars[ "zombie_perk_juggernaut_health" ];
		}
		else
		{
			max_total_health = 100;
		}
	}
	else
	{
		if ( perk == "health_reboot" )
		{
			max_total_health = 100;
		}
	}
	if ( isDefined( max_total_health ) )
	{
		if ( maps/mp/zombies/_zm_utility::is_classic() )
		{
			if ( isDefined( self.pers_upgrades_awarded[ "jugg" ] ) && self.pers_upgrades_awarded[ "jugg" ] )
			{
				max_total_health += level.pers_jugg_upgrade_health_bonus;
			}
		}
		self setmaxhealth( max_total_health );
		if ( isDefined( clamp_health_to_max_health ) && clamp_health_to_max_health == 1 )
		{
			if ( self.health > self.maxhealth )
			{
				self.health = self.maxhealth;
			}
		}
	}
}

check_player_has_perk( perk )
{
	self endon( "death" );
/#
	if ( getDvarInt( "zombie_cheat" ) >= 5 )
	{
		return;
#/
	}
	dist = 16384;
	while ( 1 )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( distancesquared( players[ i ].origin, self.origin ) < dist )
			{
				if ( !players[ i ] hasperk( perk ) && !players[ i ] has_perk_paused( perk ) && !players[ i ] in_revive_trigger() && !is_equipment_that_blocks_purchase( players[ i ] getcurrentweapon() ) && !players[ i ] hacker_active() )
				{
					self setinvisibletoplayer( players[ i ], 0 );
					i++;
					continue;
				}
				else
				{
					self setinvisibletoplayer( players[ i ], 1 );
				}
			}
			i++;
		}
		wait 0,1;
	}
}

vending_set_hintstring( perk )
{
	switch( perk )
	{
		case "specialty_armorvest":
		case "specialty_armorvest_upgrade":
			break;
	}
}

perk_think( perk )
{
/#
	if ( getDvarInt( "zombie_cheat" ) >= 5 )
	{
		if ( isDefined( self.perk_hud[ perk ] ) )
		{
			return;
#/
		}
	}
	perk_str = perk + "_stop";
	result = self waittill_any_return( "fake_death", "death", "player_downed", perk_str );
	do_retain = 1;
	if ( use_solo_revive() && perk == "specialty_quickrevive" )
	{
		do_retain = 0;
	}
	if ( do_retain && isDefined( self._retain_perks ) && self._retain_perks )
	{
		return;
	}
	self unsetperk( perk );
	self.num_perks--;

	switch( perk )
	{
		case "specialty_armorvest":
			self setmaxhealth( 100 );
			break;
		case "specialty_additionalprimaryweapon":
			if ( result == perk_str )
			{
				self maps/mp/zombies/_zm::take_additionalprimaryweapon();
			}
			break;
		case "specialty_deadshot":
			self setclientfieldtoplayer( "deadshot_perk", 0 );
			break;
		case "specialty_deadshot_upgrade":
			self setclientfieldtoplayer( "deadshot_perk", 0 );
			break;
		case "specialty_nomotionsensor":
			self maps/mp/zombies/_zm_vulture::take_vulture_perk();
			break;
	}
	self set_perk_clientfield( perk, 0 );
	self.perk_purchased = undefined;
	if ( isDefined( level.perk_lost_func ) )
	{
		self [[ level.perk_lost_func ]]( perk );
	}
	self notify( "perk_lost" );
}

set_perk_clientfield( perk, state )
{
	switch( perk )
	{
		case "specialty_additionalprimaryweapon":
			self setclientfieldtoplayer( "perk_additional_primary_weapon", state );
			break;
		case "specialty_deadshot":
			self setclientfieldtoplayer( "perk_dead_shot", state );
			break;
		case "specialty_flakjacket":
			self setclientfieldtoplayer( "perk_dive_to_nuke", state );
			break;
		case "specialty_rof":
			self setclientfieldtoplayer( "perk_double_tap", state );
			break;
		case "specialty_armorvest":
			self setclientfieldtoplayer( "perk_juggernaut", state );
			break;
		case "specialty_longersprint":
			self setclientfieldtoplayer( "perk_marathon", state );
			break;
		case "specialty_quickrevive":
			self setclientfieldtoplayer( "perk_quick_revive", state );
			break;
		case "specialty_fastreload":
			self setclientfieldtoplayer( "perk_sleight_of_hand", state );
			break;
		case "specialty_scavenger":
			self setclientfieldtoplayer( "perk_tombstone", state );
			break;
		case "specialty_finalstand":
			self setclientfieldtoplayer( "perk_chugabud", state );
			break;
		case "specialty_grenadepulldeath":
			self setclientfieldtoplayer( "perk_electric_cherry", state );
			break;
		case "specialty_nomotionsensor":
			self setclientfieldtoplayer( "perk_vulture", state );
			break;
		default:
		}
	}
}

perk_hud_destroy( perk )
{
	self.perk_hud[ perk ] destroy_hud();
}

perk_hud_grey( perk, grey_on_off )
{
	if ( grey_on_off )
	{
		self.perk_hud[ perk ].alpha = 0,3;
	}
	else
	{
		self.perk_hud[ perk ].alpha = 1;
	}
}

perk_hud_flash()
{
	self endon( "death" );
	self.flash = 1;
	self scaleovertime( 0,05, 32, 32 );
	wait 0,3;
	self scaleovertime( 0,05, 24, 24 );
	wait 0,3;
	self.flash = 0;
}

perk_flash_audio( perk )
{
	alias = undefined;
	switch( perk )
	{
		case "specialty_armorvest":
			alias = "zmb_hud_flash_jugga";
			break;
		case "specialty_quickrevive":
			alias = "zmb_hud_flash_revive";
			break;
		case "specialty_fastreload":
			alias = "zmb_hud_flash_speed";
			break;
		case "specialty_longersprint":
			alias = "zmb_hud_flash_stamina";
			break;
		case "specialty_flakjacket":
			alias = "zmb_hud_flash_phd";
			break;
		case "specialty_deadshot":
			alias = "zmb_hud_flash_deadshot";
			break;
		case "specialty_additionalprimaryweapon":
			alias = "zmb_hud_flash_additionalprimaryweapon";
			break;
	}
	if ( isDefined( alias ) )
	{
		self playlocalsound( alias );
	}
}

perk_hud_start_flash( perk )
{
	if ( self hasperk( perk ) && isDefined( self.perk_hud ) )
	{
		hud = self.perk_hud[ perk ];
		if ( isDefined( hud ) )
		{
			if ( isDefined( hud.flash ) && !hud.flash )
			{
				hud thread perk_hud_flash();
				self thread perk_flash_audio( perk );
			}
		}
	}
}

perk_hud_stop_flash( perk, taken )
{
	if ( self hasperk( perk ) && isDefined( self.perk_hud ) )
	{
		hud = self.perk_hud[ perk ];
		if ( isDefined( hud ) )
		{
			hud.flash = undefined;
			if ( isDefined( taken ) )
			{
				hud notify( "stop_flash_perk" );
			}
		}
	}
}

perk_give_bottle_begin( perk )
{
	self increment_is_drinking();
	self disable_player_move_states( 1 );
	gun = self getcurrentweapon();
	weapon = "";
	switch( perk )
	{
		case " _upgrade":
		case "specialty_armorvest":
			weapon = "zombie_perk_bottle_jugg";
			break;
		case "specialty_quickrevive":
		case "specialty_quickrevive_upgrade":
			weapon = "zombie_perk_bottle_revive";
			break;
		case "specialty_fastreload":
		case "specialty_fastreload_upgrade":
			weapon = "zombie_perk_bottle_sleight";
			break;
		case "specialty_rof":
		case "specialty_rof_upgrade":
			weapon = "zombie_perk_bottle_doubletap";
			break;
		case "specialty_longersprint":
		case "specialty_longersprint_upgrade":
			weapon = "zombie_perk_bottle_marathon";
			break;
		case "specialty_flakjacket":
		case "specialty_flakjacket_upgrade":
			weapon = "zombie_perk_bottle_nuke";
			break;
		case "specialty_deadshot":
		case "specialty_deadshot_upgrade":
			weapon = "zombie_perk_bottle_deadshot";
			break;
		case "specialty_additionalprimaryweapon":
		case "specialty_additionalprimaryweapon_upgrade":
			weapon = "zombie_perk_bottle_additionalprimaryweapon";
			break;
		case "specialty_scavenger":
		case "specialty_scavenger_upgrade":
			weapon = "zombie_perk_bottle_tombstone";
			break;
		case "specialty_finalstand":
		case "specialty_finalstand_upgrade":
			weapon = "zombie_perk_bottle_whoswho";
			break;
		case "specialty_grenadepulldeath":
		case "specialty_grenadepulldeath_upgrade":
			weapon = "zombie_perk_bottle_cherry";
			break;
		case "specialty_nomotionsensor":
			weapon = "zombie_perk_bottle_vulture";
			break;
	}
	self giveweapon( weapon );
	self switchtoweapon( weapon );
	return gun;
}

perk_give_bottle_end( gun, perk )
{
	self endon( "perk_abort_drinking" );
/#
	assert( !is_zombie_perk_bottle( gun ) );
#/
/#
	assert( gun != level.revive_tool );
#/
	self enable_player_move_states();
	weapon = "";
	switch( perk )
	{
		case "specialty_rof":
		case "specialty_rof_upgrade":
			weapon = "zombie_perk_bottle_doubletap";
			break;
		case "specialty_longersprint":
		case "specialty_longersprint_upgrade":
			weapon = "zombie_perk_bottle_marathon";
			break;
		case "specialty_flakjacket":
		case "specialty_flakjacket_upgrade":
			weapon = "zombie_perk_bottle_nuke";
			break;
		case "specialty_armorvest":
		case "specialty_armorvest_upgrade":
			weapon = "zombie_perk_bottle_jugg";
			self.jugg_used = 1;
			break;
		case "specialty_quickrevive":
		case "specialty_quickrevive_upgrade":
			weapon = "zombie_perk_bottle_revive";
			break;
		case "specialty_fastreload":
		case "specialty_fastreload_upgrade":
			weapon = "zombie_perk_bottle_sleight";
			self.speed_used = 1;
			break;
		case "specialty_deadshot":
		case "specialty_deadshot_upgrade":
			weapon = "zombie_perk_bottle_deadshot";
			break;
		case "specialty_additionalprimaryweapon":
		case "specialty_additionalprimaryweapon_upgrade":
			weapon = "zombie_perk_bottle_additionalprimaryweapon";
			break;
		case "specialty_scavenger":
		case "specialty_scavenger_upgrade":
			weapon = "zombie_perk_bottle_tombstone";
			break;
		case "specialty_finalstand":
		case "specialty_finalstand_upgrade":
			weapon = "zombie_perk_bottle_whoswho";
			break;
		case "specialty_grenadepulldeath":
		case "specialty_grenadepulldeath_upgrade":
			weapon = "zombie_perk_bottle_cherry";
			break;
		case "specialty_nomotionsensor":
			weapon = "zombie_perk_bottle_vulture";
			break;
	}
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined( self.intermission ) && self.intermission )
	{
		self takeweapon( weapon );
		return;
	}
	self takeweapon( weapon );
	if ( self is_multiple_drinking() )
	{
		self decrement_is_drinking();
		return;
	}
	else if ( gun != "none" && !is_placeable_mine( gun ) && !is_equipment_that_blocks_purchase( gun ) )
	{
		self switchtoweapon( gun );
		if ( is_melee_weapon( gun ) )
		{
			self decrement_is_drinking();
			return;
		}
	}
	else
	{
		primaryweapons = self getweaponslistprimaries();
		if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
		{
			self switchtoweapon( primaryweapons[ 0 ] );
		}
	}
	self waittill( "weapon_change_complete" );
	if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() && isDefined( self.intermission ) && !self.intermission )
	{
		self decrement_is_drinking();
	}
}

perk_abort_drinking( post_delay )
{
	if ( self.is_drinking )
	{
		self notify( "perk_abort_drinking" );
		self decrement_is_drinking();
		self enable_player_move_states();
		if ( isDefined( post_delay ) )
		{
			wait post_delay;
		}
	}
}

give_random_perk()
{
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	perks = [];
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ].script_noteworthy;
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		else
		{
			if ( perk == "specialty_weapupgrade" )
			{
				i++;
				continue;
			}
			else
			{
				if ( !self hasperk( perk ) && !self has_perk_paused( perk ) )
				{
					perks[ perks.size ] = perk;
				}
			}
		}
		i++;
	}
	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		self give_perk( perks[ 0 ] );
	}
}

lose_random_perk()
{
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	perks = [];
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ].script_noteworthy;
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		else
		{
			if ( self hasperk( perk ) || self has_perk_paused( perk ) )
			{
				perks[ perks.size ] = perk;
			}
		}
		i++;
	}
	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		perk = perks[ 0 ];
		perk_str = perk + "_stop";
		self notify( perk_str );
		if ( use_solo_revive() && perk == "specialty_quickrevive" )
		{
			self.lives--;

		}
	}
}

update_perk_hud()
{
	while ( isDefined( self.perk_hud ) )
	{
		keys = getarraykeys( self.perk_hud );
		i = 0;
		while ( i < self.perk_hud.size )
		{
			self.perk_hud[ keys[ i ] ].x = i * 30;
			i++;
		}
	}
}

quantum_bomb_give_nearest_perk_validation( position )
{
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	range_squared = 32400;
	i = 0;
	while ( i < vending_triggers.size )
	{
		if ( distancesquared( vending_triggers[ i ].origin, position ) < range_squared )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

quantum_bomb_give_nearest_perk_result( position )
{
	[[ level.quantum_bomb_play_mystery_effect_func ]]( position );
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	nearest = 0;
	i = 1;
	while ( i < vending_triggers.size )
	{
		if ( distancesquared( vending_triggers[ i ].origin, position ) < distancesquared( vending_triggers[ nearest ].origin, position ) )
		{
			nearest = i;
		}
		i++;
	}
	players = get_players();
	perk = vending_triggers[ nearest ].script_noteworthy;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( player.sessionstate == "spectator" || player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			i++;
			continue;
		}
		else
		{
			if ( !player hasperk( perk ) && isDefined( player.perk_purchased ) && player.perk_purchased != perk && randomint( 5 ) )
			{
				if ( player == self )
				{
					self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "quant_good" );
				}
				player give_perk( perk );
				player [[ level.quantum_bomb_play_player_effect_func ]]();
			}
		}
		i++;
	}
}

perk_pause( perk )
{
	if ( perk == "Pack_A_Punch" || perk == "specialty_weapupgrade" )
	{
		return;
	}
	j = 0;
	while ( j < get_players().size )
	{
		player = get_players()[ j ];
		if ( !isDefined( player.disabled_perks ) )
		{
			player.disabled_perks = [];
		}
		if ( isDefined( player.disabled_perks[ perk ] ) && !player.disabled_perks[ perk ] )
		{
			player.disabled_perks[ perk ] = player hasperk( perk );
		}
		if ( player.disabled_perks[ perk ] )
		{
			player unsetperk( perk );
			player set_perk_clientfield( perk, 2 );
			if ( perk == "specialty_armorvest" || perk == "specialty_armorvest_upgrade" )
			{
				player setmaxhealth( player.premaxhealth );
				if ( player.health > player.maxhealth )
				{
					player.health = player.maxhealth;
				}
			}
/#
			println( " ZM PERKS " + player.name + " paused perk " + perk + "\n" );
#/
		}
		j++;
	}
}

perk_unpause( perk )
{
	if ( !isDefined( perk ) )
	{
		return;
	}
	if ( perk == "Pack_A_Punch" )
	{
		return;
	}
	j = 0;
	while ( j < get_players().size )
	{
		player = get_players()[ j ];
		if ( isDefined( player.disabled_perks ) && isDefined( player.disabled_perks[ perk ] ) && player.disabled_perks[ perk ] )
		{
			player.disabled_perks[ perk ] = 0;
			player set_perk_clientfield( perk, 1 );
			player setperk( perk );
/#
			println( " ZM PERKS " + player.name + " unpaused perk " + perk + "\n" );
#/
			if ( issubstr( perk, "specialty_scavenger" ) )
			{
				player.hasperkspecialtytombstone = 1;
			}
			player perk_set_max_health_if_jugg( perk, 0, 0 );
		}
		j++;
	}
}

perk_pause_all_perks()
{
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	_a3414 = vending_triggers;
	_k3414 = getFirstArrayKey( _a3414 );
	while ( isDefined( _k3414 ) )
	{
		trigger = _a3414[ _k3414 ];
		maps/mp/zombies/_zm_perks::perk_pause( trigger.script_noteworthy );
		_k3414 = getNextArrayKey( _a3414, _k3414 );
	}
}

perk_unpause_all_perks()
{
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	_a3424 = vending_triggers;
	_k3424 = getFirstArrayKey( _a3424 );
	while ( isDefined( _k3424 ) )
	{
		trigger = _a3424[ _k3424 ];
		maps/mp/zombies/_zm_perks::perk_unpause( trigger.script_noteworthy );
		_k3424 = getNextArrayKey( _a3424, _k3424 );
	}
}

has_perk_paused( perk )
{
	if ( isDefined( self.disabled_perks ) && isDefined( self.disabled_perks[ perk ] ) && self.disabled_perks[ perk ] )
	{
		return 1;
	}
	return 0;
}

getvendingmachinenotify()
{
	if ( !isDefined( self ) )
	{
		return "";
	}
	switch( self.script_noteworthy )
	{
		case "specialty_armorvest":
		case "specialty_armorvest_upgrade":
			return "juggernog";
			case "specialty_quickrevive":
			case "specialty_quickrevive_upgrade":
				return "revive";
				case "specialty_fastreload":
				case "specialty_fastreload_upgrade":
					return "sleight";
					case "specialty_rof":
					case "specialty_rof_upgrade":
						return "doubletap";
						case "specialty_longersprint":
						case "specialty_longersprint_upgrade":
							return "marathon";
							case "specialty_flakjacket":
							case "specialty_flakjacket_upgrade":
								return "divetonuke";
								case "specialty_deadshot":
								case "specialty_deadshot_upgrade":
									return "deadshot";
									case "specialty_additionalprimaryweapon":
									case "specialty_additionalprimaryweapon_upgrade":
										return "additionalprimaryweapon";
										case "specialty_scavenger":
										case "specialty_scavenger_upgrade":
											return "tombstone";
											case "specialty_finalstand":
											case "specialty_finalstand_upgrade":
												return "chugabud";
												case "specialty_grenadepulldeath":
												case "specialty_grenadepulldeath_upgrade":
													return "electric_cherry";
													case "specialty_nomotionsensor":
														return "vulture";
														case "specialty_weapupgrade":
															return "Pack_A_Punch";
														default:
															return undefined;
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

perk_machine_removal( machine, replacement_model )
{
	if ( !isDefined( machine ) )
	{
		return;
	}
	trig = getent( machine, "script_noteworthy" );
	machine_model = undefined;
	if ( isDefined( trig ) )
	{
		trig notify( "warning_dialog" );
		while ( isDefined( trig.target ) )
		{
			parts = getentarray( trig.target, "targetname" );
			i = 0;
			while ( i < parts.size )
			{
				if ( isDefined( parts[ i ].classname ) && parts[ i ].classname == "script_model" )
				{
					machine_model = parts[ i ];
					i++;
					continue;
				}
				else
				{
					if ( parts[ i ].script_noteworthy )
					{
						if ( isDefined( parts[ i ].script_noteworthy == "clip" ) )
						{
							model_clip = parts[ i ];
						}
						i++;
						continue;
					}
					else
					{
						parts[ i ] delete();
					}
				}
				i++;
			}
		}
		if ( isDefined( replacement_model ) && isDefined( machine_model ) )
		{
			machine_model setmodel( replacement_model );
		}
		else
		{
			if ( !isDefined( replacement_model ) && isDefined( machine_model ) )
			{
				machine_model delete();
				if ( isDefined( model_clip ) )
				{
					model_clip delete();
				}
				if ( isDefined( trig.clip ) )
				{
					trig.clip delete();
				}
			}
		}
		if ( isDefined( trig.bump ) )
		{
			trig.bump delete();
		}
		trig delete();
	}
}

perk_machine_spawn_init()
{
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = ( level.scr_zm_ui_gametype + "_perks_" ) + location;
	pos = [];
	if ( isDefined( level.override_perk_targetname ) )
	{
		structs = getstructarray( level.override_perk_targetname, "targetname" );
	}
	else
	{
		structs = getstructarray( "zm_perk_machine", "targetname" );
	}
	_a3627 = structs;
	_k3627 = getFirstArrayKey( _a3627 );
	while ( isDefined( _k3627 ) )
	{
		struct = _a3627[ _k3627 ];
		if ( isDefined( struct.script_string ) )
		{
			tokens = strtok( struct.script_string, " " );
			_a3632 = tokens;
			_k3632 = getFirstArrayKey( _a3632 );
			while ( isDefined( _k3632 ) )
			{
				token = _a3632[ _k3632 ];
				if ( token == match_string )
				{
					pos[ pos.size ] = struct;
				}
				_k3632 = getNextArrayKey( _a3632, _k3632 );
			}
		}
		else pos[ pos.size ] = struct;
		_k3627 = getNextArrayKey( _a3627, _k3627 );
	}
	if ( !isDefined( pos ) || pos.size == 0 )
	{
		return;
	}
	precachemodel( "zm_collision_perks1" );
	i = 0;
	while ( i < pos.size )
	{
		perk = pos[ i ].script_noteworthy;
		if ( isDefined( perk ) && isDefined( pos[ i ].model ) )
		{
			use_trigger = spawn( "trigger_radius_use", pos[ i ].origin + vectorScale( ( 0, -1, 0 ), 30 ), 0, 40, 70 );
			use_trigger.targetname = "zombie_vending";
			use_trigger.script_noteworthy = perk;
			use_trigger triggerignoreteam();
			perk_machine = spawn( "script_model", pos[ i ].origin );
			perk_machine.angles = pos[ i ].angles;
			perk_machine setmodel( pos[ i ].model );
			bump_trigger = spawn( "trigger_radius", pos[ i ].origin, 0, 35, 64 );
			bump_trigger.script_activated = 1;
			bump_trigger.script_sound = "zmb_perks_bump_bottle";
			bump_trigger.targetname = "audio_bump_trigger";
			if ( perk != "specialty_weapupgrade" )
			{
				bump_trigger thread thread_bump_trigger();
			}
			collision = spawn( "script_model", pos[ i ].origin, 1 );
			collision.angles = pos[ i ].angles;
			collision setmodel( "zm_collision_perks1" );
			collision.script_noteworthy = "clip";
			collision disconnectpaths();
			use_trigger.clip = collision;
			use_trigger.machine = perk_machine;
			use_trigger.bump = bump_trigger;
			if ( isDefined( pos[ i ].blocker_model ) )
			{
				use_trigger.blocker_model = pos[ i ].blocker_model;
			}
			if ( isDefined( pos[ i ].script_int ) )
			{
				perk_machine.script_int = pos[ i ].script_int;
			}
			if ( isDefined( pos[ i ].turn_on_notify ) )
			{
				perk_machine.turn_on_notify = pos[ i ].turn_on_notify;
			}
			switch( perk )
			{
				case "specialty_quickrevive":
				case "specialty_quickrevive_upgrade":
					use_trigger.script_sound = "mus_perks_revive_jingle";
					use_trigger.script_string = "revive_perk";
					use_trigger.script_label = "mus_perks_revive_sting";
					use_trigger.target = "vending_revive";
					perk_machine.script_string = "revive_perk";
					perk_machine.targetname = "vending_revive";
					bump_trigger.script_string = "revive_perk";
					break;
				i++;
				continue;
				case "specialty_fastreload":
				case "specialty_fastreload_upgrade":
					use_trigger.script_sound = "mus_perks_speed_jingle";
					use_trigger.script_string = "speedcola_perk";
					use_trigger.script_label = "mus_perks_speed_sting";
					use_trigger.target = "vending_sleight";
					perk_machine.script_string = "speedcola_perk";
					perk_machine.targetname = "vending_sleight";
					bump_trigger.script_string = "speedcola_perk";
					break;
				i++;
				continue;
				case "specialty_longersprint":
				case "specialty_longersprint_upgrade":
					use_trigger.script_sound = "mus_perks_stamin_jingle";
					use_trigger.script_string = "marathon_perk";
					use_trigger.script_label = "mus_perks_stamin_sting";
					use_trigger.target = "vending_marathon";
					perk_machine.script_string = "marathon_perk";
					perk_machine.targetname = "vending_marathon";
					bump_trigger.script_string = "marathon_perk";
					break;
				i++;
				continue;
				case "specialty_armorvest":
				case "specialty_armorvest_upgrade":
					use_trigger.script_sound = "mus_perks_jugganog_jingle";
					use_trigger.script_string = "jugg_perk";
					use_trigger.script_label = "mus_perks_jugganog_sting";
					use_trigger.longjinglewait = 1;
					use_trigger.target = "vending_jugg";
					perk_machine.script_string = "jugg_perk";
					perk_machine.targetname = "vending_jugg";
					bump_trigger.script_string = "jugg_perk";
					break;
				i++;
				continue;
				case "specialty_scavenger":
				case "specialty_scavenger_upgrade":
					use_trigger.script_sound = "mus_perks_tombstone_jingle";
					use_trigger.script_string = "tombstone_perk";
					use_trigger.script_label = "mus_perks_tombstone_sting";
					use_trigger.target = "vending_tombstone";
					perk_machine.script_string = "tombstone_perk";
					perk_machine.targetname = "vending_tombstone";
					bump_trigger.script_string = "tombstone_perk";
					break;
				i++;
				continue;
				case "specialty_rof":
				case "specialty_rof_upgrade":
					use_trigger.script_sound = "mus_perks_doubletap_jingle";
					use_trigger.script_string = "tap_perk";
					use_trigger.script_label = "mus_perks_doubletap_sting";
					use_trigger.target = "vending_doubletap";
					perk_machine.script_string = "tap_perk";
					perk_machine.targetname = "vending_doubletap";
					bump_trigger.script_string = "tap_perk";
					break;
				i++;
				continue;
				case "specialty_finalstand":
				case "specialty_finalstand_upgrade":
					use_trigger.script_sound = "mus_perks_whoswho_jingle";
					use_trigger.script_string = "tap_perk";
					use_trigger.script_label = "mus_perks_whoswho_sting";
					use_trigger.target = "vending_chugabud";
					perk_machine.script_string = "tap_perk";
					perk_machine.targetname = "vending_chugabud";
					bump_trigger.script_string = "tap_perk";
					break;
				i++;
				continue;
				case "specialty_additionalprimaryweapon":
				case "specialty_additionalprimaryweapon_upgrade":
					use_trigger.script_sound = "mus_perks_mulekick_jingle";
					use_trigger.script_string = "tap_perk";
					use_trigger.script_label = "mus_perks_mulekick_sting";
					use_trigger.target = "vending_additionalprimaryweapon";
					perk_machine.script_string = "tap_perk";
					perk_machine.targetname = "vending_additionalprimaryweapon";
					bump_trigger.script_string = "tap_perk";
					break;
				i++;
				continue;
				case "specialty_weapupgrade":
					use_trigger.target = "vending_packapunch";
					use_trigger.script_sound = "mus_perks_packa_jingle";
					use_trigger.script_label = "mus_perks_packa_sting";
					use_trigger.longjinglewait = 1;
					perk_machine.targetname = "vending_packapunch";
					flag_pos = getstruct( pos[ i ].target, "targetname" );
					if ( isDefined( flag_pos ) )
					{
						perk_machine_flag = spawn( "script_model", flag_pos.origin );
						perk_machine_flag.angles = flag_pos.angles;
						perk_machine_flag setmodel( flag_pos.model );
						perk_machine_flag.targetname = "pack_flag";
						perk_machine.target = "pack_flag";
					}
					bump_trigger.script_string = "perks_rattle";
					break;
				i++;
				continue;
				case "specialty_grenadepulldeath":
				case "specialty_grenadepulldeath_upgrade":
					use_trigger.script_sound = "mus_perks_speed_jingle";
					use_trigger.script_string = "electric_cherry_perk";
					use_trigger.script_label = "mus_perks_speed_sting";
					use_trigger.target = "vending_electriccherry";
					perk_machine.script_string = "electriccherry_perk";
					perk_machine.targetname = "vendingelectric_cherry";
					bump_trigger.script_string = "electriccherry_perk";
					break;
				i++;
				continue;
				case "specialty_nomotionsensor":
					use_trigger.script_sound = "mus_perks_revive_jingle";
					use_trigger.script_string = "vulture_perk";
					use_trigger.script_label = "mus_perks_revive_sting";
					use_trigger.target = "vending_vulture";
					perk_machine.script_string = "vulture_perk";
					perk_machine.targetname = "vending_vulture";
					bump_trigger.script_string = "vulture_perk";
					break;
				i++;
				continue;
				default:
					use_trigger.script_sound = "mus_perks_speed_jingle";
					use_trigger.script_string = "speedcola_perk";
					use_trigger.script_label = "mus_perks_speed_sting";
					use_trigger.target = "vending_sleight";
					perk_machine.script_string = "speedcola_perk";
					perk_machine.targetname = "vending_sleight";
					bump_trigger.script_string = "speedcola_perk";
					break;
				i++;
				continue;
			}
		}
		i++;
	}
}

get_perk_machine_start_state( perk )
{
	if ( isDefined( level.vending_machines_powered_on_at_start ) && level.vending_machines_powered_on_at_start )
	{
		return 1;
	}
	if ( perk == "specialty_quickrevive" || perk == "specialty_quickrevive_upgrade" )
	{
/#
		assert( isDefined( level.revive_machine_is_solo ) );
#/
		return level.revive_machine_is_solo;
	}
	return 0;
}

perks_register_clientfield()
{
	if ( isDefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
	{
		registerclientfield( "toplayer", "perk_additional_primary_weapon", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		registerclientfield( "toplayer", "perk_dead_shot", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_divetonuke_perk ) && level.zombiemode_using_divetonuke_perk )
	{
		registerclientfield( "toplayer", "perk_dive_to_nuke", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		registerclientfield( "toplayer", "perk_double_tap", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
	{
		registerclientfield( "toplayer", "perk_juggernaut", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		registerclientfield( "toplayer", "perk_marathon", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		registerclientfield( "toplayer", "perk_quick_revive", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		registerclientfield( "toplayer", "perk_sleight_of_hand", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		registerclientfield( "toplayer", "perk_tombstone", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_perk_intro_fx ) && level.zombiemode_using_perk_intro_fx )
	{
		registerclientfield( "scriptmover", "clientfield_perk_intro_fx", 1000, 1, "int" );
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		registerclientfield( "toplayer", "perk_chugabud", 1000, 1, "int" );
	}
	if ( isDefined( level.zombiemode_using_electric_cherry_perk ) && level.zombiemode_using_electric_cherry_perk )
	{
		registerclientfield( "toplayer", "perk_electric_cherry", 7000, 1, "int" );
	}
	if ( isDefined( level.zombiemode_using_vulture_perk ) && level.zombiemode_using_vulture_perk )
	{
		registerclientfield( "toplayer", "perk_vulture", 7000, 1, "int" );
	}
}

thread_bump_trigger()
{
	for ( ;; )
	{
		self waittill( "trigger", trigplayer );
		trigplayer playsound( self.script_sound );
		while ( is_player_valid( trigplayer ) && trigplayer istouching( self ) )
		{
			wait 0,5;
		}
	}
}

reenable_quickrevive( machine_clip, solo_mode )
{
	if ( isDefined( level.revive_machine_spawned ) && !is_true( level.revive_machine_spawned ) )
	{
		return;
	}
	wait 0,1;
	power_state = 0;
	if ( is_true( solo_mode ) )
	{
		power_state = 1;
		should_pause = 1;
		players = get_players();
		_a3981 = players;
		_k3981 = getFirstArrayKey( _a3981 );
		while ( isDefined( _k3981 ) )
		{
			player = _a3981[ _k3981 ];
			if ( isDefined( player.lives ) && player.lives > 0 && power_state )
			{
				should_pause = 0;
			}
			else
			{
				if ( isDefined( player.lives ) && player.lives < 1 )
				{
					should_pause = 1;
				}
			}
			_k3981 = getNextArrayKey( _a3981, _k3981 );
		}
		if ( should_pause )
		{
			perk_pause( "specialty_quickrevive" );
		}
		else
		{
			perk_unpause( "specialty_quickrevive" );
		}
		if ( isDefined( level.solo_revive_init ) && level.solo_revive_init && flag( "solo_revive" ) )
		{
			disable_quickrevive( machine_clip );
			return;
		}
		update_quickrevive_power_state( 1 );
		unhide_quickrevive();
		restart_quickrevive();
		level notify( "revive_off" );
		wait 0,1;
		level notify( "stop_quickrevive_logic" );
	}
	else
	{
		if ( isDefined( level._dont_unhide_quickervive_on_hotjoin ) && !level._dont_unhide_quickervive_on_hotjoin )
		{
			unhide_quickrevive();
			level notify( "revive_off" );
			wait 0,1;
		}
		level notify( "revive_hide" );
		level notify( "stop_quickrevive_logic" );
		restart_quickrevive();
		if ( flag( "power_on" ) )
		{
			power_state = 1;
		}
		update_quickrevive_power_state( power_state );
	}
	level thread turn_revive_on();
	if ( power_state )
	{
		perk_unpause( "specialty_quickrevive" );
		level notify( "revive_on" );
		wait 0,1;
		level notify( "specialty_quickrevive_power_on" );
	}
	else
	{
		perk_pause( "specialty_quickrevive" );
	}
	if ( !is_true( solo_mode ) )
	{
		return;
	}
	should_pause = 1;
	players = get_players();
	_a4059 = players;
	_k4059 = getFirstArrayKey( _a4059 );
	while ( isDefined( _k4059 ) )
	{
		player = _a4059[ _k4059 ];
		if ( !is_player_valid( player ) )
		{
		}
		else if ( player hasperk( "specialty_quickrevive" ) )
		{
			if ( !isDefined( player.lives ) )
			{
				player.lives = 0;
			}
			if ( !isDefined( level.solo_lives_given ) )
			{
				level.solo_lives_given = 0;
			}
			level.solo_lives_given++;
			player.lives++;
			if ( isDefined( player.lives ) && player.lives > 0 && power_state )
			{
				should_pause = 0;
				break;
			}
			else
			{
				should_pause = 1;
			}
		}
		_k4059 = getNextArrayKey( _a4059, _k4059 );
	}
	if ( should_pause )
	{
		perk_pause( "specialty_quickrevive" );
	}
	else
	{
		perk_unpause( "specialty_quickrevive" );
	}
}

update_quickrevive_power_state( poweron )
{
	_a4097 = level.powered_items;
	_k4097 = getFirstArrayKey( _a4097 );
	while ( isDefined( _k4097 ) )
	{
		item = _a4097[ _k4097 ];
		if ( isDefined( item.target ) && isDefined( item.target.script_noteworthy ) && item.target.script_noteworthy == "specialty_quickrevive" )
		{
			if ( item.power && !poweron )
			{
				if ( !isDefined( item.powered_count ) )
				{
					item.powered_count = 0;
				}
				else
				{
					if ( item.powered_count > 0 )
					{
						item.powered_count--;

					}
				}
			}
			else
			{
				if ( !item.power && poweron )
				{
					if ( !isDefined( item.powered_count ) )
					{
						item.powered_count = 0;
					}
					item.powered_count++;
				}
			}
			if ( !isDefined( item.depowered_count ) )
			{
				item.depowered_count = 0;
			}
			item.power = poweron;
		}
		_k4097 = getNextArrayKey( _a4097, _k4097 );
	}
}

restart_quickrevive()
{
	triggers = getentarray( "zombie_vending", "targetname" );
	_a4137 = triggers;
	_k4137 = getFirstArrayKey( _a4137 );
	while ( isDefined( _k4137 ) )
	{
		trigger = _a4137[ _k4137 ];
		if ( !isDefined( trigger.script_noteworthy ) )
		{
		}
		else
		{
			if ( trigger.script_noteworthy == "specialty_quickrevive" || trigger.script_noteworthy == "specialty_quickrevive_upgrade" )
			{
				trigger notify( "stop_quickrevive_logic" );
				trigger thread vending_trigger_think();
				trigger trigger_on();
			}
		}
		_k4137 = getNextArrayKey( _a4137, _k4137 );
	}
}

disable_quickrevive( machine_clip )
{
	if ( is_true( level.solo_revive_init ) && flag( "solo_revive" ) && isDefined( level.quick_revive_machine ) )
	{
		triggers = getentarray( "zombie_vending", "targetname" );
		_a4159 = triggers;
		_k4159 = getFirstArrayKey( _a4159 );
		while ( isDefined( _k4159 ) )
		{
			trigger = _a4159[ _k4159 ];
			if ( !isDefined( trigger.script_noteworthy ) )
			{
			}
			else
			{
				if ( trigger.script_noteworthy == "specialty_quickrevive" || trigger.script_noteworthy == "specialty_quickrevive_upgrade" )
				{
					trigger trigger_off();
				}
			}
			_k4159 = getNextArrayKey( _a4159, _k4159 );
		}
		_a4171 = level.powered_items;
		_k4171 = getFirstArrayKey( _a4171 );
		while ( isDefined( _k4171 ) )
		{
			item = _a4171[ _k4171 ];
			if ( isDefined( item.target ) && isDefined( item.target.script_noteworthy ) && item.target.script_noteworthy == "specialty_quickrevive" )
			{
				item.power = 1;
				item.self_powered = 1;
			}
			_k4171 = getNextArrayKey( _a4171, _k4171 );
		}
		if ( isDefined( level.quick_revive_machine.original_pos ) )
		{
			level.quick_revive_default_origin = level.quick_revive_machine.original_pos;
			level.quick_revive_default_angles = level.quick_revive_machine.original_angles;
		}
		move_org = level.quick_revive_default_origin;
		if ( isDefined( level.quick_revive_linked_ent ) )
		{
			move_org = level.quick_revive_linked_ent.origin;
			if ( isDefined( level.quick_revive_linked_ent_offset ) )
			{
				move_org += level.quick_revive_linked_ent_offset;
			}
			level.quick_revive_machine unlink();
		}
		level.quick_revive_machine moveto( move_org + vectorScale( ( 0, -1, 0 ), 40 ), 3 );
		direction = level.quick_revive_machine.origin;
		direction = ( direction[ 1 ], direction[ 0 ], 0 );
		if ( direction[ 1 ] < 0 || direction[ 0 ] > 0 && direction[ 1 ] > 0 )
		{
			direction = ( direction[ 0 ], direction[ 1 ] * -1, 0 );
		}
		else
		{
			if ( direction[ 0 ] < 0 )
			{
				direction = ( direction[ 0 ] * -1, direction[ 1 ], 0 );
			}
		}
		level.quick_revive_machine vibrate( direction, 10, 0,5, 4 );
		level.quick_revive_machine waittill( "movedone" );
		level.quick_revive_machine hide();
		level.quick_revive_machine.ishidden = 1;
		if ( isDefined( level.quick_revive_machine_clip ) )
		{
			level.quick_revive_machine_clip connectpaths();
			level.quick_revive_machine_clip trigger_off();
		}
		playfx( level._effect[ "poltergeist" ], level.quick_revive_machine.origin );
		if ( isDefined( level.quick_revive_trigger ) && isDefined( level.quick_revive_trigger.blocker_model ) )
		{
			level.quick_revive_trigger.blocker_model show();
		}
		level notify( "revive_hide" );
	}
}

unhide_quickrevive()
{
	while ( players_are_in_perk_area( level.quick_revive_machine ) )
	{
		wait 0,1;
	}
	if ( isDefined( level.quick_revive_machine_clip ) )
	{
		level.quick_revive_machine_clip trigger_on();
		level.quick_revive_machine_clip disconnectpaths();
	}
	if ( isDefined( level.quick_revive_final_pos ) )
	{
		level.quick_revive_machine.origin = level.quick_revive_final_pos;
	}
	playfx( level._effect[ "poltergeist" ], level.quick_revive_machine.origin );
	if ( isDefined( level.quick_revive_trigger ) && isDefined( level.quick_revive_trigger.blocker_model ) )
	{
		level.quick_revive_trigger.blocker_model hide();
	}
	level.quick_revive_machine show();
	if ( isDefined( level.quick_revive_machine.original_pos ) )
	{
		level.quick_revive_default_origin = level.quick_revive_machine.original_pos;
		level.quick_revive_default_angles = level.quick_revive_machine.original_angles;
	}
	direction = level.quick_revive_machine.origin;
	direction = ( direction[ 1 ], direction[ 0 ], 0 );
	if ( direction[ 1 ] < 0 || direction[ 0 ] > 0 && direction[ 1 ] > 0 )
	{
		direction = ( direction[ 0 ], direction[ 1 ] * -1, 0 );
	}
	else
	{
		if ( direction[ 0 ] < 0 )
		{
			direction = ( direction[ 0 ] * -1, direction[ 1 ], 0 );
		}
	}
	org = level.quick_revive_default_origin;
	if ( isDefined( level.quick_revive_linked_ent ) )
	{
		org = level.quick_revive_linked_ent.origin;
		if ( isDefined( level.quick_revive_linked_ent_offset ) )
		{
			org += level.quick_revive_linked_ent_offset;
		}
	}
	if ( isDefined( level.quick_revive_linked_ent_moves ) && !level.quick_revive_linked_ent_moves && level.quick_revive_machine.origin != org )
	{
		level.quick_revive_machine moveto( org, 3 );
		level.quick_revive_machine vibrate( direction, 10, 0,5, 2,9 );
		level.quick_revive_machine waittill( "movedone" );
		level.quick_revive_machine.angles = level.quick_revive_default_angles;
	}
	else
	{
		if ( isDefined( level.quick_revive_linked_ent ) )
		{
			org = level.quick_revive_linked_ent.origin;
			if ( isDefined( level.quick_revive_linked_ent_offset ) )
			{
				org += level.quick_revive_linked_ent_offset;
			}
			level.quick_revive_machine.origin = org;
		}
		level.quick_revive_machine vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
	}
	if ( isDefined( level.quick_revive_linked_ent ) )
	{
		level.quick_revive_machine linkto( level.quick_revive_linked_ent );
	}
	level.quick_revive_machine.ishidden = 0;
}

players_are_in_perk_area( perk_machine )
{
	perk_area_origin = level.quick_revive_default_origin;
	if ( isDefined( perk_machine._linked_ent ) )
	{
		perk_area_origin = perk_machine._linked_ent.origin;
		if ( isDefined( perk_machine._linked_ent_offset ) )
		{
			perk_area_origin += perk_machine._linked_ent_offset;
		}
	}
	in_area = 0;
	players = get_players();
	dist_check = 9216;
	_a4349 = players;
	_k4349 = getFirstArrayKey( _a4349 );
	while ( isDefined( _k4349 ) )
	{
		player = _a4349[ _k4349 ];
		if ( distancesquared( player.origin, perk_area_origin ) < dist_check )
		{
			return 1;
		}
		_k4349 = getNextArrayKey( _a4349, _k4349 );
	}
	return 0;
}

perk_hostmigration()
{
	level endon( "end_game" );
	level notify( "perk_hostmigration" );
	level endon( "perk_hostmigration" );
	while ( 1 )
	{
		level waittill( "host_migration_end" );
		jug = getentarray( "vending_jugg", "targetname" );
		tap = getentarray( "vending_doubletap", "targetname" );
		mar = getentarray( "vending_marathon", "targetname" );
		flop = getentarray( "vending_divetonuke", "targetname" );
		deadshot = getentarray( "vending_deadshot", "targetname" );
		tomb = getentarray( "vending_tombstone", "targetname" );
		extraweap = getentarray( "vending_additionalprimaryweapon", "targetname" );
		sleight = getentarray( "vending_sleight", "targetname" );
		revive = getentarray( "vending_revive", "targetname" );
		chugabud = getentarray( "vending_chugabud", "targetname" );
		electric_cherry = getentarray( "vending_electriccherry", "targetname" );
		vulture = getentarray( "vending_vulture", "targetname" );
		_a4389 = jug;
		_k4389 = getFirstArrayKey( _a4389 );
		while ( isDefined( _k4389 ) )
		{
			perk = _a4389[ _k4389 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_jugg_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "jugger_light" );
			}
			_k4389 = getNextArrayKey( _a4389, _k4389 );
		}
		_a4398 = tap;
		_k4398 = getFirstArrayKey( _a4398 );
		while ( isDefined( _k4398 ) )
		{
			perk = _a4398[ _k4398 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_doubletap2_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "doubletap_light" );
			}
			_k4398 = getNextArrayKey( _a4398, _k4398 );
		}
		_a4407 = mar;
		_k4407 = getFirstArrayKey( _a4407 );
		while ( isDefined( _k4407 ) )
		{
			perk = _a4407[ _k4407 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_marathon_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "marathon_light" );
			}
			_k4407 = getNextArrayKey( _a4407, _k4407 );
		}
		_a4416 = flop;
		_k4416 = getFirstArrayKey( _a4416 );
		while ( isDefined( _k4416 ) )
		{
			perk = _a4416[ _k4416 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_nuke_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "divetonuke_light" );
			}
			_k4416 = getNextArrayKey( _a4416, _k4416 );
		}
		_a4425 = deadshot;
		_k4425 = getFirstArrayKey( _a4425 );
		while ( isDefined( _k4425 ) )
		{
			perk = _a4425[ _k4425 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_ads_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "deadshot_light" );
			}
			_k4425 = getNextArrayKey( _a4425, _k4425 );
		}
		_a4434 = tomb;
		_k4434 = getFirstArrayKey( _a4434 );
		while ( isDefined( _k4434 ) )
		{
			perk = _a4434[ _k4434 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_tombstone_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "tombstone_light" );
			}
			_k4434 = getNextArrayKey( _a4434, _k4434 );
		}
		_a4443 = extraweap;
		_k4443 = getFirstArrayKey( _a4443 );
		while ( isDefined( _k4443 ) )
		{
			perk = _a4443[ _k4443 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_three_gun_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "additionalprimaryweapon_light" );
			}
			_k4443 = getNextArrayKey( _a4443, _k4443 );
		}
		_a4452 = sleight;
		_k4452 = getFirstArrayKey( _a4452 );
		while ( isDefined( _k4452 ) )
		{
			perk = _a4452[ _k4452 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_sleight_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "sleight_light" );
			}
			_k4452 = getNextArrayKey( _a4452, _k4452 );
		}
		_a4461 = revive;
		_k4461 = getFirstArrayKey( _a4461 );
		while ( isDefined( _k4461 ) )
		{
			perk = _a4461[ _k4461 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_revive_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "revive_light" );
			}
			_k4461 = getNextArrayKey( _a4461, _k4461 );
		}
		_a4470 = chugabud;
		_k4470 = getFirstArrayKey( _a4470 );
		while ( isDefined( _k4470 ) )
		{
			perk = _a4470[ _k4470 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_revive_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "tombstone_light" );
			}
			_k4470 = getNextArrayKey( _a4470, _k4470 );
		}
		_a4480 = electric_cherry;
		_k4480 = getFirstArrayKey( _a4480 );
		while ( isDefined( _k4480 ) )
		{
			perk = _a4480[ _k4480 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_revive_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "tombstone_light" );
			}
			_k4480 = getNextArrayKey( _a4480, _k4480 );
		}
		_a4510 = vulture;
		_k4510 = getFirstArrayKey( _a4510 );
		while ( isDefined( _k4510 ) )
		{
			perk = _a4510[ _k4510 ];
			if ( isDefined( perk.model ) && perk.model == "zombie_vending_revive_on" )
			{
				perk perk_fx( undefined, 1 );
				perk thread perk_fx( "vulture_light" );
			}
			_k4510 = getNextArrayKey( _a4510, _k4510 );
		}
	}
}

get_perk_array( ignore_chugabud )
{
	perk_array = [];
	if ( self hasperk( "specialty_armorvest" ) )
	{
		perk_array[ perk_array.size ] = "specialty_armorvest";
	}
	if ( self hasperk( "specialty_deadshot" ) )
	{
		perk_array[ perk_array.size ] = "specialty_deadshot";
	}
	if ( self hasperk( "specialty_fastreload" ) )
	{
		perk_array[ perk_array.size ] = "specialty_fastreload";
	}
	if ( self hasperk( "specialty_flakjacket" ) )
	{
		perk_array[ perk_array.size ] = "specialty_flakjacket";
	}
	if ( self hasperk( "specialty_longersprint" ) )
	{
		perk_array[ perk_array.size ] = "specialty_longersprint";
	}
	if ( self hasperk( "specialty_quickrevive" ) )
	{
		perk_array[ perk_array.size ] = "specialty_quickrevive";
	}
	if ( self hasperk( "specialty_rof" ) )
	{
		perk_array[ perk_array.size ] = "specialty_rof";
	}
	if ( self hasperk( "specialty_additionalprimaryweapon" ) )
	{
		perk_array[ perk_array.size ] = "specialty_additionalprimaryweapon";
	}
	if ( !isDefined( ignore_chugabud ) || ignore_chugabud == 0 )
	{
		if ( self hasperk( "specialty_finalstand" ) )
		{
			perk_array[ perk_array.size ] = "specialty_finalstand";
		}
	}
	return perk_array;
}
