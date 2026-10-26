/*
:name: test_illegal_readmem_address_outside_slice
:description: $readmemh addresses fall outside the selected slice (IEEE 1800-2023 Section 21.4)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the start and finish addresses 3 and 5 lie outside the slice m[0][0:2]
:expected_stderr_regex: test_illegal_readmem_address_outside_slice\.sv:21:
*/
// When the load target uses slice syntax, the start and finish addresses
// shall fall within the bounds of that slice. The slice m[0][0:2] has
// addresses 0 to 2, but the call asks for 3 to 5.

module test_illegal_readmem_address_outside_slice;
  logic [7:0] m[0:1][0:2];
  initial begin
    $readmemh("words.txt", m[0][0:2], 3, 5);   // illegal: outside slice
  end
endmodule
