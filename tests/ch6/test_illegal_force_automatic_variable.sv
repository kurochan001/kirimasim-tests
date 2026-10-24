/*
:name: test_illegal_force_automatic_variable
:description: An automatic variable cannot be written by a procedural continuous assignment such as force (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 13.3.1 10.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the force statement writes the automatic variable av of an automatic task
:expected_stderr_regex: test_illegal_force_automatic_variable\.sv:22:
*/
// IEEE 1800-2023 §6.21: automatic variables shall not be written with
// procedural continuous assignments; force (§10.6.2) is one. av is a
// variable of the automatic task t (§13.3.1).
// The design is accepted by Verilator 5.052.

module test_illegal_force_automatic_variable;
  task automatic t();
    int av;
    force av = 1;    // illegal: procedural continuous assignment to an automatic variable
  endtask
  initial t();
endmodule
