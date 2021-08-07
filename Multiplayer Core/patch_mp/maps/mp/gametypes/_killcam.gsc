#include maps/mp/gametypes/_globallogic_spawn;
#include maps/mp/gametypes/_spectating;
#include maps/mp/_tacticalinsertion;
#include maps/mp/_challenges;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	precachestring( &"PLATFORM_PRESS_TO_SKIP" );
	precachestring( &"PLATFORM_PRESS_TO_RESPAWN" );
	precacheshader( "white" );
	level.killcam = getgametypesetting( "allowKillcam" );
	level.finalkillcam = getgametypesetting( "allowFinalKillcam" );
	initfinalkillcam();
}

initfinalkillcam() //checked changed to match cerberus output
{
	level.finalkillcamsettings = [];
	initfinalkillcamteam( "none" );
	foreach ( team in level.teams )
	{
		initfinalkillcamteam( team );
	}
	level.finalkillcam_winner = undefined;
}

initfinalkillcamteam( team ) //checked matches cerberus output
{
	level.finalkillcamsettings[ team ] = spawnstruct();
	clearfinalkillcamteam( team );
}

clearfinalkillcamteam( team ) //checked matches cerberus output
{
	level.finalkillcamsettings[ team ].spectatorclient = undefined;
	level.finalkillcamsettings[ team ].weapon = undefined;
	level.finalkillcamsettings[ team ].deathtime = undefined;
	level.finalkillcamsettings[ team ].deathtimeoffset = undefined;
	level.finalkillcamsettings[ team ].offsettime = undefined;
	level.finalkillcamsettings[ team ].entityindex = undefined;
	level.finalkillcamsettings[ team ].targetentityindex = undefined;
	level.finalkillcamsettings[ team ].entitystarttime = undefined;
	level.finalkillcamsettings[ team ].perks = undefined;
	level.finalkillcamsettings[ team ].killstreaks = undefined;
	level.finalkillcamsettings[ team ].attacker = undefined;
}

recordkillcamsettings( spectatorclient, targetentityindex, sweapon, deathtime, deathtimeoffset, offsettime, entityindex, entitystarttime, perks, killstreaks, attacker ) //checked matches cerberus output
{
	if ( level.teambased && isDefined( attacker.team ) && isDefined( level.teams[ attacker.team ] ) )
	{
		team = attacker.team;
		level.finalkillcamsettings[ team ].spectatorclient = spectatorclient;
		level.finalkillcamsettings[ team ].weapon = sweapon;
		level.finalkillcamsettings[ team ].deathtime = deathtime;
		level.finalkillcamsettings[ team ].deathtimeoffset = deathtimeoffset;
		level.finalkillcamsettings[ team ].offsettime = offsettime;
		level.finalkillcamsettings[ team ].entityindex = entityindex;
		level.finalkillcamsettings[ team ].targetentityindex = targetentityindex;
		level.finalkillcamsettings[ team ].entitystarttime = entitystarttime;
		level.finalkillcamsettings[ team ].perks = perks;
		level.finalkillcamsettings[ team ].killstreaks = killstreaks;
		level.finalkillcamsettings[ team ].attacker = attacker;
	}
	level.finalkillcamsettings[ "none" ].spectatorclient = spectatorclient;
	level.finalkillcamsettings[ "none" ].weapon = sweapon;
	level.finalkillcamsettings[ "none" ].deathtime = deathtime;
	level.finalkillcamsettings[ "none" ].deathtimeoffset = deathtimeoffset;
	level.finalkillcamsettings[ "none" ].offsettime = offsettime;
	level.finalkillcamsettings[ "none" ].entityindex = entityindex;
	level.finalkillcamsettings[ "none" ].targetentityindex = targetentityindex;
	level.finalkillcamsettings[ "none" ].entitystarttime = entitystarttime;
	level.finalkillcamsettings[ "none" ].perks = perks;
	level.finalkillcamsettings[ "none" ].killstreaks = killstreaks;
	level.finalkillcamsettings[ "none" ].attacker = attacker;
}

erasefinalkillcam() //checked changed to match cerberus output
{
	clearfinalkillcamteam( "none" );
	foreach ( team in level.teams )
	{
		clearfinalkillcamteam( team );
	}
	level.finalkillcam_winner = undefined;
}

finalkillcamwaiter() //checked matches cerberus output
{
	if ( !isDefined( level.finalkillcam_winner ) )
	{
		return 0;
	}
	level waittill( "final_killcam_done" );
	return 1;
}

postroundfinalkillcam() //checked matches cerberus output
{
	if ( is_true( level.sidebet ) )
	{
		return;
	}
	level notify( "play_final_killcam" );
	maps/mp/gametypes/_globallogic::resetoutcomeforallplayers();
	finalkillcamwaiter();
}

dofinalkillcam() //checked changed to match cerberus output
{
	level waittill( "play_final_killcam" );
	level.infinalkillcam = 1;
	winner = "none";
	if ( isDefined( level.finalkillcam_winner ) )
	{
		winner = level.finalkillcam_winner;
	}
	if ( !isDefined( level.finalkillcamsettings[ winner ].targetentityindex ) )
	{
		level.infinalkillcam = 0;
		level notify( "final_killcam_done" );
		return;
	}
	if ( isDefined( level.finalkillcamsettings[ winner ].attacker ) )
	{
		maps/mp/_challenges::getfinalkill( level.finalkillcamsettings[ winner ].attacker );
	}
	visionsetnaked( getDvar( "mapname" ), 0 );
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[ index ];
		player closemenu();
		player closeingamemenu();
		player thread finalkillcam( winner );
	}
	wait 0.1;
	while ( areanyplayerswatchingthekillcam() )
	{
		wait 0.05;
	}
	level notify( "final_killcam_done" );
	level.infinalkillcam = 0;
}

startlastkillcam() //checked matches cerberus output
{
}

areanyplayerswatchingthekillcam() //checked changed to match cerberus output
{
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[ index ];
		if ( isDefined( player.killcam ) )
		{
			return 1;
		}
	}
	return 0;
}

killcam( attackernum, targetnum, killcamentity, killcamentityindex, killcamentitystarttime, sweapon, deathtime, deathtimeoffset, offsettime, respawn, maxtime, perks, killstreaks, attacker ) //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self endon( "spawned" );
	level endon( "game_ended" );
	if ( attackernum < 0 )
	{
		return;
	}
	postdeathdelay = ( getTime() - deathtime ) / 1000;
	predelay = postdeathdelay + deathtimeoffset;
	camtime = calckillcamtime( sweapon, killcamentitystarttime, predelay, respawn, maxtime );
	postdelay = calcpostdelay();
	killcamlength = camtime + postdelay;
	if ( isDefined( maxtime ) && killcamlength > maxtime )
	{
		if ( maxtime < 2 )
		{
			return;
		}
		if ( ( maxtime - camtime ) >= 1 )
		{
			postdelay = maxtime - camtime;
		}
		else
		{
			postdelay = 1;
			camtime = maxtime - 1;
		}
		killcamlength = camtime + postdelay;
	}
	killcamoffset = camtime + predelay;
	self notify( "begin_killcam", getTime() );
	killcamstarttime = getTime() - ( killcamoffset * 1000 );
	self.sessionstate = "spectator";
	self.spectatorclient = attackernum;
	self.killcamentity = -1;
	if ( killcamentityindex >= 0 )
	{
		self thread setkillcamentity( killcamentityindex, killcamentitystarttime - killcamstarttime - 100 );
	}
	self.killcamtargetentity = targetnum;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = offsettime;
	recordkillcamsettings( attackernum, targetnum, sweapon, deathtime, deathtimeoffset, offsettime, killcamentityindex, killcamentitystarttime, perks, killstreaks, attacker );
	foreach ( team in level.teams )
	{
		self allowspectateteam( team, 1 );
	}
	self allowspectateteam( "freelook", 1 );
	self allowspectateteam( "none", 1 );
	self thread endedkillcamcleanup();
	wait 0.05;
	if ( self.archivetime <= predelay )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		self notify( "end_killcam" );
		return;
	}
	self thread checkforabruptkillcamend();
	self.killcam = 1;
	self addkillcamskiptext( respawn );
	if ( !self issplitscreen() && level.perksenabled == 1 )
	{
		self addkillcamtimer( camtime );
		self maps/mp/gametypes/_hud_util::showperks();
	}
	self thread spawnedkillcamcleanup();
	self thread waitskipkillcambutton();
	self thread waitteamchangeendkillcam();
	self thread waitkillcamtime();
	self thread maps/mp/_tacticalinsertion::cancel_button_think();
	self waittill( "end_killcam" );
	self endkillcam( 0 );
	self.sessionstate = "dead";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
}

setkillcamentity( killcamentityindex, delayms ) //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	self endon( "spawned" );
	if ( delayms > 0 )
	{
		wait ( delayms / 1000 );
	}
	self.killcamentity = killcamentityindex;
}

waitkillcamtime() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	wait ( self.killcamlength - 0.05 );
	self notify( "end_killcam" );
}

waitfinalkillcamslowdown( deathtime, starttime ) //checked matches cerberus output 
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	secondsuntildeath = ( deathtime - starttime ) / 1000;
	deathtime = getTime() + ( secondsuntildeath * 1000 );
	waitbeforedeath = 2;
	maps/mp/_utility::setclientsysstate( "levelNotify", "fkcb" );
	wait max( 0, secondsuntildeath - waitbeforedeath );
	setslowmotion( 1, 0.25, waitbeforedeath );
	wait ( waitbeforedeath + 0.5 );
	setslowmotion( 0.25, 1, 1 );
	wait 0.5;
	maps/mp/_utility::setclientsysstate( "levelNotify", "fkce" );
}

waitskipkillcambutton() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	while ( self usebuttonpressed() )
	{
		wait 0.05;
	}
	while ( !self usebuttonpressed() )
	{
		wait 0.05;
	}
	self notify( "end_killcam" );
	self clientnotify( "fkce" );
}

waitteamchangeendkillcam() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	self waittill( "changed_class" );
	endkillcam( 0 );
}

waitskipkillcamsafespawnbutton() //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	while ( self fragbuttonpressed() )
	{
		wait 0.05;
	}
	while ( !self fragbuttonpressed() )
	{
		wait 0.05;
	}
	self.wantsafespawn = 1;
	self notify( "end_killcam" );
}

endkillcam( final ) //checked matches cerberus output
{
	if ( isDefined( self.kc_skiptext ) )
	{
		self.kc_skiptext.alpha = 0;
	}
	if ( isDefined( self.kc_timer ) )
	{
		self.kc_timer.alpha = 0;
	}
	self.killcam = undefined;
	if ( !self issplitscreen() )
	{
		self hideallperks();
	}
	self thread maps/mp/gametypes/_spectating::setspectatepermissions();
}

checkforabruptkillcamend() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	while ( 1 )
	{
		if ( self.archivetime <= 0 )
		{
			break;
		}
		wait 0.05;
	}
	self notify( "end_killcam" );
}

spawnedkillcamcleanup() //checked matches cerberus output 
{
	self endon( "end_killcam" );
	self endon( "disconnect" );
	self waittill( "spawned" );
	self endkillcam( 0 );
}

spectatorkillcamcleanup( attacker ) //checked matches cerberus output
{
	self endon( "end_killcam" );
	self endon( "disconnect" );
	attacker endon( "disconnect" );
	attacker waittill( "begin_killcam", attackerkcstarttime );
	waittime = max( 0, attackerkcstarttime - self.deathtime - 50 );
	wait waittime;
	self endkillcam( 0 );
}

endedkillcamcleanup() //checked matches cerberus output
{
	self endon( "end_killcam" );
	self endon( "disconnect" );
	level waittill( "game_ended" );
	self endkillcam( 0 );
}

endedfinalkillcamcleanup() //checked matches cerberus output
{
	self endon( "end_killcam" );
	self endon( "disconnect" );
	level waittill( "game_ended" );
	self endkillcam( 1 );
}

cancelkillcamusebutton() //checked matches cerberus output
{
	return self usebuttonpressed();
}

cancelkillcamsafespawnbutton() //checked matches cerberus output
{
	return self fragbuttonpressed();
}

cancelkillcamcallback() //checked matches cerberus output
{
	self.cancelkillcam = 1;
}

cancelkillcamsafespawncallback() //checked matches cerberus output
{
	self.cancelkillcam = 1;
	self.wantsafespawn = 1;
}

cancelkillcamonuse() //checked matches cerberus output
{
	self thread cancelkillcamonuse_specificbutton( ::cancelkillcamusebutton, ::cancelkillcamcallback );
}

cancelkillcamonuse_specificbutton( pressingbuttonfunc, finishedfunc ) //checked changed at own discretion
{
	self endon( "death_delay_finished" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		if ( !self [[ pressingbuttonfunc ]]() )
		{
			wait 0.05;
			continue;
		}
		buttontime = 0;
		while ( self [[ pressingbuttonfunc ]]() )
		{
			buttontime += 0.05;
			wait 0.05;
		}
		if ( buttontime >= 0.5 )
		{
			continue;
		}
		buttontime = 0;
		while ( !( self [[ pressingbuttonfunc ]]() ) && buttontime < 0.5 )
		{
			buttontime += 0.05;
			wait 0.05;
		}
		if ( buttontime >= 0.5 )
		{
			continue;
		}
		else
		{
			self [[ finishedfunc ]]();
			return;
		}
		wait 0.05;
	}
}

finalkillcam( winner ) //checked changed to match cerberus output
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	if ( waslastround() )
	{
		setmatchflag( "final_killcam", 1 );
		setmatchflag( "round_end_killcam", 0 );
	}
	else
	{
		setmatchflag( "final_killcam", 0 );
		setmatchflag( "round_end_killcam", 1 );
	}
	/*
/#
	if ( getDvarInt( "scr_force_finalkillcam" ) == 1 )
	{
		setmatchflag( "final_killcam", 1 );
		setmatchflag( "round_end_killcam", 0 );
#/
	}
	*/
	if ( level.console )
	{
		self maps/mp/gametypes/_globallogic_spawn::setthirdperson( 0 );
	}
	killcamsettings = level.finalkillcamsettings[ winner ];
	postdeathdelay = ( getTime() - killcamsettings.deathtime ) / 1000;
	predelay = postdeathdelay + killcamsettings.deathtimeoffset;
	camtime = calckillcamtime( killcamsettings.weapon, killcamsettings.entitystarttime, predelay, 0, undefined );
	postdelay = calcpostdelay();
	killcamoffset = camtime + predelay;
	killcamlength = ( camtime + postdelay ) - 0.05;
	killcamstarttime = getTime() - ( killcamoffset * 1000 );
	self notify( "begin_killcam", getTime() );
	self.sessionstate = "spectator";
	self.spectatorclient = killcamsettings.spectatorclient;
	self.killcamentity = -1;
	if ( killcamsettings.entityindex >= 0 )
	{
		self thread setkillcamentity( killcamsettings.entityindex, killcamsettings.entitystarttime - killcamstarttime - 100 );
	}
	self.killcamtargetentity = killcamsettings.targetentityindex;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = killcamsettings.offsettime;
	foreach ( team in level.teams )
	{
		self allowspectateteam( team, 1 );
	}
	self allowspectateteam( "freelook", 1 );
	self allowspectateteam( "none", 1 );
	self thread endedfinalkillcamcleanup();
	wait 0.05;
	if ( self.archivetime <= predelay )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		self notify( "end_killcam" );
		return;
	}
	self thread checkforabruptkillcamend();
	self.killcam = 1;
	if ( !self issplitscreen() )
	{
		self addkillcamtimer( camtime );
	}
	self thread waitkillcamtime();
	self thread waitfinalkillcamslowdown( level.finalkillcamsettings[ winner ].deathtime, killcamstarttime );
	self waittill( "end_killcam" );
	self endkillcam( 1 );
	setmatchflag( "final_killcam", 0 );
	setmatchflag( "round_end_killcam", 0 );
	self spawnendoffinalkillcam();
}

spawnendoffinalkillcam() //checked matches cerberus output
{
	[[ level.spawnspectator ]]();
	self freezecontrols( 1 );
}

iskillcamentityweapon( sweapon ) //checked matches cerberus output
{
	if ( sweapon == "planemortar_mp" )
	{
		return 1;
	}
	return 0;
}

iskillcamgrenadeweapon( sweapon ) //checked changed to match cerberus output
{
	if ( sweapon == "frag_grenade_mp" )
	{
		return 1;
	}
	else if ( sweapon == "frag_grenade_short_mp" )
	{
		return 1;
	}
	else if ( sweapon == "sticky_grenade_mp" )
	{
		return 1;
	}
	else if ( sweapon == "tabun_gas_mp" )
	{
		return 1;
	}
	return 0;
}

calckillcamtime( sweapon, entitystarttime, predelay, respawn, maxtime ) //checked matches cerberus output dvars found in another dump
{
	camtime = 0;
	if ( getDvar( "scr_killcam_time" ) == "" )
	{
		if ( iskillcamentityweapon( sweapon ) )
		{
			camtime = ( ( getTime() - entitystarttime ) / 1000 ) - predelay - 0.1;
		}
		else if ( !respawn )
		{
			camtime = 5;
		}
		else if ( iskillcamgrenadeweapon( sweapon ) )
		{
			camtime = 4.25;
		}
		else
		{
			camtime = 2.5;
		}
	}
	else
	{	
		camtime = getDvarFloat( "scr_killcam_time" );
	}
	if ( isDefined( maxtime ) )
	{
		if ( camtime > maxtime )
		{
			camtime = maxtime;
		}
		if ( camtime < 0.05 )
		{
			camtime = 0.05;
		}
	}
	return camtime;
}

calcpostdelay() //checked matches cerberus output dvars found in another dump
{
	postdelay = 0;
	if ( getDvar( "scr_killcam_posttime" ) == "" )
	{
		postdelay = 2;
	}
	else
	{
		postdelay = getDvarFloat( "scr_killcam_posttime" );
		if ( postdelay < 0.05 )
		{
			postdelay = 0.05;
		}
	}
	return postdelay;
}

addkillcamskiptext( respawn ) //checked matches cerberus output
{
	if ( !isDefined( self.kc_skiptext ) )
	{
		self.kc_skiptext = newclienthudelem( self );
		self.kc_skiptext.archived = 0;
		self.kc_skiptext.x = 0;
		self.kc_skiptext.alignx = "center";
		self.kc_skiptext.aligny = "middle";
		self.kc_skiptext.horzalign = "center";
		self.kc_skiptext.vertalign = "bottom";
		self.kc_skiptext.sort = 1;
		self.kc_skiptext.font = "objective";
	}
	if ( self issplitscreen() )
	{
		self.kc_skiptext.y = -100;
		self.kc_skiptext.fontscale = 1.4;
	}
	else
	{
		self.kc_skiptext.y = -120;
		self.kc_skiptext.fontscale = 2;
	}
	if ( respawn )
	{
		self.kc_skiptext settext( &"PLATFORM_PRESS_TO_RESPAWN" );
	}
	else
	{
		self.kc_skiptext settext( &"PLATFORM_PRESS_TO_SKIP" );
	}
	self.kc_skiptext.alpha = 1;
}

addkillcamtimer( camtime ) //checked matches cerberus output
{
}

initkcelements() //checked matches cerberus output
{
	if ( !isDefined( self.kc_skiptext ) )
	{
		self.kc_skiptext = newclienthudelem( self );
		self.kc_skiptext.archived = 0;
		self.kc_skiptext.x = 0;
		self.kc_skiptext.alignx = "center";
		self.kc_skiptext.aligny = "top";
		self.kc_skiptext.horzalign = "center_adjustable";
		self.kc_skiptext.vertalign = "top_adjustable";
		self.kc_skiptext.sort = 1;
		self.kc_skiptext.font = "default";
		self.kc_skiptext.foreground = 1;
		self.kc_skiptext.hidewheninmenu = 1;
		if ( self issplitscreen() )
		{
			self.kc_skiptext.y = 20;
			self.kc_skiptext.fontscale = 1.2;
		}
		else
		{
			self.kc_skiptext.y = 32;
			self.kc_skiptext.fontscale = 1.8;
		}
	}
	if ( !isDefined( self.kc_othertext ) )
	{
		self.kc_othertext = newclienthudelem( self );
		self.kc_othertext.archived = 0;
		self.kc_othertext.y = 48;
		self.kc_othertext.alignx = "left";
		self.kc_othertext.aligny = "top";
		self.kc_othertext.horzalign = "center";
		self.kc_othertext.vertalign = "middle";
		self.kc_othertext.sort = 10;
		self.kc_othertext.font = "small";
		self.kc_othertext.foreground = 1;
		self.kc_othertext.hidewheninmenu = 1;
		if ( self issplitscreen() )
		{
			self.kc_othertext.x = 16;
			self.kc_othertext.fontscale = 1.2;
		}
		else
		{
			self.kc_othertext.x = 32;
			self.kc_othertext.fontscale = 1.6;
		}
	}
	if ( !isDefined( self.kc_icon ) )
	{
		self.kc_icon = newclienthudelem( self );
		self.kc_icon.archived = 0;
		self.kc_icon.x = 16;
		self.kc_icon.y = 16;
		self.kc_icon.alignx = "left";
		self.kc_icon.aligny = "top";
		self.kc_icon.horzalign = "center";
		self.kc_icon.vertalign = "middle";
		self.kc_icon.sort = 1;
		self.kc_icon.foreground = 1;
		self.kc_icon.hidewheninmenu = 1;
	}
	if ( !self issplitscreen() )
	{
		if ( !isDefined( self.kc_timer ) )
		{
			self.kc_timer = createfontstring( "hudbig", 1 );
			self.kc_timer.archived = 0;
			self.kc_timer.x = 0;
			self.kc_timer.alignx = "center";
			self.kc_timer.aligny = "middle";
			self.kc_timer.horzalign = "center_safearea";
			self.kc_timer.vertalign = "top_adjustable";
			self.kc_timer.y = 42;
			self.kc_timer.sort = 1;
			self.kc_timer.font = "hudbig";
			self.kc_timer.foreground = 1;
			self.kc_timer.color = vectorScale( ( 1, 1, 1 ), 0.85 );
			self.kc_timer.hidewheninmenu = 1;
		}
	}
}

