/// @arg ds_list
/// @arg iDepth
var l      = argument0;
var iDepth = argument1;

var ws = string_repeat("\t", iDepth);
var s = "";

// 
var len = ds_list_size(l);
for( var i = 0; i < len; i++ ) {
    var a = l[| i];
    s += "\n" + ws + "[" + string(i) + "]: " + string(a);
    
    if( typeof(a) == "array" && typeof(a[1]) == "number" ) {
        var g;
        if( a[0] == ds_type_map ) {
            g = printRecursive(a[1], iDepth + 1);
        } else if( a[0] == ds_type_list ) {
            g = printRecursive2(a[1], iDepth + 1);
        }
        
        s += "\n" + ws + "\t" + g;
    }
}

return s;
