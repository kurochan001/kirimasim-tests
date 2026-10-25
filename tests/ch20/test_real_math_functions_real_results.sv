/*
:name: test_real_math_functions_real_results
:description: each real math function of Table 20-4 takes real arguments, converting integer ones, and returns a real value equal to that of the C function it names (IEEE 1800-2023 Section 20.8.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_math_functions_real_results.expected
*/
// IEEE 1800-2023 §20.8.2: the functions of Table 20-4 accept real arguments
// and return a real result, behaving like the C functions log, log10, exp,
// sqrt, pow, floor, ceil, sin, cos, tan, asin, acos, atan, atan2, hypot,
// sinh, cosh, tanh, asinh, acosh and atanh.
// Lines 1 to 4 print all 21 functions with %.4f for arguments whose results
// are well known, for example ln 10 = 2.3026, atan2(1, -1) = 3*pi/4 = 2.3562
// and acosh 2 = 1.3170. Line 5 shows that the results are real: $floor(2.5)
// and $ceil(6.5) divided by the integer 4 give 0.5 and 1.75, which an
// integral result would make 0 and 1. Line 6
// passes integer arguments, which are converted to real: $sqrt(16) is 4,
// $pow(2, -1) is 0.5 and $hypot(5, 12) is 13.

module test_real_math_functions_real_results;
  initial begin
    $display("%.4f %.4f %.4f %.4f %.4f %.4f", $ln(10.0), $log10(1000.0), $exp(1.0), $sqrt(2.0),
             $pow(2.0, 0.5), $pow(2.0, 10.0));
    $display("%.4f %.4f %.4f %.4f %.4f", $floor(-2.5), $ceil(-2.5), $sin(0.5), $cos(0.5),
             $tan(0.5));
    $display("%.4f %.4f %.4f %.4f %.4f", $asin(0.5), $acos(0.5), $atan(1.0), $atan2(1.0, -1.0),
             $hypot(3.0, 4.0));
    $display("%.4f %.4f %.4f %.4f %.4f %.4f", $sinh(1.0), $cosh(1.0), $tanh(0.5), $asinh(1.0),
             $acosh(2.0), $atanh(0.5));
    $display("real: %.4f %.4f", $floor(2.5) / 4, $ceil(6.5) / 4);
    $display("int args: %.4f %.4f %.4f", $sqrt(16), $pow(2, -1), $hypot(5, 12));
  end
endmodule
