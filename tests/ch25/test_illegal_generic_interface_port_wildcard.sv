/*
:name: test_illegal_generic_interface_port_wildcard
:description: A generic interface port has to be connected with a named connection; the implicit .* connection cannot reference it (IEEE 1800-2023 Section 25.3.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generic interface port bus of u is connected only through .*
:expected_stderr_regex: test_illegal_generic_interface_port_wildcard\.sv:35:
*/
// IEEE 1800-2023 §25.3.3: an implicit port connection cannot be used to
// reference a generic interface; a named port connection shall be used. The
// module gdw_user has the generic interface port bus and the input en, and
// the module that instantiates it declares an interface instance bus and a
// variable en. The instance ok connects bus by name and en through .*, which
// is legal; u leaves both to .*.
// Oracle checks: Icarus Verilog 13.0 does not support interface ports and stops
// at the header of a module that has one; the 5.052 release of Verilator stops
// with an internal error about generic interface parameters.

interface gdw_if;
  logic s;
endinterface

module gdw_user(interface bus, input logic en);
endmodule

module test_illegal_generic_interface_port_wildcard;
  gdw_if bus ();
  logic en = 1'b1;
  gdw_user ok (.bus(bus), .*);
  gdw_user u (.*);   // illegal: .* connects the generic interface bus
endmodule
