# Limitations of the compiler

**1. You cannot use nested foreaches it will cause an infinite loop**

**2. You cannot use continues in foreaches or for loops it will cause an infinite loop**

**3. You should always use parenthesis when comparing values using conditions while using operators**

```( 0 - 1 ) < 1``` is NOT the same as ```0 - 1 < 1``` the compiler will compile it as ```0 - ( 1 < 1 )```

```( 0 - 1 ) < 1``` will return 1 because 1 is greater than -1 

```0 - 1 < 1 ``` will return 0 because it will compare the values then subtract

ALWAYS SPECIFY PARENTHESIS WHEN OPERATORS ARE INVOLVED

**4. You cannot use more than 2 conditions in an IF statement connected by OR operators enclosed in parenthesis** EXAMPLE:
```
if ( ( a || b || c ) && d )
```
WILL NOT COMPILE

However, you can rewrite this as:
```
if ( ( a || b ) && d || c && d )
OR
if ( a && d || b && d || c && d )
```

**5. You cannot use OR operators in an IF statement in parenthesis if the string of conditions would not be on the leftmost side of the if statement and the number of conditions on the rightmost side is not at least 2.**
EXAMPLE:
```
if ( a && ( b || c ) )
WILL NOT COMPILE
```
However, 
```
if ( ( b || c ) && a )
WILL COMPILE
```
In the case of
```
if ( ( a || b ) && ( c || d ) )
WILL COMPILE
```

**6. You cannot set variables equal to a condition**
EXAMPLE:
```a = b && c;```
WILL NOT COMPILE

**7. Scripts that contain #using_animtree( "animtree" ); will compile but crash upon loading**
Unfortunately, for certain scripts #using_animtree( "animtree" ); is required for the script to function so scripts containing it will crash on start/while running
There is a workaround using script names such as maps/mp/gametypes_zm/_globalentities and naming an extracted but not decompiled script

 **8. You cannot use variable defined notifies/waittills with extra inputs/outputs**
 ```
EXAMPLE:
var = "connected";
level notify( var, player );
level waittill( var, player );
WILL COMPILE BUT
```
The notify/waittill won't work.

**9. Ternary op compiles but doesn't work as expected**
Instead of returning one of the two values specified the compiler will compile it to return bools instead.
