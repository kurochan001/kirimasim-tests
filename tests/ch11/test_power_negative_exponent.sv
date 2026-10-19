/*
:name: test_power_negative_exponent
:description: Integral power with a negative exponent follows Table 11-4: 1, -1 or 1 for a base of -1, 0 for other bases, and x for a base of 0 (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_power_negative_exponent.expected
*/
// IEEE 1800-2023 §11.4.3, Table 11-4: for integral operands and a negative
// exponent, 1 ** n is 1; (-1) ** n is 1 for an even n and -1 for an odd n;
// a base larger than 1 or smaller than -1 gives 0; and a base of 0 gives x.
// Any base to the power 0 is 1, also 0 ** 0.

module test_power_negative_exponent;
  int e2 = -2, e3 = -3, e1 = -1;
  int one = 1, mone = -1, two = 2, mtwo = -2, zero = 0;

  initial begin
    $display("1**-2 = %0d", one ** e2);
    $display("(-1)**-2 = %0d", mone ** e2);
    $display("(-1)**-3 = %0d", mone ** e3);
    $display("2**-1 = %0d", two ** e1);
    $display("(-2)**-1 = %0d", mtwo ** e1);
    $display("0**-1 = %0d", zero ** e1);
    $display("3**0 = %0d, 0**0 = %0d", 3 ** 0, zero ** 0);
  end
endmodule
