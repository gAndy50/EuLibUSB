----------------------------------
--EuLibUSB
--Written by Andy P.
--Icy Viking Games
--LibUSB wrapper for Euphoria
---------------------------------
without warning

include std/ffi.e
include std/machine.e
include std/os.e
include std/math.e

atom usb = 0

ifdef WINDOWS then
	usb = open_dll("libusb-1.0.dll")
	elsifdef LINUX or FREEBSD then
	usb = open_dll("libusb-1.0.so")
end ifdef

if usb = -1 then
	puts(1,"Failed to load shared library!\n")
	abort(0)
end if

public constant LIBUSB_API_VERSION = 0x01000109

--convert 16-bit value from host-endian to little endian
public constant tmp = define_c_union({
	{C_UINT8,2}, --b8
	C_UINT16
})

atom u = allocate_struct(tmp)

public function libusb_cpu_to_le16(atom x)
	sequence u = shift_bits(x,-8)
	return u
end function

public enum type libusb_class_code
	LIBUSB_CLASS_PER_INTERFACE = 0x00,
	LIBUSB_CLASS_AUDIO = 0x01,
	LIBUSB_CLASS_COMM = 0x02,
	LIBUSB_CLASS_HID = 0x03,
	LIBUSB_CLASS_PHYSICAL = 0x05,
	LIBUSB_CLASS_IMAGE = 0x06,
	LIBUSB_CLASS_PTP = 0x06,
	LIBUSB_CLASS_PRINTER = 0x07,
	LIBUSB_CLASS_MASS_STORAGE = 0x08,
	LIBUSB_CLASS_HUB = 0x09,
	LIBUSB_CLASS_DATA = 0x0a,
	LIBUSB_CLASS_SMART_CARD = 0x0b,
	LIBUSB_CLASS_CONTENT_SECURITY = 0x0d,
	LIBUSB_CLASS_VIDEO = 0x0e,
	LIBUSB_CLASS_PERSONAL_HEALTHCARE = 0x0f,
	LIBUSB_CLASS_DIANGNOSTIC_dEVICE = 0xdc,
	LIBUSB_CLASS_WIRELESS = 0xe0,
	LIBUSB_CLASS_MISCELLANEOUS = 0xef,
	LIBUSB_CLASS_APPLICATION = 0xfe,
	LIBUSB_CLASS_VENDOR_SPEC = 0xff
end type

public enum type libusb_descriptor_type
	LIBUSB_DT_DEVICE = 0x01,
	LIBUSB_DT_CONFIG = 0x02,
	LIBUSB_DT_STRING = 0x03,
	LIBUSB_DT_INTERFACE = 0x04,
	LIBUSB_DT_ENDPOINT = 0x05,
	LIBUSB_DT_BOS = 0x0f,
	LIBUSB_DT_DEVICE_CAPABILIY = 0x10,
	LIBUSB_DT_HID = 0x21,
	LIBUSB_DT_REPORT = 0x22,
	LIBUSB_DT_PHYSICAL = 0x23,
	LIBUSB_DT_HUB = 0x29,
	LIBUSB_DT_SUPERSPEED_HUB = 0x2a,
	LIBUSB_DT_SS_ENDPOINT_COMPANION = 0x30
end type

public constant LIBUSB_DT_DEVICE_SIZE = 18,
				LIBUSB_DT_CONFIG_sIZE = 9,
				LIBUSB_DT_INTERFACE_SIZE = 9,
				LIBUSB_DT_ENDPOINT_SIZE = 7,
				LIBUSB_DT_ENDPOINT_AUDI_SIZE = 9,
				LIBUSB_DT_HUB_NONVAR_SIZE = 7,
				LIBUSB_DT_SS_ENDPOINT_COMPANION_SIZE = 6,
				LIBUSB_DT_BOS_SIZE = 5,
				LIBUSB_DT_DEVICE_CAPABILITY_SIZE = 3
				
public constant LIBUSB_BT_USB_2_0_EXTENSION_SIZE = 7,
				LIBUSB_BT_SS_USB_DEVICE_CAPABILITY_SIZE = 10,
				LIBUSB_BT_CONTAINER_ID_SIZE = 20
				
public constant LIBUSB_DT_BOS_MAX_SIZE = LIBUSB_DT_BOS_SIZE + LIBUSB_BT_USB_2_0_EXTENSION_SIZE + LIBUSB_BT_SS_USB_DEVICE_CAPABILITY_SIZE + LIBUSB_BT_CONTAINER_ID_SIZE

public constant LIBUSB_ENDPOINT_ADDRESS_MASK = 0x0f,
				LIBUSB_ENDPOINT_DIR_MASK = 0x80
		
public enum type libusb_endpoint_direction
	LIBUSB_ENDPOINT_OUT = 0x00,
	LIBUSB_ENDPOINT_IN = 0x80
end type

public constant LIBUSB_TRANSFER_TYPE_MASK = 0x03

public enum type libusb_endpoint_transfer_type
	LIBUSB_ENDPOINT_TRANSFER_TYPE_CONTROL = 0x0,
	LIBUSB_ENDPOINT_TRANSFER_TYPE_ISOCHRONOUS = 0x1,
	LIBUSB_ENDPOINT_TRANSFER_TYPE_BULK = 0x2,
	LIBUSB_ENDPOINT_TRANSFER_TYPE_INTERRUPT = 0x3
end type

public enum type libusb_standard_request
	LIBUSB_REQUEST_GET_STATUS = 0x00,
	LIBUSB_REQUEST_CLEAR_FEATURE = 0x01,
	LIBUSB_REQUEST_SET_FEATURE = 0x03,
	LIBUSB_REQUEST_SET_ADDRESS = 0x05,
	LIBUSB_REQUEST_GET_DESCRIPTOR = 0x06,
	LIBUSB_REQUEST_SET_DESCRIPTOR = 0x07,
	LIBUSB_REQUEST_GET_CONFIGURATION = 0x08,
	LIBUSB_REQUEST_SET_CONFIGURATION = 0x09,
	LIBUSB_REQUEST_GET_INTERFACE = 0x0a,
	LIBUSB_REQUEST_SET_INTERFACE = 0x0b,
	LIBUSB_REQUEST_SYNCH_FRAME = 0x0c,
	LIBUSB_REQUEST_SET_SEL = 0x30,
	LIBUSB_SET_ISOCH_DELAY = 0x31
end type

public constant LIBUSB_REQUEST_TYPE_STANDARD = shift_bits(0x00,-5),
				LIBUSB_REQUEST_TYPE_CLASS = shift_bits(0x01,-5),
				LIBUSB_REQUEST_TYPE_VENDOR = shift_bits(0x02,-5),
				LIBUSB_REQUEST_TYPE_RESERVED = shift_bits(0x03,-5)
				
public enum type libusb_request_recipient
	LIBUSB_RECIPIENT_DEVICE = 0x00,
	LIBUSB_RECIPIENT_INTERFACE = 0x01,
	LIBUSB_RECIPIENT_ENDPOINT = 0x02,
	LIBUSB_RECIPIENT_OTHER = 0x03
end type

public constant LIBUSB_ISO_SYNC_TYPE_MASK = 0x0c

public enum type libusb_iso_sync_type
	LIBUSB_ISO_SYNC_TYPE_NONE = 0x0,
	LIBUSB_ISO_SYNC_TYPE_ASYNC = 0x1,
	LIBUSB_ISO_sYNC_TYPE_ADAPTIVE = 0x2,
	LIBUSB_ISO_SYNC_TYPE_SYNC = 0x3
end type

public constant LIBUSB_ISO_USAGE_TYPE_MASK = 0x30

public enum type libusb_iso_uage_type
	LIBUSB_ISO_USAGE_TYPE_DATA =  0x0,
	LIBUSB_ISO_USAGE_TYPE_FEEDBACK = 0x1,
	LIBUSB_ISO_USAGE_TYPE_IMPLICIT = 0x2
end type

public constant LIBUSB_LOW_SPEED_OPERATION = shift_bits(1,0),
				LIBUSB_FULL_SPEED_OPERATION = shift_bits(1,-1),
				LIBUSUB_HIGH_SPEED_OPERATION = shift_bits(1,-2),
				LIBUSUB_SUPER_SPEED_OPERATION = shift_bits(1,-3)
				
public constant LIBUSB_BM_LMP_SUPPORT = shift_bits(1,-1)

public constant LIBUSB_BM_LTM_SUPPORT = shift_bits(1,-1)

public enum type libusb_bos_type
	LIBUSB_BT_WIRELESS_USB_DEVICE_CAPABILITY = 0x01,
	LIBUSB_BT_USB_2_0_EXTENSION = 0x02,
	LIBUSB_BT_SS_USB_DEVICE_CAPABILITY=  0x03,
	LIBUSB_BT_CONTAINER_ID = 0x04
end type

public constant libusb_device_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT16, --bcdUSB
	C_UINT8, --bDeviceClass
	C_UINT8, --bDeviceSubClass
	C_UINT8, --bDeviceProtocol
	C_UINT8, --bMaxPacketSize0
	C_UINT16, --idVendor
	C_UINT16, --idProduct
	C_UINT16, --bcdDevice
	C_UINT8, --iManufacturer
	C_UINT8, --iProduct
	C_UINT8, --iSerialNumber
	C_UINT8 --bNumConfigurations
})

public constant libusb_endpoint_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT8, --bEndpointAddress
	C_UINT8, --bmAttributes
	C_UINT16, --wMaxPacketSize
	C_UINT8, --bInterval,
	C_UINT8, --bRefresh
	C_UINT8, --bSynchAddress
	C_POINTER, --extra
	C_INT --extra_length
})

public constant libusb_interface_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT8, --bInterfaceNumber
	C_UINT8, --bAlternateSetting
	C_UINT8, --bNumEndpoints
	C_UINT8, --bInterfaceClass
	C_UINT8, --bInterfaceSubClass
	C_UINT8, --bInterfaceProtocol,
	C_UINT8, --iInterface
	C_POINTER, --libusb_endpoint_descriptor *endpoint
	C_POINTER, --extra
	C_INT --extra_length
})

public constant libusb_interface = define_c_struct({
	C_POINTER, --libusb_interface_descriptor *altsetting
	C_INT --num_altsetting
})

public constant libusb_config_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT16, --wTotalLength
	C_UINT8, --bNumInterfaces
	C_UINT8, --bConfigurationValue
	C_UINT8, --iConfiguration
	C_UINT8, --bmAttributes
	C_UINT8, --MaxPower
	C_POINTER, --libusb_interface *interface
	C_POINTER, --extra
	C_INT --extra_length
})

public constant libusb_ss_endpoint_companion_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT8, --bMaxBurst
	C_UINT8, --bmAttributes
	C_UINT16 --wBytesPerInterval
})

public constant libusb_bos_dev_capability_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT8, --bDevCapabilityType
	C_UINT8 --dev_capability_data
})

public constant libusb_bos_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT16, --wTotalLength
	C_UINT8, --bNumDeviceCaps
	C_POINTER --libusb_bos_dev_capability_descriptor *dev_capability[ZERO_SIZED_ARRAY]
})

public constant libusb_usb_2_0_extension_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT8, --bDevCapabilityType
	C_UINT32 --bmAttributes
})

public constant libusb_ss_usb_device_capability_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT8, --dDevCapabilityType
	C_UINT8, --bmAttributes
	C_UINT16, --wSpeedSupported
	C_UINT8, --bFunctionalSupport
	C_UINT8, --bU1DeviExitat
	C_UINT16 --bU2DevExitat
})

public constant libusb_container_id_descriptor = define_c_struct({
	C_UINT8, --bLength
	C_UINT8, --bDescriptorType
	C_UINT8, --bDevCapabilityType
	C_UINT8, --bReserved
	{C_UINT8,16} --ContainerID[16]
})

public constant libusb_control_setup = define_c_struct({
	C_UINT8, --bmRequestType
	C_UINT8, --bRequest
	C_UINT16, --wValue
	C_UINT16, --wIndex
	C_UINT16 --wLength
})

public constant libusb_version = define_c_struct({
	C_UINT16, --major
	C_UINT16, --minor
	C_UINT16, --micro
	C_UINT16, --nano
	C_STRING, --rc
	C_STRING --describe
})

public enum type libusb_speed
	LIBUSB_SPEED_UNKNOWN = 0,
	LIBUSB_SPEED_LOW,
	LIBUSB_SPEED_FULL,
	LIBUSB_SPEED_HIGH,
	LIBUSB_SPEED_SUPER,
	LIBUSB_SPEED_SUPER_PLUS
end type

public enum type libusb_error
	LIBUSB_SUCCESS = 0,
	LIBUSB_ERROR_IO = -1,
	LIBUSB_ERROR_INVALID_PARAM = -2,
	LIBUSB_ERROR_ACCESS = -3,
	LIBUSB_ERROR_NO_DEVICE = -4,
	LIBUSB_ERROR_NOT_FOUND = -5,
	LIBUSB_ERROR_BUSY = -6,
	LIBUSB_ERROR_TIMEOUT = -7,
	LIBUSB_ERROR_OVERFLOW = -8,
	LIBUSB_ERROR_PIPE = -9,
	LIBUSB_ERROR_INTERRUPTED = -10,
	LIBUSB_ERROR_NO_MEM = -11,
	LIBUSB_ERROR_NOT_SUPPORTED = -12,
	LIBUSB_ERROR_OTHER = -99
end type

public constant LIBUSB_ERROR_COUNT = 14

public enum type libusb_transfer_type
	LIBUSB_TRANSFER_TYPE_CONTROL = 0,
	LIBUSB_TRANSFER_TYPE_ISOCHRONOUS = 1,
	LIBUSB_TRANSFER_TYPE_BULK = 2,
	LIBUSB_TRANSFER_TYPE_INTERRUPT = 3,
	LIBUSB_TRANSFER_TYPE_BULK_STREAM = 4
end type

public enum type libusb_transfer_status
	LIBUSB_TRANSFER_COMPLETED = 0,
	LIBUSB_TRANSFER_ERROR,
	LIBUSB_TRANSFER_TIMED_OUT,
	LIBUSB_TRANSFER_CANCELLED,
	LIBUSB_TRANSFER_STALL,
	LIBUSB_TRANSFER_NO_DEVICE,
	LIBUSB_TRANSFER_OVERFLOW
end type

public constant LIBUSB_TRANSFER_SHORT_NOT_OK = shift_bits(1,0),
				LIBUSB_TRANSFER_FREE_BUFFER = shift_bits(1,-1),
				LIBUSB_TRANSFER_FREE_TRANSFER = shift_bits(1,-2),
				LIBUSB_TRANSFER_ADD_ZERO_PACKET = shift_bits(1,-3)
				
public constant libusb_iso_packet_descriptor = define_c_struct({
	C_UINT, --length
	C_UINT, --actual_length
	C_INT --libusb_transfer_status status
})

public constant libusb_transfer = define_c_struct({
	C_POINTER, --libusb_device_handle *dev_handle
	C_UINT8, --flags
	C_UCHAR, --endpoint,
	C_UCHAR, --type
	C_UINT, --timeout
	C_INT, --libusb_transfer_status status
	C_INT, --length
	C_INT, --actual_length
	C_POINTER, --libusb_transfer_cb_fn callback
	C_POINTER, --user_data
	C_POINTER, --buffer
	C_INT, --num_iso_packets
	C_POINTER --libusb_iso_packet_descriptor
})

public enum type libusb_capability
	LIBUSB_CAP_HAS_CAPBILITY = 0x0000,
	LIBUSB_CAP_HAS_HOTPLUG = 0x0001,
	LIBUSB_CAP_HAS_HID_ACCESS = 0x0100,
	LIBUSB_CAP_SUPPORTS_DETACH_KERNEL_DRIVER = 0x0101
end type

public enum type libusb_log_level
	LIBUSB_LOG_LEVEL_NONE = 0,
	LIBUSB_LOG_LEVEL_ERROR,
	LIBUSB_LOG_LEVEL_WARNING,
	LIBUSB_LOG_LEVEL_INFO,
	LIBUSB_LOG_LEVEL_DEBUG
end type

public constant LIBUSB_LOG_B_GLOBAL = shift_bits(1,0),
				LIBUSB_LOG_CB_CONTEXT = shift_bits(1,-1)
				
export constant xlibusb_init = define_c_func(usb,"+libusb_init",{C_POINTER},C_INT)

public function libusb_init(atom ctx)
	return c_func(xlibusb_init,{ctx})
end function

export constant xlibusb_exit = define_c_proc(usb,"+libusb_exit",{C_POINTER})

public procedure libusb_exit(atom ctx)
	c_proc(xlibusb_exit,{ctx})
end procedure

export constant xlibusb_set_debug = define_c_proc(usb,"+libusb_set_debug",{C_POINTER,C_INT})

public procedure libusb_set_debug(atom ctx,atom lvl)
	c_proc(xlibusb_set_debug,{ctx,lvl})
end procedure

export constant xlibusb_set_log_cb = define_c_proc(usb,"+libusb_set_log_cb",{C_POINTER,C_INT,C_INT})

public procedure libusb_set_log_cb(atom ctx,atom b,atom mode)
	c_proc(xlibusb_set_log_cb,{ctx,b,mode})
end procedure

export constant xlibusb_get_version = define_c_func(usb,"+libusb_get_version",{},C_POINTER)

public function libusb_get_version()
	return c_func(xlibusb_get_version,{})
end function

export constant xlibusb_has_capability = define_c_func(usb,"+libusb_has_capability",{C_UINT32},C_INT)

public function libusb_has_capability(atom cap)
	return c_func(xlibusb_has_capability,{cap})
end function

export constant xlibusb_error_name = define_c_func(usb,"+libusb_error_name",{C_INT},C_STRING)

public function libusb_error_name(atom code)
	return c_func(xlibusb_error_name,{code})
end function

export constant xlibusb_setlocale = define_c_func(usb,"+libusb_setlocale",{C_STRING},C_INT)

public function libusb_setlocale(sequence loc)
	return c_func(xlibusb_setlocale,{loc})
end function

export constant xlibusb_strerror = define_c_func(usb,"+libusb_strerror",{C_INT},C_STRING)

public function libusb_strerror(atom code)
	return c_func(xlibusb_strerror,{code})
end function

export constant xlibusb_get_device_list = define_c_func(usb,"+libusb_get_device_list",{C_POINTER,C_POINTER},C_SIZE_T)

public function libusb_get_device_list(atom ctx,atom lst)
	return c_func(xlibusb_get_device_list,{ctx,lst})
end function

export constant xlibusb_free_device_list = define_c_proc(usb,"+libusb_free_device_list",{C_POINTER,C_INT})

public procedure libusb_free_device_list(atom lst,atom unref)
	c_proc(xlibusb_free_device_list,{lst,unref})
end procedure

export constant xlibusb_ref_device = define_c_func(usb,"+libusb_ref_device",{C_POINTER},C_POINTER)

public function libusb_ref_device(atom dev)
	return c_func(xlibusb_ref_device,{dev})
end function

export constant xlibusb_unref_device = define_c_proc(usb,"+libusb_unref_device",{C_POINTER})

public procedure libusb_unref_device(atom dev)
	c_proc(xlibusb_unref_device,{dev})
end procedure

export constant xlibusb_get_configuration = define_c_func(usb,"+libusb_get_configuration",{C_POINTER,C_POINTER},C_INT)

public function libusb_get_configuration(atom dev,atom fig)
	return c_func(xlibusb_get_configuration,{dev,fig})
end function

export constant xlibusb_get_device_descriptor = define_c_func(usb,"+libusb_get_device_descriptor",{C_POINTER,C_POINTER},C_INT)

public function libusb_get_device_descriptor(atom dev,atom desc)
	return c_func(xlibusb_get_device_descriptor,{dev,desc})
end function

export constant xlibusb_get_active_config_descriptor = define_c_func(usb,"+libusb_get_active_config_descriptor",{C_POINTER,C_POINTER},C_INT)

public function libusb_get_active_config_descriptor(atom dev,atom fig)
	return c_func(xlibusb_get_active_config_descriptor,{dev,fig})
end function

export constant xlibusb_get_config_descriptor = define_c_func(usb,"+libusb_get_config_descriptor",{C_POINTER,C_UINT8,C_POINTER},C_INT)

public function libusb_get_config_descriptor(atom dev,atom fig,atom sfig)
	return c_func(xlibusb_get_config_descriptor,{dev,fig,sfig})
end function

export constant xlibusb_get_config_descriptor_by_value = define_c_func(usb,"+libuse_get_config_descriptor_by_value",{C_POINTER,C_UINT8,C_POINTER},C_INT)

public function libusb_get_config_descriptor_by_value(atom dev,atom figval,atom fig)
	return c_func(xlibusb_get_config_descriptor_by_value,{dev,figval,fig})
end function

export constant xlibusb_free_config_descriptor = define_c_proc(usb,"+libusb_free_config_descriptor",{C_POINTER})

public procedure libusb_free_config_descriptor(atom fig)
	c_proc(xlibusb_free_config_descriptor,{fig})
end procedure

export constant xlibusb_get_ss_endpoint_companion_descriptor = define_c_func(usb,"+libusb_get_ss_endpoint_companion_descriptor",{C_POINTER,C_POINTER,C_POINTER},C_INT)

public function libusb_get_ss_endpoint_companion_descriptor(atom ctx,atom ep,atom ep_com)
	return c_func(xlibusb_get_ss_endpoint_companion_descriptor,{ctx,ep,ep_com})
end function

export constant xlibusb_free_ss_endpoint_companion_descriptor = define_c_proc(usb,"+libusb_free_ss_endpoint_companion_descriptor",{C_POINTER})

public procedure libusb_free_ss_endpoint_companion_descriptor(atom ep)
	c_proc(xlibusb_free_ss_endpoint_companion_descriptor,{ep})
end procedure

export constant xlibusb_get_bos_descriptor = define_c_func(usb,"+libusb_get_bos_descriptor",{C_POINTER,C_POINTER},C_INT)

public function libusb_get_bos_descriptor(atom dev,atom bos)
	return c_func(xlibusb_get_bos_descriptor,{dev,bos})
end function

export constant xlibusb_free_bos_descriptor = define_c_proc(usb,"+libusb_free_bos_descriptor",{C_POINTER})

public procedure libusb_free_bos_descriptor(atom bos)
	c_proc(xlibusb_free_bos_descriptor,{bos})
end procedure

export constant xlibusb_get_usb_2_0_extension_descriptor = define_c_func(usb,"+libusb_get_usb_2_0_extension_descriptor",{C_POINTER,C_POINTER,C_POINTER},C_INT)

public function libusb_get_usb_2_0_extension_descriptor(atom ctx,atom dev,atom ext)
	return c_func(xlibusb_get_usb_2_0_extension_descriptor,{ctx,dev,ext})
end function

export constant xlibusb_free_usb_2_0_extension_descriptor = define_c_proc(usb,"+libusb_free_usb_2_0_extension_descriptor",{C_POINTER})

public procedure libusb_free_usb_2_0_extension_descriptor(atom ext)
	c_proc(xlibusb_free_usb_2_0_extension_descriptor,{ext})
end procedure

export constant xlibusb_get_ss_usb_device_capability_descriptor = define_c_func(usb,"+libusb_get_ss_device_capability_descriptor",{C_POINTER,C_POINTER,C_POINTER},C_INT)

public function libusb_get_ss_usb_device_capability_descriptor(atom ctx,atom dev,atom usb)
	return c_func(xlibusb_get_ss_usb_device_capability_descriptor,{ctx,dev,usb})
end function

export constant xlibusb_free_ss_usb_device_capability_descriptor = define_c_proc(usb,"+libusb_free_ss_usb_device_capability_descriptor",{C_POINTER})

public procedure libusb_free_ss_usb_device_capability_descriptor(atom cap)
	c_proc(xlibusb_free_ss_usb_device_capability_descriptor,{cap})
end procedure

export constant xlibusb_get_container_id_descriptor = define_c_func(usb,"+libusb_get_container_id_descriptor",{C_POINTER,C_POINTER,C_POINTER},C_INT)

public function libusb_get_container_id_descriptor(atom ctx,atom dev,atom id)
	return c_func(xlibusb_get_container_id_descriptor,{ctx,dev,id})
end function

export constant xlibusb_free_container_id_descriptor = define_c_proc(usb,"+libusb_free_container_id_descriptor",{C_POINTER})

public procedure libusb_free_container_id_descriptor(atom id)
	c_proc(xlibusb_free_container_id_descriptor,{id})
end procedure

export constant xlibusb_get_bus_number = define_c_func(usb,"+libusb_get_bus_number",{C_POINTER},C_UINT8)

public function libusb_get_bus_number(atom dev)
	return c_func(xlibusb_get_bus_number,{dev})
end function

export constant xlibusb_get_port_number = define_c_func(usb,"+libusb_get_port_number",{C_POINTER},C_UINT8)

public function libusb_get_port_number(atom dev)
	return c_func(xlibusb_get_port_number,{dev})
end function

export constant xlibusb_get_port_numbers = define_c_func(usb,"+libusb_get_port_numbers",{C_POINTER,C_POINTER,C_INT},C_INT)

public function libusb_get_port_numbers(atom dev,atom num,atom len)
	return c_func(xlibusb_get_port_numbers,{dev,num,len})
end function

export constant xlibusb_get_port_path = define_c_func(usb,"+libusb_get_port_path",{C_POINTER,C_POINTER,C_POINTER,C_UINT8},C_INT)

public function libusb_get_port_path(atom ctx,atom dev,atom path,sequence len)
	return c_func(xlibusb_get_port_path,{ctx,dev,path,len})
end function

export constant xlibusb_get_parent = define_c_func(usb,"+libusb_get_parent",{C_POINTER},C_POINTER)

public function libusb_get_parent(atom dev)
	return c_func(xlibusb_get_parent,{dev})
end function

export constant xlibusb_get_device_address = define_c_func(usb,"+libusb_get_device_address",{C_POINTER},C_UINT8)

public function libusb_get_device_address(atom dev)
	return c_func(xlibusb_get_device_address,{dev})
end function

export constant xlibusb_get_device_speed = define_c_func(usb,"+libusb_get_device_speed",{C_POINTER},C_INT)

public function libusb_get_device_speed(atom dev)
	return c_func(xlibusb_get_device_speed,{dev})
end function

export constant xlibusb_get_max_packet_size = define_c_func(usb,"+libusb_get_max_packet_size",{C_POINTER,C_UCHAR},C_INT)

public function libusb_get_max_packet_size(atom dev,atom ep)
	return c_func(xlibusb_get_max_packet_size,{dev,ep})
end function

export constant xlibusb_get_max_iso_packet_size = define_c_func(usb,"+libusb_get_max_iso_packet_size",{C_POINTER,C_UCHAR},C_INT)

public function libusb_get_max_iso_packet_size(atom dev,atom ep)
	return c_func(xlibusb_get_max_iso_packet_size,{dev,ep})
end function

export constant xlibusb_wrap_sys_device = define_c_func(usb,"+libusb_wrap_sys_device",{C_POINTER,C_POINTER,C_POINTER},C_INT)

public function libusb_wrap_sys_device(atom ctx,atom dev,atom hand)
	return c_func(xlibusb_wrap_sys_device,{ctx,dev,hand})
end function

export constant xlibusb_open = define_c_func(usb,"+libusb_open",{C_POINTER,C_POINTER},C_INT)

public function libusb_open(atom dev,atom han)
	return c_func(xlibusb_open,{dev,han})
end function

export constant xlibusb_close = define_c_proc(usb,"+libusb_close",{C_POINTER})

public procedure libusb_close(atom han)
	c_proc(xlibusb_close,{han})
end procedure

export constant xlibusb_get_device = define_c_func(usb,"+libusb_get_device",{C_POINTER},C_POINTER)

public function libusb_get_device(atom dev)
	return c_func(xlibusb_get_device,{dev})
end function

export constant xlibusb_set_configuration = define_c_func(usb,"+libusb_set_configuration",{C_POINTER,C_INT},C_INT)

public function libusb_set_configuration(atom dev,atom fig)
	return c_func(xlibusb_set_configuration,{dev,fig})
end function

export constant xlibusb_claim_interface = define_c_func(usb,"+libusb_claim_interface",{C_POINTER,C_INT},C_INT)

public function libusb_claim_interface(atom dev,atom num)
	return c_func(xlibusb_claim_interface,{dev,num})
end function

export constant xlibusb_release_interface = define_c_func(usb,"+libusb_release_interface",{C_POINTER,C_INT},C_INT)

public function libusb_release_interface(atom dev,atom num)
	return c_func(xlibusb_release_interface,{dev,num})
end function

export constant xlibusb_open_device_with_vid_pid = define_c_func(usb,"+libusb_open_device_with_vid_pid",{C_POINTER,C_UINT16,C_UINT16},C_POINTER)

public function libusb_open_device_with_vid_pid(atom ctx,atom id,atom id2)
	return c_func(xlibusb_open_device_with_vid_pid,{ctx,id,id2})
end function

export constant xlibusb_set_interface_alt_setting = define_c_func(usb,"+libusb_set_interface_alt_setting",{C_POINTER,C_INT,C_INT},C_INT)

public function libusb_set_interface_alt_setting(atom dev,atom num,atom alt)
	return c_func(xlibusb_set_interface_alt_setting,{dev,num,alt})
end function

export constant xlibusb_clear_halt = define_c_func(usb,"+libusb_clear_halt",{C_POINTER,C_UCHAR},C_INT)

public function libusb_clear_halt(atom dev,atom ep)
	return c_func(xlibusb_clear_halt,{dev,ep})
end function

export constant xlibusb_reset_device = define_c_func(usb,"+libusb_reset_device",{C_POINTER},C_INT)

public function libusb_reset_device(atom dev)
	return c_func(xlibusb_reset_device,{dev})
end function

export constant xlibusb_alloc_streams = define_c_func(usb,"+libusb_alloc_streams",{C_POINTER,C_UINT32,C_POINTER,C_INT},C_INT)

public function libusb_alloc_streams(atom dev,atom num,atom ep,atom num_ep)
	return c_func(xlibusb_alloc_streams,{dev,num,ep,num_ep})
end function

export constant xlibusb_free_streams = define_c_func(usb,"+libusb_free_streams",{C_POINTER,C_POINTER,C_INT},C_INT)

public function libusb_free_streams(atom dev,atom ep,atom num)
	return c_func(xlibusb_free_streams,{dev,ep,num})
end function

export constant xlibusb_dev_mem_alloc = define_c_func(usb,"+libusb_dev_mem_alloc",{C_POINTER,C_SIZE_T},C_POINTER)

public function libusb_dev_mem_alloc(atom dev,atom len)
	return c_func(xlibusb_dev_mem_alloc,{dev,len})
end function

export constant xlibusb_dev_mem_free = define_c_func(usb,"+libusb_dev_mem_free",{C_POINTER,C_POINTER,C_SIZE_T},C_INT)

public function libusb_dev_mem_free(atom dev,atom buf,atom len)
	return c_func(xlibusb_dev_mem_free,{dev,buf,len})
end function

export constant xlibusb_kernel_driver_active = define_c_func(usb,"+libusb_kernel_driver_active",{C_POINTER,C_INT},C_INT)

public function libusb_kernel_driver_active(atom dev,atom num)
	return c_func(xlibusb_kernel_driver_active,{dev,num})
end function

export constant xlibusb_detach_kernel_driver = define_c_func(usb,"+libusb_detach_kernel_driver",{C_POINTER,C_INT},C_INT)

public function libusb_detach_kernel_driver(atom dev,atom num)
	return c_func(xlibusb_detach_kernel_driver,{dev,num})
end function

export constant xlibusb_attach_kernel_driver = define_c_func(usb,"+libusb_attach_kernel_driver",{C_POINTER,C_INT},C_INT)

public function libusb_attach_kernel_driver(atom dev,atom num)
	return c_func(xlibusb_attach_kernel_driver,{dev,num})
end function

export constant xlibusb_set_auto_detach_kernel_driver = define_c_func(usb,"+libusb_set_auto_detach_kernel_driver",{C_POINTER,C_INT},C_INT)

public function libusb_set_auto_detach_kernel_driver(atom dev,atom en)
	return c_func(xlibusb_set_auto_detach_kernel_driver,{dev,en})
end function

export constant xlibusb_alloc_transfer = define_c_func(usb,"+libusb_alloc_transfer",{C_INT},C_POINTER)

public function libusb_alloc_transfer(atom iso)
	return c_func(xlibusb_alloc_transfer,{iso})
end function

export constant xlibusb_submit_transfer = define_c_func(usb,"+libusb_submit_transfer",{C_POINTER},C_INT)

public function libusb_submit_transfer(atom trans)
	return c_func(xlibusb_submit_transfer,{trans})
end function

export constant xlibusb_cancel_transfer = define_c_func(usb,"+libusb_cancel_transfer",{C_POINTER},C_INT)

public function libusb_cancel_transfer(atom trans)
	return c_func(xlibusb_cancel_transfer,{trans})
end function

export constant xlibusb_free_transfer = define_c_proc(usb,"+libusb_free_transfer",{C_POINTER})

public procedure libusb_free_transfer(atom trans)
	c_proc(xlibusb_free_transfer,{trans})
end procedure

export constant xlibusb_transfer_set_stream_id = define_c_proc(usb,"+libusb_transfer_set_stream_id",{C_POINTER,C_UINT32})

public procedure libusb_transfer_set_stream_id(atom trans,atom id)
	c_proc(xlibusb_transfer_set_stream_id,{trans,id})
end procedure

export constant xlibusb_transfer_get_stream_id = define_c_func(usb,"+libusb_transfer_get_stream_id",{C_POINTER},C_UINT32)

public function libusb_transfer_get_stream_id(atom trans)
	return c_func(xlibusb_transfer_get_stream_id,{trans})
end function

export constant xlibusb_control_transfer = define_c_func(usb,"+libusb_control_transfer",{C_POINTER,C_UINT8,C_UINT8,C_UINT16,C_UINT16,C_POINTER,C_UINT16,C_UINT},C_INT)

public function libusb_control_transfer(atom dev,atom request,atom breq,atom wv,atom wi,atom dat,atom wlen,atom ti)
	return c_func(xlibusb_control_transfer,{dev,request,breq,wv,wi,dat,wlen,ti})
end function

export constant xlibusb_bulk_transfer = define_c_func(usb,"+libusb_bulk_transfer",{C_POINTER,C_UCHAR,C_POINTER,C_INT,C_POINTER,C_UINT},C_INT)

public function libusb_bulk_transfer(atom dev,atom ep,atom dat,atom len,atom alen,atom ti)
	return c_func(xlibusb_bulk_transfer,{dev,ep,dat,len,alen,ti})
end function

export constant xlibusb_interrupt_transfer = define_c_func(usb,"+libusb_interrupt_transfer",{C_POINTER,C_UCHAR,C_POINTER,C_INT,C_POINTER,C_UINT},C_INT)

public function libusb_interrupt_transfer(atom dev,atom ep,atom dat,atom len,atom alen,atom ti)
	return c_func(xlibusb_interrupt_transfer,{dev,ep,dat,len,alen,ti})
end function

export constant xlibusb_get_string_descriptor_ascii = define_c_func(usb,"+libusb_get_string_descriptor_ascii",{C_POINTER,C_UINT8,C_POINTER,C_INT},C_INT)

public function libusb_get_string_descriptor_ascii(atom dev,atom idx,atom dat,atom len)
	return c_func(xlibusb_get_string_descriptor_ascii,{dev,idx,dat,len})
end function

export constant xlibusb_try_lock_events = define_c_func(usb,"+libusb_try_lock_events",{C_POINTER},C_INT)

public function libusb_try_lock_events(atom ctx)
	return c_func(xlibusb_try_lock_events,{ctx})
end function

export constant xlibusb_lock_events = define_c_proc(usb,"+libusb_lock_events",{C_POINTER})

public procedure libusb_lock_events(atom ctx)
	c_proc(xlibusb_lock_events,{ctx})
end procedure

export constant xlibusb_unlock_events = define_c_proc(usb,"+libusb_unlock_events",{C_POINTER})

public procedure libusb_unlock_events(atom ctx)
	c_proc(xlibusb_unlock_events,{ctx})
end procedure

export constant xlibusb_event_handling_ok = define_c_func(usb,"+libusb_event_handling_ok",{C_POINTER},C_INT)

public function libusb_event_handling_ok(atom ctx)
	return c_func(xlibusb_event_handling_ok,{ctx})
end function

export constant xlibusb_event_handler_active = define_c_func(usb,"+libusb_event_handler_active",{C_POINTER},C_INT)

public function libusb_event_handler_active(atom ctx)
	return c_func(xlibusb_event_handler_active,{ctx})
end function

export constant xlibusb_interrupt_event_handler = define_c_proc(usb,"+libusb_interrupt_event_handler",{C_POINTER})

public procedure libusb_interrupt_event_handler(atom ctx)
	c_proc(xlibusb_interrupt_event_handler,{ctx})
end procedure

export constant xlibusb_lock_event_waiters = define_c_proc(usb,"+libusb_lock_event_waiters",{C_POINTER})

public procedure libusb_lock_event_waiters(atom ctx)
	c_proc(xlibusb_lock_event_waiters,{ctx})
end procedure

export constant xlibusb_unlock_event_waiters = define_c_proc(usb,"+libusb_unlock_event_waiters",{C_POINTER})

public procedure libusb_unlock_event_waiters(atom ctx)
	c_proc(xlibusb_unlock_event_waiters,{ctx})
end procedure

export constant xlibusb_wait_for_event = define_c_func(usb,"+liusb_wait_for_event",{C_POINTER,C_POINTER},C_INT)

public function libusb_wait_for_event(atom ctx,atom tv)
	return c_func(xlibusb_wait_for_event,{ctx,tv})
end function

export constant xlibusb_handle_events_timeout = define_c_func(usb,"+libusb_handle_events_timeout",{C_POINTER,C_POINTER},C_INT)

public function libusb_handle_events_timeout(atom ctx,atom tv)
	return c_func(xlibusb_handle_events_timeout,{ctx,tv})
end function

export constant xlibusb_handle_events_timeout_completed = define_c_func(usb,"+libusb_handle_events_timeout_completed",{C_POINTER,C_POINTER,C_POINTER},C_INT)

public function libusb_handle_events_timeout_completed(atom ctx,atom tv,atom com)
	return c_func(xlibusb_handle_events_timeout_completed,{ctx,tv,com})
end function

export constant xlibusb_handle_events = define_c_func(usb,"+libusb_handle_events",{C_POINTER},C_INT)

public function libusb_handle_events(atom ctx)
	return c_func(xlibusb_handle_events,{ctx})
end function

export constant xlibusb_handle_events_completed = define_c_func(usb,"+libusb_handle_events_completed",{C_POINTER,C_POINTER},C_INT)

public function libusb_handle_events_completed(atom ctx,atom com)
	return c_func(xlibusb_handle_events_completed,{ctx,com})
end function

export constant xlibusb_handle_events_locked = define_c_func(usb,"+libusb_handle_events_locked",{C_POINTER,C_POINTER},C_INT)

public function libusb_handle_events_locked(atom ctx,atom tv)
	return c_func(xlibusb_handle_events_locked,{ctx,tv})
end function

export constant xlibusb_pollfds_handle_timeouts = define_c_func(usb,"+libusb_pollfds_handle_timeouts",{C_POINTER},C_INT)

public function libusb_pollfds_handle_timeouts(atom ctx)
	return c_func(xlibusb_pollfds_handle_timeouts,{ctx})
end function

export constant xlibusb_get_next_timeout = define_c_func(usb,"+libusb_get_next_timeout",{C_POINTER,C_POINTER},C_INT)

public function libusb_get_next_timeout(atom ctx,atom tv)
	return c_func(xlibusb_get_next_timeout,{ctx,tv})
end function

public constant libusb_pollfd = define_c_struct({
	C_INT, --fd
	C_SHORT --events
})

export constant xlibusb_get_pollfds = define_c_func(usb,"+libusb_get_pollfds",{C_POINTER},C_POINTER)

public function libusb_get_pollfds(atom ctx)
	return c_func(xlibusb_get_pollfds,{ctx})
end function

export constant xlibusb_free_pollfds = define_c_proc(usb,"+libusb_free_pollfds",{C_POINTER})

public procedure libusb_free_pollfds(atom pd)
	c_proc(xlibusb_free_pollfds,{pd})
end procedure

export constant xlibusb_set_pollfd_notifiers = define_c_proc(usb,"+libusb_set_pollfd_notifiers",{C_POINTER,C_POINTER,C_POINTER,C_POINTER})

public procedure libusb_set_pollfd_notifiers(atom ctx,atom add_cb,atom remove_cb,atom ud)
	c_proc(xlibusb_set_pollfd_notifiers,{ctx,add_cb,remove_cb,ud})
end procedure

public constant LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED = shift_bits(1,0),
				LIBUSB_HOTPLUG_EVENT_DEVICE_LEFT = shift_bits(1,-1)
				
public constant LIBUSB_HOTPLUG_ENUMERATE = shift_bits(1,0)

public constant LIBUSB_HOTPLUG_NO_FLAGS = 0
public constant LIBUSB_HOTPLUG_MATCH_ANY = -1

export constant xlibusb_hotplug_register_callback = define_c_func(usb,"+libusb_hotplug_register_callback",{C_POINTER,C_INT,C_INT,C_INT,C_INT,C_INT,C_POINTER,C_POINTER,C_POINTER},C_INT)

public function libusb_hotplug_register_callback(atom ctx,atom events,atom flags,atom id,atom pid,atom dev,atom cb,atom ud,atom cb_handle)
	return c_func(xlibusb_hotplug_register_callback,{ctx,events,flags,id,pid,dev,cb,ud,cb_handle})
end function

export constant xlibusb_hotplug_deregister_callback = define_c_proc(usb,"+libusb_hotplug_deregister_callback",{C_POINTER,C_POINTER})

public procedure libusb_hotplug_deregister_callback(atom ctx,atom cb)
	c_proc(xlibusb_hotplug_deregister_callback,{ctx,cb})
end procedure

export constant xlibusb_hotplug_get_user_data = define_c_func(usb,"+libusb_hotplug_get_user_data",{C_POINTER,C_POINTER},C_POINTER)

public function libusb_hotplug_get_user_data(atom ctx,atom cb)
	return c_func(xlibusb_hotplug_get_user_data,{ctx,cb})
end function

public enum type libusb_option
	LIBUSB_OPTION_LOG_LEVEL = 0,
	LIBUSB_OPTION_USE_USBDK = 1,
	LIBUSB_OPTION_NO_DEVICE_DISCOVERY = 2,
	LIBUSB_OPTION_MAX = 3
end type

export constant xlibusb_set_option = define_c_func(usb,"+libusb_set_option",{C_POINTER,C_INT},C_INT)

public function libusb_set_option(atom ctx,atom opt)
	return c_func(xlibusb_set_option,{ctx,opt})
end function
­953.44