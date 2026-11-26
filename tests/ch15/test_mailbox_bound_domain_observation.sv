/*
:name: test_mailbox_bound_domain_observation
:description: Legal mailbox bounds and nonblocking observations after a negative bound
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_bound_domain_observation.expected
*/
module test_mailbox_bound_domain_observation;
  mailbox #(int) bounded, unbounded, negative;
  int first, second, third, selected_bound;

  initial begin
    bounded = new(2);
    if (!bounded.try_put(17) || !bounded.try_put(29) || bounded.try_put(44))
      $fatal(1, "bounded capacity control failed");
    if (!bounded.try_get(first) || !bounded.try_get(second))
      $fatal(1, "bounded retrieval control failed");
    $display("bounded values=%0d,%0d remaining=%0d", first, second, bounded.num());

    unbounded = new(0);
    if (!unbounded.try_put(17) || !unbounded.try_put(29) || !unbounded.try_put(44))
      $fatal(1, "unbounded capacity control failed");
    if (!unbounded.try_get(first) || !unbounded.try_get(second) || !unbounded.try_get(third))
      $fatal(1, "unbounded retrieval control failed");
    $display("unbounded values=%0d,%0d,%0d remaining=%0d", first, second, third, unbounded.num());

    if ($value$plusargs("mailbox_bound=%d", selected_bound)) begin
      if (selected_bound >= 0)
        $fatal(1, "the observation requires a negative bound");
      $display("before negative constructor bound=%0d", selected_bound);
      $fflush();
      negative = new(selected_bound);
      if (negative == null)
        $display("negative constructor returned null");
      else
        $display("negative nonblocking put=%0d", negative.try_put(91));
    end
    $finish(0);
  end
endmodule
