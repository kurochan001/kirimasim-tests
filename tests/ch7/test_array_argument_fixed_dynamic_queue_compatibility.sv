/*
:name: test_array_argument_fixed_dynamic_queue_compatibility
:description: array actual arguments follow the rules of array assignment: a fixed-size formal takes fixed arrays with other ranges and dynamic arrays or queues of the same size, and an unsized dynamic or queue formal takes fixed, dynamic and queue actuals of any size, elements matching from left to right (IEEE 1800-2023 Section 7.7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.7 7.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_argument_fixed_dynamic_queue_compatibility.expected
*/
// IEEE 1800-2023 §7.7: whether an array actual can be given for a formal is
// decided by the rules for assigning the actual to the formal (§7.6). A
// subroutine with a fixed-size array formal can be passed a fixed array of
// another range, or a dynamic array or queue with a compatible element type
// and the same number of elements. A subroutine with a dynamic array or queue
// formal can be passed a dynamic array, a queue or a fixed-size array; an
// unsized formal dimension matches any size of the actual. Elements
// correspond from left to right, as in §7.6, and element types only need to
// be equivalent (int and bit signed [31:0], §6.22.2).
// fixed3 has the formal int a [3:1], so a[3] is the leftmost element of the
// actual. as_dyn and as_queue print the size and elements they get.
// two_rows takes int [1:2][0:2] and is passed an int [2][3].
// Icarus Verilog 13.0 does not support unpacked array formals. Verilator 5.052
// rejects a dynamic array or queue for the fixed-size formal, and without those
// calls its generated C++ code does not compile.

module test_array_argument_fixed_dynamic_queue_compatibility;
  int f13 [1:3] = '{1, 2, 3};
  int f02 [0:2] = '{4, 5, 6};
  int f5 [0:4] = '{1, 2, 3, 4, 5};
  int d3[] = '{7, 8, 9};
  int q3[$] = '{10, 11, 12};
  int f23 [2][3] = '{'{1, 2, 3}, '{4, 5, 6}};

  function automatic string fixed3(int a [3:1]);
    return $sformatf("a[3]=%0d a[2]=%0d a[1]=%0d", a[3], a[2], a[1]);
  endfunction

  function automatic string as_dyn(int a[]);
    string s = $sformatf("size=%0d:", a.size());
    foreach (a[i]) s = {s, $sformatf(" %0d", a[i])};
    return s;
  endfunction

  function automatic string as_queue(int a[$]);
    string s = $sformatf("size=%0d:", a.size());
    foreach (a[i]) s = {s, $sformatf(" %0d", a[i])};
    return s;
  endfunction

  function automatic int sum_bits(bit signed [31:0] a [0:2]);
    return a[0] + a[1] + a[2];
  endfunction

  function automatic string two_rows(int a [1:2][0:2]);
    return $sformatf("a[1][0]=%0d a[1][2]=%0d a[2][0]=%0d", a[1][0], a[1][2], a[2][0]);
  endfunction

  initial begin
    $display("fixed formal, fixed [0:2]: %s", fixed3(f02));
    $display("fixed formal, dynamic: %s", fixed3(d3));
    $display("fixed formal, queue: %s", fixed3(q3));
    $display("dynamic formal, fixed [1:3]: %s", as_dyn(f13));
    $display("dynamic formal, fixed [0:4]: %s", as_dyn(f5));
    $display("dynamic formal, queue: %s", as_dyn(q3));
    $display("queue formal, fixed [0:2]: %s", as_queue(f02));
    $display("queue formal, dynamic: %s", as_queue(d3));
    $display("equivalent element type: sum=%0d", sum_bits(f13));
    $display("two dimensions: %s", two_rows(f23));
  end
endmodule
