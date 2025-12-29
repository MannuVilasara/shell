import QtQuick
import Quickshell
pragma Singleton

// Root must be Item (not QtObject) to support the Timer
Item {
    // 30 Minutes
    // --- Logic ---

    id: root

    // --- Live Properties ---
    property string temperature: "--"
    property string conditionText: "Unknown"
    property string city: "Locating..."
    property string icon: ""
    property bool isDay: true
    // Detailed Stats
    property string humidity: "--%"
    property string wind: "-- km/h"
    property string pressure: "-- hPa"
    property string uvIndex: "--"
    // Weekly Forecast Model (Array of objects)
    // Structure: { day: "Mon", icon: "...", max: "20°", min: "10°", condition: "Sunny" }
    property var forecastModel: []
    // --- Configuration ---
    property int refreshInterval: 30 * 60 * 1000
    // --- Weather Codes Map ---
    property var _weatherCodes: ({
        "0": {
            "day": "",
            "night": "",
            "desc": "Clear sky"
        },
        "1": {
            "day": "",
            "night": "",
            "desc": "Mainly clear"
        },
        "2": {
            "day": "",
            "night": "",
            "desc": "Partly cloudy"
        },
        "3": {
            "day": "",
            "night": "",
            "desc": "Overcast"
        },
        "45": {
            "day": "",
            "night": "",
            "desc": "Fog"
        },
        "48": {
            "day": "",
            "night": "",
            "desc": "Rime fog"
        },
        "51": {
            "day": "",
            "night": "",
            "desc": "Light drizzle"
        },
        "53": {
            "day": "",
            "night": "",
            "desc": "Mod. drizzle"
        },
        "55": {
            "day": "",
            "night": "",
            "desc": "Dense drizzle"
        },
        "61": {
            "day": "",
            "night": "",
            "desc": "Slight rain"
        },
        "63": {
            "day": "",
            "night": "",
            "desc": "Mod. rain"
        },
        "65": {
            "day": "",
            "night": "",
            "desc": "Heavy rain"
        },
        "71": {
            "day": "",
            "night": "",
            "desc": "Slight snow"
        },
        "73": {
            "day": "",
            "night": "",
            "desc": "Mod. snow"
        },
        "75": {
            "day": "",
            "night": "",
            "desc": "Heavy snow"
        },
        "80": {
            "day": "",
            "night": "",
            "desc": "Rain showers"
        },
        "81": {
            "day": "",
            "night": "",
            "desc": "Mod. showers"
        },
        "82": {
            "day": "",
            "night": "",
            "desc": "Violent showers"
        },
        "95": {
            "day": "ﱈ",
            "night": "ﱈ",
            "desc": "Thunderstorm"
        },
        "96": {
            "day": "ﱈ",
            "night": "ﱈ",
            "desc": "Thunderstorm"
        },
        "99": {
            "day": "ﱈ",
            "night": "ﱈ",
            "desc": "Thunderstorm"
        }
    })

    function getDayName(dateString) {
        var date = new Date(dateString);
        return date.toLocaleDateString(Qt.locale(), "ddd"); // Returns "Mon", "Tue", etc.
    }

    function fetchLocation() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        root.city = response.city;
                        fetchWeather(response.lat, response.lon);
                    } catch (e) {
                        console.warn("[Weather] Location JSON parse error");
                    }
                } else {
                    console.warn("[Weather] Location fetch failed:", xhr.status);
                    root.city = "Unknown";
                }
            }
        };
        xhr.open("GET", "http://ip-api.com/json");
        xhr.send();
    }

    function fetchWeather(lat, lon) {
        // Added &daily parameters for forecast and UV
        // Added &timezone=auto to ensure daily breakdown matches local time
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current=temperature_2m,is_day,weather_code,relative_humidity_2m,wind_speed_10m,surface_pressure" + "&daily=weather_code,temperature_2m_max,temperature_2m_min,uv_index_max" + "&timezone=auto&temperature_unit=celsius&wind_speed_unit=kmh";
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        // 1. Current Weather
                        var current = response.current;
                        root.temperature = Math.round(current.temperature_2m) + "°";
                        root.isDay = current.is_day === 1;
                        root.humidity = current.relative_humidity_2m + "%";
                        root.wind = current.wind_speed_10m + " km/h";
                        root.pressure = Math.round(current.surface_pressure) + " hPa";
                        var code = current.weather_code;
                        var info = root._weatherCodes[code] || {
                            "day": "",
                            "night": "",
                            "desc": "Unknown"
                        };
                        root.icon = root.isDay ? info.day : info.night;
                        root.conditionText = info.desc;
                        // 2. Daily Data (UV & Forecast)
                        var daily = response.daily;
                        if (daily && daily.uv_index_max && daily.uv_index_max.length > 0)
                            root.uvIndex = daily.uv_index_max[0].toString();

                        // 3. Process Forecast (Next 5 days)
                        var newForecast = [];
                        // Start from index 1 (Tomorrow), loop for 5 days
                        for (var i = 1; i < 6; i++) {
                            // Always use day icon for forecast

                            if (!daily.time[i])
                                break;

                            var fCode = daily.weather_code[i];
                            var fInfo = root._weatherCodes[fCode] || {
                                "day": "",
                                "desc": "Unknown"
                            };
                            newForecast.push({
                                "day": getDayName(daily.time[i]),
                                "icon": fInfo.day,
                                "max": Math.round(daily.temperature_2m_max[i]) + "°",
                                "min": Math.round(daily.temperature_2m_min[i]) + "°",
                                "condition": fInfo.desc
                            });
                        }
                        root.forecastModel = newForecast;
                    } catch (e) {
                        console.warn("[Weather] Weather JSON parse error", e);
                    }
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }

    // Timer works because root is Item
    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.fetchLocation()
    }

}
