/*
:name: test_parallel_method_output_handle_after_forever_delay
:description: Concurrent method activations retain their own output handle across a delay (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 8.6 13.5.1 12.7.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parallel_method_output_handle_after_forever_delay.expected
:expected_exit: 0
*/
// The two drivers fetch distinct objects and resume at the same time. Store
// each result on its own driver, then print in fixed driver order after both
// observations.

module test_parallel_method_output_handle_after_forever_delay;
  class packet;
    int id;
    function new(int value); id = value; endfunction
  endclass
  class source;
    packet value;
    function new(int id); value = new(id); endfunction
    task get(output packet result); result = value; endtask
  endclass
  class driver;
    source channel;
    int seen;
    function new(int id); channel = new(id); endfunction
    task drive();
      packet request;
      forever begin
        channel.get(request);
        #1;
        seen = request.id;
        #10;
      end
    endtask
  endclass
  driver first, second;
  initial begin
    first = new(11);
    second = new(22);
    fork first.drive(); second.drive(); join
  end
  initial begin
    #3;
    $display("CHECK ids=%0d/%0d", first.seen, second.seen);
    $finish;
  end
endmodule
