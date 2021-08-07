
init_session_mode_flags()
{
	level.gamemode_public_match = 0;
	level.gamemode_private_match = 1;
	level.gamemode_local_splitscreen = 2;
	level.gamemode_wager_match = 3;
	level.gamemode_theater = 5;
	level.gamemode_league_match = 6;
	level.gamemode_rts = 7;
	level.language = getDvar( "language" );
}

empty( a, b, c, d, e )
{
}

add_to_array( array, item, allow_dupes )
{
	if ( !isDefined( item ) )
	{
		return array;
	}
	if ( !isDefined( allow_dupes ) )
	{
		allow_dupes = 1;
	}
	if ( !isDefined( array ) )
	{
		array[ 0 ] = item;
	}
	else
	{
		if ( allow_dupes || !isinarray( array, item ) )
		{
			array[ array.size ] = item;
		}
	}
	return array;
}

array_copy( array )
{
	a_copy = [];
	_a92 = array;
	_k92 = getFirstArrayKey( _a92 );
	while ( isDefined( _k92 ) )
	{
		elem = _a92[ _k92 ];
		a_copy[ a_copy.size ] = elem;
		_k92 = getNextArrayKey( _a92, _k92 );
	}
	return a_copy;
}

array_delete( array, is_struct )
{
	_a109 = array;
	_k109 = getFirstArrayKey( _a109 );
	while ( isDefined( _k109 ) )
	{
		ent = _a109[ _k109 ];
		if ( isDefined( is_struct ) && is_struct )
		{
			ent structdelete();
			ent = undefined;
		}
		else
		{
			if ( isDefined( ent ) )
			{
				ent delete();
			}
		}
		_k109 = getNextArrayKey( _a109, _k109 );
	}
}

array_randomize( array )
{
	i = 0;
	while ( i < array.size )
	{
		j = randomint( array.size );
		temp = array[ i ];
		array[ i ] = array[ j ];
		array[ j ] = temp;
		i++;
	}
	return array;
}

array_reverse( array )
{
	array2 = [];
	i = array.size - 1;
	while ( i >= 0 )
	{
		array2[ array2.size ] = array[ i ];
		i--;

	}
	return array2;
}

array_exclude( array, arrayexclude )
{
	newarray = array;
	if ( isarray( arrayexclude ) )
	{
		i = 0;
		while ( i < arrayexclude.size )
		{
			arrayremovevalue( newarray, arrayexclude[ i ] );
			i++;
		}
	}
	else arrayremovevalue( newarray, arrayexclude );
	return newarray;
}

array_notify( ents, notifier )
{
	i = 0;
	while ( i < ents.size )
	{
		ents[ i ] notify( notifier );
		i++;
	}
}

array_wait( array, msg, timeout )
{
	keys = getarraykeys( array );
	structs = [];
	i = 0;
	while ( i < keys.size )
	{
		key = keys[ i ];
		structs[ key ] = spawnstruct();
		structs[ key ]._array_wait = 1;
		structs[ key ] thread array_waitlogic1( array[ key ], msg, timeout );
		i++;
	}
	i = 0;
	while ( i < keys.size )
	{
		key = keys[ i ];
		if ( isDefined( array[ key ] ) && structs[ key ]._array_wait )
		{
			structs[ key ] waittill( "_array_wait" );
		}
		i++;
	}
}

array_wait_any( array, msg, timeout )
{
	if ( array.size == 0 )
	{
		return undefined;
	}
	keys = getarraykeys( array );
	structs = [];
	internal_msg = msg + "array_wait";
	i = 0;
	while ( i < keys.size )
	{
		key = keys[ i ];
		structs[ key ] = spawnstruct();
		structs[ key ]._array_wait = 1;
		structs[ key ] thread array_waitlogic3( array[ key ], msg, internal_msg, timeout );
		i++;
	}
	level waittill( internal_msg, ent );
	return ent;
}

array_waitlogic1( ent, msg, timeout )
{
	self array_waitlogic2( ent, msg, timeout );
	self._array_wait = 0;
	self notify( "_array_wait" );
}

array_waitlogic2( ent, msg, timeout )
{
	ent endon( msg );
	ent endon( "death" );
	if ( isDefined( timeout ) )
	{
		wait timeout;
	}
	else
	{
		ent waittill( msg );
	}
}

array_waitlogic3( ent, msg, internal_msg, timeout )
{
	if ( msg != "death" )
	{
		ent endon( "death" );
	}
	level endon( internal_msg );
	self array_waitlogic2( ent, msg, timeout );
	level notify( internal_msg );
}

array_check_for_dupes( array, single )
{
	i = 0;
	while ( i < array.size )
	{
		if ( array[ i ] == single )
		{
			return 0;
		}
		i++;
	}
	return 1;
}

array_swap( array, index1, index2 )
{
/#
	assert( index1 < array.size, "index1 to swap out of range" );
#/
/#
	assert( index2 < array.size, "index2 to swap out of range" );
#/
	temp = array[ index1 ];
	array[ index1 ] = array[ index2 ];
	array[ index2 ] = temp;
	return array;
}

array_average( array )
{
/#
	assert( isarray( array ) );
#/
/#
	assert( array.size > 0 );
#/
	total = 0;
	i = 0;
	while ( i < array.size )
	{
		total += array[ i ];
		i++;
	}
	return total / array.size;
}

array_std_deviation( array, mean )
{
/#
	assert( isarray( array ) );
#/
/#
	assert( array.size > 0 );
#/
	tmp = [];
	i = 0;
	while ( i < array.size )
	{
		tmp[ i ] = ( array[ i ] - mean ) * ( array[ i ] - mean );
		i++;
	}
	total = 0;
	i = 0;
	while ( i < tmp.size )
	{
		total += tmp[ i ];
		i++;
	}
	return sqrt( total / array.size );
}

random_normal_distribution( mean, std_deviation, lower_bound, upper_bound )
{
	x1 = 0;
	x2 = 0;
	w = 1;
	y1 = 0;
	while ( w >= 1 )
	{
		x1 = ( 2 * randomfloatrange( 0, 1 ) ) - 1;
		x2 = ( 2 * randomfloatrange( 0, 1 ) ) - 1;
		w = ( x1 * x1 ) + ( x2 * x2 );
	}
	w = sqrt( ( -2 * log( w ) ) / w );
	y1 = x1 * w;
	number = mean + ( y1 * std_deviation );
	if ( isDefined( lower_bound ) && number < lower_bound )
	{
		number = lower_bound;
	}
	if ( isDefined( upper_bound ) && number > upper_bound )
	{
		number = upper_bound;
	}
	return number;
}

random( array )
{
	keys = getarraykeys( array );
	return array[ keys[ randomint( keys.size ) ] ];
}

get_players( str_team )
{
	if ( isDefined( str_team ) )
	{
		return getplayers( str_team );
	}
	else
	{
		return getplayers();
	}
}

is_prefix( msg, prefix )
{
	if ( prefix.size > msg.size )
	{
		return 0;
	}
	i = 0;
	while ( i < prefix.size )
	{
		if ( msg[ i ] != prefix[ i ] )
		{
			return 0;
		}
		i++;
	}
	return 1;
}

is_suffix( msg, suffix )
{
	if ( suffix.size > msg.size )
	{
		return 0;
	}
	i = 0;
	while ( i < suffix.size )
	{
		if ( msg[ ( msg.size - 1 ) - i ] != suffix[ ( suffix.size - 1 ) - i ] )
		{
			return 0;
		}
		i++;
	}
	return 1;
}

vector_compare( vec1, vec2 )
{
	if ( abs( vec1[ 0 ] - vec2[ 0 ] ) < 0,001 && abs( vec1[ 1 ] - vec2[ 1 ] ) < 0,001 )
	{
		return abs( vec1[ 2 ] - vec2[ 2 ] ) < 0,001;
	}
}

draw_debug_line( start, end, timer )
{
/#
	i = 0;
	while ( i < ( timer * 20 ) )
	{
		line( start, end, ( 1, 1, 0,5 ) );
		wait 0,05;
		i++;
#/
	}
}

waittillend( msg )
{
	self waittillmatch( msg );
	return "end";
}

random_vector( max_length )
{
	return ( randomfloatrange( -1 * max_length, max_length ), randomfloatrange( -1 * max_length, max_length ), randomfloatrange( -1 * max_length, max_length ) );
}

angle_dif( oldangle, newangle )
{
	outvalue = ( oldangle - newangle ) % 360;
	if ( outvalue < 0 )
	{
		outvalue += 360;
	}
	if ( outvalue > 180 )
	{
		outvalue = ( outvalue - 360 ) * -1;
	}
	return outvalue;
}

sign( x )
{
	if ( x >= 0 )
	{
		return 1;
	}
	return -1;
}

track( spot_to_track )
{
	if ( isDefined( self.current_target ) )
	{
		if ( spot_to_track == self.current_target )
		{
			return;
		}
	}
	self.current_target = spot_to_track;
}

clear_exception( type )
{
/#
	assert( isDefined( self.exception[ type ] ) );
#/
	self.exception[ type ] = anim.defaultexception;
}

set_exception( type, func )
{
/#
	assert( isDefined( self.exception[ type ] ) );
#/
	self.exception[ type ] = func;
}

set_all_exceptions( exceptionfunc )
{
	keys = getarraykeys( self.exception );
	i = 0;
	while ( i < keys.size )
	{
		self.exception[ keys[ i ] ] = exceptionfunc;
		i++;
	}
}

cointoss()
{
	return randomint( 100 ) >= 50;
}

waittill_string( msg, ent )
{
	if ( msg != "death" )
	{
		self endon( "death" );
	}
	ent endon( "die" );
	self waittill( msg );
	ent notify( "returned" );
}

waittill_multiple( string1, string2, string3, string4, string5 )
{
	self endon( "death" );
	ent = spawnstruct();
	ent.threads = 0;
	if ( isDefined( string1 ) )
	{
		self thread waittill_string( string1, ent );
		ent.threads++;
	}
	if ( isDefined( string2 ) )
	{
		self thread waittill_string( string2, ent );
		ent.threads++;
	}
	if ( isDefined( string3 ) )
	{
		self thread waittill_string( string3, ent );
		ent.threads++;
	}
	if ( isDefined( string4 ) )
	{
		self thread waittill_string( string4, ent );
		ent.threads++;
	}
	if ( isDefined( string5 ) )
	{
		self thread waittill_string( string5, ent );
		ent.threads++;
	}
	while ( ent.threads )
	{
		ent waittill( "returned" );
		ent.threads--;

	}
	ent notify( "die" );
}

waittill_multiple_ents( ent1, string1, ent2, string2, ent3, string3, ent4, string4 )
{
	self endon( "death" );
	ent = spawnstruct();
	ent.threads = 0;
	if ( isDefined( ent1 ) )
	{
/#
		assert( isDefined( string1 ) );
#/
		ent1 thread waittill_string( string1, ent );
		ent.threads++;
	}
	if ( isDefined( ent2 ) )
	{
/#
		assert( isDefined( string2 ) );
#/
		ent2 thread waittill_string( string2, ent );
		ent.threads++;
	}
	if ( isDefined( ent3 ) )
	{
/#
		assert( isDefined( string3 ) );
#/
		ent3 thread waittill_string( string3, ent );
		ent.threads++;
	}
	if ( isDefined( ent4 ) )
	{
/#
		assert( isDefined( string4 ) );
#/
		ent4 thread waittill_string( string4, ent );
		ent.threads++;
	}
	while ( ent.threads )
	{
		ent waittill( "returned" );
		ent.threads--;

	}
	ent notify( "die" );
}

waittill_any_return( string1, string2, string3, string4, string5, string6, string7 )
{
	if ( isDefined( string1 ) && string1 != "death" && isDefined( string2 ) && string2 != "death" && isDefined( string3 ) && string3 != "death" && isDefined( string4 ) && string4 != "death" && isDefined( string5 ) && string5 != "death" && isDefined( string6 ) && string6 != "death" || !isDefined( string7 ) && string7 != "death" )
	{
		self endon( "death" );
	}
	ent = spawnstruct();
	if ( isDefined( string1 ) )
	{
		self thread waittill_string( string1, ent );
	}
	if ( isDefined( string2 ) )
	{
		self thread waittill_string( string2, ent );
	}
	if ( isDefined( string3 ) )
	{
		self thread waittill_string( string3, ent );
	}
	if ( isDefined( string4 ) )
	{
		self thread waittill_string( string4, ent );
	}
	if ( isDefined( string5 ) )
	{
		self thread waittill_string( string5, ent );
	}
	if ( isDefined( string6 ) )
	{
		self thread waittill_string( string6, ent );
	}
	if ( isDefined( string7 ) )
	{
		self thread waittill_string( string7, ent );
	}
	ent waittill( "returned", msg );
	ent notify( "die" );
	return msg;
}

waittill_any_array_return( a_notifies )
{
	if ( isinarray( a_notifies, "death" ) )
	{
		self endon( "death" );
	}
	s_tracker = spawnstruct();
	_a825 = a_notifies;
	_k825 = getFirstArrayKey( _a825 );
	while ( isDefined( _k825 ) )
	{
		str_notify = _a825[ _k825 ];
		if ( isDefined( str_notify ) )
		{
			self thread waittill_string( str_notify, s_tracker );
		}
		_k825 = getNextArrayKey( _a825, _k825 );
	}
	s_tracker waittill( "returned", msg );
	s_tracker notify( "die" );
	return msg;
}

waittill_any( str_notify1, str_notify2, str_notify3, str_notify4, str_notify5 )
{
/#
	assert( isDefined( str_notify1 ) );
#/
	waittill_any_array( array( str_notify1, str_notify2, str_notify3, str_notify4, str_notify5 ) );
}

waittill_any_array( a_notifies )
{
/#
	assert( isDefined( a_notifies[ 0 ] ), "At least the first element has to be defined for waittill_any_array." );
#/
	i = 1;
	while ( i < a_notifies.size )
	{
		if ( isDefined( a_notifies[ i ] ) )
		{
			self endon( a_notifies[ i ] );
		}
		i++;
	}
	self waittill( a_notifies[ 0 ] );
}

waittill_any_timeout( n_timeout, string1, string2, string3, string4, string5 )
{
	if ( isDefined( string1 ) && string1 != "death" && isDefined( string2 ) && string2 != "death" && isDefined( string3 ) && string3 != "death" && isDefined( string4 ) && string4 != "death" || !isDefined( string5 ) && string5 != "death" )
	{
		self endon( "death" );
	}
	ent = spawnstruct();
	if ( isDefined( string1 ) )
	{
		self thread waittill_string( string1, ent );
	}
	if ( isDefined( string2 ) )
	{
		self thread waittill_string( string2, ent );
	}
	if ( isDefined( string3 ) )
	{
		self thread waittill_string( string3, ent );
	}
	if ( isDefined( string4 ) )
	{
		self thread waittill_string( string4, ent );
	}
	if ( isDefined( string5 ) )
	{
		self thread waittill_string( string5, ent );
	}
	ent thread _timeout( n_timeout );
	ent waittill( "returned", msg );
	ent notify( "die" );
	return msg;
}

_timeout( delay )
{
	self endon( "die" );
	wait delay;
	self notify( "returned" );
}

waittill_any_ents( ent1, string1, ent2, string2, ent3, string3, ent4, string4, ent5, string5, ent6, string6, ent7, string7 )
{
/#
	assert( isDefined( ent1 ) );
#/
/#
	assert( isDefined( string1 ) );
#/
	if ( isDefined( ent2 ) && isDefined( string2 ) )
	{
		ent2 endon( string2 );
	}
	if ( isDefined( ent3 ) && isDefined( string3 ) )
	{
		ent3 endon( string3 );
	}
	if ( isDefined( ent4 ) && isDefined( string4 ) )
	{
		ent4 endon( string4 );
	}
	if ( isDefined( ent5 ) && isDefined( string5 ) )
	{
		ent5 endon( string5 );
	}
	if ( isDefined( ent6 ) && isDefined( string6 ) )
	{
		ent6 endon( string6 );
	}
	if ( isDefined( ent7 ) && isDefined( string7 ) )
	{
		ent7 endon( string7 );
	}
	ent1 waittill( string1 );
}

waittill_any_ents_two( ent1, string1, ent2, string2 )
{
/#
	assert( isDefined( ent1 ) );
#/
/#
	assert( isDefined( string1 ) );
#/
	if ( isDefined( ent2 ) && isDefined( string2 ) )
	{
		ent2 endon( string2 );
	}
	ent1 waittill( string1 );
}

waittill_flag_exists( msg )
{
	while ( !flag_exists( msg ) )
	{
		waittillframeend;
		if ( flag_exists( msg ) )
		{
			return;
		}
		else
		{
			wait 0,05;
		}
	}
}

isflashed()
{
	if ( !isDefined( self.flashendtime ) )
	{
		return 0;
	}
	return getTime() < self.flashendtime;
}

isstunned()
{
	if ( !isDefined( self.flashendtime ) )
	{
		return 0;
	}
	return getTime() < self.flashendtime;
}

flag( flagname )
{
/#
	assert( isDefined( flagname ), "Tried to check flag but the flag was not defined." );
#/
/#
	assert( isDefined( level.flag[ flagname ] ), "Tried to check flag " + flagname + " but the flag was not initialized." );
#/
	if ( !level.flag[ flagname ] )
	{
		return 0;
	}
	return 1;
}

flag_delete( flagname )
{
	if ( isDefined( level.flag[ flagname ] ) )
	{
	}
	else
	{
/#
		println( "flag_delete() called on flag that does not exist: " + flagname );
#/
	}
}

flag_init( flagname, val, b_is_trigger )
{
	if ( !isDefined( b_is_trigger ) )
	{
		b_is_trigger = 0;
	}
	if ( !isDefined( level.flag ) )
	{
		level.flag = [];
	}
	if ( !isDefined( level.sp_stat_tracking_func ) )
	{
		level.sp_stat_tracking_func = ::empty;
	}
	if ( !isDefined( level.first_frame ) )
	{
/#
		assert( !isDefined( level.flag[ flagname ] ), "Attempt to reinitialize existing flag: " + flagname );
#/
	}
	if ( isDefined( val ) && val )
	{
		level.flag[ flagname ] = 1;
	}
	else
	{
		level.flag[ flagname ] = 0;
	}
	if ( b_is_trigger )
	{
		if ( !isDefined( level.trigger_flags ) )
		{
			init_trigger_flags();
			level.trigger_flags[ flagname ] = [];
		}
		else
		{
			if ( !isDefined( level.trigger_flags[ flagname ] ) )
			{
				level.trigger_flags[ flagname ] = [];
			}
		}
	}
	if ( is_suffix( flagname, "aa_" ) )
	{
		thread [[ level.sp_stat_tracking_func ]]( flagname );
	}
}

flag_set( flagname )
{
/#
	assert( isDefined( level.flag[ flagname ] ), "Attempt to set a flag before calling flag_init: " + flagname );
#/
	level.flag[ flagname ] = 1;
	level notify( flagname );
	set_trigger_flag_permissions( flagname );
}

flag_set_for_time( n_time, str_flag )
{
	level notify( "set_flag_for_time:" + str_flag );
	flag_set( str_flag );
	level endon( "set_flag_for_time:" + str_flag );
	wait n_time;
	flag_clear( str_flag );
}

flag_toggle( flagname )
{
	if ( flag( flagname ) )
	{
		flag_clear( flagname );
	}
	else
	{
		flag_set( flagname );
	}
}

flag_wait( flagname )
{
	level waittill_flag_exists( flagname );
	while ( !level.flag[ flagname ] )
	{
		level waittill( flagname );
	}
}

flag_wait_any( str_flag1, str_flag2, str_flag3, str_flag4, str_flag5 )
{
	level flag_wait_any_array( array( str_flag1, str_flag2, str_flag3, str_flag4, str_flag5 ) );
}

flag_wait_any_array( a_flags )
{
	while ( 1 )
	{
		i = 0;
		while ( i < a_flags.size )
		{
			if ( flag( a_flags[ i ] ) )
			{
				return a_flags[ i ];
			}
			i++;
		}
		level waittill_any_array( a_flags );
	}
}

flag_clear( flagname )
{
/#
	assert( isDefined( level.flag[ flagname ] ), "Attempt to set a flag before calling flag_init: " + flagname );
#/
	if ( level.flag[ flagname ] )
	{
		level.flag[ flagname ] = 0;
		level notify( flagname );
		set_trigger_flag_permissions( flagname );
	}
}

flag_waitopen( flagname )
{
	while ( level.flag[ flagname ] )
	{
		level waittill( flagname );
	}
}

flag_waitopen_array( a_flags )
{
	_a1324 = a_flags;
	_k1324 = getFirstArrayKey( _a1324 );
	while ( isDefined( _k1324 ) )
	{
		str_flag = _a1324[ _k1324 ];
		if ( flag( str_flag ) )
		{
			flag_waitopen( str_flag );
			break;
		}
		_k1324 = getNextArrayKey( _a1324, _k1324 );
	}
}

flag_exists( flagname )
{
	if ( self == level )
	{
		if ( !isDefined( level.flag ) )
		{
			return 0;
		}
		if ( isDefined( level.flag[ flagname ] ) )
		{
			return 1;
		}
	}
	else
	{
		if ( !isDefined( self.ent_flag ) )
		{
			return 0;
		}
		if ( isDefined( self.ent_flag[ flagname ] ) )
		{
			return 1;
		}
	}
	return 0;
}

script_gen_dump_addline( string, signature )
{
	if ( !isDefined( string ) )
	{
		string = "nowrite";
	}
	if ( !isDefined( level._loadstarted ) )
	{
		if ( !isDefined( level.script_gen_dump_preload ) )
		{
			level.script_gen_dump_preload = [];
		}
		struct = spawnstruct();
		struct.string = string;
		struct.signature = signature;
		level.script_gen_dump_preload[ level.script_gen_dump_preload.size ] = struct;
		return;
	}
	if ( !isDefined( level.script_gen_dump[ signature ] ) )
	{
		level.script_gen_dump_reasons[ level.script_gen_dump_reasons.size ] = "Added: " + string;
	}
	level.script_gen_dump[ signature ] = string;
	level.script_gen_dump2[ signature ] = string;
}

array_func( entities, func, arg1, arg2, arg3, arg4, arg5, arg6 )
{
	if ( !isDefined( entities ) )
	{
		return;
	}
	if ( isarray( entities ) )
	{
		while ( entities.size )
		{
			keys = getarraykeys( entities );
			i = 0;
			while ( i < keys.size )
			{
				single_func( entities[ keys[ i ] ], func, arg1, arg2, arg3, arg4, arg5, arg6 );
				i++;
			}
		}
	}
	else single_func( entities, func, arg1, arg2, arg3, arg4, arg5, arg6 );
}

single_func( entity, func, arg1, arg2, arg3, arg4, arg5, arg6 )
{
	if ( !isDefined( entity ) )
	{
		entity = level;
	}
	if ( isDefined( arg6 ) )
	{
		return entity [[ func ]]( arg1, arg2, arg3, arg4, arg5, arg6 );
	}
	else
	{
		if ( isDefined( arg5 ) )
		{
			return entity [[ func ]]( arg1, arg2, arg3, arg4, arg5 );
		}
		else
		{
			if ( isDefined( arg4 ) )
			{
				return entity [[ func ]]( arg1, arg2, arg3, arg4 );
			}
			else
			{
				if ( isDefined( arg3 ) )
				{
					return entity [[ func ]]( arg1, arg2, arg3 );
				}
				else
				{
					if ( isDefined( arg2 ) )
					{
						return entity [[ func ]]( arg1, arg2 );
					}
					else
					{
						if ( isDefined( arg1 ) )
						{
							return entity [[ func ]]( arg1 );
						}
						else
						{
							return entity [[ func ]]();
						}
					}
				}
			}
		}
	}
}

new_func( func, arg1, arg2, arg3, arg4, arg5, arg6 )
{
	s_func = spawnstruct();
	s_func.func = func;
	s_func.arg1 = arg1;
	s_func.arg2 = arg2;
	s_func.arg3 = arg3;
	s_func.arg4 = arg4;
	s_func.arg5 = arg5;
	s_func.arg6 = arg6;
	return s_func;
}

call_func( s_func )
{
	return single_func( self, s_func.func, s_func.arg1, s_func.arg2, s_func.arg3, s_func.arg4, s_func.arg5, s_func.arg6 );
}

array_thread( entities, func, arg1, arg2, arg3, arg4, arg5, arg6 )
{
/#
	assert( isDefined( entities ), "Undefined entity array passed to common_scriptsutility::array_thread" );
#/
/#
	assert( isDefined( func ), "Undefined function passed to common_scriptsutility::array_thread" );
#/
	if ( isarray( entities ) )
	{
		if ( isDefined( arg6 ) )
		{
			_a1554 = entities;
			_k1554 = getFirstArrayKey( _a1554 );
			while ( isDefined( _k1554 ) )
			{
				ent = _a1554[ _k1554 ];
				ent thread [[ func ]]( arg1, arg2, arg3, arg4, arg5, arg6 );
				_k1554 = getNextArrayKey( _a1554, _k1554 );
			}
		}
		else if ( isDefined( arg5 ) )
		{
			_a1561 = entities;
			_k1561 = getFirstArrayKey( _a1561 );
			while ( isDefined( _k1561 ) )
			{
				ent = _a1561[ _k1561 ];
				ent thread [[ func ]]( arg1, arg2, arg3, arg4, arg5 );
				_k1561 = getNextArrayKey( _a1561, _k1561 );
			}
		}
		else if ( isDefined( arg4 ) )
		{
			_a1568 = entities;
			_k1568 = getFirstArrayKey( _a1568 );
			while ( isDefined( _k1568 ) )
			{
				ent = _a1568[ _k1568 ];
				ent thread [[ func ]]( arg1, arg2, arg3, arg4 );
				_k1568 = getNextArrayKey( _a1568, _k1568 );
			}
		}
		else if ( isDefined( arg3 ) )
		{
			_a1575 = entities;
			_k1575 = getFirstArrayKey( _a1575 );
			while ( isDefined( _k1575 ) )
			{
				ent = _a1575[ _k1575 ];
				ent thread [[ func ]]( arg1, arg2, arg3 );
				_k1575 = getNextArrayKey( _a1575, _k1575 );
			}
		}
		else if ( isDefined( arg2 ) )
		{
			_a1582 = entities;
			_k1582 = getFirstArrayKey( _a1582 );
			while ( isDefined( _k1582 ) )
			{
				ent = _a1582[ _k1582 ];
				ent thread [[ func ]]( arg1, arg2 );
				_k1582 = getNextArrayKey( _a1582, _k1582 );
			}
		}
		else if ( isDefined( arg1 ) )
		{
			_a1589 = entities;
			_k1589 = getFirstArrayKey( _a1589 );
			while ( isDefined( _k1589 ) )
			{
				ent = _a1589[ _k1589 ];
				ent thread [[ func ]]( arg1 );
				_k1589 = getNextArrayKey( _a1589, _k1589 );
			}
		}
		else _a1596 = entities;
		_k1596 = getFirstArrayKey( _a1596 );
		while ( isDefined( _k1596 ) )
		{
			ent = _a1596[ _k1596 ];
			ent thread [[ func ]]();
			_k1596 = getNextArrayKey( _a1596, _k1596 );
		}
	}
	else single_thread( entities, func, arg1, arg2, arg3, arg4, arg5, arg6 );
}

array_ent_thread( entities, func, arg1, arg2, arg3, arg4, arg5 )
{
/#
	assert( isDefined( entities ), "Undefined entity array passed to common_scriptsutility::array_ent_thread" );
#/
/#
	assert( isDefined( func ), "Undefined function passed to common_scriptsutility::array_ent_thread" );
#/
	if ( isarray( entities ) )
	{
		while ( entities.size )
		{
			keys = getarraykeys( entities );
			i = 0;
			while ( i < keys.size )
			{
				single_thread( self, func, entities[ keys[ i ] ], arg1, arg2, arg3, arg4, arg5 );
				i++;
			}
		}
	}
	else single_thread( self, func, entities, arg1, arg2, arg3, arg4, arg5 );
}

single_thread( entity, func, arg1, arg2, arg3, arg4, arg5, arg6 )
{
/#
	assert( isDefined( entity ), "Undefined entity passed to common_scriptsutility::single_thread()" );
#/
	if ( isDefined( arg6 ) )
	{
		entity thread [[ func ]]( arg1, arg2, arg3, arg4, arg5, arg6 );
	}
	else if ( isDefined( arg5 ) )
	{
		entity thread [[ func ]]( arg1, arg2, arg3, arg4, arg5 );
	}
	else if ( isDefined( arg4 ) )
	{
		entity thread [[ func ]]( arg1, arg2, arg3, arg4 );
	}
	else if ( isDefined( arg3 ) )
	{
		entity thread [[ func ]]( arg1, arg2, arg3 );
	}
	else if ( isDefined( arg2 ) )
	{
		entity thread [[ func ]]( arg1, arg2 );
	}
	else if ( isDefined( arg1 ) )
	{
		entity thread [[ func ]]( arg1 );
	}
	else
	{
		entity thread [[ func ]]();
	}
}

remove_undefined_from_array( array )
{
	newarray = [];
	i = 0;
	while ( i < array.size )
	{
		if ( !isDefined( array[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			newarray[ newarray.size ] = array[ i ];
		}
		i++;
	}
	return newarray;
}

trigger_on( name, type )
{
	if ( isDefined( name ) )
	{
		if ( !isDefined( type ) )
		{
			type = "targetname";
		}
		ents = getentarray( name, type );
		array_thread( ents, ::trigger_on_proc );
	}
	else
	{
		self trigger_on_proc();
	}
}

trigger_on_proc()
{
	if ( isDefined( self.realorigin ) )
	{
		self.origin = self.realorigin;
	}
	self.trigger_off = undefined;
}

trigger_off( name, type )
{
	if ( isDefined( name ) )
	{
		if ( !isDefined( type ) )
		{
			type = "targetname";
		}
		ents = getentarray( name, type );
		array_thread( ents, ::trigger_off_proc );
	}
	else
	{
		self trigger_off_proc();
	}
}

trigger_off_proc()
{
	if ( !isDefined( self.trigger_off ) || !self.trigger_off )
	{
		self.realorigin = self.origin;
		self.origin += vectorScale( ( 0, 0, -1 ), 10000 );
		self.trigger_off = 1;
	}
}

trigger_wait( str_name, str_key, e_entity )
{
	if ( !isDefined( str_key ) )
	{
		str_key = "targetname";
	}
	if ( isDefined( str_name ) )
	{
		triggers = getentarray( str_name, str_key );
/#
		assert( triggers.size > 0, "trigger not found: " + str_name + " key: " + str_key );
#/
		if ( triggers.size == 1 )
		{
			trigger_hit = triggers[ 0 ];
			trigger_hit _trigger_wait( e_entity );
		}
		else
		{
			s_tracker = spawnstruct();
			array_thread( triggers, ::_trigger_wait_think, s_tracker, e_entity );
			s_tracker waittill( "trigger", e_other, trigger_hit );
			trigger_hit.who = e_other;
		}
		level notify( str_name );
		return trigger_hit;
	}
	else
	{
		return _trigger_wait( e_entity );
	}
}

_trigger_wait( e_entity )
{
	if ( is_look_trigger( self ) )
	{
		self waittill( "trigger_look", e_other );
	}
	else
	{
		self waittill( "trigger", e_other );
	}
	if ( isDefined( e_entity )self.who = e_other;
	return self;
}

_trigger_wait_think( s_tracker, e_entity )
{
	self endon( "death" );
	s_tracker endon( "trigger" );
	e_other = _trigger_wait( e_entity );
	s_tracker notify( "trigger" );
}

trigger_use( str_name, str_key, ent, b_assert )
{
	if ( !isDefined( str_key ) )
	{
		str_key = "targetname";
	}
	if ( !isDefined( b_assert ) )
	{
		b_assert = 1;
	}
	if ( !isDefined( ent ) )
	{
		ent = get_players()[ 0 ];
	}
	if ( isDefined( str_name ) )
	{
		e_trig = getent( str_name, str_key );
		if ( !isDefined( e_trig ) )
		{
			if ( b_assert )
			{
/#
				assertmsg( "trigger not found: " + str_name + " key: " + str_key );
#/
			}
			return;
		}
	}
	else
	{
		e_trig = self;
		str_name = self.targetname;
	}
	e_trig useby( ent );
	level notify( str_name );
	if ( is_look_trigger( e_trig ) )
	{
		e_trig notify( "trigger_look" );
	}
	return e_trig;
}

set_trigger_flag_permissions( msg )
{
	if ( !isDefined( level.trigger_flags ) || !isDefined( level.trigger_flags[ msg ] ) )
	{
		return;
	}
	level.trigger_flags[ msg ] = remove_undefined_from_array( level.trigger_flags[ msg ] );
	array_thread( level.trigger_flags[ msg ], ::update_trigger_based_on_flags );
}

update_trigger_based_on_flags()
{
	true_on = 1;
	while ( isDefined( self.script_flag_true ) )
	{
		true_on = 0;
		tokens = create_flags_and_return_tokens( self.script_flag_true );
		i = 0;
		while ( i < tokens.size )
		{
			if ( flag( tokens[ i ] ) )
			{
				true_on = 1;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	false_on = 1;
	while ( isDefined( self.script_flag_false ) )
	{
		tokens = create_flags_and_return_tokens( self.script_flag_false );
		i = 0;
		while ( i < tokens.size )
		{
			if ( flag( tokens[ i ] ) )
			{
				false_on = 0;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	if ( true_on )
	{
		[[ level.trigger_func[ false_on ] ]]();
	}
}

create_flags_and_return_tokens( flags )
{
	tokens = strtok( flags, " " );
	i = 0;
	while ( i < tokens.size )
	{
		if ( !isDefined( level.flag[ tokens[ i ] ] ) )
		{
			flag_init( tokens[ i ], undefined, 1 );
		}
		i++;
	}
	return tokens;
}

init_trigger_flags()
{
	level.trigger_flags = [];
	level.trigger_func[ 1 ] = ::trigger_on;
	level.trigger_func[ 0 ] = ::trigger_off;
}

is_look_trigger( trig )
{
	if ( isDefined( trig ) )
	{
		if ( trig has_spawnflag( 256 ) )
		{
			if ( !isDefined( trig.classname ) && isDefined( "trigger_damage" ) && isDefined( trig.classname ) && isDefined( "trigger_damage" )}
	}
	else
	{
	}
	return 0;
}

is_trigger_once( trig )
{
	if ( isDefined( trig ) )
	{
		if ( !trig has_spawnflag( 1024 ) )
		{
			if ( !isDefined( self.classname ) && isDefined( "trigger_once" ) )
			{
				if ( isDefined( self.classname ) && isDefined( "trigger_once" ) )
				{
				}
			}
		}
	}
	else
	{
	}
	return 0;
}

getstruct( name, type )
{
	if ( !isDefined( type ) )
	{
		type = "targetname";
	}
/#
	assert( isDefined( level.struct_class_names ), "Tried to getstruct before the structs were init" );
#/
	array = level.struct_class_names[ type ][ name ];
	if ( !isDefined( array ) )
	{
		return undefined;
	}
	if ( array.size > 1 )
	{
/#
		assertmsg( "getstruct used for more than one struct of type " + type + " called " + name + "." );
#/
		return undefined;
	}
	return array[ 0 ];
}

getstructarray( name, type )
{
	if ( !isDefined( type ) )
	{
		type = "targetname";
	}
/#
	assert( isDefined( level.struct_class_names ), "Tried to getstruct before the structs were init" );
#/
	array = level.struct_class_names[ type ][ name ];
	if ( !isDefined( array ) )
	{
		return [];
	}
	return array;
}

structdelete()
{
	if ( isDefined( self.target ) && isDefined( level.struct_class_names[ "target" ][ self.target ] ) )
	{
	}
	if ( isDefined( self.targetname ) && isDefined( level.struct_class_names[ "targetname" ][ self.targetname ] ) )
	{
	}
	if ( isDefined( self.script_noteworthy ) && isDefined( level.struct_class_names[ "script_noteworthy" ][ self.script_noteworthy ] ) )
	{
	}
	if ( isDefined( self.script_linkname ) && isDefined( level.struct_class_names[ "script_linkname" ][ self.script_linkname ] ) )
	{
	}
}

struct_class_init()
{
/#
	assert( !isDefined( level.struct_class_names ), "level.struct_class_names is being initialized in the wrong place! It shouldn't be initialized yet." );
#/
	level.struct_class_names = [];
	level.struct_class_names[ "target" ] = [];
	level.struct_class_names[ "targetname" ] = [];
	level.struct_class_names[ "script_noteworthy" ] = [];
	level.struct_class_names[ "script_linkname" ] = [];
	level.struct_class_names[ "script_unitrigger_type" ] = [];
	_a2064 = level.struct;
	_k2064 = getFirstArrayKey( _a2064 );
	while ( isDefined( _k2064 ) )
	{
		s_struct = _a2064[ _k2064 ];
		if ( isDefined( s_struct.targetname ) )
		{
			if ( !isDefined( level.struct_class_names[ "targetname" ][ s_struct.targetname ] ) )
			{
				level.struct_class_names[ "targetname" ][ s_struct.targetname ] = [];
			}
			size = level.struct_class_names[ "targetname" ][ s_struct.targetname ].size;
			level.struct_class_names[ "targetname" ][ s_struct.targetname ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.target ) )
		{
			if ( !isDefined( level.struct_class_names[ "target" ][ s_struct.target ] ) )
			{
				level.struct_class_names[ "target" ][ s_struct.target ] = [];
			}
			size = level.struct_class_names[ "target" ][ s_struct.target ].size;
			level.struct_class_names[ "target" ][ s_struct.target ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.script_noteworthy ) )
		{
			if ( !isDefined( level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] ) )
			{
				level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] = [];
			}
			size = level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ].size;
			level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.script_linkname ) )
		{
/#
			assert( !isDefined( level.struct_class_names[ "script_linkname" ][ s_struct.script_linkname ] ), "Two structs have the same linkname" );
#/
			level.struct_class_names[ "script_linkname" ][ s_struct.script_linkname ][ 0 ] = s_struct;
		}
		if ( isDefined( s_struct.script_unitrigger_type ) )
		{
			if ( !isDefined( level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] ) )
			{
				level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] = [];
			}
			size = level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ].size;
			level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ][ size ] = s_struct;
		}
		_k2064 = getNextArrayKey( _a2064, _k2064 );
	}
}

fileprint_start( file )
{
/#
	filename = file;
	file = openfile( filename, "write" );
	level.fileprint = file;
	level.fileprintlinecount = 0;
	level.fileprint_filename = filename;
#/
}

fileprint_map_start( file )
{
/#
	file = "map_source/" + file + ".map";
	fileprint_start( file );
	level.fileprint_mapentcount = 0;
	fileprint_map_header( 1 );
#/
}

fileprint_chk( file, str )
{
/#
	level.fileprintlinecount++;
	if ( level.fileprintlinecount > 400 )
	{
		wait 0,05;
		level.fileprintlinecount++;
		level.fileprintlinecount = 0;
	}
	fprintln( file, str );
#/
}

fileprint_map_header( binclude_blank_worldspawn )
{
	if ( !isDefined( binclude_blank_worldspawn ) )
	{
		binclude_blank_worldspawn = 0;
	}
/#
	assert( isDefined( level.fileprint ) );
#/
/#
	fileprint_chk( level.fileprint, "iwmap 4" );
	fileprint_chk( level.fileprint, ""000_Global" flags  active" );
	fileprint_chk( level.fileprint, ""The Map" flags" );
	if ( !binclude_blank_worldspawn )
	{
		return;
	}
	fileprint_map_entity_start();
	fileprint_map_keypairprint( "classname", "worldspawn" );
	fileprint_map_entity_end();
#/
}

fileprint_map_keypairprint( key1, key2 )
{
/#
	assert( isDefined( level.fileprint ) );
	fileprint_chk( level.fileprint, """ + key1 + "" "" + key2 + """ );
#/
}

fileprint_map_entity_start()
{
/#
	assert( !isDefined( level.fileprint_entitystart ) );
	level.fileprint_entitystart = 1;
	assert( isDefined( level.fileprint ) );
	fileprint_chk( level.fileprint, "// entity " + level.fileprint_mapentcount );
	fileprint_chk( level.fileprint, "{" );
	level.fileprint_mapentcount++;
#/
}

fileprint_map_entity_end()
{
/#
	assert( isDefined( level.fileprint_entitystart ) );
	assert( isDefined( level.fileprint ) );
	level.fileprint_entitystart = undefined;
	fileprint_chk( level.fileprint, "}" );
#/
}

fileprint_end()
{
/#
	assert( !isDefined( level.fileprint_entitystart ) );
	saved = closefile( level.fileprint );
	if ( saved != 1 )
	{
		println( "-----------------------------------" );
		println( " " );
		println( "file write failure" );
		println( "file with name: " + level.fileprint_filename );
		println( "make sure you checkout the file you are trying to save" );
		println( "note: USE P4 Search to find the file and check that one out" );
		println( "      Do not checkin files in from the xenonoutput folder, " );
		println( "      this is junctioned to the proper directory where you need to go" );
		println( "junctions looks like this" );
		println( " " );
		println( "..\\xenonOutput\\scriptdata\\createfx      ..\\share\\raw\\maps\\createfx" );
		println( "..\\xenonOutput\\scriptdata\\createart     ..\\share\\raw\\maps\\createart" );
		println( "..\\xenonOutput\\scriptdata\\vision        ..\\share\\raw\\vision" );
		println( "..\\xenonOutput\\scriptdata\\scriptgen     ..\\share\\raw\\maps\\scriptgen" );
		println( "..\\xenonOutput\\scriptdata\\zone_source   ..\\xenon\\zone_source" );
		println( "..\\xenonOutput\\accuracy                  ..\\share\\raw\\accuracy" );
		println( "..\\xenonOutput\\scriptdata\\map_source    ..\\map_source\\xenon_export" );
		println( " " );
		println( "-----------------------------------" );
		println( "File not saved( see console.log for info ) " );
	}
	level.fileprint = undefined;
	level.fileprint_filename = undefined;
#/
}

fileprint_radiant_vec( vector )
{
/#
	string = "" + vector[ 0 ] + " " + vector[ 1 ] + " " + vector[ 2 ] + "";
	return string;
#/
}

is_mature()
{
	if ( level.onlinegame )
	{
		return 1;
	}
	return getlocalprofileint( "cg_mature" );
}

is_german_build()
{
	if ( level.language == "german" )
	{
		return 1;
	}
	return 0;
}

is_gib_restricted_build()
{
	if ( getDvar( "language" ) == "japanese" )
	{
		return 1;
	}
	return 0;
}

is_true( check )
{
	if ( isDefined( check ) )
	{
		return check;
	}
}

is_false( check )
{
	if ( isDefined( check ) )
	{
		return !check;
	}
}

has_spawnflag( spawnflags )
{
	if ( isDefined( self.spawnflags ) )
	{
		return ( self.spawnflags & spawnflags ) == spawnflags;
	}
	return 0;
}

clamp( val, val_min, val_max )
{
	if ( val < val_min )
	{
		val = val_min;
	}
	else
	{
		if ( val > val_max )
		{
			val = val_max;
		}
	}
	return val;
}

linear_map( num, min_a, max_a, min_b, max_b )
{
	return clamp( ( ( ( num - min_a ) / ( max_a - min_a ) ) * ( max_b - min_b ) ) + min_b, min_b, max_b );
}

lag( desired, curr, k, dt )
{
	r = 0;
	if ( ( k * dt ) >= 1 || k <= 0 )
	{
		r = desired;
	}
	else
	{
		err = desired - curr;
		r = curr + ( k * err * dt );
	}
	return r;
}

death_notify_wrapper( attacker, damagetype )
{
	level notify( "face" );
	self notify( "death" );
}

damage_notify_wrapper( damage, attacker, direction_vec, point, type, modelname, tagname, partname, idflags )
{
	level notify( "face" );
	self notify( "damage" );
}

explode_notify_wrapper()
{
	level notify( "face" );
	self notify( "explode" );
}

alert_notify_wrapper()
{
	level notify( "face" );
	self notify( "alert" );
}

shoot_notify_wrapper()
{
	level notify( "face" );
	self notify( "shoot" );
}

melee_notify_wrapper()
{
	level notify( "face" );
	self notify( "melee" );
}

isusabilityenabled()
{
	return !self.disabledusability;
}

_disableusability()
{
	self.disabledusability++;
	self disableusability();
}

_enableusability()
{
	self.disabledusability--;

/#
	assert( self.disabledusability >= 0 );
#/
	if ( !self.disabledusability )
	{
		self enableusability();
	}
}

resetusability()
{
	self.disabledusability = 0;
	self enableusability();
}

_disableweapon()
{
	if ( !isDefined( self.disabledweapon ) )
	{
		self.disabledweapon = 0;
	}
	self.disabledweapon++;
	self disableweapons();
}

_enableweapon()
{
	self.disabledweapon--;

/#
	assert( self.disabledweapon >= 0 );
#/
	if ( !self.disabledweapon )
	{
		self enableweapons();
	}
}

isweaponenabled()
{
	return !self.disabledweapon;
}

delay_thread( timer, func, param1, param2, param3, param4, param5, param6 )
{
	self thread _delay_thread_proc( func, timer, param1, param2, param3, param4, param5, param6 );
}

_delay_thread_proc( func, timer, param1, param2, param3, param4, param5, param6 )
{
	self endon( "death" );
	self endon( "disconnect" );
	wait timer;
	single_thread( self, func, param1, param2, param3, param4, param5, param6 );
}

delay_notify( str_notify, n_delay, str_endon )
{
/#
	assert( isDefined( str_notify ) );
#/
/#
	assert( isDefined( n_delay ) );
#/
	self thread _delay_notify_proc( str_notify, n_delay, str_endon );
}

_delay_notify_proc( str_notify, n_delay, str_endon )
{
	self endon( "death" );
	if ( isDefined( str_endon ) )
	{
		self endon( str_endon );
	}
	if ( n_delay > 0 )
	{
		wait n_delay;
	}
	self notify( str_notify );
}

notify_delay_with_ender( snotifystring, fdelay, ender )
{
	if ( isDefined( ender ) )
	{
		level endon( ender );
	}
/#
	assert( isDefined( self ) );
#/
/#
	assert( isDefined( snotifystring ) );
#/
/#
	assert( isDefined( fdelay ) );
#/
	self endon( "death" );
	if ( fdelay > 0 )
	{
		wait fdelay;
	}
	if ( !isDefined( self ) )
	{
		return;
	}
	self notify( snotifystring );
}
