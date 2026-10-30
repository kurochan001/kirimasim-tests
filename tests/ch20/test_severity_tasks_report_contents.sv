/*
:name: test_severity_tasks_report_contents
:description: $info, $warning, $error and $fatal print a message that names the severity, the file and line of the call, the scope of the call and the simulation time, and includes the user message formatted like $display; $error lets the run go on and $fatal ends it with an error code (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 22.13
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_severity_tasks_report_contents.expected
:expected_exit: nonzero
:expected_stderr_regex: (?i)\A(?=[\s\S]*?(?:info(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?test_severity_tasks_report_contents\.sv:44\b|test_severity_tasks_report_contents\.sv:44\b(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?info))(?=[\s\S]*?(?:msg-one 42 abc(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?test_severity_tasks_report_contents\.sv:44\b|test_severity_tasks_report_contents\.sv:44\b(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?msg-one 42 abc))(?=[\s\S]*?(?:warn(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?test_severity_tasks_report_contents\.sv:48\b|test_severity_tasks_report_contents\.sv:48\b(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?warn))(?=[\s\S]*?(?:msg-two ab 10(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?test_severity_tasks_report_contents\.sv:48\b|test_severity_tasks_report_contents\.sv:48\b(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?msg-two ab 10))(?=[\s\S]*?(?:error(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?test_severity_tasks_report_contents\.sv:52\b|test_severity_tasks_report_contents\.sv:52\b(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?error))(?=[\s\S]*?(?:msg-three 1\+2=3(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?test_severity_tasks_report_contents\.sv:52\b|test_severity_tasks_report_contents\.sv:52\b(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?msg-three 1\+2=3))(?=[\s\S]*?(?:fatal(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?test_severity_tasks_report_contents\.sv:64\b|test_severity_tasks_report_contents\.sv:64\b(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?fatal))(?=[\s\S]*?(?:msg-four end(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?test_severity_tasks_report_contents\.sv:64\b|test_severity_tasks_report_contents\.sv:64\b(?:(?!\.sv:\d)[^\n])*(?:\n(?:(?!\.sv:\d)[^\n])*)?msg-four end))(?=[\s\S]*scope_one)(?=[\s\S]*scope_two)(?=[\s\S]*scope_three)(?=[\s\S]*scope_four)(?=[\s\S]*1111)(?=[\s\S]*2222)(?=[\s\S]*3333)(?=[\s\S]*4444)
*/
// IEEE 1800-2023 §20.10: $info prints a message of no specific severity,
// $warning a warning and $error an error, and the run goes on; $fatal prints
// a fatal error and ends the run with an error code through an implicit
// $finish, so final procedures run. Each message is tool-specific but gives
// the severity, the file and line of the call as `__FILE__ and `__LINE__
// would (§22.13), the hierarchical name of the scope of the call and the
// simulation time, and includes the user message, which is formatted like
// the arguments of $display and may have any number of arguments. All four
// tasks may be called without arguments or with empty parentheses, and
// $fatal may start with a finish number 0, 1 or 2.
// Each of the four calls is made in its own named block at its own time
// (1111, 2222, 3333 and 4444 ns), which the test prints nowhere else, so
// the regular expression can look for the scope and time anywhere. The
// layout of a message is the tool's, so it looks for the severity name and
// the formatted user message next to file:line of the call: before or after
// it, on its line or the next, with no other file:line between them.
// Calls without arguments run after the $error; the other forms of $fatal
// are in a branch that is not taken.
// In release 5.052 of the Verilator tool $fatal stops the run like $stop,
// and the final procedure does not run.

`timescale 1ns/1ns

module test_severity_tasks_report_contents;
  int n = 42;

  initial begin
    #1111;
    begin : scope_one
      $info("msg-one %0d %s", n, "abc");
    end
    #1111;
    begin : scope_two
      $warning("msg-two %h %b", 8'hab, 2'b10);
    end
    #1111;
    begin : scope_three
      $error("msg-three %0d+%0d=%0d", 1, 2, 1 + 2);
    end
    $display("after error");
    $info;
    $warning();
    if (n == 0) begin
      $fatal;
      $fatal(0);
      $fatal(2, "never %0d", n);
    end
    #1111;
    begin : scope_four
      $fatal(1, "msg-four %s", "end");
    end
    $display("not reached");
  end

  final $display("final procedure ran");
endmodule
