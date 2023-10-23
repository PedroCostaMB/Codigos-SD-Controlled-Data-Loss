%{
Backtracking Search Optimization Algorithm (BSA)

Platform: Matlab 2013a   


Cite this algorithm as;
[1]  P. Civicioglu, "Backtracking Search Optimization Algorithm for 
numerical optimization problems", Applied Mathematics and Computation, 219, 8121–8144, 2013.


Copyright Notice
Copyright (c) 2012, Pinar Civicioglu
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are 
met:

    * Redistributions of source code must retain the above copyright 
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the copyright 
      notice, this list of conditions and the following disclaimer in 
      the documentation and/or other materials provided with the distribution
      
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.


%}

%function bsa(semente,tempo_de_manipulacao,setpoint_desejado,intervalo_amostragem,...
%    target_input_amplitude,target_input_inicio,num_cont,den_cont,num_planta,den_planta,tempo_execucao,delay_fw,delay_fb)

function bsa(semente,tempo_de_manipulacao,setpoint_desejado,intervalo_amostragem,...
        target_input_amplitude,target_input_inicio,num_cont_k1,den_cont_k1,...
        num_cont_k2,den_cont_k2,num_cont_k,den_cont_k,num_planta_g11,den_planta_g11,...
        num_planta_g12,den_planta_g12,num_planta_g21,den_planta_g21,num_planta_g22,...
        den_planta_g22,tempo_execucao)



%INITIALIZATION
%%% (carrega os limites do espaço de busca)
low=[0 0 0 0];              %%% limites inferiores de x e y
up=[2^(tempo_de_manipulacao-1) 2^(tempo_de_manipulacao-1) 2^(tempo_de_manipulacao-1) 2^(tempo_de_manipulacao-1)];
%low=[0.0001 0.0001 0.0001 0.0001];              %%% limites inferiores de x e y
%up=[20 20 20 20];           %%% limites superiores de x e y
dim = size(up,2);      %%% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx define quantas dimensões tem o problema
popsize = 100;          %%% define o tamanho da população
numero_iteracoes = 800;%600;%4500;  %%% define o numero de iterações (gerações)
MEMQE=1e-8;%2.9e-5;               %%% Valor do maior erro medio quadratico esperado (criterio de parada)
DIM_RATE = 1;           %%% DIM_RATE estabelece a probabilidade de uma das dimensões ser escolhida em detrimento da(s) outra(s) (OBS.: DIM_RATE=1 significa que as dimensões têm a mesma probalilidade de serem selecionadas para cruzamento/mutação)
%fnc = 'Funcao_Avaliacao_erro_constante';%'Funcao_Avaliacao';          %%% Define a função de avaliação
%fnc = 'Funcao_Avaliacao_overshoot';%'Funcao_Avaliacao';          %%% Define a função de avaliação
%fnc = 'Funcao_Avaliacao_overshoot_2';%'Funcao_Avaliacao';          %%% Define a função de avaliação
%fnc = 'Funcao_Avaliacao_overshoot_3';%'Funcao_Avaliacao';          %%% Computers & Security
fnc = 'Funcao_Avaliacao_overshoot_4';%'Funcao_Avaliacao';          %%% IEEE TIE
%semente=1;              %%% semente para permitir a replicação de resultados

rand('seed',semente);   %%% para não semear, basta comentar esta linha
randn('seed',semente);  %%% para não semear, basta comentar esta linha


%%% (Inicializa a população atual)
pop=GeneratePopulation(popsize,dim,low,up); % see Eq.1 in [1]
%pop=pop+2^(tempo_de_manipulacao^1);

%%% (Avalia a população atual com a função objetivo "fnc")
%fitnesspop=feval(fnc,pop,popsize,tempo_de_manipulacao,setpoint_desejado,intervalo_amostragem,...
%    target_input_amplitude,target_input_inicio,num_cont,den_cont,num_planta,den_planta,tempo_execucao,delay_fw,delay_fb);
fitnesspop=feval(fnc,pop,popsize,tempo_de_manipulacao,setpoint_desejado,intervalo_amostragem,...
    target_input_amplitude,target_input_inicio,num_cont_k1,den_cont_k1,...
    num_cont_k2,den_cont_k2,num_cont_k,den_cont_k,num_planta_g11,den_planta_g11,...
    num_planta_g12,den_planta_g12,num_planta_g21,den_planta_g21,num_planta_g22,...
    den_planta_g22,tempo_execucao);


%%% (Inicializa a "população histórica")
historical_pop=GeneratePopulation(popsize,dim,low,up); % see Eq.2 in [1]

% historical_pop  is swarm-memory of BSA as mentioned in [1].

% ------------------------------------------------------------------------------------------ 
globalminimum=100000000;
epk=1
%while ((epk<=numero_iteracoes) & (globalminimum>MEMQE)) %%% (Define a condição de parada. No caso epoch é igual ao numero de "gerações")
%while (globalminimum>MEMQE) %%% (Define a condição de parada pela aptidão)    
while (epk<=numero_iteracoes)%%% (Define a condição de parada. No caso epoch é igual ao numero de "gerações")
    
    %SELECTION-I
    %%% (Seleciona a população que será utilizada como "população histórica". Na realidade, a cada nova população gerada, este passo decide se esta será guardada como "população histórica" até que uma próxima seja selecionada para este fim)
    if rand<rand, historical_pop=pop; end  % see Eq.3 in [1] 
    
    %%% (embaralha os indivíduos da "população histórica")
    historical_pop=historical_pop(randperm(popsize),:); % see Eq.4 in [1] 

    %%% (determina a amplitude da direção de busca)
    F=get_scale_factor; % see Eq.5 in [1], you can other F generation strategies 
    
    %%% (Gera a matriz aleatória que mapeia os individuos que sofrerão haverá a mutação e crossover)
    %%% (A matriz "map", é uma matriz de dimensões pop_size x dim, onde pop_size é o tamanho da população 
    %%%  e dim é o número de dimensões do problema)
    %%% (Na matriz "map", cada célula recebe o valor 0 ou 1, aleatoriamente)
    %%% (Em "map", cada "1" significa que o offspring será resultado de uma
    %%% mutação. Cada "0", significa que o offspring será mantido igual ao
    %%% valor da população inicial)
    map=zeros(popsize,dim); % see Algorithm-2 in [1]         
    if rand<rand,
        for i=1:popsize,  u=randperm(dim); map(i,u(1:ceil(DIM_RATE*rand*dim)))=1; end   %%% DIM_RATE estabelece a probabilidade de uma das dimensões ser escolhida em detrimento da(s) outra(s)
    else
        for i=1:popsize,  map(i,randi(dim))=1; end
    end
    
    
    % RECOMBINATION (MUTATION+CROSSOVER)   
    offsprings=pop+(map.*F).*(historical_pop-pop);   % see Eq.5 in [1]    
    offsprings=BoundaryControl(offsprings,low,up); % see Algorithm-3 in [1]
    % SELECTON-II
    fitnessoffsprings=feval(fnc,offsprings,popsize,tempo_de_manipulacao,setpoint_desejado,intervalo_amostragem,...
        target_input_amplitude,target_input_inicio,num_cont_k1,den_cont_k1,...
        num_cont_k2,den_cont_k2,num_cont_k,den_cont_k,num_planta_g11,den_planta_g11,...
        num_planta_g12,den_planta_g12,num_planta_g21,den_planta_g21,num_planta_g22,...
        den_planta_g22,tempo_execucao);
    ind=fitnessoffsprings<fitnesspop;
    fitnesspop(ind)=fitnessoffsprings(ind);
    pop(ind,:)=offsprings(ind,:);
    [globalminimum,ind]=min(fitnesspop);    
    globalminimizer=pop(ind,:);
    % EXPORT SOLUTIONS 
    assignin('base','globalminimizer',globalminimizer);
    assignin('base','globalminimum',globalminimum);
    assignin('base','iteracoes_bsa',epk);
    %fprintf('BSA|%5.0f -----> %9.16f\n',epk,globalminimum);

    epk=epk+1
    globalminimum
end
return

function pop=GeneratePopulation(popsize,dim,low,up)
pop=ones(popsize,dim);
for i=1:popsize
    for j=1:dim
        pop(i,j)=rand*(up(j)-low(j))+low(j);
    end
end
%pop(1,:)=[.3379 .2793 -1.5462 .5646 .1701 -.1673]; % Semente para teste do algoritmo
return

function pop=BoundaryControl(pop,low,up)
[popsize,dim]=size(pop);
for i=1:popsize
    for j=1:dim                
        k=rand<rand; % you can change boundary-control strategy
        if pop(i,j)<low(j), if k, pop(i,j)=low(j); else pop(i,j)=rand*(up(j)-low(j))+low(j); end, end        
        if pop(i,j)>up(j),  if k, pop(i,j)=up(j);  else pop(i,j)=rand*(up(j)-low(j))+low(j); end, end        
    end
end
return


    %%% (determina a amplitude da direção de busca. O valor "3" e o método aleatório pode ser alterado)
function F=get_scale_factor % you can change generation strategy of scale-factor,F    
     F=1*randn; % STANDARD brownian-walk
    % F=4*randg;  % brownian-walk    
    % F=lognrnd(rand,5*rand);  % brownian-walk              
    % F=1/normrnd(0,5);        % pseudo-stable walk (levy-like)
    % F=1./gamrnd(1,0.5);      % pseudo-stable walk (levy-like, simulates inverse gamma distribution; levy-distiribution)   
return