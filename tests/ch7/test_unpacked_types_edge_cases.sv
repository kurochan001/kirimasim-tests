/*
:name: test_unpacked_types_edge_cases
:description: Test: Unpacked types edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 7.4.2 7.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_types_edge_cases.expected
*/
// Test: Unpacked types edge cases
// IEEE 1800-2023 Section 7.4 Unpacked Arrays
// Tests corner cases: multi-dimensional, mixed packed/unpacked, struct arrays

`timescale 1ns/1ps

module test_unpacked_types_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Unpacked types edge cases");

        // Test 1: 3D unpacked array
        begin
            int arr3d[2][3][4];
            arr3d[0][0][0] = 1;
            arr3d[1][2][3] = 999;
            if (arr3d[0][0][0] == 1 && arr3d[1][2][3] == 999) begin
                $display("  [PASS] 3D unpacked array works");
                passed++;
            end else begin
                $display("  [FAIL] 3D array access failed");
                failed++;
            end
        end

        // Test 2: Unpacked array of packed values
        begin
            logic [7:0] packed_arr[4];
            packed_arr[0] = 8'hAA;
            packed_arr[3] = 8'hBB;
            if (packed_arr[0] == 8'hAA && packed_arr[3] == 8'hBB) begin
                $display("  [PASS] Unpacked array of packed values");
                passed++;
            end else begin
                $display("  [FAIL] Packed value array failed");
                failed++;
            end
        end

        // Test 3: Unpacked struct
        begin
            typedef struct {
                int x;
                int y;
                string name;
            } point_t;
            point_t pt;
            pt.x = 100;
            pt.y = 200;
            pt.name = "origin";
            if (pt.x == 100 && pt.y == 200) begin
                $display("  [PASS] Unpacked struct works");
                passed++;
            end else begin
                $display("  [FAIL] Unpacked struct failed");
                failed++;
            end
        end

        // Test 4: Array of unpacked structs
        begin
            typedef struct {
                int a;
                int b;
            } pair_t;
            pair_t pairs[3];
            pairs[0].a = 1;
            pairs[0].b = 2;
            pairs[2].a = 5;
            pairs[2].b = 6;
            if (pairs[0].a == 1 && pairs[2].b == 6) begin
                $display("  [PASS] Array of unpacked structs");
                passed++;
            end else begin
                $display("  [FAIL] Struct array failed");
                failed++;
            end
        end

        // Test 5: Unpacked array copy
        begin
            static int src[4] = '{10, 20, 30, 40};
            int dst[4];
            dst = src;
            if (dst[0] == 10 && dst[3] == 40) begin
                $display("  [PASS] Unpacked array copy");
                passed++;
            end else begin
                $display("  [FAIL] Array copy failed");
                failed++;
            end
        end

        // Test 6: Unpacked array literal
        begin
            static int arr[4] = '{1, 2, 3, 4};
            if (arr[0] == 1 && arr[3] == 4) begin
                $display("  [PASS] Unpacked array literal");
                passed++;
            end else begin
                $display("  [FAIL] Array literal failed");
                failed++;
            end
        end

        // Test 7: Mixed dimensions
        begin
            logic [3:0] mixed[2][3];  // Unpacked [2][3], packed [3:0]
            mixed[0][0] = 4'hA;
            mixed[1][2] = 4'hF;
            if (mixed[0][0] == 4'hA && mixed[1][2] == 4'hF) begin
                $display("  [PASS] Mixed packed/unpacked dimensions");
                passed++;
            end else begin
                $display("  [FAIL] Mixed dimensions failed");
                failed++;
            end
        end

        // Test 8: Array bounds
        begin
            int bounded[1:4];  // 1 to 4 instead of 0 to 3
            bounded[1] = 100;
            bounded[4] = 400;
            if (bounded[1] == 100 && bounded[4] == 400) begin
                $display("  [PASS] Non-zero based array bounds");
                passed++;
            end else begin
                $display("  [FAIL] Bounded array failed");
                failed++;
            end
        end

        // Test 9: Struct with array member
        begin
            typedef struct {
                int data[4];
                int count;
            } container_t;
            container_t c;
            c.data[0] = 10;
            c.data[3] = 40;
            c.count = 4;
            if (c.data[0] == 10 && c.count == 4) begin
                $display("  [PASS] Struct with array member");
                passed++;
            end else begin
                $display("  [FAIL] Struct array member failed");
                failed++;
            end
        end

        // Test 10: Nested struct
        begin
            typedef struct {
                int x, y;
            } point_t;
            typedef struct {
                point_t start;
                point_t finish;
            } line_t;
            line_t line;
            line.start.x = 0;
            line.start.y = 0;
            line.finish.x = 100;
            line.finish.y = 100;
            if (line.start.x == 0 && line.finish.x == 100) begin
                $display("  [PASS] Nested unpacked struct");
                passed++;
            end else begin
                $display("  [FAIL] Nested struct failed");
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
