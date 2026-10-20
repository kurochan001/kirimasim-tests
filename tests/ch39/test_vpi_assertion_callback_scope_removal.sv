/*
:name: test_vpi_assertion_callback_scope_removal
:description: An assertion callback fires only for the assertion it was placed on, two callbacks with the same reason both fire with their own user data, and vpi_remove_cb stops one of them (IEEE 1800-2023 Section 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 38.31
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_callback_scope_removal.c
:expected_stdout: @test_vpi_assertion_callback_scope_removal.expected
*/
// IEEE 1800-2023 §39.4.2: a callback placed on one assertion is called for the
// events of that assertion only, every time they occur, until it is removed
// with vpi_remove_cb (38.31), and it gets the user data given when it was
// placed. a1 needs x and a2 needs !x at each tick (5, 15, 25, 35); x is 1
// until 30. $vt_watch places two success callbacks on a1, with the user data
// "first" and "second", and a failure callback on a2; at 20 $vt_drop removes
// the second one, so only the first reports the success at 25. At 35 a2
// succeeds and a1 fails, which none of the callbacks is for. The events are
// sorted before they are printed.

`timescale 1ns/1ns

module test_vpi_assertion_callback_scope_removal;
  logic clk = 0, x = 1;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) x);
  a2: assert property (@(posedge clk) !x);

  initial begin
    $vt_watch;
    #20 $vt_drop;
    #10 x = 0;
    #10 $vt_report;
    $finish;
  end
endmodule
