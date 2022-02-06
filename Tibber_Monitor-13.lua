-- QUICKAPP Tibber Monitor

-- This QuickApp gets todays and tomorrows energy prices and energy consumption from the Tibber platform. 
-- Next to the current prices the lowest, highest and average price for the next hours is calculated.
-- Tax and extra cost (cable owner) are included in the hourly, daily, monthly, yearly and total cost.  
-- All values are displayed in the labels. 
-- Child devices are available for:
   -- Hourly energy usage
   -- Hourly energy cost
   -- Todays energy usage (com.fibaro.energyMeter with automatic rateType=consumption for Fibaro Energy Panel)
   -- Todays energy cost (including extra cost)
   -- Monthly energy usage
   -- Monthly energy cost
   -- Yearly energy usage
   -- Yearly energy cost
   -- Total energy usage
   -- Total energy cost
   -- Actual price now
   -- Minimum price (of the next [forNextHour] hours)
   -- Maximum price (of the next [forNextHour] hours)
   -- Average price (calculated over the current prices and the next 10 prices)
   -- Percentage +0 hour (positive value means an increase of the price, negative value means a decrease of the price)
   -- Percentage +1 hour 
   -- Percentage +2 hour
   -- Percentage +3 hour
   -- Percentage +4 hour
   -- Percentage +5 hour
   -- Percentage +6 hour
   -- Percentage +7 hour
   -- Percentage +8 hour
   -- Percentage +9 hour
   -- Percentage +10 hour
-- These devices can be used to control appliances according to the lowest and forecast prices during the day. 

-- For easy use in for example blockscenes, Global Variables are available for:
   -- Current Price Level (NORMAL, CHEAP, VERY CHEAP, EXPENSIVE, VERY EXPENSIVE)
   -- Level +0 +1 +2 +3 +3 +4 +5 +6 +7 +8 +9 +10 hour (NORMAL, CHEAP, VERY CHEAP, EXPENSIVE, VERY EXPENSIVE)


-- To communicate with the API you need to acquire a OAuth access token and pass this along with every request passed to the server.
-- A Personal Access Token give you access to your data and your data only. 
-- This is ideal for DIY people that want to leverage the Tibber platform to extend the smartness of their home. 
-- Such a token can be acquired here: https://developer.tibber.com

-- When creating your access token or OAuth client you’ll be asked which scopes you want the access token to be associated with. 
-- These scopes tells the API which data and operations the client is allowed to perfom on the user’s behalf. 
-- The scopes your app requires depend on the type of data it is trying to request. 
-- If you for example need access to user information you add the USER scope. 
-- If information about the users homes is needed you add the appropiate HOME scopes.

-- Tomorrow values are available from 13:00 hour
-- If you have more than one home in your subscription, you need to fill in your home number the change between your homes. 

-- Price levels are based on trailing price average (3 days for hourly values and 30 days for daily values)
   -- NORMAL - The price is greater than 90 % and smaller than 115 % compared to average price.
   -- CHEAP - The price is greater than 60 % and smaller or equal to 90 % compared to average price.
   -- VERY CHEAP -	The price is smaller or equal to 60 % compared to average price.
   -- EXPENSIVE - The price is greater or equal to 115 % and smaller than 140 % compared to average price.
   -- VERY EXPENSIVE	- The price is greater or equal to 140 % compared to average price.

-- Tibber API documentation: https://developer.tibber.com/docs/guides/calling-api
-- Tibber API explorer: https://developer.tibber.com/explorer


-- Wishlist:
-- Current energy usage Watt (real time subscription = QuickApp with WebSocket?) (main device = powerSensor) ?
-- Run QuickApp at fixed time every hour ?
-- Split Extra cost in daytime and nighttime ?


-- Changes version 1.3 (6th February 2022)
-- For easy use in blockscenes added Global Variables for the levels (CHEAP, etc) for the current price and percentages +0, +1, +2, +3, +4, +5, +6, +7, +8, +9 and +10 hour. (Activate the global variables with the QuickApp Variable setGlobalVar = true)
-- Added an extra Child Device for Percentage +0 hour (current hour)
-- Added QuickApp Variable setPercentage to setup the calculation of the percentages from "average" price or from "current" price
-- Changed the caluclation of the percentages according to the setting in setPercentage, "average" or "current" price
-- Limited the calculation of the average price to the current price and the next 10 prices (in line with the child devices +0, +1 ... +10)
-- Added a minimum and maximum to forNextHour of 12 and 35 hours prices 


-- Changes version 1.2 (2nd February 2022) 
-- Solved a nasty bug with the percentage in the labels for tomorrow prices
-- Added extra child devices for percentage +6 +7 +8 +9 +10 hour

-- Changes version 1.1 (29th January 2022)
-- Added average price calculation and child device (made by Fibaro forum member drzordz)
-- Added QuickApp variable to setup amount of hours to show the next prices (made by Fibaro forum member drzordz)

-- Changes version 1.0 (8th Januari 2022)
-- Reduced max and min price and percentage to two decimals digits 
-- Solved issue with empty hourly energy
-- Added the prices to the log text of the child devices +1 +2 +3 +4 +5
-- Added percentages to the hourly prices in the labels
-- Added percentages to the minimum and maximum prices in the labels
-- Changed the abreviation to the latest moment (display in properties and labels) to get the (theoretical) most accureate calculation
-- Changed the default interval to 930 seconds to update more often and have less issues in case Tibber doesn't respond

-- Changes version 0.6 (1st January 2022)
-- Solved bug that didn't cleaned up the labels 

-- Changes version 0.5 (1st January 2021)
-- Changed main device to generic.device
-- Changed Tax calculations
-- Added child devices monthly and total energy and cost
-- Calculated the daily, monthly, yearly and total energy, cost and tax to get this day, this month, this year and total values
-- Solved a bug showing more than 12 prices just after midnight
-- Solved handling nil values at beginning of year, etc

-- Changes version 0.3 (30th December 2021)
-- Added quickapp variable homeNr to select which home if you have more than one in your subscription

-- Changes version 0.2 (29th December 2021)
-- Added all child devices
-- Added QuickApp variable for extra cost and added the cost to the calculations
-- Replaced "null" values in response to prevent errors
-- Limited values to next 12 hours

-- Changes version 0.1 (23rd December 2021)
-- Initial version


-- Variables (mandatory and created automatically): 
-- token = Authorization token (see the Tibber website: https://developer.tibber.com)
-- homeNr = Tibber home (nodes) number if you have more than one home (default = 1)
-- extraCost = Extra cost per kWh for Tibber and Cable owner, decimals with dot, not komma (default = 0)
-- interval = Interval in seconds to get the data from the Tibber Platform. The default is 930 seconds (15 minutes and 30 seconds). (Tibber has a rate limit of 100 requests in 5 minutes per IP address)
-- debugLevel = Number (1=some, 2=few, 3=all, 4=simulation mode) (default = 1)
-- setGlobalVar = true or false, whether you want to use the Global Variables (default = false)
-- setPercentage = current or average, whether you want to relate to the average price or current price for the percentage calculation (default = average)
-- icon = User defined icon number (add the icon via another device and lookup the number) (default = 0)
-- forNextHour = How many hours forward it will show the prices in the labels (default = 12, minimum = 12, maximum = 35)


-- No editing of this code is needed 


-- Child Devices

class 'hEnergy'(QuickAppChild)
function hEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hEnergy:updateValue(data) 
  self:updateProperty("value", data.hEnergy)
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'hCost'(QuickAppChild)
function hCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hCost:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.hCost+(extraCost*data.hEnergy))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.hCost) .." + " ..string.format("%.2f",extraCost*data.hEnergy))
end

class 'dEnergy'(QuickAppChild) -- Device for Energy Panel
function dEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "consumption" then 
    self:updateProperty("rateType", "consumption")
    self:warning("Changed rateType interface of Daily Energy child device (" ..self.id ..") to consumption")
  end
end
function dEnergy:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.dEnergy)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'dCost'(QuickAppChild)
function dCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function dCost:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.dCost+(extraCost*data.dEnergy))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.dCost) .." + " ..string.format("%.2f",extraCost*data.dEnergy))
end

class 'mEnergy'(QuickAppChild)
function mEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
end
function mEnergy:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.mEnergy)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'mCost'(QuickAppChild)
function mCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function mCost:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.mCost+(extraCost*data.mEnergy))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.mCost) .." + " ..string.format("%.2f",extraCost*data.mEnergy))
end

class 'yEnergy'(QuickAppChild)
function yEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
end
function yEnergy:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.yEnergy)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'yCost'(QuickAppChild)
function yCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function yCost:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.yCost+(extraCost*data.yEnergy))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.yCost) .." + " ..string.format("%.2f",extraCost*data.yEnergy))
end

class 'tEnergy'(QuickAppChild)
function tEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
end
function tEnergy:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.tEnergy)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'tCost'(QuickAppChild)
function tCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function tCost:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.tCost+(extraCost*data.tEnergy))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.tCost) .." + " ..string.format("%.2f",extraCost*data.tEnergy))
end

class 'hPrice'(QuickAppChild)
function hPrice:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hPrice:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.tPrice)))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", "(" ..data.level ..")")
end

class 'minPrice'(QuickAppChild)
function minPrice:__init(dev)
  QuickAppChild.__init(self,dev)
end
function minPrice:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.minPrice)))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", data.minStartsAt .." (" ..data.minLevel ..")")
end

class 'maxPrice'(QuickAppChild)
function maxPrice:__init(dev)
  QuickAppChild.__init(self,dev)
end
function maxPrice:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.maxPrice)))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", data.maxStartsAt .." ("..data.maxLevel ..")")
end

class 'averagePrice'(QuickAppChild)
function averagePrice:__init(dev)
  QuickAppChild.__init(self,dev)
end
function averagePrice:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",data.averagePrice)))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", " ")
end

class 'h0Percentage'(QuickAppChild)
function h0Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h0Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[1].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[1].total) .." " ..data.currency)
end

class 'h1Percentage'(QuickAppChild)
function h1Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h1Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[2].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[2].total) .." " ..data.currency)
end

class 'h2Percentage'(QuickAppChild)
function h2Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h2Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[3].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[3].total) .." " ..data.currency)
end

class 'h3Percentage'(QuickAppChild)
function h3Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h3Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[4].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[4].total) .." " ..data.currency)
end

class 'h4Percentage'(QuickAppChild)
function h4Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h4Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[5].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[5].total) .." " ..data.currency)
end

class 'h5Percentage'(QuickAppChild)
function h5Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h5Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[6].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[6].total) .." " ..data.currency)
end

class 'h6Percentage'(QuickAppChild)
function h6Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h6Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[7].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[7].total) .." " ..data.currency)
end

class 'h7Percentage'(QuickAppChild)
function h7Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h7Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[8].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[8].total) .." " ..data.currency)
end

class 'h8Percentage'(QuickAppChild)
function h8Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h8Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[9].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[9].total) .." " ..data.currency)
end

class 'h9Percentage'(QuickAppChild)
function h9Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h9Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[10].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[10].total) .." " ..data.currency)
end

class 'h10Percentage'(QuickAppChild)
function h10Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h10Percentage:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",jsonPrices[11].percentage)))
  self:updateProperty("unit", "%")
  self:updateProperty("log", string.format("%.4f",jsonPrices[11].total) .." " ..data.currency)
end


local function getChildVariable(child,varName)
  for _,v in ipairs(child.properties.quickAppVariables or {}) do
    if v.name==varName then return v.value end
  end
  return ""
end


-- QuickApp functions


function QuickApp:updateChildDevices() -- Update Child Devices
  for id,child in pairs(self.childDevices) do 
    child:updateValue(data) 
  end
end


function QuickApp:logging(level,text) -- Logging function for debug
  if tonumber(debugLevel) >= tonumber(level) then 
      self:debug(text)
  end
end


function QuickApp:setGlobalVariable(tag,res) -- Fill the Global Variables
  if setGlobalVar then 
    if api.get("/globalVariables/"..tag) == nil then
      local responseData, status = api.post("/globalVariables/",{value=(json.encode(res)),name=tag})
      self:trace("Global Variable created: " ..tag .." / status: " ..status) 
    else
      local responseData, status = api.put("/globalVariables/"..tag,{value=(json.encode(res))})
    end
  else
    if api.get("/globalVariables/"..tag) then
      self:deleteGlobalVariable(tag) -- If the Global Variables exists and you don't want them, delete them
    end
  end
end


function QuickApp:deleteGlobalVariable(tag) -- Delete the Global Variables
   local responseData, status = api.delete("/globalVariables/"..tag) 
   self:trace("Global Variable deleted: " ..tag .." / status: " ..status)
end


function QuickApp:updateProperties() -- Update the properties
  self:logging(3,"updateProperties")
  --self:updateProperty("value", 0) -- For future use
  --self:updateProperty("unit", "") -- For future use
  self:updateProperty("log", data.startsAt)
end


function QuickApp:updateLabels() -- Update the labels
  self:logging(3,"updateLabels")

  local labelText = ""
  if debugLevel == 4 then
    labelText = labelText .."SIMULATION MODE" .."\n\n"
  end

  labelText = labelText .."Hourly Energy: " ..string.format("%.2f",data.hEnergy) .." kWh / Cost: " ..string.format("%.2f",data.hCost+(extraCost*data.hEnergy)) .." " ..data.currency .."\n"
  labelText = labelText .."Daily Energy: " ..string.format("%.2f",data.dEnergy) .." kWh / Cost: " ..string.format("%.2f",data.dCost+(extraCost*data.dEnergy)) .." " ..data.currency .."\n"
  labelText = labelText .."Monthly Energy: " ..string.format("%.2f",data.mEnergy) .." kWh / Cost: " ..string.format("%.2f",data.mCost+(extraCost*data.mEnergy)) .." " ..data.currency .."\n"
  labelText = labelText .."Yearly Energy: " ..string.format("%.2f",data.yEnergy) .." kWh / Cost: " ..string.format("%.2f",data.yCost+(extraCost*data.yEnergy))  .." " ..data.currency .."\n"
  labelText = labelText .."Total Energy: " ..string.format("%.2f",data.tEnergy) .." kWh / Cost: " ..string.format("%.2f",data.tCost+(extraCost*data.tEnergy))  .." " ..data.currency .."\n\n"

  labelText = labelText .."Actual Price: " ..string.format("%.4f",data.tPrice) .." " ..data.currency .." per kWh (" ..data.level ..")" .."\n"
  labelText = labelText .."Energy: " ..string.format("%.4f",data.gPrice) .." " ..data.currency .." / Tax: " ..string.format("%.2f",data.tax) .." Cost: " ..string.format("%.2f",extraCost) .." " ..data.currency .."\n"
  labelText = labelText .."Starts at: " ..data.startsAt .."\n\n"

  labelText = labelText .."Minimum: " ..string.format("%.4f",data.minPrice) .." " ..data.currency .." (" ..data.minPercentage .."%) at: " ..data.minStartsAt .." (" ..data.minLevel ..")" .."\n"
  labelText = labelText .."Maximum: " ..string.format("%.4f",data.maxPrice) .." " ..data.currency .." (" ..data.maxPercentage .."%) at: " ..data.maxStartsAt .." (" ..data.maxLevel ..")" .."\n"
  labelText = labelText .."Average: " ..string.format("%.4f",data.averagePrice)  .." " ..data.currency .."\n\n"

  for n in pairs(jsonPrices or {}) do
    labelText = labelText .."Price: " ..string.format("%.4f",jsonPrices[n].total) .." " ..data.currency .." (" ..jsonPrices[n].percentage .."%) at: " ..jsonPrices[n].hour .." (" ..jsonPrices[n].level ..")" .."\n"
  end

  self:updateView("label1", "text", labelText)
  self:logging(2,"Label1: " ..labelText)
end


function QuickApp:getValuesTotal() -- Get Total values from json file 
  self:logging(3,"getValuesTotal")
  data.tEnergy = 0
  data.tCost = 0
  for year in pairs(jsonTable.data.viewer.homes[homeNr].yearly.nodes or {}) do -- Sum all years
    self:logging(3,"year: " ..tostring(year))
    data.tEnergy = data.tEnergy + tonumber(jsonTable.data.viewer.homes[homeNr].yearly.nodes[year].consumption)
    data.tCost = data.tCost + tonumber(jsonTable.data.viewer.homes[homeNr].yearly.nodes[year].cost)
  end
  data.tEnergy = tonumber(data.tEnergy + data.yEnergy) -- Add last year values
  data.tCost = tonumber(data.tCost + data.yCost)
  self:logging(3,"data.tEnergy: " ..tostring(data.tEnergy) .." data.tCost: " ..tostring(data.tCost))
end


function QuickApp:getValuesYearly() -- Get Yearly values from json file 
  self:logging(3,"getValuesYearly")
  data.yEnergy = 0
  data.yCost = 0
  for month in pairs(jsonTable.data.viewer.homes[homeNr].monthly.nodes or {}) do -- Sum all months of the year
    self:logging(3,"month: " ..tostring(month))
    data.yEnergy = data.yEnergy + tonumber(jsonTable.data.viewer.homes[homeNr].monthly.nodes[month].consumption)
    data.yCost = data.yCost + tonumber(jsonTable.data.viewer.homes[homeNr].monthly.nodes[month].cost)
  end
  data.yEnergy = tonumber(data.yEnergy + data.mEnergy) -- Add last month values
  data.yCost = tonumber(data.yCost + data.mCost)
  self:logging(3,"data.yEnergy: " ..tostring(data.yEnergy) .." data.yCost: " ..tostring(data.yCost))
end


function QuickApp:getValuesMonthly() -- Get Monthly values from json file 
  self:logging(3,"getValuesMonthly")
  data.mEnergy = 0
  data.mCost = 0
  for day in pairs(jsonTable.data.viewer.homes[homeNr].daily.nodes or {}) do -- Sum all days of the month
    self:logging(3,"day: " ..tostring(day))
    data.mEnergy = data.mEnergy + tonumber(jsonTable.data.viewer.homes[homeNr].daily.nodes[day].consumption)
    data.mCost = data.mCost + tonumber(jsonTable.data.viewer.homes[homeNr].daily.nodes[day].cost)
  end
  data.mEnergy = tonumber(data.mEnergy + data.dEnergy) -- Add last days values
  data.mCost = tonumber(data.mCost + data.dCost)
  self:logging(3,"data.mEnergy: " ..tostring(data.mEnergy) .." data.mCost: " ..tostring(data.mCost))
end

function QuickApp:getValuesDaily() -- Get Daily values from json file 
  self:logging(3,"getValuesDaily")
  data.dEnergy = 0
  data.dCost = 0
  data.hEnergy = 0
  data.hCost = 0
  for hour in pairs(jsonTable.data.viewer.homes[homeNr].hourly.nodes or {}) do  -- Sum all hours of the day
    self:logging(3,"hour: " ..tostring(hour))
    data.dEnergy = data.dEnergy + tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption)
    data.dCost = data.dCost + tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost)
    data.hEnergy = tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption) or 0
    data.hCost = tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost) or 0
  end
  self:logging(3,"data.hEnergy: " ..tostring(data.hEnergy) .." data.hCost: " ..tostring(data.hCost) .." data.dEnergy: " ..tostring(data.dEnergy) .."data.dCost: " ..tostring(data.dCost))
end


function QuickApp:getValues() -- Get the values from json file 
  self:logging(3,"getValues")
  
  jsonPrices = {}
  self:getValuesDaily()
  self:getValuesMonthly()
  self:getValuesYearly()
  self:getValuesTotal()
  
  data.tPrice =   tonumber(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.total)
  data.gPrice =   tonumber(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.energy)
  data.tax =      tonumber(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.tax)
  data.currency = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.currency
  data.level =    jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.level:gsub("_", " ") 
  data.startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.startsAt
  
  self:setGlobalVariable("tibber_currentLevel_"..plugin.mainDeviceId,data.level) -- Set global variable for current level
  
  local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).(%d+)+(%d+):(%d+)" --2021-12-23T17:00:00.000+01:00
  local runyear, runmonth, runday, runhour, runminute, runseconds = data.startsAt:match(pattern)
  local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
  data.startsAt = os.date("%d-%m-%Y %H:%M", convertedTimestamp)
  
  data.averagePrice = 0 
  local hAmount = 0
  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today or {}) do -- Get the average price today
    if jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total ~= 0 and hour >= tonumber(runhour) and hAmount < 11 then
      data.averagePrice = data.averagePrice + jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total
      hAmount = hAmount+1
      self:logging(3, "hour: " ..hour .." price: " ..jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total .." data.averagePrice: " ..data.averagePrice .." hAmount: " ..hAmount)
    end
  end
  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow or {}) do -- Get the average price tomorrow
    if jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total ~= 0 and hAmount < 11 then
      data.averagePrice = data.averagePrice + jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total
      hAmount = hAmount+1
      self:logging(3, "hour: " ..hour .." price: " ..jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total .." data.averagePrice: " ..data.averagePrice .." hAmount: " ..hAmount)
    end
  end
  data.averagePrice = tonumber(data.averagePrice) / hAmount -- Calculate the average price 
  self:logging(3,"data.averagePrice: " ..data.averagePrice .." for: " ..hAmount .." prices")

  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today or {}) do -- Insert all tadays prices to table jsonPrices
    if hour-1 >= tonumber(runhour) and hour-1 < (tonumber(runhour)+tonumber(forNextHour)) then
      if setPercentage == "current" then
        table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total, percentage = string.format("%.2f",((jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total-data.tPrice)/data.tPrice)*100), level = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].level:gsub("_", " "), startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].startsAt})
      else
        table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total, percentage = string.format("%.2f",((jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total-data.averagePrice)/data.averagePrice)*100), level = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].level:gsub("_", " "), startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].startsAt})
      end
    end
  end

  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow or {}) do -- Insert all tomorrow prices to table jsonPrices
    if 24-tonumber(runhour)+hour <= tonumber(forNextHour) then
      if setPercentage == "average" then
        table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total, percentage = string.format("%.2f",((jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total-data.averagePrice)/data.averagePrice)*100), level = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].level:gsub("_", " "), startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].startsAt})
      else
        table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total, percentage = string.format("%.2f",((jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total-data.tPrice)/data.tPrice)*100), level = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].level:gsub("_", " "), startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].startsAt})
      end
    end
  end
  self:logging(3,"Today and Tomorrow Prices: " ..json.encode(jsonPrices))
  
  for i=1,11 do
    self:setGlobalVariable("tibber_h" ..i-1 .."Level_"..plugin.mainDeviceId,jsonPrices[i].level) -- Set global variables for Level
  end

  data.minPrice = 999 -- Return to initial value to force new lowest price
  data.maxPrice = 0 -- Return to initial value to force new highest price
  for n in pairs(jsonPrices or {}) do
    if tonumber(jsonPrices[n].total) <= data.minPrice then
      data.minPrice =      tonumber(jsonPrices[n].total)
      data.minPercentage = jsonPrices[n].percentage
      data.minLevel =      jsonPrices[n].level
      data.minStartsAt =   jsonPrices[n].hour
    end
    if tonumber(jsonPrices[n].total) >= data.maxPrice then
      data.maxPrice =      tonumber(jsonPrices[n].total)
      data.maxPercentage = jsonPrices[n].percentage
      data.maxLevel =      jsonPrices[n].level 
      data.maxStartsAt =   jsonPrices[n].hour
    end  
  end
  self:logging(3,"data: " ..json.encode(data))
end


function QuickApp:simData() -- Simulate Tibber Platform
  self:logging(3,"simData")
  data = os.date("*t")
  apiResult = '{"data":{"viewer":{"homes":[{"hourly":{"nodes":[]},"daily":{"nodes":[{"from":"2022-01-01T00:00:00.000+01:00","to":"2022-01-02T00:00:00.000+01:00","cost":27.1006221125,"unitPrice":1.567053,"unitPriceVAT":0.313411,"consumption":17.294,"consumptionUnit":"kWh"},{"from":"2022-01-02T00:00:00.000+01:00","to":"2022-01-03T00:00:00.000+01:00","cost":28.496682,"unitPrice":1.39505,"unitPriceVAT":0.27901,"consumption":20.427,"consumptionUnit":"kWh"},{"from":"2022-01-03T00:00:00.000+01:00","to":"2022-01-04T00:00:00.000+01:00","cost":34.053851625,"unitPrice":1.580959,"unitPriceVAT":0.316192,"consumption":21.54,"consumptionUnit":"kWh"}]},"monthly":{"nodes":[]},"yearly":{"nodes":[{"from":"2020-01-01T00:00:00.000+01:00","to":"2021-01-01T00:00:00.000+01:00","cost":44.070164325,"unitPrice":0.242081,"unitPriceVAT":0.048416,"consumption":182.047,"consumptionUnit":"kWh"},{"from":"2021-01-01T00:00:00.000+01:00","to":"2022-01-01T00:00:00.000+01:00","cost":8386.1734052,"unitPrice":0.894956,"unitPriceVAT":0.178991,"consumption":9370.488,"consumptionUnit":"kWh"}]},"currentSubscription":{"status":"running","priceInfo":{"current":{"total":1.6576,"energy":1.3181,"tax":0.3395,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T00:00:00.000+01:00"},"today":[{"total":1.6576,"energy":1.3181,"tax":0.3395,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T00:00:00.000+01:00"},{"total":1.6596,"energy":1.3197,"tax":0.3399,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T01:00:00.000+01:00"},{"total":1.6182,"energy":1.2866,"tax":0.3316,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T02:00:00.000+01:00"},{"total":1.4547,"energy":1.1558,"tax":0.2989,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T03:00:00.000+01:00"},{"total":1.4283,"energy":1.1346,"tax":0.2937,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T04:00:00.000+01:00"},{"total":1.6745,"energy":1.3316,"tax":0.3429,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T05:00:00.000+01:00"},{"total":1.8044,"energy":1.4355,"tax":0.3689,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T06:00:00.000+01:00"},{"total":1.9481,"energy":1.5505,"tax":0.3976,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T07:00:00.000+01:00"},{"total":2.1101,"energy":1.6801,"tax":0.43,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T08:00:00.000+01:00"},{"total":2.0947,"energy":1.6678,"tax":0.4269,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T09:00:00.000+01:00"},{"total":2.1027,"energy":1.6742,"tax":0.4285,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T10:00:00.000+01:00"},{"total":2.0693,"energy":1.6474,"tax":0.4219,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T11:00:00.000+01:00"},{"total":2.0112,"energy":1.601,"tax":0.4102,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T12:00:00.000+01:00"},{"total":1.9576,"energy":1.5581,"tax":0.3995,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T13:00:00.000+01:00"},{"total":1.951,"energy":1.5528,"tax":0.3982,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T14:00:00.000+01:00"},{"total":1.9921,"energy":1.5857,"tax":0.4064,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T15:00:00.000+01:00"},{"total":2.0284,"energy":1.6147,"tax":0.4137,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T16:00:00.000+01:00"},{"total":2.1086,"energy":1.6789,"tax":0.4297,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T17:00:00.000+01:00"},{"total":2.0673,"energy":1.6458,"tax":0.4215,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T18:00:00.000+01:00"},{"total":1.9349,"energy":1.54,"tax":0.3949,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T19:00:00.000+01:00"},{"total":1.8465,"energy":1.4692,"tax":0.3773,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T20:00:00.000+01:00"},{"total":1.781,"energy":1.4168,"tax":0.3642,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T21:00:00.000+01:00"},{"total":1.7265,"energy":1.3732,"tax":0.3533,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T22:00:00.000+01:00"},{"total":1.4392,"energy":1.1434,"tax":0.2958,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-04T23:00:00.000+01:00"}],"tomorrow":[]}}},{"hourly":{"nodes":[]},"daily":{"nodes":[{"from":"2022-01-01T00:00:00.000+01:00","to":"2022-01-02T00:00:00.000+01:00","cost":218.896785625,"unitPrice":1.636979,"unitPriceVAT":0.327396,"consumption":133.72,"consumptionUnit":"kWh"},{"from":"2022-01-02T00:00:00.000+01:00","to":"2022-01-03T00:00:00.000+01:00","cost":188.634708375,"unitPrice":1.44448,"unitPriceVAT":0.288896,"consumption":130.59,"consumptionUnit":"kWh"},{"from":"2022-01-03T00:00:00.000+01:00","to":"2022-01-04T00:00:00.000+01:00","cost":125.61865085,"unitPrice":1.637472,"unitPriceVAT":0.327494,"consumption":76.715,"consumptionUnit":"kWh"}]},"monthly":{"nodes":[]},"yearly":{"nodes":[{"from":"2020-01-01T00:00:00.000+01:00","to":"2021-01-01T00:00:00.000+01:00","cost":240.545030375,"unitPrice":0.271799,"unitPriceVAT":0.05436,"consumption":885.01,"consumptionUnit":"kWh"},{"from":"2021-01-01T00:00:00.000+01:00","to":"2022-01-01T00:00:00.000+01:00","cost":34951.238516,"unitPrice":0.979518,"unitPriceVAT":0.195904,"consumption":35682.08,"consumptionUnit":"kWh"}]},"currentSubscription":{"status":"running","priceInfo":{"current":{"total":1.6576,"energy":1.3181,"tax":0.3395,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T00:00:00.000+01:00"},"today":[{"total":1.6576,"energy":1.3181,"tax":0.3395,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T00:00:00.000+01:00"},{"total":1.6596,"energy":1.3197,"tax":0.3399,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T01:00:00.000+01:00"},{"total":1.6182,"energy":1.2866,"tax":0.3316,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T02:00:00.000+01:00"},{"total":1.4547,"energy":1.1558,"tax":0.2989,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T03:00:00.000+01:00"},{"total":1.4283,"energy":1.1346,"tax":0.2937,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T04:00:00.000+01:00"},{"total":1.6745,"energy":1.3316,"tax":0.3429,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T05:00:00.000+01:00"},{"total":1.8044,"energy":1.4355,"tax":0.3689,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T06:00:00.000+01:00"},{"total":1.9481,"energy":1.5505,"tax":0.3976,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T07:00:00.000+01:00"},{"total":2.1101,"energy":1.6801,"tax":0.43,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T08:00:00.000+01:00"},{"total":2.0947,"energy":1.6678,"tax":0.4269,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T09:00:00.000+01:00"},{"total":2.1027,"energy":1.6742,"tax":0.4285,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T10:00:00.000+01:00"},{"total":2.0693,"energy":1.6474,"tax":0.4219,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T11:00:00.000+01:00"},{"total":2.0112,"energy":1.601,"tax":0.4102,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T12:00:00.000+01:00"},{"total":1.9576,"energy":1.5581,"tax":0.3995,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T13:00:00.000+01:00"},{"total":1.951,"energy":1.5528,"tax":0.3982,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T14:00:00.000+01:00"},{"total":1.9921,"energy":1.5857,"tax":0.4064,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T15:00:00.000+01:00"},{"total":2.0284,"energy":1.6147,"tax":0.4137,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T16:00:00.000+01:00"},{"total":2.1086,"energy":1.6789,"tax":0.4297,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T17:00:00.000+01:00"},{"total":2.0673,"energy":1.6458,"tax":0.4215,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T18:00:00.000+01:00"},{"total":1.9349,"energy":1.54,"tax":0.3949,"currency":"NOK","level":"EXPENSIVE","startsAt":"2022-01-04T19:00:00.000+01:00"},{"total":1.8465,"energy":1.4692,"tax":0.3773,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T20:00:00.000+01:00"},{"total":1.781,"energy":1.4168,"tax":0.3642,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T21:00:00.000+01:00"},{"total":1.7265,"energy":1.3732,"tax":0.3533,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-04T22:00:00.000+01:00"},{"total":1.4392,"energy":1.1434,"tax":0.2958,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-04T23:00:00.000+01:00"}],"tomorrow":[]}}}]}}}'
 
  jsonTable = json.decode(apiResult) -- Decode the json string from api to lua-table 
  
  self:getValues()
  self:updateLabels()
  self:updateProperties()
  self:updateChildDevices() 
  
  self:logging(3,"SetTimeout " ..interval .." seconds")
  fibaro.setTimeout(interval*1000, function() 
     self:simData()
  end)
end


function QuickApp:getData()
  self:logging(3,"getData")
  data = os.date("*t")
  local url = "https://api.tibber.com/v1-beta/gql"
  local requestBody = '{"query": "{viewer {homes {hourly: consumption(resolution: HOURLY, last: ' ..data.hour ..') {nodes {from to cost unitPrice unitPriceVAT consumption consumptionUnit}}daily: consumption(resolution: DAILY, last: ' ..data.day-1 ..') {nodes {from to cost unitPrice unitPriceVAT consumption consumptionUnit}}monthly: consumption(resolution: MONTHLY, last: ' ..data.month-1 ..') {nodes {from to cost unitPrice unitPriceVAT consumption consumptionUnit}}yearly: consumption(resolution: ANNUAL, last: ' ..data.year-2000 ..') {nodes {from to cost unitPrice unitPriceVAT consumption consumptionUnit}}currentSubscription {status priceInfo {current {total energy tax currency level startsAt}today {total energy tax currency level startsAt}tomorrow {total energy tax currency level startsAt}}}}}}"}'
  
  self:logging(3,"requestBody: " ..requestBody)

  http:request(url, {
    options = {
      data = requestBody,
      method = "POST",
      headers = {
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["Authorization"] = "Bearer " ..token,
      }
    },
    success = function(response) 
        self:logging(3,"response status: " ..response.status)
        self:logging(3,"headers: " ..response.headers["Content-Type"])
        self:logging(2,"Response data: " ..response.data)

        if response.data == nil or response.data == "" or response.data == "[]" or response.status > 200 then -- Check for empty result
          self:warning("Temporarily no production data from Tibber Monitor")
          self:logging(3,"SetTimeout " ..interval .." seconds")
          fibaro.setTimeout(interval*1000, function() 
            self:getdata()
          end)
        end

        response.data = response.data:gsub("null", "0") -- clean up the response.data by replacing null with 0
        --self:logging(3,"Response data without null: " ..response.data)

        jsonTable = json.decode(response.data) -- JSON decode from api to lua-table

        self:getValues()
        self:updateLabels()
        self:updateProperties()
        self:updateChildDevices() 

      end,
      error = function(error)
        self:error("error: " ..json.encode(error))
        self:updateProperty("log", "error: " ..json.encode(error))
      end
    }) 
  
  self:logging(3,"SetTimeout " ..interval .." seconds")
  fibaro.setTimeout(interval*1000, function() 
     self:getData()
  end)
end


function QuickApp:createVariables() -- Create all Variables 
  jsonTable = {}
  jsonPrices = {}
  data = {}
  data.hEnergy = 0 -- Hourly data
  data.hCost = 0
  data.dEnergy = 0 -- Daily data
  data.dCost = 0
  data.mEnergy = 0 -- Monthly data
  data.mCost = 0
  data.yEnergy = 0 -- Yearly data
  data.yCost = 0
  data.tEnergy = 0 -- Total data
  data.tCost = 0
  data.minPrice = 0 -- Minimum Price
  data.minPercentage = 0
  data.minLevel = ""
  data.minStartsAt = ""
  data.maxPrice = 0 -- Maximum Price
  data.maxPercentage = 0
  data.maxLevel = ""
  data.maxStartsAt = ""
  data.averagePrice = 0 -- Average Price
  data.tPrice = 0 -- Total Price
  data.gPrice = 0 -- (Gross) Energy Price
  data.tax = 0 -- Tax Price
  data.currency = "" 
  data.level = ""
  data.startsAt = ""
end


function QuickApp:getQuickAppVariables() -- Get all Quickapp Variables or create them
  token =         self:getVariable("token")
  homeNr =        tonumber(self:getVariable("homeNr"))
  extraCost =     tonumber(self:getVariable("extraCost")) 
  interval =      tonumber(self:getVariable("interval")) 
  httpTimeout =   tonumber(self:getVariable("httpTimeout")) 
  debugLevel =    tonumber(self:getVariable("debugLevel"))
  setGlobalVar =  string.lower(self:getVariable("setGlobalVar"))
  setPercentage = string.lower(self:getVariable("setPercentage"))
  forNextHour =   tonumber(self:getVariable("forNextHour"))
  local icon =    tonumber(self:getVariable("icon")) 

  -- Check existence of the mandatory variables, if not, create them with default values
  if token == "" or token == nil then
    token = "476c477d8a039529478ebd690d35ddd80e3308ffc49b59c65b142321aee963a4" -- This token is just an demo example, only for demo purposes
    self:setVariable("token",token)
    self:trace("Added QuickApp variable with DEMO (!) token")
  end
  if homeNr == "" or homeNr == nil then
    homeNr = "1"
    self:setVariable("homeNr",homeNr)
    self:trace("Added QuickApp variable homeNr")
    homeNr = tonumber(homeNr)
  end
  if extraCost == "" or extraCost == nil then
    extraCost = "0"
    self:setVariable("extraCost",extraCost)
    self:trace("Added QuickApp variable extraCost")
    extraCost = tonumber(extraCost)
  end
  if interval == "" or interval == nil then
    interval = "930" 
    self:setVariable("interval",interval)
    self:trace("Added QuickApp variable interval")
    interval = tonumber(interval)
  end
  if httpTimeout == "" or httpTimeout == nil then
    httpTimeout = "5" -- Default http timeout 
    self:setVariable("httpTimeout",httpTimeout)
    self:trace("Added QuickApp variable httpTimeout")
    httpTimeout = tonumber(httpTimeout)
  end 
  if debugLevel == "" or debugLevel == nil then
    debugLevel = "1" -- Default debug level
    self:setVariable("debugLevel",debugLevel)
    self:trace("Added QuickApp variable debugLevel")
    debugLevel = tonumber(debugLevel)
  end
  if setGlobalVar == "" or setGlobalVar == nil then 
    setGlobalVar = false -- Default SetGlobalVar is falso (No use of Global Variables)
    self:setVariable("setGlobalVar",tostring(setGlobalVar))
    self:trace("Added QuickApp variable setGlobalVar")
  end
  if setGlobalVar == "true" then 
    setGlobalVar = true 
  else
    setGlobalVar = false
  end
  if setPercentage == "" or setPercentage == nil then 
    setPercentage = "average" -- Default value
    self:setVariable("setPercentage",tostring(setPercentage))
    self:trace("Added QuickApp variable setPercentage")
  elseif setPercentage ~= "current" and setPercentage ~= "average" then 
    setPercentage = "average" 
  end
  if token == nil or token == ""  or token == "0" then -- Check mandatory token 
    self:error("Token is empty! Get your token from the Tibber website and copy the token to the quickapp variable")
    self:warning("No token, switched to Simulation Mode")
    debugLevel = 4 -- Simulation mode due to empty token
  end
  if forNextHour == "" or forNextHour == nil or forNextHour < 12 or forNextHour > 35 then
    forNextHour = "12" -- Default value
    self:setVariable("forNextHour",forNextHour)
    self:trace("Added QuickApp variable forNextHour")
    forNextHour = tonumber(forNextHour)
  end
  if icon == "" or icon == nil then 
    icon = "0" -- Default no user defined icon 
    self:setVariable("icon",icon)
    self:trace("Added QuickApp variable icon")
    icon = tonumber(icon)
  end
  if icon ~= 0 then 
    self:updateProperty("deviceIcon", icon) -- Set user defined icon 
  end
end
  

function QuickApp:setupChildDevices() -- Setup Child Devices
  local cdevs = api.get("/devices?parentId="..self.id) or {} -- Pick up all Child Devices
  function self:initChildDevices() end -- Null function, else Fibaro calls it after onInit()...

  if #cdevs == 0 then -- If no Child Devices, create them
    local initChildData = { 
      {className="hEnergy", name="Hourly Energy", type="com.fibaro.multilevelSensor"},
      {className="hCost", name="Hourly Cost", type="com.fibaro.multilevelSensor"},
      {className="dEnergy", name="Daily Energy", type="com.fibaro.energyMeter"}, -- Device for values Energy Panel
      {className="dCost", name="Daily Cost", type="com.fibaro.multilevelSensor"},
      {className="mEnergy", name="Monthly Energy", type="com.fibaro.multilevelSensor"},
      {className="mCost", name="Monthly Cost", type="com.fibaro.multilevelSensor"},
      {className="yEnergy", name="Yearly Energy", type="com.fibaro.multilevelSensor"}, 
      {className="yCost", name="Yearly Cost", type="com.fibaro.multilevelSensor"},
      {className="tEnergy", name="Total Energy", type="com.fibaro.multilevelSensor"},
      {className="tCost", name="Total Cost", type="com.fibaro.multilevelSensor"},
      {className="hPrice", name="Current Price", type="com.fibaro.multilevelSensor"},
      {className="minPrice", name="Minimum Price", type="com.fibaro.multilevelSensor"},
      {className="maxPrice", name="Maximum Price", type="com.fibaro.multilevelSensor"},
      {className="averagePrice", name="Average Price", type="com.fibaro.multilevelSensor"},
      {className="h0Percentage", name="+0 hour", type="com.fibaro.multilevelSensor"},
      {className="h1Percentage", name="+1 hour", type="com.fibaro.multilevelSensor"},
      {className="h2Percentage", name="+2 hour", type="com.fibaro.multilevelSensor"},
      {className="h3Percentage", name="+3 hour", type="com.fibaro.multilevelSensor"},
      {className="h4Percentage", name="+4 hour", type="com.fibaro.multilevelSensor"},
      {className="h5Percentage", name="+5 hour", type="com.fibaro.multilevelSensor"},
      {className="h6Percentage", name="+6 hour", type="com.fibaro.multilevelSensor"},
      {className="h7Percentage", name="+7 hour", type="com.fibaro.multilevelSensor"},
      {className="h8Percentage", name="+8 hour", type="com.fibaro.multilevelSensor"},
      {className="h9Percentage", name="+9 hour", type="com.fibaro.multilevelSensor"},
      {className="h10Percentage", name="+10 hour", type="com.fibaro.multilevelSensor"},
    }
    for _,c in ipairs(initChildData) do
      local ips = UI and self:makeInitialUIProperties(UI or {}) or {}
      local child = self:createChildDevice(
        {name = c.name,
          type=c.type,
          properties = {viewLayout = ips.viewLayout, uiCallbacks = ips.uiCallbacks},
          interfaces = {"quickApp"}, 
        },
        _G[c.className] -- Fetch class constructor from class name
      )
      child:setVariable("className",c.className) -- Save class name so we know when we load it next time
    end   
  else 
    for _,child in ipairs(cdevs) do
      local className = getChildVariable(child,"className") -- Fetch child class name
      local childObject = _G[className](child) -- Create child object from the constructor name
      self.childDevices[child.id]=childObject
      childObject.parent = self -- Setup parent link to device controller 
    end
  end
end


function QuickApp:onInit()
  __TAG = fibaro.getName(plugin.mainDeviceId) .." ID:" ..plugin.mainDeviceId
  self:debug("onInit") 

  self:setupChildDevices() -- Setup the Child Devices

  if not api.get("/devices/"..self.id).enabled then
    self:warning("Device", fibaro.getName(plugin.mainDeviceId), "is disabled")
    return
  end
  
  self:getQuickAppVariables() 
  self:createVariables()
  
  http = net.HTTPClient({timeout=httpTimeout*1000})
  
  if tonumber(debugLevel) >= 4 then 
    self:simData() -- Go in simulation
  else
    self:getData() -- Get data from the Tibber platform
  end
end

-- EOF
