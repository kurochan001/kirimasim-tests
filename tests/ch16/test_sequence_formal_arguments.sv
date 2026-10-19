/*
:name: test_sequence_formal_arguments
:description: an actual argument for an untyped formal is substituted with its self-determined type, while one for a typed formal is cast to the formal's type; default actuals, binding by name, $ as an upper bound and an event formal used as a clock also work (IEEE 1800-2023 Sections 16.8, 16.8.1, 16.12.1, 16.12.18)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8 16.8.1 16.12.1 16.12.18 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_formal_arguments.expected
*/
// IEEE 1800-2023 §16.8: an actual argument for an untyped formal is cast to
// its self-determined type and parenthesized before it replaces the formal,
// so for one-bit a and b, a + b is a one-bit sum, 0 when both are 1.
// §16.8.1: an actual for a typed formal is cast to the formal's type, so
// logic [1:0] x gets a + b evaluated as a two-bit value, 2, and bit x gets
// the LSB of 4'b0110, 0. Formals can have default actuals, actuals can be
// bound by name, and $ can be the actual of a formal used as an upper bound.
// §16.12.1 and §16.12.18 give properties the same rules; a formal of type
// event can be the clock. A type applies to the formals after it until the
// next type, so x after event ev is declared untyped. Each cover statement
// counts its matches (§16.14.3). a, b and w are set at the tick at 5 only; p
// is high at 5 and q from 25 to 55; r is high at the falling edges at 10 and
// 30.

`timescale 1ns/1ns

module test_sequence_formal_arguments;
  logic clk = 0, a = 0, b = 0, p = 0, q = 0, r = 0;
  logic [3:0] w = 0;
  int n_untyped = 0, n_typed = 0, n_bit = 0, n_whole = 0, n_default = 0, n_dollar = 0;
  int n_event = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, ...

  sequence is_two_untyped(x);
    x == 2'd2;
  endsequence

  sequence is_two_typed(logic [1:0] x);
    x == 2'd2;
  endsequence

  sequence as_bit(bit x);
    x;
  endsequence

  sequence as_is(x);
    x != 0;
  endsequence

  sequence later(x, y, n = 2, max = 3);
    x ##n y[*1:max];
  endsequence

  property on_event(event ev, untyped x);
    @(ev) x;
  endproperty

  c_untyped: cover property (@(posedge clk) is_two_untyped(a + b)) n_untyped++;
  c_typed: cover property (@(posedge clk) is_two_typed(a + b)) n_typed++;
  c_bit: cover property (@(posedge clk) as_bit(w)) n_bit++;
  c_whole: cover property (@(posedge clk) as_is(w)) n_whole++;
  c_default: cover sequence (@(posedge clk) later(p, q)) n_default++;
  c_dollar: cover sequence (@(posedge clk) later(.x(p), .y(q), .max($))) n_dollar++;
  c_event: cover property (on_event(negedge clk, r)) n_event++;

  initial begin
    a = 1; b = 1; w = 4'b0110; p = 1;   // sampled at 5
    #10 a = 0; b = 0; w = 0; p = 0;
  end

  initial begin
    #20 q = 1;   // sampled at 25 to 55
    #40 q = 0;
  end

  initial begin
    #7 r = 1;    // sampled at the falling edges at 10 and 30
    #5 r = 0;
    #15 r = 1;
    #5 r = 0;
  end

  initial begin
    #80;
    $display("a + b == 2: untyped %0d, logic [1:0] %0d", n_untyped, n_typed);
    $display("4'b0110 as bit %0d, as is %0d", n_bit, n_whole);
    $display("p ##2 q[*1:3] %0d, p ##2 q[*1:$] %0d", n_default, n_dollar);
    $display("@(negedge clk) r %0d", n_event);
    $finish;
  end
endmodule
