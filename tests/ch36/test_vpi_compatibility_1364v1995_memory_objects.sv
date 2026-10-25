/*
:name: test_vpi_compatibility_1364v1995_memory_objects
:description: An application compiled with VPI_COMPATIBILITY_VERSION_1364v1995 calls the 1364v1995 variants of vpi_handle_by_name, vpi_handle_by_index, vpi_iterate, vpi_scan and vpi_get, which give the IEEE 1364-1995 object model: a reg array is a vpiMemory object, its elements are vpiMemoryWord objects and an integer array is a vpiIntegerVar object (IEEE 1800-2023 Sections 36.12.1 and 36.12.2.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.2.1 36.12.1 36.12.2 L.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compatibility_1364v1995_memory_objects.c
:expected_stdout: @test_vpi_compatibility_1364v1995_memory_objects.expected
*/
// IEEE 1800-2023 §36.12.2.1: an application that defines
// VPI_COMPATIBILITY_VERSION_1364v1995 as 1 before it includes vpi_user.h has
// its calls of the remapped routines retargeted to their 1364v1995 variants
// (L.2), which behave as the VPI of IEEE 1364-1995 where Table 36-10 lists
// an incompatibility (36.12.1, 36.12.2). The design uses only constructs of
// IEEE 1364-1995.
//
// The application prints the routine names its calls expand to, and then
// the types of the objects it gets, where IEEE 1800 gives vpiRegArray and
// vpiReg: in IEEE 1364-1995 the reg array mem was a vpiMemory object (Table
// 36-10, item 1), found by name and by the vpiMemory iteration of the
// module, and its elements were vpiMemoryWord objects (item 2), given by
// vpi_handle_by_index and by the vpiMemoryWord iteration of mem; the integer
// array ia was a vpiIntegerVar object (item 3). The element mem[1], read
// through the 1364v1995 variant of vpi_get_value, holds 8'h5a (90), which shows
// that the index selects it.
//
// The vpi_user.h of Icarus Verilog 13.0 and of Verilator 5.052 does not
// include vpi_compatibility.h, so the routine names are not remapped there,
// and Verilator 5.052 cannot call a system task registered by VPI.

module test_vpi_compatibility_1364v1995_memory_objects;
  reg [7:0] mem [0:3];
  integer ia [0:1];

  initial begin
    mem[1] = 8'h5a;
    ia[0] = 1;
    #1 $vt_compat;
  end
endmodule
