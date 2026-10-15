/*
:name: test_assoc_array_extended
:description: Test associative arrays (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_extended.expected
*/
// Test associative arrays (IEEE 1800-2023 Section 7.8)

module test_assoc_array_extended;
  int aa_int[string];
  string aa_str[int];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Insert elements
    aa_int["one"] = 1;
    aa_int["two"] = 2;
    aa_int["three"] = 3;
    if (aa_int["two"] == 2) pass_count++;

    // Test 2: num/size
    if (aa_int.num() == 3) pass_count++;

    // Test 3: exists
    if (aa_int.exists("one")) pass_count++;
    if (!aa_int.exists("four")) pass_count++;

    // Test 4: delete specific key
    aa_int.delete("two");
    if (!aa_int.exists("two")) pass_count++;
    if (aa_int.num() == 2) pass_count++;

    // Test 5: first/next iteration
    begin
      string key;
      int found;
      found = 0;
      if (aa_int.first(key)) begin
        found++;
        while (aa_int.next(key)) found++;
      end
      if (found == 2) pass_count++;
    end

    // Test 6: Integer key associative array
    aa_str[100] = "hundred";
    aa_str[200] = "two hundred";
    aa_str[300] = "three hundred";
    if (aa_str[200] == "two hundred") pass_count++;

    // Test 7: delete all
    aa_int.delete();
    if (aa_int.num() == 0) pass_count++;

    $display("Associative array tests: %0d/9 passed", pass_count);
    if (pass_count == 9) begin
      $display("PASS: Associative array tests");
    end else begin
      $display("FAIL: Some associative array tests failed");
    end
  end
endmodule
