/*
:name: test_queue_insert_delete
:description: Queue push, pop, insert and delete
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_insert_delete.expected
*/
// Queue methods: push, pop, insert and delete (IEEE 1800-2023)

module test_queue_insert_delete;
  int queue[$];
  int value;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Empty queue
    if (queue.size() == 0) pass_count++;

    // Test 2: Push elements
    queue.push_back(10);
    queue.push_back(20);
    queue.push_back(30);
    if (queue.size() == 3) pass_count++;

    // Test 3: Access elements
    if (queue[0] == 10) pass_count++;
    if (queue[1] == 20) pass_count++;
    if (queue[2] == 30) pass_count++;

    // Test 4: Push front
    queue.push_front(5);
    if (queue[0] == 5) pass_count++;
    if (queue.size() == 4) pass_count++;

    // Test 5: Pop front
    value = queue.pop_front();
    if (value == 5) pass_count++;
    if (queue.size() == 3) pass_count++;

    // Test 6: Pop back
    value = queue.pop_back();
    if (value == 30) pass_count++;
    if (queue.size() == 2) pass_count++;

    // Test 7: Insert
    queue.insert(1, 15);
    if (queue[1] == 15) pass_count++;
    if (queue.size() == 3) pass_count++;

    // Test 8: Delete
    queue.delete(1);
    if (queue.size() == 2) pass_count++;

    // Test 9: Clear
    queue.delete();
    if (queue.size() == 0) pass_count++;

    $display("Queue tests: %0d/15 passed", pass_count);
    if (pass_count == 15) begin
      $display("PASS: Queue tests");
    end else begin
      $display("FAIL: Too few queue tests passed");
    end
  end
endmodule
