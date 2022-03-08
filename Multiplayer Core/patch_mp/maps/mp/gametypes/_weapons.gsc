// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precacheitem( "knife_mp" );
    precacheitem( "knife_held_mp" );
    precacheitem( "dogs_mp" );
    precacheitem( "dog_bite_mp" );
    precacheitem( "explosive_bolt_mp" );
    precachemodel( "t6_wpn_claymore_world_detect" );
    precachemodel( "t6_wpn_c4_world_detect" );
    precachemodel( "t5_weapon_scrambler_world_detect" );
    precachemodel( "t6_wpn_tac_insert_detect" );
    precachemodel( "t6_wpn_taser_mine_world_detect" );
    precachemodel( "t6_wpn_motion_sensor_world_detect" );
    precachemodel( "t6_wpn_trophy_system_world_detect" );
    precachemodel( "t6_wpn_bouncing_betty_world_detect" );
    precachemodel( "t6_wpn_tac_insert_world" );
    precachemodel( "t6_wpn_shield_stow_world" );
    precachemodel( "t6_wpn_shield_carry_world" );
    precachemodel( "t5_weapon_camera_head_world" );
    precacheitem( "scavenger_item_mp" );
    precacheitem( "scavenger_item_hack_mp" );
    precacheshader( "hud_scavenger_pickup" );
    precacheshellshock( "default" );
    precacheshellshock( "concussion_grenade_mp" );
    precacheshellshock( "tabun_gas_mp" );
    precacheshellshock( "tabun_gas_nokick_mp" );
    precacheshellshock( "proximity_grenade" );
    precacheshellshock( "proximity_grenade_exit" );
    level.missileentities = [];
    level.hackertooltargets = [];
    level.missileduddeletedelay = getdvarintdefault( "scr_missileDudDeleteDelay", 3 );
    thread maps\mp\_flashgrenades::main();
    thread maps\mp\_empgrenade::init();
    thread maps\mp\_entityheadicons::init();

    if ( !isdefined( level.roundstartexplosivedelay ) )
        level.roundstartexplosivedelay = 0;

    level thread onplayerconnect();
    maps\mp\gametypes\_weaponobjects::init();
    maps\mp\_smokegrenade::init();
    maps\mp\_heatseekingmissile::init();
    maps\mp\_acousticsensor::init();
    maps\mp\_sensor_grenade::init();
    maps\mp\_tacticalinsertion::init();
    maps\mp\_scrambler::init();
    maps\mp\_explosive_bolt::init();
    maps\mp\_sticky_grenade::init();
    maps\mp\_proximity_grenade::init();
    maps\mp\_bouncingbetty::init();
    maps\mp\_trophy_system::init();
    maps\mp\_ballistic_knife::init();
    maps\mp\_satchel_charge::init();
    maps\mp\_riotshield::init();
    maps\mp\_hacker_tool::init();
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player.usedweapons = 0;
        player.lastfiretime = 0;
        player.hits = 0;
        player scavenger_hud_create();
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self.concussionendtime = 0;
        self.scavenged = 0;
        self.hasdonecombat = 0;
        self.shielddamageblocked = 0;
        self thread watchweaponusage();
        self thread watchgrenadeusage();
        self thread watchmissileusage();
        self thread watchweaponchange();
        self thread watchturretuse();
        self thread watchriotshielduse();
        self thread trackweapon();
        self.droppeddeathweapon = undefined;
        self.tookweaponfrom = [];
        self.pickedupweaponkills = [];
        self thread updatestowedweapon();
    }
}

watchturretuse()
{
    self endon( "death" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "turretownerchange", turret );

        self thread watchfortowfire( turret );
    }
}

watchfortowfire( turret )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "turretownerchange" );

    while ( true )
    {
        self waittill( "turret_tow_fire" );

        self thread watchmissleunlink( turret );

        self waittill( "turret_tow_unlink" );
    }
}

watchmissleunlink( turret )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "turretownerchange" );

    self waittill( "turret_tow_unlink" );

    self relinktoturret( turret );
}

watchweaponchange()
{
    self endon( "death" );
    self endon( "disconnect" );
    self.lastdroppableweapon = self getcurrentweapon();
    self.hitsthismag = [];
    weapon = self getcurrentweapon();

    if ( isprimaryweapon( weapon ) && !isdefined( self.hitsthismag[weapon] ) )
        self.hitsthismag[weapon] = weaponclipsize( weapon );

    self.lastweaponchange = 0;

    while ( true )
    {
        previous_weapon = self getcurrentweapon();

        self waittill( "weapon_change", newweapon );

        if ( maydropweapon( newweapon ) )
        {
            self.lastdroppableweapon = newweapon;
            self.lastweaponchange = gettime();
        }

        if ( newweapon != "none" )
        {
            if ( ( isprimaryweapon( newweapon ) || issidearm( newweapon ) ) && !isdefined( self.hitsthismag[newweapon] ) )
                self.hitsthismag[newweapon] = weaponclipsize( newweapon );
        }

        if ( doesweaponreplacespawnweapon( self.spawnweapon, newweapon ) )
        {
            self.spawnweapon = newweapon;
            self.pers["spawnWeapon"] = newweapon;
        }
    }
}

watchriotshielduse()
{
    self endon( "death" );
    self endon( "disconnect" );
    self thread maps\mp\_riotshield::trackriotshield();

    for (;;)
    {
        self waittill( "raise_riotshield" );

        self thread maps\mp\_riotshield::startriotshielddeploy();
    }
}

updatelastheldweapontimings( newtime )
{
    if ( isdefined( self.currentweapon ) && isdefined( self.currentweaponstarttime ) )
    {
        totaltime = int( ( newtime - self.currentweaponstarttime ) / 1000 );

        if ( totaltime > 0 )
        {
            self addweaponstat( self.currentweapon, "timeUsed", totaltime );
            self.currentweaponstarttime = newtime;
        }
    }
}

updateweapontimings( newtime )
{
    if ( self is_bot() )
        return;

    updatelastheldweapontimings( newtime );

    if ( !isdefined( self.staticweaponsstarttime ) )
        return;

    totaltime = int( ( newtime - self.staticweaponsstarttime ) / 1000 );

    if ( totaltime < 0 )
        return;

    self.staticweaponsstarttime = newtime;

    if ( isdefined( self.weapon_array_grenade ) )
    {
        for ( i = 0; i < self.weapon_array_grenade.size; i++ )
            self addweaponstat( self.weapon_array_grenade[i], "timeUsed", totaltime );
    }

    if ( isdefined( self.weapon_array_inventory ) )
    {
        for ( i = 0; i < self.weapon_array_inventory.size; i++ )
            self addweaponstat( self.weapon_array_inventory[i], "timeUsed", totaltime );
    }

    if ( isdefined( self.killstreak ) )
    {
        for ( i = 0; i < self.killstreak.size; i++ )
        {
            killstreakweapon = level.menureferenceforkillstreak[self.killstreak[i]];

            if ( isdefined( killstreakweapon ) )
                self addweaponstat( killstreakweapon, "timeUsed", totaltime );
        }
    }

    if ( level.rankedmatch && level.perksenabled )
    {
        perksindexarray = [];
        specialtys = self.specialty;

        if ( !isdefined( specialtys ) )
            return;

        if ( !isdefined( self.class ) )
            return;

        if ( isdefined( self.class_num ) )
        {
            for ( numspecialties = 0; numspecialties < level.maxspecialties; numspecialties++ )
            {
                perk = self getloadoutitem( self.class_num, "specialty" + ( numspecialties + 1 ) );

                if ( perk != 0 )
                    perksindexarray[perk] = 1;
            }

            perkindexarraykeys = getarraykeys( perksindexarray );

            for ( i = 0; i < perkindexarraykeys.size; i++ )
            {
                if ( perksindexarray[perkindexarraykeys[i]] == 1 )
                    self adddstat( "itemStats", perkindexarraykeys[i], "stats", "timeUsed", "statValue", totaltime );
            }
        }
    }
}

trackweapon()
{
    currentweapon = self getcurrentweapon();
    currenttime = gettime();
    spawnid = getplayerspawnid( self );

    while ( true )
    {
        event = self waittill_any_return( "weapon_change", "death", "disconnect" );
        newtime = gettime();

        if ( event == "weapon_change" )
        {
            self maps\mp\_bb::commitweapondata( spawnid, currentweapon, currenttime );
            newweapon = self getcurrentweapon();

            if ( newweapon != "none" && newweapon != currentweapon )
            {
                updatelastheldweapontimings( newtime );
                self maps\mp\gametypes\_class::initweaponattachments( newweapon );
                currentweapon = newweapon;
                currenttime = newtime;
            }
        }
        else
        {
            if ( event != "disconnect" && isdefined( self ) )
            {
                self maps\mp\_bb::commitweapondata( spawnid, currentweapon, currenttime );
                updateweapontimings( newtime );
            }

            return;
        }
    }
}

maydropweapon( weapon )
{
    if ( level.disableweapondrop == 1 )
        return false;

    if ( weapon == "none" )
        return false;

    if ( ishackweapon( weapon ) )
        return false;

    invtype = weaponinventorytype( weapon );

    if ( invtype != "primary" )
        return false;

    if ( weapon == "none" )
        return false;

    return true;
}

dropweaponfordeath( attacker, sweapon, smeansofdeath )
{
    if ( level.disableweapondrop == 1 )
        return;

    weapon = self.lastdroppableweapon;

    if ( isdefined( self.droppeddeathweapon ) )
        return;

    if ( !isdefined( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: not defined" );
#/
        return;
    }

    if ( weapon == "none" )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: weapon == none" );
#/
        return;
    }

    if ( !self hasweapon( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: don't have it anymore (" + weapon + ")" );
#/
        return;
    }

    if ( !self anyammoforweaponmodes( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: no ammo for weapon modes" );
#/
        return;
    }

    if ( !shoulddroplimitedweapon( weapon, self ) )
        return;

    if ( maps\mp\killstreaks\_killstreak_weapons::isheldkillstreakweapon( weapon ) )
        return;

    clipammo = self getweaponammoclip( weapon );
    stockammo = self getweaponammostock( weapon );
    clip_and_stock_ammo = clipammo + stockammo;

    if ( !clip_and_stock_ammo )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: no ammo" );
#/
        return;
    }

    stockmax = weaponmaxammo( weapon );

    if ( stockammo > stockmax )
        stockammo = stockmax;

    item = self dropitem( weapon );

    if ( !isdefined( item ) )
    {
/#
        iprintlnbold( "dropItem: was not able to drop weapon " + weapon );
#/
        return;
    }

/#
    if ( getdvar( _hash_8F7FC88 ) == "1" )
        println( "dropped weapon: " + weapon );
#/
    droplimitedweapon( weapon, self, item );
    self.droppeddeathweapon = 1;
    item itemweaponsetammo( clipammo, stockammo );
    item.owner = self;
    item.ownersattacker = attacker;
    item.sweapon = sweapon;
    item.smeansofdeath = smeansofdeath;
    item thread watchpickup();
    item thread deletepickupafterawhile();
}

dropweapontoground( weapon )
{
    if ( !isdefined( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: not defined" );
#/
        return;
    }

    if ( weapon == "none" )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: weapon == none" );
#/
        return;
    }

    if ( !self hasweapon( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: don't have it anymore (" + weapon + ")" );
#/
        return;
    }

    if ( !self anyammoforweaponmodes( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: no ammo for weapon modes" );
#/

        switch ( weapon )
        {
            case "mp40_blinged_mp":
            case "minigun_mp":
            case "m32_mp":
            case "m220_tow_mp":
            case "m202_flash_mp":
                self takeweapon( weapon );
                break;
            default:
                break;
        }

        return;
    }

    if ( !shoulddroplimitedweapon( weapon, self ) )
        return;

    clipammo = self getweaponammoclip( weapon );
    stockammo = self getweaponammostock( weapon );
    clip_and_stock_ammo = clipammo + stockammo;

    if ( !clip_and_stock_ammo )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: no ammo" );
#/
        return;
    }

    stockmax = weaponmaxammo( weapon );

    if ( stockammo > stockmax )
        stockammo = stockmax;

    item = self dropitem( weapon );
/#
    if ( getdvar( _hash_8F7FC88 ) == "1" )
        println( "dropped weapon: " + weapon );
#/
    droplimitedweapon( weapon, self, item );
    item itemweaponsetammo( clipammo, stockammo );
    item.owner = self;
    item thread watchpickup();
    item thread deletepickupafterawhile();
}

deletepickupafterawhile()
{
    self endon( "death" );
    wait 60;

    if ( !isdefined( self ) )
        return;

    self delete();
}

getitemweaponname()
{
    classname = self.classname;
/#
    assert( getsubstr( classname, 0, 7 ) == "weapon_" );
#/
    weapname = getsubstr( classname, 7 );
    return weapname;
}

watchpickup()
{
    self endon( "death" );
    weapname = self getitemweaponname();

    self waittill( "trigger", player, droppeditem );

/#
    if ( getdvar( _hash_8F7FC88 ) == "1" )
        println( "picked up weapon: " + weapname + ", " + isdefined( self.ownersattacker ) );
#/
/#
    assert( isdefined( player.tookweaponfrom ) );
#/
/#
    assert( isdefined( player.pickedupweaponkills ) );
#/

    if ( isdefined( droppeditem ) )
    {
        droppedweaponname = droppeditem getitemweaponname();

        if ( isdefined( player.tookweaponfrom[droppedweaponname] ) )
        {
            droppeditem.owner = player.tookweaponfrom[droppedweaponname];
            droppeditem.ownersattacker = player;
            player.tookweaponfrom[droppedweaponname] = undefined;
        }

        droppeditem thread watchpickup();
    }

    if ( isdefined( self.ownersattacker ) && self.ownersattacker == player )
    {
        player.tookweaponfrom[weapname] = spawnstruct();
        player.tookweaponfrom[weapname].previousowner = self.owner;
        player.tookweaponfrom[weapname].sweapon = self.sweapon;
        player.tookweaponfrom[weapname].smeansofdeath = self.smeansofdeath;
        player.pickedupweaponkills[weapname] = 0;
    }
    else
    {
        player.tookweaponfrom[weapname] = undefined;
        player.pickedupweaponkills[weapname] = undefined;
    }
}

itemremoveammofromaltmodes()
{
    origweapname = self getitemweaponname();
    curweapname = weaponaltweaponname( origweapname );

    for ( altindex = 1; curweapname != "none" && curweapname != origweapname; altindex++ )
    {
        self itemweaponsetammo( 0, 0, altindex );
        curweapname = weaponaltweaponname( curweapname );
    }
}

dropoffhand()
{
    grenadetypes = [];

    for ( index = 0; index < grenadetypes.size; index++ )
    {
        if ( !self hasweapon( grenadetypes[index] ) )
            continue;

        count = self getammocount( grenadetypes[index] );

        if ( !count )
            continue;

        self dropitem( grenadetypes[index] );
    }
}

watchweaponusage()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self.usedkillstreakweapon = [];
    self.usedkillstreakweapon["minigun_mp"] = 0;
    self.usedkillstreakweapon["m32_mp"] = 0;
    self.usedkillstreakweapon["m202_flash_mp"] = 0;
    self.usedkillstreakweapon["m220_tow_mp"] = 0;
    self.usedkillstreakweapon["mp40_blinged_mp"] = 0;
    self.killstreaktype = [];
    self.killstreaktype["minigun_mp"] = "minigun_mp";
    self.killstreaktype["m32_mp"] = "m32_mp";
    self.killstreaktype["m202_flash_mp"] = "m202_flash_mp";
    self.killstreaktype["m220_tow_mp"] = "m220_tow_mp";
    self.killstreaktype["mp40_blinged_mp"] = "mp40_blinged_drop_mp";

    for (;;)
    {
        self waittill( "weapon_fired", curweapon );

        self.lastfiretime = gettime();
        self.hasdonecombat = 1;

        if ( maps\mp\gametypes\_weapons::isprimaryweapon( curweapon ) || maps\mp\gametypes\_weapons::issidearm( curweapon ) )
        {
            if ( isdefined( self.hitsthismag[curweapon] ) )
                self thread updatemagshots( curweapon );
        }

        switch ( weaponclass( curweapon ) )
        {
            case "rifle":
                if ( curweapon == "crossbow_mp" )
                    level.globalcrossbowfired++;

                if ( curweapon == "crossbow_explosive_mp" )
                {
                    level.globalcrossbowfired++;
                    self addweaponstat( curweapon, "shots", 1 );
                    self thread begingrenadetracking();
                    break;
                }
            case "spread":
            case "smg":
            case "pistol spread":
            case "pistol":
            case "mg":
                self trackweaponfire( curweapon );
                level.globalshotsfired++;
                break;
            case "rocketlauncher":
            case "grenade":
                self addweaponstat( curweapon, "shots", 1 );
                break;
            default:
                break;
        }

        if ( maps\mp\killstreaks\_killstreak_weapons::isheldkillstreakweapon( curweapon ) )
        {
            self.pers["held_killstreak_ammo_count"][curweapon]--;
            self.usedkillstreakweapon[curweapon] = 1;
        }
    }
}

updatemagshots( weaponname )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "updateMagShots_" + weaponname );
    self.hitsthismag[weaponname]--;
    wait 0.05;
    self.hitsthismag[weaponname] = weaponclipsize( weaponname );
}

checkhitsthismag( weaponname )
{
    self endon( "death" );
    self endon( "disconnect" );
    self notify( "updateMagShots_" + weaponname );
    waittillframeend;

    if ( isdefined( self.hitsthismag[weaponname] ) && self.hitsthismag[weaponname] == 0 )
    {
        if ( !sessionmodeiszombiesgame() )
        {
            weaponclass = getweaponclass( weaponname );
            maps\mp\_challenges::fullclipnomisses( weaponclass, weaponname );
        }

        self.hitsthismag[weaponname] = weaponclipsize( weaponname );
    }
}

trackweaponfire( curweapon )
{
    pixbeginevent( "trackWeaponFire" );
    self trackweaponfirenative( curweapon, 1, self.hits, 1 );
    self maps\mp\_bb::bbaddtostat( "shots", 1 );
    self maps\mp\_bb::bbaddtostat( "hits", self.hits );
    self.hits = 0;
    pixendevent();
}

checkhit( sweapon )
{
    switch ( weaponclass( sweapon ) )
    {
        case "smg":
        case "rifle":
        case "pistol":
        case "mg":
            self.hits++;
            break;
        case "spread":
        case "pistol spread":
            self.hits = 1;
            break;
        default:
            break;
    }

    waittillframeend;

    if ( isdefined( self ) && isdefined( self.hitsthismag ) && isdefined( self.hitsthismag[sweapon] ) )
        self thread checkhitsthismag( sweapon );
}

watchgrenadeusage()
{
    self endon( "death" );
    self endon( "disconnect" );
    self.throwinggrenade = 0;
    self.gotpullbacknotify = 0;
    self thread beginothergrenadetracking();
    self thread watchforthrowbacks();
    self thread watchforgrenadeduds();
    self thread watchforgrenadelauncherduds();

    for (;;)
    {
        self waittill( "grenade_pullback", weaponname );

        self addweaponstat( weaponname, "shots", 1 );
        self.hasdonecombat = 1;
        self.throwinggrenade = 1;
        self.gotpullbacknotify = 1;

        if ( weaponname == "satchel_charge_mp" )
            self thread beginsatcheltracking();

        if ( !maps\mp\killstreaks\_supplydrop::issupplydropweapon( weaponname ) && weaponname != "sensor_grenade_mp" )
        {
            self setoffhandvisible( 1 );
            self thread watchoffhandend();
        }

        self thread begingrenadetracking();
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

        self.hasdonecombat = 1;
/#
        assert( isdefined( missile ) );
#/
        level.missileentities[level.missileentities.size] = missile;
        missile thread watchmissiledeath();
    }
}

watchmissiledeath()
{
    self waittill( "death" );

    arrayremovevalue( level.missileentities, self );
}

dropweaponstoground( origin, radius )
{
    weapons = getdroppedweapons();

    for ( i = 0; i < weapons.size; i++ )
    {
        if ( distancesquared( origin, weapons[i].origin ) < radius * radius )
        {
            trace = bullettrace( weapons[i].origin, weapons[i].origin + vectorscale( ( 0, 0, -1 ), 2000.0 ), 0, weapons[i] );
            weapons[i].origin = trace["position"];
        }
    }
}

dropgrenadestoground( origin, radius )
{
    grenades = getentarray( "grenade", "classname" );

    for ( i = 0; i < grenades.size; i++ )
    {
        if ( distancesquared( origin, grenades[i].origin ) < radius * radius )
            grenades[i] launch( vectorscale( ( 1, 1, 1 ), 5.0 ) );
    }
}

watchgrenadecancel()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "grenade_fire" );
    waittillframeend;
    weapon = "none";

    while ( self isthrowinggrenade() && weapon == "none" )
        self waittill( "weapon_change", weapon );

    self.throwinggrenade = 0;
    self.gotpullbacknotify = 0;
    self notify( "grenade_throw_cancelled" );
}

watchoffhandend()
{
    self notify( "watchOffhandEnd" );
    self endon( "watchOffhandEnd" );

    while ( self isusingoffhandequipment() )
    {
        msg = self waittill_any_return( "death", "disconnect", "grenade_fire", "weapon_change" );

        if ( msg == "death" || msg == "disconnect" )
            break;
    }

    self setoffhandvisible( 0 );
}

isusingoffhandequipment()
{
    if ( self isusingoffhand() )
    {
        weapon = self getcurrentoffhand();

        if ( isweaponequipment( weapon ) )
            return true;
    }

    return false;
}

begingrenadetracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "grenade_throw_cancelled" );
    starttime = gettime();
    self thread watchgrenadecancel();

    self waittill( "grenade_fire", grenade, weaponname );

/#
    assert( isdefined( grenade ) );
#/
    level.missileentities[level.missileentities.size] = grenade;
    grenade thread watchmissiledeath();

    if ( grenade maps\mp\_utility::ishacked() )
        return;

    bbprint( "mpequipmentuses", "gametime %d spawnid %d weaponname %s", gettime(), getplayerspawnid( self ), weaponname );

    if ( gettime() - starttime > 1000 )
        grenade.iscooked = 1;

    switch ( weaponname )
    {
        case "frag_grenade_mp":
            level.globalfraggrenadesfired++;
        case "sticky_grenade_mp":
            self addweaponstat( weaponname, "used", 1 );
        case "explosive_bolt_mp":
            grenade.originalowner = self;
            break;
        case "satchel_charge_mp":
            level.globalsatchelchargefired++;
            break;
    }

    if ( weaponname == "sticky_grenade_mp" || weaponname == "frag_grenade_mp" )
    {
        grenade setteam( self.pers["team"] );
        grenade setowner( self );
    }

    self.throwinggrenade = 0;
}

beginothergrenadetracking()
{
    self notify( "grenadeTrackingStart" );
    self endon( "grenadeTrackingStart" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "grenade_fire", grenade, weaponname, parent );

        if ( grenade maps\mp\_utility::ishacked() )
            continue;

        switch ( weaponname )
        {
            case "flash_grenade_mp":
                continue;
            case "concussion_grenade_mp":
                continue;
            case "willy_pete_mp":
                grenade thread maps\mp\_smokegrenade::watchsmokegrenadedetonation( self );
                continue;
            case "tabun_gas_mp":
                grenade thread maps\mp\_tabun::watchtabungrenadedetonation( self );
                continue;
            case "sticky_grenade_mp":
                grenade thread checkstucktoplayer( 1, 1, weaponname );
                grenade thread checkstucktoshield();
                continue;
            case "satchel_charge_mp":
            case "c4_mp":
                grenade thread checkstucktoplayer( 1, 0, weaponname );
                continue;
            case "proximity_grenade_mp":
                grenade thread checkstucktoshield();
                grenade thread maps\mp\_proximity_grenade::watchproximitygrenadehitplayer( self );
                continue;
            case "tactical_insertion_mp":
                grenade thread maps\mp\_tacticalinsertion::watch( self );
                continue;
            case "scrambler_mp":
                continue;
            case "explosive_bolt_mp":
                grenade.ownerweaponatlaunch = self.currentweapon;
                grenade.owneradsatlaunch = self playerads() == 1 ? 1 : 0;
                grenade thread maps\mp\_explosive_bolt::watch_bolt_detonation( self );
                grenade thread checkstucktoplayer( 1, 0, weaponname );
                grenade thread checkstucktoshield();
                continue;
            case "hatchet_mp":
                grenade.lastweaponbeforetoss = self getlastweapon();
                grenade thread checkhatchetbounce();
                grenade thread checkstucktoplayer( 0, 0, weaponname );
                self addweaponstat( weaponname, "used", 1 );
                continue;
            case "emp_grenade_mp":
                grenade thread maps\mp\_empgrenade::watchempexplosion( self, weaponname );
                continue;
        }
    }
}

checkstucktoplayer( deleteonteamchange, awardscoreevent, weaponname )
{
    self endon( "death" );

    self waittill( "stuck_to_player", player );

    if ( isdefined( player ) )
    {
        if ( deleteonteamchange )
            self thread stucktoplayerteamchange( player );

        if ( awardscoreevent && isdefined( self.originalowner ) )
        {
            if ( self.originalowner isenemyplayer( player ) )
                maps\mp\_scoreevents::processscoreevent( "stick_explosive_kill", self.originalowner, player, weaponname );
        }

        self.stucktoplayer = player;
    }
}

checkstucktoshield()
{
    self endon( "death" );

    self waittill( "stuck_to_shield", other, owner );

    other maps\mp\_riotshield::watchriotshieldstuckentitydeath( self, owner );
}

checkhatchetbounce()
{
    self endon( "stuck_to_player" );
    self endon( "death" );

    self waittill( "grenade_bounce" );

    self.bounced = 1;
}

stucktoplayerteamchange( player )
{
    self endon( "death" );
    player endon( "disconnect" );
    originalteam = player.pers["team"];

    while ( true )
    {
        player waittill( "joined_team" );

        if ( player.pers["team"] != originalteam )
        {
            self detonate();
            return;
        }
    }
}

beginsatcheltracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    self waittill_any( "grenade_fire", "weapon_change" );
    self.throwinggrenade = 0;
}

watchforthrowbacks()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "grenade_fire", grenade, weapname );

        if ( self.gotpullbacknotify )
        {
            self.gotpullbacknotify = 0;
            continue;
        }

        if ( !issubstr( weapname, "frag_" ) )
            continue;

        grenade.threwback = 1;
        grenade.originalowner = self;
    }
}

waitanddeletedud( waittime )
{
    self endon( "death" );
    wait( waittime );

    if ( isdefined( self ) )
        self delete();
}

makeallboltsdud()
{
    grenades = getentarray( "grenade", "classname" );

    for ( i = 0; i < grenades.size; i++ )
    {
        if ( grenades[i].model == "t5_weapon_crossbow_bolt" )
        {
            grenades[i] makegrenadedud();

            if ( !isdefined( grenades[i].isdud ) )
                grenades[i] thread waitanddeletedud( level.missileduddeletedelay );

            grenades[i].isdud = 1;
        }
    }
}

turngrenadeintoadud( weapname, isthrowngrenade, player )
{
    if ( level.roundstartexplosivedelay >= maps\mp\gametypes\_globallogic_utils::gettimepassed() / 1000 )
    {
        if ( isweapondisallowedatmatchstart( weapname ) || issubstr( weapname, "gl_" ) )
        {
            timeleft = int( level.roundstartexplosivedelay - maps\mp\gametypes\_globallogic_utils::gettimepassed() / 1000 );

            if ( !timeleft )
                timeleft = 1;

            if ( weapname == "explosive_bolt_mp" )
            {
                self makeallboltsdud();
                player iprintlnbold( &"MP_LAUNCHER_UNAVAILABLE_FOR_N", " " + timeleft + " ", &"EXE_SECONDS" );
            }
            else
            {
                if ( isthrowngrenade )
                    player iprintlnbold( &"MP_GRENADE_UNAVAILABLE_FOR_N", " " + timeleft + " ", &"EXE_SECONDS" );
                else
                    player iprintlnbold( &"MP_LAUNCHER_UNAVAILABLE_FOR_N", " " + timeleft + " ", &"EXE_SECONDS" );

                self makegrenadedud();
            }
        }
    }
}

watchforgrenadeduds()
{
    self endon( "spawned_player" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "grenade_fire", grenade, weapname );

        grenade turngrenadeintoadud( weapname, 1, self );
    }
}

watchforgrenadelauncherduds()
{
    self endon( "spawned_player" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "grenade_launcher_fire", grenade, weapname );

        grenade turngrenadeintoadud( weapname, 0, self );
/#
        assert( isdefined( grenade ) );
#/
        level.missileentities[level.missileentities.size] = grenade;
        grenade thread watchmissiledeath();
    }
}

getdamageableents( pos, radius, dolos, startradius )
{
    ents = [];

    if ( !isdefined( dolos ) )
        dolos = 0;

    if ( !isdefined( startradius ) )
        startradius = 0;

    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !isalive( players[i] ) || players[i].sessionstate != "playing" )
            continue;

        playerpos = players[i].origin + vectorscale( ( 0, 0, 1 ), 32.0 );
        distsq = distancesquared( pos, playerpos );

        if ( distsq < radius * radius && ( !dolos || weapondamagetracepassed( pos, playerpos, startradius, undefined ) ) )
        {
            newent = spawnstruct();
            newent.isplayer = 1;
            newent.isadestructable = 0;
            newent.isadestructible = 0;
            newent.isactor = 0;
            newent.entity = players[i];
            newent.damagecenter = playerpos;
            ents[ents.size] = newent;
        }
    }

    grenades = getentarray( "grenade", "classname" );

    for ( i = 0; i < grenades.size; i++ )
    {
        entpos = grenades[i].origin;
        distsq = distancesquared( pos, entpos );

        if ( distsq < radius * radius && ( !dolos || weapondamagetracepassed( pos, entpos, startradius, grenades[i] ) ) )
        {
            newent = spawnstruct();
            newent.isplayer = 0;
            newent.isadestructable = 0;
            newent.isadestructible = 0;
            newent.isactor = 0;
            newent.entity = grenades[i];
            newent.damagecenter = entpos;
            ents[ents.size] = newent;
        }
    }

    destructibles = getentarray( "destructible", "targetname" );

    for ( i = 0; i < destructibles.size; i++ )
    {
        entpos = destructibles[i].origin;
        distsq = distancesquared( pos, entpos );

        if ( distsq < radius * radius && ( !dolos || weapondamagetracepassed( pos, entpos, startradius, destructibles[i] ) ) )
        {
            newent = spawnstruct();
            newent.isplayer = 0;
            newent.isadestructable = 0;
            newent.isadestructible = 1;
            newent.isactor = 0;
            newent.entity = destructibles[i];
            newent.damagecenter = entpos;
            ents[ents.size] = newent;
        }
    }

    destructables = getentarray( "destructable", "targetname" );

    for ( i = 0; i < destructables.size; i++ )
    {
        entpos = destructables[i].origin;
        distsq = distancesquared( pos, entpos );

        if ( distsq < radius * radius && ( !dolos || weapondamagetracepassed( pos, entpos, startradius, destructables[i] ) ) )
        {
            newent = spawnstruct();
            newent.isplayer = 0;
            newent.isadestructable = 1;
            newent.isadestructible = 0;
            newent.isactor = 0;
            newent.entity = destructables[i];
            newent.damagecenter = entpos;
            ents[ents.size] = newent;
        }
    }

    dogs = maps\mp\killstreaks\_dogs::dog_manager_get_dogs();

    foreach ( dog in dogs )
    {
        if ( !isalive( dog ) )
            continue;

        entpos = dog.origin;
        distsq = distancesquared( pos, entpos );

        if ( distsq < radius * radius && ( !dolos || weapondamagetracepassed( pos, entpos, startradius, dog ) ) )
        {
            newent = spawnstruct();
            newent.isplayer = 0;
            newent.isadestructable = 0;
            newent.isadestructible = 0;
            newent.isactor = 1;
            newent.entity = dog;
            newent.damagecenter = entpos;
            ents[ents.size] = newent;
        }
    }

    return ents;
}

weapondamagetracepassed( from, to, startradius, ignore )
{
    trace = weapondamagetrace( from, to, startradius, ignore );
    return trace["fraction"] == 1;
}

weapondamagetrace( from, to, startradius, ignore )
{
    midpos = undefined;
    diff = to - from;

    if ( lengthsquared( diff ) < startradius * startradius )
        midpos = to;

    dir = vectornormalize( diff );
    midpos = from + ( dir[0] * startradius, dir[1] * startradius, dir[2] * startradius );
    trace = bullettrace( midpos, to, 0, ignore );

    if ( getdvarint( _hash_A1C40B1 ) != 0 )
    {
        if ( trace["fraction"] == 1 )
            thread debugline( midpos, to, ( 1, 1, 1 ) );
        else
        {
            thread debugline( midpos, trace["position"], ( 1, 0.9, 0.8 ) );
            thread debugline( trace["position"], to, ( 1, 0.4, 0.3 ) );
        }
    }

    return trace;
}

damageent( einflictor, eattacker, idamage, smeansofdeath, sweapon, damagepos, damagedir )
{
    if ( self.isplayer )
    {
        self.damageorigin = damagepos;
        self.entity thread [[ level.callbackplayerdamage ]]( einflictor, eattacker, idamage, 0, smeansofdeath, sweapon, damagepos, damagedir, "none", 0, 0 );
    }
    else if ( self.isactor )
    {
        self.damageorigin = damagepos;
        self.entity thread [[ level.callbackactordamage ]]( einflictor, eattacker, idamage, 0, smeansofdeath, sweapon, damagepos, damagedir, "none", 0, 0 );
    }
    else if ( self.isadestructible )
    {
        self.damageorigin = damagepos;
        self.entity dodamage( idamage, damagepos, eattacker, einflictor, 0, smeansofdeath, 0, sweapon );
    }
    else
    {
        if ( self.isadestructable && ( sweapon == "claymore_mp" || sweapon == "airstrike_mp" ) )
            return;

        self.entity damage_notify_wrapper( idamage, eattacker, ( 0, 0, 0 ), ( 0, 0, 0 ), "mod_explosive", "", "" );
    }
}

debugline( a, b, color )
{
/#
    for ( i = 0; i < 600; i++ )
    {
        line( a, b, color );
        wait 0.05;
    }
#/
}

onweapondamage( eattacker, einflictor, sweapon, meansofdeath, damage )
{
    self endon( "death" );
    self endon( "disconnect" );

    switch ( sweapon )
    {
        case "concussion_grenade_mp":
            radius = 512;

            if ( self == eattacker )
                radius *= 0.5;

            scale = 1 - distance( self.origin, einflictor.origin ) / radius;

            if ( scale < 0 )
                scale = 0;

            time = 2 + 4 * scale;
            wait 0.05;

            if ( self hasperk( "specialty_stunprotection" ) )
                time *= 0.1;

            self thread playconcussionsound( time );

            if ( self mayapplyscreeneffect() )
                self shellshock( "concussion_grenade_mp", time, 0 );

            self.concussionendtime = gettime() + time * 1000;
            self.lastconcussedby = eattacker;
            break;
        case "proximity_grenade_mp":
            self proximitygrenadedamageplayer( eattacker, einflictor );
            break;
        default:
            maps\mp\gametypes\_shellshock::shellshockondamage( meansofdeath, damage );
            break;
    }
}

playconcussionsound( duration )
{
    self endon( "death" );
    self endon( "disconnect" );
    concussionsound = spawn( "script_origin", ( 0, 0, 1 ) );
    concussionsound.origin = self.origin;
    concussionsound linkto( self );
    concussionsound thread deleteentonownerdeath( self );
    concussionsound playsound( "" );
    concussionsound playloopsound( "" );

    if ( duration > 0.5 )
        wait( duration - 0.5 );

    concussionsound playsound( "" );
    concussionsound stoploopsound( 0.5 );
    wait 0.5;
    concussionsound notify( "delete" );
    concussionsound delete();
}

deleteentonownerdeath( owner )
{
    self endon( "delete" );

    owner waittill( "death" );

    self delete();
}

monitor_dog_special_grenades()
{
    self endon( "death" );

    while ( true )
    {
        self waittill( "damage", damage, attacker, direction_vec, point, type, modelname, tagname, partname, weaponname, idflags );

        if ( isflashorstunweapon( weaponname ) )
        {
            damage_area = spawn( "trigger_radius", self.origin, 0, 128, 128 );
            attacker thread maps\mp\killstreaks\_dogs::flash_dogs( damage_area );
            wait 0.05;
            damage_area delete();
        }
    }
}

isprimaryweapon( weaponname )
{
    return isdefined( level.primary_weapon_array[weaponname] );
}

issidearm( weaponname )
{
    return isdefined( level.side_arm_array[weaponname] );
}

isinventory( weaponname )
{
    return isdefined( level.inventory_array[weaponname] );
}

isgrenade( weaponname )
{
    return isdefined( level.grenade_array[weaponname] );
}

isexplosivebulletweapon( weaponname )
{
    if ( weaponname == "chopper_minigun_mp" || weaponname == "cobra_20mm_mp" || weaponname == "littlebird_guard_minigun_mp" || weaponname == "cobra_20mm_comlink_mp" )
        return true;

    return false;
}

getweaponclass_array( current )
{
    if ( isprimaryweapon( current ) )
        return level.primary_weapon_array;
    else if ( issidearm( current ) )
        return level.side_arm_array;
    else if ( isgrenade( current ) )
        return level.grenade_array;
    else
        return level.inventory_array;
}

updatestowedweapon()
{
    self endon( "spawned" );
    self endon( "killed_player" );
    self endon( "disconnect" );
    self.tag_stowed_back = undefined;
    self.tag_stowed_hip = undefined;
    team = self.pers["team"];
    class = self.pers["class"];

    while ( true )
    {
        self waittill( "weapon_change", newweapon );

        if ( self ismantling() )
            continue;

        currentstowed = self getstowedweapon();
        hasstowed = 0;
        self.weapon_array_primary = [];
        self.weapon_array_sidearm = [];
        self.weapon_array_grenade = [];
        self.weapon_array_inventory = [];
        weaponslist = self getweaponslist();

        for ( idx = 0; idx < weaponslist.size; idx++ )
        {
            switch ( weaponslist[idx] )
            {
                case "minigun_mp":
                case "m32_mp":
                    continue;
                default:
                    break;
            }

            if ( !hasstowed || currentstowed == weaponslist[idx] )
            {
                currentstowed = weaponslist[idx];
                hasstowed = 1;
            }

            if ( isprimaryweapon( weaponslist[idx] ) )
            {
                self.weapon_array_primary[self.weapon_array_primary.size] = weaponslist[idx];
                continue;
            }

            if ( issidearm( weaponslist[idx] ) )
            {
                self.weapon_array_sidearm[self.weapon_array_sidearm.size] = weaponslist[idx];
                continue;
            }

            if ( isgrenade( weaponslist[idx] ) )
            {
                self.weapon_array_grenade[self.weapon_array_grenade.size] = weaponslist[idx];
                continue;
            }

            if ( isinventory( weaponslist[idx] ) )
            {
                self.weapon_array_inventory[self.weapon_array_inventory.size] = weaponslist[idx];
                continue;
            }

            if ( isweaponprimary( weaponslist[idx] ) )
                self.weapon_array_primary[self.weapon_array_primary.size] = weaponslist[idx];
        }

        if ( newweapon != "none" || !hasstowed )
        {
            detach_all_weapons();
            stow_on_back();
            stow_on_hip();
        }
    }
}

forcestowedweaponupdate()
{
    detach_all_weapons();
    stow_on_back();
    stow_on_hip();
}

detachcarryobjectmodel()
{
    if ( isdefined( self.carryobject ) && isdefined( self.carryobject maps\mp\gametypes\_gameobjects::getvisiblecarriermodel() ) )
    {
        if ( isdefined( self.tag_stowed_back ) )
        {
            self detach( self.tag_stowed_back, "tag_stowed_back" );
            self.tag_stowed_back = undefined;
        }
    }
}

detach_all_weapons()
{
    if ( isdefined( self.tag_stowed_back ) )
    {
        clear_weapon = 1;

        if ( isdefined( self.carryobject ) )
        {
            carriermodel = self.carryobject maps\mp\gametypes\_gameobjects::getvisiblecarriermodel();

            if ( isdefined( carriermodel ) && carriermodel == self.tag_stowed_back )
            {
                self detach( self.tag_stowed_back, "tag_stowed_back" );
                clear_weapon = 0;
            }
        }

        if ( clear_weapon )
            self clearstowedweapon();

        self.tag_stowed_back = undefined;
    }

    if ( isdefined( self.tag_stowed_hip ) )
    {
        detach_model = getweaponmodel( self.tag_stowed_hip );
        self detach( detach_model, "tag_stowed_hip_rear" );
        self.tag_stowed_hip = undefined;
    }
}

non_stowed_weapon( weapon )
{
    if ( self hasweapon( "knife_ballistic_mp" ) && weapon != "knife_ballistic_mp" )
        return true;

    if ( self hasweapon( "knife_held_mp" ) && weapon != "knife_held_mp" )
        return true;

    return false;
}

stow_on_back( current )
{
    current = self getcurrentweapon();
    currentalt = self getcurrentweaponaltweapon();
    self.tag_stowed_back = undefined;
    weaponoptions = 0;
    index_weapon = "";

    if ( isdefined( self.carryobject ) && isdefined( self.carryobject maps\mp\gametypes\_gameobjects::getvisiblecarriermodel() ) )
    {
        self.tag_stowed_back = self.carryobject maps\mp\gametypes\_gameobjects::getvisiblecarriermodel();
        self attach( self.tag_stowed_back, "tag_stowed_back", 1 );
        return;
    }
    else if ( non_stowed_weapon( current ) )
        return;
    else if ( current != "none" )
    {
        for ( idx = 0; idx < self.weapon_array_primary.size; idx++ )
        {
            temp_index_weapon = self.weapon_array_primary[idx];
/#
            assert( isdefined( temp_index_weapon ), "Primary weapon list corrupted." );
#/

            if ( temp_index_weapon == current )
                continue;

            if ( temp_index_weapon == currentalt )
                continue;

            index_weapon = temp_index_weapon;
/#
            assert( isdefined( self.curclass ), "Player missing current class" );
#/

            if ( issubstr( index_weapon, self.pers["primaryWeapon"] ) && issubstr( self.curclass, "CUSTOM" ) )
                self.tag_stowed_back = getweaponmodel( index_weapon );
            else
            {
                stowedmodelindex = getweaponstowedmodel( index_weapon );
                self.tag_stowed_back = getweaponmodel( index_weapon, stowedmodelindex );
            }

            if ( issubstr( self.curclass, "CUSTOM" ) )
                weaponoptions = self calcweaponoptions( self.class_num, 0 );
        }
    }

    if ( !isdefined( self.tag_stowed_back ) )
        return;

    self setstowedweapon( index_weapon );
}

stow_on_hip()
{
    current = self getcurrentweapon();
    self.tag_stowed_hip = undefined;

    for ( idx = 0; idx < self.weapon_array_inventory.size; idx++ )
    {
        if ( self.weapon_array_inventory[idx] == current )
            continue;

        if ( !self getweaponammostock( self.weapon_array_inventory[idx] ) )
            continue;

        self.tag_stowed_hip = self.weapon_array_inventory[idx];
    }

    if ( !isdefined( self.tag_stowed_hip ) )
        return;

    if ( self.tag_stowed_hip == "satchel_charge_mp" || self.tag_stowed_hip == "claymore_mp" || self.tag_stowed_hip == "bouncingbetty_mp" )
    {
        self.tag_stowed_hip = undefined;
        return;
    }

    weapon_model = getweaponmodel( self.tag_stowed_hip );
    self attach( weapon_model, "tag_stowed_hip_rear", 1 );
}

stow_inventory( inventories, current )
{
    if ( isdefined( self.inventory_tag ) )
    {
        detach_model = getweaponmodel( self.inventory_tag );
        self detach( detach_model, "tag_stowed_hip_rear" );
        self.inventory_tag = undefined;
    }

    if ( !isdefined( inventories[0] ) || self getweaponammostock( inventories[0] ) == 0 )
        return;

    if ( inventories[0] != current )
    {
        self.inventory_tag = inventories[0];
        weapon_model = getweaponmodel( self.inventory_tag );
        self attach( weapon_model, "tag_stowed_hip_rear", 1 );
    }
}

weapons_get_dvar_int( dvar, def )
{
    return int( weapons_get_dvar( dvar, def ) );
}

weapons_get_dvar( dvar, def )
{
    if ( getdvar( dvar ) != "" )
        return getdvarfloat( dvar );
    else
    {
        setdvar( dvar, def );
        return def;
    }
}

player_is_driver()
{
    if ( !isalive( self ) )
        return false;

    if ( self isremotecontrolling() )
        return false;

    vehicle = self getvehicleoccupied();

    if ( isdefined( vehicle ) )
    {
        seat = vehicle getoccupantseat( self );

        if ( isdefined( seat ) && seat == 0 )
            return true;
    }

    return false;
}

loadout_get_offhand_weapon( stat )
{
    if ( isdefined( level.givecustomloadout ) )
        return "weapon_null_mp";

/#
    assert( isdefined( self.class_num ) );
#/

    if ( isdefined( self.class_num ) )
    {
        index = self maps\mp\gametypes\_class::getloadoutitemfromddlstats( self.class_num, stat );

        if ( isdefined( level.tbl_weaponids[index] ) && isdefined( level.tbl_weaponids[index]["reference"] ) )
            return level.tbl_weaponids[index]["reference"] + "_mp";
    }

    return "weapon_null_mp";
}

loadout_get_offhand_count( stat )
{
    count = 0;

    if ( isdefined( level.givecustomloadout ) )
        return 0;

/#
    assert( isdefined( self.class_num ) );
#/

    if ( isdefined( self.class_num ) )
        count = self maps\mp\gametypes\_class::getloadoutitemfromddlstats( self.class_num, stat );

    return count;
}

scavenger_think()
{
    self endon( "death" );

    self waittill( "scavenger", player );

    primary_weapons = player getweaponslistprimaries();
    offhand_weapons_and_alts = array_exclude( player getweaponslist( 1 ), primary_weapons );
    arrayremovevalue( offhand_weapons_and_alts, "knife_mp" );
    offhand_weapons_and_alts = array_reverse( offhand_weapons_and_alts );
    player playsound( "fly_equipment_pickup_npc" );
    player playlocalsound( "fly_equipment_pickup_plr" );
    player.scavenger_icon.alpha = 1;
    player.scavenger_icon fadeovertime( 2.5 );
    player.scavenger_icon.alpha = 0;
    loadout_primary = player loadout_get_offhand_weapon( "primarygrenade" );
    loadout_primary_count = player loadout_get_offhand_count( "primarygrenadecount" );
    loadout_secondary = player loadout_get_offhand_weapon( "specialgrenade" );
    loadout_secondary_count = player loadout_get_offhand_count( "specialgrenadeCount" );

    for ( i = 0; i < offhand_weapons_and_alts.size; i++ )
    {
        weapon = offhand_weapons_and_alts[i];

        if ( ishackweapon( weapon ) )
            continue;

        switch ( weapon )
        {
            case "satchel_charge_mp":
                if ( player maps\mp\gametypes\_weaponobjects::anyobjectsinworld( weapon ) )
                    continue;
            case "sticky_grenade_mp":
            case "hatchet_mp":
            case "frag_grenade_mp":
            case "claymore_mp":
            case "bouncingbetty_mp":
                if ( isdefined( player.grenadetypeprimarycount ) && player.grenadetypeprimarycount < 1 )
                    continue;
            case "willy_pete_mp":
            case "trophy_system_mp":
            case "tabun_gas_mp":
            case "sensor_grenade_mp":
            case "proximity_grenade_mp":
            case "pda_hack_mp":
            case "nightingale_mp":
            case "flash_grenade_mp":
            case "emp_grenade_mp":
            case "concussion_grenade_mp":
                if ( isdefined( player.grenadetypesecondarycount ) && player.grenadetypesecondarycount < 1 )
                    continue;

                maxammo = weaponmaxammo( weapon );
                stock = player getweaponammostock( weapon );

                if ( isdefined( level.customloadoutscavenge ) )
                    maxammo = self [[ level.customloadoutscavenge ]]( weapon );
                else if ( weapon == loadout_primary )
                    maxammo = loadout_primary_count;
                else if ( weapon == loadout_secondary )
                    maxammo = loadout_secondary_count;

                if ( stock < maxammo )
                {
                    ammo = stock + 1;

                    if ( ammo > maxammo )
                        ammo = maxammo;

                    player setweaponammostock( weapon, ammo );
                    player.scavenged = 1;
                    player thread maps\mp\_challenges::scavengedgrenade();
                }

                continue;
        }
    }

    for ( i = 0; i < primary_weapons.size; i++ )
    {
        weapon = primary_weapons[i];

        if ( ishackweapon( weapon ) )
            continue;

        stock = player getweaponammostock( weapon );
        start = player getfractionstartammo( weapon );
        clip = weaponclipsize( weapon );
        clip *= getdvarfloatdefault( "scavenger_clip_multiplier", 1 );
        clip = int( clip );
        maxammo = weaponmaxammo( weapon );

        if ( stock < maxammo - clip )
        {
            ammo = stock + clip;
            player setweaponammostock( weapon, ammo );
            player.scavenged = 1;
            exit_early = 1;
            continue;
        }

        player setweaponammostock( weapon, maxammo );
        player.scavenged = 1;
        exit_early = 1;
    }
}

scavenger_hud_create()
{
    if ( level.wagermatch )
        return;

    self.scavenger_icon = newclienthudelem( self );
    self.scavenger_icon.horzalign = "center";
    self.scavenger_icon.vertalign = "middle";
    self.scavenger_icon.alpha = 0;
    width = 48;
    height = 24;

    if ( level.splitscreen )
    {
        width = int( width * 0.5 );
        height = int( height * 0.5 );
    }

    self.scavenger_icon.x = width * -1 / 2;
    self.scavenger_icon.y = 16;
    self.scavenger_icon setshader( "hud_scavenger_pickup", width, height );
}

dropscavengerfordeath( attacker )
{
    if ( sessionmodeiszombiesgame() )
        return;

    if ( level.wagermatch )
        return;

    if ( !isdefined( attacker ) )
        return;

    if ( attacker == self )
        return;

    if ( level.gametype == "hack" )
        item = self dropscavengeritem( "scavenger_item_hack_mp" );
    else if ( isplayer( attacker ) && attacker hasperk( "specialty_scavenger" ) )
        item = self dropscavengeritem( "scavenger_item_mp" );
    else
        return;

    item thread scavenger_think();
}

addlimitedweapon( weapon_name, owner, num_drops )
{
    limited_info = spawnstruct();
    limited_info.weapon = weapon_name;
    limited_info.drops = num_drops;
    owner.limited_info = limited_info;
}

shoulddroplimitedweapon( weapon_name, owner )
{
    limited_info = owner.limited_info;

    if ( !isdefined( limited_info ) )
        return true;

    if ( limited_info.weapon != weapon_name )
        return true;

    if ( limited_info.drops <= 0 )
        return false;

    return true;
}

droplimitedweapon( weapon_name, owner, item )
{
    limited_info = owner.limited_info;

    if ( !isdefined( limited_info ) )
        return;

    if ( limited_info.weapon != weapon_name )
        return;

    limited_info.drops -= 1;
    owner.limited_info = undefined;
    item thread limitedpickup( limited_info );
}

limitedpickup( limited_info )
{
    self endon( "death" );

    self waittill( "trigger", player, item );

    if ( !isdefined( item ) )
        return;

    player.limited_info = limited_info;
}
