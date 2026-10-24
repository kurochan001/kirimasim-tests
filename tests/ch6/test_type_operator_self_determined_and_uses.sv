/*
:name: test_type_operator_self_determined_and_uses
:description: type(expression) is the self-determined type of the expression without evaluating it, and type references serve in var declarations, casts, local type parameters and type parameter overrides, and in comparisons that are constant expressions (IEEE 1800-2023 Section 6.23)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.23 11.6.1 11.8.1 11.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_operator_self_determined_and_uses.expected
*/
// IEEE 1800-2023 §6.23: type(expression) stands for the self-determined
// result type of the expression (§11.6.1, §11.8.1), and the expression is
// not evaluated: a + b of logic [7:0] and logic [3:0] is logic [7:0]; a * s
// with the signed bit signed [15:0] s is an unsigned 4-state 16-bit type;
// {a, b} has 12 bits; bump() has the type int and is not called, so count
// stays 0. A type reference is used like a type name: in var declarations,
// in a cast, as a local type parameter and in a type parameter override.
// ==, !=, === and !== between type references are constant expressions
// (§11.2.1): they give localparams, a packed dimension and a generate
// condition here. Icarus Verilog 13.0 does not parse type references
// (unsupported construct).

module tou_sub #(parameter type T = int) ();
  T v;
  initial #1 $display("override: bits=%0d", $bits(v));
endmodule

module test_type_operator_self_determined_and_uses;
  logic [7:0] a;
  logic [3:0] b;
  bit signed [15:0] s;
  int count = 0;

  function int bump();
    count++;
    return count;
  endfunction

  var type(a + b) c;
  var type(a * s) d;
  var type({a, b}) e;
  var type(bump()) f;
  localparam type T = type(s);
  T t;
  localparam bit SAME = type(c) == type(logic [7:0]);
  localparam bit DIFF = type(d) != type(int);
  localparam bit CSAME = type(d) === type(logic [15:0]);
  bit [type(e) === type(logic [11:0]) ? 3 : 1 : 0] dimv;
  if (type(b) !== type(bit [3:0])) begin : g
    localparam int SEL = 1;
  end else begin : g
    localparam int SEL = 2;
  end
  tou_sub #(.T(type(e))) u ();

  initial begin
    $display("bits: c=%0d d=%0d e=%0d f=%0d t=%0d count=%0d", $bits(c), $bits(d), $bits(e),
             $bits(f), $bits(t), count);
    d = -1;
    t = -1;
    $display("signs: d<0=%0d t<0=%0d", d < 0, t < 0);
    c = type(a + b)'(16'h1234);
    $display("cast: c=%h", c);
    $display("constant: SAME=%0d DIFF=%0d CSAME=%0d dim=%0d SEL=%0d", SAME, DIFF, CSAME,
             $bits(dimv), g.SEL);
  end
endmodule
