/*
:name: test_hierarchical_names
:description: Chapter 23: Modules and hierarchy
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchical_names.expected
*/
// IEEE 1800-2023 Chapter 23: Modules and hierarchy
// §23.6 Hierarchical names

module test_hierarchical_names;
    // Test hierarchical name access

    int test_count;
    int pass_count;

    // Instantiate nested hierarchy
    top_level u_top();

    initial begin
        test_count = 0;
        pass_count = 0;

        // Wait for initialization
        #1;

        // Test 1: Access signal in child module
        test_count++;
        if (u_top.u_mid.value == 42) pass_count++;
        else $display("FAIL: Hierarchical access - value=%0d (expected 42)", u_top.u_mid.value);

        // Test 2: Access nested signal
        test_count++;
        if (u_top.u_mid.u_leaf.leaf_val == 100) pass_count++;
        else $display("FAIL: Nested access - leaf_val=%0d (expected 100)", u_top.u_mid.u_leaf.leaf_val);

        // Test 3: Write through hierarchy (IEEE 1800-2023 §23.6)
        u_top.u_mid.value = 99;
        #1;
        test_count++;
        if (u_top.u_mid.value == 99) pass_count++;
        else $display("FAIL: Hierarchical write - value=%0d (expected 99)", u_top.u_mid.value);

        $display("Chapter 23.6 Hierarchical Names: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule

module top_level;
    mid_level u_mid();
endmodule

module mid_level;
    int value;
    leaf_level u_leaf();

    initial begin
        value = 42;
    end
endmodule

module leaf_level;
    int leaf_val;

    initial begin
        leaf_val = 100;
    end
endmodule
