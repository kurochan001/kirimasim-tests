/*
:name: test_fatal_form_without_parentheses
:description: A $fatal call without parentheses ends the run with an error code at the time of the call, after printing a fatal message (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 20.2 A.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fatal_form_without_parentheses.expected
:expected_exit: nonzero
:expected_stderr_regex: (?i)\A(?=[\s\S]*?(?:fatal(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?test_fatal_form_without_parentheses\.sv:35\b|test_fatal_form_without_parentheses\.sv:35\b(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?fatal))
*/
// IEEE 1800-2023 A.1.4 and 20.10: $fatal is written either without
// parentheses or with parentheses that hold a finish number, which is 0, 1
// or 2, optionally followed by a comma and a list of arguments formatted
// like $display. Here the call has no parentheses.
// It prints a message with its severity and the file and line of the call
// (the regular expression looks for them in either order, on one line or
// two, since the layout of the message is the tool's), and it ends the run
// with an error code through an implicit $finish (20.2): the final
// procedure runs, the statement after the call is not reached, and neither
// is the second initial procedure, which would print at 10.
// In release 5.052 of the Verilator tool $fatal stops the run like $stop,
// and the final procedure does not run.

`timescale 1ns/1ns

module test_fatal_form_without_parentheses;
  int n = 6;

  initial begin
    $display("before fatal n=%0d", n);
    #5 $fatal;
    $display("not reached");
  end

  initial #10 $display("not reached at 10");

  final $display("final ran at %0t", $time);
endmodule
