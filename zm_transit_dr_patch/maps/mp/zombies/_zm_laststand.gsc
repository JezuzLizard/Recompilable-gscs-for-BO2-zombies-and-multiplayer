#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_chugabud;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/_demo;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

laststand_global_init()
{
	level.const_laststand_getup_count_start = 0;
	level.const_laststand_getup_bar_start = 0,5;
	level.const_laststand_getup_bar_regen = 0,0025;
	level.const_laststand_getup_bar_damage = 0,1;
}

init()
{
	if ( level.script == "frontend" )
	{
		return;
	}
	laststand_global_init();
	level.revive_tool = "syrette_zm";
	precacheitem( level.revive_tool );
	precachestring( &"GAME_BUTTON_TO_REVIVE_PLAYER" );
	precachestring( &"GAME_PLAYER_NEEDS_TO_BE_REVIVED" );
	precachestring( &"GAME_PLAYER_IS_REVIVING_YOU" );
	precachestring( &"GAME_REVIVING" );
	if ( !isDefined( level.laststandpistol ) )
	{
		level.laststandpistol = "m1911";
		precacheitem( level.laststandpistol );
	}
	level thread revive_hud_think();
	level.primaryprogressbarx = 0;
	level.primaryprogressbary = 110;
	level.primaryprogressbarheight = 4;
	level.primaryprogressbarwidth = 120;
	level.primaryprogressbary_ss = 280;
	if ( getDvar( "revive_trigger_radius" ) == "" )
	{
		setdvar( "revive_trigger_radius", "40" );
	}
	level.laststandgetupallowed = 0;
}

player_is_in_laststand()
{
	if ( isDefined( self.no_revive_trigger ) && !self.no_revive_trigger )
	{
		return isDefined( self.revivetrigger );
	}
	else
	{
		if ( isDefined( self.laststand ) )
		{
			return self.laststand;
		}
	}
}

player_num_in_laststand()
{
	num = 0;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ] player_is_in_laststand() )
		{
			num++;
		}
		i++;
	}
	return num;
}

player_all_players_in_laststand()
{
	return player_num_in_laststand() == get_players().size;
}

player_any_player_in_laststand()
{
	return player_num_in_laststand() > 0;
}

player_last_stand_stats( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( isDefined( attacker ) && isplayer( attacker ) && attacker != self )
	{
		if ( level.gametype == "zcleansed" )
		{
			maps/mp/_demo::bookmark( "kill", getTime(), self, attacker, 0, einflictor );
		}
		if ( level.gametype == "zcleansed" )
		{
			if ( isDefined( attacker.is_zombie ) && !attacker.is_zombie )
			{
				attacker.kills++;
			}
			else
			{
				attacker.downs++;
			}
		}
		else
		{
			attacker.kills++;
		}
		attacker maps/mp/zombies/_zm_stats::increment_client_stat( "kills" );
		attacker maps/mp/zombies/_zm_stats::increment_player_stat( "kills" );
		if ( isDefined( sweapon ) )
		{
			dmgweapon = sweapon;
			if ( is_alt_weapon( dmgweapon ) )
			{
				dmgweapon = weaponaltweaponname( dmgweapon );
			}
			attacker addweaponstat( dmgweapon, "kills", 1 );
		}
		if ( is_headshot( sweapon, shitloc, smeansofdeath ) )
		{
			attacker.headshots++;
			attacker maps/mp/zombies/_zm_stats::increment_client_stat( "headshots" );
			attacker addweaponstat( sweapon, "headshots", 1 );
			attacker maps/mp/zombies/_zm_stats::increment_player_stat( "headshots" );
		}
	}
	self increment_downed_stat();
	if ( flag( "solo_game" ) && getnumconnectedplayers() < 2 )
	{
		self maps/mp/zombies/_zm_stats::increment_client_stat( "deaths" );
		self maps/mp/zombies/_zm_stats::increment_player_stat( "deaths" );
		self maps/mp/zombies/_zm_pers_upgrades::pers_upgrade_jugg_player_death_stat();
	}
}

increment_downed_stat()
{
	if ( level.gametype != "zcleansed" )
	{
		self.downs++;
	}
	self maps/mp/zombies/_zm_stats::increment_client_stat( "downs" );
	self add_weighted_down();
	self maps/mp/zombies/_zm_stats::increment_player_stat( "downs" );
	zonename = self get_current_zone();
	if ( !isDefined( zonename ) )
	{
		zonename = "";
	}
	self recordplayerdownzombies( zonename );
}

playerlaststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	self notify( "entering_last_stand" );
	if ( isDefined( level._game_module_player_laststand_callback ) )
	{
		self [[ level._game_module_player_laststand_callback ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	}
	if ( self player_is_in_laststand() )
	{
		return;
	}
	if ( isDefined( self.in_zombify_call ) && self.in_zombify_call )
	{
		return;
	}
	self thread player_last_stand_stats( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	if ( isDefined( level.playerlaststand_func ) )
	{
		[[ level.playerlaststand_func ]]( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	}
	self.health = 1;
	self.laststand = 1;
	self.ignoreme = 1;
	self thread maps/mp/gametypes_zm/_gameobjects::onplayerlaststand();
	self thread maps/mp/zombies/_zm_buildables::onplayerlaststand();
	if ( isDefined( self.no_revive_trigger ) && !self.no_revive_trigger )
	{
		self revive_trigger_spawn();
	}
	else
	{
		self undolaststand();
	}
	if ( isDefined( self.is_zombie ) && self.is_zombie )
	{
		self takeallweapons();
		if ( isDefined( attacker ) && isplayer( attacker ) && attacker != self )
		{
			attacker notify( "killed_a_zombie_player" );
		}
	}
	else
	{
		self laststand_disable_player_weapons();
		self laststand_give_pistol();
	}
	if ( isDefined( level.playersuicideallowed ) && level.playersuicideallowed && get_players().size > 1 )
	{
		if ( !isDefined( level.canplayersuicide ) || self [[ level.canplayersuicide ]]() )
		{
			self thread suicide_trigger_spawn();
		}
	}
	if ( isDefined( self.disabled_perks ) )
	{
		self.disabled_perks = [];
	}
	if ( level.laststandgetupallowed )
	{
		self thread laststand_getup();
	}
	else
	{
		bleedout_time = getDvarFloat( "player_lastStandBleedoutTime" );
		self thread laststand_bleedout( bleedout_time );
	}
	if ( level.gametype != "zcleansed" )
	{
		maps/mp/_demo::bookmark( "zm_player_downed", getTime(), self );
	}
	self notify( "player_downed" );
	self thread refire_player_downed();
	self thread cleanup_laststand_on_disconnect();
}

refire_player_downed()
{
	self endon( "player_revived" );
	self endon( "death" );
	self endon( "disconnect" );
	wait 1;
	if ( self.num_perks )
	{
		self notify( "player_downed" );
	}
}

laststand_allowed( sweapon, smeansofdeath, shitloc )
{
	if ( level.laststandpistol == "none" )
	{
		return 0;
	}
	return 1;
}

laststand_disable_player_weapons()
{
	weaponinventory = self getweaponslist( 1 );
	self.lastactiveweapon = self getcurrentweapon();
	if ( self isthrowinggrenade() && is_offhand_weapon( self.lastactiveweapon ) )
	{
		primaryweapons = self getweaponslistprimaries();
		if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
		{
			self.lastactiveweapon = primaryweapons[ 0 ];
			self switchtoweaponimmediate( self.lastactiveweapon );
		}
	}
	self setlaststandprevweap( self.lastactiveweapon );
	self.laststandpistol = undefined;
	self.hadpistol = 0;
	if ( isDefined( self.weapon_taken_by_losing_specialty_additionalprimaryweapon ) && self.lastactiveweapon == self.weapon_taken_by_losing_specialty_additionalprimaryweapon )
	{
		self.lastactiveweapon = "none";
		self.weapon_taken_by_losing_specialty_additionalprimaryweapon = undefined;
	}
	i = 0;
	while ( i < weaponinventory.size )
	{
		weapon = weaponinventory[ i ];
		class = weaponclass( weapon );
		if ( issubstr( weapon, "knife_ballistic_" ) )
		{
			class = "knife";
		}
		if ( class != "pistol" && class != "pistol spread" && class == "pistolspread" && !isDefined( self.laststandpistol ) )
		{
			self.laststandpistol = weapon;
			self.hadpistol = 1;
		}
		if ( weapon == "syrette_zm" )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "failed_sacrifices" );
			self maps/mp/zombies/_zm_stats::increment_player_stat( "failed_sacrifices" );
		}
		else
		{
			if ( is_zombie_perk_bottle( weapon ) )
			{
				self takeweapon( weapon );
				self.lastactiveweapon = "none";
				i++;
				continue;
			}
		}
		else if ( isDefined( get_gamemode_var( "item_meat_name" ) ) )
		{
			if ( weapon == get_gamemode_var( "item_meat_name" ) )
			{
				self takeweapon( weapon );
				self.lastactiveweapon = "none";
				i++;
				continue;
			}
		}
		i++;
	}
	if ( isDefined( self.hadpistol ) && self.hadpistol == 1 && isDefined( level.zombie_last_stand_pistol_memory ) )
	{
		self [[ level.zombie_last_stand_pistol_memory ]]();
	}
	if ( !isDefined( self.laststandpistol ) )
	{
		self.laststandpistol = level.laststandpistol;
	}
	self disableweaponcycling();
	self notify( "weapons_taken_for_last_stand" );
}

laststand_enable_player_weapons()
{
	if ( isDefined( self.hadpistol ) && !self.hadpistol && isDefined( self.laststandpistol ) )
	{
		self takeweapon( self.laststandpistol );
	}
	if ( isDefined( self.hadpistol ) && self.hadpistol == 1 && isDefined( level.zombie_last_stand_ammo_return ) )
	{
		[[ level.zombie_last_stand_ammo_return ]]();
	}
	self enableweaponcycling();
	self enableoffhandweapons();
	if ( isDefined( self.lastactiveweapon ) && self.lastactiveweapon != "none" && !is_placeable_mine( self.lastactiveweapon ) && !is_equipment( self.lastactiveweapon ) )
	{
		self switchtoweapon( self.lastactiveweapon );
	}
	else
	{
		primaryweapons = self getweaponslistprimaries();
		if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
		{
			self switchtoweapon( primaryweapons[ 0 ] );
		}
	}
}

laststand_clean_up_on_disconnect( playerbeingrevived, revivergun )
{
	self endon( "do_revive_ended_normally" );
	revivetrigger = playerbeingrevived.revivetrigger;
	playerbeingrevived waittill( "disconnect" );
	if ( isDefined( revivetrigger ) )
	{
		revivetrigger delete();
	}
	self cleanup_suicide_hud();
	if ( isDefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar destroyelem();
	}
	if ( isDefined( self.revivetexthud ) )
	{
		self.revivetexthud destroy();
	}
	self revive_give_back_weapons( revivergun );
}

laststand_clean_up_reviving_any( playerbeingrevived )
{
	self endon( "do_revive_ended_normally" );
	playerbeingrevived waittill_any( "disconnect", "zombified", "stop_revive_trigger" );
	self.is_reviving_any--;

	if ( self.is_reviving_any <= 0 )
	{
		self.is_reviving_any = 0;
	}
}

laststand_give_pistol()
{
/#
	assert( isDefined( self.laststandpistol ) );
#/
/#
	assert( self.laststandpistol != "none" );
#/
	if ( isDefined( level.zombie_last_stand ) )
	{
		[[ level.zombie_last_stand ]]();
	}
	else
	{
		self giveweapon( self.laststandpistol );
		self givemaxammo( self.laststandpistol );
		self switchtoweapon( self.laststandpistol );
	}
}

laststand_bleedout( delay )
{
	self endon( "player_revived" );
	self endon( "player_suicide" );
	self endon( "zombified" );
	self endon( "disconnect" );
	if ( isDefined( self.is_zombie ) || self.is_zombie && isDefined( self.no_revive_trigger ) && self.no_revive_trigger )
	{
		self notify( "bled_out" );
		wait_network_frame();
		self bleed_out();
		return;
	}
	setclientsysstate( "lsm", "1", self );
	self.bleedout_time = delay;
	while ( self.bleedout_time > int( delay * 0,5 ) )
	{
		self.bleedout_time -= 1;
		wait 1;
	}
	visionsetlaststand( "zombie_death", delay * 0,5 );
	while ( self.bleedout_time > 0 )
	{
		self.bleedout_time -= 1;
		wait 1;
	}
	while ( isDefined( self.revivetrigger ) && isDefined( self.revivetrigger.beingrevived ) && self.revivetrigger.beingrevived == 1 )
	{
		wait 0,1;
	}
	self notify( "bled_out" );
	wait_network_frame();
	self bleed_out();
}

bleed_out()
{
	self cleanup_suicide_hud();
	if ( isDefined( self.revivetrigger ) )
	{
		self.revivetrigger delete();
	}
	self.revivetrigger = undefined;
	setclientsysstate( "lsm", "0", self );
	self maps/mp/zombies/_zm_stats::increment_client_stat( "deaths" );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "deaths" );
	self maps/mp/zombies/_zm_pers_upgrades::pers_upgrade_jugg_player_death_stat();
	self recordplayerdeathzombies();
	self maps/mp/zombies/_zm_equipment::equipment_take();
	if ( level.gametype != "zcleansed" )
	{
		maps/mp/_demo::bookmark( "zm_player_bledout", getTime(), self, undefined, 1 );
	}
	level notify( "bleed_out" );
	self undolaststand();
	if ( isDefined( level.is_zombie_level ) && level.is_zombie_level )
	{
		self thread [[ level.player_becomes_zombie ]]();
	}
	else
	{
		if ( isDefined( level.is_specops_level ) && level.is_specops_level )
		{
			self thread [[ level.spawnspectator ]]();
			return;
		}
		else
		{
			self.ignoreme = 0;
		}
	}
}

cleanup_suicide_hud()
{
	if ( isDefined( self.suicideprompt ) )
	{
		self.suicideprompt destroy();
	}
	self.suicideprompt = undefined;
}

clean_up_suicide_hud_on_end_game()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "stop_revive_trigger" );
	self endon( "player_revived" );
	self endon( "bled_out" );
	level waittill_any( "end_game", "stop_suicide_trigger" );
	self cleanup_suicide_hud();
	if ( isDefined( self.suicidetexthud ) )
	{
		self.suicidetexthud destroy();
	}
	if ( isDefined( self.suicideprogressbar ) )
	{
		self.suicideprogressbar destroyelem();
	}
}

clean_up_suicide_hud_on_bled_out()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "stop_revive_trigger" );
	self waittill_any( "bled_out", "player_revived", "fake_death" );
	self cleanup_suicide_hud();
	if ( isDefined( self.suicideprogressbar ) )
	{
		self.suicideprogressbar destroyelem();
	}
	if ( isDefined( self.suicidetexthud ) )
	{
		self.suicidetexthud destroy();
	}
}

suicide_trigger_spawn()
{
	radius = getDvarInt( "revive_trigger_radius" );
	self.suicideprompt = newclienthudelem( self );
	self.suicideprompt.alignx = "center";
	self.suicideprompt.aligny = "middle";
	self.suicideprompt.horzalign = "center";
	self.suicideprompt.vertalign = "bottom";
	self.suicideprompt.y = -170;
	if ( self issplitscreen() )
	{
		self.suicideprompt.y = -132;
	}
	self.suicideprompt.foreground = 1;
	self.suicideprompt.font = "default";
	self.suicideprompt.fontscale = 1,5;
	self.suicideprompt.alpha = 1;
	self.suicideprompt.color = ( 1, 1, 1 );
	self.suicideprompt.hidewheninmenu = 1;
	self thread suicide_trigger_think();
}

suicide_trigger_think()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "stop_revive_trigger" );
	self endon( "player_revived" );
	self endon( "bled_out" );
	self endon( "fake_death" );
	level endon( "end_game" );
	level endon( "stop_suicide_trigger" );
	self thread clean_up_suicide_hud_on_end_game();
	self thread clean_up_suicide_hud_on_bled_out();
	while ( self usebuttonpressed() )
	{
		wait 1;
	}
	if ( !isDefined( self.suicideprompt ) )
	{
		return;
	}
	while ( 1 )
	{
		wait 0,1;
		while ( !isDefined( self.suicideprompt ) )
		{
			continue;
		}
		self.suicideprompt settext( &"ZOMBIE_BUTTON_TO_SUICIDE" );
		while ( !self is_suiciding() )
		{
			continue;
		}
		self.pre_suicide_weapon = self getcurrentweapon();
		self giveweapon( level.suicide_weapon );
		self switchtoweapon( level.suicide_weapon );
		duration = self docowardswayanims();
		suicide_success = suicide_do_suicide( duration );
		self.laststand = undefined;
		self takeweapon( level.suicide_weapon );
		if ( suicide_success )
		{
			self notify( "player_suicide" );
			wait_network_frame();
			self maps/mp/zombies/_zm_stats::increment_client_stat( "suicides" );
			self bleed_out();
			return;
		}
		self switchtoweapon( self.pre_suicide_weapon );
		self.pre_suicide_weapon = undefined;
	}
}

suicide_do_suicide( duration )
{
	level endon( "end_game" );
	level endon( "stop_suicide_trigger" );
	suicidetime = duration;
	timer = 0;
	suicided = 0;
	self.suicideprompt settext( "" );
	if ( !isDefined( self.suicideprogressbar ) )
	{
		self.suicideprogressbar = self createprimaryprogressbar();
	}
	if ( !isDefined( self.suicidetexthud ) )
	{
		self.suicidetexthud = newclienthudelem( self );
	}
	self.suicideprogressbar updatebar( 0,01, 1 / suicidetime );
	self.suicidetexthud.alignx = "center";
	self.suicidetexthud.aligny = "middle";
	self.suicidetexthud.horzalign = "center";
	self.suicidetexthud.vertalign = "bottom";
	self.suicidetexthud.y = -173;
	if ( self issplitscreen() )
	{
		self.suicidetexthud.y = -147;
	}
	self.suicidetexthud.foreground = 1;
	self.suicidetexthud.font = "default";
	self.suicidetexthud.fontscale = 1,8;
	self.suicidetexthud.alpha = 1;
	self.suicidetexthud.color = ( 1, 1, 1 );
	self.suicidetexthud.hidewheninmenu = 1;
	self.suicidetexthud settext( &"ZOMBIE_SUICIDING" );
	while ( self is_suiciding() )
	{
		wait 0,05;
		timer += 0,05;
		if ( timer >= suicidetime )
		{
			suicided = 1;
			break;
		}
		else
		{
		}
	}
	if ( isDefined( self.suicideprogressbar ) )
	{
		self.suicideprogressbar destroyelem();
	}
	if ( isDefined( self.suicidetexthud ) )
	{
		self.suicidetexthud destroy();
	}
	if ( isDefined( self.suicideprompt ) )
	{
		self.suicideprompt settext( &"ZOMBIE_BUTTON_TO_SUICIDE" );
	}
	return suicided;
}

can_suicide()
{
	if ( !isalive( self ) )
	{
		return 0;
	}
	if ( !self player_is_in_laststand() )
	{
		return 0;
	}
	if ( !isDefined( self.suicideprompt ) )
	{
		return 0;
	}
	if ( isDefined( self.is_zombie ) && self.is_zombie )
	{
		return 0;
	}
	if ( isDefined( level.intermission ) && level.intermission )
	{
		return 0;
	}
	return 1;
}

is_suiciding( revivee )
{
	if ( self usebuttonpressed() )
	{
		return can_suicide();
	}
}

revive_trigger_spawn()
{
	if ( isDefined( level.revive_trigger_spawn_override_link ) )
	{
		[[ level.revive_trigger_spawn_override_link ]]( self );
	}
	else
	{
		radius = getDvarInt( "revive_trigger_radius" );
		self.revivetrigger = spawn( "trigger_radius", ( 1, 1, 1 ), 0, radius, radius );
		self.revivetrigger sethintstring( "" );
		self.revivetrigger setcursorhint( "HINT_NOICON" );
		self.revivetrigger setmovingplatformenabled( 1 );
		self.revivetrigger enablelinkto();
		self.revivetrigger.origin = self.origin;
		self.revivetrigger linkto( self );
		self.revivetrigger.beingrevived = 0;
		self.revivetrigger.createtime = getTime();
	}
	self thread revive_trigger_think();
}

revive_trigger_think()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "stop_revive_trigger" );
	level endon( "end_game" );
	self endon( "death" );
	while ( 1 )
	{
		wait 0,1;
		self.revivetrigger sethintstring( "" );
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			d = 0;
			d = self depthinwater();
			if ( players[ i ] can_revive( self ) || d > 20 )
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
			if ( self == reviver || !reviver is_reviving( self ) )
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
				if ( gun == level.revive_tool )
				{
					i++;
					continue;
				}
				else
				{
					reviver giveweapon( level.revive_tool );
					reviver switchtoweapon( level.revive_tool );
					reviver setweaponammostock( level.revive_tool, 1 );
					revive_success = reviver revive_do_revive( self, gun );
					reviver revive_give_back_weapons( gun );
					if ( isplayer( self ) )
					{
						self allowjump( 1 );
					}
					self.laststand = undefined;
					if ( revive_success )
					{
						if ( isplayer( self ) )
						{
							maps/mp/zombies/_zm_chugabud::player_revived_cleanup_chugabud_corpse();
						}
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

revive_give_back_weapons( gun )
{
	self takeweapon( level.revive_tool );
	if ( self player_is_in_laststand() )
	{
		return;
	}
	if ( gun != "none" && !is_placeable_mine( gun ) && gun != "equip_gasmask_zm" && gun != "lower_equip_gasmask_zm" && self hasweapon( gun ) )
	{
		self switchtoweapon( gun );
	}
	else
	{
		primaryweapons = self getweaponslistprimaries();
		if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
		{
			self switchtoweapon( primaryweapons[ 0 ] );
		}
	}
}

can_revive( revivee )
{
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
	if ( isDefined( self.is_zombie ) && self.is_zombie )
	{
		return 0;
	}
	if ( self has_powerup_weapon() )
	{
		return 0;
	}
	if ( isDefined( level.can_revive_use_depthinwater_test ) && level.can_revive_use_depthinwater_test && revivee depthinwater() > 10 )
	{
		return 1;
	}
	if ( isDefined( level.can_revive ) && !( [[ level.can_revive ]]( revivee ) ) )
	{
		return 0;
	}
	if ( isDefined( level.can_revive_game_module ) && !( [[ level.can_revive_game_module ]]( revivee ) ) )
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
		if ( !sighttracepassed( self.origin + vectorScale( ( 1, 1, 1 ), 50 ), revivee.origin + vectorScale( ( 1, 1, 1 ), 30 ), 0, undefined ) )
		{
			return 0;
		}
		if ( !bullettracepassed( self.origin + vectorScale( ( 1, 1, 1 ), 50 ), revivee.origin + vectorScale( ( 1, 1, 1 ), 30 ), 0, undefined ) )
		{
			return 0;
		}
	}
	return 1;
}

is_reviving( revivee )
{
	if ( self usebuttonpressed() )
	{
		return can_revive( revivee );
	}
}

is_reviving_any()
{
	if ( isDefined( self.is_reviving_any ) )
	{
		return self.is_reviving_any;
	}
}

is_facing( facee )
{
	orientation = self getplayerangles();
	forwardvec = anglesToForward( orientation );
	forwardvec2d = ( forwardvec[ 0 ], forwardvec[ 1 ], 0 );
	unitforwardvec2d = vectornormalize( forwardvec2d );
	tofaceevec = facee.origin - self.origin;
	tofaceevec2d = ( tofaceevec[ 0 ], tofaceevec[ 1 ], 0 );
	unittofaceevec2d = vectornormalize( tofaceevec2d );
	dotproduct = vectordot( unitforwardvec2d, unittofaceevec2d );
	return dotproduct > 0,9;
}

revive_do_revive( playerbeingrevived, revivergun )
{
/#
	assert( self is_reviving( playerbeingrevived ) );
#/
	revivetime = 3;
	if ( self hasperk( "specialty_quickrevive" ) )
	{
		revivetime /= 2;
	}
	if ( isDefined( self.pers_upgrades_awarded[ "revive" ] ) && self.pers_upgrades_awarded[ "revive" ] )
	{
		revivetime *= 0,5;
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
	self.revivetexthud.color = ( 1, 1, 1 );
	self.revivetexthud.hidewheninmenu = 1;
	if ( isDefined( self.pers_upgrades_awarded[ "revive" ] ) && self.pers_upgrades_awarded[ "revive" ] )
	{
		self.revivetexthud.color = ( 0,5, 0,5, 1 );
	}
	self.revivetexthud settext( &"GAME_REVIVING" );
	self thread check_for_failed_revive( playerbeingrevived );
	while ( self is_reviving( playerbeingrevived ) )
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

checkforbleedout( player )
{
	self endon( "player_revived" );
	self endon( "player_suicide" );
	self endon( "disconnect" );
	player endon( "disconnect" );
	if ( is_classic() )
	{
		player.failed_revives++;
		player notify( "player_failed_revive" );
	}
}

auto_revive( reviver, dont_enable_weapons )
{
	if ( isDefined( self.revivetrigger ) )
	{
		self.revivetrigger.auto_revive = 1;
		while ( self.revivetrigger.beingrevived == 1 )
		{
			while ( 1 )
			{
				if ( self.revivetrigger.beingrevived == 0 )
				{
					break;
				}
				else
				{
					wait_network_frame();
				}
			}
		}
		self.revivetrigger.auto_trigger = 0;
	}
	self reviveplayer();
	self maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	setclientsysstate( "lsm", "0", self );
	self notify( "stop_revive_trigger" );
	if ( isDefined( self.revivetrigger ) )
	{
		self.revivetrigger delete();
		self.revivetrigger = undefined;
	}
	self cleanup_suicide_hud();
	if ( !isDefined( dont_enable_weapons ) || dont_enable_weapons == 0 )
	{
		self laststand_enable_player_weapons();
	}
	self allowjump( 1 );
	self.ignoreme = 0;
	self.laststand = undefined;
	if ( isDefined( level.isresetting_grief ) && !level.isresetting_grief )
	{
		reviver.revives++;
		reviver maps/mp/zombies/_zm_stats::increment_client_stat( "revives" );
		reviver maps/mp/zombies/_zm_stats::increment_player_stat( "revives" );
		self recordplayerrevivezombies( reviver );
		maps/mp/_demo::bookmark( "zm_player_revived", getTime(), self, reviver );
	}
	self notify( "player_revived" );
}

remote_revive( reviver )
{
	if ( !self player_is_in_laststand() )
	{
		return;
	}
	self auto_revive( reviver );
}

revive_success( reviver )
{
	if ( !isplayer( self ) )
	{
		self notify( "player_revived" );
		return;
	}
	maps/mp/_demo::bookmark( "zm_player_revived", getTime(), self, reviver );
	self notify( "player_revived" );
	self reviveplayer();
	self maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	if ( isDefined( level.isresetting_grief ) && !level.isresetting_grief )
	{
		reviver.revives++;
		reviver maps/mp/zombies/_zm_stats::increment_client_stat( "revives" );
		reviver maps/mp/zombies/_zm_stats::increment_player_stat( "revives" );
		self recordplayerrevivezombies( reviver );
		reviver.upgrade_fx_origin = self.origin;
	}
	if ( is_classic() )
	{
		reviver maps/mp/zombies/_zm_stats::increment_client_stat( "pers_revivenoperk", 0 );
	}
	reviver thread check_for_sacrifice();
	if ( isDefined( level.missioncallbacks ) )
	{
	}
	setclientsysstate( "lsm", "0", self );
	self.revivetrigger delete();
	self.revivetrigger = undefined;
	self cleanup_suicide_hud();
	self laststand_enable_player_weapons();
	self.ignoreme = 0;
}

revive_force_revive( reviver )
{
/#
	assert( isDefined( self ) );
#/
/#
	assert( isplayer( self ) );
#/
/#
	assert( self player_is_in_laststand() );
#/
	self thread revive_success( reviver );
}

revive_hud_create()
{
	self.revive_hud = newclienthudelem( self );
	self.revive_hud.alignx = "center";
	self.revive_hud.aligny = "middle";
	self.revive_hud.horzalign = "center";
	self.revive_hud.vertalign = "bottom";
	self.revive_hud.foreground = 1;
	self.revive_hud.font = "default";
	self.revive_hud.fontscale = 1,5;
	self.revive_hud.alpha = 0;
	self.revive_hud.color = ( 1, 1, 1 );
	self.revive_hud.hidewheninmenu = 1;
	self.revive_hud settext( "" );
	self.revive_hud.y = -160;
}

revive_hud_think()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		wait 0,1;
		while ( !player_any_player_in_laststand() )
		{
			continue;
		}
		players = get_players();
		playertorevive = undefined;
		i = 0;
		while ( i < players.size )
		{
			if ( !isDefined( players[ i ].revivetrigger ) || !isDefined( players[ i ].revivetrigger.createtime ) )
			{
				i++;
				continue;
			}
			else
			{
				if ( !isDefined( playertorevive ) || playertorevive.revivetrigger.createtime > players[ i ].revivetrigger.createtime )
				{
					playertorevive = players[ i ];
				}
			}
			i++;
		}
		if ( isDefined( playertorevive ) )
		{
			i = 0;
			while ( i < players.size )
			{
				if ( players[ i ] player_is_in_laststand() )
				{
					i++;
					continue;
				}
				else if ( getDvar( "g_gametype" ) == "vs" )
				{
					if ( players[ i ].team != playertorevive.team )
					{
						i++;
						continue;
					}
				}
				else if ( is_encounter() )
				{
					if ( players[ i ].sessionteam != playertorevive.sessionteam )
					{
						i++;
						continue;
					}
					else if ( isDefined( level.hide_revive_message ) && level.hide_revive_message )
					{
						i++;
						continue;
					}
				}
				else
				{
					players[ i ] thread faderevivemessageover( playertorevive, 3 );
				}
				i++;
			}
			playertorevive.revivetrigger.createtime = undefined;
			wait 3,5;
		}
	}
}

faderevivemessageover( playertorevive, time )
{
	revive_hud_show();
	self.revive_hud settext( &"GAME_PLAYER_NEEDS_TO_BE_REVIVED", playertorevive );
	self.revive_hud fadeovertime( time );
	self.revive_hud.alpha = 0;
}

revive_hud_show()
{
/#
	assert( isDefined( self ) );
#/
/#
	assert( isDefined( self.revive_hud ) );
#/
	self.revive_hud.alpha = 1;
}

revive_hud_show_n_fade( time )
{
	revive_hud_show();
	self.revive_hud fadeovertime( time );
	self.revive_hud.alpha = 0;
}

drawcylinder( pos, rad, height )
{
/#
	currad = rad;
	curheight = height;
	r = 0;
	while ( r < 20 )
	{
		theta = ( r / 20 ) * 360;
		theta2 = ( ( r + 1 ) / 20 ) * 360;
		line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) );
		line( pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) );
		line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ) );
		r++;
#/
	}
}

get_lives_remaining()
{
/#
	assert( level.laststandgetupallowed, "Lives only exist in the Laststand type GETUP." );
#/
	if ( level.laststandgetupallowed && isDefined( self.laststand_info ) && isDefined( self.laststand_info.type_getup_lives ) )
	{
		return max( 0, self.laststand_info.type_getup_lives );
	}
	return 0;
}

update_lives_remaining( increment )
{
/#
	assert( level.laststandgetupallowed, "Lives only exist in the Laststand type GETUP." );
#/
/#
	assert( isDefined( increment ), "Must specify increment true or false" );
#/
	if ( isDefined( increment ) )
	{
	}
	else
	{
	}
	increment = 0;
	if ( increment )
	{
	}
	else
	{
	}
	self.laststand_info.type_getup_lives = max( 0, self.laststand_info.type_getup_lives - 1, self.laststand_info.type_getup_lives + 1 );
	self notify( "laststand_lives_updated" );
}

player_getup_setup()
{
/#
	println( "ZM >> player_getup_setup called" );
#/
	self.laststand_info = spawnstruct();
	self.laststand_info.type_getup_lives = level.const_laststand_getup_count_start;
}

laststand_getup()
{
	self endon( "player_revived" );
	self endon( "disconnect" );
/#
	println( "ZM >> laststand_getup called" );
#/
	self update_lives_remaining( 0 );
	setclientsysstate( "lsm", "1", self );
	self.laststand_info.getup_bar_value = level.const_laststand_getup_bar_start;
	self thread laststand_getup_hud();
	self thread laststand_getup_damage_watcher();
	while ( self.laststand_info.getup_bar_value < 1 )
	{
		self.laststand_info.getup_bar_value += level.const_laststand_getup_bar_regen;
		wait 0,05;
	}
	self auto_revive( self );
	setclientsysstate( "lsm", "0", self );
}

laststand_getup_damage_watcher()
{
	self endon( "player_revived" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "damage" );
		self.laststand_info.getup_bar_value -= level.const_laststand_getup_bar_damage;
		if ( self.laststand_info.getup_bar_value < 0 )
		{
			self.laststand_info.getup_bar_value = 0;
		}
	}
}

laststand_getup_hud()
{
	self endon( "player_revived" );
	self endon( "disconnect" );
	hudelem = newclienthudelem( self );
	hudelem.alignx = "left";
	hudelem.aligny = "middle";
	hudelem.horzalign = "left";
	hudelem.vertalign = "middle";
	hudelem.x = 5;
	hudelem.y = 170;
	hudelem.font = "big";
	hudelem.fontscale = 1,5;
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = 1;
	hudelem.hidewhendead = 1;
	hudelem.sort = 2;
	hudelem.label = &"SO_WAR_LASTSTAND_GETUP_BAR";
	self thread laststand_getup_hud_destroy( hudelem );
	while ( 1 )
	{
		hudelem setvalue( self.laststand_info.getup_bar_value );
		wait 0,05;
	}
}

laststand_getup_hud_destroy( hudelem )
{
	self waittill_either( "player_revived", "disconnect" );
	hudelem destroy();
}

check_for_sacrifice()
{
	self delay_notify( "sacrifice_denied", 1 );
	self endon( "sacrifice_denied" );
	self waittill( "player_downed" );
	self maps/mp/zombies/_zm_stats::increment_client_stat( "sacrifices" );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "sacrifices" );
}

check_for_failed_revive( playerbeingrevived )
{
	self endon( "disconnect" );
	playerbeingrevived endon( "disconnect" );
	playerbeingrevived endon( "player_suicide" );
	self notify( "checking_for_failed_revive" );
	self endon( "checking_for_failed_revive" );
	playerbeingrevived endon( "player_revived" );
	playerbeingrevived waittill( "bled_out" );
	self maps/mp/zombies/_zm_stats::increment_client_stat( "failed_revives" );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "failed_revives" );
}

add_weighted_down()
{
	if ( !level.curr_gametype_affects_rank )
	{
		return;
	}
	weighted_down = 1000;
	if ( level.round_number > 0 )
	{
		weighted_down = int( 1000 / ceil( level.round_number / 5 ) );
	}
	self addplayerstat( "weighted_downs", weighted_down );
}

cleanup_laststand_on_disconnect()
{
	self endon( "player_revived" );
	self endon( "player_suicide" );
	self endon( "bled_out" );
	trig = self.revivetrigger;
	self waittill( "disconnect" );
	if ( isDefined( trig ) )
	{
		trig delete();
	}
}
