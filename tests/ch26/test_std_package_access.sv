/*
:name: test_std_package_access
:description: the built-in std package is wildcard imported into every compilation unit, so its classes and functions are visible without a prefix unless user code declares the same name, and std:: always reaches them (IEEE 1800-2023 Section 26.7)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.7 26.3 3.12.1 15.3 15.4 9.7 18.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_package_access.expected
*/
// IEEE 1800-2023 §26.7: the std package is implicitly wildcard imported into
// the compilation-unit scope (§3.12.1), so its declarations are visible in
// every scope unless user code redefines them, and std::name reaches them
// unambiguously. A user class named mailbox in the compilation unit is a local
// declaration and hides the imported one (§26.3), so mailbox names the user
// class while std::mailbox (§15.4) is the built-in one. semaphore (§15.3),
// process (§9.7) and randomize (§18.12) are not redefined and can be used with
// or without the std:: prefix.

class mailbox;
  int n = 42;
  function int num();
    return -1;
  endfunction
endclass

module test_std_package_access;
  mailbox m_user;
  std::mailbox #(int) m_std;
  semaphore s1;
  std::semaphore s2;
  process p1;
  std::process p2;
  int x;

  initial begin
    m_user = new;
    m_std = new;
    m_std.put(5);
    $display("mailbox: n = %0d, num() = %0d", m_user.n, m_user.num());
    $display("std::mailbox: num() = %0d", m_std.num());
    s1 = new(1);
    s2 = new(0);
    $display("semaphore: %0d, std::semaphore: %0d", s1.try_get(), s2.try_get());
    p1 = process::self();
    p2 = std::process::self();
    $display("same process: %0d, running: %0d", p1 == p2, p2.status() == std::process::RUNNING);
    $display("std::randomize: %0d", std::randomize(x) with { x inside {[3:4]}; });
    $display("x in range: %0d", x inside {[3:4]});
  end
endmodule
