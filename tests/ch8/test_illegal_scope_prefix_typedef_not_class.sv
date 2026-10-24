/*
:name: test_illegal_scope_prefix_typedef_not_class
:description: a typedef name before the scope resolution operator has to resolve to a class or covergroup type (IEEE 1800-2023 Section 8.23)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.23 6.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the typedef count_t, which is int, is used as the prefix of the scope resolution operator
:expected_stderr_regex: test_illegal_scope_prefix_typedef_not_class\.sv:30:
*/
// IEEE 1800-2023 §8.23: a typedef name may be the left operand of ::, but it
// shall resolve to a class or covergroup type after elaboration. conf_t, a
// typedef of a class, is a legal prefix; count_t is a typedef of int.
// Icarus Verilog 13.0 gives a syntax error on count_t::limit, but also on the
// legal conf_t::limit, so its error does not count.

class conf_c;
  static int limit = 4;
endclass

typedef conf_c conf_t;
typedef int count_t;

module test_illegal_scope_prefix_typedef_not_class;
  initial begin
    $display("%0d", conf_t::limit);
    $display("%0d", count_t::limit);   // illegal: count_t is not a class type
  end
endmodule
