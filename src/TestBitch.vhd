--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   13:37:20 10/25/2023
-- Design Name:
-- Module Name:   C:/Users/TEMP.VUTBR.003/Downloads/Rapeme/TestBitch.vhd
-- Project Name:  Rapeme
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: SPI_IF
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY TestBitch IS
END TestBitch;

ARCHITECTURE behavior OF TestBitch IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT SPI_IF
    PORT(
        clk : IN  std_logic;
        rst : IN  std_logic;
        CS_b : IN  std_logic;
        SCLK : IN  std_logic;
        MOSI : IN  std_logic;
        MISO : OUT  std_logic;
        fr_start : OUT  std_logic;
        fr_end : OUT  std_logic;
        fr_err : OUT  std_logic;
        data_out : OUT  std_logic_vector(15 downto 0);
        data_in : IN  std_logic_vector(15 downto 0);
        load_data : IN  std_logic
    );
    END COMPONENT;


    --Inputs
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal CS_b : std_logic := '0';
    signal SCLK : std_logic := '0';
    signal MOSI : std_logic := '0';
    signal data_in : std_logic_vector(15 downto 0) := (others => '0');
    signal load_data : std_logic := '0';

    --Outputs
    signal MISO : std_logic;
    signal fr_start : std_logic;
    signal fr_end : std_logic;
    signal fr_err : std_logic;
    signal data_out : std_logic_vector(15 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;
    constant SCLK_period : time := 1000 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: SPI_IF PORT MAP (
        clk => clk,
        rst => rst,
        CS_b => CS_b,
        SCLK => SCLK,
        MOSI => MOSI,
        MISO => MISO,
        fr_start => fr_start,
        fr_end => fr_end,
        fr_err => fr_err,
        data_out => data_out,
        data_in => data_in,
        load_data => load_data
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    SCLK_process :process
    begin
        SCLK <= '0';
        wait for SCLK_period/2;
        SCLK <= '1';
        wait for SCLK_period/2;
    end process;


    -- Stimulus process
    stim_proc: process is
    begin

        rst <= '1';
        CS_b <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;
        CS_b <= '0';
        wait for 50 ns;
        CS_b <= '1';
        wait for SCLK_period;
            CS_b <= '0';
            MOSI <= '1';
        wait for SCLK_period;
            MOSI <= '1';
        wait for SCLK_period;
            MOSI <= '0';
        wait for SCLK_period;
            MOSI <= '0';
        wait for SCLK_period;
            MOSI <= '1';
        wait for SCLK_period;
            MOSI <= '1';
        wait for SCLK_period;
            MOSI <= '0';
        wait for SCLK_period;
            MOSI <= '0';
        wait for SCLK_period;
            MOSI <= '1';
        wait for SCLK_period;
            MOSI <= '1';
        wait for SCLK_period;
            MOSI <= '0';
        wait for SCLK_period;
            MOSI <= '0';
        wait for SCLK_period;
            MOSI <= '1';
        wait for SCLK_period;
            MOSI <= '1';
        wait for SCLK_period;
            MOSI <= '0';
        wait for SCLK_period;
            MOSI <= '0';

        CS_b <= '1';
        wait for 100 ns;
        wait;
    end process;

END;
