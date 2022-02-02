# tibber_monitor
This QuickApp gets todays an tomorrows energy prices from the Tibber platform. 
Next to the current prices the lowest and highest price for the next 12 hours is calculated.
Tax and extra cost (cable owner) are included in the hourly, daily, monthly, yearly and total cost.  
All values are displayed in the labels. 

Child devices are available for:
- Hourly energy usage
- Hourly energy cost
- Todays energy usage (com.fibaro.energyMeter with automatic rateType=consumption for Fibaro Energy Panel)
- Todays energy cost (including fees)
- Monthly energy usage
- Monthly energy cost
- Yearly energy usage
- Yearly energy cost
- Total energy usage
- Total energy cost
- Actual price now
- Minumum price today (for the next 12 hours)
- Maximum price today (for the next 12 hours)
- Average price
- Percentage +1 hour (compaired to actual price now, positive value means an increase of the price, negative value means a decrease of the price)
- Percentage +2 hour
- Percentage +3 hour
- Percentage +4 hour
- Percentage +5 hour
- Percentage +6 hour
- Percentage +7 hour
- Percentage +8 hour
- Percentage +9 hour
- Percentage +10 hour

These values can be used to control appliances according to the lowest and forecast prices during the day. 

To communicate with the API you need to acquire a OAuth access token and pass this along with every request passed to the server.
A Personal Access Token give you access to your data and your data only. 
This is ideal for DIY people that want to leverage the Tibber platform to extend the smartness of their home. 
Such a token can be acquired here: https://developer.tibber.com
 
When creating your access token or OAuth client you’ll be asked which scopes you want the access token to be associated with. 
These scopes tells the API which data and operations the client is allowed to perfom on the user’s behalf. 
The scopes your app requires depend on the type of data it is trying to request. 
If you for example need access to user information you add the USER scope. 
If information about the users homes is needed you add the appropiate HOME scopes.
 
Tomorrow values are available from 13:00 hour
If you have more than one home in your subscription, you need to fill in your home number the change between your homes. 

Tibber API documentation: https://developer.tibber.com/docs/guides/calling-api
Tibber API explorer: https://developer.tibber.com/explorer

Changes version 1.2 (2nd February 2022)
- Solved a nasty bug with the percentage in the labels for tomorrow prices
- Added extra child devices for percentage +6 +7 +8 +9 +10 hour

Changes version 1.1 (29th January 2022)
- Added average price calculation and child device (made by Fibaro forum member drzordz)
- Added QuickApp variable to setup amount of hours to show the next prices (made by Fibaro forum member drzordz)

Changes version 1.0 (8th Januari 2022)
- Reduced max and min price and percentage to two decimals digits 
- Solved issue with empty hourly energy
- Added the prices to the log text of the child devices +1 +2 +3 +4 +5
- Added percentages to the hourly prices in the labels
- Added percentages to the minimum and maximum prices in the labels
- Changed the abreviation to the latest moment (display in properties and labels) to get the (theoretical) most accureate calculation
- Changed the default interval to 930 seconds to update more often and have less issues in case Tibber doesn't respond

Changes version 0.6 (1st January 2022)
- Solved bug that didn't cleaned up the labels 

Changes version 0.5 (1st Januari 2021)
- Changed main device to generic.device
- Changed Tax calculations
- Added child devices monthly and total energy and cost
- Calculated the daily, monthly, yearly and total energy, cost and tax to get this day, this month, this year and total values
- Solved a bug showing more than 12 prices just after midnight
- Solved handling nil values at beginning of year, etc

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
- extraCost = Extra cost per kWh for Tibber and Cable owner, decimals with dot, not komma (default = 0)
- interval = Interval in seconds to get the data from the Tibber Platform. The default is 930 seconds (15 minutes and 30 seconds). (Tibber has a rate limit of 100 requests in 5 minutes per IP address)
- debugLevel = Number (1=some, 2=few, 3=all, 4=simulation mode) (default = 1)
- setGlobalVar = true or false, whether you want tu use the Global Variables (default = false)
- icon = User defined icon number (add the icon via another device and lookup the number) (default = 0)
- forNextHour = How many hours forward it will check (default = 12)
