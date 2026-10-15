/*
:name: test_enum_methods_name_num
:description: Enumerated types
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_methods_name_num.expected
*/
// IEEE 1800-2023 Section 6.19 - Enumerated types
// Test: Enum name() and num() methods

module test_enum_methods_name_num;
  typedef enum {IDLE = 0, ACTIVE = 1, WAIT = 2, ERROR = 10} state_t;

  initial begin
    state_t s;

    // Test name() for each value
    s = IDLE;
    if (s.name() != "IDLE") $fatal(1, "FAIL: IDLE.name()");

    s = ACTIVE;
    if (s.name() != "ACTIVE") $fatal(1, "FAIL: ACTIVE.name()");

    s = WAIT;
    if (s.name() != "WAIT") $fatal(1, "FAIL: WAIT.name()");

    s = ERROR;
    if (s.name() != "ERROR") $fatal(1, "FAIL: ERROR.name()");

    // Test num() - returns total number of enum members
    if (s.num() != 4) $fatal(1, "FAIL: num() should be 4");

    // Display all enum names
    $display("Enum has %0d members:", s.num());
    s = s.first();
    for (int i = 0; i < s.num(); i++) begin
      $display("  [%0d] %s = %0d", i, s.name(), s);
      s = s.next();
    end

    $display("PASS: Enum name() and num() methods");
    $finish(0);
  end
endmodule
