/*
:name: test_cycle_delay
:description: Test for cycle delay statement execution
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.11 14.12
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cycle_delay.expected
*/
// Test for cycle delay statement execution
// IEEE 1800-2023 Section 14.11

module test_cycle_delay;
    logic clk = 0;
    int pass_count = 0;
    int test_count = 0;
    int counter = 0;

    always #5 clk = ~clk;

    // Clocking block for ## delays
    default clocking cb @(posedge clk);
    endclocking

    // The first rising edge is at time 5; ##0 does not wait when the
    // clocking event has already happened in the current time step (14.11).
    initial begin
        // Test 1: Single cycle delay
        test_count++;
        counter = 0;
        ##1;
        counter = 1;
        if ($time == 5) begin
            $display("Test 1: Single cycle delay PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL at time %0t", $time);
        end

        // Test 2: Multiple cycle delay
        test_count++;
        counter = 0;
        ##3;
        counter = 3;
        if ($time == 35) begin
            $display("Test 2: Multiple cycle delay PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL at time %0t", $time);
        end

        // Test 3: Zero cycle delay
        test_count++;
        counter = 10;
        ##0;
        counter = 11;
        if ($time == 35) begin
            $display("Test 3: Zero cycle delay PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL at time %0t", $time);
        end

        // Test 4: Cycle delay in sequence
        test_count++;
        counter = 0;
        ##1;
        counter++;
        ##1;
        counter++;
        ##1;
        counter++;
        if (counter == 3 && $time == 65) begin
            $display("Test 4: Cycle delay sequence PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL counter=%0d", counter);
        end

        // Test 5: Longer delay
        test_count++;
        counter = 0;
        ##5;
        counter = 100;
        if ($time == 115) begin
            $display("Test 5: Longer delay PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL at time %0t", $time);
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
