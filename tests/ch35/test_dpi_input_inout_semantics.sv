/*
:name: test_dpi_input_inout_semantics
:description: Changes that an imported function makes to its own copies of input arguments do not reach the actual arguments, while it reads the initial value of inout arguments of type real, unpacked array and wide packed array and its changes to them are visible to the caller (IEEE 1800-2023 Section 35.5.1.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.2 35.6.1 H.8.7 H.8.8 H.8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_input_inout_semantics.c
:expected_stdout: @test_dpi_input_inout_semantics.expected
*/
// IEEE 1800-2023 §35.5.1.2: changes an imported function makes to an input
// argument are not visible outside it, and the actual argument does not
// change; the function can read the initial value of an inout argument, and
// its changes to it are visible outside. §35.6.1: input is copy-in, inout
// copy-in and copy-out. H.8.7: a small input such as int or string comes by
// value, so c_countdown counts its own n down to 0 and c_length moves its own
// pointer along the string (H.8.10: such changes are not propagated back).
// H.8.8: inout arguments come by reference: c_accumulate adds to a real,
// c_rotate rotates an int[4] left by one, and c_add_wide adds to a 40-bit
// vector held in two svBitVecVal words, carrying into the upper one.

module test_dpi_input_inout_semantics;
  import "DPI-C" function int c_countdown(input int n);
  import "DPI-C" function int c_length(input string s);
  import "DPI-C" function void c_accumulate(inout real total, input real add);
  import "DPI-C" function void c_rotate(inout int a[4]);
  import "DPI-C" function void c_add_wide(inout bit [39:0] v, input int add);

  int n = 5, steps;
  string s = "hello";
  real total = 1.5;
  int a[4] = '{1, 2, 3, 4};
  bit [39:0] w = 40'h00_ffff_fff0;

  initial begin
    steps = c_countdown(n);
    $display("input int: %0d steps, n is still %0d, n + 2 gives %0d", steps, n, c_countdown(n + 2));
    $display("input string: length %0d, s is still \"%s\"", c_length(s), s);
    c_accumulate(total, 2.25);
    $display("inout real: %0.2f", total);
    c_rotate(a);
    $display("inout array: %0d %0d %0d %0d", a[0], a[1], a[2], a[3]);
    c_add_wide(w, 'h20);
    $display("inout packed: %h", w);
  end
endmodule
