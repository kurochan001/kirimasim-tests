/*
:name: test_illegal_assignment_pattern_in_port_expression
:description: an assignment pattern expression cannot be used as a port expression in a module declaration (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port p of sub_bad_m is declared with the assignment pattern expression ab_t'{a, b} as its port expression
:expected_stderr_regex: test_illegal_assignment_pattern_in_port_expression\.sv:30:
*/
// IEEE 1800-2023 §10.9: an assignment pattern expression shall not be used in
// a port expression in a module, interface or program declaration. The
// non-ANSI port p of sub_ok_m is the concatenation {a, b} of two inputs,
// which is legal; the port of sub_bad_m is written as ab_t'{a, b}.
// The 5.052 release of Verilator reports both port expressions as unsupported,
// so its error does not count.

typedef struct packed {
  logic a;
  logic b;
} ab_t;

module sub_ok_m (.p({a, b}));
  input a, b;
endmodule

module sub_bad_m (.p(ab_t'{a, b}));   // illegal: assignment pattern as a port expression
  input a, b;
endmodule

module test_illegal_assignment_pattern_in_port_expression;
  logic [1:0] v = 2'b10;
  sub_ok_m u_ok (.p(v));
  initial #1 $display("%b", u_ok.a);
endmodule
