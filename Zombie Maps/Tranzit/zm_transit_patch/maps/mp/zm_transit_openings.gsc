#include maps/mp/zm_transit_cling;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/animscripts/zm_run;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zm_transit_bus;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/_utility;
#include common_scripts/utility;

main()
{
	self _businittags();
	self _setupnumattachtable();
	self.openings = [];
	x = 1;
	while ( x <= 10 )
	{
		script_noteworthy = undefined;
		switch( x )
		{
			case 10:
				script_noteworthy = "front";
				break;
			case 11:
			case 12:
				script_noteworthy = "door";
				break;
		}
		self busaddopening( "tag_entry_point" + x, script_noteworthy );
		x++;
	}
	self bussetupladder();
	self bussetuproofopening();
	self businitmantle();
	self businitrightandleft();
}

busaddopening( tag_name, script_noteworthy )
{
	index = self.openings.size;
	self.openings[ index ] = spawnstruct();
	opening = self.openings[ index ];
	opening.name = script_noteworthy;
	opening.enabled = 1;
	opening.zombie = undefined;
	opening.boards = [];
	opening.boardsnum = 0;
	opening.blockertrigger = undefined;
	opening.zombietrigger = undefined;
	opening.rebuildtrigger = undefined;
	opening.tagname = tag_name;
	opening.bindtag = _busfindclosesttag( self gettagorigin( tag_name ) );
/#
	assert( isDefined( opening.bindtag ) );
#/
	opening.jumptag = _busgetjumptagfrombindtag( opening.bindtag );
	opening.jumpent = level.the_bus;
	opening.roofjoint = _busgetroofjointfrombindtag( opening.bindtag );
	opening.origin = level.the_bus gettagorigin( opening.bindtag );
	opening.angles = self gettagangles( opening.bindtag );
	targets = getentarray( tag_name, "targetname" );
	if ( !isDefined( targets ) )
	{
/#
		assert( 0 );
#/
		return;
	}
	if ( !is_classic() )
	{
		i = 0;
		while ( i < targets.size )
		{
			if ( targets[ i ] iszbarrier() )
			{
				targets[ i ] delete();
			}
			i++;
		}
		return;
	}
	i = 0;
	while ( i < targets.size )
	{
		target = targets[ i ];
		if ( target iszbarrier() )
		{
			hasbarriers = 1;
			if ( isDefined( script_noteworthy ) && script_noteworthy == "front" )
			{
				hasbarriers = 0;
			}
			opening.zbarrier = target;
			opening.zbarrier setmovingplatformenabled( 1 );
			while ( hasbarriers )
			{
				opening.zbarrier.chunk_health = [];
				opening.zbarrier setzbarriercolmodel( "p6_anim_zm_barricade_board_bus_collision" );
				maps/mp/zombies/_zm_powerups::register_carpenter_node( opening, ::post_carpenter_callback );
				j = 0;
				while ( j < opening.zbarrier getnumzbarrierpieces() )
				{
					opening.zbarrier.chunk_health[ j ] = 0;
					j++;
				}
			}
			target.origin = level.the_bus gettagorigin( opening.bindtag );
		}
		else if ( target.script_noteworthy == "blocker" )
		{
			target delete();
			i++;
			continue;
		}
		else if ( target.script_noteworthy == "rebuild" )
		{
			opening.rebuildtrigger = target;
			opening.rebuildtrigger enablelinkto();
			opening.rebuildtrigger linkto( self );
			opening.rebuildtrigger setcursorhint( "HINT_NOICON" );
			opening.rebuildtrigger set_hint_string( self, "default_reward_barrier_piece" );
			opening.rebuildtrigger triggerignoreteam();
			opening.rebuildtrigger setinvisibletoall();
			opening.rebuildtrigger setmovingplatformenabled( 1 );
			self thread busopeningrebuildthink( opening );
			i++;
			continue;
		}
		else if ( target.script_noteworthy == "zombie" )
		{
			opening.zombietrigger = target;
			opening.zombietrigger enablelinkto();
			opening.zombietrigger linkto( self );
			opening.zombietrigger setmovingplatformenabled( 1 );
			opening.zombietrigger setteamfortrigger( level.zombie_team );
			self thread busopeningzombiethink( opening );
		}
		target linkto( self, "", self worldtolocalcoords( target.origin ), target.angles - self.angles );
		i++;
	}
	if ( isDefined( opening.zbarrier ) )
	{
		opening blocker_attack_spots();
	}
	opening notify( "opening_init_complete" );
/#
	if ( opening.boardsnum != 0 )
	{
		assert( opening.boardsnum == opening.boards.size );
	}
#/
}

post_carpenter_callback()
{
	if ( isDefined( self.rebuildtrigger ) )
	{
		self.rebuildtrigger setinvisibletoall();
	}
}

businitmantle()
{
	mantlebrush = getentarray( "window_mantle", "targetname" );
	while ( isDefined( mantlebrush ) && mantlebrush.size > 0 )
	{
		i = 0;
		while ( i < mantlebrush.size )
		{
			mantlebrush[ i ] delete();
			i++;
		}
	}
}

busattachjumpent( ent, opening )
{
	jump_origin = self gettagorigin( opening.jumptag );
	jump_angles = self gettagangles( opening.jumptag );
	ent.origin = jump_origin;
	ent.angles = jump_angles;
	ent linkto( self, "", self worldtolocalcoords( ent.origin ), ent.angles - self.angles );
}

busopeningbyname( name )
{
	i = 0;
	while ( i < self.openings.size )
	{
		opening = self.openings[ i ];
		if ( isDefined( opening.name ) && opening.name == name )
		{
			return opening;
		}
		i++;
	}
	return undefined;
}

busopeningsetenabled( name, enabled )
{
	i = 0;
	while ( i < self.openings.size )
	{
		opening = self.openings[ i ];
		if ( isDefined( opening.name ) && opening.name == name )
		{
			opening.enabled = enabled;
		}
		i++;
	}
}

_businittags()
{
	self.openingtags = [];
	self.openingtags[ self.openingtags.size ] = "window_right_front_jnt";
	self.openingtags[ self.openingtags.size ] = "window_left_front_jnt";
	self.openingtags[ self.openingtags.size ] = "door_front_jnt";
	self.openingtags[ self.openingtags.size ] = "door_rear_jnt";
	self.openingtags[ self.openingtags.size ] = "window_right_1_jnt";
	self.openingtags[ self.openingtags.size ] = "window_right_2_jnt";
	self.openingtags[ self.openingtags.size ] = "window_right_3_jnt";
	self.openingtags[ self.openingtags.size ] = "window_right_4_jnt";
	self.openingtags[ self.openingtags.size ] = "window_right_rear_jnt";
	self.openingtags[ self.openingtags.size ] = "window_left_rear_jnt";
	self.openingtags[ self.openingtags.size ] = "window_left_1_jnt";
	self.openingtags[ self.openingtags.size ] = "window_left_2_jnt";
	self.openingtags[ self.openingtags.size ] = "window_left_3_jnt";
	self.openingtags[ self.openingtags.size ] = "window_left_4_jnt";
	self.openingtags[ self.openingtags.size ] = "window_left_5_jnt";
/#
	i = 0;
	while ( i < self.openingtags.size )
	{
		adddebugcommand( "devgui_cmd "Zombies:1/Bus:14/Window Openings:3/Select Tag:1/" + self.openingtags[ i ] + ":" + self.openingtags.size + "" "zombie_devgui attach_tag " + self.openingtags[ i ] + ""\n" );
		i++;
#/
	}
}

_busfindclosesttag( checkpos )
{
	closest = undefined;
	closestdist = -1;
/#
	assert( isDefined( self.openingtags ) );
#/
	i = 0;
	while ( i < self.openingtags.size )
	{
		tag = self.openingtags[ i ];
		pos = self gettagorigin( tag );
		dist2 = distancesquared( checkpos, pos );
		if ( !isDefined( closest ) || dist2 < closestdist )
		{
			closest = tag;
			closestdist = dist2;
		}
		i++;
	}
	return closest;
}

_busgetjumptagfrombindtag( tag )
{
	jump_tag = undefined;
	switch( tag )
	{
		case "window_right_1_jnt":
			jump_tag = "window_right_1_jmp_jnt";
			break;
		case "window_right_2_jnt":
			jump_tag = "window_right_2_jmp_jnt";
			break;
		case "window_right_3_jnt":
			jump_tag = "window_right_3_jmp_jnt";
			break;
		case "window_right_4_jnt":
			jump_tag = "window_right_4_jmp_jnt";
			break;
		case "window_left_1_jnt":
			jump_tag = "window_left_1_jmp_jnt";
			break;
		case "window_left_2_jnt":
			jump_tag = "window_left_2_jmp_jnt";
			break;
		case "window_left_3_jnt":
			jump_tag = "window_left_3_jmp_jnt";
			break;
		case "window_left_4_jnt":
			jump_tag = "window_left_4_jmp_jnt";
			break;
		case "window_left_5_jnt":
			jump_tag = "window_left_5_jmp_jnt";
			break;
		case "window_right_rear_jnt":
			jump_tag = "window_right_rear_jmp_jnt";
			break;
		case "window_left_rear_jnt":
			jump_tag = "window_left_rear_jmp_jnt";
			break;
		case "window_right_front_jnt":
			jump_tag = "window_right_front_jmp_jnt";
			break;
		case "window_left_front_jnt":
			jump_tag = "window_left_front_jmp_jnt";
			break;
		case "door_rear_jnt":
			jump_tag = "door_rear_jmp_jnt";
			break;
		case "door_front_jnt":
			jump_tag = "door_front_jmp_jnt";
			break;
		default:
		}
		return jump_tag;
	}
}

_busgetroofjointfrombindtag( tag )
{
	roofjoint = undefined;
	switch( tag )
	{
		case "window_left_1_jnt":
		case "window_left_front_jnt":
		case "window_right_1_jnt":
		case "window_right_front_jnt":
			roofjoint = "window_roof_1_jnt";
			break;
		case "window_left_2_jnt":
		case "window_left_3_jnt":
		case "window_left_4_jnt":
		case "window_left_5_jnt":
		case "window_left_rear_jnt":
		case "window_right_2_jnt":
		case "window_right_3_jnt":
		case "window_right_4_jnt":
		case "window_right_rear_jnt":
			roofjoint = "window_roof_2_jnt";
			default:
				break;
		}
		return roofjoint;
	}
}

_setupnumattachtable()
{
	level.numattachtable = [];
	level.numattachtable[ 0 ] = -1;
	level.numattachtable[ 1 ] = 6;
	level.numattachtable[ 2 ] = 8;
	level.numattachtable[ 3 ] = 10;
	level.numattachtable[ 4 ] = -1;
}

busgetopeningfortag( tagname )
{
	i = 0;
	while ( i < self.openings.size )
	{
		if ( self.openings[ i ].bindtag == tagname )
		{
			return self.openings[ i ];
		}
		i++;
	}
	return undefined;
}

zombieanimnotetrackthink( notifystring, chunk, node )
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( notifystring, notetrack );
		if ( notetrack == "end" )
		{
			return;
			continue;
		}
		else if ( notetrack == "board" || notetrack == "destroy_piece" )
		{
			node.zbarrier setzbarrierpiecestate( chunk, "opening" );
			if ( isDefined( node.rebuildtrigger ) )
			{
				node.rebuildtrigger setvisibletoall();
			}
			continue;
		}
		else
		{
			while ( notetrack == "fire" )
			{
				attackplayers = self zombiegetplayerstoattack();
				while ( attackplayers.size )
				{
					i = 0;
					while ( i < attackplayers.size )
					{
						attackplayers[ i ] dodamage( self.meleedamage, self.origin, self, self, "none", "MOD_MELEE" );
						i++;
					}
				}
			}
		}
	}
}

busopeningblockerthink( opening )
{
	self endon( "intermission" );
	while ( 1 )
	{
		opening.blockertrigger waittill( "trigger", player );
		while ( isDefined( opening.zombie ) )
		{
			continue;
		}
	}
	self notify( "OnBlockerPlaced" );
}

buswatchtriggervisibility( opening )
{
	self endon( "intermission" );
	opening waittill( "opening_init_complete" );
	if ( !isDefined( opening.zbarrier ) || opening.zbarrier getnumzbarrierpieces() < 1 )
	{
		return;
	}
	if ( !isDefined( level.buswatchtriggervisibility_spread ) )
	{
		level.buswatchtriggervisibility_spread = 0;
	}
	else
	{
		level.buswatchtriggervisibility_spread++;
		wait ( 0,05 * level.buswatchtriggervisibility_spread );
	}
	while ( 1 )
	{
		if ( no_valid_repairable_boards( opening ) )
		{
			opening.rebuildtrigger setinvisibletoall();
		}
		else
		{
			opening.rebuildtrigger setvisibletoall();
		}
		wait 1;
	}
}

busopeningrebuildthink( opening )
{
	self endon( "intermission" );
	self thread buswatchtriggervisibility( opening );
	cost = 10;
	if ( isDefined( opening.rebuildtrigger.zombie_cost ) )
	{
		cost = opening.rebuildtrigger.zombie_cost;
	}
	while ( 1 )
	{
		opening.rebuildtrigger waittill( "trigger", player );
		players = get_players();
		has_perk = player has_blocker_affecting_perk();
		while ( player_fails_blocker_repair_trigger_preamble( player, players, opening.rebuildtrigger, 0 ) )
		{
			continue;
		}
		while ( all_chunks_intact( opening ) )
		{
			continue;
		}
		while ( no_valid_repairable_boards( opening ) )
		{
			continue;
		}
		chunk = get_random_destroyed_chunk( opening );
		if ( isDefined( player.pers_upgrades_awarded[ "board" ] ) )
		{
			self thread replace_chunk( opening, chunk, has_perk, player.pers_upgrades_awarded[ "board" ] );
		}
		opening do_post_chunk_repair_delay( has_perk );
		while ( !is_player_valid( player ) )
		{
			if ( no_valid_repairable_boards( opening ) )
			{
				opening.rebuildtrigger setinvisibletoall();
			}
		}
		player handle_post_board_repair_rewards( cost );
		if ( no_valid_repairable_boards( opening ) )
		{
			opening.rebuildtrigger setinvisibletoall();
		}
	}
}

_determinejumpfromorigin( opening )
{
	return level.the_bus gettagorigin( opening.jumptag );
}

_getsideofbusopeningison( opening_tag )
{
	side = undefined;
	switch( opening_tag )
	{
		case "door_front_jnt":
		case "door_rear_jnt":
		case "window_right_1_jnt":
		case "window_right_2_jnt":
		case "window_right_3_jnt":
		case "window_right_4_jnt":
			side = "right";
			break;
		case "window_left_1_jnt":
		case "window_left_2_jnt":
		case "window_left_3_jnt":
		case "window_left_4_jnt":
		case "window_left_5_jnt":
			side = "left";
			break;
		case "window_left_front_jnt":
		case "window_right_front_jnt":
			side = "front";
			break;
		case "window_left_rear_jnt":
		case "window_right_rear_jnt":
			side = "back";
			break;
	}
	return side;
}

busopeningzombiethink( opening )
{
	self endon( "intermission" );
	if ( _isopeningdoor( opening.bindtag ) )
	{
		opening.enabled = 0;
		return;
	}
	while ( 1 )
	{
		opening.zombietrigger waittill( "trigger", zombie );
		while ( zombie.isdog )
		{
			continue;
		}
		if ( isDefined( zombie.isscreecher ) && zombie.isscreecher )
		{
			continue;
		}
		if ( isDefined( zombie.is_avogadro ) && zombie.is_avogadro )
		{
			continue;
		}
		while ( !isalive( zombie ) )
		{
			continue;
		}
		while ( !opening.enabled )
		{
			continue;
		}
		if ( _isopeningdoor( opening.bindtag ) && self.doorsclosed )
		{
			continue;
		}
		if ( isDefined( zombie.favoriteenemy ) )
		{
			enemy_on_roof = zombie.favoriteenemy.isonbusroof;
		}
		while ( self.ismoving && isDefined( self.disabled_by_emp ) && self.disabled_by_emp && !self.doorsclosed && !enemy_on_roof )
		{
			continue;
		}
		monkey = undefined;
		if ( isDefined( zombie.enemyoverride ) )
		{
			monkey = zombie.enemyoverride[ 1 ];
		}
		if ( isDefined( monkey ) && !monkey maps/mp/zm_transit_bus::entity_is_on_bus( 1 ) )
		{
			continue;
		}
		if ( !isDefined( zombie.favoriteenemy ) || !zombie.favoriteenemy.isonbus )
		{
			continue;
		}
		if ( isDefined( zombie.isonbus ) && zombie.isonbus )
		{
			continue;
		}
		while ( isDefined( zombie.opening ) )
		{
			continue;
		}
		while ( isDefined( opening.zombie ) )
		{
			continue;
		}
		if ( isDefined( zombie.is_inert ) && zombie.is_inert )
		{
			continue;
		}
		if ( isDefined( zombie.cannotattachtobus ) && zombie.cannotattachtobus )
		{
			continue;
		}
		while ( !level.the_bus.ismoving )
		{
			jump_origin = _determinejumpfromorigin( opening );
			distance_from_jump_origin2 = distance2dsquared( jump_origin, zombie.origin );
			while ( distance_from_jump_origin2 > 256 )
			{
				continue;
			}
		}
		if ( isDefined( zombie.dismount_start ) && zombie.dismount_start )
		{
			continue;
		}
		zombie thread zombieattachtobus( self, opening );
	}
}

_buscanzombieattach( zombie )
{
	currentlyattached = 0;
	i = 0;
	while ( i < self.openings.size )
	{
		if ( isDefined( self.openings[ i ].zombie ) )
		{
			currentlyattached++;
		}
		i++;
	}
	players = get_players();
	maxattach = level.numattachtable[ players.size ];
	if ( maxattach < 0 )
	{
		return currentlyattached < maxattach;
	}
}

zombieplayattachedanim( animname )
{
	self endon( "death" );
	anim_index = self getanimsubstatefromasd( "zm_bus_attached", animname );
	animationid = self getanimfromasd( "zm_bus_attached", anim_index );
	tag_origin = self.attachent gettagorigin( self.attachtag );
	tag_angles = self.attachent gettagangles( self.attachtag );
	start_origin = getstartorigin( tag_origin, tag_angles, animationid );
	start_angles = getstartangles( tag_origin, tag_angles, animationid );
	self animscripted( start_origin, start_angles, "zm_bus_attached", anim_index );
	self zombieanimnotetrackthink( "bus_attached_anim" );
}

debugline( frompoint, color, durationframes )
{
/#
	i = 0;
	while ( i < durationframes )
	{
		line( frompoint, ( frompoint[ 0 ], frompoint[ 1 ], frompoint[ 2 ] + 50 ), color );
		wait 0,05;
		i++;
#/
	}
}

debugbox( frompoint, color, durationframes )
{
/#
	i = 0;
	while ( i < durationframes )
	{
		box( frompoint, ( 0, -1, 0 ), ( 0, -1, 0 ), 0, color );
		wait 0,05;
		i++;
#/
	}
}

_isopeningdoor( opening_tag )
{
	is_door = 0;
	switch( opening_tag )
	{
		case "door_front_jnt":
		case "door_rear_jnt":
			is_door = 1;
			break;
		default:
		}
		return is_door;
	}
}

busexitthink( trigger )
{
	while ( 1 )
	{
		trigger waittill( "trigger", zombie );
		if ( isDefined( zombie.is_inert ) && zombie.is_inert )
		{
			continue;
		}
		if ( isDefined( zombie.walk_to_exit ) && !zombie.walk_to_exit )
		{
			continue;
		}
		if ( isDefined( zombie.exiting_window ) && zombie.exiting_window )
		{
			continue;
		}
		going_to_roof = 0;
		while ( isDefined( zombie.favoriteenemy ) && zombie.favoriteenemy.isonbusroof == 1 )
		{
			going_to_roof = 1;
			while ( trigger.substate == 2 )
			{
				continue;
			}
		}
		while ( !going_to_roof && isDefined( level.the_bus.doorsclosed ) && !level.the_bus.doorsclosed && zombie.ai_state != "zombieWindowToRoof" )
		{
			continue;
		}
		zombie thread zombieexitwindow( self, trigger, going_to_roof );
	}
}

zombieexitwindow( bus, trigger, going_to_roof )
{
	self endon( "death" );
	self.ai_state = "zombieExitWindow";
	self.inert_delay = ::zombieexitwindowdelay;
	self.exiting_window = 1;
	self linkto( bus, trigger.tag );
	tag_origin = bus gettagorigin( trigger.tag );
	tag_angles = bus gettagangles( trigger.tag );
	exit_anim = "zm_window_exit";
	if ( going_to_roof )
	{
		exit_anim = "zm_bus_window2roof";
	}
	animstate = maps/mp/animscripts/zm_utility::append_missing_legs_suffix( exit_anim );
	self animscripted( tag_origin, tag_angles, animstate, trigger.substate );
	maps/mp/animscripts/zm_shared::donotetracks( "window_exit_anim" );
	self.exiting_window = undefined;
	self.walk_to_exit = undefined;
	self unlink();
	self setgoalpos( self.origin );
	self.inert_delay = undefined;
	if ( going_to_roof )
	{
		return;
	}
	self animmode( "normal" );
	self orientmode( "face enemy" );
	self.forcemovementscriptstate = 0;
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
}

zombieexitwindowdelay()
{
	self endon( "death" );
	while ( isDefined( self.exiting_window ) && self.exiting_window )
	{
		wait 0,1;
	}
	while ( 1 )
	{
		if ( self.ai_state == "find_flesh" )
		{
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self.inert_delay = undefined;
}

teleportthreadex( verticaloffset, delay, frames )
{
	amount = verticaloffset / frames;
	if ( amount > 10 )
	{
		amount = 10;
	}
	else
	{
		if ( amount < -10 )
		{
			amount = -10;
		}
	}
	offset = ( 0, 0, amount );
	i = 0;
	while ( i < frames )
	{
		self teleport( self.origin + offset );
		wait 0,05;
		i++;
	}
}

zombieopeningdelay()
{
	self endon( "death" );
	self maps/mp/zombies/_zm_spawner::zombie_history( "opening delay detach " + getTime() );
	while ( isDefined( self.jumpingtowindow ) && self.jumpingtowindow )
	{
		while ( 1 )
		{
			if ( isDefined( self.jumpingtowindow ) && !self.jumpingtowindow )
			{
				break;
			}
			else
			{
				wait 0,1;
			}
		}
	}
	self zombiedetachfrombus( self.left_or_right );
	while ( 1 )
	{
		if ( self.ai_state == "find_flesh" )
		{
			break;
		}
		else
		{
			wait 0,1;
		}
	}
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self.inert_delay = undefined;
}

zombieattachtobus( thebus, opening, removeafterdone )
{
	self endon( "death" );
	self endon( "removed" );
	self endon( "sonicBoom" );
	level endon( "intermission" );
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self endon( "detach_on_window" );
	self endon( "exploding" );
	self.ai_state = "zombieAttachToBus";
	self maps/mp/zombies/_zm_spawner::zombie_history( "zombieAttachToBus " + getTime() );
	opening.zombie = self;
	self.dont_throw_gib = 1;
	self.forcemovementscriptstate = 1;
	self.opening = opening;
	self.left_or_right = self zombieattachleftorright( thebus );
	self.attachent = level.the_bus;
	self.attachtag = self.opening.bindtag;
	self linkto( self.attachent, self.attachtag );
	from_front = 0;
	from_rear = 0;
	self.inert_delay = ::zombieopeningdelay;
	if ( _isopeningdoor( opening.bindtag ) )
	{
		self animscripted( self.origin, self.angles, "zm_jump_on_bus", 0 );
		if ( opening.bindtag == "door_front_jnt" )
		{
			from_front = 1;
		}
		else
		{
			from_rear = 1;
		}
	}
	else
	{
		self.jumpingtowindow = 1;
		asd_name = "zm_zbarrier_jump_on_bus";
		side = _getsideofbusopeningison( opening.bindtag );
		if ( isDefined( side ) && side == "front" )
		{
			asd_name = "zm_zbarrier_jump_on_bus_front";
		}
		animstate = maps/mp/animscripts/zm_utility::append_missing_legs_suffix( asd_name );
		tag_origin = self.attachent gettagorigin( self.attachtag );
		tag_angles = self.attachent gettagangles( self.attachtag );
		self animmode( "noclip" );
		self animscripted( tag_origin, tag_angles, animstate, "jump_window" + self.left_or_right );
	}
	self zombieanimnotetrackthink( "jump_on_bus_anim" );
	self animmode( "gravity" );
	self.jumpingtowindow = 0;
	if ( isDefined( self.a.gib_ref ) || self.a.gib_ref == "left_arm" && self.a.gib_ref == "right_arm" )
	{
		self dodamage( self.health + 666, self.origin );
		self startragdoll();
		self launchragdoll( ( 0, -1, 0 ) );
		opening.zombie = undefined;
	}
	if ( 1 )
	{
		hitpos = self.attachent gettagorigin( self.attachtag );
		hitposinbus = pointonsegmentnearesttopoint( thebus.frontworld, thebus.backworld, hitpos );
		hitdir = vectornormalize( hitposinbus - hitpos );
		hitforce = vectorScale( hitdir, 100 );
		hitpos += vectorScale( ( 0, -1, 0 ), 50 );
		earthquake( randomfloatrange( 0,3, 0,4 ), randomfloatrange( 0,2, 0,4 ), hitpos, 150 );
		play_sound_at_pos( "grab_metal_bar", hitpos );
	}
	if ( self zombiecanjumponroof( opening ) )
	{
		self zombiejumponroof( thebus, opening, removeafterdone, self.left_or_right );
		self zombiesetnexttimetojumponroof();
		self maps/mp/animscripts/zm_run::needsupdate();
		if ( !self.isdog )
		{
			self maps/mp/animscripts/zm_run::moverun();
		}
	}
	else
	{
		for ( ;; )
		{
			while ( 1 )
			{
				if ( !isDefined( opening.zbarrier ) || maps/mp/zombies/_zm_spawner::get_attack_spot( opening ) )
				{
					break;
				}
				else
				{
/#
					println( "Zombie failed to get bus attack spot" );
#/
					wait 0,5;
				}
			}
		}
		while ( !all_chunks_destroyed( opening ) )
		{
			if ( zombieshoulddetachfromwindow() )
			{
				zombiedetachfrombus( self.left_or_right );
				return;
			}
			self.onbuswindow = 1;
			chunk = get_closest_non_destroyed_chunk( self.origin, opening );
			waited = 0;
			if ( isDefined( chunk ) )
			{
				waited = 1;
				opening.zbarrier setzbarrierpiecestate( chunk, "targetted_by_zombie" );
				opening thread check_zbarrier_piece_for_zombie_death( chunk, opening.zbarrier, self );
				self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "teardown", self.animname );
				animstatebase = opening.zbarrier getzbarrierpieceanimstate( chunk );
				animsubstate = "spot_" + self.attacking_spot_index + self.left_or_right + "_piece_" + opening.zbarrier getzbarrierpieceanimsubstate( chunk );
				anim_sub_index = self getanimsubstatefromasd( animstatebase + "_in", animsubstate );
				tag_origin = self.attachent gettagorigin( self.attachtag );
				tag_angles = self.attachent gettagangles( self.attachtag );
				self animscripted( tag_origin, tag_angles, maps/mp/animscripts/zm_utility::append_missing_legs_suffix( animstatebase + "_in" ), anim_sub_index );
				self zombieanimnotetrackthink( "board_tear_bus_anim", chunk, opening );
				while ( opening.zbarrier.chunk_health[ chunk ] >= 0 )
				{
					tag_origin = self.attachent gettagorigin( self.attachtag );
					tag_angles = self.attachent gettagangles( self.attachtag );
					self animscripted( tag_origin, tag_angles, maps/mp/animscripts/zm_utility::append_missing_legs_suffix( animstatebase + "_loop" ), anim_sub_index );
					self zombieanimnotetrackthink( "board_tear_bus_anim", chunk, opening );
					opening.zbarrier.chunk_health[ chunk ]--;

				}
				tag_origin = self.attachent gettagorigin( self.attachtag );
				tag_angles = self.attachent gettagangles( self.attachtag );
				self animscripted( tag_origin, tag_angles, maps/mp/animscripts/zm_utility::append_missing_legs_suffix( animstatebase + "_out" ), anim_sub_index );
				self zombieanimnotetrackthink( "board_tear_bus_anim", chunk, opening );
			}
			tried_attack = self zombietryattackthroughwindow( 1, self.left_or_right );
			if ( !tried_attack && !waited )
			{
				wait 0,1;
			}
		}
		self.onbuswindow = undefined;
		if ( !_isopeningdoor( opening.bindtag ) )
		{
			self zombiekeepattackingthroughwindow( self.left_or_right );
			side = _getsideofbusopeningison( opening.bindtag );
			if ( side == "front" )
			{
				from_front = 1;
			}
			anim_state = "window_climbin";
			if ( from_front )
			{
				anim_state += "_front";
				anim_state += self.left_or_right;
			}
			else if ( from_rear )
			{
				anim_state += "_back";
			}
			else
			{
				anim_state += self.left_or_right;
			}
			min_chance_at_round = 5;
			max_chance_at_round = 12;
			if ( level.round_number >= min_chance_at_round )
			{
				round = min( level.round_number, max_chance_at_round );
				range = max_chance_at_round - min_chance_at_round;
				chance = ( 100 / range ) * ( round - min_chance_at_round );
				if ( randomintrange( 0, 100 ) <= chance )
				{
					anim_state += "_fast";
				}
			}
			anim_index = self getanimsubstatefromasd( "zm_zbarrier_climbin_bus", anim_state );
			enter_anim = self getanimfromasd( "zm_zbarrier_climbin_bus", anim_index );
			tag_origin = self.attachent gettagorigin( self.attachtag );
			tag_angles = self.attachent gettagangles( self.attachtag );
			self.climbing_into_bus = 1;
			self.entering_bus = 1;
			self animmode( "noclip" );
			self animscripted( tag_origin, tag_angles, "zm_zbarrier_climbin_bus", anim_index );
			self zombieanimnotetrackthink( "climbin_bus_anim" );
			self animmode( "gravity" );
			self maps/mp/animscripts/zm_run::needsupdate();
			if ( !self.isdog )
			{
				self maps/mp/animscripts/zm_run::moverun();
			}
		}
		opening.zombie = undefined;
		self.opening = undefined;
		self unlink();
		self setgoalpos( self.origin );
	}
	self reset_attack_spot();
	self.climbing_into_bus = 0;
	if ( isDefined( removeafterdone ) && removeafterdone )
	{
		self delete();
		return;
	}
	self.inert_delay = undefined;
}

zombieattachleftorright( bus )
{
	tag = self.opening.bindtag;
	if ( isDefined( bus.doorsclosed ) && !bus.doorsclosed )
	{
		if ( tag != "window_right_1_jnt" || tag == "window_right_2_jnt" && tag == "window_right_3_jnt" )
		{
			return "_r";
		}
		else
		{
			if ( tag == "window_right_4_jnt" )
			{
				return "_l";
			}
		}
	}
	side = getopeningside( tag );
	while ( isDefined( side ) )
	{
		if ( side == "right" )
		{
			openings = bus.openingright;
		}
		else
		{
			if ( side == "left" )
			{
				openings = bus.openingleft;
			}
		}
		_a1332 = openings;
		_k1332 = getFirstArrayKey( _a1332 );
		while ( isDefined( _k1332 ) )
		{
			opening = _a1332[ _k1332 ];
			if ( opening == self.opening )
			{
			}
			else
			{
				if ( isDefined( opening.zombie ) )
				{
					return opening.zombie.left_or_right;
				}
			}
			_k1332 = getNextArrayKey( _a1332, _k1332 );
		}
	}
	left_or_right = "_l";
	if ( randomint( 10 ) > 5 )
	{
		left_or_right = "_r";
	}
	return left_or_right;
}

businitrightandleft()
{
	self.openingright = [];
	self.openingleft = [];
	_a1367 = self.openings;
	_k1367 = getFirstArrayKey( _a1367 );
	while ( isDefined( _k1367 ) )
	{
		opening = _a1367[ _k1367 ];
		side = getopeningside( opening.bindtag );
		if ( isDefined( side ) )
		{
			if ( side == "right" )
			{
				self.openingright[ self.openingright.size ] = opening;
				break;
			}
			else
			{
				if ( side == "left" )
				{
					self.openingleft[ self.openingleft.size ] = opening;
				}
			}
		}
		_k1367 = getNextArrayKey( _a1367, _k1367 );
	}
}

getopeningside( tag )
{
	i = 1;
	while ( i <= 4 )
	{
		window_tag = "window_right_" + i + "_jnt";
		if ( tag == window_tag )
		{
			return "right";
		}
		i++;
	}
	i = 1;
	while ( i <= 5 )
	{
		window_tag = "window_left_" + i + "_jnt";
		if ( tag == window_tag )
		{
			return "left";
		}
		i++;
	}
	return undefined;
}

zombiegetwindowanimrate()
{
	animrate = 1;
	animrateroundscalar = 0;
	players = get_players();
	if ( players.size > 1 )
	{
		target_rate = 1,5;
		target_round = 25;
		target_num_players = 4;
		rate = ( target_rate - 1 ) / target_round / target_num_players;
		animrateroundscalar = rate * players.size;
		animrate = 1 + ( animrateroundscalar * level.round_number );
		if ( animrate > target_rate )
		{
			animrate = target_rate;
		}
	}
	return animrate;
}

zombiedetachfrombus( postfix )
{
	if ( !isDefined( self.opening ) )
	{
		return;
	}
	if ( isDefined( self.opening.zombie ) && self.opening.zombie == self )
	{
		self.opening.zombie = undefined;
	}
	is_right = 0;
	if ( postfix == "_r" )
	{
		is_right = 1;
	}
	bindtag = self.opening.bindtag;
	side = _getsideofbusopeningison( bindtag );
	tag_origin = level.the_bus gettagorigin( bindtag );
	tag_angles = level.the_bus gettagangles( bindtag );
	self.opening = undefined;
	self.isonbusroof = 0;
	self.onbuswindow = undefined;
	self.ai_state = "zombieDetachFromBus";
	self.entering_bus = 0;
	self.isonbus = 0;
	asd_name = "zm_window_dismount";
	if ( isDefined( side ) && side == "front" )
	{
		asd_name = "zm_front_window_dismount";
	}
	animstate = maps/mp/animscripts/zm_utility::append_missing_legs_suffix( asd_name );
	self animscripted( tag_origin, tag_angles, animstate, is_right );
	self.dismount_start = 1;
	self thread dismount_timer();
	maps/mp/animscripts/zm_shared::donotetracks( "window_dismount_anim" );
	self unlink();
	self reset_attack_spot();
	self.dismount_start = 0;
	self.forcemovementscriptstate = 0;
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	self.dont_throw_gib = undefined;
	self notify( "detach_on_window" );
}

dismount_timer()
{
	self endon( "death" );
	wait 1,5;
	self.dismount_start = 0;
}

zombiegetcymbalmonkey()
{
	if ( isDefined( self.monkey_time ) && getTime() < self.monkey_time )
	{
		return self.monkey;
	}
	poi = undefined;
	if ( level.cymbal_monkeys.size > 0 )
	{
		poi = self get_zombie_point_of_interest( self.origin, level.cymbal_monkeys );
	}
	if ( isDefined( poi ) )
	{
		self.monkey = poi[ 1 ];
		self.monkey_time = getTime() + 250;
		return poi[ 1 ];
	}
	return undefined;
}

zombieshoulddetachfromwindow()
{
	monkey = self zombiegetcymbalmonkey();
	if ( isDefined( monkey ) )
	{
		if ( monkey maps/mp/zm_transit_bus::entity_is_on_bus( 1 ) )
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}
	enemy = self.favoriteenemy;
	if ( isDefined( enemy ) && !self.favoriteenemy.isonbus )
	{
		return 1;
	}
	return 0;
}

zombiecanjumponroof( opening )
{
	if ( level.the_bus.numplayersonroof == 0 )
	{
		if ( all_chunks_destroyed( opening ) )
		{
			return 0;
		}
		if ( isDefined( level.bus_zombie_on_roof ) )
		{
			return 0;
		}
		if ( level.bus_roof_next_time > getTime() )
		{
			return 0;
		}
	}
	percentchance = 0;
	if ( level.round_number <= 5 )
	{
		percentchance = 5;
	}
	else if ( level.round_number <= 10 )
	{
		percentchance = 20;
	}
	else if ( level.round_number <= 20 )
	{
		percentchance = 30;
	}
	else if ( level.round_number <= 25 )
	{
		percentchance = 40;
	}
	else
	{
		percentchance = 50;
	}
	percentofplayersonroof = 1;
	if ( level.the_bus.numplayersnear > 0 )
	{
		percentofplayersonroof = level.the_bus.numplayersonroof / level.the_bus.numplayersnear;
	}
	percentofplayersonroof *= 100;
	if ( percentchance < percentofplayersonroof )
	{
		percentchance = percentofplayersonroof;
	}
	if ( randomint( 100 ) < percentchance )
	{
		return 1;
	}
	return 0;
}

zombiesetnexttimetojumponroof()
{
	level.bus_roof_next_time = getTime() + level.bus_roof_min_interval_time + randomint( level.bus_roof_max_interval_time - level.bus_roof_min_interval_time );
}

zombiejumponroof( thebus, opening, removeafterdone, postfix )
{
	level.bus_zombie_on_roof = self;
	self.climbing_onto_bus = 1;
	self.entering_bus = 1;
	self animscripted( self.opening.zbarrier.origin, self.opening.zbarrier.angles, "zm_zbarrier_window_climbup", "window_climbup" + postfix );
	self zombieanimnotetrackthink( "bus_window_climbup" );
	play_sound_at_pos( "grab_metal_bar", self.origin );
	opening.zombie = undefined;
	self.opening = undefined;
	self unlink();
	self setgoalpos( self.origin );
	self.climbing_onto_bus = 0;
	if ( level.the_bus.numplayersonroof > 0 )
	{
		level.bus_zombie_on_roof = undefined;
	}
}

bussetupladder()
{
	trigger = getent( "bus_ladder_trigger", "targetname" );
	if ( !isDefined( trigger ) )
	{
		return;
	}
	trigger enablelinkto();
	trigger linkto( level.the_bus );
	trigger setmovingplatformenabled( 1 );
	trigger setinvisibletoall();
	mantlebrush = getentarray( "ladder_mantle", "targetname" );
	while ( isDefined( mantlebrush ) && mantlebrush.size > 0 )
	{
		i = 0;
		while ( i < mantlebrush.size )
		{
			self thread busdeferredinitladdermantle( mantlebrush[ i ] );
			i++;
		}
	}
	thread busladderthink();
}

busdeferredinitladdermantle( mantle )
{
	origin = self worldtolocalcoords( mantle.origin );
	mantle linkto( self, "", origin, ( 0, -1, 0 ) );
	mantle setmovingplatformenabled( 1 );
	wait_for_buildable( "busladder" );
	mantle delete();
}

busladderthink()
{
	origin = level.the_bus gettagorigin( "tag_ladder_attach" );
	origin += ( 10, 3, -30 );
	angles = level.the_bus gettagangles( "tag_ladder_attach" );
	angles += vectorScale( ( 0, -1, 0 ), 90 );
	level.the_bus.ladder = spawn( "script_model", origin );
	level.the_bus.ladder.angles = angles;
	level.the_bus.ladder setmodel( "com_stepladder_large_closed" );
	level.the_bus.ladder notsolid();
	level.the_bus.ladder linkto( level.the_bus, "tag_ladder_attach" );
	level.the_bus.ladder setmovingplatformenabled( 1 );
	level.the_bus.ladder hide();
	player = wait_for_buildable( "busladder" );
	flag_set( "ladder_attached" );
	level.the_bus.ladder show();
	player maps/mp/zombies/_zm_buildables::track_placed_buildables( "busladder" );
}

bussetuproofopening()
{
	level.bus_roof_open = 0;
	level.bus_zombie_on_roof = undefined;
	level.bus_roof_next_time = 0;
	level.bus_roof_min_interval_time = 10000;
	level.bus_roof_max_interval_time = 20000;
	trigger = getent( "bus_hatch_bottom_trigger", "targetname" );
	if ( !isDefined( trigger ) )
	{
		return;
	}
	trigger enablelinkto();
	trigger linkto( level.the_bus );
	trigger setmovingplatformenabled( 1 );
	self thread bus_hatch_wait();
	self thread bus_hatch_tearin_wait();
	clipbrush = getentarray( "hatch_clip", "targetname" );
	while ( isDefined( clipbrush ) && clipbrush.size > 0 )
	{
		i = 0;
		while ( i < clipbrush.size )
		{
			self thread businithatchclip( clipbrush[ i ] );
			i++;
		}
	}
	mantlebrush = getentarray( "hatch_mantle", "targetname" );
	while ( isDefined( mantlebrush ) && mantlebrush.size > 0 )
	{
		i = 0;
		while ( i < mantlebrush.size )
		{
			self thread busdeferredinithatchmantle( mantlebrush[ i ] );
			i++;
		}
	}
	hatch_location = spawn( "script_origin", level.the_bus localtoworldcoords( ( 227, -1,7, 48 ) ) );
	hatch_location enablelinkto();
	hatch_location linkto( level.the_bus );
	hatch_location setmovingplatformenabled( 1 );
	level.the_bus.hatch_location = hatch_location;
/#
	adddebugcommand( "devgui_cmd "Zombies:1/Bus:14/Hatch:4/Allow Traverse:1" "zombie_devgui hatch_available"\n" );
	self thread wait_open_sesame();
#/
}

wait_open_sesame()
{
	level waittill( "open_sesame" );
	self notify( "hatch_mantle_allowed" );
	if ( isDefined( level.bus_tearin_roof ) )
	{
		level.bus_tearin_roof hide();
	}
	level.the_bus showpart( "tag_hatch_attach_ladder" );
	level.the_bus hidepart( "tag_hatch_pristine" );
	level.the_bus hidepart( "tag_hatch_damaged" );
	level.bus_roof_open = 1;
	level.bus_roof_tearing = 0;
}

bus_hatch_wait()
{
	level.the_bus hidepart( "tag_hatch_attach_ladder" );
	player = wait_for_buildable( "bushatch" );
	flag_set( "hatch_attached" );
	level.the_bus showpart( "tag_hatch_attach_ladder" );
	level.the_bus hidepart( "tag_hatch_pristine" );
	level.the_bus hidepart( "tag_hatch_damaged" );
	level.bus_roof_open = 1;
	level.bus_roof_tearing = 0;
	self notify( "hatch_mantle_allowed" );
	player maps/mp/zombies/_zm_buildables::track_placed_buildables( "bushatch" );
}

bus_hatch_tearin_wait()
{
	self endon( "hatch_mantle_allowed" );
	level.the_bus hidepart( "tag_hatch_damaged" );
	self waittill( "hatch_ripped_open" );
	level.the_bus hidepart( "tag_hatch_pristine" );
	level.the_bus showpart( "tag_hatch_damaged" );
	self notify( "hatch_drop_allowed" );
	playfxontag( level._effect[ "bus_hatch_bust" ], self, "tag_headlights" );
}

businithatchclip( clip )
{
	origin = self worldtolocalcoords( clip.origin );
	clip linkto( self, "", origin, ( 0, -1, 0 ) );
	clip setmovingplatformenabled( 1 );
	self waittill_any( "hatch_mantle_allowed", "hatch_drop_allowed" );
	clip delete();
}

busdeferredinithatchmantle( mantle )
{
	origin = self worldtolocalcoords( mantle.origin );
	mantle.origin = vectorScale( ( 0, -1, 0 ), 100 );
	self waittill( "hatch_mantle_allowed" );
	mantle linkto( self, "", origin, ( 0, -1, 0 ) );
	mantle setmovingplatformenabled( 1 );
}

zombieonbusenemy()
{
	new_enemy = undefined;
	if ( isDefined( level.the_bus.bus_riders_alive ) && level.the_bus.bus_riders_alive.size > 0 )
	{
		new_enemy = getclosest( self.origin, level.the_bus.bus_riders_alive );
	}
	if ( isDefined( new_enemy ) && isDefined( self.favoriteenemy ) && isDefined( new_enemy ) && self.favoriteenemy != new_enemy )
	{
		if ( isDefined( self.favoriteenemy.isonbus ) && !self.favoriteenemy.isonbus )
		{
			self.favoriteenemy = new_enemy;
			return;
		}
		else
		{
			if ( self.isonbusroof == new_enemy.isonbusroof )
			{
				self.favoriteenemy = new_enemy;
			}
		}
	}
}

zombiemoveonbus()
{
	self endon( "death" );
	self endon( "removed" );
	level endon( "intermission" );
	self notify( "endOnBus" );
	self endon( "endOnBus" );
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	wait 0,05;
	self orientmode( "face enemy" );
	self.goalradius = 32;
	self.forcemovementscriptstate = 1;
	self.ai_state = "zombieMoveOnBus";
	self maps/mp/zombies/_zm_spawner::zombie_history( "zombieMoveOnBus " + getTime() );
	bus_nodes = getnodearray( "the_bus", "target" );
	while ( 1 )
	{
		self zombieonbusenemy();
		if ( !isDefined( self.favoriteenemy ) )
		{
			break;
		}
		else if ( isDefined( self.isonbus ) )
		{
			self_on_bus = self.isonbus;
		}
		if ( isDefined( self.isonbusroof ) )
		{
			self_is_on_bus_roof = self.isonbusroof;
		}
		if ( !self_on_bus )
		{
			break;
		}
		else
		{
			if ( isDefined( self.is_inert ) && self.is_inert )
			{
				self.ignoreall = 1;
				while ( isDefined( self.is_inert ) && self.is_inert )
				{
					wait 0,1;
				}
				self.ignoreall = 0;
			}
			poi_override = 0;
			if ( self.forcemovementscriptstate )
			{
				monkey = self zombiegetcymbalmonkey();
				if ( isDefined( monkey ) )
				{
					poi_override = 1;
					self.ignoreall = 1;
					self animmode( "normal" );
					self orientmode( "face motion" );
					if ( !level.the_bus maps/mp/zm_transit_bus::busispointinside( monkey.origin ) )
					{
						self zombiewalktoexit();
					}
					else
					{
						self setgoalpos( monkey.origin );
					}
					break;
				}
				else
				{
					self.ignoreall = 0;
					self animmode( "gravity" );
					self orientmode( "face enemy" );
					while ( isDefined( level.the_bus.doorsclosed ) && !level.the_bus.doorsclosed )
					{
						doorstrigger = getentarray( "bus_door_trigger", "targetname" );
						_a1984 = doorstrigger;
						_k1984 = getFirstArrayKey( _a1984 );
						while ( isDefined( _k1984 ) )
						{
							trigger = _a1984[ _k1984 ];
							if ( self istouching( trigger ) )
							{
								self orientmode( "face motion" );
								break;
							}
							else
							{
								_k1984 = getNextArrayKey( _a1984, _k1984 );
							}
						}
					}
					dist_sq = distancesquared( self.favoriteenemy.origin, bus_nodes[ 0 ].origin );
					goal_node = bus_nodes[ 0 ];
					i = 1;
					while ( i < bus_nodes.size )
					{
						bus_sq = distancesquared( self.favoriteenemy.origin, bus_nodes[ i ].origin );
						if ( bus_sq < dist_sq )
						{
							dist_sq = bus_sq;
							goal_node = bus_nodes[ i ];
						}
						i++;
					}
					if ( self_is_on_bus_roof )
					{
						self.goalradius = 16;
					}
					else
					{
						self.goalradius = 32;
					}
					self setgoalnode( goal_node );
				}
			}
			enemy = self.favoriteenemy;
			if ( isDefined( enemy ) )
			{
				enemy_on_bus = enemy.isonbus;
			}
			if ( enemy_on_bus && isDefined( enemy.isonbusroof ) )
			{
				enemy_on_roof = enemy.isonbusroof;
			}
			if ( !enemy_on_bus && !self_is_on_bus_roof )
			{
				monkey = self zombiegetcymbalmonkey();
				if ( !isDefined( monkey ) || !monkey maps/mp/zm_transit_bus::entity_is_on_bus( 1 ) )
				{
					self thread zombieexitbus();
					return;
				}
			}
			else
			{
				if ( enemy_on_bus && self_is_on_bus_roof != enemy_on_roof )
				{
					self thread zombieheighttraverse();
					return;
					break;
				}
				else
				{
					if ( self_is_on_bus_roof && !enemy_on_bus )
					{
						self thread zombiejumpoffroof();
						return;
						break;
					}
					else
					{
						if ( isDefined( poi_override ) && !poi_override )
						{
							disttoenemy = distance2d( self.origin, self.favoriteenemy.origin );
							shouldbeinforcemovement = disttoenemy > 32;
							if ( !shouldbeinforcemovement && self.forcemovementscriptstate )
							{
								self.forcemovementscriptstate = 0;
								self animmode( "normal" );
								self orientmode( "face enemy" );
							}
							if ( shouldbeinforcemovement && !self.forcemovementscriptstate )
							{
								self.forcemovementscriptstate = 1;
								self animmode( "gravity" );
								self orientmode( "face enemy" );
							}
						}
					}
				}
			}
			wait 0,1;
		}
	}
	self animmode( "normal" );
	self orientmode( "face enemy" );
	self.forcemovementscriptstate = 0;
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
}

zombiewalktoexit()
{
	self endon( "death" );
	bus = level.the_bus;
	self.walk_to_exit = 1;
	check_pos = self.origin;
	enemy = self.favoriteenemy;
	if ( isDefined( enemy ) )
	{
		check_pos = enemy.origin;
	}
	if ( !level.the_bus.doorsclosed )
	{
		front_dist = distance2dsquared( check_pos, level.the_bus.front_door.origin );
		back_dist = distance2dsquared( check_pos, level.the_bus.back_door.origin );
		link_one = undefined;
		link_two = undefined;
		door_node = undefined;
		door_dist = undefined;
		if ( front_dist < back_dist )
		{
			door_dist = distance2dsquared( self.origin, level.the_bus.front_door.origin );
			if ( door_dist < 256 )
			{
				door_node = level.the_bus.front_door;
			}
		}
		else
		{
			door_dist = distance2dsquared( self.origin, level.the_bus.back_door.origin );
			if ( door_dist < 256 )
			{
				door_node = level.the_bus.back_door;
			}
		}
		if ( isDefined( door_node ) )
		{
			if ( isDefined( door_node.links ) )
			{
				if ( isDefined( door_node.links[ 0 ] ) )
				{
					link_one = door_node.links[ 0 ];
				}
				if ( isDefined( door_node.links[ 1 ] ) )
				{
					link_two = door_node.links[ 1 ];
				}
			}
			link_goal = undefined;
			if ( isDefined( link_one ) )
			{
				link_goal = link_one;
			}
			if ( isDefined( link_one ) && isDefined( link_two ) )
			{
				link_one_dist = distance2dsquared( check_pos, link_one.origin );
				link_two_dist = distance2dsquared( check_pos, link_two.origin );
				link_goal = link_one;
				if ( link_two_dist < link_one_dist )
				{
					link_goal = link_two;
				}
			}
			if ( isDefined( link_goal ) )
			{
				self setgoalnode( link_goal );
				return;
			}
		}
		door_goal = level.the_bus.front_door;
		if ( back_dist < front_dist )
		{
			door_goal = level.the_bus.back_door;
		}
		self setgoalnode( door_goal );
	}
	else
	{
		dist_f = distancesquared( check_pos, bus.front_door_inside.origin );
		dist_bl = distancesquared( check_pos, bus.exit_back_l.origin );
		dist_br = distancesquared( check_pos, bus.exit_back_r.origin );
		goal_node = bus.front_door_inside;
		if ( dist_bl < dist_br )
		{
			if ( dist_bl < dist_f )
			{
				goal_node = bus.exit_back_l;
			}
		}
		else
		{
			if ( dist_br < dist_f )
			{
				goal_node = bus.exit_back_r;
			}
		}
		self setgoalnode( goal_node );
	}
}

zombiewindowtoroof()
{
	self endon( "death" );
	self animmode( "normal" );
	self orientmode( "face motion" );
	self.ai_state = "zombieWindowToRoof";
	self maps/mp/zombies/_zm_spawner::zombie_history( "zombieWindowToRoof " + getTime() );
	while ( 1 )
	{
		self zombiewalktowindow();
		if ( isDefined( self.exiting_window ) && self.exiting_window )
		{
			break;
		}
		else
		{
			if ( isDefined( self.isonbus ) || !self.isonbus && isDefined( self.ai_state == "find_flesh" ) && self.ai_state == "find_flesh" )
			{
				return;
			}
			wait 0,1;
		}
	}
	while ( isDefined( self.exiting_window ) && self.exiting_window )
	{
		wait 0,1;
	}
}

zombiewalktowindow()
{
	self endon( "death" );
	bus = level.the_bus;
	self.walk_to_exit = 1;
	check_pos = self.origin;
	dist_f = distancesquared( check_pos, bus.front_door_inside.origin );
	dist_bl = distancesquared( check_pos, bus.exit_back_l.origin );
	goal_node = bus.front_door_inside;
	if ( dist_bl < dist_f )
	{
		goal_node = bus.exit_back_l;
	}
	self setgoalnode( goal_node );
}

zombieattackplayerclinging( player )
{
	self endon( "death" );
	level endon( "intermission" );
	self.goalradius = 15;
	enemy_clinging = 1;
	while ( enemy_clinging )
	{
		best_attack_pos = maps/mp/zm_transit_cling::_getbusattackposition( player );
		dist_from_pos2 = distance2dsquared( best_attack_pos, self.origin );
		enemy_origin = player _playergetorigin();
		direction = enemy_origin - self.origin;
		direction_angles = vectorToAngle( direction );
		direction_angles = ( direction_angles[ 0 ], direction_angles[ 1 ], 0 );
		if ( dist_from_pos2 > 400 )
		{
			self orientmode( "face point", best_attack_pos );
			self setgoalpos( best_attack_pos );
		}
		else
		{
			self zombiescriptedattack( player, direction_angles, ::zombiedamageplayercling );
		}
		enemy_clinging = player maps/mp/zm_transit_cling::playerisclingingtobus();
		wait 0,1;
	}
	self.goalradius = 32;
}

zombieattackplayeronturret( player )
{
	self endon( "death" );
	level endon( "intermission" );
	enemy_on_turret = 1;
	while ( enemy_on_turret )
	{
		enemy_origin = self.favoriteenemy _playergetorigin();
		dist_from_turret2 = distance2dsquared( enemy_origin, self.origin );
		direction = enemy_origin - self.origin;
		direction_angles = vectorToAngle( direction );
		direction_angles = ( direction_angles[ 0 ], direction_angles[ 1 ], 0 );
		if ( dist_from_turret2 > 1024 )
		{
			self setgoalpos( enemy_origin, direction_angles );
		}
		else
		{
			self zombiescriptedattack( player, direction_angles, ::zombiedamageplayerturret );
		}
		wait 0,1;
		if ( isDefined( self.favoriteenemy.onbusturret ) && isDefined( self.favoriteenemy.busturret ) )
		{
			enemy_on_turret = self.favoriteenemy.onbusturret;
		}
	}
}

zombiescriptedattack( player, direction_angles, damage_func )
{
	self orientmode( "face angle", direction_angles[ 1 ] );
	zombie_attack_anim = self zombiepickunmovingattackanim();
	self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "attack", self.animname );
	while ( 1 )
	{
		self waittill( "meleeanim", note );
		if ( note == "end" || note == "stop" )
		{
			return;
		}
		else if ( note == "fire" )
		{
			if ( isDefined( damage_func ) )
			{
				[[ damage_func ]]( player );
			}
		}
	}
}

zombiedamageplayerturret( player )
{
	if ( player.onbusturret )
	{
		player dodamage( self.meleedamage, self.origin, self );
	}
}

zombiedamageplayercling( player )
{
	if ( player maps/mp/zm_transit_cling::playerisclingingtobus() )
	{
		player dodamage( self.meleedamage, self.origin, self );
	}
}

_playergetorigin()
{
	if ( isDefined( self.onbusturret ) && isDefined( self.busturret ) && self.onbusturret )
	{
		turret = self.busturret;
		turret_exit = getent( turret.target, "targetname" );
		return turret_exit.origin;
	}
	return self.origin;
}

zombiepickunmovingattackanim()
{
	melee_anim = undefined;
	if ( self.has_legs )
	{
		rand_num = randomint( 4 );
		melee_anim = level._zombie_melee[ self.animname ][ rand_num ];
	}
	else if ( self.a.gib_ref == "no_legs" )
	{
		melee_anim = random( level._zombie_stumpy_melee[ self.animname ] );
	}
	else
	{
		melee_anim = level._zombie_melee_crawl[ self.animname ][ 0 ];
	}
	return melee_anim;
}

zombieexitbus()
{
	self endon( "death" );
	self endon( "stop_zombieExitBus" );
	level endon( "intermission" );
	self animmode( "normal" );
	self orientmode( "face motion" );
	self maps/mp/zombies/_zm_spawner::zombie_history( "zombieExitBus " + getTime() );
	while ( 1 )
	{
		if ( isDefined( self.exiting_window ) && self.exiting_window )
		{
			break;
		}
		else
		{
			if ( isDefined( self.isonbus ) && !self.isonbus )
			{
				self.walk_to_exit = 0;
				return;
			}
			if ( isDefined( self.solo_revive_exit ) && !self.solo_revive_exit )
			{
				monkey = undefined;
				if ( isDefined( self.enemyoverride ) )
				{
					monkey = self.enemyoverride[ 1 ];
				}
				ignore_enemy = 0;
				if ( isDefined( monkey ) && !monkey maps/mp/zm_transit_bus::entity_is_on_bus( 1 ) )
				{
					ignore_enemy = 1;
				}
				if ( !ignore_enemy )
				{
					enemy = self.favoriteenemy;
					if ( isDefined( enemy ) )
					{
						if ( enemy.isonbus )
						{
							self.walk_to_exit = 0;
							self thread zombiemoveonbus();
							return;
						}
					}
				}
			}
			self zombiewalktoexit();
			wait 0,1;
		}
	}
	while ( isDefined( self.exiting_window ) && self.exiting_window )
	{
		wait 0,1;
	}
	self.dont_throw_gib = undefined;
	self orientmode( "face enemy" );
	self.forcemovementscriptstate = 0;
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
}

zombiejumpoffroof()
{
	self endon( "death" );
	self endon( "removed" );
	level endon( "intermission" );
	self animmode( "gravity" );
	self orientmode( "face goal" );
	self maps/mp/zombies/_zm_spawner::zombie_history( "zombieJumpOffRoof " + getTime() );
	while ( 1 )
	{
		enemy = self.favoriteenemy;
		if ( isDefined( enemy ) )
		{
			enemy_on_bus = enemy.isonbus;
		}
		enemiesonbus = level.the_bus.numaliveplayersridingbus > 0;
		if ( isDefined( self.isonbus ) )
		{
			selfisonbus = self.isonbus;
		}
		if ( enemy_on_bus )
		{
			self thread zombiemoveonbus();
			return;
		}
		if ( !selfisonbus )
		{
			return;
		}
		else closest_jump_tag = self zombiegetclosestroofjumptag();
		goal_pos = level.the_bus gettagorigin( closest_jump_tag );
		if ( distance2dsquared( self.origin, goal_pos ) <= 1024 )
		{
			self.attachent = level.the_bus;
			self.attachtag = closest_jump_tag;
			self linkto( self.attachent, self.attachtag, ( 0, -1, 0 ), ( 0, -1, 0 ) );
			wait 0,1;
			self zombieplayattachedanim( "jump_down_127" );
			self setgoalpos( self.origin );
			self unlink();
			return;
		}
		else
		{
			self setgoalpos( goal_pos );
			self orientmode( "face point", goal_pos );
			wait 0,1;
		}
	}
}

zombieheighttraverse()
{
	level endon( "intermission" );
	self endon( "death" );
	self endon( "removed" );
	self endon( "zombieHeightTraverseStop" );
	self animmode( "gravity" );
	self orientmode( "face goal" );
	self.zombie_ladder_stage = 1;
	self.goal_local_offset = level.the_bus.ladder_local_offset;
	self.goal_local_offset = ( self.goal_local_offset[ 0 ], self.goal_local_offset[ 1 ], level.the_bus.floor );
	self.goal_local_angles = vectorScale( ( 0, -1, 0 ), 90 );
	self maps/mp/zombies/_zm_spawner::zombie_history( "zombieHeightTraverse " + getTime() );
	if ( !isDefined( self.isonbusroof ) || !self.isonbusroof )
	{
		bus = level.the_bus;
		hatch_dist = distancesquared( self.origin, bus.hatch_location.origin );
		front_dist = distancesquared( self.origin, bus.front_door_inside.origin );
		back_dist = distancesquared( self.origin, bus.exit_back_l.origin );
		closer_to_hatch = 1;
		if ( front_dist < hatch_dist || back_dist < hatch_dist )
		{
			closer_to_hatch = 0;
		}
		if ( isDefined( level.bus_roof_open ) && level.bus_roof_open && isDefined( level.bus_roof_tearing ) || level.bus_roof_tearing && !closer_to_hatch )
		{
			self zombiewindowtoroof();
		}
		else
		{
			if ( self zombiepathtoladder() )
			{
				self zombieclimbtoroof();
			}
		}
	}
	else
	{
		if ( self zombiepathtoroofopening() )
		{
			self zombiejumpdownhatch();
		}
		else
		{
			enemy = self.favoriteenemy;
			if ( isDefined( enemy ) && isDefined( enemy.isonbus ) && !enemy.isonbus )
			{
				self thread zombiejumpoffroof();
				return;
			}
		}
	}
	if ( isDefined( self.isonbus ) && self.isonbus )
	{
		self thread zombiemoveonbus();
	}
}

zombiepathtoladder()
{
	self.goalradius = 2;
	while ( isDefined( self.enemy ) && self.enemy.isonbusroof )
	{
		if ( !self.isonbus )
		{
			self.goalradius = 32;
			return 0;
		}
		goal_dir = anglesToForward( level.the_bus.angles + self.goal_local_angles );
		goal_pos = level.the_bus.hatch_location.origin;
		if ( distancesquared( self.origin, goal_pos ) <= 1600 )
		{
			self.goalradius = 32;
			self.ladder_pos = goal_pos;
			return 1;
		}
		self setgoalpos( goal_pos );
		self orientmode( "face point", goal_pos );
		wait 0,1;
	}
	self.goalradius = 32;
	return 0;
}

zombiepathtoroofopening()
{
	self.goalradius = 2;
	goal_tag = self zombiegetclosestroofopeningjumptag();
	while ( 1 )
	{
		self zombieonbusenemy();
		enemy = self.favoriteenemy;
		if ( isDefined( enemy ) && isDefined( enemy.isonbusroof ) && enemy.isonbusroof )
		{
			break;
		}
		else
		{
			if ( isDefined( enemy ) && isDefined( enemy.isonbus ) && !enemy.isonbus )
			{
				break;
			}
			else
			{
				if ( !self.isonbus )
				{
					break;
				}
				else
				{
					goal_dir = level.the_bus gettagangles( goal_tag );
					goal_pos = level.the_bus gettagorigin( goal_tag );
					if ( distance2d( self.origin, goal_pos ) <= 32 )
					{
						self.goalradius = 32;
						return 1;
					}
					self setgoalpos( goal_pos );
					self orientmode( "face point", goal_pos );
					wait 0,1;
				}
			}
		}
	}
	self.goalradius = 32;
	return 0;
}

zombiejumpdownhatch()
{
	self endon( "death" );
	self thread zombiejumpdownhatchkilled();
	enemy = self.favoriteenemy;
	if ( isDefined( enemy ) && isDefined( enemy.isonbusroof ) && enemy.isonbusroof )
	{
		self unlink();
		return;
	}
	while ( isDefined( level.bus_roof_tearing ) && level.bus_roof_tearing )
	{
		wait 0,1;
	}
	roof_tag = self zombiegetclosestroofopeningjumptag();
	if ( !level.bus_roof_open )
	{
		self.inert_delay = ::zombieroofteardelay;
		level.bus_roof_open = 1;
		level.bus_roof_tearing = 1;
		self linkto( level.the_bus, roof_tag );
		tag_origin = level.the_bus gettagorigin( roof_tag );
		tag_angles = level.the_bus gettagangles( roof_tag );
		substate = 1;
		if ( roof_tag == "window_roof_2_jnt" )
		{
			substate = 2;
		}
		animstate = "zm_bus_attached";
		self animscripted( tag_origin, tag_angles, animstate, substate );
		maps/mp/animscripts/zm_shared::donotetracks( "bus_attached_anim" );
		self.inert_delay = undefined;
		level.bus_roof_tearing = 0;
		level.the_bus notify( "hatch_ripped_open" );
	}
	self.hatch_jump = 1;
	self.inert_delay = ::zombiehatchjumpdelay;
	hatch_tag = "tag_hatch_attach_ladder";
	self linkto( level.the_bus, hatch_tag );
	tag_origin = level.the_bus gettagorigin( hatch_tag );
	tag_angles = level.the_bus gettagangles( hatch_tag );
	substate = 0;
	if ( roof_tag == "window_roof_1_jnt" )
	{
		substate = 1;
	}
	animstate = maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "zm_bus_hatch_jump_down" );
	self animscripted( tag_origin, tag_angles, animstate, substate );
	maps/mp/animscripts/zm_shared::donotetracks( "bus_hatch_jump_anim" );
	self unlink();
	self.hatch_jump = 0;
	self.inert_delay = undefined;
	self setgoalpos( self.origin );
	level.bus_zombie_on_roof = undefined;
}

zombiehatchjumpdelay()
{
/#
	iprintln( "hatch delay" );
#/
	while ( isDefined( self.hatch_jump ) && self.hatch_jump )
	{
		wait 0,1;
	}
}

zombieroofteardelay()
{
	self endon( "death" );
	self notify( "zombieHeightTraverseStop" );
	self unlink();
	level.bus_roof_open = 0;
	level.bus_roof_tearing = 0;
	self.inert_wakeup_override = ::zombierooftearwakeup;
}

zombierooftearwakeup()
{
	self endon( "death" );
	self.inert_wakeup_override = undefined;
	self thread zombieheighttraverse();
}

zombiejumpdownhatchkilled()
{
	while ( isDefined( level.bus_roof_tearing ) && level.bus_roof_tearing )
	{
		if ( !isDefined( self ) )
		{
			level.bus_roof_tearing = 0;
			return;
		}
		else
		{
			wait 0,1;
		}
	}
}

zombieclimbtoroof()
{
	self endon( "death" );
	hatch_tag = "tag_hatch_attach_ladder";
	self linkto( level.the_bus, hatch_tag );
	tag_origin = level.the_bus gettagorigin( hatch_tag );
	tag_angles = level.the_bus gettagangles( hatch_tag );
	hatch_vec = vectornormalize( anglesToForward( tag_angles ) );
	player = self.favoriteenemy;
	player_vec = vectornormalize( player.origin - tag_origin );
	substate = 0;
	dot = vectordot( hatch_vec, player_vec );
	if ( dot > 0 )
	{
		substate = 1;
	}
	animstate = maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "zm_bus_hatch_jump_up" );
	self animscripted( tag_origin, tag_angles, animstate, substate );
	maps/mp/animscripts/zm_shared::donotetracks( "bus_hatch_jump_anim" );
	self unlink();
	self setgoalpos( self.origin );
}

zombiegetclosestroofjumptag()
{
	root = "tag_roof_jump_off";
	best = root + "1";
	best_pos = level.the_bus gettagorigin( best );
	best_pos_dist2 = distance2dsquared( self.origin, best_pos );
	i = 1;
	while ( i <= 4 )
	{
		next_pos = level.the_bus gettagorigin( root + i );
		next_pos_dist2 = distance2dsquared( self.origin, next_pos );
		if ( next_pos_dist2 < best_pos_dist2 )
		{
			best = root + i;
			best_pos = next_pos;
			best_pos_dist2 = next_pos_dist2;
		}
		i++;
	}
	return best;
}

zombiegetclosestroofopeningjumptag()
{
	pos1 = level.the_bus gettagorigin( "window_roof_1_jnt" );
	pos2 = level.the_bus gettagorigin( "window_roof_2_jnt" );
	closest = "window_roof_1_jnt";
	pos1_dist2 = distance2dsquared( self.origin, pos1 );
	pos2_dist2 = distance2dsquared( self.origin, pos2 );
	if ( pos2_dist2 < pos1_dist2 )
	{
		closest = "window_roof_2_jnt";
	}
	return closest;
}

zombiegetclosestdoortag()
{
	pos1 = level.the_bus gettagorigin( "door_rear_jnt" );
	pos2 = level.the_bus gettagorigin( "door_front_jnt" );
	closest = "door_rear_jnt";
	pos1_dist2 = distance2dsquared( self.origin, pos1 );
	pos2_dist2 = distance2dsquared( self.origin, pos2 );
	if ( pos2_dist2 < pos1_dist2 )
	{
		closest = "door_front_jnt";
	}
	return closest;
}

zombiekeepattackingthroughwindow( left_or_right )
{
	while ( self zombietryattackthroughwindow( 0, left_or_right ) )
	{
		tag_origin = self.attachent gettagorigin( self.attachtag );
		tag_angles = self.attachent gettagangles( self.attachtag );
		asd_name = "zm_zbarrier_window_idle";
		side = _getsideofbusopeningison( self.attachtag );
		if ( side == "front" )
		{
			asd_name = "zm_zbarrier_front_window_idle";
		}
		self animscripted( tag_origin, tag_angles, asd_name, "window_idle" + left_or_right );
		self zombieanimnotetrackthink( "bus_window_idle" );
	}
}

zombietryattackthroughwindow( is_random, postfix )
{
	attackplayers = self zombiegetplayerstoattack();
	if ( attackplayers.size == 0 )
	{
		return 0;
	}
	should_attack = 1;
	if ( is_random )
	{
		rand = randomint( 100 );
		should_attack = rand < 80;
	}
	if ( should_attack )
	{
		self thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "attack", self.animname );
		tag_origin = self.attachent gettagorigin( self.attachtag );
		tag_angles = self.attachent gettagangles( self.attachtag );
		asd_name = "zm_zbarrier_window_attack";
		side = _getsideofbusopeningison( self.attachtag );
		if ( isDefined( side ) && side == "front" )
		{
			asd_name = "zm_zbarrier_front_window_attack";
		}
		self animscripted( tag_origin, tag_angles, asd_name, "window_attack" + postfix );
		self zombieanimnotetrackthink( "bus_window_attack" );
		return 1;
	}
	return 0;
}

zombiegetplayerstoattack()
{
	playerstoattack = [];
	players = get_players();
	attackrange = 72;
	attackrange *= attackrange;
	attackheight = 37;
	attackheight *= attackheight;
	i = 0;
	while ( i < players.size )
	{
		if ( isDefined( self.opening ) && isDefined( self.opening.rebuildtrigger ) )
		{
			if ( players[ i ] istouching( self.opening.rebuildtrigger ) )
			{
				playerstoattack[ playerstoattack.size ] = players[ i ];
			}
			i++;
			continue;
		}
		else
		{
			xydist = distance2dsquared( self.origin, players[ i ].origin );
			zdist = self.origin[ 2 ] - players[ i ].origin[ 2 ];
			zdist2 = zdist * zdist;
			if ( xydist <= attackrange && zdist2 <= attackheight )
			{
				playerstoattack[ playerstoattack.size ] = players[ i ];
			}
		}
		i++;
	}
	return playerstoattack;
}
