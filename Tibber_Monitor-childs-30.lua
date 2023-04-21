-- Tibber Monitor Childs

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

class 'dEnergy'(QuickAppChild) 
function dEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
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

class 'tEnergy'(QuickAppChild) -- Device for Energy Panel
function tEnergy:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "consumption" then 
    self:updateProperty("rateType", "consumption")
    self:warning("Changed rateType interface of Total Energy child device (" ..self.id ..") to consumption")
  end
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
  self:updateProperty("value", tonumber(string.format("%.2f",data.totalPrice)))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", "(" ..translation[data.level] ..")")
end

class 'minPriceTod'(QuickAppChild)
function minPriceTod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function minPriceTod:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",(data.minPriceTod or 0))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", (data.minStartsAtTod or "") .." " ..(translation[data.minLevelTod] or ""))
end

class 'maxPriceTod'(QuickAppChild)
function maxPriceTod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function maxPriceTod:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",(data.maxPriceTod or 0))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", (data.maxStartsAtTod or "") .." "..(translation[data.maxLevelTod] or ""))
end

class 'avgPriceTod'(QuickAppChild)
function avgPriceTod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function avgPriceTod:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",(data.avgPriceTod or 0))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", " ")
end

class 'hour01Tod'(QuickAppChild) -- 00:00-01:00
function hour01Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour01Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[1].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[1].level])
end

class 'hour02Tod'(QuickAppChild) -- 01:00-02:00
function hour02Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour02Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[2].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[2].level])
end

class 'hour03Tod'(QuickAppChild) -- 02:00-03:00
function hour03Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour03Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[3].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[3].level])
end

class 'hour04Tod'(QuickAppChild) -- 03:00-04:00
function hour04Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour04Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[4].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[4].level])
end

class 'hour05Tod'(QuickAppChild) -- 04:00-05:00
function hour05Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour05Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[5].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[5].level])
end

class 'hour06Tod'(QuickAppChild) -- 05:00-06:00
function hour06Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour06Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[6].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[6].level])
end

class 'hour07Tod'(QuickAppChild) -- 06:00-07:00
function hour07Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour07Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[7].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[7].level])
end

class 'hour08Tod'(QuickAppChild) -- 07:00-08:00
function hour08Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour08Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[8].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[8].level])
end

class 'hour09Tod'(QuickAppChild) -- 08:00-09:00
function hour09Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour09Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[9].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[9].level])
end

class 'hour10Tod'(QuickAppChild) -- 09:00-10:00
function hour10Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour10Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[10].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[10].level])
end

class 'hour11Tod'(QuickAppChild) -- 10:00-11:00
function hour11Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour11Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[11].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[11].level])
end

class 'hour12Tod'(QuickAppChild) -- 11:00-12:00
function hour12Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour12Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[12].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[12].level])
end

class 'hour13Tod'(QuickAppChild) -- 12:00-13:00
function hour13Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour13Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[13].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[13].level])
end

class 'hour14Tod'(QuickAppChild) -- 13:00-14:00
function hour14Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour14Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[14].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[14].level])
end

class 'hour15Tod'(QuickAppChild) -- 14:00-15:00
function hour15Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour15Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[15].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[15].level])
end

class 'hour16Tod'(QuickAppChild) -- 15:00-16:00
function hour16Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour16Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[16].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[16].level])
end

class 'hour17Tod'(QuickAppChild) -- 16:00-17:00
function hour17Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour17Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[17].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[17].level])
end

class 'hour18Tod'(QuickAppChild) -- 17:00-18:00
function hour18Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour18Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[18].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[18].level])
end

class 'hour19Tod'(QuickAppChild) -- 18:00-19:00
function hour19Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour19Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[19].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[19].level])
end

class 'hour20Tod'(QuickAppChild) -- 19:00-20:00
function hour20Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour20Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[20].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[20].level])
end

class 'hour21Tod'(QuickAppChild) -- 20:00-21:00
function hour21Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour21Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[21].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[21].level])
end

class 'hour22Tod'(QuickAppChild) -- 21:00-22:00
function hour22Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour22Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[22].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[22].level])
end

class 'hour23Tod'(QuickAppChild) -- 22:00-23:00
function hour23Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour23Tod:updateValue() 
  self:updateProperty("value", tonumber(jsonPricesTod[23].total))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", translation[jsonPricesTod[23].level])
end

class 'hour24Tod'(QuickAppChild) -- 23:00-24:00
function hour24Tod:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour24Tod:updateValue() 
  if jsonPricesTod[24] then
    self:updateProperty("value", tonumber(jsonPricesTod[24].total))
    self:updateProperty("log", translation[jsonPricesTod[24].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", " ")
  end
  self:updateProperty("unit", data.currency)
end

class 'minPriceTom'(QuickAppChild)
function minPriceTom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function minPriceTom:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",(data.minPriceTom or 0))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", (data.minStartsAtTom or "") .." " ..(translation[data.minLevelTom] or ""))
end

class 'maxPriceTom'(QuickAppChild)
function maxPriceTom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function maxPriceTom:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",(data.maxPriceTom or 0))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", (data.maxStartsAtTom or "") .." "..(translation[data.maxLevelTom] or ""))
end

class 'avgPriceTom'(QuickAppChild)
function avgPriceTom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function avgPriceTom:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.2f",(data.avgPriceTom or 0))))
  self:updateProperty("unit", data.currency)
  self:updateProperty("log", " ")
end

class 'hour01Tom'(QuickAppChild) -- 00:00-01:00
function hour01Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour01Tom:updateValue(data) 
  if jsonPricesTom[1] then 
    self:updateProperty("value", tonumber(jsonPricesTom[1].total))
    self:updateProperty("log", translation[jsonPricesTom[1].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour02Tom'(QuickAppChild) -- 01:00-02:00
function hour02Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour02Tom:updateValue(data) 
  if jsonPricesTom[2] then 
    self:updateProperty("value", tonumber(jsonPricesTom[2].total))
    self:updateProperty("log", translation[jsonPricesTom[2].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour03Tom'(QuickAppChild) -- 02:00-03:00
function hour03Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour03Tom:updateValue(data) 
  if jsonPricesTom[3] then 
    self:updateProperty("value", tonumber(jsonPricesTom[3].total))
    self:updateProperty("log", translation[jsonPricesTom[3].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour04Tom'(QuickAppChild) -- 03:00-04:00
function hour04Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour04Tom:updateValue(data) 
  if jsonPricesTom[4] then 
    self:updateProperty("value", tonumber(jsonPricesTom[4].total))
    self:updateProperty("log", translation[jsonPricesTom[4].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour05Tom'(QuickAppChild) -- 04:00-05:00
function hour05Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour05Tom:updateValue(data) 
  if jsonPricesTom[5] then 
    self:updateProperty("value", tonumber(jsonPricesTom[5].total))
    self:updateProperty("log", translation[jsonPricesTom[5].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour06Tom'(QuickAppChild) -- 05:00-06:00
function hour06Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour06Tom:updateValue(data) 
  if jsonPricesTom[1] then 
    self:updateProperty("value", tonumber(jsonPricesTom[6].total))
    self:updateProperty("log", translation[jsonPricesTom[6].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour07Tom'(QuickAppChild) -- 06:00-07:00
function hour07Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour07Tom:updateValue(data) 
  if jsonPricesTom[7] then 
    self:updateProperty("value", tonumber(jsonPricesTom[7].total))
    self:updateProperty("log", translation[jsonPricesTom[7].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour08Tom'(QuickAppChild) -- 07:00-08:00
function hour08Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour08Tom:updateValue(data) 
  if jsonPricesTom[8] then 
    self:updateProperty("value", tonumber(jsonPricesTom[8].total))
    self:updateProperty("log", translation[jsonPricesTom[8].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour09Tom'(QuickAppChild) -- 08:00-09:00
function hour09Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour09Tom:updateValue(data) 
  if jsonPricesTom[9] then 
    self:updateProperty("value", tonumber(jsonPricesTom[9].total))
    self:updateProperty("log", translation[jsonPricesTom[9].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour10Tom'(QuickAppChild) -- 09:00-10:00
function hour10Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour10Tom:updateValue(data) 
  if jsonPricesTom[10] then 
    self:updateProperty("value", tonumber(jsonPricesTom[10].total))
    self:updateProperty("log", translation[jsonPricesTom[10].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour11Tom'(QuickAppChild) -- 10:00-11:00
function hour11Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour11Tom:updateValue(data) 
  if jsonPricesTom[11] then 
    self:updateProperty("value", tonumber(jsonPricesTom[11].total))
    self:updateProperty("log", translation[jsonPricesTom[11].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour12Tom'(QuickAppChild) -- 11:00-12:00
function hour12Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour12Tom:updateValue(data) 
  if jsonPricesTom[12] then 
    self:updateProperty("value", tonumber(jsonPricesTom[12].total))
    self:updateProperty("log", translation[jsonPricesTom[12].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour13Tom'(QuickAppChild) -- 12:00-13:00
function hour13Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour13Tom:updateValue(data) 
  if jsonPricesTom[13] then 
    self:updateProperty("value", tonumber(jsonPricesTom[13].total))
    self:updateProperty("log", translation[jsonPricesTom[13].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour14Tom'(QuickAppChild) -- 13:00-14:00
function hour14Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour14Tom:updateValue(data) 
  if jsonPricesTom[14] then 
    self:updateProperty("value", tonumber(jsonPricesTom[14].total))
    self:updateProperty("log", translation[jsonPricesTom[14].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour15Tom'(QuickAppChild) -- 14:00-15:00
function hour15Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour15Tom:updateValue(data) 
  if jsonPricesTom[15] then 
    self:updateProperty("value", tonumber(jsonPricesTom[15].total))
    self:updateProperty("log", translation[jsonPricesTom[15].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour16Tom'(QuickAppChild) -- 15:00-16:00
function hour16Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour16Tom:updateValue(data) 
  if jsonPricesTom[16] then 
    self:updateProperty("value", tonumber(jsonPricesTom[16].total))
    self:updateProperty("log", translation[jsonPricesTom[16].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour17Tom'(QuickAppChild) -- 16:00-17:00
function hour17Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour17Tom:updateValue(data) 
  if jsonPricesTom[17] then 
    self:updateProperty("value", tonumber(jsonPricesTom[17].total))
    self:updateProperty("log", translation[jsonPricesTom[17].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour18Tom'(QuickAppChild) -- 17:00-18:00
function hour18Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour18Tom:updateValue(data) 
  if jsonPricesTom[18] then 
    self:updateProperty("value", tonumber(jsonPricesTom[18].total))
    self:updateProperty("log", translation[jsonPricesTom[18].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour19Tom'(QuickAppChild) -- 18:00-19:00
function hour19Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour19Tom:updateValue(data) 
  if jsonPricesTom[19] then 
    self:updateProperty("value", tonumber(jsonPricesTom[19].total))
    self:updateProperty("log", translation[jsonPricesTom[19].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour20Tom'(QuickAppChild) -- 19:00-20:00
function hour20Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour20Tom:updateValue(data) 
  if jsonPricesTom[20] then 
    self:updateProperty("value", tonumber(jsonPricesTom[20].total))
    self:updateProperty("log", translation[jsonPricesTom[20].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour21Tom'(QuickAppChild) -- 20:00-21:00
function hour21Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour21Tom:updateValue(data) 
  if jsonPricesTom[21] then 
    self:updateProperty("value", tonumber(jsonPricesTom[21].total))
    self:updateProperty("log", translation[jsonPricesTom[21].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour22Tom'(QuickAppChild) -- 21:00-22:00
function hour22Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour22Tom:updateValue(data) 
  if jsonPricesTom[22] then 
    self:updateProperty("value", tonumber(jsonPricesTom[22].total))
    self:updateProperty("log", translation[jsonPricesTom[22].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour23Tom'(QuickAppChild) -- 22:00-23:00
function hour23Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour23Tom:updateValue(data) 
  if jsonPricesTom[23] then 
    self:updateProperty("value", tonumber(jsonPricesTom[23].total))
    self:updateProperty("log", translation[jsonPricesTom[23].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

class 'hour24Tom'(QuickAppChild) -- 23:00-24:00
function hour24Tom:__init(dev)
  QuickAppChild.__init(self,dev)
end
function hour24Tom:updateValue(data) 
  if jsonPricesTom[24] then 
    self:updateProperty("value", tonumber(jsonPricesTom[24].total))
    self:updateProperty("log", translation[jsonPricesTom[24].level])
  else
    self:updateProperty("value", 0)
    self:updateProperty("log", "N/A")
  end
  self:updateProperty("unit", data.currency)
end

-- EOF