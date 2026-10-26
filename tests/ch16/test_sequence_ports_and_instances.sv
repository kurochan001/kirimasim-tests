/*
:name: test_sequence_ports_and_instances
:description: A sequence declaration takes a nonempty comma-separated list of formal ports, a sequence instance passes positional and named actual arguments that bind to those formals, and throughout requires its left operand at every tick of the sequence, so a wrong actual or a false left operand makes the instance fail (IEEE 1800-2023 Sections 16.8 and 16.9.9, A.2.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8 16.9.9 A.2.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_ports_and_instances.expected
*/
// IEEE 1800-2023 A.2.10: a sequence_declaration is sequence
// sequence_identifier [ ( [ sequence_port_list ] ) ] ; { assertion_variable
// declaration } sequence_expr endsequence [ : name ], and sequence_port_list
// is a nonempty comma-separated list of sequence_port_items. A
// sequence_instance is a package-scoped or hierarchical sequence identifier
// with optional parentheses that hold positional actual arguments, named
// actual arguments written .name(value), or both.
//
// s_two has two formals x and y and matches when x holds at one clock tick
// and y at the next. a1 passes both actuals by position with the values that
// make s_two match at time 5; a2 passes the same actuals by name; a3 passes a
// y actual that is false at the next tick, so its instance does not match
// and its fail action reports the time. The count 1 shows that the actual
// arguments reach the formals, and the named form binds the same values as
// the positional form. a4 requires cyc >= 0 throughout the one-tick sequence
// cyc == 0, which holds at the first tick, and passes; a5 requires cyc >= 0
// throughout cyc == 1, which fails at the first tick, so the left operand of
// throughout is checked.

`timescale 1ns/1ns

module test_sequence_ports_and_instances;
  logic clk = 1'b0;
  int cyc = 0;
  int fails = 0;

  always @(posedge clk) cyc <= cyc + 1;

  sequence s_two(x, y);
    x ##1 y;
  endsequence : s_two

  a1: assert property (@(posedge clk) (cyc == 0) |-> s_two(cyc == 0, cyc == 1))
    else begin fails++; $display("a1 fail at %0t", $time); end
  a2: assert property (@(posedge clk) (cyc == 0) |-> s_two(.x(cyc == 0), .y(cyc == 1)))
    else begin fails++; $display("a2 fail at %0t", $time); end
  a3: assert property (@(posedge clk) (cyc == 0) |-> s_two(cyc == 0, cyc == 2))
    else begin fails++; $display("a3 fail at %0t", $time); end
  a4: assert property (@(posedge clk) (cyc == 0) |-> ((cyc >= 0) throughout (cyc == 0)))
    else begin fails++; $display("a4 fail at %0t", $time); end
  a5: assert property (@(posedge clk) (cyc == 0) |-> ((cyc >= 0) throughout (cyc == 1)))
    else begin fails++; $display("a5 fail at %0t", $time); end

  initial begin
    repeat (4) #5 clk = ~clk;
    $display("fails=%0d", fails);
    $finish;
  end
endmodule
