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

vector colorFromString (string vectorString) {

    list colorList = llParseString2List (vectorString, [" "], []);
    vector result;
    result.x = llList2Float (colorList, 0);
    result.y = llList2Float (colorList, 1);
    result.z = llList2Float (colorList, 2);
    
    return (result);}
integer attached = -1;   
float alpha = 1;
string AgentUserName;

default
{
    

    touch_start(integer total_number)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            llListen( 0, "", NULL_KEY, "" );
            llSetTimerEvent(60);
            llSay(0,"Say a command...");
            llSay(0,"Say \"board help\" for a list of commands");
        }
    }
    
    timer()
    {
        llSay(0,"Listen timer has expired. Touch again to say a command.");
        llListenRemove(0);
        llResetScript();
    }
    
    listen(integer channel,string name,key id,string message)
    {
        if (id == llGetOwner())
            {
            
            
            if (llGetSubString(llToLower(message), 0, 10) == "board color")
            {
               string color = llGetSubString (message, 12, llStringLength (message));
               vector finalcolor = colorFromString(color);   
               llMessageLinked(LINK_ALL_CHILDREN, LinkColourChange,(string)(finalcolor/255), NULL_KEY);
               llSetTimerEvent(60);
            } 
            else if (llGetSubString(llToLower(message), 0, 11) == "board attach")
            {
                 llRequestPermissions(llGetOwner(), PERMISSION_ATTACH);
                 llSetTimerEvent(60);
                 
            }
            else if (llGetSubString(llToLower(message), 0, 10) == "board drop")
            {
                 llRequestPermissions(llGetOwner(), PERMISSION_ATTACH);
                 llSetTimerEvent(60);
            }
            else if (llGetSubString(llToLower(message), 0, 11) == "board resize")
            {
                llMessageLinked(LINK_SET, LinkResize,"", NULL_KEY);
            }
            else if (llGetSubString(llToLower(message), 0, 9) == "board face")
            {
                if (llGetSubString(llToLower(message), 11, llStringLength(message)) == "right")
                {
                    llMessageLinked (LINK_SET, LinkFaceChange, "right", NULL_KEY);   
                }
                else if (llGetSubString(llToLower(message), 11, llStringLength(message)) == "left")
                {
                    llMessageLinked (LINK_SET, LinkFaceChange, "left", NULL_KEY);
                }
                    
            }
            else if (llGetSubString(llToLower(message), 0, 15) == "board seatheight")
            {
                llMessageLinked (LINK_SET, LinkSeatHeight, llGetSubString(message, 17,llStringLength(message)), NULL_KEY);
            }
            /*else if (llGetSubString(llToLower(message),0,1) == "gp")
            {
                llSensor("", NULL_KEY, AGENT, 96, PI); // scan for agents/avatars within 10 metres
                AgentUserName = llGetSubString(message,3,llStringLength(message));
            }*/
            else if (llToLower(message) == "board help")
            {
                llSay(0,"
                [Nyxeka] Swift Board Instructions
                To change the seat height, say \"board seatheight xx.xx\" xx.xx being any number between 00.00 - 10.00
                to resize the board, make sure that no one is sitting on the vehicle, touch it, and say \"board resize x.x\" x.x being a size multiplyer.
                To change the colour, touch the board, then say \"board color x y z\", x y and z being red green and blue, respectively
                To attach the board, touch the board and say \"board attach\"
                To detach the board into your inventory, say \"board drop\"
                To change the direction you face when your on the hoverboard, get off the hoverboard, touch the hoverboard, and say \"board face left\" or \"board face right\"
                For a Color Reference, say \"boardcolorhelp\"
                To Reset the Owner, say \"resetowner\"
                You can also check out the internal help notecard for a hard copy of these instructions.
                
                ");
            } 
            else if (llToLower(message) == "boardcolorhelp")
            {
                llGiveInventory(llGetOwner(), "Color Reference");      
            }
            else if (llToLower(message) == "resetowner")
            {
                llMessageLinked(LINK_SET,5,"reset",NULL_KEY);   
            }
            else if (llGetSubString(llToLower(message),0,10) == "board speed")
            {
                llMessageLinked(LINK_SET,LinkSpeedChange,llGetSubString(message,12,llStringLength(message)),NULL_KEY);   
            }
        }
        
    }
    //Search for the Agent's anme you just called
    sensor(integer total_number) // total_number is the number of avatars detected.
    {
        integer i;
        llWhisper(0,"Searching...");
        for (i = 0; i < total_number; i++)
        {
            if (llSubStringIndex(llDetectedName(i),AgentUserName) != -1)
            {
                llMessageLinked (LINK_SET,LinkDemoUser,(string)llDetectedKey(i),NULL_KEY); 
                llSay(0,"Gave permissions to " + llDetectedName(i));
                return;  
            }
        }
    }
    
    run_time_permissions(integer perm) {
        if (perm & PERMISSION_ATTACH)  {
            if (llGetAttached() > 0)
            {
                llDetachFromAvatar();
            }
            else
            {
                llAttachToAvatar(ATTACH_BACK);
            }
        }
    }
    
}
