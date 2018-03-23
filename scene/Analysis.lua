--====================================================================--
-- Main Facilities Manager Page Page
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2016
 
 - Mail: ttuning@us.ibm.com

******************
 - INFORMATION
******************

  
--]]

	local Widget = require( "widget" )
	local GGData = require( "lib.GGData" )
	local GlblData = require ( "lib.glbldata" )
	local rgb = require ( "lib._rgb" )
	local Timez = require ( "lib.Timez" )  -- keep track of timers
	local BuildingData = require ( "lib.buildingdata" )  -- static room data for test
	local RGF = require ( "lib.RGF" )  -- Room group object functions
	local RF = require ( "lib.RF" )    -- Room object common functions
	local theme = GlblData.theme 

local composer = require "composer"
-- Variables local to scene
local scene = composer.newScene()
local sv = {}  -- scene variables 
local sf = {}  -- scene functions 
sv.charttype = "line"

new = function (self , event )
    print ("Analysis module")
	
	
	------------------
	-- Constants
	------------------
	local _DW = display.contentWidth 
    local _DH = display.contentHeight
	
	
	local _Hheaders = 36
	local _Wheaders = 30
	local _Margins  = 30
	print ("display.contentWidth  display.contentHeight", display.contentWidth , display.contentHeight )
	local _usableW  = _DW - _Margins
	local _usableH =  _DH - _Margins - _Hheaders
    local _Aratio = display.contentWidth / display.contentHeight
	print ( "display.contentWidth size " , display.contentWidth , display.contentHeight , _Aratio )
	-- local _RBoxW  = _usableW * .35   -- right box smaller ones
	-- local _RBoxH  = ( _usableH ) / 2 
	
	local _LBoxW  = _usableW * 1   -- left box bigger one 
	local _LBoxH  = ( _usableH + 4 )
	
	
	
	------------------
	-- Variables
	------------------
	
	local currenttime = os.time()  -- # of seconds since 1970
	local starttime = currenttime 
	local allTimers = Timez:new()  --  Table to hold all my timers
	GlblData.allTimers = allTimers  --  need to pass this popup screen
	GlblData.currObject = {}  --  hold fields for currently selected object 
	GlblData.currObject.buildingname = "C"
	GlblData.currObject.buildingentry = 1  -- # entry in table that describes bldgs.
	GlblData.currObject.floorname = "1"
	GlblData.currObject.floorentry = 1  
	GlblData.currObject.roomname = "room4af"  
	GlblData.currObject.roomentry = 1  
	local EXITING = false
	local bldingparms = {}    --  parms which describe the building
	local roomparms = {}    --  parms which describe a set of rooms
	local roomdata = {}     --  Table to hold room data objects
	local updatecharts2    
	------------------
	-- Network test
	------------------
	local json = require( "json" )
	
	local function networkListener( event )

		if ( event.isError ) then
			print( "Network error: ", event.response )
		else
			print ( "RESPONSE: " .. event.response )
			local decoded, pos, msg = json.decode( event.response, 2 )
			if not decoded then
				print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
			else
				print( decoded.current_observation.feelslike_string ) 
			end
		end
	end	

	local headers = {}

	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Accept-Language"] = "en-US"
	headers["Accept"] = "application/json"

	local body = "color=red&size=small"

	local params = {}
	params.headers = headers
	params.body = body

	--local requestID = network.request( "http://api.wunderground.com/api/3089ed8c6e32c679/conditions/q/CA/San_Francisco.json", "GET", networkListener, params )
	
	------------------
	-- Groups
	------------------
	
	local localGroup = self.view -- add display objects to this group
	localGroup.myname = "Store"
	
	------------------
	-- Display Objects
	------------------
	
			
	local background = display.newRect( localGroup, 0,0,  570, 360 )
	background.anchorX , background.anchorY = 0,0  --  anchor object at top left corner
	background.alpha = 1
	
	local backgroundtitlebar = display.newRect( localGroup, 0,0,  570,  25 )
	backgroundtitlebar.anchorX , backgroundtitlebar.anchorY = 0,0  --  anchor object at top left corner
	backgroundtitlebar.alpha = .8
	
	local accentbar = display.newRect( localGroup, 0,0,  35,  2 )   -- bar that highlights which view we are on.
	accentbar.anchorX , accentbar.anchorY = .5,.5  --  anchor object at middle
	accentbar.alpha = 1
	
	local title = display.newText( theme.title, 0, 0, native.systemFontBold, 10 )
	local title2 = display.newText( theme.subtitle, 0, 0, native.systemFont, 10 )
	local subtitle1 = display.newText( "Overview", 0, 0, native.systemFont, 8 )
	local subtitle2 = display.newText( "Activity", 0, 0, native.systemFont, 8 )
	local subtitle3 = display.newText( "Analytics", 0, 0, native.systemFont, 8 )
	local Filtertitle1 = display.newText( "Filters:", 0, 0, native.systemFontBold, 8 )
	local Filtertitle2 = display.newText( "Building", 0, 0, native.systemFont, 8 )
	local Filtertitle3 = display.newText( "Floor", 0, 0, native.systemFont, 8 )
	local Filtertitle4 = display.newText( "room", 0, 0, native.systemFont, 8 )
	
	local Filtertitlebox2 =  display.newRect( localGroup, 0,0,  15,  9 )
	Filtertitlebox2.anchorX , Filtertitlebox2.anchorY = .5,.5  --  anchor object at middle
	Filtertitlebox2.alpha = 1
	local Filtertitlebox2text = display.newText( "", 0, 0, native.systemFont, 7)
	
	
	local Filtertitlebox3 =  display.newRect( localGroup, 0,0,  15,  9 )
	Filtertitlebox3.anchorX , Filtertitlebox3.anchorY = .5,.5  --  anchor object at middle
	Filtertitlebox3.alpha = 1
	local Filtertitlebox3text = display.newText( "", 0, 0, native.systemFont, 7)
	
	local Filtertitlebox4 =  display.newRect( localGroup, 0,0,  52,  9 )
	Filtertitlebox4.anchorX , Filtertitlebox4.anchorY = .5,.5  --  anchor object at middle
	Filtertitlebox4.alpha = 1
	local Filtertitlebox4text = display.newText( "", 0, 0, native.systemFont, 7)
	
	
	local stellaTX = display.newText( "Stella", 0, 0, native.systemFontBold, 8 )
	local logoutTX = display.newText( "logout", 0, 0, native.systemFont, 5 )
	
	local feedback = display.newText( "Learn more at IBM.com/IoT", 0, 0, native.systemFontBold, 12 )
	feedback.alpha = 0 ;
	
	local stella = display.newImageRect( "pictures/stella.png" , 15, 17  )
		
	local eventsTX = display.newText( "Usage Charts", 0, 0, native.systemFontBold, 8 )
	eventsTX.anchorX , eventsTX.anchorY = 0,0  --  anchor object at top left corner
	local eventsbox = display.newRect( localGroup, 0,0, _LBoxW,  _LBoxH ) 
	eventsbox.anchorX , eventsbox.anchorY = 0,0  --  anchor object at top left corner
	eventsbox.alpha = 1
	
	---------------------------
	--  charts 
	----------------------------
	
	local baseclassDG = require( "lib.baseclassDG" )
	local GooGChart = require( "lib.GooGChart" )
	local GooGChartClass = GooGChart:inheritsFrom(baseclassDG)
	local datachart
	
	local function segmentedControlListener( event )
		local target = event.target
		print ("Segmented Control\nself.segmentNumber = " .. target.segmentNumber		)
		print ("Segmented Control\nself.segmentLabel = " .. target.segmentLabel		)
		if datachart then 
			if datachart.charttype ~= target.segmentLabel then 
				sv.charttype = target.segmentLabel
				updatecharts2()
			end 
		end 
		
		
	end
	

	Widget.setTheme( "widget_theme_android_holo_light" ) 	-- Create a default segmented control (using widget.setTheme)
	local segmentedControl = Widget.newSegmentedControl {
	    left = 10,
	    top = 0,
	    segments = { "Line", "Column", "Pie" },
	    defaultSegment = 1,
		 segmentWidth = 88,
		labelColor = { default={ unpack(theme.clr_inactive) }, over={unpack(theme.clr_header) } } ,
		emboss = false , 
	    onPress = segmentedControlListener
	}
	localGroup:insert( segmentedControl )
	segmentedControl.x = display.contentCenterX
	segmentedControl.y = _LBoxH - (_LBoxH * .2 )
	segmentedControl.y = _LBoxH + segmentedControl.height
	
	
	
	
	----------------------------
	--  Functions 
	----------------------------
	
	local InitializeBldgRoomData
	      
	----------------------------
	-- Object position Function
	----------------------------
	
	local Position = function ( object , Xpercent, Ypercent )
	
		object.x = ((Xpercent / 100 ) * _DW)
		object.y = ((Ypercent / 100 ) * _DH)
		
	 return ( object )	
	end
	
	local function updatefilters ()
	
		Filtertitlebox2text.text = GlblData.currObject.buildingname
		Filtertitlebox3text.text = GlblData.currObject.floorname
		Filtertitlebox4text.text = GlblData.currObject.roomname
		
	return
	end
	
	local prev_bldg = nil
	local prev_floor = nil
	local prev_room = nil
	local is_transitioning = false
	local is_transitioning2 = false
	local ischartcreated = false
	
		------------------
		-- Listeners
		------------------
		
	
	function updatecharts2 ()
		
		if ischartcreated then	--  delete old chart. 
			datachart:destroy() 
			ischartcreated = false
		end
		-- create new chart.
		ischartcreated = true 
		-- get data from room info
		local datapoints = roomdata[GlblData.currObject.roomentry].usagedata
		-- Is this usage or trend?  
		datachart = GooGChartClass:new()
		local options = {
				title = "Monthly Costs, Work Orders and Satisfaction Totals",
				curvetype = "function", -- function or none 
				lineWidth = 6 ,
				vaxistitle = "Units",
				haxistitle = "Date",
				legend = "right",  -- bottom,left,in,none,right,top
				data = datapoints,
				width = _LBoxW - (_LBoxW * .1 ) ,  
				height = _LBoxH - (_LBoxH * .2 )
				--options = {"colors: ['#a52714', '#097138']"}  -- raw JS that will just be added into the options declaration 
			}
		print ("sv.charttype",sv.charttype)	
		if sv.charttype == "Pie" then 	     datachart:pie  ( options ) 
		elseif sv.charttype == "Column" then datachart:column( options )
		else  datachart:line( options )
		end 	
		localGroup:insert(datachart.DG)	
		datachart.DG.anchorX , datachart.DG.anchorY = 0,0  --  anchor object at top left corner
		datachart:setPosition(datachart.DG, 2, 5 , eventsbox )
		-- print ("eventsbox size " , eventsbox._properties   )
		-- print ("display.pixelWidth " , display.pixelWidth ,   display.contentWidth  )
			
		
	end 
	
	local function updatecharts()   -- Change SAT chart when room changes
		local function callback( )
			is_transitioning = false
		end  -- callback
		-- if room has changed move the needle to current setting
		-- if is_transitioning == false and is_transitioning2 == false then 
			if prev_bldg    ~= GlblData.currObject.buildingname or 
			   prev_floor	~= GlblData.currObject.floorname or 
			   prev_room    ~= GlblData.currObject.roomname then
			   updatecharts2()  --  Refresh charts because of room changes. 
			   -- is_transitioning = true
			   print (roomdata[GlblData.currObject.roomentry].roomname, "roomdata name")
			   print (roomdata[GlblData.currObject.roomentry].customerSAT, "roomdata name")
			   prev_bldg    = GlblData.currObject.buildingname  
			   prev_floor	= GlblData.currObject.floorname  
			   prev_room    = GlblData.currObject.roomname 
			end    
		-- end    
	  return
	end
	------------------
	-- Listeners
	------------------

	local touch_Active = function ( event )
		if event.phase == "ended" then
			local options = { effect = "fade", time = 500, params = {}	}
			datachart:destroy() 
			composer.gotoScene( "scene.Active", options ) -- Go to Intro screen
			timer.performWithDelay(500, function () composer.removeScene( "scene.Analysis" ); end  , 1)
		end
	end
	
	local touch_Store = function ( event )
		if event.phase == "ended" then
			local options = { effect = "fade", time = 500, params = {}	}
			datachart:destroy() 
			composer.gotoScene( "scene.Store", options ) -- Go to Intro screen	
			timer.performWithDelay(500, function () composer.removeScene( "scene.Analysis" ); end  , 1)
		end
	end
	
	
	local touch_logout = function ( event )
		if event.phase == "ended" then
			local options = { effect = "fade", time = 500, params = {}	}
			datachart:destroy() 
			composer.gotoScene( "scene.Intro", options ) -- Go to Intro screen	
			timer.performWithDelay(500, function () composer.removeScene( "scene.Analysis" ); end  , 1)
			-- composer.removeScene( "Analysis" ) 
			
		end
	end
	
	local popClosed_touch_Building = function ( returnedvalues )  --  function called from popuppicker when popup closes.
		local rownum 	
		if returnedvalues then 
			rownum = returnedvalues[1]
		end 
		composer.removeScene("scene.PopUpPicker")
		print ("popup closed", rownum)
		transition.to( localGroup , {time = 800 , delay = 0 , alpha = 1 } )
		GlblData.currObject.buildingentry = rownum - 1
		GlblData.currObject.floorentry = 1 -- default since new building selected.
		GlblData.currObject.roomentry = 1 -- default since new building selected.
		InitializeBldgRoomData()
		updatecharts2()
	end
		
	local touch_Building = function ( event )
		if event.phase == "ended" then
			transition.to( localGroup , {time = 800 , delay = 0 , alpha = .6 } )
			--  construct rows for picker.
			local  rowtable  = {}
			local  buildings = BuildingData:loadbuildings()  -- get all the data for the buildings
			for ii = 1 , #buildings + 1  , 1 do
				rowtable[ii] = {}
			end 
			--print ("building name one is: ", #buildings)
			rowtable[1].kind = "header"; 
			rowtable[1].text = "Select Building"; 
			rowtable[1].rowprefix = ""; 
			rowcounter = 2 
			-- loop thru building data and create rows. 
			for k, v in pairs( buildings ) do
				-- print ("k is ", k ," value is ", v)
				rowtable[rowcounter].kind = "row"	
				rowtable[rowcounter].text = buildings[k].buildingname
				rowtable[rowcounter].rowprefix = "Building:  "
				rowcounter = rowcounter + 1 
			end
		   			
		    -- create popup to choose building choice.
			local options = {
				isModal = true,  -- disable main panel touches 
				effect = "fade",
				effect = "fromTop",
				time = 500,
					params = {
						items = rowtable ,
						boxsize = {150,75},
						boxlocation = {Filtertitle2.x - Filtertitle2.width / 2 , Filtertitle2.y + 9 },
						onClose = popClosed_touch_Building
						}
					}
			datachart:destroy_webview() 		
			composer.showOverlay( "scene.PopUpPicker", options ) -- create popup to choose building choice.			
		    
		end
	end
	
	local popClosed_touch_Floor = function (returnedvalues)  --  function called from composer when popup closes.
		local rowindex 	
		if returnedvalues then 
			rowindex = returnedvalues[1]
		end 
		composer.removeScene("scene.PopUpPicker")
		transition.to( localGroup , {time = 800 , delay = 0 , alpha = 1 } )
		GlblData.currObject.floorentry = rowindex - 1
		InitializeBldgRoomData()
		updatecharts2()
	end
		
	local touch_Floor = function ( event )
		if event.phase == "ended" then
			transition.to( localGroup , {time = 800 , delay = 0 , alpha = .6 } )
			--  construct rows for picker.
			local  rowtable  = {}
			local  floors = BuildingData:loadfloors(GlblData.currObject.buildingentry)  -- get all the data for the buildings
			for ii = 1 , #floors + 1  , 1 do
				rowtable[ii] = {}
			end 
			--print ("building name one is: ", #buildings)
			rowtable[1].kind = "header"; 
			rowtable[1].text = "Select Floor"; 
			rowcounter = 2 
			-- loop thru building data and create rows. 
			for k, v in pairs( floors ) do
				-- print ("k is ", k ," value is ", v)
				rowtable[rowcounter].kind = "row"	
				rowtable[rowcounter].text = floors[k].floorname
				rowtable[rowcounter].rowprefix = "Floor:  "
				rowcounter = rowcounter + 1 
			end
			
		    -- create popup to choose building choice.
			local options = {
				isModal = true,  -- disable main panel touches 
				effect = "fade",
				effect = "fromTop",
				time = 500,
					params = {
						items = rowtable ,
						boxsize = {150,50},
						boxlocation = {Filtertitle3.x - Filtertitle3.width / 2 , Filtertitle2.y + 9 },
						onClose = popClosed_touch_Floor
						}
					}
			datachart:destroy_webview() 		
			composer.showOverlay( "scene.PopUpPicker", options ) -- create popup to choose building choice.		
		    
		end
	end
	

		-- local status = roomdata[GlblData.currObject.roomentry].status
		-- --  -- 1 = green  2 = yellow  3 = red
		-- if status == "1" then statusbar:setFillColor( rgb.color("darkturquoise2" ) )
			-- elseif status == "2" then statusbar:setFillColor( rgb.color("yellow" ) )
			-- elseif status == "3" then statusbar:setFillColor( rgb.color("red" ) )
			-- else  print("Analysis: popClosed_touch_Room:  status illegal value.")
		-- end
		
	local popClosed_touch_Room = function (returnedvalues)  --  function called when popup closes.
		local rowindex 	
		if returnedvalues then 
			rowindex = returnedvalues[1]
		end 
		composer.removeScene("scene.PopUpPicker")
		transition.to( localGroup , {time = 800 , delay = 0 , alpha = 1 } )
		
		GlblData.currObject.roomentry = rowindex - 1
		GlblData.currObject.roomname =  roomdata[GlblData.currObject.roomentry].roomname
		roomdata[GlblData.currObject.roomentry]:highlight();
		updatecharts2()
		
	end
		
	local touch_Room = function ( event )
		if event.phase == "ended" then
			transition.to( localGroup , {time = 800 , delay = 0 , alpha = .6 } )
			--  construct rows for picker.
			local  rowtable  = {}
			local  rooms = BuildingData:loadrooms(GlblData.currObject.buildingentry, GlblData.currObject.floorentry )  -- get all the data for the buildings
			for ii = 1 , #rooms + 1  , 1 do
				rowtable[ii] = {}
			end 
			--print ("building name one is: ", #buildings)
			rowtable[1].kind = "header"; 
			rowtable[1].text = "Select Room"; 
			rowcounter = 2 
			-- loop thru building data and create rows. 
			for k, v in pairs( rooms ) do
				print ("k is ", k ," value is ", v , rooms[k].roomname)
				rowtable[rowcounter].kind = "row"	
				rowtable[rowcounter].text = rooms[k].roomname
				rowtable[rowcounter].rowprefix = "Room:  "
				rowcounter = rowcounter + 1 
			end
		    
		    -- create popup to choose building choice.
			local options = {
				isModal = true,  -- disable main panel touches 
				effect = "fade",
				effect = "fromTop",
				time = 500,
					params = {
						items = rowtable ,
						boxsize = {150,125},
						boxlocation = {Filtertitle4.x - Filtertitle4.width / 2 , Filtertitle4.y + 9 },
						onClose = popClosed_touch_Room
						}
					}
			datachart:destroy_webview() 		
			composer.showOverlay( "scene.PopUpPicker", options ) -- create popup to choose building choice.	
			
		    
		end
	end
	
	local touch_Feedback = function ( event )
		if event.phase == "ended" then
			system.openURL( "http://www.ibm.com/iot" )
		end
	end
	
	local function mainLoop ( event )  --  this loop is called 30 times per second
					
        if not EXITING and not isPaused then 
			
		end  -- not EXITIING or paused
    end
	
	local function secondLoop ( event )  --  this loop is called 1 time per second
			allTimers:pop(event.source)		
			currenttime = currenttime + 1  --  add second
        if not EXITING and not isPaused then 
		    
			updatefilters()
			updatecharts()
		
		end  -- not EXITIING or paused
    end
	
	local function tenminLoop ( event )  --  this loop is called 1 time per 10 minutes
					
        if not EXITING and not isPaused then 
			
		end  -- not EXITIING or paused
    end
	

	--====================================================================--
	-- INITIALIZE
	--====================================================================--
	
	InitializeBldgRoomData = function () -- this isn't local because it was defined at the top of the module
	    
	    roomparms =  BuildingData:loadrooms( GlblData.currObject.buildingentry , GlblData.currObject.floorentry)  --  start with blg 1 floor 1
	    bldingparms =  BuildingData:loadbuilding( GlblData.currObject.buildingentry , GlblData.currObject.floorentry )  --  start with blg 1 floor 1
				
		GlblData.currObject.buildingname =  bldingparms.buildingname
		GlblData.currObject.floorname    =  bldingparms.floors[GlblData.currObject.floorentry].floorname  -- default show first room in table.
		GlblData.currObject.roomname    =  bldingparms.floors[GlblData.currObject.floorentry].rooms[GlblData.currObject.roomentry].roomname  -- default show first room in table.		
		-- delete old rooms if they are there.  
		local ii = 1 
		--  loop thru roomdata table and process
		local roomdataCT = #roomdata  -- 
		print (roomdataCT, "roomdataCT")
	    if roomdataCT > 0 then
			for ii = roomdataCT, 1, -1 do     -- loop through RGF created objects and delete
				local roomobject = roomdata[ii]
				roomobject:destroy("no image")  --  delete room object 	
				table.remove(roomdata , ii )   -- remove Room obj from table. 
				
			end
		end	
		--print ("bldingparms", bldingparms.buildingpic )
		
		--  Read in roomData and create room data table
		local roomCT = #roomparms 
	    if roomCT > 0 then
			for ii = 1, roomCT, 1 do  
				local newroom
				newroom = RF:new()
				newroom.entrynum = ii
				newroom:loadfields ( roomparms[ii] , bldingparms )
				-- newroom:loadimage ( localGroup )  -- create image and attach to self
         		-- newroom:setlocation ( flrplanpic )  --  position the pic on screen
				print ("Insert this room in localGroup ")
				-- localGroup:insert( newroom.image )
				table.insert(roomdata,newroom)  --  inserts to the end of the table
			end  
			-- roomdata[GlblData.currObject.roomentry]:highlight();  -- infocus entry highlighted.
		end
	
	end	
	
	local function initVars ()
		
		------------------
		-- Inserts
		------------------
		
		localGroup:insert( background )
		
		localGroup:insert( backgroundtitlebar )
		localGroup:insert( accentbar )
				
		localGroup:insert( eventsbox )
		localGroup:insert( eventsTX )
		
		localGroup:insert( title )
		localGroup:insert( title2 )
		localGroup:insert( subtitle1)
		localGroup:insert( subtitle2)
		localGroup:insert( subtitle3)
		localGroup:insert( Filtertitle1)
		localGroup:insert( Filtertitle2)
		localGroup:insert( Filtertitle3)
		localGroup:insert( Filtertitle4)
		localGroup:insert( Filtertitlebox2)
		localGroup:insert( Filtertitlebox3)
		localGroup:insert( Filtertitlebox4)
		localGroup:insert( Filtertitlebox2text)
		localGroup:insert( Filtertitlebox3text)
		localGroup:insert( Filtertitlebox4text)
		localGroup:insert( segmentedControl )
	
		localGroup:insert( feedback )
		
		localGroup:insert( stella )
		localGroup:insert( stellaTX )
		localGroup:insert( logoutTX )
--		localGroup:insert( datachart.image )
		
		
		
		------------------
		-- Positions
		------------------
		Position(title,12, 4)
		Position(title2,12, 11)
		Position(subtitle1,33, 4)
		Position(subtitle2,43, 4)
		Position(subtitle3,53, 4)
		Position( Filtertitle1,33, 11)
		Position( Filtertitle2,40, 11)
		Position( Filtertitlebox2,45, 11)
		Position( Filtertitlebox2text,45, 11)
		Position( Filtertitle3,53, 11)
		Position( Filtertitlebox3,57, 11)
		Position( Filtertitlebox3text,57, 11)
		Position( Filtertitle4,66, 11)
		Position( Filtertitlebox4,77, 11)
		Position( Filtertitlebox4text,77, 11)
		
		Position(accentbar,53, 6)
		Position(feedback, 24, 95)
		Position(stella, 80, 4)
		Position(stellaTX, 85, 4)
		Position(logoutTX, 90, 4)
		
		-- boxes

		-- Position(workorderbox, 8, 57 )		
		Position(eventsbox, 2, 16 )
        -- box titles
		
		eventsTX.x = eventsbox.x + 5
		eventsTX.y = eventsbox.y + 2
		
		------------------
		-- Colors
		------------------
		
		background:setFillColor( unpack(theme.clr_body) )
		
		backgroundtitlebar:setFillColor	 ( unpack(theme.clr_header) )
		eventsTX:setFillColor 			 ( unpack(theme.clr_header) )
		eventsbox:setFillColor			 ( unpack(theme.clr_box ) )
		title:setFillColor               ( unpack(theme.title_clr ) )
		title2:setFillColor              ( unpack(theme.subtitle_clr ) )
		subtitle1:setFillColor           ( unpack(theme.subtitle_clr ) )
		subtitle2:setFillColor			 ( unpack(theme.subtitle_clr ) )
		subtitle3:setFillColor			 ( unpack(theme.subtitle_clr ) )
		Filtertitle1:setFillColor		 ( unpack(theme.subtitle_clr ) )
		Filtertitle2:setFillColor		 ( unpack(theme.subtitle_clr ) )
		Filtertitle3:setFillColor		 ( unpack(theme.subtitle_clr ) )
		Filtertitle4:setFillColor 		 ( unpack(theme.subtitle_clr ) )
		Filtertitlebox2:setFillColor     ( unpack(theme.clr_box ) )
		Filtertitlebox3:setFillColor	 ( unpack(theme.clr_box ) )
		Filtertitlebox4:setFillColor	 ( unpack(theme.clr_box ) )
		Filtertitlebox2text:setFillColor (  unpack(theme.clr_text ) )
		Filtertitlebox3text:setFillColor (  unpack(theme.clr_text ) )
		Filtertitlebox4text:setFillColor (  unpack(theme.clr_text ) )
		accentbar:setFillColor			 (  unpack(theme.subtitle_clr ) )
		feedback:setFillColor 			 (  unpack(theme.subtitle_clr ) )
		stellaTX:setFillColor			 (  unpack(theme.title_clr ))
		logoutTX:setFillColor			 (  unpack(theme.subtitle_clr ) )
		
		
	end 
	
	local function initTimersandlisteners()	
		
		-----------------------
		--  Timers
		-----------------------
		local t1 = {} 
		t1.name = "second counter"
		t1.timer = timer.performWithDelay(1000, secondLoop , -1)
		allTimers:push(t1, -1 )
		
		local t2 = {} 
		t2.name = "10 minute counter"
		t2.timer = timer.performWithDelay(600000, tenminLoop , -1)
		allTimers:push(t2, -1 )
		
		Runtime:addEventListener("enterFrame", mainLoop)
		
	return 	
	end
	sf.initTimersandlisteners = initTimersandlisteners; 
	
	local cancelTimersandlisteners = function ()  
	    
		--  clear timers
		allTimers:listem()
		allTimers:cancelall()
		transition.cancel()		-- Cancel all transitions 
		Runtime:removeEventListener("enterFrame", mainLoop)
		
	end	 
	sf.cancelTimersandlisteners = cancelTimersandlisteners ; 
	
	------------------
	-- Initiate variables
	------------------
	
	initVars()
	InitializeBldgRoomData()
	isTableView = false
	--stella:addEventListener( "touch" , touch_Stella )
		Filtertitle2:addEventListener( "touch" , touch_Building )
		Filtertitle3:addEventListener( "touch" , touch_Floor )
		Filtertitle4:addEventListener( "touch" , touch_Room )
		subtitle1:addEventListener( "touch" , touch_Store )
		subtitle2:addEventListener( "touch" , touch_Active )
		logoutTX:addEventListener( "touch" , touch_logout )
		feedback:addEventListener( "touch" , touch_Feedback )
	
	------------------
	-- MUST return a display.newGroup()
	------------------
	
	return localGroup
	
end

----------------------------------
-- Standard Composer code 
----------------------------------
local currScene = composer.getSceneName( "current" )
function scene:create( event )  -- called once when scene is created or after destroy event.  
	print (currScene, ": create")
	new(self,event)
end 	
--  
function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then -- called before scene is shown 
	print (currScene,": show: will")
	sf.initTimersandlisteners()	--  timers and runtimelistener 		
  elseif ( phase == "did" ) then  -- called after scene is shown 
	print (currScene,": show: did")
    --audio.play(sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then  -- called before scene to be swapped out 
    print (currScene,": hide: will")
  elseif ( phase == "did" ) then  -- called after scene swapped out. 
    print (currScene,": hide: did")
	sf.cancelTimersandlisteners()	--  timers and runtimelistener 	
  end
end

function scene:destroy( event )  -- called from composer.removeScene or system cleans up from memory process. 
	print (currScene,": destroy")
	sf.cancelTimersandlisteners()	--  timers and runtimelistener 	
	-- these provide a way of accessing vars outside of their defined scope.  
	sv = nil  --  scene variables
	sf = nil  --  scene functions 
end	
	
	------------------
	-- MUST return a display.newGroup()
	------------------
	scene:addEventListener("create")
	scene:addEventListener("show")
	scene:addEventListener("hide")
	scene:addEventListener("destroy")

return scene
