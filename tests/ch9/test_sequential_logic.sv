/*
:name: test_sequential_logic
:description: Counter and register in always procedures with event controls (IEEE 1800-2023 Sections 9.2.2.1 and 9.4.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.1 9.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequential_logic.expected
*/
// IEEE 1800-2023 Sections 9.2.2.1 and 9.4.2

module test_sequential_logic;
    logic clk = 0;
    logic rst_n = 0;
    logic [7:0] counter = 0;
    logic [7:0] data_in = 0;
    logic [7:0] data_out;
    int pass_count = 0;
    int test_count = 0;

    always #5 clk = ~clk;

    // Sequential counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 8'd0;
        else
            counter <= counter + 1;
    end

    // Register
    always @(posedge clk) begin
        data_out <= data_in;
    end

    initial begin
        // Test 1: Reset counter
        test_count++;
        rst_n = 0;
        @(posedge clk);
        @(negedge clk);
        if (counter == 0) begin
            $display("Test 1: Reset counter PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL counter=%0d", counter);
        end

        // Test 2: Release reset and count
        test_count++;
        rst_n = 1;
        @(posedge clk);
        @(negedge clk);
        if (counter == 1) begin
            $display("Test 2: Counter incremented PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL counter=%0d", counter);
        end

        // Test 3: Multiple cycles
        test_count++;
        repeat(3) @(posedge clk);
        @(negedge clk);
        if (counter == 4) begin
            $display("Test 3: Counter after 3 cycles PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL counter=%0d", counter);
        end

        // Test 4: Data pipeline
        test_count++;
        data_in = 8'hAB;
        @(posedge clk);
        @(negedge clk);
        if (data_out == 8'hAB) begin
            $display("Test 4: Data pipeline PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL data_out=%h", data_out);
        end

        // Test 5: Different data
        test_count++;
        data_in = 8'hCD;
        @(posedge clk);
        @(negedge clk);
        if (data_out == 8'hCD) begin
            $display("Test 5: Different data PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL data_out=%h", data_out);
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
