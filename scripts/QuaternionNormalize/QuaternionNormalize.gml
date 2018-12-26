/// @arg x
/// @arg y
/// @arg z
/// @arg w
var len = dot_product_3d(argument0, argument1, argument2, 
                         argument0, argument1, argument2) + argument3 * argument3;

len = sqrt(len);

return [argument0 / len, argument1 / len, argument2 / len, argument3 / len];
