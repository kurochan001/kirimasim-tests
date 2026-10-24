/*
:name: test_illegal_virtual_interface_assigned_integer
:description: A virtual interface can be assigned only a virtual interface or an instance of the same type or null, so assigning it an integer is illegal (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the integer constant 0 is assigned to the virtual interface v
:expected_stderr_regex: test_illegal_virtual_interface_assigned_integer\.sv:33:
*/
// IEEE 1800-2023 §25.9: the only assignments directly allowed to a virtual
// interface variable are from a virtual interface of the same type, from an
// interface instance of the same type, and from the special constant null.
// v is set to the instance a and then to null, which is legal, and then to
// the integer 0.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count.

interface vai_if;
  logic d;
endinterface

module test_illegal_virtual_interface_assigned_integer;
  vai_if a ();
  virtual vai_if v;
  initial begin
    v = a;
    v = null;
    $display("%0d", v == null);
    v = 0;   // illegal: an integer is not null
  end
endmodule
