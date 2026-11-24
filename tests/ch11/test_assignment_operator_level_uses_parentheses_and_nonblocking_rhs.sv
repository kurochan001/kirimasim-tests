/*
:name: test_assignment_operator_level_uses_parentheses_and_nonblocking_rhs
:description: Compound assignments, parenthesized assignment expressions, nested concatenations and a nonblocking relational right side follow their grammar
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.3.6 11.4.12 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_operator_level_uses_parentheses_and_nonblocking_rhs.expected
*/
`timescale 1ns/1ns
module test_assignment_operator_level_uses_parentheses_and_nonblocking_rhs;
  int accumulator, left = 5, right = 7, arithmetic, signed_after, logical_after;
  logic queued = 1;
  logic [15:0] packet;

  initial begin
    accumulator = -24;
    accumulator += 6;
    accumulator -= 2;
    accumulator *= 3;
    accumulator /= 4;
    $display("arithmetic accumulator=%0d", accumulator);
    accumulator %= 8;
    accumulator &= 15;
    accumulator ^= 6;
    accumulator |= 16;
    $display("bitwise accumulator=%0d", accumulator);
    accumulator <<= 2;
    accumulator >>= 1;
    accumulator <<<= 1;
    $display("shift accumulator=%0d", accumulator);
    accumulator -= 252;
    accumulator >>>= 2;
    signed_after = accumulator;
    accumulator >>= 1;
    logical_after = accumulator;
    $display("right shifts=%0d/%0d", signed_after, logical_after);

    arithmetic = (left += 5) * (right -= 4) + 1;
    packet = {{2{4'(right)}}, {4'(left), 4'(arithmetic)}};
    $display("nested left=%0d right=%0d expression=%0d packet=%h", left, right, arithmetic, packet);
    queued <= left <= right;
    $display("compare=%b old=%b", left <= right, queued);
    #1 $display("queued=%b", queued);
    $finish(0);
  end
endmodule
