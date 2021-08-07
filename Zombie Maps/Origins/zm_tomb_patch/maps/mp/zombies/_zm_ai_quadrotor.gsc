#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zombies/_zm_equipment;
#include maps/_vehicle;
#include maps/_quadrotor;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include animscripts/utility;

precache()
{
	precachemodel( "veh_t6_dlc_zm_quadrotor" );
	precachevehicle( "heli_quadrotor_zm" );
	precachevehicle( "heli_quadrotor_upgraded_zm" );
}

init()
{
	level._effect[ "quadrotor_nudge" ] = loadfx( "destructibles/fx_quadrotor_nudge01" );
	level._effect[ "qd_revive" ] = loadfx( "maps/zombie_tomb/fx_tomb_veh_quadrotor_revive_health" );
	maps/mp/zombies/_zm_equipment::register_equipment( "equip_dieseldrone_zm", &"ZM_TOMB_DIHS", &"ZM_TOMB_DIHO", "riotshield_zm_icon", "riotshield" );
}

quadrotor_dealt_no_damage_to_player( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isDefined( sweapon ) && sweapon == "quadrotorturret_zm" )
	{
		return 0;
	}
	return idamage;
}

quadrotor_think()
{
	self enableaimassist();
	self sethoverparams( 5, 60, 40 );
	self setneargoalnotifydist( 64 );
	self.flyheight = 128;
	self setvehicleavoidance( 1 );
	self.vehfovcosine = 0;
	self.vehfovcosinebusy = 0,574;
	self.vehaircraftcollisionenabled = 1;
	if ( !isDefined( self.goalradius ) )
	{
		self.goalradius = 128;
	}
	if ( !isDefined( self.goalpos ) )
	{
		self.goalpos = self.origin;
	}
	self thread quadrotor_death();
	self thread quadrotor_damage();
	quadrotor_start_ai();
	self thread quadrotor_set_team( "allies" );
}

follow_ent( e_followee )
{
	level endon( "end_game" );
	self endon( "death" );
	while ( isDefined( e_followee ) )
	{
		if ( !self.returning_home )
		{
			v_facing = e_followee getplayerangles();
			v_forward = anglesToForward( ( 0, v_facing[ 1 ], 0 ) );
			candidate_goalpos = e_followee.origin + ( v_forward * 128 );
			trace_goalpos = physicstrace( self.origin, candidate_goalpos );
			if ( trace_goalpos[ "position" ] == candidate_goalpos )
			{
				self.goalpos = e_followee.origin + ( v_forward * 128 );
				break;
			}
			else
			{
				self.goalpos = e_followee.origin + vectorScale( ( 0, 0, 1 ), 60 );
			}
		}
		wait randomfloatrange( 1, 2 );
	}
}

quadrotor_start_ai()
{
	self.goalpos = self.origin;
	self.returning_home = 0;
	quadrotor_main();
}

quadrotor_main()
{
	self thread quadrotor_blink_lights();
	self thread quadrotor_fireupdate();
	self thread quadrotor_movementupdate();
	self thread quadrotor_collision();
	self thread quadrotor_ambient_vo();
	self thread quadrotor_watch_for_game_end();
}

quadrotor_ambient_vo()
{
	level endon( "end_game" );
	self endon( "death" );
	spawn_lines = [];
	spawn_lines[ 0 ] = "vox_maxi_drone_standby_0";
	spawn_lines[ 1 ] = "vox_maxi_drone_hover_0";
	spawn_lines[ 2 ] = "vox_maxi_drone_holding_0";
	vox_line = spawn_lines[ randomintrange( 0, spawn_lines.size ) ];
	self thread maps/mp/zm_tomb_vo::maxissay( vox_line, self );
	current_ambient_line_cooldown = randomintrange( 10000, 30000 );
	wait current_ambient_line_cooldown;
	while ( 1 )
	{
		current_time = getTime();
		if ( ( current_time - self.time_last_spoke_attack_line ) > current_ambient_line_cooldown )
		{
			if ( ( current_time - self.time_last_spoke_killed_line ) > current_ambient_line_cooldown )
			{
				vox_line = "vox_maxi_drone_ambient_" + randomintrange( 0, 10 ) + "_0";
				self thread maps/mp/zm_tomb_vo::maxissay( vox_line, self );
				current_ambient_line_cooldown = randomintrange( 10000, 30000 );
			}
		}
		wait 0,1;
	}
}

quadrotor_fireupdate()
{
	level endon( "end_game" );
	self endon( "death" );
	current_time = getTime();
	self.time_last_spoke_attack_line = current_time;
	self.time_last_spoke_killed_line = current_time;
	current_attack_line_cooldown = 10000;
	current_killed_line_cooldown = 10000;
	while ( 1 )
	{
		if ( isDefined( self.enemy ) && self vehcansee( self.enemy ) )
		{
			dist_squared = distancesquared( self.enemy.origin, self.origin );
			if ( dist_squared < ( 384 * 384 ) && dist_squared > ( 96 * 96 ) )
			{
				self setturrettargetent( self.enemy );
				current_time = getTime();
				if ( ( current_time - self.time_last_spoke_attack_line ) > current_attack_line_cooldown )
				{
					vox_line = "vox_maxi_drone_attacking_" + randomintrange( 0, 3 );
					self thread maps/mp/zm_tomb_vo::maxissay( vox_line, self );
					self.time_last_spoke_attack_line = current_time;
					current_attack_line_cooldown = randomintrange( 10000, 30000 );
				}
				self quadrotor_fire_for_time( randomfloatrange( 1,5, 3 ) );
			}
			if ( isDefined( self.enemy ) && isai( self.enemy ) )
			{
				wait randomfloatrange( 0,5, 1 );
			}
			else
			{
				current_time = getTime();
				if ( ( current_time - self.time_last_spoke_killed_line ) > current_killed_line_cooldown )
				{
					vox_line = "vox_maxi_drone_killed_" + randomintrange( 0, 4 );
					self maps/mp/zm_tomb_vo::maxissay( vox_line, self );
					do_thank_maxis = randomintrange( 0, 2 );
					if ( do_thank_maxis > 0 )
					{
						players = getplayers();
						player = players[ randomintrange( 0, players.size ) ];
						player thread do_player_general_vox( "quadrotor", "kill_drone", undefined, 100 );
					}
					self.time_last_spoke_killed_line = current_time;
					current_killed_line_cooldown = randomintrange( 10000, 30000 );
				}
				wait randomfloatrange( 0,5, 1,5 );
			}
			continue;
		}
		else
		{
			current_time = getTime();
			if ( ( current_time - self.time_last_spoke_attack_line ) > current_attack_line_cooldown )
			{
				vox_line = "vox_maxi_drone_scan_0";
				self thread maps/mp/zm_tomb_vo::maxissay( vox_line, self );
				self.time_last_spoke_attack_line = current_time;
				current_attack_line_cooldown = randomintrange( 10000, 30000 );
			}
			wait 0,4;
		}
	}
}

quadrotor_watch_for_game_end()
{
	self endon( "death" );
	level waittill( "end_game" );
	if ( isDefined( self ) )
	{
		playfx( level._effect[ "tesla_elec_kill" ], self.origin );
		self playsound( "zmb_qrdrone_leave" );
		self delete();
/#
		iprintln( "Maxis deleted" );
#/
	}
}

quadrotor_check_move( position )
{
	results = physicstrace( self.origin, position, ( -15, -15, -5 ), ( 15, 15, 5 ) );
	if ( results[ "fraction" ] == 1 )
	{
		return 1;
	}
	return 0;
}

quadrotor_adjust_goal_for_enemy_height( goalpos )
{
	if ( isDefined( self.enemy ) )
	{
		if ( isai( self.enemy ) )
		{
			offset = 45;
		}
		else
		{
			offset = -100;
		}
		if ( ( self.enemy.origin[ 2 ] + offset ) > goalpos[ 2 ] )
		{
			goal_z = self.enemy.origin[ 2 ] + offset;
			if ( goal_z > ( goalpos[ 2 ] + 400 ) )
			{
				goal_z = goalpos[ 2 ] + 400;
			}
			results = physicstrace( goalpos, ( goalpos[ 0 ], goalpos[ 1 ], goal_z ), ( -15, -15, -5 ), ( 15, 15, 5 ) );
			if ( results[ "fraction" ] == 1 )
			{
				goalpos = ( goalpos[ 0 ], goalpos[ 1 ], goal_z );
			}
		}
	}
	return goalpos;
}

make_sure_goal_is_well_above_ground( pos )
{
	start = pos + ( 0, 0, self.flyheight );
	end = pos + ( 0, 0, self.flyheight * -1 );
	trace = bullettrace( start, end, 0, self, 0, 0 );
	end = trace[ "position" ];
	pos = end + ( 0, 0, self.flyheight );
	z = self getheliheightlockheight( pos );
	pos = ( pos[ 0 ], pos[ 1 ], z );
	return pos;
}

waittill_pathing_done()
{
	level endon( "end_game" );
	self endon( "death" );
	self endon( "change_state" );
	if ( self.vehonpath )
	{
		self waittill_any( "near_goal", "reached_end_node", "force_goal" );
	}
}

quadrotor_movementupdate()
{
	level endon( "end_game" );
	self endon( "death" );
	self endon( "change_state" );
/#
	assert( isalive( self ) );
#/
	a_powerups = [];
	old_goalpos = self.goalpos;
	self.goalpos = self make_sure_goal_is_well_above_ground( self.goalpos );
	if ( !self.vehonpath )
	{
		if ( isDefined( self.attachedpath ) )
		{
			self script_delay();
		}
		else if ( distancesquared( self.origin, self.goalpos ) < 10000 || self.goalpos[ 2 ] > ( old_goalpos[ 2 ] + 10 ) && ( self.origin[ 2 ] + 10 ) < self.goalpos[ 2 ] )
		{
			self setvehgoalpos( self.goalpos, 1, 2, 0 );
			self pathvariableoffset( vectorScale( ( 0, 0, 1 ), 20 ), 2 );
			self waittill_any_or_timeout( 4, "near_goal", "force_goal" );
		}
		else
		{
			goalpos = self quadrotor_get_closest_node();
			self setvehgoalpos( goalpos, 1, 2, 0 );
			self waittill_any_or_timeout( 2, "near_goal", "force_goal" );
		}
	}
/#
	assert( isalive( self ) );
#/
	self setvehicleavoidance( 1 );
	goalfailures = 0;
	for ( ;; )
	{
		while ( 1 )
		{
			self waittill_pathing_done();
			self thread quadrotor_blink_lights();
			if ( self.returning_home )
			{
				self setneargoalnotifydist( 64 );
				self setheliheightlock( 0 );
				is_valid_exit_path_found = 0;
				quadrotor_table = level.quadrotor_status.pickup_trig.model;
				is_valid_exit_path_found = self setvehgoalpos( quadrotor_table.origin, 1, 2, 1 );
				while ( is_valid_exit_path_found )
				{
					self notify( "attempting_return" );
					self waittill_any( "near_goal", "force_goal", "reached_end_node", "return_timeout" );
				}
				self setneargoalnotifydist( 8 );
				str_zone = level.quadrotor_status.str_zone;
/#
				iprintln( "EXIT ZONE: " + str_zone );
#/
				switch( str_zone )
				{
					case "zone_nml_9":
						exit_path = getvehiclenode( "quadrotor_nml_exit_path", "targetname" );
						is_valid_exit_path_found = self setvehgoalpos( exit_path.origin, 1, 2, 1 );
						break;
					case "zone_bunker_5a":
						if ( flag( "activate_zone_nml" ) )
						{
							exit_path = getvehiclenode( "quadrotor_bunker_north_exit_path", "targetname" );
							is_valid_exit_path_found = self setvehgoalpos( exit_path.origin, 1, 2, 1 );
							break;
						}
						if ( !is_valid_exit_path_found )
						{
							if ( flag( "activate_zone_bunker_3b" ) )
							{
								exit_path = getvehiclenode( "quadrotor_bunker_west_exit_path", "targetname" );
								is_valid_exit_path_found = self setvehgoalpos( exit_path.origin, 1, 2, 1 );
								break;
							}
						}
						if ( !is_valid_exit_path_found )
						{
							if ( flag( "activate_zone_bunker_4b" ) )
							{
								exit_path = getvehiclenode( "quadrotor_bunker_south_exit_path", "targetname" );
								is_valid_exit_path_found = self setvehgoalpos( exit_path.origin, 1, 2, 1 );
								break;
							}
						}
						case "zone_village_2":
						}
						if ( is_valid_exit_path_found )
						{
							self waittill_any( "near_goal", "force_goal" );
							self cancelaimove();
							self clearvehgoalpos();
							self pathvariableoffsetclear();
							self pathfixedoffsetclear();
							self clearlookatent();
							self setvehicleavoidance( 0 );
							self.drivepath = 1;
							self attachpath( exit_path );
							self pathvariableoffset( vectorScale( ( 0, 0, 1 ), 8 ), randomintrange( 1, 3 ) );
							self drivepath( exit_path );
							wait 1;
							self notify( "attempting_return" );
						}
						else self thread quadrotor_escape_into_air();
						self waittill_any( "near_goal", "force_goal", "reached_end_node", "return_timeout" );
					}
					if ( !isDefined( self.revive_target ) )
					{
						player = self player_in_last_stand_within_range( 500 );
						if ( isDefined( player ) )
						{
							self.revive_target = player;
							player.quadrotor_revive = 1;
							vox_line = "vox_maxi_drone_revive_" + randomintrange( 0, 5 );
							maps/mp/zm_tomb_vo::maxissay( vox_line, self );
						}
					}
					if ( isDefined( self.revive_target ) )
					{
						origin = self.revive_target.origin;
						origin = ( origin[ 0 ], origin[ 1 ], origin[ 2 ] + 150 );
						z = self getheliheightlockheight( origin );
						origin = ( origin[ 0 ], origin[ 1 ], z );
						if ( self setvehgoalpos( origin, 1, 2, 1 ) )
						{
							self waittill_any( "near_goal", "force_goal", "reached_end_node" );
							level thread watch_for_fail_revive( self );
							wait 1;
							if ( isDefined( self.revive_target ) && self.revive_target maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
							{
								playfxontag( level._effect[ "staff_charge" ], self.revive_target, "tag_origin" );
								self.revive_target notify( "remote_revive" );
								self.revive_target do_player_general_vox( "quadrotor", "rspnd_drone_revive", undefined, 100 );
								self.player_owner notify( "revived_player_with_quadrotor" );
							}
							self.revive_target = undefined;
							self setvehgoalpos( origin, 1 );
							wait 1;
						}
					}
					else player.quadrotor_revive = undefined;
					wait 0,1;
				}
				a_powerups = [];
				if ( level.active_powerups.size > 0 && isDefined( self.player_owner ) )
				{
					a_powerups = get_array_of_closest( self.player_owner.origin, level.active_powerups, undefined, undefined, 500 );
				}
				if ( a_powerups.size > 0 )
				{
					b_got_powerup = 0;
					_a565 = a_powerups;
					_k565 = getFirstArrayKey( _a565 );
					while ( isDefined( _k565 ) )
					{
						powerup = _a565[ _k565 ];
						if ( self setvehgoalpos( powerup.origin, 1, 2, 1 ) )
						{
							self waittill_any( "near_goal", "force_goal", "reached_end_node" );
							if ( isDefined( powerup ) )
							{
								self.player_owner.ignore_range_powerup = powerup;
								b_got_powerup = 1;
							}
							wait 1;
							break;
						}
						else
						{
							_k565 = getNextArrayKey( _a565, _k565 );
						}
					}
					while ( b_got_powerup )
					{
						continue;
					}
					wait 0,1;
				}
				a_special_items = getentarray( "quad_special_item", "script_noteworthy" );
				if ( level.n_ee_medallions > 0 && isDefined( self.player_owner ) )
				{
					e_special_item = getclosest( self.player_owner.origin, a_special_items, 500 );
					if ( isDefined( e_special_item ) )
					{
						self setneargoalnotifydist( 4 );
						if ( isDefined( e_special_item.target ) )
						{
							s_start_pos = getstruct( e_special_item.target, "targetname" );
							self setvehgoalpos( s_start_pos.origin, 1, 0, 1 );
							self waittill_any( "near_goal", "force_goal", "reached_end_node" );
						}
						self setvehgoalpos( e_special_item.origin + vectorScale( ( 0, 0, 1 ), 30 ), 1, 0, 1 );
						self waittill_any( "near_goal", "force_goal", "reached_end_node" );
						wait 1;
						playfx( level._effect[ "staff_charge" ], e_special_item.origin );
						e_special_item hide();
						level.n_ee_medallions--;

						level notify( "quadrotor_medallion_found" );
						if ( isDefined( e_special_item.target ) )
						{
							s_start_pos = getstruct( e_special_item.target, "targetname" );
							self setvehgoalpos( s_start_pos.origin, 1, 0, 1 );
							self waittill_any( "near_goal", "force_goal", "reached_end_node" );
						}
						if ( level.n_ee_medallions == 0 )
						{
							s_mg_spawn = getstruct( "mgspawn", "targetname" );
							self setvehgoalpos( s_mg_spawn.origin + vectorScale( ( 0, 0, 1 ), 30 ), 1, 0, 1 );
							self waittill_any( "near_goal", "force_goal", "reached_end_node" );
							wait 1;
							playfx( level._effect[ "staff_charge" ], s_mg_spawn.origin );
							e_special_item playsound( "zmb_perks_packa_ready" );
							flag_set( "ee_medallions_collected" );
						}
						e_special_item delete();
						self setneargoalnotifydist( 30 );
						self setvehgoalpos( self.origin, 1 );
					}
				}
				if ( isDefined( level.quadrotor_custom_behavior ) )
				{
					self [[ level.quadrotor_custom_behavior ]]();
				}
				goalpos = quadrotor_find_new_position();
				if ( self setvehgoalpos( goalpos, 1, 2, 1 ) )
				{
					goalfailures = 0;
					if ( isDefined( self.goal_node ) )
					{
						self.goal_node.quadrotor_claimed = 1;
					}
					if ( isDefined( self.enemy ) && self vehcansee( self.enemy ) )
					{
						if ( randomint( 100 ) > 50 )
						{
							self setlookatent( self.enemy );
						}
					}
					self waittill_any_timeout( 12, "near_goal", "force_goal", "reached_end_node" );
					if ( isDefined( self.enemy ) && self vehcansee( self.enemy ) )
					{
						self setlookatent( self.enemy );
						wait randomfloatrange( 1, 4 );
						self clearlookatent();
					}
					if ( isDefined( self.goal_node ) )
					{
						self.goal_node.quadrotor_claimed = undefined;
					}
					continue;
				}
				else
				{
					goalfailures++;
					if ( isDefined( self.goal_node ) )
					{
						self.goal_node.quadrotor_fails = 1;
					}
					if ( goalfailures == 1 )
					{
						wait 0,5;
					}
				}
				else if ( goalfailures == 2 )
				{
					goalpos = self.origin;
				}
				else if ( goalfailures == 3 )
				{
					goalpos = self quadrotor_get_closest_node();
					self setvehgoalpos( goalpos, 1 );
					self waittill( "near_goal" );
				}
				else
				{
					if ( goalfailures > 3 )
					{
/#
						println( "WARNING: Quadrotor can't find path to goal over 4 times." + self.origin + " " + goalpos );
						line( self.origin, goalpos, ( 0, 0, 1 ), 1, 100 );
#/
						self.goalpos = make_sure_goal_is_well_above_ground( goalpos );
					}
				}
				old_goalpos = goalpos;
				offset = ( randomfloatrange( -50, 50 ), randomfloatrange( -50, 50 ), randomfloatrange( 50, 150 ) );
				goalpos += offset;
				goalpos = quadrotor_adjust_goal_for_enemy_height( goalpos );
				if ( self quadrotor_check_move( goalpos ) )
				{
					self setvehgoalpos( goalpos, 1 );
					self waittill_any( "near_goal", "force_goal", "start_vehiclepath" );
					wait randomfloatrange( 1, 3 );
					if ( !self.vehonpath )
					{
						self setvehgoalpos( old_goalpos, 1 );
						self waittill_any( "near_goal", "force_goal", "start_vehiclepath" );
					}
				}
				wait 0,5;
			}
		}
	}
}

quadrotor_escape_into_air()
{
/#
	iprintln( "couldn't path to exit" );
#/
	self.goalpos = self.origin + vectorScale( ( 0, 0, 1 ), 2048 );
	can_path_straight_up = self setvehgoalpos( self.goalpos, 1, 0, 1 );
	trace_goalpos = physicstrace( self.origin, self.goalpos );
	if ( can_path_straight_up && trace_goalpos[ "position" ] == self.goalpos )
	{
/#
		iprintln( "I can go straight up" );
#/
		self notify( "attempting_return" );
	}
	else
	{
/#
		iprintln( "Failed pathing straight up" );
#/
		self notify( "attempting_return" );
		playfx( level._effect[ "tesla_elec_kill" ], self.origin );
		self playsound( "zmb_qrdrone_leave" );
		self delete();
		level notify( "drone_available" );
	}
}

quadrotor_get_closest_node()
{
	nodes = getnodesinradiussorted( self.origin, 200, 0, 500, "Path" );
	if ( nodes.size == 0 )
	{
		nodes = getnodesinradiussorted( self.goalpos, 3000, 0, 2000, "Path" );
	}
	_a775 = nodes;
	_k775 = getFirstArrayKey( _a775 );
	while ( isDefined( _k775 ) )
	{
		node = _a775[ _k775 ];
		if ( node.type == "BAD NODE" || !node has_spawnflag( 2097152 ) )
		{
		}
		else
		{
			return make_sure_goal_is_well_above_ground( node.origin );
		}
		_k775 = getNextArrayKey( _a775, _k775 );
	}
	return self.origin;
}

quadrotor_find_new_position()
{
	if ( !isDefined( self.goalpos ) )
	{
		self.goalpos = self.origin;
	}
	origin = self.goalpos;
	nodes = getnodesinradius( self.goalpos, self.goalradius, 0, self.flyheight + 300, "Path" );
	if ( nodes.size == 0 )
	{
		nodes = getnodesinradius( self.goalpos, self.goalradius + 1000, 0, self.flyheight + 1000, "Path" );
	}
	if ( nodes.size == 0 )
	{
		nodes = getnodesinradius( self.goalpos, self.goalradius + 5000, 0, self.flyheight + 4000, "Path" );
	}
	best_node = undefined;
	best_score = 0;
	_a812 = nodes;
	_k812 = getFirstArrayKey( _a812 );
	while ( isDefined( _k812 ) )
	{
		node = _a812[ _k812 ];
		if ( node.type == "BAD NODE" || !node has_spawnflag( 2097152 ) )
		{
		}
		else
		{
			if ( isDefined( node.quadrotor_fails ) || isDefined( node.quadrotor_claimed ) )
			{
				score = randomfloat( 30 );
			}
			else
			{
				score = randomfloat( 100 );
			}
			if ( score > best_score )
			{
				best_score = score;
				best_node = node;
			}
		}
		_k812 = getNextArrayKey( _a812, _k812 );
	}
	if ( isDefined( best_node ) )
	{
		origin = best_node.origin + ( 0, 0, self.flyheight + randomfloatrange( -30, 40 ) );
		z = self getheliheightlockheight( origin );
		origin = ( origin[ 0 ], origin[ 1 ], z );
		self.goal_node = best_node;
	}
	return origin;
}

quadrotor_teleport_to_nearest_node()
{
	self.origin = self quadrotor_get_closest_node();
}

quadrotor_damage()
{
	self endon( "crash_done" );
	while ( isDefined( self ) )
	{
		self waittill( "damage", damage );
		while ( isDefined( self.off ) )
		{
			continue;
		}
		if ( type != "MOD_EXPLOSIVE" || type == "MOD_GRENADE_SPLASH" && type == "MOD_PROJECTILE_SPLASH" )
		{
			self setvehvelocity( self.velocity + ( vectornormalize( dir ) * 300 ) );
			ang_vel = self getangularvelocity();
			ang_vel += ( randomfloatrange( -300, 300 ), randomfloatrange( -300, 300 ), randomfloatrange( -300, 300 ) );
			self setangularvelocity( ang_vel );
		}
		else
		{
			ang_vel = self getangularvelocity();
			yaw_vel = randomfloatrange( -320, 320 );
			if ( yaw_vel < 0 )
			{
				yaw_vel -= 150;
			}
			else
			{
				yaw_vel += 150;
			}
			ang_vel += ( randomfloatrange( -150, 150 ), yaw_vel, randomfloatrange( -150, 150 ) );
			self setangularvelocity( ang_vel );
		}
		wait 0,3;
	}
}

quadrotor_cleanup_fx()
{
	if ( isDefined( self.stun_fx ) )
	{
		self.stun_fx delete();
	}
}

quadrotor_death()
{
	wait 0,1;
	self notify( "nodeath_thread" );
	self waittill( "death", attacker, damagefromunderneath, weaponname, point, dir );
	self notify( "nodeath_thread" );
	if ( isDefined( self.goal_node ) && isDefined( self.goal_node.quadrotor_claimed ) )
	{
		self.goal_node.quadrotor_claimed = undefined;
	}
	if ( isDefined( self.delete_on_death ) )
	{
		if ( isDefined( self ) )
		{
			self quadrotor_cleanup_fx();
			self delete();
			level.maxis_quadrotor = undefined;
		}
		return;
	}
	if ( !isDefined( self ) )
	{
		return;
	}
	self endon( "death" );
	self disableaimassist();
	self death_fx();
	self thread death_radius_damage();
	self thread set_death_model( self.deathmodel, self.modelswapdelay );
	self thread quadrotor_crash_movement( attacker, dir );
	self quadrotor_cleanup_fx();
	self waittill( "crash_done" );
	self delete();
	level.maxis_quadrotor = undefined;
}

death_fx()
{
	if ( isDefined( self.deathfx ) )
	{
		playfxontag( self.deathfx, self, self.deathfxtag );
	}
	self playsound( "veh_qrdrone_sparks" );
}

quadrotor_crash_movement( attacker, hitdir )
{
	level endon( "end_game" );
	self endon( "crash_done" );
	self endon( "death" );
	self cancelaimove();
	self clearvehgoalpos();
	self clearlookatent();
	self setphysacceleration( vectorScale( ( 0, 0, 1 ), 800 ) );
	self.vehcheckforpredictedcrash = 1;
	if ( !isDefined( hitdir ) )
	{
		hitdir = ( 0, 0, 1 );
	}
	side_dir = vectorcross( hitdir, ( 0, 0, 1 ) );
	side_dir_mag = randomfloatrange( -100, 100 );
	side_dir_mag += sign( side_dir_mag ) * 80;
	side_dir *= side_dir_mag;
	self setvehvelocity( self.velocity + vectorScale( ( 0, 0, 1 ), 100 ) + vectornormalize( side_dir ) );
	ang_vel = self getangularvelocity();
	ang_vel = ( ang_vel[ 0 ] * 0,3, ang_vel[ 1 ], ang_vel[ 2 ] * 0,3 );
	yaw_vel = randomfloatrange( 0, 210 ) * sign( ang_vel[ 1 ] );
	yaw_vel += sign( yaw_vel ) * 180;
	ang_vel += ( randomfloatrange( -1, 1 ), yaw_vel, randomfloatrange( -1, 1 ) );
	self setangularvelocity( ang_vel );
	self.crash_accel = randomfloatrange( 75, 110 );
	if ( !isDefined( self.off ) )
	{
		self thread quadrotor_crash_accel();
	}
	self thread quadrotor_collision();
	self playsound( "veh_qrdrone_dmg_hit" );
	if ( !isDefined( self.off ) )
	{
		self thread qrotor_dmg_snd();
	}
	wait 0,1;
	if ( randomint( 100 ) < 40 && !isDefined( self.off ) )
	{
		self thread quadrotor_fire_for_time( randomfloatrange( 0,7, 2 ) );
	}
	wait 15;
	self notify( "crash_done" );
}

qrotor_dmg_snd()
{
	dmg_ent = spawn( "script_origin", self.origin );
	dmg_ent linkto( self );
	dmg_ent playloopsound( "veh_qrdrone_dmg_loop" );
	self waittill_any( "crash_done", "death" );
	dmg_ent stoploopsound( 1 );
	wait 2;
	dmg_ent delete();
}

quadrotor_fire_for_time( totalfiretime )
{
	level endon( "end_game" );
	self endon( "crash_done" );
	self endon( "change_state" );
	self endon( "death" );
	if ( isDefined( self.emped ) )
	{
		return;
	}
	weaponname = self seatgetweapon( 0 );
	firetime = weaponfiretime( weaponname );
	time = 0;
	firecount = 1;
	while ( time < totalfiretime && !isDefined( self.emped ) )
	{
		if ( isDefined( self.enemy ) && isDefined( self.enemy.attackeraccuracy ) && self.enemy.attackeraccuracy == 0 )
		{
			self fireweapon( undefined, undefined, 1 );
			firecount++;
			continue;
		}
		else
		{
			self fireweapon();
		}
		firecount++;
		wait firetime;
		time += firetime;
	}
}

quadrotor_crash_accel()
{
	level endon( "end_game" );
	self endon( "crash_done" );
	self endon( "death" );
	count = 0;
	while ( 1 )
	{
		self setvehvelocity( self.velocity + ( anglesToUp( self.angles ) * self.crash_accel ) );
		self.crash_accel *= 0,98;
		wait 0,1;
		count++;
		if ( ( count % 8 ) == 0 )
		{
			if ( randomint( 100 ) > 40 )
			{
				if ( self.velocity[ 2 ] > 150 )
				{
					self.crash_accel *= 0,75;
					break;
				}
				else if ( self.velocity[ 2 ] < 40 && count < 60 )
				{
					if ( abs( self.angles[ 0 ] ) > 30 || abs( self.angles[ 2 ] ) > 30 )
					{
						self.crash_accel = randomfloatrange( 160, 200 );
						break;
					}
					else
					{
						self.crash_accel = randomfloatrange( 85, 120 );
					}
				}
			}
		}
	}
}

quadrotor_predicted_collision()
{
	level endon( "end_game" );
	self endon( "crash_done" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "veh_predictedcollision", velocity, normal );
		if ( normal[ 2 ] >= 0,6 )
		{
			self notify( "veh_collision" );
		}
	}
}

quadrotor_collision_player()
{
	level endon( "end_game" );
	self endon( "change_state" );
	self endon( "crash_done" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "veh_collision", velocity, normal );
		driver = self getseatoccupant( 0 );
		if ( isDefined( driver ) && lengthsquared( velocity ) > 4900 )
		{
			earthquake( 0,25, 0,25, driver.origin, 50 );
			driver playrumbleonentity( "damage_heavy" );
		}
	}
}

quadrotor_collision()
{
	level endon( "end_game" );
	self endon( "change_state" );
	self endon( "crash_done" );
	self endon( "death" );
	if ( !isalive( self ) )
	{
		self thread quadrotor_predicted_collision();
	}
	self.bounce_count = 0;
	time_of_last_bounce = 0;
	while ( 1 )
	{
		self waittill( "veh_collision", velocity, normal );
		ang_vel = self getangularvelocity() * 0,5;
		self setangularvelocity( ang_vel );
		if ( normal[ 2 ] < 0,6 || isalive( self ) && !isDefined( self.emped ) )
		{
			self setvehvelocity( self.velocity + ( normal * 90 ) );
			self playsound( "veh_qrdrone_wall" );
			if ( normal[ 2 ] < 0,6 )
			{
				fx_origin = self.origin - ( normal * 28 );
			}
			else
			{
				fx_origin = self.origin - ( normal * 10 );
			}
			playfx( level._effect[ "quadrotor_nudge" ], fx_origin, normal );
			current_time = getTime();
			if ( ( current_time - time_of_last_bounce ) < 1000 )
			{
				self.bounce_count += 1;
				if ( self.bounce_count > 2 )
				{
					self notify( "force_goal" );
					self.bounce_count = 0;
				}
			}
			else
			{
				self.bounce_count = 0;
			}
			time_of_last_bounce = getTime();
			continue;
		}
		else
		{
			if ( isDefined( self.emped ) )
			{
				if ( isDefined( self.bounced ) )
				{
					self playsound( "veh_qrdrone_wall" );
					self setvehvelocity( ( 0, 0, 1 ) );
					self setangularvelocity( ( 0, 0, 1 ) );
					if ( self.angles[ 0 ] < 0 )
					{
						if ( self.angles[ 0 ] < -15 )
						{
							self.angles = ( -15, self.angles[ 1 ], self.angles[ 2 ] );
						}
						else
						{
							if ( self.angles[ 0 ] > -10 )
							{
								self.angles = ( -10, self.angles[ 1 ], self.angles[ 2 ] );
							}
						}
					}
					else if ( self.angles[ 0 ] > 15 )
					{
						self.angles = ( 15, self.angles[ 1 ], self.angles[ 2 ] );
					}
					else
					{
						if ( self.angles[ 0 ] < 10 )
						{
							self.angles = ( 10, self.angles[ 1 ], self.angles[ 2 ] );
						}
					}
					self.bounced = undefined;
					self notify( "landed" );
					return;
				}
				else
				{
					self.bounced = 1;
					self setvehvelocity( self.velocity + ( normal * 120 ) );
					self playsound( "veh_qrdrone_wall" );
					if ( normal[ 2 ] < 0,6 )
					{
						fx_origin = self.origin - ( normal * 28 );
					}
					else
					{
						fx_origin = self.origin - ( normal * 10 );
					}
					playfx( level._effect[ "quadrotor_nudge" ], fx_origin, normal );
				}
				break;
			}
			else
			{
				createdynentandlaunch( self.deathmodel, self.origin, self.angles, self.origin, self.velocity * 0,01 );
				self playsound( "veh_qrdrone_explo" );
				self thread death_fire_loop_audio();
				self notify( "crash_done" );
			}
		}
	}
}

death_fire_loop_audio()
{
	sound_ent = spawn( "script_origin", self.origin );
	sound_ent playloopsound( "veh_qrdrone_death_fire_loop", 0,1 );
	wait 11;
	sound_ent stoploopsound( 1 );
	sound_ent delete();
}

quadrotor_set_team( team )
{
	self.team = team;
	self.vteam = team;
	self setteam( team );
	if ( !isDefined( self.off ) )
	{
		quadrotor_blink_lights();
	}
}

quadrotor_blink_lights()
{
	level endon( "end_game" );
	self endon( "death" );
	self lights_off();
	wait 0,1;
	self lights_on();
}

quadrotor_self_destruct()
{
	level endon( "end_game" );
	self endon( "death" );
	self endon( "exit_vehicle" );
	self_destruct = 0;
	self_destruct_time = 0;
	for ( ;; )
	{
		while ( 1 )
		{
			if ( !self_destruct )
			{
				if ( level.player meleebuttonpressed() )
				{
					self_destruct = 1;
					self_destruct_time = 5;
				}
				wait 0,05;
			}
		}
		else iprintlnbold( self_destruct_time );
		wait 1;
		self_destruct_time -= 1;
		if ( self_destruct_time == 0 )
		{
			driver = self getseatoccupant( 0 );
			if ( isDefined( driver ) )
			{
				driver disableinvulnerability();
			}
			earthquake( 3, 1, self.origin, 256 );
			radiusdamage( self.origin, 1000, 15000, 15000, level.player, "MOD_EXPLOSIVE" );
			self dodamage( self.health + 1000, self.origin );
		}
	}
}
}

quadrotor_level_out_for_landing()
{
	level endon( "end_game" );
	self endon( "death" );
	self endon( "emped" );
	self endon( "landed" );
	while ( isDefined( self.emped ) )
	{
		velocity = self.velocity;
		self.angles = ( self.angles[ 0 ] * 0,85, self.angles[ 1 ], self.angles[ 2 ] * 0,85 );
		ang_vel = self getangularvelocity() * 0,85;
		self setangularvelocity( ang_vel );
		self setvehvelocity( velocity );
		wait 0,05;
	}
}

quadrotor_temp_bullet_shield( invulnerable_time )
{
	self notify( "bullet_shield" );
	self endon( "bullet_shield" );
	self.bullet_shield = 1;
	wait invulnerable_time;
	if ( isDefined( self ) )
	{
		self.bullet_shield = undefined;
		wait 3;
		if ( isDefined( self ) && self.health < 40 )
		{
			self.health = 40;
		}
	}
}

lights_on()
{
	self clearclientflag( 10 );
}

lights_off()
{
	self setclientflag( 10 );
}

death_radius_damage()
{
	if ( !isDefined( self ) || self.radiusdamageradius <= 0 )
	{
		return;
	}
	wait 0,05;
	if ( isDefined( self ) )
	{
		self radiusdamage( self.origin + vectorScale( ( 0, 0, 1 ), 15 ), self.radiusdamageradius, self.radiusdamagemax, self.radiusdamagemin, self, "MOD_EXPLOSIVE" );
	}
}

set_death_model( smodel, fdelay )
{
/#
	assert( isDefined( smodel ) );
#/
	if ( isDefined( fdelay ) && fdelay > 0 )
	{
		wait fdelay;
	}
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( isDefined( self.deathmodel_attached ) )
	{
		return;
	}
	self setmodel( smodel );
}

player_in_last_stand_within_range( range )
{
	players = getplayers();
	if ( players.size == 1 )
	{
		return;
	}
	_a1448 = players;
	_k1448 = getFirstArrayKey( _a1448 );
	while ( isDefined( _k1448 ) )
	{
		player = _a1448[ _k1448 ];
		if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && distancesquared( self.origin, player.origin ) < ( range * range ) && !isDefined( player.quadrotor_revive ) )
		{
			return player;
		}
		_k1448 = getNextArrayKey( _a1448, _k1448 );
	}
	return;
}

watch_for_fail_revive( quad_rotor )
{
	quadrotor = quad_rotor;
	owner = quad_rotor.player_owner;
	revive_target = quad_rotor.revive_target;
	revive_target endon( "bled_out" );
	revive_target endon( "disconnect" );
	level thread kill_fx_if_target_revive( quadrotor, revive_target );
	revive_target.revive_hud settext( &"GAME_PLAYER_IS_REVIVING_YOU", owner );
	revive_target revive_hud_show_n_fade( 1 );
	wait 1;
	if ( isDefined( revive_target ) )
	{
		revive_target.quadrotor_revive = undefined;
	}
}

kill_fx_if_target_revive( quadrotor, revive_target )
{
	e_fx = spawn( "script_model", quadrotor gettagorigin( "tag_origin" ) );
	e_fx setmodel( "tag_origin" );
	e_fx playsound( "zmb_drone_revive_fire" );
	e_fx playloopsound( "zmb_drone_revive_loop", 0,2 );
	playfxontag( level._effect[ "qd_revive" ], e_fx, "tag_origin" );
	e_fx moveto( revive_target.origin, 1 );
	timer = 0;
	while ( 1 )
	{
		if ( isDefined( revive_target ) && revive_target maps/mp/zombies/_zm_laststand::player_is_in_laststand() && isDefined( quadrotor ) )
		{
			wait 0,1;
			timer += 0,1;
			if ( timer >= 1 )
			{
				playfxontag( level._effect[ "staff_soul" ], e_fx, "tag_origin" );
				e_fx stoploopsound( 0,1 );
				e_fx playsound( "zmb_drone_revive_revive_3d" );
				revive_target playsoundtoplayer( "zmb_drone_revive_revive_plr", revive_target );
				break;
			}
			else }
		else }
	e_fx delete();
}
