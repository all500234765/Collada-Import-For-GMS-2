#macro GetMaxWeightsSize 3
#macro GetMaxWeightsFormat vertex_type_float3
#macro ColladaShowMessages false

#macro MatrixIdentity matrix_set(matrix_world, matrix_build_identity());

model = ColladaLoad("model", false);
fAnimTime = 0; // Required

state = -1;

show_debug_message("-------------");

spd = 0; m_spd = 6; dir = 0; pitch = 0;

fFOV = 70;
fNear = .1;
fFar = 10000;

fSpd = 0;
max_fSpd = 34; //.0625;

fRatio = 1024 / 540;

fDist  = 1000; fDistDest  = fDist;
fDir   = 0;    fDirDest   = fDir;
fPitch = -30;  fPitchDest = fPitch;

mProj = matrix_build_projection_perspective_fov(fFOV, fRatio, fNear, fFar);
mView = matrix_build_identity();

bDone = false;
mouse = [mouse_x, mouse_y];

fSize = 100;

x = 0;
y = 0;
z = 0;

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_tex_repeat(true);

