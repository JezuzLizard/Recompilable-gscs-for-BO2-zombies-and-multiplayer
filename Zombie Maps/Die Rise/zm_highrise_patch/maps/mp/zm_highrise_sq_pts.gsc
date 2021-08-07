#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_highrise_sq;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "fxanim_props" );

init_1()
{
	flag_init( "pts_1_springpads_placed" );
	declare_sidequest_stage( "sq_1", "pts_1", ::init_stage_1, ::stage_logic_1, ::exit_stage_1 );
}

init_2()
{
	flag_init( "pts_2_springpads_placed" );
	flag_init( "pts_2_generator_1_started" );
	flag_init( "pts_2_generator_2_started" );
	declare_sidequest_stage( "sq_2", "pts_2", ::init_stage_2, ::stage_logic_2, ::exit_stage_2 );
}

init_stage_1()
{
	clientnotify( "pts_1" );
	level.n_launched_zombies = 0;
	wait 15;
	level thread richtofen_pts_instructions();
	level thread richtofen_pts_placed();
}

init_stage_2()
{
	clientnotify( "pts_2" );
	level.sq_ball_putdown_trigs = [];
	level thread maxis_pts_instructions();
	level thread maxis_pts_placed();
}

stage_logic_1()
{
/#
	iprintlnbold( "PTS1 Started" );
#/
	watch_player_springpads( 0 );
	wait_for_all_springpads_placed( "pts_ghoul", "pts_1_springpads_placed" );
	maps/mp/zm_highrise_sq::light_dragon_fireworks( "r", 1 );
	wait_for_zombies_launched();
	maps/mp/zm_highrise_sq::light_dragon_fireworks( "r", 2 );
	stage_completed( "sq_1", "pts_1" );
}

wait_for_zombies_launched()
{
	level thread richtofen_zombies_launched();
	t_tower = getent( "pts_tower_trig", "targetname" );
	s_tower_top = getstruct( "sq_zombie_launch_target", "targetname" );
	while ( level.n_launched_zombies < 16 )
	{
		wait 0,5;
	}
}

watch_zombie_flings()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_springpad_zm_taken" );
	self endon( "equip_springpad_zm_pickup" );
	while ( level.n_launched_zombies < 16 )
	{
		self waittill( "fling" );
		level.n_launched_zombies++;
		if ( level.n_launched_zombies != 1 || level.n_launched_zombies == 5 && level.n_launched_zombies == 10 )
		{
			level notify( "pts1_say_next_line" );
		}
		wait 0,1;
	}
}

stage_logic_2()
{
/#
	iprintlnbold( "PTS2 Started" );
#/
	watch_player_springpads( 1 );
	level thread wait_for_balls_launched();
	flag_wait( "pts_2_generator_1_started" );
	maps/mp/zm_highrise_sq::light_dragon_fireworks( "m", 2 );
	flag_wait( "pts_2_generator_2_started" );
	maps/mp/zm_highrise_sq::light_dragon_fireworks( "m", 2 );
	level thread maxis_balls_placed();
	stage_completed( "sq_2", "pts_2" );
}

wait_for_balls_launched()
{
	level.current_generator = 1;
	a_lion_spots = getstructarray( "pts_lion", "targetname" );
	_a138 = a_lion_spots;
	_k138 = getFirstArrayKey( _a138 );
	while ( isDefined( _k138 ) )
	{
		s_lion_spot = _a138[ _k138 ];
		s_lion_spot.a_place_ball_trigs = [];
		s_lion_spot.springpad_buddy = getstruct( s_lion_spot.script_string, "script_noteworthy" );
		_k138 = getNextArrayKey( _a138, _k138 );
	}
	a_players = getplayers();
	_a145 = a_players;
	_k145 = getFirstArrayKey( _a145 );
	while ( isDefined( _k145 ) )
	{
		player = _a145[ _k145 ];
		player.a_place_ball_trigs = [];
		if ( isDefined( player.zm_sq_has_ball ) )
		{
			player thread player_has_ball();
		}
		_k145 = getNextArrayKey( _a145, _k145 );
	}
	while ( 1 )
	{
		level waittill( "zm_ball_picked_up", player );
		player thread player_has_ball();
	}
}

player_has_ball()
{
	self thread player_set_down_ball_watcher();
}

player_set_down_ball_watcher()
{
	self waittill_either( "zm_sq_ball_putdown", "zm_sq_ball_used" );
	pts_putdown_trigs_remove_for_player( self );
}

sq_pts_create_use_trigger( v_origin, radius, height, str_hint_string )
{
	t_pickup = spawn( "trigger_radius_use", v_origin, 0, radius, height );
	t_pickup setcursorhint( "HINT_NOICON" );
	t_pickup sethintstring( str_hint_string );
	t_pickup.targetname = "ball_place_trig";
	t_pickup triggerignoreteam();
	t_pickup usetriggerrequirelookat();
	return t_pickup;
}

place_ball_think( t_place_ball, s_lion_spot )
{
	t_place_ball endon( "delete" );
	t_place_ball waittill( "trigger" );
	pts_putdown_trigs_remove_for_spot( s_lion_spot );
	pts_putdown_trigs_remove_for_spot( s_lion_spot.springpad_buddy );
	self.zm_sq_has_ball = undefined;
	s_lion_spot.which_ball = self.which_ball;
	self notify( "zm_sq_ball_used" );
	s_lion_spot.zm_pts_animating = 1;
	s_lion_spot.springpad_buddy.zm_pts_animating = 1;
	flag_set( "pts_2_generator_" + level.current_generator + "_started" );
	s_lion_spot.which_generator = level.current_generator;
	level.current_generator++;
/#
	iprintlnbold( "Ball Animating" );
#/
	s_lion_spot.springpad thread pts_springpad_fling( s_lion_spot.script_noteworthy, s_lion_spot.springpad_buddy.springpad );
	self.t_putdown_ball delete();
}

delete_all_springpads()
{
}

exit_stage_1( success )
{
}

exit_stage_2( success )
{
}

watch_player_springpads( is_generator )
{
	level thread springpad_count_watcher( is_generator );
	a_players = get_players();
	_a240 = a_players;
	_k240 = getFirstArrayKey( _a240 );
	while ( isDefined( _k240 ) )
	{
		player = _a240[ _k240 ];
		player thread pts_watch_springpad_use( is_generator );
		_k240 = getNextArrayKey( _a240, _k240 );
	}
}

pts_watch_springpad_use( is_generator )
{
	self endon( "death" );
	self endon( "disconnect" );
	while ( !flag( "sq_branch_complete" ) )
	{
		self waittill( "equipment_placed", weapon, weapname );
		if ( weapname == level.springpad_name )
		{
			self is_springpad_in_place( weapon, is_generator );
		}
	}
}

springpad_count_watcher( is_generator )
{
	level endon( "sq_pts_springad_count4" );
	str_which_spots = "pts_ghoul";
	if ( is_generator )
	{
		str_which_spots = "pts_lion";
	}
	a_spots = getstructarray( str_which_spots, "targetname" );
	while ( 1 )
	{
		level waittill( "sq_pts_springpad_in_place" );
		n_count = 0;
		_a279 = a_spots;
		_k279 = getFirstArrayKey( _a279 );
		while ( isDefined( _k279 ) )
		{
			s_spot = _a279[ _k279 ];
			if ( isDefined( s_spot.springpad ) )
			{
				n_count++;
			}
			_k279 = getNextArrayKey( _a279, _k279 );
		}
		level notify( "sq_pts_springad_count" + n_count );
	}
}

is_springpad_in_place( m_springpad, is_generator )
{
	a_lion_spots = getstructarray( "pts_lion", "targetname" );
	a_ghoul_spots = getstructarray( "pts_ghoul", "targetname" );
	a_spots = arraycombine( a_lion_spots, a_ghoul_spots, 0, 0 );
	_a298 = a_spots;
	_k298 = getFirstArrayKey( _a298 );
	while ( isDefined( _k298 ) )
	{
		s_spot = _a298[ _k298 ];
		n_dist = distance2dsquared( m_springpad.origin, s_spot.origin );
		if ( n_dist < 1024 )
		{
			v_spot_forward = vectornormalize( anglesToForward( s_spot.angles ) );
			v_pad_forward = vectornormalize( anglesToForward( m_springpad.angles ) );
			n_dot = vectordot( v_spot_forward, v_pad_forward );
/#
			iprintlnbold( "Trample Steam OFF: Dist(" + sqrt( n_dist ) + ") Dot(" + n_dot + ")" );
#/
			if ( n_dot > 0,98 )
			{
/#
				iprintlnbold( "Trample Steam IN PLACE: Dist(" + sqrt( n_dist ) + ") Dot(" + n_dot + ")" );
#/
				level notify( "sq_pts_springpad_in_place" );
				s_spot.springpad = m_springpad;
				self thread pts_springpad_removed_watcher( m_springpad, s_spot );
				if ( is_generator )
				{
					wait 0,1;
					level thread pts_should_springpad_create_trigs( s_spot );
					thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.buildablespringpad.stub );
				}
				else
				{
					m_springpad.fling_scaler = 2;
					m_springpad thread watch_zombie_flings();
				}
				if ( isDefined( s_spot.script_float ) )
				{
					s_target = getstruct( "sq_zombie_launch_target", "targetname" );
					v_override_dir = vectornormalize( s_target.origin - m_springpad.origin );
					v_override_dir = vectorScale( v_override_dir, 1024 );
					m_springpad.direction_vec_override = v_override_dir;
					m_springpad.fling_scaler = s_spot.script_float;
				}
				return;
			}
		}
		else
		{
			_k298 = getNextArrayKey( _a298, _k298 );
		}
	}
}

pts_springpad_fling( str_spot_name, m_buddy_springpad )
{
	str_anim1 = undefined;
	n_anim_length1 = undefined;
	str_anim2 = undefined;
	n_anim_length2 = undefined;
	switch( str_spot_name )
	{
		case "lion_pair_1":
			str_anim1 = "dc";
			str_anim2 = "cd";
			break;
		case "lion_pair_2":
			str_anim1 = "ab";
			str_anim2 = "ba";
			break;
		case "lion_pair_3":
			str_anim1 = "cd";
			str_anim2 = "dc";
			break;
		case "lion_pair_4":
			str_anim1 = "ba";
			str_anim2 = "ab";
			break;
	}
	m_anim = spawn( "script_model", ( 2090, 675, 3542 ) );
	m_anim.angles = ( 0, 0, 0 );
	m_anim setmodel( "fxanim_zom_highrise_trample_gen_mod" );
	m_anim useanimtree( -1 );
	m_anim.targetname = "trample_gen_" + str_spot_name;
	pts_springpad_anim_ball( m_buddy_springpad, m_anim, str_anim1, str_anim2 );
}

pts_springpad_anim_ball( m_buddy_springpad, m_anim, str_anim1, str_anim2 )
{
	m_anim endon( "delete" );
	self endon( "delete" );
	m_buddy_springpad endon( "delete" );
	n_anim_length1 = getanimlength( level.scr_anim[ "fxanim_props" ][ "trample_gen_" + str_anim1 ] );
	n_anim_length2 = getanimlength( level.scr_anim[ "fxanim_props" ][ "trample_gen_" + str_anim2 ] );
	while ( isDefined( m_anim ) )
	{
		self notify( "fling" );
		if ( isDefined( m_anim ) )
		{
			m_anim setanim( level.scr_anim[ "fxanim_props" ][ "trample_gen_" + str_anim1 ] );
		}
		wait n_anim_length1;
		m_buddy_springpad notify( "fling" );
		if ( isDefined( m_anim ) )
		{
			m_anim setanim( level.scr_anim[ "fxanim_props" ][ "trample_gen_" + str_anim2 ] );
		}
		wait n_anim_length2;
	}
}

pts_springpad_removed_watcher( m_springpad, s_spot )
{
	self pts_springpad_waittill_removed( m_springpad );
	s_spot.springpad = undefined;
}

pts_springpad_waittill_removed( m_springpad )
{
	m_springpad endon( "delete" );
	m_springpad endon( "death" );
	self waittill_any( "death", "disconnect", "equip_springpad_zm_taken", "equip_springpad_zm_pickup" );
}

wait_for_all_springpads_placed( str_type, str_flag )
{
	a_spots = getstructarray( str_type, "targetname" );
	while ( !flag( str_flag ) )
	{
		is_clear = 0;
		_a442 = a_spots;
		_k442 = getFirstArrayKey( _a442 );
		while ( isDefined( _k442 ) )
		{
			s_spot = _a442[ _k442 ];
			if ( !isDefined( s_spot.springpad ) )
			{
				is_clear = 1;
			}
			_k442 = getNextArrayKey( _a442, _k442 );
		}
		if ( !is_clear )
		{
			flag_set( str_flag );
		}
		wait 1;
	}
}

pts_should_player_create_trigs( player )
{
	a_lion_spots = getstructarray( "pts_lion", "targetname" );
	_a467 = a_lion_spots;
	_k467 = getFirstArrayKey( _a467 );
	while ( isDefined( _k467 ) )
	{
		s_lion_spot = _a467[ _k467 ];
		if ( isDefined( s_lion_spot.springpad ) && isDefined( s_lion_spot.springpad_buddy.springpad ) )
		{
			pts_putdown_trigs_create_for_spot( s_lion_spot, player );
		}
		_k467 = getNextArrayKey( _a467, _k467 );
	}
}

pts_should_springpad_create_trigs( s_lion_spot )
{
	while ( isDefined( s_lion_spot.springpad ) && isDefined( s_lion_spot.springpad_buddy.springpad ) )
	{
		a_players = getplayers();
		_a481 = a_players;
		_k481 = getFirstArrayKey( _a481 );
		while ( isDefined( _k481 ) )
		{
			player = _a481[ _k481 ];
			if ( isDefined( player.zm_sq_has_ball ) && player.zm_sq_has_ball )
			{
				pts_putdown_trigs_create_for_spot( s_lion_spot, player );
				pts_putdown_trigs_create_for_spot( s_lion_spot.springpad_buddy, player );
			}
			_k481 = getNextArrayKey( _a481, _k481 );
		}
	}
}

pts_putdown_trigs_create_for_spot( s_lion_spot, player )
{
	if ( isDefined( s_lion_spot.which_ball ) || isDefined( s_lion_spot.springpad_buddy ) && isDefined( s_lion_spot.springpad_buddy.which_ball ) )
	{
		return;
	}
	t_place_ball = sq_pts_create_use_trigger( s_lion_spot.origin, 16, 70, &"ZM_HIGHRISE_SQ_PUTDOWN_BALL" );
	player clientclaimtrigger( t_place_ball );
	t_place_ball.owner = player;
	player thread place_ball_think( t_place_ball, s_lion_spot );
	if ( !isDefined( s_lion_spot.pts_putdown_trigs ) )
	{
		s_lion_spot.pts_putdown_trigs = [];
	}
	s_lion_spot.pts_putdown_trigs[ player.characterindex ] = t_place_ball;
	level thread pts_putdown_trigs_springpad_delete_watcher( player, s_lion_spot );
}

pts_putdown_trigs_springpad_delete_watcher( player, s_lion_spot )
{
	player pts_springpad_waittill_removed( s_lion_spot.springpad );
	pts_putdown_trigs_remove_for_spot( s_lion_spot );
	pts_putdown_trigs_remove_for_spot( s_lion_spot.springpad_buddy );
	level thread pts_reset_ball( s_lion_spot );
}

pts_reset_ball( s_lion_spot )
{
	if ( isDefined( s_lion_spot.which_ball ) )
	{
		s_lion_spot.sq_pickup_reset = 1;
		s_lion_spot.which_ball notify( "sq_pickup_reset" );
		m_ball_anim = getent( "trample_gen_" + s_lion_spot.script_noteworthy, "targetname" );
		playfx( level._effect[ "sidequest_flash" ], m_ball_anim gettagorigin( "fxanim_zom_highrise_trample_gen1_jnt" ) );
		flag_clear( "pts_2_generator_" + s_lion_spot.which_generator + "_started" );
		level.current_generator--;

		s_lion_spot.which_ball = undefined;
		m_ball_anim delete();
	}
	else
	{
		if ( isDefined( s_lion_spot.springpad_buddy.which_ball ) )
		{
			s_lion_spot.springpad_buddy.sq_pickup_reset = 1;
			s_lion_spot.springpad_buddy.which_ball notify( "sq_pickup_reset" );
			m_ball_anim = getent( "trample_gen_" + s_lion_spot.springpad_buddy.script_noteworthy, "targetname" );
			playfx( level._effect[ "sidequest_flash" ], m_ball_anim gettagorigin( "fxanim_zom_highrise_trample_gen1_jnt" ) );
			flag_clear( "pts_2_generator_" + s_lion_spot.springpad_buddy.which_generator + "_started" );
			level.current_generator--;

			s_lion_spot.springpad_buddy.which_ball = undefined;
			m_ball_anim delete();
		}
	}
}

pts_putdown_trigs_remove_for_player( player )
{
	a_lion_spots = getstructarray( "pts_lion", "targetname" );
	_a554 = a_lion_spots;
	_k554 = getFirstArrayKey( _a554 );
	while ( isDefined( _k554 ) )
	{
		s_lion_spot = _a554[ _k554 ];
		if ( !isDefined( s_lion_spot.pts_putdown_trigs ) )
		{
		}
		else if ( isDefined( s_lion_spot.pts_putdown_trigs[ player.characterindex ] ) )
		{
			s_lion_spot.pts_putdown_trigs[ player.characterindex ] delete();
			arrayremoveindex( s_lion_spot.pts_putdown_trigs, player.characterindex, 1 );
		}
		_k554 = getNextArrayKey( _a554, _k554 );
	}
}

pts_putdown_trigs_remove_for_spot( s_lion_spot )
{
	if ( !isDefined( s_lion_spot.pts_putdown_trigs ) )
	{
		return;
	}
	_a575 = s_lion_spot.pts_putdown_trigs;
	_k575 = getFirstArrayKey( _a575 );
	while ( isDefined( _k575 ) )
	{
		t_putdown = _a575[ _k575 ];
		t_putdown delete();
		_k575 = getNextArrayKey( _a575, _k575 );
	}
	s_lion_spot.pts_putdown_trigs = [];
}

richtofen_pts_instructions()
{
	maps/mp/zm_highrise_sq::richtofensay( "vox_zmba_sidequest_place_trample_0" );
}

richtofen_pts_placed()
{
	level waittill( "sq_pts_springad_count1" );
	maps/mp/zm_highrise_sq::richtofensay( "vox_zmba_sidequest_place_trample_1" );
	level waittill( "sq_pts_springad_count2" );
	maps/mp/zm_highrise_sq::richtofensay( "vox_zmba_sidequest_place_trample_2" );
	level waittill( "sq_pts_springad_count3" );
	maps/mp/zm_highrise_sq::richtofensay( "vox_zmba_sidequest_place_trample_3" );
	level waittill( "sq_pts_springad_count4" );
	maps/mp/zm_highrise_sq::richtofensay( "vox_zmba_sidequest_place_trample_4" );
}

richtofen_zombies_launched()
{
	level waittill( "pts1_say_next_line" );
	maps/mp/zm_highrise_sq::richtofensay( "vox_zmba_sidequest_spill_blood_0" );
	wait 1;
	level waittill( "pts1_say_next_line" );
	maps/mp/zm_highrise_sq::richtofensay( "vox_zmba_sidequest_spill_blood_1" );
	wait 1;
	level waittill( "pts1_say_next_line" );
	maps/mp/zm_highrise_sq::richtofensay( "vox_zmba_sidequest_spill_blood_2" );
}

maxis_pts_instructions()
{
	maps/mp/zm_highrise_sq::maxissay( "vox_maxi_sidequest_create_trample_0" );
}

maxis_pts_placed()
{
	level waittill( "sq_pts_springad_count1" );
	maps/mp/zm_highrise_sq::maxissay( "vox_maxi_sidequest_create_trample_1" );
	level waittill( "sq_pts_springad_count2" );
	maps/mp/zm_highrise_sq::maxissay( "vox_maxi_sidequest_create_trample_2" );
	level waittill( "sq_pts_springad_count4" );
	maps/mp/zm_highrise_sq::maxissay( "vox_maxi_sidequest_create_trample_3" );
}

maxis_balls_placed()
{
	maps/mp/zm_highrise_sq::maxissay( "vox_maxi_sidequest_create_trample_4" );
}
