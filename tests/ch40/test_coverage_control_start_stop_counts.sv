/*
:name: test_coverage_control_start_stop_counts
:description: Coverage is collected from the start of simulation without a start call, a stop keeps later toggles out of the collected values, a start after the stop collects them again, and a reset clears them (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.2 40.3.2.3 40.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_control_start_stop_counts.expected
*/
// IEEE 1800-2023 §40.3.2.1: coverage is started automatically at the beginning
// of simulation for every portion of the hierarchy enabled for coverage, so a
// bit that toggles before any $coverage_control call is already counted when
// the start returns SV_COV_OK. `SV_COV_STOP then stops collection, so further
// toggles change no collected value, and `SV_COV_START starts it again, so a
// bit that toggles only after the restart is counted. A start of a hierarchy
// that is already collecting has no effect. `SV_COV_RESET clears all available
// coverage of the hierarchy, so the value read right after it, before another
// toggle, is zero. A tool that reports these calls as anything but OK is left
// out of the positive checks, but an error is never accepted. §40.2.2: toggle
// coverage counts each bit of a signal, so the two later bits add two to the
// value, and §40.3.2.3 reads it.

module cc_work;
  logic [7:0] t = 8'h00;

  task automatic pulse(input int bit_index);
    t[bit_index] = 1'b1;
    #1 t[bit_index] = 1'b0;
    #1;
  endtask
endmodule

module test_coverage_control_start_stop_counts;
  cc_work u();

  int check, start1, stop1, start2, reset1, reset2;
  int before_any_control, after_repeated_start, while_stopped, after_restart, after_reset;

  initial begin
    check = $coverage_control(`SV_COV_CHECK, `SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    $display("check is not ERROR: %0d", check != `SV_COV_ERROR);

    // No start call yet: the automatic start at time zero must have collected.
    u.pulse(0);
    before_any_control = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    $display("coverage is collected before any start call: %0d",
             check != `SV_COV_OK || before_any_control > 0);

    start1 = $coverage_control(`SV_COV_START, `SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    after_repeated_start = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    $display("a start while collecting leaves the values alone: %0d",
             start1 == check && after_repeated_start == before_any_control);

    stop1 = $coverage_control(`SV_COV_STOP, `SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    u.pulse(7);
    while_stopped = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    $display("stop gives OK: %0d", stop1 == `SV_COV_OK);
    $display("a stopped hierarchy collects no toggle: %0d",
             while_stopped == after_repeated_start);

    start2 = $coverage_control(`SV_COV_START, `SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    u.pulse(6);
    after_restart = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    $display("a start after a stop gives the checked availability: %0d",
             start2 == check);
    $display("a restart collects the toggles again: %0d",
             check != `SV_COV_OK || after_restart > after_repeated_start);

    reset1 = $coverage_control(`SV_COV_RESET, `SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    after_reset = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    reset2 = $coverage_control(`SV_COV_RESET, `SV_COV_TOGGLE, `SV_COV_MODULE, "cc_work");
    $display("reset gives OK, also when repeated: %0d",
             reset1 == `SV_COV_OK && reset2 == `SV_COV_OK);
    $display("a reset clears the collected values: %0d", after_reset == 0);
  end
endmodule
