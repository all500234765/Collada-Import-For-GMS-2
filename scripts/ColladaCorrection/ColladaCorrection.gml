/// @arg array
/// @arg [depth]
var a = argument[0];
var d = (argument_count == 2) ? argument[1] : 0;

var list = ds_list_create();

for( var i = 0; i < array_length_1d(a); i++ ) {
    var b = a[i];
    
    if( !is_array(b) ) { break; }
    
    if( b[0] == -1 ) {
        show_debug_message(string_repeat(" ", d) + "|" + b[1]);
        
        if( b[2] != -1 ) {
            // End of tree
            var __value__ = b[2]; /*ds_map_exists(b[2], "__value__");
            
            if( __value__ ) {
                __value__ = ds_map_find_value(b[2], "__value__");
            } else {
                __value__ = ColladaGet(ds_map_find_value(b[2], "matrix"), "__value__");
            }
            
            __value__ = matrix_transpose(string_split(__value__, " ", true));
            */
            
            ds_list_add(list, [string(b[1]), __value__, i]);
            show_debug_message(__value__);
        }
    } else {
        // Leaves
        show_debug_message(string_repeat(" ", d) + "\\" + string(b[1]));
        
        if( b[2] != -1 ) {
            // Leave
            var __value__ = b[2]; /*ds_map_exists(b[2], "__value__");
            
            if( __value__ ) {
                __value__ = ds_map_find_value(b[2], "__value__");
            } else {
                __value__ = ColladaGet(ds_map_find_value(b[2], "matrix"), "__value__");
            }
            
            __value__ = matrix_transpose(string_split(__value__, " ", true));
            */
            
            ds_list_add(list, [string(b[1]), __value__, i]);
            show_debug_message(__value__);
        }
        
        ds_list_append(list, ColladaCorrection(b[0], d + 1));
    }
}

return list;
