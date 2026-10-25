/*
:name: test_severity_task_argument_forms
:description: $info, $warning and $error can be called without parentheses, with empty parentheses or with arguments, and $fatal with a finish number and arguments, both as run-time tasks in a procedure and as elaboration tasks among the module items (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 20.10.1 A.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_severity_task_argument_forms.expected
:expected_exit: nonzero
:expected_stderr_regex: (?i)\A(?=[\s\S]*info[^\n]*test_severity_task_argument_forms\.sv:64:)(?=[\s\S]*info[^\n]*test_severity_task_argument_forms\.sv:65:)(?=[\s\S]*info[^\n]*test_severity_task_argument_forms\.sv:66:[^\n]*sv-info n=7)(?=[\s\S]*warn[^\n]*test_severity_task_argument_forms\.sv:67:)(?=[\s\S]*warn[^\n]*test_severity_task_argument_forms\.sv:68:)(?=[\s\S]*warn[^\n]*test_severity_task_argument_forms\.sv:69:[^\n]*sv-warn n=8 w)(?=[\s\S]*error[^\n]*test_severity_task_argument_forms\.sv:70:)(?=[\s\S]*error[^\n]*test_severity_task_argument_forms\.sv:71:)(?=[\s\S]*error[^\n]*test_severity_task_argument_forms\.sv:72:[^\n]*sv-error n=9)(?=[\s\S]*fatal[^\n]*test_severity_task_argument_forms\.sv:74:[^\n]*sv-fatal n=10)
*/
// IEEE 1800-2023 A.1.4 and 20.10: $info, $warning and $error take nothing,
// empty parentheses, or parentheses with a list of arguments formatted like
// $display; $fatal takes nothing or parentheses with a finish number (0, 1
// or 2) and then, after a comma, a list of arguments. A.1.4 and 20.10.1:
// among the module items, the same calls are elaboration severity tasks.
//   - The procedure makes each run-time call on its own line and at its own
//     time. $info, $warning and $error each print a message with the
//     severity and the file and line of the call (and the user message when
//     there is one), and the run goes on (20.10); the regular expression
//     looks for each of them. "after errors" shows that the run went on;
//     $fatal(1, ...) then prints its message and ends the run with an error
//     code through an implicit $finish, so the final procedure runs and
//     "not reached" is not printed.
//   - The elaboration tasks $info and $warning, in all three forms, only
//     print their message and do not keep the simulation from starting
//     (20.10.1). The elaboration $error and $fatal calls in all their forms
//     are in a generate block that is not made (W > 8 is false), so they are
//     not executed and the simulation starts: "simulation started W=4".
// Icarus Verilog 13.0 rejects the elaboration $info and $warning calls with
// a format argument ("sorry: Elaboration tasks currently only support a
// single string argument"); 20.10.1 allows a format string and constant
// expressions there. With plain strings it gives the expected output and
// messages. In release 5.052 of the Verilator tool $fatal stops the run
// like $stop, and the final procedure does not run.

`timescale 1ns/1ns

module test_severity_task_argument_forms #(parameter int W = 4);
  int n = 7;

  $info;
  $info();
  $info("sv-elab-info W=%0d", W);
  $warning;
  $warning();
  $warning("sv-elab-warn W=%0d", W);

  if (W > 8) begin : g_never
    $error;
    $error();
    $error("sv-elab-error W=%0d", W);
    $fatal;
    $fatal(0);
    $fatal(2, "sv-elab-fatal W=%0d", W);
  end

  initial begin
    $display("simulation started W=%0d", W);
    #100;
    $info;
    #1 $info();
    #1 $info("sv-info n=%0d", n);
    #1 $warning;
    #1 $warning();
    #1 $warning("sv-warn n=%0d %s", n + 1, "w");
    #1 $error;
    #1 $error();
    #1 $error("sv-error n=%0d", n + 2);
    #1 $display("after errors");
    #1 $fatal(1, "sv-fatal n=%0d", n + 3);
    $display("not reached");
  end

  final $display("final ran");
endmodule
