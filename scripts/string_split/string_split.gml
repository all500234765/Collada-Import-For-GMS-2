/// @desc string_split(string, sep, real, size);
/// @arg string
/// @arg sep
/// @arg real
/// @arg size
var s    = argument[0];
var sep  = argument[1];
var r    = argument[2];
var size = (argument_count > 3) ? argument[3] : 0;

var a = -1, l = string_length(sep), _id_ = 0;
s += sep;
a[size] = "";

if( !r ) {
    while( string_length(s) > 0 ) {
        var p = string_pos(sep, s); var q = string_copy(s, 1, p - 1);
        s = string_delete(s, 1, p + l - 1);
        
        //show_debug_message(_id_);
        a[_id_++] = r ? real(q) : q;
    }
} else { // About 10x times faster
    var t = file_text_open_from_string(s);
        
        if( size == 0 ) {
            while( !file_text_eoln(t) ) {
                a[_id_++] = file_text_read_real(t);
            }
        } else {
            repeat( size ) {
                a[_id_++] = file_text_read_real(t);
            }
        }
        
    file_text_close(t);
}

return a;

/*for( var i = 1; i <= string_length(s); i++ ) {
    var sp = string_copy(s, i, l);
    var char = string_char_at(s, i);
    
    if( sp != sep ) {
        // Isn't separator
        a[_id_] += char;
    } else {
        if( r ) a[_id_] = real(a[_id_]);
        _id_++;
        a[_id_] = "";
    }
}

if( r ) a[array_length_1d(a) - 1] = real(a[array_length_1d(a) - 1]);

return a;
