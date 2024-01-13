--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   14:34:33 11/01/2023
-- Design Name:
-- Module Name:   C:/Users/240857/Downloads/Rapeme2/Rapeme/TopBitch.vhd
-- Project Name:  Rapeme
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: Top
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
USE ieee.numeric_std.ALL;
use std.textio.all;
use std.env.finish;

ENTITY TopBitch IS
END TopBitch;

ARCHITECTURE behavior OF TopBitch IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT Top
    PORT(
        clk : IN  std_logic;
        rst : IN  std_logic;
        CS_b : IN  std_logic;
        SCLK : IN  std_logic;
        MOSI : IN  std_logic;
        MISO : OUT  std_logic
        );
    END COMPONENT;


    --Inputs
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal CS_b : std_logic := '0';
    signal SCLK : std_logic := '0';
    signal MOSI : std_logic := '0';
    signal incoming_packet_temp : std_logic_vector (15 downto 0);
    signal incoming_packet : std_logic_vector (15 downto 0);

    signal test_vector_wait_time : unsigned (31 downto 0);
    signal test_vector_num_bits : unsigned (31 downto 0);
    signal test_vector_number : std_logic_vector (63 downto 0);
    signal test_vector_result : std_logic_vector (15 downto 0);
    signal test_vector_valid : std_logic_vector (0 downto 0);

     --Outputs
    signal MISO : std_logic;

    -- Clock period definitions
    constant clk_period : time := 10 ns;
    constant SCLK_period : time := 1000 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: Top PORT MAP (
        clk => clk,
        rst => rst,
        CS_b => CS_b,
        SCLK => SCLK,
        MOSI => MOSI,
        MISO => MISO
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

    p_read : process
        constant NUM_COL                : integer := 5;
        type t_integer_array       is array(integer range <> )  of integer;
        file test_vector                : text open read_mode is "test_vectors.txt";
        variable row                    : line;
        variable v_data_read            : t_integer_array(1 to NUM_COL);
        variable v_data_row_counter     : integer := 0;
    begin

        test_vector_wait_time    <= to_unsigned(0, test_vector_wait_time'length);
        test_vector_num_bits    <= to_unsigned(0, test_vector_wait_time'length);
        test_vector_number    <= std_logic_vector(to_unsigned(0, test_vector_number'length));
        test_vector_result    <= std_logic_vector(to_unsigned(0, test_vector_result'length));
        test_vector_valid    <= std_logic_vector(to_unsigned(0, test_vector_valid'length));

        rst <= '1';
        CS_b <= '1';
        wait for SCLK_period;
        rst <= '0';
        wait for SCLK_period;
        CS_b <= '0';
        wait for SCLK_period;

        wait for SCLK_period / 2;

        while true loop
            --report "Sending frame number " & integer'image(v_data_row_counter) & "...";

            if(endfile(test_vector)) then
                report "   Test finished correctly!";
                finish;
            end if;

            v_data_row_counter := v_data_row_counter + 1;
            readline(test_vector,row);

            for kk in 1 to NUM_COL loop
                read(row,v_data_read(kk));
            end loop;

            test_vector_wait_time    <= to_unsigned(v_data_read(1), test_vector_wait_time'length);
            test_vector_num_bits    <= to_unsigned(v_data_read(2), test_vector_wait_time'length);
            test_vector_number    <= std_logic_vector(to_unsigned(v_data_read(3), test_vector_number'length));
            test_vector_result    <= std_logic_vector(to_unsigned(v_data_read(4), test_vector_result'length));
            test_vector_valid    <= std_logic_vector(to_unsigned(v_data_read(5), test_vector_valid'length));

            CS_b <= '1';            -- PACKET START
            wait for SCLK_period / 2;
            wait for to_integer(test_vector_wait_time) *100 us - SCLK_PERIOD;

            for i in 0 to to_integer(unsigned(test_vector_num_bits)) - 1 loop
                CS_b <= '0';
                MOSI <= test_vector_number(i);
                wait for SCLK_period/2;
                if(i < 16) then
                    incoming_packet_temp(i) <= MISO;
                end if;
                wait for SCLK_period/2;
            end loop;

            incoming_packet <= incoming_packet_temp;
            CS_b <= '1';            -- PACKET END
            wait for SCLK_period / 2;

            if(test_vector_num_bits = 16) then
                report "   Writing number " & integer'image(to_integer(unsigned(test_vector_number))) & " into DUT...";
            else
                report "   Writing invalid frame with " & integer'image(to_integer(unsigned(test_vector_num_bits))) & " bits into DUT...";
            end if;

            if(test_vector_valid = "1") then
                assert incoming_packet = test_vector_result report "   Test vector number "  & integer'image(v_data_row_counter) & " FAILED!           Expected result: "   & integer'image(to_integer(unsigned(test_vector_result))) & "           DUT: "   & integer'image(to_integer(unsigned(incoming_packet))) severity error;
                assert incoming_packet /= test_vector_result report "   Test vector number "  & integer'image(v_data_row_counter) & " PASSED!           Expected result: " & integer'image(to_integer(unsigned(test_vector_result))) & "           DUT: "   & integer'image(to_integer(unsigned(incoming_packet))) severity note;
            end if;

        end loop;

    end process p_read;

END;
