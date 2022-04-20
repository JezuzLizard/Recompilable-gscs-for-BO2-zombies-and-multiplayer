
anim_get_dvar_int( dvar, def )
{
	return int( anim_get_dvar( dvar, def ) );
}

anim_get_dvar( dvar, def )
{
	if ( getDvar( dvar ) != "" )
	{
		return getDvarFloat( dvar );
	}
	else
	{
		setdvar( dvar, def );
		return def;
	}
}

set_orient_mode( mode, val1 )
{
/#
	if ( level.dog_debug_orient == self getentnum() )
	{
		if ( isDefined( val1 ) )
		{
			println( "DOG:  Setting orient mode: " + mode + " " + val1 + " " + getTime() );
		}
		else
		{
			println( "DOG:  Setting orient mode: " + mode + " " + getTime() );
#/
		}
	}
	if ( isDefined( val1 ) )
	{
		self orientmode( mode, val1 );
	}
	else
	{
		self orientmode( mode );
	}
}

debug_anim_print( text )
{
/#
	if ( level.dog_debug_anims )
	{
		println( ( text + " " ) + getTime() );
	}
	if ( level.dog_debug_anims_ent == self getentnum() )
	{
		println( ( text + " " ) + getTime() );
#/
	}
}

debug_turn_print( text, line )
{
/#
	if ( level.dog_debug_turns == self getentnum() )
	{
		duration = 200;
		currentyawcolor = ( 1, 0, 1 );
		lookaheadyawcolor = ( 1, 0, 1 );
		desiredyawcolor = ( 1, 0, 1 );
		currentyaw = angleClamp180( self.angles[ 1 ] );
		desiredyaw = angleClamp180( self.desiredangle );
		lookaheaddir = self.lookaheaddir;
		lookaheadangles = vectorToAngle( lookaheaddir );
		lookaheadyaw = angleClamp180( lookaheadangles[ 1 ] );
		println( ( text + " " ) + getTime() + " cur: " + currentyaw + " look: " + lookaheadyaw + " desired: " + desiredyaw );
#/
	}
}

debug_allow_movement()
{
/#
	return anim_get_dvar_int( "debug_dog_allow_movement", "1" );
#/
	return 1;
}

debug_allow_combat()
{
/#
	return anim_get_dvar_int( "debug_dog_allow_combat", "1" );
#/
	return 1;
}

current_yaw_line_debug( duration )
{
/#
	currentyawcolor = [];
	currentyawcolor[ 0 ] = ( 1, 0, 1 );
	currentyawcolor[ 1 ] = ( 1, 0, 1 );
	current_color_index = 0;
	start_time = getTime();
	if ( !isDefined( level.lastdebugheight ) )
	{
		level.lastdebugheight = 15;
	}
	while ( ( getTime() - start_time ) < 1000 )
	{
		pos1 = ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] + level.lastdebugheight );
		pos2 = pos1 + vectorScale( anglesToForward( self.angles ), ( current_color_index + 1 ) * 10 );
		line( pos1, pos2, currentyawcolor[ current_color_index ], 0,3, 1, duration );
		current_color_index = ( current_color_index + 1 ) % currentyawcolor.size;
		wait 0,05;
	}
	if ( level.lastdebugheight == 15 )
	{
		level.lastdebugheight = 30;
	}
	else
	{
		level.lastdebugheight = 15;
#/
	}
}

getanimdirection( damageyaw )
{
	if ( damageyaw > 135 || damageyaw <= -135 )
	{
		return "front";
	}
	else
	{
		if ( damageyaw > 45 && damageyaw <= 135 )
		{
			return "right";
		}
		else
		{
			if ( damageyaw > -45 && damageyaw <= 45 )
			{
				return "back";
			}
			else
			{
				return "left";
			}
		}
	}
	return "front";
}

setfootstepeffect( name, fx )
{
/#
	assert( isDefined( name ), "Need to define the footstep surface type." );
#/
/#
	assert( isDefined( fx ), "Need to define the mud footstep effect." );
#/
	if ( !isDefined( anim.optionalstepeffects ) )
	{
		anim.optionalstepeffects = [];
	}
	anim.optionalstepeffects[ anim.optionalstepeffects.size ] = name;
	level._effect[ "step_" + name ] = fx;
}
