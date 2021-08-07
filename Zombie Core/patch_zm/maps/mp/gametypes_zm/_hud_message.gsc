#include maps/mp/_utility;
#include maps/mp/gametypes_zm/_globallogic_audio;
#include maps/mp/_music;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	precachestring( &"MENU_POINTS" );
	precachestring( &"MP_FIRSTPLACE_NAME" );
	precachestring( &"MP_SECONDPLACE_NAME" );
	precachestring( &"MP_THIRDPLACE_NAME" );
	precachestring( &"MP_WAGER_PLACE_NAME" );
	precachestring( &"MP_MATCH_BONUS_IS" );
	precachestring( &"MP_CODPOINTS_MATCH_BONUS_IS" );
	precachestring( &"MP_WAGER_WINNINGS_ARE" );
	precachestring( &"MP_WAGER_SIDEBET_WINNINGS_ARE" );
	precachestring( &"MP_WAGER_IN_THE_MONEY" );
	precachestring( &"faction_popup" );
	game[ "strings" ][ "draw" ] = &"MP_DRAW_CAPS";
	game[ "strings" ][ "round_draw" ] = &"MP_ROUND_DRAW_CAPS";
	game[ "strings" ][ "round_win" ] = &"MP_ROUND_WIN_CAPS";
	game[ "strings" ][ "round_loss" ] = &"MP_ROUND_LOSS_CAPS";
	game[ "strings" ][ "victory" ] = &"MP_VICTORY_CAPS";
	game[ "strings" ][ "defeat" ] = &"MP_DEFEAT_CAPS";
	game[ "strings" ][ "game_over" ] = &"MP_GAME_OVER_CAPS";
	game[ "strings" ][ "halftime" ] = &"MP_HALFTIME_CAPS";
	game[ "strings" ][ "overtime" ] = &"MP_OVERTIME_CAPS";
	game[ "strings" ][ "roundend" ] = &"MP_ROUNDEND_CAPS";
	game[ "strings" ][ "intermission" ] = &"MP_INTERMISSION_CAPS";
	game[ "strings" ][ "side_switch" ] = &"MP_SWITCHING_SIDES_CAPS";
	game[ "strings" ][ "match_bonus" ] = &"MP_MATCH_BONUS_IS";
	game[ "strings" ][ "codpoints_match_bonus" ] = &"MP_CODPOINTS_MATCH_BONUS_IS";
	game[ "strings" ][ "wager_winnings" ] = &"MP_WAGER_WINNINGS_ARE";
	game[ "strings" ][ "wager_sidebet_winnings" ] = &"MP_WAGER_SIDEBET_WINNINGS_ARE";
	game[ "strings" ][ "wager_inthemoney" ] = &"MP_WAGER_IN_THE_MONEY_CAPS";
	game[ "strings" ][ "wager_loss" ] = &"MP_WAGER_LOSS_CAPS";
	game[ "strings" ][ "wager_topwinners" ] = &"MP_WAGER_TOPWINNERS";
	game[ "menu_endgameupdate" ] = "endgameupdate";
	precachemenu( game[ "menu_endgameupdate" ] );
	level thread onplayerconnect();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread hintmessagedeaththink();
		player thread lowermessagethink();
		player thread initnotifymessage();
		player thread initcustomgametypeheader();
	}
}

initcustomgametypeheader()
{
	font = "default";
	titlesize = 2,5;
	self.customgametypeheader = createfontstring( font, titlesize );
	self.customgametypeheader setpoint( "TOP", undefined, 0, 30 );
	self.customgametypeheader.glowalpha = 1;
	self.customgametypeheader.hidewheninmenu = 1;
	self.customgametypeheader.archived = 0;
	self.customgametypeheader.color = ( 1, 1, 0,6 );
	self.customgametypeheader.alpha = 1;
	titlesize = 2;
	self.customgametypesubheader = createfontstring( font, titlesize );
	self.customgametypesubheader setparent( self.customgametypeheader );
	self.customgametypesubheader setpoint( "TOP", "BOTTOM", 0, 0 );
	self.customgametypesubheader.glowalpha = 1;
	self.customgametypesubheader.hidewheninmenu = 1;
	self.customgametypesubheader.archived = 0;
	self.customgametypesubheader.color = ( 1, 1, 0,6 );
	self.customgametypesubheader.alpha = 1;
}

hintmessage( hinttext, duration )
{
	notifydata = spawnstruct();
	notifydata.notifytext = hinttext;
	notifydata.duration = duration;
	notifymessage( notifydata );
}

hintmessageplayers( players, hinttext, duration )
{
	notifydata = spawnstruct();
	notifydata.notifytext = hinttext;
	notifydata.duration = duration;
	i = 0;
	while ( i < players.size )
	{
		players[ i ] notifymessage( notifydata );
		i++;
	}
}

showinitialfactionpopup( team )
{
	self luinotifyevent( &"faction_popup", 1, game[ "strings" ][ team + "_name" ] );
	maps/mp/gametypes_zm/_hud_message::oldnotifymessage( undefined, undefined, undefined, undefined );
}

initnotifymessage()
{
	if ( !sessionmodeiszombiesgame() )
	{
		if ( self issplitscreen() )
		{
			titlesize = 2;
			textsize = 1,4;
			iconsize = 24;
			font = "extrabig";
			point = "TOP";
			relativepoint = "BOTTOM";
			yoffset = 30;
			xoffset = 30;
		}
		else
		{
			titlesize = 2,5;
			textsize = 1,75;
			iconsize = 30;
			font = "extrabig";
			point = "TOP";
			relativepoint = "BOTTOM";
			yoffset = 0;
			xoffset = 0;
		}
	}
	else if ( self issplitscreen() )
	{
		titlesize = 2;
		textsize = 1,4;
		iconsize = 24;
		font = "extrabig";
		point = "TOP";
		relativepoint = "BOTTOM";
		yoffset = 30;
		xoffset = 30;
	}
	else
	{
		titlesize = 2,5;
		textsize = 1,75;
		iconsize = 30;
		font = "extrabig";
		point = "BOTTOM LEFT";
		relativepoint = "TOP";
		yoffset = 0;
		xoffset = 0;
	}
	self.notifytitle = createfontstring( font, titlesize );
	self.notifytitle setpoint( point, undefined, xoffset, yoffset );
	self.notifytitle.glowalpha = 1;
	self.notifytitle.hidewheninmenu = 1;
	self.notifytitle.archived = 0;
	self.notifytitle.alpha = 0;
	self.notifytext = createfontstring( font, textsize );
	self.notifytext setparent( self.notifytitle );
	self.notifytext setpoint( point, relativepoint, 0, 0 );
	self.notifytext.glowalpha = 1;
	self.notifytext.hidewheninmenu = 1;
	self.notifytext.archived = 0;
	self.notifytext.alpha = 0;
	self.notifytext2 = createfontstring( font, textsize );
	self.notifytext2 setparent( self.notifytitle );
	self.notifytext2 setpoint( point, relativepoint, 0, 0 );
	self.notifytext2.glowalpha = 1;
	self.notifytext2.hidewheninmenu = 1;
	self.notifytext2.archived = 0;
	self.notifytext2.alpha = 0;
	self.notifyicon = createicon( "white", iconsize, iconsize );
	self.notifyicon setparent( self.notifytext2 );
	self.notifyicon setpoint( point, relativepoint, 0, 0 );
	self.notifyicon.hidewheninmenu = 1;
	self.notifyicon.archived = 0;
	self.notifyicon.alpha = 0;
	self.doingnotify = 0;
	self.notifyqueue = [];
}

oldnotifymessage( titletext, notifytext, iconname, glowcolor, sound, duration )
{
	if ( level.wagermatch && !level.teambased )
	{
		return;
	}
	notifydata = spawnstruct();
	notifydata.titletext = titletext;
	notifydata.notifytext = notifytext;
	notifydata.iconname = iconname;
	notifydata.sound = sound;
	notifydata.duration = duration;
	self.startmessagenotifyqueue[ self.startmessagenotifyqueue.size ] = notifydata;
	self notify( "received award" );
}

notifymessage( notifydata )
{
	self endon( "death" );
	self endon( "disconnect" );
	self.messagenotifyqueue[ self.messagenotifyqueue.size ] = notifydata;
	self notify( "received award" );
}

shownotifymessage( notifydata, duration )
{
	self endon( "disconnect" );
	self.doingnotify = 1;
	waitrequirevisibility( 0 );
	self notify( "notifyMessageBegin" );
	self thread resetoncancel();
	if ( isDefined( notifydata.sound ) )
	{
		self playlocalsound( notifydata.sound );
	}
	if ( isDefined( notifydata.musicstate ) )
	{
		self maps/mp/_music::setmusicstate( notifydata.music );
	}
	if ( isDefined( notifydata.leadersound ) )
	{
		self maps/mp/gametypes_zm/_globallogic_audio::leaderdialogonplayer( notifydata.leadersound );
	}
	if ( isDefined( notifydata.glowcolor ) )
	{
		glowcolor = notifydata.glowcolor;
	}
	else
	{
		glowcolor = ( 1, 1, 1 );
	}
	if ( isDefined( notifydata.color ) )
	{
		color = notifydata.color;
	}
	else
	{
		color = ( 1, 1, 1 );
	}
	anchorelem = self.notifytitle;
	if ( isDefined( notifydata.titletext ) )
	{
		if ( isDefined( notifydata.titlelabel ) )
		{
			self.notifytitle.label = notifydata.titlelabel;
		}
		else
		{
			self.notifytitle.label = &"";
		}
		if ( isDefined( notifydata.titlelabel ) && !isDefined( notifydata.titleisstring ) )
		{
			self.notifytitle setvalue( notifydata.titletext );
		}
		else
		{
			self.notifytitle settext( notifydata.titletext );
		}
		self.notifytitle setcod7decodefx( 200, int( duration * 1000 ), 600 );
		self.notifytitle.glowcolor = glowcolor;
		self.notifytitle.color = color;
		self.notifytitle.alpha = 1;
	}
	if ( isDefined( notifydata.notifytext ) )
	{
		if ( isDefined( notifydata.textlabel ) )
		{
			self.notifytext.label = notifydata.textlabel;
		}
		else
		{
			self.notifytext.label = &"";
		}
		if ( isDefined( notifydata.textlabel ) && !isDefined( notifydata.textisstring ) )
		{
			self.notifytext setvalue( notifydata.notifytext );
		}
		else
		{
			self.notifytext settext( notifydata.notifytext );
		}
		self.notifytext setcod7decodefx( 100, int( duration * 1000 ), 600 );
		self.notifytext.glowcolor = glowcolor;
		self.notifytext.color = color;
		self.notifytext.alpha = 1;
		anchorelem = self.notifytext;
	}
	if ( isDefined( notifydata.notifytext2 ) )
	{
		if ( self issplitscreen() )
		{
			if ( isDefined( notifydata.text2label ) )
			{
				self iprintlnbold( notifydata.text2label, notifydata.notifytext2 );
			}
			else
			{
				self iprintlnbold( notifydata.notifytext2 );
			}
		}
		else
		{
			self.notifytext2 setparent( anchorelem );
			if ( isDefined( notifydata.text2label ) )
			{
				self.notifytext2.label = notifydata.text2label;
			}
			else
			{
				self.notifytext2.label = &"";
			}
			self.notifytext2 settext( notifydata.notifytext2 );
			self.notifytext2 setpulsefx( 100, int( duration * 1000 ), 1000 );
			self.notifytext2.glowcolor = glowcolor;
			self.notifytext2.color = color;
			self.notifytext2.alpha = 1;
			anchorelem = self.notifytext2;
		}
	}
	if ( isDefined( notifydata.iconname ) )
	{
		iconwidth = 60;
		iconheight = 60;
		if ( isDefined( notifydata.iconwidth ) )
		{
			iconwidth = notifydata.iconwidth;
		}
		if ( isDefined( notifydata.iconheight ) )
		{
			iconheight = notifydata.iconheight;
		}
		self.notifyicon setparent( anchorelem );
		self.notifyicon setshader( notifydata.iconname, iconwidth, iconheight );
		self.notifyicon.alpha = 0;
		self.notifyicon fadeovertime( 1 );
		self.notifyicon.alpha = 1;
		waitrequirevisibility( duration );
		self.notifyicon fadeovertime( 0,75 );
		self.notifyicon.alpha = 0;
	}
	else
	{
		waitrequirevisibility( duration );
	}
	self notify( "notifyMessageDone" );
	self.doingnotify = 0;
}

waitrequirevisibility( waittime )
{
	interval = 0,05;
	while ( !self canreadtext() )
	{
		wait interval;
	}
	while ( waittime > 0 )
	{
		wait interval;
		if ( self canreadtext() )
		{
			waittime -= interval;
		}
	}
}

canreadtext()
{
	return 1;
}

resetondeath()
{
	self endon( "notifyMessageDone" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self waittill( "death" );
	resetnotify();
}

resetoncancel()
{
	self notify( "resetOnCancel" );
	self endon( "resetOnCancel" );
	self endon( "notifyMessageDone" );
	self endon( "disconnect" );
	level waittill( "cancel_notify" );
	resetnotify();
}

resetnotify()
{
	self.notifytitle.alpha = 0;
	self.notifytext.alpha = 0;
	self.notifyicon.alpha = 0;
	self.doingnotify = 0;
}

hintmessagedeaththink()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "death" );
		if ( isDefined( self.hintmessage ) )
		{
			self.hintmessage destroyelem();
		}
	}
}

lowermessagethink()
{
	self endon( "disconnect" );
	self.lowermessage = createfontstring( "default", level.lowertextfontsize );
	self.lowermessage setpoint( "CENTER", level.lowertextyalign, 0, level.lowertexty );
	self.lowermessage settext( "" );
	self.lowermessage.archived = 0;
	timerfontsize = 1,5;
	if ( self issplitscreen() )
	{
		timerfontsize = 1,4;
	}
	self.lowertimer = createfontstring( "default", timerfontsize );
	self.lowertimer setparent( self.lowermessage );
	self.lowertimer setpoint( "TOP", "BOTTOM", 0, 0 );
	self.lowertimer settext( "" );
	self.lowertimer.archived = 0;
}

setmatchscorehudelemforteam( team )
{
	if ( level.roundscorecarry )
	{
		self setvalue( getteamscore( team ) );
	}
	else
	{
		self setvalue( getroundswon( team ) );
	}
}

teamoutcomenotify( winner, isround, endreasontext )
{
	self endon( "disconnect" );
	self notify( "reset_outcome" );
	team = self.pers[ "team" ];
	while ( isDefined( team ) && team == "spectator" )
	{
		i = 0;
		while ( i < level.players.size )
		{
			if ( self.currentspectatingclient == level.players[ i ].clientid )
			{
				team = level.players[ i ].pers[ "team" ];
				break;
			}
			else
			{
				i++;
			}
		}
	}
	if ( !isDefined( team ) || !isDefined( level.teams[ team ] ) )
	{
		team = "allies";
	}
	while ( self.doingnotify )
	{
		wait 0,05;
	}
	self endon( "reset_outcome" );
	headerfont = "extrabig";
	font = "default";
	if ( self issplitscreen() )
	{
		titlesize = 2;
		textsize = 1,5;
		iconsize = 30;
		spacing = 10;
	}
	else
	{
		titlesize = 3;
		textsize = 2;
		iconsize = 70;
		spacing = 25;
	}
	duration = 60000;
	outcometitle = createfontstring( headerfont, titlesize );
	outcometitle setpoint( "TOP", undefined, 0, 30 );
	outcometitle.glowalpha = 1;
	outcometitle.hidewheninmenu = 0;
	outcometitle.archived = 0;
	outcometext = createfontstring( font, 2 );
	outcometext setparent( outcometitle );
	outcometext setpoint( "TOP", "BOTTOM", 0, 0 );
	outcometext.glowalpha = 1;
	outcometext.hidewheninmenu = 0;
	outcometext.archived = 0;
	if ( winner == "halftime" )
	{
		outcometitle settext( game[ "strings" ][ "halftime" ] );
		outcometitle.color = ( 1, 1, 1 );
		winner = "allies";
	}
	else if ( winner == "intermission" )
	{
		outcometitle settext( game[ "strings" ][ "intermission" ] );
		outcometitle.color = ( 1, 1, 1 );
		winner = "allies";
	}
	else if ( winner == "roundend" )
	{
		outcometitle settext( game[ "strings" ][ "roundend" ] );
		outcometitle.color = ( 1, 1, 1 );
		winner = "allies";
	}
	else if ( winner == "overtime" )
	{
		outcometitle settext( game[ "strings" ][ "overtime" ] );
		outcometitle.color = ( 1, 1, 1 );
		winner = "allies";
	}
	else if ( winner == "tie" )
	{
		if ( isround )
		{
			outcometitle settext( game[ "strings" ][ "round_draw" ] );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "draw" ] );
		}
		outcometitle.color = ( 0,29, 0,61, 0,7 );
		winner = "allies";
	}
	else if ( isDefined( self.pers[ "team" ] ) && winner == team )
	{
		if ( isround )
		{
			outcometitle settext( game[ "strings" ][ "round_win" ] );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "victory" ] );
		}
		outcometitle.color = ( 0,42, 0,68, 0,46 );
	}
	else
	{
		if ( isround )
		{
			outcometitle settext( game[ "strings" ][ "round_loss" ] );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "defeat" ] );
		}
		outcometitle.color = ( 0,73, 0,29, 0,19 );
	}
	outcometext settext( endreasontext );
	outcometitle setcod7decodefx( 200, duration, 600 );
	outcometext setpulsefx( 100, duration, 1000 );
	iconspacing = 100;
	currentx = ( ( level.teamcount - 1 ) * -1 * iconspacing ) / 2;
	teamicons = [];
	teamicons[ team ] = createicon( game[ "icons" ][ team ], iconsize, iconsize );
	teamicons[ team ] setparent( outcometext );
	teamicons[ team ] setpoint( "TOP", "BOTTOM", currentx, spacing );
	teamicons[ team ].hidewheninmenu = 0;
	teamicons[ team ].archived = 0;
	teamicons[ team ].alpha = 0;
	teamicons[ team ] fadeovertime( 0,5 );
	teamicons[ team ].alpha = 1;
	currentx += iconspacing;
	_a607 = level.teams;
	_k607 = getFirstArrayKey( _a607 );
	while ( isDefined( _k607 ) )
	{
		enemyteam = _a607[ _k607 ];
		if ( team == enemyteam )
		{
		}
		else
		{
			teamicons[ enemyteam ] = createicon( game[ "icons" ][ enemyteam ], iconsize, iconsize );
			teamicons[ enemyteam ] setparent( outcometext );
			teamicons[ enemyteam ] setpoint( "TOP", "BOTTOM", currentx, spacing );
			teamicons[ enemyteam ].hidewheninmenu = 0;
			teamicons[ enemyteam ].archived = 0;
			teamicons[ enemyteam ].alpha = 0;
			teamicons[ enemyteam ] fadeovertime( 0,5 );
			teamicons[ enemyteam ].alpha = 1;
			currentx += iconspacing;
		}
		_k607 = getNextArrayKey( _a607, _k607 );
	}
	teamscores = [];
	teamscores[ team ] = createfontstring( font, titlesize );
	teamscores[ team ] setparent( teamicons[ team ] );
	teamscores[ team ] setpoint( "TOP", "BOTTOM", 0, spacing );
	teamscores[ team ].glowalpha = 1;
	if ( isround )
	{
		teamscores[ team ] setvalue( getteamscore( team ) );
	}
	else
	{
		teamscores[ team ] [[ level.setmatchscorehudelemforteam ]]( team );
	}
	teamscores[ team ].hidewheninmenu = 0;
	teamscores[ team ].archived = 0;
	teamscores[ team ] setpulsefx( 100, duration, 1000 );
	_a641 = level.teams;
	_k641 = getFirstArrayKey( _a641 );
	while ( isDefined( _k641 ) )
	{
		enemyteam = _a641[ _k641 ];
		if ( team == enemyteam )
		{
		}
		else
		{
			teamscores[ enemyteam ] = createfontstring( headerfont, titlesize );
			teamscores[ enemyteam ] setparent( teamicons[ enemyteam ] );
			teamscores[ enemyteam ] setpoint( "TOP", "BOTTOM", 0, spacing );
			teamscores[ enemyteam ].glowalpha = 1;
			if ( isround )
			{
				teamscores[ enemyteam ] setvalue( getteamscore( enemyteam ) );
			}
			else
			{
				teamscores[ enemyteam ] [[ level.setmatchscorehudelemforteam ]]( enemyteam );
			}
			teamscores[ enemyteam ].hidewheninmenu = 0;
			teamscores[ enemyteam ].archived = 0;
			teamscores[ enemyteam ] setpulsefx( 100, duration, 1000 );
		}
		_k641 = getNextArrayKey( _a641, _k641 );
	}
	font = "objective";
	matchbonus = undefined;
	if ( isDefined( self.matchbonus ) )
	{
		matchbonus = createfontstring( font, 2 );
		matchbonus setparent( outcometext );
		matchbonus setpoint( "TOP", "BOTTOM", 0, iconsize + ( spacing * 3 ) + teamscores[ team ].height );
		matchbonus.glowalpha = 1;
		matchbonus.hidewheninmenu = 0;
		matchbonus.archived = 0;
		matchbonus.label = game[ "strings" ][ "match_bonus" ];
		matchbonus setvalue( self.matchbonus );
	}
	self thread resetoutcomenotify( teamicons, teamscores, outcometitle, outcometext );
}

teamoutcomenotifyzombie( winner, isround, endreasontext )
{
	self endon( "disconnect" );
	self notify( "reset_outcome" );
	team = self.pers[ "team" ];
	while ( isDefined( team ) && team == "spectator" )
	{
		i = 0;
		while ( i < level.players.size )
		{
			if ( self.currentspectatingclient == level.players[ i ].clientid )
			{
				team = level.players[ i ].pers[ "team" ];
				break;
			}
			else
			{
				i++;
			}
		}
	}
	if ( !isDefined( team ) || !isDefined( level.teams[ team ] ) )
	{
		team = "allies";
	}
	while ( self.doingnotify )
	{
		wait 0,05;
	}
	self endon( "reset_outcome" );
	if ( self issplitscreen() )
	{
		titlesize = 2;
		spacing = 10;
		font = "default";
	}
	else
	{
		titlesize = 3;
		spacing = 50;
		font = "objective";
	}
	outcometitle = createfontstring( font, titlesize );
	outcometitle setpoint( "TOP", undefined, 0, spacing );
	outcometitle.glowalpha = 1;
	outcometitle.hidewheninmenu = 0;
	outcometitle.archived = 0;
	outcometitle settext( endreasontext );
	outcometitle setpulsefx( 100, 60000, 1000 );
	self thread resetoutcomenotify( undefined, undefined, outcometitle );
}

outcomenotify( winner, isroundend, endreasontext )
{
	self endon( "disconnect" );
	self notify( "reset_outcome" );
	while ( self.doingnotify )
	{
		wait 0,05;
	}
	self endon( "reset_outcome" );
	headerfont = "extrabig";
	font = "default";
	if ( self issplitscreen() )
	{
		titlesize = 2;
		winnersize = 1,5;
		othersize = 1,5;
		iconsize = 30;
		spacing = 10;
	}
	else
	{
		titlesize = 3;
		winnersize = 2;
		othersize = 1,5;
		iconsize = 30;
		spacing = 20;
	}
	duration = 60000;
	players = level.placement[ "all" ];
	outcometitle = createfontstring( headerfont, titlesize );
	outcometitle setpoint( "TOP", undefined, 0, spacing );
	if ( !maps/mp/_utility::isoneround() && !isroundend )
	{
		outcometitle settext( game[ "strings" ][ "game_over" ] );
	}
	else
	{
		if ( isDefined( players[ 1 ] ) && players[ 0 ].score == players[ 1 ].score && players[ 0 ].deaths == players[ 1 ].deaths || self == players[ 0 ] && self == players[ 1 ] )
		{
			outcometitle settext( game[ "strings" ][ "tie" ] );
		}
		else
		{
			if ( isDefined( players[ 2 ] ) && players[ 0 ].score == players[ 2 ].score && players[ 0 ].deaths == players[ 2 ].deaths && self == players[ 2 ] )
			{
				outcometitle settext( game[ "strings" ][ "tie" ] );
			}
			else
			{
				if ( isDefined( players[ 0 ] ) && self == players[ 0 ] )
				{
					outcometitle settext( game[ "strings" ][ "victory" ] );
					outcometitle.color = ( 0,42, 0,68, 0,46 );
				}
				else
				{
					outcometitle settext( game[ "strings" ][ "defeat" ] );
					outcometitle.color = ( 0,73, 0,29, 0,19 );
				}
			}
		}
	}
	outcometitle.glowalpha = 1;
	outcometitle.hidewheninmenu = 0;
	outcometitle.archived = 0;
	outcometitle setcod7decodefx( 200, duration, 600 );
	outcometext = createfontstring( font, 2 );
	outcometext setparent( outcometitle );
	outcometext setpoint( "TOP", "BOTTOM", 0, 0 );
	outcometext.glowalpha = 1;
	outcometext.hidewheninmenu = 0;
	outcometext.archived = 0;
	outcometext settext( endreasontext );
	firsttitle = createfontstring( font, winnersize );
	firsttitle setparent( outcometext );
	firsttitle setpoint( "TOP", "BOTTOM", 0, spacing );
	firsttitle.glowalpha = 1;
	firsttitle.hidewheninmenu = 0;
	firsttitle.archived = 0;
	if ( isDefined( players[ 0 ] ) )
	{
		firsttitle.label = &"MP_FIRSTPLACE_NAME";
		firsttitle setplayernamestring( players[ 0 ] );
		firsttitle setcod7decodefx( 175, duration, 600 );
	}
	secondtitle = createfontstring( font, othersize );
	secondtitle setparent( firsttitle );
	secondtitle setpoint( "TOP", "BOTTOM", 0, spacing );
	secondtitle.glowalpha = 1;
	secondtitle.hidewheninmenu = 0;
	secondtitle.archived = 0;
	if ( isDefined( players[ 1 ] ) )
	{
		secondtitle.label = &"MP_SECONDPLACE_NAME";
		secondtitle setplayernamestring( players[ 1 ] );
		secondtitle setcod7decodefx( 175, duration, 600 );
	}
	thirdtitle = createfontstring( font, othersize );
	thirdtitle setparent( secondtitle );
	thirdtitle setpoint( "TOP", "BOTTOM", 0, spacing );
	thirdtitle setparent( secondtitle );
	thirdtitle.glowalpha = 1;
	thirdtitle.hidewheninmenu = 0;
	thirdtitle.archived = 0;
	if ( isDefined( players[ 2 ] ) )
	{
		thirdtitle.label = &"MP_THIRDPLACE_NAME";
		thirdtitle setplayernamestring( players[ 2 ] );
		thirdtitle setcod7decodefx( 175, duration, 600 );
	}
	matchbonus = createfontstring( font, 2 );
	matchbonus setparent( thirdtitle );
	matchbonus setpoint( "TOP", "BOTTOM", 0, spacing );
	matchbonus.glowalpha = 1;
	matchbonus.hidewheninmenu = 0;
	matchbonus.archived = 0;
	if ( isDefined( self.matchbonus ) )
	{
		matchbonus.label = game[ "strings" ][ "match_bonus" ];
		matchbonus setvalue( self.matchbonus );
	}
	self thread updateoutcome( firsttitle, secondtitle, thirdtitle );
	self thread resetoutcomenotify( undefined, undefined, outcometitle, outcometext, firsttitle, secondtitle, thirdtitle, matchbonus );
}

wageroutcomenotify( winner, endreasontext )
{
	self endon( "disconnect" );
	self notify( "reset_outcome" );
	while ( self.doingnotify )
	{
		wait 0,05;
	}
	setmatchflag( "enable_popups", 0 );
	self endon( "reset_outcome" );
	headerfont = "extrabig";
	font = "objective";
	if ( self issplitscreen() )
	{
		titlesize = 2;
		winnersize = 1,5;
		othersize = 1,5;
		iconsize = 30;
		spacing = 2;
	}
	else
	{
		titlesize = 3;
		winnersize = 2;
		othersize = 1,5;
		iconsize = 30;
		spacing = 20;
	}
	halftime = 0;
	if ( isDefined( level.sidebet ) && level.sidebet )
	{
		halftime = 1;
	}
	duration = 60000;
	players = level.placement[ "all" ];
	outcometitle = createfontstring( headerfont, titlesize );
	outcometitle setpoint( "TOP", undefined, 0, spacing );
	if ( halftime )
	{
		outcometitle settext( game[ "strings" ][ "intermission" ] );
		outcometitle.color = ( 1, 1, 1 );
		outcometitle.glowcolor = ( 1, 1, 1 );
	}
	else if ( isDefined( level.dontcalcwagerwinnings ) && level.dontcalcwagerwinnings == 1 )
	{
		outcometitle settext( game[ "strings" ][ "wager_topwinners" ] );
		outcometitle.color = ( 0,42, 0,68, 0,46 );
	}
	else
	{
		if ( isDefined( self.wagerwinnings ) && self.wagerwinnings > 0 )
		{
			outcometitle settext( game[ "strings" ][ "wager_inthemoney" ] );
			outcometitle.color = ( 0,42, 0,68, 0,46 );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "wager_loss" ] );
			outcometitle.color = ( 0,73, 0,29, 0,19 );
		}
	}
	outcometitle.glowalpha = 1;
	outcometitle.hidewheninmenu = 0;
	outcometitle.archived = 0;
	outcometitle setcod7decodefx( 200, duration, 600 );
	outcometext = createfontstring( font, 2 );
	outcometext setparent( outcometitle );
	outcometext setpoint( "TOP", "BOTTOM", 0, 0 );
	outcometext.glowalpha = 1;
	outcometext.hidewheninmenu = 0;
	outcometext.archived = 0;
	outcometext settext( endreasontext );
	playernamehudelems = [];
	playercphudelems = [];
	numplayers = players.size;
	i = 0;
	while ( i < numplayers )
	{
		if ( !halftime && isDefined( players[ i ] ) )
		{
			secondtitle = createfontstring( font, othersize );
			if ( playernamehudelems.size == 0 )
			{
				secondtitle setparent( outcometext );
				secondtitle setpoint( "TOP_LEFT", "BOTTOM", -175, spacing * 3 );
			}
			else
			{
				secondtitle setparent( playernamehudelems[ playernamehudelems.size - 1 ] );
				secondtitle setpoint( "TOP_LEFT", "BOTTOM_LEFT", 0, spacing );
			}
			secondtitle.glowalpha = 1;
			secondtitle.hidewheninmenu = 0;
			secondtitle.archived = 0;
			secondtitle.label = &"MP_WAGER_PLACE_NAME";
			secondtitle.playernum = i;
			secondtitle setplayernamestring( players[ i ] );
			playernamehudelems[ playernamehudelems.size ] = secondtitle;
			secondcp = createfontstring( font, othersize );
			secondcp setparent( secondtitle );
			secondcp setpoint( "TOP_RIGHT", "TOP_LEFT", 350, 0 );
			secondcp.glowalpha = 1;
			secondcp.hidewheninmenu = 0;
			secondcp.archived = 0;
			secondcp.label = &"MENU_POINTS";
			secondcp.currentvalue = 0;
			if ( isDefined( players[ i ].wagerwinnings ) )
			{
				secondcp.targetvalue = players[ i ].wagerwinnings;
			}
			else
			{
				secondcp.targetvalue = 0;
			}
			if ( secondcp.targetvalue > 0 )
			{
				secondcp.color = ( 0,42, 0,68, 0,46 );
			}
			secondcp setvalue( 0 );
			playercphudelems[ playercphudelems.size ] = secondcp;
		}
		i++;
	}
	self thread updatewageroutcome( playernamehudelems, playercphudelems );
	self thread resetwageroutcomenotify( playernamehudelems, playercphudelems, outcometitle, outcometext );
	if ( halftime )
	{
		return;
	}
	stillupdating = 1;
	countupduration = 2;
	cpincrement = 9999;
	if ( isDefined( playercphudelems[ 0 ] ) )
	{
		cpincrement = int( playercphudelems[ 0 ].targetvalue / ( countupduration / 0,05 ) );
		if ( cpincrement < 1 )
		{
			cpincrement = 1;
		}
	}
	while ( stillupdating )
	{
		stillupdating = 0;
		i = 0;
		while ( i < playercphudelems.size )
		{
			if ( isDefined( playercphudelems[ i ] ) && playercphudelems[ i ].currentvalue < playercphudelems[ i ].targetvalue )
			{
				playercphudelems[ i ].currentvalue += cpincrement;
				if ( playercphudelems[ i ].currentvalue > playercphudelems[ i ].targetvalue )
				{
					playercphudelems[ i ].currentvalue = playercphudelems[ i ].targetvalue;
				}
				playercphudelems[ i ] setvalue( playercphudelems[ i ].currentvalue );
				stillupdating = 1;
			}
			i++;
		}
		wait 0,05;
	}
}

teamwageroutcomenotify( winner, isroundend, endreasontext )
{
	self endon( "disconnect" );
	self notify( "reset_outcome" );
	team = self.pers[ "team" ];
	if ( !isDefined( team ) || !isDefined( level.teams[ team ] ) )
	{
		team = "allies";
	}
	wait 0,05;
	while ( self.doingnotify )
	{
		wait 0,05;
	}
	self endon( "reset_outcome" );
	headerfont = "extrabig";
	font = "objective";
	if ( self issplitscreen() )
	{
		titlesize = 2;
		textsize = 1,5;
		iconsize = 30;
		spacing = 10;
	}
	else
	{
		titlesize = 3;
		textsize = 2;
		iconsize = 70;
		spacing = 15;
	}
	halftime = 0;
	if ( isDefined( level.sidebet ) && level.sidebet )
	{
		halftime = 1;
	}
	duration = 60000;
	outcometitle = createfontstring( headerfont, titlesize );
	outcometitle setpoint( "TOP", undefined, 0, spacing );
	outcometitle.glowalpha = 1;
	outcometitle.hidewheninmenu = 0;
	outcometitle.archived = 0;
	outcometext = createfontstring( font, 2 );
	outcometext setparent( outcometitle );
	outcometext setpoint( "TOP", "BOTTOM", 0, 0 );
	outcometext.glowalpha = 1;
	outcometext.hidewheninmenu = 0;
	outcometext.archived = 0;
	if ( winner == "tie" )
	{
		if ( isroundend )
		{
			outcometitle settext( game[ "strings" ][ "round_draw" ] );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "draw" ] );
		}
		outcometitle.color = ( 1, 1, 1 );
		winner = "allies";
	}
	else if ( winner == "overtime" )
	{
		outcometitle settext( game[ "strings" ][ "overtime" ] );
		outcometitle.color = ( 1, 1, 1 );
	}
	else if ( isDefined( self.pers[ "team" ] ) && winner == team )
	{
		if ( isroundend )
		{
			outcometitle settext( game[ "strings" ][ "round_win" ] );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "victory" ] );
		}
		outcometitle.color = ( 0,42, 0,68, 0,46 );
	}
	else
	{
		if ( isroundend )
		{
			outcometitle settext( game[ "strings" ][ "round_loss" ] );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "defeat" ] );
		}
		outcometitle.color = ( 0,73, 0,29, 0,19 );
	}
	if ( !isDefined( level.dontshowendreason ) || !level.dontshowendreason )
	{
		outcometext settext( endreasontext );
	}
	outcometitle setpulsefx( 100, duration, 1000 );
	outcometext setpulsefx( 100, duration, 1000 );
	teamicons = [];
	teamicons[ team ] = createicon( game[ "icons" ][ team ], iconsize, iconsize );
	teamicons[ team ] setparent( outcometext );
	teamicons[ team ] setpoint( "TOP", "BOTTOM", -60, spacing );
	teamicons[ team ].hidewheninmenu = 0;
	teamicons[ team ].archived = 0;
	teamicons[ team ].alpha = 0;
	teamicons[ team ] fadeovertime( 0,5 );
	teamicons[ team ].alpha = 1;
	_a1171 = level.teams;
	_k1171 = getFirstArrayKey( _a1171 );
	while ( isDefined( _k1171 ) )
	{
		enemyteam = _a1171[ _k1171 ];
		if ( team == enemyteam )
		{
		}
		else
		{
			teamicons[ enemyteam ] = createicon( game[ "icons" ][ enemyteam ], iconsize, iconsize );
			teamicons[ enemyteam ] setparent( outcometext );
			teamicons[ enemyteam ] setpoint( "TOP", "BOTTOM", 60, spacing );
			teamicons[ enemyteam ].hidewheninmenu = 0;
			teamicons[ enemyteam ].archived = 0;
			teamicons[ enemyteam ].alpha = 0;
			teamicons[ enemyteam ] fadeovertime( 0,5 );
			teamicons[ enemyteam ].alpha = 1;
		}
		_k1171 = getNextArrayKey( _a1171, _k1171 );
	}
	teamscores = [];
	teamscores[ team ] = createfontstring( font, titlesize );
	teamscores[ team ] setparent( teamicons[ team ] );
	teamscores[ team ] setpoint( "TOP", "BOTTOM", 0, spacing );
	teamscores[ team ].glowalpha = 1;
	teamscores[ team ] setvalue( getteamscore( team ) );
	teamscores[ team ].hidewheninmenu = 0;
	teamscores[ team ].archived = 0;
	teamscores[ team ] setpulsefx( 100, duration, 1000 );
	_a1197 = level.teams;
	_k1197 = getFirstArrayKey( _a1197 );
	while ( isDefined( _k1197 ) )
	{
		enemyteam = _a1197[ _k1197 ];
		if ( team == enemyteam )
		{
		}
		else
		{
			teamscores[ enemyteam ] = createfontstring( font, titlesize );
			teamscores[ enemyteam ] setparent( teamicons[ enemyteam ] );
			teamscores[ enemyteam ] setpoint( "TOP", "BOTTOM", 0, spacing );
			teamscores[ enemyteam ].glowalpha = 1;
			teamscores[ enemyteam ] setvalue( getteamscore( enemyteam ) );
			teamscores[ enemyteam ].hidewheninmenu = 0;
			teamscores[ enemyteam ].archived = 0;
			teamscores[ enemyteam ] setpulsefx( 100, duration, 1000 );
		}
		_k1197 = getNextArrayKey( _a1197, _k1197 );
	}
	matchbonus = undefined;
	sidebetwinnings = undefined;
	if ( !isroundend && !halftime && isDefined( self.wagerwinnings ) )
	{
		matchbonus = createfontstring( font, 2 );
		matchbonus setparent( outcometext );
		matchbonus setpoint( "TOP", "BOTTOM", 0, iconsize + ( spacing * 3 ) + teamscores[ team ].height );
		matchbonus.glowalpha = 1;
		matchbonus.hidewheninmenu = 0;
		matchbonus.archived = 0;
		matchbonus.label = game[ "strings" ][ "wager_winnings" ];
		matchbonus setvalue( self.wagerwinnings );
		if ( isDefined( game[ "side_bets" ] ) && game[ "side_bets" ] )
		{
			sidebetwinnings = createfontstring( font, 2 );
			sidebetwinnings setparent( matchbonus );
			sidebetwinnings setpoint( "TOP", "BOTTOM", 0, spacing );
			sidebetwinnings.glowalpha = 1;
			sidebetwinnings.hidewheninmenu = 0;
			sidebetwinnings.archived = 0;
			sidebetwinnings.label = game[ "strings" ][ "wager_sidebet_winnings" ];
			sidebetwinnings setvalue( self.pers[ "wager_sideBetWinnings" ] );
		}
	}
	self thread resetoutcomenotify( teamicons, teamscores, outcometitle, outcometext, matchbonus, sidebetwinnings );
}

destroyhudelem( hudelem )
{
	if ( isDefined( hudelem ) )
	{
		hudelem destroyelem();
	}
}

resetoutcomenotify( hudelemlist1, hudelemlist2, hudelem3, hudelem4, hudelem5, hudelem6, hudelem7, hudelem8, hudelem9, hudelem10 )
{
	self endon( "disconnect" );
	self waittill( "reset_outcome" );
	destroyhudelem( hudelem3 );
	destroyhudelem( hudelem4 );
	destroyhudelem( hudelem5 );
	destroyhudelem( hudelem6 );
	destroyhudelem( hudelem7 );
	destroyhudelem( hudelem8 );
	destroyhudelem( hudelem9 );
	destroyhudelem( hudelem10 );
	while ( isDefined( hudelemlist1 ) )
	{
		_a1263 = hudelemlist1;
		_k1263 = getFirstArrayKey( _a1263 );
		while ( isDefined( _k1263 ) )
		{
			elem = _a1263[ _k1263 ];
			destroyhudelem( elem );
			_k1263 = getNextArrayKey( _a1263, _k1263 );
		}
	}
	while ( isDefined( hudelemlist2 ) )
	{
		_a1271 = hudelemlist2;
		_k1271 = getFirstArrayKey( _a1271 );
		while ( isDefined( _k1271 ) )
		{
			elem = _a1271[ _k1271 ];
			destroyhudelem( elem );
			_k1271 = getNextArrayKey( _a1271, _k1271 );
		}
	}
}

resetwageroutcomenotify( playernamehudelems, playercphudelems, outcometitle, outcometext )
{
	self endon( "disconnect" );
	self waittill( "reset_outcome" );
	i = playernamehudelems.size - 1;
	while ( i >= 0 )
	{
		if ( isDefined( playernamehudelems[ i ] ) )
		{
			playernamehudelems[ i ] destroy();
		}
		i--;

	}
	i = playercphudelems.size - 1;
	while ( i >= 0 )
	{
		if ( isDefined( playercphudelems[ i ] ) )
		{
			playercphudelems[ i ] destroy();
		}
		i--;

	}
	if ( isDefined( outcometext ) )
	{
		outcometext destroy();
	}
	if ( isDefined( outcometitle ) )
	{
		outcometitle destroy();
	}
}

updateoutcome( firsttitle, secondtitle, thirdtitle )
{
	self endon( "disconnect" );
	self endon( "reset_outcome" );
	while ( 1 )
	{
		self waittill( "update_outcome" );
		players = level.placement[ "all" ];
		if ( isDefined( firsttitle ) && isDefined( players[ 0 ] ) )
		{
			firsttitle setplayernamestring( players[ 0 ] );
		}
		else
		{
			if ( isDefined( firsttitle ) )
			{
				firsttitle.alpha = 0;
			}
		}
		if ( isDefined( secondtitle ) && isDefined( players[ 1 ] ) )
		{
			secondtitle setplayernamestring( players[ 1 ] );
		}
		else
		{
			if ( isDefined( secondtitle ) )
			{
				secondtitle.alpha = 0;
			}
		}
		if ( isDefined( thirdtitle ) && isDefined( players[ 2 ] ) )
		{
			thirdtitle setplayernamestring( players[ 2 ] );
			continue;
		}
		else
		{
			if ( isDefined( thirdtitle ) )
			{
				thirdtitle.alpha = 0;
			}
		}
	}
}

updatewageroutcome( playernamehudelems, playercphudelems )
{
	self endon( "disconnect" );
	self endon( "reset_outcome" );
	while ( 1 )
	{
		self waittill( "update_outcome" );
		players = level.placement[ "all" ];
		i = 0;
		while ( i < playernamehudelems.size )
		{
			if ( isDefined( playernamehudelems[ i ] ) && isDefined( players[ playernamehudelems[ i ].playernum ] ) )
			{
				playernamehudelems[ i ] setplayernamestring( players[ playernamehudelems[ i ].playernum ] );
				i++;
				continue;
			}
			else
			{
				if ( isDefined( playernamehudelems[ i ] ) )
				{
					playernamehudelems[ i ].alpha = 0;
				}
				if ( isDefined( playercphudelems[ i ] ) )
				{
					playercphudelems[ i ].alpha = 0;
				}
			}
			i++;
		}
	}
}

setshoutcasterwaitingmessage()
{
	if ( !isDefined( self.waitingforplayerstext ) )
	{
		self.waitingforplayerstext = createfontstring( "objective", 2,5 );
		self.waitingforplayerstext setpoint( "CENTER", "CENTER", 0, -80 );
		self.waitingforplayerstext.sort = 1001;
		self.waitingforplayerstext settext( &"MP_WAITING_FOR_PLAYERS_SHOUTCASTER" );
		self.waitingforplayerstext.foreground = 0;
		self.waitingforplayerstext.hidewheninmenu = 1;
	}
}

clearshoutcasterwaitingmessage()
{
	if ( isDefined( self.waitingforplayerstext ) )
	{
		destroyhudelem( self.waitingforplayerstext );
		self.waitingforplayerstext = undefined;
	}
}
