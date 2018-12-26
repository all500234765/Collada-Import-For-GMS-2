/// @arg ColladaModelData
/// @arg loop
var data = argument0;
var loop = argument1;

// No animations avaliable
if( !data[2] ) { return; }
// 0 : vbBuffer
// 1 : dsTextureList
// 2 : uAnim
// 3 : tData
// 4 : skinData
// 5 : nodeList
// 6 : NEW_JOINT_LIST
// 7 : duration

// tData                       = array of time stamps
// skinData                    = list of [weight array, joint list] for vertex
// nodeList                    = hierrarhy of joints [-1/[-1/[...], ...], name, inv bind matrix]
// NEW_JOINT_LIST[time][joint] = [matrix, joint name]
// duration                    = total animation duration

var timeData  = data[3];

var nodeList  = data[5];
var JointList = data[6];
var duration  = data[7];

var matrices = -1; matrices[50 * 16] = 0;

// Animation (Play/Loop/Stop)
fAnimTime += 1 / room_speed;
if( loop ) fAnimTime %= duration;
else fAnimTime = min(fAnimTime, duration);

// Calculate current pose
// Get previous and next frames
var frames = [0, 0];

for( var i = 1; i < array_length_1d(timeData); i++ ) {
    frames[1] = i;
    if( timeData[frames[1]] > fAnimTime ) { break; }
    frames[0] = i;
}

// Get progress value
var totalT = timeData[frames[1]] - timeData[frames[0]];
var curntT = fAnimTime - timeData[frames[0]];
var progress = curntT / totalT;

// Interpolate frames
var JLPrev = JointList[frames[0]];
var JLNext = JointList[frames[1]];
for( var i = 0; i < array_length_1d(JLPrev); i++ ) {
    var a = JLPrev[i];
    var b = JLNext[i];
    
    if( !is_array(a) || !is_array(b) ) { break; }
    
    var prevT = a[0];
    var nextT = b[0];
    
    // Get position and rotation for each frame
    var p0 = [prevT[3], prevT[7], prevT[11]];
    var p1 = [nextT[3], nextT[7], nextT[11]];
    
    var r0 = QuaternionFromMatrix(prevT);
    var r1 = QuaternionFromMatrix(nextT);
    
    // Interpolate position
    var p = [
        lerp(p0[0], p1[0], progress), 
        lerp(p0[1], p1[1], progress), 
        lerp(p0[2], p1[2], progress)
    ];
    
    var rot = QuaternionInterpolate(r0, r1, progress);
    
    // 
    var m = matrix_build(p[0], p[1], p[2], 0, 0, 0, 1, 1, 1);
    
    array_push(matrices, matrix_multiply(m, QuaternionToRotationMatrix(rot)));
    m = -1;
    rot = -1;
    p = -1;
    p0 = -1; p1 = -1;
    r0 = -1; r1 = -1;
}

// matrices = current pose
// Apply pose to joints
/*ColladaApplyPoseToJoin(matrices, );

/*Map<String, Matrix4f> currentPose, Joint joint, Matrix4f parentTransform) {
		Matrix4f currentLocalTransform = currentPose.get(joint.name);
		Matrix4f currentTransform = Matrix4f.mul(parentTransform, currentLocalTransform, null);
		for (Joint childJoint : joint.children) {
			applyPoseToJoints(currentPose, childJoint, currentTransform);
		}
		Matrix4f.mul(currentTransform, joint.getInverseBindTransform(), currentTransform);
		joint.setAnimationTransform(currentTransform);*/

shader_set_uniform_f(shader_get_uniform(shRenderColladaModel, "_Time"), fAnimTime);
shader_set_uniform_matrix_array(shader_get_uniform(shRenderColladaModel, "_Transforms"), matrices);

// Return result matrices
return matrices;
