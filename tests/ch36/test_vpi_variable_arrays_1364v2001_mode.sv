/*
:name: test_vpi_variable_arrays_1364v2001_mode
:description: in the VPI compatibility mode 1364v2001, a reg array is a vpiMemory or a vpiRegArray and its word a vpiMemoryWord or a vpiReg, arrays of integer, time and real variables are vpiIntegerVar, vpiTimeVar and vpiRealVar objects, vpiVariables leaves out reg and reg array objects, and vpiRegArray gives no integer, time or real array (IEEE 1800-2023 Section 36.12.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.1 36.12.2.1 L.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_arrays_1364v2001_mode.c
:expected_stdout: @test_vpi_variable_arrays_1364v2001_mode.expected
*/
// IEEE 1800-2023 §36.12.1: Table 36-10 gives, for each version, which of nine
// VPI behaviors it has, and the details after it say what they were. In the
// column of IEEE Std 1364-2001
// 1) and 2) vpiMemory and vpiMemoryWord are object types that are deprecated:
//    an unpacked one-dimensional reg array can be a vpiMemory or a
//    vpiRegArray, and its words vpiMemoryWord or vpiReg objects;
// 3) and 4) an unpacked array of integer, time or real variables is a
//    vpiIntegerVar, vpiTimeVar or vpiRealVar object;
// 5) vpiVariables of a scope leaves out vpiReg and vpiRegArray objects;
// 6) vpiReg over a vpiRegArray gives only vpiReg objects;
// 7) vpiRegArray of a scope gives only arrays of vpiReg objects.
// §36.12.2.1: an application that defines VPI_COMPATIBILITY_VERSION_1364v2001
// as 1 before it includes the VPI headers gets this behavior, since
// vpi_user.h then makes vpi_iterate, vpi_scan, vpi_get, vpi_get_str,
// vpi_handle_by_name, vpi_handle_by_index and vpi_register_cb the routines
// of that mode (L.2). §36.12.2: the mode is meant for designs made of the
// constructs of that version, as this one is.
// The VPI application of this test defines the macro and, at the start of
// simulation, prints the types it finds, with its own names for the type
// constants.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 provides the routines of
// the compatibility modes: their vpi_user.h does not remap the routines, so
// the application gets the behavior of the release itself.

module test_vpi_variable_arrays_1364v2001_mode;
  reg [7:0] mem [0:3];
  integer ia [0:1];
  time ta [0:1];
  real ra [0:1];
  reg [3:0] rg;
  integer iv;
  time tv;
  real rv;

  initial begin
    mem[0] = 8'd1;
    ia[0] = 2;
    ta[0] = 3;
    ra[0] = 4.0;
    rg = 4'd5;
    iv = 6;
    tv = 7;
    rv = 8.0;
    #1 $display("design: %0d %0d %0d %0.1f %0d %0d %0d %0.1f",
                mem[0], ia[0], ta[0], ra[0], rg, iv, tv, rv);
  end
endmodule
