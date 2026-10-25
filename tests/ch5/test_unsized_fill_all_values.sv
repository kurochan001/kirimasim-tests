/*
:name: test_unsized_fill_all_values
:description: The unsized single-bit literals '0, '1, 'x and 'z fill every bit of an 8-bit, 33-bit and 65-bit context and have width one in a self-determined context (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unsized_fill_all_values.expected
*/
// IEEE 1800-2023 §5.7.1 B015: a single-bit value preceded by an apostrophe,
// with no base specifier, sets all bits of the unsized value to that bit, and
// has a width of 1 bit in a self-determined context. The four literals '0,
// '1, 'x and 'z are assigned to 8-bit, 33-bit and 65-bit variables, so the
// context determines the width and the value determines every bit. $bits('1)
// is a self-determined context and has to be 1.

module test_unsized_fill_all_values;
  logic [7:0] a0, a1, ax, az;
  logic [32:0] b0, b1, bx, bz;
  logic [64:0] c0, c1, cx, cz;

  initial begin
    a0 = '0; a1 = '1; ax = 'x; az = 'z;
    b0 = '0; b1 = '1; bx = 'x; bz = 'z;
    c0 = '0; c1 = '1; cx = 'x; cz = 'z;
    #1;
    $display("8: %h %h %h %h", a0, a1, ax, az);
    $display("33: %h %h %h %h", b0, b1, bx, bz);
    $display("65: %h %h %h %h", c0, c1, cx, cz);
    $display("self=%0d", $bits('1));
  end
endmodule
