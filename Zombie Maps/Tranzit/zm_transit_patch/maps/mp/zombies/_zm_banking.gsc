#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	onplayerconnect_callback( ::onplayerconnect_bank_deposit_box );
	if ( !isDefined( level.ta_vaultfee ) )
	{
		level.ta_vaultfee = 100;
	}
	if ( !isDefined( level.ta_tellerfee ) )
	{
		level.ta_tellerfee = 100;
	}
}

main()
{
	if ( !isDefined( level.banking_map ) )
	{
		level.banking_map = level.script;
	}
	level thread bank_teller_init();
	level thread bank_deposit_box();
}

bank_teller_init()
{
	level.bank_teller_dmg_trig = getent( "bank_teller_tazer_trig", "targetname" );
	if ( isDefined( level.bank_teller_dmg_trig ) )
	{
		level.bank_teller_transfer_trig = getent( level.bank_teller_dmg_trig.target, "targetname" );
		level.bank_teller_powerup_spot = getstruct( level.bank_teller_transfer_trig.target, "targetname" );
		level thread bank_teller_logic();
		level.bank_teller_transfer_trig.origin += vectorScale( ( 0, 0, -1 ), 25 );
		level.bank_teller_transfer_trig trigger_off();
		level.bank_teller_transfer_trig sethintstring( &"ZOMBIE_TELLER_GIVE_MONEY", level.ta_tellerfee );
	}
}

bank_teller_logic()
{
	level endon( "end_game" );
	while ( 1 )
	{
		level.bank_teller_dmg_trig waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, blah );
		if ( isDefined( attacker ) && isplayer( attacker ) && damage == 1500 && type == "MOD_MELEE" )
		{
			bank_teller_give_money();
			level.bank_teller_transfer_trig trigger_off();
		}
	}
}

bank_teller_give_money()
{
	level endon( "end_game" );
	level endon( "stop_bank_teller" );
	level.bank_teller_transfer_trig trigger_on();
	bank_transfer = undefined;
	while ( 1 )
	{
		level.bank_teller_transfer_trig waittill( "trigger", player );
		if ( !is_player_valid( player, 0 ) || player.score < ( 1000 + level.ta_tellerfee ) )
		{
			continue;
		}
		if ( !isDefined( bank_transfer ) )
		{
			bank_transfer = maps/mp/zombies/_zm_powerups::specific_powerup_drop( "teller_withdrawl", level.bank_teller_powerup_spot.origin + vectorScale( ( 0, 0, -1 ), 40 ) );
			bank_transfer thread stop_bank_teller();
			bank_transfer.value = 0;
		}
		bank_transfer.value += 1000;
		bank_transfer notify( "powerup_reset" );
		bank_transfer thread maps/mp/zombies/_zm_powerups::powerup_timeout();
		player maps/mp/zombies/_zm_score::minus_to_player_score( 1000 + level.ta_tellerfee );
		level notify( "bank_teller_used" );
	}
}

stop_bank_teller()
{
	level endon( "end_game" );
	self waittill( "death" );
	level notify( "stop_bank_teller" );
}

delete_bank_teller()
{
	wait 1;
	level notify( "stop_bank_teller" );
	bank_teller_dmg_trig = getent( "bank_teller_tazer_trig", "targetname" );
	bank_teller_transfer_trig = getent( bank_teller_dmg_trig.target, "targetname" );
	bank_teller_dmg_trig delete();
	bank_teller_transfer_trig delete();
}

onplayerconnect_bank_deposit_box()
{
	online_game = sessionmodeisonlinegame();
	if ( !online_game )
	{
		self.account_value = 0;
	}
	else
	{
		self.account_value = self maps/mp/zombies/_zm_stats::get_map_stat( "depositBox", level.banking_map );
	}
}

bank_deposit_box()
{
	level.bank_deposit_max_amount = 250000;
	level.bank_deposit_ddl_increment_amount = 1000;
	level.bank_account_max = level.bank_deposit_max_amount / level.bank_deposit_ddl_increment_amount;
	level.bank_account_increment = int( level.bank_deposit_ddl_increment_amount / 1000 );
	deposit_triggers = getstructarray( "bank_deposit", "targetname" );
	array_thread( deposit_triggers, ::bank_deposit_unitrigger );
	withdraw_triggers = getstructarray( "bank_withdraw", "targetname" );
	array_thread( withdraw_triggers, ::bank_withdraw_unitrigger );
}

bank_deposit_unitrigger()
{
	bank_unitrigger( "bank_deposit", ::trigger_deposit_update_prompt, ::trigger_deposit_think, 5, 5, undefined, 5 );
}

bank_withdraw_unitrigger()
{
	bank_unitrigger( "bank_withdraw", ::trigger_withdraw_update_prompt, ::trigger_withdraw_think, 5, 5, undefined, 5 );
}

bank_unitrigger( name, prompt_fn, think_fn, override_length, override_width, override_height, override_radius )
{
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = self.origin;
	if ( isDefined( self.script_angles ) )
	{
		unitrigger_stub.angles = self.script_angles;
	}
	else
	{
		unitrigger_stub.angles = self.angles;
	}
	unitrigger_stub.script_angles = unitrigger_stub.angles;
	if ( isDefined( override_length ) )
	{
		unitrigger_stub.script_length = override_length;
	}
	else if ( isDefined( self.script_length ) )
	{
		unitrigger_stub.script_length = self.script_length;
	}
	else
	{
		unitrigger_stub.script_length = 32;
	}
	if ( isDefined( override_width ) )
	{
		unitrigger_stub.script_width = override_width;
	}
	else if ( isDefined( self.script_width ) )
	{
		unitrigger_stub.script_width = self.script_width;
	}
	else
	{
		unitrigger_stub.script_width = 32;
	}
	if ( isDefined( override_height ) )
	{
		unitrigger_stub.script_height = override_height;
	}
	else if ( isDefined( self.script_height ) )
	{
		unitrigger_stub.script_height = self.script_height;
	}
	else
	{
		unitrigger_stub.script_height = 64;
	}
	if ( isDefined( override_radius ) )
	{
		unitrigger_stub.script_radius = override_radius;
	}
	else if ( isDefined( self.radius ) )
	{
		unitrigger_stub.radius = self.radius;
	}
	else
	{
		unitrigger_stub.radius = 32;
	}
	if ( isDefined( self.script_unitrigger_type ) )
	{
		unitrigger_stub.script_unitrigger_type = self.script_unitrigger_type;
	}
	else
	{
		unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
		unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length / 2 );
	}
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	unitrigger_stub.targetname = name;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	unitrigger_stub.prompt_and_visibility_func = prompt_fn;
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, think_fn );
}

trigger_deposit_update_prompt( player )
{
	if ( player.score < level.bank_deposit_ddl_increment_amount || player.account_value >= level.bank_account_max )
	{
		player show_balance();
		self sethintstring( "" );
		return 0;
	}
	self sethintstring( &"ZOMBIE_BANK_DEPOSIT_PROMPT", level.bank_deposit_ddl_increment_amount );
	return 1;
}

trigger_deposit_think()
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		while ( !is_player_valid( player ) )
		{
			continue;
		}
		if ( player.score >= level.bank_deposit_ddl_increment_amount && player.account_value < level.bank_account_max )
		{
			player playsoundtoplayer( "zmb_vault_bank_deposit", player );
			player.score -= level.bank_deposit_ddl_increment_amount;
			player.account_value += level.bank_account_increment;
			player maps/mp/zombies/_zm_stats::set_map_stat( "depositBox", player.account_value, level.banking_map );
			if ( isDefined( level.custom_bank_deposit_vo ) )
			{
				player thread [[ level.custom_bank_deposit_vo ]]();
			}
			if ( player.account_value >= level.bank_account_max )
			{
				self sethintstring( "" );
			}
		}
		else
		{
			player thread do_player_general_vox( "general", "exert_sigh", 10, 50 );
		}
		player show_balance();
	}
}

trigger_withdraw_update_prompt( player )
{
	if ( player.account_value <= 0 )
	{
		self sethintstring( "" );
		player show_balance();
		return 0;
	}
	self sethintstring( &"ZOMBIE_BANK_WITHDRAW_PROMPT", level.bank_deposit_ddl_increment_amount, level.ta_vaultfee );
	return 1;
}

trigger_withdraw_think()
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		while ( !is_player_valid( player ) )
		{
			continue;
		}
		if ( player.account_value >= level.bank_account_increment )
		{
			player playsoundtoplayer( "zmb_vault_bank_withdraw", player );
			player.score += level.bank_deposit_ddl_increment_amount;
			level notify( "bank_withdrawal" );
			player.account_value -= level.bank_account_increment;
			player maps/mp/zombies/_zm_stats::set_map_stat( "depositBox", player.account_value, level.banking_map );
			if ( isDefined( level.custom_bank_withdrawl_vo ) )
			{
				player thread [[ level.custom_bank_withdrawl_vo ]]();
			}
			else
			{
				player thread do_player_general_vox( "general", "exert_laugh", 10, 50 );
			}
			player thread player_withdraw_fee();
			if ( player.account_value < level.bank_account_increment )
			{
				self sethintstring( "" );
			}
		}
		else
		{
			player thread do_player_general_vox( "general", "exert_sigh", 10, 50 );
		}
		player show_balance();
	}
}

player_withdraw_fee()
{
	self endon( "disconnect" );
	wait_network_frame();
	self.score -= level.ta_vaultfee;
}

show_balance()
{
/#
	iprintlnbold( "DEBUG BANKER: " + self.name + " account worth " + self.account_value );
#/
}
