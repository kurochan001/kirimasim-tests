/*
:name: test_enum_methods_navigation
:description: Enumerated types
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_methods_navigation.expected
*/
// IEEE 1800-2023 Section 6.19 - Enumerated types
// Test: Enum navigation methods (first, last, next, prev)

module test_enum_methods_navigation;
  typedef enum {RED, GREEN, BLUE, YELLOW, ORANGE} color_t;

  initial begin
    color_t c;

    // Test first()
    c = c.first();
    if (c != RED) $fatal(1, "FAIL: first() should be RED");

    // Test last()
    c = c.last();
    if (c != ORANGE) $fatal(1, "FAIL: last() should be ORANGE");

    // Test next() from first
    c = c.first();
    c = c.next();
    if (c != GREEN) $fatal(1, "FAIL: next(RED) should be GREEN");

    c = c.next();
    if (c != BLUE) $fatal(1, "FAIL: next(GREEN) should be BLUE");

    // Test prev() from last
    c = c.last();
    c = c.prev();
    if (c != YELLOW) $fatal(1, "FAIL: prev(ORANGE) should be YELLOW");

    c = c.prev();
    if (c != BLUE) $fatal(1, "FAIL: prev(YELLOW) should be BLUE");

    // Test next() at boundary (wraps to first)
    c = c.last();
    c = c.next();
    if (c != RED) $fatal(1, "FAIL: next(ORANGE) should wrap to RED");

    // Test prev() at boundary (wraps to last)
    c = c.first();
    c = c.prev();
    if (c != ORANGE) $fatal(1, "FAIL: prev(RED) should wrap to ORANGE");

    // Test iteration through all values
    c = c.first();
    for (int i = 0; i < 5; i++) begin
      $display("  Enum[%0d] = %s", i, c.name());
      c = c.next();
    end
    if (c != RED) $fatal(1, "FAIL: After 5 next(), should wrap back to RED");

    $display("PASS: Enum navigation methods");
    $finish(0);
  end
endmodule
