/*
:name: test_assignment_patterns
:description: Tests positional, named, default and replicated assignment patterns for arrays and structs
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.1 10.9.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_patterns.expected
*/
// Tests positional, named, default and replicated assignment patterns for arrays and structs
`timescale 1ns/1ps

module test_assignment_patterns;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Array assignment pattern
    task test_array_pattern();
        int arr[4];

        arr = '{1, 2, 3, 4};

        if (arr[0] == 1 && arr[1] == 2 && arr[2] == 3 && arr[3] == 4) begin
            $display("PASS: Array assignment pattern works");
            pass_count++;
        end else begin
            $display("FAIL: Array pattern failed");
            fail_count++;
        end
    endtask

    // Test 2: Struct assignment pattern
    typedef struct {
        int x;
        int y;
        int z;
    } point_t;

    task test_struct_pattern();
        point_t p;

        p = '{x: 10, y: 20, z: 30};

        if (p.x == 10 && p.y == 20 && p.z == 30) begin
            $display("PASS: Struct assignment pattern works");
            pass_count++;
        end else begin
            $display("FAIL: Struct pattern failed");
            fail_count++;
        end
    endtask

    // Test 3: Positional struct pattern
    task test_positional_struct();
        point_t p;

        p = '{100, 200, 300};

        if (p.x == 100 && p.y == 200 && p.z == 300) begin
            $display("PASS: Positional struct pattern works");
            pass_count++;
        end else begin
            $display("FAIL: Positional struct failed");
            fail_count++;
        end
    endtask

    // Test 4: Default value in array
    task test_array_default();
        int arr[10];

        arr = '{default: 42};

        if (arr[0] == 42 && arr[5] == 42 && arr[9] == 42) begin
            $display("PASS: Array default pattern works");
            pass_count++;
        end else begin
            $display("FAIL: Array default failed");
            fail_count++;
        end
    endtask

    // Test 5: Partial override with default
    task test_partial_override();
        int arr[5];

        arr = '{0: 100, 2: 200, default: 0};

        if (arr[0] == 100 && arr[1] == 0 && arr[2] == 200 && arr[3] == 0) begin
            $display("PASS: Partial override with default works");
            pass_count++;
        end else begin
            $display("FAIL: Partial override (arr[0]=%0d, arr[2]=%0d)", arr[0], arr[2]);
            fail_count++;
        end
    endtask

    // Test 6: Packed struct pattern
    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
    } packed_pair_t;

    task test_packed_struct_pattern();
        packed_pair_t pp;

        pp = '{a: 8'hAA, b: 8'hBB};

        if (pp.a == 8'hAA && pp.b == 8'hBB) begin
            $display("PASS: Packed struct pattern works");
            pass_count++;
        end else begin
            $display("FAIL: Packed struct pattern failed");
            fail_count++;
        end
    endtask

    // Test 7: Nested struct pattern
    typedef struct {
        point_t origin;
        point_t size;
    } rect_t;

    task test_nested_struct_pattern();
        rect_t r;

        r = '{origin: '{x: 0, y: 0, z: 0}, size: '{x: 100, y: 50, z: 25}};

        if (r.origin.x == 0 && r.size.x == 100 && r.size.y == 50) begin
            $display("PASS: Nested struct pattern works");
            pass_count++;
        end else begin
            $display("FAIL: Nested struct pattern failed");
            fail_count++;
        end
    endtask

    // Test 8: Array of structs pattern
    task test_array_of_structs();
        point_t points[3];

        points = '{
            '{x: 1, y: 1, z: 1},
            '{x: 2, y: 2, z: 2},
            '{x: 3, y: 3, z: 3}
        };

        if (points[0].x == 1 && points[1].x == 2 && points[2].x == 3) begin
            $display("PASS: Array of structs pattern works");
            pass_count++;
        end else begin
            $display("FAIL: Array of structs failed");
            fail_count++;
        end
    endtask

    // Test 9: Replication in pattern
    task test_replication_pattern();
        logic [7:0] arr[8];

        arr = '{8{8'hAA}};

        if (arr[0] == 8'hAA && arr[7] == 8'hAA) begin
            $display("PASS: Replication in pattern works");
            pass_count++;
        end else begin
            $display("FAIL: Replication pattern (arr[0]=%h)", arr[0]);
            fail_count++;
        end
    endtask

    // Test 10: Mixed named and default
    typedef struct {
        int a;
        int b;
        int c;
        int d;
    } quad_t;

    task test_mixed_pattern();
        quad_t q;

        q = '{a: 100, default: 0};

        if (q.a == 100 && q.b == 0 && q.c == 0 && q.d == 0) begin
            $display("PASS: Mixed named and default works");
            pass_count++;
        end else begin
            $display("FAIL: Mixed pattern (a=%0d, b=%0d)", q.a, q.b);
            fail_count++;
        end
    endtask

    // Test 11: Dynamic array pattern
    task test_dynamic_array_pattern();
        int dyn[];

        dyn = new[4];
        dyn = '{10, 20, 30, 40};

        if (dyn[0] == 10 && dyn[3] == 40) begin
            $display("PASS: Dynamic array pattern works");
            pass_count++;
        end else begin
            $display("FAIL: Dynamic array pattern failed");
            fail_count++;
        end
    endtask

    // Test 12: 2D array pattern
    task test_2d_array_pattern();
        int matrix[2][3];

        matrix = '{'{1, 2, 3}, '{4, 5, 6}};

        if (matrix[0][0] == 1 && matrix[1][2] == 6) begin
            $display("PASS: 2D array pattern works");
            pass_count++;
        end else begin
            $display("FAIL: 2D pattern (m[0][0]=%0d, m[1][2]=%0d)", matrix[0][0], matrix[1][2]);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Assignment Patterns Corner Cases Test ===");

        test_array_pattern();
        test_struct_pattern();
        test_positional_struct();
        test_array_default();
        test_partial_override();
        test_packed_struct_pattern();
        test_nested_struct_pattern();
        test_array_of_structs();
        test_replication_pattern();
        test_mixed_pattern();
        test_dynamic_array_pattern();
        test_2d_array_pattern();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
