/*
:name: test_specify_edge_sensitive_path_declarations
:description: An edge-sensitive path declaration has an optional edge identifier and a parallel (=>) or full (*>) description, whose output is either a plain terminal or a parenthesized one with a polarity operator and a data source expression; the path is active only on the named edge, or on any transition without one (IEEE 1800-2023 Section 30.4.3)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.3 A.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_edge_sensitive_path_declarations.expected
*/
// IEEE 1800-2023 §30.4.3, Syntax 30-4 and A.7.2: an edge-sensitive path has
// an optional edge identifier before the input terminal and either a parallel
// description (one input terminal, =>, one output terminal) or a full
// description (input list, *>, output list). The output may be parenthesized
// with an optional polarity operator and a data_source_expression after a
// colon. The path is active only on the named edge; without an edge identifier
// it is active on any transition of the input. The data source expression
// describes the flow of data but does not affect propagation, and the polarity
// operator does not affect simulation results.
//
// The cell ep_pos has the plain form (posedge clk => y) with delay 3, so a
// rise of clk reaches y 3 later while a fall reaches it at once. The cell
// ep_neg has (negedge clk => (y +: d)) with the delays 2 and 4, so a fall
// reaches y 4 later while a rise reaches it at once. The cell ep_full has the
// plain form (posedge clk *> y1, y2) with the delays 1 and 2; y1 follows clk
// and y2 is its complement, so on a rise y1 rises 1 later and y2 falls 2
// later, while on a fall both change at once. The cell ep_edge has
// (edge clk *> (y1, y2 -: d)) with the delays 3 and 5, which is active on both
// edges. The cell ep_any has (clk => y) with delay 5, active on any
// transition. Each output logs its changes.
//
// Icarus Verilog 13.0 accepts an edge-sensitive path only when the output is
// parenthesized; with those two paths written parenthesized, it produces the
// same changes. Verilator 5.052 ignores module path delays.

`timescale 1ns/1ns

module ep_pos (input wire clk, output wire y);
  buf g (y, clk);
  specify
    (posedge clk => y) = 3;
  endspecify
endmodule

module ep_neg (input wire clk, input wire d, output wire y);
  buf g (y, clk);
  specify
    (negedge clk => (y +: d)) = (2, 4);
  endspecify
endmodule

module ep_full (input wire clk, output wire y1, output wire y2);
  buf g1 (y1, clk);
  not g2 (y2, clk);
  specify
    (posedge clk *> y1, y2) = (1, 2);
  endspecify
endmodule

module ep_edge (input wire clk, input wire d, output wire y1, output wire y2);
  buf g1 (y1, clk);
  not g2 (y2, clk);
  specify
    (edge clk *> (y1, y2 -: d)) = (3, 5);
  endspecify
endmodule

module ep_any (input wire clk, output wire y);
  buf g (y, clk);
  specify
    (clk => y) = 5;
  endspecify
endmodule

module test_specify_edge_sensitive_path_declarations;
  reg c_pos = 1'b0, c_neg = 1'b0, c_full = 1'b0, c_edge = 1'b0, c_any = 1'b0;
  reg d = 1'b1;
  wire y_pos, y_neg, yf1, yf2, ye1, ye2, y_any;
  string log_pos = "", log_neg = "", log_f1 = "", log_f2 = "";
  string log_e1 = "", log_e2 = "", log_any = "";

  ep_pos u_pos (c_pos, y_pos);
  ep_neg u_neg (c_neg, d, y_neg);
  ep_full u_full (c_full, yf1, yf2);
  ep_edge u_edge (c_edge, d, ye1, ye2);
  ep_any u_any (c_any, y_any);

  always @(y_pos) if ($time >= 10) log_pos = {log_pos, $sformatf(" %0t:%b", $time, y_pos)};
  always @(y_neg) if ($time >= 10) log_neg = {log_neg, $sformatf(" %0t:%b", $time, y_neg)};
  always @(yf1) if ($time >= 10) log_f1 = {log_f1, $sformatf(" %0t:%b", $time, yf1)};
  always @(yf2) if ($time >= 10) log_f2 = {log_f2, $sformatf(" %0t:%b", $time, yf2)};
  always @(ye1) if ($time >= 10) log_e1 = {log_e1, $sformatf(" %0t:%b", $time, ye1)};
  always @(ye2) if ($time >= 10) log_e2 = {log_e2, $sformatf(" %0t:%b", $time, ye2)};
  always @(y_any) if ($time >= 10) log_any = {log_any, $sformatf(" %0t:%b", $time, y_any)};

  initial begin
    #10 c_pos = 1; c_neg = 1; c_full = 1; c_edge = 1; c_any = 1;
    #10 c_pos = 0; c_neg = 0; c_full = 0; c_edge = 0; c_any = 0;
    #10 c_pos = 1; c_neg = 1; c_full = 1; c_edge = 1; c_any = 1;
    #10 c_pos = 0; c_neg = 0; c_full = 0; c_edge = 0; c_any = 0;
    #10;
    $display("pos:%s", log_pos);
    $display("neg:%s", log_neg);
    $display("full y1:%s", log_f1);
    $display("full y2:%s", log_f2);
    $display("edge y1:%s", log_e1);
    $display("edge y2:%s", log_e2);
    $display("any:%s", log_any);
    $finish;
  end
endmodule
