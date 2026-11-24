/*
:name: test_if_qualifiers_same_input_different_contracts
:description: Each if qualifier selects the first true branch and unique0 allows no match
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_qualifiers_same_input_different_contracts.expected
:expected_stderr_regex: (?is)\A(?!.*(?:violation|no\s+match|no\s+condition\s+matched))
*/
// Unique and priority have an explicit fallback. Unique0 has no fallback
// and must preserve its sentinel on a miss. Priority may have two true
// conditions, but still selects the first one.
module test_if_qualifiers_same_input_different_contracts;
  task automatic check(input int selector);
    int u, z, p;
    u = -1;
    z = -1;
    p = -1;

    unique if (selector == 1) u = 11;
    else if (selector == 2) u = 12;
    else u = 19;

    unique0 if (selector == 1) z = 21;
    else if (selector == 2) z = 22;

    priority if (selector == 1) p = 31;
    else if (selector inside {1, 2}) p = 32;
    else p = 39;

    $display("selector=%0d unique=%0d unique0=%0d priority=%0d", selector, u, z, p);
  endtask

  initial begin
    check(1);
    check(2);
    check(3);
  end
endmodule
