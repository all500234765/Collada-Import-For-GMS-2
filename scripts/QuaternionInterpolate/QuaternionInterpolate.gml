/// @arg {Quaternion} a
/// @arg {Quaternion} b
/// @arg {float} blend
var a = argument0;
var b = argument1;
var blend = argument2;

var invBlend = 1 - blend;
var res = Quaternion(0, 0, 0, 1);
var dot = dot_product_3d(a[0], a[1], a[2], b[0], b[1], b[2]) + a[3] * b[3];

if( dot < 0 ) {
    res[0] = invBlend * a[0] - blend * b[0];
    res[1] = invBlend * a[1] - blend * b[1];
    res[2] = invBlend * a[2] - blend * b[2];
    res[3] = invBlend * a[3] - blend * b[3];
} else {
    res[0] = invBlend * a[0] + blend * b[0];
    res[1] = invBlend * a[1] + blend * b[1];
    res[2] = invBlend * a[2] + blend * b[2];
    res[3] = invBlend * a[3] + blend * b[3];
}

return QuaternionNormalize(res[0], res[1], res[2], res[3]);
