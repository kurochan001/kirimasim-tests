/*
:name: test_ch6_extra_ref_dynamic_equiv
:description: A dynamic array of int is equivalent to another dynamic array of int, so a ref argument can pair them (IEEE 1800-2023 Section 6.22.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.2 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch6_extra_ref_dynamic_equiv.expected
*/
// IEEE 1800-2023 §6.22.2 rule e: two dynamic arrays are equivalent when they
// are the same kind of array and their element types are equivalent; int and
// int match, so int[] and int[] are equivalent. §13.5.2 lets a ref formal be
// matched with an equivalent actual and passes a reference rather than a
// copy, so the task below resizes and fills the caller's array. The
// nonequivalent kinds are covered by test_ch6_extra_ref_dynamic_kind.
// Icarus Verilog 13.0 does not support ref ports, so this test has no Icarus
// oracle.

module test_ch6_extra_ref_dynamic_equiv;
  task automatic fill(ref int a[]);
    a = new[3];
    a[0] = 4;
    a[1] = 5;
    a[2] = 6;
  endtask

  int d[];
  initial begin
    fill(d);
    $display("size=%0d sum=%0d", d.size(), d[0] + d[1] + d[2]);
  end
endmodule
