/*
:name: test_bit_query_functions
:description: Bit query system functions: $countones, $onehot, $onehot0, $isunknown, $clog2
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9 20.8.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bit_query_functions.expected
*/
// Bit query system functions: $countones, $onehot, $onehot0, $isunknown, $clog2
// IEEE 1800-2023 §11.4

module test_bit_query_functions;
    logic [31:0] a, b, result;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: $countones
        test_count++;
        a = 32'hAAAAAAAA;
        result = $countones(a);
        if (result == 16) begin
            $display("Test 1: $countones PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL result=%0d", result);
        end

        // Test 2: $onehot
        test_count++;
        a = 32'h00000001;
        result = $onehot(a);
        if (result == 1) begin
            $display("Test 2: $onehot PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL result=%0d", result);
        end

        // Test 3: $onehot0
        test_count++;
        a = 32'h00000000;
        result = $onehot0(a);
        if (result == 1) begin
            $display("Test 3: $onehot0 PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL result=%0d", result);
        end

        // Test 4: $isunknown
        test_count++;
        a = 32'h12345678;
        result = $isunknown(a);
        if (result == 0) begin
            $display("Test 4: $isunknown PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL result=%0d", result);
        end

        // Test 5: $clog2
        test_count++;
        result = $clog2(256);
        if (result == 8) begin
            $display("Test 5: $clog2 PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL result=%0d", result);
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
