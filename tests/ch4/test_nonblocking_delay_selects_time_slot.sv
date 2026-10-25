/*
:name: test_nonblocking_delay_selects_time_slot
:description: A nonblocking assignment without a delay or with a zero delay updates in the NBA region of the current time slot and one with a nonzero delay in the NBA region of the later slot, with the value and target computed when it is scheduled (IEEE 1800-2023 Section 4.9.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.4 4.5 10.4.2 21.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonblocking_delay_selects_time_slot.expected
*/
// IEEE 1800-2023 §4.9.4: a nonblocking assignment computes its value and
// schedules an NBA update event, in the current time step when its delay is
// zero and as a future event when the delay is not zero. The values at that
// moment give both the right-hand side and the target. §4.5: the NBA region
// of a time slot comes after its Active and Inactive regions, and $strobe
// (§21.2.2) prints at the end of the slot.
// At time 1 the process writes x <= 5, z <= #0 9 and arr[i] <= #3 v with
// i = 1 and v = 7, then changes i and v. After #0 (Inactive) x and z are
// still 0, and a $strobe at 1 shows them updated. At 3 nothing has reached
// arr yet. At 4 the process resumes in the Active region before the NBA
// update of that slot and still sees arr[1] = 0, and a $strobe at 4 shows
// arr[1] = 7, with arr[2] untouched.

module test_nonblocking_delay_selects_time_slot;
  int x = 0, z = 0, i = 1, v = 7;
  int arr[4] = '{0, 0, 0, 0};

  initial begin
    #1;
    x <= 5;
    z <= #0 9;
    arr[i] <= #3 v;
    i = 2;
    v = 8;
    #0 $display("at 1 after #0: x=%0d z=%0d", x, z);
    $strobe("strobe at 1: x=%0d z=%0d", x, z);
    #2 $display("at 3: arr=%0d %0d %0d", arr[0], arr[1], arr[2]);
    #1 $display("at 4 active: arr[1]=%0d", arr[1]);
    $strobe("strobe at 4: arr=%0d %0d %0d", arr[0], arr[1], arr[2]);
  end
endmodule
