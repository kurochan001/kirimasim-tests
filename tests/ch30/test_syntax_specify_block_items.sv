/*
:name: test_syntax_specify_block_items
:description: A specify block holds a specparam, pulse style and cancellation declarations, module paths and a system timing check, and the specparam sets the path delay, the pulse style decides when a filtered pulse turns to x, and the timing check toggles its notifier (IEEE 1800-2023 Sections 30.3 and 30.7, A.7.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.3 30.7 30.7.1 30.7.4 A.7.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_specify_block_items.expected
*/
// IEEE 1800-2023 A.7.1: a specify block is specify, any number of specparam,
// pulsestyle, showcancelled, path and system timing check items, endspecify;
// a pulse style declaration is pulsestyle_onevent or pulsestyle_ondetect with
// a list of path outputs, and a cancellation declaration is showcancelled or
// noshowcancelled with a list of path outputs.
//
// §30.7: a pulse narrower than the error limit of PATHPULSE$ but not narrower
// than the reject limit is filtered to x. §30.7.4: with on-detect style the
// output turns to x when the pulse is detected at its trailing edge, and with
// on-event style at the scheduled leading edge. The specparam tdelay = 6 sets
// the delay of the four paths; y is on-detect, z is on-event, w is
// showcancelled and v is noshowcancelled, which affects only the dump file.
// The pulse of width 3 at 10 to 13 reaches the outputs from 16 to 19: y is x
// from 13 and z, w and v from 16, and all return to 0 at 19. The pulse of
// width 7 at 30 to 37 passes on all four, from 36 to 43.
// The $width check on the rising edge of clk with limit 10 and threshold 0
// sees the high pulse from 5 to 9, which is shorter, and toggles its notifier
// from 0 to 1 at 9.
//
// The expected output follows the standard; Icarus Verilog 13.0 does not
// support the pulse style declarations and ignores PATHPULSE$.

`timescale 1ns/1ns

module spec_items (input a, input clk, output y, output z, output w, output v);
  reg notifier = 1'b0;

  buf (y, a);
  buf (z, a);
  buf (w, a);
  buf (v, a);

  specify
    specparam tdelay = 6;
    pulsestyle_ondetect y;
    pulsestyle_onevent z;
    showcancelled w;
    noshowcancelled v;
    (a => y) = tdelay;
    (a => z) = tdelay;
    (a => w) = tdelay;
    (a => v) = tdelay;
    $width(posedge clk, 10, 0, notifier);
    specparam PATHPULSE$ = (1, 5);
  endspecify
endmodule

module test_syntax_specify_block_items;
  reg a = 1'b0;
  reg clk = 1'b0;
  wire y, z, w, v;
  string log_y = "", log_z = "", log_w = "", log_v = "";

  spec_items u(a, clk, y, z, w, v);

  always @(y) if ($time >= 8) log_y = {log_y, $sformatf(" %0t:%b", $time, y)};
  always @(z) if ($time >= 8) log_z = {log_z, $sformatf(" %0t:%b", $time, z)};
  always @(w) if ($time >= 8) log_w = {log_w, $sformatf(" %0t:%b", $time, w)};
  always @(v) if ($time >= 8) log_v = {log_v, $sformatf(" %0t:%b", $time, v)};

  initial begin
    #5 clk = 1;
    #4 clk = 0;        // pulse width 4, shorter than 10
    #1 a = 1;          // 10
    #3 a = 0;          // 13
    #17 a = 1;         // 30
    #7 a = 0;          // 37
    #10;
    $display("ondetect y:%s", log_y);
    $display("onevent z:%s", log_z);
    $display("showcancelled w:%s", log_w);
    $display("noshowcancelled v:%s", log_v);
    $display("notifier=%b", u.notifier);
    $finish;
  end
endmodule
