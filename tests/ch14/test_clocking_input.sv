/*
:name: test_clocking_input
:description: Test: Clocking block input skew
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.4 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_input.expected
*/
// Test: Clocking block input skew
// Tests clocking block input sampling with skew

module test_clocking_input;
    logic clk;
    logic [7:0] data_in;
    logic valid;
    logic [3:0] control;

    int pass_count = 0;
    int fail_count = 0;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Clocking block with default input skew (1step before posedge)
    clocking cb @(posedge clk);
        default input #1step;
        input data_in;
        input valid;
        input control;
    endclocking

    initial begin
        // Initialize
        data_in = 8'h00;
        valid = 0;
        control = 4'h0;

        // Wait for first clock edge
        @(posedge clk);
        #1;

        // Test 1: Basic input sampling
        data_in = 8'hAA;
        valid = 1;
        @(posedge clk);
        #1;
        if (cb.data_in == 8'hAA) begin
            $display("PASS: Test 1 - Clocking block samples input data");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - expected 0xAA, got 0x%0h", cb.data_in);
            fail_count++;
        end

        // Test 2: Valid signal sampling
        if (cb.valid == 1) begin
            $display("PASS: Test 2 - Clocking block samples valid signal");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - expected valid=1, got %0b", cb.valid);
            fail_count++;
        end

        // Test 3: Data change between clock edges
        data_in = 8'h55;
        #2;
        data_in = 8'hBB;
        @(posedge clk);
        #1;
        // Should sample the value at the skew point before clock edge
        if (cb.data_in == 8'hBB) begin
            $display("PASS: Test 3 - Samples value at skew point");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - expected 0xBB, got 0x%0h", cb.data_in);
            fail_count++;
        end

        // Test 4: Control signal sampling
        control = 4'hF;
        @(posedge clk);
        #1;
        if (cb.control == 4'hF) begin
            $display("PASS: Test 4 - Control signal sampled correctly");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - expected 0xF, got 0x%0h", cb.control);
            fail_count++;
        end

        // Test 5: Multiple consecutive samples
        data_in = 8'h11;
        @(posedge clk);
        #1;
        if (cb.data_in == 8'h11) pass_count++; else fail_count++;

        data_in = 8'h22;
        @(posedge clk);
        #1;
        if (cb.data_in == 8'h22) pass_count++; else fail_count++;

        data_in = 8'h33;
        @(posedge clk);
        #1;
        if (cb.data_in == 8'h33) begin
            $display("PASS: Test 5 - Consecutive sampling works");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - consecutive sampling failed");
            fail_count++;
        end

        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All clocking input tests passed");
        else
            $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
