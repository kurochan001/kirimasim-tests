/*
:name: test_cg_bins_set_expr_array_kinds
:description: A set expression of a bin can be a fixed-size array, a dynamic array or a function call returning a queue, with elements of another integral type than the coverpoint, and gives the values of a single bin, a fixed number of bins or one bin per value (IEEE 1800-2023 Section 19.5.1.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1.2 19.5.1 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_bins_set_expr_array_kinds.expected
*/
// IEEE 1800-2023 §19.5.1.2: the values of a bin can be given by an expression
// that yields an array of any kind except associative, whose elements are
// assignment compatible with the type of the coverpoint; as a covergroup
// expression (19.5) it uses only constants, covergroup arguments and functions
// without side effects. The bin forms of 19.5.1 apply to these values: one is
// a single bin for the int elements 1, 4 and 6 of a fixed-size array
// parameter; two[2] shares the byte elements 2, 3 and 5 of a dynamic array,
// passed as an argument of the covergroup, out as {2} and {3, 5}; f[] makes a
// bin for each element of the queue that the function steps returns, 8 and
// 10. The coverpoint has 5 bins, and the test prints the covered bins and the
// bins (19.11.1) after each sample.

module test_cg_bins_set_expr_array_kinds;
  typedef int int_q_t[$];

  localparam int FIXED_VALS[3] = '{1, 4, 6};

  bit [3:0] x;
  byte dyn_vals[] = '{2, 3, 5};

  function automatic int_q_t steps(int first, int n);
    int_q_t q;
    for (int i = 0; i < n; i++)
      q.push_back(first + 2 * i);
    return q;
  endfunction

  covergroup cg (byte dyn[]);
    cp: coverpoint x {
      bins one = FIXED_VALS;
      bins two[2] = dyn;
      bins f[] = steps(8, 2);
    }
  endgroup

  cg inst;

  task automatic put(bit [3:0] v);
    int c, t;
    x = v;
    inst.sample();
    void'(inst.cp.get_inst_coverage(c, t));
    $display("x=%0d: %0d/%0d %.2f", v, c, t, inst.cp.get_inst_coverage());
  endtask

  initial begin
    inst = new(dyn_vals);
    put(6);
    put(5);
    put(3);
    put(2);
    put(8);
    put(9);
    put(10);
  end
endmodule
