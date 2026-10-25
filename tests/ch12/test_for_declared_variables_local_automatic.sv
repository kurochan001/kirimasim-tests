/*
:name: test_for_declared_variables_local_automatic
:description: A for loop that declares its variables wraps itself in an implicit block holding automatic loop variables, named by a statement label, while a for loop that only assigns an outer variable creates no scope and uses that variable (IEEE 1800-2023 Section 12.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1 9.3.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_declared_variables_local_automatic.expected
*/
// IEEE 1800-2023 §12.7.1: declaring the control variables in the
// initialization of a for loop creates an implicit begin-end block around
// the loop, which declares them with automatic lifetime in a new scope; a
// statement label on such a loop names that block (9.3.5). Only loops that
// declare variables get the implicit block.
//
// The module has a variable i = 100. In the named block blk:
//   - for (int i = ...) declares its own i, so the module's i stays 100;
//   - for (i = ...) declares nothing and counts the module's i up to 3, and
//     %m in its body is the name of blk itself, with no extra scope;
//   - a labelled for (int k = ...) has %m ending in the label.
// The static task run3 has a for loop that declares j and waits 2 in each
// iteration. It is called by two processes that overlap in time (from 0
// and from 1). j is automatic, so each call has its own j and both print
// j = 0, 1, 2; one static j shared by both calls would be changed by the
// other call.
//
// Simulator notes: Icarus Verilog 13.0 rejects the statement label before a
// for loop, and without that line it shares j between the two calls of run3
// (it prints t=13 j=1, t=14 j=2, t=15 j=3). In a run with Verilator 5.052
// %m in the labelled loop ends in lbl.unnamedblk3: the label makes a block
// of its own around the implicit block instead of naming it. Both differ
// from 12.7.1 and 9.3.5.

`timescale 1ns/1ns

module test_for_declared_variables_local_automatic;
  int i = 100;

  task run3(); // static task: its ordinary locals would be shared
    for (int j = 0; j < 3; j++) begin
      #2 $display("t=%0t j=%0d", $time, j);
    end
  endtask

  initial begin : blk
    for (int i = 0; i < 2; i++) ;
    $display("after for (int i ...): module i=%0d", i);
    for (i = 0; i < 3; i++) ;
    $display("after for (i = 0 ...): module i=%0d", i);
    for (i = 0; i < 1; i++) $display("body of for (i = 0 ...): %m");
    lbl: for (int k = 0; k < 1; k++) $display("body of lbl: for (int k ...): %m");
  end

  initial begin
    #10;
    fork
      run3();
      #1 run3();
    join
    $display("t=%0t done", $time);
  end
endmodule
