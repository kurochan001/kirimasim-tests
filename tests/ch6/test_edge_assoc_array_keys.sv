/*
:name: test_edge_assoc_array_keys
:description: String keys with "\0" in associative arrays: "\0" is removed from string literals
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 7.8.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_assoc_array_keys.expected
*/
// IEEE 1800-2023 6.16: every "\0" in a string literal assigned to a string
// variable is removed, and a literal that becomes empty gives the empty
// string. A string variable never contains "\0". So "\0" and "" are the same
// key of an associative array, and "a\0b" is stored under "ab".
module test_edge_assoc_array_keys;
  int assoc[string];
  string null_key;

  initial begin
    null_key = "\0";
    if (null_key.len() != 0)
      $fatal(1, "FAIL: `\"\\0\"` must assign the empty string, got len=%0d", null_key.len());

    // Same key after the removal: "" and "\0" are one entry, last write wins.
    assoc[""] = 1;
    assoc[null_key] = 2;
    if (assoc.num() != 1)
      $fatal(1, "Expected 1 entry, got %0d", assoc.num());
    if (assoc.exists("") == 0 || assoc[""] != 2)
      $fatal(1, "Empty string key missing or incorrect value");
    if (assoc.exists(null_key) == 0 || assoc[null_key] != 2)
      $fatal(1, "NUL literal key must address the same empty-string entry");

    // A key that keeps characters after the removal stays distinct.
    assoc["a\0b"] = 3;
    if (assoc.num() != 2)
      $fatal(1, "Expected 2 entries after adding \"a\\0b\", got %0d", assoc.num());
    if (assoc.exists("ab") == 0 || assoc["ab"] != 3)
      $fatal(1, "\"a\\0b\" must store under the key \"ab\"");

    $display("PASS: associative array special string keys");
    $finish;
  end
endmodule
