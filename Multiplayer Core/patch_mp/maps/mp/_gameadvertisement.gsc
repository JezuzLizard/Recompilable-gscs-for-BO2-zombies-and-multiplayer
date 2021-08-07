#include maps/mp/gametypes/_dev;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/_utility;

init()
{
/#
	level.sessionadvertstatus = 1;
	thread sessionadvertismentupdatedebughud();
#/
	thread sessionadvertisementcheck();
}

setadvertisedstatus( onoff )
{
/#
	level.sessionadvertstatus = onoff;
#/
	changeadvertisedstatus( onoff );
}

sessionadvertisementcheck()
{
	if ( sessionmodeisprivate() )
	{
		return;
	}
	if ( sessionmodeiszombiesgame() )
	{
		setadvertisedstatus( 0 );
		return;
	}
	runrules = getgametyperules();
	if ( !isDefined( runrules ) )
	{
		return;
	}
	level endon( "game_end" );
	level waittill( "prematch_over" );
	while ( 1 )
	{
		sessionadvertcheckwait = getdvarintdefault( "sessionAdvertCheckwait", 1 );
		wait sessionadvertcheckwait;
		advertise = [[ runrules ]]();
		setadvertisedstatus( advertise );
	}
}

getgametyperules()
{
	gametype = level.gametype;
	switch( gametype )
	{
		case "dm":
			return ::dm_rules;
		case "tdm":
			return ::tdm_rules;
		case "dom":
			return ::dom_rules;
		case "hq":
			return ::hq_rules;
		case "sd":
			return ::sd_rules;
		case "dem":
			return ::dem_rules;
		case "ctf":
			return ::ctf_rules;
		case "koth":
			return ::koth_rules;
		case "conf":
			return ::conf_rules;
		case "oic":
			return ::oic_rules;
		case "sas":
			return ::sas_rules;
		case "gun":
			return ::gun_rules;
		case "shrp":
			return ::shrp_rules;
	}
	return;
}

teamscorelimitcheck( rulescorepercent )
{
	if ( level.scorelimit )
	{
		minscorepercentageleft = 100;
		_a100 = level.teams;
		_k100 = getFirstArrayKey( _a100 );
		while ( isDefined( _k100 ) )
		{
			team = _a100[ _k100 ];
			scorepercentageleft = 100 - ( ( game[ "teamScores" ][ team ] / level.scorelimit ) * 100 );
			if ( minscorepercentageleft > scorepercentageleft )
			{
				minscorepercentageleft = scorepercentageleft;
			}
			if ( rulescorepercent >= scorepercentageleft )
			{
/#
				updatedebughud( 3, "Score Percentage Left: ", int( scorepercentageleft ) );
#/
				return 0;
			}
			_k100 = getNextArrayKey( _a100, _k100 );
		}
/#
		updatedebughud( 3, "Score Percentage Left: ", int( minscorepercentageleft ) );
#/
	}
	return 1;
}

timelimitcheck( ruletimeleft )
{
	maxtime = level.timelimit;
	if ( maxtime != 0 )
	{
		timeleft = maps/mp/gametypes/_globallogic_utils::gettimeremaining();
		if ( ruletimeleft >= timeleft )
		{
			return 0;
		}
	}
	return 1;
}

dm_rules()
{
	rulescorepercent = 35;
	ruletimeleft = 60000 * 1,5;
/#
	updatedebughud( 1, "Any player is within percent of score cap: ", rulescorepercent );
	updatedebughud( 2, "Time limit has less than minutes remaining: ", ruletimeleft / 60000 );
#/
	if ( level.scorelimit )
	{
		highestscore = 0;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ].pointstowin > highestscore )
			{
				highestscore = players[ i ].pointstowin;
			}
			i++;
		}
		scorepercentageleft = 100 - ( ( highestscore / level.scorelimit ) * 100 );
/#
		updatedebughud( 3, "Score Percentage Left: ", int( scorepercentageleft ) );
#/
		if ( rulescorepercent >= scorepercentageleft )
		{
			return 0;
		}
	}
	if ( timelimitcheck( ruletimeleft ) == 0 )
	{
		return 0;
	}
	return 1;
}

tdm_rules()
{
	rulescorepercent = 15;
	ruletimeleft = 60000 * 1,5;
/#
	updatedebughud( 1, "Any player is within percent of score cap: ", rulescorepercent );
	updatedebughud( 2, "Time limit has less than minutes remaining: ", ruletimeleft / 60000 );
#/
	if ( teamscorelimitcheck( rulescorepercent ) == 0 )
	{
		return 0;
	}
	if ( timelimitcheck( ruletimeleft ) == 0 )
	{
		return 0;
	}
	return 1;
}

dom_rules()
{
	rulescorepercent = 15;
	ruletimeleft = 60000 * 1,5;
	ruleround = 3;
	currentround = game[ "roundsplayed" ] + 1;
/#
	updatedebughud( 1, "Time limit 1.5 minutes remaining in final round. Any player is within percent of score cap: ", rulescorepercent );
	updatedebughud( 2, "Is round: ", ruleround );
	updatedebughud( 4, "Current Round: ", currentround );
#/
	if ( currentround >= 2 )
	{
		if ( teamscorelimitcheck( rulescorepercent ) == 0 )
		{
			return 0;
		}
	}
	if ( timelimitcheck( ruletimeleft ) == 0 )
	{
		return 0;
	}
	if ( ruleround <= currentround )
	{
		return 0;
	}
	return 1;
}

hq_rules()
{
	return koth_rules();
}

sd_rules()
{
	ruleround = 3;
/#
	updatedebughud( 1, "Any team has won rounds: ", ruleround );
#/
	maxroundswon = 0;
	_a299 = level.teams;
	_k299 = getFirstArrayKey( _a299 );
	while ( isDefined( _k299 ) )
	{
		team = _a299[ _k299 ];
		roundswon = game[ "teamScores" ][ team ];
		if ( maxroundswon < roundswon )
		{
			maxroundswon = roundswon;
		}
		if ( ruleround <= roundswon )
		{
/#
			updatedebughud( 3, "Max Rounds Won: ", maxroundswon );
#/
			return 0;
		}
		_k299 = getNextArrayKey( _a299, _k299 );
	}
/#
	updatedebughud( 3, "Max Rounds Won: ", maxroundswon );
#/
	return 1;
}

dem_rules()
{
	return ctf_rules();
}

ctf_rules()
{
	ruleround = 3;
	roundsplayed = game[ "roundsplayed" ];
/#
	updatedebughud( 1, "Is round or later: ", ruleround );
	updatedebughud( 3, "Rounds Played: ", roundsplayed );
#/
	if ( ruleround <= roundsplayed )
	{
		return 0;
	}
	return 1;
}

koth_rules()
{
	rulescorepercent = 20;
	ruletimeleft = 60000 * 1,5;
/#
	updatedebughud( 1, "Any player is within percent of score cap: ", rulescorepercent );
	updatedebughud( 2, "Time limit has less than minutes remaining: ", ruletimeleft / 60000 );
#/
	if ( teamscorelimitcheck( rulescorepercent ) == 0 )
	{
		return 0;
	}
	if ( timelimitcheck( ruletimeleft ) == 0 )
	{
		return 0;
	}
	return 1;
}

conf_rules()
{
	return tdm_rules();
}

oic_rules()
{
/#
	updatedebughud( 1, "No join in progress, so shouldnt advertise to matchmaking once the countdown timer ends.", 0 );
#/
	return 0;
}

sas_rules()
{
	rulescorepercent = 35;
	ruletimeleft = 60000 * 1,5;
/#
	updatedebughud( 1, "Any player is within percent of score cap: ", rulescorepercent );
	updatedebughud( 2, "Time limit has less than minutes remaining: ", ruletimeleft / 60000 );
#/
	if ( teamscorelimitcheck( rulescorepercent ) == 0 )
	{
		return 0;
	}
	if ( timelimitcheck( ruletimeleft ) == 0 )
	{
		return 0;
	}
	return 1;
}

gun_rules()
{
	ruleweaponsleft = 3;
/#
	updatedebughud( 1, "Any player is within X weapons from winning: ", ruleweaponsleft );
#/
	minweaponsleft = level.gunprogression.size;
	_a455 = level.players;
	_k455 = getFirstArrayKey( _a455 );
	while ( isDefined( _k455 ) )
	{
		player = _a455[ _k455 ];
		weaponsleft = level.gunprogression.size - player.gunprogress;
		if ( minweaponsleft > weaponsleft )
		{
			minweaponsleft = weaponsleft;
		}
		if ( ruleweaponsleft >= minweaponsleft )
		{
/#
			updatedebughud( 3, "Weapons Left: ", minweaponsleft );
#/
			return 0;
		}
		_k455 = getNextArrayKey( _a455, _k455 );
	}
/#
	updatedebughud( 3, "Weapons Left: ", minweaponsleft );
#/
	return 1;
}

shrp_rules()
{
	rulescorepercent = 35;
	ruletimeleft = 60000 * 1,5;
/#
	updatedebughud( 1, "Any player is within percent of score cap: ", rulescorepercent );
	updatedebughud( 2, "Time limit has less than minutes remaining: ", ruletimeleft / 60000 );
#/
	if ( teamscorelimitcheck( rulescorepercent ) == 0 )
	{
		return 0;
	}
	if ( timelimitcheck( ruletimeleft ) == 0 )
	{
		return 0;
	}
	return 1;
}

sessionadvertismentcreatedebughud( linenum, alignx )
{
/#
	debug_hud = maps/mp/gametypes/_dev::new_hud( "session_advert", "debug_hud", 0, 0, 1 );
	debug_hud.hidewheninmenu = 1;
	debug_hud.horzalign = "right";
	debug_hud.vertalign = "middle";
	debug_hud.alignx = "right";
	debug_hud.aligny = "middle";
	debug_hud.x = alignx;
	debug_hud.y = -50 + ( linenum * 15 );
	debug_hud.foreground = 1;
	debug_hud.font = "default";
	debug_hud.fontscale = 1,5;
	debug_hud.color = ( 1, 0, 0 );
	debug_hud.alpha = 1;
	debug_hud settext( "" );
	return debug_hud;
#/
}

updatedebughud( hudindex, text, value )
{
/#
	switch( hudindex )
	{
		case 1:
			level.sessionadverthud_1a_text = text;
			level.sessionadverthud_1b_text = value;
			break;
		case 2:
			level.sessionadverthud_2a_text = text;
			level.sessionadverthud_2b_text = value;
			break;
		case 3:
			level.sessionadverthud_3a_text = text;
			level.sessionadverthud_3b_text = value;
			break;
		case 4:
			level.sessionadverthud_4a_text = text;
			level.sessionadverthud_4b_text = value;
			break;
	}
#/
}

sessionadvertismentupdatedebughud()
{
/#
	level endon( "game_end" );
	sessionadverthud_0 = undefined;
	sessionadverthud_1a = undefined;
	sessionadverthud_1b = undefined;
	sessionadverthud_2a = undefined;
	sessionadverthud_2b = undefined;
	sessionadverthud_3a = undefined;
	sessionadverthud_3b = undefined;
	sessionadverthud_4a = undefined;
	sessionadverthud_4b = undefined;
	level.sessionadverthud_0_text = "";
	level.sessionadverthud_1a_text = "";
	level.sessionadverthud_1b_text = "";
	level.sessionadverthud_2a_text = "";
	level.sessionadverthud_2b_text = "";
	level.sessionadverthud_3a_text = "";
	level.sessionadverthud_3b_text = "";
	level.sessionadverthud_4a_text = "";
	level.sessionadverthud_4b_text = "";
	while ( 1 )
	{
		wait 1;
		showdebughud = getdvarintdefault( "sessionAdvertShowDebugHud", 0 );
		level.sessionadverthud_0_text = "Session is advertised";
		if ( level.sessionadvertstatus == 0 )
		{
			level.sessionadverthud_0_text = "Session is not advertised";
		}
		if ( !isDefined( sessionadverthud_0 ) && showdebughud != 0 )
		{
			host = gethostplayer();
			while ( !isDefined( host ) )
			{
				continue;
			}
			sessionadverthud_0 = host sessionadvertismentcreatedebughud( 0, 0 );
			sessionadverthud_1a = host sessionadvertismentcreatedebughud( 1, -20 );
			sessionadverthud_1b = host sessionadvertismentcreatedebughud( 1, 0 );
			sessionadverthud_2a = host sessionadvertismentcreatedebughud( 2, -20 );
			sessionadverthud_2b = host sessionadvertismentcreatedebughud( 2, 0 );
			sessionadverthud_3a = host sessionadvertismentcreatedebughud( 3, -20 );
			sessionadverthud_3b = host sessionadvertismentcreatedebughud( 3, 0 );
			sessionadverthud_4a = host sessionadvertismentcreatedebughud( 4, -20 );
			sessionadverthud_4b = host sessionadvertismentcreatedebughud( 4, 0 );
			sessionadverthud_1a.color = vectorScale( ( 1, 0, 0 ), 0,5 );
			sessionadverthud_1b.color = vectorScale( ( 1, 0, 0 ), 0,5 );
			sessionadverthud_2a.color = vectorScale( ( 1, 0, 0 ), 0,5 );
			sessionadverthud_2b.color = vectorScale( ( 1, 0, 0 ), 0,5 );
		}
		if ( isDefined( sessionadverthud_0 ) )
		{
			if ( showdebughud == 0 )
			{
				sessionadverthud_0 destroy();
				sessionadverthud_1a destroy();
				sessionadverthud_1b destroy();
				sessionadverthud_2a destroy();
				sessionadverthud_2b destroy();
				sessionadverthud_3a destroy();
				sessionadverthud_3b destroy();
				sessionadverthud_4a destroy();
				sessionadverthud_4b destroy();
				sessionadverthud_0 = undefined;
				sessionadverthud_1a = undefined;
				sessionadverthud_1b = undefined;
				sessionadverthud_2a = undefined;
				sessionadverthud_2b = undefined;
				sessionadverthud_3a = undefined;
				sessionadverthud_3b = undefined;
				sessionadverthud_4a = undefined;
				sessionadverthud_4b = undefined;
				break;
			}
			else
			{
				if ( level.sessionadvertstatus == 1 )
				{
					sessionadverthud_0.color = ( 1, 0, 0 );
				}
				else
				{
					sessionadverthud_0.color = vectorScale( ( 1, 0, 0 ), 0,9 );
				}
				sessionadverthud_0 settext( level.sessionadverthud_0_text );
				if ( level.sessionadverthud_1a_text != "" )
				{
					sessionadverthud_1a settext( level.sessionadverthud_1a_text );
					sessionadverthud_1b setvalue( level.sessionadverthud_1b_text );
				}
				if ( level.sessionadverthud_2a_text != "" )
				{
					sessionadverthud_2a settext( level.sessionadverthud_2a_text );
					sessionadverthud_2b setvalue( level.sessionadverthud_2b_text );
				}
				if ( level.sessionadverthud_3a_text != "" )
				{
					sessionadverthud_3a settext( level.sessionadverthud_3a_text );
					sessionadverthud_3b setvalue( level.sessionadverthud_3b_text );
				}
				if ( level.sessionadverthud_4a_text != "" )
				{
					sessionadverthud_4a settext( level.sessionadverthud_4a_text );
					sessionadverthud_4b setvalue( level.sessionadverthud_4b_text );
				}
			}
		}
#/
	}
}
