/*
:name: test_illegal_generic_interface_port_dot_name
:description: A generic interface port has to be connected with a named connection; an implicit .name connection cannot reference it (IEEE 1800-2023 Section 25.3.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generic interface port bus of u is connected by the implicit .bus connection
:expected_stderr_regex: test_illegal_generic_interface_port_dot_name\.sv:33:
*/
// IEEE 1800-2023 §25.3.3: an implicit port connection cannot be used to
// reference a generic interface; a named port connection shall be used. The
// module gdn_user has the generic interface port bus, and an interface
// instance named bus exists where it is instantiated. The instance ok uses
// the named connection .bus(bus); u uses .bus.
// Oracle checks: Icarus Verilog 13.0 does not support interface ports and stops
// at the header of a module that has one; the 5.052 release of Verilator stops
// with an internal error about generic interface parameters.

interface gdn_if;
  logic s;
endinterface

module gdn_user(interface bus);
endmodule

module test_illegal_generic_interface_port_dot_name;
  gdn_if bus ();
  gdn_user ok (.bus(bus));
  gdn_user u (.bus);   // illegal: implicit connection of a generic interface
endmodule
