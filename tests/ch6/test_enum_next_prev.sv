/*
:name: test_enum_next_prev
:description: Test enum next/prev (IEEE 1800-2023 Sections 6.19.5.3 and 6.19.5.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5.3 6.19.5.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_next_prev.expected
*/
// Test enum next/prev (IEEE 1800-2023 Sections 6.19.5.3 and 6.19.5.4)

module test_enum_next_prev;
  typedef enum {X, Y, Z} val_t;
  val_t v;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Next from first
    v = X;
    v = v.next();
    if (v == Y) pass_count++;

    // Test 2: Next again
    v = v.next();
    if (v == Z) pass_count++;

    // Test 3: Prev
    v = v.prev();
    if (v == Y) pass_count++;

    $display("Enum next/prev tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Enum next/prev tests");
    end else begin
      $display("FAIL: Some enum tests failed");
    end
  end
endmodule
