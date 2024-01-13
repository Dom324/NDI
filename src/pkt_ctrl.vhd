----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    15:49:44 10/25/2023
-- Design Name:
-- Module Name:    pkt_ctrl - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pkt_ctrl is
generic(
        COUNTER_WIDTH          : integer := 17;
        TIME_OUT_CYCLES        : integer := 100000
    );
    Port (
        clk             : in  STD_LOGIC;
        rst             : in  STD_LOGIC;
        fr_start        : in  STD_LOGIC;
        fr_end          : in  STD_LOGIC;
        fr_err          : in  STD_LOGIC;
        data_out        : in  STD_LOGIC_VECTOR (15 downto 0);
        load_data       : out STD_LOGIC;
        data_in         : out STD_LOGIC_VECTOR (15 downto 0);
        we_result       : out STD_LOGIC;
        we_data_fr1     : out STD_LOGIC;
        we_data_fr2     : out STD_LOGIC;
        data_fr         : out STD_LOGIC_VECTOR (15 downto 0);
        add_res         : in  STD_LOGIC_VECTOR (15 downto 0);
        mul_res         : in  STD_LOGIC_VECTOR (15 downto 0)
    );
end pkt_ctrl;

architecture Behavioral of pkt_ctrl is

    type fsm_type is (waiting_for_first, receiving_first, waiting_for_second, receiving_second);
    signal r_state : fsm_type;
    signal s_state_next : fsm_type;

    signal r_counter : STD_LOGIC_VECTOR (COUNTER_WIDTH downto 0);
    signal s_counter_next : STD_LOGIC_VECTOR (COUNTER_WIDTH downto 0);
    signal s_timeout    : STD_LOGIC;
    signal r_fr_err_prev :STD_LOGIC;
    signal s_fr_err_prev :STD_LOGIC;

begin

    process(clk, rst) is
        begin
        if rst = '1' then
            r_state <= waiting_for_first;
            r_counter <= (others => '0');
            r_fr_err_prev <= '0';
        elsif rising_edge(clk) then
            r_state <= s_state_next;
            r_counter <= s_counter_next;
            r_fr_err_prev <= s_fr_err_prev;
        end if;
    end process;

    process(r_state, r_counter) is
    begin

        if(r_state = waiting_for_second) then
            s_counter_next <= r_counter + 1;
        elsif(r_state = waiting_for_first) then
            s_counter_next <= r_counter;
          else
            s_counter_next <= (others => '0');
        end if;

    end process;

    process(r_state, fr_start, fr_end, fr_err, r_counter, r_fr_err_prev) is
    begin

        if(r_counter >= std_logic_vector(to_unsigned(TIME_OUT_CYCLES, r_counter'length))) then
            s_timeout <= '1';
          else
            s_timeout <= '0';
        end if;

        we_data_fr1 <= '0';
        we_data_fr2 <= '0';
        we_result <= '0';

        if fr_start = '1' then
            s_fr_err_prev <= '0';
        elsif fr_err = '1' then
            s_fr_err_prev <= '1';
        else
            s_fr_err_prev <= r_fr_err_prev;
        end if;

        case r_state is
            when waiting_for_first =>

                we_result <= not s_timeout and not r_fr_err_prev;

                if(fr_start = '1') then
                    s_state_next <= receiving_first;
                else
                    s_state_next <= waiting_for_first;
                end if;

            when receiving_first =>

                if(fr_err = '1') then
                    s_state_next <= waiting_for_first;
                elsif(fr_end = '1') then
                    s_state_next <= waiting_for_second;
                    we_data_fr1 <= '1';
                else
                    s_state_next <= receiving_first;
                end if;

            when waiting_for_second =>

                if(s_timeout = '1') then
                   s_state_next <= waiting_for_first;
                elsif(fr_start = '1') then
                    s_state_next <= receiving_second;
                else
                    s_state_next <= waiting_for_second;
                end if;

            when receiving_second =>

                if(fr_err = '1') then
                    s_state_next <= waiting_for_second;
                elsif(fr_end = '1') then
                    s_state_next <= waiting_for_first;
                    we_data_fr2 <= '1';
                else
                    s_state_next <= receiving_second;
                end if;

            when others =>
                s_state_next <= waiting_for_first;
        end case;

    end process;

    process(r_state, add_res, mul_res) is
    begin

        if (r_state = waiting_for_first) or (r_state = receiving_first) then
            data_in <= add_res;
        else
            data_in <= mul_res;
        end if;

    end process;

    data_fr <= data_out;
    load_data <= fr_start;

end Behavioral;

