/*
:name: test_assoc_array_iter_minimal
:description: Associative array minimal: first/next/last/num/size
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.6 7.9.4 7.9.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_iter_minimal.expected
*/
// Associative array minimal: first/next/last/num/size
// LRM: 7.8, 7.9 Associative arrays

module test_assoc_array_iter_minimal;
  int aa[string];
  string k;

  initial begin
    // Insert 3 items
    aa["a"] = 1;
    aa["c"] = 3;
    aa["b"] = 2;

    // num/size
    if (aa.num() != 3)      $fatal(1, "num mismatch");
    if (aa.size() != 3)     $fatal(1, "size mismatch");

    // first/next iteration order is lexical by key
    if (!aa.first(k) || k != "a") $fatal(1, "first key mismatch: %s", k);
    if (!aa.next(k)  || k != "b") $fatal(1, "next key mismatch: %s", k);
    if (!aa.next(k)  || k != "c") $fatal(1, "next key mismatch: %s", k);
    // No more items: next() returns 0 and leaves k unchanged (7.9.6)
    if (aa.next(k) || k != "c") $fatal(1, "next past the end: %s", k);

    // last
    if (!aa.last(k) || k != "c") $fatal(1, "last key mismatch: %s", k);

    // delete one and recheck counts
    aa.delete("b");
    if (aa.num() != 2) $fatal(1, "num after delete mismatch");

    $display("TEST PASSED: associative array iter minimal");
    $finish;
  end
endmodule
