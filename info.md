# Limitations of the compiler

**You cannot use nested foreaches it will cause an infinite loop**

**You cannot use continues in foreaches or for loops it will cause an infinite loop**

**You should always use parenthesis when comparing values using conditions while using operators**

```( 0 - 1 ) < 1``` is NOT the same as ```0 - 1 < 1``` the compiler will compile it as ```0 - ( 1 < 1 )```

```( 0 - 1 ) < 1``` will return 1 because 1 is greater than -1 

```0 - 1 < 1 ``` will return 0 because it will compare the values then subtract

ALWAYS SPECIFY PARENTHESIS WHEN OPERATORS ARE INVOLVED

**You cannot use more than 2 conditions in an IF statement connected by OR operators enclosed in parenthesis** EXAMPLE:
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

**You cannot use OR operators in an IF statement in parenthesis if the string of conditions would not be on the leftmost side of the if statement and the number of conditions on the rightmost side is not at least 2.**
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

**You cannot set variables equal to a condition**
EXAMPLE:
```a = b && c;```
WILL NOT COMPILE
```
