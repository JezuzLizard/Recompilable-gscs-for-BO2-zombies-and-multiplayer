#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "fxanim_props_dlc4" );

init()
{
	level._challenges = spawnstruct();
	stats_init();
	level.a_m_challenge_boards = [];
	level.a_uts_challenge_boxes = [];
	a_m_challenge_boxes = getentarray( "challenge_box", "targetname" );
	array_thread( a_m_challenge_boxes, ::box_init );
	onplayerconnect_callback( ::onplayerconnect );
	n_bits = getminbitcountfornum( 14 );
	registerclientfield( "toplayer", "challenge_complete_1", 14000, 1, "int" );
	registerclientfield( "toplayer", "challenge_complete_2", 14000, 1, "int" );
	registerclientfield( "toplayer", "challenge_complete_3", 14000, 1, "int" );
	registerclientfield( "toplayer", "challenge_complete_4", 14000, 1, "int" );
/#
	level thread challenges_devgui();
#/
}

onplayerconnect()
{
	player_stats_init( self.characterindex );
	_a55 = level._challenges.a_players[ self.characterindex ].a_stats;
	_k55 = getFirstArrayKey( _a55 );
	while ( isDefined( _k55 ) )
	{
		s_stat = _a55[ _k55 ];
		s_stat.b_display_tag = 1;
		_a58 = level.a_m_challenge_boards;
		_k58 = getFirstArrayKey( _a58 );
		while ( isDefined( _k58 ) )
		{
			m_board = _a58[ _k58 ];
			m_board showpart( s_stat.str_medal_tag );
			m_board hidepart( s_stat.str_glow_tag );
			_k58 = getNextArrayKey( _a58, _k58 );
		}
		_k55 = getNextArrayKey( _a55, _k55 );
	}
	self thread onplayerspawned();
}

onplayerspawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		_a81 = level._challenges.a_players[ self.characterindex ].a_stats;
		_k81 = getFirstArrayKey( _a81 );
		while ( isDefined( _k81 ) )
		{
			s_stat = _a81[ _k81 ];
			while ( s_stat.b_medal_awarded && !s_stat.b_reward_claimed )
			{
				_a85 = level.a_m_challenge_boards;
				_k85 = getFirstArrayKey( _a85 );
				while ( isDefined( _k85 ) )
				{
					m_board = _a85[ _k85 ];
					self setclientfieldtoplayer( s_stat.s_parent.cf_complete, 1 );
					_k85 = getNextArrayKey( _a85, _k85 );
				}
			}
			_k81 = getNextArrayKey( _a81, _k81 );
		}
		_a92 = level._challenges.s_team.a_stats;
		_k92 = getFirstArrayKey( _a92 );
		while ( isDefined( _k92 ) )
		{
			s_stat = _a92[ _k92 ];
			while ( s_stat.b_medal_awarded && s_stat.a_b_player_rewarded[ self.characterindex ] )
			{
				_a96 = level.a_m_challenge_boards;
				_k96 = getFirstArrayKey( _a96 );
				while ( isDefined( _k96 ) )
				{
					m_board = _a96[ _k96 ];
					self setclientfieldtoplayer( s_stat.s_parent.cf_complete, 1 );
					_k96 = getNextArrayKey( _a96, _k96 );
				}
			}
			_k92 = getNextArrayKey( _a92, _k92 );
		}
	}
}

stats_init()
{
	level._challenges.a_stats = [];
	if ( isDefined( level.challenges_add_stats ) )
	{
		[[ level.challenges_add_stats ]]();
	}
	_a124 = level._challenges.a_stats;
	_k124 = getFirstArrayKey( _a124 );
	while ( isDefined( _k124 ) )
	{
		stat = _a124[ _k124 ];
		if ( isDefined( stat.fp_init_stat ) )
		{
			level thread [[ stat.fp_init_stat ]]();
		}
		_k124 = getNextArrayKey( _a124, _k124 );
	}
	level._challenges.a_players = [];
	i = 0;
	while ( i < 4 )
	{
		player_stats_init( i );
		i++;
	}
	team_stats_init();
}

add_stat( str_name, b_team, str_hint, n_goal, str_reward_model, fp_give_reward, fp_init_stat )
{
	if ( !isDefined( b_team ) )
	{
		b_team = 0;
	}
	if ( !isDefined( str_hint ) )
	{
		str_hint = &"";
	}
	if ( !isDefined( n_goal ) )
	{
		n_goal = 1;
	}
	stat = spawnstruct();
	stat.str_name = str_name;
	stat.b_team = b_team;
	stat.str_hint = str_hint;
	stat.n_goal = n_goal;
	stat.str_reward_model = str_reward_model;
	stat.fp_give_reward = fp_give_reward;
	if ( isDefined( fp_init_stat ) )
	{
		stat.fp_init_stat = fp_init_stat;
	}
	level._challenges.a_stats[ str_name ] = stat;
	stat.cf_complete = "challenge_complete_" + level._challenges.a_stats.size;
}

player_stats_init( n_index )
{
	a_characters = array( "d", "n", "r", "t" );
	str_character = a_characters[ n_index ];
	if ( !isDefined( level._challenges.a_players[ n_index ] ) )
	{
		level._challenges.a_players[ n_index ] = spawnstruct();
		level._challenges.a_players[ n_index ].a_stats = [];
	}
	s_player_set = level._challenges.a_players[ n_index ];
	n_challenge_index = 1;
	_a196 = level._challenges.a_stats;
	_k196 = getFirstArrayKey( _a196 );
	while ( isDefined( _k196 ) )
	{
		s_challenge = _a196[ _k196 ];
		if ( !s_challenge.b_team )
		{
			if ( !isDefined( s_player_set.a_stats[ s_challenge.str_name ] ) )
			{
				s_player_set.a_stats[ s_challenge.str_name ] = spawnstruct();
			}
			s_stat = s_player_set.a_stats[ s_challenge.str_name ];
			s_stat.s_parent = s_challenge;
			s_stat.n_value = 0;
			s_stat.b_medal_awarded = 0;
			s_stat.b_reward_claimed = 0;
			n_index = level._challenges.a_stats.size + 1;
			s_stat.str_medal_tag = "j_" + str_character + "_medal_0" + n_challenge_index;
			s_stat.str_glow_tag = "j_" + str_character + "_glow_0" + n_challenge_index;
			s_stat.b_display_tag = 0;
			n_challenge_index++;
		}
		_k196 = getNextArrayKey( _a196, _k196 );
	}
	s_player_set.n_completed = 0;
	s_player_set.n_medals_held = 0;
}

team_stats_init( n_index )
{
	if ( !isDefined( level._challenges.s_team ) )
	{
		level._challenges.s_team = spawnstruct();
		level._challenges.s_team.a_stats = [];
	}
	s_team_set = level._challenges.s_team;
	_a243 = level._challenges.a_stats;
	_k243 = getFirstArrayKey( _a243 );
	while ( isDefined( _k243 ) )
	{
		s_challenge = _a243[ _k243 ];
		if ( s_challenge.b_team )
		{
			if ( !isDefined( s_team_set.a_stats[ s_challenge.str_name ] ) )
			{
				s_team_set.a_stats[ s_challenge.str_name ] = spawnstruct();
			}
			s_stat = s_team_set.a_stats[ s_challenge.str_name ];
			s_stat.s_parent = s_challenge;
			s_stat.n_value = 0;
			s_stat.b_medal_awarded = 0;
			s_stat.b_reward_claimed = 0;
			s_stat.a_b_player_rewarded = array( 0, 0, 0, 0 );
			s_stat.str_medal_tag = "j_g_medal";
			s_stat.str_glow_tag = "j_g_glow";
			s_stat.b_display_tag = 1;
		}
		_k243 = getNextArrayKey( _a243, _k243 );
	}
	s_team_set.n_completed = 0;
	s_team_set.n_medals_held = 0;
}

challenge_exists( str_name )
{
	if ( isDefined( level._challenges.a_stats[ str_name ] ) )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

get_stat( str_stat, player )
{
	s_parent_stat = level._challenges.a_stats[ str_stat ];
/#
	assert( isDefined( s_parent_stat ), "Challenge stat: " + str_stat + " does not exist" );
#/
/#
	if ( !s_parent_stat.b_team )
	{
		assert( isDefined( player ), "Challenge stat: " + str_stat + " is a player stat, but no player passed in" );
	}
#/
	if ( s_parent_stat.b_team )
	{
		s_stat = level._challenges.s_team.a_stats[ str_stat ];
	}
	else
	{
		s_stat = level._challenges.a_players[ player.characterindex ].a_stats[ str_stat ];
	}
	return s_stat;
}

increment_stat( str_stat, n_increment )
{
	if ( !isDefined( n_increment ) )
	{
		n_increment = 1;
	}
	s_stat = get_stat( str_stat, self );
	if ( !s_stat.b_medal_awarded )
	{
		s_stat.n_value += n_increment;
		check_stat_complete( s_stat );
	}
}

set_stat( str_stat, n_set )
{
	s_stat = get_stat( str_stat, self );
	if ( !s_stat.b_medal_awarded )
	{
		s_stat.n_value = n_set;
		check_stat_complete( s_stat );
	}
}

check_stat_complete( s_stat )
{
	if ( s_stat.b_medal_awarded )
	{
		return 1;
	}
	if ( s_stat.n_value >= s_stat.s_parent.n_goal )
	{
		s_stat.b_medal_awarded = 1;
		if ( s_stat.s_parent.b_team )
		{
			s_team_stats = level._challenges.s_team;
			s_team_stats.n_completed++;
			s_team_stats.n_medals_held++;
			a_players = get_players();
			_a358 = a_players;
			_k358 = getFirstArrayKey( _a358 );
			while ( isDefined( _k358 ) )
			{
				player = _a358[ _k358 ];
				player setclientfieldtoplayer( s_stat.s_parent.cf_complete, 1 );
				player playsound( "evt_medal_acquired" );
				wait_network_frame();
				_k358 = getNextArrayKey( _a358, _k358 );
			}
		}
		else s_player_stats = level._challenges.a_players[ self.characterindex ];
		s_player_stats.n_completed++;
		s_player_stats.n_medals_held++;
		self playsound( "evt_medal_acquired" );
		self setclientfieldtoplayer( s_stat.s_parent.cf_complete, 1 );
		_a376 = level.a_m_challenge_boards;
		_k376 = getFirstArrayKey( _a376 );
		while ( isDefined( _k376 ) )
		{
			m_board = _a376[ _k376 ];
			m_board showpart( s_stat.str_glow_tag );
			_k376 = getNextArrayKey( _a376, _k376 );
		}
		if ( isplayer( self ) )
		{
			if ( ( level._challenges.a_players[ self.characterindex ].n_completed + level._challenges.s_team.n_completed ) == level._challenges.a_stats.size )
			{
				self notify( "all_challenges_complete" );
			}
		}
		else
		{
			_a391 = get_players();
			_k391 = getFirstArrayKey( _a391 );
			while ( isDefined( _k391 ) )
			{
				player = _a391[ _k391 ];
				if ( isDefined( player.characterindex ) )
				{
					if ( ( level._challenges.a_players[ player.characterindex ].n_completed + level._challenges.s_team.n_completed ) == level._challenges.a_stats.size )
					{
						player notify( "all_challenges_complete" );
					}
				}
				_k391 = getNextArrayKey( _a391, _k391 );
			}
		}
		wait_network_frame();
	}
}

stat_reward_available( stat, player )
{
	if ( isstring( stat ) )
	{
		s_stat = get_stat( stat, player );
	}
	else
	{
		s_stat = stat;
	}
	if ( !s_stat.b_medal_awarded )
	{
		return 0;
	}
	if ( s_stat.b_reward_claimed )
	{
		return 0;
	}
	if ( s_stat.s_parent.b_team && s_stat.a_b_player_rewarded[ player.characterindex ] )
	{
		return 0;
	}
	return 1;
}

player_has_unclaimed_team_reward()
{
	_a441 = level._challenges.s_team.a_stats;
	_k441 = getFirstArrayKey( _a441 );
	while ( isDefined( _k441 ) )
	{
		s_stat = _a441[ _k441 ];
		if ( s_stat.b_medal_awarded && !s_stat.a_b_player_rewarded[ self.characterindex ] )
		{
			return 1;
		}
		_k441 = getNextArrayKey( _a441, _k441 );
	}
	return 0;
}

board_init( m_board )
{
	self.m_board = m_board;
	a_challenges = getarraykeys( level._challenges.a_stats );
	a_characters = array( "d", "n", "r", "t" );
	m_board.a_s_medal_tags = [];
	b_team_hint_added = 0;
	_a473 = level._challenges.a_players;
	n_char_index = getFirstArrayKey( _a473 );
	while ( isDefined( n_char_index ) )
	{
		s_set = _a473[ n_char_index ];
		str_character = a_characters[ n_char_index ];
		n_challenge_index = 1;
		_a477 = s_set.a_stats;
		_k477 = getFirstArrayKey( _a477 );
		while ( isDefined( _k477 ) )
		{
			s_stat = _a477[ _k477 ];
			str_medal_tag = "j_" + str_character + "_medal_0" + n_challenge_index;
			str_glow_tag = "j_" + str_character + "_glow_0" + n_challenge_index;
			s_tag = spawnstruct();
			s_tag.v_origin = m_board gettagorigin( str_medal_tag );
			s_tag.s_stat = s_stat;
			s_tag.n_character_index = n_char_index;
			s_tag.str_medal_tag = str_medal_tag;
			m_board.a_s_medal_tags[ m_board.a_s_medal_tags.size ] = s_tag;
			m_board hidepart( str_medal_tag );
			m_board hidepart( str_glow_tag );
			n_challenge_index++;
			_k477 = getNextArrayKey( _a477, _k477 );
		}
		n_char_index = getNextArrayKey( _a473, n_char_index );
	}
	_a495 = level._challenges.s_team.a_stats;
	_k495 = getFirstArrayKey( _a495 );
	while ( isDefined( _k495 ) )
	{
		s_stat = _a495[ _k495 ];
		str_medal_tag = "j_g_medal";
		str_glow_tag = "j_g_glow";
		s_tag = spawnstruct();
		s_tag.v_origin = m_board gettagorigin( str_medal_tag );
		s_tag.s_stat = s_stat;
		s_tag.n_character_index = 4;
		s_tag.str_medal_tag = str_medal_tag;
		m_board.a_s_medal_tags[ m_board.a_s_medal_tags.size ] = s_tag;
		m_board hidepart( str_glow_tag );
		b_team_hint_added = 1;
		_k495 = getNextArrayKey( _a495, _k495 );
	}
	level.a_m_challenge_boards[ level.a_m_challenge_boards.size ] = m_board;
}

box_init()
{
	self useanimtree( -1 );
	s_unitrigger_stub = spawnstruct();
	s_unitrigger_stub.origin = self.origin + ( 0, 0, 0 );
	s_unitrigger_stub.angles = self.angles;
	s_unitrigger_stub.radius = 64;
	s_unitrigger_stub.script_length = 64;
	s_unitrigger_stub.script_width = 64;
	s_unitrigger_stub.script_height = 64;
	s_unitrigger_stub.cursor_hint = "HINT_NOICON";
	s_unitrigger_stub.hint_string = &"";
	s_unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	s_unitrigger_stub.prompt_and_visibility_func = ::box_prompt_and_visiblity;
	s_unitrigger_stub ent_flag_init( "waiting_for_grab" );
	s_unitrigger_stub ent_flag_init( "reward_timeout" );
	s_unitrigger_stub.b_busy = 0;
	s_unitrigger_stub.m_box = self;
	s_unitrigger_stub.b_disable_trigger = 0;
	if ( isDefined( self.script_string ) )
	{
		s_unitrigger_stub.str_location = self.script_string;
	}
	if ( isDefined( s_unitrigger_stub.m_box.target ) )
	{
		s_unitrigger_stub.m_board = getent( s_unitrigger_stub.m_box.target, "targetname" );
		s_unitrigger_stub board_init( s_unitrigger_stub.m_board );
	}
	unitrigger_force_per_player_triggers( s_unitrigger_stub, 1 );
	level.a_uts_challenge_boxes[ level.a_uts_challenge_boxes.size ] = s_unitrigger_stub;
	maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( s_unitrigger_stub, ::box_think );
}

box_prompt_and_visiblity( player )
{
	if ( self.stub.b_disable_trigger )
	{
		return 0;
	}
	self thread update_box_prompt( player );
	return 1;
}

update_box_prompt( player )
{
	self endon( "kill_trigger" );
	player endon( "death_or_disconnect" );
	str_hint = &"";
	str_old_hint = &"";
	m_board = self.stub.m_board;
	self sethintstring( str_hint );
	while ( 1 )
	{
		s_hint_tag = undefined;
		b_showing_stat = 0;
		self.b_can_open = 0;
		if ( self.stub.b_busy )
		{
			if ( self.stub ent_flag( "waiting_for_grab" ) || !isDefined( self.stub.player_using ) && self.stub.player_using == player )
			{
				str_hint = &"ZM_TOMB_CH_G";
			}
			else
			{
				str_hint = &"";
			}
		}
		else str_hint = &"";
		player.s_lookat_stat = undefined;
		n_closest_dot = 0,996;
		v_eye_origin = player getplayercamerapos();
		v_eye_direction = anglesToForward( player getplayerangles() );
		_a619 = m_board.a_s_medal_tags;
		str_tag = getFirstArrayKey( _a619 );
		while ( isDefined( str_tag ) )
		{
			s_tag = _a619[ str_tag ];
			if ( !s_tag.s_stat.b_display_tag )
			{
			}
			else
			{
				v_tag_origin = s_tag.v_origin;
				v_eye_to_tag = vectornormalize( v_tag_origin - v_eye_origin );
				n_dot = vectordot( v_eye_to_tag, v_eye_direction );
				if ( n_dot > n_closest_dot )
				{
					n_closest_dot = n_dot;
					str_hint = s_tag.s_stat.s_parent.str_hint;
					s_hint_tag = s_tag;
					b_showing_stat = 1;
					self.b_can_open = 0;
					if ( s_tag.n_character_index == player.characterindex || s_tag.n_character_index == 4 )
					{
						player.s_lookat_stat = s_tag.s_stat;
						if ( stat_reward_available( s_tag.s_stat, player ) )
						{
							str_hint = &"ZM_TOMB_CH_S";
							b_showing_stat = 0;
							self.b_can_open = 1;
						}
					}
				}
			}
			str_tag = getNextArrayKey( _a619, str_tag );
		}
		if ( str_hint == &"" )
		{
			s_player = level._challenges.a_players[ player.characterindex ];
			s_team = level._challenges.s_team;
			if ( s_player.n_medals_held > 0 || player player_has_unclaimed_team_reward() )
			{
				str_hint = &"ZM_TOMB_CH_O";
				self.b_can_open = 1;
				break;
			}
			else
			{
				str_hint = &"ZM_TOMB_CH_V";
			}
		}
		if ( str_old_hint != str_hint )
		{
			str_old_hint = str_hint;
			self.stub.hint_string = str_hint;
			if ( isDefined( s_hint_tag ) )
			{
				str_name = s_hint_tag.s_stat.s_parent.str_name;
				n_character_index = s_hint_tag.n_character_index;
				if ( n_character_index != 4 )
				{
					s_player_stat = level._challenges.a_players[ n_character_index ].a_stats[ str_name ];
					break;
				}
			}
			self sethintstring( self.stub.hint_string );
		}
		wait 0,1;
	}
}

box_think()
{
	self endon( "kill_trigger" );
	s_team = level._challenges.s_team;
	while ( 1 )
	{
		self waittill( "trigger", player );
		while ( !is_player_valid( player ) )
		{
			continue;
		}
		while ( self.stub.b_busy )
		{
			current_weapon = player getcurrentweapon();
			while ( isDefined( player.intermission ) && !player.intermission && !is_placeable_mine( current_weapon ) && !is_equipment_that_blocks_purchase( current_weapon ) && current_weapon != "none" && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && !player isthrowinggrenade() && !player in_revive_trigger() || player isswitchingweapons() && player.is_drinking > 0 )
			{
				wait 0,1;
			}
			if ( self.stub ent_flag( "waiting_for_grab" ) )
			{
				if ( !isDefined( self.stub.player_using ) )
				{
					self.stub.player_using = player;
				}
				if ( player == self.stub.player_using )
				{
					self.stub ent_flag_clear( "waiting_for_grab" );
				}
			}
			wait 0,05;
		}
		if ( self.b_can_open )
		{
			self.stub.hint_string = &"";
			self sethintstring( self.stub.hint_string );
			level thread open_box( player, self.stub );
		}
	}
}

get_reward_category( player, s_select_stat )
{
	if ( isDefined( s_select_stat ) || s_select_stat.s_parent.b_team && level._challenges.s_team.n_medals_held > 0 )
	{
		return level._challenges.s_team;
	}
	if ( level._challenges.a_players[ player.characterindex ].n_medals_held > 0 )
	{
		return level._challenges.a_players[ player.characterindex ];
	}
	return undefined;
}

get_reward_stat( s_category )
{
	_a809 = s_category.a_stats;
	_k809 = getFirstArrayKey( _a809 );
	while ( isDefined( _k809 ) )
	{
		s_stat = _a809[ _k809 ];
		if ( s_stat.b_medal_awarded && !s_stat.b_reward_claimed )
		{
			if ( s_stat.s_parent.b_team && s_stat.a_b_player_rewarded[ self.characterindex ] )
			{
				break;
			}
			else
			{
				return s_stat;
			}
		}
		_k809 = getNextArrayKey( _a809, _k809 );
	}
	return undefined;
}

open_box( player, ut_stub, fp_reward_override, param1 )
{
	m_box = ut_stub.m_box;
	while ( ut_stub.b_busy )
	{
		wait 1;
	}
	ut_stub.b_busy = 1;
	ut_stub.player_using = player;
	if ( isDefined( player ) && isDefined( player.s_lookat_stat ) )
	{
		s_select_stat = player.s_lookat_stat;
	}
	m_box setanim( %o_zombie_dlc4_challenge_box_open );
	m_box delay_thread( 0,75, ::setclientfield, "foot_print_box_glow", 1 );
	wait 0,5;
	if ( isDefined( fp_reward_override ) )
	{
		ut_stub [[ fp_reward_override ]]( player, param1 );
	}
	else
	{
		ut_stub spawn_reward( player, s_select_stat );
	}
	wait 1;
	m_box setanim( %o_zombie_dlc4_challenge_box_close );
	m_box delay_thread( 0,75, ::setclientfield, "foot_print_box_glow", 0 );
	wait 2;
	ut_stub.b_busy = 0;
	ut_stub.player_using = undefined;
}

spawn_reward( player, s_select_stat )
{
	if ( isDefined( player ) )
	{
		player endon( "death_or_disconnect" );
		if ( isDefined( s_select_stat ) )
		{
			s_category = get_reward_category( player, s_select_stat );
			if ( stat_reward_available( s_select_stat, player ) )
			{
				s_stat = s_select_stat;
			}
		}
		if ( !isDefined( s_stat ) )
		{
			s_category = get_reward_category( player );
			s_stat = player get_reward_stat( s_category );
		}
		if ( self [[ s_stat.s_parent.fp_give_reward ]]( player, s_stat ) )
		{
			if ( isDefined( s_stat.s_parent.cf_complete ) )
			{
				player setclientfieldtoplayer( s_stat.s_parent.cf_complete, 0 );
			}
			while ( s_stat.s_parent.b_team )
			{
				s_stat.a_b_player_rewarded[ player.characterindex ] = 1;
				a_players = get_players();
				_a917 = a_players;
				_k917 = getFirstArrayKey( _a917 );
				while ( isDefined( _k917 ) )
				{
					player = _a917[ _k917 ];
					if ( !s_stat.a_b_player_rewarded[ player.characterindex ] )
					{
						return;
					}
					_k917 = getNextArrayKey( _a917, _k917 );
				}
			}
			s_stat.b_reward_claimed = 1;
			s_category.n_medals_held--;

		}
	}
}

reward_grab_wait( n_timeout )
{
	if ( !isDefined( n_timeout ) )
	{
		n_timeout = 10;
	}
	self ent_flag_clear( "reward_timeout" );
	self ent_flag_set( "waiting_for_grab" );
	self endon( "waiting_for_grab" );
	if ( n_timeout > 0 )
	{
		wait n_timeout;
		self ent_flag_set( "reward_timeout" );
		self ent_flag_clear( "waiting_for_grab" );
	}
	else
	{
		self ent_flag_waitopen( "waiting_for_grab" );
	}
}

reward_sink( n_delay, n_z, n_time )
{
	if ( isDefined( n_delay ) )
	{
		wait n_delay;
		if ( isDefined( self ) )
		{
			self movez( n_z * -1, n_time );
		}
	}
}

reward_rise_and_grab( m_reward, n_z, n_rise_time, n_delay, n_timeout )
{
	m_reward movez( n_z, n_rise_time );
	wait n_rise_time;
	if ( n_timeout > 0 )
	{
		m_reward thread reward_sink( n_delay, n_z, n_timeout + 1 );
	}
	self reward_grab_wait( n_timeout );
	if ( self ent_flag( "reward_timeout" ) )
	{
		return 0;
	}
	return 1;
}

reward_points( player, s_stat )
{
	player maps/mp/zombies/_zm_score::add_to_player_score( 2500 );
}

challenges_devgui()
{
/#
	setdvar( "award_challenge", "0" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Challenges:10/Award Player1" "award_challenge 1"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Challenges:10/Award Player2" "award_challenge 2"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Challenges:10/Award Player3" "award_challenge 3"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Challenges:10/Award Team" "award_challenge 4"\n" );
	thread watch_devgui_award_challenges();
#/
}

watch_devgui_award_challenges()
{
/#
	while ( 1 )
	{
		n_award_challenge = getDvarInt( "award_challenge" );
		if ( n_award_challenge != 0 )
		{
			devgui_award_challenge( n_award_challenge );
			setdvarint( "award_challenge", 0 );
		}
		wait 0,5;
#/
	}
}

devgui_award_challenge( n_index )
{
/#
	if ( n_index == 4 )
	{
		s_team_stats = level._challenges.s_team;
		s_team_stats.n_completed = 1;
		s_team_stats.n_medals_held = 1;
		a_keys = getarraykeys( level._challenges.s_team.a_stats );
		s_stat = level._challenges.s_team.a_stats[ a_keys[ 0 ] ];
		s_stat.b_medal_awarded = 1;
		s_stat.b_reward_claimed = 0;
		a_players = get_players();
		_a1055 = a_players;
		_k1055 = getFirstArrayKey( _a1055 );
		while ( isDefined( _k1055 ) )
		{
			player = _a1055[ _k1055 ];
			s_stat.a_b_player_rewarded[ player.characterindex ] = 0;
			player setclientfieldtoplayer( s_stat.s_parent.cf_complete, 1 );
			_k1055 = getNextArrayKey( _a1055, _k1055 );
		}
		_a1061 = level.a_m_challenge_boards;
		_k1061 = getFirstArrayKey( _a1061 );
		while ( isDefined( _k1061 ) )
		{
			m_board = _a1061[ _k1061 ];
			m_board showpart( s_stat.str_glow_tag );
			_k1061 = getNextArrayKey( _a1061, _k1061 );
		}
	}
	else a_keys = getarraykeys( level._challenges.a_players[ 0 ].a_stats );
	a_players = get_players();
	_a1071 = a_players;
	_k1071 = getFirstArrayKey( _a1071 );
	while ( isDefined( _k1071 ) )
	{
		player = _a1071[ _k1071 ];
		s_player_data = level._challenges.a_players[ player.characterindex ];
		s_player_data.n_completed++;
		s_player_data.n_medals_held++;
		s_stat = s_player_data.a_stats[ a_keys[ n_index - 1 ] ];
		s_stat.b_medal_awarded = 1;
		s_stat.b_reward_claimed = 0;
		player setclientfieldtoplayer( s_stat.s_parent.cf_complete, 1 );
		_a1082 = level.a_m_challenge_boards;
		_k1082 = getFirstArrayKey( _a1082 );
		while ( isDefined( _k1082 ) )
		{
			m_board = _a1082[ _k1082 ];
			m_board showpart( s_stat.str_glow_tag );
			_k1082 = getNextArrayKey( _a1082, _k1082 );
		}
		_k1071 = getNextArrayKey( _a1071, _k1071 );
#/
	}
}
