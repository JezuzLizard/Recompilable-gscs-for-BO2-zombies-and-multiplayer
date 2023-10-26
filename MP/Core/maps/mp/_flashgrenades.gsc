// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;

main()
{
    precacheshellshock( "flashbang" );
    level.sound_flash_start = "";
    level.sound_flash_loop = "";
    level.sound_flash_stop = "";
}

startmonitoringflash()
{
    self thread monitorflash();
}

stopmonitoringflash( disconnected )
{
    self notify( "stop_monitoring_flash" );
}

flashrumbleloop( duration )
{
    self endon( "stop_monitoring_flash" );
    self endon( "flash_rumble_loop" );
    self notify( "flash_rumble_loop" );
    goaltime = gettime() + duration * 1000;

    while ( gettime() < goaltime )
    {
        self playrumbleonentity( "damage_heavy" );
        wait 0.05;
    }
}

monitorflash_internal( amount_distance, amount_angle, attacker, direct_on_player )
{
    hurtattacker = 0;
    hurtvictim = 1;

    if ( amount_angle < 0.5 )
        amount_angle = 0.5;
    else if ( amount_angle > 0.8 )
        amount_angle = 1;

    if ( isdefined( attacker ) && attacker == self )
        amount_distance *= 0.5;

    duration = amount_distance * amount_angle * 6;

    if ( duration < 0.25 )
        return;

    rumbleduration = undefined;

    if ( duration > 2 )
        rumbleduration = 0.75;
    else
        rumbleduration = 0.25;

    assert( isdefined( self.team ) );

    if ( level.teambased && isdefined( attacker ) && isdefined( attacker.team ) && attacker.team == self.team && attacker != self )
    {
        if ( level.friendlyfire == 0 )
            return;
        else if ( level.friendlyfire == 1 )
        {

        }
        else if ( level.friendlyfire == 2 )
        {
            duration *= 0.5;
            rumbleduration *= 0.5;
            hurtvictim = 0;
            hurtattacker = 1;
        }
        else if ( level.friendlyfire == 3 )
        {
            duration *= 0.5;
            rumbleduration *= 0.5;
            hurtattacker = 1;
        }
    }

    if ( self hasperk( "specialty_flashprotection" ) )
    {
        duration *= 0.1;
        rumbleduration *= 0.1;
    }

    if ( hurtvictim )
    {
        if ( self mayapplyscreeneffect() || !direct_on_player && self isremotecontrolling() )
        {
            if ( self != attacker )
            {
                attacker addweaponstat( "flash_grenade_mp", "hits", 1 );
                attacker addweaponstat( "flash_grenade_mp", "used", 1 );
            }

            self thread applyflash( duration, rumbleduration, attacker );
        }
    }

    if ( hurtattacker )
    {
        if ( attacker mayapplyscreeneffect() )
            attacker thread applyflash( duration, rumbleduration, attacker );
    }
}

monitorflash()
{
    self endon( "disconnect" );
    self.flashendtime = 0;

    while ( true )
    {
        self waittill( "flashbang", amount_distance, amount_angle, attacker );

        if ( !isalive( self ) )
            continue;

        self monitorflash_internal( amount_distance, amount_angle, attacker, 1 );
    }
}

monitorrcbombflash()
{
    self endon( "death" );
    self.flashendtime = 0;

    while ( true )
    {
        self waittill( "flashbang", amount_distance, amount_angle, attacker );

        driver = self getseatoccupant( 0 );

        if ( !isdefined( driver ) || !isalive( driver ) )
            continue;

        driver monitorflash_internal( amount_distance, amount_angle, attacker, 0 );
    }
}

applyflash( duration, rumbleduration, attacker )
{
    if ( !isdefined( self.flashduration ) || duration > self.flashduration )
        self.flashduration = duration;

    if ( !isdefined( self.flashrumbleduration ) || rumbleduration > self.flashrumbleduration )
        self.flashrumbleduration = rumbleduration;

    self thread playflashsound( duration );
    wait 0.05;

    if ( isdefined( self.flashduration ) )
    {
        self shellshock( "flashbang", self.flashduration, 0 );
        self.flashendtime = gettime() + self.flashduration * 1000;
        self.lastflashedby = attacker;
    }

    if ( isdefined( self.flashrumbleduration ) )
        self thread flashrumbleloop( self.flashrumbleduration );

    self.flashduration = undefined;
    self.flashrumbleduration = undefined;
}

playflashsound( duration )
{
    self endon( "death" );
    self endon( "disconnect" );
    flashsound = spawn( "script_origin", ( 0, 0, 1 ) );
    flashsound.origin = self.origin;
    flashsound linkto( self );
    flashsound thread deleteentonownerdeath( self );
    flashsound playsound( level.sound_flash_start );
    flashsound playloopsound( level.sound_flash_loop );

    if ( duration > 0.5 )
        wait( duration - 0.5 );

    flashsound playsound( level.sound_flash_start );
    flashsound stoploopsound( 0.5 );
    wait 0.5;
    flashsound notify( "delete" );
    flashsound delete();
}

deleteentonownerdeath( owner )
{
    self endon( "delete" );

    owner waittill( "death" );

    self delete();
}
