# Ethernet Demo and Adapter Setup
This demo consists of a TAP device "silkit_tap" which is connected to the SIL Kit via ``sil-kit-adapter-tap`` as a SIL Kit participant. In a second step this TAP device is moved to a Linux network name space and gets a IP configured which is in the same range as the one of the ``sil-kit-demo-ethernet-icmp-echo-device``. The Linux ping application is used within this created network namespace to ping ``sil-kit-demo-ethernet-icmp-echo-device`` through the TAP device via SIL Kit. The application ``sil-kit-demo-ethernet-icmp-echo-device``, which is a SIL Kit participant as well, will reply to an ARP request and respond to ICMPv4 echo requests. 

The following sketch shows the general setup: 

    +-----[ Ping from NetNs ]----+                                               +------[ SIL Kit Adapter TAP ]------+
    |  silkit_tap added to NetNs | <= ----------- silkit_tap -------------   =>  |  TapConnection to silkit_tap      |
    |   <=> ping / response      |                                               |     <=> virtual (SIL Kit) Eth1    |
    +----------------------------+                                               +-----------------------------------+
                                                                                             <=>
                                                                                           SIL Kit
                                                                                             <=>                 
    +--[ SilKitDemoEthernetIcmpEchoDevice ]--+                                +-------[ SIL Kit Registry ]--------+
    |                                        | <= ------- SIL Kit -------- => |                                   |
    +----------------------------------------+                                |                                   |
                                                                              |                                   |
    +------------[ Vector CANoe ]------------+                                |                                   |
    |                                        | <= ------- SIL Kit -------- => |                                   |
    +----------------------------------------+                                +-----------------------------------+
  

## sil-kit-demo-ethernet-icmp-echo-device
This demo application implements a very simple SIL Kit participant with a single simulated ethernet controller.
The application will reply to an ARP request and respond to ICMPv4 Echo Requests directed to it's hardcoded MAC address
(``52:54:56:53:4B:55``) and IPv4 address (``192.168.7.35``).

# Running the Demos

## Running the Demo Applications

Now is a good point to start the ``sil-kit-registry``, the ``sil-kit-demo-ethernet-icmp-echo-device`` and the demo helper script ``start_adapter_and_ping_demo`` - which creates the TAP device, connects it to the adapter and afterwards adds it to the network namespace and starts pinging the echos device from there - in separate terminals:

    /path/to/SilKit-x.y.z-$platform/SilKit/bin/sil-kit-registry --listen-uri 'silkit://0.0.0.0:8501'
        
    ./bin/sil-kit-demo-ethernet-icmp-echo-device --log Debug

    sudo ./tap/demos/DemoLinux/start_adapter_and_ping_demo.sh
    
The applications will produce output when they send and receive Ethernet frames from the TAP device or the Vector SIL Kit. The console output of ``sil-kit-adapter-tap`` is redirected to ``./bin/sil-kit-adapter-tap.out``.

## ICMP Ping and Pong
The ping requests should all receive responses.
    
You should see output similar to the following from the ``sil-kit-demo-ethernet-icmp-echo-device`` application:

    [date time] [EthernetDevice] [debug] SIL Kit >> Demo: Ethernet frame (98 bytes)
    [date time] [EthernetDevice] [debug] EthernetHeader(destination=EthernetAddress(52:54:56:53:4b:55),source=EthernetAddress(9a:97:c4:83:d8:d0),etherType=EtherType::Ip4)
    [date time] [EthernetDevice] [debug] Ip4Header(totalLength=84,identification=21689,dontFragment=1,moreFragments=0,fragmentOffset=0,timeToLive=64,protocol=Ip4Protocol::ICMP,checksum=22138,sourceAddress=192.168.7.2,destinationAddress=192.168.7.35) + 64 bytes payload
    [date time] [EthernetDevice] [debug] Icmp4Header(type=Icmp4Type::EchoRequest,code=,checksum=47730) + 60 bytes payload
    [date time] [EthernetDevice] [debug] Reply: EthernetHeader(destination=EthernetAddress(9a:97:c4:83:d8:d0),source=EthernetAddress(52:54:56:53:4b:55),etherType=EtherType::Ip4)
    [date time] [EthernetDevice] [debug] Reply: Ip4Header(totalLength=84,identification=21689,dontFragment=1,moreFragments=0,fragmentOffset=0,timeToLive=64,protocol=Ip4Protocol::ICMP,checksum=22138,sourceAddress=192.168.7.35,destinationAddress=192.168.7.2)
    [date time] [EthernetDevice] [debug] Reply: Icmp4Header(type=Icmp4Type::EchoReply,code=,checksum=47730)
    [date time] [EthernetDevice] [debug] SIL Kit >> Demo: ACK for ETH Message with transmitId=3
    [date time] [EthernetDevice] [debug] Demo >> SIL Kit: Ethernet frame (98 bytes, txId=3)

## Adding CANoe (17 SP3 or newer) as a participant
If CANoe is connected to the SIL Kit, all ethernet traffic is visible there as well. You can also execute a test unit which checks if the ICMP Ping and Pong is happening as expected.

Before you can connect CANoe to the SIL Kit network you should adapt the ``RegistryUri`` in ``tap/demos/SilKitConfig_CANoe.silkit.yaml`` to the IP address of your system where your sil-kit-registry is running (in case of a WSL2 Ubuntu image e.g. the IP address of Eth0). The configuration file is referenced by both following CANoe use cases (Desktop Edition and Server Edition).

### CANoe Desktop Edition
Load the ``Tap_adapter_CANoe.cfg`` from the ``tap/demos/CANoe`` directory and start the measurement. Optionally you can also start the test unit execution of included test configuration. While the demo is running these tests should be successful.

### CANoe4SW Server Edition (Windows)
You can also run the same test set with ``CANoe4SW SE`` by executing the following PowerShell script ``tap/demos/CANoe4SW_SE/run.ps1``. The test cases are executed automatically and you should see a short test report in PowerShell after execution.

### CANoe4SW Server Edition (Linux)
You can also run the same test set with ``CANoe4SW SE (Linux)``. At first you have to execute the PowerShell script ``tap/demos/CANoe4SW_SE/createEnvForLinux.ps1`` on your Windows system by using tools of ``CANoe4SW SE (Windows)`` to prepare your test environment for Linux. In ``tap/demos/CANoe4SW_SE/run.sh`` you should adapt ``canoe4sw_se_install_dir`` to the path of your ``CANoe4SW SE`` installation in your WSL2. Afterwards you can execute ``tap/demos/CANoe4SW_SE/run.sh`` in your WSL2. The test cases are executed automatically and you should see a short test report in your terminal after execution.

## Running the demo applications inside a Docker container (Optional)
*Note: This section provides an alternative method for running the demo applications - apart from CANoe Desktop Edition and CANoe4SW Server Edition - inside a Docker container and using the `devcontainers` Visual Studio Code extension. The steps outlined here are optional and not required if you prefer to run the applications directly and manually on your host machine.*

The following tools are needed:
* Visual Studio Code in Windows
* WSL2 with Docker running as a daemon. You will need the *ms-vscode-remote.remote-wsl* Visual Studio Code Extension to connect your Visual Studio Code instance to WSL2.  
    >Alternatively, if you prefer to use a Linux Virtual Machine as a remote host, you can use the *ms-vscode-remote.remote-ssh* Visual Studio Code extension to connect your Visual Studio Code instance to it.    
* *ms-vscode-remote.remote-containers* Visual Studio Code extension

>In WSL2, it is advisable to use the native filesystem (such as `/home/`) rather than the mounted `/mnt/` filesystem to prevent any performance issues.

### Steps:
Clone the repo and open it with Visual Studio Code. A pop-up will appear and propose to open the project in a container.

![Dev Containers popup](images/dev-container-popup.png)

Alternatively, you can click on the Dev Containers button at the bottom-left corner of Visual Studio Code, then click on `Reopen in Container`. 

Wait for the Docker image to be built and for the container to start. After that, you can launch the available pre-defined tasks to acheive the demo setup. 

> The Docker container exposes the TCP/IP port 8501 to the host, which means that adding CANoe as a participant in the following steps shall work out-of-the box if you set SIL Kit's registry-uri to `silkit://localhost:8501`.  
