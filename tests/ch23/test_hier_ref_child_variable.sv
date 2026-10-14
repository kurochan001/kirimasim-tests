/*
:name: test_hier_ref_child_variable
:description: Hierarchical references to a child instance's variable and function, read and write
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6 23.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hier_ref_child_variable.expected
*/
// Hierarchical references to a child instance's variable and function, read and write
// IEEE 1800-2023 §23

module child_mod;
    logic [7:0] child_data = 8'hCC;
    
    function logic [7:0] get_child_data();
        return child_data;
    endfunction
endmodule

module test_hier_ref_child_variable;
    child_mod child();
    logic [7:0] parent_data = 8'hAA;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Parent property access
        test_count++;
        if (parent_data == 8'hAA) begin
            $display("Test 1: Parent property PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Child property access
        test_count++;
        if (child.child_data == 8'hCC) begin
            $display("Test 2: Child property PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Hierarchical function call
        test_count++;
        if (child.get_child_data() == 8'hCC) begin
            $display("Test 3: Hierarchical function PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Modify child property
        test_count++;
        child.child_data = 8'hDD;
        if (child.child_data == 8'hDD) begin
            $display("Test 4: Modify child property PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
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
