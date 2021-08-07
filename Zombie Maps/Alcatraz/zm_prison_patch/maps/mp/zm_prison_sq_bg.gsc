#include maps/mp/zombies/_zm_weap_tomahawk;
#include maps/mp/zombies/_zm_afterlife;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( isDefined( level.gamedifficulty ) && level.gamedifficulty == 0 )
	{
		sq_bg_easy_cleanup();
		return;
	}
	precachemodel( "p6_zm_al_skull_afterlife" );
	flag_init( "warden_blundergat_obtained" );
	level thread wait_for_initial_conditions();
}

sq_bg_easy_cleanup()
{
	t_reward_pickup = getent( "sq_bg_reward_pickup", "targetname" );
	t_reward_pickup delete();
}

wait_for_initial_conditions()
{
	t_reward_pickup = getent( "sq_bg_reward_pickup", "targetname" );
	t_reward_pickup sethintstring( "" );
	t_reward_pickup setcursorhint( "HINT_NOICON" );
/#
	level thread debug_sq_bg_quest_starter();
#/
	level waittill( "bouncing_tomahawk_zm_aquired" );
	level.sq_bg_macguffins = [];
	a_s_mcguffin = getstructarray( "struct_sq_bg_macguffin", "targetname" );
	_a46 = a_s_mcguffin;
	_k46 = getFirstArrayKey( _a46 );
	while ( isDefined( _k46 ) )
	{
		struct = _a46[ _k46 ];
		m_temp = spawn( "script_model", struct.origin, 0 );
		m_temp.targetname = "sq_bg_macguffin";
		m_temp setmodel( struct.model );
		m_temp.angles = struct.angles;
		m_temp ghost();
		m_temp ghostindemo();
		level.sq_bg_macguffins[ level.sq_bg_macguffins.size ] = m_temp;
		wait_network_frame();
		_k46 = getNextArrayKey( _a46, _k46 );
	}
	array_thread( level.sq_bg_macguffins, ::sq_bg_macguffin_think );
	level.a_tomahawk_pickup_funcs[ level.a_tomahawk_pickup_funcs.size ] = ::tomahawk_the_macguffin;
	level thread check_sq_bg_progress();
	level waittill( "all_macguffins_acquired" );
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "quest_generic" );
	t_reward_pickup thread give_sq_bg_reward();
}

sq_bg_macguffin_think()
{
	self endon( "sq_bg_macguffin_received_by_player" );
	self thread maps/mp/zombies/_zm_afterlife::enable_afterlife_prop();
	self.health = 10000;
	self setcandamage( 1 );
	self setforcenocull();
	while ( 1 )
	{
		self waittill( "damage", amount, attacker );
		if ( attacker == level || isplayer( attacker ) && attacker getcurrentweapon() == "lightning_hands_zm" )
		{
			playfx( level._effect[ "ee_skull_shot" ], self.origin );
			self playsound( "zmb_powerpanel_activate" );
			self thread maps/mp/zombies/_zm_afterlife::disable_afterlife_prop();
			self thread wait_and_hide_sq_bg_macguffin();
		}
	}
}

wait_and_hide_sq_bg_macguffin()
{
	self notify( "restart_show_timer" );
	self endon( "restart_show_timer" );
	self endon( "caught_by_tomahawk" );
	wait 1,6;
	self thread maps/mp/zombies/_zm_afterlife::enable_afterlife_prop();
}

tomahawk_the_macguffin( grenade, n_grenade_charge_power )
{
	if ( !isDefined( level.sq_bg_macguffins ) || level.sq_bg_macguffins.size <= 0 )
	{
		return 0;
	}
	_a119 = level.sq_bg_macguffins;
	_k119 = getFirstArrayKey( _a119 );
	while ( isDefined( _k119 ) )
	{
		macguffin = _a119[ _k119 ];
		if ( distancesquared( macguffin.origin, grenade.origin ) < 10000 )
		{
			m_tomahawk = maps/mp/zombies/_zm_weap_tomahawk::tomahawk_spawn( grenade.origin );
			m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
			macguffin notify( "caught_by_tomahawk" );
			macguffin.origin = grenade.origin;
			macguffin linkto( m_tomahawk );
			macguffin thread maps/mp/zombies/_zm_afterlife::disable_afterlife_prop();
			self thread maps/mp/zombies/_zm_weap_tomahawk::tomahawk_return_player( m_tomahawk );
			self thread give_player_macguffin_upon_receipt( m_tomahawk, macguffin );
			return 1;
		}
		_k119 = getNextArrayKey( _a119, _k119 );
	}
	return 0;
}

give_player_macguffin_upon_receipt( m_tomahawk, m_macguffin )
{
	self endon( "disconnect" );
	while ( isDefined( m_tomahawk ) )
	{
		wait 0,05;
	}
	m_macguffin notify( "sq_bg_macguffin_received_by_player" );
	arrayremovevalue( level.sq_bg_macguffins, m_macguffin );
	m_macguffin delete();
	play_sound_at_pos( "purchase", self.origin );
	level notify( "sq_bg_macguffin_collected" );
}

check_sq_bg_progress()
{
	n_macguffins_total = level.sq_bg_macguffins.size;
	n_macguffins_collected = 0;
	while ( 1 )
	{
		level waittill( "sq_bg_macguffin_collected", player );
		n_macguffins_collected++;
		if ( n_macguffins_collected >= n_macguffins_total )
		{
			level notify( "all_macguffins_acquired" );
			break;
		}
		else play_sq_bg_collected_vo( player );
	}
	wait 1;
	player playsound( "zmb_easteregg_laugh" );
}

play_sq_bg_collected_vo( player )
{
	player endon( "disconnect" );
	wait 1;
	player thread do_player_general_vox( "quest", "pick_up_easter_egg" );
}

give_sq_bg_reward()
{
	s_reward_origin = getstruct( "sq_bg_reward", "targetname" );
	t_near = spawn( "trigger_radius", s_reward_origin.origin, 0, 196, 64 );
	while ( 1 )
	{
		t_near waittill( "trigger", ent );
		if ( isplayer( ent ) )
		{
			t_near thread sq_bg_spawn_rumble();
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	a_players = getplayers();
	if ( a_players.size == 1 )
	{
		if ( a_players[ 0 ] hasweapon( "blundergat_zm" ) )
		{
			str_reward_weapon = "blundersplat_zm";
			str_loc = &"ZM_PRISON_SQ_BS";
		}
		else
		{
			str_reward_weapon = "blundergat_zm";
			str_loc = &"ZM_PRISON_SQ_BG";
		}
	}
	else
	{
		str_reward_weapon = "blundergat_zm";
		str_loc = &"ZM_PRISON_SQ_BG";
	}
	m_reward_model = spawn_weapon_model( str_reward_weapon, undefined, s_reward_origin.origin, s_reward_origin.angles );
	m_reward_model moveto( m_reward_model.origin + vectorScale( ( 0, 0, 1 ), 14 ), 5 );
	level setclientfield( "sq_bg_reward_portal", 1 );
	self sethintstring( str_loc );
	for ( ;; )
	{
		while ( 1 )
		{
			self waittill( "trigger", player );
			current_weapon = player getcurrentweapon();
			if ( is_player_valid( player ) && player.is_drinking > 0 && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && level.revive_tool != current_weapon && current_weapon != "none" && !player hacker_active() )
			{
				if ( player hasweapon( str_reward_weapon ) )
				{
/#
					iprintln( "Player has" + str_reward_weapon + " , so don't give him another one" );
#/
				}
			}
			else self delete();
			level setclientfield( "sq_bg_reward_portal", 0 );
			wait_network_frame();
			m_reward_model delete();
			player take_old_weapon_and_give_reward( current_weapon, str_reward_weapon );
		}
	}
	t_near delete();
}

sq_bg_spawn_rumble()
{
	a_players = getplayers();
	_a285 = a_players;
	_k285 = getFirstArrayKey( _a285 );
	while ( isDefined( _k285 ) )
	{
		player = _a285[ _k285 ];
		if ( player istouching( self ) )
		{
			player setclientfieldtoplayer( "rumble_sq_bg", 1 );
		}
		_k285 = getNextArrayKey( _a285, _k285 );
	}
}

take_old_weapon_and_give_reward( current_weapon, reward_weapon, weapon_limit_override )
{
	if ( !isDefined( weapon_limit_override ) )
	{
		weapon_limit_override = 0;
	}
	if ( weapon_limit_override == 1 )
	{
		self takeweapon( current_weapon );
	}
	else
	{
		primaries = self getweaponslistprimaries();
		if ( isDefined( primaries ) && primaries.size >= 2 )
		{
			self takeweapon( current_weapon );
		}
	}
	self giveweapon( reward_weapon );
	self switchtoweapon( reward_weapon );
	flag_set( "warden_blundergat_obtained" );
	self playsoundtoplayer( "vox_brutus_easter_egg_872_0", self );
}

debug_sq_bg_quest_starter()
{
/#
	while ( 1 )
	{
		a_players = getplayers();
		_a327 = a_players;
		_k327 = getFirstArrayKey( _a327 );
		while ( isDefined( _k327 ) )
		{
			player = _a327[ _k327 ];
			if ( player hasweapon( "bouncing_tomahawk_zm" ) )
			{
				level notify( "bouncing_tomahawk_zm_aquired" );
				break;
			}
			else
			{
				_k327 = getNextArrayKey( _a327, _k327 );
			}
		}
		wait 1;
#/
	}
}
