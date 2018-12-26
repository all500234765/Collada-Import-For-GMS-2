/// @arg quat
var q = argument0;

var mat = -1; mat[15] = 0;

var xy = q[0] * q[1];
var xz = q[0] * q[2];
var xw = q[0] * q[3];
var yz = q[1] * q[2];
var yw = q[1] * q[3];
var zw = q[2] * q[3];

var x2 = q[0] * q[0];
var y2 = q[1] * q[1];
var z2 = q[2] * q[2];

mat[0] = 1 - 2 * (y2 + z2);
mat[1] = 2 * (xy - zw);
mat[2] = 2 * (xz + yw);
mat[3] = 0;

mat[4] = 2 * (xy + zw);
mat[5] = 1 - 2 * (x2 + z2);
mat[6] = 2 * (yz - xw);
mat[7] = 0;

mat[08] = 2 * (xz - yw);
mat[09] = 2 * (yz + xw);
mat[10] = 1 - 2 * (x2 + y2);
mat[11] = 0;

mat[12] = 0;
mat[13] = 0;
mat[14] = 0;
mat[15] = 1;

matrix_transpose(mat);

return mat;
