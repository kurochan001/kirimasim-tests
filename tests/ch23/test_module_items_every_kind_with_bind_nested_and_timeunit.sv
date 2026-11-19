/*
:name: test_module_items_every_kind_with_bind_nested_and_timeunit
:description: one module has an item of each kind that Syntax 23-5 lists, among them a port declaration, a defparam, gate, UDP, module, interface and program instances, a concurrent assertion, a bind directive, an alias, the three procedures, generate constructs and a region, a specparam, nested module, interface and program declarations and a repeated timeunit (IEEE 1800-2023 Section 23.2.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_items_every_kind_with_bind_nested_and_timeunit.expected
*/
// IEEE 1800-2023 §23.2.4 (Syntax 23-5): a module holds zero or more module
// items: port declarations and the non-port items, which are declarations,
// defparam, gate, UDP, module, interface and program instances, assertion
// items, bind directives, continuous assignments, net aliases, initial, final
// and always procedures, loop and conditional generate constructs, generate
// regions, specify blocks, specparam declarations, nested program, module and
// interface declarations, and a timeunits declaration that repeats and
// matches an earlier one (footnote 3).
//
// The module empty_m has no item. The module items_m has a non-ANSI port
// list, so its port is declared by the item "output logic [7:0] y;". It
// starts with timeunit 10ns and timeprecision 1ns and repeats timeunit 10ns
// among its items. Each other item leaves a value that the top-level module,
// whose time unit is 1ns, reads by a hierarchical name at a fixed time:
// - y = {4'h0, a} + 1 is 4, and n1, an alias of n2 driven with 1, is 1; the
//   buf gate gives a[0] = 1 and the inverting UDP gives 0 for a[1] = 1;
// - defparam sets K of u_leaf to 7, and the bind directive puts probe_m into
//   u_leaf, whose hello is 5; the interface instance has v = 9, the nested
//   module drives 66 and the nested interface instance has iv = 77;
// - the loop generate block g_loop[1] has V = 10, the conditional one has
//   c = 44, the one in the generate region has r = 55, and the specparam SP
//   copied to sp_copy is 4;
// - u_leaf has a specify block with the path delay 3 from i to o: d rises at
//   10ns, so o is 0 at 12 and 1 at 14;
// - flag is set by #2 in items_m: 20ns, so it is 0 at 19 and 1 at 21;
// - the always procedure counts the posedges of clk (at 50ns and 150ns by
//   200), and the concurrent assertion, which holds, counts its passes;
// - the nested program prints after two posedges (150), the program instance
//   prints at 220, and when both have ended the simulation finishes; the
//   final procedure of items_m then prints the two counts.
// Icarus Verilog 13.0 does not support bind, and Verilator 5.054 does not
// support nested module declarations.

`timescale 1ns/1ns

module empty_m;
endmodule

primitive inv_udp (output o, input i);
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

interface small_if;
  int v = 9;
endinterface

program small_prog;
  initial #220 $display("program instance at %0d", $time);
endprogram

module probe_m;
  int hello = 5;
endmodule

module leaf (input logic i, output wire o);
  parameter int K = 1;
  specify
    (i => o) = 3;
  endspecify
  buf (o, i);
endmodule

module items_m (y);
  timeunit 10ns;
  timeprecision 1ns;
  output logic [7:0] y;
  parameter int W = 4;
  typedef logic [3:0] nib_t;
  nib_t a = 4'd3;
  logic clk = 1'b0, d = 1'b0;
  bit flag;
  int count_always = 0, n_pass = 0, sp_copy, nested_v;
  wire n1, n2, w_buf, w_udp, w_leaf;
  timeunit 10ns;
  specparam SP = 4;

  defparam u_leaf.K = 7;
  leaf u_leaf (d, w_leaf);
  buf g_buf (w_buf, a[0]);
  inv_udp u_udp (w_udp, a[1]);
  small_if u_if ();
  small_prog u_prog ();
  empty_m u_empty ();
  bind leaf probe_m u_probe ();

  assign y = {4'h0, a} + 8'd1;
  alias n1 = n2;
  assign n2 = 1'b1;

  always #5 clk = ~clk;
  always @(posedge clk) count_always++;
  a_holds: assert property (@(posedge clk) a == 4'd3) n_pass++;

  for (genvar i = 0; i < 2; i++) begin : g_loop
    localparam int V = i * 10;
  end
  if (W > 2) begin : g_cond
    int c = 44;
  end
  generate
    if (1) begin : g_region
      int r = 55;
    end
  endgenerate

  module nested_m (output int v);
    assign v = 66;
  endmodule
  nested_m u_nested (nested_v);

  interface nested_if;
    int iv = 77;
  endinterface
  nested_if u_nif ();

  program nested_prog;
    initial begin
      repeat (2) @(posedge clk);
      $display("nested program after two posedges");
    end
  endprogram
  nested_prog u_nprog ();

  initial begin
    sp_copy = SP;
    #1 d = 1'b1;
    #1 flag = 1'b1;
  end

  final $display("final: always ran %0d times, assertion passed %0d times", count_always,
                 n_pass);
endmodule

module test_module_items_every_kind_with_bind_nested_and_timeunit;
  wire [7:0] y;
  items_m u (y);

  initial begin
    #12 $display("leaf output at 12: %b", u.w_leaf);
    #2 $display("leaf output at 14: %b", u.w_leaf);
    #5 $display("flag at 19: %0d", u.flag);
    #2 $display("flag at 21: %0d", u.flag);
    #179;
    $display("assign y %0d, alias n1 %b, buf %b, udp %b", y, u.n1, u.w_buf, u.w_udp);
    $display("defparam K %0d, bound probe %0d, interface %0d", u.u_leaf.K,
             u.u_leaf.u_probe.hello, u.u_if.v);
    $display("nested module %0d, nested interface %0d", u.nested_v, u.u_nif.iv);
    $display("generate %0d %0d %0d, specparam %0d", u.g_loop[1].V, u.g_cond.c,
             u.g_region.r, u.sp_copy);
    $display("at 200: always %0d, assertion passes %0d", u.count_always, u.n_pass);
  end
endmodule
