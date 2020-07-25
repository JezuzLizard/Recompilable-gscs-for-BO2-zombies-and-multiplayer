#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/_ambientpackage;

main()
{
	level thread sndmusicegg();
}

sndmusicegg()
{
	origins = [];
	origins[ 0 ] = ( 2724, 300, 1347 );
	origins[ 1 ] = ( 2639, 1831, 1359 );
	origins[ 2 ] = ( 1230, 1846, 3249 );
	level.meteor_counter = 0;
	level.music_override = 0;
	i = 0;
	while ( i < origins.size )
	{
		level thread sndmusicegg_wait( origins[ i ] );
		i++;
	}
}

sndmusicegg_wait( bear_origin )
{
	temp_ent = spawn( "script_origin", bear_origin );
	temp_ent playloopsound( "zmb_meteor_loop" );
	temp_ent thread maps/mp/zombies/_zm_sidequests::fake_use( "main_music_egg_hit", ::sndmusicegg_override );
	temp_ent waittill( "main_music_egg_hit", player );
	temp_ent stoploopsound( 1 );
	player playsound( "zmb_meteor_activate" );
	level.meteor_counter += 1;
	if ( level.meteor_counter == 3 )
	{
		level thread sndmuseggplay( temp_ent, "mus_zmb_secret_song", 190 );
	}
	else
	{
		wait 1,5;
		temp_ent delete();
	}
}

sndmusicegg_override()
{
	if ( is_true( level.music_override ) )
	{
		return 0;
	}
	return 1;
}

sndmuseggplay( ent, alias, time )
{
	level.music_override = 1;
	wait 1;
	ent playsound( alias );
	level thread sndeggmusicwait( time );
	level waittill_either( "end_game", "sndSongDone" );
	ent stopsounds();
	wait 0,05;
	ent delete();
	level.music_override = 0;
}

sndeggmusicwait( time )
{
	level endon( "end_game" );
	wait time;
	level notify( "sndSongDone" );
}
