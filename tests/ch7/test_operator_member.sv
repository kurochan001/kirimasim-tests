/*
:name: test_operator_member
:description: Member access operators test
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 8.5 8.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_member.expected
*/
// Member access operators test
module test_operator_member;
    typedef struct packed {
        logic [7:0] field_a;
        logic [7:0] field_b;
    } my_struct_t;

    class MyClass;
        int value;
        string name;

        function new(int v, string n);
            value = v;
            name = n;
        endfunction

        function int get_value();
            return value;
        endfunction
    endclass

    my_struct_t s;
    MyClass obj;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Struct member access (write)
        s.field_a = 8'hAA;
        s.field_b = 8'hBB;
        if (s.field_a == 8'hAA && s.field_b == 8'hBB) begin
            $display("PASS: Struct member write: field_a=0xAA, field_b=0xBB");
            pass_count++;
        end else begin
            $display("FAIL: Struct member write failed");
            fail_count++;
        end

        // Test 2: Struct member access (read)
        if ({s.field_a, s.field_b} == 16'hAABB) begin
            $display("PASS: Struct member read concatenation = 0xAABB");
            pass_count++;
        end else begin
            $display("FAIL: Struct member read failed");
            fail_count++;
        end

        // Test 3: Class member access
        obj = new(42, "test");
        if (obj.value == 42) begin
            $display("PASS: Class member obj.value = 42");
            pass_count++;
        end else begin
            $display("FAIL: Class member value, expected 42, got %0d", obj.value);
            fail_count++;
        end

        // Test 4: Class string member
        if (obj.name == "test") begin
            $display("PASS: Class string member obj.name = \"test\"");
            pass_count++;
        end else begin
            $display("FAIL: Class string member failed");
            fail_count++;
        end

        // Test 5: Class method call via member access
        if (obj.get_value() == 42) begin
            $display("PASS: Class method obj.get_value() = 42");
            pass_count++;
        end else begin
            $display("FAIL: Class method call failed");
            fail_count++;
        end

        // Summary
        $display("Member access operators: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All member access operator tests passed");
        else $display("FAIL: Some member access operator tests failed");
        $finish;
    end
endmodule
