#!/bin/bash
CONFIG=/config.json
source  <(jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" $CONFIG | sed 's/^/export\ /g')
# This is a rather large package that hashcat requires


#curl -o /tmp/cuda.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && dpkg -i /tmp/cuda.deb
#echo "Installing cuda-toolkit-${cudaVersion}. This takes some time. "
#apt update &> /dev/null && apt-get -y install "cuda-toolkit-${cudaVersion}" &> /dev/null
#echo "Finished installed cuda-toolkit"


#AMD ...
CPU=`grep vendor_id /proc/cpuinfo | head -n1 | cut -d: -f2 | sed -re 's/^[ \t]+//g'`


if [ "$CPU" == 'AuthenticAMD' ]; then
  echo "Detected AMD"
  echo "Removing libpocl"
  apt remove libpocl2-common libpocl2 -y
fi


echo "Waiting for connection loop"

((count = 10))                           # Maximum number to try.
established=false
while [[ $count -ne 0 ]] ; do
    echo "Trying to ping $count"
    ping -c 1 -W1 10.8.0.1 1> /dev/null 2>&1
    rc=$?
    if [[ $rc -eq 0 ]] ; then
        ((count = 1))                    # If okay, flag loop exit.
	established=true
    else
        sleep 1                          # Minimise network storm.
    fi
    ((count = count - 1))                # So we don't go forever.
done

# If it reaches here. It did not work
if [ $established == 'false' ]; then
  echo "VPN Connection Failed"
  # We grab the previous setup script in case we loose connectivity. 
  if [ -e /home/taolie/previous.sh ]; then
    su - taolie -c "bash /home/taolie/previous.sh"
  fi
  exit 1
fi

echo "Connection has been established"
echo "Welcome to Taolie"
cat << EOF
                                   .:.      .:....:::::::::::::::::::::----:::::--------::
      .....:::::::::-:::-:::----:--:--:---:----=:--=---==-===----=-+-=++==+=++++++=====*+-+++=-:
   .:::::-:::--=::-=-:---=-++===-=-+-==---=--==+=+-+=+==-=+*=====##==+*=+=*+++++++**+*######%##*+:
  ::---==-===*+===-=+=-=++##+===+==-+======++===*=+-=+=+*=+*+++=+#++*#*+++*++++=*=++*####%%%%%%#%#=
 ::-===+=+*+++=++=======+*#++**+=-+++**++*#*===++==*#%%*+**+++*##++****+++***++***+*#**++%%%%%@%%%+
::-=-+--=+==+++++++***+++**+****+*-==++=#*=+=***=*+++**+*###*+*+*#+*#*+++*#*+**+*+++##%+%##@@@@%%%+
::==-=+--=-+**+++==+++++***#=-+#%%*++=+++*+-*##=##=*##=::=#%%%**##*+*#+++***+**++**#*##%%%@@%@@@@#+
::--+==-=++=+**=+--+**+++*=..:-%@@@#=+-==+=##*+#*+***-..:-@@@@@*=+*#%#+=+**+**+=******%##%%@@@@@@%+
 :--=+=+===+++=**=-+**+=+++::-%@@@@@*=##=*#=+##**+=*#*--=%@@@@@%******+++**=+#++***##*###%@@@@@@@%*
.::-=+*=-===+-+===+*+++=+#@@@@@@@@@@*****#*==+=+#*=+%@@@@@@@@@@@**#%*=++****%#*###**##**#%@@@@@@%%+
:::-+=+*==++=-===***+++++#%****##@@#**+**+++*++##+=**%#**###%@@%***+**++*####**+*#*++*#%#%%@@@@@@%#*
::=*#*==-=++===+=++*+******%%%%@@@#**=*%=*+++++++**+*#%%%%@@@@%#*+=+**#%%+*@++*+*%##*=##*%@@@@@@@%+
:-=-=-=++---==****#=*+=+****+*###*****++#+-=+#+*****##+*#%%%%*#+*+=++=*#***+=+#%*#**+*##%%%@%@@@%#+
:--==+#+=-+#==+**++++*#*++**==++*#%%**##*+==****#*%#*==++**++=#*=**+=#+=##+++#%#+**+####@@@@%@@@%#*
 :-=++++=+%***#**+*+*#+****-=+****%@=%#+#+=**=*##%@+#*=+++*=+#+***+*++*+=+*+*%+*+*%*##*%%@@@@%@@%%+
  -+=+=*+=**#**#######*#%*#=*#+#***%*=*#*=**+*##%*-#%==++++*#%*=#*+**+##***+#*####%*+#%#@@@@@@@@%%+
  --+########%#%%%%*###%#%#=++=+***###*--+*##*=-=#%%=-=+*+*#*++%%%###%%%#*######%#####%%%%%@%@%%%*
      +*#**##%%%%%%%%%%%%%#==++*+*+==+*#%%%#%%%@@#=====+***#+*%@@@@@@@%%%%%%%%%%%%%%#%%%%##%%##*
                          :=++**++*+=*+=+++***+*+*=++==++#+*#%%@@@@@@@@@%*
                          :-=++*==++**##+===---+****+==+*=#**#%%@@@@@@@@#*
                           +++*=++#+++=*++===++##+=+=+*=+++#**#%@@@@@@@@#+
                          -+*###*******=++**+*+*#++*+***+**##%%%@@@@@@%%%#
                          -=+==+*##*****#+*++++**########%%%%%%%@@@@@@@%%*
                         ==+=-=%@@%%=--*##*%**-=-*#*+=::.++%###%%%%%%%@%#*
                       -=+++=-*#@#%@%%-%@@##*+=-%%#%%@%#-+@@%##%#%#%@%%@%+
                     :-=+**+=#%##-:#@@*#@@#**+=%@%%#*%@%%*@@%%%#%#%#@%####+=
                   =-=+**#*==#@%=---@@@#@###++=#@%*=--%@@#%@@%%%*%@####*##*#+
                  +++***###==-=@*#%@%#=%@@%**#=*#%#--*@@%#%@@%%%%%###*##*%#***+
               ::-*#**###%#+===##*#%++-%@@%#++=-%*%@#@#=+*@@@@@%@##*###%###%##*+=
               :-=+#####%%%*==**=++===***-:-+*-=-*#+%=#-=*@@@@@@@##%#@##*###*##%#+
              :-+++##%%%%@@%+*#%%%%%%%+=###*:*%%*%%#@%%#*#@@@@@@@%##%%*#**##+*****=
            .:-=+=+**%%@@@@@**#**=##%**+##*##*#@@@%##%%%%@@@@@@@@@@#%#**++===**#%#*+
           :-==++*#####@@@@@+*+#*=**#+*+:-===#*%@%%%**%#*#%@@@@@@@@%#*+==+==**##+%%#*
          :-=+++*####%%%%%% +*#*#%##%*+#####*##@@@%%%%%**#%%@@@@@@@@#-==-=#****%#%%%#
          -++*+**#%%%%%%%* =+=--++++*+*+####*#%@@@%%%##*#%%@@@@@@@@@#+=+**=****+#%*%#=
          ==+***##%%%%%%=  =*=-#%#%%%==+@%%%@@#######%#***###%%@@@@@%*++*++=#++*#*%%%*
          =+*+*#####%%%#   +*+%@##%@@@*=@@%%%@---%@@%%=-+*+%@@@@@@@@@%*=++=++**####%%#
           =**####%%%%#+  :-**+#%=--#@@#@@#=++-*#%%#%@%#:%@@@@@@@@@@@@*=-*++*#%###%%%#*
             **##%#%#*    :===%*@=--#@@%@@%*#*-%##*--#@@*%@@@%%%@@@%%%*=++*##+*##%%%%%+
                 +        -=+=+@*@##@%#+@%##%#-@@#----@@@%@%#****#%%%%%**+*###%%%%%@%+
                          -=+===*%*%#=-+@%##%%-++%%#%@%#+%@%#*##*%%%%%%@#**##%%%%%%#+
                          :=++**####++=*@%##%%==+**##%++:%@%#*%%%%%%%%%%%+ *#####*=
                          -=*#*##%%%%#*++#@@@@%*++-----=+%%%#**%%#%%%%%%%*
                          -=+++*%#**#%##%%@@@@@@*#***+++++@%##%%%%%%%%%%%*
                          ==+*#******#*###%%@@@%++*#*%######*#**##%@%%%%%*
                          :=+++***#####**##%@@@@++=**+#*#***#*#%%%%%%%%%%*
                           =+*#**+*#**#*#%%%@@@%++=***#*+***#**#*%%%%%%%%*
                           =*++**#***##***%%%@@#=+*+##***#**++**%%%%%%%%%*
                           -+*##******#%#*#%%@@#+#++*+#+**+*%%%%%%%%%%%%%+
                             +##%###*###*%%@@@@@+++********#**%%%%%%%@@%
                                 =*#%%%%%%%*     +*#########*#%%%%@@@@#
                                                    +##%%%@%@@@@@%+
EOF
# They should see the logo
sleep 1

echo "Downloading Subnet $netuid" 
su - taolie -c "curl http://10.8.0.1/subnet/$netuid/start.ryan | tee /home/taolie/previous.sh | bash"
