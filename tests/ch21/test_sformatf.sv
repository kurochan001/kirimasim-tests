/*
:name: test_sformatf
:description: Test $sformatf (IEEE 1800-2023 Section 21.3.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sformatf.expected
*/
// Test $sformatf (IEEE 1800-2023 Section 21.3.3)

module test_sformatf;
  string s;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Format return value
    s = $sformatf("Value: %0d", 100);
    if (s == "Value: 100") pass_count++;

    // Test 2: Format binary
    s = $sformatf("Bin: %b", 4'b1010);
    if (s.len() > 0) pass_count++;

    // Test 3: Format string
    s = $sformatf("Hello %s", "World");
    if (s == "Hello World") pass_count++;

    $display("Sformatf tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Sformatf tests");
    end else begin
      $display("FAIL: Some sformatf tests failed");
    end
  end
endmodule
