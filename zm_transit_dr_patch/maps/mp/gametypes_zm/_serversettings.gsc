
init()
{
	level.hostname = getDvar( "sv_hostname" );
	if ( level.hostname == "" )
	{
		level.hostname = "CoDHost";
	}
	setdvar( "sv_hostname", level.hostname );
	setdvar( "ui_hostname", level.hostname );
	makedvarserverinfo( "ui_hostname", "CoDHost" );
	level.motd = getDvar( "scr_motd" );
	if ( level.motd == "" )
	{
		level.motd = "";
	}
	setdvar( "scr_motd", level.motd );
	setdvar( "ui_motd", level.motd );
	makedvarserverinfo( "ui_motd", "" );
	level.allowvote = getDvar( "g_allowVote" );
	if ( level.allowvote == "" )
	{
		level.allowvote = "1";
	}
	setdvar( "g_allowvote", level.allowvote );
	setdvar( "ui_allowvote", level.allowvote );
	makedvarserverinfo( "ui_allowvote", "1" );
	level.allow_teamchange = "0";
	if ( sessionmodeisprivate() || !sessionmodeisonlinegame() )
	{
		level.allow_teamchange = "1";
	}
	setdvar( "ui_allow_teamchange", level.allow_teamchange );
	level.friendlyfire = getgametypesetting( "friendlyfiretype" );
	setdvar( "ui_friendlyfire", level.friendlyfire );
	makedvarserverinfo( "ui_friendlyfire", "0" );
	if ( getDvar( "scr_mapsize" ) == "" )
	{
		setdvar( "scr_mapsize", "64" );
	}
	else if ( getDvarFloat( "scr_mapsize" ) >= 64 )
	{
		setdvar( "scr_mapsize", "64" );
	}
	else if ( getDvarFloat( "scr_mapsize" ) >= 32 )
	{
		setdvar( "scr_mapsize", "32" );
	}
	else if ( getDvarFloat( "scr_mapsize" ) >= 16 )
	{
		setdvar( "scr_mapsize", "16" );
	}
	else
	{
		setdvar( "scr_mapsize", "8" );
	}
	level.mapsize = getDvarFloat( "scr_mapsize" );
	constraingametype( getDvar( "g_gametype" ) );
	constrainmapsize( level.mapsize );
	for ( ;; )
	{
		updateserversettings();
		wait 5;
	}
}

updateserversettings()
{
	sv_hostname = getDvar( "sv_hostname" );
	if ( level.hostname != sv_hostname )
	{
		level.hostname = sv_hostname;
		setdvar( "ui_hostname", level.hostname );
	}
	scr_motd = getDvar( "scr_motd" );
	if ( level.motd != scr_motd )
	{
		level.motd = scr_motd;
		setdvar( "ui_motd", level.motd );
	}
	g_allowvote = getDvar( "g_allowVote" );
	if ( level.allowvote != g_allowvote )
	{
		level.allowvote = g_allowvote;
		setdvar( "ui_allowvote", level.allowvote );
	}
	scr_friendlyfire = getgametypesetting( "friendlyfiretype" );
	if ( level.friendlyfire != scr_friendlyfire )
	{
		level.friendlyfire = scr_friendlyfire;
		setdvar( "ui_friendlyfire", level.friendlyfire );
	}
}

constraingametype( gametype )
{
	entities = getentarray();
	i = 0;
	while ( i < entities.size )
	{
		entity = entities[ i ];
		if ( gametype == "dm" )
		{
			if ( isDefined( entity.script_gametype_dm ) && entity.script_gametype_dm != "1" )
			{
				entity delete();
			}
			i++;
			continue;
		}
		else if ( gametype == "tdm" )
		{
			if ( isDefined( entity.script_gametype_tdm ) && entity.script_gametype_tdm != "1" )
			{
				entity delete();
			}
			i++;
			continue;
		}
		else if ( gametype == "ctf" )
		{
			if ( isDefined( entity.script_gametype_ctf ) && entity.script_gametype_ctf != "1" )
			{
				entity delete();
			}
			i++;
			continue;
		}
		else if ( gametype == "hq" )
		{
			if ( isDefined( entity.script_gametype_hq ) && entity.script_gametype_hq != "1" )
			{
				entity delete();
			}
			i++;
			continue;
		}
		else if ( gametype == "sd" )
		{
			if ( isDefined( entity.script_gametype_sd ) && entity.script_gametype_sd != "1" )
			{
				entity delete();
			}
			i++;
			continue;
		}
		else
		{
			if ( gametype == "koth" )
			{
				if ( isDefined( entity.script_gametype_koth ) && entity.script_gametype_koth != "1" )
				{
					entity delete();
				}
			}
		}
		i++;
	}
}

constrainmapsize( mapsize )
{
	entities = getentarray();
	i = 0;
	while ( i < entities.size )
	{
		entity = entities[ i ];
		if ( int( mapsize ) == 8 )
		{
			if ( isDefined( entity.script_mapsize_08 ) && entity.script_mapsize_08 != "1" )
			{
				entity delete();
			}
			i++;
			continue;
		}
		else if ( int( mapsize ) == 16 )
		{
			if ( isDefined( entity.script_mapsize_16 ) && entity.script_mapsize_16 != "1" )
			{
				entity delete();
			}
			i++;
			continue;
		}
		else if ( int( mapsize ) == 32 )
		{
			if ( isDefined( entity.script_mapsize_32 ) && entity.script_mapsize_32 != "1" )
			{
				entity delete();
			}
			i++;
			continue;
		}
		else
		{
			if ( int( mapsize ) == 64 )
			{
				if ( isDefined( entity.script_mapsize_64 ) && entity.script_mapsize_64 != "1" )
				{
					entity delete();
				}
			}
		}
		i++;
	}
}
