/*
:name: test_illegal_scope_prefix_is_class_variable
:description: the left operand of the scope resolution operator cannot be a class variable (IEEE 1800-2023 Section 8.23)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class variable h is used as the prefix of the scope resolution operator
:expected_stderr_regex: test_illegal_scope_prefix_is_class_variable\.sv:31:
*/
// IEEE 1800-2023 §8.23: the left operand of :: shall be the name of a class
// type, package, covergroup type, coverpoint, cross, typedef or type
// parameter. conf_c::limit names the static property through the class, and
// h.limit through a handle; h::limit uses the variable h as the prefix.
// Icarus Verilog 13.0 gives a syntax error on h::limit, but also on the legal
// conf_c::limit, so its error does not count.

class conf_c;
  static int limit = 4;
endclass

module test_illegal_scope_prefix_is_class_variable;
  conf_c h = new;

  initial begin
    $display("%0d", conf_c::limit);
    $display("%0d", h.limit);
    $display("%0d", h::limit);   // illegal: a variable before ::
  end
endmodule
