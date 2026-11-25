/*
:name: test_random_initialized_seed_replays_stream
:description: Initialized integral seeds reproduce the same random stream across sequential calls
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.14.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_random_initialized_seed_replays_stream.expected
*/
module test_random_initialized_seed_replays_stream;
  localparam int START = 123456789, OTHER_START = 2026;
  int replay_seed, peer_seed, alternative_seed;
  int first[3], twin[3], other[3], replay[3];
  bit different = 0;

  initial begin
    replay_seed = START;
    peer_seed = START;
    alternative_seed = OTHER_START;
    for (int i = 0; i < 3; i++) begin
      first[i] = $random(replay_seed);
      twin[i] = $random(peer_seed);
      other[i] = $random(alternative_seed);
    end

    replay_seed = START;
    for (int i = 0; i < 3; i++)
      replay[i] = $random(replay_seed);

    for (int i = 0; i < 3; i++) begin
      if (first[i] != twin[i] || first[i] != replay[i])
        $fatal(1, "explicit seed failed to reproduce draw %0d", i);
      if (first[i] != other[i])
        different = 1;
    end
    $display("initialized streams agree=1 distinct seed differs=%0d", different);
    $finish(0);
  end
endmodule
