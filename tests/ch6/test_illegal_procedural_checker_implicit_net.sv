/*
:name: test_illegal_procedural_checker_implicit_net
:description: an undeclared actual of a procedural checker instance is not an implicit net
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.10 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the implicit-net permission does not extend to a procedural checker instance
:expected_stderr_regex: test_illegal_procedural_checker_implicit_net\.sv:25:
*/
// IEEE 1800-2023 6.10: an implicit net is assumed for an undeclared identifier
// in the port connection list of a module, interface, program, or static
// checker instance, but not for a procedural checker instance (17.3). The
// marked instantiation of a checker inside an initial block connects an
// undeclared identifier, which a tool has to reject.

checker chk(input logic a);
endchecker

module test_illegal_procedural_checker_implicit_net;
  initial begin
    chk c1(undeclared_sig); // illegal: no implicit net in procedural context
  end
endmodule
