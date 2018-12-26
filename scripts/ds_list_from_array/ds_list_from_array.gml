/// @arg array
var a = argument0;

if( !is_array(a) ) { return -1; }

var l = array_length_1d(a);
var list = ds_list_create();
for( var i = 0; i < l; i++ ) {
    list[| i] = a[i];
}

a = -1;
return list;