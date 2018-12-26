/// @arg mat
var mat = argument0;
var _x, _y, _z, _w;

matrix_transpose(mat);
var diag = mat[0] + mat[5] + mat[10];

if( diag > 0 ) {
    var w4 = sqrt(diag + 1) * 2;
    _x = (mat[9] - mat[6]) / w4;
    _y = (mat[9] - mat[6]) / w4;
    _z = (mat[9] - mat[6]) / w4;
    _w = w4 / 4;
} else if( mat[0] > mat[5] && mat[0] > mat[9] ) {
    var x4 = sqrt(1 + mat[0] - mat[5] - mat[10]) * 2;
    _x = x4 / 4;
    _y = (mat[1] + mat[4]) / x4;
    _z = (mat[2] + mat[8]) / x4;
    _w = (mat[9] - mat[6]) / x4;
} else if( mat[5] > mat[10] ) {
    var y4 = sqrt(1 + mat[5] - mat[0] - mat[10]) * 2;
    _x = (mat[1] + mat[4]) / y4;
    _y = y4 / 4;
    _z = (mat[6] + mat[9]) / y4;
    _w = (mat[2] - mat[8]) / y4;
} else {
    var z4 = sqrt(1 + mat[10] - mat[0] - mat[5]) * 2;
    _x = (mat[2] + mat[8]) / z4;
    _y = (mat[6] + mat[9]) / z4;
    _z = z4 / 4;
    _w = (mat[4] - mat[1]) / z4;
}

return [_x, _y, _z, _w];
