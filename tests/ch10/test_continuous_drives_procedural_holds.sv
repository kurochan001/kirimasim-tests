/*
:name: test_continuous_drives_procedural_holds
:description: a continuous assignment to a net and to a variable follows its right-hand side whenever an operand changes, a procedural assignment puts a value that the variable holds until the next assignment, and = and <= separate the two sides (IEEE 1800-2023 Section 10.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.2 10.3.2 10.4.1 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_continuous_drives_procedural_holds.expected
*/
// IEEE 1800-2023 §10.2: a continuous assignment drives a net or a variable
// continuously, like a combinational circuit; a procedural assignment puts a
// value into a variable, which then holds it until the next procedural
// assignment. The two sides of an assignment are separated by =, or by <= in
// a nonblocking procedural assignment, and the right-hand side is an
// expression.
//
// net_sum (a net) and var_prod (a variable) are continuously assigned from
// a and b; held gets a + b by a procedural assignment. After a and later b
// change, the continuous targets show the new results while held keeps the
// value of its last assignment until the procedure assigns it again. Last, a
// blocking (=) and a nonblocking (<=) assignment in the same time step: the
// blocking target has its new value at once, the nonblocking one only after
// the procedure has gone on, so copy_nb reads the old value of nb.

module test_continuous_drives_procedural_holds;
  logic [7:0] a = 8'd3, b = 8'd4;
  wire  [7:0] net_sum;
  logic [7:0] var_prod;
  logic [7:0] held;
  logic [7:0] blk = 8'd0, nb = 8'd0, copy_blk, copy_nb;

  assign net_sum = a + b;
  assign var_prod = a * b;

  initial begin
    #1 held = a + b;
    $display("1: net_sum=%0d var_prod=%0d held=%0d", net_sum, var_prod, held);
    a = 8'd10;
    #1 $display("2: net_sum=%0d var_prod=%0d held=%0d", net_sum, var_prod, held);
    held = a - b;
    b = 8'd1;
    #1 $display("3: net_sum=%0d var_prod=%0d held=%0d", net_sum, var_prod, held);
    blk = a + 8'd1;
    nb <= a + 8'd2;
    copy_blk = blk;
    copy_nb = nb;
    #1 $display("4: blk=%0d copy_blk=%0d nb=%0d copy_nb=%0d", blk, copy_blk, nb, copy_nb);
  end
endmodule
