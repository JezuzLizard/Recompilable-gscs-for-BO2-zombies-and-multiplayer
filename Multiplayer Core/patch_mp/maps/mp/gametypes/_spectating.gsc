// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    foreach ( team in level.teams )
        level.spectateoverride[team] = spawnstruct();

    level thread onplayerconnect();
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onjoinedteam();
        player thread onjoinedspectators();
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self setspectatepermissions();
    }
}

onjoinedteam()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_team" );

        self setspectatepermissionsformachine();
    }
}

onjoinedspectators()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_spectators" );

        self setspectatepermissionsformachine();
    }
}

updatespectatesettings()
{
    level endon( "game_ended" );

    for ( index = 0; index < level.players.size; index++ )
        level.players[index] setspectatepermissions();
}

getsplitscreenteam()
{
    for ( index = 0; index < level.players.size; index++ )
    {
        if ( !isdefined( level.players[index] ) )
            continue;

        if ( level.players[index] == self )
            continue;

        if ( !self isplayeronsamemachine( level.players[index] ) )
            continue;

        team = level.players[index].sessionteam;

        if ( team != "spectator" )
            return team;
    }

    return self.sessionteam;
}

otherlocalplayerstillalive()
{
    for ( index = 0; index < level.players.size; index++ )
    {
        if ( !isdefined( level.players[index] ) )
            continue;

        if ( level.players[index] == self )
            continue;

        if ( !self isplayeronsamemachine( level.players[index] ) )
            continue;

        if ( isalive( level.players[index] ) )
            return true;
    }

    return false;
}

allowspectateallteams( allow )
{
    foreach ( team in level.teams )
        self allowspectateteam( team, allow );
}

allowspectateallteamsexceptteam( skip_team, allow )
{
    foreach ( team in level.teams )
    {
        if ( team == skip_team )
            continue;

        self allowspectateteam( team, allow );
    }
}

setspectatepermissions()
{
    team = self.sessionteam;

    if ( team == "spectator" )
    {
        if ( self issplitscreen() && !level.splitscreen )
            team = getsplitscreenteam();

        if ( team == "spectator" )
        {
            self allowspectateallteams( 1 );
            self allowspectateteam( "freelook", 0 );
            self allowspectateteam( "none", 1 );
            self allowspectateteam( "localplayers", 1 );
            return;
        }
    }

    spectatetype = level.spectatetype;

    switch ( spectatetype )
    {
        case 0:
            self allowspectateallteams( 0 );
            self allowspectateteam( "freelook", 0 );
            self allowspectateteam( "none", 1 );
            self allowspectateteam( "localplayers", 0 );
            break;
        case 3:
            if ( self issplitscreen() && self otherlocalplayerstillalive() )
            {
                self allowspectateallteams( 0 );
                self allowspectateteam( "none", 0 );
                self allowspectateteam( "freelook", 0 );
                self allowspectateteam( "localplayers", 1 );
                break;
            }
        case 1:
            if ( !level.teambased )
            {
                self allowspectateallteams( 1 );
                self allowspectateteam( "none", 1 );
                self allowspectateteam( "freelook", 0 );
                self allowspectateteam( "localplayers", 1 );
            }
            else if ( isdefined( team ) && isdefined( level.teams[team] ) )
            {
                self allowspectateteam( team, 1 );
                self allowspectateallteamsexceptteam( team, 0 );
                self allowspectateteam( "freelook", 0 );
                self allowspectateteam( "none", 0 );
                self allowspectateteam( "localplayers", 1 );
            }
            else
            {
                self allowspectateallteams( 0 );
                self allowspectateteam( "freelook", 0 );
                self allowspectateteam( "none", 0 );
                self allowspectateteam( "localplayers", 1 );
            }

            break;
        case 2:
            self allowspectateallteams( 1 );
            self allowspectateteam( "freelook", 1 );
            self allowspectateteam( "none", 1 );
            self allowspectateteam( "localplayers", 1 );
            break;
    }

    if ( isdefined( team ) && isdefined( level.teams[team] ) )
    {
        if ( isdefined( level.spectateoverride[team].allowfreespectate ) )
            self allowspectateteam( "freelook", 1 );

        if ( isdefined( level.spectateoverride[team].allowenemyspectate ) )
            self allowspectateallteamsexceptteam( team, 1 );
    }
}

setspectatepermissionsformachine()
{
    self setspectatepermissions();

    if ( !self issplitscreen() )
        return;

    for ( index = 0; index < level.players.size; index++ )
    {
        if ( !isdefined( level.players[index] ) )
            continue;

        if ( level.players[index] == self )
            continue;

        if ( !self isplayeronsamemachine( level.players[index] ) )
            continue;

        level.players[index] setspectatepermissions();
    }
}
