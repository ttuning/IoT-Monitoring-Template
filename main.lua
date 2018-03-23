--====================================================================--
-- Business App beta
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2018
 
 - Mail: ttuning@us.ibm.com

******************
 - INFORMATION
******************

  - Main launching point for application
  - Supports 2 personas:  Facilities Manager, Technician
  
--]]

--====================================================================--
--  Required modules
--====================================================================--

local composer = require( "composer" )
local GlblData = require ( "lib.glbldata" )  -- store global data between modules. 

display.setStatusBar( display.HiddenStatusBar )  -- Removes status bar

-- Removes bottom bar on Android 
if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
	native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
	native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end
--====================================================================--
-- MAIN FUNCTION
--====================================================================--

local main = function ()
	
	local options = {
		effect = "fade",
		time = 500,
			params = {
				someKey = "someValue",
				someOtherKey = 10
			}
		}
	
	composer.gotoScene( "scene.Intro", options ) -- Go to Intro screen
	
	------------------
	-- Return
	------------------
	
	return true
end
-- local devicetype = function ()
	-- if string.sub(system.getInfo("model"),1,4) == "iPad" then 
		-- GlblData.Dtype = "ipad" 
	-- elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then  -- Iphone 5 
		-- GlblData.Dtype = "iphone5" 
	-- elseif string.sub(system.getInfo("model"),1,2) == "iP" then  -- iphone 3 and 4 
		-- GlblData.Dtype = "iphone4" 
	-- elseif display.pixelHeight / display.pixelWidth > 1.72 then --  adroid phone
		-- GlblData.Dtype = "aphone" 
	-- else GlblData.Dtype = "atablet"  -- Andriod tablet 
	-- end
-- end

--====================================================================--
-- BEGIN
--====================================================================--

main()

