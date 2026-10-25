/*
:name: test_assignment_operators_all_forms
:description: each of the thirteen assignment operators =, +=, -=, *=, /=, %=, &=, |=, ^=, <<=, >>=, <<<= and >>>= writes the result of its operation on the variable and the right-hand side (IEEE 1800-2023 Section 10.4.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 11.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_operators_all_forms.expected
*/
// IEEE 1800-2023 §10.4.1: the assignment operators of a blocking assignment
// are =, +=, -=, *=, /=, %=, &=, |=, ^=, <<=, >>=, <<<= and >>>=; each one
// other than = applies its operator to the variable and the right-hand side
// (11.4.1). The signed variable s shows the difference between >>= (a
// logical shift, 0 enters at the top) and >>>= (an arithmetic shift, the
// sign bit is copied). Each result is printed after its operator.

module test_assignment_operators_all_forms;
  int x;
  byte signed s;

  initial begin
    x = 100;   $display("=    %0d", x);
    x += 7;    $display("+=   %0d", x);
    x -= 10;   $display("-=   %0d", x);
    x *= 3;    $display("*=   %0d", x);
    x /= 4;    $display("/=   %0d", x);
    x %= 10;   $display("%%=   %0d", x);
    x = 12;
    x &= 10;   $display("&=   %0d", x);
    x |= 5;    $display("|=   %0d", x);
    x ^= 3;    $display("^=   %0d", x);
    x <<= 2;   $display("<<=  %0d", x);
    x >>= 3;   $display(">>=  %0d", x);
    x <<<= 4;  $display("<<<= %0d", x);
    s = -16;
    s >>= 2;   $display(">>=  on -16: %0d", s);
    s = -16;
    s >>>= 2;  $display(">>>= on -16: %0d", s);
  end
endmodule
