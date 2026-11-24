/*
:name: test_semaphore_put_named_count_and_default_one
:description: Semaphore put accepts a named signed integer count and a no argument call returns one key
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_put_named_count_and_default_one.expected
*/
module test_semaphore_put_named_count_and_default_one;
  std::semaphore available = new(0);

  initial begin
    int first, second, exhausted;
    available.put(.keyCount(3));
    first = available.try_get(3);
    available.put();
    second = available.try_get();
    exhausted = available.try_get();
    $display("named=%0d default=%0d exhausted=%0d", first, second, exhausted);
  end
endmodule
