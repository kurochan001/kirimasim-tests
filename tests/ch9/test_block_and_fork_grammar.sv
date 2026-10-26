/*
:name: test_block_and_fork_grammar
:description: a sequential block takes declarations before statements and a closing name, and named and unnamed fork blocks take join, join_any and join_none with their termination rules (IEEE 1800-2023 9.3.1, 9.3.2, 9.3.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.1 9.3.2 9.3.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_block_and_fork_grammar.expected
*/
// IEEE 1800-2023 §9.3.1: a sequential block may have opening and closing
// names and declares its block items before its statements. §9.3.2: a fork
// block may have a name and declarations, and ends with join, join_any or
// join_none. §9.3.4: the matching name may follow the closing keyword. The
// test declares x and a localparam in the named outer block, y in the named
// inner block, and z in the named fork before its branches; it ends them with
// their names and runs the fork with two branches under join
// (which waits for both, so "joined" follows both prints), a fork under
// join_any (which resumes at the first branch and leaves the other to print
// later), and a fork under join_none with wait fork (which waits for both
// children). A block that ignores its declarations or a fork that resumes at
// the wrong time prints a different line or order.

`timescale 1ns/1ps

module test_block_and_fork_grammar;
  initial begin : outer
    int x;
    localparam int K = 1;
    x = K;
    begin : seq
      int y;
      y = x + 1;
      $display("seq y=%0d", y);
    end : seq
    fork : par
      int z;
      begin
        z = 2;
        $display("fork a z=%0d", z);
        #2;
      end
      begin
        #1;
        $display("fork b");
      end
    join : par
    $display("joined");
    fork
      #1 $display("any1");
      #3 $display("any3");
    join_any
    #4 $display("after any");
    fork
      #1 $display("wf1");
      #2 $display("wf2");
    join_none
    wait fork;
    $display("waitfork %0d", $time);
    $finish;
  end : outer
endmodule
