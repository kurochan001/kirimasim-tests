/*
:name: test_class_this_super
:description: this and super keywords
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.11 8.15
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_this_super.expected
*/
// IEEE 1800-2023 §8.15: this and super keywords
// Tests this pointer and super class access

module test_class_this_super;
    int pass_count = 0;
    int test_count = 0;

    class Base;
        int value;

        function new(int v);
            this.value = v;  // Use 'this' explicitly
        endfunction

        function int get_value();
            return value;
        endfunction

        virtual function string get_name();
            return "Base";
        endfunction
    endclass

    class Derived extends Base;
        int extra;

        function new(int v, int e);
            super.new(v);  // Call parent constructor
            this.extra = e;
        endfunction

        function int get_total();
            return this.value + this.extra;
        endfunction

        function string get_name();
            return "Derived";
        endfunction

        function string get_both_names();
            return {super.get_name(), "-", this.get_name()};
        endfunction
    endclass

    class GrandChild extends Derived;
        function new(int v, int e);
            super.new(v, e);
        endfunction

        function string get_name();
            return "GrandChild";
        endfunction

        function string get_chain();
            return {super.get_name(), "->", this.get_name()};
        endfunction
    endclass

    initial begin
        // Test 1: this pointer in constructor
        test_count++;
        begin
            static Base b = new(42);
            if (b.value == 42) begin
                pass_count++;
                $display("Test 1 PASS: this in constructor");
            end else begin
                $display("Test 1 FAIL: this in constructor");
            end
        end

        // Test 2: super.new() call
        test_count++;
        begin
            static Derived d = new(10, 5);
            if (d.value == 10 && d.extra == 5) begin
                pass_count++;
                $display("Test 2 PASS: super.new() call");
            end else begin
                $display("Test 2 FAIL: super.new() call");
            end
        end

        // Test 3: this in method
        test_count++;
        begin
            static Derived d = new(20, 30);
            if (d.get_total() == 50) begin
                pass_count++;
                $display("Test 3 PASS: this in method");
            end else begin
                $display("Test 3 FAIL: this in method (got %0d)", d.get_total());
            end
        end

        // Test 4: super method call
        test_count++;
        begin
            static Derived d = new(1, 2);
            static string result;
            // Assigned here: a static initializer runs before the others in no
            // guaranteed order relative to the handle it reads (the standard specifies none).
            result = d.get_both_names();
            if (result == "Base-Derived") begin
                pass_count++;
                $display("Test 4 PASS: super method call");
            end else begin
                $display("Test 4 FAIL: super method call (got '%s')", result);
            end
        end

        // Test 5: Virtual method override
        test_count++;
        begin
            Base b;
            static Derived d = new(1, 2);
            b = d;  // Polymorphism
            if (b.get_name() == "Derived") begin
                pass_count++;
                $display("Test 5 PASS: virtual method override");
            end else begin
                $display("Test 5 FAIL: virtual method override (got '%s')", b.get_name());
            end
        end

        // Test 6: Grandchild super chain
        test_count++;
        begin
            static GrandChild gc = new(100, 200);
            if (gc.value == 100 && gc.extra == 200) begin
                pass_count++;
                $display("Test 6 PASS: grandchild super chain");
            end else begin
                $display("Test 6 FAIL: grandchild values");
            end
        end

        // Test 7: Grandchild method chain
        test_count++;
        begin
            static GrandChild gc = new(1, 2);
            static string result;
            // Assigned here: a static initializer runs before the others in no
            // guaranteed order relative to the handle it reads (the standard specifies none).
            result = gc.get_chain();
            if (result == "Derived->GrandChild") begin
                pass_count++;
                $display("Test 7 PASS: grandchild method chain");
            end else begin
                $display("Test 7 FAIL: grandchild method chain (got '%s')", result);
            end
        end

        // Test 8: Polymorphism with grandchild
        test_count++;
        begin
            Base b;
            static GrandChild gc = new(5, 10);
            b = gc;
            if (b.get_name() == "GrandChild") begin
                pass_count++;
                $display("Test 8 PASS: polymorphism with grandchild");
            end else begin
                $display("Test 8 FAIL: polymorphism (got '%s')", b.get_name());
            end
        end

        $display("=== Class this/super Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
