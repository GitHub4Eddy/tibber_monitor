-- QUICKAPP Tibber Monitor

-- This QuickApp gets todays an tomorrows energy prices from the Tibber platform. 
-- Next to the current prices the lowest and highest price for the next 12 hours is calculated.
-- Tax and fees are included in the hourly, daily and yearly cost.  
-- All values are displayed in the labels. 
-- Child devices are available for:
   -- Hourly energy usage
   -- Hourly energy cost
   -- Todays energy usage (com.fibaro.energyMeter with automatic rateType=consumption for Fibaro Energy Panel)
   -- Todays energy cost (including fees)
   -- Yearly energy usage
   -- Yearly energy cost
   -- Actual price now
   -- Minumum price today (for the next 12 hours)
   -- Maximum price today (for the next 12 hours)
   -- Percentage +1 hour (compaired to actual price now, positive value means a increase of the price, negative value means a decrease of the price)
   -- Percentage +2 hour
   -- Percentage +3 hour
   -- Percentage +4 hour
   -- Percentage +5 hour
-- These values can be used to control appliances according to the lowest and forecast prices during the day. 

-- To communicate with the API you need to acquire a OAuth access token and pass this along with every request passed to the server.
-- A Personal Access Token give you access to your data and your data only. 
-- This is ideal for DIY people that want to leverage the Tibber platform to extend the smartness of their home. 
-- Such a token can be acquired here: https://thewall.tibber.com

-- When creating your access token or OAuth client you’ll be asked which scopes you want the access token to be associated with. 
-- These scopes tells the API which data and operations the client is allowed to perfom on the user’s behalf. 
-- The scopes your app requires depend on the type of data it is trying to request. 
-- If you for example need access to user information you add the USER scope. 
-- If information about the users homes is needed you add the appropiate HOME scopes.

-- Tomorrow values are available from 13:00 hour

-- Tibber API documentation: https://developer.tibber.com/docs/guides/calling-api
-- Tibber API explorer: https://developer.tibber.com/explorer


-- ToDo:
-- Main device Current energy usage Watt (real time subscription = WebSocket?) (main device = powerSensor)
-- Create global variables for ?
-- Total energy usage not available? 


-- Changes version 0.2 (29th December 2021)
-- Added all child devices
-- Added QuickApp variable for extra cost and added the cost to the calculations
-- Replaced "null" values in response to prevent errors
-- Limited values to next 12 hours


-- Changes version 0.1 (23rd December 2021)
-- Initial version


-- Variables (mandatory and created automatically): 
-- token = Authorization token (see the Tibber website: https://thewall.tibber.com)
-- extraCost = Extra cost per kWh for Tibber and Cable owner, decimals with dot, not komma (default = 0)
-- interval = Interval in seconds to get the data from the Tibber Platform. The default request interval is 3600 seconds (60 minutes).
-- debugLevel = Number (1=some, 2=few, 3=all, 4=simulation mode) (default = 1)
-- setGlobalVar = true or false, whether you want tu use the Global Variables (default = false)


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
  self:updateProperty("value", data.hCost)
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", " ")
end

class 'dEnergy'(QuickAppChild)
function dEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "consumption" then 
    self:updateProperty("rateType", "consumption")
    self:warning("Changed rateType interface of Todays Consumption child device (" ..self.id ..") to consumption")
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
  self:updateProperty("value", data.dCost)
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", " ")
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
  self:updateProperty("value", data.yCost)
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", " ")
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
  self:updateProperty("value", 0) -- For future use
  self:updateProperty("unit", "")
  self:updateProperty("log", data.startsAt)
end


function QuickApp:updateLabels() -- Update the labels
  self:logging(3,"updateLabels")
  
  local labelText = ""
  if debugLevel == 4 then
    labelText = labelText .."SIMULATION MODE" .."\n\n"
  end
  labelText = labelText .."Hourly Energy: " ..data.hEnergy .." kWh / Cost: " ..string.format("%.2f",data.hCost+data.hTax+(extraCost*data.hEnergy)) .." " ..data.currency .."\n"
  labelText = labelText .."Daily Energy: " ..data.dEnergy .." kWh / Cost: " ..string.format("%.2f",data.dCost+data.dTax+(extraCost*data.dEnergy)) .." " ..data.currency .."\n"
  labelText = labelText .."Yearly Energy: " ..data.yEnergy .." kWh / Cost: " ..string.format("%.2f",data.yCost+data.yTax+(extraCost*data.yEnergy))  .." " ..data.currency .."\n\n"
  
  labelText = labelText .."Actual Price: " ..data.tPrice .." " ..data.currency .." per kWh (" ..data.level ..")" .."\n"
  labelText = labelText .."Energy: " ..data.gPrice .." " ..data.currency .." / Tax: " ..data.tax .." Cost: " ..extraCost .." " ..data.currency .."\n"
  labelText = labelText .."Starts at: " ..data.startsAt .."\n\n"
  
  labelText = labelText .."Next 12 hours:" .."\n"
  labelText = labelText .."Lowest: " ..data.minPrice .." " ..data.currency .." at: " ..data.minStartsAt .." " ..data.minLevel .."\n"
  labelText = labelText .."Highest: " ..data.maxPrice .." " ..data.currency .." at: " ..data.maxStartsAt .." " ..data.maxLevel .."\n\n"

  for n in pairs(jsonPrices) do
    labelText = labelText .."Price: " ..jsonPrices[n].total .." " ..data.currency .." at: " ..jsonPrices[n].hour .." " ..jsonPrices[n].level .."\n"
  end
  
  self:updateView("label1", "text", labelText)
  self:logging(2,"Label1: " ..labelText)
end


function QuickApp:getValues() -- Get the values from json file 
  self:logging(3,"getValues")
  if jsonTable.data.viewer.homes[1].hourly.nodes[1].consumption ~= nil then 
    data.hEnergy = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[1].hourly.nodes[1].consumption))
  else
    data.hEnergy = 0
  end
  if jsonTable.data.viewer.homes[1].hourly.nodes[1].cost ~= nil then
    data.hCost = tonumber(string.format("%.2f",jsonTable.data.viewer.homes[1].hourly.nodes[1].cost))
  else
    data.hCost = 0
  end
  data.hTax = tonumber(string.format("%.2f",tonumber(jsonTable.data.viewer.homes[1].hourly.nodes[1].unitPriceVAT)*data.hEnergy))
  data.dEnergy = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[1].daily.nodes[1].consumption))
  data.dCost = tonumber(string.format("%.2f",jsonTable.data.viewer.homes[1].daily.nodes[1].cost or 0))
  data.dTax = tonumber(string.format("%.2f",tonumber(jsonTable.data.viewer.homes[1].daily.nodes[1].unitPriceVAT)*data.dEnergy ))
  data.yEnergy = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[1].yearly.nodes[1].consumption))
  data.yCost = tonumber(string.format("%.2f",jsonTable.data.viewer.homes[1].yearly.nodes[1].cost))
  data.yTax = tonumber(string.format("%.2f",tonumber(jsonTable.data.viewer.homes[1].yearly.nodes[1].unitPriceVAT)*data.yEnergy ))
  data.hPrice = 0
  
  data.tPrice = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.current.total))
  data.gPrice = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.current.energy))
  data.tax = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.current.tax))
  data.currency = jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.current.currency
  data.level = jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.current.level:gsub("_", " ") 
  data.startsAt = jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.current.startsAt
  
  local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).(%d+)+(%d+):(%d+)" --2021-12-23T17:00:00.000+01:00
  local runyear, runmonth, runday, runhour, runminute, runseconds = data.startsAt:match(pattern)
  local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
  data.startsAt = os.date("%d-%m-%Y %H:%M", convertedTimestamp)
  
  for hour in pairs(jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.today) do -- Insert all tadays prices to table jsonPrices
    if hour-1 >= tonumber(runhour) then
      table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = string.format("%.4f",jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.today[hour].total), level = "(" ..jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.today[hour].level:gsub("_", " ")  ..")", startsAt = jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.today[hour].startsAt})
    end
  end
  for hour in pairs(jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.tomorrow) do -- Insert all tomorrow prices to table jsonPrices
    if 24-tonumber(runhour)+hour <= 12 then 
      table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = string.format("%.4f",jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.tomorrow[hour].total), level = "(" ..jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.tomorrow[hour].level:gsub("_", " ")  ..")", startsAt = jsonTable.data.viewer.homes[1].currentSubscription.priceInfo.tomorrow[hour].startsAt})
    end
  end
  self:logging(3,"Today and Tomorrow Prices: " ..json.encode(jsonPrices))
  
  local total = 0
  data.minPrice = 999 -- Return to initial value to force new lowest price
  data.maxPrice = 0 -- Return to initial value to force new highest price
  for n in pairs(jsonPrices) do
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
      self:logging(3,"hour+1: " ..tostring(n-1) .." / runhour: " ..tostring(runhour+1) .." / tprice: " ..data.tPrice .." / total: " ..total)
      data.h1Percentage = (total-data.tPrice)/data.tPrice*100
    elseif n == 3 then
      self:logging(3,"hour+2: " ..tostring(n-1) .." / runhour: " ..tostring(runhour+2) .." / tprice: " ..data.tPrice .." / total: " ..total)
      data.h2Percentage = (total-data.tPrice)/data.tPrice*100
    elseif n == 4 then
      self:logging(3,"hour+3: " ..tostring(n-1) .." / runhour: " ..tostring(runhour+3) .." / tprice: " ..data.tPrice .." / total: " ..total)
      data.h3Percentage = (total-data.tPrice)/data.tPrice*100
    elseif n == 5 then
      self:logging(3,"hour+4: " ..tostring(n-1) .." / runhour: " ..tostring(runhour+4) .." / tprice: " ..data.tPrice .." / total: " ..total)
      data.h4Percentage = (total-data.tPrice)/data.tPrice*100
    elseif n == 6 then
      self:logging(3,"hour+5: " ..tostring(n-1) .." / runhour: " ..tostring(runhour+5) .." / tprice: " ..data.tPrice .." / total: " ..total)
      data.h5Percentage = (total-data.tPrice)/data.tPrice*100
    end
  end
end


function QuickApp:simData() -- Simulate Tibber Platform
  self:logging(3,"simData")
  apiResult = '{"data":{"viewer":{"homes":[{"hourly":{"nodes":[{"from":"2021-12-29T14:00:00.000+01:00","to":"2021-12-29T15:00:00.000+01:00","cost":3.0354753,"unitPrice":0.8844625,"unitPriceVAT":0.1768925,"consumption":3.432,"consumptionUnit":"kWh"}]},"daily":{"nodes":[{"from":"2021-12-28T00:00:00.000+01:00","to":"2021-12-29T00:00:00.000+01:00","cost":68.6274829375,"unitPrice":0.783598,"unitPriceVAT":0.15672,"consumption":87.58,"consumptionUnit":"kWh"}]},"yearly":{"nodes":[{"from":"2020-01-01T00:00:00.000+01:00","to":"2021-01-01T00:00:00.000+01:00","cost":1465.24875625,"unitPrice":0.127965,"unitPriceVAT":0.025593,"consumption":11450.413,"consumptionUnit":"kWh"}]},"currentSubscription":{"status":"running","priceInfo":{"current":{"total":1.1345,"energy":0.8996,"tax":0.2349,"currency":"NOK","level":"VERY_EXPENSIVE","startsAt":"2021-12-29T15:00:00.000+01:00"},"today":[{"total":0.7158,"energy":0.5647,"tax":0.1511,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T00:00:00.000+01:00"},{"total":1.1471,"energy":0.9097,"tax":0.2374,"currency":"NOK","level":"VERY_EXPENSIVE","startsAt":"2021-12-29T01:00:00.000+01:00"},{"total":0.9309,"energy":0.7367,"tax":0.1942,"currency":"NOK","level":"EXPENSIVE","startsAt":"2021-12-29T02:00:00.000+01:00"},{"total":0.7852,"energy":0.6201,"tax":0.1651,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T03:00:00.000+01:00"},{"total":0.7131,"energy":0.5625,"tax":0.1506,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T04:00:00.000+01:00"},{"total":0.7044,"energy":0.5555,"tax":0.1489,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T05:00:00.000+01:00"},{"total":0.6754,"energy":0.5323,"tax":0.1431,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T06:00:00.000+01:00"},{"total":0.7008,"energy":0.5527,"tax":0.1481,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T07:00:00.000+01:00"},{"total":0.7141,"energy":0.5633,"tax":0.1508,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T08:00:00.000+01:00"},{"total":0.7589,"energy":0.5991,"tax":0.1598,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T09:00:00.000+01:00"},{"total":0.784,"energy":0.6192,"tax":0.1648,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T10:00:00.000+01:00"},{"total":0.7894,"energy":0.6235,"tax":0.1659,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T11:00:00.000+01:00"},{"total":0.7878,"energy":0.6222,"tax":0.1656,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T12:00:00.000+01:00"},{"total":0.831,"energy":0.6568,"tax":0.1742,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T13:00:00.000+01:00"},{"total":0.8845,"energy":0.6996,"tax":0.1849,"currency":"NOK","level":"EXPENSIVE","startsAt":"2021-12-29T14:00:00.000+01:00"},{"total":1.1345,"energy":0.8996,"tax":0.2349,"currency":"NOK","level":"VERY_EXPENSIVE","startsAt":"2021-12-29T15:00:00.000+01:00"},{"total":1.4039,"energy":1.1152,"tax":0.2887,"currency":"NOK","level":"VERY_EXPENSIVE","startsAt":"2021-12-29T16:00:00.000+01:00"},{"total":1.0097,"energy":0.7998,"tax":0.2099,"currency":"NOK","level":"EXPENSIVE","startsAt":"2021-12-29T17:00:00.000+01:00"},{"total":0.9169,"energy":0.7256,"tax":0.1913,"currency":"NOK","level":"EXPENSIVE","startsAt":"2021-12-29T18:00:00.000+01:00"},{"total":0.9213,"energy":0.729,"tax":0.1923,"currency":"NOK","level":"EXPENSIVE","startsAt":"2021-12-29T19:00:00.000+01:00"},{"total":0.9084,"energy":0.7188,"tax":0.1896,"currency":"NOK","level":"EXPENSIVE","startsAt":"2021-12-29T20:00:00.000+01:00"},{"total":0.8912,"energy":0.705,"tax":0.1862,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T21:00:00.000+01:00"},{"total":0.8124,"energy":0.6419,"tax":0.1705,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T22:00:00.000+01:00"},{"total":0.794,"energy":0.6272,"tax":0.1668,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-29T23:00:00.000+01:00"}],"tomorrow":[{"total":0.7556,"energy":0.5965,"tax":0.1591,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T00:00:00.000+01:00"},{"total":0.6074,"energy":0.478,"tax":0.1294,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-30T01:00:00.000+01:00"},{"total":0.4234,"energy":0.3308,"tax":0.0926,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-30T02:00:00.000+01:00"},{"total":0.3319,"energy":0.2576,"tax":0.0743,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-30T03:00:00.000+01:00"},{"total":0.3575,"energy":0.278,"tax":0.0795,"currency":"NOK","level":"VERY_CHEAP","startsAt":"2021-12-30T04:00:00.000+01:00"},{"total":0.535,"energy":0.42,"tax":0.115,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-30T05:00:00.000+01:00"},{"total":0.6912,"energy":0.545,"tax":0.1462,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-30T06:00:00.000+01:00"},{"total":0.7113,"energy":0.561,"tax":0.1503,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T07:00:00.000+01:00"},{"total":0.7127,"energy":0.5621,"tax":0.1506,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T08:00:00.000+01:00"},{"total":0.7204,"energy":0.5683,"tax":0.1521,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T09:00:00.000+01:00"},{"total":0.74,"energy":0.584,"tax":0.156,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T10:00:00.000+01:00"},{"total":0.7538,"energy":0.595,"tax":0.1588,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T11:00:00.000+01:00"},{"total":0.7731,"energy":0.6105,"tax":0.1626,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T12:00:00.000+01:00"},{"total":0.8032,"energy":0.6345,"tax":0.1687,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T13:00:00.000+01:00"},{"total":0.8398,"energy":0.6638,"tax":0.176,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T14:00:00.000+01:00"},{"total":0.8537,"energy":0.675,"tax":0.1787,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T15:00:00.000+01:00"},{"total":0.8559,"energy":0.6767,"tax":0.1792,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T16:00:00.000+01:00"},{"total":0.8365,"energy":0.6612,"tax":0.1753,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T17:00:00.000+01:00"},{"total":0.806,"energy":0.6368,"tax":0.1692,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T18:00:00.000+01:00"},{"total":0.7701,"energy":0.6081,"tax":0.162,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T19:00:00.000+01:00"},{"total":0.6914,"energy":0.5452,"tax":0.1462,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-30T20:00:00.000+01:00"},{"total":0.6966,"energy":0.5493,"tax":0.1473,"currency":"NOK","level":"NORMAL","startsAt":"2021-12-30T21:00:00.000+01:00"},{"total":0.6778,"energy":0.5343,"tax":0.1435,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-30T22:00:00.000+01:00"},{"total":0.6358,"energy":0.5006,"tax":0.1352,"currency":"NOK","level":"CHEAP","startsAt":"2021-12-30T23:00:00.000+01:00"}]}}}]}}}'
 
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
  local url = "https://api.tibber.com/v1-beta/gql"
  local requestBody = '{"query": "{viewer{homes {hourly:consumption(resolution: HOURLY, last: 1) {nodes {from to cost unitPrice unitPriceVAT consumption consumptionUnit}}daily:consumption(resolution: DAILY, last: 1) {nodes {from to cost unitPrice unitPriceVAT consumption consumptionUnit}} yearly:consumption(resolution: ANNUAL, last: 1) {nodes {from to cost unitPrice unitPriceVAT consumption consumptionUnit}}currentSubscription {status priceInfo {current {total energy tax currency level startsAt} today{total energy tax currency level startsAt} tomorrow{total energy tax currency level startsAt}}}}}}"}'
  
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
        --self:logging(2,"Response data withoot null: " ..response.data)

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
  data.hTax = 0
  data.hPrice = 0
  data.dEnergy = 0 -- Daily data
  data.dCost = 0
  data.dTax = 0
  data.yEnergy = 0 -- Yearly data
  data.yCost = 0
  data.yTax = 0
  data.minPrice = 0 -- Min/Max Price
  data.minLevel = ""
  data.minStartsAt = ""
  data.maxPrice = 0
  data.maxLevel = ""
  data.maxStartsAt = ""
  data.h1Percentage = 0 -- Percentage
  data.h2Percentage = 0
  data.h3Percentage = 0
  data.h4Percentage = 0
  data.h5Percentage = 0
  data.tPrice = 0 -- Current Price
  data.gPrice = 0
  data.currency = ""
  data.level = ""
  data.tax = 0  
  data.startsAt = ""
end


function QuickApp:getQuickAppVariables() -- Get all Quickapp Variables or create them
  token = self:getVariable("token")
  extraCost = tonumber(self:getVariable("extraCost")) 
  interval = tonumber(self:getVariable("interval")) 
  httpTimeout = tonumber(self:getVariable("httpTimeout")) 
  debugLevel = tonumber(self:getVariable("debugLevel"))
  setGlobalVar = self:getVariable("setGlobalVar")

  -- Check existence of the mandatory variables, if not, create them with default values
  if token == "" or token == nil then
    token = "476c477d8a039529478ebd690d35ddd80e3308ffc49b59c65b142321aee963a4" -- This token is just an demo example, only for demo purpose
    self:setVariable("token",token)
    self:trace("Added QuickApp variable with DEMO (!) token")
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
end
  

function QuickApp:setupChildDevices() -- Setup Child Devices
  local cdevs = api.get("/devices?parentId="..self.id) or {} -- Pick up all Child Devices
  function self:initChildDevices() end -- Null function, else Fibaro calls it after onInit()...

  if #cdevs == 0 then -- If no Child Devices, create them
    local initChildData = { 
      {className="hEnergy", name="Hourly Energy", type="com.fibaro.multilevelSensor"},
      {className="hCost", name="Hourly Cost", type="com.fibaro.multilevelSensor"},
      {className="dEnergy", name="Daily Energy", type="com.fibaro.energyMeter"}, -- Device for Energy Panel
      {className="dCost", name="Daily Cost", type="com.fibaro.multilevelSensor"},
      {className="yEnergy", name="Yearly Energy", type="com.fibaro.multilevelSensor"}, 
      {className="yCost", name="Yearly Cost", type="com.fibaro.multilevelSensor"},
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
