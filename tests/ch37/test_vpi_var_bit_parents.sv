/*
:name: test_vpi_var_bit_parents
:description: vpiBit iterates the var bits of logic, bit, packed struct, packed union and packed array variables and of no other variable; each var bit has size 1, its bit index by vpi_handle(vpiIndex), its indices from the bit outward by iteration, the variable or the largest containing packed array as parent, and vpiConstantSelect TRUE for a static variable and FALSE inside a dynamic array element (IEEE 1800-2023 Section 37.17)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.18 38.23 7.2.1 7.3.1 7.4.1 7.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_var_bit_parents.c
:expected_stdout: @test_vpi_var_bit_parents.expected
*/
// IEEE 1800-2023 §37.17 detail 12: the vpiBit iterator applies only to logic,
// bit, packed struct, packed union and packed array variables; for the int,
// real and string variables there are no var bits, so vpi_iterate returns NULL
// (38.23). A var bit has vpiSize 1 (detail 9). vpi_handle(vpiIndex) gives its
// bit index and vpi_iterate(vpiIndex) the indices of a bit of a
// multidimensional variable from the bit outward (detail 13): 2 then 1 for
// m2[1][2]. vpiParent (detail 26) is the first prefix, from the right, that is
// a struct or union variable or the largest containing packed array: lv, bv
// and m2 for their bits (m2[1] is contained in the larger m2), the struct sv
// and the union uv for theirs, and the packed array var pe of enums for its
// bits (its elements are enum vars, which do not qualify). vpiConstantSelect
// (detail 27) is TRUE for the bits of the static variable lv, all selected
// with constants, and FALSE for those of the element dl[0] of a dynamic array.
// Bits are listed by name, sorted.

typedef enum logic [1:0] {VBP_A, VBP_B, VBP_C} test_vpi_var_bit_parents_e;
typedef struct packed { logic [1:0] p; logic q; } test_vpi_var_bit_parents_s;
typedef union packed { logic [2:0] w; test_vpi_var_bit_parents_s s; } test_vpi_var_bit_parents_u;

module test_vpi_var_bit_parents;
  logic [3:0] lv = 4'b1010;
  bit [2:0] bv = 3'b011;
  logic [1:0][3:0] m2 = 8'hc5;
  test_vpi_var_bit_parents_s sv = 3'b101;
  test_vpi_var_bit_parents_u uv = 3'b110;
  test_vpi_var_bit_parents_e [2:0] pe = {VBP_C, VBP_A, VBP_B};
  logic [3:0] dl [];
  int iv = 7;
  real rv = 1.5;
  string st = "x";

  initial begin
    dl = new[1];
    dl[0] = 4'b0110;
    #1 $vt_bits;
  end
endmodule
