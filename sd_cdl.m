% Autor: Alan Oliveira de Sá
% PPGI - UFRJ

% % Sistema atacado - Dados da Planta:
num_planta_g11=[0.4343 0.0595];
den_planta_g11=[1 2.532 1.841 0.1483];
num_planta_g12=[-0.8796 -0.7657 -0.0366];
den_planta_g12=[0.69 2.747 3.802 1.943 0.1483];
num_planta_g21=[1.008 1.87 0.1405];
den_planta_g21=[1 2.532 1.841 0.1483];
num_planta_g22=[0.6895 0.035];
den_planta_g22=[0.69 2.747 3.802 1.943 0.1483];


% % Sistema atacado - Dados do Controlador:
num_cont_k1=[0.7765];
den_cont_k1=[1 -0.9418];
num_cont_k2=[0.0003655 0.00004839];
den_cont_k2=[1 -0.9602];
num_cont_k=[-0.2307];
den_cont_k=[1 -0.9231];
intervalo_amostragem= 0.8;


% Sistema atacado - Dados do setpoint:
target_input_amplitude=[1];
target_input_inicio=[0];

% Dados do ruído
%amplitude_ruido=0.01; % considerando a amplitude como 2 x desvio padrão

% Parâmetros do SD-Controlled Data Loss
tempo_de_manipulacao = 25; %50;%100; % Número de amostras
setpoint_desejado = 0.96; % Objetivo do atacante caso deseje erro "estacionario"
%tempo_execucao=(inicio_ataque_maximo+tempo_de_manipulacao)*intervalo_amostragem;  % calcula o tempo de execução da simulação

% Parâmetros da simulação:
amostras_execucao = 200;
tempo_execucao = amostras_execucao*intervalo_amostragem;


for semente=1:10%00

    rand('seed',semente);   %%% para não semear, basta comentar esta linha

    semente_ruido=[semente];

%     model = 'modelo';
%     load_system(model);
%     mdlWks = get_param('modelo','ModelWorkspace');
%     assignin('base','target_input_amplitude',target_input_amplitude); %Escreve a variável no workspace para ser lida pelo Simulink
%     assignin('base','target_input_inicio',target_input_inicio); %Escreve a variável no workspace para ser lida pelo Simulink
%     assignin('base','num_cont',num_cont); %Escreve a variável no workspace para ser lida pelo Simulink
%     assignin('base','den_cont',den_cont); %Escreve a variável no workspace para ser lida pelo Simulink
%     assignin('base','num_planta',num_planta); %Escreve a variável no workspace para ser lida pelo Simulink
%     assignin('base','den_planta',den_planta); %Escreve a variável no workspace para ser lida pelo Simulink
%     assignin('base','intervalo_amostragem',intervalo_amostragem); %Escreve a variável no workspace para ser lida pelo Simulink
%     assignin(mdlWks,'tempo_execucao',tempo_execucao); %Escreve a variável no workspace para ser lida pelo Simulink
%     save_system

    % Executa o BSA
    %bsa(semente,tempo_de_manipulacao,setpoint_desejado,intervalo_amostragem,...
    %    target_input_amplitude,target_input_inicio,num_cont,den_cont,num_planta,den_planta,tempo_execucao,delay_fw,delay_fb)
    bsa(semente,tempo_de_manipulacao,setpoint_desejado,intervalo_amostragem,...
        target_input_amplitude,target_input_inicio,num_cont_k1,den_cont_k1,...
        num_cont_k2,den_cont_k2,num_cont_k,den_cont_k,num_planta_g11,den_planta_g11,...
        num_planta_g12,den_planta_g12,num_planta_g21,den_planta_g21,num_planta_g22,...
        den_planta_g22,tempo_execucao)

    % Verifica a saída
    
        % Define o tempo de execução
        %tempo_execucao=(tempo_de_manipulacao)*intervalo_amostragem;  % calcula o tempo de execução da simulação
        
        % Cria o vetor de tempo para o ataque
        t=0;
        while t*intervalo_amostragem <= tempo_execucao
            tempo(t+1,1)=t*intervalo_amostragem;
            t=t+1;
        end
       
      
        % Cria o vetor de packet loss no forward_1
        forward_dec_1 = round(globalminimizer(1));
        forward_bin_1 = dec2bin(forward_dec_1);
        for i=1:size(forward_bin_1,2)
            split_forward_bin_1(i)=forward_bin_1(:,i)-'0';
        end  
        forward_1=[split_forward_bin_1 ones(1,(amostras_execucao+1-size(split_forward_bin_1,2)))]';
        forward_ataque_1=forward_1;
        
        % Cria o vetor de packet loss no feedback_1
        feedback_dec_1 = round(globalminimizer(2));
        feedback_bin_1 = dec2bin(feedback_dec_1);
        for i=1:size(feedback_bin_1,2)
            split_feedback_bin_1(i)=feedback_bin_1(:,i)-'0';
        end      
        feedback_1=[split_feedback_bin_1 ones(1,(amostras_execucao+1-size(split_feedback_bin_1,2)))]';  
        feedback_ataque_1=feedback_1;
        
        % Cria o vetor de packet loss no forward_2
        forward_dec_2 = round(globalminimizer(3));
        forward_bin_2 = dec2bin(forward_dec_2);
        for i=1:size(forward_bin_2,2)
            split_forward_bin_2(i)=forward_bin_2(:,i)-'0';
        end  
        forward_2=[split_forward_bin_2 ones(1,(amostras_execucao+1-size(split_forward_bin_2,2)))]';
        forward_ataque_2=forward_2;

        % Cria o vetor de packet loss no feedback_2
        feedback_dec_2 = round(globalminimizer(4));
        feedback_bin_2 = dec2bin(feedback_dec_2);
        for i=1:size(feedback_bin_2,2)
            split_feedback_bin_2(i)=feedback_bin_2(:,i)-'0';
        end      
        feedback_2=[split_feedback_bin_2 ones(1,(amostras_execucao+1-size(split_feedback_bin_2,2)))]'; 
        feedback_ataque_2=feedback_2;
      
        
      assignin('base','tempo_execucao',tempo_execucao); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','tempo',tempo); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','target_input_amplitude',target_input_amplitude); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','target_input_inicio',target_input_inicio); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','intervalo_amostragem',intervalo_amostragem); %Escreve a variável no workspace para ser lida pelo Simulink      
      assignin('base','forward_1',forward_1); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','feedback_1',feedback_1); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','forward_2',forward_2); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','feedback_2',feedback_2); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','num_cont_k1',num_cont_k1); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','den_cont_k1',den_cont_k1); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','num_cont_k2',num_cont_k2); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','den_cont_k2',den_cont_k2); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','num_cont_k',num_cont_k); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','den_cont_k',den_cont_k); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','num_planta_g11',num_planta_g11); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','den_planta_g11',den_planta_g11); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','num_planta_g12',num_planta_g12); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','den_planta_g12',den_planta_g12); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','num_planta_g21',num_planta_g21); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','den_planta_g21',den_planta_g21); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','num_planta_g22',num_planta_g22); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','den_planta_g22',den_planta_g22); %Escreve a variável no workspace para ser lida pelo Simulink 
        
   
      simOut=sim('modelo_chk');
      resposta_ataque_1=output_N;
      resposta_ataque_2=output_Q;
      control_ataque_1=control_signal_1;
      control_ataque_2=control_signal_2;
      
      % Resposta sem ataque
      forward_1=ones(amostras_execucao+1,1);
      feedback_1=ones(amostras_execucao+1,1);
      forward_2=ones(amostras_execucao+1,1);
      feedback_2=ones(amostras_execucao+1,1);
      assignin('base','forward_1',forward_1); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','feedback_1',feedback_1); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','forward_2',forward_2); %Escreve a variável no workspace para ser lida pelo Simulink
      assignin('base','feedback_2',feedback_2); %Escreve a variável no workspace para ser lida pelo Simulink
      simOut=sim('modelo_chk');
      resposta_sem_ataque_1=output_N;
      resposta_sem_ataque_2=output_Q;
    
    % PLOTAR RESPOSTA AO CONTROLE DE VELOCIDADE (N)
    subplot(6,2,[1,2,3,4])
    plot(tempo,resposta_ataque_1,'r');
    hold on
    plot(tempo,setpoint_n,'k'); 
    plot(tempo,control_signal_1,'m');
    plot(tempo,resposta_sem_ataque_1,'b');
    plot(tempo,control_ataque_1,'y');
    title('VELOCIDADE');
    legend('Resposta ataque','Setpoint','Controle','Resposta sem ataque','Controle atacado');
    hold off
    
    subplot(6,2,5)
    plot(tempo,forward_ataque_1,'+');
    legend('Forward 1');
    
    subplot(6,2,6)
    plot(tempo,feedback_ataque_1,'+'); 
    legend('Feedback 1');
    
    % PLOTAR RESPOSTA AO CONTROLE DE TORQUE (Q)
    subplot(6,2,[7,8,9,10])  
    plot(tempo,resposta_ataque_2,'r');
    hold on
    plot(tempo,setpoint_q,'k'); 
    plot(tempo,control_signal_2,'m');
    plot(tempo,resposta_sem_ataque_2,'b');
    plot(tempo,control_ataque_2,'y');
    title('TORQUE');
    legend('Resposta ataque','Setpoint','Controle','Resposta sem ataque','Controle atacado');
    hold off
    
    subplot(6,2,11)
    plot(tempo,forward_ataque_2,'+');
    legend('Forward 2')
    
    subplot(6,2,12)
    plot(tempo,feedback_ataque_2,'+');
    legend('Feedback 2');
    

    % Salva todos os resultados
    resultados(semente,:) = globalminimizer;
    minimos_globais(semente,:) = globalminimum;
    
    
    
    % Salva o workspace
    arq_saida = ['workspace\sd_cdl_semente',num2str(semente),'.mat']   
    save (arq_saida)
    
end