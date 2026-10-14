/*
:name: test_class_member_access
:description: Test for IEEE 1800-2023 §8: Class member access
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.5 8.6 8.13
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_member_access.expected
*/
// Test for IEEE 1800-2023 §8: Class member access

class BaseClass;
    int base_value;
    string base_name;

    function new();
        base_value = 100;
        base_name = "base";
    endfunction

    function int get_base_value();
        return base_value;
    endfunction
endclass

class DerivedClass extends BaseClass;
    int derived_value;
    string derived_name;

    function new();
        super.new();
        derived_value = 200;
        derived_name = "derived";
    endfunction

    function int get_derived_value();
        return derived_value;
    endfunction
endclass

module test_class_member_access;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        BaseClass base_obj;
        DerivedClass derived_obj;

        $display("=== Class Member Access Test ===");

        // Test BaseClass member access
        base_obj = new();

        // Test direct member access
        if (base_obj.base_value == 100) begin
            $display("PASS: base_obj.base_value = %0d", base_obj.base_value);
            pass_count++;
        end else begin
            $display("FAIL: base_obj.base_value expected 100, got %0d", base_obj.base_value);
            fail_count++;
        end

        if (base_obj.base_name == "base") begin
            $display("PASS: base_obj.base_name = \"%s\"", base_obj.base_name);
            pass_count++;
        end else begin
            $display("FAIL: base_obj.base_name expected \"base\"");
            fail_count++;
        end

        // Test member modification
        base_obj.base_value = 150;
        if (base_obj.base_value == 150) begin
            $display("PASS: base_obj.base_value modified to %0d", base_obj.base_value);
            pass_count++;
        end else begin
            $display("FAIL: base_obj.base_value modification failed");
            fail_count++;
        end

        // Test method call
        if (base_obj.get_base_value() == 150) begin
            $display("PASS: base_obj.get_base_value() = %0d", base_obj.get_base_value());
            pass_count++;
        end else begin
            $display("FAIL: base_obj.get_base_value() expected 150");
            fail_count++;
        end

        // Test DerivedClass member access
        derived_obj = new();

        // Test derived member access
        if (derived_obj.derived_value == 200) begin
            $display("PASS: derived_obj.derived_value = %0d", derived_obj.derived_value);
            pass_count++;
        end else begin
            $display("FAIL: derived_obj.derived_value expected 200, got %0d", derived_obj.derived_value);
            fail_count++;
        end

        if (derived_obj.derived_name == "derived") begin
            $display("PASS: derived_obj.derived_name = \"%s\"", derived_obj.derived_name);
            pass_count++;
        end else begin
            $display("FAIL: derived_obj.derived_name expected \"derived\"");
            fail_count++;
        end

        // Test base member access from derived
        if (derived_obj.base_value == 100) begin
            $display("PASS: derived_obj.base_value (inherited) = %0d", derived_obj.base_value);
            pass_count++;
        end else begin
            $display("FAIL: derived_obj.base_value expected 100, got %0d", derived_obj.base_value);
            fail_count++;
        end

        if (derived_obj.base_name == "base") begin
            $display("PASS: derived_obj.base_name (inherited) = \"%s\"", derived_obj.base_name);
            pass_count++;
        end else begin
            $display("FAIL: derived_obj.base_name expected \"base\"");
            fail_count++;
        end

        // Test method call on derived
        if (derived_obj.get_derived_value() == 200) begin
            $display("PASS: derived_obj.get_derived_value() = %0d", derived_obj.get_derived_value());
            pass_count++;
        end else begin
            $display("FAIL: derived_obj.get_derived_value() expected 200");
            fail_count++;
        end

        // Test inherited method call
        if (derived_obj.get_base_value() == 100) begin
            $display("PASS: derived_obj.get_base_value() (inherited) = %0d", derived_obj.get_base_value());
            pass_count++;
        end else begin
            $display("FAIL: derived_obj.get_base_value() expected 100");
            fail_count++;
        end

        // Summary
        $display("\n=== Class Member Access Test Summary ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
