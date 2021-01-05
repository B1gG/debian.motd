# debian.motd

It is my dynamic MOTD for Debian/Ubuntu.
You can find more details in my blog: [https://bigg.blog/](https://bigg.blog/)

# Usage:
If you are using Debian 10 already running `motd.service`, just place the file `10-bigg-debian.motd.sh` in `/etc/update-motd.d/` and make it executable, something like:
```
sudo mv 10-bigg-debian.motd.sh /etc/update-motd.d/10-bigg-debian.motd.sh
sudo chmod +x /etc/update-motd.d/10-bigg-debian.motd.sh
```

Now rename the file `/etc/motd`, something like:
```
sudo mv /etc/motd /etc/motd.old
```

# Requirement
There are some packages required to get details for Battery, AC Adapter and Temperature
### Install `acpi` for Battery and AC Adapter details
```
sudo apt install acpi
```

### Install `lm_sensors` for Temperature details
```
sudo apt install lm_sensors
```
then run the configuration/detection with:
```
sudo sensors-detect
```

### Weather details
To get those details you can choose between Accuweather or BBC as the source.
For Accuweather, go to [https://www.accuweather.com/](https://www.accuweather.com/) select your city and take a look at the address and the location code, for example for "London, London, GB" this will be **https://www.accuweather.com/en/gb/london/ec4a 2/weather-forecast/328328** here we will copy the code "london/ec4a 2" and modify to **london|ec4a%202**.
Notice we replace the / by | and encode the space to %20.
Replace the code in the line:
```
WEATHER_INFO=`curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=LONDON|ec4a%202" | sed -n '/Currently:/ s/.*: \(.*\): \([0-9]*\)\([CF]\).*/\2°\3, \1/p'`
```
For BBC, go to [https://www.bbc.co.uk/weather](https://www.bbc.co.uk/weather) select your location and take note of the number added at the end of the address, for example for "London, Greater London" it will be **2643743**; replace that number in the line:
```
WEATHER_INFO=`curl -s "https://weather-broker-cdn.api.bbci.co.uk/en/forecast/rss/3day/2643743" | sed -n '/Today:/ s/.*Today: \(.*\)<.*/\1/p'`
```
Remember comment/uncomment the lines to use the one you prefer

# Screenshot

![Alt text](Screenshot.jpg "Screenshot")