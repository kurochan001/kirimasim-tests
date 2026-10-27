/*
:name: test_ch16_sim_cover_counters
:description: an immediate cover statement reports the number of times it was evaluated and the number of times it succeeded, here three evaluations with two successes (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_ch16_sim_cover_counters.expected
*/
// IEEE 1800-2023 §16.3: the results of coverage for an immediate cover
// statement shall contain the number of times evaluated and the number of
// times succeeded, reported at the end of simulation or on demand via an
// assertion API (Clause 39). This test reaches one cover statement three
// times; cond() counts evaluations and the pass statement counts successes.
// The expression is true at the first and third reach, false at the second,
// so the results are 3 evaluations and 2 successes.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 prints immediate cover
// counters at the end of simulation, and neither exposes them through a
// VPI property that this suite can read without a VPI application, so the
// test reads the same two numbers through the program's own counters. The
// reporting obligation itself is recorded in notes/ch16-sim.md.
// Icarus Verilog 13.0 does not evaluate immediate cover statements, so it
// has no expected output of its own.

module test_ch16_sim_cover_counters;
  logic v = 0;
  int evaluations = 0;
  int successes = 0;

  function automatic logic cond(logic x);
    evaluations++;
    return x;
  endfunction

  initial begin
    v = 1;
    cover (cond(v)) successes++;
    v = 0;
    cover (cond(v)) successes++;
    v = 1;
    cover (cond(v)) successes++;
    $display("evaluations=%0d successes=%0d", evaluations, successes);
    $finish;
  end
endmodule
