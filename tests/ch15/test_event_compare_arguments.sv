/*
:name: test_event_compare_arguments
:description: Event variables compare equal while they refer to the same event, also as function arguments, an assignment to one of two merged variables separates them again, and two null event variables compare equal (IEEE 1800-2023 Section 15.5.5.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.5.3 15.5.5.1 15.5.5.2 15.5.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_compare_arguments.expected
*/
// IEEE 1800-2023 §15.5.5.3: ==, !=, === and !== compare event variables with
// each other or with null: two variables are equal when they refer to the
// same event, and a variable used as a condition is 0 only when it is null.
// §15.5.5: an event variable is a variable whose value refers to a
// synchronization object, so an event passed to a function as an argument
// still refers to it and compares equal to the actual. §15.5.5.1: a = b makes
// a refer to the event of b; a later b = c moves only b to the event of c,
// so a stays on the old event of b. §15.5.5.2: after null is assigned, both
// variables hold null and compare equal.

module test_event_compare_arguments;
  event a, b, c, n1, n2;

  function automatic bit same(event x, event y);
    return x == y;
  endfunction

  initial begin
    $display("same(a, a)=%0d same(a, b)=%0d", same(a, a), same(a, b));
    a = b;
    b = c;
    $display("after a = b, b = c: a == b %0d, b == c %0d, a == c %0d, same(b, c)=%0d", a == b,
             b == c, a == c, same(b, c));
    a = c;
    $display("after a = c: a === b %0d, a !== c %0d, same(a, b)=%0d", a === b, a !== c,
             same(a, b));
    n1 = null;
    n2 = null;
    $display("two null events: n1 == n2 %0d, n1 === n2 %0d, n1 != a %0d, same(n1, n2)=%0d",
             n1 == n2, n1 === n2, n1 != a, same(n1, n2));
    if (a) $display("a is true as a condition");
    if (n1) $display("n1 is true as a condition");
    else $display("n1 is false as a condition");
  end
endmodule
