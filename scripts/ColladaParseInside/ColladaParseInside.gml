/// @arg {ds_map} dsData
/// @arg {string} sInside
var dsData  = argument[0];
var sInside = string_replace_all(argument[1], "\"", "") + " ";

// Parse tag[0]
var tag = -1;
var p = string_pos(" ", sInside) - 1;
tag[0] = string_copy(sInside, 1, p);
sInside = string_delete(sInside, 1, p + 1);

// Parse tag[i]
while( sInside != "" ) {
    var p = string_pos(" ", sInside) - 1;
    tag[array_length_1d(tag)] = string_copy(sInside, 1, p);
    sInside = string_delete(sInside, 1, p + 1);
}

//show_debug_message([tag, sInside]);
// <meow dafdsf="fdsf">, tag[0] = "meow"
var dsList, iType = ds_type_map, g = false;
var q = ds_map_exists(dsData[1], tag[0]);
if( q ) { // Create list
    iType = ds_type_list;
    if( !ds_map_exists(dsData[1], "__" + tag[0] + "__") ) {
        dsList = ds_list_create();
        var m_map = ds_map_find_value(dsData[1], tag[0]); // Get old value
        
        ds_map_replace(dsData[1], tag[0], [ds_type_list, dsList]);
        ds_map_add(dsData[1], "__" + tag[0] + "__", 10); // 
        
        dsData = ds_map_create(); // Generate new map
        ds_list_add(dsList, m_map); // Store old value
        ds_list_add(dsList, [ds_type_map, dsData]); // 
        g = 1;
    } else {
        dsList = ds_map_find_value(dsData[1], tag[0]); // Get list
        dsData = ds_map_create(); // Generate new map
        ds_list_add(dsList[1], [ds_type_map, dsData]); // 
        g = true;
        //show_debug_message(49300430434390);
    }
} else {
    var m = ds_map_create();
    ds_map_add(dsData[1], tag[0], [ds_type_map, m]);
    dsData = m;
}

// parse dafdsf="fdsf" to map(key: "dafdsf", value: "fdsf")
var l = array_length_1d(tag);
for( var i = 1; i < l; i++ ) {
    p = string_pos("=", tag[i]);
    dsData[? string_copy(tag[i], 1, p - 1)] = string_copy(tag[i], p + 1, string_length(tag[i]));
}

var a = [iType, tag[0]];
if( g == 1 ) a[2] = 1;
return a;
