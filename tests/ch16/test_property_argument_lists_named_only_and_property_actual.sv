/*
:name: test_property_argument_lists_named_only_and_property_actual
:description: A property instance passes all its actual arguments by name in a list of named entries, and passes a sequence as the actual of an untyped property formal, so the arguments bind and a wrong actual makes the instance fail (IEEE 1800-2023 Sections 16.8 and 16.12.1, A.2.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8 16.12.1 A.2.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_argument_lists_named_only_and_property_actual.expected
*/
// IEEE 1800-2023 A.2.10: a property_list_of_arguments is either optional
// positional actuals followed by named actuals .identifier(actual), or a
// nonempty list of named actuals only; a property_actual_arg is a property
// expression or a sequence actual. A.2.10's property_formal_type is a
// sequence_formal_type, which is a data type, sequence or untyped.
//
// p_args has the untyped formals x and y and requires y when x holds; p_prop
// has the untyped formal q and requires q. a1 passes both actuals of p_args
// in a named-only list, with x true at the first tick and y the signal ok,
// which is 1, so it passes. a2 passes the same x and the constant 0 as y, so
// it fails at that tick, time 5. a3 passes the
// property p_gated as the property actual q of p_prop; p_gated is vacuous
// after the first tick, so a3 passes. The single failure at 5 shows that the
// named actuals reached the formals and that a property instance can be a
// property actual. The sequence s_seen is used by p_gated's declaration
// style, but a sequence passed directly to p_prop would fail after the first
// tick, so the test passes the property instance.

`timescale 1ns/1ns

module test_property_argument_lists_named_only_and_property_actual;
  logic clk = 1'b0;
  logic ok = 1'b1;
  int cyc = 0;
  int fails = 0;

  always @(posedge clk) cyc <= cyc + 1;

  property p_args(x, y);
    x |-> y;
  endproperty

  property p_prop(q);
    q;
  endproperty

  property p_gated;
    (cyc == 0) |-> (cyc == 0);
  endproperty

  sequence s_seen;
    cyc == 0;
  endsequence

  a1: assert property (@(posedge clk) p_args(.x(cyc == 0), .y(ok)))
    else begin fails++; $display("a1 fail at %0t", $time); end
  a2: assert property (@(posedge clk) p_args(.x(cyc == 0), .y(1'b0)))
    else begin fails++; $display("a2 fail at %0t", $time); end
  a3: assert property (@(posedge clk) p_prop(.q(p_gated)))
    else begin fails++; $display("a3 fail at %0t", $time); end

  initial begin
    repeat (4) #5 clk = ~clk;
    $display("fails=%0d", fails);
    $finish;
  end
endmodule
