/*
:name: test_specify_edge_path_source_edge_kinds
:description: An edge-sensitive path with posedge or negedge is active only for that edge of its source, one with edge or with no edge identifier is active for both edges, and for a vector source the edge is taken from its least significant bit (IEEE 1800-2023 Section 30.4.3)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_edge_path_source_edge_kinds.expected
*/
// IEEE 1800-2023 §30.4.3: the edge identifier of an edge-sensitive path is
// posedge, negedge or edge; for a vector source the edge is detected on its
// LSB, and a path without an edge identifier is active on any transition of
// its source. §30.5.3 uses the delay of the active path.
//
// Each cell loads d into a register on both edges of its clock (pn, ed and
// an) or on every change of its 2-bit clock c (lsb), and buffers it to q:
//   pn:  (posedge clk => (q : d)) = 20; (negedge clk => (q : d)) = 60;
//   ed:  (edge clk => (q : d)) = 30;
//   an:  (clk => (q : d)) = 40;
//   lsb: (posedge c *> (q : d)) = 20; (negedge c *> (q : d)) = 60;
// (A vector source and a scalar destination need a full connection, 30.4.5.)
// d is set 10 before each clock change, so q changes at every one. clk rises
// at 100 and falls at 200: pn changes at 120 and 260, ed at 130 and 230, an
// at 140 and 240. c goes 00 -> 11 at 300 and 11 -> 10 at 400: its LSB rises,
// then falls, so lsb changes at 320 and 460. c goes 10 -> 01 at 500: the LSB
// rises and the MSB falls, so the change is at 520, not 560. c goes 01 -> 10
// at 600: the LSB falls and the MSB rises, so the change is at 660, not 620.
// Every change is at a multiple of 10. The outputs are sampled 5 after each
// multiple of 10 from 105 on, and a sample that differs from the one before
// prints the time of the change, 5 earlier, and the outputs.
//
// Icarus Verilog 13.0 rejects the edge identifier edge in a module path as a
// syntax error. Without the cell ed it compiles the test, but the path of an,
// which has a data source and no edge identifier, then acts only on rising
// clk, so an falls at 200 with no delay. The 5.054 release of Verilator
// ignores module path delays.

`timescale 1ns/1ns

module test_specify_edge_path_source_edge_kinds_pn (input clk, input d, output q);
  reg qi = 0;
  always @(posedge clk or negedge clk) qi <= d;
  buf g (q, qi);
  specify
    (posedge clk => (q : d)) = 20;
    (negedge clk => (q : d)) = 60;
  endspecify
endmodule

module test_specify_edge_path_source_edge_kinds_ed (input clk, input d, output q);
  reg qi = 0;
  always @(posedge clk or negedge clk) qi <= d;
  buf g (q, qi);
  specify
    (edge clk => (q : d)) = 30;
  endspecify
endmodule

module test_specify_edge_path_source_edge_kinds_an (input clk, input d, output q);
  reg qi = 0;
  always @(posedge clk or negedge clk) qi <= d;
  buf g (q, qi);
  specify
    (clk => (q : d)) = 40;
  endspecify
endmodule

module test_specify_edge_path_source_edge_kinds_lsb (input [1:0] c, input d, output q);
  reg qi = 0;
  always @(c) qi <= d;
  buf g (q, qi);
  specify
    (posedge c *> (q : d)) = 20;
    (negedge c *> (q : d)) = 60;
  endspecify
endmodule

module test_specify_edge_path_source_edge_kinds;
  reg clk = 0, d = 0, d2 = 0;
  reg [1:0] c = 2'b00;
  wire qpn, qed, qan, qlsb;
  logic [3:0] prev;

  test_specify_edge_path_source_edge_kinds_pn upn (clk, d, qpn);
  test_specify_edge_path_source_edge_kinds_ed ued (clk, d, qed);
  test_specify_edge_path_source_edge_kinds_an uan (clk, d, qan);
  test_specify_edge_path_source_edge_kinds_lsb ulsb (c, d2, qlsb);

  initial begin
    #90 d = 1;
    #10 clk = 1;      // 100
    #90 d = 0;
    #10 clk = 0;      // 200
    #90 d2 = 1;
    #10 c = 2'b11;    // 300
    #90 d2 = 0;
    #10 c = 2'b10;    // 400
    #90 d2 = 1;
    #10 c = 2'b01;    // 500
    #90 d2 = 0;
    #10 c = 2'b10;    // 600
  end

  initial begin
    #95 prev = {qpn, qed, qan, qlsb};
    repeat (65) begin
      #10 if ({qpn, qed, qan, qlsb} != prev)
        $display("%0d: pn=%b ed=%b an=%b lsb=%b", $time - 5, qpn, qed, qan, qlsb);
      prev = {qpn, qed, qan, qlsb};
    end
    $finish;
  end
endmodule
