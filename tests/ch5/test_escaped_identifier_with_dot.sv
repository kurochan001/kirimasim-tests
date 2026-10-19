/*
:name: test_escaped_identifier_with_dot
:description: An escaped identifier that contains a period is one simple name, distinct from the hierarchical name with the same characters (IEEE 1800-2023 Section 5.6.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.1 23.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_escaped_identifier_with_dot.expected
*/
// IEEE 1800-2023 §5.6.1: an escaped identifier takes every printable
// character up to the next white space, a period included, and is a single
// simple identifier. So \blk.bv names a variable of its own, not the
// variable bv of the named block blk (23.6), and writing one does not change
// the other. An escaped name with a period can also be the last part of a
// hierarchical name, as in c.\w.x .

module dotted_holder;
  logic [31:0] \w.x ;
  initial \w.x = 32'd11;
endmodule

module test_escaped_identifier_with_dot;
  dotted_holder c ();

  initial begin : blk
    logic [7:0] bv;
    bv = 8'hf0;
  end

  logic [7:0] \blk.bv ;

  initial begin
    #2 \blk.bv = 8'h55;
    #1 $display("blk.bv=%h", blk.bv);
    $display("escaped blk.bv=%h", \blk.bv );
    $display("c.w.x=%0d", c.\w.x );
  end
endmodule
