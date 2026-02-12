# AsPa - Assistente Parkinson

O **AsPa** é um assistente mobile desenvolvido para auxiliar pacientes com Parkinson no gerenciamento de sua rotina, medicamentos e exercícios, promovendo maior autonomia e qualidade de vida.

## 📲 Instalação e Execução
Para testar o aplicativo, não é necessário configurar ambientes de desenvolvimento complexos. O app já está buildado para Android:

1. **Download:** Baixe o arquivo APK localizado na pasta `/android/app` (ou na seção de [Android](https://github.com/derickdtc/AsPa/tree/main/aspa/android/app)).
2. **Instalação:** Transfira o APK para um dispositivo Android (versão 10 ou superior).
3. **Permissões:** Ao abrir, conceda as permissões de **Notificação** e desative a **Otimização de Bateria** para garantir que os alertas de medicamentos funcionem corretamente, conforme detalhado no manual.

## 🛠️ Tecnologias e Estrutura
O projeto foi construído com foco em performance mobile e persistência de dados local:

* **Linguagem/Framework:** Flutter para Android Nativo.
* **Persistência de Dados:** SQLite (via Room) para armazenamento seguro das rotinas do paciente.
* **Arquitetura:** Baseada em componentes nativos do Android, garantindo integração com o sistema de alarmes e notificações do dispositivo.
* **Design:** Interface desenvolvida seguindo princípios de acessibilidade para usuários com limitações motoras.

## 📚 Documentação e Links
Para uma análise profunda da engenharia por trás do projeto, consulte os materiais oficiais:

* **Repositório do Projeto:** [github.com/derickdtc/AsPa](https://github.com/derickdtc/AsPa)
* **Documento II (Implementação e Manuais):** [Clique aqui para visualizar o PDF](./docs/ESII_2025-2_-_AsPa_-_Documento_II_-_Implementação_Implantação_Configurações_e_Manuais.pdf)
  * *Este documento contém o DER, Diagramas de Classe, Manuais de Instalação e o Plano de Testes.*

## 🏗️ Evidências de Engenharia (Qualidade)
* **Histórico de Alterações:** Documentado detalhadamente no PDF e refletido nos commits do GitHub.
* **Padrões de Interface:** Uso de componentes padrão Android para garantir previsibilidade de uso.
* **Tratamento de Exceções:** Sistema de log e tratamento de erros de conexão e permissões, conforme a seção de *Troubleshooting* do manual.

---
**Componentes do Grupo:** Derick Teles, Gustavo Assunção, Maria Luiza Andrade e Rafael Santos.  
**Disciplina:** Engenharia de Software II (2025.2) - Profª Dra. Adicinéia A. de Oliveira.
