/*
:name: test_vpi_compatibility_1364v2005_variable_objects
:description: An application compiled with VPI_COMPATIBILITY_VERSION_1364v2005 calls the 1364v2005 variants of vpi_iterate, vpi_scan, vpi_handle_by_name and vpi_get, which give the IEEE 1364-2005 object model: vpiVariables without reg variables and reg arrays, vpiRegArray with arrays of reg only, and integer, time and real arrays as vpiIntegerVar, vpiTimeVar and vpiRealVar objects (IEEE 1800-2023 Sections 36.12.1 and 36.12.2.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.2.1 36.12.1 36.12.2 L.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compatibility_1364v2005_variable_objects.c
:expected_stdout: @test_vpi_compatibility_1364v2005_variable_objects.expected
*/
// IEEE 1800-2023 §36.12.2.1: an application that defines
// VPI_COMPATIBILITY_VERSION_1364v2005 as 1 before it includes vpi_user.h has
// its calls of the remapped routines, among them vpi_iterate, vpi_scan,
// vpi_handle_by_name and vpi_get, retargeted to their 1364v2005 variants
// (L.2), which behave as the VPI of IEEE 1364-2005 where Table 36-10 lists
// an incompatibility (36.12.1, 36.12.2). The design uses only constructs of
// IEEE 1364-2005, to which such an application may be applied (36.12.2).
//
// The application prints the routine names its calls expand to, and then:
// the vpiVariables iteration of the top module, which in IEEE 1364 excluded
// reg variables and reg arrays (Table 36-10, item 5), so it gives i, t and x
// but not r and mem; the vpiRegArray iteration of the instance arrays,
// which in IEEE 1364-2005 gave arrays of reg only (item 7), so rmem but not
// ia, ta or ra; and the type of each array of arrays found by name: an
// integer or time array was a vpiIntegerVar or vpiTimeVar object (item 3)
// and a real array a vpiRealVar object (item 4), where IEEE 1800 gives
// vpiRegArray (vpiArrayVar) for all four. Lists are sorted by name.
//
// The vpi_user.h of Icarus Verilog 13.0 and of Verilator 5.052 does not
// include vpi_compatibility.h, so the routine names are not remapped there,
// and Verilator 5.052 cannot call a system task registered by VPI.

module test_vpi_compatibility_1364v2005_variable_objects_arrays;
  reg [3:0] rmem [0:1];
  integer ia [0:1];
  time ta [0:1];
  real ra [0:1];
endmodule

module test_vpi_compatibility_1364v2005_variable_objects;
  reg r;
  reg [7:0] mem [0:3];
  integer i;
  time t;
  real x;

  test_vpi_compatibility_1364v2005_variable_objects_arrays arrays();

  initial #1 $vt_compat;
endmodule
