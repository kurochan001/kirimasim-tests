/*
:name: test_generate_9
:description: Test for generate statements
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_9.expected
*/
// Test for generate statements
// IEEE 1800-2023 §27

module test_generate;
    parameter N = 4;
    logic [N-1:0] data;
    logic [N-1:0] result;
    int pass_count = 0;
    int test_count = 0;

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_loop
            assign result[i] = data[i] & 1'b1;
        end
    endgenerate

    initial begin
        // Test 1: Generate for loop
        test_count++;
        data = 4'b1010;
        #1;
        if (result == 4'b1010) begin
            $display("Test 1: Generate for loop PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL result=%b", result);
        end

        // Test 2: Different data
        test_count++;
        data = 4'b1111;
        #1;
        if (result == 4'b1111) begin
            $display("Test 2: Different data PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Zero data
        test_count++;
        data = 4'b0000;
        #1;
        if (result == 4'b0000) begin
            $display("Test 3: Zero data PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Alternating
        test_count++;
        data = 4'b0101;
        #1;
        if (result == 4'b0101) begin
            $display("Test 4: Alternating PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
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
