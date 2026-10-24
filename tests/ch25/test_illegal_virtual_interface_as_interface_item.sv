/*
:name: test_illegal_virtual_interface_as_interface_item
:description: A virtual interface cannot be an interface item, while a virtual interface variable in a module is legal (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface vpi_outer declares the virtual interface variable inner as an interface item
:expected_stderr_regex: test_illegal_virtual_interface_as_interface_item\.sv:28:
*/
// IEEE 1800-2023 §25.9: virtual interfaces shall not be used as ports,
// interface items, or members of unions. The module declares a virtual
// interface variable of vpi_inner, which is legal; the interface vpi_outer
// declares one among its items.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count. The 5.052
// release of Verilator accepts the design.

interface vpi_inner;
  logic d;
endinterface

interface vpi_outer;
  logic e;
  virtual vpi_inner inner;   // illegal: a virtual interface as an interface item
endinterface

module test_illegal_virtual_interface_as_interface_item;
  vpi_inner a ();
  vpi_outer b ();
  virtual vpi_inner v;
  initial begin
    v = a;
    $display("%0d", v == a);
  end
endmodule
