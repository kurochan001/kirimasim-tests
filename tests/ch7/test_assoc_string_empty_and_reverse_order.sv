/*
:name: test_assoc_string_empty_and_reverse_order
:description: String associative keys include the empty string and prev follows reverse lexical order (IEEE 1800-2023 Section 7.8.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.2 7.9.7 7.9.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_string_empty_and_reverse_order.expected
*/
// IEEE 1800-2023 7.8.2 7.9.7 7.9.11: An explicit default applies only to
// missing
// elements; prev returns failure without changing the index when no predecessor
// exists.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_assoc_string_empty_and_reverse_order;
  int a[string] = '{default: -7};
  string k;
  int status;
  initial begin
    a[""] = 2; a["b"] = 4; a["aa"] = 3;
    status = a.last(k);
    $display("last=%0d,%s missing=%0d", status, k, a["absent"]);
    status = a.prev(k); $display("prev=%0d,%s", status, k);
    status = a.prev(k); $display("empty=%0d,%0d", status, k.len());
    status = a.prev(k); $display("end=%0d,%0d size=%0d", status, k.len(), a.num());
  end
endmodule
