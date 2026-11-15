/*
:name: test_illegal_random_seed_literal
:description: the seed argument of $random is a literal, not a variable (IEEE 1800-2023 Section 20.14.1)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second $random call gives the literal 7 as its seed, which is not a variable
:expected_stderr_regex: test_illegal_random_seed_literal\.sv:24:
*/
// IEEE 1800-2023 §20.14.1: the seed argument of $random shall be an
// integral variable. The first call gives the int variable iseed, which is
// legal; the second gives the integral literal 7, which is not a variable,
// and is the one error. With a variable in place of 7 the design is legal.

module test_illegal_random_seed_literal;
  int iseed = 1;
  int r;
  initial begin
    r = $random(iseed);
    r = $random(7);   // illegal: not a variable
  end
endmodule

// Oracle check: Icarus Verilog 13.0 compiles the design and reports the
// literal seed only when the call runs, so the runner sees the design
// accepted; the build of the 5.054 release of Verilator fails in its
// generated C++ code, not on the named line. The cited clause alone decides
// this test.
