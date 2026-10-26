/*
:name: test_checker_covergroup_sample
:description: a covergroup in a checker may define a custom sample() method and be sampled by calls of that method, both from a procedure and from a sequence match item, which cover the values they are given (IEEE 1800-2023 Section 17.6)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.6 19.8.1 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_covergroup_sample.expected
*/
// IEEE 1800-2023 17.6: a covergroup declared in a checker may be triggered by
// a procedural call to its sample() method, and that call may appear in a
// sequence match item. 19.8.1: a covergroup may define its own sample()
// method with a with function clause, and the arguments of that method are
// the values it covers. The automatic covergroup samples the formal opcode at
// each of the four rising edges, where opcode is 0, 1, 2 and 2, so three of
// its four bins are covered. The custom covergroup is sampled twice at each
// edge: the always_ff procedure passes 3, and the match item passes opcode,
// so its four bins are covered and its percentage is 100.

`timescale 1ns/1ns

checker cg_sample(input logic clk, input logic [1:0] opcode);
  covergroup auto_cg @(posedge clk);
    cp_auto: coverpoint opcode { bins seen[] = {[0:3]}; }
  endgroup
  auto_cg c_auto = new();

  covergroup custom_cg with function sample(logic [1:0] x);
    cp_custom: coverpoint x { bins seen[] = {[0:3]}; }
  endgroup
  custom_cg c_custom = new();

  always_ff @(posedge clk)
    c_custom.sample(2'd3);

  sequence match_seq;
    @(posedge clk) (1'b1, c_custom.sample(opcode));
  endsequence
  cover property (match_seq);

  final $display("auto=%.2f custom=%.2f", c_auto.get_inst_coverage(),
                 c_custom.get_inst_coverage());
endchecker : cg_sample

module test_checker_covergroup_sample;
  logic clk = 1'b0;
  logic [1:0] opcode = 2'd0;

  always #5 clk = ~clk;      // rising edges at 5, 15, 25, 35

  cg_sample c(.clk(clk), .opcode(opcode));

  initial begin
    #10 opcode = 2'd1;       // before 15
    #10 opcode = 2'd2;       // before 25
    #15 $finish;             // 35
  end
endmodule
