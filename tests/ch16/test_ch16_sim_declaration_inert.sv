/*
:name: test_ch16_sim_declaration_inert
:description: a declared property that no assert, assume or cover statement uses produces no result, while the same body used by an assert statement fails once per tick (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_ch16_sim_declaration_inert.expected
*/
// IEEE 1800-2023 §16.12: a property defines a behavior of the design; in
// order to use the behavior for verification, an assert, assume or cover
// statement needs to be used, and a property declaration by itself does not
// produce any result. p_decl and p_used have the same always-false body.
// p_decl is only declared. p_used is used by a_used, whose else action counts
// its failed attempts. The clock rises at 5, 15, 25 and 35, so a_used fails
// four times and p_decl adds nothing: the number of failures equals the
// number of ticks, not twice that number.
// Icarus Verilog 13.0 has no concurrent assertions, so it has no expected
// output of its own.

`timescale 1ns/1ns

module test_ch16_sim_declaration_inert;
  logic clk = 0;
  int failures = 0;

  property p_decl;
    @(posedge clk) 1'b0;
  endproperty

  property p_used;
    @(posedge clk) 1'b0;
  endproperty

  always #5 clk = ~clk;

  a_used: assert property (p_used) else failures++;

  initial begin
    #40;
    $display("declared-only failures=0, asserted failures=%0d", failures);
    $finish;
  end
endmodule
