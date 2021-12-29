# tibber_monitor
This QuickApp gets todays an tomorrows energy prices from the Tibber platform. 
Next to the current prices the lowest and highest price for the next 12 hours is calculated.
Tax and fees are included in the hourly, daily and yearly cost.  
All values are displayed in the labels. 

Child devices are available for:
- Hourly energy usage
- Hourly energy cost
- Todays energy usage (com.fibaro.energyMeter with automatic rateType=consumption for Fibaro Energy Panel)
- Todays energy cost (including fees)
- Yearly energy usage
- Yearly energy cost
- Actual price now
- Minumum price today (for the next 12 hours)
- Maximum price today (for the next 12 hours)
- Percentage +1 hour (compaired to actual price now, positive value means a increase of the price, negative value means a decrease of the price)
- Percentage +2 hour
- Percentage +3 hour
- Percentage +4 hour
- Percentage +5 hour

These values can be used to control appliances according to the lowest and forecast prices during the day. 
To communicate with the API you need to acquire a OAuth access token and pass this along with every request passed to the server.
A Personal Access Token give you access to your data and your data only. 
This is ideal for DIY people that want to leverage the Tibber platform to extend the smartness of their home. 
Such a token can be acquired here: https://thewall.tibber.com
 
When creating your access token or OAuth client you’ll be asked which scopes you want the access token to be associated with. 
These scopes tells the API which data and operations the client is allowed to perfom on the user’s behalf. 
The scopes your app requires depend on the type of data it is trying to request. 
If you for example need access to user information you add the USER scope. 
If information about the users homes is needed you add the appropiate HOME scopes.
 
Tomorrow values are available from 13:00 hour
 
Tibber API documentation: https://developer.tibber.com/docs/guides/calling-api
Tibber API explorer: https://developer.tibber.com/explorer

Changes version 0.2 (29th December 2021)
- Added all child devices
- Added QuickApp variable for extra cost and added the cost to the calculations
- Replaced "null" values in response to prevent errors
- Limited values to next 12 hours

Changes version 0.1 (23rd December 2021)
- Initial version

Variables (mandatory and created automatically): 
- token = Authorization token (see the Tibber website: https://thewall.tibber.com)
- extraCost = Extra cost per kWh for Tibber and Cable owner, decimals with dot, not komma (default = 0)
- interval = Interval in seconds to get the data from the Tibber Platform. The default request interval is 3600 seconds (60 minutes).
- debugLevel = Number (1=some, 2=few, 3=all, 4=simulation mode) (default = 1)
- setGlobalVar = true or false, whether you want tu use the Global Variables (default = false)
