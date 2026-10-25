/*
:name: test_illegal_pattern_constant_of_real_type
:description: a constant expression pattern has to be of integral type (IEEE 1800-2023 Section 12.6)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.6 12.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constant expression pattern 1.5 is of type real, not of an integral type
:expected_stderr_regex: test_illegal_pattern_constant_of_real_type\.sv:29:
*/
// IEEE 1800-2023 §12.6: a constant expression used as a pattern shall be of an
// integral type. The member R of the tagged union is real; matching it against
// the identifier pattern .r is legal, but matching it against the constant
// 1.5, which is real, is not.
// Icarus Verilog 13.0 and Verilator 5.052 do not support tagged unions.

module test_illegal_pattern_constant_of_real_type;
  typedef union tagged {
    real R;
    int  I;
  } num_t;
  num_t v;
  initial begin
    v = tagged R 1.5;
    case (v) matches
      tagged R 1.5: $display("one and a half");   // illegal
      tagged R .r:  $display("%f", r);
      tagged I .i:  $display("%0d", i);
    endcase
  end
endmodule
