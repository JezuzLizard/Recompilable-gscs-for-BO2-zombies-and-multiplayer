#include maps/mp/zombies/_zm;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

onplayerconnect_sq_fc()
{
	if ( !isDefined( level.sq_fc_still_valid ) )
	{
		level.sq_fc_still_valid = 1;
	}
	if ( flag( "afterlife_start_over" ) || !level.sq_fc_still_valid )
	{
		return;
	}
	self thread watch_for_touching_controls();
}

watch_for_touching_controls()
{
	self endon( "out_of_mana" );
	self endon( "disconnect" );
	self waittill( "al_all_setup" );
	wait 1;
	v_original_origin = ( self.origin[ 0 ], self.origin[ 1 ], 0 );
	v_original_angles = self.angles;
	v_forward_point = self.origin + ( anglesToForward( self.angles ) * 10 );
	v_original_forward_vec = vectornormalize( v_forward_point - self.origin );
	while ( !flag( "afterlife_start_over" ) && level.sq_fc_still_valid )
	{
		v_new_forward_point = self.origin + ( anglesToForward( self.angles ) * 10 );
		v_new_forward_vec = vectornormalize( v_new_forward_point - self.origin );
		move_length = length( ( self.origin[ 0 ], self.origin[ 1 ], 0 ) - v_original_origin );
		if ( !self actionslotonebuttonpressed() && !self actionslottwobuttonpressed() && !self actionslotthreebuttonpressed() && !self actionslotfourbuttonpressed() && !self adsbuttonpressed() && !self attackbuttonpressed() && !self fragbuttonpressed() && !self inventorybuttonpressed() && !self jumpbuttonpressed() && !self meleebuttonpressed() && !self secondaryoffhandbuttonpressed() && !self sprintbuttonpressed() && !self stancebuttonpressed() && !self throwbuttonpressed() && !self usebuttonpressed() && !self changeseatbuttonpressed() || move_length > 2 && vectordot( v_original_forward_vec, v_new_forward_vec ) < 0,99 )
		{
			level.sq_fc_still_valid = 0;
		}
		wait 0,05;
	}
	level notify( "someone_touched_controls" );
}

watch_for_trigger_condition()
{
	level waittill( "pre_end_game" );
	if ( !level.sq_fc_still_valid )
	{
		return;
	}
	level.sndgameovermusicoverride = "game_over_nomove";
	level.custom_intermission = ::player_intermission_prison;
	players = getplayers();
	_a94 = players;
	_k94 = getFirstArrayKey( _a94 );
	while ( isDefined( _k94 ) )
	{
		player = _a94[ _k94 ];
		maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_audio_log", player );
		_k94 = getNextArrayKey( _a94, _k94 );
	}
}

player_intermission_prison()
{
	self closemenu();
	self closeingamemenu();
	level endon( "stop_intermission" );
	self endon( "disconnect" );
	self endon( "death" );
	self notify( "_zombie_game_over" );
	self.score = self.score_total;
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	points = getstructarray( "dblock_cam", "targetname" );
	if ( !isDefined( points ) || points.size == 0 )
	{
		points = getentarray( "info_intermission", "classname" );
		if ( points.size < 1 )
		{
/#
			println( "NO info_intermission POINTS IN MAP" );
#/
			return;
		}
	}
	self.game_over_bg = newclienthudelem( self );
	self.game_over_bg.horzalign = "fullscreen";
	self.game_over_bg.vertalign = "fullscreen";
	self.game_over_bg setshader( "black", 640, 480 );
	self.game_over_bg.alpha = 1;
	visionsetnaked( "cheat_bw", 0,05 );
	org = undefined;
	while ( 1 )
	{
		points = array_randomize( points );
		i = 0;
		while ( i < points.size )
		{
			point = points[ i ];
			if ( !isDefined( org ) )
			{
				self spawn( point.origin, point.angles );
			}
			if ( isDefined( points[ i ].target ) )
			{
				if ( !isDefined( org ) )
				{
					org = spawn( "script_model", self.origin + vectorScale( ( 0, 0, -1 ), 60 ) );
					org setmodel( "tag_origin" );
				}
				org.origin = points[ i ].origin;
				org.angles = points[ i ].angles;
				j = 0;
				while ( j < get_players().size )
				{
					player = get_players()[ j ];
					player camerasetposition( org );
					player camerasetlookat();
					player cameraactivate( 1 );
					j++;
				}
				speed = 20;
				if ( isDefined( points[ i ].speed ) )
				{
					speed = points[ i ].speed;
				}
				target_point = getstruct( points[ i ].target, "targetname" );
				dist = distance( points[ i ].origin, target_point.origin );
				time = dist / speed;
				q_time = time * 0,25;
				if ( q_time > 1 )
				{
					q_time = 1;
				}
				self.game_over_bg fadeovertime( q_time );
				self.game_over_bg.alpha = 0;
				org moveto( target_point.origin, time, q_time, q_time );
				org rotateto( target_point.angles, time, q_time, q_time );
				wait ( time - q_time );
				self.game_over_bg fadeovertime( q_time );
				self.game_over_bg.alpha = 1;
				wait q_time;
				i++;
				continue;
			}
			else
			{
				self.game_over_bg fadeovertime( 1 );
				self.game_over_bg.alpha = 0;
				wait 5;
				self.game_over_bg thread maps/mp/zombies/_zm::fade_up_over_time( 1 );
			}
			i++;
		}
	}
}
