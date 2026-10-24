/*
:name: test_module_instantiates_each_block_kind
:description: A module instantiates a module, an interface, a program, a checker, a built-in gate and a UDP; each instance is a level of hierarchy below the module, its ports carry values both ways, and hierarchical names reach down into it and up from it (IEEE 1800-2023 Sections 3.3 and 3.11)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.3 3.11 23.3 23.6 24.3 25.3 17.3 28.4 29.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_instantiates_each_block_kind.expected
*/
// IEEE 1800-2023 §3.3, §3.11: a module can instantiate modules, programs,
// interfaces, checkers and primitives. An instance of a module, interface,
// program or checker makes a new level of hierarchy under the module, ports
// carry values between the instance and the module, and hierarchical names
// (§23.6) reach identifiers in other levels.
// The top module instantiates one of each kind:
// - u_mod: its input port gets 5 and its output port gives back 6; the top
//   reads its variable internal (9) by a downward name, and u_mod reads the
//   top's variable shared (42) by an upward name;
// - u_if: the top writes and reads its variable data through the instance
//   name;
// - u_prog: its input port is connected to the output of u_mod (6);
// - u_chk: its input is 5 and its output gives 10;
// - two nand gates and two instances of a majority UDP with different inputs.
// %m gives the full name of the scope it runs in, so the paths that u_mod,
// u_if (captured at time 0), u_prog and u_chk print show each instance one
// level below the top. The top prints at time 1, the program at time 2 and
// then ends, which ends the simulation (§24.3); the final procedure of the
// checker, the only final procedure in the design, prints last.

`timescale 1ns/1ns

primitive each_kind_udp_maj(output y, input a, input b, input c);
  table
  // a b c : y
     0 0 ? : 0;
     0 ? 0 : 0;
     ? 0 0 : 0;
     1 1 ? : 1;
     1 ? 1 : 1;
     ? 1 1 : 1;
  endtable
endprimitive

module each_kind_child(input logic [3:0] din, output logic [3:0] dout);
  logic [3:0] internal = 4'd9;
  logic [7:0] up_seen;
  string path;

  assign dout = din + 4'd1;
  assign up_seen = test_module_instantiates_each_block_kind.shared;
  initial path = $sformatf("%m");
endmodule

interface each_kind_if;
  logic [3:0] data;
  string path;

  initial path = $sformatf("%m");
endinterface

program each_kind_prog(input logic [3:0] pin);
  initial #2 $display("program: %m pin=%0d", pin);
endprogram

checker each_kind_chk(input logic [3:0] a, output logic [3:0] doubled);
  always_comb doubled = a << 1;
  final $display("checker: %m doubled=%0d", doubled);
endchecker

module test_module_instantiates_each_block_kind;
  logic [7:0] shared = 8'd42;
  logic [3:0] din = 4'd5;
  wire [3:0] dout;
  logic [3:0] chk_out;
  wire y_nand11, y_nand10, y_maj101, y_maj100;

  each_kind_child u_mod(.din(din), .dout(dout));
  each_kind_if u_if();
  each_kind_prog u_prog(.pin(dout));
  each_kind_chk u_chk(din, chk_out);
  nand g_nand11(y_nand11, 1'b1, 1'b1);
  nand g_nand10(y_nand10, 1'b1, 1'b0);
  each_kind_udp_maj u_maj101(y_maj101, 1'b1, 1'b0, 1'b1);
  each_kind_udp_maj u_maj100(y_maj100, 1'b1, 1'b0, 1'b0);

  initial begin
    u_if.data = 4'd3;
    #1;
    $display("module: %s dout=%0d internal=%0d up_seen=%0d",
             u_mod.path, dout, u_mod.internal, u_mod.up_seen);
    $display("interface: %s data=%0d", u_if.path, u_if.data);
    $display("checker output: %0d", chk_out);
    $display("primitives: nand(1,1)=%b nand(1,0)=%b maj(1,0,1)=%b maj(1,0,0)=%b",
             y_nand11, y_nand10, y_maj101, y_maj100);
  end
endmodule
