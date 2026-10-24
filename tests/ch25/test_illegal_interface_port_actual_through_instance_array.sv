/*
:name: test_illegal_interface_port_actual_through_instance_array
:description: A hierarchical reference used as the actual of an interface port cannot resolve through an element of an arrayed instance (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the actual of the interface port b of u is the interface bus inside the element h[0] of the instance array h
:expected_stderr_regex: test_illegal_interface_port_actual_through_instance_array\.sv:39:
*/
// IEEE 1800-2023 §25.3: when the actual of an interface port connection is a
// hierarchical reference to an interface, it shall refer to an interface
// instance and shall not resolve through an arrayed instance or a generate
// block. The instance ok takes the interface bus inside the single instance
// one, which is legal; u takes the one inside h[0], an element of an array
// of instances.
// Oracle checks: Icarus Verilog 13.0 does not support interface ports and stops
// at the header of a module that has one; the 5.052 release of Verilator
// accepts the design.

interface hia_if;
  logic s;
endinterface

module hia_holder;
  hia_if bus ();
endmodule

module hia_user(hia_if b);
endmodule

module test_illegal_interface_port_actual_through_instance_array;
  hia_holder one ();
  hia_holder h [1:0] ();
  hia_user ok (.b(one.bus));
  hia_user u (.b(h[0].bus));   // illegal: through the instance array h
endmodule
