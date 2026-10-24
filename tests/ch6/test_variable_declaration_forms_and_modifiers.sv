/*
:name: test_variable_declaration_forms_and_modifiers
:description: Variable declarations with const, var and static, with signing and packed dimensions on integer vector types and signing on integer atoms, with inline packed structure, union and enum types, and with unpacked, dynamic-array and class declarators; a variable keeps its value until the next assignment (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 7.2.1 7.3.1 6.19 7.5.1 8.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variable_declaration_forms_and_modifiers.expected
*/
// IEEE 1800-2023 §6.8, Syntax 6-3: a variable declaration can start with
// const, var and a lifetime; its type can be an integer vector type (bit,
// logic, reg) with a signing and packed dimensions, an integer atom type with
// a signing, or an inline packed structure or union with a signing and packed
// dimensions (7.2.1, 7.3.1) or enum with a base type (6.19); each declarator
// can have unpacked dimensions and an initial expression, a dynamic array an
// initial new[] (7.5.1), and a class handle an initial new (8.8). Signed can
// be given to nets as well. A variable stores its value from one assignment
// to the next: keep holds what was assigned when src changes later.
// The automatic function count_auto starts its variable again at each call,
// and count_static keeps its static one between calls.

module test_variable_declaration_forms_and_modifiers;
  class box;
    int k = 9;
  endclass

  bit signed [1:0][3:0] bv = 8'hf0;
  logic unsigned [7:0] lu = 8'hff;
  reg signed [2:0] rs = 3'b100;
  shortint unsigned su = 16'hffff;
  longint signed ls = -1;
  wire signed [3:0] ws = 4'b1100;
  struct packed signed { logic [3:0] hi; logic [3:0] lo; } ps = 8'hf0;
  union packed { logic [7:0] whole; logic [1:0][3:0] halves; } pu = 8'ha5;
  struct packed { logic [1:0] f; } [2:0] parr = 6'b11_10_01;
  enum bit [1:0] { RED, GREEN = 2'd2, BLUE } color;
  const int c = 7;
  var logic vl = 1'b1;
  static int st = 3;
  int arr [3] = '{4, 5, 6};
  int dyn [] = new[2];
  box b = new;
  logic [7:0] src = 8'h11;
  logic [7:0] keep;
  int a1, a2, s1, s2;

  function automatic int count_auto();
    int n = 0;
    n++;
    return n;
  endfunction

  function int count_static();
    static int n = 0;
    n++;
    return n;
  endfunction

  initial begin
    #1 $display("signing: bv=%0d bv[1]=%h lu=%0d rs=%0d su=%0d ls=%0d ws=%0d", bv, bv[1], lu,
                rs, su, ls, ws);
    $display("inline: ps=%0d ps.hi=%h pu.halves[1]=%h parr[2].f=%b bits %0d", ps, ps.hi,
             pu.halves[1], parr[2].f, $bits(parr));
    $display("enum: bits %0d first %s BLUE=%0d", $bits(color), color.name(), BLUE);
    $display("modifiers: c=%0d vl=%b st=%0d", c, vl, st);
    a1 = count_auto();
    a2 = count_auto();
    s1 = count_static();
    s2 = count_static();
    $display("lifetimes: automatic %0d %0d static %0d %0d", a1, a2, s1, s2);
    $display("declarators: arr=%0d %0d %0d dyn size %0d b.k=%0d", arr[0], arr[1], arr[2],
             dyn.size(), b.k);
    keep = src;
    src = 8'h22;
    #1 $display("storage: keep=%h src=%h", keep, src);
  end
endmodule
