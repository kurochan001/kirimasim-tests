#ifndef VPI_PROTECTED_ACCESS_ADAPTER_H
#define VPI_PROTECTED_ACCESS_ADAPTER_H

#include "vpi_user.h"

#ifdef REFERENCE_ACCESS
PLI_INT32 access_get(PLI_INT32 property, vpiHandle object);
PLI_INT64 access_get64(PLI_INT32 property, vpiHandle object);
PLI_BYTE8 *access_get_str(PLI_INT32 property, vpiHandle object);
vpiHandle access_handle(PLI_INT32 type, vpiHandle object);
vpiHandle access_index(vpiHandle object, PLI_INT32 index);
vpiHandle access_multi_index(vpiHandle object, PLI_INT32 count, PLI_INT32 *indices);
vpiHandle access_name(PLI_BYTE8 *name, vpiHandle scope);
vpiHandle access_iterate(PLI_INT32 type, vpiHandle object);
vpiHandle access_scan(vpiHandle iterator);
PLI_INT32 access_error(p_vpi_error_info info);
#else
#define access_get vpi_get
#define access_get64 vpi_get64
#define access_get_str vpi_get_str
#define access_handle vpi_handle
#define access_index vpi_handle_by_index
#define access_multi_index vpi_handle_by_multi_index
#define access_name vpi_handle_by_name
#define access_iterate vpi_iterate
#define access_scan vpi_scan
#define access_error vpi_chk_error
#endif

#endif
