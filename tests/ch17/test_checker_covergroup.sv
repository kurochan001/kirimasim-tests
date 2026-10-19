/*
:name: test_checker_covergroup
:description: a covergroup declared in a checker, and instantiated there outside its procedures, can cover the checker's formal arguments and its variables, sampled at the covergroup's clocking event (IEEE 1800-2023 Section 17.6)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.6 17.7.1 19.3 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_covergroup.expected
*/
// IEEE 1800-2023 §17.6: covergroup declarations and instances are permitted in
// a checker, outside its procedures, and a covergroup can refer to the formal
// arguments and the variables of the checker. The covergroup instance is
// sampled at its clocking event (§19.3). Here cp_op covers the formal argument
// op (4 bins) and cp_seen the checker variable seen (2 automatic bins), which
// a continuous assignment (§17.7.1) keeps equal to op == 3. op changes only
// between clock edges and is 0, 1, 1 and 3 at the edges. A coverpoint's
// coverage is its covered bins over its bins (§19.11.1).

`timescale 1ns/1ns

checker op_coverage(logic clk, logic [1:0] op);
  bit seen;
  assign seen = (op == 3);
  covergroup cg @(posedge clk);
    cp_op: coverpoint op { bins b[] = {[0:3]}; }
    cp_seen: coverpoint seen;
  endgroup
  cg inst = new();
  final $display("%m: op %.2f, seen %.2f", inst.cp_op.get_inst_coverage(),
                 inst.cp_seen.get_inst_coverage());
endchecker

module test_checker_covergroup;
  logic clk = 0;
  logic [1:0] op1 = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, 35

  op_coverage c1(clk, op1);

  initial begin
    #10 op1 = 1;
    #20 op1 = 3;
    #10 $finish;
  end
endmodule
