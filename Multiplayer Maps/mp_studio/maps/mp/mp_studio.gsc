#include maps/mp/_tacticalinsertion;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_studio_fx::main();
	maps/mp/_load::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_studio" );
	maps/mp/mp_studio_amb::main();
	setdvar( "compassmaxrange", "2100" );
	game[ "strings" ][ "war_callsign_a" ] = &"MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings" ][ "war_callsign_b" ] = &"MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings" ][ "war_callsign_c" ] = &"MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings" ][ "war_callsign_d" ] = &"MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings" ][ "war_callsign_e" ] = &"MPUI_CALLSIGN_MAPNAME_E";
	game[ "strings_menu" ][ "war_callsign_a" ] = "@MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings_menu" ][ "war_callsign_b" ] = "@MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings_menu" ][ "war_callsign_c" ] = "@MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings_menu" ][ "war_callsign_d" ] = "@MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings_menu" ][ "war_callsign_e" ] = "@MPUI_CALLSIGN_MAPNAME_E";
	level.destructible_callbacks[ "remove_streamers" ] = ::death_streamer_think;
	alleytrigger = getent( "alleyTrigger", "targetname" );
	windowtrigger = getent( "triggerwindowTarget", "targetname" );
	target7 = getent( "trailerTarget_Window", "targetname" );
	target8 = getent( "alleyTarget_Cover", "targetname" );
	target9 = getent( "alleyTarget_Path", "targetname" );
	targetlight1_off = getent( "steelBuildingTargetLight1_off", "targetname" );
	targetlight1_on = getent( "steelBuildingTargetLight1_on", "targetname" );
	targetlight2_off = getent( "steelBuildingTargetLight2_off", "targetname" );
	targetlight2_on = getent( "steelBuildingTargetLight2_on", "targetname" );
	level.const_fx_exploder_red_light_1 = 1001;
	level.const_fx_exploder_red_light_2 = 1002;
	speaker1 = getent( "loudspeaker1", "targetname" );
	speaker2 = getent( "loudspeaker2", "targetname" );
	targetlight1_on hide();
	targetlight2_on hide();
	target8 setcandamage( 1 );
	target9 setcandamage( 1 );
	target8 thread damagetarget( 2 );
	target9 thread damagetarget( 2 );
	target7 thread movetarget( 7, ( 57, 23, 0 ), 3 );
	target8 thread movetarget( 1, 240, 10 );
	target9 thread movetarget( 1, 130, 8,6 );
	alleytrigger thread triggercheck( target9 );
	windowtrigger thread triggercheck( target7 );
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "1900", reset_dvars );
}

triggercheck( target )
{
	self endon( "game_ended" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		distance = distance( target.origin, self.origin );
		while ( distance <= 90 )
		{
			target notify( "targetStopMoving" );
			while ( isDefined( player ) && player istouching( self ) && distance <= 90 )
			{
				if ( distancesquared( target.origin, target.railpoints[ 0 ] ) < distancesquared( player.origin, target.railpoints[ 0 ] ) )
				{
					target.preferrednextpos = 0;
				}
				else
				{
					target.preferrednextpos = 1;
				}
				wait 0,25;
			}
		}
	}
}

damagetarget( dir )
{
	self endon( "game_ended" );
	while ( 1 )
	{
		self waittill( "damage", damage, attacker, direction );
		switch( dir )
		{
			case 1:
				self rotateroll( self.angles[ 1 ] + 90, 0,1 );
				wait 0,2;
				self rotateroll( self.angles[ 1 ] - 90, 0,1 );
				wait 0,2;
				self playsound( "amb_target_flip" );
				break;
			continue;
			case 2:
				rotation = 1;
				if ( isDefined( attacker ) && isplayer( attacker ) )
				{
					yaw = get2dyaw( attacker.origin, self.origin );
					if ( attacker.angles[ 1 ] > yaw )
					{
						rotation = -1;
					}
				}
				self rotateyaw( self.angles[ 2 ] + ( 180 * rotation ), 0,3 );
				self playsound( "amb_target_twirl" );
				self waittill( "rotatedone" );
				break;
			continue;
			case 3:
				self rotatepitch( self.angles[ 1 ] + 90, 0,1 );
				wait 0,2;
				self rotatepitch( self.angles[ 1 ] - 90, 0,1 );
				wait 0,2;
				self playsound( "amb_target_flip" );
				break;
			continue;
			case 4:
				self rotateroll( self.angles[ 1 ] - 90, 0,1 );
				wait 0,2;
				self rotateroll( self.angles[ 1 ] + 90, 0,1 );
				wait 0,2;
				self playsound( "amb_target_flip" );
				break;
			continue;
			case 5:
				self rotatepitch( self.angles[ 1 ] - 90, 0,1 );
				wait 0,2;
				self rotatepitch( self.angles[ 1 ] + 90, 0,1 );
				wait 0,2;
				self playsound( "amb_target_flip" );
				break;
			continue;
		}
	}
}

damagetargetlights( light_on, light_off, speaker, alias, exploderhandle )
{
	self endon( "game_ended" );
	while ( 1 )
	{
		self waittill( "damage" );
		speaker playsound( alias );
		exploder( exploderhandle );
		light_off hide();
		light_on show();
		wait 0,5;
		exploder_stop( exploderhandle );
		light_off show();
		light_on hide();
	}
}

movetarget( dir, dis, speed )
{
	self endon( "game_ended" );
	keepmoving = 1;
	self thread movement_process();
	startpos = self.origin;
	farpos = self.origin;
	sound = spawn( "script_origin", self.origin );
	sound linkto( self );
	sound playloopsound( "amb_target_chain" );
	switch( dir )
	{
		case 1:
			farpos = self.origin + ( 0, dis, 0 );
			break;
		case 2:
			farpos = self.origin - ( 0, dis, 0 );
			break;
		case 3:
			farpos = self.origin + ( dis, 0, 0 );
			break;
		case 4:
			farpos = self.origin - ( dis, 0, 0 );
			break;
		case 5:
			farpos = self.origin + ( 0, 0, dis );
			break;
		case 6:
			farpos = self.origin - ( 0, 0, dis );
			break;
		case 7:
			farpos = self.origin - dis;
			break;
	}
	self.railpoints = [];
	self.railpoints[ 0 ] = startpos;
	self.railpoints[ 1 ] = farpos;
	self.preferrednextpos = 1;
	self.playertrigger = 0;
	while ( 1 )
	{
		nextpos = self.railpoints[ self.preferrednextpos ];
		if ( self.preferrednextpos == 0 )
		{
			self.preferrednextpos = 1;
		}
		else
		{
			self.preferrednextpos = 0;
		}
		self moveto( nextpos, speed );
		self waittill_either( "movedone", "targetStopMoving" );
		self playsound( "amb_target_stop" );
	}
}

rotatetarget( dir, deg, speed, pausetime )
{
	self endon( "game_ended" );
	while ( 1 )
	{
		switch( dir )
		{
			case 1:
				self rotateyaw( self.angles[ 2 ] + deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				self rotateyaw( self.angles[ 2 ] - deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				break;
			continue;
			case 2:
				self rotateyaw( self.angles[ 2 ] - deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				self rotateyaw( self.angles[ 2 ] + deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				break;
			continue;
			case 3:
				self rotateroll( self.angles[ 0 ] + deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				self rotateroll( self.angles[ 0 ] - deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				break;
			continue;
			case 4:
				self rotateroll( self.angles[ 0 ] - deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				self rotateroll( self.angles[ 0 ] + deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				break;
			continue;
			case 5:
				self rotateroll( self.angles[ 1 ] + deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				self rotateroll( self.angles[ 1 ] - deg, speed );
				self playsound( "amb_target_rotate" );
				wait pausetime;
				break;
			continue;
			case 6:
				self rotatepitch( self.angles[ 1 ] - deg, speed );
				wait pausetime;
				self rotatepitch( self.angles[ 1 ] + deg, speed );
				wait pausetime;
				break;
			continue;
			case 7:
				self rotateto( ( self.angles[ 0 ] + 90, self.angles[ 1 ] - 90, self.angles[ 2 ] + 45 ), speed );
				wait pausetime;
				self rotateto( ( self.angles[ 0 ] - 90, self.angles[ 1 ] + 90, self.angles[ 2 ] - 45 ), speed );
				wait pausetime;
		}
	}
}

movement_process()
{
	for ( ;; )
	{
		entities = getdamageableentarray( self.origin, 50 );
		_a352 = entities;
		_k352 = getFirstArrayKey( _a352 );
		while ( isDefined( _k352 ) )
		{
			entity = _a352[ _k352 ];
			if ( isDefined( entity.targetname ) || entity.targetname == "alleyTarget_Cover" && entity.targetname == "alleyTarget_Path" )
			{
			}
			else
			{
				if ( isplayer( entity ) )
				{
					break;
				}
				else if ( !entity istouching( self ) )
				{
					break;
				}
				else if ( isDefined( entity.classname ) && entity.classname == "grenade" )
				{
					if ( !isDefined( entity.name ) )
					{
						break;
					}
					else if ( !isDefined( entity.owner ) )
					{
						break;
					}
					else if ( entity.name == "satchel_charge_mp" )
					{
						if ( entity.origin[ 2 ] > ( self.origin[ 2 ] + 5 ) )
						{
							break;
						}
					}
					else watcher = entity.owner getwatcherforweapon( entity.name );
					if ( !isDefined( watcher ) )
					{
						break;
					}
					else watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( entity, 0, undefined );
				}
				if ( isDefined( entity.targetname ) )
				{
					if ( entity.targetname == "riotshield_mp" )
					{
						entity dodamage( 1, self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
						break;
					}
				}
				else
				{
					if ( isDefined( entity.model ) && entity.model == "t6_wpn_tac_insert_world" )
					{
						entity thread maps/mp/_tacticalinsertion::fizzle();
					}
				}
			}
			_k352 = getNextArrayKey( _a352, _k352 );
		}
		wait 0,25;
	}
}

getwatcherforweapon( weapname )
{
	if ( !isDefined( self ) )
	{
		return undefined;
	}
	if ( !isplayer( self ) )
	{
		return undefined;
	}
	i = 0;
	while ( i < self.weaponobjectwatcherarray.size )
	{
		if ( self.weaponobjectwatcherarray[ i ].weapon != weapname )
		{
			i++;
			continue;
		}
		else
		{
			return self.weaponobjectwatcherarray[ i ];
		}
		i++;
	}
	return undefined;
}

death_streamer_think( notifytype, attacker )
{
	streamers = getentarray( "airconditioner_streamer", "targetname" );
	i = 0;
	while ( i < streamers.size )
	{
		streamer = streamers[ i ];
		if ( distancesquared( streamer.origin, self.origin ) < 2500 )
		{
			streamer delete();
		}
		i++;
	}
}
