--====================================================================--
-- Main Intro Page
-- Provide logins for personas
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2016
 
 - Mail: ttuning@us.ibm.com

******************
 - INFORMATION
******************

  - Main launching point for application
  - Supports 2 personas:  Facilities Manager, Technician
--]]


local Widget = require( "widget" )
local GGData = require( "lib.GGData" )
local GlblData = require ( "lib.glbldata"  )
local BuildingData = require ( "lib.buildingdata" )  -- static room data for test
local rgb = require ( "lib._rgb" )

local composer = require "composer"
-- Variables local to scene
local scene = composer.newScene()

	------------------
	-- Constants
	------------------
	local _DW = display.contentWidth 
    local _DH = display.contentHeight
	
	---------------------------
	--  Functions 
	----------------------------
	----------------------------
	-- Object position Function
	----------------------------
	
	local Position = function ( object , Xpercent, Ypercent )
	
		object.x = ((Xpercent / 100 ) * _DW)
		object.y = ((Ypercent / 100 ) * _DH)
		
	 return ( object )	
	end
	
	--  common exit operations
	local exitpage = function ()
	    print ("leaving Intro page")
	end	 
	
	
	
	
	
	------------------
	-- Listeners
	------------------

	
	local touch_Store = function ( event )
		if event.phase == "ended" then
		    exitpage()
			local options = {
				effect = "fade",
				time = 500,
					params = {
						someKey = "someValue",
						someOtherKey = 10
						}
					}
			composer.gotoScene( "scene.Store", options ) -- Go to Intro screen
		end
	end
	
	local touch_Tech = function ( event )
		if event.phase == "ended" then
			exitpage()
			local options = {
				effect = "fade",
				time = 500,
					params = {
						someKey = "someValue",
						someOtherKey = 10
						}
					}
			composer.gotoScene( "scene.Tech", options ) -- Go to Intro screen
		    -- director:changeScene("Tech" , "crossfade")
		end
	end 
	
	local touch_Feedback = function ( event )
		if event.phase == "ended" then
			system.openURL( "http://www.ibm.com/iot" )
		end
	end
    
    
	
	------------------
	-- Variables
	------------------
	
	local sv = {}  -- scene variables 
	local _L = {}  -- local variables
	
	------------------
	-- Groups
	------------------
	
	local localGroup
	
local new = function ( self, event )

	local currenttheme = BuildingData.themes.activetheme
	GlblData.theme = BuildingData:loadtheme(currenttheme)
	local theme = GlblData.theme 
	localGroup = self.view -- add display objects to this group
	localGroup.myname = "Intro"
	
	------------------
	-- Display Objects
	------------------
	
			
	local background = display.newImageRect( "pictures/BKG.png" , display.viewableContentWidth , display.viewableContentHeight)
	-- local background = display.newRect( localGroup, 0,0,  _DW * _ISM , _DH * _ISM )
	background.anchorX , background.anchorY = 0,0  --  anchor object at top left corner
	background.alpha = 1
	-- background.x = display.contentCenterX; background.y = display.contentCenterY;
	
	-- local backgroundtitlebar = display.newImageRect( "pictures/tbar.png" , 720 , 30  )
	local backgroundtitlebar = display.newRect( localGroup, 0,0,  570,  32 )
	backgroundtitlebar.anchorX , backgroundtitlebar.anchorY = 0,0  --  anchor object at top left corner
	backgroundtitlebar.alpha = .8
	
	
	local backgroundsidebar = display.newRect( localGroup ,0,0 , 33 , 360  )
	backgroundsidebar.anchorX , backgroundsidebar.anchorY = 0,0  --  anchor object at top left corner
	backgroundsidebar.alpha = .8
		
	local title = display.newText( theme.title, 0, 0, native.systemFontBold, 10 )
	
	local store = display.newText( "Facilities Mgr.", 0, 0, native.systemFontBold, 12 )
	local stellaTX = display.newText( "Stella", 0, 0, native.systemFontBold, 12 )
	
	
	local district = display.newText( "Technician", 0, 0, native.systemFontBold, 12 )
	local danTX = display.newText( "Dan", 0, 0, native.systemFontBold, 12 )
	
	local feedback = display.newText( "Learn more at IBM.com/IoT", 0, 0, native.systemFontBold, 12 )
	
	local dan = display.newImageRect( "pictures/dan.png" , 50, 56  )
	local stella = display.newImageRect( "pictures/stella.png" , 50, 56  )
	
	--====================================================================--
	-- INITIALIZE
	--====================================================================--
	
	local InitializeData = function () 
	    

	end	
	
	local function initVars ()
		
		------------------
		-- Inserts
		------------------
		
		localGroup:insert( background )
		localGroup:insert( backgroundsidebar )
		localGroup:insert( backgroundtitlebar )
		
		localGroup:insert( title )
		localGroup:insert( feedback )
		localGroup:insert( store )
		localGroup:insert( district )
		localGroup:insert( stella )
		localGroup:insert( dan )
		localGroup:insert( stellaTX )
		localGroup:insert( danTX )
		------------------
		-- Positions
		------------------
		Position(title,25, 5)
		Position(feedback, 24, 90)
		Position(store, 25, 25)
		Position(stella, 25, 40)
		Position(stellaTX, 25, 58)
		Position(district, 50, 25)
		Position(dan, 50, 40)
		Position(danTX, 50, 58)
		
		-- background.x = display.contentCenterX; background.y = display.contentCenterY;
		
		------------------
		-- Colors
		------------------
		
		title:setFillColor( unpack(theme.title_clr) )
		backgroundtitlebar:setFillColor( unpack(theme.clr_header) )
		backgroundsidebar:setFillColor( unpack(theme.clr_text) )
		feedback:setFillColor( unpack(theme.clr_text) )
		store:setFillColor   ( unpack(theme.clr_text) )
		district:setFillColor( unpack(theme.clr_text) )
		stellaTX:setFillColor( unpack(theme.clr_text) )
		danTX:setFillColor   ( unpack(theme.clr_text) )
		
		------------------
		-- Add Listeners to display items 
		------------------
		
		store:addEventListener( "touch" , touch_Store )
		stella:addEventListener( "touch" , touch_Store )
		district:addEventListener( "touch" , touch_Tech )
		dan:addEventListener     ( "touch" , touch_Tech )
		feedback:addEventListener( "touch" , touch_Feedback )
	
		
	end

	------------------
	-- Initiate variables
	------------------
	InitializeData()
	initVars()
return 
	
end 
	
	
function scene:create( event )
	
	new(self,event)
	
end 	
	

function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
	print ("Intro: show: will")
		
  elseif ( phase == "did" ) then
	print ("Intro: show: did")
    --audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
    print ("Intro: hide: will")
  elseif ( phase == "did" ) then
    print ("Intro: hide: did")
  end
end

function scene:destroy( event )
	print ("Intro: destroy")
	_L = nil 
	sv = nil 
  
end	
	
	------------------
	-- MUST return a display.newGroup()
	------------------
	scene:addEventListener("create")
	scene:addEventListener("show")
	scene:addEventListener("hide")
	scene:addEventListener("destroy")

return scene
	
