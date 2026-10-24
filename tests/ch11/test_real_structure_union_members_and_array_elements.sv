/*
:name: test_real_structure_union_members_and_array_elements
:description: real members of structures and unions and real elements of fixed-size, dynamic and associative arrays are real operands, so arithmetic, increment and compound assignment on them give real results and comparisons give one bit (IEEE 1800-2023 Section 11.3.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.1 6.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_structure_union_members_and_array_elements.expected
*/
// IEEE 1800-2023 §11.3.1: a real value selected as a member of a structure
// or union, or as an element of an array with an integer index, is a real
// operand. So an operator with such an operand gives a real result, and a
// relational or logical operator a one-bit result.
// s.re (5.0) and u.r (2.5) are real members; ra, da and aa are a fixed-size,
// a dynamic and an associative array of reals, indexed with the int i (2).
// If the members or elements were not read as reals, s.re / 2 and u.r / 2
// would be integer divisions (2 and 1, not 2.5 and 1.25), ra[i] + 0.25 and
// da[i] * 3 would lose their fractions, and s.re > 4.75 would compare
// truncated values. ra[1]++ adds 1.0 to 1.5, and s.re += 0.75 and
// aa["k"] -= 0.5 keep their fractions, and ra[3] ** 2 is 12.25. The values
// are exact in binary.
// Icarus Verilog 13.0 does not support unpacked structures.

module test_real_structure_union_members_and_array_elements;
  typedef struct { real re; int n; } rs_t;
  typedef union { real r; longint l; } ru_t;
  rs_t s;
  ru_t u;
  real ra [0:3];
  real da [];
  real aa [string];
  int i = 2;

  initial begin
    s.re = 5.0;
    s.n = 7;
    u.r = 2.5;
    ra = '{0.5, 1.5, 2.5, 3.5};
    da = new[3];
    da[2] = 1.25;
    aa["k"] = 4.75;
    $display("member: %0.2f %0.2f %0.2f %b %b", s.re / 2, s.re + s.n, u.r / 2, s.re > 4.75,
             u.r < 2.25);
    $display("element: %0.2f %0.2f %0.2f %0.2f %b", ra[i] + 0.25, ra[i] * ra[i + 1], da[i] * 3,
             aa["k"] - 0.5, ra[i] == 2.5);
    ra[1]++;
    s.re += 0.75;
    aa["k"] -= 0.5;
    $display("updated: %0.2f %0.2f %0.2f %0.2f", ra[1], s.re, aa["k"], ra[3] ** 2);
  end
endmodule
