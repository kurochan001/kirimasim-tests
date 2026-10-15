/*
:name: test_class_scope
:description: Test class method scope
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.5 8.9 8.10 8.20 8.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_scope.expected
*/
// Test class method scope
class BaseClass;
    int base_member = 10;
    static int base_static = 100;

    function int get_base();
        return base_member;
    endfunction

    virtual function int virtual_get();
        return base_member * 2;
    endfunction

    static function int get_base_static();
        return base_static;
    endfunction
endclass

class DerivedClass extends BaseClass;
    int derived_member = 20;
    static int derived_static = 200;

    function int get_derived();
        return derived_member;
    endfunction

    function int get_both();
        return base_member + derived_member;
    endfunction

    virtual function int virtual_get();
        return derived_member * 3;
    endfunction

    static function int get_derived_static();
        return derived_static;
    endfunction
endclass

class ContainerClass;
    int container_val = 50;
    BaseClass inner_obj;

    function new();
        inner_obj = new();
    endfunction

    function int get_inner_val();
        return inner_obj.base_member;
    endfunction

    function void set_inner_val(int val);
        inner_obj.base_member = val;
    endfunction
endclass

module test_class_scope;
    int pass_count = 0;
    int total_tests = 8;

    BaseClass base_obj;
    DerivedClass derived_obj;
    ContainerClass container_obj;
    BaseClass poly_obj;

    initial begin
        // Initialize objects
        base_obj = new();
        derived_obj = new();
        container_obj = new();
        poly_obj = derived_obj;  // Polymorphic assignment

        // Test 1: Base class member access
        if (base_obj.base_member == 10) begin
            $display("Test 1 PASS: base_obj.base_member = %0d", base_obj.base_member);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: base_obj.base_member = %0d, expected 10", base_obj.base_member);
        end

        // Test 2: Base class method call
        if (base_obj.get_base() == 10) begin
            $display("Test 2 PASS: base_obj.get_base() = %0d", base_obj.get_base());
            pass_count++;
        end else begin
            $display("Test 2 FAIL: base_obj.get_base() = %0d, expected 10", base_obj.get_base());
        end

        // Test 3: Derived class accesses base member
        if (derived_obj.get_both() == 30) begin
            $display("Test 3 PASS: derived_obj.get_both() = %0d", derived_obj.get_both());
            pass_count++;
        end else begin
            $display("Test 3 FAIL: derived_obj.get_both() = %0d, expected 30", derived_obj.get_both());
        end

        // Test 4: Static member via class name
        if (BaseClass::base_static == 100) begin
            $display("Test 4 PASS: BaseClass::base_static = %0d", BaseClass::base_static);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: BaseClass::base_static = %0d, expected 100", BaseClass::base_static);
        end

        // Test 5: Static function via class name
        if (DerivedClass::get_derived_static() == 200) begin
            $display("Test 5 PASS: DerivedClass::get_derived_static() = %0d", DerivedClass::get_derived_static());
            pass_count++;
        end else begin
            $display("Test 5 FAIL: get_derived_static() = %0d, expected 200", DerivedClass::get_derived_static());
        end

        // Test 6: Virtual function (polymorphic call)
        if (poly_obj.virtual_get() == 60) begin  // derived_member(20) * 3 = 60
            $display("Test 6 PASS: poly_obj.virtual_get() = %0d", poly_obj.virtual_get());
            pass_count++;
        end else begin
            $display("Test 6 FAIL: poly_obj.virtual_get() = %0d, expected 60", poly_obj.virtual_get());
        end

        // Test 7: Container class inner object access
        if (container_obj.get_inner_val() == 10) begin
            $display("Test 7 PASS: container_obj.get_inner_val() = %0d", container_obj.get_inner_val());
            pass_count++;
        end else begin
            $display("Test 7 FAIL: container_obj.get_inner_val() = %0d, expected 10", container_obj.get_inner_val());
        end

        // Test 8: Modify inner object via method
        container_obj.set_inner_val(99);
        if (container_obj.get_inner_val() == 99) begin
            $display("Test 8 PASS: After set_inner_val(99), get_inner_val() = %0d", container_obj.get_inner_val());
            pass_count++;
        end else begin
            $display("Test 8 FAIL: get_inner_val() = %0d, expected 99", container_obj.get_inner_val());
        end

        if (pass_count == total_tests) $display("PASS: class_scope (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: class_scope (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
