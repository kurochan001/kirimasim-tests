/*
:name: test_syntax_operator_assignment_statements
:description: blocking assignment statements with each of the thirteen assignment operators and with the four increment and decrement forms, including an indexed target whose index is evaluated once (IEEE 1800-2023 Section 11.4.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1 11.4.2 11.4.10 10.4.1 A.6.2 A.6.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_operator_assignment_statements.expected
*/
// IEEE 1800-2023 A.6.2, A.6.4: a blocking assignment statement can be an
// operator assignment, with one of =, +=, -=, *=, /=, %=, &=, |=, ^=, <<=,
// >>=, <<<= and >>>=, or an increment or decrement expression, followed by a
// semicolon. §11.4.1: x op= y is the same as x = x op y, except that an
// index of the target is evaluated only once. §11.4.2: ++i, i++, --i and i--
// add or subtract 1 and act as blocking assignments. §11.4.10: >>> fills
// with the sign bit for a signed operand and with 0 for an unsigned one.
//
// Each statement is followed by the new value. The index of arr[next()] +=
// 100 comes from a function that counts its calls, so it has to be called
// once and the element it returns changed.

module test_syntax_operator_assignment_statements;
  int x, i, calls;
  logic [7:0] u;
  logic signed [7:0] s;
  int arr[4];

  function int next();
    calls++;
    return calls;
  endfunction

  initial begin
    x = 7;               $display("=    %0d", x);
    x += 5;              $display("+=   %0d", x);
    x -= 2;              $display("-=   %0d", x);
    x *= 3;              $display("*=   %0d", x);
    x /= 4;              $display("/=   %0d", x);
    x %= 4;              $display("%%=   %0d", x);
    u = 8'b1100_1010;
    u &= 8'b1010_1111;   $display("&=   %b", u);
    u |= 8'b0000_0101;   $display("|=   %b", u);
    u ^= 8'b1111_0000;   $display("^=   %b", u);
    u <<= 2;             $display("<<=  %b", u);
    u >>= 3;             $display(">>=  %b", u);
    s = -8'sd64;
    s <<<= 1;            $display("<<<= %b %0d", s, s);
    s >>>= 3;            $display(">>>= %b %0d", s, s);
    u = 8'b1000_0000;
    u >>>= 2;            $display(">>>= unsigned %b", u);

    arr = '{10, 20, 30, 40};
    calls = 0;
    arr[next()] += 100;
    $display("arr=%0d %0d %0d %0d calls=%0d", arr[0], arr[1], arr[2], arr[3], calls);

    i = 5;
    i++;                 $display("i++  %0d", i);
    ++i;                 $display("++i  %0d", i);
    ++i;                 $display("++i  %0d", i);
    i--;                 $display("i--  %0d", i);
    --i;                 $display("--i  %0d", i);
    --i;                 $display("--i  %0d", i);
    arr[3]++;
    --arr[0];            $display("arr=%0d %0d %0d %0d", arr[0], arr[1], arr[2], arr[3]);
  end
endmodule
