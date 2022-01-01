-- QUICKAPP Tibber Monitor

-- This QuickApp gets todays an tomorrows energy prices from the Tibber platform. 
-- Next to the current prices the lowest and highest price for the next 12 hours is calculated.
-- Tax and extra cost (cable owner) are included in the hourly, daily, monthly, yearly and total cost.  
-- All values are displayed in the labels. 
-- Child devices are available for:
   -- Hourly energy usage
   -- Hourly energy cost
   -- Todays energy usage (com.fibaro.energyMeter with automatic rateType=consumption for Fibaro Energy Panel)
   -- Todays energy cost (including fees)
   -- Monthly energy usage
   -- Monthly energy cost
   -- Yearly energy usage
   -- Yearly energy cost
   -- Total energy usage
   -- Total energy cost
   -- Actual price now
   -- Minumum price today (for the next 12 hours)
   -- Maximum price today (for the next 12 hours)
   -- Percentage +1 hour (compaired to actual price now, positive value means an increase of the price, negative value means a decrease of the price)
   -- Percentage +2 hour
   -- Percentage +3 hour
   -- Percentage +4 hour
   -- Percentage +5 hour
-- These values can be used to control appliances according to the lowest and forecast prices during the day. 

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

-- Tibber API documentation: https://developer.tibber.com/docs/guides/calling-api
-- Tibber API explorer: https://developer.tibber.com/explorer


-- ToDo:
-- Current energy usage Watt (real time subscription = QuickApp with WebSocket?) (main device = powerSensor)
-- Create global variables for ?


-- Changes version 0.5 (1st Januari 2021)
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
-- interval = Interval in seconds to get the data from the Tibber Platform. The default is 3600 seconds (60 minutes). (Tibber has a rate limit of 100 requests in 5 minutes per IP address)
-- debugLevel = Number (1=some, 2=few, 3=all, 4=simulation mode) (default = 1)
-- setGlobalVar = true or false, whether you want tu use the Global Variables (default = false)
-- icon = User defined icon number (add the icon via another device and lookup the number) (default = 0)


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
  self:updateProperty("value", data.hCost+(extraCost*data.hEnergy))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.hCost) .." + " ..string.format("%.2f",extraCost*data.hEnergy))
end

class 'dEnergy'(QuickAppChild)
function dEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "consumption" then 
    self:updateProperty("rateType", "consumption")
    self:warning("Changed rateType interface of Daily Energy child device (" ..self.id ..") to consumption")
  end
end
function dEnergy:updateValue(data) 
  self:updateProperty("value", data.dEnergy)
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'dCost'(QuickAppChild)
function dCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function dCost:updateValue(data) 
  self:updateProperty("value", data.dCost+(extraCost*data.dEnergy))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.dCost) .." + " ..string.format("%.2f",extraCost*data.dEnergy))
end

class 'mEnergy'(QuickAppChild)
function mEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
end
function mEnergy:updateValue(data) 
  self:updateProperty("value", data.mEnergy)
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'mCost'(QuickAppChild)
function mCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function mCost:updateValue(data) 
  self:updateProperty("value", data.mCost+(extraCost*data.mEnergy))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.mCost) .." + " ..string.format("%.2f",extraCost*data.mEnergy))
end

class 'yEnergy'(QuickAppChild)
function yEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
end
function yEnergy:updateValue(data) 
  self:updateProperty("value", data.yEnergy)
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'yCost'(QuickAppChild)
function yCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function yCost:updateValue(data) 
  self:updateProperty("value", data.yCost+(extraCost*data.yEnergy))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.yCost) .." + " ..string.format("%.2f",extraCost*data.yEnergy))
end

class 'tEnergy'(QuickAppChild)
function tEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
end
function tEnergy:updateValue(data) 
  self:updateProperty("value", data.tEnergy)
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'tCost'(QuickAppChild)
function tCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function tCost:updateValue(data) 
  self:updateProperty("value", data.tCost+(extraCost*data.tEnergy))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", string.format("%.2f",data.tCost) .." + " ..string.format("%.2f",extraCost*data.tEnergy))
end

class 'hPrice'(QuickAppChild)
function hPrice:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hPrice:updateValue(data) 
  self:updateProperty("value", data.tPrice)
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", data.level)
end

class 'minPrice'(QuickAppChild)
function minPrice:__init(dev)
  QuickAppChild.__init(self,dev)
end
function minPrice:updateValue(data) 
  self:updateProperty("value", data.minPrice)
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", data.minStartsAt .." " ..data.minLevel)
end

class 'maxPrice'(QuickAppChild)
function maxPrice:__init(dev)
  QuickAppChild.__init(self,dev)
end
function maxPrice:updateValue(data) 
  self:updateProperty("value", data.maxPrice)
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", data.maxStartsAt .." "..data.maxLevel)
end

class 'h1Percentage'(QuickAppChild)
function h1Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h1Percentage:updateValue(data) 
  self:updateProperty("value", data.h1Percentage)
  self:updateProperty("unit", "%")
  self:updateProperty("log", " ")
end

class 'h2Percentage'(QuickAppChild)
function h2Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h2Percentage:updateValue(data) 
  self:updateProperty("value", data.h2Percentage)
  self:updateProperty("unit", "%")
  self:updateProperty("log", " ")
end

class 'h3Percentage'(QuickAppChild)
function h3Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h3Percentage:updateValue(data) 
  self:updateProperty("value", data.h3Percentage)
  self:updateProperty("unit", "%")
  self:updateProperty("log", " ")
end

class 'h4Percentage'(QuickAppChild)
function h4Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h4Percentage:updateValue(data) 
  self:updateProperty("value", data.h4Percentage)
  self:updateProperty("unit", "%")
  self:updateProperty("log", " ")
end

class 'h5Percentage'(QuickAppChild)
function h5Percentage:__init(dev)
  QuickAppChild.__init(self,dev)
end
function h5Percentage:updateValue(data) 
  self:updateProperty("value", data.h5Percentage)
  self:updateProperty("unit", "%")
  self:updateProperty("log", " ")
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
  if setGlobalVar then -- self:setGlobalVariable("[nameOfGlobal]_"..plugin.mainDeviceId,[value])
    if api.get("/globalVariables/"..tag) == nil then
      local responseData, status = api.post("/globalVariables/",{value=(json.encode(res)),name=tag})
      self:trace("Global Variable created: " ..tag .." / status: " ..status) 
    else
      local responseData, status = api.put("/globalVariables/"..tag,{value=(json.encode(res))})
    end
  else
    if api.get("/globalVariables/"..tag) then
      self:deleteGlobalVariable(tag) -- If the Global Variable exists, delete it
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
  --self:updateProperty("unit", "")
  self:updateProperty("log", data.startsAt)
end


function QuickApp:updateLabels() -- Update the labels
  self:logging(3,"updateLabels")

  local labelText = ""
  if debugLevel == 4 then
    labelText = labelText .."SIMULATION MODE" .."\n\n"
  end

  labelText = labelText .."Hourly Energy: " ..data.hEnergy .." kWh / Cost: " ..string.format("%.2f",data.hCost+(extraCost*data.hEnergy)) .." " ..data.currency .."\n"
  labelText = labelText .."Daily Energy: " ..data.dEnergy .." kWh / Cost: " ..string.format("%.2f",data.dCost+(extraCost*data.dEnergy)) .." " ..data.currency .."\n"
  labelText = labelText .."Monthly Energy: " ..data.mEnergy .." kWh / Cost: " ..string.format("%.2f",data.mCost+(extraCost*data.mEnergy)) .." " ..data.currency .."\n"
  labelText = labelText .."Yearly Energy: " ..data.yEnergy .." kWh / Cost: " ..string.format("%.2f",data.yCost+(extraCost*data.yEnergy))  .." " ..data.currency .."\n"
  labelText = labelText .."Total Energy: " ..data.tEnergy .." kWh / Cost: " ..string.format("%.2f",data.tCost+(extraCost*data.tEnergy))  .." " ..data.currency .."\n\n"
  
  labelText = labelText .."Actual Price: " ..data.tPrice .." " ..data.currency .." per kWh (" ..data.level ..")" .."\n"
  labelText = labelText .."Energy: " ..data.gPrice .." " ..data.currency .." / Tax: " ..data.tax .." Cost: " ..extraCost .." " ..data.currency .."\n"
  labelText = labelText .."Starts at: " ..data.startsAt .."\n\n"
  
  labelText = labelText .."Next 12 hours:" .."\n"
  labelText = labelText .."Lowest: " ..data.minPrice .." " ..data.currency .." at: " ..data.minStartsAt .." " ..data.minLevel .."\n"
  labelText = labelText .."Highest: " ..data.maxPrice .." " ..data.currency .." at: " ..data.maxStartsAt .." " ..data.maxLevel .."\n\n"

  for n in pairs(jsonPrices or {}) do
    labelText = labelText .."Price: " ..jsonPrices[n].total .." " ..data.currency .." at: " ..jsonPrices[n].hour .." " ..jsonPrices[n].level .."\n"
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
  data.tEnergy = tonumber(string.format("%.4f",data.tEnergy + data.yEnergy)) -- Add last year values
  data.tCost = tonumber(string.format("%.2f",data.tCost + data.yCost))
  self:logging(3,"data.tEnergy: " ..tostring(data.tEnergy))
  self:logging(3,"data.tCost: " ..tostring(data.tCost))
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
  data.yEnergy = tonumber(string.format("%.4f",data.yEnergy + data.mEnergy)) -- Add last month values
  data.yCost = tonumber(string.format("%.2f",data.yCost + data.mCost))
  self:logging(3,"data.yEnergy: " ..tostring(data.yEnergy))
  self:logging(3,"data.yCost: " ..tostring(data.yCost))
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
  data.mEnergy = tonumber(string.format("%.4f",data.mEnergy + data.dEnergy)) -- Add last days values
  data.mCost = tonumber(string.format("%.2f",data.mCost + data.dCost))
  self:logging(3,"data.mEnergy: " ..tostring(data.mEnergy))
  self:logging(3,"data.mCost: " ..tostring(data.mCost))
end

function QuickApp:getValuesDaily() -- Get Daily values from json file 
  self:logging(3,"getValuesDaily")
  data.dEnergy = 0
  data.dCost = 0
  for hour in pairs(jsonTable.data.viewer.homes[homeNr].hourly.nodes or {}) do  -- Sum all hours of the day
    self:logging(3,"hour: " ..tostring(hour))
    data.dEnergy = data.dEnergy + tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption))
    data.dCost = data.dCost + tonumber(string.format("%.2f",jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost))
    data.hEnergy = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption))
    data.hCost = tonumber(string.format("%.2f",jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost))
  end
  self:logging(3,"data.dEnergy: " ..tostring(data.dEnergy))
  self:logging(3,"data.dCost: " ..tostring(data.dCost))
end


function QuickApp:getValues() -- Get the values from json file 
  self:logging(3,"getValues")
  
  self:getValuesDaily()
  self:getValuesMonthly()
  self:getValuesYearly()
  self:getValuesTotal()
  
  data.tPrice =   tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.total))
  data.gPrice =   tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.energy))
  data.tax =      tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.tax))
  data.currency = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.currency
  data.level =    jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.level:gsub("_", " ") 
  data.startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.startsAt
  
  local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).(%d+)+(%d+):(%d+)" --2021-12-23T17:00:00.000+01:00
  local runyear, runmonth, runday, runhour, runminute, runseconds = data.startsAt:match(pattern)
  local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
  data.startsAt = os.date("%d-%m-%Y %H:%M", convertedTimestamp)

  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today or {}) do -- Insert all tadays prices to table jsonPrices
    if hour-1 >= tonumber(runhour) and hour-1 < tonumber(runhour)+12 then
      table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total), level = "(" ..jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].level:gsub("_", " ")  ..")", startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].startsAt})
    end
  end

  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow or {}) do -- Insert all tomorrow prices to table jsonPrices
    if 24-tonumber(runhour)+hour <= 12 then 
      table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total), level = "(" ..jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].level:gsub("_", " ")  ..")", startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].startsAt})
    end
  end
  self:logging(3,"Today and Tomorrow Prices: " ..json.encode(jsonPrices))

  local total = 0
  data.minPrice = 999 -- Return to initial value to force new lowest price
  data.maxPrice = 0 -- Return to initial value to force new highest price
  for n in pairs(jsonPrices or {}) do
    total = tonumber(string.format("%.4f",jsonPrices[n].total))
    if total <= data.minPrice then
      data.minPrice = tonumber(total)
      data.minLevel = jsonPrices[n].level
      data.minStartsAt = jsonPrices[n].hour
    end
    if total >= data.maxPrice then
      data.maxPrice = tonumber(total)
      data.maxLevel = jsonPrices[n].level 
      data.maxStartsAt = jsonPrices[n].hour
    end  
    if n == 2 then
      data.h1Percentage = (total-data.tPrice)/data.tPrice*100
    elseif n == 3 then
      data.h2Percentage = (total-data.tPrice)/data.tPrice*100
    elseif n == 4 then
      data.h3Percentage = (total-data.tPrice)/data.tPrice*100
    elseif n == 5 then
      data.h4Percentage = (total-data.tPrice)/data.tPrice*100
    elseif n == 6 then
      data.h5Percentage = (total-data.tPrice)/data.tPrice*100
    end
  end
  self:logging(3,"data: " ..json.encode(data))
end


function QuickApp:simData() -- Simulate Tibber Platform
  self:logging(3,"simData")
  apiResult = '{"data":{"viewer":{"homes":[{"hourly":{"nodes":[{"from":"2021-12-31T00:00:00.000+01:00","to":"2021-12-31T01:00:00.000+01:00","cost":0.69832125,"unitPrice":0.38475,"unitPriceVAT":0.07695,"consumption":1.815,"consumptionUnit":"kWh"},{"from":"2021-12-31T01:00:00.000+01:00","to":"2021-12-31T02:00:00.000+01:00","cost":0.551745225,"unitPrice":0.336225,"unitPriceVAT":0.067245,"consumption":1.641,"consumptionUnit":"kWh"},{"from":"2021-12-31T02:00:00.000+01:00","to":"2021-12-31T03:00:00.000+01:00","cost":0.69266925,"unitPrice":0.323375,"unitPriceVAT":0.064675,"consumption":2.142,"consumptionUnit":"kWh"},{"from":"2021-12-31T03:00:00.000+01:00","to":"2021-12-31T04:00:00.000+01:00","cost":0.4197159,"unitPrice":0.309525,"unitPriceVAT":0.061905,"consumption":1.356,"consumptionUnit":"kWh"},{"from":"2021-12-31T04:00:00.000+01:00","to":"2021-12-31T05:00:00.000+01:00","cost":0.655614,"unitPrice":0.3195,"unitPriceVAT":0.0639,"consumption":2.052,"consumptionUnit":"kWh"},{"from":"2021-12-31T05:00:00.000+01:00","to":"2021-12-31T06:00:00.000+01:00","cost":0.550834375,"unitPrice":0.3147625,"unitPriceVAT":0.0629525,"consumption":1.75,"consumptionUnit":"kWh"},{"from":"2021-12-31T06:00:00.000+01:00","to":"2021-12-31T07:00:00.000+01:00","cost":0.690819425,"unitPrice":0.349075,"unitPriceVAT":0.069815,"consumption":1.979,"consumptionUnit":"kWh"},{"from":"2021-12-31T07:00:00.000+01:00","to":"2021-12-31T08:00:00.000+01:00","cost":0.6880113625,"unitPrice":0.3884875,"unitPriceVAT":0.0776975,"consumption":1.771,"consumptionUnit":"kWh"},{"from":"2021-12-31T08:00:00.000+01:00","to":"2021-12-31T09:00:00.000+01:00","cost":0.5173125,"unitPrice":0.4171875,"unitPriceVAT":0.0834375,"consumption":1.24,"consumptionUnit":"kWh"},{"from":"2021-12-31T09:00:00.000+01:00","to":"2021-12-31T10:00:00.000+01:00","cost":1.032214375,"unitPrice":0.449375,"unitPriceVAT":0.089875,"consumption":2.297,"consumptionUnit":"kWh"},{"from":"2021-12-31T10:00:00.000+01:00","to":"2021-12-31T11:00:00.000+01:00","cost":0.577790475,"unitPrice":0.498525,"unitPriceVAT":0.099705,"consumption":1.159,"consumptionUnit":"kWh"},{"from":"2021-12-31T11:00:00.000+01:00","to":"2021-12-31T12:00:00.000+01:00","cost":1.3913659625,"unitPrice":0.5766125,"unitPriceVAT":0.1153225,"consumption":2.413,"consumptionUnit":"kWh"},{"from":"2021-12-31T12:00:00.000+01:00","to":"2021-12-31T13:00:00.000+01:00","cost":0.77490735,"unitPrice":0.6393625,"unitPriceVAT":0.1278725,"consumption":1.212,"consumptionUnit":"kWh"},{"from":"2021-12-31T13:00:00.000+01:00","to":"2021-12-31T14:00:00.000+01:00","cost":0.993094575,"unitPrice":0.6542125,"unitPriceVAT":0.1308425,"consumption":1.518,"consumptionUnit":"kWh"}]},"daily":{"nodes":[{"from":"2021-12-01T00:00:00.000+01:00","to":"2021-12-02T00:00:00.000+01:00","cost":106.060999675,"unitPrice":1.475837,"unitPriceVAT":0.295167,"consumption":71.865,"consumptionUnit":"kWh"},{"from":"2021-12-02T00:00:00.000+01:00","to":"2021-12-03T00:00:00.000+01:00","cost":154.2273203,"unitPrice":1.942312,"unitPriceVAT":0.388462,"consumption":79.404,"consumptionUnit":"kWh"},{"from":"2021-12-03T00:00:00.000+01:00","to":"2021-12-04T00:00:00.000+01:00","cost":103.512467425,"unitPrice":1.45622,"unitPriceVAT":0.291244,"consumption":71.083,"consumptionUnit":"kWh"},{"from":"2021-12-04T00:00:00.000+01:00","to":"2021-12-05T00:00:00.000+01:00","cost":82.70974565,"unitPrice":0.902147,"unitPriceVAT":0.180429,"consumption":91.681,"consumptionUnit":"kWh"},{"from":"2021-12-05T00:00:00.000+01:00","to":"2021-12-06T00:00:00.000+01:00","cost":99.077527775,"unitPrice":1.52104,"unitPriceVAT":0.304208,"consumption":65.138,"consumptionUnit":"kWh"},{"from":"2021-12-06T00:00:00.000+01:00","to":"2021-12-07T00:00:00.000+01:00","cost":81.2554525625,"unitPrice":1.492843,"unitPriceVAT":0.298569,"consumption":54.43,"consumptionUnit":"kWh"},{"from":"2021-12-07T00:00:00.000+01:00","to":"2021-12-08T00:00:00.000+01:00","cost":84.6237931,"unitPrice":1.502767,"unitPriceVAT":0.300553,"consumption":56.312,"consumptionUnit":"kWh"},{"from":"2021-12-08T00:00:00.000+01:00","to":"2021-12-09T00:00:00.000+01:00","cost":72.1906358875,"unitPrice":0.900088,"unitPriceVAT":0.180018,"consumption":80.204,"consumptionUnit":"kWh"},{"from":"2021-12-09T00:00:00.000+01:00","to":"2021-12-10T00:00:00.000+01:00","cost":38.134279075,"unitPrice":0.533361,"unitPriceVAT":0.106672,"consumption":71.498,"consumptionUnit":"kWh"},{"from":"2021-12-10T00:00:00.000+01:00","to":"2021-12-11T00:00:00.000+01:00","cost":47.0818948,"unitPrice":0.544608,"unitPriceVAT":0.108922,"consumption":86.451,"consumptionUnit":"kWh"},{"from":"2021-12-11T00:00:00.000+01:00","to":"2021-12-12T00:00:00.000+01:00","cost":49.6500579125,"unitPrice":0.637618,"unitPriceVAT":0.127524,"consumption":77.868,"consumptionUnit":"kWh"},{"from":"2021-12-12T00:00:00.000+01:00","to":"2021-12-13T00:00:00.000+01:00","cost":51.5612359125,"unitPrice":0.560022,"unitPriceVAT":0.112004,"consumption":92.07,"consumptionUnit":"kWh"},{"from":"2021-12-13T00:00:00.000+01:00","to":"2021-12-14T00:00:00.000+01:00","cost":32.533394475,"unitPrice":0.572731,"unitPriceVAT":0.114546,"consumption":56.804,"consumptionUnit":"kWh"},{"from":"2021-12-14T00:00:00.000+01:00","to":"2021-12-15T00:00:00.000+01:00","cost":34.6287187,"unitPrice":0.449461,"unitPriceVAT":0.089892,"consumption":77.045,"consumptionUnit":"kWh"},{"from":"2021-12-15T00:00:00.000+01:00","to":"2021-12-16T00:00:00.000+01:00","cost":17.1847222,"unitPrice":0.306963,"unitPriceVAT":0.061393,"consumption":55.983,"consumptionUnit":"kWh"},{"from":"2021-12-16T00:00:00.000+01:00","to":"2021-12-17T00:00:00.000+01:00","cost":18.02959695,"unitPrice":0.281317,"unitPriceVAT":0.056263,"consumption":64.09,"consumptionUnit":"kWh"},{"from":"2021-12-17T00:00:00.000+01:00","to":"2021-12-18T00:00:00.000+01:00","cost":22.1979754625,"unitPrice":0.300171,"unitPriceVAT":0.060034,"consumption":73.951,"consumptionUnit":"kWh"},{"from":"2021-12-18T00:00:00.000+01:00","to":"2021-12-19T00:00:00.000+01:00","cost":17.3707678625,"unitPrice":0.284538,"unitPriceVAT":0.056908,"consumption":61.049,"consumptionUnit":"kWh"},{"from":"2021-12-19T00:00:00.000+01:00","to":"2021-12-20T00:00:00.000+01:00","cost":38.5211196125,"unitPrice":0.29266,"unitPriceVAT":0.058532,"consumption":131.624,"consumptionUnit":"kWh"},{"from":"2021-12-20T00:00:00.000+01:00","to":"2021-12-21T00:00:00.000+01:00","cost":63.500660175,"unitPrice":0.734774,"unitPriceVAT":0.146955,"consumption":86.422,"consumptionUnit":"kWh"},{"from":"2021-12-21T00:00:00.000+01:00","to":"2021-12-22T00:00:00.000+01:00","cost":54.5404124125,"unitPrice":0.803518,"unitPriceVAT":0.160704,"consumption":67.877,"consumptionUnit":"kWh"},{"from":"2021-12-22T00:00:00.000+01:00","to":"2021-12-23T00:00:00.000+01:00","cost":52.78627495,"unitPrice":0.795705,"unitPriceVAT":0.159141,"consumption":66.339,"consumptionUnit":"kWh"},{"from":"2021-12-23T00:00:00.000+01:00","to":"2021-12-24T00:00:00.000+01:00","cost":35.979788125,"unitPrice":0.506465,"unitPriceVAT":0.101293,"consumption":71.041,"consumptionUnit":"kWh"},{"from":"2021-12-24T00:00:00.000+01:00","to":"2021-12-25T00:00:00.000+01:00","cost":37.692666025,"unitPrice":0.402111,"unitPriceVAT":0.080422,"consumption":93.737,"consumptionUnit":"kWh"},{"from":"2021-12-25T00:00:00.000+01:00","to":"2021-12-26T00:00:00.000+01:00","cost":39.78087125,"unitPrice":0.40795,"unitPriceVAT":0.08159,"consumption":97.514,"consumptionUnit":"kWh"},{"from":"2021-12-26T00:00:00.000+01:00","to":"2021-12-27T00:00:00.000+01:00","cost":43.0808987,"unitPrice":0.635421,"unitPriceVAT":0.127084,"consumption":67.799,"consumptionUnit":"kWh"},{"from":"2021-12-27T00:00:00.000+01:00","to":"2021-12-28T00:00:00.000+01:00","cost":58.3979845625,"unitPrice":0.744692,"unitPriceVAT":0.148938,"consumption":78.419,"consumptionUnit":"kWh"},{"from":"2021-12-28T00:00:00.000+01:00","to":"2021-12-29T00:00:00.000+01:00","cost":68.6274829375,"unitPrice":0.783598,"unitPriceVAT":0.15672,"consumption":87.58,"consumptionUnit":"kWh"},{"from":"2021-12-29T00:00:00.000+01:00","to":"2021-12-30T00:00:00.000+01:00","cost":62.8214135875,"unitPrice":0.869501,"unitPriceVAT":0.1739,"consumption":72.25,"consumptionUnit":"kWh"},{"from":"2021-12-30T00:00:00.000+01:00","to":"2021-12-31T00:00:00.000+01:00","cost":29.5539776375,"unitPrice":0.691305,"unitPriceVAT":0.138261,"consumption":42.751,"consumptionUnit":"kWh"}]},"monthly":{"nodes":[{"from":"2021-01-01T00:00:00.000+01:00","to":"2021-02-01T00:00:00.000+01:00","cost":1496.12567765,"unitPrice":0.575925,"unitPriceVAT":0.115185,"consumption":2597.78,"consumptionUnit":"kWh"},{"from":"2021-02-01T00:00:00.000+01:00","to":"2021-03-01T00:00:00.000+01:00","cost":1314.7741036625,"unitPrice":0.558941,"unitPriceVAT":0.111788,"consumption":2352.259,"consumptionUnit":"kWh"},{"from":"2021-03-01T00:00:00.000+01:00","to":"2021-04-01T00:00:00.000+02:00","cost":669.955541375,"unitPrice":0.321934,"unitPriceVAT":0.064387,"consumption":2081.031,"consumptionUnit":"kWh"},{"from":"2021-04-01T00:00:00.000+02:00","to":"2021-05-01T00:00:00.000+02:00","cost":652.4670385125,"unitPrice":0.333466,"unitPriceVAT":0.066693,"consumption":1956.621,"consumptionUnit":"kWh"},{"from":"2021-05-01T00:00:00.000+02:00","to":"2021-06-01T00:00:00.000+02:00","cost":463.37073145,"unitPrice":0.462631,"unitPriceVAT":0.092526,"consumption":1001.599,"consumptionUnit":"kWh"},{"from":"2021-06-01T00:00:00.000+02:00","to":"2021-07-01T00:00:00.000+02:00","cost":362.0896929625,"unitPrice":0.433144,"unitPriceVAT":0.086629,"consumption":835.957,"consumptionUnit":"kWh"},{"from":"2021-07-01T00:00:00.000+02:00","to":"2021-08-01T00:00:00.000+02:00","cost":424.3164585375,"unitPrice":0.584322,"unitPriceVAT":0.116864,"consumption":726.169,"consumptionUnit":"kWh"},{"from":"2021-08-01T00:00:00.000+02:00","to":"2021-09-01T00:00:00.000+02:00","cost":598.565520525,"unitPrice":0.706662,"unitPriceVAT":0.141332,"consumption":847.032,"consumptionUnit":"kWh"},{"from":"2021-09-01T00:00:00.000+02:00","to":"2021-10-01T00:00:00.000+02:00","cost":637.790824275,"unitPrice":0.673083,"unitPriceVAT":0.134617,"consumption":947.566,"consumptionUnit":"kWh"},{"from":"2021-10-01T00:00:00.000+02:00","to":"2021-11-01T00:00:00.000+01:00","cost":437.1167829875,"unitPrice":0.288513,"unitPriceVAT":0.057703,"consumption":1515.07,"consumptionUnit":"kWh"},{"from":"2021-11-01T00:00:00.000+01:00","to":"2021-12-01T00:00:00.000+01:00","cost":1154.2979161125,"unitPrice":0.572333,"unitPriceVAT":0.114467,"consumption":2016.83,"consumptionUnit":"kWh"}]},"yearly":{"nodes":[{"from":"2020-01-01T00:00:00.000+01:00","to":"2021-01-01T00:00:00.000+01:00","cost":1465.24875625,"unitPrice":0.127965,"unitPriceVAT":0.025593,"consumption":11450.413,"consumptionUnit":"kWh"}]},"currentSubscription":{"status":"running","priceInfo":{"current":{"total":0.6702,"energy":0.5281,"tax":0.1421,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-31T14:00:00.000+01:00"},"today":[{"total":0.3848,"energy":0.2998,"tax":0.085,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T00:00:00.000+01:00"},{"total":0.3362,"energy":0.261,"tax":0.0752,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T01:00:00.000+01:00"},{"total":0.3234,"energy":0.2507,"tax":0.0727,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T02:00:00.000+01:00"},{"total":0.3095,"energy":0.2396,"tax":0.0699,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T03:00:00.000+01:00"},{"total":0.3195,"energy":0.2476,"tax":0.0719,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T04:00:00.000+01:00"},{"total":0.3148,"energy":0.2438,"tax":0.071,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T05:00:00.000+01:00"},{"total":0.3491,"energy":0.2713,"tax":0.0778,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T06:00:00.000+01:00"},{"total":0.3885,"energy":0.3028,"tax":0.0857,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T07:00:00.000+01:00"},{"total":0.4172,"energy":0.3258,"tax":0.0914,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T08:00:00.000+01:00"},{"total":0.4494,"energy":0.3515,"tax":0.0979,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-31T09:00:00.000+01:00"},{"total":0.4985,"energy":0.3908,"tax":0.1077,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-31T10:00:00.000+01:00"},{"total":0.5766,"energy":0.4533,"tax":0.1233,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-31T11:00:00.000+01:00"},{"total":0.6394,"energy":0.5035,"tax":0.1359,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-31T12:00:00.000+01:00"},{"total":0.6542,"energy":0.5154,"tax":0.1388,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-31T13:00:00.000+01:00"},{"total":0.6702,"energy":0.5281,"tax":0.1421,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-31T14:00:00.000+01:00"},{"total":0.7006,"energy":0.5525,"tax":0.1481,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-31T15:00:00.000+01:00"},{"total":0.6918,"energy":0.5454,"tax":0.1464,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-31T16:00:00.000+01:00"},{"total":0.6686,"energy":0.5268,"tax":0.1418,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-31T17:00:00.000+01:00"},{"total":0.6364,"energy":0.5011,"tax":0.1353,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-31T18:00:00.000+01:00"},{"total":0.6089,"energy":0.4791,"tax":0.1298,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-31T19:00:00.000+01:00"},{"total":0.4336,"energy":0.3389,"tax":0.0947,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-31T20:00:00.000+01:00"},{"total":0.4227,"energy":0.3301,"tax":0.0926,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-31T21:00:00.000+01:00"},{"total":0.4134,"energy":0.3228,"tax":0.0906,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-31T22:00:00.000+01:00"},{"total":0.3812,"energy":0.297,"tax":0.0842,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-31T23:00:00.000+01:00"}],"tomorrow":[{"total":0.592,"energy":0.4656,"tax":0.1264,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T00:00:00.000+01:00"},{"total":0.5261,"energy":0.4129,"tax":0.1132,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T01:00:00.000+01:00"},{"total":0.5368,"energy":0.4214,"tax":0.1154,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T02:00:00.000+01:00"},{"total":0.5641,"energy":0.4433,"tax":0.1208,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T03:00:00.000+01:00"},{"total":0.4804,"energy":0.3763,"tax":0.1041,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T04:00:00.000+01:00"},{"total":0.5058,"energy":0.3966,"tax":0.1092,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T05:00:00.000+01:00"},{"total":0.5169,"energy":0.4055,"tax":0.1114,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T06:00:00.000+01:00"},{"total":0.5502,"energy":0.4322,"tax":0.118,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T07:00:00.000+01:00"},{"total":0.6274,"energy":0.4939,"tax":0.1335,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-01T08:00:00.000+01:00"},{"total":0.6277,"energy":0.4941,"tax":0.1336,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-01T09:00:00.000+01:00"},{"total":0.6253,"energy":0.4922,"tax":0.1331,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-01T10:00:00.000+01:00"},{"total":0.6206,"energy":0.4884,"tax":0.1322,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-01T11:00:00.000+01:00"},{"total":0.615,"energy":0.484,"tax":0.131,"currency":"NOK","level":"NORMAL","startsAt":"2022-01-01T12:00:00.000+01:00"},{"total":0.5621,"energy":0.4417,"tax":0.1204,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T13:00:00.000+01:00"},{"total":0.5392,"energy":0.4234,"tax":0.1158,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T14:00:00.000+01:00"},{"total":0.5356,"energy":0.4205,"tax":0.1151,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T15:00:00.000+01:00"},{"total":0.5382,"energy":0.4226,"tax":0.1156,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T16:00:00.000+01:00"},{"total":0.5169,"energy":0.4055,"tax":0.1114,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T17:00:00.000+01:00"},{"total":0.5109,"energy":0.4007,"tax":0.1102,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T18:00:00.000+01:00"},{"total":0.491,"energy":0.3848,"tax":0.1062,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T19:00:00.000+01:00"},{"total":0.4435,"energy":0.3468,"tax":0.0967,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T20:00:00.000+01:00"},{"total":0.4156,"energy":0.3245,"tax":0.0911,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T21:00:00.000+01:00"},{"total":0.4206,"energy":0.3285,"tax":0.0921,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T22:00:00.000+01:00"},{"total":0.4151,"energy":0.3241,"tax":0.091,"currency":"NOK","level":"CHEAP","startsAt":"2022-01-01T23:00:00.000+01:00"}]}}}]}}}'
 
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
        --self:logging(3,"Response data withoot null: " ..response.data)

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
  data.minPrice = 0 -- Min/Max Price
  data.minLevel = ""
  data.minStartsAt = ""
  data.maxPrice = 0
  data.maxLevel = ""
  data.maxStartsAt = ""
  data.h1Percentage = 0 -- Percentage +1 hour
  data.h2Percentage = 0
  data.h3Percentage = 0
  data.h4Percentage = 0
  data.h5Percentage = 0
  data.tPrice = 0 -- Todays Price
  data.gPrice = 0
  data.currency = ""
  data.level = ""
  data.tax = 0  
  data.startsAt = ""
end


function QuickApp:getQuickAppVariables() -- Get all Quickapp Variables or create them
  token = self:getVariable("token")
  homeNr = tonumber(self:getVariable("homeNr"))
  extraCost = tonumber(self:getVariable("extraCost")) 
  interval = tonumber(self:getVariable("interval")) 
  httpTimeout = tonumber(self:getVariable("httpTimeout")) 
  debugLevel = tonumber(self:getVariable("debugLevel"))
  setGlobalVar = self:getVariable("setGlobalVar")
  local icon = tonumber(self:getVariable("icon")) 

  -- Check existence of the mandatory variables, if not, create them with default values
  if token == "" or token == nil then
    token = "476c477d8a039529478ebd690d35ddd80e3308ffc49b59c65b142321aee963a4" -- This token is just an demo example, only for demo purpose
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
    interval = "3600" 
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
  if token == nil or token == ""  or token == "0" then -- Check mandatory token 
    self:error("Token is empty! Get your token from the Tibber website and copy the token to the quickapp variable")
    self:warning("No token Switched to Simulation Mode")
    debugLevel = 4 -- Simulation mode due to empty token
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
      {className="h1Percentage", name="+1 hour", type="com.fibaro.multilevelSensor"},
      {className="h2Percentage", name="+2 hour", type="com.fibaro.multilevelSensor"},
      {className="h3Percentage", name="+3 hour", type="com.fibaro.multilevelSensor"},
      {className="h4Percentage", name="+4 hour", type="com.fibaro.multilevelSensor"},
      {className="h5Percentage", name="+5 hour", type="com.fibaro.multilevelSensor"},
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
