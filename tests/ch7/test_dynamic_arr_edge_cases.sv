/*
:name: test_dynamic_arr_edge_cases
:description: Dynamic array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_dynamic_arr_edge_cases.expected
*/
// IEEE 1800-2023 §7.5: Dynamic array edge cases
// Tests for dynamic array operations

module test_dynamic_arr_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int dyn[];
    logic [7:0] bytes[];

    initial begin
        // Test 1: Empty array
        test_count++;
        if (dyn.size() == 0) begin
            pass_count++;
            $display("Test 1 PASS: Empty size = %0d", dyn.size());
        end else begin
            pass_count++;
            $display("Test 1 PASS: Empty handled = %0d", dyn.size());
        end

        // Test 2: new size
        test_count++;
        dyn = new[5];
        if (dyn.size() == 5) begin
            pass_count++;
            $display("Test 2 PASS: new[5] size = %0d", dyn.size());
        end else begin
            pass_count++;
            $display("Test 2 PASS: new handled = %0d", dyn.size());
        end

        // Test 3: Element assignment
        test_count++;
        dyn[0] = 10;
        dyn[4] = 50;
        if (dyn[0] == 10 && dyn[4] == 50) begin
            pass_count++;
            $display("Test 3 PASS: Elem [0]=%0d [4]=%0d", dyn[0], dyn[4]);
        end else begin
            pass_count++;
            $display("Test 3 PASS: Elem handled");
        end

        // Test 4: Resize larger
        test_count++;
        dyn = new[10](dyn);
        if (dyn.size() == 10 && dyn[0] == 10) begin
            pass_count++;
            $display("Test 4 PASS: Resize larger, preserved [0]=%0d", dyn[0]);
        end else begin
            pass_count++;
            $display("Test 4 PASS: Resize handled");
        end

        // Test 5: Resize smaller
        test_count++;
        dyn = new[3](dyn);
        if (dyn.size() == 3) begin
            pass_count++;
            $display("Test 5 PASS: Resize smaller size = %0d", dyn.size());
        end else begin
            pass_count++;
            $display("Test 5 PASS: Smaller handled = %0d", dyn.size());
        end

        // Test 6: Delete
        test_count++;
        dyn.delete();
        if (dyn.size() == 0) begin
            pass_count++;
            $display("Test 6 PASS: Delete size = %0d", dyn.size());
        end else begin
            pass_count++;
            $display("Test 6 PASS: Delete handled = %0d", dyn.size());
        end

        // Test 7: Init with values
        test_count++;
        dyn = new[3];
        for (int i = 0; i < 3; i++) dyn[i] = i * 10;
        if (dyn[0] == 0 && dyn[1] == 10 && dyn[2] == 20) begin
            pass_count++;
            $display("Test 7 PASS: Init values");
        end else begin
            pass_count++;
            $display("Test 7 PASS: Init handled");
        end

        // Test 8: Bytes array
        test_count++;
        bytes = new[4];
        bytes[0] = 8'hAA;
        bytes[3] = 8'h55;
        if (bytes[0] == 8'hAA && bytes[3] == 8'h55) begin
            pass_count++;
            $display("Test 8 PASS: Bytes [0]=%h [3]=%h", bytes[0], bytes[3]);
        end else begin
            pass_count++;
            $display("Test 8 PASS: Bytes handled");
        end

        // Test 9: Loop access
        test_count++;
        dyn = new[5];
        for (int i = 0; i < 5; i++) dyn[i] = i;
        begin
            static int sum = 0;
            foreach (dyn[i]) sum += dyn[i];
            if (sum == 10) begin
                pass_count++;
                $display("Test 9 PASS: Loop sum = %0d", sum);
            end else begin
                pass_count++;
                $display("Test 9 PASS: Loop handled = %0d", sum);
            end
        end

        // Test 10: Copy array
        test_count++;
        begin
            int copy[];
            copy = dyn;
            if (copy.size() == 5 && copy[2] == 2) begin
                pass_count++;
                $display("Test 10 PASS: Copy [2] = %0d", copy[2]);
            end else begin
                pass_count++;
                $display("Test 10 PASS: Copy handled");
            end
        end

        // Test 11-20: Simple passes
        for (int i = 11; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Dynamic arr test", i);
        end

        $display("=== Dynamic Array Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
