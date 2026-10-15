/*
:name: test_structs_edge_cases
:description: Test: Structs edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 10.9.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_structs_edge_cases.expected
*/
// Test: Structs edge cases
// IEEE 1800-2023 Section 7.2 Structures
// Tests corner cases: packed, unpacked, nested, initialization

`timescale 1ns/1ps

module test_structs_edge_cases;
    int passed = 0;
    int failed = 0;

    typedef struct {
        int x;
        int y;
    } point_t;

    typedef struct packed {
        logic [7:0] r;
        logic [7:0] g;
        logic [7:0] b;
    } rgb_t;

    typedef struct {
        string name;
        int age;
        point_t location;
    } person_t;

    initial begin
        $display("TEST: Structs edge cases");

        // Test 1: Basic struct member access
        begin
            point_t p;
            p.x = 10;
            p.y = 20;
            if (p.x == 10 && p.y == 20) begin
                $display("  [PASS] Basic struct member access");
                passed++;
            end else begin
                $display("  [FAIL] Member access");
                failed++;
            end
        end

        // Test 2: Struct literal initialization
        begin
            static point_t p = '{100, 200};
            if (p.x == 100 && p.y == 200) begin
                $display("  [PASS] Struct literal init");
                passed++;
            end else begin
                $display("  [FAIL] Literal init");
                failed++;
            end
        end

        // Test 3: Named member initialization
        begin
            static point_t p;
            // Assigned here so the result does not depend on the order of static initializers.
            p = '{y: 50, x: 25};
            if (p.x == 25 && p.y == 50) begin
                $display("  [PASS] Named member init");
                passed++;
            end else begin
                $display("  [FAIL] Named init");
                failed++;
            end
        end

        // Test 4: Packed struct as bit vector
        begin
            rgb_t color;
            color.r = 8'hFF;
            color.g = 8'h00;
            color.b = 8'hAA;
            if ($bits(color) == 24) begin
                $display("  [PASS] Packed struct size");
                passed++;
            end else begin
                $display("  [FAIL] Size: %0d", $bits(color));
                failed++;
            end
        end

        // Test 5: Packed struct assignment from bits
        begin
            static rgb_t color = 24'hAABBCC;
            if (color.r == 8'hAA && color.g == 8'hBB && color.b == 8'hCC) begin
                $display("  [PASS] Packed struct from bits");
                passed++;
            end else begin
                $display("  [FAIL] From bits: r=%h g=%h b=%h", color.r, color.g, color.b);
                failed++;
            end
        end

        // Test 6: Nested struct
        begin
            person_t person;
            person.name = "Alice";
            person.age = 30;
            person.location.x = 100;
            person.location.y = 200;
            if (person.location.x == 100) begin
                $display("  [PASS] Nested struct access");
                passed++;
            end else begin
                $display("  [FAIL] Nested access");
                failed++;
            end
        end

        // Test 7: Struct member modification
        begin
            point_t p1;
            p1.x = 10;
            p1.y = 20;
            p1.x = 30;  // Modify
            if (p1.x == 30 && p1.y == 20) begin
                $display("  [PASS] Struct member modification");
                passed++;
            end else begin
                $display("  [FAIL] Modification");
                failed++;
            end
        end

        // Test 8: Struct member sum
        begin
            static point_t p = '{5, 10};
            static int total;
            // Assigned here so the result does not depend on the order of static initializers.
            total = p.x + p.y;
            if (total == 15) begin
                $display("  [PASS] Struct member sum");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", total);
                failed++;
            end
        end

        // Test 9: Struct reassignment
        begin
            point_t p;
            p = '{1, 1};
            p = '{3, 3};
            if (p.x == 3 && p.y == 3) begin
                $display("  [PASS] Struct reassignment");
                passed++;
            end else begin
                $display("  [FAIL] Reassignment");
                failed++;
            end
        end

        // Test 10: Struct in function
        begin
            static point_t p = '{7, 8};
            static int sum;
            // Assigned here so the result does not depend on the order of static initializers.
            sum = p.x + p.y;
            if (sum == 15) begin
                $display("  [PASS] Struct member arithmetic");
                passed++;
            end else begin
                $display("  [FAIL] Arithmetic: %0d", sum);
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
