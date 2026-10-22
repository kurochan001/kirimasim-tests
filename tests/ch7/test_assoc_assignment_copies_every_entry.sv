/*
:name: test_assoc_assignment_copies_every_entry
:description: Whole assignment clears old entries and copies every scalar value independently (IEEE 1800-2023 Section 7.9.9)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_assignment_copies_every_entry.expected
*/
// Read every source entry in the destination, including an overwritten key.
// Scalar value copying makes no claim of recursively cloning objects.

module test_assoc_assignment_copies_every_entry;
  int src[int], dst[int];
  initial begin
    src[2] = 40; src[6] = 12; src[100] = -9;
    dst[2] = -1; dst[9] = 99;
    dst = src;
    $display("copy: size=%0d old=%0d values=%0d,%0d,%0d",
             dst.num(), dst.exists(9), dst[2], dst[6], dst[100]);
    src[2] = 400; src.delete(6);
    $display("independent: size=%0d values=%0d,%0d,%0d source=%0d,%0d",
             dst.num(), dst[2], dst[6], dst[100], src[2], src.exists(6));
    src.delete(); dst = src;
    $display("empty copy: size=%0d keys=%0d,%0d,%0d",
             dst.num(), dst.exists(2), dst.exists(6), dst.exists(100));
  end
endmodule
