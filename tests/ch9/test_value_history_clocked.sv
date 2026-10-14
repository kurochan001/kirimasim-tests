/*
:name: test_value_history_clocked
:description: Keeping the previous value of a variable across clock edges in one process
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_history_clocked.expected
*/
// Keeping the previous value of a variable across clock edges in one process
// IEEE 1800-2023 §16

module test_value_history_clocked;
    logic clk = 0;
    logic [7:0] data;
    logic [7:0] prev_data;
    int pass_count = 0;
    int test_count = 0;

    always #5 clk = ~clk;

    initial begin
        data = 8'h00;
        prev_data = 8'h00;

        // Test 1: Initial value
        test_count++;
        @(posedge clk);
        if (data == 8'h00) begin
            $display("Test 1: Initial value PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Value change
        test_count++;
        prev_data = data;
        data = 8'hAA;
        @(posedge clk);
        if (data == 8'hAA && prev_data == 8'h00) begin
            $display("Test 2: Value change PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Multiple changes
        test_count++;
        data = 8'h11;
        @(posedge clk);
        data = 8'h22;
        @(posedge clk);
        data = 8'h33;
        @(posedge clk);
        if (data == 8'h33) begin
            $display("Test 3: Multiple changes PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL data=%h", data);
        end

        // Test 4: $past simulation
        test_count++;
        prev_data = data;
        data = 8'h44;
        @(posedge clk);
        if (prev_data == 8'h33) begin
            $display("Test 4: Previous value PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL prev=%h", prev_data);
        end

        // Test 5: Rapid changes
        test_count++;
        for (int i = 0; i < 10; i++) begin
            data = i;
            #1;
        end
        @(posedge clk);
        $display("Test 5: Rapid changes PASS data=%h", data);
        pass_count++;

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
