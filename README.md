# tibber_monitor

This QuickApp gets todays and tomorrows energy prices and current energy consumption from the Tibber platform. 
Next to the current prices the mimimum, maximum and average prices and percentage +/- related to the average price for today and tomorrow are calculated. 
Tax and extra cost (cable owner) are included in the hourly, daily, monthly, yearly and total cost.  
All values are displayed in the labels. Colors show the price levels in the labels:
🟢 VERY CHEAP
🟡 CHEAP
🟠 NORMAL
🔴 EXPENSIVE
🟣 VERY EXPENSIVE

The Energy Panel is updated with the hourly prices and energy consumption. 
Several languages are supported. 

Child devices are available for:
- Hour-1 Energy (Energy usage of the previous hour)
- Hour-1 Cost (Energy cost of the previous hour)
- Daily Energy (usage in kWh)
- Daily Cost (energy and extra cost separately in the log text)
- Monthly Energy (usage in kWh)
- Monthly Cost (energy and extra cost separately in the log text)
- Yearly Energy (usage in kWh)
- Yearly Cost (energy and extra cost separately in the log text)
- Total Energy (usage in kWh, devicetype com.fibaro.energyMeter and automatic rateType=consumption for Fibaro Energy Panel)
- Total Cost (energy and extra cost separately in the log text)
- Current Price (hour and price level in the log text)
- Minimum Today Price (hour and price level in the log text)
- Maximum Today Price (hour and price level in the log text)
- Average Today Price (hour and price level in the log text)
- 24x Child devices for the Today prices from 1 to 24 hour (price level in the log text)
- Minimum Tomorrow Price (hour and price level in the log text)
- Maximum Tomorrow Price (hour and price level in the log text)
- Average Tomorrow Price (hour and price level in the log text)
- 24x Child devices for the Tomorrow prices from 1 to 24 hour (price level in the log text)

For easy use in for example blockscenes, Global Variables are available for:
- 24x Today Price Level 1-24 hour (VERY CHEAP, CHEAP, NORMAL, EXPENSIVE, VERY EXPENSIVE)
- 24x Tomorrow Price Level 1-24 hour (VERY CHEAP, CHEAP, NORMAL, EXPENSIVE, VERY EXPENSIVE)
- 24x Today Price Percentage 1-24 hour (Price related to today average price)
- 24x Tomorrow Price Percentage 1-24 hour (Price related to tomorrow average price)

These devices and global variables can be used to control appliances according to the lowest and forecast prices.


Use this QuickApp at your own risk. You are responsible for ensuring that the information provided via this QuickApp do not contain errors. 
Tibber is a registered trademark being the property of TIBBER. TIBBER reserves all rights to the registered trademarks.
Information which is published on TIBBER’s websites belongs to TIBBER or is used with the permission of the rights holder. 
Making of copies, presentations, distribution, display or any other transfer of the information on the website to the public is, except for strictly private use, prohibited unless done with the consent of TIBBER. 
Published material on dedicated TIBBER press websites, intended for public use, is exempt from the consent requirement.
Also see: https://tibber.com/en/legal-notice

To communicate with the API you need to acquire a OAuth access token and pass this along with every request passed to the server.
A Personal Access Token give you access to your data and your data only. 
This is ideal for DIY people that want to leverage the Tibber platform to extend the smartness of their home. 
Such a token can be acquired here: https://developer.tibber.com

When creating your access token or OAuth client you’ll be asked which scopes you want the access token to be associated with. 
These scopes tells the API which data and operations the client is allowed to perform on the user’s behalf. 
The scopes your app requires depend on the type of data it is trying to request. 
If you for example need access to user information you add the USER scope. 
If information about the user's homes is needed you add the appropriate HOME scopes.

Tomorrow values are available from 13:00 hour
If you have more than one home in your subscription, you need to fill in your home number the change between your homes. 
Known limitation: In case of the change due to daylight saving time, the 02:00 hour is skipped going to summer, only 23 price values are available

Tibber Price levels are based on trailing price average (3 days for hourly values and 30 days for daily values)
- VERY CHEAP - The price is smaller or equal to 60 % compared to average price
- CHEAP - The price is greater than 60 % and smaller or equal to 90 % compared to average price
- NORMAL - The price is greater than 90 % and smaller than 115 % compared to average price
- EXPENSIVE - The price is greater or equal to 115 % and smaller than 140 % compared to average price
- VERY EXPENSIVE - The price is greater or equal to 140 % compared to average price

Tibber Tax: The tax part of the price (guarantee of origin certificate, energy tax (Sweden only) and VAT)

Tibber API documentation: https://developer.tibber.com/docs/guides/calling-api
Tibber API explorer: https://developer.tibber.com/explorer
Tibber status: https://status.tibber.com


ToDo, maybe (?)
- Setup current hour price with current date/time and not from Tibber response
- Energy prices and cost insertion in Energy Panel not hourly but once a day
- In case of error: retry or wait for next interval (that is the current method)
- Show prices in cents
- Activate simulation if use of demo token


Changes versio 3.0 (21th April 2023)
- Added 24 child devices for the today prices 1 to 24 hour
- Added 24 child devices for the tomorrow prices 1 to 24 hour
- Added child devices for tomorrow minimum, tomorrow maximum and tomorrow average prices
- Added tommorow prices to the labels
- Added tomorrow minimum, tomorrow maximum and tomorrow average prices to the labels
- Added color 🟢🟡🟠🔴🟣 to the prices in the labels based on the Tibber price level
- Added todays energy usage per hour to the labels
- Deleted today PRICES from the global variables, because they are available in the child devices
- Added global variables for tomorrow price LEVELS (the today global variables were already there)
- Added global variables for today price PERCENTAGES 
- Added global variables for tomorrow price PERCENTAGES 
- Changed the name of the global variables to get a better sorting in the dashboard
- Added separate QuickApp variables to activate today and or tomorrow global variables
- Changed to QuickApp variable secondsH (interval) to how many seconds after the whole hour the QuickApp should run, so the QuickApp now runs once an hour a few minutes after the whole hour
- Added extra check for existance of the 24 hour values (for example in case of daylight saving time change)
- Changed the main device to Generic Device
- Changed to multifile QuickApp
- Added translation for English (en), Dutch (nl), Swedish (se), Norwegian (no), German (de)
- Added new Tibber user-agent to http request headers
- Made some changes to work with missing tomorrow prices from Tibber
- Improved some debug logging messages on debug level 3


Changes version 2.1 (25th June 2022)
- Changed the child device names Hourly Energy and Hourly Cost to Hour-1 Energy and Hour-1 Cost, because they actually are from the previous hour
- Added Global Variables for Prices 0-10 hour
- Removed Global Variable for Current Price Level, the Current Price Level is also available in the Global Variable for all 0-10 hour levels
- Added QuickApp variable currentPrice to insert the current price in the Energy Panel if you also use the Tibber Live QuickApp. Otherwise the hour+1 price is interted. 

Changes version 2.0 (25th May 2022)
- Changed the device for the energy panel from the Daily Energy to the Total Energy child device. Because Tibber reports always the past hour at the start of the new hour (so always too late) and the Energy panel and the Daily Energy child devices both resets at midnight and the Total Energy child device doesn't resets, that prevents the last hour from not getting into the energy panel. Thanks to @JcBorgs for analysing and testing. 
- Added workaround with the help of @JcBorgs for a Tibber API bug in 00-01 hour consumption (energy and cost can change to "null" during the day) 
- Added workaround for empty Tibber responses between 00:00 and 00:05 hour with help of @JcBorgs
- Added insert of hour-1 price in Energy Panel (can be turned on or off) with help of @JcBorgs
- Changed the name of all child devices Percentage to dynamic names like "At hour 16:00", "At hour 17:00", etc. with help of @jgab and @JcBorgs
- Changed handling of no response from Tibber
- Removed user defined icon (not necessary anymore)

Changes version 1.3 (6th February 2022)
- For easy use in blockscenes added Global Variables for the levels (CHEAP, etc) for the current price and percentages +0, +1, +2, +3, +4, +5, +6, +7, +8, +9 and +10 hour. (Activate the global variables with the QuickApp Variable setGlobalVar = true)
- Added an extra Child Device for Percentage +0 hour (current hour)
- Added QuickApp Variable setPercentage to setup the calculation of the percentages from "average" price or from "current" price
- Changed the calculation of the percentages according to the setting in setPercentage, "average" or "current" price
- Limited the calculation of the average price to the current price and the next 10 prices (in line with the child devices +0, +1 ... +10)
- Added a minimum and maximum to forNextHour of 12 and 35 hours prices 

Changes version 1.2 (2nd February 2022) 
- Solved a nasty bug with the percentage in the labels for tomorrow prices
- Added extra child devices for percentage +6 +7 +8 +9 +10 hour

Changes version 1.1 (29th January 2022)
- Added average price calculation and child device (made by Fibaro forum member @drzordz)
- Added QuickApp variable to setup amount of hours to show the next prices (made by Fibaro forum member @drzordz)

Changes version 1.0 (8th Januari 2022)
- Reduced max and min price and percentage to two decimals digits 
- Solved issue with empty hourly energy
- Added the prices to the log text of the child devices +1 +2 +3 +4 +5
- Added percentages to the hourly prices in the labels
- Added percentages to the minimum and maximum prices in the labels
- Changed the abbreviation to the latest moment (display in properties and labels) to get the (theoretical) most accurate calculation
- Changed the default interval to 930 seconds to update more often and have less issues in case Tibber doesn't respond

Changes version 0.6 (1st January 2022)
- Solved bug that didn't cleaned up the labels 

Changes version 0.5 (1st January 2021)
- Changed main device to generic.device
- Changed Tax calculations
- Added child devices monthly and total energy and cost
- Calculated the daily, monthly, yearly and total energy, cost and tax to get this day, this month, this year and total values
- Solved a bug showing more than 12 prices just after midnight
- Solved handling nil values at beginning of year, etc

Changes version 0.3 (30th December 2021)
- Added quickapp variable homeNr to select which home if you have more than one in your subscription

Changes version 0.2 (29th December 2021)
- Added all child devices
- Added QuickApp variable for extra cost and added the cost to the calculations
- Replaced "null" values in response to prevent errors
- Limited values to next 12 hours

Changes version 0.1 (23rd December 2021)
- Initial version


Variables (mandatory and created automatically): 
- token = Authorization token (see the Tibber website: https://developer.tibber.com)
- homeNr = Tibber home (nodes) number if you have more than one home (default = 1)
- extraCost = Extra cost per kWh for Tibber and Cable owner, decimals with dot, not comma (default = 0)
- secondsH = How many seconds after the whole hour should the QuickApp run (default = 300 seconds (3 minutes), always greater than 0)
- httpTimeout = How long to wait for a response from Tibber (default = 10 seconds) 
- debugLevel = Number (1=some, 2=few, 3=all, 4=simulation mode) (default = 1)
- GlobVarLevel = true or false, whether you want to use the Global Variables for the today and tomorrow price LEVELS (default = false)
- GlobVarPerc = true or false, whether you want to use the Global Variables for the today and tomorrow price PERCENTAGES (default = false)
- setEnergyPanel = inserting prices in Energy Panel (default = false)
- currentPrice = inserting current prices (if you also use Tibber Live) in Energy Panel (default = false)
- workaroundE01 = Stores the value of the 00-01 hour energy for a Tibber API bug workaround (default = 0)
- workaroundC01 = Stores the value of the 00-01 hour cost for a Tibber API bug workaround (default = 0)
- workaroundPnn = Stores the hour-1 price for the Energy Panel (default = 0)
- workaroundP23 = Stores the 23h price for the Energy Panel (default = 0)
