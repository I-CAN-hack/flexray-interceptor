library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.can;

entity can_tb is
end can_tb;

architecture tb of can_tb is
  component can_rx is
    port (
      clk   : in  std_ulogic;
      rst   : in  std_ulogic;
      rx    : in  std_ulogic;
      debug    : out std_ulogic;
      tx    : out std_ulogic;
      msg   : out work.can.message;
      ready : out std_ulogic);
  end component can_rx;

  component can_tx is
    port (
      clk   : in    std_ulogic;
      rst   : in    std_ulogic;
      ready : in    std_ulogic;
      msg   : in    work.can.message;
      tx    : inout std_ulogic;
      done  : inout std_ulogic);
  end component can_tx;

  component can_generator is
    port (channel_0 : out std_ulogic);
  end component can_generator;

  constant tb_clk_period : time       := 250 ns;  -- 8x bitrate 4 Mhz
  signal tb_clk          : std_ulogic := '0';
  signal rst             : std_ulogic := '1';
  signal msg             : work.can.message;
  signal ready           : std_ulogic;
  signal rx_ack          : std_ulogic;

  signal in_msg       : work.can.message;
  signal in_msg_ready : std_ulogic := '0';
  signal tx_done      : std_ulogic;


  signal debug : std_ulogic;
  signal channel_0 : std_ulogic;

begin
  -- tx : can_tx port map(clk => tb_clk, rst => rst, ready => in_msg_ready, msg => in_msg, tx => channel_0, done => tx_done);
  rx : can_rx port map(clk => tb_clk, rst => rst, rx => channel_0, msg => msg, ready => ready, tx => rx_ack, debug => debug);

  la_dump : can_generator port map(channel_0 => channel_0);

  -- stim_proc : process
  -- begin
  --   in_msg.id  <= "000" & X"00";
  --   in_msg.dat <= X"0102030405060708";
  --   in_msg.len <= X"8";

  --   wait for 100 us;

  --   for i in 1 to 255 loop
  --     in_msg.id    <= std_ulogic_vector(to_unsigned(i, 11));
  --     in_msg.dat   <= std_ulogic_vector(to_unsigned(i, 64));
  --     in_msg_ready <= '1';
  --     wait for 300 us;
  --     assert in_msg.id = msg.id severity failure;
  --     assert in_msg.len = msg.len severity failure;
  --     assert in_msg.dat = msg.dat severity failure;
  --     in_msg_ready <= '0';
  --     wait for 100 us;
  --   end loop;

  --   wait;
  -- end process;

  clock_proc : process
  begin
    -- Perform reset
    wait for tb_clk_period / 2;
    tb_clk <= '1';
    wait for tb_clk_period / 2;
    rst    <= '0';
    tb_clk <= '0';

    for i in 1 to 8 loop
      wait for tb_clk_period / 2;
      tb_clk <= not tb_clk;
      wait for tb_clk_period / 2;
      tb_clk <= not tb_clk;
    end loop;

    -- for i in 1 to 200000 loop
    for i in 1 to 1 * 256 * 8 loop
      tb_clk <= not tb_clk;
      wait for tb_clk_period / 2;
      tb_clk <= not tb_clk;
      wait for tb_clk_period / 2;
    end loop;
    wait;
  end process;
end tb;
