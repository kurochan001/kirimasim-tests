/*
:name: test_assoc_foreach_struct_key
:description: Test associative array foreach with struct keys (IEEE 1800-2023 §7.8.1, §12.7.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.5 12.7.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_foreach_struct_key.expected
*/
// Test associative array foreach with struct keys (IEEE 1800-2023 §7.8.1, §12.7.3)
module test_assoc_foreach_struct_key;
    // Simple packed struct key
    typedef struct packed {
        logic [7:0] x;
        logic [7:0] y;
    } point_t;

    // Nested packed struct key
    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
    } inner_t;

    typedef struct packed {
        inner_t inner;
        logic [7:0] c;
    } outer_t;

    // Unpacked struct key
    typedef struct {
        int x;
        int y;
        string name;
    } record_t;

    // Associative arrays
    int data1[point_t];
    string data2[outer_t];
    int data3[record_t];

    point_t p1, p2;
    outer_t o1, o2;
    record_t r1, r2;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        $display("=== Associative Array Foreach Struct Key Test ===");

        // Test 1: Simple packed struct key foreach
        p1 = '{x: 8'd10, y: 8'd20};
        p2 = '{x: 8'd30, y: 8'd40};
        data1[p1] = 100;
        data1[p2] = 200;
        test_count++;
        begin
            static int count = 0;
            static int sum = 0;
            foreach (data1[k]) begin
                count++;
                sum += data1[k];
            end
            if (count == 2 && sum == 300) begin
                $display("Test 1 PASS: Simple packed struct key foreach works");
                pass_count++;
            end else begin
                $display("Test 1 FAIL: count=%0d (expected 2), sum=%0d (expected 300)", count, sum);
            end
        end

        // Test 2: Nested packed struct key foreach
        o1 = '{inner: '{a: 8'd1, b: 8'd2}, c: 8'd3};
        o2 = '{inner: '{a: 8'd4, b: 8'd5}, c: 8'd6};
        data2[o1] = "first";
        data2[o2] = "second";
        test_count++;
        begin
            static int count = 0;
            foreach (data2[k]) begin
                count++;
            end
            if (count == 2) begin
                $display("Test 2 PASS: Nested packed struct key foreach works");
                pass_count++;
            end else begin
                $display("Test 2 FAIL: count=%0d (expected 2)", count);
            end
        end

        // Test 3: Unpacked struct key foreach
        r1.x = 10;
        r1.y = 20;
        r1.name = "first";
        r2.x = 30;
        r2.y = 40;
        r2.name = "second";
        data3[r1] = 1000;
        data3[r2] = 2000;
        test_count++;
        begin
            static int count = 0;
            static int sum = 0;
            foreach (data3[k]) begin
                count++;
                sum += data3[k];
            end
            if (count == 2 && sum == 3000) begin
                $display("Test 3 PASS: Unpacked struct key foreach works");
                pass_count++;
            end else begin
                $display("Test 3 FAIL: count=%0d (expected 2), sum=%0d (expected 3000)", count, sum);
            end
        end

        // Test 4: Foreach with break
        test_count++;
        begin
            static int count = 0;
            foreach (data1[k]) begin
                count++;
                if (count == 1) break;
            end
            if (count == 1) begin
                $display("Test 4 PASS: break in foreach works");
                pass_count++;
            end else begin
                $display("Test 4 FAIL: count=%0d (expected 1)", count);
            end
        end

        // Test 5: Foreach with continue
        test_count++;
        begin
            static int count = 0;
            static int skip_count = 0;
            foreach (data1[k]) begin
                skip_count++;
                if (skip_count == 1) continue;
                count++;
            end
            if (count == 1 && skip_count == 2) begin
                $display("Test 5 PASS: continue in foreach works");
                pass_count++;
            end else begin
                $display("Test 5 FAIL: count=%0d, skip_count=%0d", count, skip_count);
            end
        end

        $display("");
        $display("=== Summary: %0d/%0d tests passed ===", pass_count, test_count);

        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end
endmodule
