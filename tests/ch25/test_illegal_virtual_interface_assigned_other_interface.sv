/*
:name: test_illegal_virtual_interface_assigned_other_interface
:description: A virtual interface can be assigned only a virtual interface or an instance of the same type or null, so assigning it an instance of another interface is illegal (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance b of vao_other_if is assigned to the virtual interface v of vao_if
:expected_stderr_regex: test_illegal_virtual_interface_assigned_other_interface\.sv:40:
*/
// IEEE 1800-2023 §25.9: the only assignments directly allowed to a virtual
// interface variable are from a virtual interface of the same type, from an
// interface instance of the same type, and from null. The initial procedure
// makes the three legal assignments to v and then assigns the instance b of
// another interface, which has the same members.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count.

interface vao_if;
  logic d;
endinterface

interface vao_other_if;
  logic d;
endinterface

module test_illegal_virtual_interface_assigned_other_interface;
  vao_if a ();
  vao_other_if b ();
  virtual vao_if v, w;
  initial begin
    w = a;
    v = w;
    v = a;
    v = null;
    $display("%0d", v == null);
    v = b;   // illegal: b is an instance of another interface
  end
endmodule
