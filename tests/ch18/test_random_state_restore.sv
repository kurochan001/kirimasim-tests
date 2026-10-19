/*
:name: test_random_state_restore
:description: get_randstate and set_randstate, and srandom with the same seed, repeat the same random values for an object and a process (IEEE 1800-2023 Section 18.13.4)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.13.4 18.13.5 18.13.3 18.14.3 18.13.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_random_state_restore.expected
*/
// IEEE 1800-2023 §18.13.4, §18.13.5: get_randstate() returns the state of an
// object's random number generator, and set_randstate() puts it back, so the
// next randomize() gives the same values as before. §18.13.3: srandom() with
// the same seed starts the same sequence again, for an object and for a process
// (18.14.3). §18.13.2: $urandom_range(max, min) is within the range, also with
// the bounds in the other order. The values themselves are not printed.

class rsr_obj;
  rand int v;
endclass

module test_random_state_restore;
  rsr_obj o;
  string st;
  int x1, x2, y1[3], y2[3];
  int in_range = 1;

  initial begin
    o = new;
    st = o.get_randstate();
    void'(o.randomize()); x1 = o.v;
    o.set_randstate(st);
    void'(o.randomize()); x2 = o.v;
    $display("set_randstate repeats the value: %0d", x1 == x2);

    o.srandom(42);
    foreach (y1[i]) begin void'(o.randomize()); y1[i] = o.v; end
    o.srandom(42);
    foreach (y2[i]) begin void'(o.randomize()); y2[i] = o.v; end
    $display("object srandom repeats the sequence: %0d", y1 == y2);

    process::self().srandom(7);
    foreach (y1[i]) y1[i] = $urandom;
    process::self().srandom(7);
    foreach (y2[i]) y2[i] = $urandom;
    $display("process srandom repeats the sequence: %0d", y1 == y2);

    repeat (100) begin
      if (!($urandom_range(7, 3) inside {[3:7]})) in_range = 0;
      if (!($urandom_range(3, 7) inside {[3:7]})) in_range = 0;
    end
    $display("$urandom_range stays in range: %0d", in_range);
  end
endmodule
