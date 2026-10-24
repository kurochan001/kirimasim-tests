/*
:name: test_illegal_type_parameter_override_breaks_dependent_value
:description: A value parameter whose type is a type parameter is recomputed when that type is overridden, and an override that makes its assignment illegal, here a class type for a parameter assigned 7, fails elaboration (IEEE 1800-2023 Section 23.10.3)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: u_cls overrides T of ptd_dep with the class ptd_c, so the assignment of 7 to P of type T is illegal
:expected_stderr_regex: test_illegal_type_parameter_override_breaks_dependent_value\.sv:(29|39):
*/
// IEEE 1800-2023 §23.10.3: a parameter can depend on a type parameter; when the
// type parameter is overridden, the dependent parameter is recomputed, and the
// override can make that assignment illegal, which makes elaboration fail.
// When an instance overrides a type parameter, the dependent assignments are
// not made with the default type. P of ptd_dep is 7 of type T: the instances
// with T = int (the default) and T = byte are legal, and u_cls overrides T
// with a class. ptd_cdef has a class as the default of T, which cannot hold
// 4, but its only instance overrides T with int, which is legal. A tool can
// report the error on the declaration of P or on the instance u_cls.
// Icarus Verilog 13.0 stops with an internal error ("Unexpected parameter
// type class") on the declaration of P, which does not count.

class ptd_c;
endclass

module ptd_dep #(parameter type T = int, parameter T P = 7) ();
endmodule

module ptd_cdef #(parameter type T = ptd_c, parameter T Q = 4) ();
endmodule

module test_illegal_type_parameter_override_breaks_dependent_value;
  ptd_dep u_int ();
  ptd_dep #(.T(byte)) u_byte ();
  ptd_cdef #(.T(int)) u_def ();
  ptd_dep #(.T(ptd_c)) u_cls ();   // illegal: 7 cannot be assigned to a class type
  initial $display("built");
endmodule
