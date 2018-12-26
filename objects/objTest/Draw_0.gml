/// @description Rendering
// Render
#region FPV
matrix_set(matrix_projection, mProj);
matrix_set(matrix_view, matrix_build_lookat(x, y, z, 
    x + 32 * dcos(fDir), y - 32 * dsin(fDir), z - 32 * dsin(fPitch), 0, 0, 1));

/*matrix_set(matrix_view, matrix_build_lookat(x, y, z, x + 32 * dcos(fDir), 
                                                     y - 32 * dsin(fDir), 
                                                     z + 32 * dsin(fPitch), 0, 0, 1));*/
#endregion

#region TPV
/*if( mouse_check_button_pressed(mb_left) ) {
    mouse = [mouse_x, mouse_y];
}

if( mouse_check_button(mb_left) ) {
    var diff = [mouse_x - mouse[0], mouse_y - mouse[1]];
    fDirDest -= diff[0] / 100;
    fPitchDest -= diff[1] / 100;
}

fDistDest += (1 + keyboard_check(vk_shift)) * 50 * (mouse_wheel_down() - mouse_wheel_up());
fDistDest = clamp(fDistDest, fSize, fSize * 100);

// Update position
fDir   = lerp(fDir  , fDirDest  , .1);
fPitch = lerp(fPitch, fPitchDest, .1);
fDist  = lerp(fDist , fDistDest , .1);

// Create look at matrix
var vx = lengthdir_x(fDist * lengthdir_x(1, fDir), fPitch);
var vy = lengthdir_x(fDist * lengthdir_y(1, fDir), fPitch);
var vz = lengthdir_y(fDist, fPitch);

matrix_set(matrix_view, matrix_build_lookat(x + vx, y + vy, z + vz, x, y, z, 0, 0, 1));*/
#endregion

shader_set(shRenderColladaModel);
    
    matrix_add_scale(fSize, fSize, fSize);
        
        //ColladaAnimation(model, true);
        
        var a = ds_list_find_value(model[1], 0); // [type, id]
        
        vertex_submit(model[0], pr_trianglelist, (a[0] == 2) ? surface_get_texture(a[1]) : sprite_get_texture(a[1], 0));
        
    MatrixIdentity;
    
shader_reset();
