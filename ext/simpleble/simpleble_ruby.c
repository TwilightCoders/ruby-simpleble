// Ruby integration
#include <ruby.h>
#include <stdlib.h>

// SimpleBLE C API - use only the installed headers
// Windows installs to simpleble_c/, Unix installs to simplecble/
#ifdef _WIN32
#include <simpleble_c/adapter.h>
#include <simpleble_c/peripheral.h>
#include <simpleble_c/types.h>
#else
#include <simplecble/adapter.h>
#include <simplecble/peripheral.h>
#include <simplecble/types.h>
#endif

// Module and class definitions
static VALUE mSimpleBLE;
static VALUE cAdapter;
static VALUE cPeripheral;

// Exception classes
static VALUE eSimpleBLEError;
static VALUE eScanError;
static VALUE eConnectionError;
static VALUE eCharacteristicError; // placeholder for future use

// Error handling macro (SimpleBLE currently only has SUCCESS/FAILURE)
#define SIMPLEBLE_RAISE_IF_FAILURE(err, exc, msg) do { \
    if ((err) != SIMPLEBLE_SUCCESS) { \
        rb_raise((exc), "%s", (msg)); \
    } \
} while(0)

// Ruby object data structures - using SimpleBLE C API types
typedef struct {
    simpleble_adapter_t adapter_handle;
} adapter_data_t;

typedef struct {
    simpleble_peripheral_t peripheral_handle;
} peripheral_data_t;

// Memory management functions
static void adapter_free(void* ptr) {
    adapter_data_t* data = (adapter_data_t*)ptr;
    if (data->adapter_handle) {
        simpleble_adapter_release_handle(data->adapter_handle);
    }
    xfree(data);
}

static const rb_data_type_t adapter_type = {
    "SimpleBLE::Adapter",
    {0, adapter_free, 0, 0},
    0, 0,
    RUBY_TYPED_FREE_IMMEDIATELY,
};

static void peripheral_free(void* ptr) {
    peripheral_data_t* data = (peripheral_data_t*)ptr;
    if (data->peripheral_handle) {
        simpleble_peripheral_release_handle(data->peripheral_handle);
    }
    xfree(data);
}

static const rb_data_type_t peripheral_type = {
    "SimpleBLE::Peripheral",
    {0, peripheral_free, 0, 0},
    0, 0,
    RUBY_TYPED_FREE_IMMEDIATELY,
};

// Helper functions
static void check_adapter_data(adapter_data_t* data) {
    if (!data || !data->adapter_handle) {
        rb_raise(eSimpleBLEError, "Adapter not initialized");
    }
}

static void check_peripheral_data(peripheral_data_t* data) {
    if (!data || !data->peripheral_handle) {
        rb_raise(eSimpleBLEError, "Peripheral not initialized");
    }
}

/*
 * call-seq:
 *   SimpleBLE::Adapter.bluetooth_enabled? -> Boolean
 *
 * Check if Bluetooth is enabled on the system.
 */
static VALUE
rb_adapter_bluetooth_enabled(VALUE self)
{
    return simpleble_adapter_is_bluetooth_enabled() ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *   SimpleBLE::Adapter.get_adapters -> Array
 *
 * Get all available Bluetooth adapters.
 */
static VALUE
rb_adapter_get_adapters(VALUE self)
{
    size_t count = simpleble_adapter_get_count();
    VALUE adapters = rb_ary_new_capa(count);
    
    for (size_t i = 0; i < count; i++) {
        simpleble_adapter_t adapter_handle = simpleble_adapter_get_handle(i);
        if (adapter_handle) {
            adapter_data_t* data = ALLOC(adapter_data_t);
            data->adapter_handle = adapter_handle;
            
            VALUE adapter = TypedData_Wrap_Struct(cAdapter, &adapter_type, data);
            rb_ary_push(adapters, adapter);
        }
    }
    
    return adapters;
}

/*
 * call-seq:
 *   adapter.scan_start -> self
 *
 * Start scanning (continuous until scan_stop is called).
 */
static VALUE
rb_adapter_scan_start(VALUE self)
{
    adapter_data_t* data; 
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    simpleble_err_t err = simpleble_adapter_scan_start(data->adapter_handle);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eScanError, "Failed to start scan");
    return self;
}

/*
 * call-seq:
 *   adapter.scan_stop -> self
 *
 * Stop scanning.
 */
static VALUE
rb_adapter_scan_stop(VALUE self)
{
    adapter_data_t* data; 
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    simpleble_err_t err = simpleble_adapter_scan_stop(data->adapter_handle);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eScanError, "Failed to stop scan");
    return self;
}

/*
 * call-seq:
 *   adapter.scan_for(timeout_ms) -> self
 *
 * Perform a blocking scan for timeout_ms milliseconds.
 */
static VALUE
rb_adapter_scan_for(VALUE self, VALUE timeout_ms_val)
{
    adapter_data_t* data; 
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    int timeout_ms = NUM2INT(timeout_ms_val);
    simpleble_err_t err = simpleble_adapter_scan_for(data->adapter_handle, timeout_ms);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eScanError, "Failed to perform timed scan");
    return self;
}

/*
 * call-seq:
 *   adapter.scan_active? -> Boolean
 */
static VALUE
rb_adapter_scan_active(VALUE self)
{
    adapter_data_t* data; 
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    bool active = false;
    simpleble_err_t err = simpleble_adapter_scan_is_active(data->adapter_handle, &active);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eScanError, "Failed to query scan state");
    return active ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *   adapter.scan_results -> [Peripheral, ...]
 *
 * Return peripherals discovered in last/ongoing scan.
 */
static VALUE
rb_adapter_scan_results(VALUE self)
{
    adapter_data_t* data; 
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    size_t count = simpleble_adapter_scan_get_results_count(data->adapter_handle);
    VALUE ary = rb_ary_new_capa(count);
    for (size_t i = 0; i < count; i++) {
        simpleble_peripheral_t ph = simpleble_adapter_scan_get_results_handle(data->adapter_handle, i);
        if (ph) {
            peripheral_data_t* pdata = ALLOC(peripheral_data_t);
            pdata->peripheral_handle = ph;
            VALUE periph = TypedData_Wrap_Struct(cPeripheral, &peripheral_type, pdata);
            rb_ary_push(ary, periph);
        }
    }
    return ary;
}

/*
 * call-seq:
 *   adapter.identifier -> String
 *
 * Get the adapter identifier.
 */
static VALUE
rb_adapter_identifier(VALUE self)
{
    adapter_data_t* data;
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    
    char* identifier = simpleble_adapter_identifier(data->adapter_handle);
    if (!identifier) {
        return Qnil;
    }
    
    VALUE result = rb_str_new_cstr(identifier);
    free(identifier);
    return result;
}

/*
 * call-seq:
 *   adapter.address -> String
 *
 * Get the adapter MAC address.
 */
static VALUE
rb_adapter_address(VALUE self)
{
    adapter_data_t* data;
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    
    char* address = simpleble_adapter_address(data->adapter_handle);
    if (!address) {
        return Qnil;
    }
    
    VALUE result = rb_str_new_cstr(address);
    free(address);
    return result;
}

/* Peripheral Methods */

/* identifier */
static VALUE rb_peripheral_identifier(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    char* ident = simpleble_peripheral_identifier(data->peripheral_handle);
    if (!ident) return Qnil;
    VALUE str = rb_str_new_cstr(ident);
    free(ident);
    return str;
}

/* address */
static VALUE rb_peripheral_address(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    char* addr = simpleble_peripheral_address(data->peripheral_handle);
    if (!addr) return Qnil;
    VALUE str = rb_str_new_cstr(addr);
    free(addr);
    return str;
}

/* rssi */
static VALUE rb_peripheral_rssi(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    int16_t rssi = simpleble_peripheral_rssi(data->peripheral_handle);
    return INT2NUM(rssi);
}

/* address_type */
static VALUE rb_peripheral_address_type(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    simpleble_address_type_t at = simpleble_peripheral_address_type(data->peripheral_handle);
    return INT2NUM((int)at);
}

/* connectable? */
static VALUE rb_peripheral_connectable(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    bool connectable = false;
    simpleble_err_t err = simpleble_peripheral_is_connectable(data->peripheral_handle, &connectable);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eConnectionError, "Failed to query connectable state");
    return connectable ? Qtrue : Qfalse;
}

/* connected? */
static VALUE rb_peripheral_connected(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    bool connected = false;
    simpleble_err_t err = simpleble_peripheral_is_connected(data->peripheral_handle, &connected);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eConnectionError, "Failed to query connection state");
    return connected ? Qtrue : Qfalse;
}

/* paired? */
static VALUE rb_peripheral_paired(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    bool paired = false;
    simpleble_err_t err = simpleble_peripheral_is_paired(data->peripheral_handle, &paired);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eConnectionError, "Failed to query paired state");
    return paired ? Qtrue : Qfalse;
}

/* connect */
static VALUE rb_peripheral_connect(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    simpleble_err_t err = simpleble_peripheral_connect(data->peripheral_handle);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eConnectionError, "Failed to connect to peripheral");
    return self;
}

/* disconnect */
static VALUE rb_peripheral_disconnect(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    simpleble_err_t err = simpleble_peripheral_disconnect(data->peripheral_handle);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eConnectionError, "Failed to disconnect peripheral");
    return self;
}

/* unpair */
static VALUE rb_peripheral_unpair(VALUE self) {
    peripheral_data_t* data; 
    TypedData_Get_Struct(self, peripheral_data_t, &peripheral_type, data);
    check_peripheral_data(data);
    simpleble_err_t err = simpleble_peripheral_unpair(data->peripheral_handle);
    SIMPLEBLE_RAISE_IF_FAILURE(err, eConnectionError, "Failed to unpair peripheral");
    return self;
}

// TODO: services, manufacturer_data, read/write characteristics, notifications.

// Module initialization - SimpleBLE C API direct integration working locally
void Init_simpleble(void)
{
    // Define main module
    mSimpleBLE = rb_define_module("SimpleBLE");
    
    // Define classes
    cAdapter = rb_define_class_under(mSimpleBLE, "Adapter", rb_cObject);
    cPeripheral = rb_define_class_under(mSimpleBLE, "Peripheral", rb_cObject);
    
    // Define (or fetch existing) exception classes
    eSimpleBLEError = rb_define_class_under(mSimpleBLE, "Error", rb_eStandardError);
    // Fetch subclasses defined in Ruby layer if present
    if (rb_const_defined(mSimpleBLE, rb_intern("ScanError"))) {
        eScanError = rb_const_get(mSimpleBLE, rb_intern("ScanError"));
    } else {
        eScanError = rb_define_class_under(mSimpleBLE, "ScanError", eSimpleBLEError);
    }
    if (rb_const_defined(mSimpleBLE, rb_intern("ConnectionError"))) {
        eConnectionError = rb_const_get(mSimpleBLE, rb_intern("ConnectionError"));
    } else {
        eConnectionError = rb_define_class_under(mSimpleBLE, "ConnectionError", eSimpleBLEError);
    }
    if (rb_const_defined(mSimpleBLE, rb_intern("CharacteristicError"))) {
        eCharacteristicError = rb_const_get(mSimpleBLE, rb_intern("CharacteristicError"));
    } else {
        eCharacteristicError = rb_define_class_under(mSimpleBLE, "CharacteristicError", eSimpleBLEError);
    }
    
    // Adapter class methods
    rb_define_singleton_method(cAdapter, "bluetooth_enabled?", rb_adapter_bluetooth_enabled, 0);
    rb_define_singleton_method(cAdapter, "get_adapters", rb_adapter_get_adapters, 0);
    
    // Adapter instance methods
    rb_define_method(cAdapter, "identifier", rb_adapter_identifier, 0);
    rb_define_method(cAdapter, "address", rb_adapter_address, 0);
    rb_define_method(cAdapter, "scan_start", rb_adapter_scan_start, 0);
    rb_define_method(cAdapter, "scan_stop", rb_adapter_scan_stop, 0);
    rb_define_method(cAdapter, "scan_for", rb_adapter_scan_for, 1);
    rb_define_method(cAdapter, "scan_active?", rb_adapter_scan_active, 0);
    rb_define_method(cAdapter, "scan_results", rb_adapter_scan_results, 0);

    // Peripheral instance methods
    rb_define_method(cPeripheral, "identifier", rb_peripheral_identifier, 0);
    rb_define_method(cPeripheral, "address", rb_peripheral_address, 0);
    rb_define_method(cPeripheral, "rssi", rb_peripheral_rssi, 0);
    rb_define_method(cPeripheral, "address_type", rb_peripheral_address_type, 0);
    rb_define_method(cPeripheral, "connectable?", rb_peripheral_connectable, 0);
    rb_define_method(cPeripheral, "connected?", rb_peripheral_connected, 0);
    rb_define_method(cPeripheral, "paired?", rb_peripheral_paired, 0);
    rb_define_method(cPeripheral, "connect", rb_peripheral_connect, 0);
    rb_define_method(cPeripheral, "disconnect", rb_peripheral_disconnect, 0);
    rb_define_method(cPeripheral, "unpair", rb_peripheral_unpair, 0);
}
