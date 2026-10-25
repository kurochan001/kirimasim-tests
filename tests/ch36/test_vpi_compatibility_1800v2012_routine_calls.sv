/*
:name: test_vpi_compatibility_1800v2012_routine_calls
:description: An application compiled with VPI_COMPATIBILITY_VERSION_1800v2012 has each of the 14 remapped routine names expand to its 1800v2012 variant, and calls of all 14 variants do what the routines do in IEEE 1800-2012, which Table 36-10 lists as compatible with this standard (IEEE 1800-2023 Section 36.12.2.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.2.1 36.12.1 L.2 37.37 38.3 38.4 38.6 38.11 38.15 38.18 38.19 38.20 38.21 38.22 38.23 38.34 38.36 38.40
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compatibility_1800v2012_routine_calls.c
:expected_stdout: @test_vpi_compatibility_1800v2012_routine_calls.expected
*/
// IEEE 1800-2023 §36.12.2.1: when an application defines
// VPI_COMPATIBILITY_VERSION_1800v2012 as 1 before it includes vpi_user.h,
// vpi_compare_objects, vpi_control, vpi_get, vpi_get_str, vpi_get_value,
// vpi_handle, vpi_handle_by_index, vpi_handle_by_multi_index,
// vpi_handle_by_name, vpi_handle_multi, vpi_iterate, vpi_put_value,
// vpi_register_cb and vpi_scan become macros for their 1800v2012 variants
// (L.2), and the calls of the application use those variants. Table 36-10
// (36.12.1) gives the same column for IEEE 1800-2012 as for this standard,
// so the variants behave as the routines of chapter 38 here.
//
// The application prints the name each routine name expands to, and then
// calls every one of them at time 1: it finds r by name, prints its full
// name, its size (8) and value (8'h12, 18), writes 8'h34 (52) to it with no
// delay and reads it back, reads bit 2 of it by index (1), reads arr[1][2]
// by multiple indices (9), follows vpiModule from r to the top module,
// iterates the nets of the top module (w), compares two handles to r (1) and
// a handle to r with one to w (0), gets the intermodule path between the
// output port of s and the input port of d (37.37), and registers a
// callback for 2 time units later and one for the end of the simulation.
// The design prints r at 2, after the write; the callback at 3 prints r and
// calls vpi_control(vpiFinish, 0), so the simulation ends there (38.4), the
// end of simulation callback runs, and the display at 7 is never reached.
//
// The vpi_user.h of Icarus Verilog 13.0 and of Verilator 5.052 does not
// include vpi_compatibility.h, so the routine names are not remapped there;
// that of Icarus Verilog 13.0 does not declare vpi_handle_by_multi_index,
// and Verilator 5.052 cannot call a system task registered by VPI.

`timescale 1ns/1ns

module test_vpi_compatibility_1800v2012_routine_calls_src(output wire o);
  assign o = 1'b1;
endmodule

module test_vpi_compatibility_1800v2012_routine_calls_dst(input wire i);
endmodule

module test_vpi_compatibility_1800v2012_routine_calls;
  logic [7:0] r = 8'h12;
  logic [3:0] arr [0:1][0:2];
  wire w;

  test_vpi_compatibility_1800v2012_routine_calls_src s(.o(w));
  test_vpi_compatibility_1800v2012_routine_calls_dst d(.i(w));

  initial begin
    arr[1][2] = 4'd9;
    #1 $vt_calls;
    #1 $display("at 2: r = %h", r);
    #5 $display("at 7: still running");
  end
endmodule
