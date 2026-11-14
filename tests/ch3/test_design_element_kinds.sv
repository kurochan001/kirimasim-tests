/*
:name: test_design_element_kinds
:description: The seven kinds of design element, introduced by module, program, interface, checker, package, primitive and config, each act as their kind in one design: the package gives an item to import, the interface holds a signal, the primitive computes from its table, the checker's assertion passes, the program runs in the Reactive region and the configuration binds an instance to another module (IEEE 1800-2023 Section 3.2)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.2 3.10 24.3.1 33.4.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: dek_cfg
:expected_stdout: @test_design_element_kinds.expected
*/
// IEEE 1800-2023 §3.2: a design element is a module, program, interface,
// checker, package, primitive or configuration, introduced by the keywords
// module, program, interface, checker, package, primitive and config.
// The design has one of each, and each is used as what its keyword makes it:
// - package dek_pkg: the top module imports its local parameter DEK_BASE, 40;
// - interface dek_if: the top module instantiates it and sets its data to
//   DEK_BASE + 2, 42;
// - primitive dek_and: a user-defined primitive whose table gives 1 for the
//   inputs 1 and 1;
// - checker dek_chk: its assertion is checked at the rising edge of clk at 2
//   and passes for the data 42, so its pass action prints;
// - program dek_prog: §24.3.1, its initial procedure runs in the Reactive
//   region, so at 0 it reads the 9 that the top module gave x with a
//   nonblocking assignment at 0; it ends at 3, which ends the simulation;
// - config dek_cfg, the configuration that :top_module: elaborates: §3.10, a
//   configuration binds module instances to source definitions through
//   libraries; its design is the top module in the library work, into which
//   every file goes without a library map (33.3.1), and, §33.4.1.3, its
//   instance clause binds the instance u_leaf, written as dek_leaf_a (y = 1),
//   to the cell dek_leaf_b of work (y = 2).
// The top module prints at 1: base=40 g=1 y=2 data=42.
// Neither release produces this output. Icarus Verilog 13.0 stops with a
// syntax error at the checker. The 5.054 release of Verilator gives every
// line but the first: it runs the program's initial procedure before the
// nonblocking update and prints v=0, a known difference for §24.3.1.

package dek_pkg;
  localparam int DEK_BASE = 40;
endpackage

interface dek_if;
  logic [7:0] data;
endinterface

primitive dek_and (output y, input a, input b);
  table
    0 0 : 0;
    0 1 : 0;
    1 0 : 0;
    1 1 : 1;
  endtable
endprimitive

checker dek_chk (input logic clk, input logic [7:0] v);
  a_v: assert property (@(posedge clk) v == 8'd42) $display("checker: v=%0d", v);
endchecker

program dek_prog (input logic [7:0] v);
  initial begin
    $display("program at 0: v=%0d", v);
    #3;
  end
endprogram

module dek_leaf_a (output logic [7:0] y);
  assign y = 8'd1;
endmodule

module dek_leaf_b (output logic [7:0] y);
  assign y = 8'd2;
endmodule

module test_design_element_kinds;
  import dek_pkg::*;

  logic clk = 1'b0;
  logic a = 1'b1, b = 1'b1;
  wire g;
  logic [7:0] x = 8'd0;
  logic [7:0] y;

  dek_if bus ();
  dek_and u_and (g, a, b);
  dek_leaf_a u_leaf (y);
  dek_chk u_chk (clk, bus.data);
  dek_prog u_prog (x);

  initial begin
    x <= 8'd9;
    bus.data = DEK_BASE + 2;
    #1 $display("module at 1: base=%0d g=%b y=%0d data=%0d", DEK_BASE, g, y, bus.data);
    #1 clk = 1'b1;
  end
endmodule

config dek_cfg;
  design work.test_design_element_kinds;
  default liblist work;
  instance test_design_element_kinds.u_leaf use work.dek_leaf_b;
endconfig
