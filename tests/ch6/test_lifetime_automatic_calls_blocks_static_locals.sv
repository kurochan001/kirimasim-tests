/*
:name: test_lifetime_automatic_calls_blocks_static_locals
:description: variables of automatic tasks, functions and their blocks are created and initialized on each entry, explicitly static ones keep their value, and static variables, also those of automatic subroutines and named blocks, can be read by hierarchical name (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 13.3.1 13.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_lifetime_automatic_calls_blocks_static_locals.expected
*/
// IEEE 1800-2023 §6.21: the variables of an automatic task or function live
// for one call and are initialized on each entry; a block inside it is an
// automatic block, whose declarations are automatic, so they are initialized
// on each entry to the block. A variable declared static there keeps its
// value across calls. Each call of a recursive automatic function has its
// own copy (§13.4.2), so fact(5) is 120. A static variable can be referenced
// by hierarchical name unless it is in an unnamed block, also when it is
// declared in an automatic task or function: the top reads count.calls and
// the variable of the named block nb after the calls. A static k would give
// the block line 5 6 8. Icarus Verilog 13.0 does not support a static
// variable in an automatic function (unsupported construct).

module test_lifetime_automatic_calls_blocks_static_locals;
  function automatic int count();
    int fresh = 10;
    static int calls = 0;
    fresh++;
    calls++;
    return fresh * 100 + calls;
  endfunction

  function automatic int fact(int n);
    int here = n;
    if (n <= 1) return 1;
    return here * fact(n - 1);
  endfunction

  task automatic loop_blocks(output string s);
    s = "";
    for (int i = 0; i < 3; i++) begin
      int k = 5;
      k += i;
      s = {s, $sformatf(" %0d", k)};
    end
  endtask

  int r1, r2, r3;
  string s;

  initial begin
    r1 = count();
    r2 = count();
    r3 = count();
    $display("count: %0d %0d %0d", r1, r2, r3);
    $display("fact(5)=%0d", fact(5));
    loop_blocks(s);
    $display("block:%s", s);
    begin : nb
      static int seen = 0;
      seen = r3;
    end
    $display("hierarchical: count.calls=%0d nb.seen=%0d", count.calls, nb.seen);
  end
endmodule
