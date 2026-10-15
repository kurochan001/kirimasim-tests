/*
:name: test_packed_array_element_width
:description: Packed array element width test
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_array_element_width.expected
*/
// IEEE 1800-2023 §7.4: Packed array element width test
// Tests that packed arrays with different element widths (8, 16, 32 bits) work correctly

module test_packed_array_element_width;
    // Test 1: 8-bit elements (common case)
    logic [3:0][7:0] arr8;   // 4 elements x 8 bits = 32 bits total

    // Test 2: 16-bit elements
    logic [1:0][15:0] arr16;  // 2 elements x 16 bits = 32 bits total

    // Test 3: 32-bit elements
    logic [1:0][31:0] arr32;  // 2 elements x 32 bits = 64 bits total

    // Test 4: 4-bit elements
    logic [7:0][3:0] arr4;    // 8 elements x 4 bits = 32 bits total

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: 8-bit element array
        arr8 = 32'h0;
        arr8[0] = 8'hAB;
        arr8[1] = 8'hCD;
        arr8[2] = 8'hEF;
        arr8[3] = 8'h12;
        if (arr8 == 32'h12EFCDAB) begin
            $display("PASS: 8-bit element array");
            pass_count++;
        end else begin
            $display("FAIL: 8-bit element array - expected 32'h12EFCDAB, got %h", arr8);
            fail_count++;
        end

        // Test 2: 16-bit element array
        arr16 = 32'h0;
        arr16[0] = 16'hCAFE;
        arr16[1] = 16'hBEEF;
        if (arr16 == 32'hBEEFCAFE) begin
            $display("PASS: 16-bit element array");
            pass_count++;
        end else begin
            $display("FAIL: 16-bit element array - expected 32'hBEEFCAFE, got %h", arr16);
            fail_count++;
        end

        // Test 3: 32-bit element array
        arr32 = 64'h0;
        arr32[0] = 32'hDEADBEEF;
        arr32[1] = 32'hCAFEBABE;
        if (arr32 == 64'hCAFEBABEDEADBEEF) begin
            $display("PASS: 32-bit element array");
            pass_count++;
        end else begin
            $display("FAIL: 32-bit element array - expected 64'hCAFEBABEDEADBEEF, got %h", arr32);
            fail_count++;
        end

        // Test 4: 4-bit element array
        arr4 = 32'h0;
        arr4[0] = 4'hA;
        arr4[1] = 4'hB;
        arr4[2] = 4'hC;
        arr4[3] = 4'hD;
        arr4[4] = 4'hE;
        arr4[5] = 4'hF;
        arr4[6] = 4'h1;
        arr4[7] = 4'h2;
        if (arr4 == 32'h21FEDCBA) begin
            $display("PASS: 4-bit element array");
            pass_count++;
        end else begin
            $display("FAIL: 4-bit element array - expected 32'h21FEDCBA, got %h", arr4);
            fail_count++;
        end

        // Test 5: Read-modify-write for 16-bit
        arr16 = 32'h0;
        arr16[0] = 16'h1234;
        arr16[0] = arr16[0] + 16'h1;
        if (arr16[0] == 16'h1235) begin
            $display("PASS: 16-bit read-modify-write");
            pass_count++;
        end else begin
            $display("FAIL: 16-bit read-modify-write - expected 16'h1235, got %h", arr16[0]);
            fail_count++;
        end

        // Summary
        $display("");
        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
