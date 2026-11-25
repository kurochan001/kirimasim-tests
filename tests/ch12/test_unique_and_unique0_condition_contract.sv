/*
:name: test_unique_and_unique0_condition_contract
:description: Unique and unique0 check mutual exclusion on the same branch conditions
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_and_unique0_condition_contract.expected
*/
module test_unique_and_unique0_condition_contract;
  bit overlap_unique, overlap_zero;

  task automatic inspect(int selector);
    int first, second;
    second = 0;
    unique if (selector == 0)
      first = 11;
    else if (selector == 1 || (overlap_unique && selector == 0))
      first = 22;
    else
      first = 33;
    unique0 if (selector == 0)
      second = 44;
    else if (selector == 1 || (overlap_zero && selector == 0))
      second = 55;
    $display("selector=%0d unique=%0d unique0=%0d", selector, first, second);
  endtask

  initial begin
    overlap_unique = $test$plusargs("overlap_unique");
    overlap_zero = $test$plusargs("overlap_zero");
    for (int i=0; i<3; i++)
      inspect(i);
    $finish(0);
  end
endmodule
