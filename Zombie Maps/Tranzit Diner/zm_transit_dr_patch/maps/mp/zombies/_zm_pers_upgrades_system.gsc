#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

pers_register_upgrade( name, upgrade_active_func, stat_name, stat_desired_value, game_end_reset_if_not_achieved )
{
	if ( !isDefined( level.pers_upgrades ) )
	{
		level.pers_upgrades = [];
		level.pers_upgrades_keys = [];
	}
	if ( isDefined( level.pers_upgrades[ name ] ) )
	{
/#
		assert( 0, "A persistent upgrade is already registered for name: " + name );
#/
	}
	level.pers_upgrades_keys[ level.pers_upgrades_keys.size ] = name;
	level.pers_upgrades[ name ] = spawnstruct();
	level.pers_upgrades[ name ].stat_names = [];
	level.pers_upgrades[ name ].stat_desired_values = [];
	level.pers_upgrades[ name ].upgrade_active_func = upgrade_active_func;
	level.pers_upgrades[ name ].game_end_reset_if_not_achieved = game_end_reset_if_not_achieved;
	add_pers_upgrade_stat( name, stat_name, stat_desired_value );
}

add_pers_upgrade_stat( name, stat_name, stat_desired_value )
{
	if ( !isDefined( level.pers_upgrades[ name ] ) )
	{
/#
		assert( 0, name + " - Persistent upgrade is not registered yet." );
#/
	}
	stats_size = level.pers_upgrades[ name ].stat_names.size;
	level.pers_upgrades[ name ].stat_names[ stats_size ] = stat_name;
	level.pers_upgrades[ name ].stat_desired_values[ stats_size ] = stat_desired_value;
}

pers_upgrades_monitor()
{
	if ( !isDefined( level.pers_upgrades ) )
	{
		return;
	}
	if ( !is_classic() )
	{
		return;
	}
	level thread wait_for_game_end();
	while ( 1 )
	{
		waittillframeend;
		players = getplayers();
		player_index = 0;
		while ( player_index < players.size )
		{
			player = players[ player_index ];
			if ( is_player_valid( player ) && isDefined( player.stats_this_frame ) )
			{
				if ( !player.stats_this_frame.size && isDefined( player.pers_upgrade_force_test ) && !player.pers_upgrade_force_test )
				{
					player_index++;
					continue;
				}
				else
				{
					pers_upgrade_index = 0;
					while ( pers_upgrade_index < level.pers_upgrades_keys.size )
					{
						pers_upgrade = level.pers_upgrades[ level.pers_upgrades_keys[ pers_upgrade_index ] ];
						is_stat_updated = player is_any_pers_upgrade_stat_updated( pers_upgrade );
						if ( is_stat_updated )
						{
							should_award = player check_pers_upgrade( pers_upgrade );
							if ( should_award )
							{
								if ( isDefined( player.pers_upgrades_awarded[ level.pers_upgrades_keys[ pers_upgrade_index ] ] ) && player.pers_upgrades_awarded[ level.pers_upgrades_keys[ pers_upgrade_index ] ] )
								{
									pers_upgrade_index++;
									continue;
								}
								else
								{
									player.pers_upgrades_awarded[ level.pers_upgrades_keys[ pers_upgrade_index ] ] = 1;
									if ( flag( "initial_blackscreen_passed" ) && !is_true( player.is_hotjoining ) )
									{
										player playsoundtoplayer( "evt_player_upgrade", player );
										player delay_thread( 1, ::play_vox_to_player, "general", "upgrade" );
										if ( isDefined( player.upgrade_fx_origin ) )
										{
											fx_org = player.upgrade_fx_origin;
											player.upgrade_fx_origin = undefined;
										}
										else
										{
											fx_org = player.origin;
											v_dir = anglesToForward( player getplayerangles() );
											v_up = anglesToUp( player getplayerangles() );
											fx_org = ( fx_org + ( v_dir * 10 ) ) + ( v_up * 10 );
										}
										playfx( level._effect[ "upgrade_aquired" ], fx_org );
										level thread maps/mp/zombies/_zm::disable_end_game_intermission( 1,5 );
									}
/#
									player iprintlnbold( "Upgraded!" );
#/
									if ( isDefined( pers_upgrade.upgrade_active_func ) )
									{
										player thread [[ pers_upgrade.upgrade_active_func ]]();
									}
									pers_upgrade_index++;
									continue;
								}
								else
								{
									if ( isDefined( player.pers_upgrades_awarded[ level.pers_upgrades_keys[ pers_upgrade_index ] ] ) && player.pers_upgrades_awarded[ level.pers_upgrades_keys[ pers_upgrade_index ] ] )
									{
										if ( flag( "initial_blackscreen_passed" ) && !is_true( player.is_hotjoining ) )
										{
											player playsoundtoplayer( "evt_player_downgrade", player );
										}
/#
										player iprintlnbold( "Downgraded!" );
#/
									}
									player.pers_upgrades_awarded[ level.pers_upgrades_keys[ pers_upgrade_index ] ] = 0;
								}
							}
						}
						pers_upgrade_index++;
					}
					player.pers_upgrade_force_test = 0;
					player.stats_this_frame = [];
				}
			}
			player_index++;
		}
		wait 0,05;
	}
}

wait_for_game_end()
{
	if ( !is_classic() )
	{
		return;
	}
	level waittill( "end_game" );
	players = getplayers();
	player_index = 0;
	while ( player_index < players.size )
	{
		player = players[ player_index ];
		index = 0;
		while ( index < level.pers_upgrades_keys.size )
		{
			str_name = level.pers_upgrades_keys[ index ];
			game_end_reset_if_not_achieved = level.pers_upgrades[ str_name ].game_end_reset_if_not_achieved;
			while ( isDefined( game_end_reset_if_not_achieved ) && game_end_reset_if_not_achieved == 1 )
			{
				while ( isDefined( player.pers_upgrades_awarded[ str_name ] ) && !player.pers_upgrades_awarded[ str_name ] )
				{
					stat_index = 0;
					while ( stat_index < level.pers_upgrades[ str_name ].stat_names.size )
					{
						player maps/mp/zombies/_zm_stats::zero_client_stat( level.pers_upgrades[ str_name ].stat_names[ stat_index ], 0 );
						stat_index++;
					}
				}
			}
			index++;
		}
		player_index++;
	}
}

check_pers_upgrade( pers_upgrade )
{
	should_award = 1;
	i = 0;
	while ( i < pers_upgrade.stat_names.size )
	{
		stat_name = pers_upgrade.stat_names[ i ];
		should_award = self check_pers_upgrade_stat( stat_name, pers_upgrade.stat_desired_values[ i ] );
		if ( !should_award )
		{
			break;
		}
		else
		{
			i++;
		}
	}
	return should_award;
}

is_any_pers_upgrade_stat_updated( pers_upgrade )
{
	if ( isDefined( self.pers_upgrade_force_test ) && self.pers_upgrade_force_test )
	{
		return 1;
	}
	result = 0;
	i = 0;
	while ( i < pers_upgrade.stat_names.size )
	{
		stat_name = pers_upgrade.stat_names[ i ];
		if ( isDefined( self.stats_this_frame[ stat_name ] ) )
		{
			result = 1;
			break;
		}
		else
		{
			i++;
		}
	}
	return result;
}

check_pers_upgrade_stat( stat_name, stat_desired_value )
{
	should_award = 1;
	current_stat_value = self maps/mp/zombies/_zm_stats::get_global_stat( stat_name );
	if ( current_stat_value < stat_desired_value )
	{
		should_award = 0;
	}
	return should_award;
}

round_end()
{
	if ( !is_classic() )
	{
		return;
	}
	self notify( "pers_stats_end_of_round" );
}
