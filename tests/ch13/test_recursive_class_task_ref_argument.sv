/*
:name: test_recursive_class_task_ref_argument
:description: A recursive class method passes a ref argument down, and writes to it after each recursive call returns reach the caller's variable (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2 13.3.1 8.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recursive_class_task_ref_argument.expected
*/
// IEEE 1800-2023 §13.5.2: a ref formal refers to the actual argument itself.
// A method of a class (8.6) is automatic, so it can call itself (13.3.1),
// and each level that passes its ref formal on refers to the same variable.
// recur(3, n) increments n once at the bottom and once after each of the
// three returns, so n ends at 4; the function form returns the depth.

class walker;
  task automatic recur(int d, ref int n);
    if (d == 0) begin
      n++;
      return;
    end
    recur(d - 1, n);
    n++;
  endtask

  function automatic int depth(int d, ref int visits);
    visits++;
    if (d == 0) return 0;
    return 1 + depth(d - 1, visits);
  endfunction
endclass

module test_recursive_class_task_ref_argument;
  walker w;
  int n = 0, visits = 0, dep;

  initial begin
    w = new;
    w.recur(3, n);
    dep = w.depth(4, visits);
    $display("n=%0d depth=%0d visits=%0d", n, dep, visits);
  end
endmodule
