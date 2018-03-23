--====================================================================--
-- Main Technician Page
--====================================================================--

--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2016
 
 - Mail: ttuning@us.ibm.com

******************
 - INFORMATION
******************

  
--]]
	------------------
	-- Modules
	------------------

	local Widget = require( "widget" )
	local GGData = require( "lib.GGData" )
	local GlblData = require ( "lib.glbldata" )
	local composer = require "composer"
	local rgb = require ( "lib._rgb" )
	local Timez = require ( "lib.Timez" )  -- keep track of timers
	local BuildingData = require ( "lib.buildingdata" )  -- static room data for test
	local RGF = require ( "lib.RGF" )  -- Room group object functions
	local RF = require ( "lib.RF" )    -- Room object common functions
	local theme = GlblData.theme 

	local scene = composer.newScene()		
	local sf  = {}   --  a place to store the scene functions that need to be accessed globally.  
	local sv  = {}   --  a place to store the scene variables that need to be accessed globally. 

new = function (self , event )
    print ("tech module") 
	
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
	
	------------------
	-- Groups
	------------------
	
	local localGroup = self.view 
	localGroup.myname = "Tech"
	
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
	
	
	local stellaTX = display.newText( "Dan", 0, 0, native.systemFontBold, 8 )
	local logoutTX = display.newText( "logout", 0, 0, native.systemFont, 5 )
	
	local feedback = display.newText( "Learn more at IBM.com/IoT", 0, 0, native.systemFontBold, 12 )
	feedback.alpha = 0 ;
	
	local stella = display.newImageRect( "pictures/dan.png" , 15, 17  )
	
		
	local eventsTX = display.newText( "Work Orders", 0, 0, native.systemFontBold, 8 )
	eventsTX.anchorX , eventsTX.anchorY = 0,0  --  anchor object at top left corner
	local eventsbox = display.newRect( localGroup, 0,0, _LBoxW,  _LBoxH ) 
	eventsbox.anchorX , eventsbox.anchorY = 0,0  --  anchor object at top left corner
	eventsbox.alpha = 1
	-- WorkTaskList = tableviewer( rows, { eventsbox.x + 2, eventsbox.y + 15 } , { eventsbox.width - 2 ,eventsbox.height - 15 })  -- display table
	local WorkTaskList -- tableview list of work tasks
	local isWorkTaskList = false
	local updateworktasks 
	---------------------------
	--  Functions 
	----------------------------
	
	local exitpage   --  place holder for function which is defined lower in module.
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
	
	
	local function buildWTrows()
			--  construct rows for picker.
			local  rowtable  = {}
			local  rooms = BuildingData:loadrooms(GlblData.currObject.buildingentry, GlblData.currObject.floorentry )  -- get all the data for the buildings
			local  room = rooms[GlblData.currObject.roomentry] -- get all data for this room
			local  worktasks = room.WorkTasks;
			if #worktasks > 0 then 
				for ii = 1 , #worktasks , 1 do
					rowtable[ii] = {}
				end 
				print ("worktasks count  is: ", #worktasks)
				rowcounter = 0 
				-- loop thru building data and create rows. 
				for k, v in pairs( worktasks ) do
					rowcounter = rowcounter + 1 
					print ("k is ", k ," value is ", v)
					rowtable[rowcounter].kind = "row"	
					rowtable[rowcounter].text1 = worktasks[k].WTtitle
					rowtable[rowcounter].text2 = worktasks[k].WTasset
					rowtable[rowcounter].text3 = worktasks[k].WTtime
					rowtable[rowcounter].rowprefix = ""
					
				end
			end
		return 	rowtable	
	end
	
	local function tableviewer ( rowtable , location, size )
	
		local tableViewColors = {
		rowColor = { default =  rgb.white , over =  rgb.lightgrey },
		rowtextColor =  rgb.darkslategray ,
		lineColor = rgb.lightgrey,
		headerColor = { default =  rgb.darkturquoise2 , over = rgb.darkturquoise2 },
		headertextColor = rgb.black,
		catColor = { default = rgb.lightgrey, over = rgb.grey },
		cattextColor = rgb.black
		}
		------------------
		-- Listeners
		------------------
		
		-- Handle row rendering.  called when row is inserted into table.
		local function onRowRender( event )
			local phase = event.phase
			
			local row = event.row
			print ("row.kind", row.params.kind)
			local groupContentHeight = row.contentHeight
			
			local rowTitle = display.newText( row, "default", 0, 0, nil, 10 )
			rowTitle.x = 4
			rowTitle.anchorX = 0
			rowTitle.y = groupContentHeight * 0.5
			
			if ( row.params.kind == "header" ) then
				print ("header")
				rowTitle:setFillColor( unpack(tableViewColors.headertextColor) )
				rowTitle.text = row.params.text
			elseif (row.params.kind == "category") then
				rowTitle:setFillColor( unpack(tableViewColors.cattextColor) )
				rowTitle.text = row.params.text.. "Category"
			else 	
				print ("onRR:  row")
				rowTitle:setFillColor( unpack(tableViewColors.rowtextColor) )
				rowTitle.text = row.params.rowprefix .. row.params.text1 .. "--" .. row.params.text2 .. "--" .. row.params.text3
			end
		end
		
		-- Listen for tableView touch and scroll events
		local function tableViewListener( event )
			local phase = event.phase
			print( "Event.phase is:", event.phase )
		end
		
		
		-- Handle touches on the row
		local function onRowTouch( event )
			local phase = event.phase
			local row = event.target
			if ( "release" == phase ) then
				print ("User selected row " .. row.index )
			end
		end
		
		if isWorkTaskList == false then 
		-- Create a tableView
			WorkTaskList = Widget.newTableView
			{
				top = location[2],
				left = location[1],
				width = size[1], 
				height = size[2],
				--hideBackground = true,
				listener = tableViewListener,
				onRowRender = onRowRender,
				--onRowUpdate = onRowUpdate,
				onRowTouch = onRowTouch,
			}
			localGroup:insert( WorkTaskList )
			isWorkTaskList = true
			-- Create rows
		end 
		for k, v in pairs( rowtable ) do	
			
			local kind = rowtable[k].kind
			local text1 = rowtable[k].text1
			local text2 = rowtable[k].text2
			local text3 = rowtable[k].text3
			local rowprefix = rowtable[k].rowprefix 
			print (kind,text1)
			local rowHeight = 22
			local rowColor = tableViewColors.rowColor
			local lineColor = tableViewColors.lineColor
			if (kind == "header")  then 
				rowColor = tableViewColors.headerColor 
				rowColor.default[4] = .6  -- alpha
			end
			if (kind == "category")  then rowColor = tableViewColors.catColor end
				
			-- Insert the row into the tableView
			
			WorkTaskList:insertRow(
			{
				rowColor = rowColor,
				lineColor = lineColor,
				rowHeight = rowHeight,
				params = { kind = kind, text1 = text1 ,text2 = text2 , text3 = text3 , rowprefix = rowprefix }
			})
		end
	return WorkTaskList
	end 
	
	function updateworktasks ()
		local rows = buildWTrows() 
		if isWorkTaskList then	
			WorkTaskList:deleteAllRows() 
		end
		-- calculate TV size 
		WorkTaskList = tableviewer( rows, { eventsbox.x + 2, eventsbox.y + 15 } , { eventsbox.width - 2 ,eventsbox.height - 15 })  -- display table
		transition.from(WorkTaskList, {time = 1000 , delay = 213, alpha = 0 , transition = easing.inExpo  } )
		
		
	end 
	
	local function updateWT()   -- Change SAT chart when room changes
		local function callback( )
			is_transitioning = false
		end  -- callback
		-- if room has changed move the needle to current setting
		-- if is_transitioning == false and is_transitioning2 == false then 
			if prev_bldg    ~= GlblData.currObject.buildingname or 
			   prev_floor	~= GlblData.currObject.floorname or 
			   prev_room    ~= GlblData.currObject.roomname then
			   updateworktasks()  --  Refresh work tasks as well because of room changes. 
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

	local touch_Analysis = function ( event )
		if event.phase == "ended" then
			local options = {
				effect = "fade",
				time = 500,
					params = {
						someKey = "someValue",
						someOtherKey = 10
						}
					}
			composer.gotoScene( "scene.Analysis", options ) -- Go to Intro screen
			timer.performWithDelay(500, function () composer.removeScene( "scene.Tech" ); end  , 1)
		end
	end
	
	local touch_Store = function ( event )
		if event.phase == "ended" then
			local options = {
				effect = "fade",
				time = 500,
					params = {
						someKey = "someValue",
						someOtherKey = 10
						}
					}
			composer.gotoScene( "scene.Store", options ) -- Go to Intro screen
			timer.performWithDelay(500, function () composer.removeScene( "scene.Tech" ); end  , 1)
		end
	end
	
	
	local touch_logout = function ( event )
		if event.phase == "ended" then
			local options = {
				effect = "fade",
				time = 500,
					params = {
						someKey = "someValue",
						someOtherKey = 10
						}
					}
			composer.gotoScene( "scene.Intro", options ) -- Go to Intro screen
			timer.performWithDelay(500, function () composer.removeScene( "scene.Tech" ); end  , 1)
		end
	end
	
	local popClosed_touch_Building = function (returnedvalues)  --  function called from director when popup closes.
		
		print ("popup closed")
		transition.to( localGroup , {time = 800 , delay = 0 , alpha = 1 } )
		local rownum 	
		if returnedvalues then 
			rownum = returnedvalues[1]
		end 

		GlblData.currObject.buildingentry = rownum - 1
		GlblData.currObject.floorentry = 1 -- default since new building selected.
		GlblData.currObject.roomentry = 1 -- default since new building selected.
		InitializeBldgRoomData()
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
		    -- pass current building data to popup.  
			
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
			
		    -- create popup to choose building choice.
			composer.showOverlay( "scene.PopUpPicker", options ) -- create popup to choose building choice.			
		    
		end
	end
	local popClosed_touch_Floor = function (returnedvalues)  --  function called from director when popup closes.
		print ("popup closed")
		transition.to( localGroup , {time = 800 , delay = 0 , alpha = 1 } )
		local rowindex 	
		if returnedvalues then 
			rowindex = returnedvalues[1]
		end 
		composer.removeScene("scene.PopUpPicker")
		
		GlblData.currObject.floorentry = rowindex - 1
		InitializeBldgRoomData()
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
			
		    -- create popup to choose building choice.
			composer.showOverlay( "scene.PopUpPicker", options ) -- create popup to choose building choice.		
		    
		end
	end
	
	local popClosed_touch_Room = function (returnedvalues)  --  function called from director when popup closes.
		
		transition.to( localGroup , {time = 800 , delay = 0 , alpha = 1 } )
		
		local rowindex 	
		if returnedvalues then 
			rowindex = returnedvalues[1]
		end 
		composer.removeScene("scene.PopUpPicker")
		GlblData.currObject.roomentry = rowindex - 1
		GlblData.currObject.roomname =  roomdata[GlblData.currObject.roomentry].roomname
		
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
		    -- pass current building data to popup.  
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
						
		    -- create popup to choose building choice.
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
			updateWT()
			-- updateworktasks()
		
		end  -- not EXITIING or paused
    end
	
	local function tenminLoop ( event )  --  this loop is called 1 time per 10 minutes
					
        if not EXITING and not isPaused then 
			
		end  -- not EXITIING or paused
    end
	
--  common exit operations
	exitpage = function ()  -- this isn't local because it was defined at the top of the module
	    
		if not EXITING and not isPaused then --  only call this once. 
			EXITING = true
			  
			--  remove listeners 
			Filtertitle2:removeEventListener( "touch" , touch_Building )
			Filtertitle3:removeEventListener( "touch" , touch_Floor )
			Filtertitle4:removeEventListener( "touch" , touch_Room )
			logoutTX:removeEventListener( "touch" , touch_logout )
			subtitle1:removeEventListener( "touch" , touch_Store )
			subtitle3:removeEventListener( "touch" , touch_Analysis )
			feedback:removeEventListener( "touch" , touch_Feedback )
			Runtime:removeEventListener("enterFrame", mainLoop)
			
			--  clear timers
			allTimers:listem()
			allTimers:cancelall()
			GlblData.allTimers = nil
			
			transition.cancel()		-- Cancel all transitions 
		end
		
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
	
		localGroup:insert( feedback )
		
		localGroup:insert( stella )
		localGroup:insert( stellaTX )
		localGroup:insert( logoutTX )
		
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
		
		Position(accentbar,43, 6)
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
		subtitle1:setFillColor           ( unpack(theme.clr_inactive ) )
		subtitle2:setFillColor			 ( unpack(theme.subtitle_clr ) )
		subtitle3:setFillColor			 ( unpack(theme.clr_inactive ) )
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
		
		------------------
		-- Add Listeners to display items 
		------------------

		--stella:addEventListener( "touch" , touch_Stella )
		Filtertitle2:addEventListener( "touch" , touch_Building )
		Filtertitle3:addEventListener( "touch" , touch_Floor )
		Filtertitle4:addEventListener( "touch" , touch_Room )
		subtitle1:addEventListener( "touch" , touch_Store )
		subtitle3:addEventListener( "touch" , touch_Analysis )
		logoutTX:addEventListener( "touch" , touch_logout )
		feedback:addEventListener( "touch" , touch_Feedback )
		Runtime:addEventListener("enterFrame", mainLoop)
		
		
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
	initTimersandlisteners()
	------------------
	-- MUST return a display.newGroup()
	------------------
	
	return localGroup
	
end

-----------------------------------
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
