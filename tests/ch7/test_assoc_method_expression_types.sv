/*
:name: test_assoc_method_expression_types
:description: Associative method expression types are int and statuses are exact integers (IEEE 1800-2023 Sections 7.9.1 and 7.9.3-7.9.7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.1 7.9.3 7.9.4 7.9.5 7.9.6 7.9.7 20.6.1 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_method_expression_types.expected
*/
// Query the method expression itself, not an int receiving its converted value.
// Type queries do not execute the call. Actual traversal calls update k.

module test_assoc_method_expression_types;
  int a[int];
  int k, status;
  initial begin
    $display("types: %s %s %s %s %s %s %s", $typename(a.num()),
             $typename(a.size()), $typename(a.exists(20)), $typename(a.first(k)),
             $typename(a.last(k)), $typename(a.next(k)), $typename(a.prev(k)));
    $display("bits: %0d %0d %0d %0d %0d %0d %0d", $bits(a.num()),
             $bits(a.size()), $bits(a.exists(20)), $bits(a.first(k)),
             $bits(a.last(k)), $bits(a.next(k)), $bits(a.prev(k)));
    $display("empty: num=%0d size=%0d exists=%0d", a.num(), a.size(), a.exists(20));
    a[30] = 3; a[10] = 1; a[20] = 2;
    $display("present: num=%0d size=%0d exists=%0d missing=%0d",
             a.num(), a.size(), a.exists(20), a.exists(99));
    k = 99; status = a.first(k); $display("first=%0d,%0d", status, k);
    k = -99; status = a.last(k); $display("last=%0d,%0d", status, k);
    k = 10; status = a.next(k); $display("next=%0d,%0d", status, k);
    k = 30; status = a.prev(k); $display("prev=%0d,%0d", status, k);
  end
endmodule
