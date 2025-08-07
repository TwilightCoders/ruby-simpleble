#ifndef SIMPLEBLE_WRAPPER_H
#define SIMPLEBLE_WRAPPER_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Error codes
typedef enum {
    SIMBLEBLE_SUCCESS = 0,
    SIMBLEBLE_FAILURE = 1,
    SIMBLEBLE_INVALID_REFERENCE = 2,
    SIMBLEBLE_INVALID_PARAMETER = 3
} simpleble_err_t;

// Opaque handle types
typedef void* simpleble_adapter_t;
typedef void* simpleble_peripheral_t;
typedef void* simpleble_service_t;
typedef void* simpleble_characteristic_t;
typedef void* simpleble_descriptor_t;

// Memory management
void simpleble_free(void* handle);

// Adapter functions
bool simpleble_adapter_bluetooth_enabled(void);
size_t simpleble_adapter_get_count(void);
simpleble_adapter_t simpleble_adapter_get_handle(size_t index);
void simpleble_adapter_release(simpleble_adapter_t handle);
char* simpleble_adapter_identifier(simpleble_adapter_t handle);
char* simpleble_adapter_address(simpleble_adapter_t handle);

// Scan functions
simpleble_err_t simpleble_adapter_scan_start(simpleble_adapter_t handle);
simpleble_err_t simpleble_adapter_scan_stop(simpleble_adapter_t handle);
simpleble_err_t simpleble_adapter_scan_for(simpleble_adapter_t handle, int timeout_ms);
simpleble_err_t simpleble_adapter_scan_is_active(simpleble_adapter_t handle, bool* active);
size_t simpleble_adapter_scan_get_results_count(simpleble_adapter_t handle);
simpleble_peripheral_t simpleble_adapter_scan_get_results_handle(simpleble_adapter_t handle, size_t index);

// Peripheral functions
void simpleble_peripheral_release(simpleble_peripheral_t handle);
char* simpleble_peripheral_identifier(simpleble_peripheral_t handle);
char* simpleble_peripheral_address(simpleble_peripheral_t handle);
int simpleble_peripheral_address_type(simpleble_peripheral_t handle);
int simpleble_peripheral_rssi(simpleble_peripheral_t handle);
int16_t simpleble_peripheral_tx_power(simpleble_peripheral_t handle);
uint16_t simpleble_peripheral_mtu(simpleble_peripheral_t handle);
simpleble_err_t simpleble_peripheral_is_connectable(simpleble_peripheral_t handle, bool* connectable);
simpleble_err_t simpleble_peripheral_is_connected(simpleble_peripheral_t handle, bool* connected);
bool simpleble_peripheral_is_paired(simpleble_peripheral_t handle);
simpleble_err_t simpleble_peripheral_connect(simpleble_peripheral_t handle);
simpleble_err_t simpleble_peripheral_disconnect(simpleble_peripheral_t handle);
simpleble_err_t simpleble_peripheral_unpair(simpleble_peripheral_t handle);

// Service/characteristic functions
size_t simpleble_peripheral_services_count(simpleble_peripheral_t handle);
simpleble_service_t simpleble_peripheral_services_get(simpleble_peripheral_t handle, size_t index);
char* simpleble_service_uuid(simpleble_service_t handle);
uint8_t* simpleble_service_data(simpleble_service_t handle, size_t* length);
size_t simpleble_service_characteristic_count(simpleble_service_t handle);
simpleble_characteristic_t simpleble_service_characteristic_get(simpleble_service_t handle, size_t index);

#ifdef __cplusplus
}
#endif

#endif // SIMPLEBLE_WRAPPER_H