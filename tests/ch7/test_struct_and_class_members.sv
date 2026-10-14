/*
:name: test_struct_and_class_members
:description: Packed struct members, and class properties and methods (IEEE 1800-2023 Sections 7.2 and 8.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 8.5 8.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_and_class_members.expected
*/
`timescale 1ns/1ps

class Container;
    int value;
    string name;

    function new(int v, string n);
        value = v;
        name = n;
    endfunction

    function int get_value();
        return value;
    endfunction

    function void set_value(int v);
        value = v;
    endfunction
endclass

module test_member_access;
    typedef struct packed {
        logic [7:0] field1;
        logic [7:0] field2;
        logic [15:0] field3;
    } my_struct;

    my_struct s;
    Container c;

    initial begin
        // Struct member access
        s.field1 = 8'hAA;
        s.field2 = 8'hBB;
        s.field3 = 16'hCCDD;

        if (s.field1 != 8'hAA) $display("FAIL: struct.field1");
        if (s.field2 != 8'hBB) $display("FAIL: struct.field2");
        if (s.field3 != 16'hCCDD) $display("FAIL: struct.field3");

        // Class member access
        c = new(42, "test");

        if (c.value != 42) $display("FAIL: class.value");
        if (c.name != "test") $display("FAIL: class.name");

        // Method access
        if (c.get_value() != 42) $display("FAIL: get_value");

        c.set_value(100);
        if (c.get_value() != 100) $display("FAIL: set_value");

        $display("TEST PASSED");
        $finish;
    end
endmodule
