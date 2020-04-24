library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_cpu.all;



entity top is
port (
  clk:   in  std_logic;
  rst:   in  std_logic;
  run:   in  std_logic;
  mout:  in  bits16;
  minp:  out bits16;
  maddr: out bits16;
  mwr:   out std_logic;
  state: out cpu_state;
  regs:  out cpu_registers;
  flags: out bits64;
  ip:    out bits64
);
end entity top;



architecture bh of top is
  signal s: cpu_state;
  signal r: cpu_registers;
  signal f: bits64; -- flags
  signal i: bits64; -- ip
  signal d: cpu_instruction;
  signal a: bits64; -- addr
  signal b: bits64; -- buff
  signal w: std_logic; -- wr
begin

p_seq: process (clk, rst)
begin
  if rst = '1' then
    s <= st_halted;
    r <= (others => '0');
    f <= (others => '0');
    i <= (others => '0');
    d <= (others => '0');
    a <= (others => '0');
    b <= (others => '0');
    w <= '0';
  elsif run = '0' then
    s <= std_paused;
  else
    case s is
      when st_halted | st_paused =>
      when st_fetch0 =>
        a <= i;
        s <= st_fetch1;
      when st_fetch1 =>
        d.op <= mout(7 downto 0);
        d.rd <= mout(11 downto 8);
        d.rs <= mout(15 downto 12);
        a <= a + 2;
        case d.op is
          when op_load | op_store | op_movi =>
            s <= st_fetch2;
          when op_jmp | op_jz | op_jnz | op_jb | op_jbe | op_jg | op_jge =>
            s <= st_fetch2;
          when others =>
            s <= st_execute0;
      when st_fetch2 =>
        d.imm(15 downto 0) <= mout;
        a <= a + 2;
        s <= st_fetch3;
      when st_fetch3 =>
        d.imm(31 downto 16) <= mout;
        a <= a + 2;
        s <= st_fetch4;
      when st_fetch4 =>
        d.imm(47 downto 32) <= mout;
        a <= a + 2;
        s <= st_fetch5;
      when st_fetch5 =>
        d.imm(63 downto 48) <= mout;    
        a <= a + 2;
        s <= st_execute0;
      when st_load0 =>
        b(15 downto 0) <= mout;
        a <= a + 2;
        s <= st_load1;
      when st_load1 =>
        b(31 downto 16) <= mout;
        a <= a + 2;
        s <= st_load1;
      when st_load2 =>
        b(47 downto 32) <= mout;
        a <= a + 2;
        s <= st_load3;
      when st_load3 =>
        b(63 downto 48) <= mout;
        a <= a + 2;
        s <= st_execute1;
      when st_store0 =>
        minp <= b(31 downto 16);
        a <= a + 2;
        s <= st_store1;
      when st_store1 =>
        minp <= b(47 downto 32);
        a <= a + 2;
        s <= st_store2;
      when st_store2 =>
        minp <= b(63 downto 48);
        a <= a + 2;
        s <= st_store3;
      when st_store3 =>
        w <= '0';
        s <= st_fetch0;
      when st_execute0 =>
        case d.op is
          when op_load =>
            a <= r(d.rs) + d.imm;
            s <= st_load0;
          when op_store =>
            a <= r(d.rd) + d.imm;
            b <= r(d.rs);
            minp <= b(15 downto 0);
            w <= '1';
          when op_movi =>
            r(d.rd) <= d.imm;
          when op_mov =>
            r(d.rd) <= r(d.rs);
          when op_cmp =>
            b <= r(d.rd) - r(d.rs);
            flags(f_zero)  = '1' when b = 0 else '0';
            flags(f_sign)  = '1' when b < 0 else '0';
            flags(f_carry) = b(64);
          when op_jmp =>
            ip <= d.imm;
          when op_jz =>
            ip <= d.imm when flags(f_zero) = '1' else ip;
          when op_jnz =>
            ip <= d.imm when flags(f_zero) = '0' else ip;
          when op_jb =>
            ip <= d.imm when flags(f_sign) = '1' else ip;
          when op_jbe =>
            ip <= d.imm when flags(f_sign) = '1' or flags(f_zero) = '1' else ip;
          when op_jg =>
            ip <= d.imm when flags(f_sign) = '0' else ip;
          when op_jge =>
            ip <= d.imm when flags(f_sign) = '0' or flags(f_zero) = '1' else ip;
          when op_add =>
            r(d.rd) <= r(d.rd) + r(d.rs);
          when op_adc =>
            r(d.rd) <= r(d.rd) + r(d.rs) + flags(f_carry);
          when op_sub =>
            r(d.rd) <= r(d.rd) - r(d.rs);
          when op_sbb =>
            r(d.rd) <= r(d.rd) - r(d.rs) - flags(f_carry);
          when op_mul =>
            r(d.rd) <= r(d.rd) * r(d.rs);
          when op_imul =>
            r(d.rd) <= r(d.rd) * r(d.rs);
          when op_div =>
            r(d.rd) <= r(d.rd) / r(d.rs);
          when op_idiv =>
            r(d.rd) <= r(d.rd) / r(d.rs);
          when op_and =>
            r(d.rd) <= r(d.rd) and r(d.rs);
          when op_or =>
            r(d.rd) <= r(d.rd) or r(d.rs);
          when op_not =>
            r(d.rd) <= not r(d.rd);
          when op_xor =>
            r(d.rd) <= r(d.rd) xor r(d.rs);
          when op_shl =>
            r(d.rd) <= shift_left(r(d.rd), r(d.rs));
          when op_shr =>
            r(d.rd) <= shift_right(r(d.rd), r(d.rs));
          when op_rol =>
            r(d.rd) <= shift_left(r(d.rd), r(d.rs));
          when op_ror =>
            r(d.rd) <= shift_right(r(d.rd), r(d.rs));
          when others =>
            s <= st_halted;
        end case;
      when st_execute1 =>
        r(d.rd) <= b;
        s <= st_fetch0;
      when others =>
        s <= st_halted;
    end case;
  end if;
end process;

end architecture bh;
