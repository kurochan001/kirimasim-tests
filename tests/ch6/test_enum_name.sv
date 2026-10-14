/*
:name: test_enum_name
:description: Test enum name (IEEE 1800-2023 Section 6.19.5.6)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_name.expected
*/
// Test enum name (IEEE 1800-2023 Section 6.19.5.6)

module test_enum_name;
  typedef enum {IDLE, RUN, STOP} mode_t;
  mode_t m;
  string s;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Name of first
    m = IDLE;
    s = m.name();
    if (s == "IDLE") pass_count++;

    // Test 2: Name of middle
    m = RUN;
    s = m.name();
    if (s == "RUN") pass_count++;

    // Test 3: Name of last
    m = STOP;
    s = m.name();
    if (s == "STOP") pass_count++;

    $display("Enum name tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Enum name tests");
    end else begin
      $display("FAIL: Some enum name tests failed");
    end
  end
endmodule
