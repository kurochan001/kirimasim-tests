/*
:name: test_36_extra_timing_check_not_systf
:description: A timing check such as $setup is not a system task and cannot be overridden, so using $setup as a system task is rejected even when an application registers that name (IEEE 1800-2023 Section 36.3.2)
:tags: ch36
:type: elaboration
:lrm: 1800-2023 36.3.2 36.3 31.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $setup is a timing check, not a system task, so the call of $setup as a system task outside a specify block is rejected although the application registers a system task named $setup
:expected_stderr_regex: test_36_extra_timing_check_not_systf\.sv:31:
:vpi_c: @test_36_extra_timing_check_not_systf.c
*/
// IEEE 1800-2023 §36.3.2: timing checks, such as $setup, are not system
// tasks, and their names cannot be overridden by a user system
// task/function. §31.3: $setup is a timing check that belongs in a specify
// block.
// The application next to this test registers a user system task under the
// name $setup, and the design then uses $setup as a system task, outside any
// specify block. Since $setup is a timing check and not a system task, the
// registration does not give it that meaning and the call is illegal. The
// marked line is the call.

module test_36_extra_timing_check_not_systf;
  reg a, b;

  initial begin
    a = 1'b0;
    b = 1'b1;
    $setup(a, b, 1);   // illegal: $setup is a timing check, not a task
  end
endmodule
