# !/bin/bash
# Shell Script stromzaehler.sh
# The values are send to Home Assistant and InfluxDB trough RESTapi
# Smart Meter Lesekopf0: Logarex LK13BD

### Setup Server Homeassistant ###
server_ha="http://localhost:8123"
token_ha="<TOKEN>"

### Setup Server InfluxDB ###
server_influxdb="http://localhost:8086"
token_influxdb="<PASSWORD>"
user_influxdb="<USER>"

# cut necessary values
cutValue() {
    value=$(echo $1 | cut -d'(' -f 2 | cut -d'*' -f 1)
    value=$(echo $value | sed 's/^0*//')
    if [ "$value" = ".0000" ]; then
        value="0.0"
    fi
}

postUpdate() {
    # Build JSON output
    data='{ "state":'"$value"',"attributes":{"device_class":"energy","unit_of_measurement":"KW/h","friendly_name":"Zählerstand" }}'

    # Publish to HA with token
    curl -X POST -H "Authorization: Bearer $token_ha" \
        -H "Content-Type: application/json" \
        -d "$data" \
        $server_ha/api/states/sensor.zahlerstand

    # Publish to InfuxDB
    curl -i -XPOST "$server_influxdb/write?db=stromzaehler" \
        -H "Authorization: Token $user_influxdb:$token_influxdb" \
        --data-binary "stromzaehler,measurement=KW/h,month=$(date +"%m"),year=$(date +"%Y"),week=$(date +"%W") value=${value}"
}

# Collect data
readLesekopf0() {
    stty -F /dev/ttyUSB0 300 -parodd cs7 -cstopb parenb -ixoff -crtscts -hupcl -ixon -opost -onlcr -isig -icanon -iexten -echo -echoe -echoctl -echoke
    sleep 1

    tmpfile=/tmp/ttyDump1.data

    # open Serial Port
    cat /dev/ttyUSB0 >$tmpfile &
    PID=$!
    sleep 1
    /bin/echo -e "\x2F\x3F\x21\x0D\x0A" >/dev/ttyUSB0 #Send WAKEUP
    sleep 1
    /bin/echo -e "\x06\x30\x30\x30\x0D\x0A" >/dev/ttyUSB0 #Send DATA REQUEST
    sleep 11
    kill $PID
    # close Serial Port

    while read p; do
        case "$p" in
        *"1.8.0"*)
            cutValue $p
            postUpdate $value
            ;;
        *) ;;

        esac
    done <$tmpfile
}

# call readouts
readLesekopf0 &
# wait until returned
wait %1

exit
