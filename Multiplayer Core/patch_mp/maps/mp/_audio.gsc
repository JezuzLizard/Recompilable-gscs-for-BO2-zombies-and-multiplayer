//checked includes match cerberus output
#include common_scripts/utility;
#include maps/mp/_utility;

init() //checked matches cerberus output
{
}

wait_until_first_player() //checked changed to match cerberus output
{
	players = get_players();
	if ( !isDefined( players[ 0 ] ) )
	{
		level waittill( "first_player_ready" );
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread monitor_player_sprint();
	}
}

stand_think( trig ) //checked matches cerberus output
{
	killtext = "kill_stand_think" + trig getentitynumber();
	self endon( "disconnect" );
	self endon( "death" );
	self endon( killtext );
	while ( 1 )
	{
		if ( self.player_is_moving )
		{
			trig playsound( trig.script_label );
		}
		wait 1;
	}
}

monitor_player_sprint() //checked matches cerberus output
{
	self endon( "disconnect" );
	self thread monitor_player_movement();
	self._is_sprinting = 0;
	while ( 1 )
	{
		self waittill( "sprint_begin" );
		self._is_sprinting = 1;
		self waittill( "sprint_end" );
		self._is_sprinting = 0;
	}
}

monitor_player_movement() //checked matches cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		org_1 = self.origin;
		wait 1;
		org_2 = self.origin;
		distancemoved = distancesquared( org_1, org_2 );
		if ( distancemoved > 4096 )
		{
			self.player_is_moving = 1;
			continue;
		}
		else
		{
			self.player_is_moving = 0;
		}
	}
}

thread_enter_exit_sound( trig ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	trig.touchingplayers[ self getentitynumber() ] = 1;
	if ( isDefined( trig.script_sound ) && trig.script_activated && self._is_sprinting )
	{
		self playsound( trig.script_sound );
	}
	self thread stand_think( trig );
	while ( self istouching( trig ) )
	{
		wait 0.1;
	}
	self notify( "kill_stand_think" + trig getentitynumber() );
	self playsound( trig.script_noteworthy );
	trig.touchingplayers[ self getentitynumber() ] = 0;
}

thread_step_trigger() //checked changed to match cerberus output
{
	if ( !isDefined( self.script_activated ) )
	{
		self.script_activated = 1;
	}
	if ( !isDefined( self.touchingplayers ) )
	{
		self.touchingplayers = [];
		for ( i = 0; i < 4; i++ )
		{
			self.touchingplayers[ i ] = 0;
		}
	}
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( self.touchingplayers[ who getentitynumber() ] == 0 )
		{
			who thread thread_enter_exit_sound( self );
		}
	}
}

disable_bump_trigger( triggername ) //checked changed to match cerberus output
{
	triggers = getentarray( "audio_bump_trigger", "targetname" );
	if ( isDefined( triggers ) )
	{
		for ( i = 0; i < triggers.size; i++ )
		{
			if ( isDefined( triggers[ i ].script_label ) && triggers[ i ].script_label == triggername )
			{
				triggers[ i ].script_activated = 0;
			}
		}
	}
}

get_player_index_number( player ) //checked changed to match cerberus output
{
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ] == player )
		{
			return i;
		}
	}
	return 1;
}
