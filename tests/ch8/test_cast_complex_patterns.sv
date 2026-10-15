/*
:name: test_cast_complex_patterns
:description: $cast with complex nested patterns
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2 7.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_complex_patterns.expected
*/
// IEEE 1800-2023 §6.24.2: $cast with complex nested patterns
// Tests: 3D+ arrays, member+array combinations, nested structures
`timescale 1ns/1ps

class Base;
    int value;
    function new(int v = 0);
        value = v;
    endfunction
endclass

class Derived extends Base;
    int extra;
    function new(int v = 0, int e = 0);
        super.new(v);
        extra = e;
    endfunction
endclass

class Container;
    Base items[];         // Dynamic array of Base
    Base matrix[][];      // 2D dynamic array
    Base cube[][][];      // 3D dynamic array

    function new();
        items = new[3];
        matrix = new[2];
        matrix[0] = new[2];
        matrix[1] = new[2];
        cube = new[2];
        cube[0] = new[2];
        cube[0][0] = new[2];
        cube[0][1] = new[2];
        cube[1] = new[2];
        cube[1][0] = new[2];
        cube[1][1] = new[2];
    endfunction
endclass

module test_cast_complex_patterns;
    int pass_count = 0;
    int fail_count = 0;

    Container cont;
    Base arr[];
    Base matrix[][];
    Base cube[][][];
    Derived d;

    initial begin
        cont = new();
        arr = new[3];
        matrix = new[2];
        matrix[0] = new[2];
        matrix[1] = new[2];
        cube = new[2];
        cube[0] = new[2];
        cube[0][0] = new[2];
        cube[0][1] = new[2];
        cube[1] = new[2];
        cube[1][0] = new[2];
        cube[1][1] = new[2];

        // Test 1: Simple 1D array $cast (baseline)
        d = new(10, 20);
        if ($cast(arr[0], d)) begin
            if (arr[0].value == 10) begin
                $display("PASS: Test 1 - $cast(arr[0], d)");
                pass_count++;
            end else begin
                $display("FAIL: Test 1 - value mismatch: got %0d", arr[0].value);
                fail_count++;
            end
        end else begin
            $display("FAIL: Test 1 - $cast returned false");
            fail_count++;
        end

        // Test 2: 2D array $cast (arr[i][j])
        d = new(21, 22);
        if ($cast(matrix[1][0], d)) begin
            if (matrix[1][0].value == 21) begin
                $display("PASS: Test 2 - $cast(matrix[1][0], d)");
                pass_count++;
            end else begin
                $display("FAIL: Test 2 - value mismatch: got %0d", matrix[1][0].value);
                fail_count++;
            end
        end else begin
            $display("FAIL: Test 2 - $cast returned false");
            fail_count++;
        end

        // Test 3: 3D array $cast (arr[i][j][k])
        d = new(31, 32);
        if ($cast(cube[1][0][1], d)) begin
            if (cube[1][0][1].value == 31) begin
                $display("PASS: Test 3 - $cast(cube[1][0][1], d)");
                pass_count++;
            end else begin
                $display("FAIL: Test 3 - value mismatch: got %0d", cube[1][0][1].value);
                fail_count++;
            end
        end else begin
            $display("FAIL: Test 3 - $cast returned false");
            fail_count++;
        end

        // Test 4: Member access + 1D array (obj.arr[i])
        d = new(41, 42);
        if ($cast(cont.items[1], d)) begin
            if (cont.items[1].value == 41) begin
                $display("PASS: Test 4 - $cast(cont.items[1], d)");
                pass_count++;
            end else begin
                $display("FAIL: Test 4 - value mismatch: got %0d", cont.items[1].value);
                fail_count++;
            end
        end else begin
            $display("FAIL: Test 4 - $cast returned false");
            fail_count++;
        end

        // Test 5: Member access + 2D array (obj.arr[i][j])
        d = new(51, 52);
        if ($cast(cont.matrix[0][1], d)) begin
            if (cont.matrix[0][1].value == 51) begin
                $display("PASS: Test 5 - $cast(cont.matrix[0][1], d)");
                pass_count++;
            end else begin
                $display("FAIL: Test 5 - value mismatch: got %0d", cont.matrix[0][1].value);
                fail_count++;
            end
        end else begin
            $display("FAIL: Test 5 - $cast returned false");
            fail_count++;
        end

        // Test 6: Member access + 3D array (obj.arr[i][j][k])
        d = new(61, 62);
        if ($cast(cont.cube[1][1][0], d)) begin
            if (cont.cube[1][1][0].value == 61) begin
                $display("PASS: Test 6 - $cast(cont.cube[1][1][0], d)");
                pass_count++;
            end else begin
                $display("FAIL: Test 6 - value mismatch: got %0d", cont.cube[1][1][0].value);
                fail_count++;
            end
        end else begin
            $display("FAIL: Test 6 - $cast returned false");
            fail_count++;
        end

        // Summary
        if (fail_count == 0)
            $display("ALL TESTS PASSED (%0d tests)", pass_count);
        else
            $display("FAILED: %0d of %0d tests failed", fail_count, pass_count + fail_count);

        $finish;
    end
endmodule
