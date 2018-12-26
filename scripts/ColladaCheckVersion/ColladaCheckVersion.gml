/// @arg {ds_map} Root
/// @arg {array} t
var q = ds_map_find_value(array_get(argument0[? "COLLADA"], 1), "version");
argument1[@ 0] = q;
return (q != "1.4.1");
