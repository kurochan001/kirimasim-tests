/*
:name: test_timed_nested_fork_conditionals_keep_activation_formals
:description: Nested timed fork conditionals preserve each activation formal (IEEE 1800-2023 Section 9.3.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.2 6.21 13.5.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timed_nested_fork_conditionals_keep_activation_formals.expected
:expected_exit: 0
*/
// Each activation gets separate input formals. Sequential notifications
// resume separate fork branches and their results are checked in order.

module test_timed_nested_fork_conditionals_keep_activation_formals;
  class node;
    int id;
    event done;
    function new(int i); id = i; endfunction
    task wait_done(); @done; endtask
  endclass
  class hopper;
    int observed[3];
    task execute(node phase, int expected);
      fork
        begin
          if (expected < 2) begin
            if (phase.id < 2) begin
              phase.wait_done();
              $display("CHECK woke %0d %0d", expected, phase.id);
            end
            $display("CHECK after %0d %0d", expected, phase.id);
          end
          observed[expected] = phase.id + 1;
        end
      join_none
    endtask
  endclass
  initial begin
    automatic hopper h = new;
    automatic node a = new(0), b = new(1), c = new(2);
    h.execute(a, 0);
    #0; h.execute(b, 1);
    #0; h.execute(c, 2);
    #1; -> a.done;
    #1; -> b.done;
    #1;
    $display("CHECK recorded=%0d,%0d,%0d", h.observed[0], h.observed[1], h.observed[2]);
    if (h.observed[0] != 1 || h.observed[1] != 2 || h.observed[2] != 3)
      $fatal(1, "wrong values after the conditional: %p", h.observed);
    $display("CHECK pass");
    $finish;
  end
endmodule
