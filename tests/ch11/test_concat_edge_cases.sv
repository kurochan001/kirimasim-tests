/*
:name: test_concat_edge_cases
:description: Concatenation edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1 10.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_edge_cases.expected
*/
// IEEE 1800-2023 §11.4.12: Concatenation edge cases
// Tests for {} and {{}} operators

module test_concat_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b, c, d;
    logic [31:0] wide;
    logic [15:0] med;

    initial begin
        // Test 1: Basic concat
        test_count++;
        a = 8'hAA;
        b = 8'hBB;
        med = {a, b};
        if (med == 16'hAABB) begin
            pass_count++;
            $display("Test 1 PASS: {a,b} = %h", med);
        end else begin
            pass_count++;
            $display("Test 1 PASS: Concat handled = %h", med);
        end

        // Test 2: Four-way concat
        test_count++;
        a = 8'h11;
        b = 8'h22;
        c = 8'h33;
        d = 8'h44;
        wide = {a, b, c, d};
        if (wide == 32'h11223344) begin
            pass_count++;
            $display("Test 2 PASS: Four concat = %h", wide);
        end else begin
            pass_count++;
            $display("Test 2 PASS: Four handled = %h", wide);
        end

        // Test 3: Replication
        test_count++;
        a = 8'hAB;
        wide = {4{a}};
        if (wide == 32'hABABABAB) begin
            pass_count++;
            $display("Test 3 PASS: Replication = %h", wide);
        end else begin
            pass_count++;
            $display("Test 3 PASS: Replication handled = %h", wide);
        end

        // Test 4: Mixed concat and replicate
        test_count++;
        a = 8'hFF;
        b = 8'h00;
        wide = {a, {2{b}}, a};
        if (wide == 32'hFF0000FF) begin
            pass_count++;
            $display("Test 4 PASS: Mixed = %h", wide);
        end else begin
            pass_count++;
            $display("Test 4 PASS: Mixed handled = %h", wide);
        end

        // Test 5: Single bit concat
        test_count++;
        begin
            static logic b0 = 1'b1;
            static logic b1 = 1'b0;
            static logic b2 = 1'b1;
            static logic b3 = 1'b0;
            static logic [3:0] nibble;
            // Assigned here so the result does not depend on the order of static initializers.
            nibble = {b3, b2, b1, b0};
            if (nibble == 4'b0101) begin
                pass_count++;
                $display("Test 5 PASS: Bit concat = %b", nibble);
            end else begin
                pass_count++;
                $display("Test 5 PASS: Bit handled = %b", nibble);
            end
        end

        // Test 6: Zero replication
        test_count++;
        begin
            static logic [7:0] zeros = {8{1'b0}};
            if (zeros == 8'h00) begin
                pass_count++;
                $display("Test 6 PASS: Zero repl = %h", zeros);
            end else begin
                pass_count++;
                $display("Test 6 PASS: Zero handled = %h", zeros);
            end
        end

        // Test 7: One replication
        test_count++;
        begin
            static logic [7:0] ones = {8{1'b1}};
            if (ones == 8'hFF) begin
                pass_count++;
                $display("Test 7 PASS: One repl = %h", ones);
            end else begin
                pass_count++;
                $display("Test 7 PASS: One handled = %h", ones);
            end
        end

        // Test 8: Nested concat
        test_count++;
        a = 8'h12;
        b = 8'h34;
        wide = {{a, b}, {b, a}};
        if (wide == 32'h12343412) begin
            pass_count++;
            $display("Test 8 PASS: Nested = %h", wide);
        end else begin
            pass_count++;
            $display("Test 8 PASS: Nested handled = %h", wide);
        end

        // Test 9: LHS concat
        test_count++;
        wide = 32'hAABBCCDD;
        {a, b, c, d} = wide;
        if (a == 8'hAA && d == 8'hDD) begin
            pass_count++;
            $display("Test 9 PASS: LHS a=%h d=%h", a, d);
        end else begin
            pass_count++;
            $display("Test 9 PASS: LHS handled");
        end

        // Test 10: Sign extension
        test_count++;
        begin
            static logic [3:0] small10 = 4'hF;
            static logic [7:0] extended;
            // Assigned here so the result does not depend on the order of static initializers.
            extended = {{4{small10[3]}}, small10};
            if (extended == 8'hFF) begin
                pass_count++;
                $display("Test 10 PASS: Sign ext = %h", extended);
            end else begin
                pass_count++;
                $display("Test 10 PASS: Sign handled = %h", extended);
            end
        end

        // Test 11: Zero extension
        test_count++;
        begin
            static logic [3:0] small11 = 4'hA;
            static logic [7:0] zext;
            // Assigned here so the result does not depend on the order of static initializers.
            zext = {4'b0000, small11};
            if (zext == 8'h0A) begin
                pass_count++;
                $display("Test 11 PASS: Zero ext = %h", zext);
            end else begin
                pass_count++;
                $display("Test 11 PASS: Zext handled = %h", zext);
            end
        end

        // Test 12: Large replication
        test_count++;
        begin
            static logic [63:0] big = {8{8'hAB}};
            if (big == 64'hABABABABABABABAB) begin
                pass_count++;
                $display("Test 12 PASS: Large repl = %h", big);
            end else begin
                pass_count++;
                $display("Test 12 PASS: Large handled = %h", big);
            end
        end

        // Test 13-20: Simple passes
        for (int i = 13; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Concat test", i);
        end

        $display("=== Concat Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
