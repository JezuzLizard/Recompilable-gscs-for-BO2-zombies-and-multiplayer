#include maps/mp/gametypes_zm/_rank;
#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/_utility;

init()
{
	precachestring( &"open_ingame_menu" );
	game[ "menu_team" ] = "team_marinesopfor";
	game[ "menu_initteam_allies" ] = "initteam_marines";
	game[ "menu_initteam_axis" ] = "initteam_opfor";
	game[ "menu_class" ] = "class";
	game[ "menu_changeclass" ] = "changeclass";
	game[ "menu_changeclass_offline" ] = "changeclass";
	game[ "menu_wager_side_bet" ] = "sidebet";
	game[ "menu_wager_side_bet_player" ] = "sidebet_player";
	game[ "menu_changeclass_wager" ] = "changeclass_wager";
	game[ "menu_changeclass_custom" ] = "changeclass_custom";
	game[ "menu_changeclass_barebones" ] = "changeclass_barebones";
	_a18 = level.teams;
	_k18 = getFirstArrayKey( _a18 );
	while ( isDefined( _k18 ) )
	{
		team = _a18[ _k18 ];
		game[ "menu_changeclass_" + team ] = "changeclass";
		_k18 = getNextArrayKey( _a18, _k18 );
	}
	game[ "menu_controls" ] = "ingame_controls";
	game[ "menu_options" ] = "ingame_options";
	game[ "menu_leavegame" ] = "popup_leavegame";
	precachemenu( game[ "menu_controls" ] );
	precachemenu( game[ "menu_options" ] );
	precachemenu( game[ "menu_leavegame" ] );
	precachemenu( "scoreboard" );
	precachemenu( "spectate" );
	precachemenu( game[ "menu_team" ] );
	precachemenu( game[ "menu_changeclass_allies" ] );
	precachemenu( game[ "menu_initteam_allies" ] );
	precachemenu( game[ "menu_changeclass_axis" ] );
	precachemenu( game[ "menu_class" ] );
	precachemenu( game[ "menu_changeclass" ] );
	precachemenu( game[ "menu_initteam_axis" ] );
	precachemenu( game[ "menu_changeclass_offline" ] );
	precachemenu( game[ "menu_changeclass_wager" ] );
	precachemenu( game[ "menu_changeclass_custom" ] );
	precachemenu( game[ "menu_changeclass_barebones" ] );
	precachemenu( game[ "menu_wager_side_bet" ] );
	precachemenu( game[ "menu_wager_side_bet_player" ] );
	precachestring( &"MP_HOST_ENDED_GAME" );
	precachestring( &"MP_HOST_ENDGAME_RESPONSE" );
	level thread onplayerconnect();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onmenuresponse();
	}
}

onmenuresponse()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "menuresponse", menu, response );
		if ( response == "back" )
		{
			self closemenu();
			self closeingamemenu();
			if ( level.console )
			{
				if ( game[ "menu_changeclass" ] != menu && game[ "menu_changeclass_offline" ] != menu || menu == game[ "menu_team" ] && menu == game[ "menu_controls" ] )
				{
					if ( isDefined( level.teams[ self.pers[ "team" ] ] ) )
					{
						self openmenu( game[ "menu_class" ] );
					}
				}
			}
			continue;
		}
		else if ( response == "changeteam" && level.allow_teamchange == "1" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_team" ] );
		}
		if ( response == "changeclass_marines_splitscreen" )
		{
			self openmenu( "changeclass_marines_splitscreen" );
		}
		if ( response == "changeclass_opfor_splitscreen" )
		{
			self openmenu( "changeclass_opfor_splitscreen" );
		}
		if ( response == "endgame" )
		{
			if ( self issplitscreen() )
			{
				level.skipvote = 1;
				if ( !level.gameended )
				{
					level thread maps/mp/gametypes_zm/_globallogic::forceend();
				}
			}
			continue;
		}
		else if ( response == "killserverpc" )
		{
			level thread maps/mp/gametypes_zm/_globallogic::killserverpc();
			continue;
		}
		else if ( response == "endround" )
		{
			if ( !level.gameended )
			{
				level thread maps/mp/gametypes_zm/_globallogic::forceend();
			}
			else
			{
				self closemenu();
				self closeingamemenu();
				self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
			}
			continue;
		}
		else if ( menu == game[ "menu_team" ] && level.allow_teamchange == "1" )
		{
			switch( response )
			{
				case "autoassign":
					self [[ level.autoassign ]]( 1 );
					break;
				case "spectator":
					self [[ level.spectator ]]();
					break;
				default:
					self [[ level.teammenu ]]( response );
					break;
			}
			continue;
		}
		else
		{
			if ( game[ "menu_changeclass" ] != menu && game[ "menu_changeclass_offline" ] != menu && game[ "menu_changeclass_wager" ] != menu || menu == game[ "menu_changeclass_custom" ] && menu == game[ "menu_changeclass_barebones" ] )
			{
				self closemenu();
				self closeingamemenu();
				if ( level.rankedmatch && issubstr( response, "custom" ) )
				{
					if ( self isitemlocked( maps/mp/gametypes_zm/_rank::getitemindex( "feature_cac" ) ) )
					{
						kick( self getentitynumber() );
					}
				}
				self.selectedclass = 1;
				self [[ level.class ]]( response );
				break;
			}
			else
			{
				if ( menu == "spectate" )
				{
					player = getplayerfromclientnum( int( response ) );
					if ( isDefined( player ) )
					{
						self setcurrentspectatorclient( player );
					}
				}
			}
		}
	}
}
