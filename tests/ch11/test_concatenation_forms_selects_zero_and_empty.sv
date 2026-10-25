/*
:name: test_concatenation_forms_selects_zero_and_empty
:description: Concatenations and multiple concatenations, constant and not, with and without a bit or part select after them, a zero multiplier next to a sized operand, a string replication with a multiplier read at run time, and the empty unpacked array concatenation that empties a queue and a dynamic array (IEEE 1800-2023 Section 11.4.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1 11.4.12.2 10.10 A.8.1 A.8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concatenation_forms_selects_zero_and_empty.expected
*/
// IEEE 1800-2023 A.8.1: a concatenation is braces around one or more
// comma-separated expressions, constant ones in a constant concatenation; a
// multiple concatenation is braces around a multiplier and a concatenation;
// {} is the empty unpacked array concatenation (footnote 40). A.8.4: a
// primary, and a constant primary, can be a concatenation or a multiple
// concatenation followed by an optional select in brackets, or the empty
// unpacked array concatenation.
// §11.4.12: a select on a concatenation treats it as a packed array [n-1:0].
// §11.4.12.1: the multiplier is a constant; a zero multiplier gives a part of
// size zero, which is ignored inside a concatenation that has an operand of
// positive size. §11.4.12.2: a string replication may use a multiplier that
// is not constant. §10.10: {} assigned to a queue or a dynamic array gives an
// array with no elements.
//
// With a = 4'h9 and b = 4'h3:
//   P = {4'hA, 4'h5} = a5, Q = {3{4'h7}} = 777, R = {4'hA, 4'h5}[6:3] = 4 and
//   S = {3{2'b10}}[4:1] = 5 are constant;
//   {a, b, 4'h5} = 935, {a, b}[5:2] = 4, {a, b}[7] = 1, {2{a, b}} = 9393 and
//   {2{a, b}}[11:4] = 39;
//   {a, {0{b}}} is a alone, 9 with 4 bits;
//   {n{"ab"}} is ababab for n = 3 and ab for n = 1;
//   the queue and the dynamic array have 2 and 1 elements, then 0 after {}.
//
// Icarus Verilog 13.0 rejects a select after a concatenation or a multiple
// concatenation as a syntax error.

module test_concatenation_forms_selects_zero_and_empty;
  localparam [7:0] P = {4'hA, 4'h5};
  localparam [11:0] Q = {3{4'h7}};
  localparam [3:0] R = {4'hA, 4'h5}[6:3];
  localparam [3:0] S = {3{2'b10}}[4:1];
  logic [3:0] a = 4'h9, b = 4'h3;
  int n = 3;
  int q [$];
  int d [];
  string s1, s2;

  initial begin
    $display("const %h %h %h %h", P, Q, R, S);
    $display("concat %h %h %b %h %h", {a, b, 4'h5}, {a, b}[5:2], {a, b}[7], {2{a, b}},
             {2{a, b}}[11:4]);
    $display("zero %h %0d", {a, {0{b}}}, $bits({a, {0{b}}}));
    s1 = {n{"ab"}};
    n = 1;
    s2 = {n{"ab"}};
    $display("string %s %s", s1, s2);
    q = {1, 2};
    d = {7};
    $display("sizes %0d %0d", q.size(), d.size());
    q = {};
    d = {};
    $display("empty %0d %0d", q.size(), d.size());
  end
endmodule
