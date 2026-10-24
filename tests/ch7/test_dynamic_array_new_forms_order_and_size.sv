/*
:name: test_dynamic_array_new_forms_order_and_size
:description: new[] sizes a dynamic array in a declaration or a blocking assignment, evaluates its size before its initializer, makes only an identifier whose leftmost unpacked dimension is dynamic a dynamic array, and size() is an int that equals $size(array, 1) while delete() empties the array (IEEE 1800-2023 Sections 7.5.1, 7.5, 7.5.2, 7.5.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 7.5 7.5.2 7.5.3 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_new_forms_order_and_size.expected
*/
// IEEE 1800-2023 §7.5.1: new[] can be the right-hand side of a variable
// declaration assignment or of a blocking assignment whose left-hand side is
// a dynamic array, and its [size] argument is evaluated before its (init)
// argument. §7.5: an identifier is a dynamic array only when its leftmost
// unpacked dimension is dynamic; int m [2][] is a fixed array of two dynamic
// subarrays, each sized on its own, and int dd [][2] is a dynamic array of
// fixed subarrays. §7.5.2: size() takes no argument, returns int and is the
// same as $size(array, 1) (§20.7). §7.5.3: delete() takes no argument and
// leaves an empty array.
// The functions size_arg and init_arg print when they are evaluated, and
// init_arg returns the step at which it ran, so the order shows in both the
// messages and the contents of d. size() is printed next to $size before
// allocation, after new[5] and after delete, and its width and sign are shown
// by $bits and by size() - 1 < 0 on an empty array.
// Icarus Verilog 13.0 does not support arrays of dynamic arrays.

module test_dynamic_array_new_forms_order_and_size;
  typedef int da_t[];

  int dm[] = new[4];
  int dd[][2] = new[3];
  int dn[][] = new[2];
  int m [2][];
  int d[];
  int step = 0;

  function automatic int size_arg();
    step++;
    $display("size argument evaluated at step %0d", step);
    return 3;
  endfunction

  function automatic da_t init_arg();
    step++;
    $display("init argument evaluated at step %0d", step);
    return '{step, step};
  endfunction

  initial begin
    $display("declared: dm size=%0d dm[3]=%0d dd size=%0d dd[0] size=%0d", dm.size(), dm[3],
             dd.size(), $size(dd[0]));
    $display("declared: dn size=%0d dn[1] size=%0d", dn.size(), dn[1].size());
    $display("m: size=%0d m[0]=%0d m[1]=%0d", $size(m, 1), m[0].size(), m[1].size());
    m[1] = new[3];
    $display("m after m[1]=new[3]: size=%0d m[0]=%0d m[1]=%0d", $size(m, 1), m[0].size(),
             m[1].size());

    d = new[size_arg()](init_arg());
    $display("d: size=%0d %0d %0d %0d", d.size(), d[0], d[1], d[2]);

    d.delete();
    $display("deleted: size=%0d $size=%0d bits=%0d size-1<0=%0d", d.size(), $size(d, 1),
             $bits(d.size()), d.size() - 1 < 0);
    d = new[5];
    $display("new[5]: size=%0d size(no parens)=%0d $size=%0d", d.size(), d.size, $size(d, 1));
    d.delete;
    $display("deleted again: size=%0d $size=%0d", d.size(), $size(d, 1));
  end
endmodule
