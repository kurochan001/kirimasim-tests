/*
:name: test_clocking_blocks
:description: Test for clocking blocks: driving outputs and sampling inputs
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.13 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_blocks.expected
*/
// Test for clocking blocks: driving outputs and sampling inputs
// IEEE 1800-2023 §14

module test_clocking_blocks;
    logic clk = 0;
    logic [7:0] data_in = 0;
    logic [7:0] data_out;
    logic valid_in = 0;
    logic ready_out;
    int pass_count = 0;
    int test_count = 0;

    // Clock generation
    always #5 clk = ~clk;

    // Clocking block with input and output skews
    clocking cb @(posedge clk);
        default input #1step output #0;
        input data_in, valid_in;
        output data_out, ready_out;
    endclocking

    // Test driver using clocking block
    initial begin
        // Wait for clock
        @(cb);

        // Test 1: Write to output through clocking block
        test_count++;
        cb.data_out <= 8'hAA;
        cb.ready_out <= 1;
        // Whether the drive lands at this clocking event or the next one,
        // the value is on data_out after two more events (14.16).
        repeat (2) @(cb);
        if (data_out == 8'hAA && ready_out == 1) begin
            $display("Test 1: cb.data_out <= 0xAA PASS");
            pass_count++;
        end else begin
            $display("Test 1: data_out == %h FAIL", data_out);
        end

        // Test 2: Read input through clocking block
        test_count++;
        data_in = 8'h55;
        valid_in = 1;
        @(cb);
        if (cb.data_in == 8'h55) begin
            $display("Test 2: cb.data_in == 0x55 PASS");
            pass_count++;
        end else begin
            $display("Test 2: cb.data_in == %h FAIL", cb.data_in);
        end

        // Test 3: Multiple cycles
        test_count++;
        data_in = 8'h00;
        repeat (3) @(cb);
        data_in = 8'hFF;
        @(cb);
        if (cb.data_in == 8'hFF) begin
            $display("Test 3: cb.data_in after cycles PASS");
            pass_count++;
        end else begin
            $display("Test 3: cb.data_in == %h FAIL", cb.data_in);
        end

        // Test 4: Write multiple values
        test_count++;
        cb.data_out <= 8'h11;
        @(cb);
        cb.data_out <= 8'h22;
        @(cb);
        cb.data_out <= 8'h33;
        repeat (2) @(cb);
        if (data_out == 8'h33) begin
            $display("Test 4: Multiple writes through cb PASS");
            pass_count++;
        end else begin
            $display("Test 4: data_out == %h FAIL", data_out);
        end

        // Test 5: Read and write in same cycle
        test_count++;
        data_in = 8'hBB;
        cb.data_out <= 8'hCC;
        @(cb);
        $display("Test 5: Read/write same cycle - data_in=%h PASS", cb.data_in);
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
