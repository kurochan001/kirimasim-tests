/*
:name: test_illegal_virtual_interface_parameter_value_mismatch
:description: The type of an interface instance includes its default parameter values, so an instance with the default W = 8 cannot be assigned to a virtual interface declared with W = 16, while an instance with W = 16 can (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: u8, whose W keeps its default 8, is assigned to the virtual interface v16 declared with W = 16
:expected_stderr_regex: test_illegal_virtual_interface_parameter_value_mismatch\.sv:36:
*/
// IEEE 1800-2023 §25.9: the type of an interface includes the actual
// parameters, default or overridden, of the instance or the virtual interface
// declaration, and their values and types shall match for the two to be of the
// same type and assignment compatible. u16 is instantiated with W = 16 and
// matches v16; u8 keeps the default W = 8, as does vdef, which has no
// parameter value assignment.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count.

interface vpm_if #(parameter int W = 8);
  logic [W-1:0] d;
endinterface

module test_illegal_virtual_interface_parameter_value_mismatch;
  vpm_if #(16) u16 ();
  vpm_if u8 ();
  virtual vpm_if #(16) v16;
  virtual vpm_if vdef;
  initial begin
    v16 = u16;
    vdef = u8;
    $display("%0d %0d", $bits(v16.d), $bits(vdef.d));
    v16 = u8;   // illegal: W is 8 in u8 and 16 in v16
  end
endmodule
