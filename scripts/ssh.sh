#!/bin/bash
# Redirect SSH output to a file
exec > /tmp/ssh.out 2>&1


# This is for the SSH configuration
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -b 2048 -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key -q
fi

echo "Adding taolie user"


useradd -m -s /bin/bash ${user}

# If the host has docker then create a group called hostDocker, and assign the proper GID to it
if [ -e /var/run/docker.sock ]; then
  echo "Creating a group for docker"
  
  # The below will fail if the group is the same id. Ubuntu on Ubuntu
  usermod -a -G docker $user

  hostDocker=`stat -c %g /var/run/docker.sock`
  echo "Detected $hostDocker as the ID for the host machine"
  groupadd -g $hostDocker hostdocker
  usermod -a -G hostdocker $user
fi

mkdir /home/$user/.ssh
chmod 700 /home/$user/.ssh/
echo "$SSH_PUBLIC_KEY" > /home/$user/.ssh/authorized_keys
echo 'source /opt/conda/bin/activate' > /home/$user/.profile
echo 'export PATH=$PATH:~/.local/bin' >> /home/$user/.profile

# Change the permissions of the directory as this runs as root
chown -R $user:$user /home/$user/


/usr/sbin/sshd -De
