#include <ruby.h>
#include "simpleble_wrapper.h"

// Module and class definitions
static VALUE mSimpleBLE;
static VALUE cAdapter;
static VALUE cPeripheral;
static VALUE cService;
static VALUE cCharacteristic;
static VALUE cDescriptor;

// Exception classes
static VALUE eSimpleBLEError;
static VALUE eNotSupportedError;
static VALUE eBluetoothNotAvailableError;
static VALUE eNotConnectedError;
static VALUE eConnectionError;
static VALUE eScanError;
static VALUE eCharacteristicError;
static VALUE eTimeoutError;

// Ruby object data structures
typedef struct {
    void* adapter_handle;
    VALUE scan_start_callback;
    VALUE scan_stop_callback;
    VALUE scan_found_callback;
    VALUE scan_updated_callback;
} adapter_data_t;

typedef struct {
    void* peripheral_handle;
    VALUE connected_callback;
    VALUE disconnected_callback;
} peripheral_data_t;

// Memory management functions
static void adapter_free(void* ptr) {
    adapter_data_t* data = (adapter_data_t*)ptr;
    if (data->adapter_handle) {
        simpleble_adapter_release(data->adapter_handle);
    }
    xfree(data);
}

static const rb_data_type_t adapter_type = {
    "SimpleBLE::Adapter",
    {0, adapter_free, 0},
    0, 0,
    RUBY_TYPED_FREE_IMMEDIATELY
};

static void peripheral_free(void* ptr) {
    peripheral_data_t* data = (peripheral_data_t*)ptr;
    if (data->peripheral_handle) {
        simpleble_peripheral_release(data->peripheral_handle);
    }
    xfree(data);
}

static const rb_data_type_t peripheral_type = {
    "SimpleBLE::Peripheral",
    {0, peripheral_free, 0},
    0, 0,
    RUBY_TYPED_FREE_IMMEDIATELY
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
    return simpleble_adapter_bluetooth_enabled() ? Qtrue : Qfalse;
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
        void* adapter_handle = simpleble_adapter_get_handle(i);
        if (adapter_handle) {
            adapter_data_t* data = ALLOC(adapter_data_t);
            data->adapter_handle = adapter_handle;
            data->scan_start_callback = Qnil;
            data->scan_stop_callback = Qnil;
            data->scan_found_callback = Qnil;
            data->scan_updated_callback = Qnil;
            
            VALUE adapter = TypedData_Wrap_Struct(cAdapter, &adapter_type, data);
            rb_ary_push(adapters, adapter);
        }
    }
    
    return adapters;
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
    simpleble_free(identifier);
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
    simpleble_free(address);
    return result;
}

/*
 * call-seq:
 *   adapter.scan_start -> nil
 *
 * Start scanning for peripherals.
 */
static VALUE
rb_adapter_scan_start(VALUE self)
{
    adapter_data_t* data;
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    
    simpleble_err_t err = simpleble_adapter_scan_start(data->adapter_handle);
    if (err != SIMBLEBLE_SUCCESS) {
        rb_raise(eScanError, "Failed to start scan");
    }
    
    return Qnil;
}

/*
 * call-seq:
 *   adapter.scan_stop -> nil
 *
 * Stop scanning for peripherals.
 */
static VALUE
rb_adapter_scan_stop(VALUE self)
{
    adapter_data_t* data;
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    
    simpleble_err_t err = simpleble_adapter_scan_stop(data->adapter_handle);
    if (err != SIMBLEBLE_SUCCESS) {
        rb_raise(eScanError, "Failed to stop scan");
    }
    
    return Qnil;
}

/*
 * call-seq:
 *   adapter.scan_for(timeout_ms) -> nil
 *
 * Scan for peripherals for the specified timeout in milliseconds.
 */
static VALUE
rb_adapter_scan_for(VALUE self, VALUE timeout)
{
    adapter_data_t* data;
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    
    Check_Type(timeout, T_FIXNUM);
    int timeout_ms = NUM2INT(timeout);
    
    if (timeout_ms <= 0) {
        rb_raise(rb_eArgError, "timeout must be greater than 0");
    }
    
    simpleble_err_t err = simpleble_adapter_scan_for(data->adapter_handle, timeout_ms);
    if (err != SIMBLEBLE_SUCCESS) {
        rb_raise(eScanError, "Failed to scan for devices");
    }
    
    return Qnil;
}

/*
 * call-seq:
 *   adapter.scan_active? -> Boolean
 *
 * Check if scanning is currently active.
 */
static VALUE
rb_adapter_scan_active(VALUE self)
{
    adapter_data_t* data;
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    
    bool active;
    simpleble_err_t err = simpleble_adapter_scan_is_active(data->adapter_handle, &active);
    if (err != SIMBLEBLE_SUCCESS) {
        rb_raise(eScanError, "Failed to check scan status");
    }
    
    return active ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *   adapter.scan_results -> Array
 *
 * Get array of discovered peripherals from last scan.
 */
static VALUE
rb_adapter_scan_results(VALUE self)
{
    adapter_data_t* data;
    TypedData_Get_Struct(self, adapter_data_t, &adapter_type, data);
    check_adapter_data(data);
    
    size_t count = simpleble_adapter_scan_get_results_count(data->adapter_handle);
    VALUE peripherals = rb_ary_new_capa(count);
    
    for (size_t i = 0; i < count; i++) {
        void* peripheral_handle = simpleble_adapter_scan_get_results_handle(data->adapter_handle, i);
        if (peripheral_handle) {
            peripheral_data_t* pdata = ALLOC(peripheral_data_t);
            pdata->peripheral_handle = peripheral_handle;
            pdata->connected_callback = Qnil;
            pdata->disconnected_callback = Qnil;
            
            VALUE peripheral = TypedData_Wrap_Struct(cPeripheral, &peripheral_type, pdata);
            rb_ary_push(peripherals, peripheral);
        }
    }
    
    return peripherals;
}

// Module initialization
void Init_simpleble(void)
{
    // Define main module
    mSimpleBLE = rb_define_module("SimpleBLE");
    
    // Define classes
    cAdapter = rb_define_class_under(mSimpleBLE, "Adapter", rb_cObject);
    cPeripheral = rb_define_class_under(mSimpleBLE, "Peripheral", rb_cObject);
    cService = rb_define_class_under(mSimpleBLE, "Service", rb_cObject);
    cCharacteristic = rb_define_class_under(mSimpleBLE, "Characteristic", rb_cObject);
    cDescriptor = rb_define_class_under(mSimpleBLE, "Descriptor", rb_cObject);
    
    // Define exception classes
    eSimpleBLEError = rb_define_class_under(mSimpleBLE, "Error", rb_eStandardError);
    eNotSupportedError = rb_define_class_under(mSimpleBLE, "NotSupportedError", eSimpleBLEError);
    eBluetoothNotAvailableError = rb_define_class_under(mSimpleBLE, "BluetoothNotAvailableError", eSimpleBLEError);
    eNotConnectedError = rb_define_class_under(mSimpleBLE, "NotConnectedError", eSimpleBLEError);
    eConnectionError = rb_define_class_under(mSimpleBLE, "ConnectionError", eSimpleBLEError);
    eScanError = rb_define_class_under(mSimpleBLE, "ScanError", eSimpleBLEError);
    eCharacteristicError = rb_define_class_under(mSimpleBLE, "CharacteristicError", eSimpleBLEError);
    eTimeoutError = rb_define_class_under(mSimpleBLE, "TimeoutError", eSimpleBLEError);
    
    // Define Adapter class methods
    rb_define_singleton_method(cAdapter, "bluetooth_enabled?", rb_adapter_bluetooth_enabled, 0);
    rb_define_singleton_method(cAdapter, "get_adapters", rb_adapter_get_adapters, 0);
    
    // Define Adapter instance methods
    rb_define_method(cAdapter, "identifier", rb_adapter_identifier, 0);
    rb_define_method(cAdapter, "address", rb_adapter_address, 0);
    rb_define_method(cAdapter, "scan_start", rb_adapter_scan_start, 0);
    rb_define_method(cAdapter, "scan_stop", rb_adapter_scan_stop, 0);
    rb_define_method(cAdapter, "scan_for", rb_adapter_scan_for, 1);
    rb_define_method(cAdapter, "scan_active?", rb_adapter_scan_active, 0);
    rb_define_method(cAdapter, "scan_results", rb_adapter_scan_results, 0);
    
    // TODO: Add peripheral methods, callbacks, etc.
}