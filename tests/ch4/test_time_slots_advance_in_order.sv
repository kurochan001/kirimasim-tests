/*
:name: test_time_slots_advance_in_order
:description: Simulation time moves to the earliest nonempty time slot, in increasing order, after all the events of the current slot are processed, and the simulation ends when no slot has events left (IEEE 1800-2023 Section 4.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4 4.5 9.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_slots_advance_in_order.expected
*/
// IEEE 1800-2023 §4.4: all the events of the current time slot are processed
// before the simulation advances to the next nonempty time slot, so time
// never goes backward. §4.5: the reference algorithm moves to the first
// nonempty time slot as long as one is left. §9.2.3: final procedures run at
// the end of the simulation.
// Processes started in the order 7, 3, 12 and a chain of three #1 delays
// record $time when they wake: the times are logged as 3 3 7 12 whatever the
// order of the two processes at 3. At 3 a process writes x <= 1 and then
// y = 1 after #0, and the process that runs at 4 sees both. No event is left
// after 12, so the simulation ends there and the final procedure prints the
// log and the time 12.

module test_time_slots_advance_in_order;
  int log_t[$];
  int x = 0, y = 0;

  initial #7 log_t.push_back($time);
  initial #3 log_t.push_back($time);
  initial #12 log_t.push_back($time);

  initial begin
    #1;
    #1;
    #1 log_t.push_back($time);
  end

  initial begin
    #3;
    x <= 1;
    #0 y = 1;
  end

  initial #4 $display("at 4: x=%0d y=%0d", x, y);

  final begin
    string s;
    foreach (log_t[i]) s = {s, $sformatf(" %0d", log_t[i])};
    $display("times:%s", s);
    $display("end at %0d", $time);
  end
endmodule
