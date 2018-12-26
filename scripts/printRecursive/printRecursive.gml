/// @arg ds_map
/// @arg iDepth
var m      = argument0;
var iDepth = argument1;

var i = ds_map_find_first(m);
var s = string(i) + ": " + string(m[? i]); // First key
var ws = string_repeat("\t", iDepth);

// Other keys
for( i = ds_map_find_next(m, i); i != undefined; i = ds_map_find_next(m, i) ) {
    var a = m[? i];
    s += "\n" + ws + string(i) + ": " + string(a);
    
    if( typeof(a) == "array" && typeof(a[1]) == "number" ) {
        var g
        if( a[0] == ds_type_map ) {
            g = printRecursive(a[1], iDepth + 1);
        } else if( a[0] == ds_type_list ) {
            g = printRecursive2(a[1], iDepth + 1);
        }
        
        s += "\n" + ws + "\t" + g;
    }
}

return s;
