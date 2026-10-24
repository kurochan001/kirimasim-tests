/*
:name: test_illegal_typedef_base_not_class
:description: a typedef name used as the base class has to resolve to a class type (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.25 8.13 6.18
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class bad_c extends the typedef word_t, which is an int type
:expected_stderr_regex: test_illegal_typedef_base_not_class\.sv:28:
*/
// IEEE 1800-2023 §8.25: when a type parameter or a typedef name is used as a
// base class, it shall resolve to a class type after elaboration. base_t is
// a typedef of a class and is a legal base; word_t is a typedef of int.

class base_c;
  int v = 1;
endclass

typedef base_c base_t;
typedef int word_t;

class ok_c extends base_t;
endclass

class bad_c extends word_t;   // illegal: word_t is not a class type
endclass

module test_illegal_typedef_base_not_class;
  ok_c h = new;
  initial $display("%0d", h.v);
endmodule
