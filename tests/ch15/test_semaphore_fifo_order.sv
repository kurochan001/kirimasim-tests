/*
:name: test_semaphore_fifo_order
:description: Processes that wait in get on a semaphore without keys obtain the keys in the order in which they started to wait (IEEE 1800-2023 Section 15.3.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3.3 15.3.1 15.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_fifo_order.expected
*/
// IEEE 1800-2023 §15.3.3: the waiting queue of a semaphore is first-in
// first-out; the order of arrival is kept. The semaphore starts with no keys
// (15.3.1). C, A and B start waiting at 1, 2 and 3, each for one key; each
// put of one key (15.3.2) at 10, 20 and 30 lets the next of them go, in the
// order C, A, B, whatever their names or the order of the fork's branches.

module test_semaphore_fifo_order;
  semaphore s = new(0);
  string order = "";

  task automatic take(string name, int delay);
    #delay;
    s.get(1);
    order = {order, " ", name, $sformatf("@%0d", $time)};
  endtask

  initial begin
    fork
      take("A", 2);
      take("B", 3);
      take("C", 1);
    join_none
    #10 s.put(1);
    #10 s.put(1);
    #10 s.put(1);
    #1 $display("order:%s", order);
  end
endmodule
