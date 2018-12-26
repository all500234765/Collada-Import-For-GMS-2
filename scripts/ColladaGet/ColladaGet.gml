/// @arg {array} [type;dsRoot]
/// @arg {string} format
var ds     = argument[0];
var format = argument[1];
var ext    = (argument_count > 2) ? argument[2] : false;

// Get child
var p = string_pos("->", format);
if( p < 1 ) p = string_length(format) + 1; // Move p to end of the string

var s = string_copy(format, 1, p - 1);
format = string_delete(format, 1, p + 1);

// Return result
if( typeof(ds) != "array" ) { return ds; }

// Send help
var m;
if( ds[0] == ds_type_map ) {
    m = ds_map_find_value(array_get(ds, 1), s);
} else if( ds[0] == ds_type_list ) {
    m = ds_list_find_value(array_get(ds, 1), real(s));;
}

// Return result
if( ext ) {
    if( m == undefined ) return ds;
    if( format == "" ) { return m; }
} else {
    if( m == undefined ) { if( typeof(ds) == "array" ) return ds[1]; else return ds; }
    if( format == ""   ) { if( typeof(m ) == "array" ) return m[1];  else return m;  }
}

return ColladaGet(m, format, ext);
