/*
:name: test_assoc_traversal_gaps_and_preserved_keys
:description: Traversal accepts absent input keys and preserves the argument on failure (IEEE 1800-2023 Sections 7.9.6-7.9.7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.6 7.9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_traversal_gaps_and_preserved_keys.expected
*/
// Observe exact status and key together, including empty next/prev.
// No key value is required of empty first/last.

module test_assoc_traversal_gaps_and_preserved_keys;
  int a[int];
  int k, status;
  initial begin
    a[-5] = 1; a[10] = 2; a[30] = 3;
    k = 10; status = a.next(k); $display("next present=%0d,%0d", status, k);
    k = 20; status = a.next(k); $display("next gap=%0d,%0d", status, k);
    k = 30; status = a.prev(k); $display("prev present=%0d,%0d", status, k);
    k = 20; status = a.prev(k); $display("prev gap=%0d,%0d", status, k);
    k = 30; status = a.next(k); $display("next end=%0d,%0d", status, k);
    k = -5; status = a.prev(k); $display("prev end=%0d,%0d", status, k);
    a.delete();
    k = 17; status = a.next(k); $display("next empty=%0d,%0d", status, k);
    k = -9; status = a.prev(k); $display("prev empty=%0d,%0d", status, k);
  end
endmodule
