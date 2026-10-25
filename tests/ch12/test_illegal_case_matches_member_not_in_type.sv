/*
:name: test_illegal_case_matches_member_not_in_type
:description: the patterns of a pattern-matching case have the type of the case expression (IEEE 1800-2023 Section 12.6.1)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.6.1 12.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pattern names a member Big that the tagged union type of the case expression does not have
:expected_stderr_regex: test_illegal_case_matches_member_not_in_type\.sv:38:
*/
// IEEE 1800-2023 §12.6.1, §12.6: the expression of a pattern-matching case
// statement has a known type, which every case pattern shall have, and the
// patterns are type-checked statically. For a tagged union pattern the
// identifier after tagged is a member name of that type. The type of a has
// the members Small and Wide; Big is a member of another type, so the second
// pattern does not have the type of a.
// Icarus Verilog 13.0 and Verilator 5.052 do not support tagged unions.

module test_illegal_case_matches_member_not_in_type;
  typedef union tagged {
    logic [3:0] Small;
    logic [7:0] Wide;
  } a_t;
  typedef union tagged {
    logic [15:0] Big;
    logic [3:0]  Small;
  } b_t;
  a_t a;
  b_t b;
  initial begin
    a = tagged Wide 8'h5a;
    b = tagged Big 16'h1;
    case (a) matches
      tagged Small .s: $display("small %h", s);
      tagged Big .w:   $display("big %h", w);   // illegal
      tagged Wide .w:  $display("wide %h", w);
    endcase
  end
endmodule
