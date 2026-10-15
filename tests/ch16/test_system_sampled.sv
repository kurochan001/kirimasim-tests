/*
:name: test_system_sampled
:description: Test $sampled - sampled value in assertions
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_sampled.expected
*/
// Test $sampled - sampled value in assertions
module test_system_sampled;
    logic clk;
    logic [7:0] data;
    logic [7:0] sampled_data;
    int test_count;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        test_count = 0;
        data = 8'h00;

        // Test 1: Sample initial value
        @(posedge clk);
        sampled_data = $sampled(data);
        if (sampled_data == 8'h00)
            $display("PASS: $sampled initial value = 0x%02X", sampled_data);
        else
            $display("FAIL: $sampled initial = 0x%02X, expected 0x00", sampled_data);
        test_count++;

        // Test 2: Change data and sample at next edge
        data = 8'hAA;
        @(posedge clk);
        sampled_data = $sampled(data);
        if (sampled_data == 8'hAA)
            $display("PASS: $sampled after change = 0x%02X", sampled_data);
        else
            $display("FAIL: $sampled = 0x%02X, expected 0xAA", sampled_data);
        test_count++;

        // Test 3: Sample multiple times same cycle
        data = 8'h55;
        @(posedge clk);
        sampled_data = $sampled(data);
        if (sampled_data == 8'h55)
            $display("PASS: $sampled = 0x%02X", sampled_data);
        else
            $display("FAIL: $sampled = 0x%02X, expected 0x55", sampled_data);
        test_count++;

        // Test 4: Sample expression
        data = 8'h0F;
        @(posedge clk);
        sampled_data = $sampled(data + 8'h01);
        if (sampled_data == 8'h10)
            $display("PASS: $sampled(data+1) = 0x%02X", sampled_data);
        else
            $display("FAIL: $sampled(data+1) = 0x%02X, expected 0x10", sampled_data);
        test_count++;

        // Test 5: Verify test completion
        if (test_count == 4)
            $display("PASS: All $sampled tests completed");
        else
            $display("FAIL: Only %0d/4 tests completed", test_count);

        $finish;
    end
endmodule
