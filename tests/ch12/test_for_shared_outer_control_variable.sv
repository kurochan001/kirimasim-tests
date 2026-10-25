/*
:name: test_for_shared_outer_control_variable
:description: A for loop can use a control variable declared before it, which another process can change while the loop runs, whereas a variable declared in the loop's initialization is not affected by that process (IEEE 1800-2023 Section 12.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_shared_outer_control_variable.expected
*/
// IEEE 1800-2023 §12.7.1: the control variable of a for loop can be
// declared before the loop; it is then an ordinary variable, and another
// process that uses it can change it while the loop is still using it. A
// variable declared in the initialization is local to the loop instead.
//
// Loop A counts the module variable k from 0 below 6 and waits 2 in each
// iteration; loop B declares its own k and does the same, one time unit
// later. At time 3 a third process sets the module's k to 4: loop A sees
// 4 at time 4 and ends after printing 5, loop B goes on with 0 to 5. Loop
// B does not read the module's k, so its print at time 3 does not depend on
// the order of the two processes at that time.

`timescale 1ns/1ns

module test_for_shared_outer_control_variable;
  int k;

  initial begin
    for (k = 0; k < 6; k++) begin
      #2 $display("t=%0t loop A (module k): k=%0d", $time, k);
    end
    $display("t=%0t loop A done: module k=%0d", $time, k);
  end

  initial begin
    #1;
    for (int k = 0; k < 6; k++) begin
      #2 $display("t=%0t loop B (own k): k=%0d", $time, k);
    end
  end

  initial #3 k = 4;
endmodule
