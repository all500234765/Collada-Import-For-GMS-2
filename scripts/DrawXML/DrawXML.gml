/// @arg {ds_map} xml
/// @arg {ds_map} state [-1]
/// @arg {float} x
/// @arg {float} y
var xml   = argument0;
var state = argument1;
var _x    = argument2;
var _y    = argument3;

if( state == undefined || state == -1 ) { state = ds_map_create(); }

var e;
for( var i = ds_map_find_first(xml); i != undefined; i = ds_map_find_next(xml, i) ) {
    var p = xml[? i];
    
    var q = ((typeof(p) == "number") && ds_exists(p, ds_type_map));
    var h = string_height(p);
    
    draw_text(_x, _y, string(i) + ": " + string(p));
    
    if( q ) {
        h += DrawXML(p, state[? string(p)], _x + 20, _y + h);
    }
    
    _y += h;
}

return _y - argument3;
