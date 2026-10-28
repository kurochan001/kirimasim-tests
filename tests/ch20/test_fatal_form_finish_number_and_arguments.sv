/*
:name: test_fatal_form_finish_number_and_arguments
:description: A $fatal call with the finish number 2 and a list of arguments prints a fatal message that includes the formatted arguments and ends the run with an error code at the time of the call (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 20.2 A.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fatal_form_finish_number_and_arguments.expected
:expected_exit: nonzero
:expected_stderr_regex: (?i)\A(?=[\s\S]*(?:fatal[^\n]*test_fatal_form_finish_number_and_arguments\.sv:35:[^\n]*ff-msg n=42 end|test_fatal_form_finish_number_and_arguments\.sv:35:[^\n]*fatal[^\n]*ff-msg n=42 end))
*/
// IEEE 1800-2023 A.1.4 and 20.10: $fatal is written either without
// parentheses or with parentheses that hold a finish number, which is 0, 1
// or 2, optionally followed by a comma and a list of arguments formatted
// like $display. Here the call has the finish number 2 and the arguments
// of the message "ff-msg n=42 end".
// It prints a message with its severity and the file and line of the call
// (the regular expression looks for them), and it ends the run with an
// error code through an implicit $finish (20.2): the final procedure runs,
// the statement after the call is not reached, and neither is the second
// initial procedure, which would print at 10.
// In release 5.052 of the Verilator tool $fatal stops the run like $stop,
// and the final procedure does not run.

`timescale 1ns/1ns

module test_fatal_form_finish_number_and_arguments;
  int n = 6;

  initial begin
    $display("before fatal n=%0d", n);
    #5 $fatal(2, "ff-msg n=%0d %s", n * 7, "end");
    $display("not reached");
  end

  initial #10 $display("not reached at 10");

  final $display("final ran at %0t", $time);
endmodule
