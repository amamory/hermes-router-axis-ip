------------------------------------------------------------------------------------------------
--
--  DISTRIBUTED HEMPS  - version 5.0 
--
--  Research group: GAPH-PUCRS    -    contact   fernando.moraes@pucrs.br
--
--  Distribution:  September 2013
--
--  Source name:  RouterCC.vhd
--
--  Brief description: Top module of the NoC - the NoC is built using only this module
--
---------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------- 
--                                              ROUTER
--
--                                              NORTH               LOCAL
--                       ---------------------------------------------
--                      |                       ******         ****** |
--                      |                       *FILA*         *FILA* |
--                      |                       ******         ****** |
--                      |                   *************             |
--                      |                   *  ARBITRO  *             |
--                      | ******            *************      ****** |
--                 WEST | *FILA*            *************      *FILA* | EAST
--                      | ******            *  CONTROLE *      ****** |
--                      |                   *************             |
--                      |                       ******                |
--                      |                       *FILA*                |
--                      |                       ******                |
--                      -----------------------------------------------
--                                              SOUTH
--
--  As chaves realizam a transfer�ncia de mensagens entre n�cleos. 
--  A chave possui uma l�gica de controle de chaveamento e 5 portas bidirecionais:
--  East, West, North, South e Local. Cada porta possui uma fila para o armazenamento 
--  tempor�rio de flits. A porta Local estabelece a comunica��o entre a chave e seu 
--  n�cleo. As demais portas ligam a chave �s chaves vizinhas.
--  Os endere�os das chaves s�o compostos pelas coordenadas XY da rede de interconex�o, 
--  onde X � a posi��o horizontal e Y a posi��o vertical. A atribui��o de endere�os �s 
--  chaves � necess�ria para a execu��o do algoritmo de chaveamento.
--  Os m�dulos principais que comp�em a chave s�o: fila, �rbitro e l�gica de 
--  chaveamento implementada pelo controle_mux. Cada uma das filas da chave (E, W, N, 
--  S e L), ao receber um novo pacote requisita chaveamento ao �rbitro. O �rbitro 
--  seleciona a requisi��o de maior prioridade, quando existem requisi��es simult�neas, 
--  e encaminha o pedido de chaveamento � l�gica de chaveamento. A l�gica de 
--  chaveamento verifica se � poss�vel atender � solicita��o. Sendo poss�vel, a conex�o
--  � estabelecida e o �rbitro � informado. Por sua vez, o �rbitro informa a fila que 
--  come�a a enviar os flits armazenados. Quando todos os flits do pacote foram 
--  enviados, a conex�o � conclu�da pela sinaliza��o, por parte da fila, atrav�s do 
--  sinal sender.
---------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HeMPS_defaults.all;

entity RouterCC is
generic( address: std_logic_vector(15 downto 0) := "0000000100000001");
port(
        clock   : in  std_logic;
        reset_n : in  std_logic; -- use always active low reset since all vivado blocks are also active low
        -- AXI Stream slave interfaces: E, W, N, S, Local ports
        validE_i: in  std_logic;
        dataE_i : in  std_logic_vector(TAM_FLIT-1 downto 0);
        readyE_o: out std_logic;    

        validW_i: in  std_logic;
        dataW_i : in  std_logic_vector(TAM_FLIT-1 downto 0);
        readyW_o: out std_logic;    

        validN_i: in  std_logic;
        dataN_i : in  std_logic_vector(TAM_FLIT-1 downto 0);
        readyN_o: out std_logic;    

        validS_i: in  std_logic;
        dataS_i : in  std_logic_vector(TAM_FLIT-1 downto 0);
        readyS_o: out std_logic;    

        validL_i: in  std_logic;
        dataL_i : in  std_logic_vector(TAM_FLIT-1 downto 0);
        readyL_o: out std_logic;    

        -- AXI Stream master interfaces: E, W, N, S, Local ports
        validE_o: out std_logic;
        dataE_o : out std_logic_vector(TAM_FLIT-1 downto 0);
        readyE_i: in  std_logic;

        validW_o: out std_logic;
        dataW_o : out std_logic_vector(TAM_FLIT-1 downto 0);
        readyW_i: in  std_logic;

        validN_o: out std_logic;
        dataN_o : out std_logic_vector(TAM_FLIT-1 downto 0);
        readyN_i: in  std_logic;

        validS_o: out std_logic;
        dataS_o : out std_logic_vector(TAM_FLIT-1 downto 0);
        readyS_i: in  std_logic;

        validL_o: out std_logic;
        lastL_o : out std_logic;
        dataL_o : out std_logic_vector(TAM_FLIT-1 downto 0);
        readyL_i: in  std_logic

        );
end RouterCC;

architecture RouterCC of RouterCC is
signal h, ack_h, data_av, sender, data_ack: std_logic_vector(4 downto 0);
signal data: arrayNport_regflit;
signal data_out_crossbar: arrayNport_regflit;
signal mux_in, mux_out: arrayNport_reg3;
signal free: std_logic_vector(4 downto 0);
signal clock_rx: std_logic_vector(4 downto 0);
signal tx: std_logic_vector(4 downto 0);
signal credit_s: std_logic_vector(4 downto 0);

begin
    clock_rx(0) <= not clock;
    clock_rx(1) <= not clock;
    clock_rx(2) <= not clock;
    clock_rx(3) <= not clock;
    clock_rx(4) <= not clock;
    
        FEast : Entity work.Hermes_buffer
        port map(
                clock => clock,
                reset_n => reset_n,
                data_in => dataE_i,
                rx => validE_i,
                h => h(0),
                ack_h => ack_h(0),
                data_av => data_av(0),
                data => data(0),
                sender => sender(0),
                clock_rx => clock_rx(0),
                data_ack => data_ack(0),
                credit_o => readyE_o);

        FWest : Entity work.Hermes_buffer
        port map(
                clock => clock,
                reset_n => reset_n,
                data_in => dataW_i,
                rx => validW_i,
                h => h(1),
                ack_h => ack_h(1),
                data_av => data_av(1),
                data => data(1),
                sender => sender(1),
                clock_rx => clock_rx(1),
                data_ack => data_ack(1),
                credit_o => readyW_o);

        FNorth : Entity work.Hermes_buffer
        port map(
                clock => clock,
                reset_n => reset_n,
                data_in => dataN_i,
                rx => validN_i,
                h => h(2),
                ack_h => ack_h(2),
                data_av => data_av(2),
                data => data(2),
                sender => sender(2),
                clock_rx => clock_rx(2),
                data_ack => data_ack(2),
                credit_o => readyN_o);

        FSouth : Entity work.Hermes_buffer
        port map(
                clock => clock,
                reset_n => reset_n,
                data_in => dataS_i,
                rx => validS_i,
                h => h(3),
                ack_h => ack_h(3),
                data_av => data_av(3),
                data => data(3),
                sender => sender(3),
                clock_rx => clock_rx(3),
                data_ack => data_ack(3),
                credit_o => readyS_o);

        FLocal : Entity work.Hermes_buffer
        port map(
                clock => clock,
                reset_n => reset_n,
                data_in => dataL_i,
                rx => validL_i,
                h => h(4),
                ack_h => ack_h(4),
                data_av => data_av(4),
                data => data(4),
                sender => sender(4),
                clock_rx => clock_rx(4),
                data_ack => data_ack(4),
                credit_o => readyL_o);

        SwitchControl : Entity work.SwitchControl(XY)
        port map(
                clock => clock,
                reset_n => reset_n,
                h => h,
                ack_h => ack_h,
                address => address,
                data => data,
                sender => sender,
                free => free,
                mux_in => mux_in,
                mux_out => mux_out);

        CrossBar : Entity work.Hermes_crossbar
        port map(
                data_av => data_av,
                data_in => data,
                data_ack => data_ack,
                --sender => sender, -- not used
                free => free,
                tab_in => mux_in,
                tab_out => mux_out,
                tx => tx,
                data_out => data_out_crossbar,
                credit_i => credit_s);

        Last_Local: Entity work.Last_gen
        port map(
                clock   => clock,  
                reset_n   => reset_n,
                -- these go the external side of the local port 
                validL_o=> validL_o,
                lastL_o => lastL_o,
                dataL_o => dataL_o,
                readyL_i=> readyL_i,
                -- these go to the internal side of the router 
                valid_i => tx(4),
                data_i  => data_out_crossbar(4),
                ready_o => credit_s(4)
        );




        validE_o <= tx(0);
        validW_o <= tx(1);
        validN_o <= tx(2);
        validS_o <= tx(3);
        --validL_o <= tx(4);
        
        credit_s(0) <= readyE_i;
        credit_s(1) <= readyW_i;
        credit_s(2) <= readyN_i;
        credit_s(3) <= readyS_i;
        --credit_s(4) <= readyL_i;
        
        dataE_o <= data_out_crossbar(0);
        dataW_o <= data_out_crossbar(1);
        dataN_o <= data_out_crossbar(2);
        dataS_o <= data_out_crossbar(3);
        --dataL_o <= data_out_crossbar(4);

end RouterCC;
