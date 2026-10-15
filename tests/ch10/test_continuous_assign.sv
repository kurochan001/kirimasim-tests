/*
:name: test_continuous_assign
:description: Continuous Assignment Tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2 11.4.9 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_continuous_assign.expected
*/
// IEEE 1800-2023 Section 10.3 - Continuous Assignment Tests
// Tests: Continuous assignments, wire behavior

module test_continuous_assign;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] a, b;
    wire [7:0] sum;
    wire [7:0] diff;
    wire [7:0] and_result;
    wire [7:0] or_result;
    wire bit_result;
    wire [7:0] mux_out;
    logic sel;

    // Continuous assignments
    assign sum = a + b;
    assign diff = a - b;
    assign and_result = a & b;
    assign or_result = a | b;
    assign bit_result = |a;  // Reduction OR
    assign mux_out = sel ? a : b;

    initial begin
        $display("=== IEEE 1800-2023 Continuous Assignment Tests ===");

        // Test 1: Sum
        $display("Test 1: Sum");
        a = 8'd10;
        b = 8'd5;
        #1;  // Wait for propagation
        if (sum == 8'd15) begin
            $display("Test 1 PASS: sum=%0d", sum);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", sum);
            fail_count++;
        end

        // Test 2: Difference
        $display("Test 2: Difference");
        if (diff == 8'd5) begin
            $display("Test 2 PASS: diff=%0d", diff);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Bitwise AND
        $display("Test 3: Bitwise AND");
        a = 8'hF0;
        b = 8'h0F;
        #1;
        if (and_result == 8'h00) begin
            $display("Test 3 PASS: and=%h", and_result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Bitwise OR
        $display("Test 4: Bitwise OR");
        if (or_result == 8'hFF) begin
            $display("Test 4 PASS: or=%h", or_result);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Reduction OR
        $display("Test 5: Reduction OR");
        a = 8'h80;
        #1;
        if (bit_result == 1'b1) begin
            $display("Test 5 PASS: |a=%b", bit_result);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Mux select 0
        $display("Test 6: Mux select 0");
        a = 8'd100;
        b = 8'd200;
        sel = 0;
        #1;
        if (mux_out == 8'd200) begin
            $display("Test 6 PASS: mux=%0d (b)", mux_out);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Mux select 1
        $display("Test 7: Mux select 1");
        sel = 1;
        #1;
        if (mux_out == 8'd100) begin
            $display("Test 7 PASS: mux=%0d (a)", mux_out);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Dynamic update
        $display("Test 8: Dynamic update");
        a = 8'd50;
        b = 8'd25;
        #1;
        if (sum == 8'd75 && diff == 8'd25) begin
            $display("Test 8 PASS: sum=%0d, diff=%0d", sum, diff);
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
