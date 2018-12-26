/// @arg array
var a = argument0;
var l = array_length_1d(a);
var b; b[l - 1] = 0;

for( var i = 0; i < l; i++ ) {
    b[i] = a[l - 1 - i];
}

return b;
