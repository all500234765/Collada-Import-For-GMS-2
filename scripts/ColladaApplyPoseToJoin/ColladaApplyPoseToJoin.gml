/// @arg CurrPose
/// @arg Joint
/// @arg ParentTransform
/*var CurrPose        = ;
var Joint           = ;
var ParentTransform = ;

var InvTransform = ;

var currentPose, joint, parentTransform;
{
    currentLocalTransform = currentPose.get(joint.name);
	currentTransform = mul(parentTransform, currentLocalTransform, null);
	for( childJoint : joint.children ) {
		applyPoseToJoints(currentPose, childJoint, currentTransform);
	}
	mul(currentTransform, joint.getInverseBindTransform(), currentTransform);
	joint.setAnimationTransform(currentTransform);
}
