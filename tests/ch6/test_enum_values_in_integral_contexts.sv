/*
:name: test_enum_values_in_integral_contexts
:description: an enum variable is converted to an integral value wherever its context needs one, and enum names can be used in expressions whose results go to integral variables (IEEE 1800-2023 Section 6.19.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.3 6.19.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_values_in_integral_contexts.expected
*/
// IEEE 1800-2023 §6.19.3: enum variables are auto-cast into integral values,
// and enum names can be used as constants in expressions whose results are
// assigned to variables of a compatible integral type. §6.19.4: the value
// used is the encoding, cast to the base type of the enum.
// The variable c, of an enum with the base bit [2:0] and the value BLUE (5),
// is assigned to an int, added to an int, passed to an int argument,
// compared with an int, used as a shift amount and as a bit-select index.
// The unsigned 3-bit base makes c - 6 a 32-bit unsigned value and keeps
// c + 1'b1 at 3 bits, while the int-based p gives -5 and 32 bits.
// The names are used in a product, a bitwise OR with a vector, a
// subtraction that wraps in 8 bits and a concatenation of two 3-bit values.

module test_enum_values_in_integral_contexts;
  typedef enum bit [2:0] {RED = 1, GREEN = 2, BLUE = 5} color_t;
  typedef enum {P1 = 1, P6 = 6} plain_t;
  color_t c = BLUE;
  plain_t p = P1;
  logic [7:0] v = 8'b1010_0000;
  int i, a;
  logic [7:0] m;
  byte n;
  shortint w;

  function automatic int twice(int x);
    return 2 * x;
  endfunction

  initial begin
    i = c;
    $display("%0d %0d %0d", i, c + 10, twice(c));
    $display("%0d %0d %0d %0d", c > 3, c == 5, 1 << c, v[c]);
    $display("%0d %0d", c - 6, p - 6);
    $display("%0d %0d", $bits(c + 1'b1), $bits(p + 1'b1));
    a = BLUE * 3;
    m = GREEN | 8'h80;
    n = RED - BLUE;
    w = {RED, BLUE};
    $display("%0d %h %0d %0d", a, m, n, w);
  end
endmodule
