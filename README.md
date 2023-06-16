
# Projeto de Criação de Máquina Virtual no Azure com Nginx usando Terraform

Este projeto demonstra como usar o Terraform para criar uma máquina virtual no Azure e configurá-la com o servidor web Nginx. A máquina virtual será provisionada em uma nova rede virtual, um novo grupo de recursos e uma sub-rede específica no Azure.

## Pré-requisitos

Antes de começar, verifique se você atende aos seguintes requisitos:

-   [Terraform](https://www.terraform.io/downloads.html) instalado em sua máquina local.
-   Conta do Azure com as credenciais de acesso configuradas localmente.
-   Conhecimento básico de como usar o Terraform e provisionar recursos no Azure.

## Configuração

Siga as etapas abaixo para configurar e executar o projeto:

1.  Clone o repositório para sua máquina local:
    
    `git clone <URL_DO_REPOSITÓRIO>` 
    
2.  Navegue até o diretório do projeto:
    
       
    `cd <diretório_do_projeto>` 
    
3.  Crie um arquivo chamado `terraform.tfvars` e adicione as variáveis de usuário e senha:
    
	`admin_username = "seu_usuario"` 
  
	`admin_password = "sua_senha"`
    
	Substitua "seu_usuario" pelo nome de usuário desejado e "sua_senha" pela senha desejada.
    
4.  Abra o arquivo `main.tf` e verifique se as configurações atendem às suas necessidades. Você pode personalizar outros parâmetros, como nome da máquina virtual, localização, tamanho, etc.
    
5.  No terminal ou prompt de comando, execute o comando `terraform init` para inicializar o diretório do projeto.
    
6.  Em seguida, execute o comando `terraform plan` para visualizar o plano de execução e verificar se não há erros no código.
    
7.  Se o plano de execução estiver correto, execute o comando `terraform apply` para criar a máquina virtual no Azure. Confirme a execução digitando "yes" e pressionando Enter.
    
8.  Aguarde enquanto o Terraform provisiona os recursos no Azure. Isso pode levar alguns minutos.
    
9.  Após a conclusão bem-sucedida, você verá uma mensagem indicando que os recursos foram criados. Você também pode verificar o portal do Azure para confirmar a criação da máquina virtual.
    

## Acesso ao Nginx

Após a criação da máquina virtual, você pode acessar o Nginx em execução usando o endereço IP público atribuído à máquina na porta 80. Basta abrir um navegador e acessar `http://<endereço_ip_da_máquina_virtual>`.

## Limpeza

Para evitar custos adicionais, é recomendável executar a limpeza dos recursos criados após concluir o teste ou uso do ambiente. Execute o seguinte comando para destruir os recursos provisionados:

bashCopy code

`terraform destroy` 

Confirme a destruição digitando "yes" e pressionando Enter. Aguarde até que todos os recursos sejam removidos do Azure.
