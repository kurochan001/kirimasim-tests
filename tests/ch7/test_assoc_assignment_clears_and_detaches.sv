/*
:name: test_assoc_assignment_clears_and_detaches
:description: Associative assignment removes old destination keys and passing by value makes an independent local copy (IEEE 1800-2023 Section 7.9.9)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.9 7.9.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_assignment_clears_and_detaches.expected
*/
// IEEE 1800-2023 7.9.9 7.9.10: Assignment replaces entries rather than merging;
// a by-value formal can delete and replace its keys without affecting the
// caller.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_assoc_assignment_clears_and_detaches;
  int a[int], b[int];
  task automatic modify(input int local_copy[int]);
    local_copy.delete(); local_copy[99] = 8;
    $display("local=%0d,%0d", local_copy.num(), local_copy[99]);
  endtask
  initial begin
    a[2] = 4; a[6] = 12; b[9] = 99;
    b = a; a[2] = 40;
    modify(b);
    $display("dest=%0d old_key=%0d copied=%0d source=%0d", b.num(),
             b.exists(9), b[2], a[2]);
  end
endmodule
