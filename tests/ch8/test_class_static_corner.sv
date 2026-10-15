/*
:name: test_class_static_corner
:description: Tests static properties, methods, and class-level state
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.9 8.10 8.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_static_corner.expected
*/
// Tests static properties, methods, and class-level state
`timescale 1ns/1ps

module test_class_static_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Class with static members
    class Counter;
        static int count = 0;
        static int max_count = 100;
        int instance_id;

        function new();
            count++;
            instance_id = count;
        endfunction

        static function int get_count();
            return count;
        endfunction

        static function void reset();
            count = 0;
        endfunction

        static function void set_max(int m);
            max_count = m;
        endfunction
    endclass

    // Test 1: Static counter increments
    task test_static_counter();
        Counter c1, c2, c3;

        Counter::reset();
        c1 = new();
        c2 = new();
        c3 = new();

        if (Counter::get_count() == 3) begin
            $display("PASS: Static counter = %0d", Counter::get_count());
            pass_count++;
        end else begin
            $display("FAIL: Static counter = %0d (expected 3)", Counter::get_count());
            fail_count++;
        end
    endtask

    // Test 2: Static method access without instance
    task test_static_method_access();
        Counter::reset();

        if (Counter::get_count() == 0) begin
            $display("PASS: Static method access without instance works");
            pass_count++;
        end else begin
            $display("FAIL: Static method access failed");
            fail_count++;
        end
    endtask

    // Test 3: Static property modification
    task test_static_property_mod();
        Counter::set_max(200);

        if (Counter::max_count == 200) begin
            $display("PASS: Static property modification works");
            pass_count++;
        end else begin
            $display("FAIL: Static property = %0d (expected 200)", Counter::max_count);
            fail_count++;
        end
    endtask

    // Test 4: Instance ID uniqueness
    task test_instance_id();
        Counter c1, c2, c3;

        Counter::reset();
        c1 = new();
        c2 = new();
        c3 = new();

        if (c1.instance_id == 1 && c2.instance_id == 2 && c3.instance_id == 3) begin
            $display("PASS: Instance IDs are unique: %0d, %0d, %0d", c1.instance_id, c2.instance_id, c3.instance_id);
            pass_count++;
        end else begin
            $display("FAIL: Instance IDs not unique");
            fail_count++;
        end
    endtask

    // Class with static const
    class Config;
        static const int VERSION = 100;
        static const string NAME = "TestConfig";
    endclass

    // Test 5: Static const
    task test_static_const();
        if (Config::VERSION == 100 && Config::NAME == "TestConfig") begin
            $display("PASS: Static const works: VERSION=%0d, NAME=%s", Config::VERSION, Config::NAME);
            pass_count++;
        end else begin
            $display("FAIL: Static const failed");
            fail_count++;
        end
    endtask

    // Class with static initialization
    class InitTest;
        static int initialized = initialize();

        static function int initialize();
            $display("  Static initialization called");
            return 42;
        endfunction
    endclass

    // Test 6: Static initialization
    task test_static_init();
        if (InitTest::initialized == 42) begin
            $display("PASS: Static initialization works");
            pass_count++;
        end else begin
            $display("FAIL: Static initialization failed");
            fail_count++;
        end
    endtask

    // Class with static in inheritance
    class Base;
        static int base_count = 0;

        function new();
            base_count++;
        endfunction
    endclass

    class Derived extends Base;
        static int derived_count = 0;

        function new();
            super.new();
            derived_count++;
        endfunction
    endclass

    // Test 7: Static with inheritance
    task test_static_inheritance();
        Derived d1, d2;

        Base::base_count = 0;
        Derived::derived_count = 0;

        d1 = new();
        d2 = new();

        if (Base::base_count == 2 && Derived::derived_count == 2) begin
            $display("PASS: Static with inheritance works: base=%0d, derived=%0d",
                     Base::base_count, Derived::derived_count);
            pass_count++;
        end else begin
            $display("FAIL: Static inheritance failed");
            fail_count++;
        end
    endtask

    // Test 8: Static array
    class ArrayHolder;
        static int data[10];

        static function void init();
            foreach (data[i]) data[i] = i * 10;
        endfunction
    endclass

    task test_static_array();
        ArrayHolder::init();

        if (ArrayHolder::data[0] == 0 && ArrayHolder::data[5] == 50 && ArrayHolder::data[9] == 90) begin
            $display("PASS: Static array works");
            pass_count++;
        end else begin
            $display("FAIL: Static array failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Static Class Members Test ===");

        test_static_counter();
        test_static_method_access();
        test_static_property_mod();
        test_instance_id();
        test_static_const();
        test_static_init();
        test_static_inheritance();
        test_static_array();

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
