/*
:name: test_illegal_random_seed_real_variable
:description: the seed argument of $random is a variable of type real, which is not integral (IEEE 1800-2023 Section 20.14.1)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second $random call gives the real variable rseed as its seed, which is not an integral variable
:expected_stderr_regex: test_illegal_random_seed_real_variable\.sv:29:
*/
// IEEE 1800-2023 §20.14.1: the seed argument of $random shall be an
// integral variable. The first call gives the int variable iseed, which is
// legal; the second gives rseed, a variable of type real, which is not an
// integral type, and is the one error. With rseed declared int the design
// is legal.
// Icarus Verilog 13.0 accepts the real seed, and the build of the 5.054
// release of Verilator fails in its generated C++ code, not on the named
// line, so the cited clause alone decides this test.

module test_illegal_random_seed_real_variable;
  int iseed = 1;
  real rseed = 1.0;
  int r;
  initial begin
    r = $random(iseed);
    r = $random(rseed);   // illegal: real seed
  end
endmodule
