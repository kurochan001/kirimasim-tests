/*
:name: test_type_equivalent_arrays
:description: Unpacked arrays whose element types are equivalent, such as packed types of the same size, state and signedness, can be assigned to each other whatever their ranges, element by element from the left (IEEE 1800-2023 Section 6.22.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.2 7.6 7.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_equivalent_arrays.expected
*/
// IEEE 1800-2023 §6.22.2: packed types are equivalent when they have the same
// number of bits, are all 2-state and all unsigned (rule c), and fixed-size
// unpacked arrays are equivalent when their element types are equivalent and
// their sizes equal, whatever their bounds (rule d). An anonymous unpacked
// struct is equivalent to itself among the variables of one declaration (rule
// b). Assigning equivalent unpacked arrays copies the elements from the left
// end of each (7.6): c[3] gets a[0], and the packed struct elements of d get
// the bits of a's elements.

module test_type_equivalent_arrays;
  typedef bit [8:1] u8_t;
  typedef struct packed {bit [3:0] hi, lo;} pair_t;

  bit [7:0] a [0:3] = '{8'h01, 8'h02, 8'h03, 8'h4f};
  bit [1:8] b [4];
  u8_t c [3:0];
  pair_t d [10:13];
  struct {int x; int y;} s1, s2;

  initial begin
    b = a;
    c = a;
    d = a;
    s1.x = 5;
    s1.y = 6;
    s2 = s1;
    $display("b: %h %h %h %h", b[0], b[1], b[2], b[3]);
    $display("c[3]=%h c[0]=%h", c[3], c[0]);
    $display("d[13].hi=%h d[13].lo=%h", d[13].hi, d[13].lo);
    $display("s2: %0d %0d", s2.x, s2.y);
  end
endmodule
