/*
:name: test_checker_free_const_stability
:description: A constant free checker variable keeps its initializer at every clock, and an uninitialized constant free variable keeps one arbitrary value at every clock (IEEE 1800-2023 Section 17.7)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_free_const_stability.expected
*/
// IEEE 1800-2023 §17.7: a constant free variable with an initializer retains
// that value forever, and an uninitialized constant free variable has a
// nondeterministic value at initialization that does not change. The checker
// declares rand const k = 9 and an uninitialized rand const u. At each of the
// four rising edges it compares k with 9 and, after storing the first value
// of u, compares u with that value; both comparisons run at every edge after
// the first, so an implementation that randomizes either constant again
// clears one of the two flags even if the first edge looked right. The final
// values print k as the concrete 9, while the arbitrary value of u is never
// printed, only the fact that it did not change. Icarus Verilog 13.0 has no
// checkers and Verilator 5.052 rejects rand checker variables, so the
// expected output follows the clauses alone.

`timescale 1ns/1ns

checker cb_const (event clk, output bit [3:0] k_out, output bit k_ok,
                  output bit u_ok);
  rand const bit [3:0] k = 4'd9;
  rand const bit [31:0] u;
  bit [31:0] u0;
  bit first = 1'b1;
  bit kk = 1'b1;
  bit uu = 1'b1;

  always_ff @clk begin
    if (k != 4'd9) kk <= 1'b0;
    if (first) begin
      u0 <= u;
      first <= 1'b0;
    end
    else if (u != u0) begin
      uu <= 1'b0;
    end
  end

  assign k_out = k;
  assign k_ok = kk;
  assign u_ok = uu;
endchecker : cb_const

module test_checker_free_const_stability;
  logic clk = 1'b0;
  bit [3:0] k;
  bit k_ok, u_ok;

  cb_const u_cb (posedge clk, k, k_ok, u_ok);

  always #5 clk = ~clk;   // rising edges at 5, 15, 25 and 35

  initial begin
    #37 $display("k=%0d k_ok=%b u_ok=%b", k, k_ok, u_ok);
    $finish;
  end
endmodule
