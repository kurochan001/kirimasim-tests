/*
:name: test_comment_before_specialized_local_cast_destination
:description: A local cast destination in a parameterized method uses the active specialization (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 6.24.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comment_before_specialized_local_cast_destination.expected
:expected_exit: 0
*/
// The destination is word#(W) in a method called on word#(12). A comment
// between declarations has no semantic effect. A matching object succeeds and
// another specialization fails.

module test_comment_before_specialized_local_cast_destination;
  class base; endclass
  class word #(int W = 8) extends base;
    function bit accepts(base source);
      int prefix;
      /* Destination type depends on the current specialization. */
      word#(W) found;
      int suffix;
      bit ok;
      ok = $cast(found, source);
      return ok && found == source;
    endfunction
  endclass

  initial begin
    automatic word#(12) a = new;
    automatic word#(4) b = new;
    bit same, other;
    same = a.accepts(a);
    other = a.accepts(b);
    $display("CHECK same=%0d other=%0d", same, other);
    $finish;
  end
endmodule
