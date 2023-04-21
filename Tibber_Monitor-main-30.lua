-- Quickapp Tibber Monitor main

local function getChildVariable(child,varName)
  for _,v in ipairs(child.properties.quickAppVariables or {}) do
    if v.name==varName then return v.value end
  end
  return ""
end


local function setColor(level) -- Set the color 🟢🟡🟠🔴🟣 based on the Tibber Price Level with setColor(pricelevel) 
  if level == "VERY CHEAP" then
    return "🟢"
  elseif level == "CHEAP" then
    return "🟡"
  elseif level == "NORMAL" then 
    return "🟠"
  elseif level == "EXPENSIVE" then 
    return "🔴"
  else -- VERY EXPENSIVE and all others
    return "🟣"
  end
end


function QuickApp:logging(level,text) -- Logging function for debug
  if tonumber(debugLevel) >= tonumber(level) then 
      self:debug(text)
  end
end


function QuickApp:setGlobalVariable(tag,res) -- Fill the Global Variables
  if api.get("/globalVariables/"..tag) == nil then
    local responseData, status = api.post("/globalVariables/",{value=(json.encode(res)),name=tag})
    self:trace("Global Variable created: " ..tag .." / status: " ..status) 
  else
    local responseData, status = api.put("/globalVariables/"..tag,{value=(json.encode(res))})
  end
end


function QuickApp:deleteGlobalVariable(tag) -- Delete the Global Variables
  if api.get("/globalVariables/"..tag) then
    local responseData, status = api.delete("/globalVariables/"..tag) 
    self:trace("Global Variable deleted: " ..tag .." / status: " ..status)
  end
end


function QuickApp:updateChildDevices() -- Update Child Devices
  for id,child in pairs(self.childDevices) do 
    child:updateValue(data) 
  end
  self:logging(2,"getValues() - Return to getValues())")
end


function QuickApp:updateEnergyPanel() -- Update the Energy Panel price
  if setEnergyPanel then -- Insert prices in Energy Panel only if turned on
    self:logging(3,"updateEnergyPanel() - Update the Energy Panel price")
    local price = 0
    if currentPrice then 
      price = tonumber(data.totalPrice) -- Use current Price for Energy Panel
    else
      price = tonumber(self:getVariable("workaroundPnn")) -- Use previous hour Price for Energy Panel
    end
    self:logging(3,"updateEnergyPanel")
    local billingTariff = api.get("/energy/billing/tariff") -- Get the current Tariff from the Energy Panel
    billingTariff.rate = price -- Replace billingTariff.rate with current (previous hour) kWh price
    local responseData, status = api.put("/energy/billing/tariff", billingTariff) -- Write the new Tariff in the Energy Panel
  end
  self:updateChildDevices() 
end


function QuickApp:updateProperties() -- Update the properties
  self:logging(3,"updateProperties() - Update the properties")
  --self:updateProperty("value", 0) -- For future use
  --self:updateProperty("unit", "") -- For future use
  self:updateProperty("log", data.startsAt)
  --self:logging(2,"getValues() - Return to getValues() and wait for the interval of " ..interval  .." seconds")
  self:updateEnergyPanel()
end


function QuickApp:updateLabels() -- Update the labels
  self:logging(3,"updateLabels() - Update the labels")

  local labelText = ""
  if debugLevel == 4 then
    labelText = labelText ..translation["SIMULATION MODE"] .."\n\n"
  end
  
  labelText = labelText ..translation["Hourly Energy"] ..":" .."\n"
  for n in pairs(jsonEnergy or {}) do
    labelText = labelText ..jsonEnergy[n].hour .." " ..string.format("%.2f",jsonEnergy[n].consumption) .." " ..jsonEnergy[n].unit .." " ..string.format("%.4f",jsonEnergy[n].cost) .." " ..data.currency .."\n"
  end
  labelText = labelText .."\n"
  
  labelText = labelText ..translation["Daily Energy"] ..": " ..string.format("%.2f",data.dEnergy) .." " .."kWh" .." " ..string.format("%.2f",data.dCost+(extraCost*data.dEnergy)) .." " ..data.currency .."\n"
  labelText = labelText ..translation["Monthly Energy"] ..": " ..string.format("%.2f",data.mEnergy) .." " .."kWh" .." " ..string.format("%.2f",data.mCost+(extraCost*data.mEnergy)) .." " ..data.currency .."\n"
  labelText = labelText ..translation["Yearly Energy"] ..": " ..string.format("%.2f",data.yEnergy) .." " .."kWh" .." " ..string.format("%.2f",data.yCost+(extraCost*data.yEnergy))  .." " ..data.currency .."\n"
  labelText = labelText ..translation["Total Energy"] ..": " ..string.format("%.2f",data.tEnergy) .." " .."kWh" .." " ..string.format("%.2f",data.tCost+(extraCost*data.tEnergy))  .." " ..data.currency .."\n\n"

  labelText = labelText ..translation["Actual Price"] ..": " ..string.format("%.4f",data.totalPrice) .." " ..data.currency .." (" ..translation[data.level] ..")" .."\n"
  labelText = labelText ..translation["Nord Pool Spot price"] ..": " ..string.format("%.4f",data.spotPrice) .." " ..data.currency .."\n" 
  labelText = labelText ..translation["Tax"] ..": " ..string.format("%.2f",data.tax) .." " ..data.currency .."\n" 
  labelText = labelText ..translation["Extra cost"] ..": " ..string.format("%.2f",extraCost) .." " ..data.currency .."\n"
  labelText = labelText ..translation["Last update"] ..": " ..data.startsAt .."\n\n"

  labelText = labelText  ..translation["TODAY Prices"] ..":" .."\n"
  labelText = labelText ..(data.minStartsAtTod or "") .." " ..translation["Min"] ..": " ..string.format("%.4f",(data.minPriceTod or 0)) .." " ..data.currency .." (" ..(data.minPercentageTod or 0) .."% " ..(translation[data.minLevelTod] or "") ..")" .."\n"
  labelText = labelText ..(data.maxStartsAtTod or "") .." " ..translation["Max"] ..": " ..string.format("%.4f",(data.maxPriceTod or 0)) .." " ..data.currency .." (" ..(data.maxPercentageTod or 0) .."% " ..(translation[data.maxLevelTod] or "") ..")" .."\n"
  labelText = labelText ..translation["Average"] ..": " ..string.format("%.4f",(data.avgPriceTod or 0)) .." " ..data.currency .."\n\n"

  for n in pairs(jsonPricesTod or {}) do
    labelText = labelText ..setColor(jsonPricesTod[n].level) ..jsonPricesTod[n].hour .." " ..string.format("%.4f",jsonPricesTod[n].total) .." " ..data.currency .." (" ..jsonPricesTod[n].percentage .."% " ..translation[jsonPricesTod[n].level] ..")" .."\n"
  end
  
  labelText = labelText  .."\n" ..translation["TOMORROW Prices"]  ..":" .."\n"
  if jsonPricesTom[1] then -- Check if the Tomorrow prices are available
  labelText = labelText ..(data.minStartsAtTom or "") .." " ..translation["Min"] ..": " ..string.format("%.4f",(data.minPriceTom or 0)) .." " ..data.currency .." (" ..(data.minPercentageTom or 0) .."% " ..(translation[data.minLevelTom] or "") ..")" .."\n"
  labelText = labelText ..(data.maxStartsAtTom or "") .." " ..translation["Max"] ..": " ..string.format("%.4f",(data.maxPriceTom or 0)) .." " ..data.currency .." (" ..(data.maxPercentageTom or 0) .."% " ..(translation[data.maxLevelTom] or "") ..")" .."\n"
  labelText = labelText ..translation["Average"] ..": " ..string.format("%.4f",(data.avgPriceTom or 0)) .." " ..data.currency .."\n\n"

    for n in pairs(jsonPricesTom or {}) do
      labelText = labelText ..setColor(jsonPricesTom[n].level) ..jsonPricesTom[n].hour .." " ..string.format("%.4f",jsonPricesTom[n].total) .." " ..data.currency .." (" ..jsonPricesTom[n].percentage .."% " ..translation[jsonPricesTom[n].level] ..")" .."\n"
    end
  else
    labelText = labelText ..translation["Not yet available"] 
  end
  labelText = labelText .."\n"

  self:updateView("label", "text", labelText)
  self:logging(2,"Label: " ..labelText)
  self:updateProperties()
end


function QuickApp:calculatePrices(jsonTable) -- Calculate the prices
  self:logging(3,"calculatePrices() - Calculate the prices")
  
  local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).(%d+)+(%d+):(%d+)" --2021-12-23T17:00:00.000+01:00
  local runyear, runmonth, runday, runhour, runminute, runseconds = data.startsAt:match(pattern)
  local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
  data.startsAt = os.date("%d-%m-%Y %H:%M", convertedTimestamp)
  
  -- TODAY Price calculations 
  
  data.avgPriceTod = 0 
  local hAmountTod = 0
  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today or {}) do -- Get the average price TODAY
    data.avgPriceTod = data.avgPriceTod + jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total
    hAmountTod = hAmountTod+1
    self:logging(3, "hour: " ..hour .." Today price: " ..jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total .." data.avgPriceTod: " ..data.avgPriceTod .." hAmountTod: " ..hAmountTod)
  end
  data.avgPriceTod = tonumber(data.avgPriceTod) / hAmountTod -- Calculate the Today average price 
  self:logging(3,"data.avgPriceTod: " ..data.avgPriceTod .." for: " ..hAmountTod .." prices")

  if jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today then 
    for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today or {}) do -- Insert all TODAYS prices to table jsonPricesTod
      table.insert(jsonPricesTod,{hour = string.format("%02d",hour-1)..":00", total = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total, percentage = string.format("%.2f",((jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].total-data.avgPriceTod)/data.avgPriceTod)*100), level = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].level:gsub("_", " "), startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[hour].startsAt})
    end
  else --If Today prices are not there, set them all to zero
    jsonPricesTod = '[{"total":0,"level":" ","startsAt":"","percentage":"N/A","hour":"00:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"01:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"02:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"03:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"04:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"05:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"06:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"07:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"08:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"09:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"10:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"11:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"12:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"13:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"14:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"15:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"16:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"17:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"18:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"19:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"20:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"21:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"22:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"23:00"}]'
  end
  self:logging(3,"Today Prices: " ..json.encode(jsonPricesTod))

  for i=1,24 do -- Initialise the Global Variables for TODAY price levels
    if GlobVarLevel then 
      self:setGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_today_level_h" ..string.format("%02d",i-1), "") -- Set global variables for Level
    else
      self:deleteGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_today_level_h" ..string.format("%02d",i-1), "") -- Delete global variables for Level
    end
    if GlobVarPerc then 
      self:setGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_today_percentage_h" ..string.format("%02d",i-1), "") -- Set global variables for Percentage
    else
      self:deleteGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_today_percentage_h" ..string.format("%02d",i-1), "") -- Delete global variables for Percentage
    end
  end
  local n = 1
  for n in pairs(jsonPricesTod or {}) do -- Get the levels for Global Variables 
    if n > 24 then -- Maximum 24 Global variables, just in case
      break
    end
    if GlobVarLevel then 
      self:logging(3, "Globalvar: tibber_monitor_" ..plugin.mainDeviceId .."_today_level_h" ..string.format("%02d",n-1) .." " ..jsonPricesTod[n].level)
      self:setGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_today_level_h" ..string.format("%02d",n-1), jsonPricesTod[n].level) -- Set global variables for Level
    else
      self:deleteGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_today_level_h" ..string.format("%02d",n-1), jsonPricesTod[n].level) -- Delete global variables for Level
    end
    if GlobVarPerc then 
      self:logging(3, "Globalvar: tibber_monitor_" ..plugin.mainDeviceId .."_today_percentage_h" ..string.format("%02d",n-1) .." " ..jsonPricesTod[n].percentage)
      self:setGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_today_percentage_h" ..string.format("%02d",n-1), jsonPricesTod[n].percentage) -- Set global variables for Percentage
    else
      self:deleteGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_today_percentage_h" ..string.format("%02d",n-1), jsonPricesTod[n].percentage) -- Delete global variables for Percentage
    end
  end

  data.minPriceTod = 999 -- Return to initial value to force new lowest Today price
  data.maxPriceTod = 0 -- Return to initial value to force new highest Today price
  for n in pairs(jsonPricesTod or {}) do -- Get the minimum and maximum Today price, percentage, level and hour
    if tonumber(jsonPricesTod[n].total) <= data.minPriceTod then
      data.minPriceTod =      tonumber(jsonPricesTod[n].total)
      data.minPercentageTod = jsonPricesTod[n].percentage
      data.minLevelTod =      jsonPricesTod[n].level
      data.minStartsAtTod =   jsonPricesTod[n].hour
    end
    if tonumber(jsonPricesTod[n].total) >= data.maxPriceTod then
      data.maxPriceTod =      tonumber(jsonPricesTod[n].total)
      data.maxPercentageTod = jsonPricesTod[n].percentage
      data.maxLevelTod =      jsonPricesTod[n].level 
      data.maxStartsAtTod =   jsonPricesTod[n].hour
    end  
  end
  
  -- TOMORROW Price calculations 
  
  data.avgPriceTom = 0 
  local hAmountTom = 0
  for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow or {}) do -- Get the average price TOMORROW
    data.avgPriceTom = data.avgPriceTom + jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total
    hAmountTom = hAmountTom+1
    self:logging(3, "hour: " ..hour .." Tomorrow price: " ..jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total .." data.avgPriceTom: " ..data.avgPriceTom .." hAmountTom: " ..hAmountTom)
  end
  data.avgPriceTom = tonumber(data.avgPriceTom) / hAmountTom -- Calculate the Today average price 
  self:logging(3,"data.avgPriceTom: " ..data.avgPriceTom .." for: " ..hAmountTom .." prices")
  if jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow then
    for hour in pairs(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow or {}) do -- Insert all TOMORROW prices to table jsonPricesTom
      table.insert(jsonPricesTom,{hour = string.format("%02d",hour-1)..":00", total = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total, percentage = string.format("%.2f",((jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].total-data.avgPriceTom)/data.avgPriceTom)*100), level = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].level:gsub("_", " "), startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.tomorrow[hour].startsAt})
    end
  else -- If Tomorrow prices are not there, set them all to zero
    jsonPricesTom = '[{"total":0,"level":" ","startsAt":"","percentage":"N/A","hour":"00:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"01:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"02:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"03:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"04:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"05:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"06:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"07:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"08:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"09:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"10:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"11:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"12:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"13:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"14:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"15:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"16:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"17:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"18:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"19:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"20:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"21:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"22:00"},{"total":0,"level":" ","startsAt":" ","percentage":"N/A","hour":"23:00"}]'
  end
  self:logging(3,"Tomorrow Prices: " ..json.encode(jsonPricesTom))
  
  for i=1,24 do -- Initialise the Global Variables for TOMORROW price levels
    if GlobVarLevel then 
      self:setGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_level_h" ..string.format("%02d",i-1), "") -- Set global variables for Level
    else
      self:deleteGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_level_h" ..string.format("%02d",i-1), "") -- Delete global variables for Level
    end
    if GlobVarPerc then 
      self:setGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_percentage_h" ..string.format("%02d",i-1), "") -- Set global variables for Percentage
    else
      self:deleteGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_percentage_h" ..string.format("%02d",i-1), "") -- Delete global variables for Percentage
    end
  end
  n = 1
  for n in pairs(jsonPricesTom or {}) do -- Get the levels for Global Variables 
    if n > 24 then -- Maximum 24 Global variables, just in case
      break
    end
    if GlobVarLevel then 
      self:logging(3, "Globalvar: tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_level_h" ..string.format("%02d",n-1) .." " ..jsonPricesTom[n].level)
      self:setGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_level_h" ..string.format("%02d",n-1), jsonPricesTom[n].level) -- Set global variables for Level
    else
      self:deleteGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_level_h" ..string.format("%02d",n-1), jsonPricesTom[n].level) -- Delete global variables for Level
    end
    if GlobVarPerc then 
      self:logging(3, "Globalvar: tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_percentage_h" ..string.format("%02d",n-1) .." " ..jsonPricesTom[n].percentage)
      self:setGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_percentage_h" ..string.format("%02d",n-1), jsonPricesTom[n].percentage) -- Set global variables for Percentage
    else
      self:deleteGlobalVariable("tibber_monitor_" ..plugin.mainDeviceId .."_tomorrow_percentage_h" ..string.format("%02d",n-1), jsonPricesTom[n].percentage) -- Delete global variables for Percentage
    end
  end
  
  data.minPriceTom = 999 -- Return to initial value to force new lowest Tomorrow price
  data.maxPriceTom = 0 -- Return to initial value to force new highest Tomorrow price
  for n in pairs(jsonPricesTom or {}) do -- Get the minimum and maximum Tomorrow price, percentage, level and hour
    if tonumber(jsonPricesTom[n].total) <= data.minPriceTom then
      data.minPriceTom =      tonumber(jsonPricesTom[n].total)
      data.minPercentageTom = jsonPricesTom[n].percentage
      data.minLevelTom =      jsonPricesTom[n].level
      data.minStartsAtTom =   jsonPricesTom[n].hour
    end
    if tonumber(jsonPricesTom[n].total) >= data.maxPriceTom then
      data.maxPriceTom =      tonumber(jsonPricesTom[n].total)
      data.maxPercentageTom = jsonPricesTom[n].percentage
      data.maxLevelTom =      jsonPricesTom[n].level 
      data.maxStartsAtTom =   jsonPricesTom[n].hour
    end  
  end
  
  if os.date("%H") == "00" then -- Workaround for previous hour price for Energy Panel
    self:setVariable("workaroundPnn",tonumber(self:getVariable("workaroundP23"))) -- Save the 23h price
  else
    self:setVariable("workaroundP23",tonumber(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[23].total)) -- Save the 23h price
    self:setVariable("workaroundPnn",tonumber(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.today[tonumber(os.date("%H"))].total)) -- Save the hour-1 price
  end
  
  self:logging(3,"data: " ..json.encode(data))
  self:updateLabels()
end


function QuickApp:getValuesTotal(jsonTable) -- Get Total values from json file 
  self:logging(3,"getValuesTotal() - Get Total values from json file")
  data.tEnergy = 0
  data.tCost = 0
  for year in pairs(jsonTable.data.viewer.homes[homeNr].yearly.nodes or {}) do -- Sum all years energy
    self:logging(3,"year: " ..tostring(year) .." Consumption: " ..jsonTable.data.viewer.homes[homeNr].yearly.nodes[year].consumption .." Cost: " ..jsonTable.data.viewer.homes[homeNr].yearly.nodes[year].cost)
    data.tEnergy = data.tEnergy + tonumber(jsonTable.data.viewer.homes[homeNr].yearly.nodes[year].consumption)
    data.tCost = data.tCost + tonumber(jsonTable.data.viewer.homes[homeNr].yearly.nodes[year].cost)
  end
  data.tEnergy = tonumber(data.tEnergy + data.yEnergy) -- Add last year values
  data.tCost = tonumber(data.tCost + data.yCost)
  self:logging(3,"data.tEnergy: " ..tostring(data.tEnergy) .." data.tCost: " ..tostring(data.tCost))
  self:calculatePrices(jsonTable)
end


function QuickApp:getValuesYearly(jsonTable) -- Get Yearly values from json file 
  self:logging(3,"getValuesYearly() - Get Yearly values from json file")
  data.yEnergy = 0
  data.yCost = 0
  for month in pairs(jsonTable.data.viewer.homes[homeNr].monthly.nodes or {}) do -- Sum all months energy of the year
    self:logging(3,"month: " ..tostring(month) .." Consumption: " ..jsonTable.data.viewer.homes[homeNr].monthly.nodes[month].consumption .." Cost: " ..jsonTable.data.viewer.homes[homeNr].monthly.nodes[month].cost)
    data.yEnergy = data.yEnergy + tonumber(jsonTable.data.viewer.homes[homeNr].monthly.nodes[month].consumption)
    data.yCost = data.yCost + tonumber(jsonTable.data.viewer.homes[homeNr].monthly.nodes[month].cost)
  end
  data.yEnergy = tonumber(data.yEnergy + data.mEnergy) -- Add last month values
  data.yCost = tonumber(data.yCost + data.mCost)
  self:logging(3,"data.yEnergy: " ..tostring(data.yEnergy) .." data.yCost: " ..tostring(data.yCost))
  self:getValuesTotal(jsonTable)
end


function QuickApp:getValuesMonthly(jsonTable) -- Get Monthly values from json file 
  self:logging(3,"getValuesMonthly() - Get Monthly values from json file")
  data.mEnergy = 0
  data.mCost = 0
  for day in pairs(jsonTable.data.viewer.homes[homeNr].daily.nodes or {}) do -- Sum all days energy of the month
    self:logging(3,"day: " ..tostring(day) .." Consumption: " ..jsonTable.data.viewer.homes[homeNr].daily.nodes[day].consumption .." Cost: " ..jsonTable.data.viewer.homes[homeNr].daily.nodes[day].cost)
    data.mEnergy = data.mEnergy + tonumber(jsonTable.data.viewer.homes[homeNr].daily.nodes[day].consumption)
    data.mCost = data.mCost + tonumber(jsonTable.data.viewer.homes[homeNr].daily.nodes[day].cost)
  end
  data.mEnergy = tonumber(data.mEnergy + data.dEnergy) -- Add last days values
  data.mCost = tonumber(data.mCost + data.dCost)
  self:logging(3,"data.mEnergy: " ..tostring(data.mEnergy) .." data.mCost: " ..tostring(data.mCost))
  self:getValuesYearly(jsonTable)
end


function QuickApp:getValuesDaily(jsonTable) -- Get Daily values from json file 
  self:logging(3,"getValuesDaily() - Get Daily values from json file")
  data.dEnergy = 0
  data.dCost = 0
  data.hEnergy = 0
  data.hCost = 0
  local loopCheck = 0
  for hour in pairs(jsonTable.data.viewer.homes[homeNr].hourly.nodes or {}) do  -- Sum all hours energy of the day and insert energy in jsonEnergy
    
    table.insert(jsonEnergy, {hour = string.format("%02d",hour-1)..":00", consumption = jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption, cost = jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost, unit = jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumptionUnit}) -- Insert hourly energy usage into jsonEnergy
    
    loopCheck = 1 -- Set loopCheck to 1 to know the loop worked (probably not between 00:00 and 01:00 because of an empty jsonTable.data.viewer.homes[homeNr].hourly.nodes)
    if hour == 1 then -- Workaround check for null value 00-01 hour consumption
      if jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption == 0 then
        self:logging(3, "hour: " ..hour .." Consumption (==0): " ..self:getVariable("workaroundE01") .." Cost: " ..self:getVariable("workaroundC01"))
        data.dEnergy = tonumber(self:getVariable("workaroundE01")) -- Use workaround value 00-01 hour energy
        data.dCost = tonumber(self:getVariable("workaroundC01")) -- Use workaround value 00-01 hour cost
        self:logging(2,"Got null value from Tibber API for 00-01 hour energy and cost, using stored values instead")
      else -- No null value 00-01 hour, use the value from the Tibber API and set workaround value 00-01 hour consumption
        self:logging(3, "hour: " ..hour .." Consumption (<>0): " ..jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption .." Cost: " ..jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost)
        data.dEnergy = tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption) 
        data.dCost = tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost)
        self:setVariable("workaroundE01",jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption) 
        self:setVariable("workaroundC01",jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost) 
      end
    else -- Not 00-01 hour, no workaround checks necessary 
      self:logging(3, "hour: " ..hour .." Consumption (not 00-01 hour): " ..tostring(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption) .." Cost: " ..jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost)
      data.dEnergy = data.dEnergy + tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption)
      data.dCost = data.dCost + tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost)
    end
    if hour == 1 then 
      data.hEnergy = tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].consumption) or 0 -- If first hour new day, current consumption will be zero
      data.hCost = tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour].cost) or 0 -- If first hour new day, current cost will be zero
    else 
      data.hEnergy = tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour-1].consumption) or 0 -- Previous hour consumption because running hour will be zero
      data.hCost = tonumber(jsonTable.data.viewer.homes[homeNr].hourly.nodes[hour-1].cost) or 0 -- Previous hour cost because running hour will be zero
    end
  end
  if loopCheck == 0 then -- It is just after midnight, there was no loop, workaroundE01 and workaroundC01 needs to be reset to zero
    self:setVariable("workaroundE01","0")
    self:setVariable("workaroundC01","0")
  end
  
  self:logging(3,"jsonEnergy: " ..json.encode(jsonEnergy))

  self:logging(2, "workaroundE01: " ..self:getVariable("workaroundE01") .." workaroundC01: " ..self:getVariable("workaroundC01") .." data.hEnergy: " ..tostring(data.hEnergy) .." data.hCost: " ..tostring(data.hCost) .." data.dEnergy: " ..tostring(data.dEnergy) .." data.dCost: " ..tostring(data.dCost))
  self:getValuesMonthly(jsonTable)
end


function QuickApp:getValues(jsonTable) -- Get the values from json file 
  self:logging(3,"getValues() - Get the values from json file ")
  
  jsonPricesTod = {}
  jsonPricesTom = {}
  jsonEnergy = {}
  
  data.totalPrice = tonumber(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.total or 0) -- The total price (energy + taxes)
  data.spotPrice = tonumber(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.energy or 0) -- Nord Pool spot price
  data.tax = tonumber(jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.tax or 0) -- The tax part of the price (guarantee of origin certificate, energy tax (Sweden only) and VAT)
  data.startsAt = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.startsAt or "" -- The start time of the price
  data.currency = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.currency or "" -- The price currency
  data.level = jsonTable.data.viewer.homes[homeNr].currentSubscription.priceInfo.current.level:gsub("_", " ") -- The price level compared to recent price values
  self:getValuesDaily(jsonTable)
end


function QuickApp:simData() -- Simulate Tibber Platform
  self:logging(3,"simData() - Simulate Tibber Platform")
  data = os.date("*t")
  local apiResult = '{"data":{"viewer":{"homes":[{"hourly":{"nodes":[{"from":"2023-04-10T00:00:00.000+02:00","to":"2023-04-10T01:00:00.000+02:00","cost":2.1127347,"unitPrice":0.6543,"unitPriceVAT":0.13086,"consumption":3.229,"consumptionUnit":"kWh"},{"from":"2023-04-10T01:00:00.000+02:00","to":"2023-04-10T02:00:00.000+02:00","cost":1.5796228125,"unitPrice":0.6460625,"unitPriceVAT":0.1292125,"consumption":2.445,"consumptionUnit":"kWh"},{"from":"2023-04-10T02:00:00.000+02:00","to":"2023-04-10T03:00:00.000+02:00","cost":1.54106435,"unitPrice":0.664825,"unitPriceVAT":0.132965,"consumption":2.318,"consumptionUnit":"kWh"},{"from":"2023-04-10T03:00:00.000+02:00","to":"2023-04-10T04:00:00.000+02:00","cost":2.003935725,"unitPrice":0.685575,"unitPriceVAT":0.137115,"consumption":2.923,"consumptionUnit":"kWh"},{"from":"2023-04-10T04:00:00.000+02:00","to":"2023-04-10T05:00:00.000+02:00","cost":1.332887025,"unitPrice":0.7097375,"unitPriceVAT":0.1419475,"consumption":1.878,"consumptionUnit":"kWh"},{"from":"2023-04-10T05:00:00.000+02:00","to":"2023-04-10T06:00:00.000+02:00","cost":1.4337473,"unitPrice":0.7663,"unitPriceVAT":0.15326,"consumption":1.871,"consumptionUnit":"kWh"},{"from":"2023-04-10T06:00:00.000+02:00","to":"2023-04-10T07:00:00.000+02:00","cost":0.9455179875,"unitPrice":0.8102125,"unitPriceVAT":0.1620425,"consumption":1.167,"consumptionUnit":"kWh"},{"from":"2023-04-10T07:00:00.000+02:00","to":"2023-04-10T08:00:00.000+02:00","cost":0.02978315,"unitPrice":0.80495,"unitPriceVAT":0.16099,"consumption":0.037,"consumptionUnit":"kWh"},{"from":"2023-04-10T08:00:00.000+02:00","to":"2023-04-10T09:00:00.000+02:00","cost":0,"unitPrice":0.8267,"unitPriceVAT":0.16534,"consumption":0,"consumptionUnit":"kWh"},{"from":"2023-04-10T09:00:00.000+02:00","to":"2023-04-10T10:00:00.000+02:00","cost":0,"unitPrice":0.80155,"unitPriceVAT":0.16031,"consumption":0,"consumptionUnit":"kWh"},{"from":"2023-04-10T10:00:00.000+02:00","to":"2023-04-10T11:00:00.000+02:00","cost":0,"unitPrice":0.5076375,"unitPriceVAT":0.1015275,"consumption":0,"consumptionUnit":"kWh"},{"from":"2023-04-10T11:00:00.000+02:00","to":"2023-04-10T12:00:00.000+02:00","cost":0,"unitPrice":0.30965,"unitPriceVAT":0.06193,"consumption":0,"consumptionUnit":"kWh"},{"from":"2023-04-10T12:00:00.000+02:00","to":"2023-04-10T13:00:00.000+02:00","cost":0,"unitPrice":0.30525,"unitPriceVAT":0.06105,"consumption":0,"consumptionUnit":"kWh"}]},"daily":{"nodes":[{"from":"2023-04-01T00:00:00.000+02:00","to":"2023-04-02T00:00:00.000+02:00","cost":54.433290825,"unitPrice":0.649283,"unitPriceVAT":0.129857,"consumption":83.836,"consumptionUnit":"kWh"},{"from":"2023-04-02T00:00:00.000+02:00","to":"2023-04-03T00:00:00.000+02:00","cost":44.405446125,"unitPrice":0.794871,"unitPriceVAT":0.158974,"consumption":55.865,"consumptionUnit":"kWh"},{"from":"2023-04-03T00:00:00.000+02:00","to":"2023-04-04T00:00:00.000+02:00","cost":51.806174375,"unitPrice":1.434995,"unitPriceVAT":0.286999,"consumption":36.102,"consumptionUnit":"kWh"},{"from":"2023-04-04T00:00:00.000+02:00","to":"2023-04-05T00:00:00.000+02:00","cost":84.6181242875,"unitPrice":1.655543,"unitPriceVAT":0.331109,"consumption":51.112,"consumptionUnit":"kWh"},{"from":"2023-04-05T00:00:00.000+02:00","to":"2023-04-06T00:00:00.000+02:00","cost":121.5749948625,"unitPrice":1.525542,"unitPriceVAT":0.305108,"consumption":79.693,"consumptionUnit":"kWh"},{"from":"2023-04-06T00:00:00.000+02:00","to":"2023-04-07T00:00:00.000+02:00","cost":87.99027765,"unitPrice":1.331834,"unitPriceVAT":0.266367,"consumption":66.067,"consumptionUnit":"kWh"},{"from":"2023-04-07T00:00:00.000+02:00","to":"2023-04-08T00:00:00.000+02:00","cost":63.549446975,"unitPrice":0.898378,"unitPriceVAT":0.179676,"consumption":70.738,"consumptionUnit":"kWh"},{"from":"2023-04-08T00:00:00.000+02:00","to":"2023-04-09T00:00:00.000+02:00","cost":49.836638425,"unitPrice":0.791322,"unitPriceVAT":0.158264,"consumption":62.979,"consumptionUnit":"kWh"},{"from":"2023-04-09T00:00:00.000+02:00","to":"2023-04-10T00:00:00.000+02:00","cost":27.7669614875,"unitPrice":0.865311,"unitPriceVAT":0.173062,"consumption":32.089,"consumptionUnit":"kWh"}]},"monthly":{"nodes":[{"from":"2023-01-01T00:00:00.000+01:00","to":"2023-02-01T00:00:00.000+01:00","cost":2553.0526192875,"unitPrice":1.148209,"unitPriceVAT":0.229642,"consumption":2223.508,"consumptionUnit":"kWh"},{"from":"2023-02-01T00:00:00.000+01:00","to":"2023-03-01T00:00:00.000+01:00","cost":1971.4661446375,"unitPrice":1.055717,"unitPriceVAT":0.211143,"consumption":1867.419,"consumptionUnit":"kWh"},{"from":"2023-03-01T00:00:00.000+01:00","to":"2023-04-01T00:00:00.000+02:00","cost":2034.4427701625,"unitPrice":1.06202,"unitPriceVAT":0.212404,"consumption":1915.635,"consumptionUnit":"kWh"}]},"yearly":{"nodes":[{"from":"2018-01-01T00:00:00.000+01:00","to":"2019-01-01T00:00:00.000+01:00","cost":3834.59033825,"unitPrice":0.735441,"unitPriceVAT":0.147088,"consumption":5214,"consumptionUnit":"kWh"},{"from":"2019-01-01T00:00:00.000+01:00","to":"2020-01-01T00:00:00.000+01:00","cost":14163.34488325,"unitPrice":0.60518,"unitPriceVAT":0.121036,"consumption":23403.52,"consumptionUnit":"kWh"},{"from":"2020-01-01T00:00:00.000+01:00","to":"2021-01-01T00:00:00.000+01:00","cost":4367.1817285375,"unitPrice":0.314652,"unitPriceVAT":0.06293,"consumption":13879.419,"consumptionUnit":"kWh"},{"from":"2021-01-01T00:00:00.000+01:00","to":"2022-01-01T00:00:00.000+01:00","cost":18724.9354599375,"unitPrice":0.957861,"unitPriceVAT":0.191572,"consumption":19548.706,"consumptionUnit":"kWh"},{"from":"2022-01-01T00:00:00.000+01:00","to":"2023-01-01T00:00:00.000+01:00","cost":26246.8039997125,"unitPrice":1.594865,"unitPriceVAT":0.318973,"consumption":16457.069,"consumptionUnit":"kWh"}]},"currentSubscription":{"status":"running","priceInfo":{"current":{"total":0.2595,"energy":0.1136,"tax":0.1459,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T13:00:00.000+02:00"},"today":[{"total":0.6543,"energy":0.4294,"tax":0.2249,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T00:00:00.000+02:00"},{"total":0.6461,"energy":0.4228,"tax":0.2233,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T01:00:00.000+02:00"},{"total":0.6648,"energy":0.4379,"tax":0.2269,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T02:00:00.000+02:00"},{"total":0.6856,"energy":0.4545,"tax":0.2311,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T03:00:00.000+02:00"},{"total":0.7097,"energy":0.4738,"tax":0.2359,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T04:00:00.000+02:00"},{"total":0.7663,"energy":0.519,"tax":0.2473,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T05:00:00.000+02:00"},{"total":0.8102,"energy":0.5542,"tax":0.256,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-10T06:00:00.000+02:00"},{"total":0.805,"energy":0.55,"tax":0.255,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-10T07:00:00.000+02:00"},{"total":0.8267,"energy":0.5674,"tax":0.2593,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-10T08:00:00.000+02:00"},{"total":0.8016,"energy":0.5472,"tax":0.2544,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-10T09:00:00.000+02:00"},{"total":0.5076,"energy":0.3121,"tax":0.1955,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T10:00:00.000+02:00"},{"total":0.3096,"energy":0.1537,"tax":0.1559,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T11:00:00.000+02:00"},{"total":0.3052,"energy":0.1502,"tax":0.155,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T12:00:00.000+02:00"},{"total":0.2595,"energy":0.1136,"tax":0.1459,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T13:00:00.000+02:00"},{"total":0.1425,"energy":0.02,"tax":0.1225,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T14:00:00.000+02:00"},{"total":0.1489,"energy":0.0251,"tax":0.1238,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T15:00:00.000+02:00"},{"total":0.1769,"energy":0.0475,"tax":0.1294,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T16:00:00.000+02:00"},{"total":0.4805,"energy":0.2904,"tax":0.1901,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T17:00:00.000+02:00"},{"total":0.6651,"energy":0.4381,"tax":0.227,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T18:00:00.000+02:00"},{"total":0.7534,"energy":0.5087,"tax":0.2447,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-10T19:00:00.000+02:00"},{"total":0.6308,"energy":0.4107,"tax":0.2201,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T20:00:00.000+02:00"},{"total":0.4896,"energy":0.2977,"tax":0.1919,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-10T21:00:00.000+02:00"},{"total":0.3304,"energy":0.1703,"tax":0.1601,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T22:00:00.000+02:00"},{"total":0.1601,"energy":0.0341,"tax":0.126,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-10T23:00:00.000+02:00"}],"tomorrow":[{"total":0.1387,"energy":0.0169,"tax":0.1218,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-11T00:00:00.000+02:00"},{"total":0.1316,"energy":0.0113,"tax":0.1203,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-11T01:00:00.000+02:00"},{"total":0.1277,"energy":0.0082,"tax":0.1195,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-11T02:00:00.000+02:00"},{"total":0.133,"energy":0.0124,"tax":0.1206,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-11T03:00:00.000+02:00"},{"total":0.2069,"energy":0.0715,"tax":0.1354,"currency":"SEK","level":"VERY_CHEAP","startsAt":"2023-04-11T04:00:00.000+02:00"},{"total":0.5888,"energy":0.377,"tax":0.2118,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-11T05:00:00.000+02:00"},{"total":0.6732,"energy":0.4446,"tax":0.2286,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-11T06:00:00.000+02:00"},{"total":0.7805,"energy":0.5304,"tax":0.2501,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-11T07:00:00.000+02:00"},{"total":0.8875,"energy":0.616,"tax":0.2715,"currency":"SEK","level":"EXPENSIVE","startsAt":"2023-04-11T08:00:00.000+02:00"},{"total":0.8672,"energy":0.5998,"tax":0.2674,"currency":"SEK","level":"EXPENSIVE","startsAt":"2023-04-11T09:00:00.000+02:00"},{"total":0.6858,"energy":0.4547,"tax":0.2311,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-11T10:00:00.000+02:00"},{"total":0.5676,"energy":0.3601,"tax":0.2075,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-11T11:00:00.000+02:00"},{"total":0.5571,"energy":0.3517,"tax":0.2054,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-11T12:00:00.000+02:00"},{"total":0.5288,"energy":0.329,"tax":0.1998,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-11T13:00:00.000+02:00"},{"total":0.4825,"energy":0.292,"tax":0.1905,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-11T14:00:00.000+02:00"},{"total":0.5081,"energy":0.3124,"tax":0.1957,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-11T15:00:00.000+02:00"},{"total":0.6196,"energy":0.4017,"tax":0.2179,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-11T16:00:00.000+02:00"},{"total":0.7991,"energy":0.5453,"tax":0.2538,"currency":"SEK","level":"EXPENSIVE","startsAt":"2023-04-11T17:00:00.000+02:00"},{"total":0.7546,"energy":0.5097,"tax":0.2449,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-11T18:00:00.000+02:00"},{"total":0.6941,"energy":0.4613,"tax":0.2328,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-11T19:00:00.000+02:00"},{"total":0.6773,"energy":0.4479,"tax":0.2294,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-11T20:00:00.000+02:00"},{"total":0.6572,"energy":0.4317,"tax":0.2255,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-11T21:00:00.000+02:00"},{"total":0.6165,"energy":0.3992,"tax":0.2173,"currency":"SEK","level":"NORMAL","startsAt":"2023-04-11T22:00:00.000+02:00"},{"total":0.5713,"energy":0.363,"tax":0.2083,"currency":"SEK","level":"CHEAP","startsAt":"2023-04-11T23:00:00.000+02:00"}]}}}]}}}'
 
  local jsonTable = json.decode(apiResult) -- Decode the json string from api to lua-table 
  
  self:getValues(jsonTable)

  local interval = (3600 + tonumber(self:getVariable("secondsH"))) - (os.date("%M") * 60 + os.date("%S"))
  self:logging(3,"SetTimeout " ..interval .." seconds")
  fibaro.setTimeout(interval*1000, function() 
     self:simData()
  end)
end


function QuickApp:getData() -- Get the data from Tibber
  self:logging(3,"getData() - Get the data from Tibber")
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
        ["Authorization"] = "Bearer " ..self:getVariable("token") ,
        ["User-Agent"] = "Tibber_Monitor/3.0 Fibaro/HC3 Firmware/" ..api.get("/settings/info").softVersion -- New Tibber user-agent
      }
    },
    success = function(response) 
        self:logging(3,"response status: " ..response.status)
        self:logging(3,"headers: " ..response.headers["Content-Type"])
        self:logging(3,"Response data: " ..response.data)

        if response.data == nil or response.data == "" or response.data == "[]" or response.status > 200 then -- Check for empty result
            self:warning("Temporarily no production data from Tibber Monitor")
          return
        end

        response.data = response.data:gsub("null", "0") -- clean up the response.data by replacing null with 0
        local jsonTable = json.decode(response.data) -- JSON decode from api to lua-table

        self:getValues(jsonTable)

      end,
      error = function(error)
        self:error("error: " ..json.encode(error))
        self:updateProperty("log", "error: " ..json.encode(error))
      end
    }) 
  
  local interval = (3600 + tonumber(self:getVariable("secondsH"))) - (os.date("%M") * 60 + os.date("%S"))
  self:logging(3,"SetTimeout " ..interval .." seconds")
  fibaro.setTimeout(interval*1000, function() 
     self:getData()
  end)
end


function QuickApp:createVariables() -- Create all Variables 
  --jsonTable = {}
  jsonPricesTod = {}
  jsonEnergy = {}
  data = {}
  data.hEnergy = 0 -- Hourly Energy usage
  data.hCost = 0 -- Hourly Energy cost
  data.dEnergy = 0 -- Daily Energy usage
  data.dCost = 0 -- Daily Energy cost
  data.mEnergy = 0 -- Monthly Energy usage
  data.mCost = 0 -- Monthly Energy cost
  data.yEnergy = 0 -- Yearly Energy usage
  data.yCost = 0 -- Yearly Energy cost
  data.tEnergy = 0 -- Total Energy usage
  data.tCost = 0 -- Total Energy cost
  data.minPriceTod = 0 -- Today Minimum Price
  data.minPercentageTod = 0 -- Today Mimimum Percentage
  data.minLevelTod = "" -- Today Mimimum Price Level
  data.minStartsAtTod = "" -- Today Minimum Price at hour
  data.maxPriceTod = 0 -- Today Maximum Price
  data.maxPercentageTod = 0 -- Today Maximum Percentage
  data.maxLevelTod = "" -- Today Price Level
  data.maxStartsAtTod = "" -- Today Maximum Price at hour
  data.avgPriceTod = 0 -- Today Average Price
  data.minPriceTom = 0 -- Tomorrow Minimum Price
  data.minPercentageTom = 0 -- Tomorrow Minimum Percentage
  data.minLevelTom = "" -- Tomorrow Price Level
  data.minStartsAtTom = "" -- Tomorrow Maximum Price at hour
  data.maxPriceTom = 0 -- Tomorrow Maximum Price
  data.maxPercentageTom = 0 -- Tomorrow Maximum Percentage
  data.maxLevelTom = "" -- Tomorrow Maximum Price Level
  data.maxStartsAtTom = "" -- Tomorrow Maximum Price at hour
  data.avgPriceTom = 0 -- Tomorrow Average Price
  data.totalPrice = 0 -- The total price (energy + taxes)
  data.spotPrice = 0 -- Nord Pool spot price (Gross Energy Price)
  data.tax = 0 -- The tax part of the price (guarantee of origin certificate, energy tax (Sweden only) and VAT)
  data.startsAt = "" -- The start time of the price
  data.currency = "" -- The price currency
  data.level = "" -- The price level compared to recent price values
  translation = i18n:translation(string.lower(self:getVariable("language"))) -- Initialise the translation
end


function QuickApp:getQuickAppVariables() -- Get all Quickapp Variables or create them
  local token = self:getVariable("token") 
  homeNr = tonumber(self:getVariable("homeNr"))
  extraCost = tonumber(self:getVariable("extraCost")) 
  local secondsH = tonumber(self:getVariable("secondsH")) 
  local httpTimeout = tonumber(self:getVariable("httpTimeout")) 
  debugLevel = tonumber(self:getVariable("debugLevel"))
  GlobVarLevel = string.lower(self:getVariable("GlobVarLevel"))
  GlobVarPerc = string.lower(self:getVariable("GlobVarPerc"))
  setEnergyPanel = string.lower(self:getVariable("setEnergyPanel"))
  currentPrice = string.lower(self:getVariable("currentPrice"))
  local language = string.lower(self:getVariable("language"))
  local workaroundE01 = tonumber(self:getVariable("workaroundE01")) 
  local workaroundC01 = tonumber(self:getVariable("workaroundC01")) 
  local workaroundPnn = tonumber(self:getVariable("workaroundPnn")) 
  local workaroundP23 = tonumber(self:getVariable("workaroundP23")) 

  -- Check existence of the mandatory variables, if not, create them with default values
  if token == "" or token == nil then
    token = "5K4MVS-OjfWhK_4yrjOlFe1F6kJXPVf7eQYggo8ebAE" -- This token is just an demo example, only for demo/test purposes
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
  if secondsH == "0" or secondsH == "" or secondsH == nil then
    secondsH = "300" -- Default 300 seconds after the whole hour
    self:setVariable("secondsH",secondsH)
    self:trace("Added QuickApp variable secondsH")
  end
  if httpTimeout == "" or httpTimeout == nil then
    httpTimeout = "10" -- Default http timeout 
    self:setVariable("httpTimeout",httpTimeout)
    self:trace("Added QuickApp variable httpTimeout")
    --httpTimeout = tonumber(httpTimeout)
  end 
  if debugLevel == "" or debugLevel == nil then
    debugLevel = "1" -- Default debug level
    self:setVariable("debugLevel",debugLevel)
    self:trace("Added QuickApp variable debugLevel")
    debugLevel = tonumber(debugLevel)
  end
  if GlobVarLevel == "" or GlobVarLevel == nil then 
    GlobVarLevel = false -- Default GlobVarLevel is false (No use of Global Variables for Price LEVEL)
    self:setVariable("GlobVarLevel",tostring(GlobVarLevel))
    self:trace("Added QuickApp variable GlobVarLevel")
  end
  if GlobVarLevel == "true" then 
    GlobVarLevel = true 
  else
    GlobVarLevel = false
  end
  if GlobVarPerc == "" or GlobVarPerc == nil then 
    GlobVarPerc = false -- Default GlobVarPerc is false (No use of Global Variables for Price PERCENTAGES)
    self:setVariable("GlobVarPerc",tostring(GlobVarPerc))
    self:trace("Added QuickApp variable GlobVarPerc")
  end
  if GlobVarPerc == "true" then 
    GlobVarPerc = true 
  else
    GlobVarPerc = false
  end
  if setEnergyPanel == "" or setEnergyPanel == nil then 
    setEnergyPanel = false -- Default setEnergyPanel is false (No inserting prices in Energy Panel)
    self:setVariable("setEnergyPanel",tostring(setEnergyPanel))
    self:trace("Added QuickApp variable setEnergyPanel")
  end
  if setEnergyPanel == "true" then 
    setEnergyPanel = true 
  else
    setEnergyPanel = false
  end
  if currentPrice == "" or currentPrice == nil then 
    currentPrice = false 
    self:setVariable("currentPrice",tostring(currentPrice))
    self:trace("Added QuickApp variable currentPrice")
  end
  if currentPrice == "true" then 
    currentPrice = true 
  else
    currentPrice = false
  end
  if token == nil or token == ""  or token == "0" then -- Check mandatory token 
    self:error("Token is empty! Get your token from the Tibber website and copy the token to the quickapp variable")
    self:warning("No token, switched to Simulation Mode")
    debugLevel = 4 -- Simulation mode due to empty token
  end
  if language == "" or language == nil or type(i18n:translation(string.lower(self:getVariable("language")))) ~= "table" then
    language = "en" 
    self:setVariable("language",language)
    self:trace("Added QuickApp variable language")
  end
  if workaroundE01 == "" or workaroundE01 == nil then
    workaroundE01 = "0" 
    self:setVariable("workaroundE01",workaroundE01)
    self:trace("Added QuickApp variable workaroundE01 for Energy 00-01 hour")
  end
  if workaroundC01 == "" or workaroundC01 == nil then
    workaroundC01 = "0" 
    self:setVariable("workaroundC01",workaroundC01)
    self:trace("Added QuickApp variable workaroundC01 for Cost 00-01 hour")
  end
  if workaroundPnn == "" or workaroundPnn == nil then
    workaroundPnn = "0" 
    self:setVariable("workaroundPnn",workaroundPnn)
    self:trace("Added QuickApp variable workaroundPnn for Price Energy Panel")
  end
  if workaroundP23 == "" or workaroundP23 == nil then
    workaroundP23 = "0" 
    self:setVariable("workaroundP23",workaroundP23)
    self:trace("Added QuickApp variable workaroundP23 for 23h Price Energy Panel")
  end
end
  

function QuickApp:setupChildDevices() -- Setup Child Devices
  local cdevs = api.get("/devices?parentId="..self.id) or {} -- Pick up all Child Devices
  function self:initChildDevices() end -- Null function, else Fibaro calls it after onInit()...

  if #cdevs == 0 then -- If no Child Devices, create them
    local initChildData = { 
      {className="hEnergy", name="Hour-1 Energy", type="com.fibaro.multilevelSensor"},
      {className="hCost", name="Hour-1 Cost", type="com.fibaro.multilevelSensor"},
      {className="dEnergy", name="Daily Energy", type="com.fibaro.multilevelSensor"},
      {className="dCost", name="Daily Cost", type="com.fibaro.multilevelSensor"},
      {className="mEnergy", name="Monthly Energy", type="com.fibaro.multilevelSensor"},
      {className="mCost", name="Monthly Cost", type="com.fibaro.multilevelSensor"},
      {className="yEnergy", name="Yearly Energy", type="com.fibaro.multilevelSensor"}, 
      {className="yCost", name="Yearly Cost", type="com.fibaro.multilevelSensor"},
      {className="tEnergy", name="Total Energy", type="com.fibaro.energyMeter"}, -- Device for values Energy Panel
      {className="tCost", name="Total Cost", type="com.fibaro.multilevelSensor"},
      {className="hPrice", name="Current Price", type="com.fibaro.multilevelSensor"},
      {className="minPriceTod", name="Today Min Price", type="com.fibaro.multilevelSensor"},
      {className="maxPriceTod", name="Today Max Price", type="com.fibaro.multilevelSensor"},
      {className="avgPriceTod", name="Today Avg Price", type="com.fibaro.multilevelSensor"},
      {className="hour01Tod", name="Today 00:00", type="com.fibaro.multilevelSensor"},
      {className="hour02Tod", name="Today 01:00", type="com.fibaro.multilevelSensor"},
      {className="hour03Tod", name="Today 02:00", type="com.fibaro.multilevelSensor"},
      {className="hour04Tod", name="Today 03:00", type="com.fibaro.multilevelSensor"},
      {className="hour05Tod", name="Today 04:00", type="com.fibaro.multilevelSensor"},
      {className="hour06Tod", name="Today 05:00", type="com.fibaro.multilevelSensor"},
      {className="hour07Tod", name="Today 06:00", type="com.fibaro.multilevelSensor"},
      {className="hour08Tod", name="Today 07:00", type="com.fibaro.multilevelSensor"},
      {className="hour09Tod", name="Today 08:00", type="com.fibaro.multilevelSensor"},
      {className="hour10Tod", name="Today 09:00", type="com.fibaro.multilevelSensor"},
      {className="hour11Tod", name="Today 10:00", type="com.fibaro.multilevelSensor"},
      {className="hour12Tod", name="Today 11:00", type="com.fibaro.multilevelSensor"},
      {className="hour13Tod", name="Today 12:00", type="com.fibaro.multilevelSensor"},
      {className="hour14Tod", name="Today 13:00", type="com.fibaro.multilevelSensor"},
      {className="hour15Tod", name="Today 14:00", type="com.fibaro.multilevelSensor"},
      {className="hour16Tod", name="Today 15:00", type="com.fibaro.multilevelSensor"},
      {className="hour17Tod", name="Today 16:00", type="com.fibaro.multilevelSensor"},
      {className="hour18Tod", name="Today 17:00", type="com.fibaro.multilevelSensor"},
      {className="hour19Tod", name="Today 18:00", type="com.fibaro.multilevelSensor"},
      {className="hour20Tod", name="Today 19:00", type="com.fibaro.multilevelSensor"},
      {className="hour21Tod", name="Today 20:00", type="com.fibaro.multilevelSensor"},
      {className="hour22Tod", name="Today 21:00", type="com.fibaro.multilevelSensor"},
      {className="hour23Tod", name="Today 22:00", type="com.fibaro.multilevelSensor"},
      {className="hour24Tod", name="Today 23:00", type="com.fibaro.multilevelSensor"},   
      {className="minPriceTom", name="Tomorrow Min Price", type="com.fibaro.multilevelSensor"},
      {className="maxPriceTom", name="Tomorrow Max Price", type="com.fibaro.multilevelSensor"},
      {className="avgPriceTom", name="Tomorrow Avg Price", type="com.fibaro.multilevelSensor"},
      {className="hour01Tom", name="Tomorrow 00:00", type="com.fibaro.multilevelSensor"},
      {className="hour02Tom", name="Tomorrow 01:00", type="com.fibaro.multilevelSensor"},
      {className="hour03Tom", name="Tomorrow 02:00", type="com.fibaro.multilevelSensor"},
      {className="hour04Tom", name="Tomorrow 03:00", type="com.fibaro.multilevelSensor"},
      {className="hour05Tom", name="Tomorrow 04:00", type="com.fibaro.multilevelSensor"},
      {className="hour06Tom", name="Tomorrow 05:00", type="com.fibaro.multilevelSensor"},
      {className="hour07Tom", name="Tomorrow 06:00", type="com.fibaro.multilevelSensor"},
      {className="hour08Tom", name="Tomorrow 07:00", type="com.fibaro.multilevelSensor"},
      {className="hour09Tom", name="Tomorrow 08:00", type="com.fibaro.multilevelSensor"},
      {className="hour10Tom", name="Tomorrow 09:00", type="com.fibaro.multilevelSensor"},
      {className="hour11Tom", name="Tomorrow 10:00", type="com.fibaro.multilevelSensor"},
      {className="hour12Tom", name="Tomorrow 11:00", type="com.fibaro.multilevelSensor"},
      {className="hour13Tom", name="Tomorrow 12:00", type="com.fibaro.multilevelSensor"},
      {className="hour14Tom", name="Tomorrow 13:00", type="com.fibaro.multilevelSensor"},
      {className="hour15Tom", name="Tomorrow 14:00", type="com.fibaro.multilevelSensor"},
      {className="hour16Tom", name="Tomorrow 15:00", type="com.fibaro.multilevelSensor"},
      {className="hour17Tom", name="Tomorrow 16:00", type="com.fibaro.multilevelSensor"},
      {className="hour18Tom", name="Tomorrow 17:00", type="com.fibaro.multilevelSensor"},
      {className="hour19Tom", name="Tomorrow 18:00", type="com.fibaro.multilevelSensor"},
      {className="hour20Tom", name="Tomorrow 19:00", type="com.fibaro.multilevelSensor"},
      {className="hour21Tom", name="Tomorrow 20:00", type="com.fibaro.multilevelSensor"},
      {className="hour22Tom", name="Tomorrow 21:00", type="com.fibaro.multilevelSensor"},
      {className="hour23Tom", name="Tomorrow 22:00", type="com.fibaro.multilevelSensor"},
      {className="hour24Tom", name="Tomorrow 23:00", type="com.fibaro.multilevelSensor"},    
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
      local childObject = _G[className](child) -- Create child object from the constructor's name
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
  
  http = net.HTTPClient({timeout = tonumber(self:getVariable("httpTimeout")) *1000})
  
  if tonumber(debugLevel) >= 4 then 
    self:simData() -- Go in simulation
  else
    self:getData() -- Get data from the Tibber platform
  end
end

-- EOF