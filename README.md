# marketplace-miner

## Overview

The Taolie team has generated a docker build that makes deploying subnets easy. This docker repository is to support this work

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

To install you need to obtain a config.json file from a team member. This will be automated in the future. 
In addition to this you will require a seed.txt that contains the phrase of your coldkey. This belongs in ./seed.txt of the repository. 

This is an example of what the directory structure should be. 

```
├── Dockerfile
├── README.md
├── config.json
├── docker-compose.yaml
├── prereqs.sh
├── scripts
└── seed.txt
```


### Preparing the environment to run
The prereqs.sh script setups the nvidia container toolkit , and matches the cuda version with the container.

```
./prereqs.sh
docker compose build 
```

## Usage

To run the container, please ensure you have seed.txt, and config.json present. To expose the miner to the internet, by default docker compose opens up port 2121. If you need this changed, please change the docker compose and config.json 

**Note**: This example will change the default, and open up port 2122 on the host. 
```
    ports:
      - "2122:2121"
```

You will also need to update the config.json `axonExternalPort` to ensure it matches

### Running the Container

```
docker compose up -d
```
If you want to see the logs please run `docker compose logs -f`



### Volumes

This mounts the current users bittensor wallet directory in the container, along with a docker socket to support subnet27
- ./config.json:/config.json
- ~/.bittensor:/home/taolie/.bittensor
- taolie:/home/taolie/
- /var/run/docker.sock:/var/run/docker.sock
- ./seed.txt:/seed.txt


## Configuration