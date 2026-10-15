/*
:name: test_mixed_packed
:description: Mixed packed/unpacked arrays
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.4.2 7.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mixed_packed.expected
*/
// Mixed packed/unpacked arrays
module test_mixed_packed;
    // Scenario 1: Unpacked array of packed elements
    logic [7:0] arr1 [0:3];

    // Scenario 2: Unpacked 2D array of packed elements
    logic [15:0] arr2 [0:1][0:1];

    // Scenario 3: 2D packed with unpacked dimension
    logic [1:0][7:0] arr3 [0:1];

    // Scenario 4: Complex mixed array
    logic [3:0][3:0] arr4 [0:1][0:1];

    // Scenario 5: Mixed array with bit selection
    logic [1:0][7:0] arr5 [0:2];

    initial begin
        // Test Scenario 1: Unpacked of packed
        arr1[0] = 8'hAA;
        arr1[1] = 8'hBB;
        arr1[2] = 8'hCC;
        arr1[3] = 8'hDD;
        if (arr1[0] !== 8'hAA) begin
            $display("FAIL: Scenario 1 - arr1[0] expected 0xAA, got 0x%h", arr1[0]);
            $finish;
        end
        if (arr1[3] !== 8'hDD) begin
            $display("FAIL: Scenario 1 - arr1[3] expected 0xDD, got 0x%h", arr1[3]);
            $finish;
        end

        // Test Scenario 2: 2D unpacked of 16-bit packed
        arr2[0][0] = 16'h1234;
        arr2[0][1] = 16'h5678;
        arr2[1][0] = 16'h9ABC;
        arr2[1][1] = 16'hDEF0;
        if (arr2[0][0] !== 16'h1234) begin
            $display("FAIL: Scenario 2 - arr2[0][0] expected 0x1234, got 0x%h", arr2[0][0]);
            $finish;
        end
        if (arr2[1][1] !== 16'hDEF0) begin
            $display("FAIL: Scenario 2 - arr2[1][1] expected 0xDEF0, got 0x%h", arr2[1][1]);
            $finish;
        end

        // Test Scenario 3: 2D packed [1:0][7:0] with unpacked [0:1]
        arr3[0] = 16'hAABB;  // arr3[0][1]=AA, arr3[0][0]=BB
        arr3[1] = 16'hCCDD;  // arr3[1][1]=CC, arr3[1][0]=DD
        if (arr3[0][1] !== 8'hAA) begin
            $display("FAIL: Scenario 3 - arr3[0][1] expected 0xAA, got 0x%h", arr3[0][1]);
            $finish;
        end
        if (arr3[1][0] !== 8'hDD) begin
            $display("FAIL: Scenario 3 - arr3[1][0] expected 0xDD, got 0x%h", arr3[1][0]);
            $finish;
        end

        // Test Scenario 4: [3:0][3:0] packed (16 bits) with [0:1][0:1] unpacked
        arr4[0][0] = 16'h1111;
        arr4[0][1] = 16'h2222;
        arr4[1][0] = 16'h3333;
        arr4[1][1] = 16'h4444;
        if (arr4[0][0] !== 16'h1111) begin
            $display("FAIL: Scenario 4 - arr4[0][0] expected 0x1111, got 0x%h", arr4[0][0]);
            $finish;
        end
        // Access packed dimension
        if (arr4[1][1][3] !== 4'h4) begin
            $display("FAIL: Scenario 4 - arr4[1][1][3] expected 0x4, got 0x%h", arr4[1][1][3]);
            $finish;
        end

        // Test Scenario 5: Bit selection through mixed array
        arr5[0] = 16'h0102;  // [0][1]=01, [0][0]=02
        arr5[1] = 16'h0304;  // [1][1]=03, [1][0]=04
        arr5[2] = 16'h0506;  // [2][1]=05, [2][0]=06

        if (arr5[0][0] !== 8'h02) begin
            $display("FAIL: Scenario 5 - arr5[0][0] expected 0x02, got 0x%h", arr5[0][0]);
            $finish;
        end
        if (arr5[2][1] !== 8'h05) begin
            $display("FAIL: Scenario 5 - arr5[2][1] expected 0x05, got 0x%h", arr5[2][1]);
            $finish;
        end
        // Bit select from packed element
        if (arr5[1][0][2] !== 1'b1) begin
            $display("FAIL: Scenario 5 - arr5[1][0][2] expected 1, got %b", arr5[1][0][2]);
            $finish;
        end

        $display("PASS");
        $finish;
    end
endmodule
