/*
:name: test_illegal_type_parameter_hierarchical_type_name
:description: the data type given to a type parameter cannot be named through a hierarchical name, while a package-qualified name is allowed (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance bad overrides the type parameter T with the type sub.local_t, named through the instance sub
:expected_stderr_regex: test_illegal_type_parameter_hierarchical_type_name\.sv:(36|37):
*/
// IEEE 1800-2023 §6.20.3: package references are allowed in the data type of
// a type parameter, but hierarchical names are not. The instance from_pkg
// gives T a type declared in a package; the instance bad names a typedef of
// the instance sub through the hierarchical name sub.local_t.

package test_illegal_type_parameter_hierarchical_type_name_pkg;
  typedef logic [11:0] word_t;
endpackage

module test_illegal_type_parameter_hierarchical_type_name_sub;
  typedef logic [5:0] local_t;
endmodule

module test_illegal_type_parameter_hierarchical_type_name_m #(parameter type T = int) ();
  T v;
  initial $display("%0d", $bits(v));
endmodule

module test_illegal_type_parameter_hierarchical_type_name;
  test_illegal_type_parameter_hierarchical_type_name_sub sub();
  test_illegal_type_parameter_hierarchical_type_name_m
      #(.T(test_illegal_type_parameter_hierarchical_type_name_pkg::word_t)) from_pkg();
  test_illegal_type_parameter_hierarchical_type_name_m
      #(.T(sub.local_t)) bad();   // illegal: a type named hierarchically
endmodule
