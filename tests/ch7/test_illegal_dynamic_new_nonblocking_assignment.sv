/*
:name: test_illegal_dynamic_new_nonblocking_assignment
:description: the dynamic array new constructor can be the right-hand side of a declaration assignment or a blocking assignment, but not of a nonblocking assignment (IEEE 1800-2023 Section 7.5.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: new[2] is the right-hand side of a nonblocking assignment to the dynamic array d
:expected_stderr_regex: test_illegal_dynamic_new_nonblocking_assignment\.sv:28:
*/
// IEEE 1800-2023 §7.5.1 (Syntax 7-3): the new constructor may appear in
// place of the right-hand side of a variable declaration assignment or of a
// blocking procedural assignment whose left-hand side is a dynamic array;
// dynamic_array_new is part of the grammar of blocking assignments only.
// The declaration and the blocking assignment are legal, and the legal
// design prints the sizes they give; the last statement uses new[2] in a
// nonblocking assignment to the same array.

module test_illegal_dynamic_new_nonblocking_assignment;
  int d [] = new[3];
  initial begin
    $display("%0d", d.size());
    d = new[5];
    $display("%0d", d.size());
    d <= new[2];   // illegal: new[] in a nonblocking assignment
  end
endmodule
