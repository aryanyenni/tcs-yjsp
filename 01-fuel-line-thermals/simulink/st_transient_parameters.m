% st_transient_parameters.m

% Aryan Yenni
% Environmental Control System
% Yellow Jacket Space Program


%% ODE1: Boundary/Initial Conditions, Material/Geometry, Setup
% Geometry
r1 = 0.00902;   % {m} line inner diameter
r2 = r1+0.00051;% {m} line outer diameter
t_ins_range = [0 0.005 0.010 0.015 0.020 0.025]; % {m} insulation thickness
L_c  = 0.125;   % {m} line length

k_ins = 0.03;   % {W/m*k} insulation thermal conductivity -- PLACEHOLDER --

% Materials
rho_RP1 = 820;  % {kg/m^3}
cp_RP1 = 2000;  % {J/kg*K}
V_RP1 = pi*r1^2*L_c;
m_RP1 = rho_RP1 * V_RP1;

rho_al = 2700;  % {kg/m^3}
cp_al = 900;    % {J/kg*K}
V_wall = pi*(r2^2 - r1^2)*L_c;
m_wall = rho_al * V_wall;

mcp_RP1 = m_RP1*cp_RP1 + m_wall*cp_al;

% Temperatures
T_RP1_i = 290;  % {K} RP-1 initial condition T_RP1(O) -- PLACEHOLDER --

m = 1 ;         % {kg} RP-1 + line mass -- PLACEHOLDER --
cp_RP1 = 2000;  % {J/kg*K} effective specific heat -- PLACEHOLDER --

t_sim = 5400;   % {s} 1.5 hours


%% ODE2: Boundary/Initial Conditions, Material/Geometry, Setup
% Geometry
L_w1 = 0.125273;% {m} RP1 line length
L_w2 = 0.291389;% {m} lox line length

r_iW = 0.1651;
r_oW = r_iW+(0.0032);
L_W = 0.498;

A_ow1 = 0.0075; % {m^2}
A_ow2 = 0.0233; % {m^2}
A_iW = 1.0242;  % {m^2}
A_oW = 1.0342;  % {m^2}

% Materials
V_IT3 = pi*0.1651*L_W;
rho_air = 1.225;
m_air = V_IT3*rho_air;
cp_air = 1005;

mcp_IT3 = m_air*cp_air;

k_cc = 1;       % {W/m*K} carbon-composite -- PLACEHOLDER --
k_al = 167;     % {W/m*K} 6061 T6 Aluminum -- PLACEHOLDER --
k_lox = 0.152;  % {W/m*K} liquid oxygen @ 90K -- PLACEHOLDER --
k_RP1 = 0.15;   % {W/m*K} RP-1 -- PLACEHOLDER --

% Temperatures
T_lox = 90;     % {K} lox maximum temp. (phase change @ 90K)
T_inf = 270;    % {K} Freestream constant temp.
T_IT3_i = 290;  % {K} IT-3 initial condition -- PLACEHOLDER --


% Resistances
% w1 - RP1 Inlet Line
R_iw1 = 1/(4*pi*k_RP1*L_w1);
R_w1 = log(r2/r1)/(2*pi*k_al);
% [Nu_ow1, h_ow1] = getNusselt_natural('vertical_plate', 1.225, 1.81*10^-5,...
%                     0.135, 1005, L_w1, 0, 290, 270);
% R_ow1 = 1/(h_ow1*A_ow1);

% W - IT3 Outer Wall
[Nu_iW, h_iW] = getNusselt_natural('vertical_plate', 1.225, 1.81*10^-5,...
                    0.135, 1005, L_W, 0, 290, 270);
R_iW = 1/(h_iW*A_iW);
R_W = log(r_oW/r_iW)/(2*pi*k_cc*L_W);
[Nu_oW, h_oW] = getNusselt_forcedExternal('cylinder_crossflow', 1.225, 1.81*10^-5,...
                    0.135, 1005, L_W, 4.4704, 0, 0);
R_oW = 1/(h_oW*A_oW);

% w2 - lox Inlet Line
R_iw2 = 1/(4*pi*k_lox*L_w2);
R_w2 = log(r2/r1)/(2*pi*k_al*L_w2);
% [Nu_ow2, h_ow2] = getNusselt_natural('vertical_plate', 1.225, 1.81*10^-5,...
%                     0.135, 1005, L_w2, 0, 100, 270);
% R_ow2 = 1/(h_ow2*A_ow2);


%% MATLAB Function: getNusselt_natural.m
% Evaluated @ T_film = 290 K
% Between outer insulation wall and still air

geo = 'vertical_plate';
rho = 1.225;    % {kg/m^3}              T = 290 K, P within [0.5, 40] MPa
mu = 1.81*10^-5;% {Pa*s}                T = 293 K
k = 0.135;      % {W/m*K}
cp = 1005;      % {J/kg*K}
L = 0.125;      % {m}
D = 0;          % {m} not needed for case: 'vertical_plate'


%% Plotting

figure;
subplot(2, 2, 1); hold on;
    xlabel('Time {s}')
    ylabel('RP-1 Line Temperature {K}')
    yline(240, 'r--', 'Gelling Threshold')

    grid on

subplot(2, 2, 2); hold on;
    xlabel('Time {s}')
    ylabel('Nusselt Number (Nu)')
    
    grid on

subplot(2, 2, 3); hold on;
    xlabel('Time {s}')
    ylabel('IT-3 Temperature {K}')

    grid on
    
subplot(2, 2, 4); hold on;
    xlabel('Time {s}')
    ylabel('Nusselt Numbers (Nu)')

    grid on

colors = lines(length(t_ins_range));
legend_labels = {};

for i = 1:length(t_ins_range)
    t_ins = t_ins_range(i);
    r3 = r2 + t_ins;  % {m} insulation outer diameter
    A_oins = 0.6*pi*r3;  % {m} line surface area -- PLACEHOLDER --
    if t_ins > 0
        R_ins = log(r3/r2)/(2*pi*k_ins*L_c);
    else
        R_ins = 0;
    end

    out = sim('st_transient');

    T_RP1 = out.T.Data;
    T_IT3 = out.T2.Data;
    t = out.T.Time;
    Nu = out.Nu.Data;
    Nu1 = out.Nu1.Data;
    Nu2 = out.Nu2.Data;
    Nu3 = out.Nu3.Data;
    h = out.h.Data;

    if t_ins == 0
        legend_labels{i} = 'No insulation';
    else
        legend_labels{i} = sprintf('t = %d mm', t_ins*1000);
    end

    

    subplot(2, 2, 1); hold on;
    plot(t, T_RP1, 'Color', colors(i,:), 'LineWidth', 1.5);

    subplot(2, 2, 3); hold on;
    plot(t, T_IT3, 'Color', colors(i,:), 'LineWidth', 1.5);

    subplot(2, 2, 2); hold on;
    plot(t, Nu, 'Color', colors(i,:), 'LineWidth', 1.5);

    subplot(2, 2, 4); hold on;
    plot(t, Nu2, 'Color', colors(i,:), 'LineWidth', 1.5);

end

subplot(2, 2, 1); legend(legend_labels, 'Location', 'northeast')
    xlim([0 t_sim])
    ylim([min(T_RP1) max(T_RP1)*1.1])

subplot(2, 2, 2); legend(legend_labels, 'Location', 'northeast')
    xlim([0 t_sim])
    ylim([min(Nu) max(Nu)*1.1])

subplot(2, 2, 3); legend(legend_labels, 'Location', 'northeast')
    xlim([0 t_sim])
    ylim([min(T_IT3) max(T_IT3)*1.1])

subplot(2, 2, 4); legend(legend_labels, 'Location', 'northeast')
    xlim([0 t_sim])
    ylim([0 max(Nu2)])


%% Documentation / Theory

