/*
:name: test_shift_edge_cases
:description: Logical and arithmetic shifts, including shifts by 0 and by the width
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_shift_edge_cases.expected
*/
// IEEE 1800-2023 §11.4.10: Shift operator edge cases
// Tests for <<, >>, <<<, >>> operators

module test_shift_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] data;
    logic [15:0] wide;
    logic signed [7:0] sdata;

    initial begin
        // Test 1: Left shift
        test_count++;
        data = 8'h01;
        data = data << 3;
        if (data == 8'h08) begin
            pass_count++;
            $display("Test 1 PASS: 1 << 3 = %h", data);
        end else begin
            $display("Test 1 FAIL: Left shift unexpected = %h", data);
        end

        // Test 2: Right shift
        test_count++;
        data = 8'h80;
        data = data >> 3;
        if (data == 8'h10) begin
            pass_count++;
            $display("Test 2 PASS: 80 >> 3 = %h", data);
        end else begin
            $display("Test 2 FAIL: Right shift unexpected = %h", data);
        end

        // Test 3: Arithmetic right shift
        test_count++;
        sdata = -8;  // 8'hF8
        sdata = sdata >>> 2;
        if (sdata == -2) begin
            pass_count++;
            $display("Test 3 PASS: -8 >>> 2 = %0d", sdata);
        end else begin
            $display("Test 3 FAIL: Arith shift unexpected = %0d", sdata);
        end

        // Test 4: Arithmetic left shift
        test_count++;
        sdata = 4;
        sdata = sdata <<< 2;
        if (sdata == 16) begin
            pass_count++;
            $display("Test 4 PASS: 4 <<< 2 = %0d", sdata);
        end else begin
            $display("Test 4 FAIL: Left arith unexpected = %0d", sdata);
        end

        // Test 5: Shift by 0
        test_count++;
        data = 8'hAB;
        data = data << 0;
        if (data == 8'hAB) begin
            pass_count++;
            $display("Test 5 PASS: x << 0 = %h", data);
        end else begin
            $display("Test 5 FAIL: Zero shift unexpected = %h", data);
        end

        // Test 6: Shift to zero
        test_count++;
        data = 8'hFF;
        data = data << 8;
        if (data == 8'h00) begin
            pass_count++;
            $display("Test 6 PASS: FF << 8 = %h", data);
        end else begin
            $display("Test 6 FAIL: Full shift unexpected = %h", data);
        end

        // Test 7: Shift out and back
        test_count++;
        data = 8'hAA;
        data = data >> 4;
        data = data << 4;
        if (data == 8'hA0) begin
            pass_count++;
            $display("Test 7 PASS: Round trip = %h", data);
        end else begin
            $display("Test 7 FAIL: Round unexpected = %h", data);
        end

        // Test 8: Wide shift
        test_count++;
        wide = 16'h0001;
        wide = wide << 15;
        if (wide == 16'h8000) begin
            pass_count++;
            $display("Test 8 PASS: Wide shift = %h", wide);
        end else begin
            $display("Test 8 FAIL: Wide unexpected = %h", wide);
        end

        // Test 9: Signed negative shift
        test_count++;
        sdata = -1;  // 8'hFF
        sdata = sdata >>> 4;
        if (sdata == -1) begin
            pass_count++;
            $display("Test 9 PASS: -1 >>> 4 = %0d", sdata);
        end else begin
            $display("Test 9 FAIL: Neg arith unexpected = %0d", sdata);
        end

        // Test 10: Variable shift amount
        test_count++;
        begin
            static int shift_amt = 4;
            data = 8'hFF;
            data = data >> shift_amt;
            if (data == 8'h0F) begin
                pass_count++;
                $display("Test 10 PASS: Variable shift = %h", data);
            end else begin
                $display("Test 10 FAIL: Var shift unexpected = %h", data);
            end
        end

        // Test 11: Chain shifts
        test_count++;
        data = 8'h80;
        data = (data >> 4) << 2;
        if (data == 8'h20) begin
            pass_count++;
            $display("Test 11 PASS: Chain = %h", data);
        end else begin
            $display("Test 11 FAIL: Chain unexpected = %h", data);
        end

        // Test 12: One bit shift
        test_count++;
        data = 8'hFE;
        data = data << 1;
        if (data == 8'hFC) begin
            pass_count++;
            $display("Test 12 PASS: << 1 = %h", data);
        end else begin
            $display("Test 12 FAIL: << 1 unexpected = %h", data);
        end

        $display("=== Shift Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
