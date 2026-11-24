/*
:name: test_matches_precedes_boolean_and_or
:description: Pattern matches binds before boolean conjunction and disjunction
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6.2 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_matches_precedes_boolean_and_or.expected
*/
module test_matches_precedes_boolean_and_or;
  task automatic check(input bit allow, input bit [2:0] code);
    bit a, b;
    a = 0;
    b = 0;
    if (allow && code matches (3'b101)) a = 1;
    if (allow || code matches (3'b101)) b = 1;
    $display("allow=%b code=%0d and=%b or=%b", allow, code, a, b);
  endtask

  initial begin
    check(0, 5);
    check(1, 4);
    check(1, 5);
    check(0, 4);
  end
endmodule
