/*
:name: test_member_access_3
:description: Test: Struct/class member access
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 8.4 8.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access_3.expected
*/
// Test: Struct/class member access

module test_member_access_3;
    int pass_count = 0;
    int total_tests = 25;

    // Struct definitions
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

    // Class definition
    class SimpleClass;
        int value;
        string label;

        function new(int v, string l);
            value = v;
            label = l;
        endfunction

        function int get_value();
            return value;
        endfunction
    endclass

    // Test variables
    point_t pt;
    rgb_t color;
    person_t person;
    SimpleClass obj;

    // Helper function for Test 21
    function automatic int double_val(int v);
        return v * 2;
    endfunction

    initial begin
        // Test 1: Struct member write
        pt.x = 10;
        if (pt.x == 10) begin
            $display("Test 1 PASSED: pt.x = 10");
            pass_count++;
        end else $display("Test 1 FAILED");

        // Test 2: Struct member read
        pt.y = 20;
        if (pt.y == 20) begin
            $display("Test 2 PASSED: pt.y = 20");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: Multiple struct members
        pt.x = 100;
        pt.y = 200;
        if (pt.x + pt.y == 300) begin
            $display("Test 3 PASSED: pt.x + pt.y = 300");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Packed struct member
        color.r = 8'hFF;
        color.g = 8'h00;
        color.b = 8'h80;
        if (color.r == 8'hFF) begin
            $display("Test 4 PASSED: color.r = 0xFF");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Packed struct as value
        if (color == 24'hFF0080) begin
            $display("Test 5 PASSED: color = 24'hFF0080");
            pass_count++;
        end else $display("Test 5 FAILED: color = %h", color);

        // Test 6: Nested struct member
        person.name = "Alice";
        person.age = 30;
        person.location.x = 50;
        person.location.y = 60;
        if (person.location.x == 50) begin
            $display("Test 6 PASSED: person.location.x = 50");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: Nested struct y
        if (person.location.y == 60) begin
            $display("Test 7 PASSED: person.location.y = 60");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: String struct member
        if (person.name == "Alice") begin
            $display("Test 8 PASSED: person.name = Alice");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: Int struct member
        if (person.age == 30) begin
            $display("Test 9 PASSED: person.age = 30");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: Class instantiation and member access
        obj = new(42, "test");
        if (obj.value == 42) begin
            $display("Test 10 PASSED: obj.value = 42");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: Class string member
        if (obj.label == "test") begin
            $display("Test 11 PASSED: obj.label = \"test\"");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: Class member modification
        obj.value = 100;
        if (obj.value == 100) begin
            $display("Test 12 PASSED: obj.value modified to 100");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: Class method call
        if (obj.get_value() == 100) begin
            $display("Test 13 PASSED: obj.get_value() = 100");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Struct assignment
        pt = '{x: 5, y: 15};
        if (pt.x == 5 && pt.y == 15) begin
            $display("Test 14 PASSED: struct assignment '{x:5, y:15}");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Struct member in expression
        pt.x = 7;
        pt.y = 3;
        if (pt.x * pt.y == 21) begin
            $display("Test 15 PASSED: pt.x * pt.y = 21");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Packed struct member modify
        color.g = 8'hAA;
        if (color.g == 8'hAA) begin
            $display("Test 16 PASSED: color.g = 0xAA");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Struct copy
        begin
            point_t pt2;
            pt2 = pt;
            if (pt2.x == pt.x && pt2.y == pt.y) begin
                $display("Test 17 PASSED: struct copy");
                pass_count++;
            end else $display("Test 17 FAILED");
        end

        // Test 18: Struct member comparison
        pt.x = 10;
        pt.y = 10;
        if (pt.x == pt.y) begin
            $display("Test 18 PASSED: pt.x == pt.y");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Class member comparison
        obj.value = 50;
        if (obj.value > 25) begin
            $display("Test 19 PASSED: obj.value > 25");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Nested struct modification
        person.location = '{x: 100, y: 200};
        if (person.location.x == 100 && person.location.y == 200) begin
            $display("Test 20 PASSED: nested struct assignment");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Struct member as function arg
        pt.x = 25;
        if (double_val(pt.x) == 50) begin
            $display("Test 21 PASSED: double_val(pt.x) = 50");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Multiple packed struct operations
        color = '{r: 8'h11, g: 8'h22, b: 8'h33};
        if (color.r + color.g + color.b == 8'h66) begin
            $display("Test 22 PASSED: color.r + color.g + color.b = 0x66");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Class member string update
        obj.label = "updated";
        if (obj.label == "updated") begin
            $display("Test 23 PASSED: obj.label updated");
            pass_count++;
        end else $display("Test 23 FAILED");

        pt.x = 5;
        if (((pt.x > 0) ? pt.x : -pt.x) == 5) begin
            $display("Test 24 PASSED: abs(pt.x) = 5");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: Packed struct bit access
        color = 24'hABCDEF;
        if (color.r == 8'hAB && color.g == 8'hCD && color.b == 8'hEF) begin
            $display("Test 25 PASSED: packed struct from literal");
            pass_count++;
        end else $display("Test 25 FAILED");

        if (pass_count == total_tests) $display("PASS: member_access (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: member_access (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
