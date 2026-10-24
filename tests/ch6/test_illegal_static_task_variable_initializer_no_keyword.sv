/*
:name: test_illegal_static_task_variable_initializer_no_keyword
:description: In a static task, a variable declared with an initializer needs the keyword static or automatic (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 13.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable n of the static task step is declared with an initializer but without static or automatic
:expected_stderr_regex: test_illegal_static_task_variable_initializer_no_keyword\.sv:24:
*/
// IEEE 1800-2023 §6.21: the variables of a static task default to a static
// lifetime, but a static variable declared with an initial value needs the
// explicit keyword static, to show that it is initialized only once. The
// variable n of the static task step could be automatic, so the keyword is
// required; its declaration has neither static nor automatic.
// Icarus Verilog 13.0 gives only a warning for it, and Verilator 5.052
// accepts it.

module test_illegal_static_task_variable_initializer_no_keyword;
  task step();
    int n = 3;    // illegal: initializer without static or automatic
    n++;
    $display("%0d", n);
  endtask
  initial step();
endmodule
