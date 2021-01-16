# Shell-script-energy-consumption-Logarex
Measering energy consumption from Logarex with Weidmann IR-reading-head.

With this shell script, the data of the Logarex LK13BD electricity-meter can be recorded and passed on to the Homeassistant and optionally InfluxDB for processing.
By default, the Logarex electricity meter only sends the current meter reading. In this respect, the script is structured in such a way that it only requests this data.
The Weidmann IR-reading-head is connected to the USB interface of a Raspberry PI.
Homeassistant and optionally InfluxDB are also installed on the Raspberry PI. However, other servers are also possible here, as the data is passed on via RestAPI.

Make sure that the Weidmann IR-reading-head receives data from the Logarex-meter. Weidmann provides a diagnostic tool for Mac and Windows for this purpose.

Adapt the shell script to your requirements. Above you enter the required data of the server. A token is required for connecting to Homeassistant.
If the interface to InfluxDB is not required uncommand the responsible code.

Create a folder 'scripts‘ in the 'config' directory of Homeassistant and copy the shell script into this folder.

Add additional code to the configuration.yaml for using the shell command.

Create an automation so that the script is started periodically, e.g. every 15 minutes.

When the script starts, the 'sensor.zahlerstand‘ is automatically generated in Homeassistant. The sensor contains the data of the electricity meter.
This sensor can be used to visualize the data in the Homeassistant dashboard.

Optionally, the data can also be visualized in Grafana via InfluxDB.
