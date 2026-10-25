/*
:name: test_variable_declaration_qualifiers
:description: variable declarations with the optional const, var and static or automatic keywords in their order, with an implicit type (var alone, a signing, a packed dimension) or an explicit one, and a list of two declaration assignments, observed through widths, signedness, x start values, values kept or set again between calls and a const set from a task argument (IEEE 1800-2023 Sections 6.8, 6.20.6, 6.21, A.2.1.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 6.20.6 6.21 A.2.1.3 A.2.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_variable_declaration_qualifiers.expected
*/
// IEEE 1800-2023 A.2.1.3: a variable declaration is an optional const, an
// optional var, an optional lifetime (static or automatic), in this order,
// then a data type or an implicit type and a list of variable declaration
// assignments (A.2.3: one or more, separated by commas). A.10 note 14: the
// data type may be left out only after var, and automatic is legal only in a
// procedural context.
// - §6.8: var with an implicit type gives a logic variable with the signing
//   and packed dimensions written, so v_imp2 and v_one start at x, v_one has
//   one bit, and var signed [7:0] holding 8'hf0 is negative.
// - §6.21: a static variable is set once and keeps its value between calls,
//   an automatic one is set on every entry. bump_auto is an automatic
//   function with an explicit static counter s (11, 21, 31: s grows, a is 1
//   each time); bump_static is a static function with an explicit automatic
//   a and an explicit static s, which the initializer needs there.
// - §6.20.6: a const in an automatic task may be set from an argument, so ck
//   is 6 and then 15; const var static applies all three keywords; a const
//   class handle cannot be written but the members of its object can.
// The calls are separate statements, so their order is fixed. Neither release
// takes the test: Icarus Verilog 13.0 has no lifetime keyword inside a
// function and no const class handle, and the other release stops with an
// internal error on var followed by a packed dimension or a signing.

class Node;
  int val;
  function new(int v = 5);
    val = v;
  endfunction
endclass

module test_variable_declaration_qualifiers;
  var [3:0] v_imp = 4'b1010, v_imp2;
  var v_one;
  var signed [7:0] v_neg = 8'hf0;
  var static bit [1:0] v_static = 2'b11;
  const int C_LIM = 9;
  const var static int C_ALL = 12;
  const Node C_OBJ = new(3);

  function automatic int bump_auto();
    static int s = 0;
    int a = 0;
    s += 1;
    a += 1;
    return s * 10 + a;
  endfunction

  function int bump_static();
    automatic int a = 0;
    static int s = 100;
    s += 1;
    a += 1;
    return s * 10 + a;
  endfunction

  task automatic check(int k);
    const int ck = k * 3;
    $display("k=%0d ck=%0d", k, ck);
  endtask

  int r1, r2, r3;

  initial begin
    $display("v_imp=%b v_imp2=%b v_one=%b bits=%0d,%0d,%0d", v_imp, v_imp2, v_one,
             $bits(v_imp2), $bits(v_one), $bits(v_neg));
    $display("v_neg=%0d below_zero=%0d v_static=%b C_LIM=%0d C_ALL=%0d", v_neg, v_neg < 0,
             v_static, C_LIM, C_ALL);
    C_OBJ.val = C_OBJ.val + 1;
    $display("C_OBJ.val=%0d", C_OBJ.val);
    r1 = bump_auto();
    r2 = bump_auto();
    r3 = bump_auto();
    $display("bump_auto=%0d,%0d,%0d", r1, r2, r3);
    r1 = bump_static();
    r2 = bump_static();
    r3 = bump_static();
    $display("bump_static=%0d,%0d,%0d", r1, r2, r3);
    check(2);
    check(5);
  end
endmodule
