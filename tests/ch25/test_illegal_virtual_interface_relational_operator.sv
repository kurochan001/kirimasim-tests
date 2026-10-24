/*
:name: test_illegal_virtual_interface_relational_operator
:description: Only assignment and the operators == and != are directly allowed on virtual interfaces, so comparing two of them with < is illegal (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual interfaces v and w are compared with the operator <
:expected_stderr_regex: test_illegal_virtual_interface_relational_operator\.sv:32:
*/
// IEEE 1800-2023 §25.9: only assignment and the equality operators == and !=
// are directly allowed on virtual interface variables. The procedure compares
// v and w with == and !=, which is legal, and then with <.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count.

interface vro_if;
  logic d;
endinterface

module test_illegal_virtual_interface_relational_operator;
  vro_if a ();
  vro_if b ();
  virtual vro_if v, w;
  initial begin
    v = a;
    w = b;
    $display("%0d %0d", v == w, v != w);
    $display("%0d", v < w);   // illegal: < is not allowed on virtual interfaces
  end
endmodule
