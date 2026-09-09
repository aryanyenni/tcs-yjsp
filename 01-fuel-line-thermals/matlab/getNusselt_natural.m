% getNusselt_natural.m
%
% Owner: Aryan Yenni
% Org: Yellow Jacket Space Program
% Program: Elytra Vehicle Program
% DO NOT DISTRIBUTE



%% Nusselt Number Calculator

% =======================================================================
% Workflow
%     1) Know your film temperature. T_film = (T_s + T_inf)/2
%
%     2) Know your characteristic length, L.
%        'vertical_plate': L = length of the plate. D = 0.
%        'horizontal_plate: L = Area/Perimeter of the plate. D = 0.
%        'vertical_cylinder', 'horizontal_cylinder': enter L and D.
%        'sphere': enter D. L = 0.
% 
%     3) Fluid Properties
% 
%        Open the fluid properties lookup table provided for air, or
%        find one for your specific fluid.
%
%        Provide the following fluid properties upon function call (rho,
%        mu, k, cp, u, T_inf). Properties must be evaluated at film temp.
%
%     4) Material / Surface Properties
% 
%        Find material properties and surface values (k, L, T_s) (at film
%        temp. if a temperature function) to provide upon function call.
%
%     5) Provide a valid geometry (geo).
%
%     6) Attain Nu and h, please validate externally or with experiment.
%
% 
% Inputs
%    geo    : geometry type - 'vertical_plate', 'horizontal_plate',
%                             'vertical_cylinder', 'horizontal_cylinder',
%                             'sphere'
%    rho    : fluid density                             {kg/m^3}
%    mu     : fluid dynamic viscosity                   {Pa*s}
%    k      : thermal conductivity                      {W/(m*K)}
%    cp     : specific heat (constant pressure)         {J/(kg*K)}
%    L      : characteristic length                     {m}
%    D      : diameter (cylinders)                      {m}
%    T_s    : surface temperature                       {K}
%    T_inf  : freestream temperature                    {K}
%    
% 
% Outputs
%    Nu     : Nusselt number                            {~}
%    h      : convective heat transfer coefficient      {W/(m^2*K)}
%
% 
% Assumptions:
% - Ideal gas (air): beta = 1/T
% - Steady State
% - Properties evaluated at film temperature
% - Properties provided by user from tables (Cengel appendix or
%   equivalent) in proper units
%   
% 
% Theory provided at the end.
% =======================================================================

function [Nu, h] = getNusselt_natural(geo, rho, mu, k, cp, L, D,...
                                      T_s, T_inf)


    % ===================================================================
    % Derived Values
    T_film = (T_s + T_inf)/2;   % {K} Film temperature
    nu = mu/rho;                % {m^2/s} kinematic viscosity
    Pr = mu*cp/k;               % {~} Prandtl Number
    g = 9.81;                   % {m/s^2} gravitational acceleration
    beta = 1/T_film;            % {1/K} volume expansion coefficient
    Gr = (g*beta*abs(T_s-...    % {~} Grashof Number
         T_film)*L^3)/(nu^2);
    Ra = Gr*Pr;                 % {~} Rayleigh Number

    fprintf('\n---- Results ----\n');
    fprintf('T_film : %.2f      K\n',       T_film);
    fprintf('beta   : %.4f      1/K\n',     beta);
    fprintf('Pr     : %.4f      ~\n',         Pr);
    fprintf('Gr     : %.4f    ~\n',         Gr);
    fprintf('Ra     : %.2f      ~\n',         Ra);
        
    % ===================================================================
    
    switch geo
        
        case 'vertical_plate' % Churchill-Chu Correlation
            % Entire Ra range
            Nu = (0.825 + (0.387*Ra^(1/6))/...
                 (1 + (0.492/Pr)^(9/16))^(8/27))^2;
            fprintf('Nu     : %.4f      ~\n', Nu);

            h = Nu*k / L;
            fprintf('h      : %.4f     W/m^2*K\n\n', h);
        
        case 'horizontal_plate'
            if T_s > T_inf
                if Ra > 10^4 && Ra < 10^7
                    Nu = 0.59*Ra^(1/4);
                    fprintf('Nu     : %.4f      ~\n', Nu);

                    h = Nu*k / L;
                    fprintf('h      : %.4f     W/m^2*K\n\n', h);
                
                elseif Ra >= 10^7 && Ra < 10^11
                    Nu = 0.10*Ra^(1/3);
                    fprintf('Nu     : %.4f      ~\n', Nu);

                    h = Nu*k / L;
                    fprintf('h      : %.4f     W/m^2*K\n\n', h);

                else
                    warning('No explicit correlation for this Ra value.');
                
                end

            elseif T_s < T_inf
                if Ra > 10^5 && Ra < 10^10
                    Nu = 0.27*Ra^(1/4);
                    fprintf('Nu     : %.4f      ~\n', Nu);

                    h = Nu*k / L;
                    fprintf('h      : %.4f     W/m^2*K\n\n', h);

                else
                    warning('No explicit correlation at this Ra value.');

                end

            end
    
        case 'vertical_cylinder'
            if D >= 35*L/Gr^(1/4)
                print('Call function using "vertical_plate" (keep other',...
                      'parameters unchanged).');

            else
                warning('No explicit correlation for this geometry type.');

            end

        case 'horizontal_cylinder'
            if Ra <= 10^12
                Nu = (0.6 + (0.387*Ra^(1/6))/...
                     (1 + (0.559/Pr)^(9/16))^(8/27))^2;
                fprintf('Nu     : %.4f      ~', Nu);

                h = Nu*k/D;
                fprintf('h      : %.4f     W/m^2*K\n\n', h);

            else
                warning('No explicit correlation at this Ra value.');

            end
        
        case 'sphere'
            if Ra <= 10^11
                Nu = 2 + (0.589*Ra^(1/4))/(1 + (0.469/Pr)^(9/16))^(4/9);
                fprintf('Nu     : %.4f      ~', Nu);

                h = Nu*k/D;
                fprintf('h      : %.4f     W/m^2*K\n\n', h);
            
            else
                warning('No explicit correlation at this Ra value.');
            
            end
        
        otherwise
            
            error('Unknown geometry for natural(); %s', geo);

    
    end


end



%% Theory / Documentation

% =======================================================================
% 
% Quick Overview: https://en.wikipedia.org/wiki/Nusselt_number
% 
% 
% 
% 
% 
% 
