/*
:name: test_class_new_args
:description: Test: Class constructor with various argument types
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.7 13.5.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_new_args.expected
*/
// Test: Class constructor with various argument types
module test_class_new_args;
    int pass_count = 0;
    int fail_count = 0;

    // Class with no arguments
    class NoArgs;
        int value;
        function new();
            value = 42;
        endfunction
    endclass

    // Class with basic arguments
    class BasicArgs;
        int x, y;
        function new(int a, int b);
            x = a;
            y = b;
        endfunction
    endclass

    // Class with default arguments
    class DefaultArgs;
        int a, b, c;
        function new(int x, int y = 10, int z = 20);
            a = x;
            b = y;
            c = z;
        endfunction
    endclass

    // Class with string argument
    class StringArgs;
        string name;
        int id;
        function new(string n, int i);
            name = n;
            id = i;
        endfunction
    endclass

    // Class with array argument
    class ArrayArgs;
        int data[];
        function new(int size);
            data = new[size];
            foreach (data[i]) data[i] = i;
        endfunction
    endclass

    NoArgs na;
    BasicArgs ba;
    DefaultArgs da1, da2, da3;
    StringArgs sa;
    ArrayArgs aa;

    initial begin
        // Test 1: No arguments constructor
        na = new();
        if (na.value == 42) begin
            $display("PASS: No arguments constructor");
            pass_count++;
        end else begin
            $display("FAIL: No arguments - expected 42, got %0d", na.value);
            fail_count++;
        end

        // Test 2: Basic arguments constructor
        ba = new(5, 7);
        if (ba.x == 5 && ba.y == 7) begin
            $display("PASS: Basic arguments constructor");
            pass_count++;
        end else begin
            $display("FAIL: Basic arguments - expected (5,7), got (%0d,%0d)", ba.x, ba.y);
            fail_count++;
        end

        // Test 3: Default arguments - all provided
        da1 = new(1, 2, 3);
        if (da1.a == 1 && da1.b == 2 && da1.c == 3) begin
            $display("PASS: Default arguments - all provided");
            pass_count++;
        end else begin
            $display("FAIL: Default args all - expected (1,2,3), got (%0d,%0d,%0d)", da1.a, da1.b, da1.c);
            fail_count++;
        end

        // Test 4: Default arguments - partial
        da2 = new(100);
        if (da2.a == 100 && da2.b == 10 && da2.c == 20) begin
            $display("PASS: Default arguments - partial (uses defaults)");
            pass_count++;
        end else begin
            $display("FAIL: Default args partial - expected (100,10,20), got (%0d,%0d,%0d)", da2.a, da2.b, da2.c);
            fail_count++;
        end

        // Test 5: String argument constructor
        sa = new("TestObject", 123);
        if (sa.name == "TestObject" && sa.id == 123) begin
            $display("PASS: String argument constructor");
            pass_count++;
        end else begin
            $display("FAIL: String argument - expected ('TestObject',123), got ('%s',%0d)", sa.name, sa.id);
            fail_count++;
        end

        // Test 6: Array creation in constructor
        aa = new(4);
        if (aa.data.size() == 4 && aa.data[0] == 0 && aa.data[3] == 3) begin
            $display("PASS: Array argument constructor");
            pass_count++;
        end else begin
            $display("FAIL: Array argument - size=%0d, data[3]=%0d", aa.data.size(), aa.data[3]);
            fail_count++;
        end

        // Summary
        $display("Class new args test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All class constructor tests passed");
        $finish;
    end
endmodule
