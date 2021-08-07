//Treyarch only creates up to 8 values for "zombie_score_start_numplayersp" so for games of more than 8 players the initial score for powerups to drop a powerup will be lower than default

_zm::init_player_levelvars() 
{
	flag_wait( "start_zombie_round_logic" );
	difficulty = 1;
	column = int( difficulty ) + 1;
	for ( i = 0; i < 8; i++ )
	{
		points = 500;
		if ( i > 3 )
		{
			points = 3000;
		}
		points = set_zombie_var( "zombie_score_start_" + i + 1 + "p", points, 0, column );
	}
}

_zm_powerups::watch_for_drop() 
{
	flag_wait( "start_zombie_round_logic" );
	flag_wait( "begin_spawning" );
	players = get_players();
	score_to_drop = ( players.size * level.zombie_vars[ "zombie_score_start_" + players.size + "p" ] ) + level.zombie_vars[ "zombie_powerup_drop_increment" ];
	while ( 1 )
	{
		flag_wait( "zombie_drop_powerups" );
		players = get_players();
		curr_total_score = 0;
		for ( i = 0; i < players.size; i++ )
		{
			if ( isDefined( players[ i ].score_total ) )
			{
				curr_total_score += players[ i ].score_total;
			}
		}
		if ( curr_total_score > score_to_drop )
		{
			level.zombie_vars[ "zombie_powerup_drop_increment" ] *= 1.14;
			score_to_drop = curr_total_score + level.zombie_vars[ "zombie_powerup_drop_increment" ];
			level.zombie_vars[ "zombie_drop_item" ] = 1;
		}
		wait 0.5;
	}
	
}

_zm_utility::is_zombie_perk_bottle( str_weapon ) //optimized
{
    return isSubStr( str_weapon, "zombie_perk_bottle_" );
}