/*
:name: test_instance_hierarchy
:description: Using instance hierarchy in configurations
:tags: config
:type: simulation
:lrm: 1800-2023 23.6
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_instance_hierarchy.expected
*/
// IEEE 1800-2023 §33.5: Using instance hierarchy in configurations
// Tests hierarchical instance access
// Verifies nested module instantiation

module leaf_module #(parameter int ID = 0);
    logic [7:0] value = 8'h00;
endmodule

module mid_module #(parameter int MID_ID = 0);
    leaf_module #(.ID(MID_ID * 10 + 1)) leaf1();
    leaf_module #(.ID(MID_ID * 10 + 2)) leaf2();
endmodule

module top_module;
    mid_module #(.MID_ID(1)) mid1();
    mid_module #(.MID_ID(2)) mid2();
endmodule

module test_instance_hierarchy;
    int pass_count = 0;
    int fail_count = 0;

    top_module top();

    initial begin
        $display("=== IEEE 1800-2023 §33.5: Instance Hierarchy ===");

        // Test 1: Access nested leaf ID
        if (top.mid1.leaf1.ID == 11) begin
            $display("PASS: top.mid1.leaf1.ID = 11");
            pass_count++;
        end else begin
            $display("FAIL: top.mid1.leaf1.ID = %0d", top.mid1.leaf1.ID);
            fail_count++;
        end

        // Test 2: Access different leaf
        if (top.mid1.leaf2.ID == 12) begin
            $display("PASS: top.mid1.leaf2.ID = 12");
            pass_count++;
        end else begin
            $display("FAIL: top.mid1.leaf2.ID = %0d", top.mid1.leaf2.ID);
            fail_count++;
        end

        // Test 3: Access second mid-level
        if (top.mid2.leaf1.ID == 21) begin
            $display("PASS: top.mid2.leaf1.ID = 21");
            pass_count++;
        end else begin
            $display("FAIL: top.mid2.leaf1.ID = %0d", top.mid2.leaf1.ID);
            fail_count++;
        end

        // Test 4: Access second mid-level second leaf
        if (top.mid2.leaf2.ID == 22) begin
            $display("PASS: top.mid2.leaf2.ID = 22");
            pass_count++;
        end else begin
            $display("FAIL: top.mid2.leaf2.ID = %0d", top.mid2.leaf2.ID);
            fail_count++;
        end

        // Test 5: MID_ID propagation
        if (top.mid1.MID_ID == 1 && top.mid2.MID_ID == 2) begin
            $display("PASS: MID_ID propagation correct");
            pass_count++;
        end else begin
            $display("FAIL: MID_ID wrong");
            fail_count++;
        end

        // Test 6: Leaf default value
        if (top.mid1.leaf1.value == 8'h00) begin
            $display("PASS: Leaf default value is 0");
            pass_count++;
        end else begin
            $display("FAIL: Leaf value wrong");
            fail_count++;
        end

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
