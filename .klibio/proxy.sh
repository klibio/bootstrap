#!/bin/bash
if [[ ${debug:-false} == true ]]; then
  set -o xtrace   # activate bash debug
fi

###########################################################
# proxy configuration
###########################################################

# Function to check if a proxy PAC file is being used in Windows
configure_proxy() {
    if [ "$proxy_pac_executed" ]; then
        echo "proxy evaluation already executed - using $https_proxy"
    else
        # evaluate proxy settings
        unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

        reg_key="HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        reg_value="AutoConfigURL"

        # Read the value of AutoConfigURL from the Windows Registry (mind // for win bash)
        proxy_pac_url=$(reg query "$reg_key" //v "$reg_value" 2> /dev/null | awk -F ' ' '/REG_SZ/ {print $NF}')

        # Check if AutoConfigURL value exists and is not empty
        if [[ -n $proxy_pac_url ]]; then
            echo "proxy.pac file is configured - url: $proxy_pac_url"
#            return 0
        else
            echo "NO proxy.pac file is found - no proxy configured"
            return 1
        fi
        parse_proxy_entries "$proxy_pac_url"
    fi
}

# Function to test internet connectivity
test_connectivity() {
    proxy=$1
    timeout=2
    http_connected=false
    https_connected=false
    echo -ne "check internet connectivity via proxy $proxy "
    echo -ne "# http"
    curl -L --proxy $proxy --max-time $timeout http://www.google.com &> /dev/null
    if [[ $? == 0 ]]; then
        http_connected=true
        echo -ne " - OK "
    else
        echo -ne " - FAILED "
    fi
    if [[ "$http_connected" == "true" ]]; then
        echo -ne "# https"
        curl -L --proxy $proxy --max-time $timeout https://www.google.com &> /dev/null
        if [[ $? == 0 ]]; then
            https_connected=true
            echo -e " - OK"
        else
            echo -e " - FAILED"
        fi
    else
        echo -e ""
    fi

    if [[ "$http_connected" == "true" ]] && [[ "$https_connected" == "true" ]]; then
        echo "configuring shell http_proxy / https_proxy / HTTPS_PROXY $proxy"
        export http_proxy=$proxy
        export https_proxy=$proxy
        export HTTPS_PROXY=$proxy
        case $proxy in
            (*:*) proxyHost=${proxy%:*} proxyPort=${proxy##*:};;
            (*)   proxyHost=$1          proxyPort=3128;;
        esac
        export proxy_mvn_activate=true
        export "proxyHost=${proxyHost}"
        export "proxyPort=${proxyPort}"

        echo "exporting    ANT_OPTS=\"-Dhttp.proxyHost=$proxyHost -Dhttp.proxyPort=$proxyPort -Dhttps.proxyHost=$proxyHost -Dhttps.proxyPort=$proxyPort\""
        export ANT_OPTS="-Dhttp.proxyHost=$proxyHost -Dhttp.proxyPort=$proxyPort -Dhttps.proxyHost=$proxyHost -Dhttps.proxyPort=$proxyPort"
        echo "exporting  MAVEN_OPTS=\"-Dhttp.proxyHost=$proxyHost -Dhttp.proxyPort=$proxyPort -Dhttps.proxyHost=$proxyHost -Dhttps.proxyPort=$proxyPort\""
        export MAVEN_OPTS="-Dhttp.proxyHost=$proxyHost -Dhttp.proxyPort=$proxyPort -Dhttps.proxyHost=$proxyHost -Dhttps.proxyPort=$proxyPort"
        echo "exporting GRADLE_OPTS=\"-Dhttp.proxyHost=$proxyHost -Dhttp.proxyPort=$proxyPort -Dhttps.proxyHost=$proxyHost -Dhttps.proxyPort=$proxyPort\""
        export GRADLE_OPTS="-Dhttp.proxyHost=$proxyHost -Dhttp.proxyPort=$proxyPort -Dhttps.proxyHost=$proxyHost -Dhttps.proxyPort=$proxyPort"

        env | sort | grep proxy
        return 0
    else 
        export proxy_mvn_activate=false
    fi
    return 1
}

# Function to parse proxy entries from an URL using curl and return them as an array
parse_proxy_entries() {
    url="$1"

    # Download the proxy PAC file using curl
    echo "Downloading proxy PAC file from: $url"
    pac_file=$(mktemp)
    if ! curl -s "$url" -o "$pac_file"; then
        echo "Failed to download the proxy PAC file."
        return 1
    fi

    # Extract proxy entries from the PAC file
    proxy_entries=$(grep -Eo 'PROXY [^;]+' "$pac_file" | sed 's/PROXY //' | sed 's/"//')

    # Check if proxy entries are found
    if [[ -n $proxy_entries ]]; then
        # Convert proxy entries to an array
        IFS=$'\n' read -r -d '' -a proxy_array <<< "$proxy_entries"
        for proxy in "${proxy_array[@]}"; do
            if test_connectivity "$proxy" ; then
                echo "found and configured working proxy $proxy"
                export proxy_pac_executed=true
                return 0
            fi
        done
        echo "No proxy with working internet connection found."
    else
        echo "No proxy entries found in the PAC file."
    fi

    # Clean up the temporary PAC file
    rm -f "$pac_file"
}

# configure_proxy
configure_proxy
