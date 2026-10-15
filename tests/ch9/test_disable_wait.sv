/*
:name: test_disable_wait
:description: Process Control
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2 9.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_wait.expected
*/
// IEEE 1800-2023 §9.6 Process Control
// Tests disable statements and wait statements

module test_disable_wait;
    int pass_count = 0;
    int fail_count = 0;
    int counter;
    bit flag;
    event done_event;

    initial begin : main_block
        // Test 1: disable named block
        counter = 0;
        begin : count_block
            for (int i = 0; i < 100; i++) begin
                counter++;
                if (counter >= 5) disable count_block;
            end
        end
        if (counter == 5) begin
            $display("PASS: disable named block - counter = 5");
            pass_count++;
        end else begin
            $display("FAIL: disable named block - counter=%0d", counter);
            fail_count++;
        end

        // Test 2: nested disable
        counter = 0;
        begin : outer_block
            for (int i = 0; i < 10; i++) begin : inner_block
                counter++;
                if (counter == 3) disable outer_block;
            end
        end
        if (counter == 3) begin
            $display("PASS: nested disable - counter = 3");
            pass_count++;
        end else begin
            $display("FAIL: nested disable - counter=%0d", counter);
            fail_count++;
        end

        // Test 3: wait with immediate true condition
        flag = 1;
        wait (flag == 1);
        $display("PASS: wait with immediate true - passed immediately");
        pass_count++;

        // Test 4: Multiple block disables
        counter = 0;
        begin : block_a
            counter++;
            begin : block_b
                counter++;
                disable block_b;
                counter = 100;  // Should not execute
            end
            counter++;  // Should execute after block_b disabled
        end
        if (counter == 3) begin
            $display("PASS: multiple block disables - counter = 3");
            pass_count++;
        end else begin
            $display("FAIL: multiple block disables - counter=%0d", counter);
            fail_count++;
        end

        // Test 5: disable with continue/break equivalent behavior
        counter = 0;
        for (int i = 0; i < 5; i++) begin : iter_block
            if (i == 2) begin
                disable iter_block;  // Acts like continue
            end
            counter++;
        end
        if (counter == 4) begin  // Skipped i=2
            $display("PASS: disable as continue - counter = 4");
            pass_count++;
        end else begin
            $display("FAIL: disable as continue - counter=%0d", counter);
            fail_count++;
        end

        $display("");
        $display("=== Disable/Wait Statements Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
