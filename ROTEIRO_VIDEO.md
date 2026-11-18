# Roteiro do vídeo pitch — Sentinela (3 minutos)

**Formato:** gravação da tela do emulador com narração. Antes de gravar: conta criada, cenário **Calmo** selecionado (Configurações → desligar clima real → Calmo), "Limpar alertas salvos", localização do emulador em `-23.5505, -46.6333`, e feche o app para começar pela tela de consentimento (revogue o consentimento nas Configurações).

**Ritmo:** cerca de 140 palavras por minuto. Cada bloco tem a fala e a ação na tela. Total: ~420 palavras.

---

## 0:00 – 0:20 · Abertura (problema)

**Tela:** banner do README ou o ícone do app em tela cheia, depois a tela de consentimento.

> Todo ano, cidades brasileiras perdem vidas e dinheiro com alagamentos, deslizamentos e secas que davam sinais dias antes. Os dados existem, mas chegam dispersos e sem explicação, e a gestão acaba reagindo em vez de prevenir.
>
> O **Sentinela** é um painel de inteligência territorial que reúne esses sinais no celular do gestor e do cidadão, e gera alertas preditivos que explicam o próprio raciocínio.

## 0:20 – 0:40 · Consentimento e entrada

**Ação:** rolar a tela de consentimento, marcar a caixa, Continuar. Fazer login.

> Antes de qualquer dado, o app pede consentimento explícito e explica o que coleta: a conta é local, a senha vira um hash, e os relatos são anônimos. A localização só é usada quando a pessoa pede.

## 0:40 – 1:00 · Visão geral

**Ação:** tela inicial. Apontar o aviso de decisão humana, os cards de benefício social e os três painéis.

> Esta é a central de decisões. Logo no topo, o princípio do projeto: os alertas apoiam, mas não substituem, a decisão humana. Abaixo, o indicador de benefício social, quantos moradores estão cobertos por alertas, e os três painéis do território.

## 1:00 – 1:25 · Alerta sendo gerado

**Ação:** Configurações → cenário **Tempestade** → voltar. Os alertas aparecem no início. Abrir **Alagamento**.

> Vou simular uma frente de tempestade. O motor recalcula na hora, e surgem os alertas de chuva intensa, alagamento e deslizamento nas encostas.
>
> Cada alerta mostra as evidências que o justificam, o nível de confiança com a regra que o calculou, as limitações dos dados, a ação sugerida e o ponto no mapa. Nada é decidido sozinho.

## 1:25 – 1:50 · Painéis e indicador

**Ação:** aba Painéis → Clima (rolar pelo gráfico de chuva com barras vermelhas) → tocar no card **Chuva** → detalhe do indicador → rolar até "Quando não confiar". Depois passar rápido por Recursos e Serviços.

> O painel de Clima traz trinta dias de histórico com tendência semanal. Cada indicador abre um detalhe que explica como a tendência é calculada e, principalmente, quando não confiar nela.
>
> Recursos acompanha água e energia e detecta vazamentos pelo consumo; Serviços organiza os relatos dos cidadãos por região e tipo.

## 1:50 – 2:20 · Relato do cidadão com GPS e clima real

**Ação:** Início → **Registrar alerta** → "Usar minha localização" → mostrar região sugerida, mini-mapa e condições do momento → escolher tipo, prioridade, descrever → salvar. Ir à aba **Mapa** e tocar no marcador novo.

> O cidadão participa. Com um toque, o app usa o GPS para sugerir a região e busca o clima real daquele ponto na Open-Meteo, que já sugere o tipo de ocorrência. A localização, se anexada, é arredondada a um quilômetro. O relato entra no mapa e no histórico, anônimo.

## 2:20 – 2:40 · Limiares e modo offline

**Ação:** Configurações → **Limiares de alerta** → mudar "Chuva intensa" para 100 e salvar (alerta de chuva some). Voltar, ligar **Simular falha de rede**, Recarregar: aviso de cache aparece.

> O gestor ajusta os limiares à realidade do território, e os alertas são recalculados na hora. Sem conexão, o app continua útil: mostra os últimos dados salvos, avisa que são do cache e reduz a confiança dos alertas.

## 2:40 – 3:00 · Acessibilidade e fechamento

**Ação:** Configurações → tema **Alto contraste** e texto a 140%. Voltar ao início. Fechar no ícone.

> Alto contraste, texto ampliado e leitor de tela em todos os elementos, porque informação de risco precisa chegar a todos.
>
> Sentinela: antecipar o risco, explicar o motivo, e deixar a decisão com quem responde por ela. Obrigado.

---

## Checklist de gravação

- [ ] Até 3 minutos (teste o tempo lendo em voz alta antes de gravar)
- [ ] Todas as telas aparecem: consentimento, login, início, alerta, painéis (3), indicador, registrar, mapa, histórico, limiares, configurações, perfil (mostre o perfil por 2 s ao passar pelas configurações)
- [ ] O alerta sendo gerado e sua justificativa aparecem (bloco 1:00)
- [ ] Voz clara ou legenda; sem música alta por cima da fala
- [ ] Emulador em tamanho grande na tela, sem o terminal visível
- [ ] Publicar no YouTube como **não listado** (acesso público pelo link) e colar o link no README e no ENTREGA.txt
