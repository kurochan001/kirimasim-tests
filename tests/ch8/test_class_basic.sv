/*
:name: test_class_basic
:description: Test for class basics
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_basic.expected
*/
// Test for class basics
// IEEE 1800-2023 §8

class SimpleClass;
    int value;
    string name;
    
    function new(int v = 0, string n = "default");
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

module test_class_basic;
    SimpleClass obj;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Object creation
        test_count++;
        obj = new(10, "test");
        if (obj != null) begin
            $display("Test 1: Object creation PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Member access
        test_count++;
        if (obj.value == 10) begin
            $display("Test 2: Member access PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Method call
        test_count++;
        if (obj.get_value() == 10) begin
            $display("Test 3: Method call PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Setter method
        test_count++;
        obj.set_value(20);
        if (obj.value == 20) begin
            $display("Test 4: Setter method PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: String member
        test_count++;
        if (obj.name == "test") begin
            $display("Test 5: String member PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
