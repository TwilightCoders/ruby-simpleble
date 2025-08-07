#include "simpleble_wrapper.h"
#include <simpleble/SimpleBLE.h>
#include <memory>
#include <vector>
#include <cstdlib>
#include <cstring>

using namespace SimpleBLE;

extern "C" {

// Memory management
void simpleble_free(void* handle) {
    if (handle) {
        free(handle);
    }
}

// Adapter functions using C++ API
bool simpleble_adapter_bluetooth_enabled(void) {
    try {
        return Adapter::bluetooth_enabled();
    } catch (...) {
        return false;
    }
}

size_t simpleble_adapter_get_count(void) {
    try {
        auto adapters = Adapter::get_adapters();
        return adapters.size();
    } catch (...) {
        return 0;
    }
}

simpleble_adapter_t simpleble_adapter_get_handle(size_t index) {
    try {
        auto adapters = Adapter::get_adapters();
        if (index >= adapters.size()) return nullptr;
        
        // Create a copy of the adapter on the heap
        Adapter* adapter = new Adapter(adapters[index]);
        return static_cast<void*>(adapter);
    } catch (...) {
        return nullptr;
    }
}

void simpleble_adapter_release(simpleble_adapter_t handle) {
    if (handle) {
        Adapter* adapter = static_cast<Adapter*>(handle);
        delete adapter;
    }
}

char* simpleble_adapter_identifier(simpleble_adapter_t handle) {
    if (!handle) return nullptr;
    try {
        Adapter* adapter = static_cast<Adapter*>(handle);
        std::string id = adapter->identifier();
        char* result = static_cast<char*>(malloc(id.length() + 1));
        strcpy(result, id.c_str());
        return result;
    } catch (...) {
        return nullptr;
    }
}

char* simpleble_adapter_address(simpleble_adapter_t handle) {
    if (!handle) return nullptr;
    try {
        Adapter* adapter = static_cast<Adapter*>(handle);
        std::string addr = adapter->address();
        char* result = static_cast<char*>(malloc(addr.length() + 1));
        strcpy(result, addr.c_str());
        return result;
    } catch (...) {
        return nullptr;
    }
}

// Scan functions
simpleble_err_t simpleble_adapter_scan_start(simpleble_adapter_t handle) {
    if (!handle) return SIMBLEBLE_INVALID_PARAMETER;
    try {
        Adapter* adapter = static_cast<Adapter*>(handle);
        adapter->scan_start();
        return SIMBLEBLE_SUCCESS;
    } catch (...) {
        return SIMBLEBLE_FAILURE;
    }
}

simpleble_err_t simpleble_adapter_scan_stop(simpleble_adapter_t handle) {
    if (!handle) return SIMBLEBLE_INVALID_PARAMETER;
    try {
        Adapter* adapter = static_cast<Adapter*>(handle);
        adapter->scan_stop();
        return SIMBLEBLE_SUCCESS;
    } catch (...) {
        return SIMBLEBLE_FAILURE;
    }
}

simpleble_err_t simpleble_adapter_scan_for(simpleble_adapter_t handle, int timeout_ms) {
    if (!handle) return SIMBLEBLE_INVALID_PARAMETER;
    try {
        Adapter* adapter = static_cast<Adapter*>(handle);
        adapter->scan_for(timeout_ms);
        return SIMBLEBLE_SUCCESS;
    } catch (...) {
        return SIMBLEBLE_FAILURE;
    }
}

simpleble_err_t simpleble_adapter_scan_is_active(simpleble_adapter_t handle, bool* active) {
    if (!handle || !active) return SIMBLEBLE_INVALID_PARAMETER;
    try {
        Adapter* adapter = static_cast<Adapter*>(handle);
        *active = adapter->scan_is_active();
        return SIMBLEBLE_SUCCESS;
    } catch (...) {
        return SIMBLEBLE_FAILURE;
    }
}

size_t simpleble_adapter_scan_get_results_count(simpleble_adapter_t handle) {
    if (!handle) return 0;
    try {
        Adapter* adapter = static_cast<Adapter*>(handle);
        auto peripherals = adapter->scan_get_results();
        return peripherals.size();
    } catch (...) {
        return 0;
    }
}

simpleble_peripheral_t simpleble_adapter_scan_get_results_handle(simpleble_adapter_t handle, size_t index) {
    if (!handle) return nullptr;
    try {
        Adapter* adapter = static_cast<Adapter*>(handle);
        auto peripherals = adapter->scan_get_results();
        if (index >= peripherals.size()) return nullptr;
        
        // Create a copy of the peripheral on the heap
        Peripheral* peripheral = new Peripheral(peripherals[index]);
        return static_cast<void*>(peripheral);
    } catch (...) {
        return nullptr;
    }
}

// Peripheral functions
void simpleble_peripheral_release(simpleble_peripheral_t handle) {
    if (handle) {
        Peripheral* peripheral = static_cast<Peripheral*>(handle);
        delete peripheral;
    }
}

char* simpleble_peripheral_identifier(simpleble_peripheral_t handle) {
    if (!handle) return nullptr;
    try {
        Peripheral* peripheral = static_cast<Peripheral*>(handle);
        std::string id = peripheral->identifier();
        char* result = static_cast<char*>(malloc(id.length() + 1));
        strcpy(result, id.c_str());
        return result;
    } catch (...) {
        return nullptr;
    }
}

char* simpleble_peripheral_address(simpleble_peripheral_t handle) {
    if (!handle) return nullptr;
    try {
        Peripheral* peripheral = static_cast<Peripheral*>(handle);
        std::string addr = peripheral->address();
        char* result = static_cast<char*>(malloc(addr.length() + 1));
        strcpy(result, addr.c_str());
        return result;
    } catch (...) {
        return nullptr;
    }
}

int simpleble_peripheral_address_type(simpleble_peripheral_t handle) {
    if (!handle) return -1;
    try {
        Peripheral* peripheral = static_cast<Peripheral*>(handle);
        return static_cast<int>(peripheral->address_type());
    } catch (...) {
        return -1;
    }
}

int simpleble_peripheral_rssi(simpleble_peripheral_t handle) {
    if (!handle) return 0;
    try {
        Peripheral* peripheral = static_cast<Peripheral*>(handle);
        return peripheral->rssi();
    } catch (...) {
        return 0;
    }
}

simpleble_err_t simpleble_peripheral_connect(simpleble_peripheral_t handle) {
    if (!handle) return SIMBLEBLE_INVALID_PARAMETER;
    try {
        Peripheral* peripheral = static_cast<Peripheral*>(handle);
        peripheral->connect();
        return SIMBLEBLE_SUCCESS;
    } catch (...) {
        return SIMBLEBLE_FAILURE;
    }
}

simpleble_err_t simpleble_peripheral_disconnect(simpleble_peripheral_t handle) {
    if (!handle) return SIMBLEBLE_INVALID_PARAMETER;
    try {
        Peripheral* peripheral = static_cast<Peripheral*>(handle);
        peripheral->disconnect();
        return SIMBLEBLE_SUCCESS;
    } catch (...) {
        return SIMBLEBLE_FAILURE;
    }
}

simpleble_err_t simpleble_peripheral_is_connected(simpleble_peripheral_t handle, bool* connected) {
    if (!handle || !connected) return SIMBLEBLE_INVALID_PARAMETER;
    try {
        Peripheral* peripheral = static_cast<Peripheral*>(handle);
        *connected = peripheral->is_connected();
        return SIMBLEBLE_SUCCESS;
    } catch (...) {
        return SIMBLEBLE_FAILURE;
    }
}

simpleble_err_t simpleble_peripheral_is_connectable(simpleble_peripheral_t handle, bool* connectable) {
    if (!handle || !connectable) return SIMBLEBLE_INVALID_PARAMETER;
    try {
        Peripheral* peripheral = static_cast<Peripheral*>(handle);
        *connectable = peripheral->is_connectable();
        return SIMBLEBLE_SUCCESS;
    } catch (...) {
        return SIMBLEBLE_FAILURE;
    }
}

// Placeholder implementations for remaining functions
size_t simpleble_peripheral_services_count(simpleble_peripheral_t handle) {
    // Implementation needed
    return 0;
}

simpleble_service_t simpleble_peripheral_services_get(simpleble_peripheral_t handle, size_t index) {
    // Implementation needed  
    return nullptr;
}

void simpleble_service_release(simpleble_service_t handle) {
    // Implementation needed
}

char* simpleble_service_uuid(simpleble_service_t handle) {
    // Implementation needed
    return nullptr;
}

size_t simpleble_service_characteristics_count(simpleble_service_t handle) {
    // Implementation needed
    return 0;
}

simpleble_characteristic_t simpleble_service_characteristics_get(simpleble_service_t handle, size_t index) {
    // Implementation needed
    return nullptr;
}

void simpleble_characteristic_release(simpleble_characteristic_t handle) {
    // Implementation needed
}

char* simpleble_characteristic_uuid(simpleble_characteristic_t handle) {
    // Implementation needed
    return nullptr;
}

size_t simpleble_characteristic_descriptors_count(simpleble_characteristic_t handle) {
    // Implementation needed
    return 0;
}

simpleble_descriptor_t simpleble_characteristic_descriptors_get(simpleble_characteristic_t handle, size_t index) {
    // Implementation needed
    return nullptr;
}

void simpleble_descriptor_release(simpleble_descriptor_t handle) {
    // Implementation needed
}

char* simpleble_descriptor_uuid(simpleble_descriptor_t handle) {
    // Implementation needed
    return nullptr;
}

} // extern "C"