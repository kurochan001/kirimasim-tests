/*
:name: test_rng_state_format_and_replay
:description: Object and process RNG states replay before separate format observations
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.13.4 18.13.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rng_state_format_and_replay.expected
*/
module test_rng_state_format_and_replay;
  class generator;
    rand bit [15:0] value;
  endclass

  initial begin
    generator object_rng;
    process thread_rng;
    string object_state, thread_state;
    int unsigned object_values[2], thread_values[2];
    bit object_replayed, thread_replayed;

    object_replayed = 1;
    thread_replayed = 1;

    object_rng = new;
    thread_rng = process::self();
    object_rng.srandom(177);
    thread_rng.srandom(711);
    object_state = object_rng.get_randstate();
    thread_state = thread_rng.get_randstate();
    foreach (object_values[i]) begin
      if (!object_rng.randomize()) $fatal(1, "object randomize failed");
      object_values[i] = {16'b0, object_rng.value};
      thread_values[i] = $urandom;
    end
    object_rng.set_randstate(object_state);
    thread_rng.set_randstate(thread_state);
    foreach (object_values[i]) begin
      if (!object_rng.randomize()) $fatal(1, "object replay failed");
      object_replayed &= object_values[i] == {16'b0, object_rng.value};
      thread_replayed &= thread_values[i] == $urandom;
    end
    $display("object replay=%0d process replay=%0d", object_replayed, thread_replayed);
    if ($test$plusargs("observe_state")) begin
      $display("object size=%0d prefix=%02h,%02h", object_state.len(),
               object_state.getc(0), object_state.getc(1));
      $display("process size=%0d prefix=%02h,%02h", thread_state.len(),
               thread_state.getc(0), thread_state.getc(1));
    end
`ifdef OBSERVE_UNKNOWN_STATE
    $display("before setting manually constructed state");
    object_rng.set_randstate("no saved state");
    $display("set_randstate returned");
`endif
    $finish(0);
  end
endmodule
