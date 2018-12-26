/// @arg dest
/// @arg source
var a = argument0;
var b = argument1;

var l = ds_list_size(a);
for( var i = 0; i < ds_list_size(b); i++ ) { a[| i + l] = b[| i]; }

ds_list_destroy(b);
return a;
