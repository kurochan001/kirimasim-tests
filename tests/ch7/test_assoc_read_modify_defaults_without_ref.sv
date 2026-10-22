/*
:name: test_assoc_read_modify_defaults_without_ref
:description: Read-modify-write uses user and type defaults without ref support (IEEE 1800-2023 Section 7.8.7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_read_modify_defaults_without_ref.expected
*/
// Isolate initialization from ref support. The untouched struct member
// exposes initialization of the whole element.

module test_assoc_read_modify_defaults_without_ref;
  typedef struct { int lo = 3; int hi = 9; } range_t;
  int hits[string] = '{default:10};
  int counts[int];
  range_t ranges[int];
  initial begin
    hits["add"] += 5; hits["inc"]++;
    counts[4] += 3; counts[5]++;
    ranges[7].hi = 1;
    $display("user: add=%0d inc=%0d num=%0d", hits["add"], hits["inc"], hits.num());
    $display("type: add=%0d inc=%0d num=%0d", counts[4], counts[5], counts.num());
    $display("struct: lo=%0d hi=%0d num=%0d",
             ranges[7].lo, ranges[7].hi, ranges.num());
  end
endmodule
