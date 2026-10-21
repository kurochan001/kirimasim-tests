/*
:name: test_dpi_context_call_chain
:description: Context imports call exported functions of other instances, which change their own instance's data and call context imports again, and after each export returns the chain is back in the scope it had when the export was called (IEEE 1800-2023 Section 35.5.1.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.3 35.5.3 35.7 H.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_context_call_chain.c
:expected_stdout: @test_dpi_context_call_chain.expected
*/
// IEEE 1800-2023 §35.5.1.3: an import that calls exported subroutines, and
// through them reaches SystemVerilog data other than its arguments, is
// declared context. §35.5.3: a call of a context import from SystemVerilog
// gets the scope of the instance of its import declaration; svSetScope
// changes the scope of the chain (H.9.3), and when an export called from the
// chain returns, the scope is again the one the chain had at that call. An
// export can call imports in turn, all in one chain. c_start, in the top
// module, calls sv_down of node a with 4; sv_down adds its argument to seen
// of its own instance and calls its context import c_down, which calls
// sv_down of the other node with one less, down to 0. The C code checks the
// scope on entry to each import and after each export returns, comparing the
// names that svGetNameFromScope gives (H.9.3), and counts the checks that
// fail.
// When an export returns, Verilator 5.052 leaves the scope that the inner
// part of the chain set, so two of the checks after an export fail here.

module test_dpi_context_call_chain_node #(parameter int ID = 0) ();
  import "DPI-C" context function int c_down(input int id, input int n);
  export "DPI-C" function sv_down;

  int seen;

  function automatic int sv_down(input int n);
    seen += n;
    return n + c_down(ID, n - 1);
  endfunction
endmodule

module test_dpi_context_call_chain;
  import "DPI-C" context function int c_start(input int n);
  import "DPI-C" function int c_failed_on_entry();
  import "DPI-C" function int c_failed_after_export();

  test_dpi_context_call_chain_node #(.ID(1)) a();
  test_dpi_context_call_chain_node #(.ID(2)) b();

  int sum;

  initial begin
    sum = c_start(4);
    $display("sum along the chain: %0d", sum);
    $display("a saw %0d, b saw %0d", a.seen, b.seen);
    $display("failed scope checks: %0d on entry, %0d after an export returned",
             c_failed_on_entry(), c_failed_after_export());
  end
endmodule
