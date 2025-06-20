#include <iostream>
#include <windows.h>
#include <conio.h>
#include <TcAdsDef.h>
#include <TcAdsApi.h>

#pragma comment(lib, "TcAdsDll.lib")

class EtherCATMaster {
private:
    long m_nPort;
    AmsAddr m_Addr;
    bool m_bConnected;

public:
    EtherCATMaster() : m_nPort(0), m_bConnected(false) {
        // Initialize AMS address for local connection
        m_Addr.netId.b[0] = 127;
        m_Addr.netId.b[1] = 0;
        m_Addr.netId.b[2] = 0;
        m_Addr.netId.b[3] = 1;
        m_Addr.netId.b[4] = 1;
        m_Addr.netId.b[5] = 1;
        m_Addr.port = 851; // TwinCAT3 PLC port (AMSPORT_R0_PLC_TC3)
    }

    ~EtherCATMaster() {
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
        std::cout << "ADS State: " << nAdsState << ", Device State: " << nDeviceState << std::endl;
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

    bool ReadVariable(const std::string& variableName, void* pData, unsigned long nDataSize) {
        if (!m_bConnected) {
            std::cerr << "Error: Not connected to TwinCAT!" << std::endl;
            return false;
        }

        unsigned long nBytesRead;
        long nErr = AdsSyncReadReqEx2(m_nPort, &m_Addr, ADSIGRP_SYM_VALBYHND, 
                                      0, nDataSize, pData, &nBytesRead);
        
        if (nErr) {
            std::cerr << "Error reading variable '" << variableName 
                      << "': 0x" << std::hex << nErr << std::endl;
            return false;
        }

        return true;
    }

    bool WriteVariable(const std::string& variableName, void* pData, unsigned long nDataSize) {
        if (!m_bConnected) {
            std::cerr << "Error: Not connected to TwinCAT!" << std::endl;
            return false;
        }

        long nErr = AdsSyncWriteReqEx(m_nPort, &m_Addr, ADSIGRP_SYM_VALBYHND, 
                                      0, nDataSize, pData);
        
        if (nErr) {
            std::cerr << "Error writing variable '" << variableName 
                      << "': 0x" << std::hex << nErr << std::endl;
            return false;
        }

        return true;
    }

    void PrintSystemInfo() {
        if (!m_bConnected) {
            std::cerr << "Error: Not connected to TwinCAT!" << std::endl;
            return;
        }

        std::cout << "\n=== TwinCAT System Information ===" << std::endl;
        
        // Read system information
        AdsVersion version;
        char deviceName[16];
        long nErr = AdsSyncReadDeviceInfoReq(&m_Addr, deviceName, &version);
        
        if (!nErr) {
            std::cout << "Device Name: " << deviceName << std::endl;
            std::cout << "Version: " << (int)version.version 
                      << "." << (int)version.revision 
                      << "." << (int)version.build << std::endl;
        }
    }
};

int main() {
    std::cout << "=== Simple EtherCAT Master Application ===" << std::endl;
    std::cout << "TwinCAT3 C++ EtherCAT Master Demo" << std::endl;
    std::cout << "==========================================" << std::endl;

    EtherCATMaster master;

    // Connect to TwinCAT
    if (!master.Connect()) {
        std::cerr << "Failed to connect to TwinCAT system!" << std::endl;
        std::cout << "\nMake sure:" << std::endl;
        std::cout << "1. TwinCAT3 is installed and running" << std::endl;
        std::cout << "2. TwinCAT is in RUN mode" << std::endl;
        std::cout << "3. A PLC project is loaded" << std::endl;
        return -1;
    }

    // Print system information
    master.PrintSystemInfo();

    // Example: Simple monitoring loop
    std::cout << "\n=== Monitoring Loop ===" << std::endl;
    std::cout << "Press 'q' + Enter to quit..." << std::endl;

    char input = 0;
    int counter = 0;
    
    while (input != 'q') {
        // Example of cyclic operation
        std::cout << "Cycle " << ++counter << " - System running..." << std::endl;
        
        // Here you would typically:
        // 1. Read input data from EtherCAT slaves
        // 2. Process the data
        // 3. Write output data to EtherCAT slaves
        
        Sleep(1000); // Wait 1 second

        // Check for user input (non-blocking)
        if (_kbhit()) {
            input = _getch();
        }
    }

    std::cout << "\nShutting down EtherCAT Master..." << std::endl;
    master.Disconnect();

    return 0;
}

