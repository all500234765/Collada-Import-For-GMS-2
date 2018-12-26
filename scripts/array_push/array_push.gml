/// @arg dest
/// @arg src
var dest = argument0;
var src = argument1;

var ls = array_length_1d(src);
var ld = array_length_1d(dest);

for( var i = 0; i < ls; i++ ) {
    dest[@ i + ld] = src[i];
}

src = -1;
return dest;
