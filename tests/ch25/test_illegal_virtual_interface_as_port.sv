/*
:name: test_illegal_virtual_interface_as_port
:description: A virtual interface cannot be a port, while it can be an argument of a task and an interface instance can be connected to an interface port (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module vap_user declares the port v with a virtual interface type
:expected_stderr_regex: test_illegal_virtual_interface_as_port\.sv:34:
*/
// IEEE 1800-2023 §25.9: virtual interfaces shall not be used as ports,
// interface items or members of unions, but virtual interface variables may
// be passed as arguments to tasks and functions. vap_ok has an interface
// port, and its task show takes a virtual interface argument, which is
// legal; the input port v of vap_user, on the marked line, has a virtual
// interface type.
// Icarus Verilog 13.0 does not support virtual interfaces and reports syntax
// errors, which do not count; Verilator 5.052 accepts the design.

interface vap_if;
  logic d = 1'b1;
endinterface

module vap_ok (vap_if bus);
  task automatic show(virtual vap_if vi);
    $display("d=%b", vi.d);
  endtask
  initial #1 show(bus);
endmodule

module vap_user (input virtual vap_if v);   // illegal: a virtual interface as a port
  initial #2 $display("d=%b", v.d);
endmodule

module test_illegal_virtual_interface_as_port;
  vap_if bus ();
  virtual vap_if vbus;
  vap_ok u_ok (bus);
  vap_user u_bad (vbus);
  initial vbus = bus;
endmodule
