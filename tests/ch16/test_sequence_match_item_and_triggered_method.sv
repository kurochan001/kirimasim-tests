/*
:name: test_sequence_match_item_and_triggered_method
:description: A sequence match item assigns a variable from a constant bit select when the part of the sequence before it matches, and the triggered method of a sequence instance is a primary that says whether the sequence reached its end point in the current time step, also through a hierarchical name, as is a property of another instance (IEEE 1800-2023 Sections 16.10, 16.11 and 16.13.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.6 16.10 16.11 A.8.4 A.10 A.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_match_item_and_triggered_method.expected
*/
// IEEE 1800-2023 A.8.4: a primary can be a sequence method call, which is a
// sequence instance name and the method triggered or matched. A.9.3: a
// property and a sequence are named by identifiers, and a hierarchical name
// can name them through an instance. Footnote 51 of A.10: a variable lvalue
// assigned in a sequence match item uses constant selects only.
//
// §16.10 and §16.11: the match item (a, seen[1:0] = 2'b10) assigns seen when
// a matches. §16.13.6: s.triggered is true in the time step in which the
// sequence reaches its end point and false otherwise. A sequence that
// declares its own clocking event is evaluated when it is used, here by the
// wait statement and by the assertion of the hierarchical property.
//
// a is 1 from time 12 and b from 22, so u.p_ab (a ##1 b) completes at the
// posedge at 25 and its action prints 25. c is 1 from 32 and d from 42, so
// the wait on u.s_cd.triggered ends after the posedge at 45 and prints once.
// e is 1 from 52 and f from 62, so the match item sets seen to 2 at the
// posedge at 55 and the wait on the local s_ef.triggered ends after the
// posedge at 65. At time 70 seen is 2 and s_ef.triggered is false again.
//
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports sequence match
// items or the triggered method, so this expected output follows the
// standard.

`timescale 1ns/1ns

module sub (input var bit clk, a, b, c, d);
  property p_ab;
    @(posedge clk) a ##1 b;
  endproperty

  sequence s_cd;
    @(posedge clk) c ##1 d;
  endsequence
endmodule

module test_sequence_match_item_and_triggered_method;
  bit clk = 0, a = 0, b = 0, c = 0, d = 0, e = 0, f = 0;
  int seen = 0;

  always #5 clk = ~clk;

  sequence s_ef;
    @(posedge clk) (e, seen[1:0] = 2'b10) ##1 f;
  endsequence

  sub u (clk, a, b, c, d);

  ap: assert property (u.p_ab) $display("prop %0d", $time);

  initial begin
    wait (u.s_cd.triggered);
    $display("hseq");
  end

  initial begin
    wait (s_ef.triggered);
    $display("lseq");
  end

  initial begin
    #12 a = 1;
    #10 b = 1;
    #10 c = 1;
    #10 d = 1;
    #10 e = 1;
    #10 f = 1;
    #8 $display("seen %0d trig %0d", seen, s_ef.triggered);
    #5 $finish;
  end
endmodule
