#include maps/mp/zm_transit_bus;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "zm_transit_automaton" );

init_animtree()
{
	scriptmodelsuseanimtree( -1 );
}

initaudioaliases()
{
	level.vox zmbvoxadd( "automaton", "scripted", "discover_bus", "near_station1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "leaving_warning", "warning_out", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "leaving", "warning_leaving", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "emp_disable", "stop_generic", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "out_of_gas", "gas_out", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "refueled_gas", "gas_full", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "doors_open", "doors_open", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "doors_close", "doors_close", undefined );
	level.vox zmbvoxadd( "automaton", "convo", "player_enter", "player_enter", undefined );
	level.vox zmbvoxadd( "automaton", "convo", "player_leave", "player_exit", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "zombie_on_board", "zombie_enter", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "zombie_at_window", "zombie_attack", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "zombie_on_roof", "zombie_roof", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "player_attack_1", "player_1attack", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "player_attack_2", "player_2attack", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "player_attack_3", "player_3attack", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "hint_upgrade", "hint_upgrade", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "ride_generic", "ride_generic", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_station1", "near_station2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_station2", "near_station2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_station3", "near_station3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_station4", "near_station4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_station5", "near_station5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_diner1", "near_diner1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_diner2", "near_diner2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_diner3", "near_diner3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_diner4", "near_diner4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_diner5", "near_diner5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_tunnel1", "near_tunnel1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_tunnel2", "near_tunnel2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_tunnel3", "near_tunnel3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_tunnel4", "near_tunnel4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_tunnel5", "near_tunnel5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest1_1", "near_1forest1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest1_2", "near_1forest2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest1_3", "near_1forest3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest1_4", "near_1forest4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest1_5", "near_1forest5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest2_1", "near_2forest1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest2_2", "near_2forest2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest2_3", "near_2forest3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest2_4", "near_2forest4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_forest2_5", "near_2forest5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_farm1", "near_farm1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_farm2", "near_farm2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_farm3", "near_farm3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_farm4", "near_farm4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_farm5", "near_farm5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_corn1", "near_corn1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_corn2", "near_corn2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_corn3", "near_corn3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_corn4", "near_corn4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_corn5", "near_corn5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_power1", "near_power1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_power2", "near_power2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_power3", "near_power3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_power4", "near_power4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_power5", "near_power5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_town1", "near_town1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_town2", "near_town2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_town3", "near_town3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_town4", "near_town4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_town5", "near_town5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_bridge1", "near_bridge1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_bridge2", "near_bridge2", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_bridge3", "near_bridge3", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_bridge4", "near_bridge4", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "near_bridge5", "near_bridge5", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "leave_tunnel", "exit_tunnel1", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "bridge_collapse", "bridge_collapse", undefined );
	level.vox zmbvoxadd( "automaton", "inform", "player_pissed", "player_pissed", undefined );
}

main()
{
	level.automaton = getent( "bus_driver_head", "targetname" );
	level.automaton thread automatonsetup();
	level.timesplayerattackingautomaton = 0;
	level.automaton.greeting_timer = 0;
}

automatonsetup()
{
	self linkto( level.the_bus );
	self setmovingplatformenabled( 1 );
	self useanimtree( -1 );
	self setanim( %ai_zombie_bus_driver_idle );
	self addasspeakernpc( 1 );
	level.vox zmbvoxinitspeaker( "automaton", "vox_bus_", self );
	self thread automatondamagecallback();
	self thread automatonanimationsspeaking();
	self thread automatonemp();
	level thread bus_upgrade_vox();
}

automatondamagecallback()
{
	self setcandamage( 1 );
	self.health = 100000;
	triggers = getentarray( "bus_door_trigger", "targetname" );
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, directionvec, point, type );
		self.health = 100000;
		wait 1;
		while ( isDefined( self.disabled_by_emp ) && !self.disabled_by_emp && isDefined( self.isspeaking ) || self.isspeaking && isDefined( level.playerattackingautomaton ) && level.playerattackingautomaton )
		{
			continue;
		}
		self say_player_attack_vox();
		while ( level.timesplayerattackingautomaton < 3 )
		{
			continue;
		}
		level.timesplayerattackingautomaton = 0;
		if ( isDefined( attacker ) && isplayer( attacker ) )
		{
			wait 5;
			if ( !isDefined( self.dmgfxorigin ) )
			{
				self.dmgfxorigin = spawn( "script_model", point );
				self.dmgfxorigin setmodel( "tag_origin" );
				if ( isDefined( type ) && type == "MOD_GRENADE_SPLASH" )
				{
					self.dmgfxorigin.origin = self gettagorigin( "tag_origin" ) + vectorScale( ( 0, 0, 1 ), 40 );
				}
				self.dmgfxorigin linkto( self, "J_neck" );
			}
			wait 0,5;
			playfxontag( level._effect[ "switch_sparks" ], self.dmgfxorigin, "tag_origin" );
			_a204 = triggers;
			_k204 = getFirstArrayKey( _a204 );
			while ( isDefined( _k204 ) )
			{
				trigger = _a204[ _k204 ];
				trigger setinvisibletoall();
				_k204 = getNextArrayKey( _a204, _k204 );
			}
			level.the_bus.force_lock_doors = 1;
			if ( randomint( 100 ) > 50 )
			{
				if ( isDefined( level.the_bus.skip_next_destination ) && !level.the_bus.skip_next_destination )
				{
					level thread bus_skip_destination();
				}
				level thread automatonspeak( "inform", "player_pissed", undefined, 0 );
			}
			else
			{
				level thread automatonspeak( "inform", "player_pissed", undefined, 1 );
			}
			if ( level.the_bus.doorsclosed )
			{
				triggers[ 0 ] playsound( "zmb_bus_door_open" );
				level.the_bus maps/mp/zm_transit_bus::busdoorsopen();
				wait 1,25;
				shove_players_off_bus();
				wait 1,25;
				triggers[ 0 ] playsound( "zmb_bus_door_close" );
				level.the_bus maps/mp/zm_transit_bus::busdoorsclose();
			}
			else
			{
				shove_players_off_bus();
				wait 1,25;
				triggers[ 0 ] playsound( "zmb_bus_door_close" );
				level.the_bus maps/mp/zm_transit_bus::busdoorsclose();
			}
			wait 3,5;
			level thread automatonspeak( "inform", "player_pissed", undefined, 2 );
			wait 28;
			_a245 = triggers;
			_k245 = getFirstArrayKey( _a245 );
			while ( isDefined( _k245 ) )
			{
				trigger = _a245[ _k245 ];
				trigger setvisibletoall();
				_k245 = getNextArrayKey( _a245, _k245 );
			}
			level.the_bus.force_lock_doors = 0;
		}
		if ( isDefined( self.dmgfxorigin ) )
		{
			self.dmgfxorigin unlink();
			self.dmgfxorigin delete();
			self.dmgfxorigin = undefined;
		}
	}
}

bus_skip_destination()
{
	level.the_bus.skip_next_destination = 1;
	level.the_bus waittill( "skipping_destination" );
	level.the_bus.skip_next_destination = 0;
}

automatonanimationsspeaking()
{
	self thread bus_driver_idle();
	while ( 1 )
	{
		self waittill( "want_to_be_speaking", speakingline );
		self.isplayingspeakinganim = 1;
		while ( isDefined( self.isplayingidleanim ) && self.isplayingidleanim )
		{
			wait 0,05;
		}
		self notify( "startspeaking" );
		while ( isDefined( self.disabled_by_emp ) && self.disabled_by_emp )
		{
			self.isplayingspeakinganim = 0;
		}
		speakinganim = %ai_zombie_bus_driver_idle_dialog;
		speakingnum = 0;
		if ( issubstr( speakingline, "attack" ) || issubstr( speakingline, "pissed" ) )
		{
			speakinganim = %ai_zombie_bus_driver_idle_dialog_angry;
			speakingnum = 1;
		}
		else
		{
			if ( issubstr( speakingline, "warning_out" ) || is_true( level.bus_driver_focused ) )
			{
				speakinganim = %ai_zombie_bus_driver_idle_dialog_focused;
				speakingnum = 2;
				break;
			}
			else
			{
				if ( issubstr( speakingline, "zombie_enter" ) || isDefined( level.bus_zombie_danger ) && level.bus_zombie_danger )
				{
					speakinganim = %ai_zombie_bus_driver_idle_dialog_panicked;
					speakingnum = 3;
					break;
				}
				else
				{
					if ( issubstr( speakingline, "stop_generic" ) || issubstr( speakingline, "warning_leaving" ) )
					{
						speakinganim = %ai_zombie_bus_driver_idle_dialog_panicked;
						speakingnum = 3;
						break;
					}
					else
					{
						if ( issubstr( speakingline, "player_enter" ) )
						{
							speakinganim = %ai_zombie_bus_driver_player_enter;
							speakingnum = 4;
							break;
						}
						else if ( issubstr( speakingline, "player_leave" ) )
						{
							speakinganim = %ai_zombie_bus_driver_player_exit;
							speakingnum = 5;
							break;
						}
						else if ( issubstr( speakingline, "generic" ) )
						{
							if ( randomint( 100 ) > 50 )
							{
								speakinganim = %ai_zombie_bus_driver_forward_short_dialog;
								speakingnum = 7;
							}
							else
							{
								speakinganim = %ai_zombie_bus_driver_turnback_short_dialog;
								speakingnum = 6;
							}
							break;
						}
						else if ( issubstr( speakingline, "discover" ) )
						{
							speakinganim = %ai_zombie_bus_driver_idle_dialog;
							speakingnum = 0;
							break;
						}
						else
						{
							if ( isDefined( level.stops ) && isDefined( level.stops[ "depot" ] ) && level.stops[ "depot" ] < 1 && issubstr( speakingline, "near_" ) )
							{
								speakinganim = %ai_zombie_bus_driver_forward_short_dialog;
								speakingnum = 7;
							}
						}
					}
				}
			}
		}
		self setanim( speakinganim );
		self thread sndspeakinganimaudio( speakingnum );
/#
		if ( getDvar( #"96F6EBD9" ) != "" )
		{
			iprintlnbold( "" + speakinganim );
#/
		}
		wait getanimlength( speakinganim );
		self.isplayingspeakinganim = 0;
	}
}

bus_driver_idle()
{
	danger_anims = [];
	danger_anims[ 0 ] = %ai_zombie_bus_driver_idle_twitch_a;
	danger_anims[ 1 ] = %ai_zombie_bus_driver_idle_twitch_focused;
	danger_anims[ 2 ] = %ai_zombie_bus_driver_idle_twitch_panicked;
	danger_anims[ 3 ] = %ai_zombie_bus_driver_idle_twitch_b;
	focused_anims = [];
	focused_anims[ 0 ] = %ai_zombie_bus_driver_idle_twitch_panicked;
	focused_anims[ 1 ] = %ai_zombie_bus_driver_idle_twitch_focused;
	twitch_anims = [];
	twitch_anims[ 0 ] = %ai_zombie_bus_driver_idle_twitch_a;
	twitch_anims[ 1 ] = %ai_zombie_bus_driver_idle_twitch_b;
	idle_anims = [];
	idle_anims[ 0 ] = %ai_zombie_bus_driver_idle_a;
	idle_anims[ 1 ] = %ai_zombie_bus_driver_idle_b;
	idle_anims[ 2 ] = %ai_zombie_bus_driver_idle_c;
	idle_anims[ 3 ] = %ai_zombie_bus_driver_idle_d;
	idle_anims[ 4 ] = %ai_zombie_bus_driver_idle;
	while ( 1 )
	{
		while ( isDefined( self.isplayingspeakinganim ) || self.isplayingspeakinganim && isDefined( self.disabled_by_emp ) && self.disabled_by_emp )
		{
			wait 0,05;
		}
		if ( isDefined( level.bus_zombie_danger ) && level.bus_zombie_danger )
		{
			driveranim = random( danger_anims );
		}
		else
		{
			if ( is_true( level.bus_driver_focused ) )
			{
				driveranim = random( focused_anims );
				break;
			}
			else if ( randomint( 100 ) > 90 )
			{
				driveranim = random( twitch_anims );
				break;
			}
			else
			{
				driveranim = random( idle_anims );
			}
		}
		if ( isDefined( self.previous_anim ) && self.previous_anim == driveranim && driveranim != %ai_zombie_bus_driver_idle )
		{
			driveranim = %ai_zombie_bus_driver_idle;
		}
/#
		if ( getDvar( #"6DF184E8" ) != "" )
		{
			iprintlnbold( "Idle:" + driveranim );
#/
		}
		self.isplayingidleanim = 1;
		self setanim( driveranim );
		self thread sndplaydriveranimsnd( driveranim );
		wait getanimlength( driveranim );
		self.previous_anim = driveranim;
		self.isplayingidleanim = 0;
	}
}

automatonemp()
{
	while ( 1 )
	{
		if ( isDefined( level.the_bus.disabled_by_emp ) && !level.the_bus.disabled_by_emp )
		{
			level.the_bus waittill( "pre_power_off" );
		}
		level.automaton.disabled_by_emp = 1;
		level.automaton setanim( %ai_zombie_bus_driver_emp_powerdown );
		self thread sndplaydriveranimsnd( %ai_zombie_bus_driver_emp_powerdown );
		level.automaton maps/mp/zombies/_zm_audio::create_and_play_dialog( "inform", "emp_disable" );
		wait getanimlength( %ai_zombie_bus_driver_emp_powerdown );
		level.automaton setanim( %ai_zombie_bus_driver_emp_powerdown_idle );
		if ( isDefined( level.the_bus.pre_disabled_by_emp ) || level.the_bus.pre_disabled_by_emp && isDefined( level.the_bus.disabled_by_emp ) && level.the_bus.disabled_by_emp )
		{
			level.the_bus waittill( "power_on" );
		}
		level.automaton setanim( %ai_zombie_bus_driver_emp_powerup );
		self thread sndplaydriveranimsnd( %ai_zombie_bus_driver_emp_powerup );
		wait getanimlength( %ai_zombie_bus_driver_emp_powerup );
		level.automaton.disabled_by_emp = 0;
		self setanim( %ai_zombie_bus_driver_idle );
	}
}

say_player_attack_vox()
{
	if ( isDefined( level.the_bus.force_lock_doors ) && level.the_bus.force_lock_doors )
	{
		level.timesplayerattackingautomaton = 0;
		return;
	}
	else
	{
		if ( isDefined( level.playerattackingautomaton ) && level.playerattackingautomaton )
		{
			return;
		}
	}
	level.playerattackingautomaton = 1;
	if ( level.timesplayerattackingautomaton == 0 )
	{
		level thread automaton_attack_reset_timer();
	}
	level.timesplayerattackingautomaton++;
	level thread automatonspeak( "inform", "player_attack_" + level.timesplayerattackingautomaton );
	if ( level.timesplayerattackingautomaton >= 3 )
	{
		level notify( "automaton_threshold_reached" );
	}
	level thread automaton_attack_choke_timer();
}

automaton_attack_choke_timer()
{
	wait 10;
	level.playerattackingautomaton = 0;
}

automaton_attack_reset_timer()
{
	level endon( "automaton_threshold_reached" );
	wait 60;
	level.timesplayerattackingautomaton = 0;
}

bus_upgrade_vox()
{
	ladder_trig = getent( "bus_ladder_trigger", "targetname" );
	plow_trig = getent( "trigger_plow", "targetname" );
	hatch_trig = getent( "bus_hatch_bottom_trigger", "targetname" );
	while ( 1 )
	{
		while ( isDefined( level.stops ) && isDefined( level.stops[ "depot" ] ) && level.stops[ "depot" ] < 1 )
		{
			wait 1;
		}
		should_say_upgrade = -1;
		players = get_players();
		_a534 = players;
		_k534 = getFirstArrayKey( _a534 );
		while ( isDefined( _k534 ) )
		{
			player = _a534[ _k534 ];
			if ( isDefined( player.isonbus ) && player.isonbus )
			{
				if ( distancesquared( player.origin, hatch_trig.origin ) < 5184 && !flag( "hatch_attached" ) )
				{
					should_say_upgrade = 2;
				}
			}
			else
			{
				if ( distancesquared( player.origin, plow_trig.origin ) < 9216 && !flag( "catcher_attached" ) )
				{
					should_say_upgrade = 1;
					break;
				}
				else
				{
					if ( distancesquared( player.origin, ladder_trig.origin ) < 9216 && !flag( "ladder_attached" ) )
					{
						should_say_upgrade = 0;
					}
				}
			}
			_k534 = getNextArrayKey( _a534, _k534 );
		}
		if ( should_say_upgrade > -1 )
		{
			level thread automatonspeak( "inform", "hint_upgrade", undefined, should_say_upgrade );
			wait 60;
		}
		wait 1;
	}
}

shove_players_off_bus()
{
	playfxontag( level._effect[ "turbine_on" ], level.automaton, "J_neck" );
	wait 0,25;
	level.automaton playsound( "zmb_powerup_grabbed" );
	players = get_players();
	_a572 = players;
	_k572 = getFirstArrayKey( _a572 );
	while ( isDefined( _k572 ) )
	{
		player = _a572[ _k572 ];
		if ( isDefined( player.isonbus ) && player.isonbus )
		{
			dir = anglesToRight( level.the_bus.angles );
			dir = vectornormalize( dir );
			player_velocity = dir * 900;
			player setvelocity( player_velocity );
			earthquake( 0,25, 1, player.origin, 256, player );
		}
		_k572 = getNextArrayKey( _a572, _k572 );
	}
}

sndspeakinganimaudio( num )
{
	switch( num )
	{
		case 0:
			wait 0,4;
			self playsound( "evt_zmb_robot_jerk" );
			wait 2,4;
			self playsound( "evt_zmb_robot_jerk" );
			wait 2,25;
			self playsound( "evt_zmb_robot_jerk" );
			wait 1,1;
			self playsound( "evt_zmb_robot_jerk" );
			break;
		case 1:
			wait 0,31;
			self playsound( "evt_zmb_robot_jerk" );
			wait 3,55;
			self playsound( "evt_zmb_robot_jerk" );
			break;
		case 2:
			wait 0,18;
			self playsound( "evt_zmb_robot_jerk" );
			wait 4,83;
			self playsound( "evt_zmb_robot_jerk" );
			break;
		case 3:
			wait 0,23;
			self playsound( "evt_zmb_robot_jerk" );
			wait 0,77;
			self playsound( "evt_zmb_robot_jerk" );
			wait 1,4;
			self playsound( "evt_zmb_robot_jerk" );
			wait 0,15;
			self playsound( "evt_zmb_robot_spin" );
			wait 0,53;
			self playsound( "evt_zmb_robot_hat" );
			break;
		case 4:
			wait 0,3;
			self playsound( "evt_zmb_robot_jerk" );
			wait 3,64;
			self playsound( "evt_zmb_robot_jerk" );
			break;
		case 5:
			wait 0,38;
			self playsound( "evt_zmb_robot_jerk" );
			wait 3,4;
			self playsound( "evt_zmb_robot_jerk" );
			break;
		case 6:
			wait 0,3;
			self playsound( "evt_zmb_robot_jerk" );
			break;
		case 7:
		}
	}
}

sndplaydriveranimsnd( the_anim )
{
	if ( the_anim == %ai_zombie_bus_driver_idle_twitch_a )
	{
		wait 0,55;
		self playsound( "evt_zmb_robot_jerk" );
		wait 1,2;
		self playsound( "evt_zmb_robot_hat" );
		wait 0,79;
		self playsound( "evt_zmb_robot_spin" );
		wait 1,1;
		self playsound( "evt_zmb_robot_hat" );
		self playsound( "evt_zmb_robot_spin" );
	}
	else if ( the_anim == %ai_zombie_bus_driver_idle_twitch_focused )
	{
		wait 0,25;
		self playsound( "evt_zmb_robot_jerk" );
		wait 4,8;
		self playsound( "evt_zmb_robot_jerk" );
	}
	else if ( the_anim == %ai_zombie_bus_driver_idle_twitch_panicked )
	{
		wait 0,31;
		self playsound( "evt_zmb_robot_jerk" );
		wait 0,79;
		self playsound( "evt_zmb_robot_jerk" );
		wait 1,3;
		self playsound( "evt_zmb_robot_jerk" );
		wait 0,18;
		self playsound( "evt_zmb_robot_spin" );
		wait 0,52;
		self playsound( "evt_zmb_robot_hat" );
	}
	else if ( the_anim == %ai_zombie_bus_driver_idle_twitch_b )
	{
		wait 0,22;
		self playsound( "evt_zmb_robot_hat" );
		wait 1,06;
		self playsound( "evt_zmb_robot_spin" );
		wait 1,05;
		self playsound( "evt_zmb_robot_hat" );
		wait 1,07;
		self playsound( "evt_zmb_robot_spin" );
		wait 0,59;
		self playsound( "evt_zmb_robot_hat" );
	}
	else if ( the_anim == %ai_zombie_bus_driver_idle_d )
	{
		wait 0,24;
		self playsound( "evt_zmb_robot_spin" );
		wait 1,04;
		self playsound( "evt_zmb_robot_hat" );
	}
	else if ( the_anim == %ai_zombie_bus_driver_emp_powerdown )
	{
		wait 0,1;
		self playsound( "evt_zmb_robot_jerk" );
		wait 0,9;
		self playsound( "evt_zmb_robot_jerk" );
	}
	else
	{
		if ( the_anim == %ai_zombie_bus_driver_emp_powerup )
		{
			wait 0,63;
			self playsound( "evt_zmb_robot_jerk" );
		}
	}
}
