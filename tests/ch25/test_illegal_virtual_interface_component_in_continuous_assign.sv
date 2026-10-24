/*
:name: test_illegal_virtual_interface_component_in_continuous_assign
:description: The components of an interface reached through a virtual interface can be used only in procedural statements, so a continuous assignment that reads one is illegal, while a procedural read is legal (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment to w reads the component d through the virtual interface v
:expected_stderr_regex: test_illegal_virtual_interface_component_in_continuous_assign\.sv:31:
*/
// IEEE 1800-2023 §25.9: once a virtual interface is initialized, the
// components of the interface instance are available through it with the dot
// notation, but only in procedural statements; they cannot be used in
// continuous assignments. The initial procedure reads v.d, which is legal;
// the continuous assignment to w reads v.d as well.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count. The 5.052
// release of Verilator accepts the design.

interface vca_if;
  logic d = 1'b1;
endinterface

module test_illegal_virtual_interface_component_in_continuous_assign;
  vca_if bus ();
  virtual vca_if v;
  wire w;
  assign w = v.d;   // illegal: a virtual interface component in a continuous assignment
  initial begin
    v = bus;
    $display("%b", v.d);
  end
endmodule
