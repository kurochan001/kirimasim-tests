/*
:name: test_checker_free_variable_constants
:description: An initialized constant free variable keeps its initial value, an uninitialized constant free variable keeps one arbitrary value, and an initialized nonconstant free variable starts from its initializer (IEEE 1800-2023 Section 17.7)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_free_variable_constants.expected
*/
// IEEE 1800-2023 §17.7: a free variable declared const that has an initializer
// retains that value forever, and an uninitialized const free variable has one
// nondeterministic value at initialization that does not change. A
// nonconstant free variable with an initializer has that value in the first
// time step and may change later (§17.7.2 randomizes it in later steps). The
// checker declares rand const k = 9, rand const u without an initializer and
// rand n = 4. The design prints k and n before the first clock, so the value
// fixed by the initializer is observable without depending on a random
// choice, and at the first clock it stores the value of u and then compares u
// with that stored value at every later clock, so a constant free variable
// gives stable = 1 whatever value was chosen. Icarus Verilog 13.0 has no
// checkers and Verilator 5.052 does not support rand variables in checkers,
// so the expected output follows the clauses alone.

`timescale 1ns/1ns

checker cb_const (event clk, output bit [3:0] k_out, output bit [3:0] n_out,
                  output bit stable);
  rand const bit [3:0] k = 4'd9;
  rand const bit [3:0] u;
  rand bit [3:0] n = 4'd4;
  bit [3:0] u0;
  bit first = 1'b1;
  bit same = 1'b1;

  always_ff @clk begin
    if (first) begin
      u0 <= u;
      first <= 1'b0;
    end
    else if (u != u0) begin
      same <= 1'b0;
    end
  end

  assign k_out = k;
  assign n_out = n;
  assign stable = same;
endchecker : cb_const

module test_checker_free_variable_constants;
  logic clk = 1'b0;
  bit [3:0] k, n;
  bit stable;

  cb_const u_cb (posedge clk, k, n, stable);

  always #5 clk = ~clk;

  initial begin
    #1 $display("k=%0d n=%0d", k, n);
    #44 $display("stable=%b", stable);
    $finish;
  end
endmodule
