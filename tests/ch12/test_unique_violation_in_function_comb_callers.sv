/*
:name: test_unique_violation_in_function_comb_callers
:description: a unique if or case in a function called by two always_comb procedures is flushed only for the procedure that is triggered again, and reported for the other (IEEE 1800-2023 Sections 12.4.2.2 and 12.5.3.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2.2 12.5.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_violation_in_function_comb_callers.expected
:expected_stderr_regex: \A(?=[\s\S]*test_unique_violation_in_function_comb_callers\.sv:35\b)(?=[\s\S]*test_unique_violation_in_function_comb_callers\.sv:39\b)(?![\s\S]*test_unique_violation_in_function_comb_callers\.sv:35\b[\s\S]*test_unique_violation_in_function_comb_callers\.sv:35\b)(?![\s\S]*test_unique_violation_in_function_comb_callers\.sv:39\b[\s\S]*test_unique_violation_in_function_comb_callers\.sv:39\b)
*/
// IEEE 1800-2023 §12.4.2.2 and §12.5.3.2: a violation report is associated
// with the process that executes the check, so a unique if or case in a
// function called by several processes is checked independently for each
// of them, and a flush point of one process discards only its own reports.
// The always_comb procedures b1 and b2 call f_if and f_case. At t=1, c
// becomes 1 while d, which follows !c through a nonblocking assignment, is
// still 1, so the calls of b1 fail once and pass when the change of d
// triggers b1 again; b2 calls them with e = f = 1, and nothing triggers it
// again. So each of the two lines is reported exactly once, for b2: the
// regular expression requires one message that names each line and
// rejects two. A shared queue would lose the report of b2 at the flush of
// b1, and a missing flush would add one for b1. The standard leaves the
// form of the report to the tool.
// Icarus Verilog 13.0 does not support unique and priority if; Verilator
// 5.052 reports a violation when the statement executes.

`timescale 1ns/1ns
module test_unique_violation_in_function_comb_callers;
  logic c = 0, d = 1, e = 1, f = 0;
  int s1, s2, t1, t2;
  function automatic int f_if(logic u, logic v);
    unique if (u) return 1; else if (v) return 2;
    return 0;
  endfunction
  function automatic int f_case(logic u, logic v);
    unique case (1'b1) u: return 3; v: return 4; endcase
    return 0;
  endfunction
  always @(c) d <= !c;
  always_comb begin : b1
    s1 = f_if(c, d);
    t1 = f_case(c, d);
  end
  always_comb begin : b2
    s2 = f_if(e, f);
    t2 = f_case(e, f);
  end
  initial begin
    #1 c = 1;
    f = 1;
    #1 $display("s1=%0d t1=%0d s2=%0d t2=%0d", s1, t1, s2, t2);
  end
endmodule
