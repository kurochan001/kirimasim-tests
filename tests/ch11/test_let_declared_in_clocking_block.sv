/*
:name: test_let_declared_in_clocking_block
:description: a let can be declared in a clocking block and used in a property of that clocking block, which an assertion outside the block refers to (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12 16.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_declared_in_clocking_block.expected
*/
// IEEE 1800-2023 §11.12: a clocking block is one of the scopes where a let
// may be declared. §16.16: a property declared in a clocking block is clocked
// by the clocking event of the block, and an assertion can refer to it as
// cb.name.
// cl compares sig with 10. At the rising edge at time 5 sig is 10 and the
// assertion passes; at the edge at time 10 sig has become 11 and it fails.
// Each action block prints the time.
// Icarus Verilog 13.0 does not parse let declarations, and assertion items
// in clocking blocks are not supported by Verilator 5.052.

`timescale 1ns/1ns

module test_let_declared_in_clocking_block;
  logic clk = 0;
  logic [7:0] sig = 8'd10;

  clocking cb @(posedge clk);
    let cl = sig == 8'd10;
    property cp;
      cl;
    endproperty
  endclocking

  a_cb: assert property (cb.cp) $display("pass at %0t", $time);
    else $display("fail at %0t", $time);

  initial begin
    #5 clk = 1;
    #1 clk = 0;
    sig = 8'd11;
    #4 clk = 1;
    #1 $finish;
  end
endmodule
