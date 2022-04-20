#include maps/mp/gametypes_zm/_globallogic_utils;
#include maps/mp/_challenges;
#include maps/mp/gametypes_zm/_globallogic_audio;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/_bb;
#include maps/mp/_utility;
#include common_scripts/utility;

updatematchbonusscores( winner )
{
}

givematchbonus( scoretype, score )
{
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
		if ( !isDefined( players[ i ].score ) )
		{
			i++;
			continue;
		}
		else if ( players[ i ].score < 1 )
		{
			i++;
			continue;
		}
		else if ( !isDefined( winner ) || players[ i ].score > winner.score )
		{
			winner = players[ i ];
			tie = 0;
			i++;
			continue;
		}
		else
		{
			if ( players[ i ].score == winner.score )
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
	}
	score += rampagebonus;
	if ( score > 0 && self hasperk( "specialty_earnmoremomentum" ) )
	{
		score = roundtonearestfive( int( ( score * getDvarFloat( "perk_killstreakMomentumMultiplier" ) ) + 0,5 ) );
	}
	_setplayermomentum( self, self.pers[ "momentum" ] + score );
}

resetplayermomentumondeath()
{
	if ( isDefined( level.usingscorestreaks ) && level.usingscorestreaks )
	{
		_setplayermomentum( self, 0 );
		self thread resetscorechain();
	}
}

giveplayermomentum( event, player, victim, weapon, descvalue )
{
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
	player addplayerstatwithgametype( "score", scorediff );
	if ( isDefined( player.pers[ "lastHighestScore" ] ) && newscore > player.pers[ "lastHighestScore" ] )
	{
		player setdstat( "HighestStats", "highest_score", newscore );
	}
	pixendevent();
	return scorediff;
}

default_onplayerscore( event, player, victim )
{
}

_setplayerscore( player, score )
{
}

_getplayerscore( player )
{
	return player.pers[ "score" ];
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
	if ( momentum > oldmomentum )
	{
		highestmomentumcost = 0;
		numkillstreaks = player.killstreak.size;
		killstreaktypearray = [];
	}
	player.pers[ "momentum" ] = momentum;
	player.momentum = player.pers[ "momentum" ];
}

_giveplayerkillstreakinternal( player, momentum, oldmomentum, killstreaktypearray )
{
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
	thread maps/mp/gametypes_zm/_globallogic::checkscorelimit();
}

giveteamscoreforobjective( team, score )
{
	teamscore = game[ "teamScores" ][ team ];
	onteamscore( score, team );
	newscore = game[ "teamScores" ][ team ];
	bbprint( "mpteamobjscores", "gametime %d  team %d diff %d score %d", getTime(), team, newscore - teamscore, newscore );
	if ( teamscore == newscore )
	{
		return;
	}
	updateteamscores( team );
	thread maps/mp/gametypes_zm/_globallogic::checkscorelimit();
}

_setteamscore( team, teamscore )
{
	if ( teamscore == game[ "teamScores" ][ team ] )
	{
		return;
	}
	game[ "teamScores" ][ team ] = teamscore;
	updateteamscores( team );
	thread maps/mp/gametypes_zm/_globallogic::checkscorelimit();
}

resetteamscores()
{
	while ( isDefined( level.roundscorecarry ) || level.roundscorecarry == 0 && maps/mp/_utility::isfirstround() )
	{
		_a591 = level.teams;
		_k591 = getFirstArrayKey( _a591 );
		while ( isDefined( _k591 ) )
		{
			team = _a591[ _k591 ];
			game[ "teamScores" ][ team ] = 0;
			_k591 = getNextArrayKey( _a591, _k591 );
		}
	}
	maps/mp/gametypes_zm/_globallogic_score::updateallteamscores();
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
	level thread maps/mp/gametypes_zm/_globallogic::checkteamscorelimitsoon( team );
}

updateallteamscores()
{
	_a629 = level.teams;
	_k629 = getFirstArrayKey( _a629 );
	while ( isDefined( _k629 ) )
	{
		team = _a629[ _k629 ];
		updateteamscores( team );
		_k629 = getNextArrayKey( _a629, _k629 );
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
	_a645 = level.teams;
	_k645 = getFirstArrayKey( _a645 );
	while ( isDefined( _k645 ) )
	{
		team = _a645[ _k645 ];
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
		_k645 = getNextArrayKey( _a645, _k645 );
	}
	return winning_teams;
}

areteamarraysequal( teamsa, teamsb )
{
	if ( teamsa.size != teamsb.size )
	{
		return 0;
	}
	_a668 = teamsa;
	_k668 = getFirstArrayKey( _a668 );
	while ( isDefined( _k668 ) )
	{
		team = _a668[ _k668 ];
		if ( !isDefined( teamsb[ team ] ) )
		{
			return 0;
		}
		_k668 = getNextArrayKey( _a668, _k668 );
	}
	return 1;
}

onteamscore( score, team )
{
	game[ "teamScores" ][ team ] += score;
	if ( level.scorelimit && game[ "teamScores" ][ team ] > level.scorelimit )
	{
		game[ "teamScores" ][ team ] = level.scorelimit;
	}
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
	level.laststatustime = getTime();
	while ( iswinning.size == 1 )
	{
		_a707 = iswinning;
		_k707 = getFirstArrayKey( _a707 );
		while ( isDefined( _k707 ) )
		{
			team = _a707[ _k707 ];
			if ( isDefined( level.waswinning[ team ] ) )
			{
				if ( level.waswinning.size == 1 )
				{
				}
			}
			else
			{
				maps/mp/gametypes_zm/_globallogic_audio::leaderdialog( "lead_taken", team, "status" );
			}
			_k707 = getNextArrayKey( _a707, _k707 );
		}
	}
	while ( level.waswinning.size == 1 )
	{
		_a726 = level.waswinning;
		_k726 = getFirstArrayKey( _a726 );
		while ( isDefined( _k726 ) )
		{
			team = _a726[ _k726 ];
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
				maps/mp/gametypes_zm/_globallogic_audio::leaderdialog( "lead_lost", team, "status" );
			}
			_k726 = getNextArrayKey( _a726, _k726 );
		}
	}
	level.waswinning = iswinning;
}

default_onteamscore( event, team )
{
}

initpersstat( dataname, record_stats, init_to_stat_value )
{
	if ( !isDefined( self.pers[ dataname ] ) )
	{
		self.pers[ dataname ] = 0;
	}
	if ( !isDefined( record_stats ) || record_stats == 1 )
	{
		recordplayerstats( self, dataname, int( self.pers[ dataname ] ) );
	}
	if ( isDefined( init_to_stat_value ) && init_to_stat_value == 1 )
	{
		self.pers[ dataname ] = self getdstat( "PlayerStatsList", dataname, "StatValue" );
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
	loser setdstat( "playerstatslist", "cur_win_streak", "StatValue", 0 );
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
	}
	else
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
					players[ i ] setdstat( "playerstatslist", "cur_win_streak", "StatValue", 0 );
				}
			}
			i++;
		}
	}
}

backupandclearwinstreaks()
{
}

restorewinstreaks( winner )
{
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
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "kills", 1, 1, 1 );
	self.kills = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "kills" );
	self updatestatratio( "kdratio", "kills", "deaths" );
	attacker = self;
	if ( smeansofdeath == "MOD_HEAD_SHOT" )
	{
		attacker thread incpersstat( "headshots", 1, 1, 0 );
		attacker.headshots = attacker.pers[ "headshots" ];
		evictim recordkillmodifier( "headshot" );
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
	maps/mp/gametypes_zm/_globallogic_utils::waittillslowprocessallowed();
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
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "assists", 1, 1, 1 );
	self.assists = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "assists" );
}

processassist( killedplayer, damagedone, weapon )
{
	self endon( "disconnect" );
	killedplayer endon( "disconnect" );
	wait 0,05;
	maps/mp/gametypes_zm/_globallogic_utils::waittillslowprocessallowed();
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
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "assists", 1, 1, 1 );
	self.assists = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "assists" );
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
}

xpratethread()
{
/#
#/
}
