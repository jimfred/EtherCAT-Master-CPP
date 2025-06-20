# EtherCAT Master C++ Applications Suite

This project contains **three different EtherCAT Master applications** for TwinCAT3, each demonstrating different approaches and capabilities.

## 🏗️ **Applications Included:**

### 1. 🔵 **Basic EtherCAT Master** (`main.cpp`)
**Output:** `EtherCATMaster_Basic.exe`

**Features:**
- Connect to TwinCAT3 runtime via ADS
- Read system information and version
- Monitor TwinCAT status
- Basic cyclic operations template
- Error handling for ADS operations

**Limitations:**
- ❌ **Does NOT control EtherCAT states**
- ❌ **Cannot get EtherCAT to OP mode**
- Only monitors existing system state

### 2. 🟢 **State-Aware EtherCAT Master** (`EtherCATStateMaster.cpp`)
**Output:** `EtherCATMaster_StateAware.exe`

**Features:**
- All features of Basic Master PLUS:
- Control TwinCAT system states (IDLE → RUN → STOP)
- Monitor EtherCAT master and slave states
- Interactive command interface
- Comprehensive state reporting

**Key Capability:**
- ✅ **CAN attempt to get EtherCAT to OP mode**
- ✅ **Can start/stop TwinCAT system**
- Automatically transitions EtherCAT when TwinCAT starts

### 3. 🟡 **Direct EtherCAT Master Demo** (`DirectEtherCATMaster.cpp`)
**Output:** `EtherCATMaster_Direct.exe`

**Features:**
- Network adapter enumeration and selection
- Shows direct EtherCAT programming concepts
- Demonstrates Ethernet port configuration
- Educational example of EtherCAT requirements

**Purpose:**
- 📚 **Educational demonstration only**
- Shows how direct EtherCAT masters work
- Not a functional EtherCAT master

## Prerequisites

1. **TwinCAT3** installed and running
2. **Visual Studio** 2019 or later with C++ development tools
3. **TwinCAT3 SDK** (included with TwinCAT3 installation)

## 📁 **Project Structure**

```
EtherCATMaster/
├── 📄 Source Files
│   ├── main.cpp                    # Basic EtherCAT Master
│   ├── EtherCATStateMaster.cpp     # State-Aware EtherCAT Master  
│   └── DirectEtherCATMaster.cpp    # Direct EtherCAT Demo
├── 🔧 Build Files
│   ├── EtherCATMaster.vcxproj      # Visual Studio project
│   ├── BasicMaster.vcxproj         # Basic master project
│   └── CMakeLists.txt              # CMake configuration
├── 🏗️ Build Scripts
│   ├── build.cmd                   # Single app builder (basic only)
│   ├── build_all_simple.cmd        # ALL 3 apps builder
│   ├── build_individual.cmd        # Individual app selector
│   └── IdeStart.cmd                # Visual Studio launcher
├── 📋 Configuration
│   └── ethercat_config.xml         # EtherCAT config example
└── 📖 Documentation
    └── README.md                   # This file
```

## 🚀 **Building the Applications**

### **Quick Start - Build All Applications**
```batch
# Build all 3 applications at once (RECOMMENDED)
build_all_simple.cmd
```
**Output:** `EtherCATMaster_Basic.exe`, `EtherCATMaster_StateAware.exe`, `EtherCATMaster_Direct.exe`

---

### **🔧 Build Script Options**

| Script | Builds | Output Files | Use Case |
|--------|--------|-------------|----------|
| `build_all_simple.cmd` | **All 3 apps** | `*_Basic.exe`, `*_StateAware.exe`, `*_Direct.exe` | **Recommended** |
| `build.cmd` | Basic only | `EtherCATMaster.exe` | Single app development |
| `build_individual.cmd` | Your choice | Custom names | Selective building |
| `IdeStart.cmd` | Opens VS | N/A | IDE development |

### **📋 Individual Build Commands**

```batch
# Build only the basic EtherCAT master
build.cmd

# Build specific application
build_individual.cmd basic      # Basic master only
build_individual.cmd state      # State-aware only
build_individual.cmd direct     # Direct demo only
build_individual.cmd all        # All three

# Build with options
build.cmd debug                 # Debug build
build.cmd release x86           # 32-bit release
build_all_simple.cmd            # All apps, release x64
```

### **🎯 Visual Studio Method**

```batch
# Launch Visual Studio IDE
IdeStart.cmd
```
**Then:** Use F7 or Build → Build Solution

### **⚙️ Advanced Methods**

#### **CMake Build**
```powershell
mkdir build && cd build
cmake ..
cmake --build . --config Release
```

#### **Direct MSBuild**
```powershell
# Basic master
MSBuild BasicMaster.vcxproj /p:Configuration=Release /p:Platform=x64

# Original project (main.cpp)
MSBuild EtherCATMaster.vcxproj /p:Configuration=Release /p:Platform=x64
```

## 🏃 **Running the Applications**

### **Pre-Requirements**
1. **Start TwinCAT3**: Make sure TwinCAT3 is running  
2. **EtherCAT Configuration**: EtherCAT Master configured in System Manager
3. **PLC Project**: Optional - only needed for traditional PLC-based approach
   - ✅ **Standalone C++ Master**: No PLC project required
   - ℹ️ **PLC-based approach**: Load a PLC project (even empty)
4. **Administrator Rights**: Run as administrator for TwinCAT control

### **🚀 Execute Applications**

```powershell
# Navigate to build output
cd x64\Release

# Run Basic EtherCAT Master (monitoring only)
.\EtherCATMaster_Basic.exe

# Run State-Aware Master (can control EtherCAT states)
.\EtherCATMaster_StateAware.exe

# Run Direct EtherCAT Demo (educational)
.\EtherCATMaster_Direct.exe
```

### **🎯 Application Comparison**

| Application | **Can Get to OP Mode?** | **Use Case** |
|-------------|------------------------|-------------|
| `EtherCATMaster_Basic.exe` | ❌ **NO** | Monitor existing system |
| `EtherCATMaster_StateAware.exe` | ✅ **YES** | Control and manage EtherCAT |
| `EtherCATMaster_Direct.exe` | 📚 **Educational** | Learn EtherCAT concepts |

### **📝 Application Controls**

#### **Basic Master**
- Press `q` + Enter to quit
- Automatic monitoring loop

#### **State-Aware Master**
- Press `s` to start EtherCAT system
- Press `r` to read status  
- Press `q` to quit
- Interactive commands for system control

#### **Direct Master Demo**
- Shows network adapters automatically
- Press any key to continue through demos
- Educational information display

## Application Features

The application provides:

- **Connection Management**: Establishes ADS connection to TwinCAT3
- **System Information**: Displays TwinCAT version and device information
- **Monitoring Loop**: Simulates cyclic EtherCAT operations
- **Error Handling**: Basic error handling for ADS operations
- **Clean Shutdown**: Proper disconnection when exiting

## Troubleshooting

### Common Issues

1. **"Failed to open ADS port"**
   - Ensure TwinCAT3 is installed and running
   - Check that the ADS service is running

2. **"ADS connection failed"**
   - Verify TwinCAT is in RUN mode
   - Check that a PLC project is loaded
   - Ensure AMS NetID is correct (127.0.0.1.1.1 for local)

3. **Compilation Errors**
   - Verify TwinCAT3 SDK paths in project settings
   - Check that TcAdsDll.lib is accessible
   - Ensure include paths point to TwinCAT SDK headers

### Checking TwinCAT Status

You can check TwinCAT status using:
```powershell
# Check if TwinCAT service is running
Get-Service | Where-Object {$_.Name -like "*TwinCAT*"}

# Check ADS router
netstat -an | findstr :48898
```

## Next Steps

This basic application can be extended to:

1. **Read/Write PLC Variables**: Add functions to communicate with specific PLC variables
2. **EtherCAT Device Management**: Add functions to manage EtherCAT slaves
3. **Real-time Operations**: Implement real-time cyclic operations
4. **Configuration Management**: Add XML configuration file support
5. **Logging**: Add structured logging capabilities

## Code Structure

The main components:

- **EtherCATMaster Class**: Encapsulates ADS communication
- **Connect()**: Establishes connection to TwinCAT
- **ReadVariable()/WriteVariable()**: Template for PLC variable access
- **PrintSystemInfo()**: Displays system information
- **Main Loop**: Demonstrates cyclic operation pattern

## EtherCAT OP Mode

### ❌ **Basic Application (`main.cpp`)**
**Will NOT get EtherCAT to OP mode automatically.**

The basic application:
- Only connects via ADS to TwinCAT
- Assumes TwinCAT and EtherCAT are already configured
- Monitors whatever state TwinCAT is already in
- Does not control EtherCAT states

### ✅ **State-Aware Application (`EtherCATStateMaster.cpp`)**
**CAN attempt to get EtherCAT to OP mode.**

To build the state-aware version:
1. Exclude `main.cpp` from build
2. Include `EtherCATStateMaster.cpp` in build
3. Or create a separate project

The state-aware application:
- Can start/stop TwinCAT system
- Monitors EtherCAT master and slave states
- Attempts to transition EtherCAT to OP mode
- Provides interactive control commands

### 🎯 **Requirements for EtherCAT OP Mode**

#### **Option 1: Standalone C++ EtherCAT Master (Your Case)**

For a **standalone C++ application** without PLC:

1. **TwinCAT System Configuration**:
   - EtherCAT Master configured in System Manager
   - Ethernet adapter assigned to EtherCAT
   - EtherCAT slaves scanned and configured
   - Configuration activated

2. **No PLC Required**:
   - ❌ **No PLC project needed**
   - ❌ **No PLC variables required**
   - ✅ **Your C++ app controls EtherCAT directly**
   - ✅ **Process data handled in your application**

3. **System State**:
   - TwinCAT in RUN mode (without PLC)
   - All EtherCAT slaves responding
   - No configuration errors

#### **Option 2: Traditional TwinCAT with PLC**

For a **PLC-based system** (traditional approach):

1. **TwinCAT System Configuration**:
   - EtherCAT Master configured in System Manager
   - Ethernet adapter assigned to EtherCAT
   - EtherCAT slaves scanned and configured
   - Configuration activated

2. **PLC Program** (if using PLC approach):
   - PLC project with I/O mapping
   - Variables linked to EtherCAT I/O
   - Program compiled and downloaded

3. **System State**:
   - TwinCAT in RUN mode
   - PLC program running
   - All EtherCAT slaves responding

**Note:** Your C++ applications can work with **either approach** - they connect via ADS regardless of whether a PLC is present.

### 🔧 **Manual Steps to Configure EtherCAT**

#### **For Standalone C++ EtherCAT Master (Your Case):**

1. Open TwinCAT System Manager
2. Add EtherCAT Master device  
3. Assign Ethernet adapter to EtherCAT
4. Scan for EtherCAT slaves
5. Configure I/O mapping (Process Data)
6. **Skip PLC creation** - your C++ app will handle process data
7. Activate configuration
8. Set TwinCAT to RUN mode 
9. **Now** EtherCAT will go to OP mode

#### **For Traditional PLC-based Approach:**

1. Open TwinCAT System Manager
2. Add EtherCAT Master device
3. Assign Ethernet adapter to EtherCAT  
4. Scan for EtherCAT slaves
5. Configure I/O mapping
6. Create PLC project with I/O variables
7. Link PLC variables to EtherCAT I/O
8. Activate configuration
9. Set TwinCAT to RUN mode
10. **Now** EtherCAT will go to OP mode

**Key Difference:** In standalone mode, your C++ application accesses process data directly via ADS instead of through PLC variables.

## License

This is example code for educational purposes.

