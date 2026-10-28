/*
:name: test_A_extra_repetitions
:description: Boolean abbreviations allow the consecutive [*count] and [+] forms, the nonconsecutive [=count] form and the goto [->count] form, and each form holds when its operand is true at every tick the abbreviation needs, while the unbounded [*] form admits an empty match and cannot be asserted as a property (IEEE 1800-2023 Sections 16.9.2 and A.2.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.2 A.2.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_repetitions.expected
*/
// IEEE 1800-2023 A.2.10, boolean_abbrev: a Boolean expression takes a
// consecutive_repetition, a nonconsecutive_repetition or a goto_repetition.
// The consecutive forms are [*const_or_range_expression] and [+]; the
// nonconsecutive form is [=const_or_range_expression] and the goto form is
// [->const_or_range_expression]. Every operand here is the literal 1, which
// is true at every tick, so an attempt of each property succeeds at every
// tick from the second tick on, and no attempt fails. The form [*] is
// [*0:$], which admits the empty match, so §16.12.22 does not allow it as a
// property and the test leaves it out.

`timescale 1ns/1ns
module test_A_extra_repetitions;
  logic clk = 0;
  int fails = 0;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
  endclocking

  a_con: assert property (1'b1[*2]) else fails++;
  a_plus: assert property (1'b1[+]) else fails++;
  a_goto: assert property (1'b1[->1]) else fails++;
  a_non: assert property (1'b1[=1]) else fails++;

  initial begin
    #30 $display("fails=%0d", fails);
    $finish;
  end
endmodule
