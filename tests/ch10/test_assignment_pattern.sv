/*
:name: test_assignment_pattern
:description: Test: Assignment patterns '{...}
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.1 10.9.2 5.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_pattern.expected
*/
// Test: Assignment patterns '{...}

module test_assignment_pattern;
    int pass_count = 0;
    int total_tests = 25;

    // Type definitions
    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
        logic [7:0] c;
    } triple_t;

    typedef struct {
        int x;
        int y;
        string name;
    } point_t;

    typedef struct packed {
        logic [3:0] high;
        logic [3:0] low;
    } nibble_pair_t;

    // Test variables
    triple_t t;
    point_t p;
    nibble_pair_t np;
    int arr[4];
    logic [7:0] byte_arr[3];
    int result;

    // Helper function for Test 12
    function automatic int sum_triple(triple_t val);
        return val.a + val.b + val.c;
    endfunction

    initial begin
        // Test 1: Simple struct assignment pattern
        t = '{8'hAA, 8'hBB, 8'hCC};
        if (t.a == 8'hAA && t.b == 8'hBB && t.c == 8'hCC) begin
            $display("Test 1 PASSED: struct '{0xAA, 0xBB, 0xCC}");
            pass_count++;
        end else $display("Test 1 FAILED");

        // Test 2: Named struct assignment pattern
        t = '{a: 8'h11, b: 8'h22, c: 8'h33};
        if (t.a == 8'h11 && t.b == 8'h22 && t.c == 8'h33) begin
            $display("Test 2 PASSED: struct '{a:0x11, b:0x22, c:0x33}");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: Named pattern out of order
        t = '{c: 8'hFF, a: 8'h00, b: 8'h55};
        if (t.a == 8'h00 && t.b == 8'h55 && t.c == 8'hFF) begin
            $display("Test 3 PASSED: named pattern out of order");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Mixed type struct
        p = '{x: 100, y: 200, name: "point1"};
        if (p.x == 100 && p.y == 200 && p.name == "point1") begin
            $display("Test 4 PASSED: mixed type struct pattern");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Array assignment pattern
        arr = '{10, 20, 30, 40};
        if (arr[0] == 10 && arr[1] == 20 && arr[2] == 30 && arr[3] == 40) begin
            $display("Test 5 PASSED: array '{10, 20, 30, 40}");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Array with replication
        arr = '{4{100}};
        if (arr[0] == 100 && arr[1] == 100 && arr[2] == 100 && arr[3] == 100) begin
            $display("Test 6 PASSED: array '{4{100}}");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: Array with default
        arr = '{default: 0};
        if (arr[0] == 0 && arr[1] == 0 && arr[2] == 0 && arr[3] == 0) begin
            $display("Test 7 PASSED: array '{default: 0}");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: Byte array pattern
        byte_arr = '{8'hDE, 8'hAD, 8'hBE};
        if (byte_arr[0] == 8'hDE && byte_arr[1] == 8'hAD && byte_arr[2] == 8'hBE) begin
            $display("Test 8 PASSED: byte array pattern");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: Nibble pair struct
        np = '{high: 4'hA, low: 4'h5};
        if (np == 8'hA5) begin
            $display("Test 9 PASSED: nibble pair '{high:A, low:5} = 0xA5");
            pass_count++;
        end else $display("Test 9 FAILED: np = %h", np);

        // Test 10: Pattern with expressions
        begin
            static int val = 10;
            arr = '{val, val*2, val*3, val*4};
            if (arr[0] == 10 && arr[1] == 20 && arr[2] == 30 && arr[3] == 40) begin
                $display("Test 10 PASSED: pattern with expressions");
                pass_count++;
            end else $display("Test 10 FAILED");
        end

        // Test 11: Nested struct pattern
        begin
            typedef struct {
                point_t pt;
                int value;
            } nested_t;
            nested_t n;
            n = '{pt: '{x: 5, y: 10, name: "nested"}, value: 42};
            if (n.pt.x == 5 && n.pt.y == 10 && n.value == 42) begin
                $display("Test 11 PASSED: nested struct pattern");
                pass_count++;
            end else $display("Test 11 FAILED");
        end

        // Test 12: Pattern in function call (function moved to module scope)
        result = sum_triple('{8'd10, 8'd20, 8'd30});
        if (result == 60) begin
            $display("Test 12 PASSED: pattern in function arg");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: Pattern with zero values
        t = '{8'h00, 8'h00, 8'h00};
        if (t == 24'h000000) begin
            $display("Test 13 PASSED: all-zero pattern");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Pattern with max values
        t = '{8'hFF, 8'hFF, 8'hFF};
        if (t == 24'hFFFFFF) begin
            $display("Test 14 PASSED: all-ones pattern");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Partial named pattern
        t = '{a: 8'h12, default: 8'h00};
        if (t.a == 8'h12 && t.b == 8'h00 && t.c == 8'h00) begin
            $display("Test 15 PASSED: partial named with default");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Array index pattern
        arr = '{0: 100, 1: 200, 2: 300, 3: 400};
        if (arr[0] == 100 && arr[3] == 400) begin
            $display("Test 16 PASSED: indexed array pattern");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Mixed index and default
        arr = '{0: 999, default: 0};
        if (arr[0] == 999 && arr[1] == 0 && arr[2] == 0 && arr[3] == 0) begin
            $display("Test 17 PASSED: mixed index and default");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: Pattern reassignment
        t = '{8'hAA, 8'hBB, 8'hCC};
        t = '{8'h11, 8'h22, 8'h33};
        if (t.a == 8'h11) begin
            $display("Test 18 PASSED: pattern reassignment");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Pattern in conditional
        begin
            static int flag = 1;
            t = flag ? '{8'hAA, 8'hBB, 8'hCC} : '{8'h11, 8'h22, 8'h33};
            if (t.a == 8'hAA) begin
                $display("Test 19 PASSED: pattern in conditional");
                pass_count++;
            end else $display("Test 19 FAILED");
        end

        // Test 20: Empty array with default
        begin
            int empty_arr[2];
            empty_arr = '{default: -1};
            if (empty_arr[0] == -1 && empty_arr[1] == -1) begin
                $display("Test 20 PASSED: empty array with default");
                pass_count++;
            end else $display("Test 20 FAILED");
        end

        // Test 21: Struct default value
        p = '{default: 0, name: "test"};
        if (p.x == 0 && p.y == 0 && p.name == "test") begin
            $display("Test 21 PASSED: struct with default");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Pattern with explicit type (type cast with pattern needs context)
        begin
            triple_t temp;
            logic [23:0] raw;
            temp = '{8'h12, 8'h34, 8'h56};
            raw = temp;
            if (raw == 24'h123456) begin
                $display("Test 22 PASSED: pattern to raw via struct");
                pass_count++;
            end else $display("Test 22 FAILED");
        end

        // Test 23: Replication in struct context
        t = '{3{8'hAB}};
        if (t.a == 8'hAB && t.b == 8'hAB && t.c == 8'hAB) begin
            $display("Test 23 PASSED: replication in struct");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: Complex nested pattern
        begin
            typedef struct {
                int data[2];
            } data_holder_t;
            data_holder_t dh;
            dh = '{data: '{100, 200}};
            if (dh.data[0] == 100 && dh.data[1] == 200) begin
                $display("Test 24 PASSED: nested array in struct");
                pass_count++;
            end else $display("Test 24 FAILED");
        end

        // Test 25: Pattern comparison
        t = '{8'hAA, 8'hBB, 8'hCC};
        if (t == triple_t'{8'hAA, 8'hBB, 8'hCC}) begin
            $display("Test 25 PASSED: pattern comparison");
            pass_count++;
        end else $display("Test 25 FAILED");

        if (pass_count == total_tests) $display("PASS: assignment_pattern (%0d/%0d)", pass_count, total_tests);
        else $display("FAIL: assignment_pattern (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
