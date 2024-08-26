# Install docker
export DOCKER=`dpkg --get-selections docker-ce`
if [ -z "$DOCKER" ]; then
  curl -fsSL https://get.docker.com | bash
fi

# This script requires jq
export JQ=`dpkg --get-selections | egrep jq -w`
if [ -z "$JQ" ]; then
  echo "Installing jq"
  sudo apt install jq -y 
fi

export VERSION=`dpkg --get-selections | egrep cuda-toolkit-[0-9\-]+ | awk '{print $1}' | head -n1 | sed -re 's/cuda-toolkit-([0-9\-]+)/\1/g'`
if [ -z $VERSION ]; then 
  echo "I could not detect cuda-toolkit"
  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
  sudo dpkg -i cuda-keyring_1.1-1_all.deb
  rm cuda-keyring_1.1-1_all.deb
  sudo apt-get update && apt-get -y install cuda-toolkit-12-5
  
  #The recommended version is 12.5.
  VERSION='12-5'
  jq '.cudaVersion = env.VERSION' config.json > .config.json; cat .config.json > config.json; rm .config.json
else
  echo "modifying config.json for cuda version $VERSION"
  jq '.cudaVersion = env.VERSION' config.json > .config.json; cat .config.json > config.json; rm .config.json
fi

# NVIDIA Container Toolkit
TOOLKIT=`dpkg --get-selections  | grep nvidia-container-toolkit`

if [ -z "$TOOLKIT" ] ; then
  echo "Could not find the nvidia container toolkit. I will install it "
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  sudo apt-get update && apt install nvidia-container-toolkit -y
  echo "Configuring nvidia and docker"
  sudo nvidia-ctk runtime configure --runtime=docker

  echo "Restarting Docker"
  sudo systemctl restart docker
fi

