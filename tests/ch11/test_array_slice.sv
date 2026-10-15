/*
:name: test_array_slice
:description: Array slice operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_slice.expected
*/
// Array slice operations
module test_array_slice;
    // Scenario 1: Part select on packed array
    logic [31:0] arr1;

    // Scenario 2: Indexed part select +: (ascending)
    logic [31:0] arr2;

    // Scenario 3: Indexed part select -: (descending)
    logic [31:0] arr3;

    // Scenario 4: Part select on 2D packed array
    logic [3:0][7:0] arr4;

    // Scenario 5: Multiple slice operations
    logic [63:0] arr5;
    logic [7:0] slice_result;

    int idx;

    initial begin
        // Test Scenario 1: Basic part select
        arr1 = 32'hDEADBEEF;
        if (arr1[31:24] !== 8'hDE) begin
            $display("FAIL: Scenario 1 - arr1[31:24] expected 0xDE, got 0x%h", arr1[31:24]);
            $finish;
        end
        if (arr1[7:0] !== 8'hEF) begin
            $display("FAIL: Scenario 1 - arr1[7:0] expected 0xEF, got 0x%h", arr1[7:0]);
            $finish;
        end
        if (arr1[15:8] !== 8'hBE) begin
            $display("FAIL: Scenario 1 - arr1[15:8] expected 0xBE, got 0x%h", arr1[15:8]);
            $finish;
        end

        // Test Scenario 2: Indexed part select +: (base +: width)
        arr2 = 32'h12345678;
        idx = 8;
        if (arr2[idx +: 8] !== 8'h56) begin
            $display("FAIL: Scenario 2 - arr2[8+:8] expected 0x56, got 0x%h", arr2[idx +: 8]);
            $finish;
        end
        idx = 16;
        if (arr2[idx +: 8] !== 8'h34) begin
            $display("FAIL: Scenario 2 - arr2[16+:8] expected 0x34, got 0x%h", arr2[idx +: 8]);
            $finish;
        end
        idx = 0;
        if (arr2[idx +: 16] !== 16'h5678) begin
            $display("FAIL: Scenario 2 - arr2[0+:16] expected 0x5678, got 0x%h", arr2[idx +: 16]);
            $finish;
        end

        // Test Scenario 3: Indexed part select -: (base -: width)
        arr3 = 32'hAABBCCDD;
        idx = 31;
        if (arr3[idx -: 8] !== 8'hAA) begin
            $display("FAIL: Scenario 3 - arr3[31-:8] expected 0xAA, got 0x%h", arr3[idx -: 8]);
            $finish;
        end
        idx = 15;
        if (arr3[idx -: 8] !== 8'hCC) begin
            $display("FAIL: Scenario 3 - arr3[15-:8] expected 0xCC, got 0x%h", arr3[idx -: 8]);
            $finish;
        end
        idx = 7;
        if (arr3[idx -: 8] !== 8'hDD) begin
            $display("FAIL: Scenario 3 - arr3[7-:8] expected 0xDD, got 0x%h", arr3[idx -: 8]);
            $finish;
        end

        // Test Scenario 4: Part select on 2D packed [3:0][7:0] = 32 bits
        arr4 = 32'hCAFEBABE;
        // arr4[3]=CA, arr4[2]=FE, arr4[1]=BA, arr4[0]=BE
        if (arr4[3][7:4] !== 4'hC) begin
            $display("FAIL: Scenario 4 - arr4[3][7:4] expected 0xC, got 0x%h", arr4[3][7:4]);
            $finish;
        end
        if (arr4[0][3:0] !== 4'hE) begin
            $display("FAIL: Scenario 4 - arr4[0][3:0] expected 0xE, got 0x%h", arr4[0][3:0]);
            $finish;
        end

        // Test Scenario 5: Multiple slices and assignment
        arr5 = 64'h0123456789ABCDEF;
        slice_result = arr5[39:32];  // 0x67
        if (slice_result !== 8'h67) begin
            $display("FAIL: Scenario 5 - arr5[39:32] expected 0x67, got 0x%h", slice_result);
            $finish;
        end

        // Slice assignment
        arr5[31:24] = 8'hFF;
        if (arr5[31:24] !== 8'hFF) begin
            $display("FAIL: Scenario 5 - arr5[31:24] after assign expected 0xFF, got 0x%h", arr5[31:24]);
            $finish;
        end

        // Indexed slice assignment
        idx = 8;
        arr5[idx +: 8] = 8'h00;
        if (arr5[15:8] !== 8'h00) begin
            $display("FAIL: Scenario 5 - arr5[15:8] after indexed assign expected 0x00, got 0x%h", arr5[15:8]);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
