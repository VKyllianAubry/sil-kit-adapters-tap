#!/bin/bash
echo "Setting up network bridge for QEMU images..."
ip tuntap add dev tap10 mode tap
ethtool -K eth0 tx off
ethtool -K tap10 tx off
# create bridge network in Linux
sudo brctl addbr br10

# Add tap interfaces from QEMU RichOS (qemu_richos) and QEMU QNX (qemu_qnx) into the bridge
sudo brctl addif br10 qemu_demo_tap
sudo brctl addif br10 tap10

# Activate the bridge and interfaces
sudo ip link set br10 up
sudo ip link set qemu_demo_tap up
sudo ip link set tap10 up
