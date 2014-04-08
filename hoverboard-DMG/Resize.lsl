// Linkset Resizer with Menu
// version 1.00 (25.04.2010)
// by: Brilliant Scientist

//////////////////////////////////////////
//
//        Link Globals
//

integer LinkSeatHeight   = 1;
integer LinkFaceChange   = 2;
integer LinkDemoUser     = 3;
integer LinkColourChange = 4;
integer LinkSpeedChange  = 6;
integer LinkResize       = 7;


float MIN_DIMENSION=0.001; // the minimum scale of a prim allowed, in any dimension
float MAX_DIMENSION=10.0; // the maximum scale of a prim allowed, in any dimension
 
float max_scale;
float min_scale;
 
float   cur_scale = 1.0;
integer handle;
integer menuChan;
 
float min_original_scale=10.0; // minimum x/y/z component of the scales in the linkset
float max_original_scale=0.0; // minimum x/y/z component of the scales in the linkset
 
list link_scales = [];
list link_positions = [];
 
makeMenu()
{
    llListenRemove(handle);
    menuChan = 50000 + (integer)llFrand(50000.00);
    handle = llListen(menuChan,"",llGetOwner(),"");
 
    //the button values can be changed i.e. you can set a value like "-1.00" or "+2.00"
    //and it will work without changing anything else in the script
    llDialog(llGetOwner(),"Max scale: "+(string)max_scale+"\nMin scale: "+(string)min_scale+"\n \nCurrent scale: "+
        (string)cur_scale,["-0.01","-0.05","-0.10","+0.01","+0.05","+0.10","MIN SIZE","RESTORE","MAX SIZE"],menuChan);
}
 
integer scanLinkset()
{
    integer link_qty = llGetNumberOfPrims();
    integer link_idx;
    vector link_pos;
    vector link_scale;
 
    //script made specifically for linksets, not for single prims
    if (link_qty > 1)
    {
        //link numbering in linksets starts with 1
        for (link_idx=1; link_idx <= link_qty; link_idx++)
        {
            link_pos=llList2Vector(llGetLinkPrimitiveParams(link_idx,[PRIM_POSITION]),0);
            link_scale=llList2Vector(llGetLinkPrimitiveParams(link_idx,[PRIM_SIZE]),0);
 
            // determine the minimum and maximum prim scales in the linkset,
            // so that rescaling doesn't fail due to prim scale limitations
            if(link_scale.x<min_original_scale) min_original_scale=link_scale.x;
            else if(link_scale.x>max_original_scale) max_original_scale=link_scale.x;
            if(link_scale.y<min_original_scale) min_original_scale=link_scale.y;
            else if(link_scale.y>max_original_scale) max_original_scale=link_scale.y;
            if(link_scale.z<min_original_scale) min_original_scale=link_scale.z;
            else if(link_scale.z>max_original_scale) max_original_scale=link_scale.z;
 
            link_scales    += [link_scale];
            link_positions += [(link_pos-llGetRootPosition())/llGetRootRotation()];
        }
    }
    else
    {
        llOwnerSay("error: this script doesn't work for non-linked objects");
        return FALSE;
    }
 
    max_scale = MAX_DIMENSION/max_original_scale;
    min_scale = MIN_DIMENSION/min_original_scale;
 
    return TRUE;
}
 
resizeObject(float scale)
{
    integer link_qty = llGetNumberOfPrims();
    integer link_idx;
    vector new_size;
    vector new_pos;
 
    if (link_qty > 1)
    {
        //link numbering in linksets starts with 1
        for (link_idx=1; link_idx <= link_qty; link_idx++)
        {
            new_size   = scale * llList2Vector(link_scales, link_idx-1);
            new_pos    = scale * llList2Vector(link_positions, link_idx-1);
 
            if (link_idx == 1)
            {
                //because we don't really want to move the root prim as it moves the whole object
                llSetLinkPrimitiveParamsFast(link_idx, [PRIM_SIZE, new_size]);
            }
            else
            {
                llSetLinkPrimitiveParamsFast(link_idx, [PRIM_SIZE, new_size, PRIM_POSITION, new_pos]);
            }
        }
    }
}
 
default
{
    state_entry()
    {
        if (scanLinkset())
        {
            //llOwnerSay("resizer script ready");
        }
        else
        {
            llRemoveInventory(llGetScriptName());
        }
    }
    
    link_message(integer sender_num, integer command, string str, key id)
    {
        if (command == LinkResize) {
            makeMenu();
        }
    }
}