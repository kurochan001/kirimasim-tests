/*
:name: test_type_assignment_cast_compatible
:description: Assignment-compatible types convert implicitly, an enum to an integer and between integral types with truncation or a real with rounding, while an integer becomes an enum only through a cast (IEEE 1800-2023 Section 6.22.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.3 6.22.4 6.24.1 6.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_assignment_cast_compatible.expected
*/
// IEEE 1800-2023 §6.22.3: types with implicit casting rules between them are
// assignment compatible; all integral types are, losing bits by truncation,
// and a real becomes an integer by rounding (6.12.1), halfway away from zero.
// An enum converts to an integral type without a cast, but not the other way:
// §6.22.4 makes an integral type cast compatible with an enum, which needs an
// explicit cast (6.24.1).

module test_type_assignment_cast_compatible;
  typedef enum {RED, GREEN, BLUE} color_t;

  color_t c = BLUE;
  int i;
  byte b;
  int r1, r2;

  initial begin
    i = c;
    b = 300;
    r1 = 2.5;
    r2 = -2.5;
    $display("i=%0d b=%0d r1=%0d r2=%0d", i, b, r1, r2);
    c = color_t'(1);
    $display("c=%s", c.name());
  end
endmodule
