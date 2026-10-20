/*
:name: test_illegal_named_interface_port_other_type
:description: A port of a named interface type cannot be connected to an instance of another interface (IEEE 1800-2023 Section 23.3.3.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.4 25.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port of type cfgi_a is connected to an instance of cfgi_b
:expected_stderr_regex: test_illegal_named_interface_port_other_type\.sv:31:
*/
// IEEE 1800-2023 §23.3.3.4: a port declared with a named interface type shall
// be connected to an instance of the identical interface (25.3.2); only a
// generic interface port takes any interface.

interface cfgi_a;
  logic x;
endinterface

interface cfgi_b;
  logic x;
endinterface

module user(cfgi_a bus);
endmodule

module test_illegal_named_interface_port_other_type;
  cfgi_b b();
  user u(b);           // illegal: cfgi_b for a cfgi_a port
endmodule
