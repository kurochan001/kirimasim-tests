/*
:name: test_dollar_value_range_membership
:description: a lower dollar bound includes every value at or below the other bound and an upper dollar bound includes every value at or above it
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dollar_value_range_membership.expected
*/
// IEEE 1800-2023 6.20.7: in a value range [$:expression] the dollar bound
// means the set of values less than or equal to the expression, and in
// [expression:$] it means the set of values greater than or equal to it. The
// test checks both bounds with themselves and with one value beyond each:
// -1 and 6 are inside [$:6] while 7 is not, and 5 and 100 are inside [5:$]
// while 4 is not. A tool that excludes the bound itself, or that treats a
// dollar bound as an empty set, prints other truth values.

module test_dollar_value_range_membership;
  initial begin
    $display("lo=%0d %0d %0d", (-1) inside {[$:6]}, (6) inside {[$:6]},
             (7) inside {[$:6]});
    $display("hi=%0d %0d %0d", (4) inside {[5:$]}, (5) inside {[5:$]},
             (100) inside {[5:$]});
  end
endmodule
