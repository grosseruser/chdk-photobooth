--[[
@title PhotoBooth_x
# verif = 2 "MoDect time before seq. (s)" [0 99]
# shots = 3 "Shots to take in seq." [1 99]
# delay = 2 "Delay between each shot (s)" [0 99]
# rearm = 3 "Re-arm delay afer seq. (s)" [0 99]
# gain = 3 "MoDect Threshold (1-255)" [1 255]
# snd = 1 "Sounds" [0 1]
# led = 1 "LED" [0 1]
# debug = 0 "Debug mode" [0 1]
--]]

-- Carl Chan 2012
-- carl.chan@proudlygeeky.net
-- Martin Klein 2026

----
function cameraready()
    if( get_flash_mode() == 2 ) then
	  return get_shooting()
    else
	  return not get_shooting() and get_flash_ready()
    end
end

function shootphoto()
--Pre-shoot warning, sound+led
    if (led) then set_led(9,1,30) end
    if (snd) then play_sound(4) end
    if (led) then 
	  sleep(100)
	  set_led(9,1,1)
    end
    
    if( debug > 0 ) then
	  play_sound(1)
    else
	  shoot()
    end
    
    repeat sleep(50) until cameraready() == true
end

--detect continuous motions for TIME seconds
--returns true if there was motion detected more than 50% of the time in the interval specified
function continuousmotion( time )
	if( time == 0 ) then
		return true
	else
		motion=0
		loop = time * 2
		for i=1,loop do
		    t_end = get_tick_count + 500
		    contmotion=md_detect_motion(6,6,1,500,10,gain,debug,0,0,0,0,0,0,0,2,0)
		    if( contmotion > 0 ) then
			  motion=motion+1
			  repeat sleep(10) until (get_tick_count>=t_end) -- wait until the scheduled time has elapsed
		    end
		end
		return ( motion > time )
	end
end

-- Main Loop
set_record(1)
rec,vid,mode=get_mode()
if rec and not vid then
    -- remove all other display stuff
    --set_prop_str(105,1)
    repeat
	  cls()
	  set_led(9,0,0)
	  print("Photobooth ready!")
	  zones=md_detect_motion(6,6,1,600000,10,gain,1,0,0,0,0,0,0,0,2,0)
	  if( zones > 0 ) then
		--Turn on LED when initial motion is detected
		if (led) then set_led(9,1,1) end
		--Motion detected, check for "verif" seconds of continuous motion before starting series
		--This prevents accidental triggering of photobooth if someone is just walking by
		if ( continuousmotion(verif) ) then	
		    --Start photo process
		    print("Smile for the camera!")
		    for i=1,shots do
			  print("Picture #" .. i .. "/" .. shots)
			  shootphoto()
			  if (i<shots) and (delay>0) then 
				--Checking for movement during the photoshoot is not a good idea, when everyone is supposed to be holding stil
				for j=0,delay do sleep(1000) end
			  end
		    end
		    print("All done! Next!")
		    set_led(9,0,0)
		    if (rearm>0) then
			  for j=0,rearm do sleep(1000) end
		    end
		else
		    set_led(9,0,0)
		end
	  end
    until false
else
    print("Camera must be in photo mode")
    print("Photobooth stopped.")
end
