/*
:name: test_enum_cast_outside_set_static_and_dynamic
:description: a cast assigns an enum variable a value of another type or an encoding outside its set of names; a static cast does so without a check, while $cast fails and leaves the variable unchanged for a value outside the set (IEEE 1800-2023 Section 6.19.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_cast_outside_set_static_and_dynamic.expected
*/
// IEEE 1800-2023 §6.19.3: an enum variable cannot be assigned a value outside
// its set of names directly, but a cast can assign it a value of another data
// type or an out-of-range value; 6.19.4, 6.24.1 and 6.24.2 describe the casts.
// A static cast (6.24.1) converts without a check, and the $cast function
// (6.24.2) returns 0 and leaves its destination unchanged when the value is
// not one of the names of the enum, 1 after assigning it otherwise.
// - color_t'(3) assigns 3, which no name of color_t has, and c keeps it.
// - color_t'(CAT) converts a name of the other enum pet_t, whose value 2 is
//   GREEN in color_t.
// - $cast(c, 5) fails, as 5 is not a value of color_t, and c stays GREEN.
// - $cast(c, k) with the int k = 4 succeeds and gives BLUE.
// Icarus Verilog 13.0 does not support $cast.

module test_enum_cast_outside_set_static_and_dynamic;
  typedef enum bit [2:0] {RED = 1, GREEN = 2, BLUE = 4} color_t;
  typedef enum bit [2:0] {CAT = 2, DOG = 3} pet_t;
  color_t c;
  int ok;
  int k = 4;

  initial begin
    c = color_t'(3);
    $display("static outside: %0d", c);
    c = color_t'(CAT);
    $display("static other enum: %0d %s", c, c.name());
    ok = $cast(c, 5);
    $display("dynamic outside: ok=%0d c=%0d %s", ok, c, c.name());
    ok = $cast(c, k);
    $display("dynamic inside: ok=%0d c=%0d %s", ok, c, c.name());
  end
endmodule
