#!/bin/bash
################################################################################
################################################################################
function nsr_mount_verify () {
echo "################################################################################"
echo "[[ nsr_mount_verify ]]"
mountpoint /nsr
x=$?
if [[ $x -ne 0 ]]
then
        echo "NO EXCLUSIVE MOUNT POINT FOR /nsr DETECTED."
        echo "TERMINATING THE SCRIPT."
        exit 1
fi
mountpoint /nsr/res/jobsdb
x=$?
if [[ $x -ne 0 ]]
then
        echo "NO EXCLUSIVE MOUNT POINT FOR /nsr/res/jobsdb DETECTED."
        echo "CREATING /nsr/res/jobsdb"
        mkdir -p /nsr/res/jobsdb
        cat >> /etc/fstab <<EOF
tmpfs   /nsr/res/jobsdb tmpfs   defaults,size=1024M     1       2
EOF
        mount -a
else
        echo "Mount points /nsr and /nsr/res/jobsdb are verified"
fi
}
################################################################################
################################################################################
function networker_addrpms() {
  echo "################################################################################"
  echo "[[ networker_addrpms ]]"
  while [ "$(ps -ef | egrep -v grep | grep zypper | wc -l | awk '{print $1}')" -ne "0" ]; do
    sleep 5
  done
  zypper -qn in libcap2 libstdc++6 java-1_8_0-openjdk git net-tools-deprecated binutils bind-utils cron
  if [ "$(
    grep -q noelision /etc/ld.so.conf
    echo $?
  )" -ne "0" ]; then
    echo "/lib64/noelision" >>/etc/ld.so.conf
    /sbin/ldconfig
  fi
}
################################################################################
################################################################################
function networker_download() {
  echo "################################################################################"
  echo "[[ networker_download ]]"
  url="https://gcsbackuprepo001.blob.core.windows.net/networker/NW_PACKAGE.tar.gz?sp=r&st=2022-08-03T12:54:35Z&se=2023-08-03T20:54:35Z&spr=https&sv=2021-06-08&sr=b&sig=GnDRo2y9Ktx%2BkwUMdlcowix2JDE1x58qiHVgy6vfqlQ%3D"
echo $url
  mkdir -p /nsr/amoeba
  wget "$url" -k -O /nsr/amoeba/NW_PACKAGE.tar.gz
  x=$?
  if [[ $x -ne 0 ]]
  then
        echo "FAILED TO DOWNLOAD"
        echo "TERMINATING THE SCRIPT."
        exit 2
fi
  tar -xvf /nsr/amoeba/NW_PACKAGE.tar.gz -C /nsr/amoeba
  rm /nsr/amoeba/NW_PACKAGE.tar.gz
}
nsr_mount_verify
networker_addrpms
networker_download
