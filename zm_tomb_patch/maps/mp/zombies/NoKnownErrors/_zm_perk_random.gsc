#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked 100% parity
{
	level._random_zombie_perk_cost = 1500;
	level thread precache();
	level thread init_machines();
	registerclientfield( "scriptmover", "perk_bottle_cycle_state", 14000, 2, "int" );
	registerclientfield( "scriptmover", "turn_active_perk_light_red", 14000, 1, "int" );
	registerclientfield( "scriptmover", "turn_active_perk_light_green", 14000, 1, "int" );
	registerclientfield( "scriptmover", "turn_on_location_indicator", 14000, 1, "int" );
	registerclientfield( "scriptmover", "turn_active_perk_ball_light", 14000, 1, "int" );
	registerclientfield( "scriptmover", "zone_captured", 14000, 1, "int" );
	level._effect[ "perk_machine_light" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light" );
	level._effect[ "perk_machine_light_red" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light_red" );
	level._effect[ "perk_machine_light_green" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light_green" );
	level._effect[ "perk_machine_steam" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_steam" );
	level._effect[ "perk_machine_location" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_identify" );
	level._effect[ "perk_machine_activation_electric_loop" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_on" );
	flag_init( "machine_can_reset" );

}

init_machines()
{
	machines = getentarray("random_perk_machine", "targetname");
	foreach(machine in machines)
	{
		machine.artifact_glow_setting = 1;
		machine.machinery_glow_setting = 0;
		machine.is_current_ball_location = 0;
		machine.unitrigger_stub = spawnstruct();
		machine.unitrigger_stub.origin = machine.origin + AnglesToRight(machine.angles) * 22.5;
		machine.unitrigger_stub.angles = machine.angles;
		machine.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
		machine.unitrigger_stub.script_width = 64;
		machine.unitrigger_stub.script_height = 64;
		machine.unitrigger_stub.script_length = 64;
		machine.unitrigger_stub.trigger_target = machine;
		unitrigger_force_per_player_triggers(machine.unitrigger_stub, 1);
		machine.unitrigger_stub.prompt_and_visibility_func = ::wunderfizztrigger_update_prompt;
		level thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger(machine.unitrigger_stub, ::wunderfizz_unitrigger_think);
	}
}

wunderfizztrigger_update_prompt( player ) //checked 100% parity
{
	can_use = self wunderfizzstub_update_prompt( player );
	if ( isDefined( self.hint_string ) )
	{
		if ( isDefined( self.hint_parm1 ) )
		{
			self sethintstring( self.hint_string, self.hint_parm1 );
		}
		else
		{
			self sethintstring( self.hint_string );
		}
	}
	return can_use;
}

wunderfizzstub_update_prompt( player ) //checked 100% parity
{
	self setcursorhint( "HINT_NOICON" );
	if ( !self trigger_visible_to_player( player ) )
	{
		return 0;
	}
	self.hint_parm1 = undefined;
	if ( isDefined( self.stub.trigger_target.is_locked ) && self.stub.trigger_target.is_locked )
	{
		self.hint_string = &"ZM_TOMB_RPU";
		return 0;
	}
	else
	{
		if ( self.stub.trigger_target.is_current_ball_location )
		{
			if ( isDefined( self.stub.trigger_target.machine_user ) )
			{
				if ( isDefined( self.stub.trigger_target.grab_perk_hint ) && self.stub.trigger_target.grab_perk_hint )
				{
					n_purchase_limit = player get_player_perk_purchase_limit();
					if ( player.num_perks >= n_purchase_limit )
					{
						self.hint_string = &"ZM_TOMB_RPT";
						self.hint_parm1 = n_purchase_limit;
						return 0;
					}
					else
					{
						self.hint_string = &"ZM_TOMB_RPP";
						return 1;
					}
				}
				else
				{
					return 0;
				}
			}
			else
			{
				n_purchase_limit = player get_player_perk_purchase_limit();
				if ( player.num_perks >= n_purchase_limit )
				{
					self.hint_string = &"ZM_TOMB_RPT";
					self.hint_parm1 = n_purchase_limit;
					return 0;
				}
				else
				{
					self.hint_string = &"ZM_TOMB_RPB";
					self.hint_parm1 = level._random_zombie_perk_cost;
					return 1;
				}
			}
		}
		else
		{
			self.hint_string = &"ZM_TOMB_RPE";
			return 0;
		}
	}
}

trigger_visible_to_player( player ) //checked 100% parity
{
	self setinvisibletoplayer(player);
	visible = 1;
	if(isdefined(self.stub.trigger_target.machine_user))
	{
		if(player != self.stub.trigger_target.machine_user || is_placeable_mine(self.stub.trigger_target.machine_user getcurrentweapon()))
		{
			visible = 0;
		}
	}
	else if(!player can_buy_perk())
	{
		visible = 0;
	}
	if(!visible)
	{
		return 0;
	}
	self setvisibletoplayer(player);
	return 1;
}

can_buy_perk() //checked 100% parity
{
	if ( isDefined( self.is_drinking ) && self.is_drinking > 0 )
	{
		return 0;
	}
	current_weapon = self getcurrentweapon();
	if ( is_placeable_mine( current_weapon ) || is_equipment_that_blocks_purchase( current_weapon ) )
	{
		return 0;
	}
	if ( self in_revive_trigger() )
	{
		return 0;
	}
	if ( current_weapon == "none" )
	{
		return 0;
	}
	return 1;
}

init_animtree() //checked 100% parity
{	
	scriptmodelsuseanimtree( -1 );
}

start_random_machine() //checked 100% parity
{
	level thread machines_setup();
	level thread machine_selector();
}

precache() //checked 100% parity
{
	precachemodel( "p6_zm_vending_diesel_magic" );
	precachemodel( "t6_wpn_zmb_perk_bottle_bear_world" );
}


machines_setup() //checked 100% parity
{
	wait(0.5);
	level.perk_bottle_weapon_array = arraycombine(level.machine_assets, level._custom_perks, 0, 1);
	start_machines = getentarray("start_machine", "script_noteworthy");
	machines = getentarray("random_perk_machine", "targetname");
	//level.random_perk_start_machine = machines[5];
	/*
	notes
	gen1 is machines[5]
	gen2 is machines[0]
	gen3 is machines[1]
	gen4 is machines[2]
	gen5 is machines[3]
	gen6 is machines[4]

	*/
	
	
	if(start_machines.size == 1)
	{
		level.random_perk_start_machine = start_machines[0];
	}
	else
	{
		level.random_perk_start_machine = start_machines[randomint(start_machines.size)];
	}
	
	
	foreach(machine in machines)
	{
		spawn_location = spawn("script_model", machine.origin);
		spawn_location setmodel("tag_origin");
		spawn_location.angles = machine.angles;
		forward_dir = AnglesToRight(machine.angles);
		spawn_location.origin = spawn_location.origin + VectorScale( 0, 0, 1, 65);
		machine.bottle_spawn_location = spawn_location;
		machine useanimtree(-1);
		//broken currently
		machine thread machine_power_indicators();
		if(machine != level.random_perk_start_machine)
		{
			machine hidepart("j_ball");
			machine.is_current_ball_location = 0;
		}
		else
		{
			level.wunderfizz_starting_machine = machine;
			level notify("wunderfizz_setup");
			machine thread machine_think();
		}
		wait_network_frame();
	}
}

machine_power_indicators() //checked 100% parity
{
	self setclientfield( "zone_captured", 1 );
	wait 1;
	self setclientfield( "zone_captured", 0 );
	while ( 1 )
	{
		self conditional_power_indicators();
		while ( isDefined( self.is_locked ) && self.is_locked )
		{
			wait 1;
		}
		self conditional_power_indicators();
		while ( !isDefined( self.is_locked ) || !self.is_locked )
		{
			wait 1;
		}
		wait 0.05;
	}
}

conditional_power_indicators() //checked 100% parity
{
	if(isdefined(self.is_locked) && self.is_locked)
	{
		self setclientfield("turn_active_perk_light_red", 0);
		self setclientfield("turn_active_perk_light_green", 0);
		self setclientfield("turn_active_perk_ball_light", 0);
		self setclientfield("zone_captured", 0);
	}
	else if(self.is_current_ball_location)
	{
		self setclientfield("turn_active_perk_light_red", 0);
		self setclientfield("turn_active_perk_light_green", 1);
		self setclientfield("turn_active_perk_ball_light", 1);
		self setclientfield("zone_captured", 1);
	}
	else
	{
		self setclientfield("turn_active_perk_light_red", 1);
		self setclientfield("turn_active_perk_light_green", 0);
		self setclientfield("turn_active_perk_ball_light", 0);
		self setclientfield("zone_captured", 1);
	}
}

wunderfizz_unitrigger_think( player ) //checked 100% parity
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		self.stub.trigger_target notify( "trigger" );
		level.players_wunderfizz = player; //better way to define player
	}
}

machine_think() //checked 80% parity
{
	level notify("machine_think");
	level endon("machine_think");
	self thread machine_sounds();
	self show();
	self.num_time_used = 0; //0 normally
	self.num_til_moved = randomintrange(4, 7);
	self.is_current_ball_location = 1;
	self setclientfield("turn_on_location_indicator", 1);
	self showpart("j_ball");
	self thread update_animation("start");
	while(isdefined(self.is_locked) && self.is_locked)
	{
		wait(1);
	}
	self conditional_power_indicators();
	while(1)
	{
		self waittill("trigger", level.players_wunderfizz);
		flag_clear("machine_can_reset");
		player = level.players_wunderfizz;
		if(player.score < level._random_zombie_perk_cost)
		{
			self playsound("evt_perk_deny");
			player maps/mp/zombies/_zm_audio::create_and_play_dialog("general", "perk_deny", undefined, 0);
			continue;
		}
		if(self.num_time_used >= self.num_til_moved)
		{
			level notify("pmmove");
			self thread update_animation("shut_down");
			level notify("random_perk_moving");
			self setclientfield("turn_on_location_indicator", 0);
			self.is_current_ball_location = 0;
			self conditional_power_indicators();
			self hidepart("j_ball");
			return;
		}
		self.machine_user = player;
		self.num_time_used++;
		player maps/mp/zombies/_zm_stats::increment_client_stat("use_perk_random");
		player maps/mp/zombies/_zm_stats::increment_player_stat("use_perk_random");
		
		player maps/mp/zombies/_zm_score::minus_to_player_score(level._random_zombie_perk_cost);
		
		
		self thread update_animation("in_use");
		if(isdefined(level.perk_random_vo_func_usemachine) && isdefined(player))
		{
			player thread [[level.perk_random_vo_func_usemachine]]();
		}

		while(1)
		{
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger(self.unitrigger_stub);
			
			random_perk = get_weighted_random_perk(player);
			
			self setclientfield("perk_bottle_cycle_state", 1);
			level notify("pmstrt");
			wait(1);
			self thread start_perk_bottle_cycling();
			self thread perk_bottle_motion();
			model = get_perk_weapon_model(random_perk);
			wait(3);
			self notify("done_cycling");
			if(self.num_time_used >= self.num_til_moved)
			{
				self.bottle_spawn_location setmodel("t6_wpn_zmb_perk_bottle_bear_world");
				level notify("pmmove");
				self thread update_animation("shut_down");
				wait(3);
				player maps/mp/zombies/_zm_score::add_to_player_score(level._random_zombie_perk_cost);
				self.bottle_spawn_location setmodel("tag_origin");
				level notify("random_perk_moving");
				self setclientfield("perk_bottle_cycle_state", 0);
				self setclientfield("turn_on_location_indicator", 0);
				self.is_current_ball_location = 0;
				self conditional_power_indicators();
				self hidepart("j_ball");
				self.machine_user = undefined;
				thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger(self.unitrigger_stub, ::wunderfizz_unitrigger_think);
				break;
			}
			else
			{
				self.bottle_spawn_location setmodel(model);
			}
			self.grab_perk_hint = 1;
			thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger(self.unitrigger_stub, ::wunderfizz_unitrigger_think);

			self thread grab_check(player, random_perk);
			
			self thread time_out_check();
			self waittill_either("grab_check", "time_out_check");
			self.grab_perk_hint = 0;
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger(self.unitrigger_stub);
			thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger(self.unitrigger_stub, ::wunderfizz_unitrigger_think);
			level notify("pmstop");
			if(player.num_perks >= player get_player_perk_purchase_limit())
			{
				player maps/mp/zombies/_zm_score::add_to_player_score(level._random_zombie_perk_cost);
			}
			self setclientfield("perk_bottle_cycle_state", 0);
			self.machine_user = undefined;
			self.bottle_spawn_location setmodel("tag_origin");
			self thread update_animation("idle");
			break;
		}
		flag_wait("machine_can_reset");
	}
}

grab_check( player, random_perk ) //checked 100% parity
{
	self endon("time_out_check");
	perk_is_bought = 0;
	while(!perk_is_bought)
	{
		self waittill("trigger", e_triggerer);
		if(e_triggerer == player)
		{
			while ( isDefined( player.is_drinking ) && player.is_drinking > 0 )
			{
				wait 0.1;
			}
			if(player.num_perks < level.perk_purchase_limit )
			{
				perk_is_bought = 1;
			}
			else
			{
				self playsound("evt_perk_deny");
				player maps/mp/zombies/_zm_audio::create_and_play_dialog("general", "sigh");
				self notify("time_out_or_perk_grab");
				return;
			}
		}
	}
	player maps/mp/zombies/_zm_stats::increment_client_stat("grabbed_from_perk_random");
	player maps/mp/zombies/_zm_stats::increment_player_stat("grabbed_from_perk_random");
	player thread monitor_when_player_acquires_perk();
	self notify("grab_check");
	self notify("time_out_or_perk_grab");
	gun = player maps/mp/zombies/_zm_perks::perk_give_bottle_begin(random_perk);
	evt = player waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete");
	
	if(evt == "weapon_change_complete")
	{
		player thread maps/mp/zombies/_zm_perks::wait_give_perk(random_perk, 1);
	}
	
	player maps/mp/zombies/_zm_perks::perk_give_bottle_end(gun, random_perk);
	
	if( isDefined( player.has_drunk_wunderfizz ) && !player.has_drunk_wunderfizz )
	{
		player do_player_general_vox("wunderfizz", "perk_wonder", undefined, 100);
		player.has_drunk_wunderfizz = 1;
	}
}

monitor_when_player_acquires_perk() //checked 100% parity
{
	self waittill_any( "perk_acquired", "death_or_disconnect", "player_downed" );
	flag_set( "machine_can_reset" );
}

time_out_check() //checked 100% parity
{
	self endon( "grab_check" );
	wait 10;
	self notify( "time_out_check" );
	flag_set( "machine_can_reset" );
}

machine_selector() //fixed has 100% parity 
{
	while ( 1 )
	{
		level waittill( "random_perk_moving" );
		machines = getentarray( "random_perk_machine", "targetname" );
		if(machines.size == 1)
		{
			new_machine = machines[0];
			new_machine thread machine_think();
			continue;
		}
		else 
		{
			new_machine = machines[ randomint( machines.size ) ];
			level.random_perk_start_machine = new_machine;
		}
		wait 10;
		new_machine thread machine_think();
	}
}

include_perk_in_random_rotation( perk ) //checked 100% parity
{
	if ( !isDefined( level._random_perk_machine_perk_list ) )
	{
		level._random_perk_machine_perk_list = [];
	}
	level._random_perk_machine_perk_list = add_to_array( level._random_perk_machine_perk_list, perk );
}

get_weighted_random_perk( player ) //checked 100% parity
{
	keys = array_randomize(getarraykeys(level._random_perk_machine_perk_list));
	if(isdefined(level.custom_random_perk_weights))
	{
		keys = player [[level.custom_random_perk_weights]]();
	}
	i = 0;
	while ( i < keys.size )
	{
		if ( player hasperk( level._random_perk_machine_perk_list[ keys[ i ] ] ) )
		{
			i++;
			continue;
		}
		return level._random_perk_machine_perk_list[ keys[ i ] ];
		i++;
	}
	return level._random_perk_machine_perk_list[ keys[ 0 ] ];
}
perk_bottle_motion() //checked 100% parity
{
	putouttime = 3;
	putbacktime = 10;
	v_float = anglesToForward( self.angles - ( 0, 90, 0 ) ) * 10;
	self.bottle_spawn_location.origin = self.origin + ( 0, 0, 53 );
	self.bottle_spawn_location.angles = self.angles;
	self.bottle_spawn_location.origin -= v_float;
	self.bottle_spawn_location moveto( self.bottle_spawn_location.origin + v_float, putouttime, putouttime * 0.5 );
	self.bottle_spawn_location.angles += ( 0, 0, 10 );
	self.bottle_spawn_location rotateyaw( 720, putouttime, putouttime * 0.5 );
	self waittill( "done_cycling" );
	self.bottle_spawn_location.angles = self.angles;
	self.bottle_spawn_location moveto( self.bottle_spawn_location.origin - v_float, putbacktime, putbacktime * 0.5 );
	self.bottle_spawn_location rotateyaw( 90, putbacktime, putbacktime * 0.5 );
}

start_perk_bottle_cycling() //checked 100% parity
{
	self endon("done_cycling");
	array_key = getarraykeys(level.perk_bottle_weapon_array);
	timer = 0;
	while(1)
	{
		for(i = 0; i < array_key.size; i++)
		{
			perk_bottle_list = array_key[i];
			if(isdefined(level.perk_bottle_weapon_array[perk_bottle_list].weapon))
			{
				model = getweaponmodel(level.perk_bottle_weapon_array[perk_bottle_list].weapon);
			}
			else
			{
				model = getweaponmodel(level.perk_bottle_weapon_array[perk_bottle_list].perk_bottle);
			}
			self.bottle_spawn_location setmodel(model);
			wait(0.2);
		}
	}
}

get_perk_weapon_model( perk ) //checked 100% parity
{
	switch( perk )
	{
		case " _upgrade":
		case "specialty_armorvest":
			weapon = level.machine_assets[ "juggernog" ].weapon;
			break;
		case "specialty_quickrevive":
		case "specialty_quickrevive_upgrade":
			weapon = level.machine_assets[ "revive" ].weapon;
			break;
		case "specialty_fastreload":
		case "specialty_fastreload_upgrade":
			weapon = level.machine_assets[ "speedcola" ].weapon;
			break;
		case "specialty_rof":
		case "specialty_rof_upgrade":
			weapon = level.machine_assets[ "doubletap" ].weapon;
			break;
		case "specialty_longersprint":
		case "specialty_longersprint_upgrade":
			weapon = level.machine_assets[ "marathon" ].weapon;
			break;
		case "specialty_flakjacket":
		case "specialty_flakjacket_upgrade":
			weapon = level.machine_assets[ "divetonuke" ].weapon;
			break;
		case "specialty_deadshot":
		case "specialty_deadshot_upgrade":
			weapon = level.machine_assets[ "deadshot" ].weapon;
			break;
		case "specialty_additionalprimaryweapon":
		case "specialty_additionalprimaryweapon_upgrade":
			weapon = level.machine_assets[ "additionalprimaryweapon" ].weapon;
			break;
		case "specialty_scavenger":
		case "specialty_scavenger_upgrade":
			weapon = level.machine_assets[ "tombstone" ].weapon;
			break;
		case "specialty_finalstand":
		case "specialty_finalstand_upgrade":
			weapon = level.machine_assets[ "whoswho" ].weapon;
			break;
	}
	if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].perk_bottle ) )
	{
		weapon = level._custom_perks[ perk ].perk_bottle;
	}
	return getweaponmodel( weapon );
}

update_animation( animation )
{
	switch( animation )
	{
		case "start":
			self clearanim( %root, 0.2 );
			self setanim( %o_zombie_dlc4_vending_diesel_turn_on, 1, 0.2, 1 );
			break;
		case "shut_down":
			self clearanim( %root, 0.2 );
			self setanim( %o_zombie_dlc4_vending_diesel_turn_off, 1, 0.2, 1 );
			break;
		case "in_use":
			self clearanim( %root, 0.2 );
			self setanim( %o_zombie_dlc4_vending_diesel_ballspin_loop, 1, 0.2, 1 );
			break;
		case "idle":
			self clearanim( %root, 0.2 );
			self setanim( %o_zombie_dlc4_vending_diesel_on_idle, 1, 0.2, 1 );
			break;
		default:
			self clearanim( %root, 0.2 );
			self setanim( %o_zombie_dlc4_vending_diesel_on_idle, 1, 0.2, 1 );
			break;
	}
}

machine_sounds() //checked 100% parity
{
	level endon( "machine_think" );
	while ( 1 )
	{
		level waittill( "pmstrt" );
		rndprk_ent = spawn( "script_origin", self.origin );
		rndprk_ent stopsounds();
		rndprk_ent playsound( "zmb_rand_perk_start" );
		rndprk_ent playloopsound( "zmb_rand_perk_loop", 0.5 );
		state_switch = level waittill_any_return( "pmstop", "pmmove" );
		rndprk_ent stoploopsound( 1 );
		if ( state_switch == "pmstop" )
		{
			rndprk_ent playsound( "zmb_rand_perk_stop" );
		}
		else
		{
			rndprk_ent playsound( "zmb_rand_perk_leave" );
		}
		rndprk_ent delete();
	}
}






