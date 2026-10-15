/*
:name: test_package_wildcard_import
:description: Packages
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_wildcard_import.expected
*/
// IEEE 1800-2023 Section 26.3 - Packages
// Test: Wildcard package import

package pkg1;
  typedef enum {RED, GREEN, BLUE} color_t;
  parameter int MAX_SIZE = 100;

  function int add(int a, int b);
    return a + b;
  endfunction
endpackage

package pkg2;
  typedef struct {
    int x;
    int y;
  } point_t;

  parameter int TIMEOUT = 50;

  function int multiply(int a, int b);
    return a * b;
  endfunction
endpackage

module test_package_wildcard_import;
  // Wildcard import brings all package items into scope
  import pkg1::*;
  import pkg2::*;

  initial begin
    color_t c;
    point_t p;
    int result;

    // Use items from pkg1
    c = RED;
    if (c != RED) $fatal(1, "FAIL: color_t from pkg1");

    if (MAX_SIZE != 100) $fatal(1, "FAIL: MAX_SIZE from pkg1");

    result = add(10, 20);
    if (result != 30) $fatal(1, "FAIL: add() from pkg1");

    // Use items from pkg2
    p.x = 5;
    p.y = 10;
    if (p.x != 5 || p.y != 10) $fatal(1, "FAIL: point_t from pkg2");

    if (TIMEOUT != 50) $fatal(1, "FAIL: TIMEOUT from pkg2");

    result = multiply(7, 8);
    if (result != 56) $fatal(1, "FAIL: multiply() from pkg2");

    $display("PASS: Package wildcard import");
    $finish(0);
  end
endmodule
