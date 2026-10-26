/*
:name: test_illegal_extern_module_port_mismatch
:description: an extern module declaration does not match the port name of the module (IEEE 1800-2023 Section 23.5)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the extern declaration of m names its port a but the module body names it b
:expected_stderr_regex: test_illegal_extern_module_port_mismatch\.sv:19:
*/
// An extern module declaration declares the ports of a module whose body
// appears elsewhere; the declaration and the body shall agree in port
// names, positions and equivalent types. The extern declaration names
// the port a, and the body names it b.

extern module m (input logic [3:0] a);   // illegal: port a
module m (input logic [3:0] b);
endmodule
module t;
  logic [3:0] v;
  m u(.b(v));
endmodule
