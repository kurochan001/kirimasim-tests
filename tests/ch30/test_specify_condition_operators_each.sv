/*
:name: test_specify_condition_operators_each
:description: Each operator of Table 30-1 (bitwise, equality, logical, reduction, concatenation, replication and conditional) can form the condition of a state-dependent path, and the path delay applies exactly when the condition is true (IEEE 1800-2023 Section 30.4.4.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.4.1 30.4.4.2 30.4.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_condition_operators_each.expected
*/
// IEEE 1800-2023 §30.4.4.1: the condition of a state-dependent path may use
// the operators of Table 30-1 on input ports, their selects and constants;
// the path gets its delay when the condition is true, and a condition of more
// than one bit is decided by its least significant bit. Each output of the
// cell copies a and has one simple state-dependent path (30.4.4.2) with a
// delay of 2, whose condition uses one operator, and an ifnone path with a
// delay of 7 (30.4.4.4). Binary XNOR and reduction XNOR are written both as
// ~^ and as ^~. For each pair of values of the 4-bit inputs p and q, a
// toggles; 3 time units later an output shows 1 when it has already followed
// a (condition true), 0 when not (condition false), and 8 time units later
// every output has followed a. The pairs make each condition true at least
// once and false at least once; for example p=0110 q=0011 makes p && q true
// although the LSB of p & q is 0, and !p false although the LSB of ~p is 1.
// p=0000 q=1010 makes p || q true and p && q false.

`timescale 1ns/1ns

module test_specify_condition_operators_each_cell (
    input a, input [3:0] p, input [3:0] q,
    output b_not, output b_and, output b_or, output b_xor, output b_xnor1, output b_xnor2,
    output l_eq, output l_ne, output l_and, output l_or, output l_not,
    output r_and, output r_or, output r_xor, output r_nand, output r_nor, output r_xnor1,
    output r_xnor2, output c_cat, output c_rep, output c_cond);
  assign {b_not, b_and, b_or, b_xor, b_xnor1, b_xnor2} = {6{a}};
  assign {l_eq, l_ne, l_and, l_or, l_not} = {5{a}};
  assign {r_and, r_or, r_xor, r_nand, r_nor, r_xnor1, r_xnor2} = {7{a}};
  assign {c_cat, c_rep, c_cond} = {3{a}};
  specify
    if (~p[0]) (a => b_not) = 2;
    ifnone (a => b_not) = 7;
    if (p[0] & q[0]) (a => b_and) = 2;
    ifnone (a => b_and) = 7;
    if (p[0] | q[0]) (a => b_or) = 2;
    ifnone (a => b_or) = 7;
    if (p[0] ^ q[0]) (a => b_xor) = 2;
    ifnone (a => b_xor) = 7;
    if (p[1] ~^ q[1]) (a => b_xnor1) = 2;
    ifnone (a => b_xnor1) = 7;
    if (p[1] ^~ q[1]) (a => b_xnor2) = 2;
    ifnone (a => b_xnor2) = 7;
    if (p == q) (a => l_eq) = 2;
    ifnone (a => l_eq) = 7;
    if (p != q) (a => l_ne) = 2;
    ifnone (a => l_ne) = 7;
    if (p && q) (a => l_and) = 2;
    ifnone (a => l_and) = 7;
    if (p || q) (a => l_or) = 2;
    ifnone (a => l_or) = 7;
    if (!p) (a => l_not) = 2;
    ifnone (a => l_not) = 7;
    if (&p) (a => r_and) = 2;
    ifnone (a => r_and) = 7;
    if (|p) (a => r_or) = 2;
    ifnone (a => r_or) = 7;
    if (^p) (a => r_xor) = 2;
    ifnone (a => r_xor) = 7;
    if (~&p) (a => r_nand) = 2;
    ifnone (a => r_nand) = 7;
    if (~|p) (a => r_nor) = 2;
    ifnone (a => r_nor) = 7;
    if (~^q) (a => r_xnor1) = 2;
    ifnone (a => r_xnor1) = 7;
    if (^~q) (a => r_xnor2) = 2;
    ifnone (a => r_xnor2) = 7;
    if ({p[0], q[0]} == 2'b10) (a => c_cat) = 2;
    ifnone (a => c_cat) = 7;
    if ({2{p[1:0]}} == 4'b1010) (a => c_rep) = 2;
    ifnone (a => c_rep) = 7;
    if (p[0] ? q[0] : q[1]) (a => c_cond) = 2;
    ifnone (a => c_cond) = 7;
  endspecify
endmodule

module test_specify_condition_operators_each;
  logic a = 0;
  logic [3:0] p = 0, q = 0;
  wire b_not, b_and, b_or, b_xor, b_xnor1, b_xnor2;
  wire l_eq, l_ne, l_and, l_or, l_not;
  wire r_and, r_or, r_xor, r_nand, r_nor, r_xnor1, r_xnor2;
  wire c_cat, c_rep, c_cond;

  test_specify_condition_operators_each_cell c (
      a, p, q, b_not, b_and, b_or, b_xor, b_xnor1, b_xnor2, l_eq, l_ne, l_and, l_or, l_not,
      r_and, r_or, r_xor, r_nand, r_nor, r_xnor1, r_xnor2, c_cat, c_rep, c_cond);

  wire [20:0] all = {b_not, b_and, b_or, b_xor, b_xnor1, b_xnor2, l_eq, l_ne, l_and, l_or,
                     l_not, r_and, r_or, r_xor, r_nand, r_nor, r_xnor1, r_xnor2, c_cat,
                     c_rep, c_cond};

  // Sets p and q, toggles a 10 time units later and shows, 3 time units
  // after the toggle, which outputs have followed a (1) and which not (0).
  task automatic phase(input logic [3:0] np, input logic [3:0] nq);
    p = np;
    q = nq;
    #10 a = ~a;
    #3 $display("p=%b q=%b ~:%b &:%b |:%b ^:%b ~^:%b ^~:%b ==:%b !=:%b &&:%b ||:%b !:%b",
                p, q, b_not == a, b_and == a, b_or == a, b_xor == a, b_xnor1 == a,
                b_xnor2 == a, l_eq == a, l_ne == a, l_and == a, l_or == a, l_not == a);
    $display("  u&:%b u|:%b u^:%b u~&:%b u~|:%b u~^:%b u^~:%b {}:%b {{}}:%b ?::%b",
             r_and == a, r_or == a, r_xor == a, r_nand == a, r_nor == a, r_xnor1 == a,
             r_xnor2 == a, c_cat == a, c_rep == a, c_cond == a);
    #5 $display("  all followed after 8: %b", all == {21{a}});
    #2;
  endtask

  initial begin
    #10;
    phase(4'b1111, 4'b1111);
    phase(4'b0000, 4'b0000);
    phase(4'b0110, 4'b0011);
    phase(4'b1011, 4'b0100);
    phase(4'b0010, 4'b0100);
    phase(4'b1101, 4'b0101);
    phase(4'b0000, 4'b1010);
  end
endmodule
