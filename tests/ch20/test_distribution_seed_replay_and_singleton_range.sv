/*
:name: test_distribution_seed_replay_and_singleton_range
:description: Replaying a distribution seed reproduces its result and a singleton uniform interval returns its endpoint (IEEE 1800-2023 Section 20.14.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_distribution_seed_replay_and_singleton_range.expected
*/
// IEEE 1800-2023 20.14.2: Seed is an inout state. Equal incoming seeds for the
// same function yield equal result and next state; a bounded singleton
// distribution has one possible value.

module test_distribution_seed_replay_and_singleton_range;
  int seed_a, seed_b, a, b;
  bit replay = 1, singleton = 1;
  initial begin
    seed_a = 321; seed_b = 321;
    repeat (10) begin
      a = $dist_normal(seed_a, 10, 3); b = $dist_normal(seed_b, 10, 3);
      if (a != b || seed_a != seed_b) replay = 0;
    end
    repeat (10) begin
      a = $dist_uniform(seed_a, -4, -4);
      if (a != -4) singleton = 0;
    end
    $display("seed_replay=%0d singleton=%0d", replay, singleton);
  end
endmodule
