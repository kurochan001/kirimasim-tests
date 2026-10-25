/*
:name: test_coverage_control_check_while_stopped
:description: $coverage_control reports the coverage availability of a stopped hierarchy unchanged, a repeated start leaves the collected values alone, and every control of an existing scope returns a value of Table 40-1 that is not an error (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.2 40.3.2.3 40.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_control_check_while_stopped.expected
*/
// IEEE 1800-2023 §40.3.2.1: `SV_COV_CHECK asks whether coverage information
// can be obtained from a hierarchy. That is availability, not collection, so a
// check before and after `SV_COV_STOP gives the same value (the coverage "could
// have been stopped"). Table 40-1 allows a check and a start the values
// SV_COV_OK, SV_COV_NOCOV and SV_COV_PARTIAL and a stop and a reset only
// SV_COV_OK, and a start reports the availability of the same hierarchy, so
// here it repeats what the check gave. Starting a hierarchy that is already
// collecting has no effect, so the collected toggle value does not change
// across a second start. A reset clears the collected values but not their
// availability, since it has no effect where coverage is not available.
// §40.3.2.2 and §40.3.2.3: a maximum of zero means no coverage is available,
// so the check must then say SV_COV_NOCOV. The design toggles its signals and
// runs its task before the calls and does nothing during them, so the calls
// are made in one time step and nothing changes between two readings.

module cc_probe;
  logic [7:0] t = 8'h00;

  task automatic pulse(input int bit_index);
    t[bit_index] = 1'b1;
    #1 t[bit_index] = 1'b0;
    #1;
  endtask
endmodule

module test_coverage_control_check_while_stopped;
  cc_probe u();

  int maximum, check0, stop1, check1, stop2, check2;
  int start1, value1, start2, value2, reset1, check3, reset2, value3, check4;

  task automatic probe(input int coverage_type, input string name);
    // Everything below runs in one time step: u has stopped toggling.
    maximum = $coverage_get_max(coverage_type, `SV_COV_MODULE, "cc_probe");
    check0 = $coverage_control(`SV_COV_CHECK, coverage_type, `SV_COV_MODULE, "cc_probe");
    stop1 = $coverage_control(`SV_COV_STOP, coverage_type, `SV_COV_MODULE, "cc_probe");
    check1 = $coverage_control(`SV_COV_CHECK, coverage_type, `SV_COV_MODULE, "cc_probe");
    stop2 = $coverage_control(`SV_COV_STOP, coverage_type, `SV_COV_MODULE, "cc_probe");
    check2 = $coverage_control(`SV_COV_CHECK, coverage_type, `SV_COV_MODULE, "cc_probe");
    start1 = $coverage_control(`SV_COV_START, coverage_type, `SV_COV_MODULE, "cc_probe");
    value1 = $coverage_get(coverage_type, `SV_COV_MODULE, "cc_probe");
    start2 = $coverage_control(`SV_COV_START, coverage_type, `SV_COV_MODULE, "cc_probe");
    value2 = $coverage_get(coverage_type, `SV_COV_MODULE, "cc_probe");
    reset1 = $coverage_control(`SV_COV_RESET, coverage_type, `SV_COV_MODULE, "cc_probe");
    check3 = $coverage_control(`SV_COV_CHECK, coverage_type, `SV_COV_MODULE, "cc_probe");
    value3 = $coverage_get(coverage_type, `SV_COV_MODULE, "cc_probe");
    reset2 = $coverage_control(`SV_COV_RESET, coverage_type, `SV_COV_MODULE, "cc_probe");
    check4 = $coverage_control(`SV_COV_CHECK, coverage_type, `SV_COV_MODULE, "cc_probe");

    $display("%s: check is OK, NOCOV or PARTIAL: %0d", name,
             check0 == `SV_COV_OK || check0 == `SV_COV_NOCOV
             || check0 == `SV_COV_PARTIAL);
    $display("%s: stop gives OK: %0d",
             name, stop1 == `SV_COV_OK && stop2 == `SV_COV_OK);
    $display("%s: check is unchanged by stopping: %0d",
             name, check1 == check0 && check2 == check0);
    $display("%s: start gives the checked availability: %0d",
             name, start1 == check0 && start2 == check0);
    $display("%s: a repeated start leaves coverage alone: %0d", name, value1 == value2);
    $display("%s: reset gives OK: %0d", name, reset1 == `SV_COV_OK && reset2 == `SV_COV_OK);
    $display("%s: reset clears the collected values: %0d", name, value3 == 0);
    $display("%s: check is unchanged by resetting: %0d",
             name, check3 == check0 && check4 == check0);
    $display("%s: check is NOCOV exactly when the maximum is zero: %0d",
             name, (check0 == `SV_COV_NOCOV) == (maximum == 0));
  endtask

  initial begin
    u.pulse(0);
    u.pulse(7);
    probe(`SV_COV_TOGGLE, "toggle");
    probe(`SV_COV_STATEMENT, "statement");
  end
endmodule
