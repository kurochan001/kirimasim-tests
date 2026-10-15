/*
:name: test_assoc_array_assign
:description: Test: Associative array assignment
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.8.1 7.8.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_assign.expected
*/
// Test: Associative array assignment

module test_assoc_array_assign;
    int pass_count = 0;
    int total_tests = 15;

    // Various associative array types
    int int_aa [int];           // int key, int value
    int str_key_aa [string];    // string key, int value
    string int_key_str_aa [int]; // int key, string value
    logic [7:0] byte_aa [logic [15:0]];  // 16-bit key, byte value

    typedef struct {
        int x;
        int y;
    } point_t;
    point_t struct_aa [string];

    int keys[$];
    string skeys[$];

    initial begin
        // Test 1: Simple int key assignment
        int_aa[10] = 100;
        int_aa[20] = 200;
        if (int_aa[10] == 100 && int_aa[20] == 200) begin
            pass_count++;
            $display("PASS: Int key assignment");
        end else $display("FAIL: Int key assignment");

        // Test 2: String key assignment
        str_key_aa["first"] = 1;
        str_key_aa["second"] = 2;
        if (str_key_aa["first"] == 1 && str_key_aa["second"] == 2) begin
            pass_count++;
            $display("PASS: String key assignment");
        end else $display("FAIL: String key assignment");

        // Test 3: String value assignment
        int_key_str_aa[0] = "zero";
        int_key_str_aa[1] = "one";
        if (int_key_str_aa[0] == "zero" && int_key_str_aa[1] == "one") begin
            pass_count++;
            $display("PASS: String value assignment");
        end else $display("FAIL: String value assignment");

        // Test 4: Wide key assignment
        byte_aa[16'hABCD] = 8'hEF;
        byte_aa[16'h1234] = 8'h56;
        if (byte_aa[16'hABCD] == 8'hEF && byte_aa[16'h1234] == 8'h56) begin
            pass_count++;
            $display("PASS: Wide key assignment");
        end else $display("FAIL: Wide key assignment");

        // Test 5: Overwrite existing key
        int_aa[10] = 999;
        if (int_aa[10] == 999) begin
            pass_count++;
            $display("PASS: Overwrite existing key");
        end else $display("FAIL: Overwrite existing key");

        // Test 6: Struct value assignment
        struct_aa["origin"].x = 0;
        struct_aa["origin"].y = 0;
        struct_aa["point1"].x = 10;
        struct_aa["point1"].y = 20;
        if (struct_aa["origin"].x == 0 && struct_aa["point1"].y == 20) begin
            pass_count++;
            $display("PASS: Struct value assignment");
        end else $display("FAIL: Struct value assignment");

        // Test 7: Compound assignment
        int_aa[30] = 100;
        int_aa[30] += 50;
        if (int_aa[30] == 150) begin
            pass_count++;
            $display("PASS: Compound assignment");
        end else $display("FAIL: Compound assignment");

        // Test 8: Assignment from expression
        int_aa[40] = int_aa[10] + int_aa[20];
        if (int_aa[40] == 1199) begin  // 999 + 200
            pass_count++;
            $display("PASS: Assignment from expression");
        end else $display("FAIL: Assignment from expression, got %0d", int_aa[40]);

        // Test 9: Loop assignment
        for (int i = 0; i < 5; i++) begin
            int_aa[i * 100] = i;
        end
        if (int_aa[0] == 0 && int_aa[400] == 4) begin
            pass_count++;
            $display("PASS: Loop assignment");
        end else $display("FAIL: Loop assignment");

        // Test 10: Negative key
        int_aa[-5] = -500;
        if (int_aa[-5] == -500) begin
            pass_count++;
            $display("PASS: Negative key assignment");
        end else $display("FAIL: Negative key assignment");

        // Test 11: Empty string key
        str_key_aa[""] = 0;
        if (str_key_aa[""] == 0) begin
            pass_count++;
            $display("PASS: Empty string key");
        end else $display("FAIL: Empty string key");

        // Test 12: Check exists after assignment
        int_aa.delete();  // Clear all
        int_aa[777] = 7;
        if (int_aa.exists(777) && !int_aa.exists(888)) begin
            pass_count++;
            $display("PASS: Exists after assignment");
        end else $display("FAIL: Exists after assignment");

        // Test 13: Assignment preserves other keys
        int_aa[100] = 1;
        int_aa[200] = 2;
        int_aa[300] = 3;
        int_aa[200] = 22;
        if (int_aa[100] == 1 && int_aa[200] == 22 && int_aa[300] == 3) begin
            pass_count++;
            $display("PASS: Preserves other keys");
        end else $display("FAIL: Preserves other keys");

        // Test 14: Struct field compound
        struct_aa["point1"].x += 5;
        if (struct_aa["point1"].x == 15) begin
            pass_count++;
            $display("PASS: Struct field compound");
        end else $display("FAIL: Struct field compound");

        // Test 15: Byte value bit-slice
        byte_aa[16'h0000] = 8'hAB;
        byte_aa[16'h0000][7:4] = 4'hF;
        if (byte_aa[16'h0000] == 8'hFB) begin
            pass_count++;
            $display("PASS: Byte value bit-slice");
        end else $display("FAIL: Byte value bit-slice, got %h", byte_aa[16'h0000]);

        if (pass_count == total_tests) $display("PASS: assoc_array_assign (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: assoc_array_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
