%Ataque nas 25 primeiras amostras, tal=50% tal do sistema original
%800 iteracoes

  function ObjVal = fnc(x,popsize,tempo_de_manipulacao,setpoint_desejado,intervalo_amostragem,...
      target_input_amplitude,target_input_inicio,num_cont_k1,den_cont_k1,...
      num_cont_k2,den_cont_k2,num_cont_k,den_cont_k,num_planta_g11,den_planta_g11,...
      num_planta_g12,den_planta_g12,num_planta_g21,den_planta_g21,num_planta_g22,...
      den_planta_g22,tempo_execucao)
   
    amostras_execucao=tempo_execucao/intervalo_amostragem+1;
  
    for p = 1:popsize
       
        % Define o tempo de execução 
        %tempo_execucao=(tempo_de_manipulacao)*intervalo_amostragem;  % calcula o tempo de execução da simulação
        
        % Cria o vetor de tempo para o ataque ===== ESSE VETOR TEMPO NÃO É
        % USADO
        t=0;
        while t*intervalo_amostragem <= tempo_execucao
            tempo(t+1,1)=t*intervalo_amostragem;
            t=t+1;
        end
        
       % Cria o vetor de packet loss no forward_1
        forward_dec_1 = round(x(p,1));
        forward_bin_1 = dec2bin(forward_dec_1);
        for i=1:size(forward_bin_1,2)
            split_forward_bin_1(i)=forward_bin_1(:,i)-'0';
        end  
        forward_1=[split_forward_bin_1 ones(1,(amostras_execucao-size(split_forward_bin_1,2)))]';
  

        % Cria o vetor de packet loss no feedback_1
        feedback_dec_1 = round(x(p,2));
        feedback_bin_1 = dec2bin(feedback_dec_1);
        for i=1:size(feedback_bin_1,2)
            split_feedback_bin_1(i)=feedback_bin_1(:,i)-'0';
        end      
        feedback_1=[split_feedback_bin_1 ones(1,(amostras_execucao-size(split_feedback_bin_1,2)))]';  
  

        % Cria o vetor de packet loss no forward_2
        forward_dec_2 = round(x(p,3));
        forward_bin_2 = dec2bin(forward_dec_2);
        for i=1:size(forward_bin_2,2)
            split_forward_bin_2(i)=forward_bin_2(:,i)-'0';
        end  
        forward_2=[split_forward_bin_2 ones(1,(amostras_execucao-size(split_forward_bin_2,2)))]';

        
        % Cria o vetor de packet loss no feedback_2
        feedback_dec_2 = round(x(p,4));
        feedback_bin_2 = dec2bin(feedback_dec_2);
        for i=1:size(feedback_bin_2,2)
            split_feedback_bin_2(i)=feedback_bin_2(:,i)-'0';
        end      
        feedback_2=[split_feedback_bin_2 ones(1,(amostras_execucao-size(split_feedback_bin_2,2)))]';   
 
        
        
        
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
      
      simOut=sim('modelo');


% alvo 
      alvo=[0
            0.2182
            0.3888
            0.5222
            0.6264
            0.7079
            0.7717
            0.8215
            0.8604
            0.8909
            0.9147
            0.9333
            0.9479
            0.9592
            0.9681
            0.9751
            0.9805
            0.9848
            0.9881
            0.9907
            0.9927
            0.9943
            0.9956
            0.9965
            0.9973
            0.9979];    

        erro_convergencia=output_N(1:25,1)-alvo(1:25,1);
        o2 = sum(erro_convergencia.*erro_convergencia)/size(erro_convergencia,1);
      
      
        

        ObjVal(p) = o2;

    clear tempo forward_dec_1 forward_bin_1 split_forward_bin_1 forward_1 feedback_dec_1 feedback_bin_1 split_feedback_bin_1 feedback_1             
    clear forward_dec_2 forward_bin_2 split_forward_bin_2 forward_2 feedback_dec_2 feedback_bin_2 split_feedback_bin_2 feedback_2                 
    end  
    
  return