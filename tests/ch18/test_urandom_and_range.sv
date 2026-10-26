/*
:name: test_urandom_and_range
:description: $urandom returns a new 32-bit unsigned value on each call and its seed argument has int type, while $urandom_range returns a value within its inclusive bounds, with a default lower bound of 0 and with reversed arguments when maxval is smaller (IEEE 1800-2023 Sections 18.13.1 and 18.13.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.13.1 18.13.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_urandom_and_range.expected
*/
// IEEE 1800-2023 §18.13.1: $urandom returns a new unsigned 32-bit value on each
// call. Eight consecutive values are all different, and at least one of 64 has
// bit 31 set, so the generator is not a smaller or constant value. The optional
// seed is an int; the same int value gives the same first number. §18.13.2:
// $urandom_range(7,0), $urandom_range(7) and $urandom_range(0,7) all return a
// value in 0 to 7 inclusive, both bounds occur, and $urandom_range(3,3) returns
// 3. $urandom_range(5,2) reverses its arguments and returns 2 to 5.
// $urandom_range(32'hFFFFFFFF, 0) covers the whole unsigned 32-bit range, so
// a value above 32'h7FFFFFFF occurs.

module test_urandom_and_range;
  int unsigned u[8];
  int seed;
  int unsigned s1, s2;
  int distinct, high;
  int outside, seen0, seen7, outside_def, seen0d, seen7d;
  int outside_rev, seen0r, seen7r, outside_same, outside_low, seen2, seen5;
  int high32;

  initial begin
    distinct = 1;
    high = 0;
    for (int i = 0; i < 8; i++) begin
      u[i] = $urandom;
      for (int j = 0; j < i; j++) if (u[j] == u[i]) distinct = 0;
    end
    for (int i = 0; i < 64; i++) begin
      int unsigned v;
      v = $urandom;
      if (v[31]) high = 1;
    end
    seed = 254;
    s1 = $urandom(seed);
    seed = 254;
    s2 = $urandom(seed);
    $display("$urandom: eight calls distinct %0d, bit 31 seen %0d",
             distinct, high);
    $display("$urandom seed: same int seed gives the same value %0d", s1 == s2);
    outside = 0;
    seen0 = 0;
    seen7 = 0;
    repeat (500) begin
      int unsigned v;
      v = $urandom_range(7, 0);
      if (v > 7) outside++;
      if (v == 0) seen0 = 1;
      if (v == 7) seen7 = 1;
    end
    $display("range 0..7: outside %0d, both bounds seen %0d",
             outside, seen0 && seen7);
    outside_def = 0;
    seen0d = 0;
    seen7d = 0;
    repeat (500) begin
      int unsigned v;
      v = $urandom_range(7);
      if (v > 7) outside_def++;
      if (v == 0) seen0d = 1;
      if (v == 7) seen7d = 1;
    end
    $display("range default: outside %0d, both bounds seen %0d",
             outside_def, seen0d && seen7d);
    outside_rev = 0;
    seen0r = 0;
    seen7r = 0;
    repeat (500) begin
      int unsigned v;
      v = $urandom_range(0, 7);
      if (v > 7) outside_rev++;
      if (v == 0) seen0r = 1;
      if (v == 7) seen7r = 1;
    end
    $display("range reversed: outside %0d, both bounds seen %0d",
             outside_rev, seen0r && seen7r);
    outside_same = 0;
    repeat (100) if ($urandom_range(3, 3) != 3) outside_same++;
    $display("range 3,3: outside %0d", outside_same);
    outside_low = 0;
    seen2 = 0;
    seen5 = 0;
    repeat (500) begin
      int unsigned v;
      v = $urandom_range(5, 2);
      if (v < 2 || v > 5) outside_low++;
      if (v == 2) seen2 = 1;
      if (v == 5) seen5 = 1;
    end
    $display("range 5,2: outside %0d, both bounds seen %0d",
             outside_low, seen2 && seen5);
    high32 = 0;
    repeat (64) begin
      int unsigned v;
      v = $urandom_range(32'hFFFFFFFF, 0);
      if (v > 32'h7FFFFFFF) high32 = 1;
    end
    $display("range full 32 bits: bit 31 seen %0d", high32);
  end
endmodule
