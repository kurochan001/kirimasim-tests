/*
:name: test_vpi_assertion_callback_handle_placement
:description: vpi_register_assertion_cb returns a callback handle when the callback is placed and NULL when it cannot be placed, the callback fires only for the events of its own assertion, and the handle removes it with vpi_remove_cb (IEEE 1800-2023 Section 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_callback_handle_placement.c
:expected_stdout: @test_vpi_assertion_callback_handle_placement.expected
*/
// IEEE 1800-2023 §39.4.2: an assertion callback belongs to the assertion it is
// placed on and does not fire for events of another assertion. When it is
// placed, vpi_register_assertion_cb returns a handle to it, which vpi_remove_cb
// takes to remove it (38.39); when it cannot be placed, it returns NULL. The
// reason has to be one of the assertion callback reasons, and the first
// argument a handle to an assertion.
// At 1, $vt_watch places a cbAssertionSuccess callback on a1 and tries to place
// one with the handle of the variable x instead of an assertion, and one on a1
// with cbValueChange, which is not an assertion callback reason; the last two
// give NULL. a1 needs x and a2 needs y; both are 1 at every tick (5, 15, 25,
// 35), so both succeed at each tick. The callback records the time and the name
// of the assertion it gets: a1 at 5 and 15, never a2. At 20, $vt_drop removes
// it with the handle that was returned, and it does not fire at 25 and 35. No
// simulator here runs the application: the expected output is derived from
// §39.4.2.

`timescale 1ns/1ns

module test_vpi_assertion_callback_handle_placement;
  logic clk = 0, x = 1, y = 1;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) x);
  a2: assert property (@(posedge clk) y);

  initial begin
    #1 $vt_watch;     // 1
    #19 $vt_drop;     // 20
    #20 $vt_report;   // 40
    $finish;
  end
endmodule
