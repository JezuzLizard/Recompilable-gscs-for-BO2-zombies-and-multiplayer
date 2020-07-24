## The Basics

Each of the decompilers isn't able to 100% decompile scripts exactly as the original script is.

However if you compare the outputs of multiple decompilers its possible to get a clearer picture of what the developers had actually coded.

### Common Decompiler Errors

#### 2014 dump

The basic bo2 zombies dump featured in the readme is from 2014 and in this guide will be refered to as the 2014 dump.

The 2014 dump is the best dump to start with as a base script since while it has many errors its output is the most similar to the original decompiled scripts.
However, it struggles with properly placing devcalls, and misidentifies periods as commas so definitely check waits and other functions that use decimal inputs.
Additionally the 2014 dump doesn't ever use for loops or foreaches so as a result it uses some odd logic at times.

The 2014 dump also will misidentify if statements as while loops as well as improperly place if/else statements.
The 2014 dump may also misidentify conditions in if/else statements.
The 2014 dump may mistakenly add extra :: at the start of a pointer calling a function from another script.

Finally the 2014 dump has an issue where it uses the wrong numbers when dealing with functions using vector type functions.

#### Cerberus Decompiler dumps

The Cerberus Decompiler works well with if/else statements and can output code using for loops and foreaches unlike the 2014 dump.

However, the Cerberus Decompiler should not be used as a base script since its output is intended for use in bo3 scripting, and as a result would have a lot of errors.
The Cerberus Decompiler is similar to the 2014 dump except it doesn't misplace devcalls, and commas.
Just like the 2014 dump it may also misidentify if/else statement conditions.

#### Beta Dump

In addition to the other dumps there is also the beta dump. The beta dump is literally a leak of scripts from the BO2 beta so it includes comments since it was never decompiled but is actual source. The beta dump is the most accurate dump but only includes the scripts that were used at the time. Therefore, only core scripts and maps that existed at that time appear in the beta dump.

### Script Fixing Methodology 

What constitutes a fixed script that has parity with the original script depends on the original scripts complexity. 
Treyarch has a tendancy to not go all out and use every feature that the GSC language permits. As a result cerberus usually gives accurate results since there aren't many unusual ways that Treyarch will write something. First I will go over common syntax errors that the 2014 dump will have and then the common syntax errors that cerberus creates.

**The 2014 dump always has the following types of script errors:**
```
Floats will improperly use a , instead of a .
```
```
Function variable references that reference a script outside of the current script will have an extra :: in front of them
```
**Example:**
```
function = ::maps/mp/zombies/_zombie_script::function;
OR
self thread onplayerconnect_callback( ::maps/mp/zombies/_zombie_script::function ); 
will throw an error on map launch
```
**Correct Usage:**
```
function = maps/mp/zombies/_zombie_script::function;
OR
self thread onplayerconnect_callback( maps/mp/zombies/_zombie_script::function ); 
```
**The 2014 dump sometimes has these types of script errors:**
```
Missing includes
Sometimes includes that need to be included in the script are not there
The cerberus output always has the require includes so copy them over
```

**The 2014 dump always produces outputs which are not in parity of the original script:**
```
Foreaches do not appear in the 2014 dump instead they look like this:

	_a427 = players;
	_k427 = getFirstArrayKey( _a427 );
	while ( isDefined( _k427 ) )
	{
		player = _a427[ _k427 ];
		_k427 = getNextArrayKey( _a427, _k427 );
	}
  This is functional but not correct check cerberus output for what the foreach should look like in each context
  The correct way to rewrite this is like this:
  foreach ( player in players )
  {
  }
```
```
For loops do not appear in the 2014 dump and while loops are used instead
Replace them with for loops but always check the info.md for compiler limitations
```

If you need more help contact me on my Discord username JezuzLizard#7864.

**Common Errors**

Infinite While Loop Without Wait:

When its not possible to connect to the server but its running that means there is an infinite loop with no wait active.

This can also happen ingame but the zombies freeze and the ammo counter freezes.

This can also happen when a client connects so controls are frozen.

This can also happen with a blackscreen that doesn't pass.


