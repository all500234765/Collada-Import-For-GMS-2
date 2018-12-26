/// @arg {string} FName
/// @arg {bool} EnableAnimations
var fname = (filename_ext(argument0) == "") ? (argument0 + ".dae") : argument0;
var uAnim = argument1;

var fn1 = "Cache\\Collada\\Models\\" + argument0 + ".m_cache";
var fn2 = "Cache\\Collada\\Formats\\" + argument0 + ".f_cache";
if( file_exists(fn1) && file_exists(fn2) && false ) {

#region Load format cache
var format        = ds_list_create();
var dsTextureList = ds_list_create(), dsTexture2Sav = ds_list_create();

var t = file_text_open_read(fn2);
    
    ds_list_read(format, file_text_read_string(t));
    file_text_readln(t);
    ds_list_read(dsTexture2Sav, file_text_read_string(t));
    
file_text_close(t);

#region Load textures
for( var i = 0; i < ds_list_size(dsTexture2Sav); i++ ) {
    var a = dsTexture2Sav[| i];
    var sType = a[0];
    var fName = a[1];
    
    ColladaLog("[ColladaLoader::ColladaLoadTexturesFromCache] LoadingTexture(" + sType + ", \"" + fName + "\")");
    
    var ref = -1;
    var ext = string_lower(filename_ext(fName));
    switch( file_exists(fName) ? ext : "err0" ) {
        case "err0": ColladaLog("[ColladaLoader::ColladaLoadTexturesFromCache] No file found! (" + fName + ")"); break;
        case ".tga": ref = [2, LoadTGA(fName)];                   break; // 2 - surface
        case ".png": ref = [1, sprite_add(fName, 1, 0, 0, 0, 0)]; break; // 1 - sprite
        default:
            ColladaLog("[ColladaLoader::ColladaLoadTexturesFromCache] Unsupported format: " + ext);
            break;
    }
    
    ds_list_add(dsTextureList, ref);
}
#endregion

#region Load format
vertex_format_begin();

var l = ds_list_size(format);
for( var i = 0; i < l; i++ ) {
    var type = format[| i];
    
    ColladaLog("ColladaLoader::GenerateFormat[" + string(i) + "]: " + type);
    
    // Fill format with data
    switch( type ) {
        case "position"    : vertex_format_add_position_3d(); ds_list_add(format, type); break;
        case "normal"      : vertex_format_add_normal(); ds_list_add(format, type); break;
        case "map"         :
        case "texcoord"    : vertex_format_add_texcoord(); ds_list_add(format, "texcoord"); break;
        case "tangent"     : vertex_format_add_custom(vertex_type_float3, vertex_usage_tangent); ds_list_add(format, type); break;
        case "binormal"    : 
        case "bitangent"   : vertex_format_add_custom(vertex_type_float3, vertex_usage_binormal); ds_list_add(format, "binormal"); break;
        case "BlendIndices": vertex_format_add_custom(GetMaxWeightsFormat, vertex_usage_blendindices); ds_list_add(format, "BlendIndices"); break;
        case "BlendWeight" : vertex_format_add_custom(GetMaxWeightsFormat, vertex_usage_blendweight ); ds_list_add(format, "BlendWeight" ); break;
        default:
            // SINCE IT DOESN'T HAVE ANY KIND OF STANDART
            ColladaLog("[ColladaLoader::ColladaLoadMeshFromCache::GenerateFormat]: Not supported (" + type + ")");
            ds_list_add(format, "nop");
            break;
    }
}

ColladaLog("[ColladaLoader::ColladaLoadMesh]: Format generated");
var vfFormat = vertex_format_end();
#endregion

#endregion

#region Load model cache
var bBuffer = buffer_load(fn1);
var vbBuffer = vertex_create_buffer_from_buffer(bBuffer, vfFormat);

vertex_freeze(vbBuffer);
buffer_delete(bBuffer);
#endregion

} else {

#region Parser
// Check for file existance

var sLine = -1;
var t = file_text_open_read(fname);
    
    var i = 0; // 1, 2, 8, 20, 200
    while( !file_text_eof(t) ) {
        sLine[i++] = file_text_read_string(t);
        file_text_readln(t);
    }
    
file_text_close(t);

// Parse file
var dsStack = ds_stack_create();
var dsRoot = ds_map_create();
var iDepth = 0;

ds_stack_push(dsStack, [ds_type_map, dsRoot]); // Push root data map

var l = i - 1, i = 0;
while( i ++< l ) {
    if( sLine[i] == "" || sLine[i] = " " ) { continue; }
    var ds = ds_stack_top(dsStack);
    var point = ColladaParse(sLine[i], ds); // 
    var p = point;
    q = (typeof(point) == "array");
    
    if( q ) {
        //ColladaLog([sLine[i], point, ds, ds_map_find_value(ds[1], "")]);
        
        if( point[2] == 1 ) {
            var key = string_replace(point[1], "\\", "");
            var d = ds_map_find_value(ds[1], key);
            if( point[0] == ds_type_map ) {
                ds_stack_push(dsStack, d);
            } else if( point[0] == ds_type_list ) {
                //ColladaLog(ds_list_find_value(d, max(ds_list_size(d) - 1, 0)));
                ds_stack_push(dsStack, ds_list_find_value(d[1], max(ds_list_size(d[1]) - 1, 0)));
            }
        }
        
        // Just for debug
        point = point[1];
    }
    
    var c = "|", c0 = string_char_at(point, 1);
    //ColladaLog([c0, point]);
    if( c0 == "\\" ) { // Going in
        iDepth++;
        c = "\\";
    } else if( c0 == "/" ) { // Going out
        iDepth--;
        c = "/";
        if( iDepth == 0 ) c = "|";
        ds_stack_pop(dsStack);
    }
    
    var q = (c != "|");
    ColladaLog("[ColladaLoader::ColladaLoad]: " + ((iDepth > 0) ? "|" : "") + string_repeat(" ", iDepth - (c == "\\")) + (q ? "" : c) + point);
}

/*ColladaLog(print(dsRoot));
ColladaLog("----------------------------");
ColladaLog(print(2));
ColladaLog("----------------------------");
//ColladaLog(ds_list_size(ds_map_find_value(7, "image"))); //*/
#endregion

#region Loader
#region Check version
var q = [];
if( ColladaCheckVersion(dsRoot, q) ) {
    ColladaLog("[ColladaLoader::ColladaCheckVersion]: Error, Unsupported COLLADA version (" + q[0] + "), Please use 1.4.1 version");
    return -1;
}
#endregion

#region Load textures <library_images>
// COLLADA[1] -> library_images[1] -> image[1]
// TODO: Support 0 textures
var dsTexList = ColladaGet([ds_type_map, dsRoot], "COLLADA->library_images->image", true), a = dsTexList, dsTexList = a[1];
var size, dsTextureList, dsTexture2Sav;
dsTextureList = ds_list_create(); dsTexture2Sav = ds_list_create();

if( a[0] == ds_type_list ) {
    size = ds_list_size(dsTexList);
} else if( a[0] == ds_type_map ) {
    size = 1;
}

ds_map_add_list(dsRoot, "dsTextureList", dsTextureList);

for( var i = 0; i < size; i++ ) {
    var dsData;
    
    if( a[0] == ds_type_list ) {
        dsData = array_get(dsTexList[| i], 1); // ds_map
    } else if( a[0] == ds_type_map ) {
        dsData = dsTexList; // ds_map
    }
    
    var fName = string_replace_all(string(dsData[? "init_from"]), "%20", " ");
    var sType = string(dsData[? "name"]);
    
    ColladaLog("[ColladaLoader::ColladaLoadTextures] LoadingTexture(" + sType + ", \"" + fName + "\")");
    
    var ref = -1;
    var ext = string_lower(filename_ext(fName));
    switch( file_exists(fName) ? ext : "err0" ) {
        case "err0": ColladaLog("[ColladaLoader::ColladaLoadTextures] No file found! (" + fName + ")"); break;
        case ".tga": ref = [2, LoadTGA(fName)];                   break; // 2 - surface
        case ".png": ref = [1, sprite_add(fName, 1, 0, 0, 0, 0)]; break; // 1 - sprite
        default:
            ColladaLog("[ColladaLoader::ColladaLoadTextures] Unsupported format: " + ext);
            break;
    }
    
    ds_list_add(dsTextureList, ref);
    ds_list_add(dsTexture2Sav, [sType, fName]);
}
#endregion

#region Load <library_effects>

#endregion

#region Load <library_geometries>
// COLLADA[1] -> library_geometries[1] -> geometry[1]
// TODO: Support 1/0 textures
var dsMesh = ColladaGet([ds_type_map, dsRoot], "COLLADA->library_geometries->geometry->mesh");
var dsSrc  = ColladaGet([ds_type_map, dsMesh], "source");
var PosSrc = string_replace_all(ColladaGet([ds_type_map, dsMesh], "vertices->source"), "#", "");

var dsTri, dsDat1, meshTris = 0;
if( ds_map_exists(dsMesh, "triangles") ) {
    dsTri  = ColladaGet([ds_type_map, dsMesh], "triangles->p");
    dsDat1 = ColladaGet([ds_type_map, dsMesh], "triangles->input");
    meshTris = ds_map_find_value(ColladaGet([ds_type_map, dsMesh], "triangles"), "count");
    ColladaLog("[ColladaLoader::ColladaLoadMesh]: Triangles");
} else if( ds_map_exists(dsMesh, "polylist") ) {
    dsTri  = ColladaGet([ds_type_map, dsMesh], "polylist->p");
    dsDat1 = ColladaGet([ds_type_map, dsMesh], "polylist->input");
    meshTris = ds_map_find_value(ColladaGet([ds_type_map, dsMesh], "polylist"), "count");
    ColladaLog("[ColladaLoader::ColladaLoadMesh]: Polylist");
}

// Just to be sure
meshTris = real(meshTris);

#region Create format
vertex_format_begin();

var size = 0; // Format size
var format = ds_list_create(); // Format 
var tmp = ds_list_create();

var l = ds_list_size(dsSrc);

if( false ) {
#region Old vertex format generation
for( var i = 0; i < l; i++ ) {
    var dsMap = ColladaGet([ds_type_list, dsSrc], string(i));
    var type  = dsMap[? "id"];
    var count = real(dsMap[? "count"]);
    
    var s = string(ds_map_find_value(ColladaGet([ds_type_map, dsMap], "float_array"), ""));
    
    if( s == "undefined" ) { ds_list_add(format, "nop"); size++; continue; }
    //ColladaLog(i);
    var z = real(ColladaGet([ds_type_map, dsMap], "technique_common->accessor->stride"));
    //ColladaLog(z);
    var data = string_split(s, " ", true, count);
    var sz = array_length_1d(data);
    var b; b[sz div z] = -1;
    
    // Pack data
    for( var j = 0; j < sz; j += z ) {
        if( j mod z == 0 ) b[j div z] = [data[j]];
        repeat( z - 1 ) {
            var l1 = array_length_1d(b[j div z]);
            if( j + l1 >= sz ) { break; }
            array_set(b[j div z], l1, data[j + l1]);
        }
    }
    
    ds_list_add(tmp, b);
    
    // Fill format with data
    switch( type ) {
        case "position" : vertex_format_add_position_3d(); size++; ds_list_add(format, type); break;
        case "normal"   : vertex_format_add_normal(); size++; ds_list_add(format, type); break;
        case "map"      :
        case "texcoord" : vertex_format_add_texcoord(); size++; ds_list_add(format, "texcoord"); break;
        case "tangent"  : vertex_format_add_custom(vertex_type_float3, vertex_usage_tangent); size++; ds_list_add(format, type); break;
        case "binormal" : 
        case "bitangent": vertex_format_add_custom(vertex_type_float3, vertex_usage_binormal); size++; ds_list_add(format, "binormal"); break;
        default:
            // SINCE IT DOESN'T HAVE ANY KIND OF STANDART
            if( string_pos(type, "position") > 0 ) {
                vertex_format_add_position_3d();
                size++;
                ds_list_add(format, "position");
            } else if( string_pos(type, "normal") > 0 ) {
                vertex_format_add_normal();
                size++;
                ds_list_add(format, "normal");
            } else if( string_pos(type, "texcoord") > 0 || string_pos(type, "map") > 0 ) {
                vertex_format_add_texcoord();
                size++;
                ds_list_add(format, "texcoord");
            } else if( string_pos(type, "tangent") > 0 ) {
                vertex_format_add_custom(vertex_type_float3, vertex_usage_tangent);
                size++;
                ds_list_add(format, "tangent");
            } else if( string_pos(type, "binormal") > 0 || string_pos(type, "bitangent") > 0 ) {
                vertex_format_add_custom(vertex_type_float3, vertex_usage_binormal);
                size++;
                ds_list_add(format, "binormal");
            } else {
                ColladaLog("[ColladaLoader::ColladaLoadMesh::GenerateFormat]: Not supported (" + type + ")");
                size++;
                ds_list_add(format, "nop");
            }
            break;
    }
}
#endregion
} else {
#region New vertex format generation
var dsMap = ColladaGet([ds_type_list, dsSrc], string(0));
var s = string(ds_map_find_value(ColladaGet([ds_type_map, dsMap], "float_array"), ""));

if( s == "undefined" ) {
    ds_list_add(format, "nop");
    size++;
} else {
    // 
    var count = real(dsMap[? "count"]);
    var z = real(ColladaGet([ds_type_map, dsMap], "technique_common->accessor->stride"));
    var data = string_split(s, " ", true, count);
    var sz = array_length_1d(data);
    var b = -1; b[sz div z] = -1;
    
    // Pack data
    for( var j = 0; j < sz; j += z ) {
        b[j div z] = [data[j]];
        
        repeat( z - 1 ) {
            var l1 = array_length_1d(b[j div z]);
            if( j + l1 >= sz ) { break; }
            array_set(b[j div z], l1, data[j + l1]);
        }
    }
    
    //ColladaLog(b);
    ds_list_add(tmp, b);
    
    vertex_format_add_position_3d();
    ds_list_add(format, "position"); size++;
}

var __offset = 0;

//ColladaLog("---------------------------------------------- " + string(i));
for( var i = 1; i < l; i++ ) {
    var semantic = ColladaGet([ds_type_list, dsDat1], string(i) + "->semantic");
    var dsMap = ColladaGet([ds_type_list, dsSrc], string(i));
    var count = real(dsMap[? "count"]);
    
    var s = string(ds_map_find_value(ColladaGet([ds_type_map, dsMap], "float_array"), ""));
    
    if( s == "undefined" ) { ds_list_add(format, "nop"); size++; continue; }
    var z = real(ColladaGet([ds_type_map, dsMap], "technique_common->accessor->stride"));
    var data = string_split(s, " ", true, count);
    var sz = array_length_1d(data);
    var b = -1; b[sz div z] = -1;
    
    // Pack data
    for( var j = 0; j < sz; j += z ) {
        b[j div z] = [data[j]];
        repeat( z ) {
            var l1 = array_length_1d(b[j div z]);
            if( j + l1 >= sz ) { break; }
            array_set(b[j div z], l1, data[j + l1]);
        }
    }
    
    ds_list_add(tmp, b);
    
    __offset = real(ColladaGet([ds_type_list, dsDat1], string(i) + "->offset"));
    //ColladaLog([semantic, __offset, i]);
    
    // Fill format with data
    switch( semantic ) {
        case "NORMAL"     : vertex_format_add_normal(); size++; ds_list_add(format, "normal"); break;
        case "TEXCOORD"   : vertex_format_add_texcoord(); size++; ds_list_add(format, "texcoord"); break;
        case "TEXTANGENT" : vertex_format_add_custom(vertex_type_float3, vertex_usage_tangent); size++; ds_list_add(format, "tangent"); break;
        case "TEXBINORMAL": vertex_format_add_custom(vertex_type_float3, vertex_usage_binormal); size++; ds_list_add(format, "binormal"); break;
        default:
            ColladaLog("[ColladaLoader::ColladaLoadMesh::GenerateFormat]: Not supported (" + semantic + ")");
            size++;
            ds_list_add(format, "nop");
            break;
    }
}

#region Load animation format here too, if we can otherwise throw an error and stop loading animations
if( uAnim ) {
    var animRoot = ColladaGet([ds_type_map, dsRoot], "COLLADA->library_animations");
    if( !ds_exists(animRoot, ds_type_map) ) {
        // Disable animations
        ColladaLog("[ColladaLoader::ColladaLoadAnimations]: No animations found. Animations disabled!");
        uAnim = false;
    } else {
        // Find root joint name
        var __list = ColladaGet([ds_type_map, dsRoot], "COLLADA->library_visual_scenes->visual_scene->node"); // Get list of nodes
        var rjName = "";
        var __i = 0;
        
        for( var i = 0; i < ds_list_size(__list); i++ ) {
            var __d = ColladaGet([ds_type_list, __list], string(i) + "->id");
            
            if( __d == "Armature" ) {
                // Found armature
                rjName = ColladaGet([ds_type_list, __list], string(i) + "->node->id");
                __i = i;
            }
        }
        
        if( rjName == "" ) {
            // Disable animations
            ColladaLog("[ColladaLoader::ColladaLoadAnimations]: No root joint found. Animations disabled!");
            uAnim = false;
        } else {
            var JOINT_KEYFRAMES = -1;
            var LIST = ColladaGet([ds_type_map, animRoot], "animation");
            for( var JOINT = 0; JOINT < ds_list_size(LIST); JOINT++ ) {
                repeat( 1 ) {
                    // Get key times
                    var rt___      = ColladaGet([ds_type_map, animRoot], "animation->" + string(JOINT) + "->source->0->float_array");
                    var frameCount = real(ColladaGet([ds_type_map, rt___], "count"));
                    var tData      = string_split(ColladaGet([ds_type_map, rt___], "__value__"), " ", true, frameCount);
                    //ColladaLog(tData);
                    
                    // Animation total duration
                    var duration = tData[frameCount - 1];
                    
                    // Init keyframes
                    kf = -1;
                    var kf; kf[frameCount - 1] = -1;
                    
                    // Search for OUTPUT semantic
                    var list__ = ColladaGet([ds_type_map, animRoot], "animation->" + string(JOINT) + "->sampler->input");
                    var dataID = "";
                    
                    for( var j = 0; j < ds_list_size(list__); j++ ) {
                        if( ColladaGet([ds_type_list, list__], string(j) + "->semantic") == "OUTPUT" ) {
                            dataID = string_replace(ColladaGet([ds_type_list, list__], string(j) + "->source"), "#", "");
                            break;
                        }
                    }
                    
                    if( dataID == "" ) {
                        // Disable animations for keyframe
                        ColladaLog("[ColladaLoader::ColladaLoadAnimations]: No OUTPUT semantic found in library_animations->animation[" + string(JOINT) + "]->sampler found. Animations for keyframe disabled!");
                        //uAnim = false;
                        //break;
                        continue;
                    }
                    
                    // Search for joint name
                    list__ = ColladaGet([ds_type_map, animRoot], "animation->" + string(JOINT) + "->channel->target");
                    var jointName = array_get(string_split(list__, "/", false), 0);
                    ColladaLog(jointName);
                    
                    // Search for output matrix
                    list__ = ColladaGet([ds_type_map, animRoot], "animation->" + string(JOINT) + "->source");
                    
                    var __count = 0;
                    var __value = [0];
                    for( var j = 0; j < ds_list_size(list__); j++ ) {
                        if( ColladaGet([ds_type_list, list__], string(j) + "->id") == dataID ) {
                            __count = real(ColladaGet([ds_type_list, list__], string(j) + "->float_array->count"));
                            __value = string_split(ColladaGet([ds_type_list, list__], string(j) + "->float_array->__value__"), " ", true, __count);
                            break;
                        }
                    }
                    
                    if( __count == 0 ) {
                        // Disable animations for keyframe
                        ColladaLog("[ColladaLoader::ColladaLoadAnimations]: No output matrix values found in library_animations->animation[" + string(JOINT) + "]->source->" + dataID + " found. Animations for keyframe disabled!");
                        continue;
                    }
                    
                    // Process matrices
                    var matrix = matrix_build_identity();
                    
                    for( var i = 0; i < frameCount; i++ ) {
                        for( var j = 0; j < 16; j++ ) {
                            matrix[j] = __value[i * 16 + j];
                        }
                        
                        matrix = array_flip(matrix);
                        matrix_transpose(matrix);
                        
                        kf[i] = [matrix, jointName];
                    }
                    
                    //ColladaLog(kf);
                    
                    JOINT_KEYFRAMES[JOINT] = kf;
                }
            }
            
            if( uAnim ) {
                JOINT--;
                
                // Sort list
                var NEW_JOINT_LIST = -1; NEW_JOINT_LIST[frameCount - 1] = -1;
                for( var i = 0; i < frameCount; i++ ) {
                    var a; a[JOINT] = -1;
                    
                    for( var j = 0; j < JOINT - 1; j++ ) {
                        a[j] = array_get(JOINT_KEYFRAMES[j], i);
                    }
                    
                    NEW_JOINT_LIST[i] = a;
                    
                    for( var k = 0; k < array_length_1d(NEW_JOINT_LIST[i]); k++ ) {
                        ColladaLog("NEW_JOINT_LIST[time=" + string(i) + ", k=" + string(k) + "]: " + string(array_get(NEW_JOINT_LIST[i], k)));
                    }
                }
                
                // Now we have array with all keyframes
                // NEW_JOINT_LIST[KeyFrame] = [matrix, joint name]
                
                // Build hierrarhy
                var armature = ColladaGet([ds_type_list, __list], string(__i) + "->node->node");
                
                // Parse weights
                var controller = ColladaGet([ds_type_map, dsRoot], "COLLADA->library_controllers->controller->skin");
                var __count    = ColladaGet([ds_type_map, controller], "vertex_weights->count");
                
                var semantic0 = ColladaGet([ds_type_map, controller], "vertex_weights->input->0->semantic");
                var semantic1 = ColladaGet([ds_type_map, controller], "vertex_weights->input->1->semantic");
                
                var src0 = string_replace(ColladaGet([ds_type_map, controller], "vertex_weights->input->0->source"), "#", ""); // Field name
                var src1 = string_replace(ColladaGet([ds_type_map, controller], "vertex_weights->input->1->source"), "#", "");
                
                // Search for inverse bind matrix
                var jointInput       = ColladaGet([ds_type_map, controller], "joints->input");
                var jointsInvMat     = -1;
                var jointsInvMatName = "";
                var useInvMatrix     = true;
                
                // 
                for( var i = 0; i < ds_list_size(jointInput); i++ ) {
                    if( ColladaGet([ds_type_list, jointInput], string(i) + "->semantic") == "INV_BIND_MATRIX" ) {
                        jointsInvMatName = string_replace(ColladaGet([ds_type_list, jointInput], string(i) + "->source"), "#", "");
                        break;
                    }
                }
                
                // Debug
                if( jointsInvMatName == "" ) {
                    // Calculate matrices
                    useInvMatrix = false;
                    ColladaLog("[ColladaLoader::ColladaLoadAnimations]: No inverse matrix found in library_controllers->controller->skin->joints->input->semantic 'INV_BIND_MATRIX' found. All joints will calculate inverse bind matrices!");
                } else {
                    
                    
                }
                
                // Selection
                var j = src0;
                if( semantic1 == "JOINT" ) { j = src1; }
                
                var w = src0;
                if( semantic1 == "WEIGHT" ) { w = src1; }
                
                // Get weights and joint list
                var WeightList = -1;
                var JointList  = -1;
                
                var lsize = ds_list_size(ColladaGet([ds_type_map, controller], "source"))
                for( var i = 0; i < lsize; i++ ) {
                    var data = ColladaGet([ds_type_map, controller], "source->" + string(i) + "->id");
                    ColladaLog("DATA: " + data);
                    if( data == w ) {
                        // Weight list
                        var dat     = ColladaGet([ds_type_map, controller], "source->" + string(i) + "->float_array");
                        var _count_ = real(ColladaGet([ds_type_map, dat], "count"));
                        var dataArr = ColladaGet([ds_type_map, dat], "__value__");
                        
                        WeightList = string_split(dataArr, " ", true, _count_ - 1);
                    } else if( data == j ) {
                        // Joint list
                        var dat     = ColladaGet([ds_type_map, controller], "source->" + string(i) + "->Name_array");
                        var _count_ = real(ColladaGet([ds_type_map, dat], "count"));
                        var dataArr = ColladaGet([ds_type_map, dat], "__value__");
                        
                        JointList = ds_list_from_array(string_split(dataArr, " ", false, _count_ - 1));
                    } else if( useInvMatrix && data == jointsInvMatName ) {
                        // Inv bind transform
                        jointsInvMat = string_split(ColladaGet([ds_type_map, controller], "source->" + string(i) + "->float_array->__value__"), " ", true, real(ColladaGet([ds_type_map, controller], "source->" + string(i) + "->float_array->count")));
                    }
                }
                
                if( JointList == -1 ) {
                    uAnim = false;
                    ColladaLog("[ColladaLoader::ColladaLoadAnimations]: No Joint List found. Animations disabled!");
                }
                
                if( WeightList == -1 ) {
                    uAnim = false;
                    ColladaLog("[ColladaLoader::ColladaLoadAnimations]: No Weight List found. Animations disabled!");
                }
                
                if( uAnim ) {
                    // Build node hierrarhy
                    var h = ColladaNodeHierrarhy([ds_type_list, armature], jointsInvMat, JointList);
                    var nodeList = ColladaCorrection(h);
                    
                    ColladaLog("Node List: ");
                    for( var i = 0; i < ds_list_size(nodeList); i++ ) {
                        ColladaLog("    " + string(nodeList[| i]));
                    }
                    
                    // Get effective joints counts
                    var _count = real(ColladaGet([ds_type_map, controller], "vertex_weights->count"));
                    var vcount = string_split(ColladaGet([ds_type_map, controller], "vertex_weights->vcount"), " ", true);
                    
                    // Get skin data
                    var v___ = string_split(ColladaGet([ds_type_map, controller], "vertex_weights->v"), " ", true);
                    var _ptr = 0;
                    var skinData = ds_list_create();
                    
                    var SZ = array_length_1d(v___);
                    for( var i = 0; i < array_length_1d(vcount); i++ ) {
                        var a = [[], []];
                        
                        if( _ptr > SZ + 1 ) { break; }
                        for( var j = 0; j < vcount[i]; j++ ) {
                            var JID =            v___[_ptr++];
                            var W   = WeightList[v___[_ptr++]];
                            
                            // Update vertex data
                            var bl = false;
                            
                            var _w = a[0];
                            var _j = a[1];
                            var _l = array_length_1d(_w);
                            for( var k = 0; k < _l; k++ ) {
                                if( W > _w[k] ) {
                                    _j[@ k] = W;
                                    _w[@ k] = JID;
                                    bl = true;
                                    break;
                                }
                            }
                            
                            if( !bl ) {
                                _w = a[0];
                                _j = a[1];
                                _j[@ 0] = W;
                                _w[@ 0] = JID;
                            }
                        }
                        
                        // Limit joint number
                        _w = a[0];
                        _j = a[1];
                        _l = array_length_1d(_j);
                        if( _l > GetMaxWeightsSize ) {
                            var topW = -1; topW[_l] = -1;
                            var total = 0;
                            
                            // Save top weights
                            for( var j = 0; j < _l; j++ ) {
                                topW[j] = _w[j];
                                total += topW[j];
                            }
                            
                            // Refill weight list
                            _w = -1;
                            
                            for( var j = 0; j < min(_l, GetMaxWeightsSize); j++ ) {
                                _w[j] = min(topW[i] / total, 1);
                            }
                            
                            // Remove excess joint IDs
                            var JNTS = -1;
                            for( var j = 0; j < GetMaxWeightsSize; j++ ) {
                                JNTS[j] = _j[j];
                            }
                            
                            a = [_w, JNTS];
                        } else {
                            // Fill empty weights
                            for( var j = _l; j < GetMaxWeightsSize; j++ ) {
                                _w[@ j] = 0;
                                _j[@ j] = 0;
                            }
                        }
                        
                        ds_list_add(skinData, a);
                    }
                    
                    // Finally update vertex format
                    // Add indices and weights to format
                    vertex_format_add_custom(GetMaxWeightsFormat, vertex_usage_blendindices); ds_list_add(format, "BlendIndices"); //size++;
                    vertex_format_add_custom(GetMaxWeightsFormat, vertex_usage_blendweight ); ds_list_add(format, "BlendWeight" ); //size++;
                }
            }
        }
    }
}

// tData                       = array of time stamps
// skinData                    = list of [weight array, joint list] for vertex
// nodeList                    = hierrarhy of joints [-1/[-1/[...], ...], name, inv bind matrix]
// NEW_JOINT_LIST[time][joint] = [matrix, joint name]
// duration                    = total animation duration
#endregion
#endregion
}

// Debug
for( var i = 0; i < ds_list_size(format); i++ ) { ColladaLog("ColladaLoader::GenerateFormat[" + string(i) + "]: " + format[| i]); }

ColladaLog("[ColladaLoader::ColladaLoadMesh]: Format generated");
var vfFormat = vertex_format_end();
#endregion

#region Create mesh
var vbBuffer = vertex_create_buffer();
vertex_begin(vbBuffer, vfFormat);

// Get triangles
var s = (typeof(dsTri) == "string") ? dsTri : dsTri[? ""];
var tris = string_split(s, " ", true, count);

var _size = __offset; //real(ds_map_find_value(ColladaGet([ds_type_list, dsDat1], string(size - 1)), "offset"));
ColladaLog([size, _size]);

var brk = false;
var _S = 1 + _size;
var _L = array_length_1d(tris) - 1;
for( var j = 0; j < _L; j += _S ) {
    for( var i = 0; i < size; i++ ) {
        var offset = min(i, _size); //real(ds_map_find_value(ColladaGet([ds_type_list, dsDat1], string(i)), "offset"));
        var q = tris[j + offset]; // Index
        
        if( format[| i] != undefined ) {
            var f = tmp[| i]; // Get data array
            if( q >= array_length_1d(f) - 1 ) { brk = true; break; }
            
            var a = f[q];
            //ColladaLog([format[| i], i, a, q, brk]);
        }
        
        switch( format[| i] ) {
            case "position": vertex_position_3d(vbBuffer, a[0], a[1], a[2]); break;
            case "normal"  : vertex_float3(     vbBuffer, a[0], a[1], a[2]); break;
            case "texcoord": vertex_texcoord(   vbBuffer, a[0],  1. - a[1]); break;
            case "tangent" : vertex_float3(     vbBuffer, a[0], a[1], a[2]); break;
            case "binormal": vertex_float3(     vbBuffer, a[0], a[1], a[2]); break;
        }
    }
    
    if( uAnim ) {
        var z = j;
        
        var SkinData_j;
        if( z < ds_list_size(skinData) ) {
            SkinData_j = skinData[| z];
            b = SkinData_j[0]; // Indices
            a = SkinData_j[1]; // Weights
        } else {
            b = [0, 0, 0, 0]; // Indices
            a = [0, 0, 0, 0]; // Weights
        }
        
        switch( GetMaxWeightsSize ) {
            case 1:
                vertex_float1(vbBuffer, a[0]); // Indices
                vertex_float1(vbBuffer, b[0]); // Weights
                break;
                
            case 2:
                vertex_float2(vbBuffer, a[0], a[1]); // Indices
                vertex_float2(vbBuffer, b[0], b[1]); // Weights
                break;
                
            case 3:
                vertex_float3(vbBuffer, a[0], a[1], a[2]); // Indices
                vertex_float3(vbBuffer, b[0], b[1], b[2]); // Weights
                break;
                
            case 4:
                vertex_float4(vbBuffer, a[0], a[1], a[2], a[3]); // Indices
                vertex_float4(vbBuffer, b[0], b[1], b[2], b[3]); // Weights
                break;
        }
    }
    
    if( brk ) { break; }
}

ColladaLog("Triangle Count: " + string(j));
#endregion

// 
vertex_end(vbBuffer);

#region Cache
// Format, Texture List
var t = file_text_open_write(fn2);
    
    file_text_write_string(t, ds_list_write(format));
    file_text_writeln(t);
    file_text_write_string(t, ds_list_write(dsTexture2Sav));
    
file_text_close(t);

// Buffer
var bBuffer = buffer_create_from_vertex_buffer(vbBuffer, buffer_grow, 1);
buffer_save(bBuffer, fn1);
buffer_delete(bBuffer);
#endregion

// 
vertex_freeze(vbBuffer);

// Store vbuffer ID
//dsRoot[? "vbuffer"] = vbBuffer;

ds_list_destroy(tmp);
#endregion
#endregion

}

// 
if( uAnim ) {
    return [vbBuffer, dsTextureList, true, tData, skinData, nodeList, NEW_JOINT_LIST, duration];
}

return [vbBuffer, dsTextureList, false];
