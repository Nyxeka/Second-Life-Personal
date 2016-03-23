//////////////////////////////////////////
//                                      //
//      [Nyxeka] HoverBoard Script      //
//        By: Nicholas J. Hylands       //
//              5/12/2011               //
//                                      //
//////////////////////////////////////////

//////////////////////////////////////////
//
//        Link Globals
//

integer LinkSeatHeight   = 1;
integer LinkFaceChange   = 2;
integer LinkDemoUser     = 3;
integer LinkColourChange = 4;
integer LinkSpeedChange  = 6;

string sitAnim     = "Hoverboard_Normal";
string leanLeft    = "Hoverboard_Lean_Left";
string leanRight   = "Hoverboard_Lean_Right";
string leanBack    = "Hoverboard_Lean_Back";
string leanForward = "Hoverboard_Lean_Forward";
string leanDown    = "Hoverboard_Lean_Down";
string orientation = "left";
string currentAnim = sitAnim;
string lastAnim = sitAnim;
vector seatPos = <-0.35,0.0,0.49>;
string currentRegion;
string lastRegion;
float VehicleSpeed = 25;
float turnSpeed = 1;

list castRayResults;
integer counter;

key USER;

float bankAmount;
vector local_vel;

float flyHeight = 2.0;

vector angular_motor;
vector linear_motor;

integer currentHeld;
integer lastHeld;

integer bankingRight = 2;
integer bankingLeft = 3;
integer goingBackwards = 4;

float gravity; //the gravity on the board. -9.8 is Earth gravity.
float verticalForceMult=3; //This is for multiplying the vertcal force (gravity) of the board, for when
                         //it is moving UP.
float floatheight;
float timespeedForTimer;

handleNewRegion (string regionName) {

    llWhisper(0,"Entered Sim: "+regionName);
    if (!llGetStatus (STATUS_PHYSICS))
        llSetStatus (STATUS_PHYSICS, TRUE);
    llStopAnimation(lastAnim);
    llStartAnimation(currentAnim);
}

vector RotToVector(rotation myRot){
    vector myVec;
    myVec = llRot2Euler(myRot); 
    myVec *= RAD_TO_DEG;
    return myVec;
}

default
{
    on_rez(integer start_params)
    {
        USER = llGetOwner();
        
        llSetStatus(STATUS_PHYSICS, FALSE);
    }
    
    state_entry()
    {
        USER = llGetOwner();
        llPassCollisions(TRUE);
        
        llSetSitText("Ride");
        llSitTarget(seatPos,ZERO_ROTATION);
        
        llSetCameraEyeOffset(<-5.0, -0.00, 2.0> );
        llSetCameraAtOffset(<3.0, 0.0, 2.0> );
        
        llSetVehicleType(VEHICLE_TYPE_AIRPLANE);
        
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.6);
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.1);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 2);
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 2);
        
        
        llSetVehicleFloatParam( VEHICLE_HOVER_HEIGHT, flyHeight );
        llSetVehicleFloatParam( VEHICLE_HOVER_EFFICIENCY, 1.0 );
        llSetVehicleFloatParam( VEHICLE_HOVER_TIMESCALE, 0.9);
        llSetVehicleFloatParam( VEHICLE_BUOYANCY, 1.0 );
        
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 0.57);
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 0.4);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.01);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.8);
        
        llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <15.0,1.0,1000> );
        llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <1000,1000,50> );
        
        
        llRemoveVehicleFlags(VEHICLE_FLAG_LIMIT_ROLL_ONLY | VEHICLE_FLAG_HOVER_UP_ONLY);
        
        llSetVehicleFlags(VEHICLE_FLAG_NO_DEFLECTION_UP);
        
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.5);
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 0.5);
        
        llSetVehicleFloatParam(VEHICLE_BANKING_EFFICIENCY, 1.0);
        llSetVehicleFloatParam(VEHICLE_BANKING_TIMESCALE, 0.1);
        llSetVehicleFloatParam(VEHICLE_BANKING_MIX, 1.0);
        
        //llSetVehicleFloatParam(VEHICLE_BUOYANCY, 0.0);
        llCollisionSound("", 0.0);
        
    }
    
    link_message(integer sender_num, integer command, string str, key id)
    {   
        if (command == LinkSeatHeight)
        {
            seatPos.z = ((float)llGetSubString(str, 0, llStringLength(str)))/10;
            llWhisper(0,"Seat height set");
        } else if (command == LinkFaceChange)
        {
            if  (llToLower(llGetSubString(str, 0, llStringLength(str))) == "right")
            {
                sitAnim     = "Hoverboard_Normal_MIRROR";
                leanLeft    = "Hoverboard_Lean_Left_MIRROR";
                leanRight   = "Hoverboard_Lean_Right_MIRROR";
                leanBack    = "Hoverboard_Lean_Back_MIRROR";
                leanForward = "Hoverboard_Lean_Forward_MIRROR";
                leanDown    = "Hoverboard_Lean_Down_MIRROR";
                llWhisper(0,"face set.");
            } else if (llToLower(llGetSubString(str, 0, llStringLength(str))) == "left")
            {
                sitAnim     = "Hoverboard_Normal";
                leanLeft    = "Hoverboard_Lean_Left";
                leanRight   = "Hoverboard_Lean_Right";
                leanBack    = "Hoverboard_Lean_Back";
                leanForward = "Hoverboard_Lean_Forward";
                leanDown    = "Hoverboard_Lean_Down";
                llWhisper(0,"face set.");
            }
            
        }
        else if (command == LinkDemoUser)
        {
            USER = (key)str;
            //state demo;
        }
        else if (command == 5)
        {
            USER = llGetOwner();
            llWhisper(0,"Owner reset.");
            llResetScript();
        }
        else if (command == LinkSpeedChange)
        {
            if (str == "default")
            {
                VehicleSpeed = 25;
            } else {
                VehicleSpeed = (float)(str);
            }
        }
        
        llSitTarget(seatPos,ZERO_ROTATION);
        
    }

    changed(integer change)
    {
        
        if (change & CHANGED_LINK)
        {
            //The llAvatarSitOnTarget function will let us find the key 
            // of an avatar that sits on an object using llSitTarget
            // which we defined in the state_entry event. We can use 
            // this to make sure that only the owner can drive our vehicle.
            // We can also use this to find if the avatar is sitting, or is getting up, because both will be a link change.
            // If the avatar is sitting down, it will return its key, otherwise it will return a null key when it stands up.
            key agent = llAvatarOnSitTarget();

            //If sitting down.
            if (agent == llGetOwner())
            {
                if (USER == NULL_KEY) {
                    
                    USER = llGetOwner();
                }
                //We don't want random punks to come stealing our 
                // motorcycle! The simple solution is to unsit them,
                // and for kicks, send um flying.
                if (agent != USER)
                {
                    llSay(0, "You aren't the owner"); //Deny the false user access
                    llUnSit(agent);
                    llSetStatus(STATUS_PHYSICS, FALSE);
                
                vector currentRot;
                rotation quaternionn;
                quaternionn = llGetRot();
                currentRot = llRot2Euler(quaternionn);
                //currentRot += <0.0,0.0,PI_BY_TWO>;
                quaternionn = llEuler2Rot(currentRot);
                //I have no idea why, but for some reason, the only way
                //to get it to work is to go through ALL of that crap, as in, 
                //converting it and then converting it back. (idk why)
                llSetRot(quaternionn);
                llReleaseControls();
                llStopAnimation(lastAnim);
                llStopAnimation(currentAnim);
                //Tell the rest of the board that we're "off"
                llMessageLinked(LINK_ALL_OTHERS, 0, "off", "");
                llPlaySound("stop",1.0);
                llStopSound();
                llSetTimerEvent(0.01);
                }
                // If you are the owner, lets ride!
                else
                {
                    //The vehicle works with the physics engine, so in 
                    // order for a object to act like a vehicle, it must first be
                    // set physical.
                    llSetStatus(STATUS_PHYSICS, TRUE);
                    //Set the animations
                    llRequestPermissions(agent, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
                    //We will play a little "startup" sound.
                    llPlaySound("start",1.0);
                    llLoopSound("hoverbikesound", 0.7);
                    llSetTimerEvent(0.01);
                    //Let the rest of the board know we're "on"
                    llMessageLinked(LINK_ALL_OTHERS, 0, "on", "");
                }
            }
            //The null key has been returned, so no one is driving anymore.
            else
            {
                llSetStatus(STATUS_PHYSICS, FALSE);
                
                vector currentRot;
                rotation quaternionn;
                quaternionn = llGetRot();
                currentRot = llRot2Euler(quaternionn);
                //currentRot += <0.0,0.0,PI_BY_TWO>;
                quaternionn = llEuler2Rot(currentRot);
                //I have no idea why, but for some reason, the only way
                //to get it to work is to go through ALL of that crap, as in, 
                //converting it and then converting it back. (idk why)
                llSetRot(quaternionn);
                llReleaseControls();
                llStopAnimation(lastAnim);
                llStopAnimation(currentAnim);
                //Tell the rest of the board that we're "off"
                llMessageLinked(LINK_ALL_OTHERS, 0, "off", "");
                llPlaySound("stop",1.0);
                llStopSound();
                llSetTimerEvent(0.);
            }
        }

    }
    //#################################################################
    //#################################################################
    //#################################################################
    //#################################################################
    //#################################################################
    //#########################Notice me FFS###########################
    //#################################################################
    //#################################################################
    //#################################################################
    //#################################################################
    //#################################################################
    // I put this here so that I could actually find the timer function when scrolling through the code.
    timer()
    {
        llSetForce(<0.0,0.0,gravity>,0);
        timespeedForTimer = (timespeedForTimer + 0.05);
        if (timespeedForTimer > (2 * 3.14159265358)){
            timespeedForTimer = 0;
        }
        castRayResults = llCastRay(llGetPos(), llGetPos()+<0.0,0.0,-1.0 + llCos(timespeedForTimer/10)>, [] );
        if (llList2Integer(castRayResults, -1) > 0){
            llApplyImpulse(<0.0,0.0,1.2356>, 1);
        } 
        
    }
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    run_time_permissions(integer perm)
    {
        if (perm)
        {
            llStartAnimation(sitAnim); //start sit anim
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT | CONTROL_UP | CONTROL_DOWN, TRUE, FALSE); //take controls.
            //set some sexy camera controls
            llSetCameraParams([
            CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
            CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
            CAMERA_BEHINDNESS_LAG, 0.1, // (0 to 3) seconds
            CAMERA_DISTANCE, 4.0, // ( 0.5 to 10) meters
            //CAMERA_FOCUS, <0,0,5>, // region relative position
            CAMERA_FOCUS_LAG, 0.05 , // (0 to 3) seconds
            CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
            CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
            CAMERA_PITCH, 7.0, // (-45 to 80) degrees
            //CAMERA_POSITION, <0,0,0>, // region relative position
            CAMERA_POSITION_LAG, 0.06, // (0 to 3) seconds
            CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
            CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
            CAMERA_FOCUS_OFFSET, <0,0,0> // <-10,-10,-10> to <10,10,10> meters
            ]);
        }
    }
    
    control(key id, integer level, integer edge)
    {
        angular_motor = <0.0,0.0,0.0>;
        linear_motor = <0.0,0.0,0.0>;
        local_vel = llGetVel() / llGetRot();
        
        if((level & CONTROL_FWD) && !((level & CONTROL_ROT_RIGHT) | (level & CONTROL_ROT_LEFT)))
        {
            //The Maximum linear motor direction is 25, and will try to 
            // get us up to 25 m/s - things like friction and the
            // motor decay timescale can limit that.
             angular_motor += <0.0,3.0,0.0>;
             linear_motor.x += VehicleSpeed;
             currentAnim = sitAnim;
             
        } else if(level & CONTROL_FWD && ((level & CONTROL_ROT_RIGHT) | (level & CONTROL_ROT_LEFT)))
        {
            //The Maximum linear motor direction is 25, and will try to 
            // get us up to 25 m/s - things like friction and the
            // motor decay timescale can limit that.
            // angular_motor += <0.0,3.0,0.0>;
             linear_motor.x += VehicleSpeed;
             currentAnim = sitAnim;
             
        }
        if(level & CONTROL_BACK)
        {
            
            
            //myActualVel = llSqrt(llPow(myVelocity.x,2.) + llPow(myVelocity.y,2.));
            //llSay(0,"" + (string)myActualVel);
             //angular_motor -= <0.0,myActualVel*0.3,0.0>;
             angular_motor += <0.0,-3.0,0.0>;
             linear_motor.x -= VehicleSpeed/2;
             currentAnim = leanBack;
             currentHeld = goingBackwards;
             
        } else {
            currentAnim = sitAnim;
        }
       
           // llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.0);
            //llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 0.0);  
            
             if(level & (CONTROL_ROT_RIGHT))
            {
                angular_motor.z -= turnSpeed;
                angular_motor.x += 15*(llVecMag(llGetVel())/10) + 1;
                currentAnim = leanRight;
                currentHeld = bankingRight;
                //linear_motor.y += 3.5;
            }
            else if(level & (CONTROL_ROT_LEFT))
            {
                angular_motor.z += turnSpeed;
                angular_motor.x -= 15*(llVecMag(llGetVel())/10) + 1;
                currentAnim = leanLeft;
                currentHeld = bankingLeft;
                //linear_motor.y -= 3.5;
            }
            
            if(level & (CONTROL_RIGHT))
            {
                angular_motor.z = 0;
                angular_motor.x += 5*(VehicleSpeed/20);
                currentAnim = leanRight;
                currentHeld = bankingRight;
                linear_motor.y -= VehicleSpeed/2;
                //linear_motor.y += 3.5;
            }
            else if(level & (CONTROL_LEFT))
            {
                angular_motor.z = 0;
                angular_motor.x -= 5*(VehicleSpeed/20);
                currentAnim = leanLeft;
                currentHeld = bankingLeft;
                linear_motor.y += VehicleSpeed/2;
                //linear_motor.y -= 3.5;
            } 
        
        
        if(level & CONTROL_UP)
        {
            if (gravity != (4.9*verticalForceMult)){
                gravity = 4.9*verticalForceMult;
                llSetVehicleFlags(VEHICLE_FLAG_HOVER_UP_ONLY);
            }
        }else {
            if (gravity != -9.8){
                gravity = -9.8;
                llRemoveVehicleFlags(VEHICLE_FLAG_HOVER_UP_ONLY);
            }
        }
        if((level & CONTROL_DOWN) && !(level & CONTROL_FWD))
        {
            angular_motor -= <-local_vel.y,local_vel.x*0.5,0.0>;
            currentAnim = leanBack;
        }
        
        linear_motor.x += angular_motor.y;
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION,angular_motor);
        
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION,linear_motor );
        turnSpeed = 3.2;
        
        if (currentAnim == "")
        {
            currentAnim = sitAnim;
        }
        llStopAnimation(lastAnim);
        llStartAnimation(currentAnim);
        lastAnim = currentAnim;
        lastHeld = currentHeld;
        
    }

}



















