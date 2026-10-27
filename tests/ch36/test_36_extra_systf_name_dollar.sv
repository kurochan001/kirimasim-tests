/*
:name: test_36_extra_systf_name_dollar
:description: A user system task/function name must begin with $, so a name that lacks it is not a system task name and a call of it is rejected (IEEE 1800-2023 Section 36.3)
:tags: ch36
:type: elaboration
:lrm: 1800-2023 36.3 5.6.3 38.37.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the application registers the user system task under the name vt_nodollar, which does not begin with $, and the design calls vt_nodollar as a system task
:expected_stderr_regex: test_36_extra_systf_name_dollar\.sv:29:
:vpi_c: @test_36_extra_systf_name_dollar.c
*/
// IEEE 1800-2023 §36.3, §5.6.3: the name of a user system task/function
// begins with the dollar sign, which is what tells it apart from an ordinary
// task or function name; §38.37.1: an application gives such a name when it
// registers the routine with vpi_register_systf.
// The application next to this test registers a task under the name
// vt_nodollar, without the leading $, and the design calls the task under
// that name. Since a user system task/function name begins with $, that
// registration is not a system task name, so the call is not a call of a
// user system task and the design is illegal. The marked line is the call.
// An implementation that accepted the name would need a task of that name in
// the design, which this one does not declare.

module test_36_extra_systf_name_dollar;
  initial begin
    vt_nodollar;   // illegal: a user system task name must begin with $
  end
endmodule
