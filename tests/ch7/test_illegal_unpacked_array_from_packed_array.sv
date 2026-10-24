/*
:name: test_illegal_unpacked_array_from_packed_array
:description: a packed array cannot be assigned directly to an unpacked array without an explicit cast (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the packed array p is assigned directly to the unpacked array u, without a cast
:expected_stderr_regex: test_illegal_unpacked_array_from_packed_array\.sv:30:
*/
// IEEE 1800-2023 §7.6: for assignment a packed array is treated as a vector,
// and any vector expression can be assigned to any packed array whatever
// its bounds, but a packed array cannot be assigned directly to an unpacked
// array without an explicit cast. The packed array p is assigned to the
// packed array q with other bounds and to a vector, and the legal design
// prints them; the last assignment gives p to the unpacked array u.

module test_illegal_unpacked_array_from_packed_array;
  bit [7:0] p = 8'h5a;
  bit [3:0][1:0] q;
  bit [7:0] v;
  bit u [8];
  initial begin
    q = p;
    v = q;
    $display("%h %h %b", q, v, q[2]);
    u = p;   // illegal: packed array to unpacked array without a cast
  end
endmodule
