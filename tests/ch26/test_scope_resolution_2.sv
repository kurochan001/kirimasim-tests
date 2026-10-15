/*
:name: test_scope_resolution_2
:description: Test scope resolution operator ::
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 8.23
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_resolution_2.expected
*/
// Test scope resolution operator ::
package pkg_a;
    parameter int VALUE = 100;
    typedef logic [7:0] byte_t;

    function int get_value();
        return VALUE;
    endfunction

    class ClassA;
        static int static_count = 0;
        int instance_id;

        function new();
            static_count++;
            instance_id = static_count;
        endfunction

        static function int get_count();
            return static_count;
        endfunction
    endclass
endpackage

package pkg_b;
    parameter int VALUE = 200;
    typedef logic [15:0] word_t;

    function int get_value();
        return VALUE;
    endfunction
endpackage

class OuterClass;
    static int outer_static = 42;

    class InnerClass;
        static int inner_static = 24;

        static function int get_inner();
            return inner_static;
        endfunction
    endclass

    static function int get_outer();
        return outer_static;
    endfunction
endclass

module test_scope_resolution_2;
    import pkg_a::*;

    int pass_count = 0;
    int total_tests = 8;

    pkg_a::byte_t byte_val;
    pkg_b::word_t word_val;

    pkg_a::ClassA obj1;
    pkg_a::ClassA obj2;

    initial begin
        // Test 1: Package parameter access with ::
        if (pkg_a::VALUE == 100) begin
            $display("Test 1 PASS: pkg_a::VALUE = %0d", pkg_a::VALUE);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: pkg_a::VALUE = %0d, expected 100", pkg_a::VALUE);
        end

        // Test 2: Different package parameter
        if (pkg_b::VALUE == 200) begin
            $display("Test 2 PASS: pkg_b::VALUE = %0d", pkg_b::VALUE);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: pkg_b::VALUE = %0d, expected 200", pkg_b::VALUE);
        end

        // Test 3: Package function call with ::
        if (pkg_a::get_value() == 100) begin
            $display("Test 3 PASS: pkg_a::get_value() = %0d", pkg_a::get_value());
            pass_count++;
        end else begin
            $display("Test 3 FAIL: pkg_a::get_value() = %0d, expected 100", pkg_a::get_value());
        end

        // Test 4: Package typedef usage
        byte_val = 8'hAB;
        word_val = 16'hCDEF;
        if (byte_val == 8'hAB && word_val == 16'hCDEF) begin
            $display("Test 4 PASS: Package typedefs work correctly");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: Package typedef values incorrect");
        end

        // Test 5: Class static member via ::
        obj1 = new();
        obj2 = new();
        if (pkg_a::ClassA::static_count == 2) begin
            $display("Test 5 PASS: ClassA::static_count = %0d", pkg_a::ClassA::static_count);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: ClassA::static_count = %0d, expected 2", pkg_a::ClassA::static_count);
        end

        // Test 6: Class static function via ::
        if (pkg_a::ClassA::get_count() == 2) begin
            $display("Test 6 PASS: ClassA::get_count() = %0d", pkg_a::ClassA::get_count());
            pass_count++;
        end else begin
            $display("Test 6 FAIL: ClassA::get_count() = %0d, expected 2", pkg_a::ClassA::get_count());
        end

        // Test 7: Nested class static access
        if (OuterClass::outer_static == 42) begin
            $display("Test 7 PASS: OuterClass::outer_static = %0d", OuterClass::outer_static);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: OuterClass::outer_static = %0d, expected 42", OuterClass::outer_static);
        end

        // Test 8: Write to static via ::
        pkg_a::ClassA::static_count = 10;
        if (pkg_a::ClassA::static_count == 10) begin
            $display("Test 8 PASS: Write via :: successful");
            pass_count++;
        end else begin
            $display("Test 8 FAIL: Write via :: failed");
        end

        if (pass_count == total_tests) $display("PASS: scope_resolution (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: scope_resolution (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
