//checked includes match cerberus output
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_class;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/teams/_teams;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_persistence;
#include maps/mp/gametypes/_rank;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/gametypes/_globallogic_score;
#include common_scripts/utility;
#include maps/mp/_utility;

init() //checked matches cerberus output
{
	precachestring( &"MP_HEADS_UP" );
	precachestring( &"MP_U2_ONLINE" );
	precachestring( &"MP_BONUS_ACQUIRED" );
	if ( gamemodeismode( level.gamemode_wager_match ) && !ispregame() )
	{
		level.wagermatch = 1;
		if ( !isDefined( game[ "wager_pot" ] ) )
		{
			game[ "wager_pot" ] = 0;
			game[ "wager_initial_pot" ] = 0;
		}
		game[ "dialog" ][ "wm_u2_online" ] = "boost_gen_02";
		game[ "dialog" ][ "wm_in_the_money" ] = "boost_gen_06";
		game[ "dialog" ][ "wm_oot_money" ] = "boost_gen_07";
		level.poweruplist = [];
		level thread onplayerconnect();
		level thread helpgameend();
	}
	else
	{
		level.wagermatch = 0;
	}
	level.takelivesondeath = 1;
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread ondisconnect();
		player thread initwagerplayer();
	}
}

initwagerplayer() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );
	if ( !isDefined( self.pers[ "wager" ] ) )
	{
		self.pers[ "wager" ] = 1;
		self.pers[ "wager_sideBetWinnings" ] = 0;
		self.pers[ "wager_sideBetLosses" ] = 0;
	}
	if ( is_true( level.inthemoneyonradar ) || is_true( level.firstplaceonradar ) )
	{
		self.pers[ "hasRadar" ] = 1;
		self.hasspyplane = 1;
	}
	else
	{
		self.pers[ "hasRadar" ] = 0;
		self.hasspyplane = 0;
	}
	self thread deductplayerante();
}

ondisconnect() //checked matches cerberus output
{
	level endon( "game_ended" );
	self endon( "player_eliminated" );
	self waittill( "disconnect" );
	level notify( "player_eliminated" );
}

deductplayerante() //checked matches cerberus output
{
	if ( isDefined( self.pers[ "hasPaidWagerAnte" ] ) )
	{
		return;
	}
	waittillframeend;
	codpoints = self maps/mp/gametypes/_rank::getcodpointsstat();
	wagerbet = getDvarInt( "scr_wagerBet" );
	if ( wagerbet > codpoints )
	{
		wagerbet = codpoints;
	}
	codpoints -= wagerbet;
	self maps/mp/gametypes/_rank::setcodpointsstat( codpoints );
	if ( !self islocaltohost() )
	{
		self incrementescrowforplayer( wagerbet );
	}
	game[ "wager_pot" ] += wagerbet;
	game[ "wager_initial_pot" ] += wagerbet;
	self.pers[ "hasPaidWagerAnte" ] = 1;
	self addplayerstat( "LIFETIME_BUYIN", wagerbet );
	self addrecentearningstostat( 0 - wagerbet );
	if ( isDefined( level.onwagerplayerante ) )
	{
		[[ level.onwagerplayerante ]]( self, wagerbet );
	}
	self thread maps/mp/gametypes/_persistence::uploadstatssoon();
}

incrementescrowforplayer( amount ) //checked matches cerberus output
{
	if ( !isDefined( self ) || !isplayer( self ) )
	{
		return;
	}
	if ( !isDefined( game[ "escrows" ] ) )
	{
		game[ "escrows" ] = [];
	}
	playerxuid = self getxuid();
	if ( !isDefined( playerxuid ) )
	{
		return;
	}
	escrowstruct = spawnstruct();
	escrowstruct.xuid = playerxuid;
	escrowstruct.amount = amount;
	game[ "escrows" ][ game[ "escrows" ].size ] = escrowstruct;
}

clearescrows() //checked changed to match cerberus output
{
	if ( !isDefined( game[ "escrows" ] ) )
	{
		return;
	}
	escrows = game[ "escrows" ];
	numescrows = escrows.size;
	for ( i = 0; i < numescrows; i++ )
	{
		escrowstruct = escrows[ i ];
	}
	game[ "escrows" ] = [];
}

addrecentearningstostat( recentearnings ) //checked matches cerberus output 
{
	currearnings = self maps/mp/gametypes/_persistence::getrecentstat( 1, 0, "score" );
	self maps/mp/gametypes/_persistence::setrecentstat( 1, 0, "score", currearnings + recentearnings );
}

prematchperiod() //checked matches cerberus output 
{
	if ( !level.wagermatch )
	{
		return;
	}
}

finalizewagerround() //checked matches cerberus output 
{
	if ( level.wagermatch == 0 )
	{
		return;
	}
	determinewagerwinnings();
	if ( isDefined( level.onwagerfinalizeround ) )
	{
		[[ level.onwagerfinalizeround ]]();
	}
}

determinewagerwinnings()
{
	if ( !isDefined( level.dontcalcwagerwinnings ) || !level.dontcalcwagerwinnings )
	{
		shouldcalculatewinnings = 0;
	}
	else
	{
		shouldcalculatewinnings = 1;
	}
	if ( !shouldcalculatewinnings )
	{
		return;
	}
	if ( !level.teambased )
	{
		calculatefreeforallpayouts();
	}
	else
	{
		calculateteampayouts();
	}
}

calculatefreeforallpayouts() //checked changed to match cerberus output
{
	playerrankings = level.placement[ "all" ];
	payoutpercentages = array( 0.5, 0.3, 0.2 );
	if ( playerrankings.size == 2 )
	{
		payoutpercentages = array( 0.7, 0.3 );
	}
	else if ( playerrankings.size == 1 )
	{
		payoutpercentages = array( 1 );
	}
	setwagerwinningsonplayers( level.players, 0 );
	if ( is_true( level.hostforcedend ) )
	{
		wagerbet = getDvarInt( "scr_wagerBet" );
		for ( i = 0; i < playerrankings.size; i++ )
		{
			if ( !playerrankings[ i ] islocaltohost() )
			{
				playerrankings[ i ].wagerwinnings = wagerbet;
			}
		}
	}
	else if ( level.players.size == 1 )
	{
		return;
	}
	else
	{
		currentpayoutpercentage = 0;
		cumulativepayoutpercentage = payoutpercentages[ 0 ];
		playergroup = [];
		playergroup[ playergroup.size ] = playerrankings[ 0 ];
		for ( i = 1; i < playerrankings.size; i++ )
		{
			if ( playerrankings[ i ].pers[ "score" ] < playergroup[ 0 ].pers[ "score" ] )
			{
				setwagerwinningsonplayers( playergroup, int( ( game[ "wager_pot" ] * cumulativepayoutpercentage ) / playergroup.size ) );
				playergroup = [];
				cumulativepayoutpercentage = 0;
			}
			playergroup[ playergroup.size ] = playerrankings[ i ];
			currentpayoutpercentage++;
			if ( isDefined( payoutpercentages[ currentpayoutpercentage ] ) )
			{
				cumulativepayoutpercentage += payoutpercentages[ currentpayoutpercentage ];
			}
		}
		setwagerwinningsonplayers( playergroup, int( ( game[ "wager_pot" ] * cumulativepayoutpercentage ) / playergroup.size ) );
	}
}

calculateplacesbasedonscore() //checked changed to match cerberus output
{
	level.playerplaces = array( [], [], [] );
	playerrankings = level.placement[ "all" ];
	placementscores = array( playerrankings[ 0 ].pers[ "score" ], -1, -1 );
	currentplace = 0;
	for ( index = 0; index < playerrankings.size && currentplace < placementscores.size; index++ )
	{
		player = playerrankings[ index ];
		if ( player.pers[ "score" ] < placementscores[ currentplace ] )
		{
			currentplace++;
			if ( currentplace >= level.playerplaces.size )
			{
				break;
			}
			placementscores[ currentplace ] = player.pers[ "score" ];
		}
		level.playerplaces[ currentplace ][ level.playerplaces[ currentplace ].size ] = player;
	}
}

calculateteampayouts() //checked changed to match cerberus output
{
	winner = maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "teamScores" );
	if ( winner == "tie" )
	{
		calculatefreeforallpayouts();
		return;
	}
	playersonwinningteam = [];
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[ index ];
		player.wagerwinnings = 0;
		if ( player.pers[ "team" ] == winner )
		{
			playersonwinningteam[ playersonwinningteam.size ] = player;
		}
	}
	if ( playersonwinningteam.size == 0 )
	{
		setwagerwinningsonplayers( level.players, getDvarInt( "scr_wagerBet" ) );
		return;
	}
	winningssplit = int( game[ "wager_pot" ] / playersonwinningteam.size );
	setwagerwinningsonplayers( playersonwinningteam, winningssplit );
}

setwagerwinningsonplayers( players, amount ) //checked changed to match cerberus output
{
	for ( index = 0; index < players.size; index++ )
	{
		players[ index ].wagerwinnings = amount;
	}
}

finalizewagergame() //checked changed to match cerberus output
{
	level.wagergamefinalized = 1;
	if ( level.wagermatch == 0 )
	{
		return;
	}
	determinewagerwinnings();
	determinetopearners();
	players = level.players;
	wait 0.5;
	playerrankings = level.wagertopearners;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[ index ];
		if ( isDefined( player.pers[ "wager_sideBetWinnings" ] ) )
		{
			payoutwagerwinnings( player, player.wagerwinnings + player.pers[ "wager_sideBetWinnings" ] );
		}
		else
		{
			payoutwagerwinnings( player, player.wagerwinnings );
		}
		if ( player.wagerwinnings > 0 )
		{
			maps/mp/gametypes/_globallogic_score::updatewinstats( player );
		}
	}
	clearescrows();
}

payoutwagerwinnings( player, winnings ) //checked matches cerberus output
{
	if ( winnings == 0 )
	{
		return;
	}
	codpoints = player maps/mp/gametypes/_rank::getcodpointsstat();
	player maps/mp/gametypes/_rank::setcodpointsstat( codpoints + winnings );
	player addplayerstat( "LIFETIME_EARNINGS", winnings );
	player addrecentearningstostat( winnings );
}

determinetopearners() //checked changed to match beta dump
{
	topwinnings = array( -1, -1, -1 );
	level.wagertopearners = [];
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[ index ];
		if ( !isDefined( player.wagerwinnings ) )
		{
			player.wagerwinnings = 0;
		}
		if ( player.wagerwinnings > topwinnings[ 0 ] )
		{
			topwinnings[ 2 ] = topwinnings[ 1 ];
			topwinnings[ 1 ] = topwinnings[ 0 ];
			topwinnings[ 0 ] = player.wagerwinnings;
			level.wagertopearners[ 2 ] = level.wagertopearners[ 1 ];
			level.wagertopearners[ 1 ] = level.wagertopearners[ 0 ];
			level.wagertopearners[ 0 ] = player;
		}
		else if ( player.wagerwinnings > topwinnings[ 1 ] )
		{
			topwinnings[ 2 ] = topwinnings[ 1 ];
			topwinnings[ 1 ] = player.wagerwinnings;
			level.wagertopearners[ 2 ] = level.wagertopearners[ 1 ];
			level.wagertopearners[ 1 ] = player;
		}
		else if ( player.wagerwinnings > topwinnings[ 2 ] )
		{
			topwinnings[ 2 ] = player.wagerwinnings;
			level.wagertopearners[ 2 ] = player;
		}
	}
}

postroundsidebet() //checked matches cerberus output
{
	if ( is_true( level.sidebet ) )
	{
		level notify( "side_bet_begin" );
		level waittill( "side_bet_end" );
	}
}

sidebettimer() //checked changed to match cerberus output
{
	level endon( "side_bet_end" );
	secondstowait = ( level.sidebetendtime - getTime() ) / 1000;
	if ( secondstowait < 0 )
	{
		secondstowait = 0;
	}
	wait secondstowait;
	for ( playerindex = 0; playerindex < level.players.size; playerindex++ )
	{
		if ( isDefined( level.players[ playerindex ] ) )
		{
			level.players[ playerindex ] closemenu();
		}
	}
	level notify( "side_bet_end" );
}

sidebetallbetsplaced() //checked changed to match cerberus output
{
	secondsleft = ( level.sidebetendtime - getTime() ) / 1000;
	if ( secondsleft <= 3 )
	{
		return;
	}
	level.sidebetendtime = getTime() + 3000;
	wait 3;
	for ( playerindex = 0; playerindex < level.players.size; playerindex++ )
	{
		if ( isDefined( level.players[ playerindex ] ) )
		{
			level.players[ playerindex ] closemenu();
		}
	}
	level notify( "side_bet_end" );
}

setupblankrandomplayer( takeweapons, chooserandombody, weapon ) //checked changed to match cerberus output
{
	if ( !isDefined( chooserandombody ) || chooserandombody )
	{
		if ( !isDefined( self.pers[ "wagerBodyAssigned" ] ) )
		{
			self assignrandombody();
			self.pers[ "wagerBodyAssigned" ] = 1;
		}
		self maps/mp/teams/_teams::set_player_model( self.team, weapon );
	}
	self clearperks();
	self.killstreak = [];
	self.pers[ "killstreaks" ] = [];
	self.pers[ "killstreak_has_been_used" ] = [];
	self.pers[ "killstreak_unique_id" ] = [];
	if ( !isDefined( takeweapons ) || takeweapons )
	{
		self takeallweapons();
	}
	if ( is_true( self.pers[ "hasRadar" ] ) )
	{
		self.hasspyplane = 1;
	}
	if ( isDefined( self.powerups ) && isDefined( self.powerups.size ) )
	{
		for ( i = 0; i < self.powerups.size; i++ )
		{
			self applypowerup( self.powerups[ i ] );
		}
	}
	self setradarvisibility();
}

assignrandombody() //checked matches cerberus output
{
}

queuewagerpopup( message, points, submessage, announcement ) //checked matches cerberus output
{
	self endon( "disconnect" );
	size = self.wagernotifyqueue.size;
	self.wagernotifyqueue[ size ] = spawnstruct();
	self.wagernotifyqueue[ size ].message = message;
	self.wagernotifyqueue[ size ].points = points;
	self.wagernotifyqueue[ size ].submessage = submessage;
	self.wagernotifyqueue[ size ].announcement = announcement;
	self notify( "received award" );
}

helpgameend() //checked changed to match beta dump
{
	level endon( "game_ended" );
	for ( ;; )
	{
		level waittill( "player_eliminated" );
		if ( !isDefined( level.numlives ) || !level.numlives )
		{
			continue;
		}
		wait 0.05;
		players = level.players;
		playersleft = 0;
		for ( i = 0; i < players.size; i++ )
		{
			if ( isDefined( players[ i ].pers[ "lives" ] ) && players[ i ].pers[ "lives" ] > 0 )
			{
				playersleft++;
			}
		}
		if ( playersleft == 2 )
		{
			for ( i = 0; i < players.size; i++ )
			{
				players[ i ] queuewagerpopup( &"MP_HEADS_UP", 0, &"MP_U2_ONLINE", "wm_u2_online" );
				players[ i ].pers[ "hasRadar" ] = 1;
				players[ i ].hasspyplane = 1;
				level.activeuavs[ players[ i ] getentitynumber() ]++;
			}
		}
	}
}

setradarvisibility() //checked changed to match cerberus output
{
	prevscoreplace = self.prevscoreplace;
	if ( !isDefined( prevscoreplace ) )
	{
		prevscoreplace = 1;
	}
	if ( is_true( level.inthemoneyonradar ) )
	{
		if ( prevscoreplace <= 3 && isDefined( self.score ) && self.score > 0 )
		{
			self unsetperk( "specialty_gpsjammer" );
		}
		else
		{
			self setperk( "specialty_gpsjammer" );
		}
	}
	else if ( is_true( level.firstplaceonradar ) )
	{
		if ( prevscoreplace == 1 && isDefined( self.score ) && self.score > 0 )
		{
			self unsetperk( "specialty_gpsjammer" );
			return;
		}
		else
		{
			self setperk( "specialty_gpsjammer" );
		}
	}
}

playerscored() //checked changed to match cerberus output
{
	self notify( "wager_player_scored" );
	self endon( "wager_player_scored" );
	wait 0.05;
	maps/mp/gametypes/_globallogic::updateplacement();
	for ( i = 0; i < level.placement["all"].size; i++ )
	{
		prevscoreplace = level.placement[ "all" ][ i ].prevscoreplace;
		if ( !isDefined( prevscoreplace ) )
		{
			prevscoreplace = 1;
		}
		currentscoreplace = i + 1;
		for ( j = i - 1; j >= 0; j-- )
		{
			if ( level.placement[ "all" ][ i ].score == level.placement[ "all" ][ j ].score )
			{
				currentscoreplace--;

			}
		}
		wasinthemoney = prevscoreplace <= 3;
		isinthemoney = currentscoreplace <= 3;
		if ( !wasinthemoney && isinthemoney )
		{
			level.placement[ "all" ][ i ] wagerannouncer( "wm_in_the_money" );
		}
		else if ( wasinthemoney && !isinthemoney )
		{
			level.placement[ "all" ][ i ] wagerannouncer( "wm_oot_money" );
		}
		level.placement[ "all" ][ i ].prevscoreplace = currentscoreplace;
		level.placement[ "all" ][ i ] setradarvisibility();
	}
}

wagerannouncer( dialog, group ) //checked matches cerberus output
{
	self maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( dialog, group );
}

createpowerup( name, type, displayname, iconmaterial ) //checked matches cerberus output
{
	powerup = spawnstruct();
	powerup.name = [];
	powerup.name[ 0 ] = name;
	powerup.type = type;
	powerup.displayname = displayname;
	powerup.iconmaterial = iconmaterial;
	return powerup;
}

addpowerup( name, type, displayname, iconmaterial ) //checked changed to match cerberus output
{
	if ( !isDefined( level.poweruplist ) )
	{
		level.poweruplist = [];
	}
	for ( i = 0; i < level.poweruplist.size; i++ )
	{
		if ( level.poweruplist[ i ].displayname == displayname )
		{
			level.poweruplist[ i ].name[ level.poweruplist[ i ].name.size ] = name;
			return;
		}
	}
	powerup = createpowerup( name, type, displayname, iconmaterial );
	level.poweruplist[ level.poweruplist.size ] = powerup;
}

copypowerup( powerup ) //checked matches cerberus output
{
	return createpowerup( powerup.name[ 0 ], powerup.type, powerup.displayname, powerup.iconmaterial );
}

applypowerup( powerup ) //checked changed to match cerberus output
{
	switch( powerup.type )
	{
		case "primary":
			self giveweapon( powerup.name[ 0 ] );
			self switchtoweapon( powerup.name[ 0 ] );
			break;
		case "secondary":
			self giveweapon( powerup.name[ 0 ] );
			break;
		case "equipment":
			self giveweapon( powerup.name[ 0 ] );
			self maps/mp/gametypes/_class::setweaponammooverall( powerup.name[ 0 ], 1 );
			self setactionslot( 1, "weapon", powerup.name[ 0 ] );
			break;
		case "primary_grenade":
			self setoffhandprimaryclass( powerup.name[ 0 ] );
			self giveweapon( powerup.name[ 0 ] );
			self setweaponammoclip( powerup.name[ 0 ], 2 );
			break;
		case "secondary_grenade":
			self setoffhandsecondaryclass( powerup.name[ 0 ] );
			self giveweapon( powerup.name[ 0 ] );
			self setweaponammoclip( powerup.name[ 0 ], 2 );
			break;
		case "perk":
			for ( i = 0; i < powerup.name.size; i++ )
			{
				self setperk( powerup.name[ i ] );
			}
		case "killstreak":
			self maps/mp/killstreaks/_killstreaks::givekillstreak( powerup.name[ 0 ] );
			break;
		case "score_multiplier":
			self.scoremultiplier = powerup.name[ 0 ];
			break;
	}
}

givepowerup( powerup, doanimation ) //checked changed to match cerberus output
{
	if ( !isDefined( self.powerups ) )
	{
		self.powerups = [];
	}
	powerupindex = self.powerups.size;
	self.powerups[ powerupindex ] = copypowerup( powerup );
	for ( i = 0; i < powerup.name.size; i++ )
	{
		self.powerups[ powerupindex ].name[ self.powerups[ powerupindex ].name.size ] = powerup.name[ i ];
	}
	self applypowerup( self.powerups[ powerupindex ] );
	self thread showpowerupmessage( powerupindex, doanimation );
}

pulsepowerupicon( powerupindex ) //checked changed to match cerberus output
{
	if ( !isDefined( self ) || !isDefined( self.powerups ) || !isDefined( self.powerups[ powerupindex ] ) || !isDefined( self.powerups[ powerupindex ].hud_elem_icon ) )
	{
		return;
	}
	self endon( "disconnect" );
	self endon( "delete" );
	self endon( "clearing_powerups" );
	pulsepercent = 1.5;
	pulsetime = 0.5;
	hud_elem = self.powerups[ powerupindex ].hud_elem_icon;
	if ( is_true( hud_elem.animating ) )
	{
		return;
	}
	origx = hud_elem.x;
	origy = hud_elem.y;
	origwidth = hud_elem.width;
	origheight = hud_elem.height;
	bigwidth = origwidth * pulsepercent;
	bigheight = origheight * pulsepercent;
	xoffset = ( bigwidth - origwidth ) / 2;
	yoffset = ( bigheight - origheight ) / 2;
	hud_elem scaleovertime( 0.05, int( bigwidth ), int( bigheight ) );
	hud_elem moveovertime( 0.05 );
	hud_elem.x = origx - xoffset;
	hud_elem.y = origy - yoffset;
	wait 0.05;
	hud_elem scaleovertime( pulsetime, origwidth, origheight );
	hud_elem moveovertime( pulsetime );
	hud_elem.x = origx;
	hud_elem.y = origy;
}

showpowerupmessage( powerupindex, doanimation ) //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self endon( "delete" );
	self endon( "clearing_powerups" );
	if ( !isDefined( doanimation ) )
	{
		doanimation = 1;
	}
	wasinprematch = level.inprematchperiod;
	powerupstarty = 320;
	powerupspacing = 40;
	if ( self issplitscreen() )
	{
		powerupstarty = 120;
		powerupspacing = 35;
	}
	if ( isDefined( self.powerups[ powerupindex ].hud_elem ) )
	{
		self.powerups[ powerupindex ].hud_elem destroy();
	}
	self.powerups[ powerupindex ].hud_elem = newclienthudelem( self );
	self.powerups[ powerupindex ].hud_elem.fontscale = 1,5;
	self.powerups[ powerupindex ].hud_elem.x = -125;
	self.powerups[ powerupindex ].hud_elem.y = powerupstarty - ( powerupspacing * powerupindex );
	self.powerups[ powerupindex ].hud_elem.alignx = "left";
	self.powerups[ powerupindex ].hud_elem.aligny = "middle";
	self.powerups[ powerupindex ].hud_elem.horzalign = "user_right";
	self.powerups[ powerupindex ].hud_elem.vertalign = "user_top";
	self.powerups[ powerupindex ].hud_elem.color = ( 1, 1, 1 );
	self.powerups[ powerupindex ].hud_elem.foreground = 1;
	self.powerups[ powerupindex ].hud_elem.hidewhendead = 0;
	self.powerups[ powerupindex ].hud_elem.hidewheninmenu = 1;
	self.powerups[ powerupindex ].hud_elem.hidewheninkillcam = 1;
	self.powerups[ powerupindex ].hud_elem.archived = 0;
	self.powerups[ powerupindex ].hud_elem.alpha = 0;
	self.powerups[ powerupindex ].hud_elem settext( self.powerups[ powerupindex ].displayname );
	bigiconsize = 40;
	iconsize = 32;
	if ( isDefined( self.powerups[ powerupindex ].hud_elem_icon ) )
	{
		self.powerups[ powerupindex ].hud_elem_icon destroy();
	}
	if ( doanimation )
	{
		self.powerups[ powerupindex ].hud_elem_icon = self createicon( self.powerups[ powerupindex ].iconmaterial, bigiconsize, bigiconsize );
		self.powerups[ powerupindex ].hud_elem_icon.animating = 1;
	}
	else
	{
		self.powerups[ powerupindex ].hud_elem_icon = self createicon( self.powerups[ powerupindex ].iconmaterial, iconsize, iconsize );
	}
	self.powerups[ powerupindex ].hud_elem_icon.x = ( ( self.powerups[ powerupindex ].hud_elem.x - 5 ) - ( iconsize / 2 ) ) - ( bigiconsize / 2 );
	self.powerups[ powerupindex ].hud_elem_icon.y = ( powerupstarty - ( powerupspacing * powerupindex ) ) - ( bigiconsize / 2 );
	self.powerups[ powerupindex ].hud_elem_icon.horzalign = "user_right";
	self.powerups[ powerupindex ].hud_elem_icon.vertalign = "user_top";
	self.powerups[ powerupindex ].hud_elem_icon.color = ( 1, 1, 1 );
	self.powerups[ powerupindex ].hud_elem_icon.foreground = 1;
	self.powerups[ powerupindex ].hud_elem_icon.hidewhendead = 0;
	self.powerups[ powerupindex ].hud_elem_icon.hidewheninmenu = 1;
	self.powerups[ powerupindex ].hud_elem_icon.hidewheninkillcam = 1;
	self.powerups[ powerupindex ].hud_elem_icon.archived = 0;
	self.powerups[ powerupindex ].hud_elem_icon.alpha = 1;
	if ( !wasinprematch && doanimation )
	{
		self thread queuewagerpopup( self.powerups[ powerupindex ].displayname, 0, &"MP_BONUS_ACQUIRED" );
	}
	pulsetime = 0.5;
	if ( doanimation )
	{
		self.powerups[ powerupindex ].hud_elem fadeovertime( pulsetime );
		self.powerups[ powerupindex ].hud_elem_icon scaleovertime( pulsetime, iconsize, iconsize );
		self.powerups[ powerupindex ].hud_elem_icon.width = iconsize;
		self.powerups[ powerupindex ].hud_elem_icon.height = iconsize;
		self.powerups[ powerupindex ].hud_elem_icon moveovertime( pulsetime );
	}
	self.powerups[ powerupindex ].hud_elem.alpha = 1;
	self.powerups[ powerupindex ].hud_elem_icon.x = ( self.powerups[ powerupindex ].hud_elem.x - 5 ) - iconsize;
	self.powerups[ powerupindex ].hud_elem_icon.y = ( powerupstarty - ( powerupspacing * powerupindex ) ) - ( iconsize / 2 );
	if ( doanimation )
	{
		wait pulsetime;
	}
	if ( level.inprematchperiod )
	{
		level waittill( "prematch_over" );
	}
	else
	{
		if ( doanimation )
		{
			wait pulsetime;
		}
	}
	if ( wasinprematch && doanimation )
	{
		self thread queuewagerpopup( self.powerups[ powerupindex ].displayname, 0, &"MP_BONUS_ACQUIRED" );
	}
	wait 1.5;
	for ( i = 0; i <= powerupindex; i++ )
	{
		self.powerups[ i ].hud_elem fadeovertime( 0.25 );
		self.powerups[ i ].hud_elem.alpha = 0;
	}
	wait 0.25;
	for ( i = 0; i <= powerupindex; i++ )
	{
		self.powerups[ i ].hud_elem_icon moveovertime( 0.25 );
		self.powerups[ i ].hud_elem_icon.x = 0 - iconsize;
		self.powerups[ i ].hud_elem_icon.horzalign = "user_right";
	}
	self.powerups[ powerupindex ].hud_elem_icon.animating = 0;
}

clearpowerups() //checked changed to match cerberus output
{
	self notify( "clearing_powerups" );
	while ( isDefined( self.powerups ) && isDefined( self.powerups.size ) )
	{
		for ( i = 0; i < self.powerups.size; i++ )
		{
			if ( isDefined( self.powerups[ i ].hud_elem ) )
			{
				self.powerups[ i ].hud_elem destroy();
			}
			if ( isDefined( self.powerups[ i ].hud_elem_icon ) )
			{
				self.powerups[ i ].hud_elem_icon destroy();
			}
		}
	}
	self.powerups = [];
}

trackwagerweaponusage( name, incvalue, statname ) //checked matches cerberus output
{
	if ( !isDefined( self.wagerweaponusage ) )
	{
		self.wagerweaponusage = [];
	}
	if ( !isDefined( self.wagerweaponusage[ name ] ) )
	{
		self.wagerweaponusage[ name ] = [];
	}
	if ( !isDefined( self.wagerweaponusage[ name ][ statname ] ) )
	{
		self.wagerweaponusage[ name ][ statname ] = 0;
	}
	self.wagerweaponusage[ name ][ statname ] += incvalue;
}

gethighestwagerweaponusage( statname ) //checked partially changed to match cerberus output did not use continues in for loop see github for more info
{
	if ( !isDefined( self.wagerweaponusage ) )
	{
		return undefined;
	}
	bestweapon = undefined;
	highestvalue = 0;
	wagerweaponsused = getarraykeys( self.wagerweaponusage );
	for ( i = 0; i < wagerweaponsused.size; i++ )
	{
		weaponstats = self.wagerweaponusage[ wagerweaponsused[ i ] ];
		if ( !isDefined( weaponstats[ statname ] ) || !getbaseweaponitemindex( wagerweaponsused[ i ] ) )
		{
		}
		else if ( !isDefined( bestweapon ) || weaponstats[ statname ] > highestvalue )
		{
			bestweapon = wagerweaponsused[ i ];
			highestvalue = weaponstats[ statname ];
		}
	}
	return bestweapon;
}

setwagerafteractionreportstats() //checked changed to match beta dump
{
	topweapon = self gethighestwagerweaponusage( "kills" );
	topkills = 0;
	if ( isDefined( topweapon ) )
	{
		topkills = self.wagerweaponusage[ topweapon ][ "kills" ];
	}
	else
	{
		topweapon = self gethighestwagerweaponusage( "timeUsed" );
	}
	if ( !isDefined( topweapon ) )
	{
		topweapon = "";
	}
	self maps/mp/gametypes/_persistence::setafteractionreportstat( "topWeaponItemIndex", getbaseweaponitemindex( topweapon ) );
	self maps/mp/gametypes/_persistence::setafteractionreportstat( "topWeaponKills", topkills );
	if ( isDefined( level.onwagerawards ) )
	{
		self [[ level.onwagerawards ]]();
	}
	else
	{
		for(i = 0; i < 3; i++)
		{
			self maps/mp/gametypes/_persistence::setafteractionreportstat( "wagerAwards", 0, i );
		}
	}
}

