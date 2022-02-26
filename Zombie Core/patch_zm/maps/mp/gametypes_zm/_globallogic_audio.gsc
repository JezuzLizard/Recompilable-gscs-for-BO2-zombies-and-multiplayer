// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_globallogic_utils;
#include maps\mp\gametypes_zm\_globallogic_audio;
#include maps\mp\_music;

init()
{
    game["music"]["defeat"] = "mus_defeat";
    game["music"]["victory_spectator"] = "mus_defeat";
    game["music"]["winning"] = "mus_time_running_out_winning";
    game["music"]["losing"] = "mus_time_running_out_losing";
    game["music"]["match_end"] = "mus_match_end";
    game["music"]["victory_tie"] = "mus_defeat";
    game["music"]["suspense"] = [];
    game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_01";
    game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_02";
    game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_03";
    game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_04";
    game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_05";
    game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_06";
    game["dialog"]["mission_success"] = "mission_success";
    game["dialog"]["mission_failure"] = "mission_fail";
    game["dialog"]["mission_draw"] = "draw";
    game["dialog"]["round_success"] = "encourage_win";
    game["dialog"]["round_failure"] = "encourage_lost";
    game["dialog"]["round_draw"] = "draw";
    game["dialog"]["timesup"] = "timesup";
    game["dialog"]["winning"] = "winning";
    game["dialog"]["losing"] = "losing";
    game["dialog"]["min_draw"] = "min_draw";
    game["dialog"]["lead_lost"] = "lead_lost";
    game["dialog"]["lead_tied"] = "tied";
    game["dialog"]["lead_taken"] = "lead_taken";
    game["dialog"]["last_alive"] = "lastalive";
    game["dialog"]["boost"] = "generic_boost";

    if ( !isdefined( game["dialog"]["offense_obj"] ) )
        game["dialog"]["offense_obj"] = "generic_boost";

    if ( !isdefined( game["dialog"]["defense_obj"] ) )
        game["dialog"]["defense_obj"] = "generic_boost";

    game["dialog"]["hardcore"] = "hardcore";
    game["dialog"]["oldschool"] = "oldschool";
    game["dialog"]["highspeed"] = "highspeed";
    game["dialog"]["tactical"] = "tactical";
    game["dialog"]["challenge"] = "challengecomplete";
    game["dialog"]["promotion"] = "promotion";
    game["dialog"]["bomb_acquired"] = "sd_bomb_taken";
    game["dialog"]["bomb_taken"] = "sd_bomb_taken_taken";
    game["dialog"]["bomb_lost"] = "sd_bomb_drop";
    game["dialog"]["bomb_defused"] = "sd_bomb_defused";
    game["dialog"]["bomb_planted"] = "sd_bomb_planted";
    game["dialog"]["obj_taken"] = "securedobj";
    game["dialog"]["obj_lost"] = "lostobj";
    game["dialog"]["obj_defend"] = "defend_start";
    game["dialog"]["obj_destroy"] = "destroy_start";
    game["dialog"]["obj_capture"] = "capture_obj";
    game["dialog"]["objs_capture"] = "capture_objs";
    game["dialog"]["hq_located"] = "hq_located";
    game["dialog"]["hq_enemy_captured"] = "hq_capture";
    game["dialog"]["hq_enemy_destroyed"] = "hq_defend";
    game["dialog"]["hq_secured"] = "hq_secured";
    game["dialog"]["hq_offline"] = "hq_offline";
    game["dialog"]["hq_online"] = "hq_online";
    game["dialog"]["koth_located"] = "koth_located";
    game["dialog"]["koth_captured"] = "koth_captured";
    game["dialog"]["koth_lost"] = "koth_lost";
    game["dialog"]["koth_secured"] = "koth_secured";
    game["dialog"]["koth_contested"] = "koth_contest";
    game["dialog"]["koth_offline"] = "koth_offline";
    game["dialog"]["koth_online"] = "koth_online";
    game["dialog"]["move_to_new"] = "new_positions";
    game["dialog"]["attack"] = "attack";
    game["dialog"]["defend"] = "defend";
    game["dialog"]["offense"] = "offense";
    game["dialog"]["defense"] = "defense";
    game["dialog"]["halftime"] = "halftime";
    game["dialog"]["overtime"] = "overtime";
    game["dialog"]["side_switch"] = "switchingsides";
    game["dialog"]["flag_taken"] = "ourflag";
    game["dialog"]["flag_dropped"] = "ourflag_drop";
    game["dialog"]["flag_returned"] = "ourflag_return";
    game["dialog"]["flag_captured"] = "ourflag_capt";
    game["dialog"]["enemy_flag_taken"] = "enemyflag";
    game["dialog"]["enemy_flag_dropped"] = "enemyflag_drop";
    game["dialog"]["enemy_flag_returned"] = "enemyflag_return";
    game["dialog"]["enemy_flag_captured"] = "enemyflag_capt";
    game["dialog"]["securing_a"] = "dom_securing_a";
    game["dialog"]["securing_b"] = "dom_securing_b";
    game["dialog"]["securing_c"] = "dom_securing_c";
    game["dialog"]["securing_d"] = "dom_securing_d";
    game["dialog"]["securing_e"] = "dom_securing_e";
    game["dialog"]["securing_f"] = "dom_securing_f";
    game["dialog"]["secured_a"] = "dom_secured_a";
    game["dialog"]["secured_b"] = "dom_secured_b";
    game["dialog"]["secured_c"] = "dom_secured_c";
    game["dialog"]["secured_d"] = "dom_secured_d";
    game["dialog"]["secured_e"] = "dom_secured_e";
    game["dialog"]["secured_f"] = "dom_secured_f";
    game["dialog"]["losing_a"] = "dom_losing_a";
    game["dialog"]["losing_b"] = "dom_losing_b";
    game["dialog"]["losing_c"] = "dom_losing_c";
    game["dialog"]["losing_d"] = "dom_losing_d";
    game["dialog"]["losing_e"] = "dom_losing_e";
    game["dialog"]["losing_f"] = "dom_losing_f";
    game["dialog"]["lost_a"] = "dom_lost_a";
    game["dialog"]["lost_b"] = "dom_lost_b";
    game["dialog"]["lost_c"] = "dom_lost_c";
    game["dialog"]["lost_d"] = "dom_lost_d";
    game["dialog"]["lost_e"] = "dom_lost_e";
    game["dialog"]["lost_f"] = "dom_lost_f";
    game["dialog"]["secure_flag"] = "secure_flag";
    game["dialog"]["securing_flag"] = "securing_flag";
    game["dialog"]["losing_flag"] = "losing_flag";
    game["dialog"]["lost_flag"] = "lost_flag";
    game["dialog"]["oneflag_enemy"] = "oneflag_enemy";
    game["dialog"]["oneflag_friendly"] = "oneflag_friendly";
    game["dialog"]["lost_all"] = "dom_lock_theytake";
    game["dialog"]["secure_all"] = "dom_lock_wetake";
    game["dialog"]["squad_move"] = "squad_move";
    game["dialog"]["squad_30sec"] = "squad_30sec";
    game["dialog"]["squad_winning"] = "squad_onemin_vic";
    game["dialog"]["squad_losing"] = "squad_onemin_loss";
    game["dialog"]["squad_down"] = "squad_down";
    game["dialog"]["squad_bomb"] = "squad_bomb";
    game["dialog"]["squad_plant"] = "squad_plant";
    game["dialog"]["squad_take"] = "squad_takeobj";
    game["dialog"]["kicked"] = "player_kicked";
    game["dialog"]["sentry_destroyed"] = "dest_sentry";
    game["dialog"]["sentry_hacked"] = "kls_turret_hacked";
    game["dialog"]["microwave_destroyed"] = "dest_microwave";
    game["dialog"]["microwave_hacked"] = "kls_microwave_hacked";
    game["dialog"]["sam_destroyed"] = "dest_sam";
    game["dialog"]["tact_destroyed"] = "dest_tact";
    game["dialog"]["equipment_destroyed"] = "dest_equip";
    game["dialog"]["hacked_equip"] = "hacked_equip";
    game["dialog"]["uav_destroyed"] = "kls_u2_destroyed";
    game["dialog"]["cuav_destroyed"] = "kls_cu2_destroyed";
    level.dialoggroups = [];
    level thread post_match_snapshot_watcher();
}

registerdialoggroup( group, skipifcurrentlyplayinggroup )
{
    if ( !isdefined( level.dialoggroups ) )
        level.dialoggroups = [];
    else if ( isdefined( level.dialoggroup[group] ) )
    {
        error( "registerDialogGroup:  Dialog group " + group + " already registered." );
        return;
    }

    level.dialoggroup[group] = spawnstruct();
    level.dialoggroup[group].group = group;
    level.dialoggroup[group].skipifcurrentlyplayinggroup = skipifcurrentlyplayinggroup;
    level.dialoggroup[group].currentcount = 0;
}

sndstartmusicsystem()
{
    self endon( "disconnect" );

    if ( game["state"] == "postgame" )
        return;

    if ( game["state"] == "pregame" )
    {
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - music state is undefined Waiting 15 seconds to set music state" );
#/
        wait 30;

        if ( !isdefined( level.nextmusicstate ) )
        {
            self.pers["music"].currentstate = "UNDERSCORE";
            self thread suspensemusic();
        }
    }

    if ( !isdefined( level.nextmusicstate ) )
    {
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - music state is undefined Waiting 15 seconds to set music state" );
#/
        self.pers["music"].currentstate = "UNDERSCORE";
        self thread suspensemusic();
    }
}

suspensemusicforplayer()
{
    self endon( "disconnect" );
    self thread set_music_on_player( "UNDERSCORE", 0 );
/#
    if ( getdvarint( _hash_BC4784C ) > 0 )
        println( "Music System - Setting Music State Random Underscore " + self.pers["music"].returnstate + " On player " + self getentitynumber() );
#/
}

suspensemusic( random )
{
    level endon( "game_ended" );
    level endon( "match_ending_soon" );
    self endon( "disconnect" );
/#
    if ( getdvarint( _hash_BC4784C ) > 0 )
        println( "Music System - Starting random underscore" );
#/
    while ( true )
    {
        wait( randomintrange( 25, 60 ) );
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - Checking for random underscore" );
#/
        if ( !isdefined( self.pers["music"].inque ) )
            self.pers["music"].inque = 0;

        if ( self.pers["music"].inque )
        {
/#
            if ( getdvarint( _hash_BC4784C ) > 0 )
                println( "Music System - Inque no random underscore" );
#/
            continue;
        }

        if ( !isdefined( self.pers["music"].currentstate ) )
            self.pers["music"].currentstate = "SILENT";

        if ( randomint( 100 ) < self.underscorechance && self.pers["music"].currentstate != "ACTION" && self.pers["music"].currentstate != "TIME_OUT" )
        {
            self thread suspensemusicforplayer();
            self.underscorechance -= 20;
/#
            if ( getdvarint( _hash_BC4784C ) > 0 )
                println( "Music System - Starting random underscore" );
#/
        }
    }
}

leaderdialogforotherteams( dialog, skip_team, squad_dialog )
{
    foreach ( team in level.teams )
    {
        if ( team != skip_team )
            leaderdialog( dialog, team, undefined, undefined, squad_dialog );
    }
}

announceroundwinner( winner, delay )
{
    if ( delay > 0 )
        wait( delay );

    if ( !isdefined( winner ) || isplayer( winner ) )
        return;

    if ( isdefined( level.teams[winner] ) )
    {
        leaderdialog( "round_success", winner );
        leaderdialogforotherteams( "round_failure", winner );
    }
    else
    {
        foreach ( team in level.teams )
            thread playsoundonplayers( "mus_round_draw" + "_" + level.teampostfix[team] );

        leaderdialog( "round_draw" );
    }
}

announcegamewinner( winner, delay )
{
    if ( delay > 0 )
        wait( delay );

    if ( !isdefined( winner ) || isplayer( winner ) )
        return;

    if ( isdefined( level.teams[winner] ) )
    {
        leaderdialog( "mission_success", winner );
        leaderdialogforotherteams( "mission_failure", winner );
    }
    else
        leaderdialog( "mission_draw" );
}

doflameaudio()
{
    self endon( "disconnect" );
    waittillframeend;

    if ( !isdefined( self.lastflamehurtaudio ) )
        self.lastflamehurtaudio = 0;

    currenttime = gettime();

    if ( self.lastflamehurtaudio + level.fire_audio_repeat_duration + randomint( level.fire_audio_random_max_duration ) < currenttime )
    {
        self playlocalsound( "vox_pain_small" );
        self.lastflamehurtaudio = currenttime;
    }
}

leaderdialog( dialog, team, group, excludelist, squaddialog )
{
/#
    assert( isdefined( level.players ) );
#/
    if ( level.splitscreen )
        return;

    if ( level.wagermatch )
        return;

    if ( !isdefined( team ) )
    {
        dialogs = [];

        foreach ( team in level.teams )
            dialogs[team] = dialog;

        leaderdialogallteams( dialogs, group, excludelist );
        return;
    }

    if ( level.splitscreen )
    {
        if ( level.players.size )
            level.players[0] leaderdialogonplayer( dialog, group );

        return;
    }

    if ( isdefined( excludelist ) )
    {
        for ( i = 0; i < level.players.size; i++ )
        {
            player = level.players[i];

            if ( isdefined( player.pers["team"] ) && player.pers["team"] == team && !maps\mp\gametypes_zm\_globallogic_utils::isexcluded( player, excludelist ) )
                player leaderdialogonplayer( dialog, group );
        }
    }
    else
    {
        for ( i = 0; i < level.players.size; i++ )
        {
            player = level.players[i];

            if ( isdefined( player.pers["team"] ) && player.pers["team"] == team )
                player leaderdialogonplayer( dialog, group );
        }
    }
}

leaderdialogallteams( dialogs, group, excludelist )
{
/#
    assert( isdefined( level.players ) );
#/
    if ( level.splitscreen )
        return;

    if ( level.splitscreen )
    {
        if ( level.players.size )
            level.players[0] leaderdialogonplayer( dialogs[level.players[0].team], group );

        return;
    }

    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];
        team = player.pers["team"];

        if ( !isdefined( team ) )
            continue;

        if ( !isdefined( dialogs[team] ) )
            continue;

        if ( isdefined( excludelist ) && maps\mp\gametypes_zm\_globallogic_utils::isexcluded( player, excludelist ) )
            continue;

        player leaderdialogonplayer( dialogs[team], group );
    }
}

flushdialog()
{
    foreach ( player in level.players )
        player flushdialogonplayer();
}

flushdialogonplayer()
{
    self.leaderdialoggroups = [];
    self.leaderdialogqueue = [];
    self.leaderdialogactive = 0;
    self.currentleaderdialoggroup = "";
}

flushgroupdialog( group )
{
    foreach ( player in level.players )
        player flushgroupdialogonplayer( group );
}

flushgroupdialogonplayer( group )
{
    self.leaderdialoggroups[group] = undefined;

    foreach ( key, dialog in self.leaderdialogqueue )
    {
        if ( dialog == group )
            self.leaderdialogqueue[key] = undefined;
    }
}

addgroupdialogtoplayer( dialog, group )
{
    if ( !isdefined( level.dialoggroup[group] ) )
    {
        error( "leaderDialogOnPlayer:  Dialog group " + group + " is not registered" );
        return 0;
    }

    addtoqueue = 0;

    if ( !isdefined( self.leaderdialoggroups[group] ) )
        addtoqueue = 1;

    if ( !level.dialoggroup[group].skipifcurrentlyplayinggroup )
    {
        if ( self.currentleaderdialog == dialog && self.currentleaderdialogtime + 2000 > gettime() )
        {
            self.leaderdialoggroups[group] = undefined;

            foreach ( key, leader_dialog in self.leaderdialogqueue )
            {
                if ( leader_dialog == group )
                {
                    for ( i = key + 1; i < self.leaderdialogqueue.size; i++ )
                        self.leaderdialogqueue[i - 1] = self.leaderdialogqueue[i];

                    self.leaderdialogqueue[i - 1] = undefined;
                    break;
                }
            }

            return 0;
        }
    }
    else if ( self.currentleaderdialoggroup == group )
        return 0;

    self.leaderdialoggroups[group] = dialog;
    return addtoqueue;
}

testdialogqueue( group )
{
/#
    count = 0;

    foreach ( temp in self.leaderdialogqueue )
    {
        if ( temp == group )
            count++;
    }

    if ( count > 1 )
        shit = 0;
#/
}

leaderdialogonplayer( dialog, group )
{
    team = self.pers["team"];

    if ( level.splitscreen )
        return;

    if ( !isdefined( team ) )
        return;

    if ( !isdefined( level.teams[team] ) )
        return;

    if ( isdefined( group ) )
    {
        if ( !addgroupdialogtoplayer( dialog, group ) )
        {
            self testdialogqueue( group );
            return;
        }

        dialog = group;
    }

    if ( !self.leaderdialogactive )
        self thread playleaderdialogonplayer( dialog );
    else
        self.leaderdialogqueue[self.leaderdialogqueue.size] = dialog;
}

waitforsound( sound, extratime )
{
    if ( !isdefined( extratime ) )
        extratime = 0.1;

    time = soundgetplaybacktime( sound );

    if ( time < 0 )
        wait( 3.0 + extratime );
    else
        wait( time * 0.001 + extratime );
}

playleaderdialogonplayer( dialog )
{
    if ( isdefined( level.allowannouncer ) && !level.allowannouncer )
        return;

    team = self.pers["team"];
    self endon( "disconnect" );
    self.leaderdialogactive = 1;

    if ( isdefined( self.leaderdialoggroups[dialog] ) )
    {
        group = dialog;
        dialog = self.leaderdialoggroups[group];
        self.leaderdialoggroups[group] = undefined;
        self.currentleaderdialoggroup = group;
        self testdialogqueue( group );
    }

    if ( level.wagermatch || !isdefined( game["voice"] ) )
        faction = "vox_wm_";
    else
        faction = game["voice"][team];

    sound_name = faction + game["dialog"][dialog];

    if ( level.allowannouncer )
    {
        self playlocalsound( sound_name );
        self.currentleaderdialog = dialog;
        self.currentleaderdialogtime = gettime();
    }

    waitforsound( sound_name );
    self.leaderdialogactive = 0;
    self.currentleaderdialoggroup = "";
    self.currentleaderdialog = "";

    if ( self.leaderdialogqueue.size > 0 )
    {
        nextdialog = self.leaderdialogqueue[0];

        for ( i = 1; i < self.leaderdialogqueue.size; i++ )
            self.leaderdialogqueue[i - 1] = self.leaderdialogqueue[i];

        self.leaderdialogqueue[i - 1] = undefined;

        if ( isdefined( self.leaderdialoggroups[dialog] ) )
            self testdialogqueue( dialog );

        self thread playleaderdialogonplayer( nextdialog );
    }
}

isteamwinning( checkteam )
{
    score = game["teamScores"][checkteam];

    foreach ( team in level.teams )
    {
        if ( team != checkteam )
        {
            if ( game["teamScores"][team] >= score )
                return false;
        }
    }

    return true;
}

announceteamiswinning()
{
    foreach ( team in level.teams )
    {
        if ( isteamwinning( team ) )
        {
            leaderdialog( "winning", team, undefined, undefined, "squad_winning" );
            leaderdialogforotherteams( "losing", team, "squad_losing" );
            return true;
        }
    }

    return false;
}

musiccontroller()
{
    level endon( "game_ended" );
    level thread musictimesout();

    level waittill( "match_ending_soon" );

    if ( islastround() || isoneround() )
    {
        if ( !level.splitscreen )
        {
            if ( level.teambased )
            {
                if ( !announceteamiswinning() )
                    leaderdialog( "min_draw" );
            }

            level waittill( "match_ending_very_soon" );

            foreach ( team in level.teams )
                leaderdialog( "timesup", team, undefined, undefined, "squad_30sec" );
        }
    }
    else
    {
        level waittill( "match_ending_vox" );

        leaderdialog( "timesup" );
    }
}

musictimesout()
{
    level endon( "game_ended" );

    level waittill( "match_ending_very_soon" );

    thread maps\mp\gametypes_zm\_globallogic_audio::set_music_on_team( "TIME_OUT", "both", 1, 0 );
}

actionmusicset()
{
    level endon( "game_ended" );
    level.playingactionmusic = 1;
    wait 45;
    level.playingactionmusic = 0;
}

play_2d_on_team( alias, team )
{
/#
    assert( isdefined( level.players ) );
#/
    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( isdefined( player.pers["team"] ) && player.pers["team"] == team )
            player playlocalsound( alias );
    }
}

set_music_on_team( state, team, save_state, return_state, wait_time )
{
    if ( sessionmodeiszombiesgame() )
        return;
/#
    assert( isdefined( level.players ) );
#/
    if ( !isdefined( team ) )
    {
        team = "both";
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - team undefined: Setting to both" );
#/
    }

    if ( !isdefined( save_state ) )
    {
        save_sate = 0;
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - save_sate undefined: Setting to false" );
#/
    }

    if ( !isdefined( return_state ) )
    {
        return_state = 0;
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - Music System - return_state undefined: Setting to false" );
#/
    }

    if ( !isdefined( wait_time ) )
    {
        wait_time = 0;
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - wait_time undefined: Setting to 0" );
#/
    }

    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( team == "both" )
        {
            player thread set_music_on_player( state, save_state, return_state, wait_time );
            continue;
        }

        if ( isdefined( player.pers["team"] ) && player.pers["team"] == team )
        {
            player thread set_music_on_player( state, save_state, return_state, wait_time );
/#
            if ( getdvarint( _hash_BC4784C ) > 0 )
                println( "Music System - Setting Music State " + state + " On player " + player getentitynumber() );
#/
        }
    }
}

set_music_on_player( state, save_state, return_state, wait_time )
{
    self endon( "disconnect" );

    if ( sessionmodeiszombiesgame() )
        return;
/#
    assert( isplayer( self ) );
#/
    if ( !isdefined( save_state ) )
    {
        save_state = 0;
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - Music System - save_sate undefined: Setting to false" );
#/
    }

    if ( !isdefined( return_state ) )
    {
        return_state = 0;
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - Music System - return_state undefined: Setting to false" );
#/
    }

    if ( !isdefined( wait_time ) )
    {
        wait_time = 0;
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - wait_time undefined: Setting to 0" );
#/
    }

    if ( !isdefined( state ) )
    {
        state = "UNDERSCORE";
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - state undefined: Setting to UNDERSCORE" );
#/
    }

    maps\mp\_music::setmusicstate( state, self );

    if ( isdefined( self.pers["music"].currentstate ) && save_state )
    {
        self.pers["music"].returnstate = state;
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - Saving Music State " + self.pers["music"].returnstate + " On " + self getentitynumber() );
#/
    }

    self.pers["music"].previousstate = self.pers["music"].currentstate;
    self.pers["music"].currentstate = state;
/#
    if ( getdvarint( _hash_BC4784C ) > 0 )
        println( "Music System - Setting Music State " + state + " On player " + self getentitynumber() );
#/
    if ( isdefined( self.pers["music"].returnstate ) && return_state )
    {
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - Starting Return State " + self.pers["music"].returnstate + " On " + self getentitynumber() );
#/
        self set_next_music_state( self.pers["music"].returnstate, wait_time );
    }
}

return_music_state_player( wait_time )
{
    if ( !isdefined( wait_time ) )
    {
        wait_time = 0;
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - wait_time undefined: Setting to 0" );
#/
    }

    self set_next_music_state( self.pers["music"].returnstate, wait_time );
}

return_music_state_team( team, wait_time )
{
    if ( !isdefined( wait_time ) )
    {
        wait_time = 0;
/#
        if ( getdvarint( _hash_BC4784C ) > 0 )
            println( "Music System - wait_time undefined: Setting to 0" );
#/
    }

    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( team == "both" )
        {
            player thread set_next_music_state( self.pers["music"].returnstate, wait_time );
            continue;
        }

        if ( isdefined( player.pers["team"] ) && player.pers["team"] == team )
        {
            player thread set_next_music_state( self.pers["music"].returnstate, wait_time );
/#
            if ( getdvarint( _hash_BC4784C ) > 0 )
                println( "Music System - Setting Music State " + self.pers["music"].returnstate + " On player " + player getentitynumber() );
#/
        }
    }
}

set_next_music_state( nextstate, wait_time )
{
    self endon( "disconnect" );
    self.pers["music"].nextstate = nextstate;
/#
    if ( getdvarint( _hash_BC4784C ) > 0 )
        println( "Music System - Setting next Music State " + self.pers["music"].nextstate + " On " + self getentitynumber() );
#/
    if ( !isdefined( self.pers["music"].inque ) )
        self.pers["music"].inque = 0;

    if ( self.pers["music"].inque )
    {
        return;
/#
        println( "Music System - Music state in que" );
#/
    }
    else
    {
        self.pers["music"].inque = 1;

        if ( wait_time )
            wait( wait_time );

        self set_music_on_player( self.pers["music"].nextstate, 0 );
        self.pers["music"].inque = 0;
    }
}

getroundswitchdialog( switchtype )
{
    switch ( switchtype )
    {
        case "halftime":
            return "halftime";
        case "overtime":
            return "overtime";
        default:
            return "side_switch";
    }
}

post_match_snapshot_watcher()
{
    level waittill( "game_ended" );

    level clientnotify( "pm" );

    level waittill( "sfade" );

    level clientnotify( "pmf" );
}
