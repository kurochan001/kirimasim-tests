/*
:name: test_comb_array_reduce_sort
:description: Test: Array reduction methods (sum/product/and/or/xor), shuffle, sort, unique
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1 7.12.2 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_array_reduce_sort.expected
*/
// Test: Array reduction methods (sum/product/and/or/xor), shuffle, sort, unique
module test_comb_array_reduce_sort;
    int pass_count;

    initial begin
        pass_count = 0;

        // Test 1: Queue sum()
        begin
            static int q[$] = '{10, 20, 30, 40};
            static int s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = q.sum();
            if (s == 100) pass_count++;
        end

        // Test 2: Queue product()
        begin
            static int q[$] = '{2, 3, 5};
            static int p;
            // Assigned here so the result does not depend on the order of static initializers.
            p = q.product();
            if (p == 30) pass_count++;
        end

        // Test 3: Dynamic array sum
        begin
            int da[];
            da = new[4];
            da[0] = 5; da[1] = 10; da[2] = 15; da[3] = 20;
            if (da.sum() == 50) pass_count++;
        end

        // Test 4: Array and() reduction
        begin
            static logic [7:0] arr[$] = '{8'hFF, 8'hF0, 8'hFE};
            static logic [7:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = arr.and();
            if (r == 8'hF0) pass_count++;
        end

        // Test 5: Array or() reduction
        begin
            static logic [7:0] arr[$] = '{8'h01, 8'h10, 8'h80};
            static logic [7:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = arr.or();
            if (r == 8'h91) pass_count++;
        end

        // Test 6: Array xor() reduction
        begin
            static logic [7:0] arr[$] = '{8'hFF, 8'h0F};
            static logic [7:0] r;
            // Assigned here so the result does not depend on the order of static initializers.
            r = arr.xor();
            if (r == 8'hF0) pass_count++;
        end

        // Test 7: Sort ascending
        begin
            static int q[$] = '{30, 10, 50, 20, 40};
            q.sort();
            if (q[0] == 10 && q[4] == 50) pass_count++;
        end

        // Test 8: Reverse sort
        begin
            static int q[$] = '{30, 10, 50, 20, 40};
            q.rsort();
            if (q[0] == 50 && q[4] == 10) pass_count++;
        end

        // Test 9: Shuffle
        begin
            static int q[$] = '{1, 2, 3, 4, 5, 6, 7, 8};
            static int orig_sum;
            // Assigned here so the result does not depend on the order of static initializers.
            orig_sum = q.sum();
            q.shuffle();
            // Sum should be preserved after shuffle
            if (q.sum() == orig_sum) pass_count++;
        end

        // Test 10: Unique
        begin
            static int q[$] = '{1, 2, 3, 2, 1, 4, 3};
            static int u[$];
            // Assigned here so the result does not depend on the order of static initializers.
            u = q.unique();
            // unique should have 4 distinct elements
            if (u.size() == 4) pass_count++;
        end

        // Test 11: Min/max
        begin
            static int q[$] = '{42, 7, 99, 3, 55};
            static int mn[$];
            static int mx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            mn = q.min();
            mx = q.max();
            if (mn[0] == 3 && mx[0] == 99) pass_count++;
        end

        // Test 12: Find with condition
        begin
            static int q[$] = '{5, 12, 3, 18, 7, 25};
            static int found[$];
            // Assigned here so the result does not depend on the order of static initializers.
            found = q.find() with (item > 10);
            if (found.size() == 3) pass_count++;  // 12, 18, 25
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count >= 12)
            $display("PASS: test_comb_array_reduce_sort");
        else
            $display("FAIL: test_comb_array_reduce_sort (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
