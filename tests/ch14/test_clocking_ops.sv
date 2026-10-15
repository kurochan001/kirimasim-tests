/*
:name: test_clocking_ops
:description: Test for clocking block operations
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.13 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_ops.expected
*/
// Test for clocking block operations
// IEEE 1800-2023 §14

module test_clocking_ops;
    logic clk = 0;
    logic [7:0] data_in, data_out;
    logic valid;
    int pass_count = 0;
    int test_count = 0;

    always #5 clk = ~clk;

    clocking cb @(posedge clk);
        input data_in;
        output data_out;
        input valid;
    endclocking

    initial begin
        data_in = 8'h00;
        data_out = 8'h00;
        valid = 0;

        // Test 1: Initial state
        test_count++;
        @(cb);
        if (cb.data_in == 8'h00) begin
            $display("Test 1: Initial state PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Data change
        test_count++;
        data_in = 8'hAA;
        @(cb);
        @(cb);
        if (cb.data_in == 8'hAA) begin
            $display("Test 2: Data change PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL data_in=%h", cb.data_in);
        end

        // Test 3: Valid signal
        test_count++;
        valid = 1;
        @(cb);
        @(cb);
        if (cb.valid == 1) begin
            $display("Test 3: Valid signal PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL valid=%b", cb.valid);
        end

        // Test 4: Output through clocking
        test_count++;
        cb.data_out <= 8'hBB;
        @(cb);
        @(cb);
        if (data_out == 8'hBB) begin
            $display("Test 4: Output PASS data_out=%h", data_out);
            pass_count++;
        end else begin
            $display("Test 4: FAIL data_out=%h", data_out);
        end

        // Test 5: Multiple cycles
        test_count++;
        for (int i = 0; i < 5; i++) begin
            data_in = i;
            @(cb);
        end
        if (cb.data_in == 8'd4) begin
            $display("Test 5: Multiple cycles PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL data_in=%h", cb.data_in);
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
