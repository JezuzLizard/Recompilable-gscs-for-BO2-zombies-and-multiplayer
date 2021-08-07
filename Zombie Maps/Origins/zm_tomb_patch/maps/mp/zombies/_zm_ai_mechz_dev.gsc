#include maps/mp/animscripts/zm_shared;
#include maps/mp/zombies/_zm_ai_mechz;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#using_animtree( "mechz_claw" );

mechz_debug()
{
/#
	while ( 1 )
	{
		debug_level = getDvarInt( #"E7121222" );
		while ( isDefined( debug_level ) && debug_level )
		{
			while ( debug_level == 1 )
			{
				mechz_array = getentarray( "mechz_zombie_ai" );
				i = 0;
				while ( i < mechz_array.size )
				{
					if ( isDefined( mechz_array[ i ].goal_pos ) )
					{
						debugstar( mechz_array[ i ].goal_pos, ( 0, 0, 1 ), 1 );
						line( mechz_array[ i ].goal_pos, mechz_array[ i ].origin, ( 0, 0, 1 ), 0, 1 );
					}
					i++;
				}
			}
		}
#/
	}
}

setup_devgui()
{
/#
	setdvar( "spawn_Mechz", "off" );
	setdvar( "force_mechz_jump", "off" );
	setdvar( "test_mechz_tank", "off" );
	setdvar( "test_mechz_robot", "off" );
	setdvar( "reset_mechz_thinking", "off" );
	setdvar( "test_mechz_sprint", "off" );
	setdvar( "mechz_force_behavior", "none" );
	setdvarint( "mechz_behavior_orient", 0 );
	setdvarint( "mechz_behavior_dist", 300 );
	adddebugcommand( "devgui_cmd "Zombies/Zombie Spawning:2/Spawn Zombie:1/Mech Zombie:1" "spawn_Mechz on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Jump In:1" "mechz_force_behavior jump_in"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Jump Out:2" "mechz_force_behavior jump_out"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Flamethrower:3" "mechz_force_behavior flamethrower"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Damage Armor:4" "mechz_force_behavior damage_armor"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Damage Faceplate:5" "mechz_force_behavior damage_faceplate"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Claw Attack:5" "mechz_force_behavior claw_attack"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Melee:6" "mechz_force_behavior melee"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Angles:7/zero degrees:1" "mechz_behavior_orient 0"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Angles:7/forty-five degrees:2" "mechz_behavior_orient 45"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Angles:7/ninety degrees:3" "mechz_behavior_orient 90"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Angles:7/one thirty five degrees:4" "mechz_behavior_orient 135"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Angles:7/one eighty degrees:5" "mechz_behavior_orient 180"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Angles:7/two twenty five degrees:6" "mechz_behavior_orient 225"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Angles:7/two seventy degrees:7" "mechz_behavior_orient 270"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Angles:7/three fifteen degrees:8" "mechz_behavior_orient 315"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Distance:8/one hundred:1" "mechz_behavior_dist 100"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Distance:8/two hundred:2" "mechz_behavior_dist 200"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Distance:8/three hundred:3" "mechz_behavior_dist 300"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Distance:8/four hundred:4" "mechz_behavior_dist 400"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Force Behavior:1/Distance:8/five hundred:5" "mechz_behavior_dist 500"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Test Tank Knockdown:2" "test_mechz_tank on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Test Robot Knockdown:3" "test_mechz_robot on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Test Sprint:4" "test_mechz_sprint on"\n" );
	adddebugcommand( "devgui_cmd "Zombies/MechZ:3/Reset Mech:5" "reset_mechz_thinking on"\n" );
	level thread watch_devgui_mechz();
#/
}

watch_devgui_mechz()
{
/#
	while ( 1 )
	{
		if ( getDvar( "spawn_Mechz" ) == "on" )
		{
			mechz_health_increases();
			level.mechz_left_to_spawn = 1;
			if ( getDvarInt( "zombie_cheat" ) >= 2 )
			{
				level.round_number++;
			}
			level notify( "spawn_mechz" );
			setdvar( "spawn_Mechz", "off" );
			level.mechz_last_spawn_round = 0;
		}
		if ( getDvar( "mechz_force_behavior" ) != "none" )
		{
			behavior = getDvar( "mechz_force_behavior" );
			zombies = getaiarray( "axis" );
			i = 0;
			while ( i < zombies.size )
			{
				if ( isDefined( zombies[ i ].is_mechz ) && zombies[ i ].is_mechz )
				{
					zombies[ i ] thread mechz_force_behavior( behavior );
				}
				i++;
			}
			setdvar( "mechz_force_behavior", "none" );
		}
		if ( getDvar( "test_mechz_tank" ) == "on" )
		{
			setdvar( "test_mechz_tank", "off" );
			mechz = undefined;
			zombies = getaiarray( "axis" );
			i = 0;
			while ( i < zombies.size )
			{
				if ( isDefined( zombies[ i ].is_mechz ) && zombies[ i ].is_mechz )
				{
					mechz = zombies[ i ];
				}
				i++;
			}
			while ( !isDefined( mechz ) )
			{
				continue;
			}
			mechz.not_interruptable = 1;
			mechz mechz_stop_basic_find_flesh();
			mechz.ai_state = "devgui";
			mechz.goal_pos = ( 446, -4318, 200 );
			mechz setgoalpos( mechz.goal_pos );
		}
		if ( getDvar( "test_mechz_robot" ) == "on" )
		{
			setdvar( "test_mechz_robot", "off" );
			mechz = undefined;
			zombies = getaiarray( "axis" );
			i = 0;
			while ( i < zombies.size )
			{
				if ( isDefined( zombies[ i ].is_mechz ) && zombies[ i ].is_mechz )
				{
					mechz = zombies[ i ];
				}
				i++;
			}
			while ( !isDefined( mechz ) )
			{
				continue;
			}
			mechz.not_interruptable = 1;
			mechz mechz_stop_basic_find_flesh();
			mechz.ai_state = "devgui";
			mechz.goal_pos = ( 1657, -336, 92 );
			mechz setgoalpos( mechz.goal_pos );
		}
		while ( getDvar( "test_mechz_sprint" ) == "on" )
		{
			setdvar( "test_mechz_sprint", "off" );
			zombies = getaiarray( "axis" );
			i = 0;
			while ( i < zombies.size )
			{
				if ( isDefined( zombies[ i ].is_mechz ) && zombies[ i ].is_mechz )
				{
					zombies[ i ].force_sprint = 1;
				}
				i++;
			}
		}
		while ( getDvar( "reset_mechz_thinking" ) == "on" )
		{
			setdvar( "reset_mechz_thinking", "off" );
			zombies = getaiarray( "axis" );
			i = 0;
			while ( i < zombies.size )
			{
				if ( isDefined( zombies[ i ].is_mechz ) && zombies[ i ].is_mechz )
				{
					zombies[ i ].not_interruptable = 0;
					zombies[ i ].force_sprint = 0;
				}
				i++;
			}
		}
		wait 0,1;
#/
	}
}

mechz_force_behavior( behavior )
{
/#
	self notify( "kill_force_behavior" );
	self thread mechz_stop_basic_find_flesh();
	self.ignoreall = 1;
	self.force_behavior = 1;
	if ( behavior == "jump_in" )
	{
		self thread mechz_force_jump_in();
	}
	if ( behavior == "jump_out" )
	{
		self thread mechz_force_jump_out();
	}
	if ( behavior == "flamethrower" )
	{
		self thread mechz_force_flamethrower();
	}
	if ( behavior == "claw_attack" )
	{
		self thread mechz_force_claw_attack();
	}
	if ( behavior == "damage_armor" )
	{
		self thread mechz_force_damage_armor();
	}
	if ( behavior == "damage_faceplate" )
	{
		self thread mechz_force_damage_faceplate();
	}
	if ( behavior == "melee" )
	{
		self thread mechz_force_melee();
	}
	if ( behavior == "none" )
	{
		self.ignoreall = 0;
		self.force_behavior = 0;
		self notify( "kill_force_behavior" );
#/
	}
}

get_behavior_orient()
{
/#
	behavior_orient = getDvarInt( #"2F660A7B" );
	return level.players[ 0 ].angles + vectorScale( ( 0, 0, 1 ), 180 ) + ( 0, behavior_orient, 0 );
#/
}

setup_force_behavior()
{
/#
	if ( !isDefined( level.test_align_struct ) )
	{
		player = get_players()[ 0 ];
		pos = player.origin;
		offset = anglesToForward( player.angles );
		offset = vectornormalize( offset );
		level.test_align_struct = spawn( "script_model", pos + ( 300 * offset ) );
		level.test_align_struct setmodel( "tag_origin" );
		level.test_align_struct.angles = player.angles + vectorScale( ( 0, 0, 1 ), 180 );
		level.test_align_struct thread align_test_struct();
		level.test_align_struct.angles = player.angles + vectorScale( ( 0, 0, 1 ), 180 );
	}
	self linkto( level.test_align_struct, "tag_origin", ( 0, 0, 1 ), ( 0, 0, 1 ) );
	self.fx_field &= 64;
	self.fx_field &= 128;
	self.fx_field &= 256;
#/
}

align_test_struct()
{
/#
	while ( 1 )
	{
		pos = level.players[ 0 ].origin;
		offset = anglesToForward( level.players[ 0 ].angles );
		offset = vectornormalize( offset );
		dist = getDvarInt( #"6DCD047E" );
		level.test_align_struct.origin = pos + ( dist * offset );
		level.test_align_struct.angles = get_behavior_orient();
		wait 0,05;
#/
	}
}

scripted_behavior( anim_scripted_name, notify_name )
{
/#
	self animscripted( level.test_align_struct.origin, level.test_align_struct.angles, anim_scripted_name );
	self maps/mp/animscripts/zm_shared::donotetracks( notify_name );
#/
}

mechz_force_jump_in()
{
/#
	self endon( "kill_force_behavior" );
	self setup_force_behavior();
	while ( 1 )
	{
		self animscripted( self.origin, self.angles, "zm_idle" );
		wait 0,2;
		self scripted_behavior( "zm_spawn", "jump_anim" );
#/
	}
}

mechz_force_jump_out()
{
/#
	self endon( "kill_force_behavior" );
	self setup_force_behavior();
	while ( 1 )
	{
		self animscripted( self.origin, self.angles, "zm_idle" );
		wait 0,2;
		self scripted_behavior( "zm_fly_out", "jump_anim" );
		self ghost();
		self animscripted( self.origin, self.angles, "zm_fly_hover" );
		wait level.mechz_jump_delay;
		self show();
		self scripted_behavior( "zm_fly_in", "jump_anim" );
#/
	}
}

mechz_force_flamethrower()
{
/#
	self endon( "kill_force_behavior" );
	self setup_force_behavior();
	curr_aim_anim = 1;
	curr_timer = 0;
	self animscripted( self.origin, self.angles, "zm_idle" );
	wait 0,2;
	self scripted_behavior( "zm_flamethrower_aim_start", "flamethrower_anim" );
	while ( 1 )
	{
		if ( curr_timer > 3 )
		{
			curr_aim_anim++;
			curr_timer = 0;
			if ( curr_aim_anim < 10 )
			{
				iprintln( "Testing aim_" + curr_aim_anim );
			}
		}
		if ( curr_aim_anim >= 10 )
		{
			iprintln( "Testing flamethrower sweep" );
			curr_aim_anim = 1;
			self scripted_behavior( "zm_flamethrower_sweep", "flamethrower_anim" );
			self.fx_field |= 64;
			self setclientfield( "mechz_fx", self.fx_field );
			continue;
		}
		else
		{
			length = self getanimlengthfromasd( "zm_flamethrower_aim_" + curr_aim_anim, 0 );
			self clearanim( %root, 0 );
			self scripted_behavior( "zm_flamethrower_aim_" + curr_aim_anim, "flamethrower_anim" );
			curr_timer += length;
		}
#/
	}
}

fake_launch_claw()
{
/#
	self.launching_claw = 1;
	v_claw_origin = self gettagorigin( "tag_claw" );
	v_claw_angles = vectorToAngle( self.origin - level.players[ 0 ].origin );
	self.fx_field |= 256;
	self setclientfield( "mechz_fx", self.fx_field );
	self.m_claw setanim( %ai_zombie_mech_grapple_arm_open_idle, 1, 0, 1 );
	self.m_claw unlink();
	self.m_claw.fx_ent = spawn( "script_model", self.m_claw gettagorigin( "tag_claw" ) );
	self.m_claw.fx_ent.angles = self.m_claw gettagangles( "tag_claw" );
	self.m_claw.fx_ent setmodel( "tag_origin" );
	self.m_claw.fx_ent linkto( self.m_claw, "tag_claw" );
	network_safe_play_fx_on_tag( "mech_claw", 1, level._effect[ "mechz_claw" ], self.m_claw.fx_ent, "tag_origin" );
	self.m_claw clearanim( %root, 0,2 );
	self.m_claw setanim( %ai_zombie_mech_grapple_arm_open_idle, 1, 0,2, 1 );
	offset = anglesToForward( self.angles );
	offset = vectornormalize( offset );
	target_pos = self.origin + ( offset * 500 ) + vectorScale( ( 0, 0, 1 ), 36 );
	n_time = 0,08333334;
	self.m_claw moveto( target_pos, n_time );
	self.m_claw waittill( "movedone" );
	self.m_claw clearanim( %root, 0,2 );
	self.m_claw setanim( %ai_zombie_mech_grapple_arm_closed_idle, 1, 0,2, 1 );
	wait 0,5;
	self.m_claw moveto( v_claw_origin, 0,5 );
	self.m_claw waittill( "movedone" );
	self.m_claw.fx_ent delete();
	self.fx_field &= 256;
	self setclientfield( "mechz_fx", self.fx_field );
	v_claw_origin = self gettagorigin( "tag_claw" );
	v_claw_angles = self gettagangles( "tag_claw" );
	self.m_claw.origin = v_claw_origin;
	self.m_claw.angles = v_claw_angles;
	self.m_claw linkto( self, "tag_claw" );
	self.launching_claw = 0;
#/
}

mechz_force_claw_attack()
{
/#
	self endon( "kill_force_behavior" );
	self setup_force_behavior();
	while ( 1 )
	{
		self animscripted( self.origin, self.angles, "zm_idle" );
		wait 0,2;
		self scripted_behavior( "zm_grapple_aim_start", "grapple_anim" );
		self thread fake_launch_claw();
		while ( isDefined( self.launching_claw ) && self.launching_claw )
		{
			self clearanim( %root, 0 );
			wait 0,05;
			self scripted_behavior( "zm_grapple_aim_5", "grapple_anim" );
		}
		self scripted_behavior( "zm_flamethrower_claw_victim", "flamethrower_anim" );
#/
	}
}

mechz_force_damage_armor()
{
/#
	self endon( "kill_force_behavior" );
	self setup_force_behavior();
	if ( !isDefined( self.next_armor_piece ) )
	{
		self.next_armor_piece = 0;
	}
	self thread scripted_behavior( "zm_idle", "idle_anim" );
	if ( self.next_armor_piece == self.armor_state.size )
	{
		self.next_armor_piece = 0;
		i = 0;
		while ( i < self.armor_state.size )
		{
			self.fx_field &= 1 << self.armor_state[ i ].index;
			if ( isDefined( self.armor_state[ i ].model ) )
			{
				self attach( self.armor_state[ i ].model, self.armor_state[ i ].tag );
			}
			i++;
		}
	}
	else self.fx_field |= 1 << self.armor_state[ self.next_armor_piece ].index;
	if ( isDefined( self.armor_state[ self.next_armor_piece ].model ) )
	{
		self detach( self.armor_state[ self.next_armor_piece ].model, self.armor_state[ self.next_armor_piece ].tag );
	}
	self.next_armor_piece++;
	self setclientfield( "mechz_fx", self.fx_field );
	while ( 1 )
	{
		self scripted_behavior( "zm_idle", "idle_anim" );
#/
	}
}

mechz_force_damage_faceplate()
{
/#
	self endon( "kill_force_behavior" );
	self setup_force_behavior();
	self thread scripted_behavior( "zm_idle", "idle_anim" );
	if ( isDefined( self.has_helmet ) && self.has_helmet )
	{
		self.has_helmet = 0;
		self detach( "c_zom_mech_faceplate", "J_Helmet" );
		self.fx_field |= 1024;
		self.fx_field &= 2048;
	}
	else
	{
		self.has_helmet = 1;
		self.fx_field &= 1024;
		self.fx_field |= 2048;
		self attach( "c_zom_mech_faceplate", "J_Helmet" );
	}
	self setclientfield( "mechz_fx", self.fx_field );
	while ( 1 )
	{
		self scripted_behavior( "zm_idle", "idle_anim" );
#/
	}
}

mechz_force_melee()
{
/#
	self endon( "kill_force_behavior" );
	self setup_force_behavior();
	while ( 1 )
	{
		self animscripted( self.origin, self.angles, "zm_idle" );
		wait 0,2;
		self scripted_behavior( "zm_melee_stand", "melee_anim" );
#/
	}
}
