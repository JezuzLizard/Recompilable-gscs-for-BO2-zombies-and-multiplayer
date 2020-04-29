#include maps/mp/bots/_bot;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/_challenges;
#include maps/mp/gametypes/_class;
#include maps/mp/killstreaks/_killstreak_weapons;
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_wager;
#include maps/mp/gametypes/_persistence;
#include maps/mp/_bb;
#include maps/mp/_scoreevents;
#include maps/mp/gametypes/_rank;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/_utility;
#include common_scripts/utility;

updatematchbonusscores( winner )
{
	if ( !game[ "timepassed" ] )
	{
		return;
	}
	if ( !level.rankedmatch )
	{
		return;
	}
	if ( level.teambased && isDefined( winner ) )
	{
		if ( winner == "endregulation" )
		{
			return;
		}
	}
	if ( !level.timelimit || level.forcedend )
	{
		gamelength = maps/mp/gametypes/_globallogic_utils::gettimepassed() / 1000;
		gamelength = min( gamelength, 1200 );
		if ( level.gametype == "twar" && game[ "roundsplayed" ] > 0 )
		{
			gamelength += level.timelimit * 60;
		}
	}
	else
	{
		gamelength = level.timelimit * 60;
	}
	if ( level.teambased )
	{
		winningteam = "tie";
		_a40 = level.teams;
		_k40 = getFirstArrayKey( _a40 );
		while ( isDefined( _k40 ) )
		{
			team = _a40[ _k40 ];
			if ( winner == team )
			{
				winningteam = team;
				break;
			}
			else
			{
				_k40 = getNextArrayKey( _a40, _k40 );
			}
		}
		if ( winningteam != "tie" )
		{
			winnerscale = 1;
			loserscale = 0,5;
		}
		else
		{
			winnerscale = 0,75;
			loserscale = 0,75;
		}
		players = level.players;
		i = 0;
		while ( i < players.size )
		{
			player = players[ i ];
			if ( player.timeplayed[ "total" ] < 1 || player.pers[ "participation" ] < 1 )
			{
				player thread maps/mp/gametypes/_rank::endgameupdate();
				i++;
				continue;
			}
			else
			{
				totaltimeplayed = player.timeplayed[ "total" ];
				if ( totaltimeplayed > gamelength )
				{
					totaltimeplayed = gamelength;
				}
				if ( level.hostforcedend && player ishost() )
				{
					i++;
					continue;
				}
				else
				{
					if ( player.pers[ "score" ] < 0 )
					{
						i++;
						continue;
					}
					else spm = player maps/mp/gametypes/_rank::getspm();
					if ( winningteam == "tie" )
					{
						playerscore = int( ( winnerscale * ( gamelength / 60 ) * spm ) * ( totaltimeplayed / gamelength ) );
						player thread givematchbonus( "tie", playerscore );
						player.matchbonus = playerscore;
						i++;
						continue;
					}
					else if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] == winningteam )
					{
						playerscore = int( ( winnerscale * ( gamelength / 60 ) * spm ) * ( totaltimeplayed / gamelength ) );
						player thread givematchbonus( "win", playerscore );
						player.matchbonus = playerscore;
						i++;
						continue;
					}
					else
					{
						if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] != "spectator" )
						{
							playerscore = int( ( loserscale * ( gamelength / 60 ) * spm ) * ( totaltimeplayed / gamelength ) );
							player thread givematchbonus( "loss", playerscore );
							player.matchbonus = playerscore;
						}
					}
				}
			}
			i++;
		}
	}
	else if ( isDefined( winner ) )
	{
		winnerscale = 1;
		loserscale = 0,5;
	}
	else
	{
		winnerscale = 0,75;
		loserscale = 0,75;
	}
	players = level.players;
	i = 0;
	while ( i < players.size )
	{
		player = players[ i ];
		if ( player.timeplayed[ "total" ] < 1 || player.pers[ "participation" ] < 1 )
		{
			player thread maps/mp/gametypes/_rank::endgameupdate();
			i++;
			continue;
		}
		else
		{
			totaltimeplayed = player.timeplayed[ "total" ];
			if ( totaltimeplayed > gamelength )
			{
				totaltimeplayed = gamelength;
			}
			spm = player maps/mp/gametypes/_rank::getspm();
			iswinner = 0;
			pidx = 0;
			while ( pidx < min( level.placement[ "all" ][ 0 ].size, 3 ) )
			{
				if ( level.placement[ "all" ][ pidx ] != player )
				{
					pidx++;
					continue;
				}
				else
				{
					iswinner = 1;
				}
				pidx++;
			}
			if ( iswinner )
			{
				playerscore = int( ( winnerscale * ( gamelength / 60 ) * spm ) * ( totaltimeplayed / gamelength ) );
				player thread givematchbonus( "win", playerscore );
				player.matchbonus = playerscore;
				i++;
				continue;
			}
			else
			{
				playerscore = int( ( loserscale * ( gamelength / 60 ) * spm ) * ( totaltimeplayed / gamelength ) );
				player thread givematchbonus( "loss", playerscore );
				player.matchbonus = playerscore;
			}
		}
		i++;
	}
}

givematchbonus( scoretype, score )
{
	self endon( "disconnect" );
	level waittill( "give_match_bonus" );
	if ( maps/mp/_scoreevents::shouldaddrankxp( self ) )
	{
		self addrankxpvalue( scoretype, score );
	}
	self maps/mp/gametypes/_rank::endgameupdate();
}

doskillupdate( winner )
{
	skillupdate( winner, level.teambased );
}

gethighestscoringplayer()
{
	players = level.players;
	winner = undefined;
	tie = 0;
	i = 0;
	while ( i < players.size )
	{
		if ( !isDefined( players[ i ].pointstowin ) )
		{
			i++;
			continue;
		}
		else if ( players[ i ].pointstowin < 1 )
		{
			i++;
			continue;
		}
		else if ( !isDefined( winner ) || players[ i ].pointstowin > winner.pointstowin )
		{
			winner = players[ i ];
			tie = 0;
			i++;
			continue;
		}
		else
		{
			if ( players[ i ].pointstowin == winner.pointstowin )
			{
				tie = 1;
			}
		}
		i++;
	}
	if ( tie || !isDefined( winner ) )
	{
		return undefined;
	}
	else
	{
		return winner;
	}
}

resetscorechain()
{
	self notify( "reset_score_chain" );
	self.scorechain = 0;
	self.rankupdatetotal = 0;
}

scorechaintimer()
{
	self notify( "score_chain_timer" );
	self endon( "reset_score_chain" );
	self endon( "score_chain_timer" );
	self endon( "death" );
	self endon( "disconnect" );
	wait 20;
	self thread resetscorechain();
}

roundtonearestfive( score )
{
	rounding = score % 5;
	if ( rounding <= 2 )
	{
		return score - rounding;
	}
	else
	{
		return score + ( 5 - rounding );
	}
}

giveplayermomentumnotification( score, label, descvalue, countstowardrampage )
{
	rampagebonus = 0;
	if ( isDefined( level.usingrampage ) && level.usingrampage )
	{
		if ( countstowardrampage )
		{
			if ( !isDefined( self.scorechain ) )
			{
				self.scorechain = 0;
			}
			self.scorechain++;
			self thread scorechaintimer();
		}
		if ( isDefined( self.scorechain ) && self.scorechain >= 999 )
		{
			rampagebonus = roundtonearestfive( int( ( score * level.rampagebonusscale ) + 0,5 ) );
		}
	}
	if ( score != 0 )
	{
		self luinotifyevent( &"score_event", 3, label, score, rampagebonus );
		self luinotifyeventtospectators( &"score_event", 3, label, score, rampagebonus );
	}
	score += rampagebonus;
	if ( score > 0 && self hasperk( "specialty_earnmoremomentum" ) )
	{
		score = roundtonearestfive( int( ( score * getDvarFloat( "perk_killstreakMomentumMultiplier" ) ) + 0,5 ) );
	}
	if ( isalive( self ) )
	{
		_setplayermomentum( self, self.pers[ "momentum" ] + score );
	}
}

resetplayermomentumonspawn()
{
	if ( isDefined( level.usingscorestreaks ) && level.usingscorestreaks )
	{
		_setplayermomentum( self, 0 );
		self thread resetscorechain();
	}
}

giveplayermomentum( event, player, victim, weapon, descvalue )
{
	if ( isDefined( level.disablemomentum ) && level.disablemomentum == 1 )
	{
		return;
	}
	score = maps/mp/gametypes/_rank::getscoreinfovalue( event );
/#
	assert( isDefined( score ) );
#/
	label = maps/mp/gametypes/_rank::getscoreinfolabel( event );
	countstowardrampage = maps/mp/gametypes/_rank::doesscoreinfocounttowardrampage( event );
	if ( event == "death" )
	{
		_setplayermomentum( victim, victim.pers[ "momentum" ] + score );
	}
	if ( score == 0 )
	{
		return;
	}
	if ( !isDefined( label ) )
	{
/#
		assertmsg( event + " label undefined" );
#/
		player giveplayermomentumnotification( score, "", descvalue, countstowardrampage );
		return;
	}
	if ( level.gameended )
	{
		return;
	}
	player giveplayermomentumnotification( score, label, descvalue, countstowardrampage );
}

giveplayerscore( event, player, victim, weapon, descvalue )
{
	scorediff = 0;
	momentum = player.pers[ "momentum" ];
	giveplayermomentum( event, player, victim, weapon, descvalue );
	newmomentum = player.pers[ "momentum" ];
	if ( level.overrideplayerscore )
	{
		return 0;
	}
	pixbeginevent( "level.onPlayerScore" );
	score = player.pers[ "score" ];
	[[ level.onplayerscore ]]( event, player, victim );
	newscore = player.pers[ "score" ];
	pixendevent();
	bbprint( "mpplayerscore", "spawnid %d gametime %d type %s player %s delta %d deltamomentum %d team %s", getplayerspawnid( player ), getTime(), event, player.name, newscore - score, newmomentum - momentum, player.team );
	player maps/mp/_bb::bbaddtostat( "score", newscore - score );
	if ( score == newscore )
	{
		return 0;
	}
	pixbeginevent( "givePlayerScore" );
	recordplayerstats( player, "score", newscore );
	scorediff = newscore - score;
	challengesenabled = !level.disablechallenges;
	player addplayerstatwithgametype( "score", scorediff );
	if ( challengesenabled )
	{
		player addplayerstat( "CAREER_SCORE", scorediff );
	}
	if ( level.hardcoremode )
	{
		player addplayerstat( "SCORE_HC", scorediff );
		if ( challengesenabled )
		{
			player addplayerstat( "CAREER_SCORE_HC", scorediff );
		}
	}
	if ( level.multiteam )
	{
		player addplayerstat( "SCORE_MULTITEAM", scorediff );
		if ( challengesenabled )
		{
			player addplayerstat( "CAREER_SCORE_MULTITEAM", scorediff );
		}
	}
	if ( !level.disablestattracking && isDefined( player.pers[ "lastHighestScore" ] ) && newscore > player.pers[ "lastHighestScore" ] )
	{
		player setdstat( "HighestStats", "highest_score", newscore );
	}
	player maps/mp/gametypes/_persistence::addrecentstat( 0, 0, "score", scorediff );
	pixendevent();
	return scorediff;
}

default_onplayerscore( event, player, victim )
{
	score = maps/mp/gametypes/_rank::getscoreinfovalue( event );
/#
	assert( isDefined( score ) );
#/
	if ( level.wagermatch )
	{
		player thread maps/mp/gametypes/_rank::updaterankscorehud( score );
	}
	_setplayerscore( player, player.pers[ "score" ] + score );
}

_setplayerscore( player, score )
{
	if ( score == player.pers[ "score" ] )
	{
		return;
	}
	if ( !level.rankedmatch )
	{
		player thread maps/mp/gametypes/_rank::updaterankscorehud( score - player.pers[ "score" ] );
	}
	player.pers[ "score" ] = score;
	player.score = player.pers[ "score" ];
	recordplayerstats( player, "score", player.pers[ "score" ] );
	if ( level.wagermatch )
	{
		player thread maps/mp/gametypes/_wager::playerscored();
	}
}

_getplayerscore( player )
{
	return player.pers[ "score" ];
}

playtop3sounds()
{
	wait 0,05;
	maps/mp/gametypes/_globallogic::updateplacement();
	i = 0;
	while ( i < level.placement[ "all" ].size )
	{
		prevscoreplace = level.placement[ "all" ][ i ].prevscoreplace;
		if ( !isDefined( prevscoreplace ) )
		{
			prevscoreplace = 1;
		}
		currentscoreplace = i + 1;
		j = i - 1;
		while ( j >= 0 )
		{
			if ( level.placement[ "all" ][ i ].score == level.placement[ "all" ][ j ].score )
			{
				currentscoreplace--;

			}
			j--;

		}
		wasinthemoney = prevscoreplace <= 3;
		isinthemoney = currentscoreplace <= 3;
		level.placement[ "all" ][ i ].prevscoreplace = currentscoreplace;
		i++;
	}
}

setpointstowin( points )
{
	self.pers[ "pointstowin" ] = clamp( points, 0, 65000 );
	self.pointstowin = self.pers[ "pointstowin" ];
	self thread maps/mp/gametypes/_globallogic::checkscorelimit();
	self thread maps/mp/gametypes/_globallogic::checkplayerscorelimitsoon();
	level thread playtop3sounds();
}

givepointstowin( points )
{
	self setpointstowin( self.pers[ "pointstowin" ] + points );
}

_setplayermomentum( player, momentum )
{
	momentum = clamp( momentum, 0, 2000 );
	oldmomentum = player.pers[ "momentum" ];
	if ( momentum == oldmomentum )
	{
		return;
	}
	player maps/mp/_bb::bbaddtostat( "momentum", momentum - oldmomentum );
	while ( momentum > oldmomentum )
	{
		highestmomentumcost = 0;
		numkillstreaks = 0;
		if ( isDefined( player.killstreak ) )
		{
			numkillstreaks = player.killstreak.size;
		}
		killstreaktypearray = [];
		currentkillstreak = 0;
		while ( currentkillstreak < numkillstreaks )
		{
			killstreaktype = maps/mp/killstreaks/_killstreaks::getkillstreakbymenuname( player.killstreak[ currentkillstreak ] );
			if ( isDefined( killstreaktype ) )
			{
				momentumcost = level.killstreaks[ killstreaktype ].momentumcost;
				if ( momentumcost > highestmomentumcost )
				{
					highestmomentumcost = momentumcost;
				}
				killstreaktypearray[ killstreaktypearray.size ] = killstreaktype;
			}
			currentkillstreak++;
		}
		_giveplayerkillstreakinternal( player, momentum, oldmomentum, killstreaktypearray );
		while ( highestmomentumcost > 0 && momentum >= highestmomentumcost )
		{
			oldmomentum = 0;
			momentum -= highestmomentumcost;
			_giveplayerkillstreakinternal( player, momentum, oldmomentum, killstreaktypearray );
		}
	}
	player.pers[ "momentum" ] = momentum;
	player.momentum = player.pers[ "momentum" ];
}

_giveplayerkillstreakinternal( player, momentum, oldmomentum, killstreaktypearray )
{
	killstreaktypeindex = 0;
	while ( killstreaktypeindex < killstreaktypearray.size )
	{
		killstreaktype = killstreaktypearray[ killstreaktypeindex ];
		momentumcost = level.killstreaks[ killstreaktype ].momentumcost;
		if ( momentumcost > oldmomentum && momentumcost <= momentum )
		{
			weapon = maps/mp/killstreaks/_killstreaks::getkillstreakweapon( killstreaktype );
			if ( isDefined( level.usingscorestreaks ) && level.usingscorestreaks )
			{
				if ( maps/mp/killstreaks/_killstreak_weapons::isheldkillstreakweapon( weapon ) )
				{
					if ( !isDefined( player.pers[ "held_killstreak_ammo_count" ][ weapon ] ) )
					{
						player.pers[ "held_killstreak_ammo_count" ][ weapon ] = 0;
					}
					if ( !isDefined( player.pers[ "killstreak_quantity" ][ weapon ] ) )
					{
						player.pers[ "killstreak_quantity" ][ weapon ] = 0;
					}
					currentweapon = player getcurrentweapon();
					if ( currentweapon == weapon )
					{
						if ( player.pers[ "killstreak_quantity" ][ weapon ] < level.scorestreaksmaxstacking )
						{
							player.pers[ "killstreak_quantity" ][ weapon ]++;
						}
					}
					else
					{
						player.pers[ "held_killstreak_clip_count" ][ weapon ] = weaponclipsize( weapon );
						player.pers[ "held_killstreak_ammo_count" ][ weapon ] = weaponmaxammo( weapon );
						player maps/mp/gametypes/_class::setweaponammooverall( weapon, player.pers[ "held_killstreak_ammo_count" ][ weapon ] );
					}
				}
				else
				{
					player maps/mp/_challenges::earnedkillstreak();
					player maps/mp/killstreaks/_killstreaks::changekillstreakquantity( weapon, 1 );
				}
				player maps/mp/killstreaks/_killstreaks::addkillstreaktoqueue( level.killstreaks[ killstreaktype ].menuname, 0, killstreaktype );
				killstreaktypeindex++;
				continue;
			}
			else
			{
				player maps/mp/killstreaks/_killstreaks::addkillstreaktoqueue( level.killstreaks[ killstreaktype ].menuname, 0, killstreaktype );
				activeeventname = "reward_active";
				if ( isDefined( weapon ) )
				{
					neweventname = weapon + "_active";
					if ( maps/mp/_scoreevents::isregisteredevent( neweventname ) )
					{
						activeeventname = neweventname;
					}
				}
			}
		}
		killstreaktypeindex++;
	}
}

setplayermomentumdebug()
{
/#
	setdvar( "sv_momentumPercent", 0 );
	while ( 1 )
	{
		wait 1;
		momentumpercent = getdvarfloatdefault( "sv_momentumPercent", 0 );
		if ( momentumpercent != 0 )
		{
			player = gethostplayer();
			if ( !isDefined( player ) )
			{
				return;
			}
			if ( isDefined( player.killstreak ) )
			{
				_setplayermomentum( player, int( 2000 * ( momentumpercent / 100 ) ) );
			}
		}
#/
	}
}

giveteamscore( event, team, player, victim )
{
	if ( level.overrideteamscore )
	{
		return;
	}
	pixbeginevent( "level.onTeamScore" );
	teamscore = game[ "teamScores" ][ team ];
	[[ level.onteamscore ]]( event, team );
	pixendevent();
	newscore = game[ "teamScores" ][ team ];
	bbprint( "mpteamscores", "gametime %d event %s team %d diff %d score %d", getTime(), event, team, newscore - teamscore, newscore );
	if ( teamscore == newscore )
	{
		return;
	}
	updateteamscores( team );
	thread maps/mp/gametypes/_globallogic::checkscorelimit();
}

giveteamscoreforobjective_delaypostprocessing( team, score )
{
	teamscore = game[ "teamScores" ][ team ];
	onteamscore_incrementscore( score, team );
	newscore = game[ "teamScores" ][ team ];
	bbprint( "mpteamobjscores", "gametime %d  team %d diff %d score %d", getTime(), team, newscore - teamscore, newscore );
	if ( teamscore == newscore )
	{
		return;
	}
	updateteamscores( team );
}

postprocessteamscores( teams )
{
	_a660 = teams;
	_k660 = getFirstArrayKey( _a660 );
	while ( isDefined( _k660 ) )
	{
		team = _a660[ _k660 ];
		onteamscore_postprocess( team );
		_k660 = getNextArrayKey( _a660, _k660 );
	}
	thread maps/mp/gametypes/_globallogic::checkscorelimit();
}

giveteamscoreforobjective( team, score )
{
	if ( !isDefined( level.teams[ team ] ) )
	{
		return;
	}
	teamscore = game[ "teamScores" ][ team ];
	onteamscore( score, team );
	newscore = game[ "teamScores" ][ team ];
	bbprint( "mpteamobjscores", "gametime %d  team %d diff %d score %d", getTime(), team, newscore - teamscore, newscore );
	if ( teamscore == newscore )
	{
		return;
	}
	updateteamscores( team );
	thread maps/mp/gametypes/_globallogic::checkscorelimit();
}

_setteamscore( team, teamscore )
{
	if ( teamscore == game[ "teamScores" ][ team ] )
	{
		return;
	}
	game[ "teamScores" ][ team ] = clamp( teamscore, 0, 1000000 );
	updateteamscores( team );
	thread maps/mp/gametypes/_globallogic::checkscorelimit();
}

resetteamscores()
{
	while ( isDefined( level.roundscorecarry ) || level.roundscorecarry == 0 && maps/mp/_utility::isfirstround() )
	{
		_a705 = level.teams;
		_k705 = getFirstArrayKey( _a705 );
		while ( isDefined( _k705 ) )
		{
			team = _a705[ _k705 ];
			game[ "teamScores" ][ team ] = 0;
			_k705 = getNextArrayKey( _a705, _k705 );
		}
	}
	maps/mp/gametypes/_globallogic_score::updateallteamscores();
}

resetallscores()
{
	resetteamscores();
	resetplayerscores();
}

resetplayerscores()
{
	players = level.players;
	winner = undefined;
	tie = 0;
	i = 0;
	while ( i < players.size )
	{
		if ( isDefined( players[ i ].pers[ "score" ] ) )
		{
			_setplayerscore( players[ i ], 0 );
		}
		i++;
	}
}

updateteamscores( team )
{
	setteamscore( team, game[ "teamScores" ][ team ] );
	level thread maps/mp/gametypes/_globallogic::checkteamscorelimitsoon( team );
}

updateallteamscores()
{
	_a743 = level.teams;
	_k743 = getFirstArrayKey( _a743 );
	while ( isDefined( _k743 ) )
	{
		team = _a743[ _k743 ];
		updateteamscores( team );
		_k743 = getNextArrayKey( _a743, _k743 );
	}
}

_getteamscore( team )
{
	return game[ "teamScores" ][ team ];
}

gethighestteamscoreteam()
{
	score = 0;
	winning_teams = [];
	_a759 = level.teams;
	_k759 = getFirstArrayKey( _a759 );
	while ( isDefined( _k759 ) )
	{
		team = _a759[ _k759 ];
		team_score = game[ "teamScores" ][ team ];
		if ( team_score > score )
		{
			score = team_score;
			winning_teams = [];
		}
		if ( team_score == score )
		{
			winning_teams[ team ] = team;
		}
		_k759 = getNextArrayKey( _a759, _k759 );
	}
	return winning_teams;
}

areteamarraysequal( teamsa, teamsb )
{
	if ( teamsa.size != teamsb.size )
	{
		return 0;
	}
	_a782 = teamsa;
	_k782 = getFirstArrayKey( _a782 );
	while ( isDefined( _k782 ) )
	{
		team = _a782[ _k782 ];
		if ( !isDefined( teamsb[ team ] ) )
		{
			return 0;
		}
		_k782 = getNextArrayKey( _a782, _k782 );
	}
	return 1;
}

onteamscore( score, team )
{
	onteamscore_incrementscore( score, team );
	onteamscore_postprocess( team );
}

onteamscore_incrementscore( score, team )
{
	game[ "teamScores" ][ team ] += score;
	if ( game[ "teamScores" ][ team ] < 0 )
	{
		game[ "teamScores" ][ team ] = 0;
	}
	if ( level.scorelimit && game[ "teamScores" ][ team ] > level.scorelimit )
	{
		game[ "teamScores" ][ team ] = level.scorelimit;
	}
}

onteamscore_postprocess( team )
{
	if ( level.splitscreen )
	{
		return;
	}
	if ( level.scorelimit == 1 )
	{
		return;
	}
	iswinning = gethighestteamscoreteam();
	if ( iswinning.size == 0 )
	{
		return;
	}
	if ( ( getTime() - level.laststatustime ) < 5000 )
	{
		return;
	}
	if ( areteamarraysequal( iswinning, level.waswinning ) )
	{
		return;
	}
	if ( iswinning.size == 1 )
	{
		level.laststatustime = getTime();
		_a835 = iswinning;
		_k835 = getFirstArrayKey( _a835 );
		while ( isDefined( _k835 ) )
		{
			team = _a835[ _k835 ];
			if ( isDefined( level.waswinning[ team ] ) )
			{
				if ( level.waswinning.size == 1 )
				{
				}
			}
			else
			{
				maps/mp/gametypes/_globallogic_audio::leaderdialog( "lead_taken", team, "status" );
			}
			_k835 = getNextArrayKey( _a835, _k835 );
		}
	}
	else return;
	while ( level.waswinning.size == 1 )
	{
		_a858 = level.waswinning;
		_k858 = getFirstArrayKey( _a858 );
		while ( isDefined( _k858 ) )
		{
			team = _a858[ _k858 ];
			if ( isDefined( iswinning[ team ] ) )
			{
				if ( iswinning.size == 1 )
				{
				}
				else if ( level.waswinning.size > 1 )
				{
				}
			}
			else
			{
				maps/mp/gametypes/_globallogic_audio::leaderdialog( "lead_lost", team, "status" );
			}
			_k858 = getNextArrayKey( _a858, _k858 );
		}
	}
	level.waswinning = iswinning;
}

default_onteamscore( event, team )
{
	score = maps/mp/gametypes/_rank::getscoreinfovalue( event );
/#
	assert( isDefined( score ) );
#/
	onteamscore( score, team );
}

initpersstat( dataname, record_stats )
{
	if ( !isDefined( self.pers[ dataname ] ) )
	{
		self.pers[ dataname ] = 0;
	}
	if ( !isDefined( record_stats ) || record_stats == 1 )
	{
		recordplayerstats( self, dataname, int( self.pers[ dataname ] ) );
	}
}

getpersstat( dataname )
{
	return self.pers[ dataname ];
}

incpersstat( dataname, increment, record_stats, includegametype )
{
	pixbeginevent( "incPersStat" );
	self.pers[ dataname ] += increment;
	if ( isDefined( includegametype ) && includegametype )
	{
		self addplayerstatwithgametype( dataname, increment );
	}
	else
	{
		self addplayerstat( dataname, increment );
	}
	if ( !isDefined( record_stats ) || record_stats == 1 )
	{
		self thread threadedrecordplayerstats( dataname );
	}
	pixendevent();
}

threadedrecordplayerstats( dataname )
{
	self endon( "disconnect" );
	waittillframeend;
	recordplayerstats( self, dataname, self.pers[ dataname ] );
}

updatewinstats( winner )
{
	winner addplayerstatwithgametype( "losses", -1 );
	winner addplayerstatwithgametype( "wins", 1 );
	if ( level.hardcoremode )
	{
		winner addplayerstat( "wins_HC", 1 );
	}
	if ( level.multiteam )
	{
		winner addplayerstat( "wins_MULTITEAM", 1 );
	}
	winner updatestatratio( "wlratio", "wins", "losses" );
	restorewinstreaks( winner );
	winner addplayerstatwithgametype( "cur_win_streak", 1 );
	winner notify( "win" );
	cur_gamemode_win_streak = winner maps/mp/gametypes/_persistence::statgetwithgametype( "cur_win_streak" );
	gamemode_win_streak = winner maps/mp/gametypes/_persistence::statgetwithgametype( "win_streak" );
	cur_win_streak = winner getdstat( "playerstatslist", "cur_win_streak", "StatValue" );
	if ( !level.disablestattracking && cur_win_streak > winner getdstat( "HighestStats", "win_streak" ) )
	{
		winner setdstat( "HighestStats", "win_streak", cur_win_streak );
	}
	if ( cur_gamemode_win_streak > gamemode_win_streak )
	{
		winner maps/mp/gametypes/_persistence::statsetwithgametype( "win_streak", cur_gamemode_win_streak );
	}
	if ( maps/mp/bots/_bot::is_bot_ranked_match() )
	{
		combattrainingwins = winner getdstat( "combatTrainingWins" );
		winner setdstat( "combatTrainingWins", combattrainingwins + 1 );
	}
}

updatelossstats( loser )
{
	loser addplayerstatwithgametype( "losses", 1 );
	loser updatestatratio( "wlratio", "wins", "losses" );
	loser notify( "loss" );
}

updatetiestats( loser )
{
	loser addplayerstatwithgametype( "losses", -1 );
	loser addplayerstatwithgametype( "ties", 1 );
	loser updatestatratio( "wlratio", "wins", "losses" );
	if ( !level.disablestattracking )
	{
		loser setdstat( "playerstatslist", "cur_win_streak", "StatValue", 0 );
	}
	loser notify( "tie" );
}

updatewinlossstats( winner )
{
	if ( !waslastround() && !level.hostforcedend )
	{
		return;
	}
	players = level.players;
	if ( !isDefined( winner ) || isDefined( winner ) && !isplayer( winner ) && winner == "tie" )
	{
		i = 0;
		while ( i < players.size )
		{
			if ( !isDefined( players[ i ].pers[ "team" ] ) )
			{
				i++;
				continue;
			}
			else if ( level.hostforcedend && players[ i ] ishost() )
			{
				i++;
				continue;
			}
			else
			{
				updatetiestats( players[ i ] );
			}
			i++;
		}
	}
	else if ( isplayer( winner ) )
	{
		if ( level.hostforcedend && winner ishost() )
		{
			return;
		}
		updatewinstats( winner );
		while ( !level.teambased )
		{
			placement = level.placement[ "all" ];
			topthreeplayers = min( 3, placement.size );
			index = 1;
			while ( index < topthreeplayers )
			{
				nexttopplayer = placement[ index ];
				updatewinstats( nexttopplayer );
				index++;
			}
		}
	}
	else i = 0;
	while ( i < players.size )
	{
		if ( !isDefined( players[ i ].pers[ "team" ] ) )
		{
			i++;
			continue;
		}
		else if ( level.hostforcedend && players[ i ] ishost() )
		{
			i++;
			continue;
		}
		else
		{
			if ( winner == "tie" )
			{
				updatetiestats( players[ i ] );
				i++;
				continue;
			}
			else if ( players[ i ].pers[ "team" ] == winner )
			{
				updatewinstats( players[ i ] );
				i++;
				continue;
			}
			else
			{
				if ( !level.disablestattracking )
				{
					players[ i ] setdstat( "playerstatslist", "cur_win_streak", "StatValue", 0 );
				}
			}
		}
		i++;
	}
}

backupandclearwinstreaks()
{
	self.pers[ "winStreak" ] = self getdstat( "playerstatslist", "cur_win_streak", "StatValue" );
	if ( !level.disablestattracking )
	{
		self setdstat( "playerstatslist", "cur_win_streak", "StatValue", 0 );
	}
	self.pers[ "winStreakForGametype" ] = maps/mp/gametypes/_persistence::statgetwithgametype( "cur_win_streak" );
	self maps/mp/gametypes/_persistence::statsetwithgametype( "cur_win_streak", 0 );
}

restorewinstreaks( winner )
{
	if ( !level.disablestattracking )
	{
		winner setdstat( "playerstatslist", "cur_win_streak", "StatValue", winner.pers[ "winStreak" ] );
	}
	winner maps/mp/gametypes/_persistence::statsetwithgametype( "cur_win_streak", winner.pers[ "winStreakForGametype" ] );
}

inckillstreaktracker( sweapon )
{
	self endon( "disconnect" );
	waittillframeend;
	if ( sweapon == "artillery_mp" )
	{
		self.pers[ "artillery_kills" ]++;
	}
	if ( sweapon == "dog_bite_mp" )
	{
		self.pers[ "dog_kills" ]++;
	}
}

trackattackerkill( name, rank, xp, prestige, xuid )
{
	self endon( "disconnect" );
	attacker = self;
	waittillframeend;
	pixbeginevent( "trackAttackerKill" );
	if ( !isDefined( attacker.pers[ "killed_players" ][ name ] ) )
	{
		attacker.pers[ "killed_players" ][ name ] = 0;
	}
	if ( !isDefined( attacker.killedplayerscurrent[ name ] ) )
	{
		attacker.killedplayerscurrent[ name ] = 0;
	}
	if ( !isDefined( attacker.pers[ "nemesis_tracking" ][ name ] ) )
	{
		attacker.pers[ "nemesis_tracking" ][ name ] = 0;
	}
	attacker.pers[ "killed_players" ][ name ]++;
	attacker.killedplayerscurrent[ name ]++;
	attacker.pers[ "nemesis_tracking" ][ name ] += 1;
	if ( attacker.pers[ "nemesis_name" ] == name )
	{
		attacker maps/mp/_challenges::killednemesis();
	}
	if ( attacker.pers[ "nemesis_name" ] == "" || attacker.pers[ "nemesis_tracking" ][ name ] > attacker.pers[ "nemesis_tracking" ][ attacker.pers[ "nemesis_name" ] ] )
	{
		attacker.pers[ "nemesis_name" ] = name;
		attacker.pers[ "nemesis_rank" ] = rank;
		attacker.pers[ "nemesis_rankIcon" ] = prestige;
		attacker.pers[ "nemesis_xp" ] = xp;
		attacker.pers[ "nemesis_xuid" ] = xuid;
	}
	else
	{
		if ( isDefined( attacker.pers[ "nemesis_name" ] ) && attacker.pers[ "nemesis_name" ] == name )
		{
			attacker.pers[ "nemesis_rank" ] = rank;
			attacker.pers[ "nemesis_xp" ] = xp;
		}
	}
	if ( !isDefined( attacker.lastkilledvictim ) || !isDefined( attacker.lastkilledvictimcount ) )
	{
		attacker.lastkilledvictim = name;
		attacker.lastkilledvictimcount = 0;
	}
	if ( attacker.lastkilledvictim == name )
	{
		attacker.lastkilledvictimcount++;
		if ( attacker.lastkilledvictimcount >= 5 )
		{
			attacker.lastkilledvictimcount = 0;
			attacker addplayerstat( "streaker", 1 );
		}
	}
	else
	{
		attacker.lastkilledvictim = name;
		attacker.lastkilledvictimcount = 1;
	}
	pixendevent();
}

trackattackeedeath( attackername, rank, xp, prestige, xuid )
{
	self endon( "disconnect" );
	waittillframeend;
	pixbeginevent( "trackAttackeeDeath" );
	if ( !isDefined( self.pers[ "killed_by" ][ attackername ] ) )
	{
		self.pers[ "killed_by" ][ attackername ] = 0;
	}
	self.pers[ "killed_by" ][ attackername ]++;
	if ( !isDefined( self.pers[ "nemesis_tracking" ][ attackername ] ) )
	{
		self.pers[ "nemesis_tracking" ][ attackername ] = 0;
	}
	self.pers[ "nemesis_tracking" ][ attackername ] += 1,5;
	if ( self.pers[ "nemesis_name" ] == "" || self.pers[ "nemesis_tracking" ][ attackername ] > self.pers[ "nemesis_tracking" ][ self.pers[ "nemesis_name" ] ] )
	{
		self.pers[ "nemesis_name" ] = attackername;
		self.pers[ "nemesis_rank" ] = rank;
		self.pers[ "nemesis_rankIcon" ] = prestige;
		self.pers[ "nemesis_xp" ] = xp;
		self.pers[ "nemesis_xuid" ] = xuid;
	}
	else
	{
		if ( isDefined( self.pers[ "nemesis_name" ] ) && self.pers[ "nemesis_name" ] == attackername )
		{
			self.pers[ "nemesis_rank" ] = rank;
			self.pers[ "nemesis_xp" ] = xp;
		}
	}
	if ( self.pers[ "nemesis_name" ] == attackername && self.pers[ "nemesis_tracking" ][ attackername ] >= 2 )
	{
		self setclientuivisibilityflag( "killcam_nemesis", 1 );
	}
	else
	{
		self setclientuivisibilityflag( "killcam_nemesis", 0 );
	}
	pixendevent();
}

default_iskillboosting()
{
	return 0;
}

givekillstats( smeansofdeath, sweapon, evictim )
{
	self endon( "disconnect" );
	waittillframeend;
	if ( level.rankedmatch && self [[ level.iskillboosting ]]() )
	{
/#
		self iprintlnbold( "GAMETYPE DEBUG: NOT GIVING YOU OFFENSIVE CREDIT AS BOOSTING PREVENTION" );
#/
		return;
	}
	pixbeginevent( "giveKillStats" );
	self maps/mp/gametypes/_globallogic_score::incpersstat( "kills", 1, 1, 1 );
	self.kills = self maps/mp/gametypes/_globallogic_score::getpersstat( "kills" );
	self updatestatratio( "kdratio", "kills", "deaths" );
	attacker = self;
	if ( smeansofdeath == "MOD_HEAD_SHOT" && !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( sweapon ) )
	{
		attacker thread incpersstat( "headshots", 1, 1, 0 );
		attacker.headshots = attacker.pers[ "headshots" ];
		if ( isDefined( evictim ) )
		{
			evictim recordkillmodifier( "headshot" );
		}
	}
	pixendevent();
}

inctotalkills( team )
{
	if ( level.teambased && isDefined( level.teams[ team ] ) )
	{
		game[ "totalKillsTeam" ][ team ]++;
	}
	game[ "totalKills" ]++;
}

setinflictorstat( einflictor, eattacker, sweapon )
{
	if ( !isDefined( eattacker ) )
	{
		return;
	}
	if ( !isDefined( einflictor ) )
	{
		eattacker addweaponstat( sweapon, "hits", 1 );
		return;
	}
	if ( !isDefined( einflictor.playeraffectedarray ) )
	{
		einflictor.playeraffectedarray = [];
	}
	foundnewplayer = 1;
	i = 0;
	while ( i < einflictor.playeraffectedarray.size )
	{
		if ( einflictor.playeraffectedarray[ i ] == self )
		{
			foundnewplayer = 0;
			break;
		}
		else
		{
			i++;
		}
	}
	if ( foundnewplayer )
	{
		einflictor.playeraffectedarray[ einflictor.playeraffectedarray.size ] = self;
		if ( sweapon == "concussion_grenade_mp" || sweapon == "tabun_gas_mp" )
		{
			eattacker addweaponstat( sweapon, "used", 1 );
		}
		eattacker addweaponstat( sweapon, "hits", 1 );
	}
}

processshieldassist( killedplayer )
{
	self endon( "disconnect" );
	killedplayer endon( "disconnect" );
	wait 0,05;
	maps/mp/gametypes/_globallogic_utils::waittillslowprocessallowed();
	if ( !isDefined( level.teams[ self.pers[ "team" ] ] ) )
	{
		return;
	}
	if ( self.pers[ "team" ] == killedplayer.pers[ "team" ] )
	{
		return;
	}
	if ( !level.teambased )
	{
		return;
	}
	self maps/mp/gametypes/_globallogic_score::incpersstat( "assists", 1, 1, 1 );
	self.assists = self maps/mp/gametypes/_globallogic_score::getpersstat( "assists" );
	maps/mp/_scoreevents::processscoreevent( "shield_assist", self, killedplayer, "riotshield_mp" );
}

processassist( killedplayer, damagedone, weapon )
{
	self endon( "disconnect" );
	killedplayer endon( "disconnect" );
	wait 0,05;
	maps/mp/gametypes/_globallogic_utils::waittillslowprocessallowed();
	if ( !isDefined( level.teams[ self.pers[ "team" ] ] ) )
	{
		return;
	}
	if ( self.pers[ "team" ] == killedplayer.pers[ "team" ] )
	{
		return;
	}
	if ( !level.teambased )
	{
		return;
	}
	assist_level = "assist";
	assist_level_value = int( ceil( damagedone / 25 ) );
	if ( assist_level_value < 1 )
	{
		assist_level_value = 1;
	}
	else
	{
		if ( assist_level_value > 3 )
		{
			assist_level_value = 3;
		}
	}
	assist_level = ( assist_level + "_" ) + ( assist_level_value * 25 );
	self maps/mp/gametypes/_globallogic_score::incpersstat( "assists", 1, 1, 1 );
	self.assists = self maps/mp/gametypes/_globallogic_score::getpersstat( "assists" );
	if ( isDefined( weapon ) )
	{
		self addweaponstat( weapon, "assists", 1 );
	}
	switch( weapon )
	{
		case "concussion_grenade_mp":
			assist_level = "assist_concussion";
			break;
		case "flash_grenade_mp":
			assist_level = "assist_flash";
			break;
		case "emp_grenade_mp":
			assist_level = "assist_emp";
			break;
		case "proximity_grenade_aoe_mp":
		case "proximity_grenade_mp":
			assist_level = "assist_proximity";
			break;
	}
	self maps/mp/_challenges::assisted();
	maps/mp/_scoreevents::processscoreevent( assist_level, self, killedplayer, weapon );
}

processkillstreakassists( attacker, inflictor, weaponname )
{
	if ( isDefined( attacker ) || !isDefined( attacker.team ) && self isenemyplayer( attacker ) == 0 )
	{
		return;
	}
	if ( self == attacker || attacker.classname == "trigger_hurt" && attacker.classname == "worldspawn" )
	{
		return;
	}
	enemycuavactive = 0;
	while ( attacker hasperk( "specialty_immunecounteruav" ) == 0 )
	{
		_a1403 = level.teams;
		_k1403 = getFirstArrayKey( _a1403 );
		while ( isDefined( _k1403 ) )
		{
			team = _a1403[ _k1403 ];
			if ( team == attacker.team )
			{
			}
			else
			{
				if ( level.activecounteruavs[ team ] > 0 )
				{
					enemycuavactive = 1;
				}
			}
			_k1403 = getNextArrayKey( _a1403, _k1403 );
		}
	}
	_a1417 = level.players;
	_k1417 = getFirstArrayKey( _a1417 );
	while ( isDefined( _k1417 ) )
	{
		player = _a1417[ _k1417 ];
		if ( player.team != attacker.team )
		{
		}
		else if ( player.team == "spectator" )
		{
		}
		else if ( player == attacker )
		{
		}
		else if ( player.sessionstate != "playing" )
		{
		}
		else
		{
/#
			assert( isDefined( player.activecounteruavs ) );
#/
/#
			assert( isDefined( player.activeuavs ) );
#/
/#
			assert( isDefined( player.activesatellites ) );
#/
			if ( player.activecounteruavs > 0 && !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( weaponname ) )
			{
				scoregiven = thread maps/mp/_scoreevents::processscoreevent( "counter_uav_assist", player );
				if ( isDefined( scoregiven ) )
				{
					player maps/mp/_challenges::earnedcuavassistscore( scoregiven );
				}
			}
			if ( enemycuavactive == 0 )
			{
				if ( player.activeuavs > 0 && !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( weaponname ) )
				{
					scoregiven = thread maps/mp/_scoreevents::processscoreevent( "uav_assist", player );
					if ( isDefined( scoregiven ) )
					{
						player maps/mp/_challenges::earneduavassistscore( scoregiven );
					}
				}
				if ( player.activesatellites > 0 && !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( weaponname ) )
				{
					scoregiven = thread maps/mp/_scoreevents::processscoreevent( "satellite_assist", player );
					if ( isDefined( scoregiven ) )
					{
						player maps/mp/_challenges::earnedsatelliteassistscore( scoregiven );
					}
				}
			}
		}
		_k1417 = getNextArrayKey( _a1417, _k1417 );
	}
	_a1466 = level.teams;
	_k1466 = getFirstArrayKey( _a1466 );
	while ( isDefined( _k1466 ) )
	{
		assistteam = _a1466[ _k1466 ];
		if ( assistteam == self.team )
		{
		}
		else if ( attacker.team != assistteam )
		{
		}
		else
		{
			activeempowner = level.empowners[ assistteam ];
			if ( isDefined( activeempowner ) && isplayer( activeempowner ) )
			{
				if ( isDefined( attacker ) && activeempowner != attacker )
				{
					if ( isDefined( activeempowner.emptime ) && activeempowner.spawntime < activeempowner.emptime )
					{
						scoregiven = maps/mp/_scoreevents::processscoreevent( "emp_assist", activeempowner );
						if ( isDefined( scoregiven ) )
						{
							activeempowner maps/mp/_challenges::earnedempassistscore( scoregiven );
						}
					}
				}
			}
		}
		_k1466 = getNextArrayKey( _a1466, _k1466 );
	}
}

xpratethread()
{
/#
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	while ( level.inprematchperiod )
	{
		wait 0,05;
	}
	for ( ;; )
	{
		wait 5;
		if ( isDefined( level.teams[ level.players[ 0 ].pers[ "team" ] ] ) )
		{
			self maps/mp/gametypes/_rank::giverankxp( "kill", int( min( getDvarInt( #"F8D00F60" ), 50 ) ) );
		}
#/
	}
}
