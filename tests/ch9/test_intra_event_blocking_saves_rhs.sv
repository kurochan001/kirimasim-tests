/*
:name: test_intra_event_blocking_saves_rhs
:description: a blocking assignment with an intra-assignment event control reads its right-hand side when reached, blocks its process until the event, and only then writes the saved value (IEEE 1800-2023 Section 9.4.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_intra_event_blocking_saves_rhs.expected
*/
// IEEE 1800-2023 §9.4.5 and Table 9-3: "a = @(posedge clk) b;" behaves like
// copying b to a temporary, waiting for the posedge of clk, and then
// assigning the temporary to a. So the value of b at the time the statement
// is reached is the one assigned, a keeps its old value until the event, and
// the next statement of the process runs only after the event.
//
// The statement is reached at time 2 with b = 1. b becomes 7 at time 3; a is
// still 0 when another process looks at time 4; the posedge comes at time 5,
// and the statement after the assignment sees a = 1 (the saved value) and
// b = 7. A second assignment waits for a named event: b + 1 = 21 is saved at
// time 5, b becomes 30 at time 7, a is still 1 at time 8, and the event is
// triggered at time 9, when a becomes 21.

`timescale 1ns/1ns
module test_intra_event_blocking_saves_rhs;
  logic clk = 0;
  event go;
  int a = 0, b = 1;

  initial begin
    #2;
    a = @(posedge clk) b;
    $display("t=%0t after posedge: a=%0d b=%0d", $time, a, b);
    b = 20;
    a = @(go) b + 1;
    $display("t=%0t after go: a=%0d b=%0d", $time, a, b);
  end

  initial begin
    #3 b = 7;
    #1 $display("t=%0t before posedge: a=%0d", $time, a);
    #3 b = 30;
    #1 $display("t=%0t before go: a=%0d", $time, a);
    #1 -> go;
  end

  initial #5 clk = 1;
endmodule
