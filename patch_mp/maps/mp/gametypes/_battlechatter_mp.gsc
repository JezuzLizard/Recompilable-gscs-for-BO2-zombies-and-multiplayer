//checked includes match cerberus output
#include maps/mp/killstreaks/_killstreaks;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked changed to match cerberus output
{
	if ( level.createfx_enabled )
	{
		return;
	}
	foreach ( team in level.teams )
	{
		/*
/#
		assert( isDefined( level.teamprefix[ team ] ) );
#/
/#
		assert( isDefined( level.teamprefix[ team ] ) );
#/
		*/
		level.isteamspeaking[ team ] = 0;
		level.speakers[ team ] = [];
	}
	level.bcsounds = [];
	level.bcsounds[ "inform_attack" ] = "attack";
	level.bcsounds[ "c4_out" ] = "c4";
	level.bcsounds[ "claymore_out" ] = "claymore";
	level.bcsounds[ "emp_out" ] = "emp";
	level.bcsounds[ "flash_out" ] = "flash";
	level.bcsounds[ "gas_out" ] = "gas";
	level.bcsounds[ "frag_out" ] = "grenade";
	level.bcsounds[ "revive_out" ] = "revive";
	level.bcsounds[ "smoke_out" ] = "smoke";
	level.bcsounds[ "sticky_out" ] = "sticky";
	level.bcsounds[ "gas_incoming" ] = "gas";
	level.bcsounds[ "grenade_incoming" ] = "incoming";
	level.bcsounds[ "kill" ] = "kill";
	level.bcsounds[ "kill_sniper" ] = "kill_sniper";
	level.bcsounds[ "revive" ] = "need_revive";
	level.bcsounds[ "reload" ] = "reloading";
	level.bcsounds[ "enemy" ] = "threat";
	level.bcsounds[ "sniper" ] = "sniper";
	level.bcsounds[ "conc_out" ] = "attack_stun";
	level.bcsounds[ "satchel_plant" ] = "attack_throwsatchel";
	level.bcsounds[ "casualty" ] = "casualty_gen";
	level.bcsounds[ "flare_out" ] = "attack_flare";
	level.bcsounds[ "betty_plant" ] = "plant";
	level.bcsounds[ "landmark" ] = "landmark";
	level.bcsounds[ "taunt" ] = "taunt";
	level.bcsounds[ "killstreak_enemy" ] = "enemy";
	level.bcsounds[ "killstreak_taunt" ] = "kls";
	level.bcsounds[ "kill_killstreak" ] = "killstreak";
	level.bcsounds[ "destructible" ] = "destructible_near";
	level.bcsounds[ "teammate" ] = "teammate_near";
	level.bcsounds[ "gametype" ] = "gametype";
	level.bcsounds[ "squad" ] = "squad";
	level.bcsounds[ "gametype" ] = "gametype";
	level.bcsounds[ "perk" ] = "perk_equip";
	level.bcsounds[ "pain" ] = "pain";
	level.bcsounds[ "death" ] = "death";
	level.bcsounds[ "breathing" ] = "breathing";
	level.bcsounds[ "inform_need" ] = "need";
	level.bcsounds[ "scream" ] = "scream";
	level.bcsounds[ "fire" ] = "fire";
	setdvar( "bcmp_weapon_delay", "2000" );
	setdvar( "bcmp_weapon_fire_probability", "80" );
	setdvar( "bcmp_weapon_reload_probability", "60" );
	setdvar( "bcmp_weapon_fire_threat_probability", "80" );
	setdvar( "bcmp_sniper_kill_probability", "20" );
	setdvar( "bcmp_ally_kill_probability", "60" );
	setdvar( "bcmp_killstreak_incoming_probability", "100" );
	setdvar( "bcmp_perk_call_probability", "100" );
	setdvar( "bcmp_incoming_grenade_probability", "5" );
	setdvar( "bcmp_toss_grenade_probability", "20" );
	setdvar( "bcmp_toss_trophy_probability", "80" );
	setdvar( "bcmp_kill_inform_probability", "40" );
	setdvar( "bcmp_pain_small_probability", "0" );
	setdvar( "bcmp_breathing_probability", "0" );
	setdvar( "bcmp_pain_delay", ".5" );
	setdvar( "bcmp_last_stand_delay", "3" );
	setdvar( "bcmp_breathing_delay", "" );
	setdvar( "bcmp_enemy_contact_delay", "30" );
	setdvar( "bcmp_enemy_contact_level_delay", "15" );
	level.bcweapondelay = getDvarInt( "bcmp_weapon_delay" );
	level.bcweaponfireprobability = getDvarInt( "bcmp_weapon_fire_probability" );
	level.bcweaponreloadprobability = getDvarInt( "bcmp_weapon_reload_probability" );
	level.bcweaponfirethreatprobability = getDvarInt( "bcmp_weapon_fire_threat_probability" );
	level.bcsniperkillprobability = getDvarInt( "bcmp_sniper_kill_probability" );
	level.bcallykillprobability = getDvarInt( "bcmp_ally_kill_probability" );
	level.bckillstreakincomingprobability = getDvarInt( "bcmp_killstreak_incoming_probability" );
	level.bcperkcallprobability = getDvarInt( "bcmp_perk_call_probability" );
	level.bcincominggrenadeprobability = getDvarInt( "bcmp_incoming_grenade_probability" );
	level.bctossgrenadeprobability = getDvarInt( "bcmp_toss_grenade_probability" );
	level.bctosstrophyprobability = getDvarInt( "bcmp_toss_trophy_probability" );
	level.bckillinformprobability = getDvarInt( "bcmp_kill_inform_probability" );
	level.bcpainsmallprobability = getDvarInt( "bcmp_pain_small_probability" );
	level.bcpaindelay = getDvarInt( "bcmp_pain_delay" );
	level.bclaststanddelay = getDvarInt( "bcmp_last_stand_delay" );
	level.bcmp_breathing_delay = getDvarInt( "bcmp_breathing_delay" );
	level.bcmp_enemy_contact_delay = getDvarInt( "bcmp_enemy_contact_delay" );
	level.bcmp_enemy_contact_level_delay = getDvarInt( "bcmp_enemy_contact_level_delay" );
	level.bcmp_breathing_probability = getDvarInt( "bcmp_breathing_probability" );
	level.allowbattlechatter = getgametypesetting( "allowBattleChatter" );
	level.landmarks = getentarray( "trigger_landmark", "targetname" );
	level.enemyspotteddialog = 1;
	level thread enemycontactleveldelay();
	level thread onplayerconnect();
	level thread updatebcdvars();
	level.battlechatter_init = 1;
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onjoinedteam();
		player thread onplayerspawned();
	}
}

updatebcdvars() //checked matches cerberus output
{
	level endon( "game_ended" );
	for ( ;; )
	{
		level.bcweapondelay = getDvarInt( "bcmp_weapon_delay" );
		level.bckillinformprobability = getDvarInt( "bcmp_kill_inform_probability" );
		level.bcweaponfireprobability = getDvarInt( "bcmp_weapon_fire_probability" );
		level.bcsniperkillprobability = getDvarInt( "bcmp_sniper_kill_probability" );
		level thread maps/mp/gametypes/_globallogic::updateteamstatus();
		wait 2;
	}
}

onjoinedteam() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_team" );
		self.pers[ "bcVoiceNumber" ] = randomintrange( 0, 3 );
		self.pilotisspeaking = 0;
	}
}

onjoinedspectators() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "joined_spectators" );
	}
}

onplayerspawned() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self.lastbcattempttime = 0;
		self.heartbeatsnd = 0;
		self.soundmod = "player";
		self.bcvoicenumber = self.pers[ "bcVoiceNumber" ];
		self.pilotisspeaking = 0;
		if ( level.splitscreen )
		{
			continue;
		}
		self thread reloadtracking();
		self thread grenadetracking();
		self thread enemythreat();
		self thread stickygrenadetracking();
		self thread painvox();
		self thread allyrevive();
		self thread onfirescream();
		self thread deathvox();
		self thread watchmissileusage();
	}
}

enemycontactleveldelay()
{
	while ( 1 ) //checked matches cerberus output
	{
		level waittill( "level_enemy_spotted" );
		level.enemyspotteddialog = 0;
		wait level.bcmp_enemy_contact_level_delay;
		level.enemyspotteddialog = 1;
	}
}

breathinghurtvox() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		self waittill( "snd_breathing_hurt" );
		if ( randomintrange( 0, 100 ) >= level.bcmp_breathing_probability )
		{
			wait 0.5;
			if ( isalive( self ) )
			{
				level thread mpsaylocalsound( self, "breathing", "hurt", 0, 1 );
			}
		}
		wait level.bcmp_breathing_delay;
	}
}

onfirescream() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "snd_burn_scream" );
		if ( randomintrange( 0, 100 ) >= level.bcmp_breathing_probability )
		{
			wait 0.5;
			if ( isalive( self ) )
			{
				level thread mpsaylocalsound( self, "fire", "scream" );
			}
		}
		wait level.bcmp_breathing_delay;
	}
}

breathingbettervox() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		self waittill( "snd_breathing_better" );
		if ( isalive( self ) )
		{
			level thread mpsaylocalsound( self, "breathing", "better", 0, 1 );
		}
	}
}

laststandvox() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self waittill( "snd_last_stand" );
	for ( ;; )
	{
		self waittill( "weapon_fired" );
		if ( isalive( self ) )
		{
			level thread mpsaylocalsound( self, "perk", "laststand" );
		}
		wait level.bclaststanddelay;
	}
}

allyrevive() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "snd_ally_revive" );
		if ( isalive( self ) )
		{
			level thread mpsaylocalsound( self, "inform_attack", "revive" );
		}
		wait level.bclaststanddelay;
	}
}

painvox() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "snd_pain_player" );
		if ( randomintrange( 0, 100 ) >= level.bcpainsmallprobability )
		{
			if ( isalive( self ) )
			{
				soundalias = level.teamprefix[ self.team ] + self.bcvoicenumber + "_" + level.bcsounds[ "pain" ] + "_" + "small";
				self thread dosound( soundalias );
			}
		}
		wait level.bcpaindelay;
	}
}

deathvox() //checked matches cerberus output
{
	self endon( "disconnect" );
	self waittill( "death" );
	if ( self.team != "spectator" )
	{
		soundalias = level.teamprefix[ self.team ] + self.bcvoicenumber + "_" + level.bcsounds[ "pain" ] + "_" + "death";
		self thread dosound( soundalias );
	}
}

stickygrenadetracking() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "sticky_explode" );
	for ( ;; )
	{
		self waittill( "grenade_stuck", grenade );
		if ( isDefined( grenade ) )
		{
			grenade.stucktoplayer = self;
		}
		if ( isalive( self ) )
		{
			level thread mpsaylocalsound( self, "grenade_incoming", "sticky" );
		}
		self notify( "sticky_explode" );
	}
}

onplayersuicideorteamkill( player, type ) //checked matches cerberus output
{
	self endon( "disconnect" );
	waittillframeend;
	if ( !isDefined( level.battlechatter_init ) )
	{
		return;
	}
	if ( !level.teambased )
	{
		return;
	}
	myteam = player.team;
	if ( isDefined( level.aliveplayers[ myteam ] ) )
	{
		if ( level.aliveplayers[ myteam ].size )
		{
			index = checkdistancetoevent( player, 1000000 );
			if ( isDefined( index ) )
			{
				wait 1;
				if ( isalive( level.aliveplayers[ myteam ][ index ] ) )
				{
					level thread mpsaylocalsound( level.aliveplayers[ myteam ][ index ], "teammate", type );
				}
			}
		}
	}
}

onplayerkillstreak( player ) //checked matches cerberus output
{
	player endon( "disconnect" );
}

onkillstreakused( killstreak, team ) //checked matches cerberus output
{
}

onplayernearexplodable( object, type ) //checked matches cerberus output
{
	self endon( "disconnect" );
	self endon( "explosion_started" );
}

shoeboxtracking() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "begin_firing" );
		weaponname = self getcurrentweapon();
		if ( weaponname == "mine_shoebox_mp" )
		{
			level thread mpsaylocalsound( self, "satchel_plant", "shoebox" );
		}
	}
}

checkweaponreload( weapon ) //checked matches cerberus output
{
	switch( weapon )
	{
		case "crossbow_mp":
		case "fhj18_mp":
		case "judge_mp":
		case "smaw_mp":
		case "usrpg_mp":
			return 0;
		default:
			return 1;
	}
}

reloadtracking() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "reload_start" );
		if ( randomintrange( 0, 100 ) >= level.bcweaponreloadprobability )
		{
			weaponname = self getcurrentweapon();
			weaponshouldreload = checkweaponreload( weaponname );
			if ( weaponshouldreload )
			{
				level thread mpsaylocalsound( self, "reload", "gen" );
			}
		}
	}
}

perkspecificbattlechatter( type, checkdistance ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "perk_done" );
}

enemythreat() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "weapon_fired" );
		if ( level.enemyspotteddialog )
		{
			if ( ( getTime() - self.lastbcattempttime ) > level.bcmp_enemy_contact_delay )
			{
				shooter = self;
				myteam = self.team;
				closest_enemy = shooter get_closest_player_enemy();
				self.lastbcattempttime = getTime();
				if ( isDefined( closest_enemy ) )
				{
					if ( randomintrange( 0, 100 ) >= level.bcweaponfirethreatprobability )
					{
						area = 360000;
						if ( distancesquared( closest_enemy.origin, self.origin ) < area )
						{
							level thread mpsaylocalsound( closest_enemy, "enemy", "infantry", 0 );
							level notify( "level_enemy_spotted" );
						}
					}
				}
			}
		}
	}
}

weaponfired() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "weapon_fired" );
		if ( ( getTime() - self.lastbcattempttime ) > level.bcweapondelay )
		{
			self.lastbcattempttime = getTime();
			if ( randomintrange( 0, 100 ) >= level.bcweaponfireprobability )
			{
				self.landmarkent = self getlandmark();
				if ( isDefined( self.landmarkent ) )
				{
					myteam = self.team;
					foreach ( team in level.teams )
					{
						if ( team == myteam )
						{
							break;
						}
						keys = getarraykeys( level.squads[ team ] );
						for ( i = 0; i < keys.size; i++ ) 
						{
							if ( level.squads[ team ][ keys[ i ] ].size )
							{
								index = randomintrange( 0, level.squads[ team ][ keys[ i ] ].size );
								level thread mpsaylocalsound( level.squads[ team ][ keys[ i ] ][ index ], "enemy", "infantry" );
							}
						}
					}
				}
			}
		}
	}
}

killedbysniper( sniper ) //checked matches cerberus output
{
	self endon( "disconnect" );
	sniper endon( "disconnect" );
	waittillframeend;
	if ( !isDefined( level.battlechatter_init ) )
	{
		return;
	}
	victim = self;
	if ( level.hardcoremode || !level.teambased )
	{
		return;
	}
	sniper.issniperspotted = 1;
	if ( randomintrange( 0, 100 ) >= level.bcsniperkillprobability )
	{
		sniperteam = sniper.team;
		victimteam = self.team;
		index = checkdistancetoevent( victim, 1000000 );
		if ( isDefined( index ) )
		{
			level thread mpsaylocalsound( level.aliveplayers[ victimteam ][ index ], "enemy", "sniper", 0 );
		}
	}
}

playerkilled( attacker ) //checked matches cerberus output
{
	self endon( "disconnect" );
	if ( !isplayer( attacker ) )
	{
		return;
	}
	waittillframeend;
	if ( !isDefined( level.battlechatter_init ) )
	{
		return;
	}
	victim = self;
	if ( level.hardcoremode )
	{
		return;
	}
	if ( randomintrange( 0, 100 ) >= level.bcallykillprobability )
	{
		attackerteam = attacker.team;
		victimteam = self.team;
		closest_ally = victim get_closest_player_ally();
		area = 1000000;
		if ( isDefined( closest_ally ) )
		{
			if ( distancesquared( closest_ally.origin, self.origin ) < area )
			{
				level thread mpsaylocalsound( closest_ally, "inform_attack", "revive", 0 );
			}
		}
	}
}

grenadetracking() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "grenade_fire", grenade, weaponname );
		if ( weaponname == "frag_grenade_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "grenade" );
			}
			level thread incominggrenadetracking( self, grenade, "grenade" );
			continue;
		}
		if ( weaponname == "satchel_charge_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "c4" );
			}
			continue;
		}
		if ( weaponname == "emp_grenade_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "emp" );
			}
			continue;
		}
		if ( weaponname == "claymore_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "claymore" );
			}
			continue;
		}
		if ( weaponname == "flash_grenade_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "flash" );
			}
			continue;
		}
		if ( weaponname == "sticky_grenade_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "sticky" );
			}
			continue;
		}
		if ( weaponname == "tabun_gas_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "gas" );
			}
			continue;
		}
		if ( weaponname == "willy_pete_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "smoke" );
			}
			continue;
		}
		if ( weaponname == "hatchet_mp" || weaponname == "proximity_grenade_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "hatchet" );
			}
			continue;
		}
		if ( weaponname == "concussion_grenade_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "concussion" );
			}
			continue;
		}
		if ( weaponname == "scrambler_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "scrambler" );
			}
			continue;
		}
		if ( weaponname == "tactical_insertion_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "tactical" );
			}
			continue;
		}
		if ( weaponname == "bouncingbetty_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctosstrophyprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "c4" );
			}
			continue;
		}
		if ( weaponname == "sensor_grenade_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "hatchet" );
			}
			continue;
		}
		if ( weaponname == "trophy_system_mp" )
		{
			if ( randomintrange( 0, 100 ) >= level.bctosstrophyprobability )
			{
				level thread mpsaylocalsound( self, "inform_attack", "scrambler" );
			}
		}
	}
}

watchmissileusage() //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		self waittill( "missile_fire", missile, weapon_name );
		if ( weapon_name == "usrpg_mp" )
		{
			level thread incominggrenadetracking( self, missile, "rpg", 0.2 );
		}
		return;
	}
}

incominggrenadetracking( thrower, grenade, type, waittime ) //checked matches cerberus output
{
	if ( randomintrange( 0, 100 ) >= level.bcincominggrenadeprobability )
	{
		if ( !isDefined( waittime ) )
		{
			waittime = 1;
		}
		wait waittime;
		if ( !isDefined( thrower ) )
		{
			return;
		}
		if ( thrower.team == "spectator" )
		{
			return;
		}
		enemyteam = thrower.team;
		if ( level.players.size )
		{
			player = checkdistancetoobject( 250000, grenade, enemyteam, thrower );
			if ( isDefined( player ) )
			{
				level thread mpsaylocalsound( player, "grenade_incoming", type );
			}
		}
	}
}

incomingspecialgrenadetracking( type ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "grenade_ended" );
	for ( ;; )
	{
		if ( randomintrange( 0, 100 ) >= level.bcincominggrenadeprobability )
		{
			if ( level.aliveplayers[ self.team ].size || !level.teambased && level.players.size )
			{
				level thread mpsaylocalsound( self, "grenade_incoming", type );
				self notify( "grenade_ended" );
			}
		}
		wait 3;
	}
}

gametypespecificbattlechatter( event, team ) //checked changed to match the beta dump _battlechatter_mp.gsc
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "event_ended" );
	for ( ;; )
	{
		if ( isDefined( team ) )
		{

			index = CheckDistanceToEvent( self, 300 * 300 );
			if ( isDefined( index ) )
			{
				level thread mpSayLocalSound( level.alivePlayers[ team ][ index ], "gametype", event );
				self notify( "event_ended" );
			}
		}
		else
		{
			foreach ( team in level.teams )
			{
				index = randomIntRange( 0, level.alivePlayers[ team ].size );
				level thread mpSayLocalSound( level.alivePlayers[ team ][ index ], "gametype", event );
			}
		}
		wait 1;
	}
}

checkweaponkill( weapon ) //checked matches cerberus output
{
	switch( weapon )
	{
		case "cobra_20mm_comlink_mp":
		case "knife_mp":
			return 1;
		default:
			return 0;
	}
}

saykillbattlechatter( attacker, sweapon, victim ) //checked changed to match cerberus output
{
	if ( checkweaponkill( sweapon ) )
	{
		return;
	}
	if ( isDefined( victim.issniperspotted ) && victim.issniperspotted && randomintrange( 0, 100 ) >= level.bckillinformprobability )
	{
		level thread saylocalsounddelayed( attacker, "kill", "sniper", 0.75 );
		victim.issniperspotted = 0;
	}
	else if ( isDefined( level.bckillinformprobability ) && randomintrange( 0, 100 ) >= level.bckillinformprobability )
	{
		if ( !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( sweapon ) )
		{
			level thread saylocalsounddelayed( attacker, "kill", "infantry", 0.75 );
		}
	}
}

saylocalsounddelayed( player, soundtype1, soundtype2, delay ) //checked matches cerberus output
{
	player endon( "death" );
	player endon( "disconnect" );
	if ( !isDefined( level.battlechatter_init ) )
	{
		return;
	}
	wait delay;
	mpsaylocalsound( player, soundtype1, soundtype2 );
}

saylocalsound( player, soundtype ) //checked matches cerberus output
{
	player endon( "death" );
	player endon( "disconnect" );
	if ( isspeakerinrange( player ) )
	{
		return;
	}
	if ( player.team != "spectator" )
	{
		soundalias = level.teamprefix[ player.team ] + player.bcvoicenumber + "_" + level.bcsounds[ soundtype ];
	}
}

mpsaylocalsound( player, partone, parttwo, checkspeakers, is2d ) //checked changed to match cerberus output
{
	player endon( "death" );
	player endon( "disconnect" );
	if ( level.players.size <= 1 )
	{
		return;
	}
	if ( !isDefined( checkspeakers ) )
	{
		if ( isspeakerinrange( player ) )
		{
			return;
		}
	}
	if ( player hasperk( "specialty_quieter" ) )
	{
		return;
	}
	if ( player.team != "spectator" )
	{
		soundalias = level.teamprefix[ player.team ] + player.bcvoicenumber + "_" + level.bcsounds[ partone ] + "_" + parttwo;
		if ( isDefined( is2d ) )
		{
			player thread dosound( soundalias, is2d );
		}
		else
		{
			player thread dosound( soundalias );
		}
	}
}

mpsaylocationallocalsound( player, prefix, partone, parttwo ) //checked matches cerberus output
{
	player endon( "death" );
	player endon( "disconnect" );
	if ( level.players.size <= 1 )
	{
		return;
	}
	if ( isspeakerinrange( player ) )
	{
		return;
	}
	if ( player.team != "spectator" )
	{
		soundalias1 = level.teamprefix[ player.team ] + player.bcvoicenumber + "_" + level.bcsounds[ prefix ];
		soundalias2 = level.teamprefix[ player.team ] + player.bcvoicenumber + "_" + level.bcsounds[ partone ] + "_" + parttwo;
		player thread dolocationalsound( soundalias1, soundalias2 );
	}
}

dosound( soundalias, is2d ) //checked changed to match cerberus output
{
	team = self.team;
	level addspeaker( self, team );
	if ( isDefined( is2d ) )
	{
		self playlocalsound( soundalias );
	}
	else if ( level.allowbattlechatter && level.teambased )
	{
		self playsoundontag( soundalias, "J_Head" );
	}
	self thread waitplaybacktime( soundalias );
	self waittill_any( soundalias, "death", "disconnect" );
	level removespeaker( self, team );
}

dolocationalsound( soundalias1, soundalias2 ) //checked matches cerberus output
{
	team = self.team;
	level addspeaker( self, team );
	if ( level.allowbattlechatter && level.teambased )
	{
		self playbattlechattertoteam( soundalias1, soundalias2, team, self );
	}
	self thread waitplaybacktime( soundalias1 );
	self waittill_any( soundalias1, "death", "disconnect" );
	level removespeaker( self, team );
}

waitplaybacktime( soundalias ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	playbacktime = soundgetplaybacktime( soundalias );
	if ( playbacktime >= 0 )
	{
		waittime = playbacktime * 0,001;
		wait waittime;
	}
	else
	{
		wait 1;
	}
	self notify( soundalias );
}

isspeakerinrange( player ) //checked changed to match cerberus output
{
	player endon( "death" );
	player endon( "disconnect" );
	distsq = 1000000;
	if ( isDefined( player ) && isDefined( player.team ) && player.team != "spectator" )
	{
		for ( index = 0; index < level.speakers[player.team].size; index++ )
		{
			teammate = level.speakers[ player.team ][ index ];
			if ( teammate == player )
			{
				return 1;
			}
			if ( distancesquared( teammate.origin, player.origin ) < distsq )
			{
				return 1;
			}
		}
	}
	return 0;
}

addspeaker( player, team ) //checked matches cerberus output
{
	level.speakers[ team ][ level.speakers[ team ].size ] = player;
}

removespeaker( player, team ) //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
{
	newspeakers = [];
	index = 0;
	while ( index < level.speakers[ team ].size )
	{
		if ( level.speakers[ team ][ index ] == player )
		{
			index++;
			continue;
		}
		newspeakers[ newspeakers.size ] = level.speakers[ team ][ index ];
		index++;
	}
	level.speakers[ team ] = newspeakers;
}

getlandmark() //checked changed to match cerberus output
{
	landmarks = level.landmarks;
	for ( i = 0; i < landmarks.size; i++ )
	{
		if ( self istouching( landmarks[ i ] ) && isDefined( landmarks[ i ].script_landmark ) )
		{
			return landmarks[ i ];
		}
	}
	return undefined;
}

checkdistancetoevent( player, area ) //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
{
	if ( !isDefined( player ) )
	{
		return undefined;
	}
	index = 0;
	while ( index < level.aliveplayers[ player.team ].size )
	{
		teammate = level.aliveplayers[ player.team ][ index ];
		if ( !isDefined( teammate ) )
		{
			index++;
			continue;
		}
		if ( teammate == player )
		{
			index++;
			continue;
		}
		if ( distancesquared( teammate.origin, player.origin ) < area )
		{
			return index;
		}
		index++;
	}
}

checkdistancetoenemy( enemy, area, team ) //checked changed to match cerberus output
{
	if ( !isDefined( enemy ) )
	{
		return undefined;
	}
	for ( index = 0; index < level.aliveplayers[team].size; index++ )
	{
		player = level.aliveplayers[ team ][ index ];
		if ( distancesquared( enemy.origin, player.origin ) < area )
		{
			return index;
		}
	}
}

checkdistancetoobject( area, object, ignoreteam, ignoreent ) //checked partially changed to match cerberus output did not change while loops to for loops see github for more info
{
	if ( isDefined( ignoreteam ) )
	{
		foreach ( team in level.teams )
		{
			i = 0;
			while ( i < level.aliveplayers[ team ].size )
			{
				player = level.aliveplayers[ team ][ i ];
				if ( isDefined( ignoreent ) && player == ignoreent )
				{
					i++;
					continue;
				}
				if ( isDefined( object ) && distancesquared( player.origin, object.origin ) < area )
				{
					return player;
				}
				i++;
			}
		}
	}
	i = 0;
	while ( i < level.players.size )
	{
		player = level.players[ i ];
		if ( isDefined( ignoreent ) && player == ignoreent )
		{
			i++;
			continue;
		}
		if ( isalive( player ) )
		{
			if ( isDefined( object ) && distancesquared( player.origin, object.origin ) < area )
			{
				return player;
			}
		}
		i++;
	}
}

get_closest_player_enemy() //checked partially changed to match cerberus output did not use continue in foreach see github for more info
{
	players = getplayers();
	players = arraysort( players, self.origin );
	foreach ( player in players )
	{
		if ( !isDefined( player ) || !isalive( player ) )
		{
		}
		else if ( player.sessionstate != "playing" )
		{
		}
		else if ( player == self )
		{
		}
		else if ( level.teambased && self.team == player.team )
		{
		}
		else
		{
			return player;
		}
	}
	return undefined;
}

get_closest_player_ally() //checked partially changed to match cerberus output did not use continue in foreach see github for more info
{
	if ( !level.teambased )
	{
		return undefined;
	}
	players = getplayers( self.team );
	players = arraysort( players, self.origin );
	foreach ( player in players )
	{
		if ( !isDefined( player ) || !isalive( player ) )
		{
		}
		else if ( player.sessionstate != "playing" )
		{
		}
		else if ( player == self )
		{
		}
		else
		{
			return player;
		}
	}
	return undefined;
}

