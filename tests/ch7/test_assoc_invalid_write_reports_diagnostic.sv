/*
:name: test_assoc_invalid_write_reports_diagnostic
:description: An invalid four-state key write is ignored with a warning (IEEE 1800-2023 Section 7.8.6)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.6 7.8.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_invalid_write_reports_diagnostic.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// Only one write is invalid. Silently ignoring the write must fail the
// raw diagnostic predicate even if all normalized values are correct.

module test_assoc_invalid_write_reports_diagnostic;
  int a[logic [3:0]];
  logic [3:0] bad_key;
  initial begin
    a[4'b0011] = 17;
    bad_key = 4'bx011;
    a[bad_key] = 99;
    $display("size=%0d retained=%0d exists=%0d", a.num(), a[4'b0011],
             a.exists(4'b0011));
  end
endmodule
