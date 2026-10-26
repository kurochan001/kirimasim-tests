/*
:name: test_illegal_readmem_higher_range
:description: $readmemh selects the highest dimension of a 2-D array with a range (IEEE 1800-2023 Section 21.4)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the load target m[0:1] applies a range to the highest dimension
:expected_stderr_regex: test_illegal_readmem_higher_range\.sv:21:
*/
// A partly indexed multidimensional load target shall index its higher
// dimensions; only the lowest selected dimension may use a slice. The
// load target m[0:1] is a range of the highest dimension.

module test_illegal_readmem_higher_range;
  logic [7:0] m[0:1][0:2];
  initial begin
    $readmemh("words.txt", m[0:1]);   // illegal: range on highest dim
  end
endmodule
