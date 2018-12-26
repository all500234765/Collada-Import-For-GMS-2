/// @arg node
/// @arg InvMatrix
/// @arg JointList
var node         = argument[0];
var jointsInvMat = argument[1];
var JointList    = argument[2];

if( node[0] == ds_type_list ) {
    var list = node[1];
    var len = ds_list_size(list);
    var l; l[len - 1] = 0;
    for( var i = 0; i < len; i++ ) {
        l[i] = [ColladaNodeHierrarhy(list[| i], jointsInvMat, JointList), ColladaGet(list[| i], "id"), jointsInvMat];
    }
    
    return l;
} else if( node[0] == ds_type_map ) {
    var map = node[1];
    
    if( ds_map_exists(map, "node") ) {
        if( ds_map_exists(map, "__node__") ) {
            return ColladaNodeHierrarhy(map[? "node"], jointsInvMat, JointList);
        }
        
        var mat = -1; mat[16] = 0;
        var p = ds_list_find_index(JointList, map[? "id"]);
        for( var i = 0; i < 16; i++ ) {
            mat[i] = jointsInvMat[i + 16 * p];
        }
        
        return [ColladaNodeHierrarhy(map[? "node"], jointsInvMat, JointList), map[? "id"], mat];
    }
    
    var mat = -1; mat[16] = 0;
    var p = ds_list_find_index(JointList, map[? "id"]);
    for( var i = 0; i < 16; i++ ) {
        mat[i] = jointsInvMat[i + 16 * p];
    }
    return [-1, map[? "id"], mat];
} else {
    // Error
    show_debug_message("[ColladaLoader::ColladaNodeHierrarhy]: Unknown node {" + string(node[1]) + "} type: " + string(node[0]));
    return -1;
}
