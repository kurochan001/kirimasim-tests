/*
:name: test_class_copy_corner
:description: Tests shallow copy, deep copy, and clone patterns
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12 8.21
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_copy_corner.expected
*/
// Tests shallow copy, deep copy, and clone patterns
`timescale 1ns/1ps

module test_class_copy_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Simple class
    class SimpleData;
        int value;
        string name;

        function new(int v = 0, string n = "");
            value = v;
            name = n;
        endfunction

        function SimpleData copy();
            SimpleData c = new();
            c.value = this.value;
            c.name = this.name;
            return c;
        endfunction
    endclass

    // Test 1: Basic copy
    task test_basic_copy();
        static SimpleData orig = new(42, "original");
        static SimpleData copied;
        // Assigned here: a static initializer runs before the others in no
        // guaranteed order relative to the handle it reads (the standard specifies none).
        copied = orig.copy();

        if (copied.value == 42 && copied.name == "original") begin
            $display("PASS: Basic copy works");
            pass_count++;
        end else begin
            $display("FAIL: Basic copy failed");
            fail_count++;
        end

        // Modify copy, original unchanged
        copied.value = 100;
        if (orig.value == 42) begin
            $display("PASS: Copy is independent");
            pass_count++;
        end else begin
            $display("FAIL: Copy affected original");
            fail_count++;
        end
    endtask

    // Class with nested object (for shallow vs deep copy)
    class Inner;
        int data;
        function new(int d = 0);
            data = d;
        endfunction
    endclass

    class Outer;
        int id;
        Inner inner;

        function new(int i = 0, int d = 0);
            id = i;
            inner = new(d);
        endfunction

        // Shallow copy
        function Outer shallow_copy();
            Outer c = new();
            c.id = this.id;
            c.inner = this.inner; // Same reference
            return c;
        endfunction

        // Deep copy
        function Outer deep_copy();
            Outer c = new();
            c.id = this.id;
            c.inner = new(this.inner.data); // New object
            return c;
        endfunction
    endclass

    // Test 2: Shallow copy shares nested object
    task test_shallow_copy();
        static Outer orig = new(1, 100);
        static Outer shallow;
        // Assigned here: a static initializer runs before the others in no
        // guaranteed order relative to the handle it reads (the standard specifies none).
        shallow = orig.shallow_copy();

        // Modify nested object
        shallow.inner.data = 999;

        if (orig.inner.data == 999) begin
            $display("PASS: Shallow copy shares nested object (both show 999)");
            pass_count++;
        end else begin
            $display("FAIL: Shallow copy behavior unexpected");
            fail_count++;
        end
    endtask

    // Test 3: Deep copy has independent nested object
    task test_deep_copy();
        static Outer orig = new(1, 100);
        static Outer deep;
        // Assigned here: a static initializer runs before the others in no
        // guaranteed order relative to the handle it reads (the standard specifies none).
        deep = orig.deep_copy();

        // Modify nested object
        deep.inner.data = 999;

        if (orig.inner.data == 100 && deep.inner.data == 999) begin
            $display("PASS: Deep copy has independent nested object");
            pass_count++;
        end else begin
            $display("FAIL: Deep copy not independent");
            fail_count++;
        end
    endtask

    // Class with array
    class ArrayContainer;
        int data[];

        function new(int size = 0);
            data = new[size];
        endfunction

        function ArrayContainer copy();
            ArrayContainer c = new(this.data.size());
            foreach (this.data[i]) c.data[i] = this.data[i];
            return c;
        endfunction
    endclass

    // Test 4: Copy with dynamic array
    task test_array_copy();
        static ArrayContainer orig = new(5);
        ArrayContainer copied;

        foreach (orig.data[i]) orig.data[i] = i * 10;
        copied = orig.copy();

        // Modify copy
        copied.data[0] = 999;

        if (orig.data[0] == 0 && copied.data[0] == 999) begin
            $display("PASS: Array copy is independent");
            pass_count++;
        end else begin
            $display("FAIL: Array copy not independent");
            fail_count++;
        end
    endtask

    // Class with clone virtual method
    virtual class Cloneable;
        pure virtual function Cloneable clone();
    endclass

    class ConcreteCloneable extends Cloneable;
        int value;

        function new(int v = 0);
            value = v;
        endfunction

        virtual function Cloneable clone();
            ConcreteCloneable c = new(this.value);
            return c;
        endfunction
    endclass

    // Test 5: Clone pattern
    task test_clone_pattern();
        static ConcreteCloneable orig = new(42);
        Cloneable cloned_base;
        ConcreteCloneable cloned;

        cloned_base = orig.clone();
        if ($cast(cloned, cloned_base)) begin
            if (cloned.value == 42) begin
                $display("PASS: Clone pattern works");
                pass_count++;
            end else begin
                $display("FAIL: Clone value incorrect");
                fail_count++;
            end
        end else begin
            $display("FAIL: Clone cast failed");
            fail_count++;
        end
    endtask

    // Test 6: Handle assignment (reference copy)
    task test_reference_copy();
        static SimpleData a = new(50, "shared");
        SimpleData b;

        b = a; // Reference copy

        b.value = 100;

        if (a.value == 100) begin
            $display("PASS: Handle assignment creates reference (both show 100)");
            pass_count++;
        end else begin
            $display("FAIL: Handle assignment behavior unexpected");
            fail_count++;
        end
    endtask

    // Test 7: Null handling in copy
    task test_null_handling();
        static Outer obj = new(1, 100);
        Outer copy_obj;

        obj.inner = null; // Set nested to null

        // Copy should handle null
        copy_obj = new();
        copy_obj.id = obj.id;
        copy_obj.inner = obj.inner; // null

        if (copy_obj.inner == null) begin
            $display("PASS: Null handling in copy works");
            pass_count++;
        end else begin
            $display("FAIL: Null handling failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Class Copy Corner Cases Test ===");

        test_basic_copy();
        test_shallow_copy();
        test_deep_copy();
        test_array_copy();
        test_clone_pattern();
        test_reference_copy();
        test_null_handling();

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
