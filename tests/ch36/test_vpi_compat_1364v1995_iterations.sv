/*
:name: test_vpi_compat_1364v1995_iterations
:description: in the VPI compatibility mode 1364v1995, vpiVariables leaves out a reg variable and a reg array, the reg array is a vpiMemory object, and neither a vpiRegArray iteration nor a vpiReg iteration on a vpiRegArray applies (IEEE 1800-2023 Section 36.12.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.1 36.12.2.1 L.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compat_1364v1995_iterations.c
:expected_stdout: @test_vpi_compat_1364v1995_iterations.expected
*/
// IEEE 1800-2023 §36.12.1: Table 36-10 gives, for each version, which of nine
// VPI behaviors it has, and the details after it say what they were. In the
// column of IEEE Std 1364-1995
// 1) a one-dimensional unpacked reg array is a vpiMemory object, not a
//    vpiRegArray, and its words are vpiMemoryWord objects;
// 3) an unpacked array of integer or time variables is one vpiIntegerVar or
//    vpiTimeVar object;
// 5) vpiVariables leaves out vpiReg and vpiRegArray objects, so the scalar
//    reg and the reg array are absent from it while the integer, time and
//    real variables are present;
// 6) and 7) a vpiReg iteration on a vpiRegArray and a vpiRegArray iteration
//    that gives variable arrays do not apply, because the mode has no
//    vpiRegArray object at all.
// §36.12.2.1: an application that defines VPI_COMPATIBILITY_VERSION_1364v1995
// as 1 before it includes the VPI headers gets these behaviors, since
// vpi_user.h then makes vpi_iterate, vpi_scan, vpi_get, vpi_get_str,
// vpi_handle_by_name, vpi_handle_by_index and vpi_get_value the routines of
// that mode (L.2). §36.12.2: the mode is meant for designs made of the
// constructs of that version, as this one is; it therefore has no real array,
// which that version did not allow.
// The VPI application of this test defines the macro and, when its task runs
// after the assignments, prints the types it finds, whether the plain
// variables are in vpiVariables while the reg objects are not, whether
// vpiRegArray gives anything, and a value read through a vpiMemoryWord handle
// and through the scalar reg.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 provides the routines of
// the compatibility modes: their vpi_user.h does not remap the routines, so
// the application gets the behavior of the release itself.

module test_vpi_compat_1364v1995_iterations;
  reg [7:0] mem [0:3];
  integer ia [0:1];
  time ta [0:1];
  reg [3:0] rg;
  integer iv;
  time tv;
  real rv;

  initial begin
    mem[0] = 8'd1;
    ia[0] = 2;
    ta[0] = 3;
    rg = 4'd5;
    iv = 6;
    tv = 7;
    rv = 8.0;
    #1 $vt_compat;
    $display("design: %0d %0d %0d %0d %0d %0d %0.1f",
             mem[0], ia[0], ta[0], rg, iv, tv, rv);
  end
endmodule
