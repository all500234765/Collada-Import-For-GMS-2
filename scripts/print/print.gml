/// @arg ds_map
var m = argument0;

var i = ds_map_find_first(m);
var s = string(i) + ": " + string(m[? i]); // First key

// Other keys
for( i = ds_map_find_next(m, i); i != undefined; i = ds_map_find_next(m, i) ) {
    s += "\n" + string(i) + ": " + string(m[? i]);
}

return s;
