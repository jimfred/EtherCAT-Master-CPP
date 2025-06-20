#include <iostream>
#include <windows.h>
#include <conio.h>
#include <TcAdsDef.h>
#include <TcAdsApi.h>
#include <vector>
#include <string>

#pragma comment(lib, "TcAdsDll.lib")

// EtherCAT state definitions
enum EtherCATState {
    EC_STATE_INIT    = 0x01,
    EC_STATE_PREOP   = 0x02,
    EC_STATE_SAFEOP  = 0x04,
    EC_STATE_OP      = 0x08
};

// TwinCAT system states
enum TwinCATState {
    ADSSTATE_INVALID     = 0,
    ADSSTATE_IDLE        = 1,
    ADSSTATE_RESET       = 2,
    ADSSTATE_INIT        = 3,
    ADSSTATE_START       = 4,
    ADSSTATE_RUN         = 5,
    ADSSTATE_STOP        = 6
};

class EtherCATStateMaster {
private:
    long m_nPort;
    AmsAddr m_Addr;
    bool m_bConnected;
    
    // EtherCAT Master port (different from PLC port)
    AmsAddr m_EcMasterAddr;
    
public:
    EtherCATStateMaster() : m_nPort(0), m_bConnected(false) {
        // Initialize AMS address for PLC connection
        m_Addr.netId.b[0] = 127;
        m_Addr.netId.b[1] = 0;
        m_Addr.netId.b[2] = 0;
        m_Addr.netId.b[3] = 1;
        m_Addr.netId.b[4] = 1;
        m_Addr.netId.b[5] = 1;
        m_Addr.port = 851; // PLC runtime port
        
        // Initialize EtherCAT Master address
        m_EcMasterAddr = m_Addr;
        m_EcMasterAddr.port = 500; // EtherCAT Master port
    }

    ~EtherCATStateMaster() {
        Disconnect();
    }

    bool Connect() {
        // Open communication port
        m_nPort = AdsPortOpen();
        if (m_nPort == 0) {
            std::cerr << "Error: Failed to open ADS port!" << std::endl;
            return false;
        }

        // Test connection by reading ADS state
        unsigned short nAdsState;
        unsigned short nDeviceState;
        long nErr = AdsSyncReadStateReq(&m_Addr, &nAdsState, &nDeviceState);
        
        if (nErr) {
            std::cerr << "Error: ADS connection failed! Error code: 0x" 
                      << std::hex << nErr << std::endl;
            AdsPortClose();
            return false;
        }

        m_bConnected = true;
        std::cout << "Successfully connected to TwinCAT!" << std::endl;
        std::cout << "TwinCAT State: " << GetTwinCATStateName(nAdsState) 
                  << " (" << nAdsState << ")" << std::endl;
        return true;
    }

    void Disconnect() {
        if (m_nPort != 0) {
            AdsPortClose();
            m_nPort = 0;
        }
        m_bConnected = false;
        std::cout << "Disconnected from TwinCAT." << std::endl;
    }

    std::string GetTwinCATStateName(unsigned short state) {
        switch (state) {
            case ADSSTATE_INVALID: return "INVALID";
            case ADSSTATE_IDLE:    return "IDLE";
            case ADSSTATE_RESET:   return "RESET";
            case ADSSTATE_INIT:    return "INIT";
            case ADSSTATE_START:   return "START";
            case ADSSTATE_RUN:     return "RUN";
            case ADSSTATE_STOP:    return "STOP";
            default:               return "UNKNOWN";
        }
    }

    std::string GetEtherCATStateName(unsigned char state) {
        switch (state) {
            case EC_STATE_INIT:   return "INIT";
            case EC_STATE_PREOP:  return "PREOP";
            case EC_STATE_SAFEOP: return "SAFEOP";
            case EC_STATE_OP:     return "OP";
            default:              return "UNKNOWN";
        }
    }

    bool SetTwinCATState(unsigned short targetState) {
        if (!m_bConnected) {
            std::cerr << "Error: Not connected to TwinCAT!" << std::endl;
            return false;
        }

        std::cout << "Setting TwinCAT state to: " << GetTwinCATStateName(targetState) << std::endl;
        
        long nErr = AdsSyncWriteControlReq(&m_Addr, targetState, 0, 0, nullptr);
        
        if (nErr) {
            std::cerr << "Error setting TwinCAT state: 0x" << std::hex << nErr << std::endl;
            return false;
        }

        // Wait for state change
        Sleep(1000);
        
        // Verify state change
        unsigned short currentState, deviceState;
        nErr = AdsSyncReadStateReq(&m_Addr, &currentState, &deviceState);
        
        if (nErr) {
            std::cerr << "Error reading TwinCAT state: 0x" << std::hex << nErr << std::endl;
            return false;
        }

        std::cout << "TwinCAT state is now: " << GetTwinCATStateName(currentState) << std::endl;
        return (currentState == targetState);
    }

    bool ReadEtherCATMasterState() {
        if (!m_bConnected) {
            std::cerr << "Error: Not connected to TwinCAT!" << std::endl;
            return false;
        }

        std::cout << "\n=== EtherCAT Master State Information ===" << std::endl;
        
        // Try to read EtherCAT master state
        // Index Group: 0x9000 (EtherCAT master)
        // Index Offset: 0x0000 (Master state)
        unsigned long masterState;
        unsigned long bytesRead;
        
        long nErr = AdsSyncReadReqEx2(m_nPort, &m_EcMasterAddr, 
                                      0x9000, 0x0000, 
                                      sizeof(masterState), &masterState, &bytesRead);
        
        if (nErr) {
            std::cout << "Cannot read EtherCAT master state directly (Error: 0x" 
                      << std::hex << nErr << ")" << std::endl;
            std::cout << "This is normal - EtherCAT state is managed by TwinCAT System Manager" << std::endl;
            return false;
        }

        std::cout << "EtherCAT Master State: 0x" << std::hex << masterState << std::endl;
        return true;
    }

    bool ReadEtherCATSlaveStates() {
        if (!m_bConnected) {
            std::cerr << "Error: Not connected to TwinCAT!" << std::endl;
            return false;
        }

        std::cout << "\n=== EtherCAT Slave States ===" << std::endl;
        
        // Try to read number of slaves
        unsigned short slaveCount;
        unsigned long bytesRead;
        
        long nErr = AdsSyncReadReqEx2(m_nPort, &m_EcMasterAddr, 
                                      0x9000, 0x0001, 
                                      sizeof(slaveCount), &slaveCount, &bytesRead);
        
        if (nErr) {
            std::cout << "Cannot read EtherCAT slave information directly" << std::endl;
            std::cout << "EtherCAT configuration is managed by TwinCAT System Manager" << std::endl;
            return false;
        }

        std::cout << "Number of EtherCAT slaves: " << slaveCount << std::endl;
        
        // Read individual slave states
        for (int i = 0; i < slaveCount && i < 10; i++) { // Limit to 10 slaves for demo
            unsigned char slaveState;
            nErr = AdsSyncReadReqEx2(m_nPort, &m_EcMasterAddr, 
                                     0x9000, 0x0010 + i, 
                                     sizeof(slaveState), &slaveState, &bytesRead);
            
            if (!nErr) {
                std::cout << "Slave " << i << " state: " 
                          << GetEtherCATStateName(slaveState) << std::endl;
            }
        }
        
        return true;
    }

    bool StartEtherCATSystem() {
        std::cout << "\n=== Starting EtherCAT System ===" << std::endl;
        
        // Step 1: Ensure TwinCAT is running
        unsigned short currentState, deviceState;
        long nErr = AdsSyncReadStateReq(&m_Addr, &currentState, &deviceState);
        
        if (nErr) {
            std::cerr << "Cannot read TwinCAT state!" << std::endl;
            return false;
        }

        std::cout << "Current TwinCAT state: " << GetTwinCATStateName(currentState) << std::endl;

        // Step 2: If not running, try to start TwinCAT
        if (currentState != ADSSTATE_RUN) {
            std::cout << "TwinCAT is not in RUN mode. Attempting to start..." << std::endl;
            
            if (!SetTwinCATState(ADSSTATE_RUN)) {
                std::cerr << "Failed to start TwinCAT!" << std::endl;
                std::cout << "\nTo manually start TwinCAT:" << std::endl;
                std::cout << "1. Open TwinCAT System Manager" << std::endl;
                std::cout << "2. Right-click on System" << std::endl;
                std::cout << "3. Select 'Set TwinCAT to Run Mode'" << std::endl;
                return false;
            }
        }

        // Step 3: Check if EtherCAT is operational
        std::cout << "\nChecking EtherCAT status..." << std::endl;
        ReadEtherCATMasterState();
        ReadEtherCATSlaveStates();

        return true;
    }

    void MonitorEtherCATStatus() {
        std::cout << "\n=== EtherCAT Status Monitor ===" << std::endl;
        std::cout << "Monitoring TwinCAT and EtherCAT status..." << std::endl;
        std::cout << "Press 'q' to quit, 's' to start system, 'r' to read status" << std::endl;

        char input = 0;
        int counter = 0;

        while (input != 'q') {
            if (counter % 10 == 0) { // Every 10 seconds, show status
                unsigned short adsState, deviceState;
                long nErr = AdsSyncReadStateReq(&m_Addr, &adsState, &deviceState);
                
                if (!nErr) {
                    std::cout << "\nCycle " << counter << " - TwinCAT State: " 
                              << GetTwinCATStateName(adsState) << std::endl;
                } else {
                    std::cout << "\nCycle " << counter << " - Connection lost!" << std::endl;
                }
            }

            Sleep(1000);
            counter++;

            // Check for user input
            if (_kbhit()) {
                input = _getch();
                
                switch (input) {
                    case 's':
                        StartEtherCATSystem();
                        break;
                    case 'r':
                        ReadEtherCATMasterState();
                        ReadEtherCATSlaveStates();
                        break;
                    case 'q':
                        break;
                    default:
                        std::cout << "Commands: 's'=start system, 'r'=read status, 'q'=quit" << std::endl;
                        break;
                }
            }
        }
    }

    void ShowEtherCATRequirements() {
        std::cout << "\n=== EtherCAT OP Mode Requirements ===" << std::endl;
        std::cout << "To reach EtherCAT OP mode, you need:" << std::endl;
        std::cout << "\n1. TwinCAT System Configuration:" << std::endl;
        std::cout << "   - EtherCAT Master configured in System Manager" << std::endl;
        std::cout << "   - Ethernet adapter assigned to EtherCAT" << std::endl;
        std::cout << "   - EtherCAT slaves scanned and configured" << std::endl;
        std::cout << "\n2. PLC Program:" << std::endl;
        std::cout << "   - PLC project with I/O mapping" << std::endl;
        std::cout << "   - Variables linked to EtherCAT I/O" << std::endl;
        std::cout << "   - Program compiled and downloaded" << std::endl;
        std::cout << "\n3. System Activation:" << std::endl;
        std::cout << "   - Activate Configuration in System Manager" << std::endl;
        std::cout << "   - Set TwinCAT to RUN mode" << std::endl;
        std::cout << "   - EtherCAT will automatically go to OP mode" << std::endl;
        std::cout << "\n4. This Application:" << std::endl;
        std::cout << "   - Connects via ADS to monitor/control" << std::endl;
        std::cout << "   - Can start/stop TwinCAT system" << std::endl;
        std::cout << "   - Monitors EtherCAT status through TwinCAT" << std::endl;
    }
};

int main() {
    std::cout << "=== EtherCAT State-Aware Master Application ===" << std::endl;
    std::cout << "TwinCAT3 C++ EtherCAT State Control Demo" << std::endl;
    std::cout << "===========================================" << std::endl;

    EtherCATStateMaster master;

    // Show requirements first
    master.ShowEtherCATRequirements();

    // Connect to TwinCAT
    if (!master.Connect()) {
        std::cerr << "Failed to connect to TwinCAT system!" << std::endl;
        std::cout << "\nMake sure:" << std::endl;
        std::cout << "1. TwinCAT3 is installed" << std::endl;
        std::cout << "2. TwinCAT System Service is running" << std::endl;
        std::cout << "3. You have administrator privileges" << std::endl;
        return -1;
    }

    // Try to start the EtherCAT system
    master.StartEtherCATSystem();

    // Monitor system status
    master.MonitorEtherCATStatus();

    std::cout << "\nShutting down EtherCAT State Master..." << std::endl;
    master.Disconnect();

    return 0;
}

