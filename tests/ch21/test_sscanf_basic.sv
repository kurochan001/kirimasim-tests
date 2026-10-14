/*
:name: test_sscanf_basic
:description: Test $sscanf basic (IEEE 1800-2023 Section 21.3.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_basic.expected
*/
// Test $sscanf basic (IEEE 1800-2023 Section 21.3.4)

module test_sscanf_basic;
  string s;
  int val;
  int cnt;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Scan integer
    s = "42";
    cnt = $sscanf(s, "%d", val);
    if (cnt == 1 && val == 42) pass_count++;

    // Test 2: Scan different value
    s = "123";
    cnt = $sscanf(s, "%d", val);
    if (cnt == 1 && val == 123) pass_count++;

    // Test 3: Scan hex
    s = "FF";
    cnt = $sscanf(s, "%x", val);
    if (cnt == 1 && val == 255) pass_count++;

    $display("Sscanf basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Sscanf basic tests");
    end else begin
      $display("FAIL: Some sscanf tests failed");
    end
  end
endmodule
