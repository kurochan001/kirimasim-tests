/*
:name: test_initial_block_2
:description: Initial block execution
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_initial_block_2.expected
*/
// Initial block execution
// Verifies initial block execution order and behavior

module test_initial_block;
    int order_tracker = 0;
    int block1_order, block2_order, block3_order;
    logic [7:0] data1, data2, data3;
    int sum;
    int pass_count = 0;
    int fail_count = 0;

    // Scenario 1: First initial block
    initial begin
        block1_order = order_tracker++;
        data1 = 8'hAA;
    end

    // Scenario 2: Second initial block
    initial begin
        block2_order = order_tracker++;
        data2 = 8'hBB;
    end

    // Scenario 3: Third initial block with delay
    initial begin
        #1;
        block3_order = order_tracker++;
        data3 = 8'hCC;
    end

    // Scenario 4: Initial block with computation
    initial begin
        sum = 0;
        for (int i = 1; i <= 5; i++) begin
            sum = sum + i;
        end
    end

    // Main test block
    initial begin
        // Wait for all initial blocks to execute
        #2;

        // Test 1: First block executed
        if (data1 === 8'hAA) begin
            $display("PASS: Scenario 1 - Block 1 executed (data1=0x%h)", data1);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 1 - data1=0x%h (expected 0xAA)", data1);
            fail_count++;
        end

        // Test 2: Second block executed
        if (data2 === 8'hBB) begin
            $display("PASS: Scenario 2 - Block 2 executed (data2=0x%h)", data2);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 2 - data2=0x%h (expected 0xBB)", data2);
            fail_count++;
        end

        // Test 3: Third block executed with delay
        if (data3 === 8'hCC) begin
            $display("PASS: Scenario 3 - Block 3 executed after delay (data3=0x%h)", data3);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 3 - data3=0x%h (expected 0xCC)", data3);
            fail_count++;
        end

        // Test 4: Block 1 and 2 started at time 0
        if (block1_order < block3_order && block2_order < block3_order) begin
            $display("PASS: Scenario 4 - Block 3 executed after delay");
            pass_count++;
        end else begin
            $display("FAIL: Scenario 4 - Order incorrect (b1=%0d, b2=%0d, b3=%0d)",
                     block1_order, block2_order, block3_order);
            fail_count++;
        end

        // Test 5: Computation in initial block
        if (sum === 15) begin
            $display("PASS: Scenario 5 - Computation correct (sum=%0d)", sum);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 5 - sum=%0d (expected 15)", sum);
            fail_count++;
        end

        // Summary
        $display("Initial block execution: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
