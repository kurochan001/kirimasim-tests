/*
:name: test_vpi_vlog_info_structure
:description: vpi_get_vlog_info returns 1 and fills s_vpi_vlog_info with argc, argv of argc NUL-terminated strings, and product and version strings, in the listed field order and types, with the plusargs at the end of argv (IEEE 1800-2023 Section 38.17)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.17 38.13
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +vt_alpha +vt_count=3
:vpi_c: @test_vpi_vlog_info_structure.c
:expected_stdout: @test_vpi_vlog_info_structure.expected
*/
// IEEE 1800-2023 §38.17: vpi_get_vlog_info returns 1 on success and fills an
// s_vpi_vlog_info structure that the application allocates. The structure has
// PLI_INT32 argc, PLI_BYTE8** argv, and the PLI_BYTE8* product and version, in
// that order. argv holds argc pointers to NUL-terminated strings from the
// tool's command line; argv[0] is the tool's name. The plusargs +vt_alpha and
// +vt_count=3 are the last two entries of argv, in the order given.
//
// The application runs at the start of the simulation and prints the
// compile-time checks of the field types and order, whether every argv entry
// is a string, whether product and version are strings, that argv[0] is not
// empty and not a plusarg, and the last two plusargs in order.

module test_vpi_vlog_info_structure;
  initial begin
    #1 $finish;
  end
endmodule
