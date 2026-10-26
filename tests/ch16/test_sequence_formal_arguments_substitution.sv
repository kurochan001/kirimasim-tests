/*
:name: test_sequence_formal_arguments_substitution
:description: an untyped actual is substituted as a parenthesized expression cast to its self-determined type, a typed formal views a variable actual through its type, a property formal of type sequence is substituted as a sequence_expr, and a local input formal of a property takes its default actual and its given actual (IEEE 1800-2023 Sections 16.8, 16.8.1, 16.12.18 and 16.12.19)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8 16.8.1 16.12.18 16.12.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_formal_arguments_substitution.expected
*/
// IEEE 1800-2023 §16.8: an untyped formal is replaced by the actual as an
// expression term in parentheses, cast to its self-determined type. Hence
// x + k with the actual a | b is (a | b) + k and not a | (b + k), and
// x == 0 with the actual a + b, a self-determined 4-bit sum, is 0 == 0.
// §16.8.1: a variable_lvalue actual is viewed through the type of a typed
// formal, so the byte y read through formal v of type bit [3:0] is 4'h5.
// §16.12.18: a property formal of type sequence is replaced by the
// sequence_expr actual, and one of type bit [3:0] is cast, so the byte 8'hA5
// becomes 4'h5. §16.12.19: a local input formal of a property obeys the
// sequence rules and takes its default actual when none is given. The pass
// counts of the two properties are printed at the end, so the order of their
// actions in a time step does not matter.

`timescale 1ns/1ns

module test_sequence_formal_arguments_substitution;
  logic clk = 0, go = 0;
  logic [3:0] a = 4'hf, b = 4'h1;
  byte y = 8'ha5;
  int prec = 0, self = 0, viewed = 0, local_sum = 0;
  int typed_pass = 0, typed_fail = 0, prop_pass = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, ...

  function automatic void add_prec(int v);
    prec = v;
  endfunction

  function automatic void add_self(bit v);
    self = v;
  endfunction

  function automatic void add_view(int v);
    viewed = v;
  endfunction

  function automatic void add_loc(int v);
    local_sum += v;
  endfunction

  sequence s_prec(x, k);
    (go, add_prec(x + k));
  endsequence

  sequence s_self(x);
    (go, add_self(x == 0));
  endsequence

  sequence s_view(bit [3:0] v);
    (go, add_view(v));
  endsequence

  property p_typed(bit [3:0] v, sequence sq);
    sq |-> (v == 4'h5);
  endproperty

  property p_prop(sequence sq);
    sq |-> sq;
  endproperty

  property p_loc(local input int w = 4, input int z);
    @(posedge clk) (go, add_loc(w + z));
  endproperty

  c_prec: cover sequence (@(posedge clk) s_prec(a | b, 1));
  c_self: cover sequence (@(posedge clk) s_self(a + b));
  c_view: cover sequence (@(posedge clk) s_view(y));

  a_typed: assert property (@(posedge clk) p_typed(y, go)) typed_pass++;
    else typed_fail++;
  a_prop: assert property (@(posedge clk) p_prop(go)) prop_pass++;
  a_loc: assert property (p_loc(.z(2)));
  a_loc2: assert property (p_loc(.w(10), .z(2)));

  initial begin
    $assertvacuousoff;
    go = 1;
    #6 go = 0;
    #29;
    $display("prec: %0d", prec);
    $display("self: %0d", self);
    $display("viewed: %0d", viewed);
    $display("typed passes=%0d fails=%0d", typed_pass, typed_fail);
    $display("property formal passes=%0d", prop_pass);
    $display("local sum: %0d", local_sum);
    $finish;
  end
endmodule
