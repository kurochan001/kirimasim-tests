/*
:name: test_clocking_block_per_instance_local_scope
:description: A clocking block declared in a module exists once for each instance of the module, with its own sampled clockvars reached as block.signal, and its name is local to the module, so the top module can declare a clocking block of the same name (IEEE 1800-2023 Section 14.7)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.7 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_block_per_instance_local_scope.expected
*/
// IEEE 1800-2023 §14.7: a clocking block is both a declaration and an
// instance; one copy exists for each instance of the module that declares
// it, without an instantiation step, and its clockvars are reached with the
// block name and a dot. It has static lifetime and a scope local to the
// module that contains it.
//
// The module counter adds K to d at every posedge and has a clocking block
// cb sampling d (input skew 1step). u1 has K = 1 and u2 has K = 10. The top
// module has its own block, also named cb, sampling u1.d at negedges. No
// process waits on u2.cb, which still samples at every clock event. At 26,
// after the posedges at 5, 15 and 25, d is 3 and 30 and the values sampled
// just before 25 are 2 and 20; the top block sampled u1.d = 2 at 20.

`timescale 1ns/1ns

module counter #(parameter int K = 1) (input logic clk);
  logic [7:0] d = 8'd0;

  always @(posedge clk) d <= d + K;

  clocking cb @(posedge clk);
    input d;
  endclocking
endmodule

module test_clocking_block_per_instance_local_scope;
  logic clk = 0;

  always #5 clk = ~clk;   // posedges at 5, 15, 25; negedges at 10, 20

  counter #(.K(1)) u1 (clk);
  counter #(.K(10)) u2 (clk);

  clocking cb @(negedge clk);
    input v = u1.d;
  endclocking

  initial begin
    #26;
    $display("t=%0t u1.d=%0d u2.d=%0d", $time, u1.d, u2.d);
    $display("t=%0t u1.cb.d=%0d u2.cb.d=%0d top cb.v=%0d", $time, u1.cb.d, u2.cb.d, cb.v);
    $finish;
  end
endmodule
