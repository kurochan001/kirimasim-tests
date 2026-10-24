/*
:name: test_illegal_virtual_interface_external_defparam
:description: An interface instance whose parameter a defparam outside the interface changes cannot be assigned to a virtual interface, while an instance with the same value given by a parameter assignment can (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: u_def, whose parameter W the module changes with a defparam, is assigned to the virtual interface v
:expected_stderr_regex: test_illegal_virtual_interface_external_defparam\.sv:36:
*/
// IEEE 1800-2023 §25.9: it shall be illegal to assign an interface instance
// to a virtual interface if a defparam declared outside the interface changes
// a parameter of that instance. u_ovr gets W = 4 by its parameter value
// assignment and u_def gets W = 4 by a defparam in the module, so both have
// the type of the virtual interface v. Assigning u_ovr to v is legal; assigning
// u_def is not.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count. The 5.052
// release of Verilator accepts the design.

interface vxd_if #(parameter int W = 8);
  logic [W-1:0] d;
endinterface

module test_illegal_virtual_interface_external_defparam;
  vxd_if #(.W(4)) u_ovr ();
  vxd_if u_def ();
  defparam u_def.W = 4;
  virtual vxd_if #(.W(4)) v;
  initial begin
    v = u_ovr;
    $display("%0d", $bits(v.d));
    v = u_def;   // illegal: u_def is changed by a defparam outside the interface
  end
endmodule
