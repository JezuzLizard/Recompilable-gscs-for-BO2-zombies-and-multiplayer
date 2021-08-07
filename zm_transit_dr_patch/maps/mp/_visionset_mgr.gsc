#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( level.createfx_enabled )
	{
		return;
	}
	level.vsmgr_initializing = 1;
	level.vsmgr_default_info_name = "none";
	level.vsmgr = [];
	level thread register_type( "visionset" );
	level thread register_type( "overlay" );
	onfinalizeinitialization_callback( ::finalize_clientfields );
	level thread monitor();
	level thread onplayerconnect();
}

vsmgr_register_info( type, name, version, priority, lerp_step_count, activate_per_player, lerp_thread, ref_count_lerp_thread )
{
	if ( level.createfx_enabled )
	{
		return;
	}
/#
	assert( level.vsmgr_initializing, "All info registration in the visionset_mgr system must occur during the first frame while the system is initializing" );
#/
	lower_name = tolower( name );
	validate_info( type, lower_name, priority );
	add_sorted_name_key( type, lower_name );
	add_sorted_priority_key( type, lower_name, priority );
	level.vsmgr[ type ].info[ lower_name ] = spawnstruct();
	level.vsmgr[ type ].info[ lower_name ] add_info( type, lower_name, version, priority, lerp_step_count, activate_per_player, lerp_thread, ref_count_lerp_thread );
	if ( level.vsmgr[ type ].highest_version < version )
	{
		level.vsmgr[ type ].highest_version = version;
	}
}

vsmgr_activate( type, name, player, opt_param_1, opt_param_2 )
{
	if ( level.vsmgr[ type ].info[ name ].state.activate_per_player )
	{
		activate_per_player( type, name, player, opt_param_1, opt_param_2 );
		return;
	}
	state = level.vsmgr[ type ].info[ name ].state;
	if ( state.ref_count_lerp_thread )
	{
		state.ref_count++;
		if ( state.ref_count >= 1 )
		{
			return;
		}
	}
	if ( isDefined( state.lerp_thread ) )
	{
		state thread lerp_thread_wrapper( state.lerp_thread, opt_param_1, opt_param_2 );
	}
	else
	{
		players = getplayers();
		player_index = 0;
		while ( player_index < players.size )
		{
			state vsmgr_set_state_active( players[ player_index ], 1 );
			player_index++;
		}
	}
}

vsmgr_deactivate( type, name, player )
{
	if ( level.vsmgr[ type ].info[ name ].state.activate_per_player )
	{
		deactivate_per_player( type, name, player );
		return;
	}
	state = level.vsmgr[ type ].info[ name ].state;
	if ( state.ref_count_lerp_thread )
	{
		state.ref_count--;

		if ( state.ref_count >= 0 )
		{
			return;
		}
	}
	state notify( "deactivate" );
	players = getplayers();
	player_index = 0;
	while ( player_index < players.size )
	{
		state vsmgr_set_state_inactive( players[ player_index ] );
		player_index++;
	}
}

vsmgr_set_state_active( player, lerp )
{
	player_entnum = player getentitynumber();
	self.players[ player_entnum ].active = 1;
	self.players[ player_entnum ].lerp = lerp;
}

vsmgr_set_state_inactive( player )
{
	player_entnum = player getentitynumber();
	self.players[ player_entnum ].active = 0;
	self.players[ player_entnum ].lerp = 0;
}

vsmgr_timeout_lerp_thread( timeout, opt_param_2 )
{
	players = getplayers();
	player_index = 0;
	while ( player_index < players.size )
	{
		self vsmgr_set_state_active( players[ player_index ], 1 );
		player_index++;
	}
	wait timeout;
	vsmgr_deactivate( self.type, self.name );
}

vsmgr_timeout_lerp_thread_per_player( player, timeout, opt_param_2 )
{
	self vsmgr_set_state_active( player, 1 );
	wait timeout;
	deactivate_per_player( self.type, self.name, player );
}

vsmgr_duration_lerp_thread( duration, max_duration )
{
	start_time = getTime();
	end_time = start_time + int( duration * 1000 );
	if ( isDefined( max_duration ) )
	{
		start_time = end_time - int( max_duration * 1000 );
	}
	while ( 1 )
	{
		lerp = calc_remaining_duration_lerp( start_time, end_time );
		if ( lerp < 0 )
		{
			break;
		}
		else
		{
			players = getplayers();
			player_index = 0;
			while ( player_index < players.size )
			{
				self vsmgr_set_state_active( players[ player_index ], lerp );
				player_index++;
			}
			wait 0,05;
		}
	}
	vsmgr_deactivate( self.type, self.name );
}

vsmgr_duration_lerp_thread_per_player( player, duration, max_duration )
{
	start_time = getTime();
	end_time = start_time + int( duration * 1000 );
	if ( isDefined( max_duration ) )
	{
		start_time = end_time - int( max_duration * 1000 );
	}
	while ( 1 )
	{
		lerp = calc_remaining_duration_lerp( start_time, end_time );
		if ( lerp < 0 )
		{
			break;
		}
		else
		{
			self vsmgr_set_state_active( player, lerp );
			wait 0,05;
		}
	}
	deactivate_per_player( self.type, self.name, player );
}

register_type( type )
{
	level.vsmgr[ type ] = spawnstruct();
	level.vsmgr[ type ].type = type;
	level.vsmgr[ type ].in_use = 0;
	level.vsmgr[ type ].highest_version = 0;
	level.vsmgr[ type ].cf_slot_name = type + "_slot";
	level.vsmgr[ type ].cf_lerp_name = type + "_lerp";
	level.vsmgr[ type ].info = [];
	level.vsmgr[ type ].sorted_name_keys = [];
	level.vsmgr[ type ].sorted_prio_keys = [];
	vsmgr_register_info( type, level.vsmgr_default_info_name, 1, 0, 1, 0, undefined );
}

finalize_clientfields()
{
	typekeys = getarraykeys( level.vsmgr );
	type_index = 0;
	while ( type_index < typekeys.size )
	{
		level.vsmgr[ typekeys[ type_index ] ] thread finalize_type_clientfields();
		type_index++;
	}
	level.vsmgr_initializing = 0;
}

finalize_type_clientfields()
{
	if ( self.info.size < 1 )
	{
		return;
	}
	self.in_use = 1;
	self.cf_slot_bit_count = getminbitcountfornum( self.info.size - 1 );
	self.cf_lerp_bit_count = self.info[ self.sorted_name_keys[ 0 ] ].lerp_bit_count;
	i = 0;
	while ( i < self.sorted_name_keys.size )
	{
		self.info[ self.sorted_name_keys[ i ] ].slot_index = i;
		if ( self.info[ self.sorted_name_keys[ i ] ].lerp_bit_count > self.cf_lerp_bit_count )
		{
			self.cf_lerp_bit_count = self.info[ self.sorted_name_keys[ i ] ].lerp_bit_count;
		}
		i++;
	}
	registerclientfield( "toplayer", self.cf_slot_name, self.highest_version, self.cf_slot_bit_count, "int" );
	if ( self.cf_lerp_bit_count >= 1 )
	{
		registerclientfield( "toplayer", self.cf_lerp_name, self.highest_version, self.cf_lerp_bit_count, "float" );
	}
}

validate_info( type, name, priority )
{
	keys = getarraykeys( level.vsmgr );
	i = 0;
	while ( i < keys.size )
	{
		if ( type == keys[ i ] )
		{
			break;
		}
		else
		{
			i++;
		}
	}
/#
	assert( i < keys.size, "In visionset_mgr, type '" + type + "'is unknown" );
#/
	keys = getarraykeys( level.vsmgr[ type ].info );
	i = 0;
	while ( i < keys.size )
	{
/#
		assert( level.vsmgr[ type ].info[ keys[ i ] ].name != name, "In visionset_mgr of type '" + type + "': name '" + name + "' has previously been registered" );
#/
/#
		assert( level.vsmgr[ type ].info[ keys[ i ] ].priority != priority, "In visionset_mgr of type '" + type + "': priority '" + priority + "' requested for name '" + name + "' has previously been registered under name '" + level.vsmgr[ type ].info[ keys[ i ] ].name + "'" );
#/
		i++;
	}
}

add_sorted_name_key( type, name )
{
	i = 0;
	while ( i < level.vsmgr[ type ].sorted_name_keys.size )
	{
		if ( name < level.vsmgr[ type ].sorted_name_keys[ i ] )
		{
			break;
		}
		else
		{
			i++;
		}
	}
	arrayinsert( level.vsmgr[ type ].sorted_name_keys, name, i );
}

add_sorted_priority_key( type, name, priority )
{
	i = 0;
	while ( i < level.vsmgr[ type ].sorted_prio_keys.size )
	{
		if ( priority > level.vsmgr[ type ].info[ level.vsmgr[ type ].sorted_prio_keys[ i ] ].priority )
		{
			break;
		}
		else
		{
			i++;
		}
	}
	arrayinsert( level.vsmgr[ type ].sorted_prio_keys, name, i );
}

add_info( type, name, version, priority, lerp_step_count, activate_per_player, lerp_thread, ref_count_lerp_thread )
{
	self.type = type;
	self.name = name;
	self.version = version;
	self.priority = priority;
	self.lerp_step_count = lerp_step_count;
	self.lerp_bit_count = getminbitcountfornum( lerp_step_count );
	if ( !isDefined( ref_count_lerp_thread ) )
	{
		ref_count_lerp_thread = 0;
	}
	self.state = spawnstruct();
	self.state.type = type;
	self.state.name = name;
	self.state.activate_per_player = activate_per_player;
	self.state.lerp_thread = lerp_thread;
	self.state.ref_count_lerp_thread = ref_count_lerp_thread;
	self.state.players = [];
	if ( ref_count_lerp_thread && !activate_per_player )
	{
		self.state.ref_count = 0;
	}
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread on_player_connect();
	}
}

on_player_connect()
{
	self._player_entnum = self getentitynumber();
	typekeys = getarraykeys( level.vsmgr );
	type_index = 0;
	while ( type_index < typekeys.size )
	{
		type = typekeys[ type_index ];
		if ( !level.vsmgr[ type ].in_use )
		{
			type_index++;
			continue;
		}
		else
		{
			name_index = 0;
			while ( name_index < level.vsmgr[ type ].sorted_name_keys.size )
			{
				name_key = level.vsmgr[ type ].sorted_name_keys[ name_index ];
				level.vsmgr[ type ].info[ name_key ].state.players[ self._player_entnum ] = spawnstruct();
				level.vsmgr[ type ].info[ name_key ].state.players[ self._player_entnum ].active = 0;
				level.vsmgr[ type ].info[ name_key ].state.players[ self._player_entnum ].lerp = 0;
				if ( level.vsmgr[ type ].info[ name_key ].state.ref_count_lerp_thread && level.vsmgr[ type ].info[ name_key ].state.activate_per_player )
				{
					level.vsmgr[ type ].info[ name_key ].state.players[ self._player_entnum ].ref_count = 0;
				}
				name_index++;
			}
			level.vsmgr[ type ].info[ level.vsmgr_default_info_name ].state vsmgr_set_state_active( self, 1 );
		}
		type_index++;
	}
}

monitor()
{
	while ( level.vsmgr_initializing )
	{
		wait 0,05;
	}
	typekeys = getarraykeys( level.vsmgr );
	while ( 1 )
	{
		wait 0,05;
		waittillframeend;
		players = get_players();
		type_index = 0;
		while ( type_index < typekeys.size )
		{
			type = typekeys[ type_index ];
			if ( !level.vsmgr[ type ].in_use )
			{
				type_index++;
				continue;
			}
			else
			{
				player_index = 0;
				while ( player_index < players.size )
				{
/#
					if ( is_true( players[ player_index ].pers[ "isBot" ] ) )
					{
						player_index++;
						continue;
#/
					}
					else
					{
						update_clientfields( players[ player_index ], level.vsmgr[ type ] );
					}
					player_index++;
				}
			}
			type_index++;
		}
	}
}

get_first_active_name( type_struct )
{
	size = type_struct.sorted_prio_keys.size;
	prio_index = 0;
	while ( prio_index < size )
	{
		prio_key = type_struct.sorted_prio_keys[ prio_index ];
		if ( type_struct.info[ prio_key ].state.players[ self._player_entnum ].active )
		{
			return prio_key;
		}
		prio_index++;
	}
	return level.vsmgr_default_info_name;
}

update_clientfields( player, type_struct )
{
	name = player get_first_active_name( type_struct );
	player setclientfieldtoplayer( type_struct.cf_slot_name, type_struct.info[ name ].slot_index );
	if ( type_struct.cf_lerp_bit_count >= 1 )
	{
		player setclientfieldtoplayer( type_struct.cf_lerp_name, type_struct.info[ name ].state.players[ player._player_entnum ].lerp );
	}
}

lerp_thread_wrapper( func, opt_param_1, opt_param_2 )
{
	self notify( "deactivate" );
	self endon( "deactivate" );
	self [[ func ]]( opt_param_1, opt_param_2 );
}

lerp_thread_per_player_wrapper( func, player, opt_param_1, opt_param_2 )
{
	player_entnum = player getentitynumber();
	self notify( "deactivate" );
	self endon( "deactivate" );
	self.players[ player_entnum ] notify( "deactivate" );
	self.players[ player_entnum ] endon( "deactivate" );
	player endon( "disconnect" );
	self [[ func ]]( player, opt_param_1, opt_param_2 );
}

activate_per_player( type, name, player, opt_param_1, opt_param_2 )
{
	player_entnum = player getentitynumber();
	state = level.vsmgr[ type ].info[ name ].state;
	if ( state.ref_count_lerp_thread )
	{
		state.players[ player_entnum ].ref_count++;
		if ( state.players[ player_entnum ].ref_count >= 1 )
		{
			return;
		}
	}
	if ( isDefined( state.lerp_thread ) )
	{
		state thread lerp_thread_per_player_wrapper( state.lerp_thread, player, opt_param_1, opt_param_2 );
	}
	else
	{
		state vsmgr_set_state_active( player, 1 );
	}
}

deactivate_per_player( type, name, player )
{
	player_entnum = player getentitynumber();
	state = level.vsmgr[ type ].info[ name ].state;
	if ( state.ref_count_lerp_thread )
	{
		state.players[ player_entnum ].ref_count--;

		if ( state.players[ player_entnum ].ref_count >= 0 )
		{
			return;
		}
	}
	state vsmgr_set_state_inactive( player );
	state notify( "deactivate" );
}

calc_remaining_duration_lerp( start_time, end_time )
{
	now = getTime();
	frac = float( end_time - now ) / float( end_time - start_time );
	return clamp( frac, 0, 1 );
}
