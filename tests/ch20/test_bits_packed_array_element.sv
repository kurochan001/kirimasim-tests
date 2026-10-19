/*
:name: test_bits_packed_array_element
:description: $bits of elements, bit-selects and part-selects of multidimensional packed arrays (IEEE 1800-2023 Section 20.6.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2 7.4.1 7.4.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_packed_array_element.expected
*/
// IEEE 1800-2023 §20.6.2, §7.4.1, §7.4.5: selecting one index of a packed array
// with several dimensions leaves the remaining dimensions, so for
// logic [3:0][7:0] pa, pa[0] is an 8-bit vector and $bits(pa[0]) is 8; each
// further index removes one more dimension. A part-select of such an element
// has the width of its range and a bit-select is one bit wide.

module test_bits_packed_array_element;
  logic [3:0][7:0]      pa2;   // 4 x 8 = 32
  logic [1:0][3:0][7:0] pa3;   // 2 x 4 x 8 = 64
  logic [7:0]           ref8;
  logic [3:0][7:0]      ref48; // 4 x 8 = 32
  int errs;
  task automatic chk(string w, int got, int exp);
    if (got === exp) $display("  ok   %s = %0d", w, got);
    else begin errs++; $display("  FAIL %s = %0d (exp %0d)", w, got, exp); end
  endtask
  initial begin
    // whole arrays
    chk("$bits(pa2)",         $bits(pa2),         32);
    chk("$bits(pa3)",         $bits(pa3),         64);
    // one or two indices
    chk("$bits(pa2[0])",      $bits(pa2[0]),       8);
    chk("$bits(pa2[3])",      $bits(pa2[3]),       8);
    chk("$bits(pa3[0])",      $bits(pa3[0]),      32);
    chk("$bits(pa3[1])",      $bits(pa3[1]),      32);
    chk("$bits(pa3[0][0])",   $bits(pa3[0][0]),    8);
    chk("$bits(pa3[0][3])",   $bits(pa3[0][3]),    8);
    // part-selects and bit-selects of an element
    chk("$bits(pa2[0][3:0])", $bits(pa2[0][3:0]),  4);
    chk("$bits(pa2[0][7:4])", $bits(pa2[0][7:4]),  4);
    chk("$bits(pa2[0][0])",   $bits(pa2[0][0]),    1);
    chk("$bits(pa2[0][7])",   $bits(pa2[0][7]),    1);
    // the whole array is the number of elements times one element
    chk("pa2 == 4*bits(pa2[0])", $bits(pa2), 4 * $bits(pa2[0]));
    chk("pa3 == 2*bits(pa3[0])", $bits(pa3), 2 * $bits(pa3[0]));
    // vectors of the element widths
    chk("$bits(ref8)",   $bits(ref8),   8);
    chk("$bits(ref48)",  $bits(ref48), 32);
    chk("bits(pa2[0]) == bits(ref8)",  $bits(pa2[0]), $bits(ref8));
    chk("bits(pa3[0]) == bits(ref48)", $bits(pa3[0]), $bits(ref48));

    if (errs == 0) $display("TEST PASSED");
    else $display("TEST FAILED: %0d errors", errs);
  end
endmodule
