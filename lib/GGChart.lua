-- Project: GGChart
--
--  - Version: 0.1
 -- - Made by Tom Tuning @ 2016
 
 -- - Mail: ttuning@us.ibm.com

-- ******************
-- - INFORMATION
-- ******************
--
-- Comments: 
-- 
--		GGChart allows for easy creation of Google Image Charts for your Corona apps. 
--		The Google Image Chart API was deprecated in April 2012 however it should still
--		work. Info is here - https://developers.google.com/chart/image/
--
--
----------------------------------------------------------------------------------------------------

local GGChart = {}
local GGCharts_mt = { __index = GGChart }

local http = require( "socket.http" )
local ltn12 = require( "ltn12" )

local googleUrl = "http://chart.apis.google.com/chart?"

--- Initiates a new GGChart object.
-- @return The new object.
function GGChart:new( params )
    
    local self = {}
    
    setmetatable( self, GGCharts_mt )
    
    if params then
    	if params.type == "qr" then		
			self:newQR(params)
		elseif params.type == "pie" then		
			self:newPie(params)	
		elseif params.type == "line" then		
			self:newLine(params)
		elseif params.type == "bar" then		
			self:newBar(params)		
		else print ("ggCHART:  TYPE not supported") 	
		end
    end
    
    return self
    
end

--- Creates a new line chart. Called internally.
-- @param params The chart params.
function GGChart:newLine( params )

	if not params then
		params = {}
	end

	self.mode = params.mode or "standard"

	if self.mode == "standard" then
		self.type = "lc"
	elseif self.mode == "spark" then
		self.type = "ls"
	elseif self.mode == "xy" then
		self.type = "lxy"
	end	

	self.title = params.title or ""
	self.titleColour = params.titleColour or "000000"
	self.titleFontSize = params.titleFontSize or 11.5
	self.data = params.data or ""
	self.width = params.width or 200
	self.height = params.height or self.width
	self.legend = params.legend or ""
	self.legendPosition = params.legendPosition or "r"
	self.legendSize = params.legendSize
	self.labels = params.labels or ""
	self.margins = params.margins or { 0, 0, 0, 0 }
	self.x = params.x or 0
	self.y = params.y or 0
	self.scale = params.scale or { 0, 100 }
	self.dataColours = params.dataColours or "0000FF"
	self.dataStyle = params.dataStyle or ""

	self.axis = params.axis or ""
	self.axisLabels = params.axisLabels or ""
	self.axisLabelPositions = params.axisLabelPositions or ""

	self.transparency = params.transparency or "a,s,000000" 
	self.background = params.background or "bg,s,FFFFFF"

	self.url = googleUrl .. "chf=" .. self:encodeString( self.transparency .. "|" .. self.background ) 
	self.url = self.url .. "&chs=" .. self.width .. "x" .. self.height
	self.url = self.url .. "&cht=" .. self.type 
	self.url = self.url .. "&chco=" .. self:encodeString( self.dataColours ) 
	self.url = self.url .. "&chd=" .. self:encodeString( self.data) 
	self.url = self.url .. "&chdl=" .. self:encodeString( self.legend) 
	self.url = self.url .. "&chdlp=" .. self.legendPosition
	self.url = self.url .. "&chls=" .. self:encodeString( self.dataStyle )
	self.url = self.url .. "&chts=" .. self:encodeString( self.titleColour .. "," .. self.titleFontSize )  
	self.url = self.url .. "&chma=" .. self:encodeString( self.margins[ 1 ] .. "," .. self.margins[ 2 ] .. "," .. self.margins[ 3 ] .. "," .. self.margins[ 4 ] ) 
	self.url = self.url .. "&chtt=" .. self:encodeString( self.title ) 
   
   	if self.axisLabels ~= "" then
   		
   		self.url = self.url .. "&chxt=" .. self.axis
   		self.url = self.url .. "&chxl=" .. encodeString(self.axisLabels) 
		if self.axisLabelPositions ~= "" then 
			self.url = self.url .. "&chxp="  .. encodeString(self.axisLabelPositions)
		end 
   	
   	else
 
		if self.legendSize then
			self.url = self.url .. "&chl=" .. self:encodeString( self.labels .. "|" .. self.legendSize[ 1 ] .. "," .. self.legendSize[ 2 ] )
		else
			self.url = self.url .. "&chl=" .. self:encodeString( self.labels )
		end
   	
   	end

	self:downloadChart()

end

--- Creates a new line chart. Called internally.
-- @param params The chart params.
function GGChart:newBar( params )

	if not params then
		params = {}
	end

	self.mode = params.mode or "groupedH"

	if self.mode == "grouped" then
		self.type = "bvg"
	elseif self.mode == "groupedH" then
		self.type = "bhg"	
	elseif self.mode == "stacked" then
		self.type = "bvs"
	elseif self.mode == "overlapped" then
		self.type = "bvo"
	elseif self.mode == "stackedH" then
		self.type = "bhs"
	elseif self.mode == "overlapped" then
		self.type = "bho"
	else self.type = "bhg"		
	end	

	self.title = params.title or ""
	self.titleColour = params.titleColour or "000000"
	self.titleFontSize = params.titleFontSize or 11.5
	self.data = params.data or ""
	self.width = params.width or 200
	self.height = params.height or self.width
	-- make chart as big as possible.  google supports 300,000 pixels.
	local pixmax = 300000
	local pixsize = self.width * self.height
	if pixsize < pixmax then 
		self.chtwidth  = self.width  + math.floor((.93 -(pixsize/pixmax)) * self.width)
		self.chtheight = self.height + math.floor((.93 -(pixsize/pixmax)) * self.height)
	end
	
	self.legend = params.legend or ""
	self.legendPosition = params.legendPosition or "r"
	self.legendSize = params.legendSize
	self.labels = params.labels or ""
	self.margins = params.margins or { 0, 0, 0, 0 }
	self.x = params.x or 0
	self.y = params.y or 0
	self.scale = params.scale or { 0, 100 }
	self.dataColours = params.dataColours or "0000FF"
	self.dataStyle = params.dataStyle or ""
	self.markers = params.markers or ""
	self.barwidth = params.barwidth or ""

	self.axis = params.axis or ""
	self.axisLabels = params.axisLabels or ""
	self.axisLabelPositions = params.axisLabelPositions or ""
	self.axisLabelfont = params.axisLabelfont or ""

	self.transparency = params.transparency or "a,s,000000" 
	self.background = params.background or "bg,s,FFFFFF"

	self.url = googleUrl .. "chf=" .. self:encodeString( self.transparency .. "|" .. self.background ) 
	self.url = self.url .. "&chs=" .. self.chtwidth .. "x" .. self.chtheight
	self.url = self.url .. "&cht=" .. self.type 
	self.url = self.url .. "&chco=" .. self:encodeString( self.dataColours ) 
	self.url = self.url .. "&chd=" .. self:encodeString( self.data) 
	self.url = self.url .. "&chdl=" .. self:encodeString( self.legend) 
	self.url = self.url .. "&chdlp=" .. self.legendPosition
	self.url = self.url .. "&chls=" .. self:encodeString( self.dataStyle )
	self.url = self.url .. "&chts=" .. self:encodeString( self.titleColour .. "," .. self.titleFontSize )  
	self.url = self.url .. "&chma=" .. self:encodeString( self.margins[ 1 ] .. "," .. self.margins[ 2 ] .. "," .. self.margins[ 3 ] .. "," .. self.margins[ 4 ] ) 
	self.url = self.url .. "&chtt=" .. self:encodeString( self.title ) 
	
	if self.markers ~= "" then 
		self.url = self.url .. "&chm=" .. self:encodeString( self.markers ) 
	end	
	if self.barwidth ~= "" then 
		self.url = self.url .. "&chbh=" .. self:encodeString( self.barwidth ) 
	end	
   	if self.axisLabels ~= "" then
   		
   		self.url = self.url .. "&chxt=" .. self.axis
   		self.url = self.url .. "&chxl=" .. self:encodeString(self.axisLabels) 
   		self.url = self.url .. "&chxp="  .. self:encodeString(self.axisLabelPositions)
   		self.url = self.url .. "&chxs="  .. self:encodeString(self.axisLabelfont)
		
   	
   	else
 
		if self.legendSize then
			self.url = self.url .. "&chl=" .. self:encodeString( self.labels .. "|" .. self.legendSize[ 1 ] .. "," .. self.legendSize[ 2 ] )
		else
			self.url = self.url .. "&chl=" .. self:encodeString( self.labels )
		end
   	
   	end
	print ("TTchart:  ", self.url )
	self:downloadChart()

end

--- Creates a new QR code. Called internally.
-- @param params The chart params.
function GGChart:newQR( params )

	if not params then
		params = {}
	end

	self.type = "qr"
	self.width = params.width or 200
	self.height = params.height or self.width
	self.data = self:encodeString( params.data or "" )
	self.encoding = params.encoding or "UTF-8"
	self.errorCorrectionLevel = params.errorCorrectionLevel or "L"
	self.margin = params.margin or 4
	self.x = params.x or 0
	self.y = params.y or 0

	self.transparency = params.transparency or "a,s,000000" 
	self.background = params.background or "bg,s,FFFFFF"

	self.url = googleUrl .. "chf=" .. self:encodeString( self.transparency .. "|" .. self.background ) 
	self.url = self.url .. "&chs=" .. self.width .. "x" .. self.height 
	self.url = self.url .. "&cht=" .. self.type 
	self.url = self.url .. "&chld=" .. self:encodeString( self.errorCorrectionLevel .. "|" .. self.margin ) 
	self.url = self.url .. "&chl=" .. self.data 
	self.url = self.url .. "&choe=" .. self.encoding

	self:downloadChart()

end

--- Creates a new pie chart. Called internally.
-- @param params The chart params.
function GGChart:newPie( params )

	if not params then
		params = {}
	end

	self.mode = params.mode or "2d"

	if self.mode == "2d" then
		self.type = "p"
	elseif self.mode == "3d" then
		self.type = "p3"
	elseif self.mode == "concentric" then
		self.type = "pc"
	end	

	self.title = params.title or ""
	self.titleColour = params.titleColour or "000000"
	self.titleFontSize = params.titleFontSize or 11.5
	self.data = params.data or ""
	self.width = params.width or 200
	self.height = params.height or self.width
	self.legend = params.legend or ""
	self.legendPosition = params.legendPosition or "r"
	self.legendSize = params.legendSize
	self.labels = params.labels or ""
	self.radians = params.radians or 1
	self.margins = params.margins or { 0, 0, 0, 0 }
	self.x = params.x or 0
	self.y = params.y or 0
	self.scale = params.scale or { 0, 100 }
	self.dataColours = params.dataColours or "0000FF"

	self.transparency = params.transparency or "a,s,000000" 
	self.background = params.background or "bg,s,FFFFFF"

	self.url = googleUrl .. "chf=" .. self:encodeString( self.transparency .. "|" .. self.background ) 
	self.url = self.url .. "&chs=" .. self.width .. "x" .. self.height
	self.url = self.url .. "&cht=" .. self.type 
	self.url = self.url .. "&chco=" .. self:encodeString( self.dataColours ) 
	self.url = self.url .. "&chds=" .. self:encodeString( self.scale[ 1 ] .. "," .. self.scale[ 2 ] ) 
	self.url = self.url .. "&chd=" .. self:encodeString( self.data ) 
	self.url = self.url .. "&chdl=" .. self:encodeString( self.legend ) 
	self.url = self.url .. "&chdlp=" .. self.legendPosition
	self.url = self.url .. "&chp=" .. self.radians 
	self.url = self.url .. "&chtt=" .. self:encodeString( self.title ) 
	self.url = self.url .. "&chts=" .. self:encodeString( self.titleColour .. "," .. self.titleFontSize ) 
	self.url = self.url .. "&chma=" .. self:encodeString( self.margins[ 1 ] .. "," .. self.margins[ 2 ] .. "," .. self.margins[ 3 ] .. "," .. self.margins[ 4 ] ) 

	if self.legendSize then
		self.url = self.url .. "&chl=" .. self:encodeString( self.labels .. "|" .. self.legendSize[ 1 ] .. "," .. self.legendSize[ 2 ] )
	else
		self.url = self.url .. "&chl=" .. self:encodeString( self.labels )
	end

	self:downloadChart()
	
end



--- Url encodes a string. Called internally.
-- @param str The string to encode.
-- @return The encoded string.
function GGChart:encodeString( str )

	if str then
		str = string.gsub( str, "\n", "\r\n" )
		str = string.gsub( str, "([^%w ])", function (c) return string.format( "%%%02X", string.byte( c ) ) end )
		str = string.gsub( str, " ", "+" )
	end
	
  	return str	
  	
end

--- Downloads this GGChart object. Called internally.
function GGChart:downloadChart()

	local networkListener = function( event )

        if ( event.isError ) then
    		print ( "GGChart Error - Download failed." )
        else
            
        end

	end

	if self.url and self.type then	 

		local download = function()

			local time = os.time()

			self.filename = "chart_" .. self.type .. "_" .. time .. ".png"
			self.filename2 = "chart_" .. self.type .. "_" .. time .. "@2x.png"
			self.filename4 = "chart_" .. self.type .. "_" .. time .. "@4x.png"
			self.path = system.pathForFile( self.filename , system.DocumentsDirectory )
			self.path2 = system.pathForFile( self.filename2 , system.DocumentsDirectory )
			self.path4 = system.pathForFile( self.filename4 , system.DocumentsDirectory )

			local file = io.open( self.path, "w+b" ) 
			local file2 = io.open( self.path2, "w+b" ) 
			local file4 = io.open( self.path4, "w+b" ) 

			-- Request remote file and save data to local file
			print ("-----------------------------")
			http.request
			{
				url = self.url, 
				sink = ltn12.sink.file( file ),
			}
			http.request
			{
				url = self.url, 
				sink = ltn12.sink.file( file2 ),
			}http.request
			{
				url = self.url, 
				sink = ltn12.sink.file( file4 ),
			}

			native.setActivityIndicator( false )	
			
			self.image = display.newImageRect(self.filename, system.DocumentsDirectory, self.width, self.height )
			self.image.anchorX = 0
			self.image.anchorY = 0

		end

		local showActivityIndicator = function()
			native.setActivityIndicator( true )
			timer.performWithDelay(1, download(), 1 )
		end

		showActivityIndicator()
		
	end

end

--- Destroys this GGChart object.
function GGChart:destroy()

	self.image:removeSelf()  -- delete Display Object and removes from DG
	self.image = nil 
	-- display.remove( self.image )
	local filename = nil
	if self.filename then
		local result = os.remove( system.pathForFile( self.filename, system.DocumentsDirectory ) )
		if result then
				print("Destroyed file first try:", self.filename )
			else
				print("WARNING! Failed to destroy file delay and try again:", self.filename )
				filename = self.filename
			end
	end
	if self.filename2 then
		local result = os.remove( system.pathForFile( self.filename2, system.DocumentsDirectory ) )
		if result then
				print("Destroyed file first try:", self.filename2 )
			else
				print("WARNING! Failed to destroy file delay and try again:", self.filename2 )
				filename = self.filename2
			end
	end
	if self.filename4 then
		local result = os.remove( system.pathForFile( self.filename4, system.DocumentsDirectory ) )
		if result then
				print("Destroyed file first try:", self.filename4 )
			else
				print("WARNING! Failed to destroy file delay and try again:", self.filename4 )
				filename = self.filename4
			end
	end
	
	
	local t = nil
	
	local removeFile = function()
	
		if filename then
			local result = os.remove( system.pathForFile( filename, system.DocumentsDirectory ) )
			if result then
				print("Timer: Destroyed file:", filename )
			else
				print("Timer: WARNING! Failed to destroy file:", filename )
			end
		end
		
		if t then
			timer.cancel( t )
		end
		t = nil
		
	end
	
	
	t = timer.performWithDelay(200, removeFile, 1 )
	
end 

return GGChart
