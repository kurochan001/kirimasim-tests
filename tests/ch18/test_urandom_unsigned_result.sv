/*
:name: test_urandom_unsigned_result
:description: $urandom returns an unsigned 32-bit value on each call, so no call gives a negative value or a value above 32'hFFFFFFFF, consecutive calls differ, and the same int seed gives the same first value (IEEE 1800-2023 Section 18.13.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.13.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_urandom_unsigned_result.expected
*/
// IEEE 1800-2023 §18.13.1: $urandom returns a new 32-bit random number on each
// call, and the number is unsigned; the optional seed argument has the type
// int, and the same seed gives the same sequence. A signed 32-bit result would
// be negative in about half of 400 calls, and a 64-bit result would exceed
// 32'hFFFFFFFF in some of them. The test counts both, and it counts the calls
// whose value repeats the previous one: a constant result repeats in all 399
// pairs. It also calls $urandom with the int seed 254 twice and compares the
// first values. The random values themselves are not printed, because they
// depend on the implementation.

module test_urandom_unsigned_result;
  int negative, above32, repeat_previous, distinct;
  longint signed v, previous;
  int seed;
  int unsigned first_seed, second_seed;

  initial begin
    negative = 0;
    above32 = 0;
    repeat_previous = 0;
    distinct = 0;
    previous = -1;
    for (int i = 0; i < 400; i++) begin
      v = $urandom;
      if (v < 0) negative++;
      if (v > 64'h0000_0000_FFFF_FFFF) above32++;
      if (v == previous) repeat_previous++;
      else distinct++;
      previous = v;
    end
    seed = 254;
    first_seed = $urandom(seed);
    seed = 254;
    second_seed = $urandom(seed);
    $display("negative %0d, above 32 bits %0d", negative, above32);
    $display("distinct seen %0d", distinct > 1);
    $display("same int seed gives the same first value %0d",
             first_seed == second_seed);
  end
endmodule
