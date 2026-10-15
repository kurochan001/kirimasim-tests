/*
:name: test_initial_final
:description: Initial and final procedures (IEEE 1800-2023 Sections 9.2.1 and 9.2.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.1 9.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_initial_final.expected
*/
// IEEE 1800-2023 Section 9.2.1/9.2.3 - Initial/Final Block Tests
// Tests: Initial blocks, final blocks, execution order

module test_initial_final;
    int pass_count = 0;
    int fail_count = 0;

    int init_count = 0;
    int order_check = 0;
    // Each initial block writes only its own variables: the order of the
    // blocks at time 0 is not defined (4.7).
    int init_a = 0, init_b = 0;
    int order_a = 0, order_b = 0;
    logic [7:0] data;
    logic ready;

    // First initial block
    initial begin
        init_a = 1;
        order_a = 1;
        data = 8'hAA;
    end

    // Second initial block
    initial begin
        init_b = 1;
        order_b = 10;
        ready = 1'b1;
    end

    // Main test initial block
    initial begin
        #1;  // Wait for other blocks to execute
        init_count = init_a + init_b;
        order_check = order_a + order_b;
        $display("=== IEEE 1800-2023 Initial/Final Block Tests ===");

        // Test 1: Initial blocks executed
        $display("Test 1: Initial blocks executed");
        if (init_count >= 2) begin
            $display("Test 1 PASS: %0d initial blocks executed", init_count);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", init_count);
            fail_count++;
        end

        // Test 2: Data initialized
        $display("Test 2: Data initialized");
        if (data == 8'hAA) begin
            $display("Test 2 PASS: data=%h", data);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %h", data);
            fail_count++;
        end

        // Test 3: Ready initialized
        $display("Test 3: Ready initialized");
        if (ready == 1'b1) begin
            $display("Test 3 PASS: ready=%b", ready);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %b", ready);
            fail_count++;
        end

        // Test 4: Order check
        $display("Test 4: Multiple initial blocks");
        if (order_check >= 10) begin
            $display("Test 4 PASS: order_check=%0d", order_check);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %0d", order_check);
            fail_count++;
        end

        // Test 5: Modify data
        $display("Test 5: Modify data in initial");
        data = 8'hBB;
        if (data == 8'hBB) begin
            $display("Test 5 PASS: data=%h after modification", data);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %h", data);
            fail_count++;
        end

        // Test 6: Modify ready
        $display("Test 6: Modify ready in initial");
        ready = 1'b0;
        if (ready == 1'b0) begin
            $display("Test 6 PASS: ready=%b after modification", ready);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %b", ready);
            fail_count++;
        end

        // Test 7: Increment counter
        $display("Test 7: Increment counter");
        init_count++;
        if (init_count >= 3) begin
            $display("Test 7 PASS: init_count=%0d", init_count);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %0d", init_count);
            fail_count++;
        end

        // Test 8: Complex expression
        $display("Test 8: Complex expression");
        data = 8'h12 + 8'h34;
        if (data == 8'h46) begin
            $display("Test 8 PASS: 12+34=%h", data);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %h", data);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end

    // Final block (executes at end of simulation)
    final begin
        // This runs at simulation end
        $display("[FINAL] Simulation completed");
    end
endmodule
