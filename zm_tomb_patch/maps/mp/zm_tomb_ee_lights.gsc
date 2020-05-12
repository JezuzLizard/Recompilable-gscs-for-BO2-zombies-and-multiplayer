#include maps/mp/zm_tomb_quest_crypt;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

main()
{
	registerclientfield( "world", "light_show", 14000, 2, "int" );
	flag_init( "show_morse_code" );
	init_morse_code();
	flag_wait( "start_zombie_round_logic" );
	chamber_discs = getentarray( "crypt_puzzle_disc", "script_noteworthy" );
	lit_discs = [];
	_a24 = chamber_discs;
	_k24 = getFirstArrayKey( _a24 );
	while ( isDefined( _k24 ) )
	{
		disc = _a24[ _k24 ];
		if ( isDefined( disc.script_int ) )
		{
			lit_discs[ disc.script_int - 1 ] = disc;
		}
		_k24 = getNextArrayKey( _a24, _k24 );
	}
	flag_wait_any( "ee_all_staffs_upgraded", "show_morse_code" );
	while ( 1 )
	{
		setclientfield( "light_show", 1 );
		if ( randomint( 100 ) < 10 )
		{
			turn_all_lights_off( lit_discs );
			wait 10;
			setclientfield( "light_show", 3 );
			light_show_morse( lit_discs, "GIOVAN BATTISTA BELLASO" );
			setclientfield( "light_show", 1 );
		}
		turn_all_lights_off( lit_discs );
		wait 10;
		setclientfield( "light_show", 2 );
		light_show_morse( lit_discs, level.cipher_key );
		_a56 = level.morse_messages;
		_k56 = getFirstArrayKey( _a56 );
		while ( isDefined( _k56 ) )
		{
			message = _a56[ _k56 ];
			setclientfield( "light_show", 1 );
			cipher = phrase_convert_to_cipher( message, level.cipher_key );
			turn_all_lights_off( lit_discs );
			wait 10;
			light_show_morse( lit_discs, cipher );
			_k56 = getNextArrayKey( _a56, _k56 );
		}
	}
}

init_morse_code()
{
	level.morse_letters = [];
	level.morse_letters[ "A" ] = ".-";
	level.morse_letters[ "B" ] = "-...";
	level.morse_letters[ "C" ] = "-.-.";
	level.morse_letters[ "D" ] = "-..";
	level.morse_letters[ "E" ] = ".";
	level.morse_letters[ "F" ] = "..-.";
	level.morse_letters[ "G" ] = "--.";
	level.morse_letters[ "H" ] = "....";
	level.morse_letters[ "I" ] = "..";
	level.morse_letters[ "J" ] = ".---";
	level.morse_letters[ "K" ] = "-.-";
	level.morse_letters[ "L" ] = ".-..";
	level.morse_letters[ "M" ] = "--";
	level.morse_letters[ "N" ] = "-.";
	level.morse_letters[ "O" ] = "---";
	level.morse_letters[ "P" ] = ".--.";
	level.morse_letters[ "Q" ] = "--.-";
	level.morse_letters[ "R" ] = ".-.";
	level.morse_letters[ "S" ] = "...";
	level.morse_letters[ "T" ] = "-";
	level.morse_letters[ "U" ] = "..-";
	level.morse_letters[ "V" ] = "...-";
	level.morse_letters[ "W" ] = ".--";
	level.morse_letters[ "X" ] = "-..-";
	level.morse_letters[ "Y" ] = "-.--";
	level.morse_letters[ "Z" ] = "--..";
	level.morse_messages = [];
	level.morse_messages[ 0 ] = "WARN MESSINES";
	level.morse_messages[ 1 ] = "SOMETHING BLUE IN THE EARTH";
	level.morse_messages[ 2 ] = "NOT CLAY";
	level.morse_messages[ 3 ] = "WE GREW WEAK";
	level.morse_messages[ 4 ] = "THOUGHT IT WAS FLU";
	level.morse_messages[ 5 ] = "MEN BECAME BEASTS";
	level.morse_messages[ 6 ] = "BLOOD TURNED TO ASH";
	level.morse_messages[ 7 ] = "LIBERATE TUTE DE INFERNIS";
	level.cipher_key = "INFERNO";
}

turn_all_lights_off( a_discs )
{
	_a114 = a_discs;
	_k114 = getFirstArrayKey( _a114 );
	while ( isDefined( _k114 ) )
	{
		disc = _a114[ _k114 ];
		disc maps/mp/zm_tomb_quest_crypt::bryce_cake_light_update( 0 );
		_k114 = getNextArrayKey( _a114, _k114 );
	}
}

turn_all_lights_on( a_discs )
{
	_a122 = a_discs;
	_k122 = getFirstArrayKey( _a122 );
	while ( isDefined( _k122 ) )
	{
		disc = _a122[ _k122 ];
		disc maps/mp/zm_tomb_quest_crypt::bryce_cake_light_update( 1 );
		_k122 = getNextArrayKey( _a122, _k122 );
	}
}

phrase_convert_to_cipher( str_phrase, str_key )
{
	alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	alphabet_vals = [];
	num = 0;
	i = 0;
	while ( i < alphabet.size )
	{
		letter = alphabet[ i ];
		alphabet_vals[ letter ] = num;
		num++;
		i++;
	}
	encrypted_phrase = [];
	j = 0;
	i = 0;
	while ( i < str_phrase.size )
	{
		cipher_letter = str_key[ j % str_key.size ];
		original_letter = str_phrase[ i ];
		n_original_letter = alphabet_vals[ original_letter ];
		if ( !isDefined( n_original_letter ) )
		{
			encrypted_phrase[ encrypted_phrase.size ] = original_letter;
			i++;
			continue;
		}
		else
		{
			n_cipher_offset = alphabet_vals[ cipher_letter ];
			n_ciphered_letter = ( n_original_letter + n_cipher_offset ) % alphabet.size;
			encrypted_phrase[ encrypted_phrase.size ] = alphabet[ n_ciphered_letter ];
			j++;
		}
		i++;
	}
	return encrypted_phrase;
}

light_show_morse( a_discs, message )
{
	i = 0;
	while ( i < message.size )
	{
		letter = message[ i ];
		letter_code = level.morse_letters[ letter ];
		if ( isDefined( letter_code ) )
		{
			j = 0;
			while ( j < letter_code.size )
			{
				turn_all_lights_on( a_discs );
				if ( letter_code[ j ] == "." )
				{
					wait 0,2;
				}
				else
				{
					if ( letter_code[ j ] == "-" )
					{
						wait 1;
					}
				}
				turn_all_lights_off( a_discs );
				wait 0,5;
				j++;
			}
		}
		else wait 2;
		wait 1,5;
		i++;
	}
}
