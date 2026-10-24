/*
:name: test_illegal_virtual_interface_modport_to_plain
:description: A virtual interface with no modport can be assigned to one with a modport, but not the other way, since the modport is part of its type (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: v_mp, which selects the modport mon, is assigned to v_all, which selects no modport
:expected_stderr_regex: test_illegal_virtual_interface_modport_to_plain\.sv:37:
*/
// IEEE 1800-2023 §25.9: a selected modport is part of the type of a virtual
// interface, and an interface instance or a virtual interface with no modport
// selected may be assigned to a virtual interface with a modport selected.
// The assignments from the instance bus and from v_all to v_mp are legal;
// the assignment the other way, from v_mp to v_all, is not among the allowed
// ones.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count.

interface vmp_if;
  logic d;
  modport mon(input d);
endinterface

module test_illegal_virtual_interface_modport_to_plain;
  vmp_if bus ();
  virtual vmp_if v_all;
  virtual vmp_if.mon v_mp;
  initial begin
    v_all = bus;
    v_mp = bus;
    v_mp = v_all;
    $display("%b", v_mp.d);
    v_all = v_mp;   // illegal: the modport mon cannot be dropped
  end
endmodule
