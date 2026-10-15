/*
:name: test_packed_3d
:description: 3D packed arrays
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_3d.expected
*/
// 3D packed arrays
module test_packed_3d;
    // Scenario 1: Basic 3D packed array
    logic [1:0][1:0][7:0] arr1;

    // Scenario 2: Access 2D slice from 3D
    logic [1:0][1:0][3:0] arr2;

    // Scenario 3: Individual element access
    logic [1:0][2:0][7:0] arr3;

    // Scenario 4: 3D packed array modification
    logic [1:0][1:0][7:0] arr4;

    // Scenario 5: Mixed dimension sizes
    logic [2:0][1:0][3:0] arr5;

    initial begin
        // Test Scenario 1: Basic 3D packed array (2x2x8 = 32 bits)
        arr1 = 32'hAABBCCDD;
        // arr1[1][1] = AA, arr1[1][0] = BB, arr1[0][1] = CC, arr1[0][0] = DD
        if (arr1[1][1] !== 8'hAA) begin
            $display("FAIL: Scenario 1 - arr1[1][1] expected 0xAA, got 0x%h", arr1[1][1]);
            $finish;
        end
        if (arr1[0][0] !== 8'hDD) begin
            $display("FAIL: Scenario 1 - arr1[0][0] expected 0xDD, got 0x%h", arr1[0][0]);
            $finish;
        end

        // Test Scenario 2: Access 2D slice (2x2x4 = 16 bits)
        arr2 = 16'h1234;
        // arr2[1] = 12 (8 bits), arr2[0] = 34 (8 bits)
        if (arr2[1] !== 8'h12) begin
            $display("FAIL: Scenario 2 - arr2[1] expected 0x12, got 0x%h", arr2[1]);
            $finish;
        end
        if (arr2[1][1] !== 4'h1) begin
            $display("FAIL: Scenario 2 - arr2[1][1] expected 0x1, got 0x%h", arr2[1][1]);
            $finish;
        end
        if (arr2[1][0] !== 4'h2) begin
            $display("FAIL: Scenario 2 - arr2[1][0] expected 0x2, got 0x%h", arr2[1][0]);
            $finish;
        end

        // Test Scenario 3: Individual element write (2x3x8 = 48 bits)
        arr3 = 48'h000000000000;
        arr3[1][2] = 8'hAA;
        arr3[1][1] = 8'hBB;
        arr3[1][0] = 8'hCC;
        arr3[0][2] = 8'hDD;
        arr3[0][1] = 8'hEE;
        arr3[0][0] = 8'hFF;
        if (arr3 !== 48'hAABBCCDDEEFF) begin
            $display("FAIL: Scenario 3 - arr3 expected 0xAABBCCDDEEFF, got 0x%h", arr3);
            $finish;
        end

        // Test Scenario 4: Modify specific element
        arr4 = 32'h00000000;
        arr4[0][1] = 8'hFF;
        if (arr4[0][1] !== 8'hFF) begin
            $display("FAIL: Scenario 4 - arr4[0][1] expected 0xFF, got 0x%h", arr4[0][1]);
            $finish;
        end
        if (arr4[1][1] !== 8'h00) begin
            $display("FAIL: Scenario 4 - arr4[1][1] expected 0x00, got 0x%h", arr4[1][1]);
            $finish;
        end

        // Test Scenario 5: Mixed dimension (3x2x4 = 24 bits)
        arr5 = 24'hABCDEF;
        // arr5[2] = AB (8 bits), arr5[1] = CD (8 bits), arr5[0] = EF (8 bits)
        if (arr5[2][1] !== 4'hA) begin
            $display("FAIL: Scenario 5 - arr5[2][1] expected 0xA, got 0x%h", arr5[2][1]);
            $finish;
        end
        if (arr5[2][0] !== 4'hB) begin
            $display("FAIL: Scenario 5 - arr5[2][0] expected 0xB, got 0x%h", arr5[2][0]);
            $finish;
        end
        if (arr5[0][0] !== 4'hF) begin
            $display("FAIL: Scenario 5 - arr5[0][0] expected 0xF, got 0x%h", arr5[0][0]);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
