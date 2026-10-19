/*
:name: test_array_args_by_value_ref
:description: Arrays passed by value are copied, also dynamic arrays, queues and associative arrays, while a ref argument is the caller's array (IEEE 1800-2023 Section 7.7)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.7 7.9.10 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_args_by_value_ref.expected
*/
// IEEE 1800-2023 §7.7: an array argument passed by value is a copy, for every
// kind of array, so the subroutine can change its copy without changing the
// caller's array. §7.9.10: an associative array passed by
// value is a local copy too. §13.5.2: a ref argument is the caller's array, so
// a change made through it stays.

module test_array_args_by_value_ref;
  int fixed[3] = '{1, 2, 3};
  int dyn[];
  int q[$];
  int aa[int];

  function automatic int sum_after_clobber(int x[3]);
    x[0] = 100;
    return x[0] + x[1] + x[2];
  endfunction

  function automatic int sum_dyn(int x[]);
    int s;
    s = 0;
    foreach (x[i]) s += x[i];
    x[0] = -1;
    return s;
  endfunction

  function automatic int sum_queue(int x[$]);
    int s;
    s = 0;
    foreach (x[i]) s += x[i];
    x.delete();
    return s;
  endfunction

  function automatic void set_by_ref(ref int x[3]);
    x[1] = 50;
  endfunction

  function automatic int size_after_add(int m[int]);
    m[99] = 1;
    return m.size();
  endfunction

  initial begin
    $display("fixed by value: sum=%0d fixed[0]=%0d", sum_after_clobber(fixed), fixed[0]);
    set_by_ref(fixed);
    $display("fixed by ref: fixed[1]=%0d", fixed[1]);
    dyn = '{4, 5, 6};
    $display("dynamic by value: sum=%0d dyn[0]=%0d", sum_dyn(dyn), dyn[0]);
    q = '{7, 8, 9};
    $display("queue by value: sum=%0d q[0]=%0d", sum_queue(q), q[0]);
    aa[1] = 10;
    aa[2] = 20;
    $display("associative by value: callee size=%0d caller size=%0d", size_after_add(aa), aa.size());
  end
endmodule
