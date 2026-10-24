/*
:name: test_illegal_virtual_interface_compared_other_interface
:description: A virtual interface can only be compared with == or != against a virtual interface or an instance of the same type or null, so a comparison with an instance of another interface is illegal (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual interface v of vco_if is compared with the instance b of vco_other_if
:expected_stderr_regex: test_illegal_virtual_interface_compared_other_interface\.sv:40:
*/
// IEEE 1800-2023 §25.9: the only direct comparisons (== and !=) allowed on a
// virtual interface are with a virtual interface of the same type, with an
// interface instance of the same type, and with null. The procedure makes
// these three comparisons with v and then compares v with the instance b of
// another interface, which has the same members.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count. The 5.052
// release of Verilator accepts the comparison and then fails to compile the
// C++ it generates (comparison of distinct pointer types).

interface vco_if;
  logic d;
endinterface

interface vco_other_if;
  logic d;
endinterface

module test_illegal_virtual_interface_compared_other_interface;
  vco_if a ();
  vco_other_if b ();
  virtual vco_if v, w;
  initial begin
    v = a;
    w = a;
    $display("%0d %0d %0d", v == w, v != a, v == null);
    $display("%0d", v == b);   // illegal: b is an instance of another interface
  end
endmodule
