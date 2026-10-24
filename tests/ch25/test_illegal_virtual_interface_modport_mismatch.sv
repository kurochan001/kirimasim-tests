/*
:name: test_illegal_virtual_interface_modport_mismatch
:description: A modport selected in a virtual interface declaration is part of its type, so a virtual interface of one modport cannot be assigned to one of another modport, while one without a modport can be assigned to either (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual interface v_drv of the modport drv is assigned to v_mon of the modport mon
:expected_stderr_regex: test_illegal_virtual_interface_modport_mismatch\.sv:38:
*/
// IEEE 1800-2023 §25.9: a virtual interface declaration may select a modport,
// and the modport is then part of its type. An interface instance or a virtual
// interface with no modport may be assigned to a virtual interface with a
// modport, so the assignments from the instance bus and from v_all are
// legal. v_drv and v_mon select different modports of vmm_if.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count.

interface vmm_if;
  logic d;
  modport drv(output d);
  modport mon(input d);
endinterface

module test_illegal_virtual_interface_modport_mismatch;
  vmm_if bus ();
  virtual vmm_if v_all;
  virtual vmm_if.drv v_drv;
  virtual vmm_if.mon v_mon;
  initial begin
    v_all = bus;
    v_drv = bus;
    v_mon = v_all;
    $display("%b", v_mon.d);
    v_mon = v_drv;   // illegal: the modports drv and mon differ
  end
endmodule
