/*
:name: test_type_check_edge_cases
:description: Type checking edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1 20.6.2 6.23
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_check_edge_cases.expected
*/
// IEEE 1800-2023 §6.24.2: Type checking edge cases
// Tests for $typename, $bits, type comparisons.
// The spacing of packed ranges in $typename strings is not settled by the
// examples in 20.6.1, so those results are compared with $typename of an
// equivalent type instead of a literal string.

module test_type_check_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    typedef logic [7:0] byte_t;
    typedef int signed_int;
    typedef struct packed {
        logic [3:0] upper;
        logic [3:0] lower;
    } nibble_pair_t;

    int int_var;
    logic [31:0] logic_var;
    byte_t byte_var;
    nibble_pair_t struct_var;
    real real_var;
    string str_var;

    initial begin
        // Test 1: $bits of int
        test_count++;
        if ($bits(int_var) == 32) begin
            pass_count++;
            $display("Test 1 PASS: $bits(int) = %0d", $bits(int_var));
        end else begin
            $display("Test 1 FAIL: bits int unexpected = %0d", $bits(int_var));
        end

        // Test 2: $bits of logic
        test_count++;
        if ($bits(logic_var) == 32) begin
            pass_count++;
            $display("Test 2 PASS: $bits(logic[31:0]) = %0d", $bits(logic_var));
        end else begin
            $display("Test 2 FAIL: bits logic unexpected");
        end

        // Test 3: $bits of typedef
        test_count++;
        if ($bits(byte_var) == 8) begin
            pass_count++;
            $display("Test 3 PASS: $bits(byte_t) = %0d", $bits(byte_var));
        end else begin
            $display("Test 3 FAIL: bits typedef unexpected");
        end

        // Test 4: $bits of struct
        test_count++;
        if ($bits(struct_var) == 8) begin
            pass_count++;
            $display("Test 4 PASS: $bits(struct) = %0d", $bits(struct_var));
        end else begin
            $display("Test 4 FAIL: bits struct unexpected = %0d", $bits(struct_var));
        end

        // Test 5: $typename of int
        test_count++;
        begin
            static string tn;
            // Assigned here so the result does not depend on the order of static initializers.
            tn = $typename(int_var);
            if (tn == "int") begin
                pass_count++;
                $display("Test 5 PASS: $typename(int)");
            end else begin
                $display("Test 5 FAIL: got %s", tn);
            end
        end

        // Test 6: $typename of logic
        test_count++;
        begin
            static string tn;
            // Assigned here so the result does not depend on the order of static initializers.
            tn = $typename(logic_var);
            if (tn == $typename(logic [31:0]) && tn != $typename(bit [31:0])) begin
                pass_count++;
                $display("Test 6 PASS: $typename(logic [31:0]) differs from bit [31:0]");
            end else begin
                $display("Test 6 FAIL: got %s", tn);
            end
        end

        // Test 7: $typename of typedef
        test_count++;
        begin
            static string tn;
            // Assigned here so the result does not depend on the order of static initializers.
            tn = $typename(byte_var);
            if (tn == $typename(logic [7:0])) begin
                pass_count++;
                $display("Test 7 PASS: $typename(byte_t) resolves to logic [7:0]");
            end else begin
                $display("Test 7 FAIL: got %s", tn);
            end
        end

        // Test 8: $typename of struct
        test_count++;
        begin
            static string tn;
            // Assigned here so the result does not depend on the order of static initializers.
            tn = $typename(struct_var);
            if (tn == $typename(nibble_pair_t) && tn != $typename(logic [7:0])) begin
                pass_count++;
                $display("Test 8 PASS: $typename(struct) is the struct type");
            end else begin
                $display("Test 8 FAIL: got %s", tn);
            end
        end

        // Test 9: $typename of real
        test_count++;
        begin
            static string tn;
            // Assigned here so the result does not depend on the order of static initializers.
            tn = $typename(real_var);
            if (tn == "real") begin
                pass_count++;
                $display("Test 9 PASS: $typename(real)");
            end else begin
                $display("Test 9 FAIL: got %s", tn);
            end
        end

        // Test 10: $typename of string
        test_count++;
        begin
            static string tn;
            // Assigned here so the result does not depend on the order of static initializers.
            tn = $typename(str_var);
            if (tn == "string") begin
                pass_count++;
                $display("Test 10 PASS: $typename(string)");
            end else begin
                $display("Test 10 FAIL: got %s", tn);
            end
        end

        // Test 11: type() operator
        test_count++;
        begin
            typedef type(int_var) int_type;
            static int_type x = 42;
            if (x == 42) begin
                pass_count++;
                $display("Test 11 PASS: type() = %0d", x);
            end else begin
                $display("Test 11 FAIL: type() unexpected");
            end
        end

        // Test 12: Struct access after type check
        test_count++;
        struct_var.upper = 4'hA;
        struct_var.lower = 4'hB;
        if (struct_var == 8'hAB) begin
            pass_count++;
            $display("Test 12 PASS: struct = %h", struct_var);
        end else begin
            $display("Test 12 FAIL: struct unexpected = %h", struct_var);
        end

        $display("=== Type Check Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
