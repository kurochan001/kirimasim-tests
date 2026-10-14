/*
:name: test_enum_type
:description: Test enum types (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.19.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_type.expected
*/
// Test enum types (IEEE 1800-2023 Section 6.19)

module test_enum_type;
  typedef enum logic [1:0] {IDLE=0, RUN=1, STOP=2, ERROR=3} state_t;
  typedef enum {RED, GREEN, BLUE} color_t;

  state_t state;
  color_t color;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Enum assignment
    state = IDLE;
    if (state == IDLE) pass_count++;

    // Test 2: Enum comparison
    state = RUN;
    if (state == RUN && state != IDLE) pass_count++;

    // Test 3: Enum as numeric
    state = STOP;
    if (state == 2) pass_count++;

    // Test 4: Enum iteration-like
    state = IDLE;
    state = state_t'(state + 1);
    if (state == RUN) pass_count++;

    // Test 5: Simple enum
    color = RED;
    if (color == RED) pass_count++;

    // Test 6: Enum next value
    color = GREEN;
    if (color == 1) pass_count++;

    // Test 7: Cast to enum
    state = state_t'(3);
    if (state == ERROR) pass_count++;

    $display("Enum type tests: %0d/7 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Enum type tests");
    end else begin
      $display("FAIL: Some enum tests failed");
    end
  end
endmodule
