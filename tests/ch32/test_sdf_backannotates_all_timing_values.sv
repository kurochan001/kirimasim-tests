/*
:name: test_sdf_backannotates_all_timing_values
:description: SDF annotation replaces a specify path delay, a specparam, a timing check limit and an interconnect delay, each mapping from its own SDF section (IEEE 1800-2023 Section 32.2, 32.4)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.2 32.4 32.4.2 32.4.3 32.4.4 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_backannotates_all_timing_values.expected
*/
// IEEE 1800-2023 §32.2: backannotation replaces specify path delays,
// specparam values, timing check limits and interconnect delays with values
// from an SDF file. §32.4: each SDF section maps to its own declaration kind:
// DELAY to a path and an interconnect delay, TIMINGCHECK to a $setup limit,
// LABEL to a specparam. Cell u is annotated: its path a to y becomes 7
// instead of 4, its specparam t 9 instead of 3, and its setup limit 5 instead
// of 2. Cell v keeps its source values. d changes at 20 and clk at 24, so the
// 4 ns setup is a violation of u (limit 5) and not of v (limit 2), which
// toggles only u.notif (31.6). An INTERCONNECT entry delays src.o to dst.i by
// 6: n1 changes at 40, dst.i and dst.o at 46.
//
// Icarus Verilog 13.0 supports the IOPATH and INTERCONNECT delays when they
// stand alone, but it does not read LABEL and its SDF parser stops at that
// section, so nothing is annotated here; it also does not support timing
// checks. Verilator 5.052 ignores $sdf_annotate.

`timescale 1ns/1ns

module sdf_map_cell(output y, output [7:0] tval, input a, input d, input clk);
  specparam t = 3;
  reg notif = 0;

  assign tval = t;
  assign y = a;

  specify
    (a => y) = 4;
    $setup(d, posedge clk, 2, notif);
  endspecify
endmodule

module sdf_map_src(output o, input i);
  assign o = i;
endmodule

module sdf_map_dst(output o, input i);
  assign o = i;
endmodule

module test_sdf_backannotates_all_timing_values;
  reg a = 0, d = 0, clk = 0, a2 = 0;
  wire yu, yv, n1, o2;
  wire [7:0] tu, tv;
  integer f;

  sdf_map_cell u(.y(yu), .tval(tu), .a(a), .d(d), .clk(clk));
  sdf_map_cell v(.y(yv), .tval(tv), .a(a), .d(d), .clk(clk));
  sdf_map_src src(.o(n1), .i(a2));
  sdf_map_dst dst(.o(o2), .i(n1));

  initial begin
    f = $fopen("test_sdf_backannotates_all_timing_values.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_map_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y (7))))");
    $fdisplay(f, "    (LABEL (ABSOLUTE (t 9)))");
    $fdisplay(f, "    (TIMINGCHECK (SETUP d (posedge clk) (5))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"test_sdf_backannotates_all_timing_values\") (INSTANCE)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (INTERCONNECT src.o dst.i (6))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_backannotates_all_timing_values.sdf");
    #1 $display("1: u.t=%0d v.t=%0d", tu, tv);
    #9 a = 1;
    #5 $display("15: u.y=%b v.y=%b", yu, yv);
    #5 d = 1;
    #4 clk = 1;
    #6 $display("30: u.y=%b v.y=%b u.notif=%b v.notif=%b", yu, yv, u.notif, v.notif);
    #10 a2 = 1;
    #2 $display("42: n1=%b dst.i=%b", n1, dst.i);
    #5 $display("47: n1=%b dst.i=%b o2=%b", n1, dst.i, o2);
    #3 $finish;
  end
endmodule
