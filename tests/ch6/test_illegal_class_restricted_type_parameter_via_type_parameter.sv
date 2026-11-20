/*
:name: test_illegal_class_restricted_type_parameter_via_type_parameter
:description: A type parameter restricted with class that is given another type parameter conforms only when that parameter resolves to a class, so passing int down through an unrestricted type parameter is an error (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3 6.20.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance bad gives int to the unrestricted type parameter T of mid_m, which passes it on to the type parameter C of inner_m, declared type class
:expected_stderr_regex: test_illegal_class_restricted_type_parameter_via_type_parameter\.sv:(46|36|41):
*/
// IEEE 1800-2023 §6.20.3: a type parameter declared with class before its name
// accepts only class types, and it shall be an error if it is assigned a type
// that does not conform. The type that a parameter is given is the type that
// its value resolves to, so a type parameter used as the value conforms when
// its own value does. mid_m has the unrestricted type parameter T and passes
// it to C of inner_m, which is restricted to classes. The instance ok keeps T
// as the class node_c, which is legal; the instance bad gives T the type int,
// which is legal for T, but makes C of its inner_m instance int. A tool can
// report the instance bad, the instance of inner_m in mid_m or the
// declaration of C. inner_m only declares a variable of type C, which would
// also be legal for int, so the restriction is the only rule broken. With
// node_c in place of int in the marked line the design is legal and prints
// done.
// The 5.054 release of Verilator rejects the instance of inner_m in mid_m
// for this reason. Icarus Verilog 13.0 does not support a basic type
// restriction on a type parameter and reports a syntax error on the
// declaration of C, one of the lines the test names, which does not count.

class node_c;
  int id = 4;
endclass

module inner_m #(parameter type class C = node_c) ();   // (or reported here)
  C h;
endmodule

module mid_m #(parameter type T = node_c) ();
  inner_m #(.C(T)) in ();   // (or reported here)
endmodule

module test_illegal_class_restricted_type_parameter_via_type_parameter;
  mid_m ok ();
  mid_m #(.T(int)) bad ();   // illegal: int reaches the class-restricted C
  initial $display("done");
endmodule
