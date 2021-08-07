#include maps/mp/zombies/_zm_ai_sloth;
#include maps/mp/zm_buried;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

should_ignore_candybooze( player )
{
	if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_underground_courthouse" ) || player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_underground_courthouse2" ) )
	{
		if ( !maps/mp/zm_buried::is_courthouse_open() )
		{
			return 1;
		}
	}
	if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_tunnels_north2" ) )
	{
		if ( !maps/mp/zm_buried::is_courthouse_open() )
		{
			return 1;
		}
	}
	if ( !player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_tunnels_center" ) || player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_tunnels_north" ) && player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_tunnels_south" ) )
	{
		if ( !maps/mp/zm_buried::is_tunnel_open() )
		{
			return 1;
		}
	}
	if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_start_lower" ) )
	{
		return 1;
	}
	if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_underground_bar" ) )
	{
		if ( !maps/mp/zombies/_zm_ai_sloth::is_bar_open() )
		{
			return 1;
		}
	}
	return 0;
}

watch_crash_pos()
{
	dist_crash = 4096;
	level.crash_pos = [];
	level.crash_pos[ level.crash_pos.size ] = ( 3452, 1012, 56 );
	level.crash_pos[ level.crash_pos.size ] = ( 3452, 1092, 56 );
	level.crash_pos[ level.crash_pos.size ] = ( 3452, 1056, 56 );
	while ( 1 )
	{
		while ( !isDefined( self.state ) || self.state != "berserk" )
		{
			wait 0,1;
		}
		_a82 = level.crash_pos;
		_k82 = getFirstArrayKey( _a82 );
		while ( isDefined( _k82 ) )
		{
			pos = _a82[ _k82 ];
			dist = distancesquared( self.origin, pos );
			if ( dist < dist_crash )
			{
				self.anchor.origin = self.origin;
				self.anchor.angles = self.angles;
				self linkto( self.anchor );
				self setclientfield( "sloth_berserk", 0 );
				self sloth_set_state( "crash", 0 );
				wait 0,25;
				self unlink();
			}
			_k82 = getNextArrayKey( _a82, _k82 );
		}
		wait 0,05;
	}
}

sloth_is_pain()
{
	if ( is_true( self.is_pain ) )
	{
		anim_state = self getanimstatefromasd();
		if ( anim_state == "zm_pain" || anim_state == "zm_pain_no_restart" )
		{
			return 1;
		}
		else
		{
			self.reset_asd = undefined;
			self animmode( "normal" );
			self.is_pain = 0;
			self.damage_accumulating = 0;
			self notify( "stop_accumulation" );
/#
			sloth_print( "pain was interrupted" );
#/
		}
	}
	return 0;
}

sloth_is_traversing()
{
	if ( is_true( self.is_traversing ) )
	{
		anim_state = self getanimstatefromasd();
		if ( anim_state != "zm_traverse" && anim_state != "zm_traverse_no_restart" && anim_state != "zm_traverse_barrier" && anim_state != "zm_traverse_barrier_no_restart" && anim_state != "zm_sling_equipment" && anim_state != "zm_unsling_equipment" && anim_state != "zm_sling_magicbox" && anim_state != "zm_unsling_magicbox" && anim_state != "zm_sloth_crawlerhold_sling" && anim_state != "zm_sloth_crawlerhold_unsling" || anim_state == "zm_sloth_crawlerhold_sling_hunched" && anim_state == "zm_sloth_crawlerhold_unsling_hunched" )
		{
			return 1;
		}
		else
		{
			self.is_traversing = 0;
/#
			sloth_print( "traverse was interrupted" );
#/
		}
	}
	return 0;
}

sloth_face_object( facee, type, data, dot_limit )
{
	if ( type == "angle" )
	{
		self orientmode( "face angle", data );
	}
	else
	{
		if ( type == "point" )
		{
			self orientmode( "face point", data );
		}
	}
	time_started = getTime();
	while ( 1 )
	{
		if ( type == "angle" )
		{
			delta = abs( self.angles[ 1 ] - data );
			if ( delta <= 15 )
			{
				break;
			}
			else }
		else if ( isDefined( dot_limit ) )
		{
			if ( self is_facing( facee, dot_limit ) )
			{
				break;
			}
			else }
		else if ( self is_facing( facee ) )
		{
			break;
		}
		else if ( ( getTime() - time_started ) > 1000 )
		{
/#
			sloth_print( "face took too long" );
#/
			break;
		}
		else
		{
			wait 0,1;
		}
	}
/#
	time_elapsed = getTime() - time_started;
	sloth_print( "time to face: " + time_elapsed );
#/
}

sloth_print( str )
{
/#
	if ( getDvarInt( #"B6252E7C" ) )
	{
		iprintln( "sloth: " + str );
		if ( isDefined( self.debug_msg ) )
		{
			self.debug_msg[ self.debug_msg.size ] = str;
			if ( self.debug_msg.size > 64 )
			{
				self.debug_msg = [];
			}
			return;
		}
		else
		{
			self.debug_msg = [];
			self.debug_msg[ self.debug_msg.size ] = str;
#/
		}
	}
}

sloth_debug_context( item, dist )
{
/#
	if ( is_true( self.context_debug ) )
	{
		debugstar( item.origin, 100, ( 1, 1, 1 ) );
		circle( item.origin, dist, ( 1, 1, 1 ), 0, 1, 100 );
#/
	}
}
