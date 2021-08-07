#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_hackables_box;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zm_buried;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zombies/_zm_ai_sloth;
#include maps/mp/zombies/_zm_ai_sloth_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

box_lock_condition()
{
	box = level.chests[ level.chest_index ];
	if ( !isDefined( box ) )
	{
		return 0;
	}
/#
	self sloth_debug_context( box, sqrt( 32400 ) );
#/
	if ( flag( "moving_chest_now" ) )
	{
		return 0;
	}
	if ( is_true( box._box_open ) || is_true( box._box_opened_by_fire_sale ) )
	{
		return 0;
	}
	dist = distancesquared( self.origin, box.origin );
	if ( dist < 32400 )
	{
		return 1;
	}
	return 0;
}

box_get_ground_offset()
{
	vec_right = vectornormalize( anglesToRight( self.angles ) );
	box_pos = self.origin - ( vec_right * 36 );
	ground_pos = groundpos( box_pos );
	return ground_pos;
}

common_abort_box( box )
{
	if ( flag( "moving_chest_now" ) )
	{
		self.context_done = 1;
		return 1;
	}
	if ( isDefined( box ) )
	{
		if ( is_true( box._box_open ) || is_true( box._box_opened_by_fire_sale ) )
		{
/#
			sloth_print( "box was opened...abort" );
#/
			self.context_done = 1;
			return 1;
		}
	}
	return 0;
}

common_move_to_maze( box )
{
	self endon( "death" );
	while ( 1 )
	{
		if ( self common_abort_box( box ) )
		{
			return 0;
		}
		if ( self maps/mp/zombies/_zm_ai_sloth::sloth_behind_mansion() )
		{
			break;
		}
		else
		{
			self maps/mp/zombies/_zm_ai_sloth::action_navigate_mansion( level.maze_depart, level.maze_arrive );
			wait 0,2;
		}
	}
	return 1;
}

common_move_to_courtyard( box )
{
	self endon( "death" );
	while ( 1 )
	{
		if ( self common_abort_box( box ) )
		{
			return 0;
		}
		if ( !self maps/mp/zombies/_zm_ai_sloth::sloth_behind_mansion() )
		{
			break;
		}
		else
		{
			self maps/mp/zombies/_zm_ai_sloth::action_navigate_mansion( level.courtyard_depart, level.courtyard_arrive );
			wait 0,2;
		}
	}
	return 1;
}

common_move_to_box( box, range, ignore_open, asd_name )
{
	if ( isDefined( asd_name ) )
	{
		anim_id = self getanimfromasd( asd_name, 0 );
		start_org = getstartorigin( box.origin, box.angles, anim_id );
		start_ang = getstartangles( box.origin, box.angles, anim_id );
		self setgoalpos( start_org );
		ground_pos = start_org;
	}
	else
	{
		vec_right = vectornormalize( anglesToRight( box.angles ) );
		box_pos = box.origin - ( vec_right * 36 );
		ground_pos = groundpos( box_pos );
		self setgoalpos( ground_pos );
	}
	while ( 1 )
	{
		if ( flag( "moving_chest_now" ) )
		{
			self.context_done = 1;
			return 0;
		}
		if ( !is_true( ignore_open ) || is_true( box._box_open ) && is_true( box._box_opened_by_fire_sale ) )
		{
/#
			sloth_print( "box was opened...abort" );
#/
			self.context_done = 1;
			return 0;
		}
		dist = distancesquared( self.origin, ground_pos );
		if ( dist < range )
		{
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	if ( isDefined( asd_name ) )
	{
		self setgoalpos( self.origin );
		self sloth_face_object( box, "angle", start_ang[ 1 ], 0,9 );
	}
	else
	{
		angles = vectorToAngle( vec_right );
		self.anchor.origin = self.origin;
		self.anchor.angles = angles;
		self orientmode( "face angle", angles[ 1 ] );
		wait 0,2;
	}
	if ( flag( "moving_chest_now" ) )
	{
		self.context_done = 1;
		return 0;
	}
	return 1;
}

box_lock_action()
{
	self endon( "death" );
	self endon( "stop_action" );
	self maps/mp/zombies/_zm_ai_sloth::common_context_action();
	box = level.chests[ level.chest_index ];
	if ( !self common_move_to_box( box, 1024 ) )
	{
		return;
	}
	self animscripted( box.origin, box.angles, "zm_lock_magicbox" );
	maps/mp/animscripts/zm_shared::donotetracks( "lock_magicbox_anim", ::box_notetracks, box );
	if ( flag( "moving_chest_now" ) )
	{
		self.context_done = 1;
		return;
	}
	setdvar( "magic_chest_movable", "0" );
/#
	sloth_print( "box will not move" );
#/
	maps/mp/zombies/_zm_ai_sloth::unregister_candy_context( "box_lock" );
	maps/mp/zombies/_zm_ai_sloth::unregister_candy_context( "box_move" );
	self.context_done = 1;
}

box_move_condition()
{
	if ( flag( "moving_chest_now" ) )
	{
		return 0;
	}
	self.box_move = undefined;
	self.box_current = undefined;
	self.box_current_in_maze = 0;
	box_current = level.chests[ level.chest_index ];
	if ( is_true( box_current._box_open ) || is_true( box_current._box_opened_by_fire_sale ) )
	{
		return 0;
	}
	if ( box_current.script_noteworthy == "courtroom_chest1" )
	{
		if ( !maps/mp/zm_buried::is_courthouse_open() )
		{
			return 0;
		}
	}
	if ( box_current.script_noteworthy == "tunnels_chest1" )
	{
		if ( !maps/mp/zm_buried::is_tunnel_open() )
		{
			return 0;
		}
	}
	if ( box_current.script_noteworthy == "maze_chest1" || box_current.script_noteworthy == "maze_chest2" )
	{
		self.box_current_in_maze = 1;
		if ( !is_maze_open() )
		{
			return 0;
		}
	}
	i = 0;
	while ( i < level.chests.size )
	{
		if ( i == level.chest_index )
		{
			i++;
			continue;
		}
		else
		{
			box = level.chests[ i ];
			if ( box.script_noteworthy != "maze_chest1" )
			{
				self.box_move_in_maze = box.script_noteworthy == "maze_chest2";
			}
			dist = distancesquared( self.origin, box.origin );
			if ( dist < 32400 )
			{
				self.box_move_index = i;
				self.box_move = box;
				self.box_current = box_current;
				return 1;
			}
		}
		i++;
	}
	return 0;
}

box_move_action()
{
	self endon( "death" );
	self endon( "stop_action" );
	self maps/mp/zombies/_zm_ai_sloth::common_context_action();
/#
	sloth_print( "moving box from: " + self.box_current.script_noteworthy + " to: " + self.box_move.script_noteworthy );
#/
	if ( !self common_move_to_box( self.box_move, 1024, 0, "zm_magicbox_point" ) )
	{
		return;
	}
	self maps/mp/zombies/_zm_ai_sloth::action_animscripted( "zm_magicbox_point", "magicbox_point_anim", self.box_move.origin, self.box_move.angles );
	if ( is_true( self.box_current_in_maze ) )
	{
		if ( !is_true( self.box_move_in_maze ) )
		{
			if ( !self common_move_to_maze( self.box_current ) )
			{
				return;
			}
		}
	}
	else
	{
		if ( is_true( self.box_move_in_maze ) )
		{
			if ( !self common_move_to_courtyard( self.box_current ) )
			{
				return;
			}
		}
	}
	if ( !self common_move_to_box( self.box_current, 1024, 0, "zm_pull_magicbox" ) )
	{
		return;
	}
	self animscripted( self.box_current.origin, self.box_current.angles, "zm_pull_magicbox" );
	maps/mp/animscripts/zm_shared::donotetracks( "pull_magicbox_anim", ::box_notetracks, self.box_current );
	if ( self common_abort_box( self.box_current ) )
	{
		self box_move_interrupt();
		return;
	}
	if ( isDefined( level.sloth.custom_box_move_func ) )
	{
		self thread [[ level.sloth.custom_box_move_func ]]( 0 );
	}
	level.sloth_moving_box = 1;
	self.ignore_common_run = 1;
	self set_zombie_run_cycle( "run_holding_magicbox" );
	self.locomotion = "run_holding_magicbox";
	if ( is_true( self.box_current_in_maze ) )
	{
		if ( !is_true( self.box_move_in_maze ) )
		{
			if ( !self common_move_to_courtyard( undefined ) )
			{
				self box_move_interrupt();
				return;
			}
		}
	}
	else
	{
		if ( is_true( self.box_move_in_maze ) )
		{
			if ( !self common_move_to_maze( undefined ) )
			{
				self box_move_interrupt();
				return;
			}
		}
	}
	if ( !self common_move_to_box( self.box_move, 1024, 0, "zm_place_magicbox" ) )
	{
		self box_move_interrupt();
		return;
	}
	self animscripted( self.box_move.origin, self.box_move.angles, "zm_place_magicbox" );
	maps/mp/animscripts/zm_shared::donotetracks( "place_magicbox_anim", ::box_notetracks, self.box_move );
	self.box_current = undefined;
	self.context_done = 1;
	level.sloth_moving_box = undefined;
	if ( isDefined( level.sloth.custom_box_move_func ) )
	{
		self thread [[ level.sloth.custom_box_move_func ]]( 1 );
	}
}

box_notetracks( note, box )
{
	if ( !flag( "moving_chest_now" ) || is_true( box._box_open ) && is_true( box._box_opened_by_fire_sale ) )
	{
		return 0;
	}
	if ( note == "pulled" )
	{
		playfx( level._effect[ "fx_buried_sloth_box_slam" ], box.origin );
		tag_name = "tag_stowed_back";
		twr_origin = self gettagorigin( tag_name );
		twr_angles = self gettagangles( tag_name );
		if ( !isDefined( self.box_model ) )
		{
			self.box_model = spawn( "script_model", twr_origin );
			self.box_model.angles = twr_angles;
			self.box_model setmodel( level.small_magic_box );
			self.box_model linkto( self, tag_name );
			self.box_model_visible = 1;
		}
		else
		{
			self.box_model show();
			self.box_model_visible = 1;
		}
		self.box_current maps/mp/zombies/_zm_magicbox::hide_chest();
	}
	else if ( note == "placed" )
	{
		playfx( level._effect[ "fx_buried_sloth_box_slam" ], box.origin );
		self box_model_hide();
		if ( isDefined( self.box_move.zbarrier ) )
		{
			self.box_move.zbarrier maps/mp/zombies/_zm_magicbox::set_magic_box_zbarrier_state( "initial" );
			self.box_move.hidden = 0;
			self.box_move thread [[ level.pandora_show_func ]]();
			level.chest_index = self.box_move_index;
		}
	}
	else
	{
		if ( note == "locked" )
		{
			playfx( level._effect[ "fx_buried_sloth_box_slam" ], box.origin );
		}
	}
}

box_model_hide()
{
	if ( isDefined( self.box_model ) )
	{
		self.box_model ghost();
		self.box_model_visible = 0;
	}
}

box_move_interrupt()
{
	if ( isDefined( self.box_current ) )
	{
		if ( isDefined( self.box_current.zbarrier ) )
		{
			self.box_current.zbarrier maps/mp/zombies/_zm_magicbox::set_magic_box_zbarrier_state( "initial" );
			self.box_current.hidden = 0;
			self.box_current thread [[ level.pandora_show_func ]]();
		}
	}
	if ( isDefined( level.sloth.custom_box_move_func ) )
	{
		self thread [[ level.sloth.custom_box_move_func ]]( 1 );
	}
	level.sloth_moving_box = undefined;
	self box_model_hide();
}

box_spin_condition()
{
	if ( flag( "moving_chest_now" ) )
	{
		return 0;
	}
	box = level.chests[ level.chest_index ];
	if ( is_true( box._box_open ) || is_true( box._box_opened_by_fire_sale ) )
	{
		ground_pos = groundpos( box.origin );
		dist = distancesquared( self.origin, ground_pos );
		if ( dist < 32400 )
		{
			return 1;
		}
	}
	return 0;
}

box_spin_action()
{
	self endon( "death" );
	self endon( "stop_action" );
	self maps/mp/zombies/_zm_ai_sloth::common_context_action();
	box = level.chests[ level.chest_index ];
	hackable = spawnstruct();
	hackable.chest = box;
	if ( !self common_move_to_box( box, 1024, 1, "zm_cycle_magicbox" ) )
	{
		return;
	}
	if ( !self box_spin_qualifier( hackable ) )
	{
		return;
	}
	self animscripted( box.origin, box.angles, "zm_cycle_magicbox" );
	maps/mp/animscripts/zm_shared::donotetracks( "cycle_magicbox_anim", ::box_kick, hackable );
	self.context_done = 1;
}

box_kick( note, hackable )
{
	if ( note == "kick" )
	{
		if ( !self box_spin_qualifier( hackable ) )
		{
			return;
		}
		if ( !flag( "moving_chest_now" ) )
		{
			hackable thread box_trigger();
			hackable maps/mp/zombies/_zm_hackables_box::respin_box( self.candy_player );
		}
	}
}

box_trigger()
{
	if ( isDefined( self.chest ) )
	{
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.chest.unitrigger_stub );
		self.chest.zbarrier waittill( "randomization_done" );
		if ( !flag( "moving_chest_now" ) )
		{
			thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.chest.unitrigger_stub, ::maps/mp/zombies/_zm_magicbox::magicbox_unitrigger_think );
		}
	}
}

box_spin_qualifier( hackable )
{
	if ( isDefined( hackable.chest ) )
	{
		if ( !isDefined( hackable.chest.chest_user ) )
		{
			self.context_done = 1;
			return 0;
		}
	}
	if ( !hackable maps/mp/zombies/_zm_hackables_box::hack_box_qualifier( self.candy_player ) )
	{
/#
		sloth_print( "hack_box_qualifier failed" );
#/
		self.context_done = 1;
		return 0;
	}
	return 1;
}
