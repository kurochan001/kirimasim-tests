/*
:name: test_member_access_patterns
:description: Member Access Patterns Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.4 7.10 6.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access_patterns.expected
*/
// IEEE 1800-2023 Section 11.4 - Member Access Patterns Tests
// Tests: Struct member access, array element access, method chaining

module test_member_access_patterns;
    int pass_count = 0;
    int fail_count = 0;

    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
        logic [7:0] c;
    } inner_t;

    typedef struct packed {
        inner_t inner;
        logic [7:0] d;
    } outer_t;

    outer_t data;
    logic [7:0] arr [4];
    logic [31:0] packed_arr;
    int queue_data[$];
    string str;

    initial begin
        $display("=== IEEE 1800-2023 Member Access Patterns Tests ===");

        // Test 1: Simple struct member access
        $display("Test 1: Simple struct member access");
        data.d = 8'hAB;
        if (data.d == 8'hAB) begin
            $display("Test 1 PASS: data.d=%h", data.d);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Nested struct member access
        $display("Test 2: Nested struct member access");
        data.inner.a = 8'h11;
        data.inner.b = 8'h22;
        data.inner.c = 8'h33;
        if (data.inner.a == 8'h11 && data.inner.b == 8'h22) begin
            $display("Test 2 PASS: inner.a=%h, inner.b=%h", data.inner.a, data.inner.b);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Array element access
        $display("Test 3: Array element access");
        arr[0] = 8'h10;
        arr[1] = 8'h20;
        arr[2] = 8'h30;
        arr[3] = 8'h40;
        if (arr[2] == 8'h30) begin
            $display("Test 3 PASS: arr[2]=%h", arr[2]);
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Bit select
        $display("Test 4: Bit select");
        packed_arr = 32'hCAFEBABE;
        if (packed_arr[7:0] == 8'hBE) begin
            $display("Test 4 PASS: packed_arr[7:0]=%h", packed_arr[7:0]);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Queue element access
        $display("Test 5: Queue element access");
        queue_data.push_back(100);
        queue_data.push_back(200);
        queue_data.push_back(300);
        if (queue_data[1] == 200) begin
            $display("Test 5 PASS: queue_data[1]=%0d", queue_data[1]);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: String method access
        $display("Test 6: String method access");
        str = "Hello";
        if (str.len() == 5) begin
            $display("Test 6 PASS: str.len()=%0d", str.len());
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Queue size method
        $display("Test 7: Queue size method");
        if (queue_data.size() == 3) begin
            $display("Test 7 PASS: queue_data.size()=%0d", queue_data.size());
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Nested array index
        $display("Test 8: Variable index access");
        begin
            static int idx = 2;
            if (arr[idx] == 8'h30) begin
                $display("Test 8 PASS: arr[idx]=%h", arr[idx]);
                pass_count++;
            end else begin
                $display("Test 8 FAIL");
                fail_count++;
            end
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
