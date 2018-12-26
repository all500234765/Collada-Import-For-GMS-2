/// @arg {string} Total
/// @arg {ds_map} dsData
var sTotal = argument0;
var dsData = argument1;

// Delete first whitespaces and <
var p = string_pos("<", sTotal);
sTotal = string_delete(sTotal, 1, p);

// Get inside char "?", "/" or anything else
var c0 = string_char_at(sTotal, 1);

// Get inside data
var point, sInside;
if( string_count(">", sTotal) == 1 ) {
    var f = "", force = false;
    p = string_pos(">", sTotal);
    if( c0 == "?" ) { // XML Settings
        sTotal = string_delete(sTotal, 1, 1);
        sInside = string_copy(sTotal, 1, p - 3);
    } else if( c0 == "/" ) { // End of tag
        sTotal = string_delete(sTotal, 1, 1);
        sInside = string_copy(sTotal, 1, p - 2);
        //show_debug_message("/" + sInside);
        return "/" + sInside;
    } else {
        f = string_repeat("\\", string_count("/", sTotal) == 0);
        
        if( string_char_at(sTotal, p - 1) == "/" ) {
            sInside = string_copy(sTotal, 1, p - 2);
            c0 = "";
            force = true;
        } else {
            sInside = string_copy(sTotal, 1, p - 1);
        }
    }
    
    // Parse
    point = ColladaParseInside(dsData, sInside);
    
    // 
    if( typeof(point) == "array" ) {
        point[1] = f + point[1];
        if( array_length_1d(point) == 2 ) point[2] = (c0 != "?") && (c0 != "/");
        if( force ) point[2] = false;
    }
} else {
    // Get key
    p = string_pos(">", sTotal);
    var sKey = string_copy(sTotal, 1, p - 1); sTotal = string_delete(sTotal, 1, p);
    //ds_map_add(dsData[1], sKey, [ds_type_map, ds_map_create()]);
    
    // Parse inside data
    p = string_pos("<", sTotal) - 1;
    sInside = string_copy(sTotal, 1, (p < 1) ? string_length(sTotal) : p);
    while( string_char_at(sInside, 1) == " " ) sInside = string_delete(sInside, 1, 1); // Remove whitespaces at the beginning
    
    // 
    //show_debug_message([dsData, sKey, sInside]);
    
    // <meow key0="value0">something</meow>
    if( string_count("=", sKey) > 0 ) {
        var p__      = string_pos(" ", sKey);
        var sKey2    = string_copy(sKey, 1, p__ - 1);
        var settings = string_split(string_copy(sKey, p__ + 1, string_length(sKey)), " ", false);
        
        //show_debug_message([sKey2, settings]);
        
        var tag = [sKey2];
        for( var k = 0; k < array_length_1d(settings); k++ ) {
            var set = string_replace_all(settings[k], "\"", "");
            
            tag[1 + k] = set;
        }
        
        //show_debug_message(tag);
        
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
            p = string_pos("=", tag[i]); show_debug_message([-99, string_copy(tag[i], 1, p - 1), string_copy(tag[i], p + 1, string_length(tag[i]))]);
            dsData[? string_copy(tag[i], 1, p - 1)] = string_copy(tag[i], p + 1, string_length(tag[i]));
        }
        
        var a = [iType, tag[0]];
        if( g == 1 ) a[2] = 1;
        
        if( typeof(g) == "array" ) {
            g[1] = f + g[1];
            if( array_length_1d(g) == 2 ) g[2] = (c0 != "?") && (c0 != "/");
            if( force ) g[2] = false;
        }
        
        dsData[? "__value__"] = string_copy(sTotal, 1, string_pos("<", sTotal) - 1);
        
        /*if( dsData[0] == ds_type_map ) {
            ds_map_add(dsData[1], sKey, sInside);
            //ds_map_add(dsData[1], 
        } else if( dsData[0] == ds_type_list ) {
            var m = ds_list_find_value(dsData[1], max(ds_list_size(dsData[1]) - 1, 0));
            ds_map_add(m[1], sKey, sInside);
        }*/
    } else {
        if( dsData[0] == ds_type_map ) {
            ds_map_add(dsData[1], sKey, sInside);
        } else if( dsData[0] == ds_type_list ) {
            var m = ds_list_find_value(dsData[1], max(ds_list_size(dsData[1]) - 1, 0));
            ds_map_add(m[1], sKey, sInside);
        }
    }
    
    point = sKey;
}

//show_debug_message(sInside);
//show_debug_message("[ColladaLoader::ColladaParse] New Point: " + point);

return point;
