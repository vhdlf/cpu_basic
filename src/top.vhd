library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_bits.all;
use work.pkg_mem.all;
use work.pkg_cpu.all;
use work.pkg_report.all;



entity top is
port (
  clk:  in  std_logic;
  rst:  in  std_logic;
  run:  in  std_logic;
  mout: in  mem_output;
  minp: out mem_input;
  cout: out cpu_output
);
end entity top;



architecture bh of top is
  signal xi: cpu_internal;
begin

p_seq: process (clk, rst, run, xi)
  variable i: cpu_internal;
  variable m: mem_output;
  variable vw:  word;
  variable vdw: dword;
  variable vd, vs, imm: word;
  variable zf, cf, sf:  std_logic;
begin

  -- reset? clean up
  if rst = '1' then
    i := xi;
    
    -- clean up
    i.state := st_halted;
    i.regs  := (others => (others => '0'));
    i.flags := (others => '0');
    i.ip    := (others => '0');
    i.op    := (others => '0');
    i.rd    := (others => '0');
    i.rs    := (others => '0');
    i.imm   := (others => '0');
    i.addr  := (others => '0');
    i.data  := (others => '0');
    i.buff  := (others => '0');
    i.wr    := '0';
    
    -- drive signals
    xi <= i;
    
    -- drive output
    minp.addr <= i.addr;
    minp.data <= i.data;
    minp.wr   <= i.wr;
    cout.state <= to_unsigned(cpu_state'pos(i.state), 4);
    cout.ip    <= i.ip(7 downto 0);
    cout.op <= i.op;
    cout.rd <= i.rd;
    cout.rs <= i.rs;
  
  -- run? do something
  elsif rising_edge(clk) then
    i := xi;
    m := mout;
    
    case i.state is
      -- was halted? start fetch
      when st_halted =>
        if run = '1' then i.state := st_fetch0; end if;
      
      -- request bytes 0-1
      when st_fetch0 =>
        i.addr  := i.ip(15 downto 0);
        i.state := st_fetch1;
      
      -- got bytes 0-1
      -- if short opcode, execute
      -- else request bytes 2-3
      when st_fetch1 =>
        i.op := m.data(7  downto 0);
        i.rd := m.data(11 downto 8);
        i.rs := m.data(15 downto 12);
        i.addr := i.addr + 2;
        case i.op is
          when OP_LOAD |
               OP_STORE |
               OP_MOVI |
               OP_JMP |
               OP_JZ |
               OP_JNZ |
               OP_JB |
               OP_JBE |
               OP_JG |
               OP_JGE =>
            i.ip    := i.ip + 6;
            i.state := st_fetch2;
          when others =>
            i.ip    := i.ip + 2;
            i.state := st_execute;
        end case;
      
      -- got bytes 2-3
      -- request bytes 4-5
      when st_fetch2 =>
        i.imm(15 downto 0) := m.data;
        i.addr  := i.addr + 2;
        i.state := st_fetch3;
      
      -- got bytes 4-5
      -- start execution
      when st_fetch3 =>
        i.imm(31 downto 16) := m.data;    
        i.addr  := i.addr + 2;
        i.state := st_execute;
      
      -- got bytes 0-1
      -- request bytes 2-3
      when st_load0 =>
        i.buff(15 downto 0) := m.data;
        i.addr  := i.addr + 2;
        i.state := st_load1;
      
      -- got bytes 2-3
      -- set dest register
      -- fetch next instruction
      when st_load1 =>
        i.buff(31 downto 16) := m.data;
        i.regs(to_integer(i.rd)) := i.buff;
        report "" severity note;
        i.addr  := i.addr + 2;
        i.state := st_fetch0;
      
      -- wrote bytes 0-1
      -- send bytes 2-3
      when st_store0 =>
        i.data  := i.buff(31 downto 16);
        i.addr  := i.addr + 2;
        i.state := st_store1;
      
      -- wrote bytes 2-3
      -- stop writing
      -- fetch next instruction
      when st_store1 =>
        i.wr    := '0';
        i.state := st_fetch0;
      
      -- execute instruction
      when st_execute =>
        vd  := i.regs(to_integer(i.rd));
        vs  := i.regs(to_integer(i.rs));
        imm := i.imm;
        zf := i.flags(FL_ZERO);
        sf := i.flags(FL_SIGN);
        cf := i.flags(FL_CARRY);
        i.state := st_fetch0;
        
        case i.op is
          -- load rd, [rs+imm]
          when OP_LOAD =>
            vw := vs + imm;
            i.addr  := vw(15 downto 0);
            i.state := st_load0;
          
          -- store [rd+imm], rs
          when OP_STORE =>
            vw := vd + imm;
            i.addr  := vw(15 downto 0);
            i.buff  := vs;
            i.data  := i.buff(15 downto 0);
            i.wr    := '1';
            i.state := st_store0;
          
          -- movi rd, imm
          when OP_MOVI =>
            vd := imm;
          
          -- mov rd, rs
          when OP_MOV =>
            vd := vs;
          
          -- cmp rd, rs
          when OP_CMP =>
            vw := vd - vs;
            if vw = 0 then zf := '1'; else zf := '0'; end if;
            if vw < 0 then sf := '1'; else sf := '0'; end if;
            cf := '0'; -- v65(64);
          
          -- jmp imm
          when OP_JMP =>
            i.ip := imm;
          
          -- jz imm
          when OP_JZ =>
            if zf = '1' then
              i.ip := imm;
            end if;
          
          -- jnz imm
          when OP_JNZ =>
            if zf = '0' then
              i.ip := imm;
            end if;
          
          -- jb imm
          when OP_JB =>
            if sf = '1' and zf = '0' then
              i.ip := imm;
            end if;
          
          -- jbe imm
          when OP_JBE =>
            if sf = '1' or zf = '1' then
              i.ip := imm;
            end if;
          
          -- jg imm
          when OP_JG =>
            if sf = '0' and zf = '0' then
              i.ip := imm;
            end if;
          
          -- jge imm
          when OP_JGE =>
            if sf = '0' or zf = '1' then
              i.ip := imm;
            end if;
          
          -- add rd, rs
          when OP_ADD =>
            vd := vd + vs;
          
          -- adc rd, rs
          --when OP_ADC =>
          --  if cf = '1' then vs := vs + 1; end if;
          --  vd := vd + vs;
          
          -- sub rd, rs
          when OP_SUB =>
            vd := vd - vs;
          
          -- sbb rd, rs
          --when OP_SBB =>
          --  if cf = '1' then vs := vs - 1; end if;
          --  vd := vd - vs;
          
          -- mul rd, rs
          when OP_MUL =>
            vdw := vd * vs;
            vd := vdw(31 downto 0);
          
          -- imul rd, rs
          --when OP_IMUL =>
          --  v128 := vd * vs;
          --  vd := v128(63 downto 0);
          
          -- div rd, rs
          when OP_DIV =>
            vd := vd / vs;
          
          -- idiv rd, rs
          --when OP_IDIV =>
          --  vd := vd / vs;
          
          -- and rd, rs
          when OP_AND =>
            vd := vd and vs;
          
          -- or rd, rs
          when OP_OR =>
            vd := vd or vs;
          
          -- not rd
          when OP_NOT =>
            vd := not vd;
          
          -- xor rd, rs
          when OP_XOR =>
            vd := vd xor vs;
          
          -- shl rd, rs
          --when OP_SHL =>
          --  vd := shift_left(vd, to_integer(vs));
          
          -- shr rd, rs
          --when OP_SHR =>
          --  vd := shift_right(vd, to_integer(vs));
          
          -- rol rd, rs
          --when OP_ROL =>
          --  vd := shift_left(vd, to_integer(vs));
          
          -- ror rd, rs
          --when OP_ROR =>
          --  vd := shift_right(vd, to_integer(vs));
          
          -- invalid
          when others =>
            i.state := st_halted;
        end case;
        i.flags(FL_CARRY) := cf;
        i.flags(FL_SIGN)  := sf;
        i.flags(FL_ZERO)  := zf;
        i.regs(to_integer(i.rd)) := vd;
        
      -- invalid state
      when others =>
        i.state := st_halted;
    end case;
    
    -- drive status
    xi <= i;

    -- drive outputs
    minp.addr <= i.addr;
    minp.data <= i.data;
    minp.wr   <= i.wr;
    cout.state <= to_unsigned(cpu_state'pos(i.state), 4);
    cout.ip    <= i.ip(7 downto 0);
    cout.op <= i.op;
    cout.rd <= i.rd;
    cout.rs <= i.rs;
  end if;
end process;

end architecture bh;
