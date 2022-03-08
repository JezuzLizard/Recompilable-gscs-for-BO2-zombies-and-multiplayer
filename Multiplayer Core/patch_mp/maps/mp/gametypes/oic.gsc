// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::setupcallbacks();
    maps\mp\gametypes\_globallogic::setupcallbacks();
    level.pointsperweaponkill = getgametypesetting( "pointsPerWeaponKill" );
    level.pointspermeleekill = getgametypesetting( "pointsPerMeleeKill" );
    level.pointsforsurvivalbonus = getgametypesetting( "pointsForSurvivalBonus" );
    registertimelimit( 0, 1440 );
    registerscorelimit( 0, 50000 );
    registerroundlimit( 0, 10 );
    registerroundwinlimit( 0, 10 );
    registernumlives( 1, 100 );
    level.onstartgametype = ::onstartgametype;
    level.onspawnplayer = ::onspawnplayer;
    level.onspawnplayerunified = ::onspawnplayerunified;
    level.givecustomloadout = ::givecustomloadout;
    level.onplayerkilled = ::onplayerkilled;
    level.onplayerdamage = ::onplayerdamage;
    level.onwagerawards = ::onwagerawards;
    game["dialog"]["gametype"] = "oic_start";
    game["dialog"]["wm_2_lives"] = "oic_2life";
    game["dialog"]["wm_final_life"] = "oic_last";
    precachestring( &"MPUI_PLAYER_KILLED" );
    precachestring( &"MP_PLUS_ONE_BULLET" );
    precachestring( &"MP_OIC_SURVIVOR_BONUS" );
    precacheitem( "kard_wager_mp" );
    setscoreboardcolumns( "pointstowin", "kills", "deaths", "stabs", "survived" );
}

onplayerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
    if ( smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET" || smeansofdeath == "MOD_HEAD_SHOT" )
        idamage = self.maxhealth + 1;

    return idamage;
}

givecustomloadout()
{
    weapon = "kard_wager_mp";
    self maps\mp\gametypes\_wager::setupblankrandomplayer( 1, 1, weapon );
    self giveweapon( weapon );
    self giveweapon( "knife_mp" );
    self switchtoweapon( weapon );
    clipammo = 1;

    if ( isdefined( self.pers["clip_ammo"] ) )
    {
        clipammo = self.pers["clip_ammo"];
        self.pers["clip_ammo"] = undefined;
    }

    self setweaponammoclip( weapon, clipammo );
    stockammo = 0;

    if ( isdefined( self.pers["stock_ammo"] ) )
    {
        stockammo = self.pers["stock_ammo"];
        self.pers["stock_ammo"] = undefined;
    }

    self setweaponammostock( weapon, stockammo );
    self setspawnweapon( weapon );
    self setperk( "specialty_unlimitedsprint" );
    self setperk( "specialty_movefaster" );
    return weapon;
}

onstartgametype()
{
    setclientnamemode( "auto_change" );
    setobjectivetext( "allies", &"OBJECTIVES_DM" );
    setobjectivetext( "axis", &"OBJECTIVES_DM" );

    if ( level.splitscreen )
    {
        setobjectivescoretext( "allies", &"OBJECTIVES_DM" );
        setobjectivescoretext( "axis", &"OBJECTIVES_DM" );
    }
    else
    {
        setobjectivescoretext( "allies", &"OBJECTIVES_DM_SCORE" );
        setobjectivescoretext( "axis", &"OBJECTIVES_DM_SCORE" );
    }

    allowed[0] = "oic";
    maps\mp\gametypes\_gameobjects::main( allowed );
    maps\mp\gametypes\_spawning::create_map_placed_influencers();
    level.spawnmins = ( 0, 0, 0 );
    level.spawnmaxs = ( 0, 0, 0 );
    newspawns = getentarray( "mp_wager_spawn", "classname" );

    if ( newspawns.size > 0 )
    {
        maps\mp\gametypes\_spawnlogic::addspawnpoints( "allies", "mp_wager_spawn" );
        maps\mp\gametypes\_spawnlogic::addspawnpoints( "axis", "mp_wager_spawn" );
    }
    else
    {
        maps\mp\gametypes\_spawnlogic::addspawnpoints( "allies", "mp_dm_spawn" );
        maps\mp\gametypes\_spawnlogic::addspawnpoints( "axis", "mp_dm_spawn" );
    }

    maps\mp\gametypes\_spawning::updateallspawnpoints();
    level.mapcenter = maps\mp\gametypes\_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
    setmapcenter( level.mapcenter );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getrandomintermissionpoint();
    setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
    level.usestartspawns = 0;
    level.displayroundendtext = 0;

    if ( level.roundlimit != 1 && level.numlives )
    {
        level.overrideplayerscore = 1;
        level.displayroundendtext = 1;
        level.onendgame = ::onendgame;
    }

    level thread watchelimination();
    setobjectivehinttext( "allies", &"OBJECTIVES_OIC_HINT" );
    setobjectivehinttext( "axis", &"OBJECTIVES_OIC_HINT" );
}

onspawnplayerunified()
{
    maps\mp\gametypes\_spawning::onspawnplayer_unified();
    livesleft = self.pers["lives"];

    if ( livesleft == 2 )
        self maps\mp\gametypes\_wager::wagerannouncer( "wm_2_lives" );
    else if ( livesleft == 1 )
        self maps\mp\gametypes\_wager::wagerannouncer( "wm_final_life" );
}

onspawnplayer( predictedspawn )
{
    spawnpoints = maps\mp\gametypes\_spawnlogic::getteamspawnpoints( self.pers["team"] );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_dm( spawnpoints );

    if ( predictedspawn )
        self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
    else
        self spawn( spawnpoint.origin, spawnpoint.angles, "oic" );
}

onendgame( winningplayer )
{
    if ( isdefined( winningplayer ) && isplayer( winningplayer ) )
        [[ level._setplayerscore ]]( winningplayer, [[ level._getplayerscore ]]( winningplayer ) + 1 );
}

onstartwagersidebets()
{
    thread saveoffallplayersammo();
}

saveoffallplayersammo()
{
    wait 1.0;

    for ( playerindex = 0; playerindex < level.players.size; playerindex++ )
    {
        player = level.players[playerindex];

        if ( !isdefined( player ) )
            continue;

        if ( player.pers["lives"] == 0 )
            continue;

        currentweapon = player getcurrentweapon();
        player.pers["clip_ammo"] = player getweaponammoclip( currentweapon );
        player.pers["stock_ammo"] = player getweaponammostock( currentweapon );
    }
}

isplayereliminated( player )
{
    return isdefined( player.pers["eliminated"] ) && player.pers["eliminated"];
}

getplayersleft()
{
    playersremaining = [];

    for ( playerindex = 0; playerindex < level.players.size; playerindex++ )
    {
        player = level.players[playerindex];

        if ( !isdefined( player ) )
            continue;

        if ( !isplayereliminated( player ) )
            playersremaining[playersremaining.size] = player;
    }

    return playersremaining;
}

onwagerfinalizeround()
{
    playersleft = getplayersleft();
    lastmanstanding = playersleft[0];
    sidebetpool = 0;
    sidebetwinners = [];
    players = level.players;

    for ( playerindex = 0; playerindex < players.size; playerindex++ )
    {
        if ( isdefined( players[playerindex].pers["sideBetMade"] ) )
        {
            sidebetpool += getdvarint( "scr_wagerSideBet" );

            if ( players[playerindex].pers["sideBetMade"] == lastmanstanding.name )
                sidebetwinners[sidebetwinners.size] = players[playerindex];
        }
    }

    if ( sidebetwinners.size == 0 )
        return;

    sidebetpayout = int( sidebetpool / sidebetwinners.size );

    for ( index = 0; index < sidebetwinners.size; index++ )
    {
        player = sidebetwinners[index];
        player.pers["wager_sideBetWinnings"] += sidebetpayout;
    }
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    if ( isdefined( attacker ) && isplayer( attacker ) && self != attacker )
    {
        attackerammo = attacker getammocount( "kard_wager_mp" );
        victimammo = self getammocount( "kard_wager_mp" );
        attacker giveammo( 1 );
        attacker thread maps\mp\gametypes\_wager::queuewagerpopup( &"MPUI_PLAYER_KILLED", 0, &"MP_PLUS_ONE_BULLET" );
        attacker playlocalsound( "mpl_oic_bullet_pickup" );

        if ( smeansofdeath == "MOD_MELEE" )
        {
            attacker maps\mp\gametypes\_globallogic_score::givepointstowin( level.pointspermeleekill );

            if ( attackerammo > 0 )
                maps\mp\_scoreevents::processscoreevent( "knife_with_ammo_oic", attacker, self, sweapon );

            if ( victimammo > attackerammo )
                maps\mp\_scoreevents::processscoreevent( "kill_enemy_with_more_ammo_oic", attacker, self, sweapon );
        }
        else
        {
            attacker maps\mp\gametypes\_globallogic_score::givepointstowin( level.pointsperweaponkill );

            if ( victimammo > attackerammo + 1 )
                maps\mp\_scoreevents::processscoreevent( "kill_enemy_with_more_ammo_oic", attacker, self, sweapon );
        }

        if ( self.pers["lives"] == 0 )
            maps\mp\_scoreevents::processscoreevent( "eliminate_oic", attacker, self, sweapon );
    }
}

giveammo( amount )
{
    currentweapon = self getcurrentweapon();
    clipammo = self getweaponammoclip( currentweapon );
    self setweaponammoclip( currentweapon, clipammo + amount );
}

shouldreceivesurvivorbonus()
{
    if ( isalive( self ) )
        return true;

    if ( self.hasspawned && self.pers["lives"] > 0 )
        return true;

    return false;
}

watchelimination()
{
    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "player_eliminated" );

        players = level.players;

        for ( i = 0; i < players.size; i++ )
        {
            if ( isdefined( players[i] ) && players[i] shouldreceivesurvivorbonus() )
            {
                players[i].pers["survived"]++;
                players[i].survived = players[i].pers["survived"];
                players[i] thread maps\mp\gametypes\_wager::queuewagerpopup( &"MP_OIC_SURVIVOR_BONUS", 10 );
                score = maps\mp\gametypes\_globallogic_score::_getplayerscore( players[i] );
                maps\mp\_scoreevents::processscoreevent( "survivor", players[i] );
                players[i] maps\mp\gametypes\_globallogic_score::givepointstowin( level.pointsforsurvivalbonus );
            }
        }
    }
}

onwagerawards()
{
    stabs = self maps\mp\gametypes\_globallogic_score::getpersstat( "stabs" );

    if ( !isdefined( stabs ) )
        stabs = 0;

    self maps\mp\gametypes\_persistence::setafteractionreportstat( "wagerAwards", stabs, 0 );
    longshots = self maps\mp\gametypes\_globallogic_score::getpersstat( "longshots" );

    if ( !isdefined( longshots ) )
        longshots = 0;

    self maps\mp\gametypes\_persistence::setafteractionreportstat( "wagerAwards", longshots, 1 );
    bestkillstreak = self maps\mp\gametypes\_globallogic_score::getpersstat( "best_kill_streak" );

    if ( !isdefined( bestkillstreak ) )
        bestkillstreak = 0;

    self maps\mp\gametypes\_persistence::setafteractionreportstat( "wagerAwards", bestkillstreak, 2 );
}
