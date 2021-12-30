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
   -- Percentage +1 hour (compaired to actual price now, positive value means an increase of the price, negative value means a decrease of the price)
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
-- If you have more than one home in your subscription, you need to fill in your home number the change between your homes. 

-- Tibber API documentation: https://developer.tibber.com/docs/guides/calling-api
-- Tibber API explorer: https://developer.tibber.com/explorer


-- ToDo:
-- Main device Current energy usage Watt (real time subscription = WebSocket?) (main device = powerSensor)
-- Create global variables for ?
-- Total energy usage not available ? 


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
-- token = Authorization token (see the Tibber website: https://thewall.tibber.com)
-- homeNr = Tibber home (nodes) number if you have more than one home (default = 1)
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
  data.hEnergy = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].hourly.nodes[1].consumption))
  data.hCost = tonumber(string.format("%.2f",jsonTable.data.viewer.homes[homeNr].hourly.nodes[1].cost))
  data.hTax = tonumber(string.format("%.2f",tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[1].unitPriceVAT)*data.hEnergy))
  data.dEnergy = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].daily.nodes[1].consumption))
  data.dCost = tonumber(string.format("%.2f",jsonTable.data.viewer.homes[homeNr].daily.nodes[1].cost or 0))
  data.dTax = tonumber(string.format("%.2f",tonumber(jsonTable.data.viewer.homes[homeNr].daily.nodes[1].unitPriceVAT)*data.dEnergy ))
  data.yEnergy = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].yearly.nodes[1].consumption))
  data.yCost = tonumber(string.format("%.2f",jsonTable.data.viewer.homes[homeNr].yearly.nodes[1].cost))
  data.yTax = tonumber(string.format("%.2f",tonumber(jsonTable.data.viewer.homes[homeNr].yearly.nodes[1].unitPriceVAT)*data.yEnergy ))
  data.tPrice = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.total))
  data.gPrice = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.energy))
  data.tax = tonumber(string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.tax))
  data.currency = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.currency
  data.level = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.level:gsub("_", " ") 
  data.startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.startsAt
  
  local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).(%d+)+(%d+):(%d+)" --2021-12-23T17:00:00.000+01:00
  local runyear, runmonth, runday, runhour, runminute, runseconds = data.startsAt:match(pattern)
  local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
  data.startsAt = os.date("%d-%m-%Y %H:%M", convertedTimestamp)
  
  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today) do -- Insert all tadays prices to table jsonPrices
    if hour-1 >= tonumber(runhour) then
      table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total), level = "(" ..jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].level:gsub("_", " ")  ..")", startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].startsAt})
    end
  end
  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow) do -- Insert all tomorrow prices to table jsonPrices
    if 24-tonumber(runhour)+hour <= 12 then 
      table.insert(jsonPrices,{hour = tostring(hour-1)..":00", total = string.format("%.4f",jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total), level = "(" ..jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].level:gsub("_", " ")  ..")", startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].startsAt})
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
  apiResult = '{"data": {"viewer": {"homes": [{"hourly": {"nodes": [{"from": "2021-12-29T21:00:00.000+01:00","to": "2021-12-29T22:00:00.000+01:00","cost": 0.333887,"unitPrice": 1.7573,"unitPriceVAT": 0.35146,"consumption": 0.19,"consumptionUnit": "kWh"}]},"daily": {"nodes": [{"from": "2021-12-28T00:00:00.000+01:00","to": "2021-12-29T00:00:00.000+01:00","cost": 65.3287032,"unitPrice": 1.83487,"unitPriceVAT": 0.366974,"consumption": 35.604,"consumptionUnit": "kWh"}]},"yearly": {"nodes": [{"from": "2020-01-01T00:00:00.000+01:00","to": "2021-01-01T00:00:00.000+01:00","cost": 44.070164325,"unitPrice": 0.242081,"unitPriceVAT": 0.048416,"consumption": 182.047,"consumptionUnit": "kWh"}]},"currentSubscription": {"status": "running","priceInfo": {"current": {"total": 1.6907,"energy": 1.3446,"tax": 0.3461,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T22:00:00.000+01:00"},"today": [{"total": 1.7628,"energy": 1.4022,"tax": 0.3606,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T00:00:00.000+01:00"},{"total": 1.7598,"energy": 1.3998,"tax": 0.36,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T01:00:00.000+01:00"},{"total": 1.7523,"energy": 1.3938,"tax": 0.3585,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T02:00:00.000+01:00"},{"total": 1.7478,"energy": 1.3902,"tax": 0.3576,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T03:00:00.000+01:00"},{"total": 1.7519,"energy": 1.3935,"tax": 0.3584,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T04:00:00.000+01:00"},{"total": 1.7665,"energy": 1.4052,"tax": 0.3613,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T05:00:00.000+01:00"},{"total": 1.8098,"energy": 1.4398,"tax": 0.37,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T06:00:00.000+01:00"},{"total": 2.2264,"energy": 1.7732,"tax": 0.4532,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T07:00:00.000+01:00"},{"total": 2.4034,"energy": 1.9147,"tax": 0.4887,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T08:00:00.000+01:00"},{"total": 2.4699,"energy": 1.9679,"tax": 0.502,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T09:00:00.000+01:00"},{"total": 2.484,"energy": 1.9792,"tax": 0.5048,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T10:00:00.000+01:00"},{"total": 2.4889,"energy": 1.9831,"tax": 0.5058,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T11:00:00.000+01:00"},{"total": 2.5037,"energy": 1.995,"tax": 0.5087,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T12:00:00.000+01:00"},{"total": 2.4989,"energy": 1.9911,"tax": 0.5078,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T13:00:00.000+01:00"},{"total": 2.4996,"energy": 1.9917,"tax": 0.5079,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T14:00:00.000+01:00"},{"total": 2.4307,"energy": 1.9365,"tax": 0.4942,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T15:00:00.000+01:00"},{"total": 2.3821,"energy": 1.8977,"tax": 0.4844,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T16:00:00.000+01:00"},{"total": 2.4245,"energy": 1.9316,"tax": 0.4929,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T17:00:00.000+01:00"},{"total": 2.2655,"energy": 1.8044,"tax": 0.4611,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T18:00:00.000+01:00"},{"total": 2.0538,"energy": 1.6351,"tax": 0.4187,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T19:00:00.000+01:00"},{"total": 1.7832,"energy": 1.4185,"tax": 0.3647,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T20:00:00.000+01:00"},{"total": 1.7573,"energy": 1.3978,"tax": 0.3595,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T21:00:00.000+01:00"},{"total": 1.6907,"energy": 1.3446,"tax": 0.3461,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T22:00:00.000+01:00"},{"total": 1.6219,"energy": 1.2895,"tax": 0.3324,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T23:00:00.000+01:00"}],"tomorrow": [{"total": 1.6528,"energy": 1.3142,"tax": 0.3386,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T00:00:00.000+01:00"},{"total": 1.5469,"energy": 1.2295,"tax": 0.3174,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T01:00:00.000+01:00"},{"total": 1.4895,"energy": 1.1836,"tax": 0.3059,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T02:00:00.000+01:00"},{"total": 1.547,"energy": 1.2296,"tax": 0.3174,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T03:00:00.000+01:00"},{"total": 1.5479,"energy": 1.2303,"tax": 0.3176,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T04:00:00.000+01:00"},{"total": 1.5051,"energy": 1.1961,"tax": 0.309,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T05:00:00.000+01:00"},{"total": 1.6264,"energy": 1.2932,"tax": 0.3332,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T06:00:00.000+01:00"},{"total": 1.6784,"energy": 1.3347,"tax": 0.3437,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T07:00:00.000+01:00"},{"total": 1.777,"energy": 1.4136,"tax": 0.3634,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T08:00:00.000+01:00"},{"total": 1.8489,"energy": 1.4711,"tax": 0.3778,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T09:00:00.000+01:00"},{"total": 1.8757,"energy": 1.4926,"tax": 0.3831,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T10:00:00.000+01:00"},{"total": 1.8812,"energy": 1.497,"tax": 0.3842,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T11:00:00.000+01:00"},{"total": 1.8616,"energy": 1.4813,"tax": 0.3803,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T12:00:00.000+01:00"},{"total": 1.8596,"energy": 1.4797,"tax": 0.3799,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T13:00:00.000+01:00"},{"total": 1.8576,"energy": 1.4781,"tax": 0.3795,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T14:00:00.000+01:00"},{"total": 1.8589,"energy": 1.4791,"tax": 0.3798,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T15:00:00.000+01:00"},{"total": 1.8548,"energy": 1.4758,"tax": 0.379,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T16:00:00.000+01:00"},{"total": 1.8922,"energy": 1.5058,"tax": 0.3864,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T17:00:00.000+01:00"},{"total": 1.8846,"energy": 1.4997,"tax": 0.3849,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T18:00:00.000+01:00"},{"total": 1.8539,"energy": 1.4751,"tax": 0.3788,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T19:00:00.000+01:00"},{"total": 1.8325,"energy": 1.458,"tax": 0.3745,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T20:00:00.000+01:00"},{"total": 1.7967,"energy": 1.4294,"tax": 0.3673,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T21:00:00.000+01:00"},{"total": 1.7314,"energy": 1.3771,"tax": 0.3543,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T22:00:00.000+01:00"},{"total": 1.7181,"energy": 1.3664,"tax": 0.3517,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T23:00:00.000+01:00"}]}}},{"hourly": {"nodes": [{"from": "2021-12-29T21:00:00.000+01:00","to": "2021-12-29T22:00:00.000+01:00","cost": 13.35548,"unitPrice": 1.7573,"unitPriceVAT": 0.35146,"consumption": 7.6,"consumptionUnit": "kWh"}]},"daily": {"nodes": [{"from": "2021-12-28T00:00:00.000+01:00","to": "2021-12-29T00:00:00.000+01:00","cost": 248.76987325,"unitPrice": 1.85262,"unitPriceVAT": 0.370524,"consumption": 134.28,"consumptionUnit": "kWh"}]},"yearly": {"nodes": [{"from": "2020-01-01T00:00:00.000+01:00","to": "2021-01-01T00:00:00.000+01:00","cost": 240.545030375,"unitPrice": 0.271799,"unitPriceVAT": 0.05436,"consumption": 885.01,"consumptionUnit": "kWh"}]},"currentSubscription": {"status": "running","priceInfo": {"current": {"total": 1.6907,"energy": 1.3446,"tax": 0.3461,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T22:00:00.000+01:00"},"today": [{"total": 1.7628,"energy": 1.4022,"tax": 0.3606,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T00:00:00.000+01:00"},{"total": 1.7598,"energy": 1.3998,"tax": 0.36,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T01:00:00.000+01:00"},{"total": 1.7523,"energy": 1.3938,"tax": 0.3585,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T02:00:00.000+01:00"},{"total": 1.7478,"energy": 1.3902,"tax": 0.3576,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T03:00:00.000+01:00"},{"total": 1.7519,"energy": 1.3935,"tax": 0.3584,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T04:00:00.000+01:00"},{"total": 1.7665,"energy": 1.4052,"tax": 0.3613,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T05:00:00.000+01:00"},{"total": 1.8098,"energy": 1.4398,"tax": 0.37,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T06:00:00.000+01:00"},{"total": 2.2264,"energy": 1.7732,"tax": 0.4532,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T07:00:00.000+01:00"},{"total": 2.4034,"energy": 1.9147,"tax": 0.4887,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T08:00:00.000+01:00"},{"total": 2.4699,"energy": 1.9679,"tax": 0.502,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T09:00:00.000+01:00"},{"total": 2.484,"energy": 1.9792,"tax": 0.5048,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T10:00:00.000+01:00"},{"total": 2.4889,"energy": 1.9831,"tax": 0.5058,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T11:00:00.000+01:00"},{"total": 2.5037,"energy": 1.995,"tax": 0.5087,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T12:00:00.000+01:00"},{"total": 2.4989,"energy": 1.9911,"tax": 0.5078,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T13:00:00.000+01:00"},{"total": 2.4996,"energy": 1.9917,"tax": 0.5079,"currency": "NOK","level": "EXPENSIVE","startsAt": "2021-12-29T14:00:00.000+01:00"},{"total": 2.4307,"energy": 1.9365,"tax": 0.4942,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T15:00:00.000+01:00"},{"total": 2.3821,"energy": 1.8977,"tax": 0.4844,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T16:00:00.000+01:00"},{"total": 2.4245,"energy": 1.9316,"tax": 0.4929,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T17:00:00.000+01:00"},{"total": 2.2655,"energy": 1.8044,"tax": 0.4611,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T18:00:00.000+01:00"},{"total": 2.0538,"energy": 1.6351,"tax": 0.4187,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-29T19:00:00.000+01:00"},{"total": 1.7832,"energy": 1.4185,"tax": 0.3647,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T20:00:00.000+01:00"},{"total": 1.7573,"energy": 1.3978,"tax": 0.3595,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T21:00:00.000+01:00"},{"total": 1.6907,"energy": 1.3446,"tax": 0.3461,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T22:00:00.000+01:00"},{"total": 1.6219,"energy": 1.2895,"tax": 0.3324,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-29T23:00:00.000+01:00"}],"tomorrow": [{"total": 1.6528,"energy": 1.3142,"tax": 0.3386,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T00:00:00.000+01:00"},{"total": 1.5469,"energy": 1.2295,"tax": 0.3174,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T01:00:00.000+01:00"},{"total": 1.4895,"energy": 1.1836,"tax": 0.3059,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T02:00:00.000+01:00"},{"total": 1.547,"energy": 1.2296,"tax": 0.3174,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T03:00:00.000+01:00"},{"total": 1.5479,"energy": 1.2303,"tax": 0.3176,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T04:00:00.000+01:00"},{"total": 1.5051,"energy": 1.1961,"tax": 0.309,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T05:00:00.000+01:00"},{"total": 1.6264,"energy": 1.2932,"tax": 0.3332,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T06:00:00.000+01:00"},{"total": 1.6784,"energy": 1.3347,"tax": 0.3437,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T07:00:00.000+01:00"},{"total": 1.777,"energy": 1.4136,"tax": 0.3634,"currency": "NOK","level": "CHEAP","startsAt": "2021-12-30T08:00:00.000+01:00"},{"total": 1.8489,"energy": 1.4711,"tax": 0.3778,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T09:00:00.000+01:00"},{"total": 1.8757,"energy": 1.4926,"tax": 0.3831,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T10:00:00.000+01:00"},{"total": 1.8812,"energy": 1.497,"tax": 0.3842,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T11:00:00.000+01:00"},{"total": 1.8616,"energy": 1.4813,"tax": 0.3803,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T12:00:00.000+01:00"},{"total": 1.8596,"energy": 1.4797,"tax": 0.3799,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T13:00:00.000+01:00"},{"total": 1.8576,"energy": 1.4781,"tax": 0.3795,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T14:00:00.000+01:00"},{"total": 1.8589,"energy": 1.4791,"tax": 0.3798,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T15:00:00.000+01:00"},{"total": 1.8548,"energy": 1.4758,"tax": 0.379,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T16:00:00.000+01:00"},{"total": 1.8922,"energy": 1.5058,"tax": 0.3864,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T17:00:00.000+01:00"},{"total": 1.8846,"energy": 1.4997,"tax": 0.3849,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T18:00:00.000+01:00"},{"total": 1.8539,"energy": 1.4751,"tax": 0.3788,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T19:00:00.000+01:00"},{"total": 1.8325,"energy": 1.458,"tax": 0.3745,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T20:00:00.000+01:00"},{"total": 1.7967,"energy": 1.4294,"tax": 0.3673,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T21:00:00.000+01:00"},{"total": 1.7314,"energy": 1.3771,"tax": 0.3543,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T22:00:00.000+01:00"},{"total": 1.7181,"energy": 1.3664,"tax": 0.3517,"currency": "NOK","level": "NORMAL","startsAt": "2021-12-30T23:00:00.000+01:00"}]}}}]}}}'
 
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
