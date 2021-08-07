#include maps/mp/gametypes/_hud_message;
#include maps/mp/gametypes/_rank;
#include maps/mp/gametypes/_persistence;
#include maps/mp/_medals;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level.contractsettings = spawnstruct();
	level.contractsettings.waittime = 4,2;
	level.killstreaksettings = spawnstruct();
	level.killstreaksettings.waittime = 3;
	level.ranksettings = spawnstruct();
	level.ranksettings.waittime = 3;
	level.startmessage = spawnstruct();
	level.startmessagedefaultduration = 2;
	level.endmessagedefaultduration = 2;
	level.challengesettings = spawnstruct();
	level.challengesettings.waittime = 3;
	level.teammessage = spawnstruct();
	level.teammessage.waittime = 3;
	level.regulargamemessages = spawnstruct();
	level.regulargamemessages.waittime = 6;
	level.wagersettings = spawnstruct();
	level.wagersettings.waittime = 3;
	level.momentumnotifywaittime = 0;
	level.momentumnotifywaitlasttime = 0;
	level.teammessagequeuemax = 8;
	precachestring( &"KILLSTREAK_DESTROYED_UAV" );
	precachestring( &"KILLSTREAK_DESTROYED_COUNTERUAV" );
	precachestring( &"KILLSTREAK_DESTROYED_REMOTE_MORTAR" );
	precachestring( &"KILLSTREAK_MP40_INBOUND" );
	precachestring( &"KILLSTREAK_M220_TOW_INBOUND" );
	precachestring( &"KILLSTREAK_MINIGUN_INBOUND" );
	precachestring( &"KILLSTREAK_M202_FLASH_INBOUND" );
	precachestring( &"KILLSTREAK_M32_INBOUND" );
	precachestring( &"MP_CAPTURED_THE_FLAG" );
	precachestring( &"MP_KILLED_FLAG_CARRIER" );
	precachestring( &"MP_FRIENDLY_FLAG_DROPPED" );
	precachestring( &"MP_ENEMY_FLAG_DROPPED" );
	precachestring( &"MP_FRIENDLY_FLAG_RETURNED" );
	precachestring( &"MP_ENEMY_FLAG_RETURNED" );
	precachestring( &"MP_FRIENDLY_FLAG_TAKEN" );
	precachestring( &"MP_ENEMY_FLAG_TAKEN" );
	precachestring( &"MP_ENEMY_FLAG_CAPTURED" );
	precachestring( &"MP_FRIENDLY_FLAG_CAPTURED" );
	precachestring( &"MP_EXPLOSIVES_BLOWUP_BY" );
	precachestring( &"MP_EXPLOSIVES_DEFUSED_BY" );
	precachestring( &"MP_EXPLOSIVES_PLANTED_BY" );
	precachestring( &"MP_HQ_DESTROYED_BY" );
	precachestring( &"KILLSTREAK_DESTROYED_HELICOPTER" );
/#
	level thread popupsfromconsole();
#/
	level thread onplayerconnect();
}

popupsfromconsole()
{
/#
	while ( 1 )
	{
		timeout = getdvarintdefault( "scr_popuptime", 1 );
		if ( timeout == 0 )
		{
			timeout = 1;
		}
		wait timeout;
		medal = getdvarintdefault( "scr_popupmedal", 0 );
		challenge = getdvarintdefault( "scr_popupchallenge", 0 );
		rank = getdvarintdefault( "scr_popuprank", 0 );
		gun = getdvarintdefault( "scr_popupgun", 0 );
		contractpass = getdvarintdefault( "scr_popupcontractpass", 0 );
		contractfail = getdvarintdefault( "scr_popupcontractfail", 0 );
		gamemodemsg = getdvarintdefault( "scr_gamemodeslideout", 0 );
		teammsg = getdvarintdefault( "scr_teamslideout", 0 );
		challengeindex = getdvarintdefault( "scr_challengeIndex", 1 );
		i = 0;
		while ( i < medal )
		{
			level.players[ 0 ] maps/mp/_medals::codecallback_medal( 4 );
			i++;
		}
		i = 0;
		while ( i < challenge )
		{
			level.players[ 0 ] maps/mp/gametypes/_persistence::codecallback_challengecomplete( 2500, 1, 84, 3, 0, 0, 851 );
			level.players[ 0 ] maps/mp/gametypes/_persistence::codecallback_challengecomplete( 500, 1, 22, 2, 0, 0, 533 );
			i++;
		}
		i = 0;
		while ( i < rank )
		{
			level.players[ 0 ] maps/mp/gametypes/_rank::codecallback_rankup( 4, 0, 0 );
			i++;
		}
		i = 0;
		while ( i < gun )
		{
			level.players[ 0 ] maps/mp/gametypes/_persistence::codecallback_gunchallengecomplete( 0, 20, 25, 0 );
			i++;
		}
		i = 0;
		while ( i < contractpass )
		{
			level.players[ 0 ] maps/mp/gametypes/_persistence::addcontracttoqueue( 12, 1 );
			i++;
		}
		i = 0;
		while ( i < contractfail )
		{
			level.players[ 0 ] maps/mp/gametypes/_persistence::addcontracttoqueue( 12, 0 );
			i++;
		}
		i = 0;
		while ( i < teammsg )
		{
			player = level.players[ 0 ];
			if ( isDefined( level.players[ 1 ] ) )
			{
				player = level.players[ 1 ];
			}
			level.players[ 0 ] displayteammessagetoall( &"KILLSTREAK_DESTROYED_HELICOPTER", player );
			i++;
		}
		reset = getdvarintdefault( "scr_popupreset", 1 );
		if ( reset )
		{
			if ( medal )
			{
				setdvar( "scr_popupmedal", 0 );
			}
			if ( challenge )
			{
				setdvar( "scr_popupchallenge", 0 );
			}
			if ( gun )
			{
				setdvar( "scr_popupgun", 0 );
			}
			if ( rank )
			{
				setdvar( "scr_popuprank", 0 );
			}
			if ( contractpass )
			{
				setdvar( "scr_popupcontractpass", 0 );
			}
			if ( contractfail )
			{
				setdvar( "scr_popupcontractfail", 0 );
			}
			if ( gamemodemsg )
			{
				setdvar( "scr_gamemodeslideout", 0 );
			}
			if ( teammsg )
			{
				setdvar( "scr_teamslideout", 0 );
			}
		}
#/
	}
}

displaykillstreakteammessagetoall( killstreak, player )
{
	if ( !isDefined( level.killstreaks[ killstreak ] ) )
	{
		return;
	}
	if ( !isDefined( level.killstreaks[ killstreak ].inboundtext ) )
	{
		return;
	}
	message = level.killstreaks[ killstreak ].inboundtext;
	self displayteammessagetoall( message, player );
}

shoulddisplayteammessages()
{
	if ( level.hardcoremode == 1 || level.splitscreen == 1 )
	{
		return 0;
	}
	return 1;
}

displayteammessagetoall( message, player )
{
	if ( !shoulddisplayteammessages() )
	{
		return;
	}
	i = 0;
	while ( i < level.players.size )
	{
		cur_player = level.players[ i ];
		if ( cur_player isempjammed() )
		{
			i++;
			continue;
		}
		else size = cur_player.teammessagequeue.size;
		if ( size >= level.teammessagequeuemax )
		{
			i++;
			continue;
		}
		else
		{
			cur_player.teammessagequeue[ size ] = spawnstruct();
			cur_player.teammessagequeue[ size ].message = message;
			cur_player.teammessagequeue[ size ].player = player;
			cur_player notify( "received teammessage" );
		}
		i++;
	}
}

displayteammessagetoteam( message, player, team )
{
	if ( !shoulddisplayteammessages() )
	{
		return;
	}
	i = 0;
	while ( i < level.players.size )
	{
		cur_player = level.players[ i ];
		if ( cur_player.team != team )
		{
			i++;
			continue;
		}
		else if ( cur_player isempjammed() )
		{
			i++;
			continue;
		}
		else size = cur_player.teammessagequeue.size;
		if ( size >= level.teammessagequeuemax )
		{
			i++;
			continue;
		}
		else
		{
			cur_player.teammessagequeue[ size ] = spawnstruct();
			cur_player.teammessagequeue[ size ].message = message;
			cur_player.teammessagequeue[ size ].player = player;
			cur_player notify( "received teammessage" );
		}
		i++;
	}
}

displayteammessagewaiter()
{
	if ( !shoulddisplayteammessages() )
	{
		return;
	}
	self endon( "disconnect" );
	level endon( "game_ended" );
	self.teammessagequeue = [];
	for ( ;; )
	{
		if ( self.teammessagequeue.size == 0 )
		{
			self waittill( "received teammessage" );
		}
		if ( self.teammessagequeue.size > 0 )
		{
			nextnotifydata = self.teammessagequeue[ 0 ];
			arrayremoveindex( self.teammessagequeue, 0, 0 );
			if ( !isDefined( nextnotifydata.player ) || !isplayer( nextnotifydata.player ) )
			{
				continue;
			}
			else
			{
				if ( self isempjammed() )
				{
					break;
				}
				else
				{
					self luinotifyevent( &"player_callout", 2, nextnotifydata.message, nextnotifydata.player.entnum );
				}
				wait level.teammessage.waittime;
			}
		}
	}
}

displaypopupswaiter()
{
	self endon( "disconnect" );
	self.ranknotifyqueue = [];
	if ( !isDefined( self.pers[ "challengeNotifyQueue" ] ) )
	{
		self.pers[ "challengeNotifyQueue" ] = [];
	}
	if ( !isDefined( self.pers[ "contractNotifyQueue" ] ) )
	{
		self.pers[ "contractNotifyQueue" ] = [];
	}
	self.messagenotifyqueue = [];
	self.startmessagenotifyqueue = [];
	self.wagernotifyqueue = [];
	while ( !level.gameended )
	{
		if ( self.startmessagenotifyqueue.size == 0 && self.messagenotifyqueue.size == 0 )
		{
			self waittill( "received award" );
		}
		waittillframeend;
		if ( level.gameended )
		{
			return;
		}
		else
		{
			if ( self.startmessagenotifyqueue.size > 0 )
			{
				nextnotifydata = self.startmessagenotifyqueue[ 0 ];
				arrayremoveindex( self.startmessagenotifyqueue, 0, 0 );
				if ( isDefined( nextnotifydata.duration ) )
				{
					duration = nextnotifydata.duration;
				}
				else
				{
					duration = level.startmessagedefaultduration;
				}
				self maps/mp/gametypes/_hud_message::shownotifymessage( nextnotifydata, duration );
				wait duration;
				continue;
			}
			else if ( self.messagenotifyqueue.size > 0 )
			{
				nextnotifydata = self.messagenotifyqueue[ 0 ];
				arrayremoveindex( self.messagenotifyqueue, 0, 0 );
				if ( isDefined( nextnotifydata.duration ) )
				{
					duration = nextnotifydata.duration;
				}
				else
				{
					duration = level.regulargamemessages.waittime;
				}
				self maps/mp/gametypes/_hud_message::shownotifymessage( nextnotifydata, duration );
				continue;
			}
			else
			{
				wait 1;
			}
		}
	}
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player.resetgameoverhudrequired = 0;
		player thread displaypopupswaiter();
		if ( !level.hardcoremode )
		{
			player thread displayteammessagewaiter();
		}
	}
}

milestonenotify( index, itemindex, type, tier )
{
	level.globalchallenges++;
	if ( !isDefined( type ) )
	{
		type = "global";
	}
	size = self.pers[ "challengeNotifyQueue" ].size;
	self.pers[ "challengeNotifyQueue" ][ size ] = [];
	self.pers[ "challengeNotifyQueue" ][ size ][ "tier" ] = tier;
	self.pers[ "challengeNotifyQueue" ][ size ][ "index" ] = index;
	self.pers[ "challengeNotifyQueue" ][ size ][ "itemIndex" ] = itemindex;
	self.pers[ "challengeNotifyQueue" ][ size ][ "type" ] = type;
	self notify( "received award" );
}
