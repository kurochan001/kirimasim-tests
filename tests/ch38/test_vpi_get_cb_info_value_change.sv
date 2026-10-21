/*
:name: test_vpi_get_cb_info_value_change
:description: vpi_get_cb_info fills an s_cb_data structure with the reason, routine, trigger object and user data of each of two value change callbacks, one on a variable and one on a net (IEEE 1800-2023 Section 38.8)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.8 38.36.1 38.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_cb_info_value_change.c
:expected_stdout: @test_vpi_get_cb_info_value_change.expected
*/
// IEEE 1800-2023 §38.8: vpi_get_cb_info returns the information of a
// simulation callback in an s_cb_data structure that the application
// allocates. At the start of the simulation the application registers two
// cbValueChange callbacks (38.36.1) with the same routine, one on the variable
// r and one on the net w, each with its own user data, and reads the
// information of each from the handle that vpi_register_cb returned, with
// the time and value fields pointing at structures of its own, as the clause
// does not say whether the tool fills them or replaces the pointers. The
// trigger object is compared with r and w by vpi_compare_objects (38.3).
// Icarus Verilog 13.0 has no vpi_get_cb_info in its vpi_user.h, and Verilator
// 5.052 stops at it as unsupported.

module test_vpi_get_cb_info_value_change;
  logic [3:0] r = 4'd0;
  wire [3:0] w;

  assign w = ~r;

  initial #1 $display("design: done");
endmodule
