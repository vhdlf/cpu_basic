library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_bits.all;
use work.pkg_mem.all;
use work.pkg_cpu.all;



entity top is
port (
  clk:    in  std_logic;
  rst:    in  std_logic;
  run:    in  std_logic;
  mout:   in  mem_output;
  minp:   out mem_input;
  output: out cpu_output
);
end entity top;



architecture bh of top is
  signal xs: cpu_status;
  signal xi: cpu_internal;
begin

p_seq: process (clk, rst)
  variable s: cpu_status;
  variable i: cpu_internal;
  variable m: mem_output;
  variable vw:  word;
  variable vdw: dword;
  variable vd, vs, imm: word;
  variable zf, cf, sf:  std_logic;
begin

  -- reset? clean up
  if rst = '1' then
    s := xs;
    i := xi;
    
    -- clean up
    s.state := st_halted;
    s.regs  := (others => (others => '0'));
    s.flags := (others => '0');
    s.ip    := (others => '0');
    i.op    := (others => '0');
    i.rd    := (others => '0');
    i.rs    := (others => '0');
    i.imm   := (others => '0');
    i.addr  := (others => '0');
    i.data  := (others => '0');
    i.buff  := (others => '0');
    i.wr    := '0';
    
    -- drive signals
    xs <= s;
    xi <= i;
    
    -- drive output
    minp.addr <= i.addr;
    minp.data <= i.data;
    minp.wr   <= i.wr;
    output.state <= to_unsigned(cpu_state'pos(s.state), 4);
    output.ip    <= s.ip(15 downto 0);
  
  -- run? do something
  elsif rising_edge(clk) and run = '1' then
    s := xs;
    i := xi;
    m := mout;
    
    case s.state is
      -- was halted? start fetch
      when st_halted =>
        s.state := st_fetch0;
      
      -- request bytes 0-1
      when st_fetch0 =>
        i.addr  := s.ip(15 downto 0);
        s.state := st_fetch1;
      
      -- got bytes 0-1
      -- if short opcode, execute
      -- else request bytes 2-3
      when st_fetch1 =>
        i.op := m.data(7  downto 0);
        i.rd := m.data(11 downto 8);
        i.rs := m.data(15 downto 12);
        i.addr := i.addr + 2;
        case cpu_opcode'val(to_integer(i.op)) is
          when op_load |
               op_store |
               op_movi |
               op_jmp |
               op_jz |
               op_jnz |
               op_jb |
               op_jbe |
               op_jg |
               op_jge =>
            s.ip    := s.ip + 6;
            s.state := st_fetch2;
          when others =>
            s.ip    := s.ip + 2;
            s.state := st_execute;
        end case;
      
      -- got bytes 2-3
      -- request bytes 4-5
      when st_fetch2 =>
        i.imm(15 downto 0) := m.data;
        i.addr  := i.addr + 2;
        s.state := st_fetch3;
      
      -- got bytes 4-5
      -- start execution
      when st_fetch3 =>
        i.imm(31 downto 16) := m.data;    
        i.addr  := i.addr + 2;
        s.state := st_execute;
      
      -- got bytes 0-1
      -- request bytes 2-3
      when st_load0 =>
        i.buff(15 downto 0) := m.data;
        i.addr  := i.addr + 2;
        s.state := st_load1;
      
      -- got bytes 2-3
      -- set dest register
      -- fetch next instruction
      when st_load1 =>
        i.buff(31 downto 16) := m.data;
        s.regs(to_integer(i.rd)) := i.buff;
        i.addr  := i.addr + 2;
        s.state := st_fetch0;
      
      -- wrote bytes 0-1
      -- send bytes 2-3
      when st_store0 =>
        i.data  := i.buff(31 downto 16);
        i.addr  := i.addr + 2;
        s.state := st_store1;
      
      -- wrote bytes 2-3
      -- stop writing
      -- fetch next instruction
      when st_store1 =>
        i.wr    := '0';
        s.state := st_fetch0;
      
      -- execute instruction
      when st_execute =>
        vd  := s.regs(to_integer(i.rd));
        vs  := s.regs(to_integer(i.rs));
        imm := i.imm;
        zf := s.flags(cpu_flags'pos(fl_zero));
        sf := s.flags(cpu_flags'pos(fl_sign));
        cf := s.flags(cpu_flags'pos(fl_carry));
        
        case cpu_opcode'val(to_integer(i.op)) is
          -- load rd, [rs+imm]
          when op_load =>
            vw := vs + imm;
            i.addr  := vw(15 downto 0);
            s.state := st_load0;
          
          -- store [rd+imm], rs
          when op_store =>
            vw := vd + imm;
            i.addr := vw(15 downto 0);
            i.buff := vs;
            i.data := i.buff(15 downto 0);
            i.wr   := '1';
          
          -- movi rd, imm
          when op_movi =>
            vd := imm;
          
          -- mov rd, rs
          when op_mov =>
            vd := vs;
          
          -- cmp rd, rs
          when op_cmp =>
            vw := vd - vs;
            if vw = 0 then zf := '1'; else zf := '0'; end if;
            if vw < 0 then sf := '1'; else sf := '0'; end if;
            cf := '0'; -- v65(64);
          
          -- jmp imm
          when op_jmp =>
            s.ip := imm;
          
          -- jz imm
          when op_jz =>
            if zf = '1' then
              s.ip := imm;
            end if;
          
          -- jnz imm
          when op_jnz =>
            if zf = '0' then
              s.ip := imm;
            end if;
          
          -- jb imm
          when op_jb =>
            if sf = '1' and zf = '0' then
              s.ip := imm;
            end if;
          
          -- jbe imm
          when op_jbe =>
            if sf = '1' or zf = '1' then
              s.ip := imm;
            end if;
          
          -- jg imm
          when op_jg =>
            if sf = '0' and zf = '0' then
              s.ip := imm;
            end if;
          
          -- jge imm
          when op_jge =>
            if sf = '0' or zf = '1' then
              s.ip := imm;
            end if;
          
          -- add rd, rs
          when op_add =>
            vd := vd + vs;
          
          -- adc rd, rs
          --when op_adc =>
          --  if cf = '1' then vs := vs + 1; end if;
          --  vd := vd + vs;
          
          -- sub rd, rs
          when op_sub =>
            vd := vd - vs;
          
          -- sbb rd, rs
          --when op_sbb =>
          --  if cf = '1' then vs := vs - 1; end if;
          --  vd := vd - vs;
          
          -- mul rd, rs
          when op_mul =>
            vdw := vd * vs;
            vd := vdw(31 downto 0);
          
          -- imul rd, rs
          --when op_imul =>
          --  v128 := vd * vs;
          --  vd := v128(63 downto 0);
          
          -- div rd, rs
          when op_div =>
            vd := vd / vs;
          
          -- idiv rd, rs
          --when op_idiv =>
          --  vd := vd / vs;
          
          -- and rd, rs
          when op_and =>
            vd := vd and vs;
          
          -- or rd, rs
          when op_or =>
            vd := vd or vs;
          
          -- not rd
          when op_not =>
            vd := not vd;
          
          -- xor rd, rs
          when op_xor =>
            vd := vd xor vs;
          
          -- shl rd, rs
          --when op_shl =>
          --  vd := shift_left(vd, to_integer(vs));
          
          -- shr rd, rs
          --when op_shr =>
          --  vd := shift_right(vd, to_integer(vs));
          
          -- rol rd, rs
          --when op_rol =>
          --  vd := shift_left(vd, to_integer(vs));
          
          -- ror rd, rs
          --when op_ror =>
          --  vd := shift_right(vd, to_integer(vs));
          
          -- invalid
          when others =>
            s.state := st_halted;
        end case;
        s.flags(cpu_flags'pos(fl_carry)) := cf;
        s.flags(cpu_flags'pos(fl_sign))  := sf;
        s.flags(cpu_flags'pos(fl_zero))  := zf;
        s.regs(to_integer(i.rd)) := vd;
        
      -- invalid state
      when others =>
        s.state := st_halted;
    end case;
    
    -- drive status
    xi <= i;
    xs <= s;

    -- drive outputs
    minp.addr <= i.addr;
    minp.data <= i.data;
    minp.wr   <= i.wr;
    output.state <= to_unsigned(cpu_state'pos(s.state), 4);
    output.ip    <= s.ip(15 downto 0);
  end if;
end process;

end architecture bh;
