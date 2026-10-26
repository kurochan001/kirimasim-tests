/*
:name: test_assoc_missing_read_warning_and_index
:description: a missing associative read and an invalid x/z index read the nonexistent value, add no entry, and issue a warning
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assoc_missing_read_warning_and_index.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// IEEE 1800-2023 7.8.6: reading a missing associative entry, or a four-state
// index that contains x or z, returns the Table 7-1 nonexistent value for the
// element type and issues a warning; a user-specified default is the
// exception, which another test observes. Here the element type is int, so
// both reads return 0, and neither read adds an entry, so num() stays 1. The
// regular expression checks that the run reports a warning without fixing its
// wording. Verilator 5.052 returns the same values but does not warn; the
// expected result follows the clause.

module test_assoc_missing_read_warning_and_index;
  int a[string];
  int b[logic [3:0]];
  int r1, r2;

  initial begin
    a["live"] = 17;
    r1 = a["missing"];
    b[4'b0011] = 7;
    r2 = b[4'b1x00];
    $display("missing=%0d size=%0d xz=%0d xzsize=%0d", r1, a.num(), r2, b.num());
  end
endmodule
