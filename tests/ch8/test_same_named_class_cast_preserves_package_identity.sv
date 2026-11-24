/*
:name: test_same_named_class_cast_preserves_package_identity
:description: Classes with the same name in different packages are distinct cast types (IEEE 1800-2023 Section 8.16)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 26.3 6.24.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_same_named_class_cast_preserves_package_identity.expected
:expected_exit: 0
*/
// A base handle to a class from one package can be cast back to its own
// class. A same-named but unrelated class in another package cannot.

package base_pkg;
  class root;
  endclass
endpackage

package first_pkg;
  import base_pkg::*;
  class box extends root;
  endclass
endpackage

package second_pkg;
  import base_pkg::*;
  class box extends root;
  endclass
endpackage

module test_same_named_class_cast_preserves_package_identity;
  initial begin
    first_pkg::box a;
    second_pkg::box b;
    base_pkg::root r;
    a = new();
    r = a;
    begin
      first_pkg::box positive;
      int own_ok, other_ok;
      own_ok = $cast(positive, r);
      other_ok = $cast(b, r);
      $display("CHECK same_type %0d cross_package %0d", own_ok, other_ok);
      if (own_ok != 1 || other_ok != 0) $fatal(1, "wrong class cast result");
    end
    $finish;
  end
endmodule
