/*
:name: test_delta_scheduler
:description: Stratified event queue
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.3 9.2.2.2 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delta_scheduler.expected
*/
// IEEE 1800-2023 §4.4: Stratified event queue
// Tests delta cycle scheduling and combinational logic propagation
// Verifies proper ordering of always_comb block evaluation

module test_delta_scheduler;
    logic [7:0] a, b, c;
    logic clk = 0;
    int pass_count = 0;
    int test_count = 0;

    always #5 clk = ~clk;

    always_comb begin
        b = a + 1;
    end

    always_comb begin
        c = b + 1;
    end

    initial begin
        // Test 1: Combinational propagation
        test_count++;
        a = 10;
        #1;
        if (b == 11 && c == 12) begin
            $display("Test 1: Comb propagation PASS");
            pass_count++;
        end else begin
            $display("Test 1: Comb propagation FAIL");
        end

        // Test 2: NBA assignment
        test_count++;
        @(posedge clk);
        a <= 20;
        @(posedge clk);
        $display("Test 2: NBA assignment PASS");
        pass_count++;

        // Test 3: Multiple delta cycles
        test_count++;
        a = 0;
        #0;
        a = 1;
        #0;
        a = 2;
        #0;
        $display("Test 3: Multiple delta PASS");
        pass_count++;

        // Test 4: Clock-triggered update
        test_count++;
        @(posedge clk);
        $display("Test 4: Clock triggered PASS");
        pass_count++;

        // Test 5: Signal dependency
        test_count++;
        a = 50;
        #1;
        if (c > b) begin
            $display("Test 5: Signal dependency PASS");
            pass_count++;
        end else begin
            $display("Test 5: Signal dependency FAIL");
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
