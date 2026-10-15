/*
:name: test_parity_edge_cases
:description: Even and odd parity built from reduction XOR in continuous assignments
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9 10.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parity_edge_cases.expected
*/
// IEEE 1800-2023: Parity edge cases
// Tests for parity generator/checker constructs

module test_parity_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] data;
    logic even_parity, odd_parity;
    logic [8:0] data_with_even, data_with_odd;
    logic even_check, odd_check;

    // Parity generator
    assign even_parity = ^data;        // XOR reduction for even parity
    assign odd_parity = ~(^data);      // Inverted for odd parity

    // Data with parity
    assign data_with_even = {even_parity, data};
    assign data_with_odd = {odd_parity, data};

    // Parity checker
    assign even_check = ^data_with_even;  // Should be 0 for valid even parity
    assign odd_check = ^data_with_odd;    // Should be 1 for valid odd parity

    initial begin
        // Test 1: All zeros (even number of 1s)
        test_count++;
        data = 8'h00;
        #1;
        if (even_parity == 0) begin
            pass_count++;
            $display("Test 1 PASS: 0x00 even_parity=%b", even_parity);
        end else begin
            $display("Test 1 FAIL: unexpected even_parity=%b", even_parity);
        end

        // Test 2: All ones (even number of 1s)
        test_count++;
        data = 8'hFF;
        #1;
        if (even_parity == 0) begin
            pass_count++;
            $display("Test 2 PASS: 0xFF even_parity=%b", even_parity);
        end else begin
            $display("Test 2 FAIL: unexpected even_parity=%b", even_parity);
        end

        // Test 3: Single 1 (odd number of 1s)
        test_count++;
        data = 8'h01;
        #1;
        if (even_parity == 1) begin
            pass_count++;
            $display("Test 3 PASS: 0x01 even_parity=%b", even_parity);
        end else begin
            $display("Test 3 FAIL: unexpected");
        end

        // Test 4: Odd parity complement
        test_count++;
        if (odd_parity == 0) begin
            pass_count++;
            $display("Test 4 PASS: 0x01 odd_parity=%b", odd_parity);
        end else begin
            $display("Test 4 FAIL: unexpected odd_parity=%b", odd_parity);
        end

        // Test 5: Even parity check valid
        test_count++;
        data = 8'hAA;  // 4 ones
        #1;
        if (even_check == 0) begin
            pass_count++;
            $display("Test 5 PASS: Even check valid=%b", even_check);
        end else begin
            $display("Test 5 FAIL: unexpected even_check=%b", even_check);
        end

        // Test 6: Odd parity check valid
        test_count++;
        if (odd_check == 1) begin
            pass_count++;
            $display("Test 6 PASS: Odd check valid=%b", odd_check);
        end else begin
            $display("Test 6 FAIL: unexpected odd_check=%b", odd_check);
        end

        // Test 7: Pattern 0x55 (4 ones)
        test_count++;
        data = 8'h55;
        #1;
        if (even_parity == 0) begin
            pass_count++;
            $display("Test 7 PASS: 0x55 even_parity=%b", even_parity);
        end else begin
            $display("Test 7 FAIL: unexpected");
        end

        $display("=== Parity Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
