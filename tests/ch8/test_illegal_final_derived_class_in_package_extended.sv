/*
:name: test_illegal_final_derived_class_in_package_extended
:description: A class declared :final that itself extends a base class, declared in a package, cannot be extended through its package-qualified name, while its base class still can be (IEEE 1800-2023 Section 8.13)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.13 26.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: leaf_c extends fin_pkg::mid_c, which is declared :final
:expected_stderr_regex: test_illegal_final_derived_class_in_package_extended\.sv:36:
*/
// IEEE 1800-2023 §8.13: a class declared with the final specifier shall not be
// extended; the specifier applies to that class only, so its own base class
// can be extended by other classes. §26.3: a class of a package is named from
// outside with the package scope, fin_pkg::mid_c. In fin_pkg, mid_c is final
// and extends root_c. side_c extends fin_pkg::root_c, which is legal; leaf_c
// extends fin_pkg::mid_c. Without the extends in the marked header the legal
// design prints 1 2 1. The 5.054 release of Verilator rejects the marked line
// for this reason; Icarus Verilog 13.0 does not support :final and stops at
// the header of mid_c.

package fin_pkg;
  class root_c;
    int r = 1;
  endclass
  class :final mid_c extends root_c;
    int m = 2;
  endclass
endpackage

class side_c extends fin_pkg::root_c;
endclass

class leaf_c extends fin_pkg::mid_c;   // illegal: mid_c is final
endclass

module test_illegal_final_derived_class_in_package_extended;
  fin_pkg::mid_c m;
  side_c s;
  initial begin
    m = new;
    s = new;
    $display("%0d %0d %0d", m.r, m.m, s.r);
  end
endmodule
