#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( !maps/mp/zombies/_zm_equipment::is_equipment_included( "equip_gasmask_zm" ) )
	{
		return;
	}
	registerclientfield( "toplayer", "gasmaskoverlay", 7000, 1, "int" );
	maps/mp/zombies/_zm_equipment::register_equipment( "equip_gasmask_zm", &"ZOMBIE_EQUIP_GASMASK_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_GASMASK_HOWTO", undefined, "gasmask", ::gasmask_activation_watcher_thread );
	level.deathcard_spawn_func = ::remove_gasmask_on_player_bleedout;
	precacheitem( "lower_equip_gasmask_zm" );
	onplayerconnect_callback( ::gasmask_on_player_connect );
}

gasmask_on_player_connect()
{
}

gasmask_removed_watcher_thread()
{
	self notify( "only_one_gasmask_removed_thread" );
	self endon( "only_one_gasmask_removed_thread" );
	self endon( "disconnect" );
	self waittill( "equip_gasmask_zm_taken" );
	if ( isDefined( level.zombiemode_gasmask_reset_player_model ) )
	{
		ent_num = self.characterindex;
		if ( isDefined( self.zm_random_char ) )
		{
			ent_num = self.zm_random_char;
		}
		self [[ level.zombiemode_gasmask_reset_player_model ]]( ent_num );
	}
	if ( isDefined( level.zombiemode_gasmask_reset_player_viewmodel ) )
	{
		ent_num = self.characterindex;
		if ( isDefined( self.zm_random_char ) )
		{
			ent_num = self.zm_random_char;
		}
		self [[ level.zombiemode_gasmask_reset_player_viewmodel ]]( ent_num );
	}
	self setclientfieldtoplayer( "gasmaskoverlay", 0 );
}

gasmask_activation_watcher_thread()
{
	self endon( "zombified" );
	self endon( "disconnect" );
	self endon( "equip_gasmask_zm_taken" );
	self thread gasmask_removed_watcher_thread();
	self thread remove_gasmask_on_game_over();
	if ( isDefined( level.zombiemode_gasmask_set_player_model ) )
	{
		ent_num = self.characterindex;
		if ( isDefined( self.zm_random_char ) )
		{
			ent_num = self.zm_random_char;
		}
		self [[ level.zombiemode_gasmask_set_player_model ]]( ent_num );
	}
	if ( isDefined( level.zombiemode_gasmask_set_player_viewmodel ) )
	{
		ent_num = self.characterindex;
		if ( isDefined( self.zm_random_char ) )
		{
			ent_num = self.zm_random_char;
		}
		self [[ level.zombiemode_gasmask_set_player_viewmodel ]]( ent_num );
	}
	for ( ;; )
	{
		while ( 1 )
		{
			self waittill_either( "equip_gasmask_zm_activate", "equip_gasmask_zm_deactivate" );
			if ( self maps/mp/zombies/_zm_equipment::is_equipment_active( "equip_gasmask_zm" ) )
			{
				self increment_is_drinking();
				self setactionslot( 1, "" );
				if ( isDefined( level.zombiemode_gasmask_set_player_model ) )
				{
					ent_num = self.characterindex;
					if ( isDefined( self.zm_random_char ) )
					{
						ent_num = self.zm_random_char;
					}
					self [[ level.zombiemode_gasmask_change_player_headmodel ]]( ent_num, 1 );
				}
				clientnotify( "gmsk2" );
				self waittill( "weapon_change_complete" );
				self setclientfieldtoplayer( "gasmaskoverlay", 1 );
			}
			else
			{
				self increment_is_drinking();
				self setactionslot( 1, "" );
				if ( isDefined( level.zombiemode_gasmask_set_player_model ) )
				{
					ent_num = self.characterindex;
					if ( isDefined( self.zm_random_char ) )
					{
						ent_num = self.zm_random_char;
					}
					self [[ level.zombiemode_gasmask_change_player_headmodel ]]( ent_num, 0 );
				}
				self takeweapon( "equip_gasmask_zm" );
				self giveweapon( "lower_equip_gasmask_zm" );
				self switchtoweapon( "lower_equip_gasmask_zm" );
				wait 0,05;
				self setclientfieldtoplayer( "gasmaskoverlay", 0 );
				self waittill( "weapon_change_complete" );
				self takeweapon( "lower_equip_gasmask_zm" );
				self giveweapon( "equip_gasmask_zm" );
			}
			if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
			{
				if ( self is_multiple_drinking() )
				{
					self decrement_is_drinking();
					self setactionslot( 1, "weapon", "equip_gasmask_zm" );
					self notify( "equipment_select_response_done" );
				}
			}
			else if ( isDefined( self.prev_weapon_before_equipment_change ) && self hasweapon( self.prev_weapon_before_equipment_change ) )
			{
				if ( self.prev_weapon_before_equipment_change != self getcurrentweapon() )
				{
					self switchtoweapon( self.prev_weapon_before_equipment_change );
					self waittill( "weapon_change_complete" );
				}
				break;
			}
			else
			{
				primaryweapons = self getweaponslistprimaries();
				if ( isDefined( primaryweapons ) && primaryweapons.size > 0 )
				{
					if ( primaryweapons[ 0 ] != self getcurrentweapon() )
					{
						self switchtoweapon( primaryweapons[ 0 ] );
						self waittill( "weapon_change_complete" );
					}
					break;
				}
				else
				{
					self switchtoweapon( get_player_melee_weapon() );
				}
			}
		}
		self setactionslot( 1, "weapon", "equip_gasmask_zm" );
		if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() && isDefined( self.intermission ) && !self.intermission )
		{
			self decrement_is_drinking();
		}
		self notify( "equipment_select_response_done" );
	}
}

remove_gasmask_on_player_bleedout()
{
	self setclientfieldtoplayer( "gasmaskoverlay", 0 );
	wait_network_frame();
	wait_network_frame();
	self setclientfieldtoplayer( "gasmaskoverlay", 1 );
}

remove_gasmask_on_game_over()
{
	self endon( "equip_gasmask_zm_taken" );
	level waittill( "pre_end_game" );
	self setclientfieldtoplayer( "gasmaskoverlay", 0 );
}

gasmask_active()
{
	return self maps/mp/zombies/_zm_equipment::is_equipment_active( "equip_gasmask_zm" );
}

gasmask_debug_print( msg, color )
{
/#
	if ( !getDvarInt( #"4D1BCA99" ) )
	{
		return;
	}
	if ( !isDefined( color ) )
	{
		color = ( 0, 0, 1 );
	}
	print3d( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), msg, color, 1, 1, 40 );
#/
}
