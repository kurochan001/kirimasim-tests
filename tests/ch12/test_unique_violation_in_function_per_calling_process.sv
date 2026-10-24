/*
:name: test_unique_violation_in_function_per_calling_process
:description: a unique if or case in a function called by two processes keeps a separate violation report for each process, so the flush point of one process does not remove the report of the other (IEEE 1800-2023 Sections 12.4.2.2 and 12.5.3.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2.2 12.5.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_violation_in_function_per_calling_process.expected
:expected_stderr_regex: \A(?=[\s\S]*test_unique_violation_in_function_per_calling_process\.sv:37\b)(?=[\s\S]*test_unique_violation_in_function_per_calling_process\.sv:41\b)(?![\s\S]*test_unique_violation_in_function_per_calling_process\.sv:37\b[\s\S]*test_unique_violation_in_function_per_calling_process\.sv:37\b)(?![\s\S]*test_unique_violation_in_function_per_calling_process\.sv:41\b[\s\S]*test_unique_violation_in_function_per_calling_process\.sv:41\b)
*/
// IEEE 1800-2023 §12.4.2.2 and §12.5.3.2: a violation report is associated
// with the process that executes the check, so a unique if or case in a
// function called by several processes is checked independently for each
// of them, and a flush point of one process discards only its own reports.
// At t=1 the processes p1 and p2 both call pick and pick_case with u = v =
// 1, so the unique if of pick and the unique case of pick_case fail in
// each process. p1 then goes on without a flush point; p2 waits on ev,
// which another process triggers with ->> in the same time step, and calls
// the functions again with v = 0 after it resumes. So each of the two
// lines is reported exactly once, for p1: the regular expression requires
// one message that names each line and rejects two. A shared queue would
// lose the report of p1, and a missing flush would add one for p2.
// The standard leaves the form of the report to the tool.
// Icarus Verilog 13.0 does not support unique and priority if; Verilator 5.052
// reports a violation when the statement executes, not in the Observed
// region, and does not resume a process waiting on an event triggered with
// ->> in the same time step.

`timescale 1ns/1ns
module test_unique_violation_in_function_per_calling_process;
  int r1, r2, r3, r4, r5, r6;
  event ev;
  function automatic int pick(logic u, logic v);
    unique if (u) return 1; else if (v) return 2;
    return 0;
  endfunction
  function automatic int pick_case(logic u, logic v);
    unique case (1'b1) u: return 3; v: return 4; endcase
    return 0;
  endfunction
  initial begin : p1
    #1;
    r1 = pick(1, 1);
    r3 = pick_case(1, 1);
    #2 $display("p1 %0d %0d", r1, r3);
  end
  initial begin : p2
    #1;
    r2 = pick(1, 1);
    r4 = pick_case(1, 1);
    @(ev);
    r5 = pick(1, 0);
    r6 = pick_case(1, 0);
    #1 $display("p2 %0d %0d %0d %0d at %0t", r2, r4, r5, r6, $time);
  end
  initial #1 ->> ev;
endmodule
