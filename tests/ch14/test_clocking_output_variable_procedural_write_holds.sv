/*
:name: test_clocking_output_variable_procedural_write_holds
:description: A variable associated with a clocking output can also be written by a procedural assignment, and it keeps that value across clocking events without a drive until another drive or assignment changes it (IEEE 1800-2023 Section 14.16.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_output_variable_procedural_write_holds.expected
*/
// IEEE 1800-2023 §14.16.2: a procedural assignment can write a variable
// associated with an output clockvar; the variable then holds that value
// until another assignment, by a drive or procedurally, happens. A clocking
// output only assigns its signal in the cycles where a drive occurs.
//
// The posedges are at 5, 15, 25, 35. The drive at 5 sets v to 1; at 8 a
// procedural assignment sets it to 5, which stays at the events at 15 and
// 25, where nothing is driven; a drive executed at 28 sets 7 at 35; at 38
// the procedural assignment v = 9 stays at the event at 45.

`timescale 1ns/1ns

module test_clocking_output_variable_procedural_write_holds;
  logic clk = 0;
  int v = 0;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    output v;
  endclocking

  initial begin
    @(cb);
    cb.v <= 1;
    #1 $display("t=%0t v=%0d", $time, v);
    #2 v = 5;
    #1 $display("t=%0t v=%0d", $time, v);
    #7 $display("t=%0t v=%0d", $time, v);
    #10 $display("t=%0t v=%0d", $time, v);
    #2 cb.v <= 7;
    #6 $display("t=%0t v=%0d", $time, v);
    #2 $display("t=%0t v=%0d", $time, v);
    #2 v = 9;
    #8 $display("t=%0t v=%0d", $time, v);
    $finish;
  end
endmodule
