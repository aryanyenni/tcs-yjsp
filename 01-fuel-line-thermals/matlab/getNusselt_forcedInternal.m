% getNusselt_forcedInternal.m
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
%     2) Fluid Properties
% 
%        Open the fluid properties lookup table provided for air, or
%        find one for your specific fluid.
%
%        Provide the following fluid properties upon function call (rho,
%        mu, k, cp, u, T_inf). Properties must be evaluated at film temp.
%
%     2) Material / Surface Properties
% 
%        Find material properties and surface values (k, L, T_s) (at film
%        temp. if a temperature function) to provide upon function call.
%
%     3) Provide a valid geometry (geo).
%
%        If Nu for 'rectangular_duct' or 'ellipse' is needed, a message
%        will return suggesting to refer to a provided appendix.
%
%     4) Attain Nu and h.
%        Attain f (friction factor) if applicable.
%        Valid all results externally or through experiment.
%
% 
% Inputs
%    geo    : geometry type - 'circular_pipe', 'rectangular_duct',
%                             'ellipse'
%    rho    : fluid density                             {kg/m^3}
%    mu     : fluid dynamic viscosity                   {Pa*s}
%    k      : thermal conductivity                      {W/(m*K)}
%    cp     : specific heat (constant pressure)         {J/(kg*K)}
%    L      : characteristic length                     {m}
%    u      : bulk fluid velocity                       {m/s}
%    T_s    : surface temperature                       {K}
%    T_inf  : max/min fluid temperature                 {K}
% 
%
% Outputs
%    Nu     : Nusselt number                            {~}
%    h      : convective heat transfer coefficient      {W/(m^2*K)}
%    f      : Darcy-Weisbach friction factor            {~}
%
% 
% Assumptions:
% - Incompressible flow
% - Steady State
% - Properties evaluated at film temperature
% - Hydrodynamically and thermally fully developed
% - Properties provided by user from tables (Cengel appendix or equivalent)
%   in proper units
%   
% 
% Theory provided at the end.
% =======================================================================


function [Nu, h] =getNusselt_forcedInternal(geo, rho, mu, k, cp, L, u,...
                                            T_s, T_inf)


    % ===================================================================
    % Derived Values
    T_film = (T_s + T_inf)/2;   % {K} Film temperature
    Re = rho*u*L/mu;            % {~} Reynolds Number
    Pr = mu*cp/k;               % {~} Prandtl Number
    
    fprintf('\n---- Results ----\n');
    fprintf('T_film : %.2f      K\n',       T_film);
    fprintf('Re     : %.4f', Re);
    fprintf('Pr     : %.4f', Pr);


    % ===============================================================
    
    
    switch geo
        
        case 'circular_pipe'
            if Re < 3000 % Laminar
                Nu_constT = 3.66;
                h_constT = Nu_constT*k/L;
                % Hydrodynamically and thermally fully developed
                % T_s = const.
                Nu_constq = 4.36;
                h_constq = Nu_constq*k/L;
                % q_s = const.
                f = 64/Re; % Darcy-Weisbach Friction Factor
                
                fprintf('Nu (const. T_s): %.4f', Nu_constT);
                fprintf('Nu (const. q_s): %.4f', Nu_constq);
                fprintf('h (const. T_s):  %.4f', h_constT);
                fprintf('h (const. q_s): %.4f', h_constq);
                fprintf('f      : %.4f', f);

            elseif Re >= 3000 && Re < 5*10^5 % Gnielinski Correlation
                % Much more accurate than Dittus-Boelter
                
                f = (0.79*log(Re) - 1.64)^-2; % Filonenko Correlation
                Nu = ((f/8)*(Re - 1000)*Pr)/...
                       (1 + 12.7*(f/8)^(1/2)*(Pr^(2/3)-1));
                h = Nu*k/L;

                fprintf('Nu     : %.4f', Nu);
                fprintf('h      : %.4f', h);
                fprintf('f      : %.4f', f);

            end
        
        case 'rectangular_duct'

            print(['\nInterpolate from Cengel et. al. Table 8-1.\n' ...
                   'Provided in SharePoint ("Cengel Chapter 8 - Table '...
                   '8-1.pdf".']);

        case 'ellipse'

            print(['\nInterpolate from Cengel et. al. Table 8-1.\n' ...
                   'Provided in SharePoint ("Cengel Chapter 8 - Table '...
                   '8-1.pdf".']);

        otherwise
            
            error('Unknown geometry for forcedInternal();%s', geo);
    
    end


end




%% Theory / Documentation

% =======================================================================
% Quick Overview: https://en.wikipedia.org/wiki/Nusselt_number
% 
% TURBULENT PIPE FLOWS
%
% The Gnielinski Correlation takes the Darcy friction factor from the
% Filonenko Correlation, which can also be found in the Moody chart.
% Gnielinski has simplified power-law correlations for limited Pr ranges.
% The full-range equation is much more accurate than the Dittus-Boelter
% Equation.
%
% The Sieder-Tate correlation for turbulent pipe flow accounts for the
% viscosity change (mu_b and mu_w) due to temperature change.
%
%       Nu_D = 0.027*Re^0.8*Pr^(1/3)*(mu_b/mu_w)^0.14
% 
% where mu_b and mu_w are the viscosities at the film temperature and wall
% temperature respectively. mu = f(T)
% =======================================================================
