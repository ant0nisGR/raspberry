#!/bin/sh
: <<'COMMENT'
# To dokimasa se raspberry pi 4 me bookworm 64bit kai doylepse kanonika
#Ean xrisimopoiis to rtl sdr v4, xreiazetai na egkatastiseis tous sostous drivers (https://www.rtl-sdr.com/v4/)

Linux (Debian)

On Linux the procedure is also simple quite simple and just involves removing any existing RTL-SDR drivers, and installing our version.

    Purge the previous driver:

    sudo apt purge ^librtlsdr
    sudo rm -rvf /usr/lib/librtlsdr* /usr/include/rtl-sdr* /usr/local/lib/librtlsdr* /usr/local/include/rtl-sdr* /usr/local/include/rtl_* /usr/local/bin/rtl_* 

    Install the RTL-SDR Blog drivers:

    sudo apt-get install libusb-1.0-0-dev git cmake pkg-config
    git clone https://github.com/rtlsdrblog/rtl-sdr-blog
    cd rtl-sdr-blog
    mkdir build
    cd build
    cmake ../ -DINSTALL_UDEV_RULES=ON
    make
    sudo make install
    sudo cp ../rtl-sdr.rules /etc/udev/rules.d/
    sudo ldconfig

    Blacklist the DVB-T TV drivers.

    echo 'blacklist dvb_usb_rtl28xxu' | sudo tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf

    Reboot
COMMENT

set -e

[ $(id -u) = 0 ] && echo "Please do not run this script as root" && exit 100

echo "Installing dependencies"
sudo apt update
sudo apt install -y build-essential cmake git libfftw3-dev libglfw3-dev libglew-dev libvolk2-dev libzstd-dev libsoapysdr-dev libairspyhf-dev libairspy-dev \
            libiio-dev libad9361-dev librtaudio-dev libhackrf-dev librtlsdr-dev libbladerf-dev liblimesuite-dev p7zip-full wget

cd ~            
mkdir -p git && cd git
git clone https://github.com/AlexandreRouma/SDRPlusPlus
cd SDRPlusPlus            

echo "Preparing build"
sudo mkdir -p build/CMakeFiles
cd build

sudo cmake .. -DOPT_BUILD_RTL_SDR_SOURCE=ON

echo "Building"
sudo make

echo "Installing"
sudo make install

echo "Done!"

### modded by TekMaker 26/3/2022

: <<'COMMENT'
Create a service file to automatically start the sdrpp server

sudo vim /etc/systemd/system/sdrpp-server.service

[Unit]
Description=SDRpp server
After=multi-user.target

[Service]
Type=simple
Restart=always
RestartSec=20
User=pi
WorkingDirectory=/usr/bin
ExecStart=sdrpp -s

[Install]
WantedBy=multi-user.target

sudo systemctl enable sdrpp-server
sudo systemctl start sdrpp-server

COMMENT

