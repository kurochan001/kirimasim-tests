/*
:name: test_mailbox_negative_bound_observation
:description: A positive mailbox bound provides a control for observing a negative bound
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_negative_bound_observation.expected
*/
module test_mailbox_negative_bound_observation;
  mailbox #(int) valid, invalid;
  int first, second;
  initial begin
    valid = new(2);
    if (valid.try_put(17) != 1 || valid.try_put(29) != 1 || valid.try_put(44) != 0)
      $fatal(1, "bad bounded control");
    if (valid.try_get(first) != 1 || valid.try_get(second) != 1)
      $fatal(1, "bounded control did not return both values");
    $display("bounded mailbox values=%0d,%0d remaining=%0d", first, second, valid.num());
    if ($test$plusargs("observe_negative")) begin
      $display("before constructing mailbox with negative bound");
      invalid = new(-1);
      $display("negative constructor returned null=%0d", invalid == null);
    end
    $finish(0);
  end
endmodule
