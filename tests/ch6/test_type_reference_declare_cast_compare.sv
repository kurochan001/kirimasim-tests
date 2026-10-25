/*
:name: test_type_reference_declare_cast_compare
:description: A type reference declares a variable after var and a net after a net type keyword with the type of its expression, is the casting type of a static cast, and is compared with ==, !=, === and !== by type matching (IEEE 1800-2023 Section 6.23)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.23 6.22.1 6.24.1 11.6.1 A.2.1.3 A.8.4 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_reference_declare_cast_compare.expected
*/
// IEEE 1800-2023 §6.23 with footnotes 18 and 45 of A.10: a type reference
// stands for the self-determined type of its expression. In a variable
// declaration it follows the keyword var, and in a net declaration a net
// type keyword (footnote 18). As a constant primary it can be the casting
// type of a static cast (6.24.1), and the only operators it is used with are
// ==, !=, === and !==, which compare it with another type reference and are
// true exactly when the two types match (6.22.1) (footnote 45).
//
// Declarations: v12 is var type(w12), a 4-state 12-bit unsigned variable;
// vs is var type(s6), a 2-state signed 6-bit variable; vm is
// var type(bb + s6), the self-determined type of the sum of the byte bb and
// the 6-bit signed s6, which is 8 bits wide and signed (11.6.1, 11.8.1);
// n12 is wire type(w12), a net driven by a continuous assignment. The test
// shows their $bits, their signedness (-1 assigned and printed in decimal),
// and which types they match: vs matches bit signed [5:0] and not the
// 4-state logic signed [5:0], v12 matches logic [11:0].
//
// Casts: type(s6)'(8'hFF) keeps 6 bits, 6'b111111 = -1 signed;
// type(w12)'(16'hABCD) keeps 12'hBCD; type(bb)'(300) keeps 8 bits of 300,
// which is 44.
//
// Comparisons: type(w12) and type(logic [11:0]) match; type(w12) and
// type(bit [11:0]) do not (4-state against 2-state); int matches
// bit signed [31:0] (6.22.1), so type(i) === type(bit signed [31:0]) is 1
// and !== is 0; type(v12) matches type(w12). EQ is a localparam set from a
// comparison, which is a constant expression.
//
// Icarus Verilog 13.0 does not support the type operator. The 5.052
// release of Verilator prints === 0 !== 1: it does not treat int and
// bit signed [31:0] as matching types, which rule e) of 6.22.1 makes them.

module test_type_reference_declare_cast_compare;
  logic [11:0] w12;
  bit signed [5:0] s6;
  byte bb;
  int i;

  var type(w12) v12;
  var type(s6) vs;
  var type(bb + s6) vm;
  wire type(w12) n12;

  localparam bit EQ = type(w12) == type(logic [11:0]);

  assign n12 = w12 ^ 12'hF0F;

  initial begin
    $display("bits: v12=%0d vs=%0d vm=%0d n12=%0d", $bits(v12), $bits(vs), $bits(vm),
             $bits(n12));
    v12 = -1;
    vs = -1;
    vm = -1;
    $display("minus one: v12=%0d vs=%0d vm=%0d", v12, vs, vm);
    $display("decl: v12~logic[11:0]=%0d vs~bit signed[5:0]=%0d vs~logic signed[5:0]=%0d",
             type(v12) == type(logic [11:0]), type(vs) == type(bit signed [5:0]),
             type(vs) == type(logic signed [5:0]));
    w12 = 12'h0F0;
    #1 $display("net: n12=%h", n12);
    $display("cast: %0d %h %0d", type(s6)'(8'hFF), type(w12)'(16'hABCD), type(bb)'(300));
    $display("== %0d %0d", type(w12) == type(logic [11:0]), type(w12) == type(bit [11:0]));
    $display("!= %0d %0d", type(w12) != type(logic [11:0]), type(w12) != type(bit [11:0]));
    $display("=== %0d !== %0d", type(i) === type(bit signed [31:0]),
             type(i) !== type(bit signed [31:0]));
    $display("v12 matches w12: %0d EQ=%0d", type(v12) == type(w12), EQ);
  end
endmodule
