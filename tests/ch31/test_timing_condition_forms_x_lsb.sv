/*
:name: test_timing_condition_forms_x_lsb
:description: The condition after &&& in a timing check event can be an expression, its inversion or a comparison with a scalar constant; an x condition enables the check for == and != but not for a plain signal, ~ or ===, and a multibit condition uses only its least significant bit (IEEE 1800-2023 Section 31.7)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.7 31.3.1 31.4.4 31.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_timing_condition_forms_x_lsb.expected
*/
// IEEE 1800-2023 §31.7: a timing check event, also the controlled reference
// event of $width, can be followed by &&& and a condition: an expression, ~
// and an expression, or an expression compared with ==, ===, != or !== to a
// scalar constant such as 1'b1, 'b0 or 1, possibly in parentheses. The event
// counts only when the condition is true. With ===, !==, ~ or no operator an
// x on the conditioning signal does not enable the check; with == and != it
// does. A vector or multibit condition contributes only its least
// significant bit. §31.3.1: $setup(d, posedge clk &&& c, 3, n) reports a d
// change 2 before an enabled clk edge. §31.4.4: $width reports a pulse
// narrower than its limit. §31.6: each violation toggles the notifier.
//
// d changes 2 before each clk edge at 20, 40 and 60. The conditioning
// signals are en = 1, ek = 1, ven = 2'b01 for the edge at 20; en = 0, ek = 0,
// ven = 2'b10 for the edge at 40; and en = x, ek = 1, ven = 2'b00 for the
// edge at 60 (ek, never x, is used for !==). So the checks report at:
//   en 20; ~en 40; (en === 1'b1) 20; en == 1'b1 20 and 60; en != 'b0 20 and
//   60; ek !== 1 40; ven (least significant bit 1, 0, 0) 20;
//   {ven[0], ven[1]} (least significant bit 0, 1, 0) 40.
// wclk has a high pulse of 3 from 12 to 15 while en is 1 and from 32 to 35
// while en is 0, so $width(posedge wclk &&& en, 5, 0, nw) reports only at 15.
// The times at which each notifier changes are printed at the end.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module tcf_checks (input clk, d, en, ek, wclk, input [1:0] ven);
  reg np = 0, ni = 0, nce = 0, ne = 0, nn = 0, ncn = 0, nv = 0, nc = 0, nw = 0;
  specify
    $setup(d, posedge clk &&& en, 3, np);
    $setup(d, posedge clk &&& ~en, 3, ni);
    $setup(d, posedge clk &&& (en === 1'b1), 3, nce);
    $setup(d, posedge clk &&& en == 1'b1, 3, ne);
    $setup(d, posedge clk &&& en != 'b0, 3, nn);
    $setup(d, posedge clk &&& ek !== 1, 3, ncn);
    $setup(d, posedge clk &&& ven, 3, nv);
    $setup(d, posedge clk &&& {ven[0], ven[1]}, 3, nc);
    $width(posedge wclk &&& en, 5, 0, nw);
  endspecify
endmodule

module test_timing_condition_forms_x_lsb;
  reg clk = 0, d = 0, en = 1, ek = 1, wclk = 0;
  reg [1:0] ven = 2'b01;
  string lp = "", li = "", lce = "", le = "", ln = "", lcn = "", lv = "", lc = "", lw = "";

  tcf_checks u (clk, d, en, ek, wclk, ven);

  always @(u.np) lp = {lp, $sformatf(" %0d", $time)};
  always @(u.ni) li = {li, $sformatf(" %0d", $time)};
  always @(u.nce) lce = {lce, $sformatf(" %0d", $time)};
  always @(u.ne) le = {le, $sformatf(" %0d", $time)};
  always @(u.nn) ln = {ln, $sformatf(" %0d", $time)};
  always @(u.ncn) lcn = {lcn, $sformatf(" %0d", $time)};
  always @(u.nv) lv = {lv, $sformatf(" %0d", $time)};
  always @(u.nc) lc = {lc, $sformatf(" %0d", $time)};
  always @(u.nw) lw = {lw, $sformatf(" %0d", $time)};

  initial begin
    #12 wclk = 1;           // 12: en = 1
    #3 wclk = 0;            // 15: width 3
    #3 d = 1;               // 18
    #2 clk = 1;             // 20
    #5 clk = 0;
    #5 en = 0; ek = 0; ven = 2'b10;
    #2 wclk = 1;            // 32: en = 0
    #3 wclk = 0;            // 35
    #3 d = 0;               // 38
    #2 clk = 1;             // 40
    #5 clk = 0;
    #5 en = 1'bx; ek = 1; ven = 2'b00;
    #8 d = 1;               // 58
    #2 clk = 1;             // 60
    #5 clk = 0;
    #10 $display("en:%s", lp);
    $display("~en:%s", li);
    $display("(en === 1'b1):%s", lce);
    $display("en == 1'b1:%s", le);
    $display("en != 'b0:%s", ln);
    $display("ek !== 1:%s", lcn);
    $display("ven:%s", lv);
    $display("{ven[0], ven[1]}:%s", lc);
    $display("$width &&& en:%s", lw);
  end
endmodule
