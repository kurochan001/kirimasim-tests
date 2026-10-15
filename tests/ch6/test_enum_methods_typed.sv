/*
:name: test_enum_methods_typed
:description: Enumerated types
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.19.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_methods_typed.expected
*/
// IEEE 1800-2023 Section 6.19 - Enumerated types
// Test: Enum methods with different base types

module test_enum_methods_typed;
  typedef enum bit [1:0] {S0 = 0, S1 = 1, S2 = 2, S3 = 3} state2_t;
  typedef enum int {N1 = -10, N2 = 0, N3 = 10, N4 = 100} nums_t;

  initial begin
    state2_t s2;
    nums_t n;

    // Test 2-bit enum
    s2 = s2.first();
    if (s2 != S0) $fatal(1, "FAIL: state2 first");
    if (s2.name() != "S0") $fatal(1, "FAIL: state2 S0 name");

    s2 = s2.last();
    if (s2 != S3) $fatal(1, "FAIL: state2 last");
    if (s2.name() != "S3") $fatal(1, "FAIL: state2 S3 name");

    if (s2.num() != 4) $fatal(1, "FAIL: state2 num");

    // Test int enum with non-sequential values
    n = n.first();
    if (n != N1) $fatal(1, "FAIL: nums first");
    if (n != -10) $fatal(1, "FAIL: nums first value");

    n = n.next();
    if (n != N2) $fatal(1, "FAIL: nums next");
    if (n != 0) $fatal(1, "FAIL: nums next value");

    n = n.next();
    if (n != N3) $fatal(1, "FAIL: nums next(2)");
    if (n != 10) $fatal(1, "FAIL: nums next(2) value");

    n = n.last();
    if (n != N4) $fatal(1, "FAIL: nums last");
    if (n != 100) $fatal(1, "FAIL: nums last value");

    if (n.num() != 4) $fatal(1, "FAIL: nums num");

    $display("PASS: Enum methods with typed bases");
    $finish(0);
  end
endmodule
