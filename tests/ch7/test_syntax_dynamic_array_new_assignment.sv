/*
:name: test_syntax_dynamic_array_new_assignment
:description: blocking assignments of new[size] and new[size](init) to a dynamic array variable and to elements of arrays of dynamic arrays set the size and the elements (IEEE 1800-2023 Section 7.5.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 A.6.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_dynamic_array_new_assignment.expected
*/
// IEEE 1800-2023 A.6.2, §7.5.1: a blocking assignment can assign
// new [size] or new [size] (array) to a variable lvalue without a range
// select that names a dynamic array. new [n] makes the array n elements of
// the default value; with an initialization array the elements are copied,
// the array being cut to n elements or padded with the default value.
//
// The targets are a dynamic array d, the element fix[1] of a fixed-size
// array of dynamic arrays, and the element dd[0] of a dynamic array of
// dynamic arrays after dd itself has been created; d is also resized
// with its own old contents. Sizes and elements are printed after each
// assignment.

module test_syntax_dynamic_array_new_assignment;
  int d[];
  int fix[2][];
  int dd[][];
  int src[3] = '{5, 6, 7};

  task show(string name, int a[]);
    $write("%s size=%0d:", name, a.size());
    foreach (a[i]) $write(" %0d", a[i]);
    $display;
  endtask

  initial begin
    d = new [3];
    show("d", d);
    d = new [2] (src);
    show("d", d);
    d = new [4] (d);
    show("d", d);
    fix[1] = new [3] (src);
    show("fix[0]", fix[0]);
    show("fix[1]", fix[1]);
    dd = new [2];
    dd[0] = new [5];
    dd[0][4] = 9;
    $display("dd size=%0d", dd.size());
    show("dd[0]", dd[0]);
    show("dd[1]", dd[1]);
    d = new [0];
    show("d", d);
  end
endmodule
