/*
:name: test_always_comb_sensitivity_exceptions
:description: The implicit sensitivity of always_comb leaves out variables it writes, the contents of called tasks and the expressions of assertion action blocks, but includes task arguments and the expression of an immediate assertion (IEEE 1800-2023 Section 9.2.2.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.1 9.2.2.2.2 16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_sensitivity_exceptions.expected
*/
// IEEE 1800-2023 §9.2.2.2.1: runs is both read and written by the block, so
// it is not in the sensitivity list and the block does not trigger itself.
// The argument a of the task call is in the list, but hidden, read only
// inside the task, is not. The expression of the immediate assertion counts as
// if it were the condition of an if statement, so e is in the list, while the
// action block, which reads verbose, adds nothing (16.3). The block runs once
// at time 0 (9.2.2.2.2); then hidden, a, e and verbose change one at a time,
// and only the changes of a and e run it again. y keeps its old value when
// hidden changes, since the block does not run.

`timescale 1ns/1ns

module test_always_comb_sensitivity_exceptions;
  logic [7:0] a = 8'd1, hidden = 8'd0, e = 8'd0, verbose = 8'd0;
  logic [7:0] y;
  int runs, reports;   // written only by the always_comb; int starts at 0

  task automatic add_hidden(input logic [7:0] v, output logic [7:0] r);
    r = v + hidden;
  endtask

  always_comb begin
    runs++;
    add_hidden(a, y);
    ia: assert (y != e) else if (verbose != 0) reports++;
  end

  initial begin
    #1 $display("start: runs %0d, y %0d", runs, y);
    hidden = 8'd5;
    #1 $display("hidden changed: runs %0d, y %0d", runs, y);
    a = 8'd2;
    #1 $display("a changed: runs %0d, y %0d", runs, y);
    e = 8'd9;
    #1 $display("e changed: runs %0d, y %0d", runs, y);
    verbose = 8'd1;
    #1 $display("verbose changed: runs %0d, y %0d, reports %0d", runs, y, reports);
  end
endmodule
