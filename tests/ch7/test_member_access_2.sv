/*
:name: test_member_access_2
:description: Class and struct member access patterns
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 8.5 8.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access_2.expected
*/
// Class and struct member access patterns
module test_member_access_2;
    int pass_count = 0;

    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
        logic [15:0] c;
    } my_struct_t;

    class MyClass;
        int value;
        string name;
        my_struct_t data;

        function new(int v, string n);
            value = v;
            name = n;
            data.a = 8'hAA;
            data.b = 8'hBB;
            data.c = 16'hCCCC;
        endfunction

        function int get_value();
            return value;
        endfunction

        function void set_value(int v);
            value = v;
        endfunction
    endclass

    class DerivedClass extends MyClass;
        int extra;

        function new(int v, string n, int e);
            super.new(v, n);
            extra = e;
        endfunction
    endclass

    MyClass obj;
    DerivedClass derived;
    my_struct_t s;

    initial begin
        // Test class instantiation and member access
        obj = new(42, "test");
        if (obj.value == 42) pass_count++;
        if (obj.name == "test") pass_count++;

        // Test struct member access
        if (obj.data.a == 8'hAA) pass_count++;
        if (obj.data.b == 8'hBB) pass_count++;

        // Test method calls
        if (obj.get_value() == 42) pass_count++;

        obj.set_value(100);
        if (obj.value == 100) pass_count++;

        // Test derived class
        derived = new(10, "derived", 99);
        if (derived.value == 10) pass_count++;
        if (derived.extra == 99) pass_count++;

        // Test standalone struct
        s.a = 8'h11;
        s.b = 8'h22;
        s.c = 16'h3344;
        if (s.a == 8'h11) pass_count++;
        if (s.c == 16'h3344) pass_count++;

        if (pass_count == 10) $display("PASS: member access (%0d/10)", pass_count);
        else $display("FAIL: member access (%0d/10)", pass_count);
        $finish;
    end
endmodule
