/*
:name: test_class_shallow_copy_random_state
:description: a shallow copy takes over the random number generator state, the rand_mode and constraint_mode settings and the randc cycle of the source object, so both objects then randomize to the same values (IEEE 1800-2023 Section 8.12)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12 18.4.2 18.8 18.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_shallow_copy_random_state.expected
*/
// IEEE 1800-2023 §8.12: a shallow copy copies the internal state used for
// randomization: the random number generator (RNG) state, the constraint_mode
// status of each constraint (§18.9), the rand_mode status of each random
// variable (§18.8), and the cyclic state of randc variables (§18.4.2).
// x has m switched off as a random variable and the constraint low_m switched
// off, then randomizes five times, using five values of the 16-value cycle of
// rc. y is a copy of x. The copy reports the same modes, and then x and y
// randomize eleven times each in step: with the same RNG state and randc
// state they give equal values every time, and the eleven rc values of y are
// the rest of the cycle that x started, so the sixteen values are all
// different. The values themselves depend on the tool and are not printed.
// Icarus Verilog 13.0 does not support constraints and randomize().

module test_class_shallow_copy_random_state;
  class rnd_c;
    rand bit [15:0] r;
    randc bit [3:0] rc;
    rand int m;
    constraint low_m { m > 0; m < 10; }
  endclass

  rnd_c x, y;
  bit [3:0] seen[$];
  bit [3:0] uniq[$];
  int ok = 1;
  int mismatches = 0;

  initial begin
    x = new;
    x.srandom(11);
    x.m.rand_mode(0);
    x.low_m.constraint_mode(0);
    x.m = 42;
    repeat (5) begin
      ok &= x.randomize();
      seen.push_back(x.rc);
    end
    y = new x;
    $display("copy: m rand_mode=%0d low_m constraint_mode=%0d r rand_mode=%0d m=%0d",
             y.m.rand_mode(), y.low_m.constraint_mode(), y.r.rand_mode(), y.m);
    repeat (11) begin
      ok &= x.randomize();
      ok &= y.randomize();
      if (x.r != y.r || x.rc != y.rc || x.m != y.m) mismatches++;
      seen.push_back(y.rc);
    end
    uniq = seen.unique();
    $display("randomize ok=%0d mismatches=%0d m=%0d", ok, mismatches, y.m);
    $display("rc values=%0d distinct=%0d", seen.size(), uniq.size());
  end
endmodule
