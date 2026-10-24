/*
:name: test_interface_instantiates_interface_program_and_checker
:description: An interface instantiates an interface, a program and two checkers; each instance is a level of hierarchy below the interface instance, so two instances of the outer interface have separate children with their own paths and values (IEEE 1800-2023 Section 3.11)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.11 25.3 17.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_instantiates_interface_program_and_checker.expected
*/
// IEEE 1800-2023 §3.11: besides modules, interfaces can instantiate other
// building blocks and so create levels of the hierarchy tree. An interface
// can instantiate interfaces and programs (§25.3), and a checker can be
// instantiated wherever a concurrent assertion can appear (§17.3), which
// includes the items of an interface.
// ih_outer_if instantiates the interface ih_leaf_if as u_leaf, the program
// ih_prog as u_prog and the checker ih_and_chk twice. The top module has two
// instances of ih_outer_if, u_outer (ID 0) and u_other (ID 1), so each child
// exists once under each of them:
// - each u_leaf records its own path with %m; the top writes 20 into k of
//   u_other.u_leaf only, and each outer instance adds 1 to the k of its own
//   leaf at time 1;
// - the checkers give 1 & 1 = 1 and 1 & 0 = 0 to the variables of the
//   interface;
// - each program prints its path and its input (9 + ID) at time 3 + ID; the
//   end of the second program at time 4 ends the simulation (§24.3).
// The top module prints the values below u_outer and u_other at time 2.
// Icarus Verilog 13.0 does not support checkers (syntax error at the
// checker declaration).

`timescale 1ns/1ns

checker ih_and_chk(input logic a, input logic b, output logic c);
  always_comb c = a & b;
endchecker

program ih_prog #(parameter int AT = 3) (input logic [3:0] v);
  initial #AT $display("program: %m v=%0d", v);
endprogram

interface ih_leaf_if;
  int k = 7;
  string path;

  initial path = $sformatf("%m");
endinterface

interface ih_outer_if #(parameter int ID = 0);
  logic x = 1'b1, y1 = 1'b1, y0 = 1'b0;
  logic c11, c10;
  logic [3:0] pv = 4'(9 + ID);
  int sum;

  ih_leaf_if u_leaf();
  ih_prog #(.AT(3 + ID)) u_prog(.v(pv));
  ih_and_chk u_chk11(.a(x), .b(y1), .c(c11));
  ih_and_chk u_chk10(.a(x), .b(y0), .c(c10));

  initial #1 sum = u_leaf.k + 1;
endinterface

module test_interface_instantiates_interface_program_and_checker;
  ih_outer_if #(.ID(0)) u_outer();
  ih_outer_if #(.ID(1)) u_other();

  initial begin
    u_other.u_leaf.k = 20;
    #2;
    $display("leaf: %s k=%0d", u_outer.u_leaf.path, u_outer.u_leaf.k);
    $display("leaf: %s k=%0d", u_other.u_leaf.path, u_other.u_leaf.k);
    $display("sums: u_outer=%0d u_other=%0d", u_outer.sum, u_other.sum);
    $display("checkers: u_outer c11=%b c10=%b, u_other c11=%b c10=%b", u_outer.c11,
             u_outer.c10, u_other.c11, u_other.c10);
  end
endmodule
