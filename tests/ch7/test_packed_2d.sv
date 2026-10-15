/*
:name: test_packed_2d
:description: 2D packed arrays
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_2d.expected
*/
// 2D packed arrays
module test_packed_2d;
    // Scenario 1: Basic 2D packed array
    logic [1:0][7:0] arr1;

    // Scenario 2: 2D packed array with different dimensions
    logic [3:0][3:0] arr2;

    // Scenario 3: Access individual elements
    logic [2:0][7:0] arr3;

    // Scenario 4: Packed array assignment from flat value
    logic [1:0][15:0] arr4;

    // Scenario 5: Packed array slice
    logic [3:0][7:0] arr5;

    initial begin
        // Test Scenario 1: Basic 2D packed array
        arr1 = 16'hABCD;  // arr1[1]=AB, arr1[0]=CD
        if (arr1[1] !== 8'hAB) begin
            $display("FAIL: Scenario 1 - arr1[1] expected 0xAB, got 0x%h", arr1[1]);
            $finish;
        end
        if (arr1[0] !== 8'hCD) begin
            $display("FAIL: Scenario 1 - arr1[0] expected 0xCD, got 0x%h", arr1[0]);
            $finish;
        end

        // Test Scenario 2: 4x4 bit array
        arr2 = 16'h1234;
        if (arr2[3] !== 4'h1) begin
            $display("FAIL: Scenario 2 - arr2[3] expected 0x1, got 0x%h", arr2[3]);
            $finish;
        end
        if (arr2[0] !== 4'h4) begin
            $display("FAIL: Scenario 2 - arr2[0] expected 0x4, got 0x%h", arr2[0]);
            $finish;
        end

        // Test Scenario 3: Individual element access and modification
        arr3 = 24'h000000;
        arr3[2] = 8'hFF;
        arr3[1] = 8'hAA;
        arr3[0] = 8'h55;
        if (arr3 !== 24'hFFAA55) begin
            $display("FAIL: Scenario 3 - arr3 expected 0xFFAA55, got 0x%h", arr3);
            $finish;
        end

        // Test Scenario 4: 2x16 bit array
        arr4 = 32'h12345678;
        if (arr4[1] !== 16'h1234) begin
            $display("FAIL: Scenario 4 - arr4[1] expected 0x1234, got 0x%h", arr4[1]);
            $finish;
        end
        if (arr4[0] !== 16'h5678) begin
            $display("FAIL: Scenario 4 - arr4[0] expected 0x5678, got 0x%h", arr4[0]);
            $finish;
        end

        // Test Scenario 5: Packed array with slice assignment
        arr5 = 32'hDEADBEEF;
        if (arr5[3] !== 8'hDE) begin
            $display("FAIL: Scenario 5 - arr5[3] expected 0xDE, got 0x%h", arr5[3]);
            $finish;
        end
        if (arr5[2] !== 8'hAD) begin
            $display("FAIL: Scenario 5 - arr5[2] expected 0xAD, got 0x%h", arr5[2]);
            $finish;
        end
        if (arr5[1] !== 8'hBE) begin
            $display("FAIL: Scenario 5 - arr5[1] expected 0xBE, got 0x%h", arr5[1]);
            $finish;
        end
        if (arr5[0] !== 8'hEF) begin
            $display("FAIL: Scenario 5 - arr5[0] expected 0xEF, got 0x%h", arr5[0]);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
