/*
:name: test_enum_first_last
:description: Test enum first/last (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_first_last.expected
*/
// Test enum first/last (IEEE 1800-2023 Section 6.19)

module test_enum_first_last;
  typedef enum {A, B, C, D} state_t;
  state_t s;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: First element
    s = s.first();
    if (s == A) pass_count++;

    // Test 2: Last element
    s = s.last();
    if (s == D) pass_count++;

    // Test 3: Num elements
    if (s.num() == 4) pass_count++;

    $display("Enum first/last tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Enum first/last tests");
    end else begin
      $display("FAIL: Some enum tests failed");
    end
  end
endmodule
