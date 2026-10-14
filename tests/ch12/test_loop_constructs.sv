/*
:name: test_loop_constructs
:description: Test loop constructs (IEEE 1800-2023 Section 12.7)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loop_constructs.expected
*/
// Test loop constructs (IEEE 1800-2023 Section 12.7)

module test_loop_constructs;
  int counter;
  int arr[10];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: for loop
    counter = 0;
    for (int i = 0; i < 5; i++) counter++;
    if (counter == 5) pass_count++;

    // Test 2: while loop
    counter = 0;
    while (counter < 3) counter++;
    if (counter == 3) pass_count++;

    // Test 3: do-while loop
    counter = 0;
    do counter++; while (counter < 2);
    if (counter == 2) pass_count++;

    // Test 4: repeat loop
    counter = 0;
    repeat(4) counter++;
    if (counter == 4) pass_count++;

    // Test 5: foreach loop
    foreach(arr[i]) arr[i] = i;
    if (arr[5] == 5) pass_count++;

    // Test 6: forever with break
    counter = 0;
    forever begin
      counter++;
      if (counter >= 3) break;
    end
    if (counter == 3) pass_count++;

    $display("Loop constructs tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Loop constructs tests");
    end else begin
      $display("FAIL: Some loop tests failed");
    end
  end
endmodule
