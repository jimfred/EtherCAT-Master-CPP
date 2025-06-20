#include <iostream>
#include <windows.h>
#include <winsock2.h>
#include <iphlpapi.h>
#include <vector>
#include <string>

#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "ws2_32.lib")

class DirectEtherCATMaster {
private:
    std::string m_selectedAdapter;
    std::string m_adapterMAC;
    
public:
    // Structure to hold network adapter information
    struct NetworkAdapter {
        std::string name;
        std::string description;
        std::string macAddress;
        bool isEthernetCapable;
        DWORD speed;
    };

    std::vector<NetworkAdapter> ListNetworkAdapters() {
        std::vector<NetworkAdapter> adapters;
        
        // Get adapter information
        ULONG bufferSize = 0;
        GetAdaptersInfo(nullptr, &bufferSize);
        
        std::vector<BYTE> buffer(bufferSize);
        PIP_ADAPTER_INFO pAdapterInfo = reinterpret_cast<PIP_ADAPTER_INFO>(buffer.data());
        
        if (GetAdaptersInfo(pAdapterInfo, &bufferSize) == NO_ERROR) {
            PIP_ADAPTER_INFO pAdapter = pAdapterInfo;
            
            while (pAdapter) {
                NetworkAdapter adapter;
                adapter.name = pAdapter->AdapterName;
                adapter.description = pAdapter->Description;
                
                // Format MAC address
                char macStr[18];
                sprintf_s(macStr, "%02X:%02X:%02X:%02X:%02X:%02X",
                    pAdapter->Address[0], pAdapter->Address[1], pAdapter->Address[2],
                    pAdapter->Address[3], pAdapter->Address[4], pAdapter->Address[5]);
                adapter.macAddress = macStr;
                
                // Check if it's Ethernet (exclude loopback, PPP, etc.)
                adapter.isEthernetCapable = (pAdapter->Type == MIB_IF_TYPE_ETHERNET) ||
                                          (pAdapter->Type == IF_TYPE_IEEE80211); // WiFi
                
                adapters.push_back(adapter);
                pAdapter = pAdapter->Next;
            }
        }
        
        return adapters;
    }

    void PrintAvailableAdapters() {
        std::cout << "\\n=== Available Network Adapters ===" << std::endl;
        auto adapters = ListNetworkAdapters();
        
        int index = 1;
        for (const auto& adapter : adapters) {
            std::cout << index++ << ". " << adapter.description << std::endl;
            std::cout << "   Name: " << adapter.name << std::endl;
            std::cout << "   MAC: " << adapter.macAddress << std::endl;
            std::cout << "   EtherCAT Capable: " << (adapter.isEthernetCapable ? "Yes" : "No") << std::endl;
            std::cout << std::endl;
        }
    }

    bool SelectAdapter(const std::string& adapterName) {
        auto adapters = ListNetworkAdapters();
        
        for (const auto& adapter : adapters) {
            if (adapter.name == adapterName || adapter.description == adapterName) {
                if (!adapter.isEthernetCapable) {
                    std::cerr << "Warning: Selected adapter may not be suitable for EtherCAT" << std::endl;
                }
                
                m_selectedAdapter = adapter.name;
                m_adapterMAC = adapter.macAddress;
                
                std::cout << "Selected adapter: " << adapter.description << std::endl;
                std::cout << "MAC Address: " << adapter.macAddress << std::endl;
                return true;
            }
        }
        
        std::cerr << "Adapter not found: " << adapterName << std::endl;
        return false;
    }

    bool InitializeEtherCAT() {
        if (m_selectedAdapter.empty()) {
            std::cerr << "No adapter selected! Call SelectAdapter() first." << std::endl;
            return false;
        }

        std::cout << "\\n=== Initializing EtherCAT Master ===" << std::endl;
        std::cout << "Using adapter: " << m_selectedAdapter << std::endl;
        std::cout << "MAC Address: " << m_adapterMAC << std::endl;
        
        // In a real EtherCAT implementation, you would:
        // 1. Open raw socket on the selected adapter
        // 2. Set the adapter to promiscuous mode
        // 3. Initialize EtherCAT frame handling
        // 4. Start the real-time cycle
        
        std::cout << "\\nEtherCAT Master would be initialized with:" << std::endl;
        std::cout << "- Raw Ethernet socket on " << m_selectedAdapter << std::endl;
        std::cout << "- EtherCAT protocol handling" << std::endl;
        std::cout << "- Real-time cyclic communication" << std::endl;
        std::cout << "- Slave device management" << std::endl;
        
        return true;
    }

    void ShowEtherCATConfiguration() {
        std::cout << "\\n=== EtherCAT Configuration Requirements ===" << std::endl;
        std::cout << "For a real EtherCAT master, you need:" << std::endl;
        std::cout << "\\n1. Hardware Requirements:" << std::endl;
        std::cout << "   - Dedicated Ethernet port (1 Gbps recommended)" << std::endl;
        std::cout << "   - Real-time capable network adapter" << std::endl;
        std::cout << "   - No sharing with regular network traffic" << std::endl;
        std::cout << "\\n2. Software Requirements:" << std::endl;
        std::cout << "   - Raw socket access (administrative privileges)" << std::endl;
        std::cout << "   - Real-time operating system or RT kernel" << std::endl;
        std::cout << "   - EtherCAT master stack (e.g., SOEM, IGH, TwinCAT)" << std::endl;
        std::cout << "\\n3. Network Configuration:" << std::endl;
        std::cout << "   - Disable Windows network protocols on EtherCAT adapter" << std::endl;
        std::cout << "   - Configure adapter for optimal performance" << std::endl;
        std::cout << "   - Set appropriate buffer sizes and interrupt settings" << std::endl;
    }
};

int main() {
    std::cout << "=== Direct EtherCAT Master - Network Configuration ===" << std::endl;
    
    DirectEtherCATMaster master;
    
    // Show available network adapters
    master.PrintAvailableAdapters();
    
    // Show configuration requirements
    master.ShowEtherCATConfiguration();
    
    // Example: Select an adapter (you would typically prompt user or use config file)
    std::cout << "\\n=== Adapter Selection Example ===" << std::endl;
    std::cout << "In a real application, you would:" << std::endl;
    std::cout << "1. Read from configuration file" << std::endl;
    std::cout << "2. Prompt user to select adapter" << std::endl;
    std::cout << "3. Auto-detect based on criteria" << std::endl;
    
    // Try to select first Ethernet adapter
    auto adapters = master.ListNetworkAdapters();
    for (const auto& adapter : adapters) {
        if (adapter.isEthernetCapable && adapter.description.find("Virtual") == std::string::npos) {
            std::cout << "\\nExample: Selecting " << adapter.description << std::endl;
            master.SelectAdapter(adapter.name);
            master.InitializeEtherCAT();
            break;
        }
    }
    
    std::cout << "\\n=== TwinCAT vs Direct EtherCAT ===" << std::endl;
    std::cout << "TwinCAT Approach (our main app):" << std::endl;
    std::cout << "- TwinCAT handles Ethernet port selection" << std::endl;
    std::cout << "- Configured in TwinCAT System Manager" << std::endl;
    std::cout << "- Your app connects via ADS (TCP/IP)" << std::endl;
    std::cout << "\\nDirect EtherCAT Approach (this example):" << std::endl;
    std::cout << "- Your app directly controls Ethernet port" << std::endl;
    std::cout << "- Must handle real-time requirements" << std::endl;
    std::cout << "- More complex but more control" << std::endl;
    
    std::cout << "\\nPress any key to continue..." << std::endl;
    std::cin.get();
    
    return 0;
}

