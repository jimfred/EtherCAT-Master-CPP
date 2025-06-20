# EtherCAT Master - Quick Reference

## 🚀 **Quick Start**
```bash
# Build all applications
build_all_simple.cmd

# Run state-aware master (can get to OP mode)
cd x64\Release
.\EtherCATMaster_StateAware.exe
```

## 🎯 **Which App Does What?**
| App | Can Get to OP Mode? | Purpose |
|-----|-------------------|---------|
| `EtherCATMaster_Basic.exe` | ❌ NO | Monitor existing system |
| `EtherCATMaster_StateAware.exe` | ✅ YES | Control EtherCAT states |
| `EtherCATMaster_Direct.exe` | 📚 Educational | Learn concepts |

## 🔧 **Build Commands**
```bash
build.cmd                    # Basic master only
build_all_simple.cmd         # All 3 applications  
build_individual.cmd state   # State-aware only
IdeStart.cmd                 # Open Visual Studio
```

## ⚙️ **TwinCAT Setup for Standalone C++**
1. TwinCAT System Manager
2. Add EtherCAT Master → assign Ethernet port
3. Scan slaves OR import ENI file
4. Configure PDO mapping
5. **Skip PLC creation** (C++ handles process data)
6. Activate configuration → Set to RUN mode
7. Run C++ application

## 🐛 **Quick Troubleshooting**
| Error | Solution |
|-------|----------|
| "Failed to open ADS port" | Check TwinCAT service running |
| "ADS connection failed" | Verify TwinCAT in RUN mode |
| Build fails | Check VS2022 installed, TwinCAT SDK paths |
| Can't get to OP mode | Use StateAware app, ensure EtherCAT configured |

## 📁 **Key Files**
- `main.cpp` - Basic master (monitoring only)
- `EtherCATStateMaster.cpp` - State control master ⭐
- `build_all_simple.cmd` - Recommended build script ⭐
- `DEVELOPMENT_LOG.md` - Full context and decisions ⭐

## 🔑 **Key Insights**
- **Standalone approach:** No PLC project needed
- **EtherCAT OP mode:** Achieved by starting TwinCAT (IDLE→RUN)
- **Process data:** Access via ADS, not PLC variables
- **ENI files:** Define PDO mapping for standalone masters

