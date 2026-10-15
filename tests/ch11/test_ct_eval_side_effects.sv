/*
:name: test_ct_eval_side_effects
:description: Functions for testing
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1 11.4.2 13.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ct_eval_side_effects.expected
*/
module test_ct_eval_side_effects;
    int pass_count = 0;
    int test_count = 14;

    // Functions for testing
    function automatic int compute(int a, int b);
        return a * b + 1;
    endfunction

    function automatic int accumulate(int arr[], int size);
        int sum = 0;
        for (int i = 0; i < size; i++) sum += arr[i];
        return sum;
    endfunction

    // Tasks declared in the module
    task automatic t7_double_val(ref int v);
        v = v * 2;
    endtask

    task automatic t8_set_point(output int ox, output int oy);
        ox = 10;
        oy = 20;
    endtask

    // Continuous assign with function
    wire [7:0] func_in;
    wire [7:0] func_out;
    assign func_in = 8'd10;
    assign func_out = func_in * 2 + 1;

    initial begin
        // T1: Sum of two array elements
        begin
            static int arr[4] = '{10, 20, 30, 40};
            int val;
            val = arr[1] + arr[2];
            if (val == 50) begin
                $display("T1: PASS - sum of elements val=%0d", val);
                pass_count++;
            end else
                $display("T1: FAIL - val=%0d", val);
        end

        // T2: Write-back with intermediate evaluation
        begin
            static int q[$] = '{1, 2, 3};
            static int sum = 0;
            foreach (q[i]) sum += q[i];
            q.push_back(sum);
            if (q.size() == 4 && q[3] == 6) begin
                $display("T2: PASS - pushed sum q[3]=%0d", q[3]);
                pass_count++;
            end else
                $display("T2: FAIL - size=%0d q[3]=%0d", q.size(), q[3]);
        end

        // T3: Compound assignment on array elements
        begin
            static int arr[5] = '{1, 2, 3, 4, 5};
            for (int i = 0; i < 5; i++) arr[i] *= 2;
            if (arr[0] == 2 && arr[1] == 4 && arr[2] == 6 &&
                arr[3] == 8 && arr[4] == 10) begin
                $display("T3: PASS - compound assign");
                pass_count++;
            end else
                $display("T3: FAIL");
        end

        // T4: Compound assignment +=
        begin
            static int val = 10;
            val += 5;
            val += 3;
            if (val == 18) begin
                $display("T4: PASS - += chain val=%0d", val);
                pass_count++;
            end else
                $display("T4: FAIL - val=%0d", val);
        end

        // T5: Pre-increment in expression
        begin
            static int a = 5;
            int b;
            b = ++a * 2;
            if (a == 6 && b == 12) begin
                $display("T5: PASS - pre-inc a=%0d b=%0d", a, b);
                pass_count++;
            end else
                $display("T5: FAIL - a=%0d b=%0d", a, b);
        end

        // T6: Post-increment in expression
        begin
            static int a = 5;
            int b;
            b = a++ * 2;
            if (a == 6 && b == 10) begin
                $display("T6: PASS - post-inc a=%0d b=%0d", a, b);
                pass_count++;
            end else
                $display("T6: FAIL - a=%0d b=%0d", a, b);
        end

        // T7: ref argument updates the caller variable
        begin
            static int x = 21;
            t7_double_val(x);
            if (x == 42) begin
                $display("T7: PASS - task ref x=%0d", x);
                pass_count++;
            end else
                $display("T7: FAIL - x=%0d", x);
        end

        // T9: Multiple side effects in one statement
        begin
            static int a = 1, b = 1;
            a = a + (b = b + 1);
            if (a == 3 && b == 2) begin
                $display("T9: PASS - multiple side effects a=%0d b=%0d", a, b);
                pass_count++;
            end else
                $display("T9: FAIL - a=%0d b=%0d", a, b);
        end

        // T10: Function in continuous assign
        #1;
        if (func_out == 21) begin
            $display("T10: PASS - continuous assign func_out=%0d", func_out);
            pass_count++;
        end else
            $display("T10: FAIL - func_out=%0d", func_out);

        // T11: Chained method calls on string
        begin
            static string s = "Hello World";
            static int len;
            static string lower;
            // Assigned here so the result does not depend on the order of static initializers.
            len = s.len();
            lower = s.tolower();
            if (len == 11 && lower == "hello world") begin
                $display("T11: PASS - string methods len=%0d", len);
                pass_count++;
            end else
                $display("T11: FAIL - len=%0d lower='%s'", len, lower);
        end

        // T12: String method getc/putc
        begin
            static string s = "abc";
            static byte c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = s.getc(1);
            if (c == "b") begin
                s.putc(1, "x");
                if (s == "axc") begin
                    $display("T12: PASS - getc/putc '%s'", s);
                    pass_count++;
                end else
                    $display("T12: FAIL - putc s='%s'", s);
            end else
                $display("T12: FAIL - getc=%0d", c);
        end

        // T13: Array element compound assignment
        begin
            static int arr[3] = '{10, 20, 30};
            arr[0] += 5;
            arr[1] -= 10;
            arr[2] *= 2;
            if (arr[0] == 15 && arr[1] == 10 && arr[2] == 60) begin
                $display("T13: PASS - array compound assign");
                pass_count++;
            end else
                $display("T13: FAIL");
        end

        // T14: Pre/post decrement
        begin
            static int a = 10;
            static int b;
            static int c;
            // Assigned here so the result does not depend on the order of static initializers.
            b = a--;
            c = --a;
            if (b == 10 && a == 8 && c == 8) begin
                $display("T14: PASS - pre/post decrement a=%0d b=%0d c=%0d", a, b, c);
                pass_count++;
            end else
                $display("T14: FAIL - a=%0d b=%0d c=%0d", a, b, c);
        end

        // T15: Compound assign with bitwise ops
        begin
            static logic [7:0] val = 8'hFF;
            val &= 8'h0F;
            if (val == 8'h0F) begin
                val |= 8'hF0;
                if (val == 8'hFF) begin
                    val ^= 8'hAA;
                    if (val == 8'h55) begin
                        $display("T15: PASS - bitwise compound val=%0h", val);
                        pass_count++;
                    end else
                        $display("T15: FAIL - xor val=%0h", val);
                end else
                    $display("T15: FAIL - or val=%0h", val);
            end else
                $display("T15: FAIL - and val=%0h", val);
        end

        $display("pass_count = %0d / %0d", pass_count, test_count);
        if (pass_count == test_count)
            $display("PASS: test_ct_eval_side_effects");
        else
            $display("FAIL: test_ct_eval_side_effects (pass_count=%0d/%0d)", pass_count, test_count);
        $finish;
    end
endmodule
