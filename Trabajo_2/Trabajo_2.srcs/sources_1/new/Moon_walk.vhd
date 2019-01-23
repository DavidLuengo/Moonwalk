----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.01.2019 17:00:26
-- Design Name: 
-- Module Name: Moon_walk - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2018 18:16:24
-- Design Name: 
-- Module Name: Moon_Walk - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

package MOONWALK_PACK is
    type sc_type is array (3 downto 0) of std_logic_vector (7 downto 0);-- Tipo pantalla
    --  CONSTANTS  --
    constant MAX_OBS_TYPE   :   integer := 4;
end MOONWALK_PACK;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.MOONWALK_PACK.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Moon_Walk is
    Port (
    clk         :   in  std_logic;
    reset       :   in  std_logic;
    P           :   in  std_logic;
    Speed       :   in  std_logic;
    segments    :   out std_logic_vector(7 downto 0);
    selector    :   out std_logic_vector(3 downto 0);
    led         :   out std_logic_vector(7 downto 0)
    );
end Moon_Walk;

architecture Behavioral of Moon_Walk is
    --  SIGNALS  --
    -- Explicacion signals
    --      P_a     :   std_logic           pulsacion filtrada
    --      pulso   :   std_logic           pulso basico de 1 clk cada 0.5 s
    --      thrust  :   integer             tipo de pulsacion
    --      obs_type:   integer             tipo de obstaculo
    --      car     :   std_logic_vector     posicion del coche
    --      screen  :   sc_type             objetos y coche en la pantalla
    --      sumavida:   std_logic           1 pulso para sumar vida
    --      choque  :   std_logic           se mantiene activo durante el choque
    --      enable  :   std_logic           si 1, se esta jugando
    --      endgame :   std_logic           para el juego y visualiza puntuacion
    --      vida    :   integer             vidas totales
    --      score   :   sc_type             puntuacion a visualizar
    
    signal P_a      :   std_logic;
    signal pulso    :   std_logic;
    signal thrust   :   integer range 0 to 4;
    signal obs_type :   integer range 0 to MAX_OBS_TYPE;
    signal car      :   std_logic_vector (2 downto 0);
    signal screen   :   sc_type;
    signal sumavida :   std_logic;
    signal choque   :   std_logic;
    signal enable   :   std_logic;
    signal endgame  :   std_logic;
    signal vida     :   integer range 0 to 8;
    signal score    :   sc_type;
    
    signal seg_aux    :   std_logic_vector(7 downto 0);
    signal sel_aux    :   std_logic_vector(3 downto 0);
    
    
    --  COMPONENTS  --
    --  NOMBRE                      HECHO   FUNCIONA
    --  antirrebotes                si      si
    --  generador de thrust         si      si
    --  generador de obstaculos     si      si
    --  generador de pulsos         si      si
    --  decodificador 7 segmentos   no
    --  decodificador led           no
    --  Maquina Estados juego       no
    --  Maquina Estados coche       no
    --  Maquina Estados pantalla    no
    --  Contador vidas              no
    --  Contador puntuacion         no
    
    
    
    
    --  antirrebotes
    component antirreb
        port (
            clk     :   in  std_logic;
            reset   :   in  std_logic;
            P       :   in  std_logic;
            P_a     :   out std_logic
        );
        end component;
        
    --  generador de thrust
    component gen_thrust
        port (
            clk     :   in  std_logic;
            reset   :   in  std_logic;
            P_a     :   in  std_logic;
            thrust  :   out integer range 0 to 4
        );
        end component;
    
    --  generador de obstaculos
    component gen_obs
        port (
            clk     :   in  std_logic;
            reset   :   in  std_logic;
            P_a     :   in  std_logic;
            pulso   :   in  std_logic;
            obs_type:   out integer range 0 to MAX_OBS_TYPE
        );
        end component;
    
    --  generador de pulsos (0.5 seg)
    component gen_pulso
        port(
            clk     :   in  std_logic;
            reset   :   in  std_logic;
            speed   :   in  std_logic;
            pulso   :   out std_logic
        );
        end component;
        
    --  decodifiicador 7 segmentos
    component dec_7seg
        port(
                clk     :   in  std_logic;
                reset   :   in  std_logic;
                --enable  :   in  std_logic;
                screen  :   in  sc_type;
                selector:   out std_logic_vector (3 downto 0);
                segments:   out std_logic_vector (7 downto 0)
             );
        end component;
    
    --  decodificador led
    component dec_led
        port(
            clk     :   in  std_logic;
            reset   :   in  std_logic;
            vida    :   in  integer range 0 to 8;
            led     :   out std_logic_vector(7 downto 0)
        );
        end component;
    
    --  Maquina Estados juego
    component GameSM
        port(
            clk     :   in  std_logic;
            reset   :   in  std_logic;
            choque  :   in  std_logic;
            vida    :   in  integer range 0 to 8;
            enable  :   out std_logic;
            endgame :   out std_logic
        );
        end component;
    
    --  Maquina Estados coche
    component CarSM
        port(
            clk     :   in  std_logic;
            reset   :   in  std_logic;
            thrust  :   in  integer range 0 to 4;
            enable  :   in  std_logic;
            pulso   :   in  std_logic;
            car     :   out std_logic_vector (2 downto 0)
        );
        end component;
    
    --  Maquina Estados pantalla
    component ScreenCp
        port(
            clk         :   in std_logic;
            reset       :   in std_logic;
            enable      :   in std_logic;
            pulso       :   in std_logic;
            obs_type    :   in integer range 0 to MAX_OBS_TYPE;
            car         :   in std_logic_vector (2 downto 0);
            endgame     :   in std_logic;
            choque      :   out std_logic;
            sumavida    :   out std_logic;
            screen      :   out sc_type
        );
        end component;
    
    --  Contador vidas
    component LifeCount
        port(
            clk     :   in  std_logic;
            reset   :   in  std_logic;
            choque  :   in  std_logic;
            sumavida:   in  std_logic;
            vida    :   out integer range 0 to 8
        );
        end component;
        
    --  Contador puntuacion
    component ScoreCount
        port(
            clk     :   in  std_logic;
            reset   :   in  std_logic;
            pulso   :   in  std_logic;
            enable  :   in  std_logic;
            choque  :   in  std_logic;
            score   :   out sc_type
        );
        end component;
    
    
begin
    anti    :   antirreb
    port map(
        clk => clk,
        reset => reset,
        P => P,
        P_a => P_a
    );
    
    GenThrust   :   gen_thrust
    port map(
        clk => clk,
        reset => reset,
        P_a => P_a,
        thrust => thrust
    );

    GenObs  :   gen_obs
    port map(
        clk => clk,
        reset => reset,
        P_a => P_a,
        pulso => pulso,
        obs_type => obs_type
    );
    
    GenPulso    :   gen_pulso
    port map(
        clk => clk,
        reset => reset,
        speed => speed,
        pulso => pulso
    );
    
    Dec7Seg :   dec_7seg
    port map(
        clk => clk,
        reset => reset,
        --enable => enable,
        screen => screen,
        selector => selector,
        segments => segments
    );
    
    DecLed  :   dec_led
    port map(
        clk => clk,
        reset => reset,
        vida => vida,
        led => led
    );
    
    Game    :   GameSM
    port map(
        clk => clk,
        reset => reset,
        choque => choque,
        vida => vida,
        enable => enable,
        endgame => endgame
    );
    
    Coche   :   CarSM
    port map(
        clk => clk,
        reset => reset,
        thrust => thrust,
        enable => enable,
        pulso => pulso,
        car => car
    );
    
    Pantalla    :   ScreenCp
    port map(
        clk => clk,
        reset => reset,
        enable => enable,
        pulso => pulso,
        obs_type => obs_Type,
        car => car,
        endgame => endgame,
        choque => choque,
        sumavida => sumavida,
        screen => screen
    );
    
    ContVida    :   LifeCount
    port map(
        clk => clk,
        reset => reset,
        choque => choque,
        sumavida => sumavida,
        vida => vida
    );
    
    Puntuacion  :   ScoreCount
    port map(
        clk => clk,
        reset => reset,
        pulso => pulso,
        enable => enable,
        choque => choque,
        score => score
    );
    
    
    segments <= seg_aux;
    selector <= sel_aux;
    
end Behavioral;
