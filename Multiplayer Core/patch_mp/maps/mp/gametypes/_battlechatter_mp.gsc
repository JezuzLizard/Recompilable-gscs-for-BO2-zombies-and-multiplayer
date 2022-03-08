// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    if ( level.createfx_enabled )
        return;

    foreach ( team in level.teams )
    {
/#
        assert( isdefined( level.teamprefix[team] ) );
#/
/#
        assert( isdefined( level.teamprefix[team] ) );
#/
        level.isteamspeaking[team] = 0;
        level.speakers[team] = [];
    }

    level.bcsounds = [];
    level.bcsounds["inform_attack"] = "attack";
    level.bcsounds["c4_out"] = "c4";
    level.bcsounds["claymore_out"] = "claymore";
    level.bcsounds["emp_out"] = "emp";
    level.bcsounds["flash_out"] = "flash";
    level.bcsounds["gas_out"] = "gas";
    level.bcsounds["frag_out"] = "grenade";
    level.bcsounds["revive_out"] = "revive";
    level.bcsounds["smoke_out"] = "smoke";
    level.bcsounds["sticky_out"] = "sticky";
    level.bcsounds["gas_incoming"] = "gas";
    level.bcsounds["grenade_incoming"] = "incoming";
    level.bcsounds["kill"] = "kill";
    level.bcsounds["kill_sniper"] = "kill_sniper";
    level.bcsounds["revive"] = "need_revive";
    level.bcsounds["reload"] = "reloading";
    level.bcsounds["enemy"] = "threat";
    level.bcsounds["sniper"] = "sniper";
    level.bcsounds["conc_out"] = "attack_stun";
    level.bcsounds["satchel_plant"] = "attack_throwsatchel";
    level.bcsounds["casualty"] = "casualty_gen";
    level.bcsounds["flare_out"] = "attack_flare";
    level.bcsounds["betty_plant"] = "plant";
    level.bcsounds["landmark"] = "landmark";
    level.bcsounds["taunt"] = "taunt";
    level.bcsounds["killstreak_enemy"] = "enemy";
    level.bcsounds["killstreak_taunt"] = "kls";
    level.bcsounds["kill_killstreak"] = "killstreak";
    level.bcsounds["destructible"] = "destructible_near";
    level.bcsounds["teammate"] = "teammate_near";
    level.bcsounds["gametype"] = "gametype";
    level.bcsounds["squad"] = "squad";
    level.bcsounds["gametype"] = "gametype";
    level.bcsounds["perk"] = "perk_equip";
    level.bcsounds["pain"] = "pain";
    level.bcsounds["death"] = "death";
    level.bcsounds["breathing"] = "breathing";
    level.bcsounds["inform_need"] = "need";
    level.bcsounds["scream"] = "scream";
    level.bcsounds["fire"] = "fire";
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
    level.bcweapondelay = getdvarint( "bcmp_weapon_delay" );
    level.bcweaponfireprobability = getdvarint( "bcmp_weapon_fire_probability" );
    level.bcweaponreloadprobability = getdvarint( "bcmp_weapon_reload_probability" );
    level.bcweaponfirethreatprobability = getdvarint( "bcmp_weapon_fire_threat_probability" );
    level.bcsniperkillprobability = getdvarint( "bcmp_sniper_kill_probability" );
    level.bcallykillprobability = getdvarint( "bcmp_ally_kill_probability" );
    level.bckillstreakincomingprobability = getdvarint( "bcmp_killstreak_incoming_probability" );
    level.bcperkcallprobability = getdvarint( "bcmp_perk_call_probability" );
    level.bcincominggrenadeprobability = getdvarint( "bcmp_incoming_grenade_probability" );
    level.bctossgrenadeprobability = getdvarint( "bcmp_toss_grenade_probability" );
    level.bctosstrophyprobability = getdvarint( "bcmp_toss_trophy_probability" );
    level.bckillinformprobability = getdvarint( "bcmp_kill_inform_probability" );
    level.bcpainsmallprobability = getdvarint( "bcmp_pain_small_probability" );
    level.bcpaindelay = getdvarint( "bcmp_pain_delay" );
    level.bclaststanddelay = getdvarint( "bcmp_last_stand_delay" );
    level.bcmp_breathing_delay = getdvarint( "bcmp_breathing_delay" );
    level.bcmp_enemy_contact_delay = getdvarint( "bcmp_enemy_contact_delay" );
    level.bcmp_enemy_contact_level_delay = getdvarint( "bcmp_enemy_contact_level_delay" );
    level.bcmp_breathing_probability = getdvarint( "bcmp_breathing_probability" );
    level.allowbattlechatter = getgametypesetting( "allowBattleChatter" );
    level.landmarks = getentarray( "trigger_landmark", "targetname" );
    level.enemyspotteddialog = 1;
    level thread enemycontactleveldelay();
    level thread onplayerconnect();
    level thread updatebcdvars();
    level.battlechatter_init = 1;
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onjoinedteam();
        player thread onplayerspawned();
    }
}

updatebcdvars()
{
    level endon( "game_ended" );

    for (;;)
    {
        level.bcweapondelay = getdvarint( "bcmp_weapon_delay" );
        level.bckillinformprobability = getdvarint( "bcmp_kill_inform_probability" );
        level.bcweaponfireprobability = getdvarint( "bcmp_weapon_fire_probability" );
        level.bcsniperkillprobability = getdvarint( "bcmp_sniper_kill_probability" );
        level thread maps\mp\gametypes\_globallogic::updateteamstatus();
        wait 2.0;
    }
}

onjoinedteam()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_team" );

        self.pers["bcVoiceNumber"] = randomintrange( 0, 3 );
        self.pilotisspeaking = 0;
    }
}

onjoinedspectators()
{
    self endon( "disconnect" );

    for (;;)
        self waittill( "joined_spectators" );
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self.lastbcattempttime = 0;
        self.heartbeatsnd = 0;
        self.soundmod = "player";
        self.bcvoicenumber = self.pers["bcVoiceNumber"];
        self.pilotisspeaking = 0;

        if ( level.splitscreen )
            continue;

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
    while ( true )
    {
        level waittill( "level_enemy_spotted" );

        level.enemyspotteddialog = 0;
        wait( level.bcmp_enemy_contact_level_delay );
        level.enemyspotteddialog = 1;
    }
}

breathinghurtvox()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "snd_breathing_hurt" );

        if ( randomintrange( 0, 100 ) >= level.bcmp_breathing_probability )
        {
            wait 0.5;

            if ( isalive( self ) )
                level thread mpsaylocalsound( self, "breathing", "hurt", 0, 1 );
        }

        wait( level.bcmp_breathing_delay );
    }
}

onfirescream()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "snd_burn_scream" );

        if ( randomintrange( 0, 100 ) >= level.bcmp_breathing_probability )
        {
            wait 0.5;

            if ( isalive( self ) )
                level thread mpsaylocalsound( self, "fire", "scream" );
        }

        wait( level.bcmp_breathing_delay );
    }
}

breathingbettervox()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "snd_breathing_better" );

        if ( isalive( self ) )
            level thread mpsaylocalsound( self, "breathing", "better", 0, 1 );
    }
}

laststandvox()
{
    self endon( "death" );
    self endon( "disconnect" );

    self waittill( "snd_last_stand" );

    for (;;)
    {
        self waittill( "weapon_fired" );

        if ( isalive( self ) )
            level thread mpsaylocalsound( self, "perk", "laststand" );

        wait( level.bclaststanddelay );
    }
}

allyrevive()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "snd_ally_revive" );

        if ( isalive( self ) )
            level thread mpsaylocalsound( self, "inform_attack", "revive" );

        wait( level.bclaststanddelay );
    }
}

painvox()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "snd_pain_player" );

        if ( randomintrange( 0, 100 ) >= level.bcpainsmallprobability )
        {
            if ( isalive( self ) )
            {
                soundalias = level.teamprefix[self.team] + self.bcvoicenumber + "_" + level.bcsounds["pain"] + "_" + "small";
                self thread dosound( soundalias );
            }
        }

        wait( level.bcpaindelay );
    }
}

deathvox()
{
    self endon( "disconnect" );

    self waittill( "death" );

    if ( self.team != "spectator" )
    {
        soundalias = level.teamprefix[self.team] + self.bcvoicenumber + "_" + level.bcsounds["pain"] + "_" + "death";
        self thread dosound( soundalias );
    }
}

stickygrenadetracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "sticky_explode" );

    for (;;)
    {
        self waittill( "grenade_stuck", grenade );

        if ( isdefined( grenade ) )
            grenade.stucktoplayer = self;

        if ( isalive( self ) )
            level thread mpsaylocalsound( self, "grenade_incoming", "sticky" );

        self notify( "sticky_explode" );
    }
}

onplayersuicideorteamkill( player, type )
{
    self endon( "disconnect" );
    waittillframeend;

    if ( !isdefined( level.battlechatter_init ) )
        return;

    if ( !level.teambased )
        return;

    myteam = player.team;

    if ( isdefined( level.aliveplayers[myteam] ) )
    {
        if ( level.aliveplayers[myteam].size )
        {
            index = checkdistancetoevent( player, 1000000 );

            if ( isdefined( index ) )
            {
                wait 1.0;

                if ( isalive( level.aliveplayers[myteam][index] ) )
                    level thread mpsaylocalsound( level.aliveplayers[myteam][index], "teammate", type );
            }
        }
    }
}

onplayerkillstreak( player )
{
    player endon( "disconnect" );
}

onkillstreakused( killstreak, team )
{

}

onplayernearexplodable( object, type )
{
    self endon( "disconnect" );
    self endon( "explosion_started" );
}

shoeboxtracking()
{
    self endon( "death" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "begin_firing" );

        weaponname = self getcurrentweapon();

        if ( weaponname == "mine_shoebox_mp" )
            level thread mpsaylocalsound( self, "satchel_plant", "shoebox" );
    }
}

checkweaponreload( weapon )
{
    switch ( weapon )
    {
        case "usrpg_mp":
        case "smaw_mp":
        case "judge_mp":
        case "fhj18_mp":
        case "crossbow_mp":
            return false;
        default:
            return true;
    }
}

reloadtracking()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "reload_start" );

        if ( randomintrange( 0, 100 ) >= level.bcweaponreloadprobability )
        {
            weaponname = self getcurrentweapon();
            weaponshouldreload = checkweaponreload( weaponname );

            if ( weaponshouldreload )
                level thread mpsaylocalsound( self, "reload", "gen" );
        }
    }
}

perkspecificbattlechatter( type, checkdistance )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "perk_done" );
}

enemythreat()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "weapon_fired" );

        if ( level.enemyspotteddialog )
        {
            if ( gettime() - self.lastbcattempttime > level.bcmp_enemy_contact_delay )
            {
                shooter = self;
                myteam = self.team;
                closest_enemy = shooter get_closest_player_enemy();
                self.lastbcattempttime = gettime();

                if ( isdefined( closest_enemy ) )
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

weaponfired()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "weapon_fired" );

        if ( gettime() - self.lastbcattempttime > level.bcweapondelay )
        {
            self.lastbcattempttime = gettime();

            if ( randomintrange( 0, 100 ) >= level.bcweaponfireprobability )
            {
                self.landmarkent = self getlandmark();

                if ( isdefined( self.landmarkent ) )
                {
                    myteam = self.team;

                    foreach ( team in level.teams )
                    {
                        if ( team == myteam )
                            continue;

                        keys = getarraykeys( level.squads[team] );

                        for ( i = 0; i < keys.size; i++ )
                        {
                            if ( level.squads[team][keys[i]].size )
                            {
                                index = randomintrange( 0, level.squads[team][keys[i]].size );
                                level thread mpsaylocalsound( level.squads[team][keys[i]][index], "enemy", "infantry" );
                            }
                        }
                    }
                }
            }
        }
    }
}

killedbysniper( sniper )
{
    self endon( "disconnect" );
    sniper endon( "disconnect" );
    waittillframeend;

    if ( !isdefined( level.battlechatter_init ) )
        return;

    victim = self;

    if ( level.hardcoremode || !level.teambased )
        return;

    sniper.issniperspotted = 1;

    if ( randomintrange( 0, 100 ) >= level.bcsniperkillprobability )
    {
        sniperteam = sniper.team;
        victimteam = self.team;
        index = checkdistancetoevent( victim, 1000000 );

        if ( isdefined( index ) )
            level thread mpsaylocalsound( level.aliveplayers[victimteam][index], "enemy", "sniper", 0 );
    }
}

playerkilled( attacker )
{
    self endon( "disconnect" );

    if ( !isplayer( attacker ) )
        return;

    waittillframeend;

    if ( !isdefined( level.battlechatter_init ) )
        return;

    victim = self;

    if ( level.hardcoremode )
        return;

    if ( randomintrange( 0, 100 ) >= level.bcallykillprobability )
    {
        attackerteam = attacker.team;
        victimteam = self.team;
        closest_ally = victim get_closest_player_ally();
        area = 1000000;

        if ( isdefined( closest_ally ) )
        {
            if ( distancesquared( closest_ally.origin, self.origin ) < area )
                level thread mpsaylocalsound( closest_ally, "inform_attack", "revive", 0 );
        }
    }
}

grenadetracking()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "grenade_fire", grenade, weaponname );

        if ( weaponname == "frag_grenade_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "grenade" );

            level thread incominggrenadetracking( self, grenade, "grenade" );
            continue;
        }

        if ( weaponname == "satchel_charge_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "c4" );

            continue;
        }

        if ( weaponname == "emp_grenade_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "emp" );

            continue;
        }

        if ( weaponname == "claymore_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "claymore" );

            continue;
        }

        if ( weaponname == "flash_grenade_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "flash" );

            continue;
        }

        if ( weaponname == "sticky_grenade_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "sticky" );

            continue;
        }

        if ( weaponname == "tabun_gas_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "gas" );

            continue;
        }

        if ( weaponname == "willy_pete_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "smoke" );

            continue;
        }

        if ( weaponname == "hatchet_mp" || weaponname == "proximity_grenade_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "hatchet" );

            continue;
        }

        if ( weaponname == "concussion_grenade_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "concussion" );

            continue;
        }

        if ( weaponname == "scrambler_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "scrambler" );

            continue;
        }

        if ( weaponname == "tactical_insertion_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "tactical" );

            continue;
        }

        if ( weaponname == "bouncingbetty_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctosstrophyprobability )
                level thread mpsaylocalsound( self, "inform_attack", "c4" );

            continue;
        }

        if ( weaponname == "sensor_grenade_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctossgrenadeprobability )
                level thread mpsaylocalsound( self, "inform_attack", "hatchet" );

            continue;
        }

        if ( weaponname == "trophy_system_mp" )
        {
            if ( randomintrange( 0, 100 ) >= level.bctosstrophyprobability )
                level thread mpsaylocalsound( self, "inform_attack", "scrambler" );
        }
    }
}

watchmissileusage()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "missile_fire", missile, weapon_name );

        if ( weapon_name == "usrpg_mp" )
        {
            level thread incominggrenadetracking( self, missile, "rpg", 0.2 );
            continue;
        }

        return;
    }
}

incominggrenadetracking( thrower, grenade, type, waittime )
{
    if ( randomintrange( 0, 100 ) >= level.bcincominggrenadeprobability )
    {
        if ( !isdefined( waittime ) )
            waittime = 1.0;

        wait( waittime );

        if ( !isdefined( thrower ) )
            return;

        if ( thrower.team == "spectator" )
            return;

        enemyteam = thrower.team;

        if ( level.players.size )
        {
            player = checkdistancetoobject( 250000, grenade, enemyteam, thrower );

            if ( isdefined( player ) )
                level thread mpsaylocalsound( player, "grenade_incoming", type );
        }
    }
}

incomingspecialgrenadetracking( type )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "grenade_ended" );

    for (;;)
    {
        if ( randomintrange( 0, 100 ) >= level.bcincominggrenadeprobability )
        {
            if ( level.aliveplayers[self.team].size || !level.teambased && level.players.size )
            {
                level thread mpsaylocalsound( self, "grenade_incoming", type );
                self notify( "grenade_ended" );
            }
        }

        wait 3.0;
    }
}

gametypespecificbattlechatter( event, team )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "event_ended" );

    for (;;)
    {
        if ( isdefined( team ) )
        {
            index = checkdistancetoevent( self, 90000 );

            if ( isdefined( index ) )
            {
                level thread mpsaylocalsound( level.aliveplayers[team][index], "gametype", event );
                self notify( "event_ended" );
            }
        }
        else
        {
            foreach ( team in level.teams )
            {
                index = randomintrange( 0, level.aliveplayers[team].size );
                level thread mpsaylocalsound( level.aliveplayers[team][index], "gametype", event );
            }
        }

        wait 1.0;
    }
}

checkweaponkill( weapon )
{
    switch ( weapon )
    {
        case "knife_mp":
        case "cobra_20mm_comlink_mp":
            return true;
        default:
            return false;
    }
}

saykillbattlechatter( attacker, sweapon, victim )
{
    if ( checkweaponkill( sweapon ) )
        return;

    if ( isdefined( victim.issniperspotted ) && victim.issniperspotted && randomintrange( 0, 100 ) >= level.bckillinformprobability )
    {
        level thread saylocalsounddelayed( attacker, "kill", "sniper", 0.75 );
        victim.issniperspotted = 0;
    }
    else if ( isdefined( level.bckillinformprobability ) && randomintrange( 0, 100 ) >= level.bckillinformprobability )
    {
        if ( !maps\mp\killstreaks\_killstreaks::iskillstreakweapon( sweapon ) )
            level thread saylocalsounddelayed( attacker, "kill", "infantry", 0.75 );
    }
}

saylocalsounddelayed( player, soundtype1, soundtype2, delay )
{
    player endon( "death" );
    player endon( "disconnect" );

    if ( !isdefined( level.battlechatter_init ) )
        return;

    wait( delay );
    mpsaylocalsound( player, soundtype1, soundtype2 );
}

saylocalsound( player, soundtype )
{
    player endon( "death" );
    player endon( "disconnect" );

    if ( isspeakerinrange( player ) )
        return;

    if ( player.team != "spectator" )
        soundalias = level.teamprefix[player.team] + player.bcvoicenumber + "_" + level.bcsounds[soundtype];
}

mpsaylocalsound( player, partone, parttwo, checkspeakers, is2d )
{
    player endon( "death" );
    player endon( "disconnect" );

    if ( level.players.size <= 1 )
        return;

    if ( !isdefined( checkspeakers ) )
    {
        if ( isspeakerinrange( player ) )
            return;
    }

    if ( player hasperk( "specialty_quieter" ) )
        return;

    if ( player.team != "spectator" )
    {
        soundalias = level.teamprefix[player.team] + player.bcvoicenumber + "_" + level.bcsounds[partone] + "_" + parttwo;

        if ( isdefined( is2d ) )
            player thread dosound( soundalias, is2d );
        else
            player thread dosound( soundalias );
    }
}

mpsaylocationallocalsound( player, prefix, partone, parttwo )
{
    player endon( "death" );
    player endon( "disconnect" );

    if ( level.players.size <= 1 )
        return;

    if ( isspeakerinrange( player ) )
        return;

    if ( player.team != "spectator" )
    {
        soundalias1 = level.teamprefix[player.team] + player.bcvoicenumber + "_" + level.bcsounds[prefix];
        soundalias2 = level.teamprefix[player.team] + player.bcvoicenumber + "_" + level.bcsounds[partone] + "_" + parttwo;
        player thread dolocationalsound( soundalias1, soundalias2 );
    }
}

dosound( soundalias, is2d )
{
    team = self.team;
    level addspeaker( self, team );

    if ( isdefined( is2d ) )
        self playlocalsound( soundalias );
    else if ( level.allowbattlechatter && level.teambased )
        self playsoundontag( soundalias, "J_Head" );

    self thread waitplaybacktime( soundalias );
    self waittill_any( soundalias, "death", "disconnect" );
    level removespeaker( self, team );
}

dolocationalsound( soundalias1, soundalias2 )
{
    team = self.team;
    level addspeaker( self, team );

    if ( level.allowbattlechatter && level.teambased )
        self playbattlechattertoteam( soundalias1, soundalias2, team, self );

    self thread waitplaybacktime( soundalias1 );
    self waittill_any( soundalias1, "death", "disconnect" );
    level removespeaker( self, team );
}

waitplaybacktime( soundalias )
{
    self endon( "death" );
    self endon( "disconnect" );
    playbacktime = soundgetplaybacktime( soundalias );

    if ( playbacktime >= 0 )
    {
        waittime = playbacktime * 0.001;
        wait( waittime );
    }
    else
        wait 1.0;

    self notify( soundalias );
}

isspeakerinrange( player )
{
    player endon( "death" );
    player endon( "disconnect" );
    distsq = 1000000;

    if ( isdefined( player ) && isdefined( player.team ) && player.team != "spectator" )
    {
        for ( index = 0; index < level.speakers[player.team].size; index++ )
        {
            teammate = level.speakers[player.team][index];

            if ( teammate == player )
                return true;

            if ( distancesquared( teammate.origin, player.origin ) < distsq )
                return true;
        }
    }

    return false;
}

addspeaker( player, team )
{
    level.speakers[team][level.speakers[team].size] = player;
}

removespeaker( player, team )
{
    newspeakers = [];

    for ( index = 0; index < level.speakers[team].size; index++ )
    {
        if ( level.speakers[team][index] == player )
            continue;

        newspeakers[newspeakers.size] = level.speakers[team][index];
    }

    level.speakers[team] = newspeakers;
}

getlandmark()
{
    landmarks = level.landmarks;

    for ( i = 0; i < landmarks.size; i++ )
    {
        if ( self istouching( landmarks[i] ) && isdefined( landmarks[i].script_landmark ) )
            return landmarks[i];
    }

    return undefined;
}

checkdistancetoevent( player, area )
{
    if ( !isdefined( player ) )
        return undefined;

    for ( index = 0; index < level.aliveplayers[player.team].size; index++ )
    {
        teammate = level.aliveplayers[player.team][index];

        if ( !isdefined( teammate ) )
            continue;

        if ( teammate == player )
            continue;

        if ( distancesquared( teammate.origin, player.origin ) < area )
            return index;
    }
}

checkdistancetoenemy( enemy, area, team )
{
    if ( !isdefined( enemy ) )
        return undefined;

    for ( index = 0; index < level.aliveplayers[team].size; index++ )
    {
        player = level.aliveplayers[team][index];

        if ( distancesquared( enemy.origin, player.origin ) < area )
            return index;
    }
}

checkdistancetoobject( area, object, ignoreteam, ignoreent )
{
    if ( isdefined( ignoreteam ) )
    {
        foreach ( team in level.teams )
        {
            for ( i = 0; i < level.aliveplayers[team].size; i++ )
            {
                player = level.aliveplayers[team][i];

                if ( isdefined( ignoreent ) && player == ignoreent )
                    continue;

                if ( isdefined( object ) && distancesquared( player.origin, object.origin ) < area )
                    return player;
            }
        }
    }
    else
    {
        for ( i = 0; i < level.players.size; i++ )
        {
            player = level.players[i];

            if ( isdefined( ignoreent ) && player == ignoreent )
                continue;

            if ( isalive( player ) )
            {
                if ( isdefined( object ) && distancesquared( player.origin, object.origin ) < area )
                    return player;
            }
        }
    }
}

get_closest_player_enemy()
{
    players = getplayers();
    players = arraysort( players, self.origin );

    foreach ( player in players )
    {
        if ( !isdefined( player ) || !isalive( player ) )
            continue;

        if ( player.sessionstate != "playing" )
            continue;

        if ( player == self )
            continue;

        if ( level.teambased && self.team == player.team )
            continue;

        return player;
    }

    return undefined;
}

get_closest_player_ally()
{
    if ( !level.teambased )
        return undefined;

    players = getplayers( self.team );
    players = arraysort( players, self.origin );

    foreach ( player in players )
    {
        if ( !isdefined( player ) || !isalive( player ) )
            continue;

        if ( player.sessionstate != "playing" )
            continue;

        if ( player == self )
            continue;

        return player;
    }

    return undefined;
}
